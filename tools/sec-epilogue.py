#!/usr/bin/env python3
"""
sec-epilogue -- Insert Secure return epilogues into exported procedures.
--
Reads Module.mod and Module.lst, inserts SYSTEM.EMIT/EMITH/LDREG
sequences before END ProcName; for each exported non-handler procedure.
Generates stack deallocation + POP.W {LR} + BXNS LR, with full
register sanitisation by default (adversarial mode).
Modifies the .mod file in place using markers for re-run.
--
Usage:
    python sec-epilogue.py Module.mod [Module2.mod ...]
    python sec-epilogue.py Module.mod --no-clear
    python sec-epilogue.py Module.mod --dry-run

The .lst file is expected alongside the .mod file (same directory,
same base name). If not found, a warning is issued and the module
is skipped.

Options:
    --no-clear       Skip register sanitisation (no_clear S/NS model)
    --dry-run           Show what would be generated, do not write

Sanitisation modes:
    Default (adversarial): clear all GPR (R0-R11, R1-R11 for function
      procedures), APSR, all FPU registers (d0-d15 + FPSCR) if FPU
      instructions detected in the procedure.
    --no-clear: no register clearing. Only stack deallocation +
      POP.W {LR} + BXNS LR. Use when S and NS trust each other.
--
Copyright (c) 2026 Gray, gray@grayraven.org
https://oberon-rtk.org/licences/
"""

import sys
import re
import argparse
from pathlib import Path


PROG_NAME = 'sec-epilogue'

# --- Markers ---
_GEN_START = '(* +sec-epilogue *)'
_GEN_END = '(* -sec-epilogue *)'
_GEN_START_RE = re.compile(r'^\s*\(\*\s*\+sec-epilogue\s*\*\)')
_GEN_END_RE = re.compile(r'^\s*\(\*\s*-sec-epilogue\s*\*\)')

# --- Instruction encodings (hex constants, no module references) ---
ADD_SP_NARROW_BASE = 0xB000  # add sp,#N*4 — add N/4 to bits [6:0], max 508
POP_W_LR = 0xE8BD4000       # pop.w {lr}
BXNS_LR = 0x4774             # bxns lr
MSR_APSR_R0 = 0xF3808800    # msr APSR_nzcvq, r0

def _encode_thumb2_mod_imm(value):
    """Encode a value as Thumb2 modified immediate (i:imm3:imm8 → imm12).
    Returns imm12 or None if not encodable."""
    # case 0: plain 8-bit
    if value < 0x100:
        return value
    # case 1: 00XY00XY
    if (value & 0xFF00FF00) == 0 and (value & 0xFF) == ((value >> 16) & 0xFF):
        return 0x100 | (value & 0xFF)
    # case 2: XY00XY00
    if (value & 0x00FF00FF) == 0 and ((value >> 8) & 0xFF) == ((value >> 24) & 0xFF):
        return 0x200 | ((value >> 8) & 0xFF)
    # case 3: XYXYXYXY
    b = value & 0xFF
    if value == (b | (b << 8) | (b << 16) | (b << 24)):
        return 0x300 | b
    # case 4: rotated 1xxxxxxx
    for rot in range(1, 32):
        # ROR(base, rot) = value → base = ROL(value, rot)
        rotated = ((value << rot) | (value >> (32 - rot))) & 0xFFFFFFFF
        if rotated < 0x100 and (rotated & 0x80):
            imm7 = rotated & 0x7F
            imm12 = (rot << 7) | imm7
            return imm12
    return None


def _encode_add_w_sp(imm):
    """Encode ADD.W SP, SP, #imm as a 32-bit instruction.
    Returns the 32-bit encoding or None if not encodable."""
    imm12 = _encode_thumb2_mod_imm(imm)
    if imm12 is None:
        return None
    # ADD (SP + immediate) T3: 1111 0 i 01 000 S 1101 0 imm3 1101 imm8
    # S=0 (no flags)
    i_bit = (imm12 >> 11) & 1
    imm3 = (imm12 >> 8) & 7
    imm8 = imm12 & 0xFF
    hw1 = 0xF10D | (i_bit << 10)  # 1111 0 i 01 000 0 1101
    hw2 = (imm3 << 12) | (0xD << 8) | imm8  # 0 imm3 1101 imm8
    return (hw1 << 16) | hw2


