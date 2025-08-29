ENTRY(efi_main)
SECTIONS {
    .text : { *(.text) }
    .data : { *(.data) *(.rodata) }
    .sdata : { *(.sdata) }
    .dynamic : { *(.dynamic) }
    .dynsym : { *(.dynsym) }
    .rel : { *(.rel*) }
    .rela : { *(.rela*) }
}
