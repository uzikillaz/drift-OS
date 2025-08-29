# drift-OS Makefile
# Targets: all (build EFI and kernel), iso (create bootable ISO for Ventoy), qemu (test in QEMU), clean

# Compiler and tools
CC = x86_64-elf-gcc
AS = nasm
LD = x86_64-elf-ld
EFI_CC = gcc  # For GNU-EFI, assuming native gcc
EFI_LD = ld
OBJCOPY = objcopy

# Flags
CFLAGS = -ffreestanding -mno-red-zone -m64 -Wall -Wextra -I$(KERN_DIR)
ASMFLAGS = -f elf64
LDFLAGS = -nostdlib -z max-page-size=0x1000
EFI_CFLAGS = -I$(EFI_INCLUDE) -I$(EFI_INCLUDE)/x86_64 -fpic -ffreestanding -fno-stack-protector -fno-stack-check -fshort-wchar -mno-red-zone -maccumulate-outgoing-args

# GNU-EFI paths (adjust if needed, assumes gnu-efi installed)
EFI_INCLUDE = /usr/include/efi
EFI_LIB = /usr/lib
EFI_CRT_OBJS = $(EFI_LIB)/crt0-efi-x86_64.o
EFI_LDS = $(BOOT_DIR)/link.ld  # Using custom bootloader linker script

# Directories
BOOT_DIR = bootloader
KERN_DIR = kernel
ISO_DIR = iso

# Source files
BOOT_SRC = $(BOOT_DIR)/main.c
KERN_SRC = $(KERN_DIR)/kernel.c $(KERN_DIR)/memory.c $(KERN_DIR)/interrupts.c \
           $(KERN_DIR)/drivers/nvme.c $(KERN_DIR)/drivers/keyboard.c $(KERN_DIR)/drivers/mouse.c \
           $(KERN_DIR)/fs/fat32.c $(KERN_DIR)/ui/gop.c $(KERN_DIR)/ui/window.c \
           $(KERN_DIR)/ui/font.c $(KERN_DIR)/ui/compositor.c \
           $(KERN_DIR)/apps/file_manager.c $(KERN_DIR)/apps/text_editor.c
KERN_ASM = $(KERN_DIR)/entry.asm

# Object files
BOOT_OBJS = $(BOOT_SRC:.c=.o)
KERN_OBJS = $(KERN_SRC:.c=.o) $(KERN_ASM:.asm=.o)

# Targets
.PHONY: all iso qemu clean

all: BOOTX64.EFI kernel.elf

BOOTX64.EFI: $(BOOT_OBJS)
	$(EFI_LD) -nostdlib -znocombreloc -T $(EFI_LDS) -shared -Bsymbolic -L$(EFI_LIB) $(EFI_CRT_OBJS) $^ -o BOOTX64.so -lefi -lgnuefi
	$(OBJCOPY) -j .text -j .sdata -j .data -j .dynamic -j .dynsym -j .rel -j .rela -j .reloc --target=efi-app-x86_64 BOOTX64.so $@

$(BOOT_DIR)/%.o: $(BOOT_DIR)/%.c
	$(EFI_CC) $(EFI_CFLAGS) -c $< -o $@

kernel.elf: $(KERN_OBJS)
	$(LD) -T $(KERN_DIR)/link.ld $(LDFLAGS) $^ -o $@

$(KERN_DIR)/%.o: $(KERN_DIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

$(KERN_DIR)/%.o: $(KERN_DIR)/%.asm
	$(AS) $(ASMFLAGS) $< -o $@

# Create ISO for Ventoy (UEFI bootable)
iso: all
	rm -rf $(ISO_DIR)
	mkdir -p $(ISO_DIR)/EFI/BOOT
	cp BOOTX64.EFI $(ISO_DIR)/EFI/BOOT/
	cp kernel.elf $(ISO_DIR)/
	genisoimage -R -J -o drift-os.iso -eltorito-alt-boot -e EFI/BOOT/BOOTX64.EFI -no-emul-boot $(ISO_DIR)

# Test in QEMU
qemu: iso
	qemu-system-x86_64 -bios /usr/share/ovmf/OVMF.fd -cdrom drift-os.iso -cpu host -m 512M -vga virtio -accel kvm

# Clean build artifacts
clean:
	rm -rf $(BOOT_OBJS) $(KERN_OBJS) BOOTX64.EFI BOOTX64.so kernel.elf drift-os.iso $(ISO_DIR)
