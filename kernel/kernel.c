#include <stdint.h>

extern void init_memory(void);
extern void init_interrupts(void);
extern void init_drivers(void);
extern void init_fs(void);
extern void init_ui(void);
extern void run_apps(void);

void kernel_main(void) {
    // Clear screen or basic output (using GOP later)
    init_memory();
    init_interrupts();
    init_drivers();
    init_fs();
    init_ui();
    run_apps();

    for (;;) { hlt; }  // Infinite loop
}
