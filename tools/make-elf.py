#!/usr/bin/env python3
"""
make-elf -- Build ELF files with DWARF debug data from Oberon binaries.
--
Creates ELF executables from compiled Oberon binaries (.bin) with
embedded DWARF debug sections generated from listing files (.alst)
in the rdb directory. Supports:
  - Full DWARF 4 debug info (types, variables, line mapping, frames)
  - RP2350 IMAGE_DEF picobin metadata block (--image-def)
  - Auto-detection of code base and BSS range from .map file
  - ARM ELF attributes (.ARM.attributes section)
--
Usage:
    python make-elf.py [binary:address ...] [options]

    --debug             Include DWARF debug sections (implies --symbols)
    --symbols           Include procedure/variable symbols (requires rdb/)
    --sym-prefix P      Prefix all symbols with P_ (e.g. S for Secure)
    --image-def         Prepend RP2350 IMAGE_DEF block
    --rdb-dir DIR       Listing directory (default: rdb)
    --bss START:END     BSS memory range (auto-detected from .map if omitted)
    --map FILE          Map file (default: auto-detect)
    --entry ADDR        Override entry address (hex)
    --no-main           Suppress main/startup symbols
    -o FILE             Output file (default: <binary>.elf)
    -e EXT              Source file extension (default: .alst)
    --nxp               NXP-specific modifications
    -l, --source-lines  Map to Oberon source lines (experimental)

Example:
    python make-elf.py SignalSync.bin
    python make-elf.py SignalSync.bin --debug
    python make-elf.py SignalSync.bin:10000100 --debug --image-def
    python make-elf.py S.bin:C000000 NSC.bin:C0FE000 --debug --sym-prefix S
--
Copyright (c) 2024-2026 Gray, gray@grayraven.org
https://oberon-rtk.org/licences/
"""

import struct, sys, json

PROG_NAME = 'make-elf'

# import elfdata module
sys.path.insert(0, str(__import__('pathlib').Path(__file__).resolve().parent / 'pylib'))
import elfdata

# ARM attributes config file name (looked up in listing directory)
ARM_ATTR_CFG = 'arm-attr.cfg'

# --- ELF constants ---

# e_ident
ELFCLASS32      = 1         # 32-bit objects
ELFDATA2LSB     = 1         # little-endian
EV_CURRENT      = 1         # current ELF version
ELFOSABI_NONE   = 0x00      # no OS/ABI extensions

# e_type
ET_EXEC         = 0x02      # executable file

# e_machine
EM_ARM          = 0x28      # ARM

# e_flags (ARM-specific)
EF_ARM_ABI_VER5     = 0x05000000   # ARM ABI version 5
EF_ARM_ABI_FLOAT_HARD = 0x00000400 # hard-float ABI

# section header types (sh_type)
SHT_PROGBITS        = 1
SHT_SYMTAB          = 2
SHT_STRTAB          = 3
SHT_NOBITS          = 8         # no file data (e.g. .bss)
SHT_ARM_ATTRIBUTES  = 0x70000003

# section header flags (sh_flags)
SHF_WRITE       = 0x01      # section is writable
SHF_ALLOC       = 0x02      # section occupies memory during execution
SHF_EXECINSTR   = 0x04      # section contains executable instructions

# program header types (p_type)
PT_LOAD         = 1         # loadable segment

# program header flags (p_flags)
PF_X            = 0x01      # executable
PF_W            = 0x02      # writable
PF_R            = 0x04      # readable

# symbol binding (upper 4 bits of st_info)
STB_LOCAL       = 0
STB_GLOBAL      = 1

# symbol type (lower 4 bits of st_info)
STT_NOTYPE      = 0         # type not specified (used for mapping symbols)
STT_OBJECT      = 1         # data object (variable)
STT_FUNC        = 2         # function or procedure

# special section index: symbol value is an absolute address
SHN_ABS         = 0xFFF1


# --- RP2350 IMAGE_DEF (picobin metadata block) ---
# Encapsulates all RP2350-specific boot metadata.  The rest of the ELF
# generation code treats an ImageDef instance as an opaque section provider:
# it asks for the load address, section data, section name, and description.

class ImageDef:
    """RP2350 IMAGE_DEF picobin metadata block.

    The RP2350 boot ROM scans the first 256 bytes of flash for a picobin
    metadata block to determine how to boot the program.  This class builds
    the 256-byte block containing the IMAGE_DEF item (Secure, ARM, RP2350,
    executable) and a vector-table pointer so the boot ROM can locate the
    program's vector table.
    """

    BLOCK_SIZE    = 0x100       # 256 bytes
    BLOCK_BEGIN   = 0xFFFFDED3
    BLOCK_END     = 0xAB123579
    IMAGE_DEF_S   = 0x10210142  # Secure, ARM, RP2350, executable
    VECT_TABLE    = 0x00000203  # vector table item header
    LAST_ITEM     = 0x000003FF
    LINK_SELF     = 0x00000000

    SECTION_NAME  = '.image_def'

    def __init__(self, code_base):
        """Create an IMAGE_DEF block placed immediately before code_base.
        code_base: load address of the first binary (vector table address).
        """
        self._code_base = code_base
        self._addr = code_base - self.BLOCK_SIZE
        self._data = self._build(code_base)

    def _build(self, vtab_addr):
        """Build the 256-byte picobin metadata block."""
        block = struct.pack('<7I',
            self.BLOCK_BEGIN,
            self.IMAGE_DEF_S,
            self.VECT_TABLE,
            vtab_addr,
            self.LAST_ITEM,
            self.LINK_SELF,
            self.BLOCK_END,
        )
        return block + b'\x00' * (self.BLOCK_SIZE - len(block))

    @property
    def addr(self):
        """Load address of the IMAGE_DEF block in flash."""
        return self._addr

    @property
    def data(self):
        """The 256-byte IMAGE_DEF block."""
        return self._data

    @property
    def size(self):
        return self.BLOCK_SIZE

    @property
    def section_name(self):
        return self.SECTION_NAME

    def verbose_line(self):
        """Single-line description for -v output."""
        return f'IMAGE_DEF: 0x{self._addr:08X} ({self.BLOCK_SIZE} bytes, vtab 0x{self._code_base:08X})'


