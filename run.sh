#!/bin/zsh

name="Windows"
dir=/home/notneo/BillyGates

# check permissions
if [[ "$UID" != "0" ]]; then
	echo "script: Root permissions are needed to run $name virtual machine" 2>/dev/null
	exit 1
fi

# virtual raid config
if [[ "$1" == "stop" ]]; then
	# stop virtual RAID disk
	mdadm --stop --scan
	losetup --detach-all
    echo "script: The virtual RAID was shutdown" &
	exit 0
else
	# setup virtual RAID disk
	losetup -f $PWD/efi1
	losetup -f $PWD/efi2
	mdadm --build --verbose /dev/md0 --chunk=512 --level=linear --raid-devices=3 /dev/loop0 /dev/nvme1n1p2 /dev/loop1
	sleep 1
	chown $USER /dev/md0

    # check if a passthrough vm is running
    if ps -ef | grep qemu-system-x86_64 | grep -q multifunction=on; then
        echo "script: A GPU passthrough virtual machine is already running!" &
        exit 1
    else

    cp /usr/share/OVMF/x64/OVMF_VARS.fd /tmp/vars.fd

    echo "script: Starting $name virtual machine"

    local -a qemu_params=(
        -name $name,process=$name \
        -machine type=pc,accel=kvm \
        -enable-kvm \
        -m 16G \
        -smp sockets=1,cores=2,threads=2 \
        -cpu host,kvm=off,hv_time,hv_relaxed,hv_vapic,hv_spinlocks=0x1fff \
        -nodefaults \
        -drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/x64/OVMF_CODE.fd \
        -drive if=pflash,format=raw,file=/tmp/vars.fd \
    )

    local -a qemu_rtc_params=(
        -rtc clock=host,base=localtime \
    )

    local -a qemu_source_params=(
        -drive id=system,file=/dev/md0,media=disk,format=raw,cache=none \
        -drive id=files,file=/dev/sda,media=disk,format=raw,cache=none \
        -boot order=c \
    )

    local -a qemu_pass_video=(
        # IVShMem
        -device ivshmem-plain,memdev=ivshmem \
        -object memory-backend-file,id=ivshmem,share=on,mem-path=/dev/shm/looking-glass,size=32M \
        # GPU Passthrough
        -vga none \
        -nographic \
        -serial none \
        -parallel none \
        -device vfio-pci,host=01:00.0,multifunction=on \
    )

    local -a qemu_pass_input=(
        # Looking Glass input
        -spice port=5901,addr=127.0.0.1,disable-ticketing=on \
        # Clipboard
        -device virtio-serial-pci \
        -chardev spicevmc,id=vdagent,name=vdagent \
        -device virtserialport,chardev=vdagent,name=com.redhat.spice.0 \
    )

    local -a qemu_usb_host=(
        -usb \
        # Keyboard
        -usbdevice keyboard \
        # Mouse
        -usbdevice mouse \
        # MIDI Keyboard
        -device usb-host,vendorid=0x2467,productid=0x2018 \
        # Physical mouse/keyboard
        #-device usb-host,vendorid=0x046d,productid=0xc52b\
        #-device usb-host,vendorid=0x046d,productid=0xc083\
    )

    local -a qemu_emulated_sound=(
        # Scream
        -device ivshmem-plain,memdev=scream-ivshmem \
        -object memory-backend-file,id=scream-ivshmem,share=on,mem-path=/dev/shm/scream-ivshmem,size=2M \
    )

    local -a qemu_network=(
        -nic user,model=virtio-net-pci\
    )

    qemu-system-x86_64 "${qemu_params[@]}" \
        "${qemu_rtc_params[@]}" \
        "${qemu_emulated_sound[@]}" \
        "${qemu_source_params[@]}" \
        "${qemu_pass_video[@]}" \
        "${qemu_pass_input[@]}" \
        "${qemu_network[@]}" \
        "${qemu_usb_host[@]}"

    echo "script: $name virtual machine was shutdown"

    exit 0
    fi
fi