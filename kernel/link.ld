ENTRY(_start)
SECTIONS {
    . = 0xFFFFFFFF80000000;  /* Higher-half kernel base */
    .text : { *(.text) }
    .data : { *(.data) *(.rodata*) }
    .bss : { *(.bss) }
}
