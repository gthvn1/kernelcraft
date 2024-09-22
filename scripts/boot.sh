#!/bin/bash

./qemu/build/qemu-system-x86_64 \
    -enable-kvm \
    -cpu host \
    -kernel linux/build/arch/x86_64/boot/bzImage \
    -append "console=ttyS0  root=/dev/vda devtmpfs.mount=1" \
    -drive format=raw,file=buildroot/output/images/rootfs.ext2,if=virtio \
    -m 1024M