def _symtab_name(oberon_name, prefix=''):
    """Convert an Oberon qualified name to a valid C identifier for .symtab.
    Dots are replaced by underscores so that Ozone's Elf.GetExprValue()
    can look up the symbol without the dot being parsed as a struct member
    access operator.  When prefix is set (e.g. 'S'), the prefix is prepended
    with an underscore separator.
    Examples (no prefix):
        'SignalSync.run'   -> 'SignalSync_run'
        'SignalSync..init' -> 'SignalSync__init'
        'main'             -> 'main'  (unchanged)
    Examples (prefix='S'):
        'SignalSync.run'   -> 'S_SignalSync_run'
        'main'             -> 'S_main'
    """
    name = oberon_name.replace('.', '_')
    if prefix:
        name = f'{prefix}_{name}'
    return name


class Elf:
    def __init__(self):
        self._buf = bytearray()
        self._fh = FileHeader()
        self._sh_tab = SectionHeaderTable()
        self._ph_tab = ProgramHeaderTable()
        self._sections = dict()

        # create section header string table section (sic) .shstrtab
        self._shstr_tab = StringTable()
        self.add_section(self._shstr_tab, '.shstrtab')
        self._shstr_tab.add_string('.shstrtab')

        # register section .shstrtab in section header table
        shstr_tab_hd = SectionHeader()
        shstr_tab_hd.set_data_field('sh_name', self._shstr_tab.index_of('.shstrtab'))
        shstr_tab_hd.set_data_field('sh_type', SHT_STRTAB)
        self._shstr_tab.set_section_header(shstr_tab_hd)
        self._shstr_tab_hd = shstr_tab_hd

    def add_section(self, section, section_name):
        self._sections[section_name] = section

    def make(self, bin_files, entry_addr, debug_data, include_debug=False,
             create_main=True, bss_range=None, image_def=None, symbol_prefix=''):
        # define file header
        self._fh.set_data_field('e_ident_magic', self._fh.magic)
        self._fh.set_data_field('e_ident_class', ELFCLASS32)
        self._fh.set_data_field('e_ident_data', ELFDATA2LSB)
        self._fh.set_data_field('e_ident_version', EV_CURRENT)
        self._fh.set_data_field('e_ident_osabi', ELFOSABI_NONE)
        self._fh.set_data_field('e_type', ET_EXEC)
        self._fh.set_data_field('e_machine', EM_ARM)
        self._fh.set_data_field('e_version', EV_CURRENT)
        self._fh.set_data_field('e_entry', entry_addr)
        self._fh.set_data_field('e_flags', EF_ARM_ABI_VER5)  # no hard-float: Oberon RTK uses soft-float ABI
        self._fh.set_data_field('e_ehsize', FileHeader.entry_size)
        # e_phentsize: set whenever there will be any program headers
        has_ph = bool(bin_files) or (bss_range is not None) or (image_def is not None)
        if has_ph:
            self._fh.set_data_field('e_phentsize', ProgramHeader.entry_size)
        self._fh.set_data_field('e_shentsize', SectionHeader.entry_size)

        # write file header
        self._fh.append_to_buf(self._buf)

        # st_shndx for symbols: .text section index (1) with binary, SHN_ABS without
        # When image_def is present, .image_def is section 1 and .text is section 2.
        if bin_files:
            sym_shndx = 2 if image_def is not None else 1
        else:
            sym_shndx = SHN_ABS

        text_sections = list()

        # --- IMAGE_DEF section (RP2350 picobin metadata, before .text) ---
        if image_def is not None:
            idef_sec = Section()
            idef_sec.put_data(image_def.data)
            text_sections.append(idef_sec)
            self.add_section(idef_sec, image_def.section_name)
            self._shstr_tab.add_string(image_def.section_name)

            idef_sh = SectionHeader()
            idef_sh.set_data_field('sh_name', self._shstr_tab.index_of(image_def.section_name))
            idef_sh.set_data_field('sh_type', SHT_PROGBITS)
            idef_sh.set_data_field('sh_flags', SHF_ALLOC)
            idef_sh.set_data_field('sh_addr', image_def.addr)
            idef_sh.set_data_field('sh_size', image_def.size)
            idef_sh.set_data_field('sh_addralign', 4)

            self._sh_tab.add_entry(idef_sh, image_def.section_name)
            idef_sec.set_section_header(idef_sh)

            idef_ph = ProgramHeader()
            idef_ph.set_data_field('p_type', PT_LOAD)
            idef_ph.set_data_field('p_vaddr', image_def.addr)
            idef_ph.set_data_field('p_paddr', image_def.addr)
            idef_ph.set_data_field('p_filesz', image_def.size)
            idef_ph.set_data_field('p_memsz', image_def.size)
            idef_ph.set_data_field('p_flags', PF_R)
            idef_ph.set_data_field('p_align', 0x1000)

            self._ph_tab.add_entry(idef_ph, image_def.section_name)
            idef_sec.set_program_header(idef_ph)

        for i, file in enumerate(bin_files):
            # create code section for 'file' image
            text = Section()
            text_sections.append(text)
            text.put_data(file.data)
            if i > 0:
                section_name = f'.{file.name}'
            else:
                section_name = '.text'
            self.add_section(text, section_name)
            self._shstr_tab.add_string(section_name)

            # create entry for 'file' image in section header table
            text_sh = SectionHeader()
            text_sh.set_data_field('sh_name', self._shstr_tab.index_of(section_name))
            text_sh.set_data_field('sh_type', SHT_PROGBITS)
            text_sh.set_data_field('sh_flags', SHF_EXECINSTR | SHF_ALLOC)
            text_sh.set_data_field('sh_addr', file.load_addr)
            text_sh.set_data_field('sh_size', text.size())
            text_sh.set_data_field('sh_addralign', 4)

            self._sh_tab.add_entry(text_sh, section_name)
            text.set_section_header(text_sh)

            # create entry for 'file' image in program header table
            text_ph = ProgramHeader()
            text_ph.set_data_field('p_type', PT_LOAD)
            text_ph.set_data_field('p_vaddr', file.load_addr)
            text_ph.set_data_field('p_paddr', file.load_addr)
            text_ph.set_data_field('p_filesz', text.size())
            text_ph.set_data_field('p_memsz', text.size())
            text_ph.set_data_field('p_flags', PF_R | PF_X)
            text_ph.set_data_field('p_align', 0x1000)

            self._ph_tab.add_entry(text_ph, section_name)
            text.set_program_header(text_ph)

        # --- .bss section: declares a RAM region so Ozone can read variable values ---
        # SHT_NOBITS contributes no bytes to the ELF file; it only declares the
        # memory region in the section header table and program header table.
        # Without this, Ozone shows blank values even when addresses are correct.
        if bss_range is not None:
            bss_start, bss_size = bss_range
            self._shstr_tab.add_string('.bss')
            self._sections['.bss'] = None  # NOBITS: no section data object

            bss_sh = SectionHeader()
            bss_sh.set_data_field('sh_name', self._shstr_tab.index_of('.bss'))
            bss_sh.set_data_field('sh_type', SHT_NOBITS)
            bss_sh.set_data_field('sh_flags', SHF_ALLOC | SHF_WRITE)
            bss_sh.set_data_field('sh_addr', bss_start)
            bss_sh.set_data_field('sh_size', bss_size)
            bss_sh.set_data_field('sh_addralign', 4)
            # sh_offset stays 0: NOBITS means no file bytes; value is "conceptual"
            self._sh_tab.add_entry(bss_sh, '.bss')

            bss_ph = ProgramHeader()
            bss_ph.set_data_field('p_type', PT_LOAD)
            bss_ph.set_data_field('p_vaddr', bss_start)
            bss_ph.set_data_field('p_paddr', bss_start)
            bss_ph.set_data_field('p_filesz', 0)       # no file content
            bss_ph.set_data_field('p_memsz', bss_size) # RAM bytes mapped by OS/debugger
            bss_ph.set_data_field('p_flags', PF_R | PF_W)
            bss_ph.set_data_field('p_align', 0x1000)
            # p_offset stays 0: no file bytes
            self._ph_tab.add_entry(bss_ph, '.bss')

        # --- debug and metadata sections (non-loadable, before string/symbol tables) ---
        debug_sections = list()
        if debug_data is not None:
            for section_name, section_bytes, section_type in [
                ('.debug_line',      debug_data.debug_line,      SHT_PROGBITS),
                ('.debug_info',      debug_data.debug_info,      SHT_PROGBITS),
                ('.debug_abbrev',    debug_data.debug_abbrev,    SHT_PROGBITS),
                ('.debug_aranges',   debug_data.debug_aranges,   SHT_PROGBITS),
                ('.debug_pubnames',  debug_data.debug_pubnames,  SHT_PROGBITS),
                ('.debug_str',       debug_data.debug_str,       SHT_PROGBITS),
                ('.debug_frame',     debug_data.debug_frame,     SHT_PROGBITS),
                ('.ARM.attributes',  debug_data.arm_attributes,  SHT_ARM_ATTRIBUTES),
            ]:
                if not section_bytes:
                    continue

                # skip .debug_* sections unless --debug is set
                if not include_debug and section_name.startswith('.debug_'):
                    continue

                dbg = Section()
                dbg.put_data(section_bytes)
                debug_sections.append(dbg)
                self.add_section(dbg, section_name)
                self._shstr_tab.add_string(section_name)

                dbg_sh = SectionHeader()
                dbg_sh.set_data_field('sh_name', self._shstr_tab.index_of(section_name))
                dbg_sh.set_data_field('sh_type', section_type)
                dbg_sh.set_data_field('sh_flags', 0)
                dbg_sh.set_data_field('sh_addr', 0)
                dbg_sh.set_data_field('sh_size', dbg.size())
                dbg_sh.set_data_field('sh_addralign', 1)
                dbg_sh.set_data_field('sh_entsize', 0)

                self._sh_tab.add_entry(dbg_sh, section_name)
                dbg.set_section_header(dbg_sh)

        # create string table .strtab
        self._str_tab = StringTable()
        self.add_section(self._str_tab, '.strtab')
        self._shstr_tab.add_string('.strtab')

        # create entry for .strtab in section header table
        str_tab_hd = SectionHeader()
        str_tab_hd.set_data_field('sh_name', self._shstr_tab.index_of('.strtab'))
        str_tab_hd.set_data_field('sh_type', SHT_STRTAB)
        self._str_tab.set_section_header(str_tab_hd)
        self._sh_tab.add_entry(str_tab_hd, '.strtab')

        # create symbol table .symtab
        symtab = SymbolTable()
        self.add_section(symtab, '.symtab')
        self._shstr_tab.add_string('.symtab')
        self._sym_tab = symtab

        # create entry for .symtab in section header table
        symtab_hd = SectionHeader()
        symtab_hd.set_data_field('sh_name', self._shstr_tab.index_of('.symtab'))
        symtab_hd.set_data_field('sh_type', SHT_SYMTAB)
        symtab_hd.set_data_field('sh_link', self._sh_tab.index_of('.strtab'))
        symtab_hd.set_data_field('sh_entsize', SymbolTableEntry.entry_size)
        self._sh_tab.add_entry(symtab_hd, '.symtab')
        symtab.set_section_header(symtab_hd)

        # --- LOCAL symbols: ARM $t mapping symbols ---
        # A $t symbol at the physical entry address of each Thumb procedure tells
        # disassemblers "Thumb-2 code starts here".  LOCAL symbols must come before
        # globals in .symtab; SymbolTable.add_local_entry() tracks the count for sh_info.
        if debug_data is not None:
            self._str_tab.add_string('$t')
            for proc in debug_data.procedures:
                t_sym = SymbolTableEntry()
                t_sym.set_data_field('st_name',  self._str_tab.index_of('$t'))
                t_sym.set_data_field('st_value', proc.address)   # even (physical address)
                t_sym.set_data_field('st_size',  0)
                t_sym.set_data_field('st_info',  (STB_LOCAL << 4) | STT_NOTYPE)  # = 0
                t_sym.set_data_field('st_other', 0)
                t_sym.set_data_field('st_shndx', sym_shndx)
                self._sym_tab.add_local_entry(t_sym, f'$t_{proc.address:08x}')

        # --- GLOBAL symbols ---

        # add 'main' and 'startup' symbols at entry point
        # Bit 0 of st_value is set for Thumb functions (ARM IHI0044 ABI convention).
        # 'startup' is an alias for 'main' at the same address; it anticipates
        # future relocation of 'main' to the user program entry point.
        if create_main and entry_addr != 0:
            for base_name in ('main', 'startup'):
                sym_name = _symtab_name(base_name, symbol_prefix)
                sym = SymbolTableEntry()
                self._str_tab.add_string(sym_name)
                sym.set_data_field('st_name', self._str_tab.index_of(sym_name))
                sym.set_data_field('st_value', entry_addr | 1)   # Thumb bit
                sym.set_data_field('st_size', 0)
                sym.set_data_field('st_info', (STB_GLOBAL << 4) | STT_FUNC)
                sym.set_data_field('st_other', 0)
                sym.set_data_field('st_shndx', sym_shndx)
                self._sym_tab.add_entry(sym, sym_name)

        # add procedure symbols from debug data
        # Dots in Oberon qualified names are replaced by underscores in .symtab
        # so that Ozone's Elf.GetExprValue() can look them up without the dot
        # being misinterpreted as the C struct member-access operator.
        # The DWARF DW_AT_name (generated by elfdata) retains the original dotted name.
        # Bit 0 of st_value is set for Thumb functions (ARM IHI0044 ABI convention).
        if debug_data is not None:
            for proc in debug_data.procedures:
                sym = SymbolTableEntry()
                sym_name = _symtab_name(proc.name, symbol_prefix)  # e.g. 'SignalSync_run'
                self._str_tab.add_string(sym_name)
                sym.set_data_field('st_name', self._str_tab.index_of(sym_name))
                sym.set_data_field('st_value', proc.address | 1)  # Thumb bit
                sym.set_data_field('st_size', proc.size)
                sym.set_data_field('st_info', (STB_GLOBAL << 4) | STT_FUNC)
                sym.set_data_field('st_other', 0)
                sym.set_data_field('st_shndx', sym_shndx)
                self._sym_tab.add_entry(sym, sym_name)

        # add global variable symbols as STT_OBJECT entries
        # Use .bss section index (not SHN_ABS) so Ozone knows these are memory-mapped
        # objects, not absolute constants.  SHN_ABS would tell Ozone the st_value IS
        # the constant; a real section index tells it to read from target memory at
        # that address.  GCC/SEGGER ELFs always point variable symbols at their BSS
        # section.  If no .bss section exists, fall back to SHN_ABS.
        if debug_data is not None:
            var_shndx = self._sh_tab.index_of('.bss') if '.bss' in self._sections else SHN_ABS
            for gsym in debug_data.global_symbols:
                sym = SymbolTableEntry()
                # Module-qualify the .symtab name (e.g. 'BasicTypes_i') to match the
                # convention used for procedure symbols ('BasicTypes_p0').  This avoids
                # .symtab name collisions when multiple modules declare the same variable
                # name, and is consistent with how ESD/SEGGER debuggers expect symbols.
                pfx = f'{symbol_prefix}_' if symbol_prefix else ''
                qual_name = f'{pfx}{gsym.module_name}_{gsym.name}'
                self._str_tab.add_string(qual_name)
                sym.set_data_field('st_name',  self._str_tab.index_of(qual_name))
                sym.set_data_field('st_value', gsym.address)
                sym.set_data_field('st_size',  gsym.byte_size)
                sym.set_data_field('st_info',  (STB_GLOBAL << 4) | STT_OBJECT)
                sym.set_data_field('st_other', 0)
                sym.set_data_field('st_shndx', var_shndx)  # .bss section, not SHN_ABS
                self._sym_tab.add_entry(sym, qual_name)  # unique across all modules

        # write program header table (when there are any loadable segments)
        if has_ph:
            self._ph_tab.append_to_buf(self._buf, len(self._buf))

        # add .shstrtab to section header table
        self._sh_tab.add_entry(self._shstr_tab_hd, '.shstrtab')

        # --- write all section data ---

        # write code sections (includes .image_def if present, then .text)
        for text in text_sections:
            text.append_to_buf(self._buf, len(self._buf))

        # .bss: SHT_NOBITS — no bytes written to file

        # write debug sections
        for dbg in debug_sections:
            dbg.append_to_buf(self._buf, len(self._buf))

        # write section header string table section
        self._shstr_tab.append_to_buf(self._buf, len(self._buf))

        # write string table section
        self._str_tab.append_to_buf(self._buf, len(self._buf))

        # write symbol table section
        symtab.append_to_buf(self._buf, len(self._buf))

        # --- write section header table LAST (standard ELF layout) ---
        self._sh_tab.append_to_buf(self._buf, len(self._buf))

        # --- fix-up all section headers with correct file offsets ---

        # fix-up code sections (includes .image_def and .text)
        for text in text_sections:
            text.section_header().set_buf_field("sh_offset", text.offset())
            text.program_header().set_buf_field("p_offset", text.offset())

        # fix-up debug sections
        for dbg in debug_sections:
            dbg.section_header().set_buf_field('sh_offset', dbg.offset())

        # fix-up .shstrtab
        self._shstr_tab.section_header().set_buf_field('sh_offset', self._shstr_tab.offset())
        self._shstr_tab.section_header().set_buf_field('sh_size', self._shstr_tab.size())

        # fix-up .strtab
        self._str_tab.section_header().set_buf_field('sh_offset', self._str_tab.offset())
        self._str_tab.section_header().set_buf_field('sh_size', self._str_tab.size())

        # fix-up .symtab
        symtab.section_header().set_buf_field('sh_offset', symtab.offset())
        symtab.section_header().set_buf_field('sh_size', symtab.size())
        symtab.section_header().set_buf_field('sh_info', symtab.index_of_first_global())

        # .bss: sh_offset stays 0 (NOBITS — no file content); p_offset stays 0

        # fix-up file header entries
        self._fh.set_buf_field('e_shnum', self._sh_tab.num_entries())
        self._fh.set_buf_field('e_phnum', self._ph_tab.num_entries())
        self._fh.set_buf_field('e_shoff', self._sh_tab.offset())
        # e_phoff: only set when there is a program header table
        if has_ph:
            self._fh.set_buf_field('e_phoff', self._ph_tab.offset())
        self._fh.set_buf_field('e_shstrndx', self._sh_tab.index_of('.shstrtab'))

    @property
    def data(self):
        return self._buf


