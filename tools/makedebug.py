#!/usr/bin/env python3

"""
Extract debug data from listing files.
--
Parses Astrobe modified listing files (.alst) to extract:
- Procedure symbols (name, address, size)
- DWARF line number info mapping code addresses to source file lines
- Stack unwinding data (.debug_frame)
--
Designed as an importable module for integration into makeelf.py,
and also callable from the command line.
--
Run with option -h for help.
--
To run form the command line, put into a directory on $PYTHONPATH, and run as
'python -m  makedebug ...'
--
Copyright (c) 2026 Gray, gray@grayraven.org
https://oberon-rtk.org/licences/
"""

import sys
import re
import json
import struct
import argparse
from pathlib import Path
from dataclasses import dataclass, field


SOURCE_EXT = '.alst'  # source listing file extension


# LEB128 encoding

def uleb128(value):
    """Encode unsigned integer as ULEB128."""
    result = bytearray()
    while True:
        byte = value & 0x7F
        value >>= 7
        if value != 0:
            byte |= 0x80
        result.append(byte)
        if value == 0:
            break
    return bytes(result)


def sleb128(value):
    """Encode signed integer as SLEB128."""
    result = bytearray()
    while True:
        byte = value & 0x7F
        value >>= 7
        if (value == 0 and (byte & 0x40) == 0) or (value == -1 and (byte & 0x40) != 0):
            result.append(byte)
            break
        else:
            byte |= 0x80
            result.append(byte)
    return bytes(result)


# Regex patterns

ASM_LINE_RE = re.compile( r'^\.\s+(\d+)\s+([0-9A-Fa-f]+)\s+([0-9A-Fa-f]+)\s+(.*)')
MODULE_RE = re.compile(r'^MODULE\s+(\w+)\s*;')
PROCEDURE_RE = re.compile(r'^\s*PROCEDURE\*?\s+(\w+)\*?')
PUSH_LR_RE = re.compile(r'push(?:\.w)?\s+\{.*lr.*\}', re.IGNORECASE)
POP_PC_RE = re.compile(r'pop(?:\.w)?\s+\{.*pc.*\}', re.IGNORECASE)

# Parse push register list: "push { r0, r1, lr }" or "push.w { r4, ... lr }"
PUSH_REGS_RE = re.compile(r'push(?:\.w)?\s+\{([^}]+)\}', re.IGNORECASE)

# Parse sub sp immediate: "sub sp,#4" or "sub sp, #8"
SUB_SP_RE = re.compile(r'sub\s+sp,\s*#(\d+)', re.IGNORECASE)

# Data annotations — these are not executable instructions
DATA_ANNOTATION_RE = re.compile(r'<(Const|Global|String|Case|Type|LineNo|Pad):')

@dataclass
class ProcSymbol:
    name: str       # Module.Procedure or Module..init
    address: int    # absolute code address
    size: int       # bytes


@dataclass
class LineEntry:
    address: int    # absolute code address
    line: int       # 1-based line number in the source file


@dataclass
class FrameInfo:
    """Stack frame description for one procedure."""
    address: int        # procedure start address
    size: int           # procedure size in bytes
    push_size: int      # size of push instruction (2 or 4 bytes)
    saved_regs: list    # register numbers in push order (lowest first)
    sp_adjust: int = 0  # additional SP adjustment from sub sp, #n
    sub_sp_size: int = 0  # size of sub sp instruction (0 if none)


@dataclass
class ModuleDebug:
    name: str
    filename: str   # e.g. "LED.alst"
    procedures: list  # list of ProcSymbol
    line_entries: list  # list of LineEntry, sorted by address
    frame_infos: list = field(default_factory=list)  # list of FrameInfo
    low_pc: int = 0
    high_pc: int = 0


@dataclass
class DebugData:
    """Complete debug data extracted from source listing files."""
    modules: list           # list of ModuleDebug
    procedures: list        # flat list of all ProcSymbol, sorted by address
    debug_line: bytes = b''
    debug_info: bytes = b''
    debug_abbrev: bytes = b''
    debug_aranges: bytes = b''
    debug_frame: bytes = b''
    arm_attributes: bytes = b''


# Source file parsing

def instr_size(hex_instr):
    """Determine instruction size in bytes from hex instruction field length."""
    return 2 if len(hex_instr) <= 5 else 4


def is_data_line(rest):
    """Check if an assembly line's mnemonic/args indicate embedded data."""
    return DATA_ANNOTATION_RE.search(rest) is not None


