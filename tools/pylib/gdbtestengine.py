"""
gdbtestengine -- Spec-based code test engine for Oberon RTK programs.
--
Parses .spec files, resolves locations to absolute breakpoint addresses,
and executes check/trace actions on hardware via GDB. Supports JLink
and OpenOCD servers with auto-detection.
Features:
  - Declarative spec language (check, trace, start/stop directives)
  - Cross-module constant resolution from .alst and .map data
  - Comparison operators (=, #, >, <, >=, <=), NIL, signed/unsigned
  - Sentinel conditions (when hits=N, when var=value, stop after all checks)
  - Halt on failure with interactive GDB inspection
  - Timestamped reports
--
Environment variables (GDB mode):
    SPEC                     Spec filename (required).
    RTK_PROJECT_DIR          Project root (default: cwd). Must contain rdb/, *.elf, *.map.
    RTK_GDB_TESTS_SPECS_DIR  Spec directory within project (default: rdb-gdb-tests/specs).
                             Spec resolves to: project_dir / RTK_GDB_TESTS_SPECS_DIR / SPEC
    RTK_REPORTS_DIR          Report output directory
                             (default: specs_dir parent / reports -> rdb-gdb-tests/reports).
Usage (inside GDB -- full execution):
    (gdb) set environment SPEC halt-test.spec
    (gdb) run-test
The run-test command must be defined in ~/.gdbinit or a local .gdbinit
as a GDB alias that sources this script.
Usage (batch):
    SPEC=halt-test.spec arm-none-eabi-gdb-py3 -batch \
        -x gdbtestengine.py
Usage (standalone -- parse/resolve only):
    python gdbtestengine.py <spec-file> [project-dir]
--
Copyright (c) 2026 Gray, gray@grayraven.org
https://oberon-rtk.org/licences/
"""
import re
import sys
import threading
import time
from dataclasses import dataclass, field
from pathlib import Path
@dataclass
class Value:
    kind: str
    raw: str
    int_value: int = None
    module: str = None
    name: str = None
    signedness: str = None
@dataclass
class Address:
    kind: str
    raw: str
    int_value: int = None
    module: str = None
    name: str = None
    offset: int = None
@dataclass
class Indirect:
    source_type: str
    source_name: str
    offset_sign: str = None
    offset: 'Value' = None
@dataclass
class Target:
    target_type: str
    var_ref: str = None
    address: 'Address' = None
    indirect: 'Indirect' = None
    bit_range: tuple = None
@dataclass
class Action:
    kind: str
    target: Target
    op: str = '='
    expected: Value = None
    halt: bool = False
@dataclass
class LocationBlock:
    location_type: str
    location_value: object = None
    actions: list = field(default_factory=list)
@dataclass
class ProcBlock:
    qual_name: str
    locations: list = field(default_factory=list)
@dataclass
class Condition:
    kind: str
    hits_value: int = None
    var_ref: str = None
    var_value: Value = None
@dataclass
class Directive:
    kind: str
    qual_name: str = None
    location_type: str = None
    location_value: object = None
    condition: Condition = None
    stop_type: str = None
    stop_value: int = None
    option_name: str = None
    option_value: str = None
@dataclass
class TestSpec:
    directives: list = field(default_factory=list)
    proc_blocks: list = field(default_factory=list)
    options: dict = field(default_factory=dict)
    hex_style: str = 'oberon'
_HEX_0X = re.compile(r'0x[0-9a-fA-F]+')
_HEX_H = re.compile(r'[0-9][0-9a-fA-F]*H')
_INTEGER = re.compile(r'-?\d+')
_IDENT = re.compile(r'[a-zA-Z_]\w*')
def _tokenise_line(line):
    tokens = []
    i = 0
    while i < len(line):
        c = line[i]
        if c in ' \t':
            i += 1
            continue
        if c == '#':
            tokens.append(('HASH', '#'))
            i += 1
        elif c == '.':
            tokens.append(('DOT', '.'))
            i += 1
        elif c == '+':
            tokens.append(('PLUS', '+'))
            i += 1
        elif c == '-':
            if i + 1 < len(line) and line[i + 1] == '-':
                break
            if i + 1 < len(line) and line[i + 1].isdigit():
                if not tokens or tokens[-1][0] in (
                        'EQUALS', 'HASH', 'LESS', 'GREATER',
                        'LESSEQUAL', 'GREATEREQUAL', 'LBRACKET'):
                    m = _INTEGER.match(line, i)
                    if m:
                        tokens.append(('INTEGER', m.group()))
                        i = m.end()
                        continue
            tokens.append(('MINUS', '-'))
            i += 1
        elif c == '=':
            tokens.append(('EQUALS', '='))
            i += 1
        elif c == '<':
            if i + 1 < len(line) and line[i + 1] == '=':
                tokens.append(('LESSEQUAL', '<='))
                i += 2
            else:
                tokens.append(('LESS', '<'))
                i += 1
        elif c == '>':
            if i + 1 < len(line) and line[i + 1] == '=':
                tokens.append(('GREATEREQUAL', '>='))
                i += 2
            else:
                tokens.append(('GREATER', '>'))
                i += 1
        elif c == '[':
            tokens.append(('LBRACKET', '['))
            i += 1
        elif c == ']':
            tokens.append(('RBRACKET', ']'))
            i += 1
        elif c == ':':
            tokens.append(('COLON', ':'))
            i += 1
        else:
            m = _HEX_0X.match(line, i)
            if m:
                tokens.append(('HEX', m.group()))
                i = m.end()
                continue
            m = _HEX_H.match(line, i)
            if m:
                tokens.append(('HEX', m.group()))
                i = m.end()
                continue
            m = _INTEGER.match(line, i)
            if m:
                tokens.append(('INTEGER', m.group()))
                i = m.end()
                continue
            m = _IDENT.match(line, i)
            if m:
                tokens.append(('IDENT', m.group()))
                i = m.end()
                continue
            raise ParseError(f"unexpected character: {c!r}")
    return tokens
class ParseError(Exception):
    pass
class _TokenStream:
    def __init__(self, tokens):
        self._tokens = tokens
        self._pos = 0
    def peek(self, offset=0):
        idx = self._pos + offset
        if idx < len(self._tokens):
            return self._tokens[idx]
        return None
    def consume(self):
        t = self._tokens[self._pos]
        self._pos += 1
        return t
    def expect(self, kind, value=None):
        t = self.peek()
        if t is None:
            raise ParseError(f"expected {kind}, got end of line")
        if t[0] != kind:
            raise ParseError(f"expected {kind}, got {t[0]} ({t[1]!r})")
        if value is not None and t[1] != value:
            raise ParseError(f"expected {value!r}, got {t[1]!r}")
        return self.consume()
    def at_end(self):
        return self._pos >= len(self._tokens)
    def remaining(self):
        return len(self._tokens) - self._pos
def _parse_hex_value(raw):
    if raw.startswith('0x') or raw.startswith('0X'):
        return int(raw, 16)
    if raw.endswith('H') or raw.endswith('h'):
        return int(raw[:-1], 16)
    raise ParseError(f"invalid hex literal: {raw!r}")
def _fmt_hex(n, style='oberon', pad=0):
    if style == 'oberon':
        h = f"{n:0{pad}X}" if pad else f"{n:X}"
        if h[0] in 'ABCDEF':
            h = '0' + h
        return h + 'H'
    h = f"{n:0{pad}X}" if pad else f"{n:X}"
    return f"0x{h}"
_hex_style = 'oberon'
def _to_display_hex(s):
    if _hex_style == 'c':
        return s
    s2 = s.strip()
    if s2.startswith('0x') or s2.startswith('0X'):
        try:
            return _fmt_hex(int(s2, 16), _hex_style)
        except ValueError:
            pass
    return s
def _parse_value(ts):
    t = ts.peek()
    if t is None:
        raise ParseError("expected value, got end of line")
    if t[0] == 'HEX':
        ts.consume()
        return Value(kind='hex', raw=t[1], int_value=_parse_hex_value(t[1]))
    if t[0] == 'INTEGER':
        ts.consume()
        return Value(kind='integer', raw=t[1], int_value=int(t[1]))
    if t[0] == 'IDENT':
        if t[1] == 'TRUE':
            ts.consume()
            return Value(kind='bool', raw='TRUE', int_value=1)
        if t[1] == 'FALSE':
            ts.consume()
            return Value(kind='bool', raw='FALSE', int_value=0)
        if t[1] == 'NIL':
            ts.consume()
            return Value(kind='nil', raw='NIL', int_value=0)
        if ts.peek(1) and ts.peek(1)[0] == 'DOT':
            module = ts.consume()[1]
            ts.expect('DOT')
            name = ts.expect('IDENT')[1]
            return Value(kind='const_ref', raw=f"{module}.{name}",
                         module=module, name=name)
        raise ParseError(f"expected value, got identifier {t[1]!r} "
                         f"(use Module.Const for constant references)")
    raise ParseError(f"expected value, got {t[0]} ({t[1]!r})")
