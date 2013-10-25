#!/usr/bin/env python

#
# Sine table generator by Mathias Olsson
#

import sys
import math
import argparse

masks = {
    'b': 0xff,
    'w': 0xffff,
    'l': 0xffffffff
}

parser = argparse.ArgumentParser(description='Generate a premultiplied integer only sine table')
parser.add_argument('nr_of_values', type=int, help='Number of values to create')
parser.add_argument('premultiplier', type=int, help='Premultiplier to use')
parser.add_argument('offset', type=int, help='Offset to use')
parser.add_argument('out', help='File to write sine table to')
parser.add_argument('--size', help='Size per value: b, w, or l', action="store")
parser.add_argument('--f1', help='Use y = ((sin(x) + 1) / 2) ^ a', action="store_true")
parser.add_argument('--post', type=int, help='Multiply result by this value', default=1)

args = parser.parse_args()

output_file = args.out
nr_of_values = args.nr_of_values
premultiplier = args.premultiplier
postmultiplier = args.post
offset = args.offset
f1 = args.f1

type = ''

if args.size:
    type = args.size
else:
    if (premultiplier + offset) * postmultiplier < 2**8:
        # Should fit in a byte
        type = 'b'
    elif (premultiplier + offset) * postmultiplier < 2**16:
        # Should fit in a word
        type = 'w'
    elif (premultiplier + offset) * postmultiplier < 2**32:
        # Should fit in a longword
        type = 'l'
    else:
        print 'Result will be to large. Try with a smaller premultiplier or smaller offset.'
        sys.exit(1)
mask = masks[type]

two_pi = math.pi * 2;
increment = two_pi / nr_of_values
current = 0
counter = 0

newline_counter = 0;

with open(output_file, 'w') as out:
    while counter < nr_of_values:
        if f1:
            current_sine = math.pow(((math.sin(current) + 1) / 2), 3) * premultiplier + offset
        else:
            current_sine = math.sin(current) * premultiplier + offset
        current_int = (int(round(current_sine)) * postmultiplier) & mask
        if newline_counter == 0:
            out.write('\tdc.%s %d' % (type, current_int))
        else:
            out.write(', %d' % current_int)
        newline_counter += 1
        if newline_counter == 8:
            newline_counter = 0
            out.write('\n')
        counter += 1
        current += increment
    out.write('\n')

print 'Generated', nr_of_values, 'sine values to the file', output_file
