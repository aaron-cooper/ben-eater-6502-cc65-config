# ben-eater-6502-cc65-config

Config and short tutorial for compiling C code (and assembly) for Ben Eater's
6502 computer.

## Prerequisites
This repo is meant to be used with the [cc65 development package](https://cc65.github.io/).
Check out their ["getting started"](https://cc65.github.io/getting-started.html) page
for instructions on how to install.

If you choose to use my `compile.sh` script, you'll need bash, or something that
can run bash scripts. 

## What This Repo Includes
This repo is mainly useful as a starting point for writing C or assembly for Ben
Eater's 6502 computer. It includes a few files that will configure the compiler
to produce machine code that's compatible with the 6502 computer, so that you
can hit the ground running.

### `custom.cfg`
This file provides information to the compiler (or rather the linker) about the
layout of our ROM and RAM, and where the machine code that it generates should
be placed. When linking your code, you'll need to provide this file with the
`-C` flag. For an in-depth explanation of the contents of this file, check out
the [Configuration Files](https://cc65.github.io/doc/ld65.html#s5) section of
the ld65 documentation.

### `crt0.s`
This file contains the initialization code that runs when you reset the 65c02.
This is the code that'll initialize the environment (required for some standard
library functions like `malloc`) and call your `main` function.

This file also contains code that runs once your `main` function exits (although
this code is essentially just an infinite loop).

This file is included in the repo for reference, but it's actually baked into
`custom.lib` which is where the linker accesses it.

### `custom.lib`
This file is a custom version of `none.lib` provided by cc65. It contains all
the code that makes your C code work. You need to provide it to the linker.

### `vectors.s`
This file contains the six bytes that'll be positioned at addresses
0xFFFA-0xFFFF, that is, the vector locations that the 65c02 uses to find your
reset code and interrupt handlers. If you wish to add a non-maskable interrupt
handler, or a interrupt request handler, you'll need to modify this file. You'll
need to assemble this file and provide the resulting `.o` file to the linker.

### `compile.sh`
An unsophisticated script for compiling your code. If your program has a fairly
basic layout, this should work for you. See the next section for an explanation
on how to use it.

## How to Compile a C Program
### Using `compile.sh`:
1. Place `compile.sh`, `custom.cfg`, `vectors.s`, and `custom.lib` into the root
of your project.

2. Write your C program.

3. Open `compile.sh` and find the line containing `C_FILES=()`, then put a
space-separated list of all your `.c` files between the parentheses.

4. Find the line containing `ASM_FILES=()` and put a space-separated list of
all of your `.s` files (not including `vectors.s`)

5. Open your bash/bash compatible shell, and `cd` into the root of your project.

6. Run the script with `./compile.sh`. The prior to running the script for the
first time, you may need to run `chmod u+x compile.sh` to put the file in
execution mode.

Your code should now be compiled.

### Manually:
1. Place `compile.sh`, `custom.cfg`, `vectors.s`, and `custom.lib` into the root
of your project.

2. Write your C program.

3. For each of your `.c` files, run `cc65 --cpu 65c02 <your .c file>`. This will
translate your C code to 6502 assembly and store it in a `.s` file with the same
root name as your `.c` file.

4. For each of the `.s` files, including the ones generated during the previous
step as well as `vectors.s`, run `ca65 --cpu 65c02 <your .s file>`. This will 
generate an object file (`.o`) with the same root name as your `.s` file.

5. Run this command: `ld65 -C custom.cfg <all .o files> custom.lib`.

### After Compilation
Once you've finished compiling your code, you should have a file named `a.out`.
This file should be exactly 32'768 bytes long. You can now use your eeprom
programmer to write this file to your eeprom.

## Using Assembly
You may wish to call assembly sub-routines from within your C program,
especially when interacting the LCD display included in the kit. If this is
something you'd like to do, you can check out 
[this section](https://cc65.github.io/doc/customizing.html#s7) of the cc65
documentation which describes how to do so.

If you wish to use this project only for assembly rather than for a C project,
that is possible as well. However, you'll need to make a few adjustments to the
assembly that Ben writes in his video series since this is a different
assembler. As well, since you're using this configuration, the environment
code that cc65 wraps your program in will still be present.

You'll need to make the following changes to any of the assembly that Ben
writes:
- Remove the `.org` instructions
- Remove the vector data at the end of the file, populating the addresses of the
reset and interrupt vectors is handled by `vectors.s`. 
- Rename the `reset` routine to `_main`.
- Add the command `.export _main` somewhere in your file.

To generate the executable that you should write to your EEPROM, you can follow
the steps listed in "How to Compile a C Program".