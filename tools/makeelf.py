#!/usr/bin/env python3

# Create an ELF file for Astrobe for Cortex-M0
# --
# Run with option -h for help.
# --
# Put into a directory on $PYTHONPATH, and run as
# 'python -m  pio2o ...'
# No idea if that's the right way, but it works.
# --
# Copyright (c) 2024 Gray, gray@graraven.org
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
    self._sections = list()

    # create section header string table section (sic)
    self._shstr_tab = StringTable()
    self.add_section(self._shstr_tab)
    self._shstr_tab.add_string('.shstrtab')

    # register section in section header table
    shstr_tab_hd = SectionHeader()
    shstr_tab_hd.set_data_field('sh_name', self._shstr_tab.index_of('.shstrtab'))
    shstr_tab_hd.set_data_field('sh_type', 3) # SHT_STRTAB
    self._shstr_tab.set_section_header(shstr_tab_hd)
    self._sh_tab.add_header(shstr_tab_hd, '.shstrtab')

  def add_section(self, section):
    self._sections.append(section)

  def set_code_addr(self, entry_addr, prog_addr):
    self._entry_addr = entry_addr
    self._prog_addr = prog_addr

  def make(self, boot_data, prog_data):
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
    self._fh.set_data_field('e_ehsize', 0x34)
    self._fh.set_data_field('e_phentsize', 0x20)
    self._fh.set_data_field('e_shentsize', 0x28)

    self._fh.append_to_buf(self._buf, len(self._buf))
    #print("end of file header: {}".format(hex(len(self._buf))))

    boot2 = Section()
    boot2.put_data(boot_data)
    self.add_section(boot2)
    self._shstr_tab.add_string('.boot2')

    boot2_hd = SectionHeader()
    boot2_hd.set_data_field('sh_name', self._shstr_tab.index_of('.boot2'))
    boot2_hd.set_data_field('sh_type', 1) # SHT_PROGBITS
    boot2_hd.set_data_field('sh_flags', 0x10000000 | 0x04 | 0x02) # SHF_ ENTRYSECT | SHF_EXECINSTR | SHF_ALLOC
    boot2_hd.set_data_field('sh_addr', self._entry_addr) # rp2040 boot load address
    boot2_hd.set_data_field('sh_size', boot2.size())
    boot2_hd.set_data_field('sh_addralign', 4)
    self._sh_tab.add_header(boot2_hd, '.boot2')
    boot2.set_section_header(boot2_hd)

    boot2_ph = ProgramHeader()
    boot2_ph.set_data_field('p_type', 1)  # PT_LOAD
    boot2_ph.set_data_field('p_vaddr', self._entry_addr)  # rp2040 boot load address
    boot2_ph.set_data_field('p_paddr', self._entry_addr)
    boot2_ph.set_data_field('p_filesz', boot2.size())
    boot2_ph.set_data_field('p_memsz', boot2.size())
    boot2_ph.set_data_field('p_flags', 0x04 | 0x01) # PF_R | PF_X
    self._ph_tab.add_header(boot2_ph, '.boot2')
    boot2.set_program_header(boot2_ph)

    text = Section()
    text.put_data(prog_data)
    self.add_section(text)
    self._shstr_tab.add_string('.text')

    text_hd = SectionHeader()
    text_hd.set_data_field('sh_name', self._shstr_tab.index_of('.text'))
    text_hd.set_data_field('sh_type', 1) # SHT_PROGBITS
    text_hd.set_data_field('sh_flags', 0x4 | 0x2) # SHF_EXECINSTR | SHF_ALLOC
    text_hd.set_data_field('sh_addr', self._prog_addr) # rp2040 prog load address
    text_hd.set_data_field('sh_size', text.size())
    text_hd.set_data_field('sh_addralign', 4)
    self._sh_tab.add_header(text_hd, '.text')
    text.set_section_header(text_hd)

    text_ph = ProgramHeader()
    text_ph.set_data_field('p_type', 1)  # PT_LOAD
    text_ph.set_data_field('p_vaddr', self._prog_addr)  # rp2040 prog load address
    text_ph.set_data_field('p_paddr', self._prog_addr)
    text_ph.set_data_field('p_filesz', text.size())
    text_ph.set_data_field('p_memsz', text.size())
    text_ph.set_data_field('p_flags', 0x04 | 0x01) # PF_R | PF_X
    self._ph_tab.add_header(text_ph, '.text')
    text.set_program_header(text_ph)

    self._sh_tab.append_to_buf(self._buf, len(self._buf))
    #print("end of sh_tab: {}".format(hex(len(self._buf))))

    self._ph_tab.append_to_buf(self._buf, len(self._buf))
    #print("end of ph_tab: {}".format(hex(len(self._buf))))

    boot2.append_to_buf(self._buf, len(self._buf))
    #print("end of .boot: {}".format(hex(len(self._buf))))
    boot2.section_header().set_buf_field("sh_offset", boot2.offset())
    boot2.program_header().set_buf_field("p_offset", boot2.offset())

    text.append_to_buf(self._buf, len(self._buf))
    #print("end of .text: {}".format(hex(len(self._buf))))
    text.section_header().set_buf_field("sh_offset", text.offset())
    text.program_header().set_buf_field("p_offset", text.offset())

    self._shstr_tab.append_to_buf(self._buf, len(self._buf))
    #print("end of _shstr_tab: {}".format(hex(len(self._buf))))
    self._shstr_tab.section_header().set_buf_field('sh_offset', self._shstr_tab.offset())
    self._shstr_tab.section_header().set_buf_field('sh_size', self._shstr_tab.size())

    self._fh.set_buf_field('e_shnum', self._sh_tab.num_entries())
    self._fh.set_buf_field('e_phnum', self._ph_tab.num_entries())
    self._fh.set_buf_field('e_shoff', self._sh_tab.offset())
    self._fh.set_buf_field('e_phoff', self._ph_tab.offset())
    self._fh.set_buf_field('e_shstrndx', self._sh_tab.index_of('.shstrtab'))