def _generate_add_sp(dealloc):
    """Generate ADD SP instruction(s) for the given deallocation.
    Returns list of (emit_call, comment) tuples."""
    lines = []
    remaining = dealloc
    while remaining > 0:
        if remaining <= 508:
            # narrow ADD SP
            n = remaining // 4
            lines.append((f'SYSTEM.EMITH(0{ADD_SP_NARROW_BASE + n:04X}H)',
                           f'add sp, #{remaining}'))
            remaining = 0
        else:
            # try 32-bit ADD.W SP for the largest chunk
            # try remaining first, then fall back to largest encodable
            enc = _encode_add_w_sp(remaining)
            if enc is not None:
                lines.append((f'SYSTEM.EMIT(0{enc:08X}H)',
                               f'add.w sp, sp, #{remaining}'))
                remaining = 0
            else:
                # split: use largest power-of-2 aligned chunk
                # that fits in modified immediate
                chunk = remaining & ~0xFF  # align down
                while chunk > 0:
                    enc = _encode_add_w_sp(chunk)
                    if enc is not None:
                        break
                    chunk -= 256
                if enc is not None and chunk > 0:
                    lines.append((f'SYSTEM.EMIT(0{enc:08X}H)',
                                   f'add.w sp, sp, #{chunk}'))
                    remaining -= chunk
                else:
                    # fallback: use 508 (max narrow)
                    lines.append((f'SYSTEM.EMITH(0{ADD_SP_NARROW_BASE + 127:04X}H)',
                                   f'add sp, #508'))
                    remaining -= 508
    return lines


# VMOV Dd, Rm, Rn: clear double FP register via two zero core regs
def _vmov_d_rr(dd, rm, rn):
    vm = dd & 0xF
    m = (dd >> 4) & 1
    return 0xEC400B10 | (rn << 16) | (rm << 12) | (m << 5) | vm

VMSR_FPSCR_R0 = 0xEEE10A10  # vmsr FPSCR, r0

# --- Source parsing ---

# Exported procedure: PROCEDURE [*] Name* or PROCEDURE [*] Name* (
_PROC_RE = re.compile(
    r'^\s*PROCEDURE\s*(\*)?\s*(\w+)\s*(\*)\s*'
    r'(?:\(([^)]*)\))?\s*(?::\s*(\w+))?\s*;'
)
# Handler procedure: PROCEDURE Name [N]
_HANDLER_RE = re.compile(r'^\s*PROCEDURE\s+\w+\s*\[')
# END ProcName;
_END_PROC_RE = re.compile(r'^(\s*)END\s+(\w+)\s*;')
# MODULE Name;
_MODULE_RE = re.compile(r'^\s*MODULE\s+(\w+)\s*;')
# IMPORT line(s)
_IMPORT_RE = re.compile(r'^\s*IMPORT\b')


def parse_source(lines):
    """Parse source for exported procedures and their END markers.

    Returns list of dicts with keys:
      name: procedure name
      is_function: True if returns a value
      is_leaf: True if marked with leading *
      end_line: line index of END ProcName;
      end_indent: indentation of END line
    """
    procs = []
    current_proc = None
    handler_names = set()

    for i, line in enumerate(lines):
        # detect handlers first
        if _HANDLER_RE.match(line):
            # extract name
            m = re.match(r'^\s*PROCEDURE\s+(\w+)\s*\[', line)
            if m:
                handler_names.add(m.group(1))
            continue

        m = _PROC_RE.match(line)
        if m:
            is_leaf = m.group(1) == '*'
            name = m.group(2)
            is_exported = m.group(3) == '*'
            params = m.group(4)
            return_type = m.group(5)

            if is_exported and name not in handler_names:
                current_proc = {
                    'name': name,
                    'is_function': return_type is not None,
                    'is_leaf': is_leaf,
                    'end_line': None,
                    'end_indent': '',
                }
            continue

        m = _END_PROC_RE.match(line)
        if m and current_proc is not None:
            end_name = m.group(2)
            if end_name == current_proc['name']:
                current_proc['end_line'] = i
                current_proc['end_indent'] = m.group(1)
                procs.append(current_proc)
                current_proc = None

    return procs


# --- Listing parsing ---

# Assembly line: .  offset  hex  opcode  mnemonic  operands
_ASM_LINE_RE = re.compile(
    r'^\.\s+(\d+)\s+([0-9A-Fa-f]+H)\s+'
    r'(0[0-9A-Fa-f]+H)\s+'
    r'(\w[\w.]*)\s*(.*)'
)

