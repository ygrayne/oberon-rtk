#!/usr/bin/env python3
"""
gen-asm -- Translate inline assembly blocks in Oberon source files.
--
Finds (* ASM ... END ASM *) blocks in Oberon .mod files and generates
the corresponding SYSTEM.EMIT/EMITH/LDREG/REG calls. Generated code is
placed between (* +ASM *) and (* -ASM *) markers and replaced on each
re-run. The ASM block is the source of truth; the programmer edits only
the ASM block.

Handcrafted SYSTEM calls outside the markers are never touched.
--
Usage:
    python gen-asm.py File.mod [File2.mod ...]
    python gen-asm.py directory/
    python gen-asm.py --recursive lib/v3.1/

Example:
    python gen-asm.py Secure.mod
    python gen-asm.py config/
    python gen-asm.py --recursive lib/v3.1/ --dry-run
--
Copyright (c) 2026 Gray, gray@grayraven.org
https://oberon-rtk.org/licences/
"""

import sys
import re
import argparse
from pathlib import Path


PROG_NAME = 'gen-asm'

# --- ASM block markers ---

_ASM_BLOCK_START = re.compile(r'^\s*\(\*\s*[Aa][Ss][Mm]\b')
_ASM_BLOCK_END = re.compile(r'\b[Ee][Nn][Dd]\s+[Aa][Ss][Mm]\s*\*\)')
_GEN_START = '(* +asm *)'
_GEN_END = '(* -asm *)'
_GEN_START_RE = re.compile(r'^\s*\(\*\s*\+[Aa][Ss][Mm]\s*\*\)')
_GEN_END_RE = re.compile(r'^\s*\(\*\s*-[Aa][Ss][Mm]\s*\*\)')

# --- Instruction encodings ---

# SYSm values for MRS/MSR system registers
SYSREG = {
    'APSR_NZCVQ': 0x00,
    'XPSR':       0x03,
    'IPSR':       0x05,
    'MSP':        0x08,
    'PSP':        0x09,
    'MSPLIM':     0x0A,
    'PSPLIM':     0x0B,
    'PRIMASK':    0x10,
    'BASEPRI':    0x11,
    'FAULTMASK':  0x13,
    'CONTROL':    0x14,
    'MSP_NS':     0x88,
    'PSP_NS':     0x89,
    'MSPLIM_NS':  0x8A,
    'PSPLIM_NS':  0x8B,
    'CONTROL_NS': 0x94,
    'SP_NS':      0x98,
}

# Fixed 32-bit instructions (SYSTEM.EMIT)
FIXED_32 = {
    'DSB': 0xF3BF8F4F,
    'ISB': 0xF3BF8F6F,
    'DMB': 0xF3BF8F5F,
}

# Fixed 16-bit instructions (SYSTEM.EMITH)
FIXED_16 = {
    'NOP':      0xBF00,
    'WFI':      0xBF30,
    'WFE':      0xBF20,
    'SEV':      0xBF40,
    'CPSIE_I':  0xB662,
    'CPSID_I':  0xB672,
    'CPSIE_F':  0xB661,
    'CPSID_F':  0xB671,
    'BXNS_LR':  0x4774,
}

# POP.W {LR} — fixed 32-bit
POP_LR = 0xE8BD4000


# --- Register parsing ---

_REG_RE = re.compile(r'^[Rr](\d+)$')

def parse_reg(s):
    """Parse register name (r0-r15 or R0-R15), return number or None."""
    m = _REG_RE.match(s.strip())
    if m:
        n = int(m.group(1))
        if 0 <= n <= 15:
            return n
    return None

def parse_dreg(s):
    """Parse double FP register (d0-d15 or D0-D15), return number or None."""
    s = s.strip().upper()
    if s.startswith('D') and s[1:].isdigit():
        n = int(s[1:])
        if 0 <= n <= 15:
            return n
    return None