def parse_push_regs(mnemonic_args):
    """Parse register list from a push instruction.

    Returns list of register numbers in push order (lowest first),
    or None if not a push instruction.

    Examples:
        "push { lr }"                    -> [14]
        "push { r0, r1, lr }"           -> [0, 1, 14]
        "push.w { r4, r5, ..., r11, lr }" -> [4,5,...,11,14]
    """
    m = PUSH_REGS_RE.search(mnemonic_args)
    if not m:
        return None

    reg_str = m.group(1)
    regs = []
    for part in reg_str.split(','):
        part = part.strip().lower()
        if part == 'lr':
            regs.append(14)
        elif part == 'sp':
            regs.append(13)
        elif part == 'pc':
            regs.append(15)
        elif part.startswith('r'):
            try:
                regs.append(int(part[1:]))
            except ValueError:
                pass

    regs.sort()  # ARM push saves in register-number order
    return regs if regs else None


def parse_listing(filepath, source_lines=False):
    """Parse a single listing file. Returns a ModuleDebug or None.

    Args:
        filepath: Path to the listing file
        source_lines: If True, map code addresses to Oberon source line
            numbers instead of assembly line numbers. Each assembly
            instruction maps to the most recent non-assembly, non-blank
            line above it.
    """
    lines = filepath.read_text().splitlines()

    module_name = None
    asm_lines = []  # (line_idx_1based, rel_offset, abs_addr, hex_instr, rest)

    for i, line in enumerate(lines):
        m = MODULE_RE.match(line)
        if m:
            module_name = m.group(1)

        m = ASM_LINE_RE.match(line)
        if m:
            asm_lines.append((
                i + 1,                 # 1-based line number
                int(m.group(1)),       # rel_offset
                int(m.group(2), 16),   # abs_addr
                m.group(3),            # hex_instr
                m.group(4).strip(),    # rest
            ))

    if module_name is None or not asm_lines:
        return None

    # Build address -> asm_line index lookup
    addr_to_idx = {}
    for idx, (_, _, abs_addr, _, _) in enumerate(asm_lines):
        addr_to_idx[abs_addr] = idx

    # Find declared procedures
    procedures = []
    pending_proc_name = None
    comment_depth = 0

    for i, line in enumerate(lines):
        if not ASM_LINE_RE.match(line):
            for j in range(len(line) - 1):
                if line[j] == '(' and line[j+1] == '*':
                    comment_depth += 1
                elif line[j] == '*' and line[j+1] == ')':
                    comment_depth = max(0, comment_depth - 1)

        if comment_depth > 0:
            continue

        if MODULE_RE.match(line):
            continue

        m = PROCEDURE_RE.match(line)
        if m:
            pending_proc_name = m.group(1)
            continue

        if pending_proc_name is not None:
            am = ASM_LINE_RE.match(line)
            if am:
                addr = int(am.group(2), 16)
                procedures.append((pending_proc_name, addr))
                pending_proc_name = None

    # Find module init by backward scan
    init_addr = None
    last_pop_idx = None
    for j in range(len(asm_lines) - 1, -1, -1):
        if POP_PC_RE.search(asm_lines[j][4]):
            last_pop_idx = j
            break

    if last_pop_idx is not None:
        for j in range(last_pop_idx - 1, -1, -1):
            if PUSH_LR_RE.search(asm_lines[j][4]):
                init_addr = asm_lines[j][2]
                break

    proc_addrs = {addr for _, addr in procedures}
    if init_addr is not None and init_addr not in proc_addrs:
        procedures.append(('..init', init_addr))

    procedures.sort(key=lambda p: p[1])

    # Compute sizes
    last_asm = asm_lines[-1]
    file_end_addr = last_asm[2] + instr_size(last_asm[3])

    proc_symbols = []
    for i, (name, addr) in enumerate(procedures):
        full_name = f"{module_name}..init" if name == '..init' else f"{module_name}.{name}"
        size = (procedures[i + 1][1] if i + 1 < len(procedures) else file_end_addr) - addr
        proc_symbols.append(ProcSymbol(name=full_name, address=addr, size=size))

    # Extract frame info for each procedure
    frame_infos = []
    for proc in proc_symbols:
        idx = addr_to_idx.get(proc.address)
        if idx is None:
            continue

        # First instruction should be push
        _, _, _, hex_instr, rest = asm_lines[idx]
        saved_regs = parse_push_regs(rest)
        if saved_regs is None:
            continue

        push_sz = instr_size(hex_instr)

        # Check if next instruction is sub sp, #n
        sp_adj = 0
        sub_sz = 0
        if idx + 1 < len(asm_lines):
            _, _, _, next_hex, next_rest = asm_lines[idx + 1]
            sm = SUB_SP_RE.search(next_rest)
            if sm:
                sp_adj = int(sm.group(1))
                sub_sz = instr_size(next_hex)

        frame_infos.append(FrameInfo(
            address=proc.address,
            size=proc.size,
            push_size=push_sz,
            saved_regs=saved_regs,
            sp_adjust=sp_adj,
            sub_sp_size=sub_sz,
        ))

    # extract line entries (instruction lines only)
    line_entries = []
    if source_lines:
        # source-level mode: map each assembly address to the most recent
        # non-assembly, non-blank source line above it
        current_source_line = 1
        for i, line in enumerate(lines):
            if ASM_LINE_RE.match(line):
                m = ASM_LINE_RE.match(line)
                if m and not is_data_line(m.group(4).strip()):
                    abs_addr = int(m.group(2), 16)
                    line_entries.append(LineEntry(address=abs_addr, line=current_source_line))
            elif line.strip():
                current_source_line = i + 1  # 1-based
    else:
        # assembly-level mode (default): map each address to its own asm line
        for line_no, rel_off, abs_addr, hex_inst, rest in asm_lines:
            if not is_data_line(rest):
                line_entries.append(LineEntry(address=abs_addr, line=line_no))

    # Compute address range
    low_pc = asm_lines[0][2]
    high_pc = file_end_addr

    return ModuleDebug(
        name=module_name,
        filename=filepath.name,
        procedures=proc_symbols,
        line_entries=line_entries,
        frame_infos=frame_infos,
        low_pc=low_pc,
        high_pc=high_pc,
    )


