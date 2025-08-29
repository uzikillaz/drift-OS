#include <stdint.h>

int mouse_x, mouse_y;

void mouse_handler(void) {
    // Read packets, update position
}

void init_mouse(void) {
    // IRQ12 handler
    // Enable data reporting (0xF4)
    // Detect Intellimouse if needed
}