def _parse_address(ts):
    t = ts.peek()
    if t is None:
        raise ParseError("expected address, got end of line")
    if t[0] == 'HEX':
        ts.consume()
        return Address(kind='hex', raw=t[1],
                       int_value=_parse_hex_value(t[1]))
    if t[0] == 'IDENT':
        module = ts.consume()[1]
        t2 = ts.peek()
        if t2 and t2[0] == 'DOT':
            ts.consume()
            name = ts.expect('IDENT')[1]
            return Address(kind='const_ref', raw=f"{module}.{name}",
                           module=module, name=name)
        raise ParseError(f"expected '.' after module name {module!r}")
    raise ParseError(f"expected address, got {t[0]} ({t[1]!r})")
def _parse_location_address(ts):
    t = ts.peek()
    if t is None:
        raise ParseError("expected address, got end of line")
    if t[0] == 'HEX':
        ts.consume()
        return Address(kind='hex', raw=t[1],
                       int_value=_parse_hex_value(t[1]))
    if t[0] == 'INTEGER':
        ts.consume()
        offset_val = int(t[1])
        return Address(kind='module_offset', raw=t[1],
                       offset=offset_val)
    raise ParseError(f"expected address (hex or integer offset), "
                     f"got {t[0]} ({t[1]!r})")
def _parse_indirect(ts):
    ts.expect('LBRACKET')
    t = ts.peek()
    if t is None:
        raise ParseError("expected indirect expression, got end of line")
    if t[0] == 'IDENT' and t[1] in ('arg', 'local'):
        source_type = ts.consume()[1]
        name = _parse_var_ref(ts)
        offset_sign = None
        offset = None
        t2 = ts.peek()
        if t2 and t2[0] in ('PLUS', 'MINUS'):
            offset_sign = ts.consume()[1]
            offset = _parse_value(ts)
        ts.expect('RBRACKET')
        return Indirect(source_type=source_type, source_name=name,
                        offset_sign=offset_sign, offset=offset)
    if t[0] == 'IDENT' and t[1] not in ('arg', 'local'):
        name = _parse_var_ref(ts)
        offset_sign = None
        offset = None
        t2 = ts.peek()
        if t2 and t2[0] in ('PLUS', 'MINUS'):
            offset_sign = ts.consume()[1]
            offset = _parse_value(ts)
        ts.expect('RBRACKET')
        return Indirect(source_type='var', source_name=name,
                        offset_sign=offset_sign, offset=offset)
    addr = _parse_address(ts)
    offset_sign = None
    offset = None
    t2 = ts.peek()
    if t2 and t2[0] in ('PLUS', 'MINUS'):
        offset_sign = ts.consume()[1]
        offset = _parse_value(ts)
    ts.expect('RBRACKET')
    return Indirect(source_type='address', source_name=None,
                    offset_sign=offset_sign, offset=offset)
def _parse_bit_range(ts):
    if ts.peek() and ts.peek()[0] == 'LBRACKET':
        ts.consume()
        hi = ts.expect('INTEGER')[1]
        ts.expect('COLON')
        lo = ts.expect('INTEGER')[1]
        ts.expect('RBRACKET')
        return (int(hi), int(lo))
    return None
def _parse_target(ts):
    t = ts.peek()
    if t is None:
        raise ParseError("expected target, got end of line")
    if t[0] == 'IDENT' and t[1] == 'arg':
        ts.consume()
        var_ref = _parse_var_ref(ts)
        bit_range = _parse_bit_range(ts)
        return Target(target_type='arg', var_ref=var_ref, bit_range=bit_range)
    if t[0] == 'IDENT' and t[1] == 'local':
        ts.consume()
        var_ref = _parse_var_ref(ts)
        bit_range = _parse_bit_range(ts)
        return Target(target_type='local', var_ref=var_ref, bit_range=bit_range)
    if t[0] == 'IDENT' and t[1] == 'return':
        ts.consume()
        return Target(target_type='return')
    if t[0] == 'IDENT' and t[1] == 'mem':
        ts.consume()
        t2 = ts.peek()
        if t2 and t2[0] == 'LBRACKET':
            t3 = ts.peek(1)
            if t3 and t3[0] == 'IDENT' and t3[1] in ('arg', 'local'):
                indirect = _parse_indirect(ts)
                bit_range = _parse_bit_range(ts)
                return Target(target_type='mem', indirect=indirect,
                              bit_range=bit_range)
            indirect = _parse_indirect(ts)
            bit_range = _parse_bit_range(ts)
            return Target(target_type='mem', indirect=indirect,
                          bit_range=bit_range)
        else:
            address = _parse_address(ts)
            bit_range = _parse_bit_range(ts)
            return Target(target_type='mem', address=address,
                          bit_range=bit_range)
    if t[0] == 'LBRACKET':
        indirect = _parse_indirect(ts)
        bit_range = _parse_bit_range(ts)
        return Target(target_type='mem', indirect=indirect,
                      bit_range=bit_range)
    if t[0] == 'HEX':
        address = _parse_address(ts)
        bit_range = _parse_bit_range(ts)
        return Target(target_type='mem', address=address,
                      bit_range=bit_range)
    if t[0] == 'IDENT':
        var_ref = _parse_var_ref(ts)
        bit_range = _parse_bit_range(ts)
        return Target(target_type='var', var_ref=var_ref, bit_range=bit_range)
    raise ParseError(f"expected target, got {t[1]!r}")
def _parse_var_ref(ts):
    name = ts.expect('IDENT')[1]
    while True:
        t = ts.peek()
        if t is not None and t[0] == 'DOT':
            ts.consume()
            part = ts.expect('IDENT')[1]
            name = f"{name}.{part}"
        elif t is not None and t[0] == 'LBRACKET':
            t1 = ts.peek(1)
            if not (t1 and t1[0] == 'INTEGER'):
                break
            t2 = ts.peek(2)
            if t2 and t2[0] == 'COLON':
                break
            ts.consume()
            idx = ts.expect('INTEGER')[1]
            ts.expect('RBRACKET')
            name = f"{name}[{idx}]"
        else:
            break
    return name
def _parse_qual_name(ts):
    module = ts.expect('IDENT')[1]
    ts.expect('DOT')
    proc = ts.expect('IDENT')[1]
    return f"{module}.{proc}"
def _parse_location(ts):
    ts.expect('IDENT', 'at')
    t = ts.peek()
    if t is None:
        raise ParseError("expected location after 'at'")
    if t[0] == 'IDENT' and t[1] == 'entry':
        ts.consume()
        return 'entry', None
    if t[0] == 'IDENT' and t[1] == 'exit':
        ts.consume()
        return 'exit', None
    if t[0] == 'IDENT' and t[1] == 'line':
        ts.consume()
        line_num = ts.expect('INTEGER')[1]
        return 'line', int(line_num)
    addr = _parse_location_address(ts)
    return 'address', addr
def _parse_condition(ts):
    ts.expect('IDENT', 'when')
    t = ts.peek()
    if t and t[0] == 'IDENT' and t[1] == 'hits':
        ts.consume()
        ts.expect('EQUALS')
        n = ts.expect('INTEGER')[1]
        return Condition(kind='hits', hits_value=int(n))
    var_ref = _parse_var_ref(ts)
    ts.expect('EQUALS')
    val = _parse_value(ts)
    return Condition(kind='var', var_ref=var_ref, var_value=val)
def _get_indent(line):
    stripped = line.lstrip(' ')
    spaces = len(line) - len(stripped)
    return spaces // 2