class Header:
  # abstract class for all headers

  fields = {}

  def __init__(self):
    self.offset = 0
    self.data = dict()
    for k in self.fields:
      self.data[k] = 0

  def set_data_field(self, name, val):
    assert(name in self.data)
    self.data[name] = val

  def set_buf_field(self, name, val):
    size, offset = self.fields[name]
    offset = offset + self.offset
    fmt = {1: '<B', 2: '<H', 4: '<I', 8: '<Q'}[size]
    self._buf[offset:offset+size] = struct.pack(fmt, val)

  def append_to_buf(self, buf, offset):
    self._buf = buf
    self.offset = offset
    for _, val in self.fields.items():
      size, _ = val
      buf.extend(b'\0' * size)
    for name, val in self.data.items():
      self.set_buf_field(name, val)


class FileHeader(Header):
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

  def append_to_buf(self, buf, offset):
    self._buf = buf
    self.offset = offset
    for _, val in self.fields.items():
      size, _ = val
      buf.extend(b'\0' * size)
    for name, val in self.data.items():
      if name != 'e_pad':
        self.set_buf_field(name, val)


class SectionHeader(Header):
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


class ProgramHeader(Header):
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

class HeaderTable:
  def __init__(self):
    self._headers = list()
    self._header_names = dict()

  def add_header(self, header, header_name):
    ix = len(self._headers)
    self._headers.append(header)
    self._header_names[header_name] = ix

  def get_header(self, id) -> Header:
    if type(id) == str:
      id = self._header_names[id]
    return self._headers[id]

  def index_of(self, header_name) -> int:
    return self._header_names[header_name]

  def num_entries(self) -> int:
    return len(self._headers)

  def offset(self) -> int:
    return self._offset

  def append_to_buf(self, buf, offset):
    self._offset = offset
    for hd in self._headers:
      hd.append_to_buf(buf, offset)
      offset = len(buf)


class SectionHeaderTable(HeaderTable):
  def __init__(self):
    self._headers = list()
    self._header_names = dict()
    self.add_header(SectionHeader(), 'zero')


class ProgramHeaderTable(HeaderTable):
  pass


class StringTable: # a section
  def __init__(self):
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
    self._size = len(buf) - offset


class Section:
  def __init__(self):
    pass

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


class SymbolTable:
  pass


def main():
  import argparse, os
  from pathlib import PurePath

  parser = argparse.ArgumentParser(
    prog = 'makeelf',
    description = '',
    epilog = ''
  )
  parser.add_argument("prog_file", type=str, help="input file (.bin)")
  parser.add_argument("-v", action="store_true", dest="verbose", help="print feedback")
  parser.add_argument("-o", type=str, dest='out_file', help="output file (.elf), default: in_file.elf")
  parser.add_argument("-l", type=str, dest='boot_file',
                      help="bootstage 2 file (.bin), default: 'boot2.bin' in installation directory")
  parser.add_argument("-e", dest='entry_addr', default='0x10000000',
                      help="entry address in hexadecimal, default: 0x10000000")
  parser.add_argument("-p", dest='prog_addr', default='0x10000100',
                      help="program address in hexadecimal, default: 0x10000100")
  args = parser.parse_args()

  outf_base = PurePath(args.prog_file)
  if args.out_file == None: args.out_file = outf_base.with_suffix(".elf")

  run_dir = os.path.dirname(os.path.realpath(sys.argv[0])) + "/"
  if args.boot_file == None: args.boot_file = run_dir + "boot2.bin"

  try:
    args.entry_addr = int(args.entry_addr, base = 16)
    args.prog_addr = int(args.prog_addr, base = 16)
  except:
    print("Enter addresses in hexadecimal format (with or without '0x' prefix).")
    sys.exit()

  try:
    with open(args.boot_file, "rb") as boot_file:
      boot_data = boot_file.read()
  except:
    print("Could not open and read bootstage 2 file '{}'".format(args.boot_file))
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