# push / push.w
_PUSH_RE = re.compile(r'^push(?:\.w)?\s*\{([^}]+)\}', re.IGNORECASE)
# sub sp,#N / sub.w sp,sp,#N (immediate)
_SUB_SP_IMM_RE = re.compile(r'^sub(?:\.w)?\s+sp\s*,\s*(?:sp\s*,\s*)?#(\d+)', re.IGNORECASE)
# sub.w sp,sp,rN (register — large locals)
_SUB_SP_REG_RE = re.compile(r'^sub\.w\s+sp\s*,\s*sp\s*,\s*r(\d+)', re.IGNORECASE)
# movw rN,#imm / mov rN,#imm (value load for register-based sub)
_MOV_IMM_RE = re.compile(r'^movw?\s+r(\d+)\s*,\s*#(\d+)', re.IGNORECASE)


def parse_listing_proc(lst_lines, proc_name):
    """Parse .lst for a specific procedure's stack frame and register usage.

    Returns dict with keys:
      push_count: number of pushed registers
      sub_bytes: SUB SP immediate in bytes (0 if none)
      highest_gpr: highest GPR number seen (0-12)
      has_fpu: True if FP instructions detected
    """
    result = {
        'push_count': 0,
        'sub_bytes': 0,
        'highest_gpr': 0,
        'has_fpu': False,
    }

    # find procedure in listing
    in_proc = False
    proc_start_re = re.compile(
        rf'^\s*PROCEDURE\s*\*?\s*{re.escape(proc_name)}\s*\*'
    )
    proc_end_re = re.compile(
        rf'^\s*END\s+{re.escape(proc_name)}\s*;'
    )

    push_found = False
    sub_checked = False
    prev_asm_line = None  # (mnemonic, operands) of previous asm line

    for i, line in enumerate(lst_lines):
        if not in_proc:
            if proc_start_re.match(line):
                in_proc = True
            continue

        if proc_end_re.match(line):
            break

        m = _ASM_LINE_RE.match(line)
        if m:
            mnemonic = m.group(4).lower()
            operands = m.group(5).strip()

            # push instruction (first one is the prologue)
            if not push_found and mnemonic in ('push', 'push.w'):
                pm = _PUSH_RE.match(f'{mnemonic} {operands}')
                if pm:
                    regs = [r.strip() for r in pm.group(1).split(',')]
                    result['push_count'] = len(regs)
                    push_found = True
                prev_asm_line = (mnemonic, operands)
                continue

            # sub sp immediately after push (or after movw + sub.w sp,sp,rN)
            if push_found and not sub_checked:
                # immediate form: sub sp,#N / sub.w sp,sp,#N
                sm = _SUB_SP_IMM_RE.match(f'{mnemonic} {operands}')
                if sm:
                    result['sub_bytes'] = int(sm.group(1))
                    sub_checked = True
                    prev_asm_line = (mnemonic, operands)
                    continue

                # register form: sub.w sp,sp,rN (large locals)
                sm = _SUB_SP_REG_RE.match(f'{mnemonic} {operands}')
                if sm:
                    reg_n = int(sm.group(1))
                    # look at previous instruction for movw rN, #imm
                    if prev_asm_line is not None:
                        prev_str = f'{prev_asm_line[0]} {prev_asm_line[1]}'
                        mm = _MOV_IMM_RE.match(prev_str)
                        if mm and int(mm.group(1)) == reg_n:
                            result['sub_bytes'] = int(mm.group(2))
                    sub_checked = True
                    prev_asm_line = (mnemonic, operands)
                    continue

                # not a sub instruction — but could be a mov loading
                # the value for a register-based sub (next instruction)
                if not mnemonic.startswith('mov'):
                    sub_checked = True

            # scan for register usage (GPR r0-r11)
            # r12 is not used by the compiler; if used via ASM,
            # clearing is the programmer's responsibility
            for rm in re.finditer(r'\br(\d+)\b', operands):
                rn = int(rm.group(1))
                if 0 <= rn <= 11:
                    result['highest_gpr'] = max(result['highest_gpr'], rn)

            # scan for FPU instructions
            if mnemonic.startswith('v'):
                result['has_fpu'] = True

            prev_asm_line = (mnemonic, operands)

    return result


# --- Epilogue generation ---

