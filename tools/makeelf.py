#!/usr/bin/env python3

# Create an ELF file from several binaries
# --
# Run with option -h for help.
# --
# Put into a directory on $PYTHONPATH, and run as
# 'python -m  makeelf ...'
# --
# Copyright (c) 2025-2026 Gray, gray@graraven.org
# https://oberon-rtk.org/licences/

import struct, sys

PROG_NAME = 'makeelf'

class Elf:
  def __init__(self):
    self._buf = bytearray()
    self._fh = FileHeader()
    self._sh_tab = SectionHeaderTable()
    self._ph_tab = ProgramHeaderTable()
    self.sections = dict()

    # create section header string table section (sic) .shstrtab
    self._shstr_tab = StringTable()
    self.add_section(self._shstr_tab, '.shstrtab')
    self._shstr_tab.add_string('.shstrtab')

    # register section .shstrtab in section header table
    shstr_tab_hd = SectionHeader()
    shstr_tab_hd.set_data_field('sh_name', self._shstr_tab.index_of('.shstrtab'))
    shstr_tab_hd.set_data_field('sh_type', 3) # SHT_STRTAB
    self._shstr_tab.set_section_header(shstr_tab_hd)
    self._shstr_tab_hd = shstr_tab_hd

  def add_section(self, section, section_name):
    assert section_name not in self.sections
    self.sections[section_name] = section

  def make(self, bin_files, entry_addr):
    # define file header
    self._fh.set_data_field('e_ident_magic', self._fh.magic)
    self._fh.set_data_field('e_ident_class', 1)
    self._fh.set_data_field('e_ident_data', 1)
    self._fh.set_data_field('e_ident_version', 1)
    self._fh.set_data_field('e_ident_osabi', 0x00)
    self._fh.set_data_field('e_type', 0x02)    # little endian
    self._fh.set_data_field('e_machine', 0x28) # ARM
    self._fh.set_data_field('e_version', 1)
    self._fh.set_data_field('e_entry', entry_addr)
    self._fh.set_data_field('e_flags', 0x5000400)
    self._fh.set_data_field('e_ehsize', FileHeader.entry_size)
    self._fh.set_data_field('e_phentsize', ProgramHeader.entry_size)
    self._fh.set_data_field('e_shentsize', SectionHeader.entry_size)

    # write file header
    self._fh.append_to_buf(self._buf)

    text_sections = list()
    for file in bin_files:
      # create code section for 'file' image
      text = Section()
      text_sections.append(text)
      text.put_data(file.data)
      section_name = f'.{file.name}'
      self.add_section(text, section_name)
      self._shstr_tab.add_string(section_name)

      # create entry for 'file' image in section header table
      text_sh = SectionHeader()
      text_sh.set_data_field('sh_name', self._shstr_tab.index_of(section_name))
      text_sh.set_data_field('sh_type', 1) # SHT_PROGBITS
      text_sh.set_data_field('sh_flags', 0x4 | 0x2) # SHF_EXECINSTR | SHF_ALLOC
      text_sh.set_data_field('sh_addr', file.load_addr)
      text_sh.set_data_field('sh_size', text.size())
      text_sh.set_data_field('sh_addralign', 4)
      self._sh_tab.add_entry(text_sh, section_name)
      text.set_section_header(text_sh)

      # create entry for 'file' image in program header table
      text_ph = ProgramHeader()
      text_ph.set_data_field('p_type', 1)  # PT_LOAD
      text_ph.set_data_field('p_vaddr', file.load_addr)
      text_ph.set_data_field('p_paddr', file.load_addr)
      text_ph.set_data_field('p_filesz', text.size())
      text_ph.set_data_field('p_memsz', text.size())
      text_ph.set_data_field('p_flags', 0x04 | 0x01) # PF_R | PF_X
      text_ph.set_data_field('p_align', 0x1000)
      self._ph_tab.add_entry(text_ph, section_name)
      text.set_program_header(text_ph)

    # create string table .strtab
    self._str_tab = StringTable()
    self.add_section(self._str_tab, '.strtab')
    self._shstr_tab.add_string('.strtab')

    # create entry for .strtab in section header table
    str_tab_hd = SectionHeader()
    str_tab_hd.set_data_field('sh_name', self._shstr_tab.index_of('.strtab'))
    str_tab_hd.set_data_field('sh_type', 3) # SHT_STRTAB
    self._str_tab.set_section_header(str_tab_hd)
    self._sh_tab.add_entry(str_tab_hd, '.strtab')

    # create symbol table .symtab
    symtab = SymbolTable()
    self.add_section(symtab, '.symtab')
    self._shstr_tab.add_string('.symtab')

    # create entry for .symtab in section header table
    symtab_hd = SectionHeader()
    symtab_hd.set_data_field('sh_name', self._shstr_tab.index_of('.symtab'))
    symtab_hd.set_data_field('sh_type', 2) # SHT_SYMTAB
    symtab_hd.set_data_field('sh_link', self._sh_tab.index_of('.strtab')) # link to .strtab
    symtab_hd.set_data_field('sh_entsize', SymbolTableEntry.entry_size)
    self._sh_tab.add_entry(symtab_hd, '.symtab')
    symtab.set_section_header(symtab_hd)

    # write program header table
    self._ph_tab.append_to_buf(self._buf, len(self._buf))

    # add .shstrtab to section header table
    self._sh_tab.add_entry(self._shstr_tab_hd, '.shstrtab')

    # write section header table
    self._sh_tab.append_to_buf(self._buf, len(self._buf))

    # write code sections
    for text in text_sections:
      text.append_to_buf(self._buf, len(self._buf))
      # fix-up section and program header entries
      text.section_header().set_buf_field("sh_offset", text.offset())
      text.program_header().set_buf_field("p_offset", text.offset())

    # write section header string table section
    self._shstr_tab.append_to_buf(self._buf, len(self._buf))
    # fix-up section header
    self._shstr_tab.section_header().set_buf_field('sh_offset', self._shstr_tab.offset())
    self._shstr_tab.section_header().set_buf_field('sh_size', self._shstr_tab.size())

    # write string table section
    self._str_tab.append_to_buf(self._buf, len(self._buf))
    # fix-up section header
    self._str_tab.section_header().set_buf_field('sh_offset', self._str_tab.offset())
    self._str_tab.section_header().set_buf_field('sh_size', self._str_tab.size())

    # write symbol table section
    symtab.append_to_buf(self._buf, len(self._buf))
    # fix-up section header
    # 'sh_info' contains the index of the first global symbol for symbol tables
    symtab.section_header().set_buf_field('sh_offset', symtab.offset())
    symtab.section_header().set_buf_field('sh_size', symtab.size())
    symtab.section_header().set_buf_field('sh_info', symtab.index_of_first_global())

    # fix-up file header entries
    self._fh.set_buf_field('e_shnum', self._sh_tab.num_entries())
    self._fh.set_buf_field('e_phnum', self._ph_tab.num_entries())
    self._fh.set_buf_field('e_shoff', self._sh_tab.offset())
    self._fh.set_buf_field('e_phoff', self._ph_tab.offset())
    self._fh.set_buf_field('e_shstrndx', self._sh_tab.index_of('.shstrtab'))


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
  magic = 0x464C457F  # '7F 45 4C 46'
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
    'st_info':    (1, 0x09),
    'st_other':   (1, 0x0A),
    'st_shndx':   (2, 0x0B)
  }

  entry_size = 0x10