class TableEntry:
    fields = {}
    entry_size: int

    def __init__(self):
        self._offset: int
        self._data = dict()
        for k in self.fields:
            self._data[k] = 0

    def set_data_field(self, name, val):
        assert(name in self._data)
        self._data[name] = val

    def set_buf_field(self, name, val):
        size, offset = self.fields[name]
        offset = offset + self._offset
        fmt = {1: '<B', 2: '<H', 4: '<I', 8: '<Q'}[size]
        self._buf[offset:offset+size] = struct.pack(fmt, val)

    def append_to_buf(self, buf, offset):
        self._buf = buf
        self._offset = offset
        for _, val in self.fields.items():
            size, _ = val
            buf.extend(b'\0' * size)
        for name, val in self._data.items():
            self.set_buf_field(name, val)


class Table:
    def __init__(self):
        self._offset: int
        self._entries = list()
        self._entry_names = dict()

    def add_entry(self, entry, entry_name):
        ix = len(self._entries)
        self._entries.append(entry)
        self._entry_names[entry_name] = ix

    def get_entry(self, id) -> TableEntry:
        if type(id) == str:
            id = self._entry_names[id]
        return self._entries[id]

    def index_of(self, entry_name) -> int:
        return self._entry_names[entry_name]

    def num_entries(self) -> int:
        return len(self._entries)

    def offset(self) -> int:
        return self._offset

    def size(self) -> int:
        return self._size

    def append_to_buf(self, buf, offset):
        self._offset = offset
        for en in self._entries:
            en.append_to_buf(buf, offset)
            offset = len(buf)
        self._size = len(buf) - self._offset


