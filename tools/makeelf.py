#!/usr/bin/env python3

# Create an ELF file for Astrobe for Cortex-M0
# --
# Run with option -h for help.
# --
# Put into a directory on $PYTHONPATH, and run as
# 'python -m  makeelf ...'
# --
# Copyright (c) 2024-2025 Gray, gray@graraven.org
# https://oberon-rtk.org/licences/

# The accompanying 'boot2.bin' binary is
# Copyright (c) 2019-2021 Raspberry Pi (Trading) Ltd.
# SPDX-Licence-Identifier: BSD-3-Clause

import struct, sys

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
    #self._sh_tab.add_entry(shstr_tab_hd, '.shstrtab')

    # # create string table .strtab
    # self._str_tab = StringTable()
    # self.add_section(self._str_tab, '.strtab')
    # self._shstr_tab.add_string('.strtab')

    # # register section .strtab in section header table
    # str_tab_hd = SectionHeader()
    # str_tab_hd.set_data_field('sh_name', self._shstr_tab.index_of('.strtab'))
    # str_tab_hd.set_data_field('sh_type', 3) # SHT_STRTAB
    # self._str_tab.set_section_header(str_tab_hd)
    # self._sh_tab.add_entry(str_tab_hd, '.strtab')

  def add_section(self, section, section_name):
    assert section_name not in self.sections
    self.sections[section_name] = section

  def set_code_addr(self, entry_addr, prog_addr):
    self._entry_addr = entry_addr
    self._prog_addr = prog_addr

  def make(self, boot_data, prog_data):
    # define file header
    self._fh.set_data_field('e_ident_magic', self._fh.magic)
    self._fh.set_data_field('e_ident_class', 1)
    self._fh.set_data_field('e_ident_data', 1)
    self._fh.set_data_field('e_ident_version', 1)
    self._fh.set_data_field('e_ident_osabi', 0x00)
    self._fh.set_data_field('e_type', 0x02)    # little endian
    self._fh.set_data_field('e_machine', 0x28) # ARM
    self._fh.set_data_field('e_version', 1)
    self._fh.set_data_field('e_entry', self._entry_addr)
    self._fh.set_data_field('e_flags', 0x5000200) # from SDK example progs
    self._fh.set_data_field('e_ehsize', FileHeader.entry_size)
    self._fh.set_data_field('e_phentsize', ProgramHeader.entry_size)
    self._fh.set_data_field('e_shentsize', SectionHeader.entry_size)

    # write file header
    self._fh.append_to_buf(self._buf)
    #print("end of file header: {}".format(hex(len(self._buf))))

    # create code section .boot2
    boot2 = Section()
    boot2.put_data(boot_data)
    self.add_section(boot2, '.boot2')
    self._shstr_tab.add_string('.boot2')

    # create entry for .boot2 in section header table
    boot2_hd = SectionHeader()
    boot2_hd.set_data_field('sh_name', self._shstr_tab.index_of('.boot2'))
    boot2_hd.set_data_field('sh_type', 1) # SHT_PROGBITS
    boot2_hd.set_data_field('sh_flags', 0x10000000 | 0x04 | 0x02) # SHF_ ENTRYSECT | SHF_EXECINSTR | SHF_ALLOC
    boot2_hd.set_data_field('sh_addr', self._entry_addr) # rp2040 boot load address
    boot2_hd.set_data_field('sh_size', boot2.size())
    boot2_hd.set_data_field('sh_addralign', 4)
    self._sh_tab.add_entry(boot2_hd, '.boot2')
    boot2.set_section_header(boot2_hd)

    # create entry for .boot2 in program header table
    boot2_ph = ProgramHeader()
    boot2_ph.set_data_field('p_type', 1)  # PT_LOAD
    boot2_ph.set_data_field('p_vaddr', self._entry_addr)  # rp2040 boot load address
    boot2_ph.set_data_field('p_paddr', self._entry_addr)
    boot2_ph.set_data_field('p_filesz', boot2.size())
    boot2_ph.set_data_field('p_memsz', boot2.size())
    boot2_ph.set_data_field('p_flags', 0x04 | 0x01) # PF_R | PF_X
    self._ph_tab.add_entry(boot2_ph, '.boot2')
    boot2.set_program_header(boot2_ph)

    # create code section for .text
    text = Section()
    text.put_data(prog_data)
    self.add_section(text, '.text')
    self._shstr_tab.add_string('.text')

    # create entry for .text in section header table
    text_hd = SectionHeader()
    text_hd.set_data_field('sh_name', self._shstr_tab.index_of('.text'))
    text_hd.set_data_field('sh_type', 1) # SHT_PROGBITS
    text_hd.set_data_field('sh_flags', 0x4 | 0x2) # SHF_EXECINSTR | SHF_ALLOC
    text_hd.set_data_field('sh_addr', self._prog_addr) # rp2040 prog load address
    text_hd.set_data_field('sh_size', text.size())
    text_hd.set_data_field('sh_addralign', 4)
    self._sh_tab.add_entry(text_hd, '.text')
    text.set_section_header(text_hd)

    # create entry for .text in program header table
    text_ph = ProgramHeader()
    text_ph.set_data_field('p_type', 1)  # PT_LOAD
    text_ph.set_data_field('p_vaddr', self._prog_addr)  # rp2040 prog load address
    text_ph.set_data_field('p_paddr', self._prog_addr)
    text_ph.set_data_field('p_filesz', text.size())
    text_ph.set_data_field('p_memsz', text.size())
    text_ph.set_data_field('p_flags', 0x04 | 0x01) # PF_R | PF_X
    self._ph_tab.add_entry(text_ph, '.text')
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

    # create 3 dummy symbols for testing
    sym0 = SymbolTableEntry()
    self._str_tab.add_string('test0')
    sym0.set_data_field('st_name', self._str_tab.index_of('test0'))
    symtab.add_entry(sym0, 'test0')

    sym1 = SymbolTableEntry()
    self._str_tab.add_string('test1')
    sym1.set_data_field('st_name', self._str_tab.index_of('test1'))
    symtab.add_entry(sym1, 'test1')

    sym2 = SymbolTableEntry()
    self._str_tab.add_string('test2')
    sym2.set_data_field('st_name', self._str_tab.index_of('test2'))
    symtab.add_entry(sym2, 'test2')

    # write program header table
    self._ph_tab.append_to_buf(self._buf, len(self._buf))

    # add .shstrtab to section header table
    self._sh_tab.add_entry(self._shstr_tab_hd, '.shstrtab')

    # write section header table
    self._sh_tab.append_to_buf(self._buf, len(self._buf))

    # write code section .boot2
    boot2.append_to_buf(self._buf, len(self._buf))
    # fix-up section and program header entries
    boot2.section_header().set_buf_field("sh_offset", boot2.offset())
    boot2.program_header().set_buf_field("p_offset", boot2.offset())

    # write code section .text
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
    'sh_info':      (4, 0x01C),
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