def generate_epilogue(proc_info, lst_info, no_clear):
    """Generate the SYSTEM.EMIT/EMITH/LDREG lines for a Secure epilogue.

    no_clear=True: no sanitisation (S and NS trust each other).
    no_clear=False (default): full sanitisation (adversarial).

    Returns list of (code, comment) tuples.
    """
    lines = []

    push_count = lst_info['push_count']
    sub_bytes = lst_info['sub_bytes']
    has_fpu = lst_info['has_fpu']
    is_function = proc_info['is_function']

    if not no_clear:
        # --- Full register sanitisation (adversarial) ---

        # clear all GPR r0-r11 (r1-r11 for function procs)
        start_reg = 1 if is_function else 0
        for r in range(start_reg, 12):
            lines.append((f'SYSTEM.LDREG({r}, 0)', f'clear r{r}'))

        # APSR clearing
        if is_function:
            # use r1 (first cleared register) for APSR
            lines.append((f'SYSTEM.EMIT(0{MSR_APSR_R0 + (1 << 16):08X}H)',
                           'msr APSR_nzcvq, r1'))
        else:
            lines.append((f'SYSTEM.EMIT(0{MSR_APSR_R0:08X}H)',
                           'msr APSR_nzcvq, r0'))

        # FPU sanitisation (if FPU instructions detected)
        # always use r1 as zero source — r1 is always cleared
        if has_fpu:
            for d in range(16):
                enc = _vmov_d_rr(d, 1, 1)
                lines.append((f'SYSTEM.EMIT(0{enc:08X}H)',
                               f'vmov d{d}, r1, r1'))
            lines.append((f'SYSTEM.EMIT(0{VMSR_FPSCR_R0 + (1 << 12):08X}H)',
                           'vmsr FPSCR, r1'))

    # --- Stack deallocation ---
    # Total to deallocate: (push_count - 1) * 4 + sub_bytes
    # push_count - 1 because LR is popped separately by pop.w {lr}
    dealloc = (push_count - 1) * 4 + sub_bytes

    if dealloc > 0:
        lines.extend(_generate_add_sp(dealloc))

    # pop.w {lr}
    lines.append((f'SYSTEM.EMIT(0{POP_W_LR:08X}H)', 'pop.w {lr}'))

    # bxns lr
    lines.append((f'SYSTEM.EMITH(0{BXNS_LR:04X}H)', 'bxns lr'))

    return lines


def format_epilogue(epilogue_lines, indent):
    """Format epilogue lines as indented Oberon source."""
    result = []
    result.append(f'{indent}{_GEN_START}')
    for code, comment in epilogue_lines:
        if comment:
            result.append(f'{indent}  {code}; (* {comment} *)')
        else:
            result.append(f'{indent}  {code};')
    # remove trailing semicolon from last line
    if result and result[-1].rstrip().endswith(';'):
        result[-1] = result[-1].rstrip()[:-1]
    result.append(f'{indent}{_GEN_END}')
    return result


# --- IMPORT handling ---

def ensure_system_import(lines):
    """Ensure SYSTEM is in the IMPORT list. Returns True if added."""
    for i, line in enumerate(lines):
        if _IMPORT_RE.match(line):
            if re.search(r'\bSYSTEM\b', line):
                return False
            # insert SYSTEM after IMPORT keyword
            m = re.match(r'^(\s*)(IMPORT\b)(.*)', line, re.DOTALL)
            if m:
                lines[i] = f'{m.group(1)}{m.group(2)} SYSTEM,{m.group(3)}'
                return True
    return False


# --- File processing ---

