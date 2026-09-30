ENTRY(_start)
SECTIONS
{
    . = 0;
    .text : { *(.text.start) *(.text .text.*) }
    /DISCARD/ : { *(.comment) *(.riscv.attributes) *(.eh_frame*) }
}