# DWARF generation (version 4)
# DWARF constants
DW_TAG_compile_unit = 0x11
DW_TAG_subprogram = 0x2E
DW_CHILDREN_no = 0x00
DW_CHILDREN_yes = 0x01
DW_AT_name = 0x03
DW_AT_language = 0x13
DW_AT_comp_dir = 0x1B
DW_AT_low_pc = 0x11
DW_AT_high_pc = 0x12
DW_AT_stmt_list = 0x10
DW_AT_producer = 0x25
DW_AT_frame_base = 0x40
DW_FORM_string = 0x08
DW_FORM_addr = 0x01
DW_FORM_data2 = 0x05
DW_FORM_data4 = 0x06
DW_FORM_sec_offset = 0x17  # DWARF 4: for stmt_list
DW_FORM_exprloc = 0x18     # DWARF 4: for location expressions

# Language codes
DW_LANG_Mips_Assembler = 0x8001

# Location expression opcodes
DW_OP_reg13 = 0x5D  # SP register

# Line number standard opcodes (DWARF 4: opcodes 1..12)
DW_LNS_copy = 1
DW_LNS_advance_pc = 2
DW_LNS_advance_line = 3
DW_LNS_set_file = 4
DW_LNS_set_column = 5
DW_LNS_negate_stmt = 6
DW_LNS_set_basic_block = 7
DW_LNS_const_add_pc = 8
DW_LNS_fixed_advance_pc = 9
DW_LNS_set_prologue_end = 10
DW_LNS_set_epilogue_begin = 11
DW_LNS_set_isa = 12

# Line number extended opcodes
DW_LNE_end_sequence = 1
DW_LNE_set_address = 2

# CFA instruction opcodes
DW_CFA_advance_loc = 0x40     # high 2 bits = 01, low 6 = delta (max 63)
DW_CFA_offset = 0x80          # high 2 bits = 10, low 6 = register
DW_CFA_nop = 0x00
DW_CFA_def_cfa = 0x0C
DW_CFA_def_cfa_offset = 0x0E
DW_CFA_advance_loc1 = 0x02
DW_CFA_advance_loc2 = 0x03
DW_CFA_advance_loc4 = 0x04


def build_debug_abbrev():
    """Build .debug_abbrev section.

    Abbreviation 1: DW_TAG_compile_unit (has children)
      - DW_AT_name (string) -- includes subdir path, e.g. "rdb/LED.alst"
      - DW_AT_comp_dir (string) -- "."
      - DW_AT_low_pc (addr)
      - DW_AT_high_pc (data4) -- size from low_pc
      - DW_AT_stmt_list (sec_offset) -- offset into .debug_line
      - DW_AT_producer (string)
      - DW_AT_language (data2) -- source language

    Abbreviation 2: DW_TAG_subprogram (no children)
      - DW_AT_name (string) -- qualified procedure name (Module.Proc)
      - DW_AT_low_pc (addr)
      - DW_AT_high_pc (data4) -- size from low_pc
      - DW_AT_frame_base (exprloc) -- stack pointer
    """
    data = bytearray()

    # Abbreviation 1: compile_unit with children
    data += uleb128(1)                      # abbreviation code
    data += uleb128(DW_TAG_compile_unit)    # tag
    data.append(DW_CHILDREN_yes)            # has children

    data += uleb128(DW_AT_name)
    data += uleb128(DW_FORM_string)
    data += uleb128(DW_AT_comp_dir)
    data += uleb128(DW_FORM_string)
    data += uleb128(DW_AT_low_pc)
    data += uleb128(DW_FORM_addr)
    data += uleb128(DW_AT_high_pc)
    data += uleb128(DW_FORM_data4)          # size, not absolute address
    data += uleb128(DW_AT_stmt_list)
    data += uleb128(DW_FORM_sec_offset)     # DWARF 4: section offset
    data += uleb128(DW_AT_producer)
    data += uleb128(DW_FORM_string)
    data += uleb128(DW_AT_language)
    data += uleb128(DW_FORM_data2)

    data += uleb128(0)  # end of attributes
    data += uleb128(0)

    # Abbreviation 2: subprogram (no children)
    data += uleb128(2)                      # abbreviation code
    data += uleb128(DW_TAG_subprogram)      # tag
    data.append(DW_CHILDREN_no)             # no children

    data += uleb128(DW_AT_name)
    data += uleb128(DW_FORM_string)
    data += uleb128(DW_AT_low_pc)
    data += uleb128(DW_FORM_addr)
    data += uleb128(DW_AT_high_pc)
    data += uleb128(DW_FORM_data4)          # size from low_pc
    data += uleb128(DW_AT_frame_base)
    data += uleb128(DW_FORM_exprloc)        # DWARF 4: expression location

    data += uleb128(0)  # end of attributes
    data += uleb128(0)

    data += uleb128(0)  # end of abbreviations

    return bytes(data)