def parse_sreg(s):
    """Parse single FP register (s0-s31 or S0-S31), return number or None."""
    s = s.strip().upper()
    if s.startswith('S') and s[1:].isdigit():
        n = int(s[1:])
        if 0 <= n <= 31:
            return n
    return None


# --- Instruction encoding functions ---

def encode_mrs(rd, sysreg):
    """MRS Rd, sysreg -> 32-bit encoding."""
    # MRS: 11110011 1110 1111 1000 Rd[11:8] SYSm[7:0]
    return 0xF3EF8000 | (rd << 8) | sysreg

def encode_msr(rn, sysreg):
    """MSR sysreg, Rn -> 32-bit encoding."""
    # MSR: 11110011 1000 Rn[19:16] 1000 (mask) SYSm[7:0]
    # For APSR_nzcvq: mask bits [11:10] = 10
    if sysreg == SYSREG['APSR_NZCVQ']:
        return 0xF3808800 | (rn << 16) | sysreg
    return 0xF3808800 | (rn << 16) | sysreg

def encode_bx(rn):
    """BX Rn -> 16-bit encoding."""
    return 0x4700 | (rn << 3)

def encode_blxns(rn):
    """BLXNS Rn -> 16-bit encoding."""
    return 0x4784 | (rn << 3)

def encode_svc(imm):
    """SVC #N -> 16-bit encoding."""
    if not (0 <= imm <= 255):
        return None
    return 0xDF00 | imm