def process_module(mod_path, lst_path, no_clear, dry_run):
    """Process one module. Returns (modified, error_count)."""
    mod_path = Path(mod_path)
    lst_path = Path(lst_path)

    if not mod_path.is_file():
        print(f'{PROG_NAME}: source file not found: {mod_path}',
              file=sys.stderr)
        return False, 1

    try:
        mod_content = mod_path.read_text(encoding='utf-8')
        lst_content = lst_path.read_text(encoding='utf-8')
    except (OSError, UnicodeDecodeError) as e:
        print(f'{PROG_NAME}: cannot read: {e}', file=sys.stderr)
        return False, 1

    mod_lines = mod_content.split('\n')
    lst_lines = lst_content.split('\n')

    # parse source for exported procedures
    procs = parse_source(mod_lines)

    if not procs:
        print(f'{PROG_NAME}: {mod_path.name}: no exported procedures found')
        return False, 0

    # analyse listing for each procedure
    proc_data = []
    error_count = 0
    for proc in procs:
        lst_info = parse_listing_proc(lst_lines, proc['name'])
        if lst_info['push_count'] == 0:
            print(f'{PROG_NAME}: {mod_path.name}: {proc["name"]}: '
                  f'no push found in listing', file=sys.stderr)
            error_count += 1
            continue
        proc_data.append((proc, lst_info))

    if error_count > 0:
        return False, error_count

    # generate epilogues and insert into source
    # process in reverse order so line indices remain valid
    output_lines = list(mod_lines)
    modified = False
    procs_new = 0
    procs_updated = 0
    procs_unchanged = 0

    for proc, lst_info in reversed(proc_data):
        end_line = proc['end_line']
        indent = proc['end_indent']

        # generate epilogue
        epilogue = generate_epilogue(proc, lst_info, no_clear)
        formatted = format_epilogue(epilogue, indent)

        # check for existing generated block above END
        # look backwards from end_line for markers
        existing_start = None
        existing_end = None
        j = end_line - 1
        while j >= 0:
            if _GEN_END_RE.match(output_lines[j]):
                existing_end = j
                k = j - 1
                while k >= 0:
                    if _GEN_START_RE.match(output_lines[k]):
                        existing_start = k
                        break
                    k -= 1
                break
            elif output_lines[j].strip() and not output_lines[j].strip().startswith('(*'):
                break
            j -= 1

        if existing_start is not None and existing_end is not None:
            # replace existing block
            old_block = output_lines[existing_start:existing_end + 1]
            if old_block == formatted:
                procs_unchanged += 1
            else:
                output_lines[existing_start:existing_end + 1] = formatted
                procs_updated += 1
                modified = True
        else:
            # insert new block before END ProcName;
            # add blank line before marker for readability
            insert = [''] + formatted
            output_lines[end_line:end_line] = insert
            procs_new += 1
            modified = True

    # ensure SYSTEM is imported
    if modified:
        if ensure_system_import(output_lines):
            print(f'{PROG_NAME}: added SYSTEM to IMPORT in {mod_path.name}')

    if modified and error_count == 0:
        new_content = '\n'.join(output_lines)
        if new_content != mod_content:
            if dry_run:
                print(f'{PROG_NAME}: would update {mod_path}')
            else:
                mod_path.write_text(new_content, encoding='utf-8')
                parts = []
                if procs_new: parts.append(f'{procs_new} new')
                if procs_updated: parts.append(f'{procs_updated} updated')
                if procs_unchanged: parts.append(f'{procs_unchanged} unchanged')
                detail = f' ({", ".join(parts)})' if parts else ''
                print(f'{PROG_NAME}: updated {mod_path}{detail}')
            for proc, lst_info in proc_data:
                dealloc = (lst_info['push_count'] - 1) * 4 + lst_info['sub_bytes']
                print(f'  {proc["name"]}: push={lst_info["push_count"]} '
                      f'sub={lst_info["sub_bytes"]} dealloc={dealloc} '
                      f'gpr=r{lst_info["highest_gpr"]} '
                      f'fpu={"yes" if lst_info["has_fpu"] else "no"} '
                      f'func={"yes" if proc["is_function"] else "no"}')
        else:
            print(f'{PROG_NAME}: no changes {mod_path}')
            modified = False

    return modified, error_count


# --- Main ---

def main():
    parser = argparse.ArgumentParser(
        prog=PROG_NAME,
        description='Insert Secure return epilogues into exported procedures.',
    )
    parser.add_argument('files', nargs='+', type=Path,
        help='.mod files (corresponding .lst expected alongside)')
    parser.add_argument('--no-clear', action='store_true',
        help='skip register sanitisation (no_clear S/NS model)')
    parser.add_argument('--dry-run', '-n', action='store_true',
        help='show what would be generated, do not write')
    args = parser.parse_args()

    # derive .lst from .mod (same directory, same base name)
    pairs = []
    for mod_f in args.files:
        if mod_f.suffix.lower() != '.mod':
            print(f'{PROG_NAME}: expected .mod file, got: {mod_f}',
                  file=sys.stderr)
            sys.exit(1)
        lst_f = mod_f.with_suffix('.lst')
        if not lst_f.is_file():
            print(f'{PROG_NAME}: warning: listing not found: {lst_f}, '
                  f'skipping {mod_f.name}', file=sys.stderr)
            continue
        pairs.append((mod_f, lst_f))

    total_modified = 0
    total_errors = 0

    for mod_f, lst_f in pairs:
        mod, errs = process_module(
            mod_f, lst_f,
            args.no_clear,
            args.dry_run,
        )
        if mod:
            total_modified += 1
        total_errors += errs

    print(f'{PROG_NAME}: {len(pairs)} module(s) processed, '
          f'{total_modified} modified, {total_errors} error(s)')

    sys.exit(1 if total_errors > 0 else 0)


if __name__ == '__main__':
    main()