def build_debug_line_program(module, src_subdir):
    """Build one .debug_line unit for a module (DWARF version 4).

    Returns bytes for this unit's complete line number program
    (including the unit header).

    The file table uses directory index 1 (src_subdir), and
    DW_AT_comp_dir is set to "." for consistency.
    """
    if not module.line_entries:
        return b''

    # Build the header
    # Directory table: one entry for source subdirectory
    dir_table = bytearray()
    dir_table += src_subdir.encode('utf-8') + b'\x00'  # directory 1
    dir_table += b'\x00'  # end of directories

    # File table: single file using directory index 1 (src_subdir)
    file_table = bytearray()
    file_table += module.filename.encode('utf-8') + b'\x00'  # filename
    file_table += uleb128(1)   # directory index 1 = src_subdir
    file_table += uleb128(0)   # modification time (unknown)
    file_table += uleb128(0)   # file length (unknown)
    file_table += b'\x00'      # end of files

    # Header parameters (DWARF 4)
    min_inst_length = 2     # Thumb-2: minimum instruction is 2 bytes
    max_ops_per_inst = 1    # DWARF 4: one operation per instruction
    default_is_stmt = 1
    line_base = -5
    line_range = 14
    opcode_base = 13  # first special opcode (standard opcodes 1..12)

    # Standard opcode lengths (opcodes 1..12, DWARF 4)
    std_opcode_lengths = bytes([
        0,  # DW_LNS_copy
        1,  # DW_LNS_advance_pc
        1,  # DW_LNS_advance_line
        1,  # DW_LNS_set_file
        1,  # DW_LNS_set_column
        0,  # DW_LNS_negate_stmt
        0,  # DW_LNS_set_basic_block
        0,  # DW_LNS_const_add_pc
        1,  # DW_LNS_fixed_advance_pc
        0,  # DW_LNS_set_prologue_end
        0,  # DW_LNS_set_epilogue_begin
        1,  # DW_LNS_set_isa
    ])

    header_fields = bytearray()
    header_fields.append(min_inst_length)
    header_fields.append(max_ops_per_inst)  # DWARF 4: maximum_operations_per_instruction
    header_fields.append(default_is_stmt)
    header_fields.append(line_base & 0xFF)  # signed byte
    header_fields.append(line_range)
    header_fields.append(opcode_base)
    header_fields += std_opcode_lengths
    header_fields += dir_table
    header_fields += file_table

    header_length = len(header_fields)

    # Build the line number program
    program = bytearray()

    prev_addr = 0
    prev_line = 1

    for i, entry in enumerate(module.line_entries):
        if i == 0:
            # Set address with extended opcode
            addr_bytes = struct.pack('<I', entry.address)
            program.append(0)  # extended opcode marker
            program += uleb128(1 + len(addr_bytes))  # length
            program.append(DW_LNE_set_address)
            program += addr_bytes

            # Advance line
            if entry.line != prev_line:
                program.append(DW_LNS_advance_line)
                program += sleb128(entry.line - prev_line)

            program.append(DW_LNS_copy)
            prev_addr = entry.address
            prev_line = entry.line
        else:
            addr_delta = entry.address - prev_addr
            line_delta = entry.line - prev_line

            # Try special opcode (with min_inst_length = 2, addr advance is in units of 2)
            addr_advance = addr_delta // min_inst_length
            adjusted_opcode = (line_delta - line_base) + (line_range * addr_advance) + opcode_base
            if 0 <= (line_delta - line_base) < line_range and adjusted_opcode < 256 and adjusted_opcode >= opcode_base:
                program.append(adjusted_opcode)
            else:
                # Use explicit opcodes
                if addr_delta > 0:
                    program.append(DW_LNS_advance_pc)
                    program += uleb128(addr_advance)
                if line_delta != 0:
                    program.append(DW_LNS_advance_line)
                    program += sleb128(line_delta)
                program.append(DW_LNS_copy)

            prev_addr = entry.address
            prev_line = entry.line

    # End sequence
    program.append(0)  # extended opcode marker
    program += uleb128(1)
    program.append(DW_LNE_end_sequence)

    # Assemble the complete unit
    version = 4  # DWARF 4
    content = bytearray()
    content += struct.pack('<H', version)           # version
    content += struct.pack('<I', header_length)      # header_length (prologue_length)
    content += header_fields
    content += program

    unit = bytearray()
    unit += struct.pack('<I', len(content))  # unit_length
    unit += content

    return bytes(unit)


