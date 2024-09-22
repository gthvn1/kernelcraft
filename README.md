# Kernel Craft

<img align="left" src="images/kernelcraft.png" alt="KernelCraft Project Illustration" width="200"/>

KernelCraft is an exciting journey into the hidden world of computers. Just like explorers of the past, we set out to discover the secrets inside the heart of modern systems—the kernel. This project will build a custom Linux kernel, create a root filesystem using Buildroot, and use QEMU to test and experiment with new device drivers.

Our mission is to understand how virtual devices, block drivers, and Virtio work together to make everything function. Through each experiment, we will learn step by step how these parts come alive, shaping the way computers communicate with the world.

Join us in this adventure, where knowledge is gained through hands-on exploration, and the world of technology becomes our playground.

---

## Steps

### build a linux kernel
```bash
mkdir linux/build
cp linux-config linux/build/.config
cd linux/
make O=build oldconfig
make O=build -j 8
```
### build qemu
```bash
mkdir qemu/build
cd qemu/build
../configure --target-list=x86_64-softmmu
make -j 8
```
### build a rootfs using buildroot

**TODO**

### build a hello world kernel module

**TODO**

## Notes

- We provide an OCaml script just for fun but you can use `boot.sh`
- We are using a fork of linux, qemu and buildroot. We are on the master branch
but not uptodate. Check our repo to see SHA1.
- **linux** and **buildroot** are using Kconfig so both can be configured using `make menuconfig`
    - See `steps`
- **qemu** is configured to only build x86_64.
    - See `steps`

## Status

- Currently we are able to boot and get a prompt on serial
- Next step, add a kernel module.