class FileHeader(TableEntry):
    magic = 0x464C457F  # ELF magic: 7F 45 4C 46
    fields = {
        'e_ident_magic':      (4, 0x00),
        'e_ident_class':      (1, 0x04),
        'e_ident_data':       (1, 0x05),
        'e_ident_version':    (1, 0x06),
        'e_ident_osabi':      (1, 0x07),
        'e_ident_abiversion': (1, 0x08),
        'e_pad':              (7, 0x09),
        'e_type':             (2, 0x10),
        'e_machine':          (2, 0x12),
        'e_version':          (4, 0x14),
        'e_entry':            (4, 0x18),
        'e_phoff':            (4, 0x1C),
        'e_shoff':            (4, 0x20),
        'e_flags':            (4, 0x24),
        'e_ehsize':           (2, 0x28),
        'e_phentsize':        (2, 0x2A),
        'e_phnum':            (2, 0x2C),
        'e_shentsize':        (2, 0x2E),
        'e_shnum':            (2, 0x30),
        'e_shstrndx':         (2, 0x32)
    }

    entry_size = 0x34

    def append_to_buf(self, buf):
        self._buf = buf
        self._offset = 0 # always at beginning of buffer/file
        for _, val in self.fields.items():
            size, _ = val
            buf.extend(b'\0' * size)
        for name, val in self._data.items():
            if name != 'e_pad':
                self.set_buf_field(name, val)