def build_debug_info_unit(module, abbrev_offset, stmt_list_offset, src_subdir):
    """Build one .debug_info compilation unit for a module (DWARF version 4).

    Uses comp_dir="." and DW_AT_name="subdir/file.alst" so that both the
    .debug_info CU name and the .debug_line file table resolve to the
    same path, eliminating duplicate file references.

    Includes DW_TAG_subprogram child DIEs for each procedure.
    """
    content = bytearray()
    content += struct.pack('<H', 4)              # version (DWARF 4)
    content += struct.pack('<I', abbrev_offset)  # debug_abbrev_offset
    content.append(4)                            # address_size

    # DIE: abbreviation 1 (DW_TAG_compile_unit, has children)
    content += uleb128(1)

    # DW_AT_name (string) — include subdir so path matches .debug_line
    cu_name = f'{src_subdir}/{module.filename}'
    content += cu_name.encode('utf-8') + b'\x00'

    # DW_AT_comp_dir (string) — current working directory
    content += b'.\x00'

    # DW_AT_low_pc (addr)
    content += struct.pack('<I', module.low_pc)

    # DW_AT_high_pc (data4) — size from low_pc
    content += struct.pack('<I', module.high_pc - module.low_pc)

    # DW_AT_stmt_list (sec_offset / data4) — offset into .debug_line
    content += struct.pack('<I', stmt_list_offset)

    # DW_AT_producer (string)
    content += b'makedebug (Oberon RTK)\x00'

    # DW_AT_language (data2) — assembler
    content += struct.pack('<H', DW_LANG_Mips_Assembler)

    # Child DIEs: DW_TAG_subprogram for each procedure
    for proc in module.procedures:
        content += uleb128(2)  # abbreviation 2 (DW_TAG_subprogram)

        # DW_AT_name (string) — qualified name (Module.Proc)
        content += proc.name.encode('utf-8') + b'\x00'

        # DW_AT_low_pc (addr)
        content += struct.pack('<I', proc.address)

        # DW_AT_high_pc (data4) — size from low_pc
        content += struct.pack('<I', proc.size)

        # DW_AT_frame_base (exprloc) — 1-byte expression: DW_OP_reg13 (SP)
        content += uleb128(1)           # expression length: 1 byte
        content.append(DW_OP_reg13)     # SP register

    # Null DIE — terminates children of compile_unit
    content.append(0x00)

    unit = bytearray()
    unit += struct.pack('<I', len(content))  # unit_length
    unit += content

    return bytes(unit)


def build_debug_aranges(modules, info_offsets):
    """Build .debug_aranges section.

    Maps address ranges to .debug_info compilation unit offsets.
    One entry set per module. DWARF version 2 format (used with DWARF 2-5).

    Args:
        modules: list of ModuleDebug with line_entries
        info_offsets: list of byte offsets into .debug_info for each module
    """
    address_size = 4
    segment_size = 0
    data = bytearray()

    for module, info_offset in zip(modules, info_offsets):
        # Build the content after unit_length
        content = bytearray()
        content += struct.pack('<H', 2)              # version (always 2 for aranges)
        content += struct.pack('<I', info_offset)    # debug_info_offset
        content.append(address_size)                 # address_size
        content.append(segment_size)                 # segment_size

        # Pad so that first tuple is aligned to 2 * address_size (8 bytes)
        # from the start of the unit (including the 4-byte unit_length field)
        total_header = 4 + len(content)  # 4 for unit_length + content so far
        tuple_align = 2 * address_size
        pad = (tuple_align - (total_header % tuple_align)) % tuple_align
        content += b'\x00' * pad

        # Address range tuple: (address, length)
        content += struct.pack('<I', module.low_pc)
        content += struct.pack('<I', module.high_pc - module.low_pc)

        # Terminator tuple: (0, 0)
        content += struct.pack('<I', 0)
        content += struct.pack('<I', 0)

        # Prepend unit_length
        data += struct.pack('<I', len(content))
        data += content

    return bytes(data)


