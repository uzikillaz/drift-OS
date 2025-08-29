#include <stdint.h>

uint32_t* framebuffer;
uint32_t width, height, pitch;

void init_gop(void) {
    // From UEFI, get GOP mode
    // Set mode, get FrameBufferBase
    width = gop->Mode->Info->HorizontalResolution;
    height = gop->Mode->Info->VerticalResolution;
    pitch = 4 * gop->Mode->Info->PixelsPerScanLine;
    framebuffer = (uint32_t*)gop->Mode->FrameBufferBase;
}

void put_pixel(int x, int y, uint32_t color) {
    if (x >= 0 && x < width && y >= 0 && y < height) {
        framebuffer[y * (pitch / 4) + x] = color;
    }
}
