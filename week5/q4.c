#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>


#define READING   0x01    0b0000 0001
#define WRITING   0x02    0b0000 0010
#define AS_BYTES  0x04    0b0000 0100
#define AS_BLOCKS 0x08    0b0000 1000
#define LOCKED    0x10    0b0001 0000

a)
device = (READING|AS_BYTES|LOCKED)
0000 0001
0000 0100
0001 0000
------------
0001 0101

b) 
device = (WRITING|AS_BLOCKS|LOCKED)

c) device = device | LOCKED
0001 0101
0001 0000
---------
0001 0101

d) device = device &~ LOCKED
0001 0101
1110 1111
----------
0000 0101

e) device = (device & ~READING) | WRITING

f) device = device ^ (READING | WRITING)
0001 0101
0000 0011
----------
0001 0110