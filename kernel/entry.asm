section .text
bits 64
global _start
_start:
    cli
    call kernel_main
    hlt
