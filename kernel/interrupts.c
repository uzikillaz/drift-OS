#include <stdint.h>

struct IDTEntry {
    uint16_t offset_low;
    uint16_t selector;
    uint8_t ist;
    uint8_t type_attr;
    uint16_t offset_mid;
    uint32_t offset_high;
    uint32_t zero;
};

struct IDTEntry idt[256];

struct IDTR {
    uint16_t size;
    uint64_t offset;
} __attribute__((packed));

void init_interrupts(void) {
    // Fill IDT entries (e.g., for IRQ0-15)
    for (int i = 0; i < 256; i++) {
        // Set offset to ISR handler, selector 0x08 (code seg), type 0x8E (interrupt gate)
    }

    struct IDTR idtr = { .size = sizeof(idt) - 1, .offset = (uint64_t)idt };
    asm volatile("lidt %0" : : "m"(idtr));
    asm("sti");  // Enable interrupts
}

// Example ISR
void isr_handler(void) {
    // Handle, send EOI to PIC
    asm("outb $0x20, $0x20");
}