def parse_spec(text):
    global _hex_style
    spec = TestSpec()
    lines = text.splitlines()
    for scan_line in lines:
        scan_stripped = scan_line.strip()
        if not scan_stripped or scan_stripped.startswith('--'):
            continue
        for tok in _tokenise_line(scan_stripped):
            if tok[0] == 'HEX':
                if tok[1].endswith('H') or tok[1].endswith('h'):
                    spec.hex_style = 'oberon'
                else:
                    spec.hex_style = 'c'
                break
        if spec.hex_style != 'oberon' or any(
                t[0] == 'HEX' for t in _tokenise_line(scan_stripped)):
            break
    _hex_style = spec.hex_style
    i = 0
    while i < len(lines):
        line = lines[i]
        stripped = line.strip()
        if not stripped or stripped.startswith('--'):
            i += 1
            continue
        indent = _get_indent(line)
        try:
            tokens = _tokenise_line(stripped)
        except ParseError as e:
            raise ParseError(f"line {i + 1}: {e}") from None
        if not tokens:
            i += 1
            continue
        ts = _TokenStream(tokens)
        first = tokens[0]
        try:
            if indent == 0:
                if first[1] == 'option':
                    ts.consume()
                    opt_name = ts.expect('IDENT')[1]
                    while ts.peek() and ts.peek()[0] == 'MINUS':
                        ts.consume()
                        part = ts.expect('IDENT')[1]
                        opt_name = f"{opt_name}-{part}"
                    ts.expect('EQUALS')
                    val_parts = []
                    while not ts.at_end():
                        val_parts.append(ts.consume()[1])
                    opt_value = ' '.join(val_parts)
                    d = Directive(kind='option',
                                 option_name=opt_name,
                                 option_value=opt_value)
                    spec.directives.append(d)
                    spec.options[opt_name] = opt_value
                elif first[1] == 'start':
                    ts.consume()
                    ts.expect('IDENT', 'proc')
                    qn = _parse_qual_name(ts)
                    loc_type, loc_value = _parse_location(ts)
                    cond = None
                    if not ts.at_end() and ts.peek()[1] == 'when':
                        cond = _parse_condition(ts)
                    d = Directive(kind='start', qual_name=qn,
                                 location_type=loc_type,
                                 location_value=loc_value,
                                 condition=cond)
                    spec.directives.append(d)
                elif first[1] == 'stop':
                    ts.consume()
                    t2 = ts.peek()
                    if t2 and t2[1] == 'after':
                        ts.consume()
                        t3 = ts.peek()
                        if t3 and t3[1] == 'all':
                            ts.consume()
                            ts.expect('IDENT', 'checks')
                            d = Directive(kind='stop',
                                         stop_type='all_checks')
                            spec.directives.append(d)
                        elif t3 and t3[0] == 'INTEGER':
                            n = int(ts.consume()[1])
                            t4 = ts.peek()
                            if t4 and t4[1] == 'hits':
                                ts.consume()
                                d = Directive(kind='stop',
                                              stop_type='hits',
                                              stop_value=n)
                                spec.directives.append(d)
                            elif t4 and t4[1] == 's':
                                ts.consume()
                                d = Directive(kind='stop',
                                              stop_type='timeout',
                                              stop_value=n)
                                spec.directives.append(d)
                            else:
                                raise ParseError(
                                    "expected 'hits' or 's' after number")
                        else:
                            raise ParseError(
                                "expected 'all checks' or N after 'stop after'")
                    elif t2 and t2[1] == 'proc':
                        ts.consume()
                        qn = _parse_qual_name(ts)
                        loc_type, loc_value = _parse_location(ts)
                        cond = None
                        if not ts.at_end() and ts.peek()[1] == 'when':
                            cond = _parse_condition(ts)
                        d = Directive(kind='stop', qual_name=qn,
                                      location_type=loc_type,
                                      location_value=loc_value,
                                      condition=cond)
                        spec.directives.append(d)
                    else:
                        raise ParseError(
                            "expected 'after' or 'proc' after 'stop'")
                elif first[1] == 'proc':
                    ts.consume()
                    qn = _parse_qual_name(ts)
                    proc_block = ProcBlock(qual_name=qn)
                    i += 1
                    while i < len(lines):
                        loc_line = lines[i]
                        loc_stripped = loc_line.strip()
                        if not loc_stripped or loc_stripped.startswith('--'):
                            i += 1
                            continue
                        loc_indent = _get_indent(loc_line)
                        if loc_indent < 1:
                            break
                        if loc_indent == 1:
                            loc_tokens = _tokenise_line(loc_stripped)
                            loc_ts = _TokenStream(loc_tokens)
                            loc_type, loc_value = _parse_location(loc_ts)
                            loc_block = LocationBlock(
                                location_type=loc_type,
                                location_value=loc_value)
                            i += 1
                            while i < len(lines):
                                act_line = lines[i]
                                act_stripped = act_line.strip()
                                if not act_stripped or \
                                        act_stripped.startswith('--'):
                                    i += 1
                                    continue
                                act_indent = _get_indent(act_line)
                                if act_indent < 2:
                                    break
                                act_tokens = _tokenise_line(act_stripped)
                                act_ts = _TokenStream(act_tokens)
                                action = _parse_action(act_ts)
                                loc_block.actions.append(action)
                                i += 1
                            proc_block.locations.append(loc_block)
                        else:
                            raise ParseError(
                                f"line {i + 1}: unexpected indentation "
                                f"level {loc_indent} in proc block")
                    spec.proc_blocks.append(proc_block)
                    continue
                else:
                    raise ParseError(f"unexpected keyword: {first[1]!r}")
            else:
                raise ParseError(
                    f"unexpected indentation at top level")
        except ParseError as e:
            if not str(e).startswith('line '):
                raise ParseError(f"line {i + 1}: {e}") from None
            raise
        i += 1
    return spec
def _parse_op(ts):
    t = ts.peek()
    if t is None:
        raise ParseError("expected operator")
    if t[0] == 'EQUALS':       ts.consume(); return '='
    if t[0] == 'HASH':         ts.consume(); return '#'
    if t[0] == 'GREATER':      ts.consume(); return '>'
    if t[0] == 'LESS':         ts.consume(); return '<'
    if t[0] == 'GREATEREQUAL': ts.consume(); return '>='
    if t[0] == 'LESSEQUAL':    ts.consume(); return '<='
    raise ParseError(f"expected operator, got {t[1]!r}")
def _parse_action(ts):
    t = ts.peek()
    if t is None:
        raise ParseError("expected 'check' or 'trace'")
    if t[1] == 'check':
        ts.consume()
        target = _parse_target(ts)
        op = _parse_op(ts)
        expected = _parse_value(ts)
        if not ts.at_end() and ts.peek()[1] == 'as':
            ts.consume()
            st = ts.peek()
            if st is None:
                raise ParseError("expected 'signed' or 'unsigned' after 'as'")
            if st[1] == 'signed':
                ts.consume()
                expected.signedness = 'signed'
            elif st[1] == 'unsigned':
                ts.consume()
                expected.signedness = 'unsigned'
            else:
                raise ParseError(f"expected 'signed' or 'unsigned', "
                                 f"got {st[1]!r}")
        if op not in ('=', '#') and expected.kind == 'bool':
            raise ParseError(f"ordered comparison on BOOLEAN value "
                             f"({op} {expected.raw})")
        halt = False
        if not ts.at_end() and ts.peek()[1] == 'halt':
            ts.consume()
            halt = True
        return Action(kind='check', target=target, op=op,
                      expected=expected, halt=halt)
    if t[1] == 'trace':
        ts.consume()
        target = _parse_target(ts)
        return Action(kind='trace', target=target)
    raise ParseError(f"expected 'check' or 'trace', got {t[1]!r}")
def format_spec(spec):
    lines = []
    for d in spec.directives:
        if d.kind == 'option':
            lines.append(f"option {d.option_name} = {d.option_value}")
        elif d.kind == 'start':
            s = f"start proc {d.qual_name} at {d.location_type}"
            if d.location_type == 'line':
                s += f" {d.location_value}"
            elif d.location_type == 'address':
                s += f" {_format_address(d.location_value)}"
            if d.condition:
                s += f" when {_format_condition(d.condition)}"
            lines.append(s)
        elif d.kind == 'stop':
            if d.stop_type == 'all_checks':
                lines.append("stop after all checks")
            elif d.stop_type == 'hits':
                lines.append(f"stop after {d.stop_value} hits")
            elif d.stop_type == 'timeout':
                lines.append(f"stop after {d.stop_value} s")
            elif d.qual_name:
                s = f"stop proc {d.qual_name} at {d.location_type}"
                if d.location_type == 'line':
                    s += f" {d.location_value}"
                elif d.location_type == 'address':
                    s += f" {_format_address(d.location_value)}"
                if d.condition:
                    s += f" when {_format_condition(d.condition)}"
                lines.append(s)
    if spec.directives and spec.proc_blocks:
        lines.append("")
    for pb in spec.proc_blocks:
        lines.append(f"proc {pb.qual_name}")
        for lb in pb.locations:
            loc_str = f"  at {lb.location_type}"
            if lb.location_type == 'line':
                loc_str += f" {lb.location_value}"
            elif lb.location_type == 'address':
                loc_str += f" {_format_address(lb.location_value)}"
            lines.append(loc_str)
            for act in lb.actions:
                lines.append(f"    {_format_action(act)}")
    return '\n'.join(lines)
def _format_value(v):
    if v.kind == 'hex':
        return v.raw
    if v.kind == 'integer':
        return v.raw
    if v.kind == 'bool':
        return v.raw
    if v.kind == 'nil':
        return 'NIL'
    if v.kind == 'const_ref':
        return f"{v.module}.{v.name}"
    return v.raw
def _format_address(a):
    if a.kind == 'hex':
        return a.raw
    if a.kind == 'const_ref':
        return f"{a.module}.{a.name}"
    if a.kind == 'module_offset':
        return f"{a.module} + {a.raw.split('+')[1].strip()}"
    return a.raw
def _format_condition(c):
    if c.kind == 'hits':
        return f"hits = {c.hits_value}"
    return f"{c.var_ref} = {_format_value(c.var_value)}"
def _format_target(t):
    if t.target_type == 'return':
        return "return"
    bits = f" [{t.bit_range[0]}:{t.bit_range[1]}]" if t.bit_range else ""
    if t.target_type == 'var':
        return f"{t.var_ref}{bits}"
    if t.target_type in ('arg', 'local'):
        return f"{t.target_type} {t.var_ref}{bits}"
    s = "mem " if t.target_type == 'mem' else ""
    if t.indirect:
        s += _format_indirect(t.indirect)
    elif t.address:
        s += _format_address(t.address)
    s += bits
    return s
def _format_indirect(ind):
    if ind.source_type == 'address':
        return f"[{ind.source_name}]"
    if ind.source_type == 'var':
        s = f"[{ind.source_name}"
    else:
        s = f"[{ind.source_type} {ind.source_name}"
    if ind.offset_sign:
        s += f" {ind.offset_sign} {_format_value(ind.offset)}"
    s += "]"
    return s
