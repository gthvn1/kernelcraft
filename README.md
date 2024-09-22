# Kernel Craft

<img align="left" src="images/kernelcraft.png" alt="KernelCraft Project Illustration" width="200"/>

KernelCraft is an exciting journey into the hidden world of computers. Just like explorers of the past, we set out to discover the secrets inside the heart of modern systems—the kernel. This project will build a custom Linux kernel, create a root filesystem using Buildroot, and use QEMU to test and experiment with new device drivers.

Our mission is to understand how virtual devices, block drivers, and Virtio work together to make everything function. Through each experiment, we will learn step by step how these parts come alive, shaping the way computers communicate with the world.

Join us in this adventure, where knowledge is gained through hands-on exploration, and the world of technology becomes our playground.

---

## Steps
- build a linux kernel
- build a rootfs using buildroot
- build qemu

## Notes

We are using the following versions:
- linux-6.10.6
- qemu-9.0.3
- buildroot-2024.02.6

## Status

- Currently we are able to boot and get a prompt on serial
- Next step, add a kernel module.