class SectionHeader(TableEntry):
    fields = {
        'sh_name':      (4, 0x00),
        'sh_type':      (4, 0x04),
        'sh_flags':     (4, 0x08),
        'sh_addr':      (4, 0x0C),
        'sh_offset':    (4, 0x10),
        'sh_size':      (4, 0x14),
        'sh_link':      (4, 0x18),
        'sh_info':      (4, 0x1C),
        'sh_addralign': (4, 0x20),
        'sh_entsize':   (4, 0x24)
    }

    entry_size = 0x28

class ProgramHeader(TableEntry):
    fields = {
        'p_type':   (4, 0x00),
        'p_offset': (4, 0x04),
        'p_vaddr':  (4, 0x08),
        'p_paddr':  (4, 0x0C),
        'p_filesz': (4, 0x10),
        'p_memsz':  (4, 0x14),
        'p_flags':  (4, 0x18),
        'p_align':  (4, 0x1C)
    }

    entry_size = 0x20


class SectionHeaderTable(Table):
    def __init__(self):
        super().__init__()
        self.add_entry(SectionHeader(), 'zero')


class ProgramHeaderTable(Table):
    pass


class StringTable: # a section
    def __init__(self):
        self._size: int
        self._offset: int
        self._strings = dict()
        self._cix = 0
        self.add_string('\0')

    def add_string(self, string):
        if not string in self._strings:
            self._strings[string] = self._cix
            self._cix = self._cix + len(string) + 1

    def index_of(self, string) -> int:
        assert(string in self._strings)
        return self._strings[string]

    def set_section_header(self, section_header):
        self._section_header = section_header

    def section_header(self) -> SectionHeader:
        return self._section_header

    def offset(self) -> int:
        return self._offset

    def size(self) -> int:
        return self._size

    def append_to_buf(self, buf, offset):
        self._offset = offset
        for s in self._strings:
            buf.extend(s.encode('ascii'))
            buf.extend(b'\0')
        self._size = len(buf) - self._offset