def _format_action(act):
    s = f"{act.kind} {_format_target(act.target)}"
    if act.kind == 'check':
        s += f" {act.op} {_format_value(act.expected)}"
        if act.expected.signedness:
            s += f" as {act.expected.signedness}"
        if act.halt:
            s += " halt"
    return s
class ResolveError(Exception):
    pass
@dataclass
class ResolvedBreakpoint:
    address: int
    qual_name: str
    location_type: str
    location_desc: str
    actions: list
@dataclass
class ResolvedDirective:
    kind: str
    address: int = None
    qual_name: str = None
    location_type: str = None
    condition: Condition = None
    stop_type: str = None
    stop_value: int = None
@dataclass
class ResolvedSpec:
    breakpoints: list
    directives: list
    options: dict
    proc_map: list = field(default_factory=list)
def _import_elfdata():
    tools_dir = str(Path(__file__).resolve().parent)
    if tools_dir not in sys.path:
        sys.path.insert(0, tools_dir)
    import elfdata
    return elfdata
def _parse_oberon_int(text):
    text = text.strip()
    if text.upper().endswith('H'):
        return int(text[:-1], 16)
    return int(text)
_CONST_SECTION_RE = re.compile(
    r'^\s+CONST\s*$', re.MULTILINE)
_SECTION_KW_RE = re.compile(
    r'^\s+(?:TYPE|VAR|PROCEDURE|BEGIN)\b')
_CONST_DECL_RE = re.compile(
    r'^\s+(\w+)\s*\*?\s*=\s*(.+?)\s*;')
_COMMENT_RE = re.compile(r'\(\*.*?\*\)')
def _extract_consts_from_alst(alst_path):
    text = alst_path.read_text(errors='replace')
    lines = text.splitlines()
    const_lines = []
    in_const = False
    for line in lines:
        if _CONST_SECTION_RE.match(line):
            in_const = True
            continue
        if in_const:
            if _SECTION_KW_RE.match(line):
                in_const = False
                continue
            const_lines.append(line)
    raw_defs = {}
    for line in const_lines:
        clean = _COMMENT_RE.sub('', line)
        m = _CONST_DECL_RE.match(clean)
        if m:
            name = m.group(1)
            expr = m.group(2).strip()
            raw_defs[name] = expr
    resolved = {}
    max_iters = len(raw_defs) + 1
    for _ in range(max_iters):
        progress = False
        for name, expr in list(raw_defs.items()):
            if name in resolved:
                continue
            val = _try_eval_const_expr(expr, resolved)
            if val is not None:
                resolved[name] = val
                progress = True
        if not progress:
            break
    return resolved
def _try_eval_const_expr(expr, known):
    expr = expr.strip()
    if '{' in expr:
        return None
    try:
        return _parse_oberon_int(expr)
    except ValueError:
        pass
    for op in (' + ', ' - ', ' * '):
        idx = expr.find(op)
        if idx < 0:
            continue
        left = expr[:idx].strip()
        right = expr[idx + len(op):].strip()
        left_val = _resolve_operand(left, known)
        if left_val is None:
            continue
        right_val = _resolve_operand(right, known)
        if right_val is None:
            continue
        if op == ' + ':
            return left_val + right_val
        elif op == ' - ':
            return left_val - right_val
        elif op == ' * ':
            return left_val * right_val
    if re.fullmatch(r'\w+', expr) and expr in known:
        return known[expr]
    return None
def _resolve_operand(text, known):
    text = text.strip()
    try:
        return _parse_oberon_int(text)
    except ValueError:
        pass
    if re.fullmatch(r'\w+', text) and text in known:
        return known[text]
    return None
def build_const_table(modules):
    table = {}
    for mod in modules:
        mod_consts = {}
        if (hasattr(mod, 'module_src') and mod.module_src is not None
                and hasattr(mod.module_src, 'consts')):
            mod_consts.update(mod.module_src.consts)
        table[mod.name] = mod_consts
    for mod in modules:
        if hasattr(mod, '_alst_path') and mod._alst_path:
            alst_path = mod._alst_path
            if alst_path.exists():
                extracted = _extract_consts_from_alst(alst_path)
                for k, v in extracted.items():
                    table[mod.name][k] = v
    for mod in modules:
        if not (hasattr(mod, '_alst_path') and mod._alst_path
                and mod._alst_path.exists()):
            continue
        text = mod._alst_path.read_text(errors='replace')
        lines = text.splitlines()
        in_const = False
        for line in lines:
            if _CONST_SECTION_RE.match(line):
                in_const = True
                continue
            if in_const:
                if _SECTION_KW_RE.match(line):
                    in_const = False
                    continue
                clean = _COMMENT_RE.sub('', line)
                m = _CONST_DECL_RE.match(clean)
                if m:
                    name = m.group(1)
                    expr = m.group(2).strip()
                    if name in table.get(mod.name, {}):
                        continue
                    qm = re.fullmatch(r'(\w+)\.(\w+)', expr)
                    if qm:
                        ref_mod = qm.group(1)
                        ref_name = qm.group(2)
                        if (hasattr(mod, 'module_src')
                                and mod.module_src is not None):
                            real_mod = mod.module_src.imports.get(
                                ref_mod, ref_mod)
                        else:
                            real_mod = ref_mod
                        if (real_mod in table
                                and ref_name in table[real_mod]):
                            table.setdefault(mod.name, {})[name] = (
                                table[real_mod][ref_name])
    return table
def _resolve_const_refs_in_spec(spec, const_table):
    for pb in spec.proc_blocks:
        for lb in pb.locations:
            for action in lb.actions:
                if (action.expected is not None
                        and action.expected.kind == 'const_ref'):
                    val = _lookup_const(
                        action.expected.module, action.expected.name,
                        const_table)
                    if val is None:
                        raise ResolveError(
                            f"cannot resolve const "
                            f"{action.expected.raw}")
                    action.expected.int_value = val
                if (action.target.address is not None
                        and action.target.address.kind == 'const_ref'):
                    val = _lookup_const(
                        action.target.address.module,
                        action.target.address.name, const_table)
                    if val is None:
                        raise ResolveError(
                            f"cannot resolve const "
                            f"{action.target.address.raw}")
                    action.target.address.int_value = val
                if (action.target.indirect is not None
                        and action.target.indirect.offset is not None
                        and action.target.indirect.offset.kind
                        == 'const_ref'):
                    val = _lookup_const(
                        action.target.indirect.offset.module,
                        action.target.indirect.offset.name,
                        const_table)
                    if val is None:
                        raise ResolveError(
                            f"cannot resolve const "
                            f"{action.target.indirect.offset.raw}")
                    action.target.indirect.offset.int_value = val
    for d in spec.directives:
        if (d.condition is not None
                and d.condition.var_value is not None
                and d.condition.var_value.kind == 'const_ref'):
            val = _lookup_const(
                d.condition.var_value.module,
                d.condition.var_value.name,
                const_table)
            if val is None:
                raise ResolveError(
                    f"cannot resolve const "
                    f"{d.condition.var_value.raw}")
            d.condition.var_value.int_value = val
def _lookup_const(module, name, const_table):
    if module in const_table and name in const_table[module]:
        return const_table[module][name]
    return None
_ADD_SP_RE = re.compile(r'add\s+sp,\s*#(\d+)', re.IGNORECASE)
_POP_PC_RE = re.compile(r'pop(?:\.w)?\s+\{.*pc.*\}', re.IGNORECASE)
_ASM_LINE_RE = re.compile(
    r'^\.\s+(\d+)\s+([0-9A-Fa-f]+)\s+([0-9A-Fa-f]+)\s+(.*)'
)
def _instr_size(hex_instr):
    return 2 if len(hex_instr) <= 5 else 4
def _parse_asm_lines(filepath):
    result = []
    for line in filepath.read_text(errors='replace').splitlines():
        m = _ASM_LINE_RE.match(line)
        if m:
            result.append((
                int(m.group(1)),
                int(m.group(2), 16),
                m.group(3),
                m.group(4).strip(),
            ))
    return result
def _find_exit_address(asm_lines, proc_addr, proc_size):
    proc_end = proc_addr + proc_size
    proc_asm = [(addr, hex_i, mnemo)
                for _, addr, hex_i, mnemo in asm_lines
                if proc_addr <= addr < proc_end]
    if not proc_asm:
        return None
    for i in range(len(proc_asm) - 1, -1, -1):
        addr, hex_i, mnemo = proc_asm[i]
        if _POP_PC_RE.search(mnemo):
            if i > 0:
                prev_addr, _, prev_mnemo = proc_asm[i - 1]
                if _ADD_SP_RE.search(prev_mnemo):
                    return prev_addr
            return addr
    return None
def _find_line_address(line_entries, line_num):
    for le in line_entries:
        if le.line == line_num:
            return le.address
    return None
_MAP_LINE_RE = re.compile(
    r'^(\w+)\s+'
    r'[0-9A-Fa-f]+H\s+\d+\s+'
    r'([0-9A-Fa-f]+)H\s+\d+',
)
def parse_map_code_addrs(map_path):
    result = {}
    for line in Path(map_path).read_text(errors='replace').splitlines():
        m = _MAP_LINE_RE.match(line.strip())
        if m:
            name = m.group(1)
            code_addr = int(m.group(2), 16)
            if name not in ('End', 'Total'):
                result[name] = code_addr
    return result