def encode_add_sp(n):
    """ADD SP, #N -> 16-bit encoding. N must be multiple of 4."""
    if n % 4 != 0 or n < 0 or n > 508:
        return None
    return 0xB000 | (n // 4)

def encode_tt(rd, rn):
    """TT Rd, Rn -> 32-bit encoding."""
    return 0xE840F000 | (rn << 16) | (rd << 8)

def encode_mov_imm8(rd, imm):
    """MOV Rd, #imm8 (R0-R7) -> 16-bit encoding."""
    if rd > 7 or not (0 <= imm <= 255):
        return None
    return 0x2000 | (rd << 8) | imm

def encode_mov_w(rd, imm):
    """MOV.W Rd, #imm16 -> 32-bit encoding.
    Only handles imm=0 (the sanitisation case) for now.
    Full Thumb2 modified-immediate encoding is complex."""
    if imm == 0:
        # MOV.W Rd, #0: encoding T2: 11110 0 00 010 0 1111 0 imm3 Rd imm8
        # = F04F 0000 | (Rd << 8)
        return 0xF04F0000 | (rd << 8)
    # MOVW Rd, #imm16: encoding T3
    # 11110 i 10 0100 imm4 0 imm3 Rd imm8
    if 0 <= imm <= 0xFFFF:
        imm4 = (imm >> 12) & 0xF
        i = (imm >> 11) & 1
        imm3 = (imm >> 8) & 7
        imm8 = imm & 0xFF
        hw1 = 0xF240 | (i << 10) | imm4
        hw2 = (imm3 << 12) | (rd << 8) | imm8
        return (hw1 << 16) | hw2
    return None

def encode_vmov_s_r(sn, rn):
    """VMOV Sn, Rn (core to single FP) -> 32-bit encoding."""
    # VMOV Sn, Rt: 1110 1110 000 0 Vn:4 Rt:4 1010 N 001 0000
    # Sn = (Vn << 1) | N
    vn = sn >> 1
    n = sn & 1
    return 0xEE000A10 | (vn << 16) | (rn << 12) | (n << 7)

def encode_vmov_d_rr(dd, rm, rn):
    """VMOV Dd, Rm, Rn (two core regs to double FP) -> 32-bit encoding."""
    # VMOV Dm, Rt, Rt2: 1110 1100 010 0 Rt2:4 Rt:4 1011 00 M 1 Vm:4
    # Dd = (M << 4) | Vm
    vm = dd & 0xF
    m = (dd >> 4) & 1
    return 0xEC400B10 | (rn << 16) | (rm << 12) | (m << 5) | vm

def encode_vmsr_fpscr(rn):
    """VMSR FPSCR, Rn -> 32-bit encoding."""
    # VMSR FPSCR, Rt: 1110 1110 1110 0001 Rt:4 1010 0001 0000
    return 0xEEE10A10 | (rn << 12)


# --- Hex formatting ---

def hex32(val):
    """Format 32-bit value as Oberon hex constant."""
    return f'0{val:08X}H'

def hex16(val):
    """Format 16-bit value as Oberon hex constant."""
    return f'0{val:04X}H'


# --- ASM line parser ---

def error(msg, filename=None, lineno=None):
    loc = ''
    if filename:
        loc = f'{filename}'
        if lineno is not None:
            loc += f':{lineno}'
        loc += ': '
    print(f'{PROG_NAME}: {loc}{msg}', file=sys.stderr)

def fatal(msg, filename=None, lineno=None):
    error(msg, filename, lineno)
    sys.exit(1)


def parse_asm_line(line, filename=None, lineno=None):
    """Parse one assembly line from an ASM block.

    Returns a list of (emit_call, comment) tuples, where emit_call is
    a SYSTEM.xxx call string and comment is the assembly mnemonic.
    Multiple tuples are returned when variable binding generates
    LDREG/REG calls alongside the instruction.

    Returns None on parse error (error is printed).
    """
    line = line.strip()
    if not line or line.startswith('(*'):
        return []

    # Strip inline comment (* ... *)
    comment_match = re.search(r'\(\*.*?\*\)', line)
    if comment_match:
        line = line[:comment_match.start()].strip()
    if not line:
        return []

    results = []

    # Check for output binding: instruction -> var
    output_var = None
    if '->' in line and not line.startswith(('(*',)):
        # Could be: "mrs r11, PSP -> varName" (output)
        # or: "varName -> msr BASEPRI, r3" (input)
        parts = line.split('->')
        if len(parts) > 2:
            error('multiple -> bindings on one line are not supported',
                  filename, lineno)
            return None
        if len(parts) == 2:
            left = parts[0].strip()
            right = parts[1].strip()
            # Determine direction: if left starts with a known mnemonic, it's output
            # If right starts with a known mnemonic, it's input
            left_first = left.split()[0].upper() if left.split() else ''
            right_first = right.split()[0].upper() if right.split() else ''

            if left_first in _ALL_MNEMONICS:
                # output: "instruction -> var"
                output_var = right
                line = left
            elif right_first in _ALL_MNEMONICS:
                # input: "var -> instruction"
                input_var = left
                line = right
                # Parse the instruction to find the register
                instr_result = _parse_instruction(line, filename, lineno)
                if instr_result is None:
                    return None
                emit_calls, reg_used, comment = instr_result
                # Generate LDREG before the instruction
                if reg_used is not None:
                    results.append((f'SYSTEM.LDREG({reg_used}, {input_var})',
                                    f'{input_var} -> r{reg_used}'))
                results.extend([(call, comment) for call in emit_calls])
                return results
            else:
                error(f'cannot determine binding direction: {line}',
                      filename, lineno)
                return None

    # Parse the instruction
    instr_result = _parse_instruction(line, filename, lineno)
    if instr_result is None:
        return None
    emit_calls, reg_used, comment = instr_result

    results.extend([(call, comment) for call in emit_calls])

    # Output binding: emit REG after instruction
    if output_var is not None and reg_used is not None:
        results.append((f'{output_var} := SYSTEM.REG({reg_used})',
                         f'r{reg_used} -> {output_var}'))

    return results


# Set of all known mnemonics for binding direction detection
_ALL_MNEMONICS = {
    'DSB', 'ISB', 'DMB',
    'NOP', 'WFI', 'WFE', 'SEV',
    'CPSIE', 'CPSID',
    'MRS', 'MSR',
    'BX', 'BXNS', 'BLXNS',
    'POP.W', 'ADD', 'SVC', 'TT',
    'MOV', 'MOV.W',
    'VMOV', 'VMSR',
}


def _parse_instruction(line, filename=None, lineno=None):
    """Parse an assembly instruction line.

    Returns (emit_calls, reg_used, comment) where:
      emit_calls: list of SYSTEM.EMIT/EMITH call strings
      reg_used: register number used (for variable binding) or None
      comment: assembly mnemonic string for the comment

    Returns None on error.
    """
    tokens = line.split()
    if not tokens:
        return None

    mnemonic = tokens[0].upper()
    operands = ' '.join(tokens[1:])
    # Split operands by comma
    ops = [s.strip() for s in operands.split(',')] if operands else []

    # --- Fixed 32-bit ---
    if mnemonic in FIXED_32:
        enc = FIXED_32[mnemonic]
        return ([f'SYSTEM.EMIT({hex32(enc)})'], None, mnemonic.lower())

    # --- Fixed 16-bit ---
    if mnemonic in FIXED_16:
        enc = FIXED_16[mnemonic]
        return ([f'SYSTEM.EMITH({hex16(enc)})'], None, mnemonic.lower())

    # --- POP.W {LR} ---
    if mnemonic == 'POP.W':
        # Expect {LR} or { LR }
        rest = operands.strip().upper().replace(' ', '')
        if rest in ('{LR}',):
            return ([f'SYSTEM.EMIT({hex32(POP_LR)})'], None, 'pop.w {lr}')
        error(f'POP.W: expected {{LR}}, got {operands}', filename, lineno)
        return None

    # --- CPSIE / CPSID ---
    if mnemonic in ('CPSIE', 'CPSID'):
        if len(ops) != 1:
            error(f'{mnemonic}: expected I or F operand', filename, lineno)
            return None
        flag = ops[0].upper()
        key = f'{mnemonic}_{flag}'
        if key not in FIXED_16:
            error(f'{mnemonic}: unknown flag {flag} (expected I or F)',
                  filename, lineno)
            return None
        enc = FIXED_16[key]
        return ([f'SYSTEM.EMITH({hex16(enc)})'], None,
                f'{mnemonic.lower()} {flag.lower()}')

    # --- MRS Rd, sysreg ---
    if mnemonic == 'MRS':
        if len(ops) != 2:
            error('MRS: expected Rd, sysreg', filename, lineno)
            return None
        rd = parse_reg(ops[0])
        if rd is None:
            error(f'MRS: invalid register {ops[0]}', filename, lineno)
            return None
        sysreg_name = ops[1].upper()
        if sysreg_name not in SYSREG:
            error(f'MRS: unknown system register {ops[1]}', filename, lineno)
            return None
        enc = encode_mrs(rd, SYSREG[sysreg_name])
        return ([f'SYSTEM.EMIT({hex32(enc)})'], rd,
                f'mrs r{rd}, {sysreg_name}')

    # --- MSR sysreg, Rn ---
    if mnemonic == 'MSR':
        if len(ops) != 2:
            error('MSR: expected sysreg, Rn', filename, lineno)
            return None
        sysreg_name = ops[0].upper()
        if sysreg_name not in SYSREG:
            error(f'MSR: unknown system register {ops[0]}', filename, lineno)
            return None
        rn = parse_reg(ops[1])
        if rn is None:
            error(f'MSR: invalid register {ops[1]}', filename, lineno)
            return None
        enc = encode_msr(rn, SYSREG[sysreg_name])
        return ([f'SYSTEM.EMIT({hex32(enc)})'], rn,
                f'msr {sysreg_name}, r{rn}')

    # --- BX Rn ---
    if mnemonic == 'BX':
        if len(ops) != 1:
            error('BX: expected Rn', filename, lineno)
            return None
        rn = parse_reg(ops[0])
        if rn is None:
            error(f'BX: invalid register {ops[0]}', filename, lineno)
            return None
        enc = encode_bx(rn)
        return ([f'SYSTEM.EMITH({hex16(enc)})'], None, f'bx r{rn}')

    # --- BXNS LR ---
    if mnemonic == 'BXNS':
        rest = operands.strip().upper()
        if rest == 'LR':
            enc = FIXED_16['BXNS_LR']
            return ([f'SYSTEM.EMITH({hex16(enc)})'], None, 'bxns lr')
        error(f'BXNS: expected LR, got {operands}', filename, lineno)
        return None

    # --- BLXNS Rn ---
    if mnemonic == 'BLXNS':
        if len(ops) != 1:
            error('BLXNS: expected Rn', filename, lineno)
            return None
        rn = parse_reg(ops[0])
        if rn is None:
            error(f'BLXNS: invalid register {ops[0]}', filename, lineno)
            return None
        enc = encode_blxns(rn)
        return ([f'SYSTEM.EMITH({hex16(enc)})'], rn, f'blxns r{rn}')

    # --- SVC #N ---
    if mnemonic == 'SVC':
        if len(ops) != 1:
            error('SVC: expected #N', filename, lineno)
            return None
        imm_str = ops[0].lstrip('#')
        try:
            imm = int(imm_str, 0)
        except ValueError:
            error(f'SVC: invalid immediate {ops[0]}', filename, lineno)
            return None
        enc = encode_svc(imm)
        if enc is None:
            error(f'SVC: immediate {imm} out of range (0-255)',
                  filename, lineno)
            return None
        return ([f'SYSTEM.EMITH({hex16(enc)})'], None, f'svc #{imm}')

    # --- ADD SP, #N ---
    if mnemonic == 'ADD':
        if len(ops) != 2:
            error('ADD: expected SP, #N', filename, lineno)
            return None
        if ops[0].upper() != 'SP':
            error(f'ADD: expected SP as first operand, got {ops[0]}',
                  filename, lineno)
            return None
        imm_str = ops[1].lstrip('#')
        try:
            imm = int(imm_str, 0)
        except ValueError:
            error(f'ADD: invalid immediate {ops[1]}', filename, lineno)
            return None
        enc = encode_add_sp(imm)
        if enc is None:
            error(f'ADD SP: immediate {imm} not a multiple of 4 or out of range',
                  filename, lineno)
            return None
        return ([f'SYSTEM.EMITH({hex16(enc)})'], None, f'add sp, #{imm}')

    # --- TT Rd, Rn ---
    if mnemonic == 'TT':
        if len(ops) != 2:
            error('TT: expected Rd, Rn', filename, lineno)
            return None
        rd = parse_reg(ops[0])
        rn = parse_reg(ops[1])
        if rd is None:
            error(f'TT: invalid register {ops[0]}', filename, lineno)
            return None
        if rn is None:
            error(f'TT: invalid register {ops[1]}', filename, lineno)
            return None
        enc = encode_tt(rd, rn)
        return ([f'SYSTEM.EMIT({hex32(enc)})'], rd, f'tt r{rd}, r{rn}')

    # --- MOV Rd, #imm8 (R0-R7) ---
    if mnemonic == 'MOV':
        if len(ops) != 2:
            error('MOV: expected Rd, #imm8', filename, lineno)
            return None
        rd = parse_reg(ops[0])
        if rd is None:
            error(f'MOV: invalid register {ops[0]}', filename, lineno)
            return None
        imm_str = ops[1].lstrip('#')
        try:
            imm = int(imm_str, 0)
        except ValueError:
            error(f'MOV: invalid immediate {ops[1]}', filename, lineno)
            return None
        enc = encode_mov_imm8(rd, imm)
        if enc is None:
            error(f'MOV: R{rd} > R7 or immediate out of range (use MOV.W)',
                  filename, lineno)
            return None
        return ([f'SYSTEM.EMITH({hex16(enc)})'], rd, f'mov r{rd}, #{imm}')

    # --- MOV.W Rd, #imm ---
    if mnemonic == 'MOV.W':
        if len(ops) != 2:
            error('MOV.W: expected Rd, #imm', filename, lineno)
            return None
        rd = parse_reg(ops[0])
        if rd is None:
            error(f'MOV.W: invalid register {ops[0]}', filename, lineno)
            return None
        imm_str = ops[1].lstrip('#')
        try:
            imm = int(imm_str, 0)
        except ValueError:
            error(f'MOV.W: invalid immediate {ops[1]}', filename, lineno)
            return None
        enc = encode_mov_w(rd, imm)
        if enc is None:
            error(f'MOV.W: cannot encode immediate {imm}',
                  filename, lineno)
            return None
        return ([f'SYSTEM.EMIT({hex32(enc)})'], rd, f'mov.w r{rd}, #{imm}')

    # --- VMOV Sn, Rn (core to single FP) ---
    # --- VMOV Dd, Rm, Rn (core pair to double FP) ---
    if mnemonic == 'VMOV':
        if len(ops) == 2:
            # VMOV Sn, Rn
            sn = parse_sreg(ops[0])
            rn = parse_reg(ops[1])
            if sn is not None and rn is not None:
                enc = encode_vmov_s_r(sn, rn)
                return ([f'SYSTEM.EMIT({hex32(enc)})'], None,
                        f'vmov s{sn}, r{rn}')
            error(f'VMOV: expected Sn, Rn — got {ops[0]}, {ops[1]}',
                  filename, lineno)
            return None
        elif len(ops) == 3:
            # VMOV Dd, Rm, Rn
            dd = parse_dreg(ops[0])
            rm = parse_reg(ops[1])
            rn = parse_reg(ops[2])
            if dd is not None and rm is not None and rn is not None:
                enc = encode_vmov_d_rr(dd, rm, rn)
                return ([f'SYSTEM.EMIT({hex32(enc)})'], None,
                        f'vmov d{dd}, r{rm}, r{rn}')
            error(f'VMOV: expected Dd, Rm, Rn — got {", ".join(ops)}',
                  filename, lineno)
            return None
        error(f'VMOV: expected 2 or 3 operands, got {len(ops)}',
              filename, lineno)
        return None

    # --- VMSR FPSCR, Rn ---
    if mnemonic == 'VMSR':
        if len(ops) != 2:
            error('VMSR: expected FPSCR, Rn', filename, lineno)
            return None
        if ops[0].upper() != 'FPSCR':
            error(f'VMSR: expected FPSCR, got {ops[0]}', filename, lineno)
            return None
        rn = parse_reg(ops[1])
        if rn is None:
            error(f'VMSR: invalid register {ops[1]}', filename, lineno)
            return None
        enc = encode_vmsr_fpscr(rn)
        return ([f'SYSTEM.EMIT({hex32(enc)})'], None, f'vmsr FPSCR, r{rn}')

    # --- Unknown ---
    error(f'unknown instruction: {mnemonic}', filename, lineno)
    return None


# --- ASM block extraction and processing ---

def extract_asm_lines(block_text):
    """Extract assembly lines from an ASM block (between ASM and END ASM).

    Returns list of (line_text, line_offset) tuples.
    """
    lines = block_text.split('\n')
    result = []
    in_body = False
    for i, line in enumerate(lines):
        if not in_body:
            if _ASM_BLOCK_START.search(line):
                # Body starts after (* ASM on this line
                # Check if there's content after ASM on same line
                m = re.search(r'\(\*\s*ASM\b\s*(.*)', line)
                if m:
                    rest = m.group(1).strip()
                    if rest and not re.match(r'END\s+ASM', rest):
                        result.append((rest, i))
                in_body = True
        else:
            if _ASM_BLOCK_END.search(line):
                # Check for content before END ASM on same line
                m = re.match(r'(.*?)\s*END\s+ASM\s*\*\)', line)
                if m:
                    rest = m.group(1).strip()
                    if rest:
                        result.append((rest, i))
                break
            result.append((line, i))
    return result


def translate_asm_block(block_text, indent, filename=None, block_start_line=0):
    """Translate an ASM block into SYSTEM.xxx call lines.

    Returns list of indented Oberon source lines, or None on error.
    """
    asm_lines = extract_asm_lines(block_text)
    output = []
    has_error = False

    for asm_line, offset in asm_lines:
        lineno = block_start_line + offset + 1  # 1-based
        result = parse_asm_line(asm_line, filename, lineno)
        if result is None:
            has_error = True
            continue
        for call, comment in result:
            if comment:
                output.append(f'{indent}{call};  (* {comment} *)')
            else:
                output.append(f'{indent}{call};')

    if has_error:
        return None

    # Remove trailing semicolon from last line (Oberon: no semicolon
    # before END or before next statement separator)
    # Actually, keep semicolons — they are valid as statement separators
    # and the programmer's surrounding code determines if one is needed.

    return output


# --- IMPORT list handling ---

_IMPORT_RE = re.compile(r'^(\s*)(IMPORT\b)(.*)', re.DOTALL)

def ensure_system_import(lines):
    """Ensure SYSTEM is in the IMPORT list. Modifies lines in place.
    Returns True if SYSTEM was added, False if already present or
    no IMPORT found."""
    for i, line in enumerate(lines):
        m = _IMPORT_RE.match(line)
        if m:
            indent = m.group(1)
            keyword = m.group(2)
            rest = m.group(3)
            # check if SYSTEM is already imported (as a whole word)
            if re.search(r'\bSYSTEM\b', rest):
                return False
            # insert SYSTEM after IMPORT keyword
            lines[i] = f'{indent}{keyword} SYSTEM,{rest}'
            return True
    return False


# --- File processing ---

def process_file(filepath, dry_run=False, verbose=False):
    """Process a single .mod file. Returns (modified, error_count)."""
    filepath = Path(filepath)
    try:
        content = filepath.read_text(encoding='utf-8')
    except (OSError, UnicodeDecodeError) as e:
        error(f'cannot read: {e}', str(filepath))
        return False, 1

    lines = content.split('\n')
    output_lines = []
    i = 0
    modified = False
    error_count = 0
    blocks_new = 0
    blocks_updated = 0
    blocks_unchanged = 0

    while i < len(lines):
        line = lines[i]

        # Check for start of ASM block
        if _ASM_BLOCK_START.search(line):
            # Collect the entire ASM block
            block_lines = [line]
            block_start = i
            found_end = _ASM_BLOCK_END.search(line)

            if not found_end:
                j = i + 1
                while j < len(lines):
                    block_lines.append(lines[j])
                    if _ASM_BLOCK_END.search(lines[j]):
                        found_end = True
                        break
                    j += 1

            if not found_end:
                error('unterminated ASM block', str(filepath), i + 1)
                output_lines.append(line)
                i += 1
                error_count += 1
                continue

            block_end = block_start + len(block_lines) - 1
            block_text = '\n'.join(block_lines)

            # Determine indentation from the ASM block line
            indent_match = re.match(r'^(\s*)', line)
            indent = indent_match.group(1) if indent_match else '    '

            # Output the ASM block unchanged
            output_lines.extend(block_lines)
            i = block_end + 1

            # Check if there's an existing generated block to replace
            old_gen_lines = None
            if i < len(lines) and _GEN_START_RE.search(lines[i]):
                old_gen_lines = []
                i += 1
                while i < len(lines):
                    if _GEN_END_RE.search(lines[i]):
                        i += 1
                        break
                    old_gen_lines.append(lines[i])
                    i += 1

            # Translate the ASM block
            translated = translate_asm_block(
                block_text, indent, str(filepath), block_start)

            if translated is None:
                error_count += 1
                # Keep going but don't insert generated code
                continue

            if translated:
                # Insert generated block with markers
                output_lines.append(f'{indent}{_GEN_START}')
                output_lines.extend(translated)
                output_lines.append(f'{indent}{_GEN_END}')
                if old_gen_lines is None:
                    blocks_new += 1
                elif old_gen_lines != translated:
                    blocks_updated += 1
                else:
                    blocks_unchanged += 1
                modified = True
        else:
            # Check for orphaned generated block (no ASM block before it)
            if _GEN_START_RE.search(line):
                # Pass through — don't touch orphaned markers
                output_lines.append(line)
                i += 1
                continue

            output_lines.append(line)
            i += 1

    if modified and error_count == 0:
        # ensure SYSTEM is imported (needed for generated SYSTEM.EMIT etc.)
        if ensure_system_import(output_lines):
            if verbose:
                print(f'{PROG_NAME}: added SYSTEM to IMPORT list in {filepath}')
        new_content = '\n'.join(output_lines)
        if new_content != content:
            if dry_run:
                print(f'{PROG_NAME}: would update {filepath}')
            else:
                filepath.write_text(new_content, encoding='utf-8')
                if verbose:
                    parts = []
                    if blocks_new: parts.append(f'{blocks_new} new')
                    if blocks_updated: parts.append(f'{blocks_updated} updated')
                    if blocks_unchanged: parts.append(f'{blocks_unchanged} unchanged')
                    detail = f' ({", ".join(parts)})' if parts else ''
                    print(f'{PROG_NAME}: updated {filepath}{detail}')
        else:
            if verbose:
                print(f'{PROG_NAME}: no changes {filepath}')
            modified = False
    elif error_count > 0:
        print(f'{PROG_NAME}: {filepath}: {error_count} error(s), file not modified',
              file=sys.stderr)

    return modified, error_count


def collect_mod_files(paths, recursive=False):
    """Collect .mod files from paths (files and/or directories)."""
    result = []
    for p in paths:
        p = Path(p)
        if p.is_file():
            if p.suffix.lower() == '.mod':
                result.append(p)
            else:
                error(f'not a .mod file: {p}')
        elif p.is_dir():
            if recursive:
                result.extend(sorted(p.rglob('*.mod')))
                result.extend(sorted(p.rglob('*.Mod')))
            else:
                result.extend(sorted(p.glob('*.mod')))
                result.extend(sorted(p.glob('*.Mod')))
        else:
            error(f'not found: {p}')
    # Deduplicate preserving order
    seen = set()
    deduped = []
    for f in result:
        resolved = f.resolve()
        if resolved not in seen:
            seen.add(resolved)
            deduped.append(f)
    return deduped


# --- Main ---

def main():
    parser = argparse.ArgumentParser(
        prog=PROG_NAME,
        description='Translate inline assembly blocks in Oberon source files.',
    )
    parser.add_argument('paths', nargs='+', type=Path,
        help='.mod files or directories to process')
    parser.add_argument('--recursive', '-r', action='store_true',
        help='scan directories recursively')
    parser.add_argument('--dry-run', '-n', action='store_true',
        help='show what would be generated, do not write')
    parser.add_argument('-v', '--verbose', action='store_true',
        help='verbose output')
    args = parser.parse_args()

    files = collect_mod_files(args.paths, args.recursive)
    if not files:
        fatal('no .mod files found')

    total_modified = 0
    total_errors = 0

    for filepath in files:
        mod, errs = process_file(filepath, args.dry_run, args.verbose)
        if mod:
            total_modified += 1
        total_errors += errs

    print(f'{PROG_NAME}: {len(files)} file(s) processed, '
          f'{total_modified} modified, {total_errors} error(s)')

    sys.exit(1 if total_errors > 0 else 0)


if __name__ == '__main__':
    main()