class Section:
    def __init__(self):
        self._section_header: SectionHeader
        self._program_header: ProgramHeader
        self._offset: int

    def put_data(self, data):
        self._data = data

    def size(self) -> int:
        return(len(self._data))

    def set_section_header(self, section_header):
        self._section_header = section_header

    def set_program_header(self, program_header):
        self._program_header = program_header

    def offset(self) -> int:
        return self._offset

    def section_header(self) -> SectionHeader:
        return self._section_header

    def program_header(self) -> ProgramHeader:
        return self._program_header

    def append_to_buf(self, buf, offset):
        self._offset = offset
        buf.extend(self._data)


class SymbolTableEntry(TableEntry):
    fields = {
        'st_name':    (4, 0x00),
        'st_value':   (4, 0x04),
        'st_size':    (4, 0x08),
        'st_info':    (1, 0x0C),
        'st_other':   (1, 0x0D),
        'st_shndx':   (2, 0x0E)
    }

    entry_size = 0x10


class SymbolTable(Table): # a section
    def __init__(self):
        self._section_header: SectionHeader
        super().__init__()
        # null entry at index 0 is the only local symbol; all others are global
        self.add_entry(SymbolTableEntry(), 'zero') # empty/zeroed entry as per specs
        self._num_locals = 1  # null entry is the first (and only initial) local

    def set_section_header(self, section_header):
        self._section_header = section_header

    def section_header(self) -> SectionHeader:
        return self._section_header

    def add_local_entry(self, entry, key):
        """Add a LOCAL symbol.  Must be called before any global symbol is added."""
        self._num_locals += 1
        self.add_entry(entry, key)

    def index_of_first_global(self) -> int:
        return self._num_locals


class BinFile:
    def __init__(self, bin_file, load_addr): # Path
        # bin_file exists, tested by caller
        try:
            with bin_file.open('br') as f:
                    data = f.read()
        except:
            print(f'{PROG_NAME}: cannot read {bin_file}')
            sys.exit(1)
        self._file = bin_file
        self._load_addr = load_addr
        self._name = bin_file.stem
        self._binbuf = bytearray(data)
        self._size = len(data)

    def make_nxp(self):
        print(hex(self._size))
        self._binbuf[0x20:0x24] = struct.pack('<I', self._size)

    def clean(self):
        for i in range(0x8, 0x100, 4):
                self._binbuf[i:i+4] = struct.pack('<I', 0x0)

    @property
    def entry_addr(self):
        return struct.unpack('<L', self._binbuf[4:8])[0]

    @property
    def load_addr(self):
        return self._load_addr

    @property
    def name(self):
        return self._name

    @property
    def data(self):
        return self._binbuf


def parse_hex(s):
    """Parse a hex string accepting three forms: naked '20000000', '0x' prefix, 'H' postfix."""
    s = s.strip()
    if s.upper().endswith('H'):
        s = s[:-1]
    return int(s, 16)


def parse_map_ranges(map_path):
    """Extract Code Range and Data Range from .map file.

    Returns dict with keys code_base, data_start, data_end (int or None).
    """
    import re
    code_re = re.compile(r'^Code Range:\s+([0-9A-F]+)H', re.IGNORECASE)
    data_re = re.compile(r'^Data Range:\s+([0-9A-F]+)H\s+([0-9A-F]+)H', re.IGNORECASE)
    result = {'code_base': None, 'data_start': None, 'data_end': None}
    try:
        text = map_path.read_text(encoding='utf-8', errors='replace')
    except OSError:
        return result
    for line in text.splitlines():
        m = code_re.match(line)
        if m:
            result['code_base'] = int(m.group(1), 16)
            continue
        m = data_re.match(line)
        if m:
            result['data_start'] = int(m.group(1), 16)
            result['data_end'] = int(m.group(2), 16)
    return result