def resolve_spec(spec, modules, map_path=None):
    elfdata = _import_elfdata()
    mod_by_name = {}
    for mod in modules:
        mod_by_name[mod.name] = mod
    proc_by_name = {}
    for mod in modules:
        for ps in mod.procedures:
            proc_by_name[ps.name] = (ps, mod)
    const_table = build_const_table(modules)
    _resolve_const_refs_in_spec(spec, const_table)
    asm_cache = {}
    code_bases = {}
    if map_path:
        code_bases = parse_map_code_addrs(map_path)
    def get_asm_lines(mod):
        if mod.name not in asm_cache:
            alst_path = None
            for parent_mod in modules:
                if parent_mod is mod:
                    if hasattr(mod, '_alst_path') and mod._alst_path:
                        alst_path = mod._alst_path
                    break
            if alst_path and alst_path.exists():
                asm_cache[mod.name] = _parse_asm_lines(alst_path)
            else:
                asm_cache[mod.name] = []
        return asm_cache[mod.name]
    def find_frame_info(mod, proc_addr):
        for fi in mod.frame_infos:
            if fi.address == proc_addr:
                return fi
        return None
    def resolve_location(qual_name, loc_type, loc_value):
        if loc_type == 'address':
            addr_obj = loc_value
            if addr_obj.kind == 'hex':
                return addr_obj.int_value
        if qual_name not in proc_by_name:
            raise ResolveError(f"procedure {qual_name!r} not found")
        proc_sym, mod = proc_by_name[qual_name]
        if loc_type == 'address':
            addr_obj = loc_value
            module_name = qual_name.split('.')[0]
            base = code_bases.get(module_name)
            if base is None:
                raise ResolveError(
                    f"module {module_name!r} not found in .map file "
                    f"for offset {addr_obj.raw}")
            return base + addr_obj.offset
        if loc_type == 'entry':
            fi = find_frame_info(mod, proc_sym.address)
            if fi is not None:
                return proc_sym.address + fi.push_size + fi.sub_sp_size
            return proc_sym.address
        if loc_type == 'exit':
            asm = get_asm_lines(mod)
            if not asm:
                raise ResolveError(
                    f"no assembly data for {qual_name} — "
                    f"cannot resolve exit point")
            exit_addr = _find_exit_address(asm, proc_sym.address, proc_sym.size)
            if exit_addr is None:
                raise ResolveError(
                    f"cannot find exit point for {qual_name}")
            return exit_addr
        if loc_type == 'line':
            line_num = loc_value
            addr = _find_line_address(mod.line_entries, line_num)
            if addr is None:
                raise ResolveError(
                    f"line {line_num} not found in {mod.name}")
            return addr
        raise ResolveError(f"unknown location type: {loc_type}")
    breakpoints = []
    for pb in spec.proc_blocks:
        for lb in pb.locations:
            try:
                addr = resolve_location(pb.qual_name, lb.location_type,
                                        lb.location_value)
            except ResolveError as e:
                raise ResolveError(
                    f"proc {pb.qual_name} at {lb.location_type}: {e}"
                ) from None
            desc = lb.location_type
            if lb.location_type == 'line':
                desc = f"line {lb.location_value}"
            elif lb.location_type == 'address':
                desc = _fmt_hex(addr, _hex_style, pad=8)
            breakpoints.append(ResolvedBreakpoint(
                address=addr,
                qual_name=pb.qual_name,
                location_type=lb.location_type,
                location_desc=desc,
                actions=lb.actions,
            ))
    resolved_directives = []
    for d in spec.directives:
        if d.kind == 'option':
            continue
        if d.kind in ('start', 'stop') and d.qual_name:
            try:
                addr = resolve_location(d.qual_name, d.location_type,
                                        d.location_value)
            except ResolveError as e:
                raise ResolveError(
                    f"{d.kind} proc {d.qual_name}: {e}") from None
            resolved_directives.append(ResolvedDirective(
                kind=d.kind,
                address=addr,
                qual_name=d.qual_name,
                location_type=d.location_type,
                condition=d.condition,
            ))
        elif d.kind == 'stop' and d.stop_type:
            resolved_directives.append(ResolvedDirective(
                kind='stop',
                stop_type=d.stop_type,
                stop_value=d.stop_value,
            ))
    proc_map = []
    for mod in modules:
        mod_base = code_bases.get(mod.name, 0)
        for ps in mod.procedures:
            proc_map.append((
                ps.address,
                ps.address + ps.size,
                ps.name,
                mod_base,
            ))
    proc_map.sort(key=lambda x: x[0])
    return ResolvedSpec(
        breakpoints=breakpoints,
        directives=resolved_directives,
        options=dict(spec.options),
        proc_map=proc_map,
    )
def load_modules(rdb_dir):
    elfdata = _import_elfdata()
    modules = []
    for alst in sorted(rdb_dir.glob('*.alst')):
        mod = elfdata.parse_listing(alst, source_lines=True)
        if mod is not None:
            mod._alst_path = alst
            modules.append(mod)
    return modules
_DEFAULT_TIMEOUT = 10
_DEFAULT_MAX_HITS = 500
_DEFAULT_HOST = 'localhost:3333'
def _in_gdb():
    try:
        import gdb
        return True
    except ImportError:
        return False
def _is_batch_mode():
    try:
        import gdb
        out = gdb.execute('show interactive-mode', to_string=True)
        return 'currently off' in out
    except Exception:
        return False
def _gdb_execute(cmd):
    import gdb
    try:
        return gdb.execute(cmd, to_string=True)
    except gdb.error as e:
        return f"ERROR: {e}"
def _interrupt_after(seconds):
    import gdb
    def _do_interrupt():
        try:
            gdb.post_event(lambda: gdb.execute('interrupt'))
        except Exception:
            pass
    timer = threading.Timer(seconds, _do_interrupt)
    timer.daemon = True
    timer.start()
    return timer
def _parse_info_output(output):
    result = {}
    if output is None:
        return result
    for line in output.strip().splitlines():
        line = line.strip()
        if not line or line == 'No arguments.' or line == 'No locals.':
            continue
        m = re.match(r'^(\w+)\s*=\s*(.*)', line)
        if m:
            result[m.group(1)] = m.group(2).strip()
    return result
def _is_accessible(value_str):
    return not ('Cannot access memory' in value_str
                or '<error' in value_str
                or 'optimized out' in value_str)
def _parse_gdb_int(value_str):
    s = value_str.strip()
    if s.startswith('0x') or s.startswith('0X'):
        return int(s, 16)
    if s.startswith('-0x') or s.startswith('-0X'):
        return -int(s[1:], 16)
    m = re.match(r'^(-?\d+)', s)
    if m:
        return int(m.group(1))
    return None
def _resolve_global(var_ref, bp, suffix=''):
    base_ref = var_ref
    candidates = []
    if '.' in base_ref:
        module, name = base_ref.split('.', 1)
        candidates.append(f'{module}_{name}')
        candidates.append(f"'{module}.{name}'")
    else:
        module = bp.qual_name.split('.')[0] if bp and bp.qual_name else None
        if module:
            candidates.append(f'{module}_{base_ref}')
            candidates.append(f"'{module}.{base_ref}'")
    for sym in candidates:
        output = _gdb_execute(f'print/x {sym}{suffix}')
        if 'ERROR' not in output and 'No symbol' not in output:
            m = re.search(r'=\s*(0x[0-9a-fA-F]+)', output)
            if m:
                return m.group(1)
            if not suffix:
                m = re.search(r'=\s*\{', output)
                if m:
                    addr_out = _gdb_execute(f'print/x &{sym}')
                    m_addr = re.search(r'=\s*(0x[0-9a-fA-F]+)', addr_out)
                    if m_addr:
                        return m_addr.group(1)
            m = re.search(r'=\s*(-?\d+)', output)
            if m:
                return m.group(1)
    return None
@dataclass
class CheckResult:
    kind: str
    target_desc: str
    status: str
    actual: str = ''
    expected: str = ''
    op: str = '='
    message: str = ''
    hit: int = 0
    location: str = ''
@dataclass
class TestResults:
    results: list = field(default_factory=list)
    passed: int = 0
    failed: int = 0
    errors: int = 0
    traces: int = 0
    def record(self, result):
        self.results.append(result)
        if result.status == 'PASS':
            self.passed += 1
        elif result.status == 'FAIL':
            self.failed += 1
        elif result.status == 'ERROR':
            self.errors += 1
        elif result.status == 'TRACE':
            self.traces += 1
def _is_unsigned(expected):
    if expected.signedness == 'signed':
        return False
    if expected.signedness == 'unsigned':
        return True
    if expected.kind == 'integer':
        return False
    return True
def _compare(actual_int, expected_int, op, unsigned):
    if unsigned:
        a = actual_int & 0xFFFFFFFF
        e = expected_int & 0xFFFFFFFF
    else:
        a = actual_int if actual_int < 0x80000000 else actual_int - 0x100000000
        e = expected_int if expected_int < 0x80000000 else expected_int - 0x100000000
    if op == '=':  return a == e
    if op == '#':  return a != e
    if op == '>':  return a > e
    if op == '<':  return a < e
    if op == '>=': return a >= e
    if op == '<=': return a <= e
    return False
