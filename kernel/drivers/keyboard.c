#include <stdint.h>

#define PS2_DATA 0x60
#define PS2_STATUS 0x64

void keyboard_handler(void) {
    uint8_t scancode = inb(PS2_DATA);
    // Process scancode, update key states
}

void init_keyboard(void) {
    // Set IRQ1 handler to keyboard_handler
    // Enable scanning (cmd 0xF4)
}