def main():
  import argparse, os
  from pathlib import Path

  parser = argparse.ArgumentParser(
    prog = 'makeelf',
    description = '',
    epilog = ''
  )
  parser.add_argument('prog_file', type=str, help="input file (.bin)")
  parser.add_argument('-v', action='store_true', dest='verbose', help="print feedback")
  parser.add_argument('-o', type=str, dest='out_file', help="output file (.elf), default: in_file.elf")
  parser.add_argument('-l', type=str, dest='boot_file',
                      help="bootstage 2 file (.bin), default: 'boot2.bin' in installation directory")
  parser.add_argument('-e', dest='entry_addr', default='0x10000000',
                      help="entry address in hexadecimal, default: 0x10000000")
  parser.add_argument('-p', dest='prog_addr', default='0x10000100',
                      help="program address in hexadecimal, default: 0x10000100")
  args = parser.parse_args()

  args.prog_file = Path(args.prog_file)
  #outf_base = Path(args.prog_file)
  if args.out_file == None: args.out_file = args.prog_file.with_suffix('.elf')

  if args.boot_file == None:
    args.boot_file = Path(__file__).parent.joinpath('boot2.bin')
  else:
    args.boot_file = Path(args.boot_file)

  try:
    args.entry_addr = int(args.entry_addr, base = 16)
    args.prog_addr = int(args.prog_addr, base = 16)
  except:
    print("Enter addresses in hexadecimal format (with or without '0x' prefix).")
    sys.exit()

  if not args.boot_file.exists():
    print("Could not find bootstage2 file '{}'".format(args.boot_file))
    sys.exit()

  try:
    with open(args.boot_file, 'rb') as boot_file:
      boot_data = boot_file.read()
  except:
    print("Could not read bootstage 2 file '{}'".format(args.boot_file))
    sys.exit()

  try:
    with open(args.prog_file, "rb") as prog_file:
      prog_data = prog_file.read()
  except:
    print("Could not open and read input file '{}'".format(args.prog_file))
    sys.exit()

  elf = Elf()
  elf.set_code_addr(args.entry_addr, args.prog_addr)

  if args.verbose:
    print("Program file: {}".format(args.prog_file))
    print("Boot file: {}".format(args.boot_file))
    print("Elf file: {}".format(args.out_file))
    print("Entry address: {}".format(hex(args.entry_addr)))
    print("Program address: {}".format(hex(args.prog_addr)))
    print("Creating ELF data: {}...".format(args.out_file))

  elf.make(boot_data, prog_data)

  if args.verbose:
    print("sections:")
    for section in elf.sections:
      print("  " + section)

  if args.verbose:
    print("Writing ELF file: {}...".format(args.out_file))

  try:
    with open(args.out_file, 'wb') as out_file:
      out_file.write(elf._buf)
  except:
    print("Error: could not create output file {}".format(args.out_file))
    sys.exit()

  print("Created ELF file: {}".format(args.out_file))

if __name__ == '__main__':
    main()