def _evaluate_action(action, bp):
    import gdb
    target = action.target
    target_desc = _format_target(target)
    if target.target_type in ('arg', 'local', 'var'):
        m_split = re.match(r'^([a-zA-Z_]\w*)(.*)', target.var_ref)
        base_name = m_split.group(1)
        suffix = m_split.group(2)
        info = {}
        if target.target_type in ('arg', 'var'):
            output = _gdb_execute('info args')
            info = _parse_info_output(output)
        if base_name not in info and target.target_type in ('local', 'var'):
            output = _gdb_execute('info locals')
            info = _parse_info_output(output)
        if base_name not in info and target.target_type == 'var':
            dot_idx = target.var_ref.find('.')
            if dot_idx >= 0:
                rest = target.var_ref[dot_idx + 1:]
                m_gv = re.match(r'^([a-zA-Z_]\w*)(.*)', rest)
                if m_gv:
                    global_base = target.var_ref[:dot_idx + 1 + len(m_gv.group(1))]
                    global_suffix = m_gv.group(2)
                else:
                    global_base = target.var_ref
                    global_suffix = ''
            else:
                global_base = target.var_ref
                global_suffix = ''
            raw_value = _resolve_global(global_base, bp, suffix=global_suffix)
            if raw_value is not None:
                info = None
            else:
                return CheckResult(
                    kind=action.kind,
                    target_desc=target_desc,
                    status='ERROR',
                    message=f"{target.var_ref} not found")
        if info is not None and base_name not in info:
            return CheckResult(
                kind=action.kind,
                target_desc=target_desc,
                status='ERROR',
                message=f"{base_name} not found")
        if info is not None:
            raw_value = info[base_name]
            if not _is_accessible(raw_value):
                return CheckResult(
                    kind=action.kind,
                    target_desc=target_desc,
                    status='ERROR',
                    actual=raw_value,
                    message='value not accessible')
            if suffix:
                arrow_suffix = suffix.replace('.', '->', 1) if suffix.startswith('.') else suffix
                resolved_val = None
                for expr_suffix in (arrow_suffix, suffix):
                    output = _gdb_execute(f'print/x {base_name}{expr_suffix}')
                    m_ev = re.search(r'=\s*(0x[0-9a-fA-F]+)', output)
                    if m_ev:
                        resolved_val = m_ev.group(1)
                        break
                    m_ev = re.search(r'=\s*(-?\d+)', output)
                    if m_ev:
                        resolved_val = m_ev.group(1)
                        break
                if resolved_val is None:
                    return CheckResult(
                        kind=action.kind,
                        target_desc=target_desc,
                        status='ERROR',
                        actual=raw_value,
                        message=f"cannot evaluate {base_name}{suffix}")
                raw_value = resolved_val
        if target.bit_range is not None:
            actual_int = _parse_gdb_int(raw_value)
            if actual_int is None:
                return CheckResult(
                    kind=action.kind,
                    target_desc=target_desc,
                    status='ERROR',
                    actual=raw_value,
                    message='cannot parse value for bit-range extraction')
            hi, lo = target.bit_range
            mask = (1 << (hi - lo + 1)) - 1
            actual_int = (actual_int >> lo) & mask
            raw_value = _fmt_hex(actual_int, _hex_style)
        if action.kind == 'trace':
            return CheckResult(
                kind='trace',
                target_desc=target_desc,
                status='TRACE',
                actual=raw_value)
        expected = action.expected
        if expected.int_value is not None:
            actual_int = _parse_gdb_int(raw_value)
            if actual_int is None:
                return CheckResult(
                    kind='check',
                    target_desc=target_desc,
                    status='ERROR',
                    actual=raw_value,
                    expected=_format_value(expected),
                    message='cannot parse actual value as integer')
            unsigned = _is_unsigned(expected)
            if _compare(actual_int, expected.int_value, action.op, unsigned):
                return CheckResult(
                    kind='check',
                    target_desc=target_desc,
                    status='PASS',
                    actual=raw_value,
                    expected=_format_value(expected))
            else:
                return CheckResult(
                    kind='check',
                    target_desc=target_desc,
                    status='FAIL',
                    actual=raw_value,
                    expected=_format_value(expected))
        else:
            return CheckResult(
                kind='check',
                target_desc=target_desc,
                status='ERROR',
                expected=_format_value(expected),
                message='const_ref value not resolved')
    if target.target_type == 'return':
        raw_value = _gdb_execute('print/x $r0')
        m = re.search(r'(0x[0-9a-fA-F]+)', raw_value)
        if m:
            raw_value = m.group(1)
        else:
            raw_value = raw_value.strip()
        if action.kind == 'trace':
            return CheckResult(
                kind='trace',
                target_desc=target_desc,
                status='TRACE',
                actual=raw_value)
        expected = action.expected
        if expected.int_value is not None:
            actual_int = _parse_gdb_int(raw_value)
            if actual_int is None:
                return CheckResult(
                    kind='check',
                    target_desc=target_desc,
                    status='ERROR',
                    actual=raw_value,
                    expected=_format_value(expected),
                    message='cannot parse return value as integer')
            unsigned = _is_unsigned(expected)
            if _compare(actual_int, expected.int_value, action.op, unsigned):
                return CheckResult(
                    kind='check',
                    target_desc=target_desc,
                    status='PASS',
                    actual=raw_value,
                    expected=_format_value(expected))
            else:
                return CheckResult(
                    kind='check',
                    target_desc=target_desc,
                    status='FAIL',
                    actual=raw_value,
                    expected=_format_value(expected))
        else:
            return CheckResult(
                kind='check',
                target_desc=target_desc,
                status='ERROR',
                expected=_format_value(expected),
                message='const_ref value not resolved')
    if target.target_type == 'mem':
        addr = None
        mem_val = None
        if target.address is not None:
            if target.address.int_value is not None:
                addr = target.address.int_value
            else:
                return CheckResult(
                    kind=action.kind,
                    target_desc=target_desc,
                    status='ERROR',
                    message='mem address not resolved '
                            '(const_ref or module_offset)')
        elif target.indirect is not None:
            ind = target.indirect
            if '.' in ind.source_name:
                base_name, field_path = ind.source_name.split('.', 1)
                for expr in (f'{base_name}->{field_path}',
                             f'{base_name}.{field_path}'):
                    output = _gdb_execute(f'print/x {expr}')
                    m_fld = re.search(r'=\s*(0x[0-9a-fA-F]+)', output)
                    if m_fld:
                        break
                else:
                    return CheckResult(
                        kind=action.kind,
                        target_desc=target_desc,
                        status='ERROR',
                        actual=output.strip(),
                        message=f'cannot evaluate {ind.source_name}')
                field_val = int(m_fld.group(1), 16)
                if ind.offset_sign and ind.offset:
                    off_val = ind.offset.int_value
                    if off_val is None:
                        return CheckResult(
                            kind=action.kind,
                            target_desc=target_desc,
                            status='ERROR',
                            message='indirect offset not resolved')
                    if ind.offset_sign == '+':
                        addr = field_val + off_val
                    else:
                        addr = field_val - off_val
                else:
                    addr = field_val
            else:
                info = {}
                if ind.source_type in ('arg', 'var'):
                    output = _gdb_execute('info args')
                    info = _parse_info_output(output)
                if ind.source_name not in info and ind.source_type in (
                        'local', 'var'):
                    output = _gdb_execute('info locals')
                    info = _parse_info_output(output)
                if ind.source_name not in info:
                    return CheckResult(
                        kind=action.kind,
                        target_desc=target_desc,
                        status='ERROR',
                        message=f"{ind.source_name} not found")
                base_str = info[ind.source_name]
                if not _is_accessible(base_str):
                    return CheckResult(
                        kind=action.kind,
                        target_desc=target_desc,
                        status='ERROR',
                        actual=base_str,
                        message='base variable not accessible')
                base_val = _parse_gdb_int(base_str)
                if base_val is None:
                    m_ptr = re.search(r'0x([0-9a-fA-F]+)', base_str)
                    if m_ptr:
                        base_val = int(m_ptr.group(1), 16)
                    else:
                        return CheckResult(
                            kind=action.kind,
                            target_desc=target_desc,
                            status='ERROR',
                            actual=base_str,
                            message='cannot parse base variable '
                                    'as address')
                if ind.offset_sign and ind.offset:
                    off_val = ind.offset.int_value
                    if off_val is None:
                        return CheckResult(
                            kind=action.kind,
                            target_desc=target_desc,
                            status='ERROR',
                            message='indirect offset not resolved')
                    if ind.offset_sign == '+':
                        addr = base_val + off_val
                    else:
                        addr = base_val - off_val
                else:
                    addr = base_val
        else:
            return CheckResult(
                kind=action.kind,
                target_desc=target_desc,
                status='ERROR',
                message='mem target has no address')
        if mem_val is None:
            mem_output = _gdb_execute(f'x/1xw 0x{addr:08X}')
            m = re.search(r':\s*0x([0-9a-fA-F]+)', mem_output)
            if not m:
                return CheckResult(
                    kind=action.kind,
                    target_desc=target_desc,
                    status='ERROR',
                    actual=mem_output.strip(),
                    message='cannot parse memory read output')
            mem_val = int(m.group(1), 16)
        if target.bit_range is not None:
            hi, lo = target.bit_range
            mask = (1 << (hi - lo + 1)) - 1
            mem_val = (mem_val >> lo) & mask
        raw_value = _fmt_hex(mem_val, _hex_style)
        if action.kind == 'trace':
            return CheckResult(
                kind='trace',
                target_desc=target_desc,
                status='TRACE',
                actual=raw_value)
        expected = action.expected
        if expected.int_value is not None:
            unsigned = _is_unsigned(expected)
            if _compare(mem_val, expected.int_value, action.op, unsigned):
                return CheckResult(
                    kind='check',
                    target_desc=target_desc,
                    status='PASS',
                    actual=raw_value,
                    expected=_format_value(expected))
            else:
                return CheckResult(
                    kind='check',
                    target_desc=target_desc,
                    status='FAIL',
                    actual=raw_value,
                    expected=_format_value(expected))
        else:
            return CheckResult(
                kind='check',
                target_desc=target_desc,
                status='ERROR',
                expected=_format_value(expected),
                message='const_ref value not resolved')
    return CheckResult(
        kind=action.kind,
        target_desc=target_desc,
        status='ERROR',
        message=f'unknown target type: {target.target_type}')