def _cfa_advance_loc(delta):
    """Encode a CFA advance_loc instruction for the given byte delta."""
    data = bytearray()
    if delta <= 63:
        data.append(DW_CFA_advance_loc | delta)
    elif delta <= 255:
        data.append(DW_CFA_advance_loc1)
        data.append(delta)
    elif delta <= 65535:
        data.append(DW_CFA_advance_loc2)
        data += struct.pack('<H', delta)
    else:
        data.append(DW_CFA_advance_loc4)
        data += struct.pack('<I', delta)
    return bytes(data)


def build_debug_frame(all_frame_infos):
    """Build .debug_frame section with CIE and FDEs.

    Generates one CIE (shared by all FDEs) and one FDE per procedure.

    The CIE defines:
    - Code alignment factor: 1 (byte-granular addresses)
    - Data alignment factor: -4 (stack grows downward, 4-byte slots)
    - Return address register: 14 (LR)
    - Initial CFA rule: CFA = r13 + 0 (SP before any frame setup)

    Each FDE describes the prologue:
    - After push: CFA offset = num_saved_regs * 4, saved registers recorded
    - After sub sp (if present): CFA offset increased by sp_adjust

    Args:
        all_frame_infos: flat list of FrameInfo for all procedures
    """
    if not all_frame_infos:
        return b''

    address_size = 4
    data = bytearray()

    # --- CIE ---
    cie_offset = 0
    cie_content = bytearray()
    cie_content += struct.pack('<I', 0xFFFFFFFF)  # CIE_id (distinguishes CIE from FDE)
    cie_content.append(4)                         # version
    cie_content.append(0x00)                      # augmentation (empty string)
    cie_content.append(address_size)              # address_size
    cie_content.append(0)                         # segment_size
    cie_content += uleb128(1)                     # code_alignment_factor
    cie_content += sleb128(-4)                    # data_alignment_factor
    cie_content += uleb128(14)                    # return_address_register (LR)

    # Initial instructions: DW_CFA_def_cfa r13, 0
    cie_content.append(DW_CFA_def_cfa)
    cie_content += uleb128(13)                    # register: r13 (SP)
    cie_content += uleb128(0)                     # offset: 0

    # Pad to pointer size alignment
    while len(cie_content) % address_size != 0:
        cie_content.append(DW_CFA_nop)

    data += struct.pack('<I', len(cie_content))   # CIE length
    data += cie_content

    # FDEs
    for fi in all_frame_infos:
        fde_content = bytearray()
        fde_content += struct.pack('<I', cie_offset)       # CIE_pointer
        fde_content += struct.pack('<I', fi.address)       # initial_location
        fde_content += struct.pack('<I', fi.size)          # address_range

        num_regs = len(fi.saved_regs)
        cfa_offset_after_push = num_regs * 4

        # advance past push instruction
        fde_content += _cfa_advance_loc(fi.push_size)

        # CFA offset after push
        fde_content.append(DW_CFA_def_cfa_offset)
        fde_content += uleb128(cfa_offset_after_push)

        # record saved registers
        # registers are pushed lowest-numbered first at lowest address.
        # register at index k (0-based) in saved_regs is at:
        #   CFA - (num_regs - k) * 4
        # factored offset = (num_regs - k) because data_align = -4:
        #   CFA + factored_offset * (-4) = CFA - factored_offset * 4
        for k, reg in enumerate(fi.saved_regs):
            factored_offset = num_regs - k
            fde_content.append(DW_CFA_offset | reg)
            fde_content += uleb128(factored_offset)

        # if there's a sub sp, #n after the push
        if fi.sp_adjust > 0:
            fde_content += _cfa_advance_loc(fi.sub_sp_size)
            fde_content.append(DW_CFA_def_cfa_offset)
            fde_content += uleb128(cfa_offset_after_push + fi.sp_adjust)

        # pad to pointer size alignment
        while len(fde_content) % address_size != 0:
            fde_content.append(DW_CFA_nop)

        data += struct.pack('<I', len(fde_content))  # FDE length
        data += fde_content

    return bytes(data)


# ARM attributes — configurable via MCU config file

# Tag encoding: tag_name -> (tag_number, type)
ARM_ATTR_TAGS = {
    'Tag_CPU_name':         (5,  'string'),
    'Tag_CPU_arch':         (6,  'int'),
    'Tag_CPU_arch_profile': (7,  'int'),
    'Tag_THUMB_ISA_use':    (9,  'int'),
    'Tag_FP_arch':          (10, 'int'),
    'Tag_ABI_VFP_args':     (28, 'int'),
}