def main():
    import argparse, os, re
    from pathlib import Path

    # single colon
    _file_pat0 = (r'^([A-Za-z]:[/\\](?:[^:]+[/\\])*[^:]*' +
                                        r'|[A-Za-z]:[^/\\:]+' +
                                        r'|/(?:[^:]+/)*[^:]*' +
                                        r'|(?:\.\.?/)?[^:]+(?:/[^:]*)*' +
                                        r'|[^/:]+)(?::(.+))?$')

    parser = argparse.ArgumentParser(
        prog = 'make-elf',
        description =
        """Create an .elf file from binary files, with optional DWARF debug data.
        Each binary file is given as 'file_name:load_address'.
        When no binary files are given, a debug-only ELF is created (no loadable
        sections): Ozone will use it for symbols and DWARF only and will not write
        to flash.
        By default a 'main' symbol is added at the entry address; this allows
        Ozone to root the Call Graph and use Run-to-Main.
        Procedure symbol names in .symtab use underscores instead of dots
        (e.g. 'SignalSync_run') so that Ozone scripts can look them up via
        Elf.GetExprValue() without the dot being parsed as a C operator.""",
        epilog = ''
    )
    parser.add_argument('bin_files', type=str, nargs='*', help="binary files (.bin), as 'bin_file:load_addr'")
    parser.add_argument('-v', action='store_true', dest='verbose', help="print feedback")
    parser.add_argument('--debug', action='store_true', dest='include_debug',
                        help="include .debug_* sections (line numbers, frame info, etc.); "
                             "implies --symbols")
    parser.add_argument('--symbols', action='store_true', dest='include_symbols',
                        help="include procedure and variable symbols from listing files "
                             "(requires rdb/ directory from gen-rdb)")
    parser.add_argument('--sym-prefix', type=str,
                        dest='symbol_prefix', default='',
                        help="prefix all symbol names with PREFIX_ (e.g. S for Secure, "
                             "NS for Non-Secure) for TrustZone dual-image debugging")
    parser.add_argument('--image-def', action='store_true', dest='image_def',
                        help="prepend a 256-byte RP2350 IMAGE_DEF metadata block "
                             "at code_base - 0x100 (enables standalone boot after "
                             "GDB/OpenOCD flash programming)")
    parser.add_argument('--rdb-dir', type=str, dest='rdb_dir', default='rdb',
                        help="directory with listing files (default: rdb)")
    parser.add_argument('--bss', type=str, dest='bss_range', default=None,
                        help="RAM data region: 'start_addr:end_addr' (hex; accepts 0x prefix or H postfix). "
                             "Adds a SHT_NOBITS .bss section and PT_LOAD segment so the debugger "
                             "can read variable values from that address range. "
                             "Use DataStart:DataEnd from your Astrobe linker config (.ini). "
                             "Example: --bss=20000000:20030000")
    parser.add_argument('--map', type=str, dest='map_file', default=None,
                        help="path to .map file for global variable addresses "
                             "(auto-detected as <binary>.map if not given)")
    parser.add_argument('--entry', type=str, dest='entry_addr', default=None,
                        help="entry address (hex) for 'main'/'startup' symbols and e_entry; "
                             "needed in no-binary mode when --no-main is not set")
    parser.add_argument('--no-main', action='store_true', dest='no_main',
                        help="do not add 'main' and 'startup' symbols at the entry point")
    parser.add_argument('-o', type=str, dest='out_file', help="output file (.elf), default: first bin_file.elf or <rdb-parent>.elf")
    parser.add_argument('-e', type=str, dest='src_ext', default=None,
                        help="source file extension including dot (default: .alst)")
    parser.add_argument('--nxp', action='store_true', dest='nxp',
                        help="make NXP-specific modifications")
    parser.add_argument('-l', '--source-lines', action='store_true', dest='source_lines',
                        help="map addresses to Oberon source lines instead of assembly lines (requires --debug)")
    args = parser.parse_args()

    # --debug implies --symbols
    if args.include_debug:
        args.include_symbols = True

    file_re = re.compile(_file_pat0)

    # Pass 1: collect binary file paths and optional addresses
    bin_specs = []  # list of (resolved_path, load_addr_int_or_None)
    first_bin_f = None
    for i, f in enumerate(args.bin_files):
        m = file_re.match(f)
        if m:
            file = m.group(1)
            addr_str = m.group(2)
            bin_f = Path(file).resolve()
            if not bin_f.is_file():
                print(f'{PROG_NAME}: cannot find file {bin_f}')
                sys.exit(1)
            if addr_str is not None:
                try:
                    load_addr = parse_hex(addr_str)
                except:
                    print(f'{PROG_NAME}: {file} enter addresses in hexadecimal format')
                    sys.exit(1)
                if load_addr > 0xFFFFFFFF:
                    print(f'{PROG_NAME}: {file} address {addr_str} exceeds 32-bit range')
                    sys.exit(1)
            else:
                load_addr = None
            bin_specs.append((bin_f, load_addr))
            if i == 0:
                first_bin_f = bin_f
                if args.out_file is None:
                    args.out_file = bin_f.with_suffix('.elf')
                else:
                    args.out_file = Path(args.out_file).resolve()
        else:
            print(f'{PROG_NAME}: specify image files as \'file_name:load_addr\' (in hex): \'{f}\'')
            sys.exit(1)

    # Resolve .map file early (needed for code base and BSS auto-detect)
    map_file = None
    if args.map_file:
        map_file = Path(args.map_file).resolve()
        if not map_file.is_file():
            print(f'{PROG_NAME}: map file not found: {map_file}')
            sys.exit(1)
    elif first_bin_f is not None:
        auto_map = first_bin_f.with_suffix('.map')
        if auto_map.is_file():
            map_file = auto_map

    # Parse .map ranges (code base + data range) if available
    map_ranges = None
    if map_file is not None:
        map_ranges = parse_map_ranges(map_file)

    # Pass 2: resolve missing addresses and create BinFile objects
    addr_from_map = False
    if bin_specs:
        missing = [i for i, (_, a) in enumerate(bin_specs) if a is None]
        if missing:
            if len(bin_specs) > 1:
                print(f'{PROG_NAME}: multiple binaries require explicit load addresses for all files')
                sys.exit(1)
            # Single binary, no address — try .map
            if map_ranges is not None and map_ranges['code_base'] is not None:
                bin_specs[0] = (bin_specs[0][0], map_ranges['code_base'])
                addr_from_map = True
            else:
                print(f'{PROG_NAME}: no load address for {bin_specs[0][0].name} and '
                      f'no Code Range in .map file; '
                      f'use \'file:addr\' or provide a .map file')
                sys.exit(1)

    bin_files = []
    entry_addr = 0
    for i, (bin_f, load_addr) in enumerate(bin_specs):
        bin_file = BinFile(bin_f, load_addr)
        if args.nxp:
            bin_file.make_nxp()
        bin_files.append(bin_file)
        if i == 0:
            entry_addr = bin_file.entry_addr

    # --entry overrides entry address from binary (or sets it in no-binary mode)
    if args.entry_addr is not None:
        try:
            entry_addr = parse_hex(args.entry_addr)
        except:
            print(f'{PROG_NAME}: --entry: invalid hex address \'{args.entry_addr}\'')
            sys.exit(1)
        if entry_addr > 0xFFFFFFFF:
            print(f'{PROG_NAME}: --entry: address {args.entry_addr} exceeds 32-bit range')
            sys.exit(1)

    # no-binary mode: debug-only ELF
    if not bin_files:
        if entry_addr == 0:
            if not args.no_main and args.verbose:
                print(f'{PROG_NAME}: no binary and no --entry: main symbol will not be added; '
                      f'use --entry=<hex> to specify the entry address')

        if args.out_file is None:
            # derive output name from rdb directory's parent directory name
            db_path = Path(args.rdb_dir).resolve()
            if db_path.is_dir():
                args.out_file = db_path.parent / (db_path.parent.name + '.elf')
            else:
                print(f'{PROG_NAME}: no binary given and listing directory \'{args.rdb_dir}\' not found; '
                      f'use -o to specify output file')
                sys.exit(1)
        else:
            args.out_file = Path(args.out_file).resolve()
        if not args.include_debug:
            # debug sections are the primary purpose of no-binary mode; auto-enable
            args.include_debug = True
            args.include_symbols = True
            if args.verbose:
                print(f'no binary: --debug auto-enabled')

    # --- validate --image-def ---
    image_def = None
    if args.image_def:
        if not bin_files:
            print(f'{PROG_NAME}: --image-def requires at least one binary file '
                  f'(need code base address for vector table pointer)')
            sys.exit(1)
        image_def = ImageDef(bin_files[0].load_addr)

    create_main = not args.no_main

    # --- parse --bss range ---
    bss_range = None
    if args.bss_range is not None:
        parts = args.bss_range.split(':')
        if len(parts) != 2:
            print(f'{PROG_NAME}: --bss: expected start:end (hex), got \'{args.bss_range}\'')
            sys.exit(1)
        try:
            bss_start = parse_hex(parts[0])
            bss_end   = parse_hex(parts[1])
        except ValueError:
            print(f'{PROG_NAME}: --bss: invalid hex address in \'{args.bss_range}\'')
            sys.exit(1)
        if bss_end <= bss_start:
            print(f'{PROG_NAME}: --bss: end address must be greater than start address')
            sys.exit(1)
        bss_range = (bss_start, bss_end - bss_start)

    # --- auto-detect BSS from .map ---
    bss_from_map = False
    if bss_range is None and map_ranges is not None:
        ds = map_ranges['data_start']
        de = map_ranges['data_end']
        if ds is not None and de is not None and de > ds:
            bss_range = (ds, de - ds)
            bss_from_map = True

    # --- locate listing files and extract symbols ---
    debug_data = None
    db_dir = Path(args.rdb_dir).resolve()
    rdb_path = Path(args.rdb_dir)
    src_subdir = rdb_path.name
    comp_dir = str(rdb_path.parent)

    if args.include_symbols:
        # --symbols or --debug: extract symbols from listing files
        if db_dir.is_dir():
            # auto-detect ARM attributes config file
            arm_attr_cfg = db_dir / ARM_ATTR_CFG
            if arm_attr_cfg.is_file():
                if args.verbose:
                    print(f'ARM attributes: {arm_attr_cfg}')
            else:
                arm_attr_cfg = None
                if args.verbose:
                    print(f'ARM attributes: no {ARM_ATTR_CFG} in {src_subdir}/')

            if args.verbose:
                if map_file:
                    print(f'map file: {map_file}')
                elif args.include_debug:
                    print(f'map file: none (global variable addresses not available)')

            debug_data = elfdata.extract(db_dir, src_subdir, args.src_ext,
                                           source_lines=(args.source_lines and args.include_debug),
                                           arm_attr_cfg=arm_attr_cfg,
                                           map_file=map_file, comp_dir=comp_dir,
                                           symbol_prefix=args.symbol_prefix)

            if args.verbose:
                print(f'debug: {len(debug_data.procedures)} symbols from {src_subdir}/')
                if args.include_debug:
                    n_lines = sum(len(m.line_entries) for m in debug_data.modules)
                    print(f'  {n_lines} line entries')
                    if args.source_lines:
                        print(f'  line mapping: source-level (Oberon source lines)')
                print(f'  symtab names: dots replaced by underscores '
                      f'(e.g. SignalSync.run => SignalSync_run)')
        else:
            print(f'{PROG_NAME}: --{"debug" if args.include_debug else "symbols"} '
                  f'requires listing files, but directory \'{args.rdb_dir}\' not found')
            sys.exit(1)
    else:
        if args.verbose:
            print(f'symbols: none (use --symbols or --debug with gen-rdb listing files)')

    if args.verbose:
        print(f'ELF file: {args.out_file}')
        if bin_files:
            print('binary files:')
            for file in bin_files:
                src = ' (from .map Code Range)' if addr_from_map else ''
                print(f'  {file.name} {hex(file.load_addr)}{src}')
            print(f'entry address: {hex(entry_addr)}')
        else:
            print('mode: debug-only (no binary, no loadable sections)')
            if entry_addr:
                print(f'entry address: {hex(entry_addr)}')
        if create_main and entry_addr:
            pfx = f'{args.symbol_prefix}_' if args.symbol_prefix else ''
            print(f'main symbol: {pfx}main at {hex(entry_addr)}')
            print(f'startup symbol: {pfx}startup at {hex(entry_addr)}')
        elif not create_main:
            print('main symbol: suppressed (--no-main)')
        else:
            print('main symbol: not added (no entry address)')
        if args.symbol_prefix:
            print(f'symbol prefix: {args.symbol_prefix}_')
        if bss_range is not None:
            bss_start, bss_size = bss_range
            src = ' (from .map Data Range)' if bss_from_map else ''
            print(f'BSS region: 0x{bss_start:08x}\u20130x{bss_start + bss_size:08x} ({bss_size} bytes){src}')
        if image_def is not None:
            print(image_def.verbose_line())

    elf = Elf()
    elf.make(bin_files, entry_addr, debug_data, include_debug=args.include_debug,
             create_main=create_main, bss_range=bss_range, image_def=image_def,
             symbol_prefix=args.symbol_prefix)

    if args.verbose:
        print('sections:')
        for section in elf._sections:
            print(f'  {section}')

    try:
        with open(args.out_file, 'wb') as f:
            f.write(elf.data)
    except:
        print(f'{PROG_NAME}: could not create output file {args.out_file}')
        sys.exit(1)

    try:
        elf_display = args.out_file.relative_to(Path.cwd().parent)
    except ValueError:
        elf_display = args.out_file
    print(f'{PROG_NAME}: created ELF file: {elf_display}')

if __name__ == '__main__':
    main()