def _check_sentinel_condition(rd, sentinel_hits):
    cond = rd.condition
    if cond is None:
        return True
    if cond.kind == 'hits':
        count = sentinel_hits.get(id(rd), 0)
        return count >= cond.hits_value
    if cond.kind == 'var':
        var_name = cond.var_ref
        output = _gdb_execute('info args')
        info = _parse_info_output(output)
        if var_name not in info:
            output = _gdb_execute('info locals')
            info = _parse_info_output(output)
        if var_name not in info:
            return False
        raw_val = info[var_name]
        if not _is_accessible(raw_val):
            return False
        actual = _parse_gdb_int(raw_val)
        if actual is None:
            return False
        expected = cond.var_value.int_value if cond.var_value else None
        if expected is None:
            return False
        return actual == expected
    return True
def _describe_pc(pc, proc_map):
    for start, end, qual_name, mod_base in proc_map:
        if start <= pc < end:
            mod_offset = pc - mod_base
            return (f"{qual_name} {_fmt_hex(pc, _hex_style, pad=8)}, "
                    f"module offset {mod_offset}")
    return _fmt_hex(pc, _hex_style, pad=8)
def run_test(resolved, elf_path, host=_DEFAULT_HOST,
             timeout=_DEFAULT_TIMEOUT, max_hits=_DEFAULT_MAX_HITS):
    import gdb
    results = TestResults()
    timeout = int(resolved.options.get('timeout', timeout))
    max_hits = int(resolved.options.get('max-hits', max_hits))
    halt_enabled = resolved.options.get('halt-enabled', 'true').lower() == 'true'
    halt_on_fail = resolved.options.get('halt-on-fail', 'false').lower() == 'true'
    _gdb_execute('set confirm off')
    _gdb_execute('set pagination off')
    _gdb_execute('set suppress-cli-notifications on')
    elf_str = str(elf_path).replace('\\', '/')
    print(f"Loading ELF: {elf_str}")
    _gdb_execute(f'file {elf_str}')
    print(f"Connecting to {host} ...")
    out = _gdb_execute(f'target remote {host}')
    if 'ERROR' in out:
        print(f"Connection failed: {out}")
        return results, 0, 'connection_failed'
    out = _gdb_execute('monitor flash breakpoints = 1')
    server = 'JLink' if 'ERROR' not in out else 'OpenOCD'
    print(f"Server: {server}")
    if server == 'JLink':
        _gdb_execute('monitor reset')
    else:
        _gdb_execute('monitor reset halt')
    _gdb_execute('load')
    addr_to_bp = {}
    for bp in resolved.breakpoints:
        if bp.address not in addr_to_bp:
            addr_to_bp[bp.address] = []
        addr_to_bp[bp.address].append(bp)
    stop_addrs = {}
    for rd in resolved.directives:
        if rd.kind == 'stop' and rd.address is not None:
            stop_addrs[rd.address] = rd
    start_addrs = {}
    for rd in resolved.directives:
        if rd.kind == 'start' and rd.address is not None:
            start_addrs[rd.address] = rd
    stop_after_hits = None
    for rd in resolved.directives:
        if rd.kind == 'stop' and rd.stop_type == 'hits':
            stop_after_hits = rd.stop_value
        elif rd.kind == 'stop' and rd.stop_type == 'timeout':
            timeout = rd.stop_value
    if stop_after_hits is not None and stop_after_hits < max_hits:
        max_hits = stop_after_hits
    has_start = any(rd.kind == 'start' for rd in resolved.directives)
    window_open = not has_start
    sentinel_hits = {}
    for rd in resolved.directives:
        if rd.condition and rd.condition.kind == 'hits':
            sentinel_hits[id(rd)] = 0
    stop_after_all = any(
        rd.kind == 'stop' and rd.stop_type == 'all_checks'
        for rd in resolved.directives)
    total_checks = sum(1 for bp in resolved.breakpoints
                       for a in bp.actions if a.kind == 'check')
    checks_evaluated = set()
    bp_cmd = 'break' if server == 'JLink' else 'hbreak'
    all_addrs = (set(addr_to_bp.keys()) | set(stop_addrs.keys())
                 | set(start_addrs.keys()))
    bp_nums = {}
    for addr in sorted(all_addrs):
        out = _gdb_execute(f'{bp_cmd} *0x{addr:08X}')
        m = re.search(r'(?:Hardware assisted b|B)reakpoint\s+(\d+)', out)
        if m:
            bp_nums[addr] = int(m.group(1))
    window_msg = ("closed (waiting for start)" if has_start
                  else "open (no start directive)")
    print(f"Set {len(bp_nums)} breakpoints, max {max_hits} hits, "
          f"timeout {timeout}s, window {window_msg}")
    if server == 'JLink':
        _gdb_execute('monitor reset')
    else:
        _gdb_execute('monitor reset halt')
    hit_count = 0
    pc = None
    stop_reason = 'max_hits'
    halt_triggered = False
    while hit_count < max_hits:
        timer = _interrupt_after(timeout)
        try:
            _gdb_execute('continue')
        except Exception as e:
            timer.cancel()
            stop_reason = f'error: {e}'
            break
        timer.cancel()
        pc_output = _gdb_execute('print/x $pc')
        m = re.search(r'0x([0-9a-fA-F]+)', pc_output)
        if not m:
            stop_reason = 'cannot read PC'
            break
        pc = int(m.group(1), 16)
        if pc not in all_addrs:
            pc_desc = _describe_pc(pc, resolved.proc_map)
            stop_reason = f'timeout: stopped at {pc_desc}'
            break
        hit_count += 1
        if pc in start_addrs:
            rd = start_addrs[pc]
            if id(rd) in sentinel_hits:
                sentinel_hits[id(rd)] += 1
            if not window_open and _check_sentinel_condition(rd,
                                                             sentinel_hits):
                window_open = True
                print(f"  Window opened: {rd.qual_name} "
                      f"at {rd.location_type}")
        if pc in stop_addrs:
            rd = stop_addrs[pc]
            if id(rd) in sentinel_hits:
                sentinel_hits[id(rd)] += 1
            if _check_sentinel_condition(rd, sentinel_hits):
                pc_desc = _describe_pc(pc, resolved.proc_map)
                stop_reason = f'stop: {pc_desc}'
                break
        if window_open and pc in addr_to_bp:
            for bp in addr_to_bp[pc]:
                loc = f"{bp.qual_name} at {bp.location_desc}"
                for action in bp.actions:
                    cr = _evaluate_action(action, bp)
                    cr.hit = hit_count
                    cr.location = loc
                    cr.op = action.op
                    results.record(cr)
                    if action.kind == 'check':
                        checks_evaluated.add(id(action))
                    should_halt = cr.status == 'FAIL' and (
                        halt_on_fail or (halt_enabled and action.halt))
                    if should_halt:
                        print(_report_line(cr))
                        print(f"  ** HALT: target halted at failure point")
                        pc_desc = _describe_pc(pc, resolved.proc_map)
                        stop_reason = (f'halt: {pc_desc}, '
                                       f'FAIL {cr.target_desc}')
                        halt_triggered = True
                        break
                    print(_report_line(cr))
                if halt_triggered:
                    break
        if halt_triggered:
            break
        if stop_after_all and len(checks_evaluated) >= total_checks:
            stop_reason = 'all checks evaluated'
            break
    if stop_reason == 'max_hits' and pc is not None:
        pc_desc = _describe_pc(pc, resolved.proc_map)
        stop_reason = f'max_hits: last at {pc_desc}'
    print()
    print(f"Stopped: {stop_reason} after {hit_count} hits")
    if halt_triggered:
        _gdb_execute('delete')
        pc_desc = _describe_pc(pc, resolved.proc_map)
        print(f"  Breakpoints cleared, target halted at {pc_desc}")
    return results, hit_count, stop_reason
