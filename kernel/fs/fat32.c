#include <stdint.h>

struct FATBootSector {
    // Fields from osdev
};

void init_fs(void) {
    // Read boot sector from NVMe sector 0
    // Calculate first data sector, etc.
}

void read_directory(uint32_t cluster, void* buffer) {
    // Read cluster chain, parse 32-byte entries
    // Handle LFN and 8.3
}

void read_file(uint32_t cluster, void* buffer, uint32_t size) {
    // Follow FAT chain, read sectors via NVMe
}
