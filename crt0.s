;from https://cc65.github.io/doc/customizing.html#s3 with small edits

.export _init, _exit
.import _main

.export __STARTUP__ : absolute = 1 ;Mark as startup
.import __RAM_START__, __RAM_SIZE__ ;Linker generated

.import zerobss, initlib, donelib, copydata

.include "zeropage.inc"

.segment "STARTUP"

_init:
    ldx #$FF ; Initialize stack pointer to $01FF
    txs
    cld ;clear decimal mode

    lda #<(__RAM_START__ + __RAM_SIZE__) ; Initialize cc65 stack pointer
    sta sp
    lda #>(__RAM_START__ + __RAM_SIZE__)
    sta sp+1

    jsr zerobss
    jsr copydata
    jsr initlib
    jsr _main
_exit:
    pha
    jsr donelib
    pla
    nop
    bra _exit