def _report_line(cr):
    prefix = f"  {cr.hit:3d} [{cr.location}]"
    actual = _to_display_hex(cr.actual)
    expected = _to_display_hex(cr.expected)
    if cr.status == 'PASS':
        if cr.op == '=':
            return f"{prefix} PASS  {cr.target_desc} = {actual}"
        else:
            return (f"{prefix} PASS  {cr.target_desc} {cr.op} "
                    f"{expected} (actual {actual})")
    elif cr.status == 'FAIL':
        if cr.op == '=':
            return (f"{prefix} FAIL  {cr.target_desc} = {actual} "
                    f"(expected {expected})")
        else:
            return (f"{prefix} FAIL  {cr.target_desc} = {actual} "
                    f"(expected {cr.op} {expected})")
    elif cr.status == 'TRACE':
        return f"{prefix} TRACE {cr.target_desc} = {actual}"
    elif cr.status == 'ERROR':
        return f"{prefix} ERROR {cr.target_desc}: {cr.message}"
    return f"{prefix} {cr.status} {cr.target_desc}"
def format_report(results, hit_count, stop_reason, spec_path, elf_path):
    sep = '=' * 64
    lines = [
        sep,
        "Code Test Report",
        sep,
        f"  Spec:  {spec_path.name}",
        f"  ELF:   {elf_path.name}",
        f"  Date:  {time.strftime('%Y-%m-%d %H:%M:%S')}",
        f"  Hits:  {hit_count}",
        f"  Stop:  {stop_reason}",
        f"  PASS:  {results.passed}",
        f"  FAIL:  {results.failed}",
        f"  TRACE: {results.traces}",
        f"  ERROR: {results.errors}",
    ]
    if stop_reason.startswith('halt:'):
        lines.append(f"  HALT:  {stop_reason}")
    lines.append("")
    if results.failed > 0:
        lines.append("FAILURES")
        lines.append("-" * 40)
        for cr in results.results:
            if cr.status == 'FAIL':
                lines.append(_report_line(cr))
        lines.append("")
    if results.errors > 0:
        lines.append("ERRORS")
        lines.append("-" * 40)
        for cr in results.results:
            if cr.status == 'ERROR':
                lines.append(_report_line(cr))
        lines.append("")
    lines.append("TIMELINE")
    lines.append("-" * 40)
    for cr in results.results:
        lines.append(_report_line(cr))
    lines.append("")
    if results.traces > 0:
        lines.append("TRACES")
        lines.append("-" * 40)
        for cr in results.results:
            if cr.status == 'TRACE':
                lines.append(_report_line(cr))
        lines.append("")
    if results.passed > 0:
        lines.append("PASSED")
        lines.append("-" * 40)
        for cr in results.results:
            if cr.status == 'PASS':
                lines.append(_report_line(cr))
        lines.append("")
    return '\n'.join(lines)
def _get_args():
    import os
    def _getenv(name, default=None):
        val = os.environ.get(name)
        if val:
            return val
        if _in_gdb():
            try:
                import gdb
                out = gdb.execute(f'show environment {name}',
                                  to_string=True).strip()
                if '=' in out and 'not defined' not in out:
                    return out.split('=', 1)[1].strip()
            except Exception:
                pass
        return default
    spec_env = _getenv('SPEC')
    if spec_env:
        proj_dir = Path(_getenv('RTK_PROJECT_DIR', '.'))
        specs_dir_env = _getenv('RTK_GDB_TESTS_SPECS_DIR',
                                'rdb-gdb-tests/specs')
        spec_path = proj_dir / specs_dir_env / spec_env
        reports_env = _getenv('RTK_REPORTS_DIR')
        if reports_env:
            report_dir = proj_dir / reports_env
        else:
            report_dir = (proj_dir / specs_dir_env).resolve().parent / 'reports'
        host = _getenv('RTK_GDB_HOST', _DEFAULT_HOST)
        return spec_path, proj_dir, report_dir, host
    args = sys.argv[1:]
    if len(args) < 1:
        return None, None, None, _DEFAULT_HOST
    spec_path = Path(args[0])
    project_dir = Path(args[1]) if len(args) >= 2 else None
    report_dir = spec_path.resolve().parent / 'reports' if project_dir else None
    return spec_path, project_dir, report_dir, _DEFAULT_HOST
def main():
    in_gdb = _in_gdb()
    spec_path, project_dir, report_dir, host = _get_args()
    if spec_path is None:
        msg = ("Usage:\n"
               "  GDB:        (gdb) set environment SPEC <spec>\n"
               "              (gdb) run-test\n"
               "  Batch:      SPEC=<spec> arm-none-eabi-gdb-py3"
               " -batch -x gdbtestengine.py\n"
               "  Standalone: python gdbtestengine.py"
               " <spec> [project-dir]\n"
               "  See RTK_PROJECT_DIR, RTK_GDB_TESTS_SPECS_DIR,"
               " RTK_REPORTS_DIR env vars.")
        print(msg, file=sys.stderr)
        if not in_gdb:
            sys.exit(1)
        return
    if not spec_path.exists():
        print(f"Error: file not found: {spec_path}", file=sys.stderr)
        if not in_gdb:
            sys.exit(1)
        return
    text = spec_path.read_text(encoding='utf-8')
    try:
        spec = parse_spec(text)
    except ParseError as e:
        print(f"Parse error: {e}", file=sys.stderr)
        if not in_gdb:
            sys.exit(1)
        return
    print(f"Parsed: {spec_path.name}")
    print(f"  Directives: {len(spec.directives)}")
    print(f"  Proc blocks: {len(spec.proc_blocks)}")
    print(f"  Options: {spec.options}")
    print()
    if project_dir is None:
        print("--- Round-trip output ---")
        print(format_spec(spec))
        return
    rdb_dir = project_dir / 'rdb'
    if not rdb_dir.exists():
        print(f"Error: rdb/ directory not found in {project_dir}",
              file=sys.stderr)
        if not in_gdb:
            sys.exit(1)
        return
    map_files = list(project_dir.glob('*.map'))
    map_path = map_files[0] if map_files else None
    elf_files = list(project_dir.glob('*.elf'))
    elf_path = elf_files[0] if elf_files else None
    print(f"Loading modules from {rdb_dir} ...")
    modules = load_modules(rdb_dir)
    print(f"  Loaded {len(modules)} modules")
    if map_path:
        print(f"  Map file: {map_path.name}")
    if elf_path:
        print(f"  ELF file: {elf_path.name}")
    print()
    try:
        resolved = resolve_spec(spec, modules, map_path)
    except ResolveError as e:
        print(f"Resolve error: {e}", file=sys.stderr)
        if not in_gdb:
            sys.exit(1)
        return
    print(f"Resolved: {len(resolved.breakpoints)} breakpoints, "
          f"{len(resolved.directives)} directives")
    for bp in resolved.breakpoints:
        print(f"  BP {_fmt_hex(bp.address, _hex_style, pad=8)}  "
              f"{bp.qual_name}  at {bp.location_desc}")
    has_start = any(rd.kind == 'start' for rd in resolved.directives)
    for rd in resolved.directives:
        if rd.address is not None:
            cond_str = ''
            if rd.condition:
                if rd.condition.kind == 'hits':
                    cond_str = f' when hits = {rd.condition.hits_value}'
                elif rd.condition.kind == 'var':
                    cond_str = (f' when {rd.condition.var_ref} = '
                                f'{rd.condition.var_value.int_value}')
            print(f"  {rd.kind.upper()} "
                  f"{_fmt_hex(rd.address, _hex_style, pad=8)}  "
                  f"{rd.qual_name}  at {rd.location_type}{cond_str}")
        elif rd.stop_type:
            print(f"  STOP after {rd.stop_value} "
                  f"{'hits' if rd.stop_type == 'hits' else 's'}"
                  if rd.stop_value else f"  STOP after all checks")
    if has_start:
        print(f"  Window: starts closed (waiting for start sentinel)")
    print()
    if not in_gdb:
        print("(Not in GDB — resolve-only mode)")
        return
    if elf_path is None:
        print("Error: no .elf file found in project directory",
              file=sys.stderr)
        return
    results, hit_count, stop_reason = run_test(resolved, elf_path, host=host)
    print()
    print("=" * 60)
    print(f"Results: {results.passed} PASS, {results.failed} FAIL, "
          f"{results.traces} TRACE, {results.errors} ERROR")
    print("=" * 60)
    report_dir.mkdir(parents=True, exist_ok=True)
    report_name = spec_path.stem + f'-report-{time.strftime("%Y%m%d-%H%M%S")}.txt'
    report_path = report_dir / report_name
    report_text = format_report(results, hit_count, stop_reason,
                                spec_path, elf_path)
    report_path.write_text(report_text, encoding='utf-8')
    print(f"Report: {report_path}")
    halted = stop_reason.startswith('halt:')
    if halted and not _is_batch_mode():
        print()
        print("Target halted at failure point. You are at the (gdb) prompt.")
        print("Use 'info registers', 'print <var>', 'x/...' to inspect state.")
        return
    import gdb
    gdb.execute('quit', to_string=True)
if _in_gdb():
    main()
elif __name__ == '__main__':
    main()
