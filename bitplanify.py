#!/usr/bin/env python

import sys
import math
from array import array
from PIL import Image

import argparse


def write_copper(file):
    for index, rgb in enumerate(palette):
        file.write('\tdc.w\t$%x,$%03x\n' % (0x180 + index * 2, rgb))


def write_interleaved(file):
    """Write all bitplanes in interleaved mode to a file."""
    for row in xrange(height):
        offset = row * byte_width
        for plane_index in range(bit_depth):
            bitplanes[plane_index][offset:offset + byte_width].write(file)


def write_bitplane(file, plane_index):
    """Write a single bitplane to a file."""
    bitplanes[plane_index].write(out)


parser = argparse.ArgumentParser(description='Convert an image to Amiga bitplanes')
parser.add_argument(
    '--depth', metavar='N', type=int, default=None,
    help='Set number of bitplanes in output')
parser.add_argument(
    '--copper',
    help='Write palette as copper source code (default is to auto-detect)')
parser.add_argument(
    '--separate', action='store_true',
    help='Write one bitplane per file. Use %%s in filename as replacement for bitplane number.')
parser.add_argument(
    '--verbose', '-v', action='store_true',
    help='Write more information to stdout')
parser.add_argument('source', metavar='IMAGE_FILE',
    help='Image file to convert to bitplanes')
parser.add_argument('out', metavar='BITPLANES_FILE',
    help='File to write bitmaps to')

args = parser.parse_args()

source_file = args.source
bit_depth = args.depth
verbose = args.verbose

img = Image.open(source_file)
if img.mode != 'P':
    print 'Image is not palette-based'
    sys.exit(1)

if img.palette.mode != 'RGB':
    print 'Unexpected palette mode:', img.palette.mode
    sys.exit(1)

number_of_colors = len(img.palette.palette) / 3
if verbose:
    print 'Palette size:', number_of_colors
if not bit_depth:
    bit_depth = int(math.log(number_of_colors - 1) / math.log(2)) + 1
    if verbose:
        print 'Detected bit depth:', bit_depth

palette = []
for color_index in range(min(number_of_colors, 1 << bit_depth)):
    r, g, b = [ord(c) for c in img.palette.palette[color_index * 3:(color_index + 1) * 3]]
    rgb = ((r >> 4) << 8) | ((g >> 4) << 4) | (b >> 4)
    palette.append(rgb)

width, height = img.size
if (width & 7) != 0:
    print 'Width is not divisable by 8:', width
    sys.exit(1)

byte_width = (width + 7) // 8

if verbose:
    print 'Image width: %d pixels = %d bytes. Height: %d pixels' % (
        width, byte_width, height)

bitplanes = [array('c') for _ in xrange(bit_depth)]

for row in xrange(height):
    for byte in xrange(byte_width):
        planes = [0] * bit_depth
        for bit in xrange(8):
            palette_index = img.getpixel((byte * 8 + 7 - bit, row))
            for plane_index in range(bit_depth):
                planes[plane_index] |= ((palette_index >> plane_index) & 1) << bit
        for plane_index in range(bit_depth):
            bitplanes[plane_index].append(chr(planes[plane_index]))

if args.separate:
    for plane_index in range(bit_depth):
        with open(args.out % (plane_index + 1), 'wb') as out:
            write_bitplane(out, plane_index)
else:
    with open(args.out, 'wb') as out:
        write_interleaved(out)

if args.copper:
    with open(args.copper, 'w') as out:
        write_copper(out)
