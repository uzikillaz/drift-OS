#include <efi.h>
#include <efilib.h>

EFI_STATUS EFIAPI efi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable) {
    InitializeLib(ImageHandle, SystemTable);
    Print(L"drift-OS Bootloader\n");

    // Load kernel from file
    EFI_FILE_HANDLE RootDir, KernelFile;
    EFI_LOADED_IMAGE *LoadedImage;
    EFI_SIMPLE_FILE_SYSTEM_PROTOCOL *FileSystem;
    uefi_call_wrapper(ST->BootServices->HandleProtocol, 3, ImageHandle, &LoadedImageProtocol, (void**)&LoadedImage);
    uefi_call_wrapper(ST->BootServices->HandleProtocol, 3, LoadedImage->DeviceHandle, &FileSystemProtocol, (void**)&FileSystem);
    uefi_call_wrapper(FileSystem->OpenVolume, 2, FileSystem, &RootDir);
    uefi_call_wrapper(RootDir->Open, 5, RootDir, &KernelFile, L"kernel.elf", EFI_FILE_MODE_READ, 0);

    UINTN KernelSize = 0;
    uefi_call_wrapper(KernelFile->SetPosition, 2, KernelFile, 0);
    uefi_call_wrapper(KernelFile->GetInfo, 4, KernelFile, &FileInfoGuid, &KernelSize, NULL);
    uefi_call_wrapper(ST->BootServices->AllocatePool, 3, EfiLoaderData, KernelSize, (void**)&KernelBuffer);
    uefi_call_wrapper(KernelFile->Read, 3, KernelFile, &KernelSize, KernelBuffer);

    // Exit boot services and jump to kernel
    EFI_MEMORY_DESCRIPTOR *MemMap = NULL;
    UINTN MapSize = 0, MapKey, DescriptorSize;
    UINT32 DescriptorVersion;
    uefi_call_wrapper(ST->BootServices->GetMemoryMap, 5, &MapSize, MemMap, &MapKey, &DescriptorSize, &DescriptorVersion);
    uefi_call_wrapper(ST->BootServices->AllocatePool, 3, EfiLoaderData, MapSize, (void**)&MemMap);
    uefi_call_wrapper(ST->BootServices->GetMemoryMap, 5, &MapSize, MemMap, &MapKey, &DescriptorSize, &DescriptorVersion);
    uefi_call_wrapper(ST->BootServices->ExitBootServices, 2, ImageHandle, MapKey);

    // Jump to kernel entry (assuming at 0x100000)
    typedef void (*KernelEntry)(void);
    KernelEntry entry = (KernelEntry)0x100000;
    entry();

    return EFI_SUCCESS;
}
