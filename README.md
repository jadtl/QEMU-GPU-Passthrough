# WindowsQEMU

**Personal [QEMU](https://www.qemu.org/) Windows virtual machine**
## Features
- Virtual RAID for physical disk boot [[Reference]](https://lejenome.tik.tn/post/boot-physical-windows-inside-qemu-guest-machine)
- CPU cores isolation [[Reference]()]
- Graphics card PCI passthrough via OVMF [[Reference]](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF)
- Spice server and IVShMem device to use [LookingGlass](https://github.com/gnif/LookingGlass) [[Reference]](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Using_Looking_Glass_to_stream_guest_screen_to_the_host)
- Audio passthrough using [Scream](https://github.com/duncanthrax/scream) with IVShMem [[Reference]](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Adding_the_IVSHMEM_device_to_use_Scream_with_IVSHMEM)

## Usage

This is a **personal script**, thus only meant to be read and adapted for your own use case, reading the references above should help in doing so.

Used setup for reference: **Arch Linux on i7 7700K [4 cores, 8 threads], 32GB, GTX 970**

## License
[MIT](https://choosealicense.com/licenses/mit/)