class SymbolTable(Table): # a section
  def __init__(self):
    self._section_header: SectionHeader
    super().__init__()
    self._first_global = 1
    self.add_entry(SymbolTableEntry(), 'zero') # empty/zeroed entry as per specs

  def add_entry(self, entry, entry_name):
    super().add_entry(entry, entry_name)
    self._first_global += 1

  def set_section_header(self, section_header):
    self._section_header = section_header

  def section_header(self) -> SectionHeader:
    return self._section_header

  def index_of_first_global(self) -> int:
    return self._first_global


class BinFile:
  def __init__(self, bin_file, load_addr): # Path
    # bin_file exists, tested by caller
    try:
      with bin_file.open('br') as f:
          data = f.read()
    except:
      print(f'{PROG_NAME}: cannot read {self._file}')
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

  # file_pat = r'([\w\d\.\_\-]+)\:?(.*)'
  file_pat = r'(.*)\:(.*)'
  # file_pat = r'(\w+\.\w+)\:*([0-9A-Fa-f]*)'

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
  parser.add_argument('--nxp', action='store_true', dest='nxp',
                      help="make NXP-specific modifications")
  args = parser.parse_args()

  file_re = re.compile(file_pat)

  bin_files = list()
  # print(args.bin_files)
  first = True
  for file in args.bin_files:
    # print(file)
    m = file_re.match(file)
    if m is None:
      print(f'{PROG_NAME}: specify each binary as \'bin_file:load_address\'')
      sys.exit(1)
    else:
      bin_f = Path(m.group(1)).resolve()
      # print(bin_f)
      try:
          load_addr = int(m.group(2), 16)
      except:
          print(f'{PROG_NAME}: enter addresses in hexadecimal format (with or without \'0x\' prefix)')
          sys.exit(1)
      if not bin_f.is_file():
        print(f'{PROG_NAME}: cannot find binary file {bin_f}')
        sys.exit(1)
      bin_file = BinFile(bin_f, load_addr)
      # bin_file.clean()
      if args.nxp:
        bin_file.make_nxp()
      bin_files.append(bin_file)
      if first:
        if args.out_file == None: args.out_file = bin_f.with_suffix('.elf')
        entry_addr = bin_file.entry_addr
        first = False

  # print(bin_files)
  # print(args.out_file)

  if args.verbose:
    print(f'ELF file: {args.out_file}')
    print("binary files:")
    for file in bin_files:
      print(f'  {file.name} {hex(file.load_addr)}')
    print(f'entry address: {hex(entry_addr)}')

  elf = Elf()
  elf.make(bin_files, entry_addr)

  if args.verbose:
    print("sections created:")
    for section in elf.sections:
      print(f'  {section}')

  # if args.verbose:
  #   print(f'Writing ELF file: {args.out_file}...')

  try:
    with open(args.out_file, 'wb') as f:
      f.write(elf._buf)
  except:
    print(f'{PROG_NAME}: could not create output file {args.out_file}')
    sys.exit(1)

  print("Created ELF file: {}".format(args.out_file))

if __name__ == '__main__':
    main()
