# drift-OS Makefile
# Targets: all (build EFI and kernel), iso (create bootable ISO for Ventoy), qemu (test in QEMU), clean

# Compiler and tools
CC = x86_64-elf-gcc
AS = nasm
LD = x86_64-elf-ld
EFI_CC = gcc  # For GNU-EFI, assuming native gcc
EFI_LD = ld

# Flags (adapt as needed, based on osdev standards)
CFLAGS = -ffreestanding -mno-red-zone -m64 -Wall -Wextra
ASMFLAGS = -f elf64
LDFLAGS = -T link.ld -nostdlib -z max-page-size=0x1000

# GNU-EFI paths (install gnu-efi and set these)
EFI_INCLUDE = /usr/include/efi
EFI_LIB = /usr/lib
EFI_CRT_OBJS = $(EFI_LIB)/crt0-efi-x86_64.o
EFI_LDS = $(EFI_LIB)/elf_x86_64_efi.lds

# Directories
BOOT_DIR = bootloader
KERN_DIR = kernel
ISO_DIR = iso

# Targets
all: BOOTX64.EFI kernel.elf

BOOTX64.EFI: $(BOOT_DIR)/main.o
	$(EFI_LD) -nostdlib -znocombreloc -T $(EFI_LDS) -shared -Bsymbolic -L$(EFI_LIB) $(EFI_CRT_OBJS) $^ -o BOOTX64.so -lefi -lgnuefi
	objcopy -j .text -j .sdata -j .data -j .dynamic -j .dynsym -j .rel -j .rela -j .reloc --target=efi-app-x86_64 BOOTX64.so $@

$(BOOT_DIR)/main.o: $(BOOT_DIR)/main.c
	$(EFI_CC) -I$(EFI_INCLUDE) -I$(EFI_INCLUDE)/x86_64 -fpic -ffreestanding -fno-stack-protector -fno-stack-check -fshort-wchar -mno-red-zone -maccumulate-outgoing-args -c $^ -o $@

kernel.elf: $(KERN_DIR)/entry.o $(KERN_DIR)/kernel.o $(KERN_DIR)/memory.o $(KERN_DIR)/interrupts.o $(KERN_DIR)/drivers/nvme.o $(KERN_DIR)/drivers/keyboard.o $(KERN_DIR)/drivers/mouse.o $(KERN_DIR)/fs/fat32.o $(KERN_DIR)/ui/gop.o $(KERN_DIR)/ui/window.o $(KERN_DIR)/ui/font.o $(KERN_DIR)/ui/compositor.o $(KERN_DIR)/apps/file_manager.o $(KERN_DIR)/apps/text_editor.o
	$(LD) $(LDFLAGS) $^ -o $@

$(KERN_DIR)/%.o: $(KERN_DIR)/%.c
	$(CC) $(CFLAGS) -c $^ -o $@

$(KERN_DIR)/entry.o: $(KERN_DIR)/entry.asm
	$(AS) $(ASMFLAGS) $^ -o $@

# Create ISO for Ventoy (bootable UEFI ISO)
iso: all
	mkdir -p $(ISO_DIR)/EFI/BOOT
	cp BOOTX64.EFI $(ISO_DIR)/EFI/BOOT/
	cp kernel.elf $(ISO_DIR)/
	genisoimage -R -J -o drift-os.iso -eltorito-alt-boot -e EFI/BOOT/BOOTX64.EFI -no-emul-boot $(ISO_DIR)

# For xorriso alternative (if genisoimage not available):
# xorriso -as mkisofs -r -o drift-os.iso --grub2-mbr /usr/lib/grub/i386-pc/boot_hybrid.img -partition_offset 16 --mbr-force-bootable -append_partition 2 287fa-287fa iso/EFI/BOOT/BOOTX64.EFI -appended_part_as_gpt -iso_mbr_part_type a2a0d0ebe5b9334487c068b6b72699c7 -c '/boot.catalog' -b 'EFI/BOOT/BOOTX64.EFI' -no-emul-boot $(ISO_DIR)
# But genisoimage is simpler for pure UEFI.

qemu: iso
	qemu-system-x86_64 -bios /usr/share/ovmf/OVMF.fd -cdrom drift-os.iso -cpu host -m 512M -vga virtio -accel kvm

clean:
	rm -rf *.o $(BOOT_DIR)/*.o $(KERN_DIR)/*.o $(KERN_DIR)/drivers/*.o $(KERN_DIR)/fs/*.o $(KERN_DIR)/ui/*.o $(KERN_DIR)/apps/*.o BOOTX64.EFI BOOTX64.so kernel.elf drift-os.iso $(ISO_DIR)
