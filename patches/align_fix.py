#!/usr/bin/env python

import struct
import sys
import os

if len(sys.argv) < 2:
    print('Usage: ' + os.path.basename(sys.argv[0]) + ' input_file')
    exit()

with open(sys.argv[1], 'r+b') as f:
  f.seek(0)
  hdr = f.read(16)
  if hdr[0] != 0x7f or hdr[1] != ord('E') or hdr[2] != ord('L') or hdr[3] != ord('F'):
    raise Exception('Not an elf file')

  if hdr[4] == 1:
    # 32 bit code
    f.seek(28)
    offset = struct.unpack('<I', f.read(4))[0]
    f.seek(42)
    phsize = struct.unpack('<H', f.read(2))[0]
    phnum = struct.unpack('<H', f.read(2))[0]
    for i in range(0, phnum):
      f.seek(offset + i * phsize)
      t = struct.unpack('<I', f.read(4))[0]
      if t == 7:
        f.seek(28 - 4, 1)
        align = struct.unpack('<I', f.read(4))[0]
        print('Found TLS segment with align = ' + str(align))
        if (align < 32):
          print('TLS segment is underaligned, patching')
          f.seek(-4, 1)
          f.write(struct.pack('<I', 32))

  elif hdr[4] == 2:
    # 64 bit code
    f.seek(32)
    offset = struct.unpack('<Q', f.read(8))[0]
    f.seek(54)
    phsize = struct.unpack('<H', f.read(2))[0]
    phnum = struct.unpack('<H', f.read(2))[0]
    for i in range(0, phnum):
      f.seek(offset + i * phsize)
      t = struct.unpack('<I', f.read(4))[0]
      if t == 7:
        f.seek(48 - 4, 1)
        align = struct.unpack('<Q', f.read(8))[0]
        print('Found TLS segment with align = ' + str(align))
        if (align < 64):
          print('TLS segment is underaligned, patching')
          f.seek(-8, 1)
          f.write(struct.pack('<H', 64))

  else:
    raise Exception('Unknown file class')
