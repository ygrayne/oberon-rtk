#!/usr/bin/env python3

"""
Create an ELF file from several binaries
Includes debug data extracted directly from listing files (.alst)
--
Run with option -h for help.
--
Put into a directory on $PYTHONPATH, and run as
'python -m  makeelf ...'
--
Copyright (c) 2024-2026 Gray, gray@grayraven.org
https://oberon-rtk.org/licences/
"""

import struct, sys, json
import makedebug

PROG_NAME = 'makeelf'

# ARM attributes config file name (looked up in listing directory)
ARM_ATTR_CFG = 'arm-attr.cfg'


# ELF constants

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
SHT_ARM_ATTRIBUTES  = 0x70000003

# section header flags (sh_flags)
SHF_ALLOC       = 0x02      # section occupies memory during execution
SHF_EXECINSTR   = 0x04      # section contains executable instructions

# program header types (p_type)
PT_LOAD         = 1         # loadable segment

# program header flags (p_flags)
PF_X            = 0x01      # executable
PF_R            = 0x04      # readable

# symbol binding (upper 4 bits of st_info)
STB_GLOBAL      = 1

# symbol type (lower 4 bits of st_info)
STT_FUNC        = 2


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

    def make(self, bin_files, entry_addr, debug_data, include_debug=False):
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
        self._fh.set_data_field('e_flags', EF_ARM_ABI_VER5 | EF_ARM_ABI_FLOAT_HARD)
        self._fh.set_data_field('e_ehsize', FileHeader.entry_size)
        self._fh.set_data_field('e_phentsize', ProgramHeader.entry_size)
        self._fh.set_data_field('e_shentsize', SectionHeader.entry_size)

        # write file header
        self._fh.append_to_buf(self._buf)

        text_sections = list()
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

        # --- debug and metadata sections (non-loadable, before string/symbol tables) ---
        debug_sections = list()
        if debug_data is not None:
            for section_name, section_bytes, section_type in [
                ('.debug_line',      debug_data.debug_line,      SHT_PROGBITS),
                ('.debug_info',      debug_data.debug_info,      SHT_PROGBITS),
                ('.debug_abbrev',    debug_data.debug_abbrev,    SHT_PROGBITS),
                ('.debug_aranges',   debug_data.debug_aranges,   SHT_PROGBITS),
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

        # add symbols from debug data
        if debug_data is not None:
            for proc in debug_data.procedures:
                sym = SymbolTableEntry()
                self._str_tab.add_string(proc.name)
                sym.set_data_field('st_name', self._str_tab.index_of(proc.name))
                sym.set_data_field('st_value', proc.address)
                sym.set_data_field('st_size', proc.size)
                sym.set_data_field('st_info', (STB_GLOBAL << 4) | STT_FUNC)
                sym.set_data_field('st_other', 0)
                sym.set_data_field('st_shndx', 1)  # .text section index
                self._sym_tab.add_entry(sym, proc.name)

        # write program header table (right after file header, standard location)
        self._ph_tab.append_to_buf(self._buf, len(self._buf))

        # add .shstrtab to section header table
        self._sh_tab.add_entry(self._shstr_tab_hd, '.shstrtab')

        # --- write all section data ---

        # write code sections
        for text in text_sections:
            text.append_to_buf(self._buf, len(self._buf))

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

        # fix-up code sections
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

        # fix-up file header entries
        self._fh.set_buf_field('e_shnum', self._sh_tab.num_entries())
        self._fh.set_buf_field('e_phnum', self._ph_tab.num_entries())
        self._fh.set_buf_field('e_shoff', self._sh_tab.offset())
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

    def set_section_header(self, section_header):
        self._section_header = section_header

    def section_header(self) -> SectionHeader:
        return self._section_header

    def index_of_first_global(self) -> int:
        return 1  # index 0 is null (local), all others are global


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
        prog = 'makeelf',
        description =
        """Create an .elf file from binary files. The first binary defines the entry point as well
        as the name of the .elf file if option '-o' is not used. Each binary file is given as
        'file_name:load_address'.""",
        epilog = ''
    )
    parser.add_argument('bin_files', type=str, nargs='+', help="binary files (.bin), as 'bin_file:load_addr'")
    parser.add_argument('-v', action='store_true', dest='verbose', help="print feedback")
    parser.add_argument('-o', type=str, dest='out_file', help="output file (.elf), default: first bin_file.elf")
    parser.add_argument('-d', type=str, dest='db_dir', default='rdb',
                        help="directory with listing files (default: rdb)")
    parser.add_argument('-e', type=str, dest='src_ext', default=None,
                        help="source file extension including dot (default: .alst)")
    parser.add_argument('-l', '--source-lines', action='store_true', dest='source_lines',
                        help="map addresses to Oberon source lines instead of assembly lines (requires --debug)")
    parser.add_argument('--debug', action='store_true', dest='include_debug',
                        help="include .debug_* sections (line numbers, frame info, etc.)")
    parser.add_argument('--nxp', action='store_true', dest='nxp',
                                            help="make NXP-specific modifications")
    args = parser.parse_args()

    file_re = re.compile(_file_pat0)

    bin_files = list()
    for i, f in enumerate(args.bin_files):
        m = file_re.match(f)
        if m:
            file = m.group(1)
            load_addr = m.group(2)
            bin_f = Path(file).resolve()
            if not bin_f.is_file():
                print(f'{PROG_NAME}: cannot find file {bin_f}')
                sys.exit(1)
            if load_addr[-1] == 'H': # accept Oberon hex numbers, for easier copy & paste, I am lazy
                load_addr = load_addr[0:-1]
            try:
                load_addr = int(load_addr, 16)
            except:
                print(f'{PROG_NAME}: {file} enter addresses in hexadecimal format')
                sys.exit(1)
            bin_file = BinFile(bin_f, load_addr)
            if args.nxp:
                bin_file.make_nxp()
            bin_files.append(bin_file)
            if i == 0:
                if args.out_file == None:
                    args.out_file = bin_f.with_suffix('.elf')
                else:
                    args.out_file = Path(args.out_file).resolve()
                entry_addr = bin_file.entry_addr
        else:
            print(f'{PROG_NAME}: specify image files as \'file_name:load_addr\' (in hex): \'{f}\'')
            sys.exit(1)

    # --- locate listing files ---
    debug_data = None
    db_dir = Path(args.db_dir).resolve()
    src_subdir = Path(args.db_dir).name

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

        # listing directory exists — extract symbols (always)
        debug_data = makedebug.extract(db_dir, src_subdir, args.src_ext,
                                       source_lines=(args.source_lines and args.include_debug),
                                       arm_attr_cfg=arm_attr_cfg)

        if args.verbose:
            print(f'debug: {len(debug_data.procedures)} symbols from {src_subdir}/')
            if args.include_debug:
                n_lines = sum(len(m.line_entries) for m in debug_data.modules)
                print(f'  {n_lines} line entries')
                if args.source_lines:
                    print(f'  line mapping: source-level (Oberon source lines)')
    else:
        # listing directory not found
        if args.include_debug:
            print(f'{PROG_NAME}: --debug requires listing files, '
                  f'but directory \'{args.db_dir}\' not found')
            sys.exit(1)
        if args.verbose:
            print(f'no listing files (directory \'{args.db_dir}\' not found)')

    if args.verbose:
        print(f'ELF file: {args.out_file}')
        print('binary files:')
        for file in bin_files:
            print(f'  {file.name} {hex(file.load_addr)}')
        print(f'entry address: {hex(entry_addr)}')

    elf = Elf()
    elf.make(bin_files, entry_addr, debug_data, include_debug=args.include_debug)

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

    print(f'{PROG_NAME}: created ELF file: {args.out_file}')

if __name__ == '__main__':
    main()
