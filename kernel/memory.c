#include <stdint.h>

#define PAGE_SIZE 4096
#define MEMORY_SIZE 0x100000000ULL  // Assume 4GB, detect from UEFI memmap

uint8_t bitmap[MEMORY_SIZE / PAGE_SIZE / 8];

void init_memory(void) {
    // Initialize bitmap to free (0)
    for (size_t i = 0; i < sizeof(bitmap); i++) bitmap[i] = 0;
    // Mark kernel pages as used (based on linker symbols)
}

uintptr_t allocate_frame(void) {
    for (size_t i = 0; i < sizeof(bitmap); i++) {
        if (bitmap[i] != 0xFF) {
            for (size_t j = 0; j < 8; j++) {
                if (!(bitmap[i] & (1 << j))) {
                    bitmap[i] |= (1 << j);
                    return (i * 8 + j) * PAGE_SIZE;
                }
            }
        }
    }
    return 0;  // Out of memory
}

// Setup paging: Identity map first 4GB, etc. (Use CR3, PML4, etc.)
void setup_paging(void) {
    // Implement PML4, PDPT, PD, PT setup here
}
