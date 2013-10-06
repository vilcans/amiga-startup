#!/usr/bin/env python

import sys
from array import array
from PIL import Image

img = Image.open('fivefinger.png')
#img = Image.open('simple.png')
if img.mode != 'P':
    print 'Image is not palette-based'
    sys.exit(1)

if img.palette.mode != 'RGB':
    print 'Unexpected palette mode:', img.palette.mode
    sys.exit(1)

#print 'Palette size:', len(img.palette.data) / 3
bit_depth = 3
number_of_colors = len(img.palette.palette) / 3
palette = []
for color_index in range(number_of_colors):
    r, g, b = [ord(c) for c in img.palette.palette[color_index * 3:(color_index + 1) * 3]]
    rgb = ((r >> 4) << 8) | ((g >> 4) << 4) | (b >> 4)
    print '\tdc.w\t$%x,$%x' % (0x180 + color_index * 2, rgb)
    palette.append(rgb)

width, height = img.size
if (width & 7) != 0:
    print 'Width is not divisable by 16:', width
    sys.exit(1)

byte_width = (width + 7) // 8

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

if False:
    # Write one bitplane per file
    for plane_index in range(bit_depth):
        with open('plane%d.raw' % (plane_index + 1), 'wb') as out:
            bitplanes[plane_index].write(out)
else:
    with open('image.raw', 'wb') as out:
        for row in xrange(height):
            offset = row * byte_width
            for plane_index in range(bit_depth):
                bitplanes[plane_index][offset:offset + byte_width].write(out)
