#include <stdint.h>

uint64_t nvme_base;

void init_nvme(void) {
    // PCI scan for class 0x01, subclass 0x08
    // Map BAR0
    // Setup admin queues (from tool code)
    // Create IO queues
}

bool nvme_read(uint64_t lba, void* buffer, uint16_t count) {
    // Send read command (opcode 0x02), use PRPs
    return true;
}