def parse_arm_attr_cfg(filepath):
    """Parse an ARM attributes config file.

    File format: Tag_name = value lines, # comments, blank lines.
    String values in double quotes, integers as decimal or 0x hex.

    Args:
        filepath: Path to the config file

    Returns:
        dict mapping tag names to values (str or int)
    """
    attrs = {}
    for line in filepath.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith('#'):
            continue
        # Parse Tag_name = value
        m = re.match(r'(\w+)\s*=\s*(.*)', line)
        if not m:
            continue
        tag_name = m.group(1)
        raw_value = m.group(2).strip()

        if tag_name not in ARM_ATTR_TAGS:
            print(f'warning: unknown tag {tag_name} in {filepath}')
            continue

        _, tag_type = ARM_ATTR_TAGS[tag_name]
        if tag_type == 'string':
            # Strip double quotes
            if raw_value.startswith('"') and raw_value.endswith('"'):
                attrs[tag_name] = raw_value[1:-1]
            else:
                attrs[tag_name] = raw_value
        else:
            # Integer: decimal or 0x hex
            if raw_value.startswith('0x') or raw_value.startswith('0X'):
                attrs[tag_name] = int(raw_value, 16)
            else:
                attrs[tag_name] = int(raw_value)

    return attrs


def build_arm_attributes(attrs):
    """Build .ARM.attributes section from a config dict.

    Encodes CPU architecture tags following the ARM ELF attributes ABI.
    Section type must be SHT_ARM_ATTRIBUTES (0x70000003) in the ELF.

    Args:
        attrs: dict from parse_arm_attr_cfg(), mapping tag names to values
    """
    # Build attribute tag-value pairs, in tag-number order
    attr_data = bytearray()
    for tag_name, (tag_num, tag_type) in sorted(ARM_ATTR_TAGS.items(), key=lambda x: x[1][0]):
        if tag_name not in attrs:
            continue
        value = attrs[tag_name]
        attr_data += uleb128(tag_num)
        if tag_type == 'string':
            attr_data += value.encode('utf-8') + b'\x00'
        else:
            attr_data += uleb128(value)

    if not attr_data:
        return b''

    # Build Tag_File sub-subsection: tag(1) + size(4) + attrs
    file_subsec = bytearray()
    file_subsec.append(0x01)  # Tag_File
    file_subsec += struct.pack('<I', 4 + len(attr_data) + 1)  # size includes itself
    file_subsec += attr_data

    # Build vendor subsection: size(4) + "aeabi\0" + file_subsec
    vendor = bytearray()
    vendor_name = b'aeabi\x00'
    vendor_content = vendor_name + file_subsec
    vendor += struct.pack('<I', 4 + len(vendor_content))  # size includes itself
    vendor += vendor_content

    # Complete section: version byte + vendor subsection
    data = bytearray()
    data.append(0x41)  # 'A' = format version
    data += vendor

    return bytes(data)


def generate_dwarf(modules, src_subdir):
    """Generate all DWARF sections from parsed module data.

    Path strategy:
    - DW_AT_comp_dir = "." (current working directory)
    - DW_AT_name = "subdir/file.alst" (relative path)
    - .debug_line directory 1 = "subdir", file at dir 1
    Both resolve to "subdir/file.alst" from ".", eliminating duplicates.

    Returns (debug_line, debug_info, debug_abbrev, debug_aranges) as bytes.
    """
    debug_abbrev = build_debug_abbrev()

    debug_line = bytearray()
    debug_info = bytearray()
    active_modules = []
    info_offsets = []

    for module in modules:
        if not module.line_entries:
            continue

        active_modules.append(module)
        stmt_list_offset = len(debug_line)
        info_offset = len(debug_info)
        info_offsets.append(info_offset)

        line_program = build_debug_line_program(module, src_subdir)
        debug_line += line_program

        info_unit = build_debug_info_unit(module, 0, stmt_list_offset, src_subdir)
        debug_info += info_unit

    debug_aranges = build_debug_aranges(active_modules, info_offsets)

    return bytes(debug_line), bytes(debug_info), debug_abbrev, debug_aranges


# Public API

