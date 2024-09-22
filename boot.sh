#!/bin/bash

./qemu-9.0.3/build/qemu-system-x86_64 \
    -enable-kvm \
    -cpu host \
    -kernel linux-6.10.6/arch/x86_64/boot/bzImage \
    -append "console=ttyS0  root=/dev/vda devtmpfs.mount=1" \
    -drive format=raw,file=buildroot-2024.02.6/output/images/rootfs.ext2,if=virtio \
    -m 1024M