def extract(src_dir, src_subdir='rdb', src_ext=None, source_lines=False,
            arm_attr_cfg=None):
    """Extract all debug data from listing files in a directory.

    Args:
        src_dir: Path to directory containing listing files
        src_subdir: Name of the source subdirectory relative to ELF file.
                    Used in .debug_line directory table and DW_AT_name path.
        src_ext: Source file extension including dot (default: SOURCE_EXT)
        source_lines: If True, map addresses to Oberon source lines instead
                      of assembly lines
        arm_attr_cfg: Path to arm-attr.cfg file, or None for no ARM attributes

    Returns:
        DebugData with procedures, line mappings, and DWARF sections
    """
    if src_ext is None:
        src_ext = SOURCE_EXT

    src_dir = Path(src_dir)
    src_files = sorted(src_dir.glob(f'*{src_ext}'))

    if not src_files:
        return DebugData(modules=[], procedures=[])

    modules = []
    all_procedures = []
    all_frame_infos = []

    for fpath in src_files:
        mod = parse_listing(fpath, source_lines=source_lines)
        if mod is not None:
            modules.append(mod)
            all_procedures.extend(mod.procedures)
            all_frame_infos.extend(mod.frame_infos)

    all_procedures.sort(key=lambda s: s.address)
    all_frame_infos.sort(key=lambda f: f.address)

    # Generate DWARF sections
    debug_line, debug_info, debug_abbrev, debug_aranges = generate_dwarf(
        modules, src_subdir
    )

    # Build .debug_frame
    debug_frame = build_debug_frame(all_frame_infos)

    # Build ARM attributes (only if config file provided)
    arm_attributes = b''
    if arm_attr_cfg is not None:
        attrs = parse_arm_attr_cfg(Path(arm_attr_cfg))
        if attrs:
            arm_attributes = build_arm_attributes(attrs)

    return DebugData(
        modules=modules,
        procedures=all_procedures,
        debug_line=debug_line,
        debug_info=debug_info,
        debug_abbrev=debug_abbrev,
        debug_aranges=debug_aranges,
        debug_frame=debug_frame,
        arm_attributes=arm_attributes,
    )


# JSON output (for standalone use)

def write_symbols_json(procedures, output_path):
    """Write procedure symbols to JSON file."""
    data = {
        'procedures': [
            {
                'name': p.name,
                'address': f"0x{p.address:08X}",
                'size': p.size,
            }
            for p in procedures
        ]
    }
    output_path.write_text(json.dumps(data, indent=2))


# Command-line interface

def main():
    parser = argparse.ArgumentParser(
        description='Extract debug data from Astrobe listing files.'
    )
    parser.add_argument(
        'src_dir',
        help='Directory containing listing files'
    )
    parser.add_argument(
        '-o', '--output-dir',
        help='Output directory for generated files (default: src_subdir)',
        default=None,
    )
    parser.add_argument(
        '-s', '--src-subdir',
        help='Name of source subdirectory relative to ELF file (default: rdb)',
        default='rdb',
    )
    parser.add_argument(
        '-e', '--ext',
        help=f'Source file extension (default: {SOURCE_EXT})',
        default=SOURCE_EXT,
    )
    parser.add_argument(
        '-l', '--source-lines',
        action='store_true',
        dest='source_lines',
        help='Map addresses to Oberon source lines instead of assembly lines',
    )

    args = parser.parse_args()

    src_dir = Path(args.src_dir)
    output_dir = Path(args.output_dir) if args.output_dir else src_dir

    if not src_dir.is_dir():
        print(f"Error: '{src_dir}' is not a directory")
        sys.exit(1)

    output_dir.mkdir(parents=True, exist_ok=True)

    data = extract(src_dir, args.src_subdir, args.ext, args.source_lines)

    if not data.procedures:
        print("No symbols found.")
        sys.exit(1)

    # Write symbols JSON
    symbols_path = output_dir / 'symbols.json'
    write_symbols_json(data.procedures, symbols_path)

    # Write DWARF binary sections
    for name, section_data in [
        ('debug_line.bin', data.debug_line),
        ('debug_info.bin', data.debug_info),
        ('debug_abbrev.bin', data.debug_abbrev),
        ('debug_aranges.bin', data.debug_aranges),
        ('debug_frame.bin', data.debug_frame),
    ]:
        path = output_dir / name
        path.write_bytes(section_data)

    # Summary
    total_lines = sum(len(m.line_entries) for m in data.modules)
    total_frames = sum(len(m.frame_infos) for m in data.modules)
    print(f"Extracted {len(data.procedures)} symbols from {len(data.modules)} modules")
    print(f"Line entries: {total_lines}")
    print(f"Frame entries: {total_frames}")
    if args.source_lines:
        print(f"Line mapping: source-level (Oberon source lines)")
    else:
        print(f"Line mapping: assembly-level (assembly line numbers)")
    print(f"Output:")
    print(f"  {symbols_path} ({symbols_path.stat().st_size} bytes)")
    print(f"  {output_dir / 'debug_line.bin'} ({len(data.debug_line)} bytes)")
    print(f"  {output_dir / 'debug_info.bin'} ({len(data.debug_info)} bytes)")
    print(f"  {output_dir / 'debug_abbrev.bin'} ({len(data.debug_abbrev)} bytes)")
    print(f"  {output_dir / 'debug_aranges.bin'} ({len(data.debug_aranges)} bytes)")
    print(f"  {output_dir / 'debug_frame.bin'} ({len(data.debug_frame)} bytes)")


if __name__ == '__main__':
    main()
