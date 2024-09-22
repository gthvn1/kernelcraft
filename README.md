# Kernel Craft

<img align="left" src="images/kernelcraft.png" alt="KernelCraft Project Illustration" width="200"/>

KernelCraft is an exciting journey into the hidden world of computers. Just like
explorers of the past, we set out to discover the secrets inside the heart of
modern systems—the kernel. This project will build a custom Linux kernel, create
a root filesystem using Buildroot, and use QEMU to test and experiment with new
device drivers.

Our mission is to understand how virtual devices, block drivers, and Virtio work
together to make everything function. Through each experiment, we will learn step
by step how these parts come alive, shaping the way computers communicate with the
world.

Join us in this adventure, where knowledge is gained through hands-on exploration,
and the world of technology becomes our playground.

---

# Status

- [x] booting a custom kernel with a custom root filesystem and get a prompt on serial
- [x] build a simple kernel module and see the log in *dmesg*
- [ ] play with a virtio block device
    - [ ] understand how virtqueue are used on both part (*qemu:device* and *linux:driver*)
    - [ ] add a new simple virtio device in qemu
    - [ ] add a new kernel module to interact with the new device
- [ ] extend the device... something else?

# The expedition...

## Build the system

### build the linux kernel
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
- We use BusyBox as init system
- Buildroot already puts everything in `output/`
```bash
cp buildroot-config buildroot/.config
cd buildroot
make oldconfig
make
```

## Boot the system

If you followed the steps in the [build section](https://github.com/gthvn1/kernelcraft#build) you should be able to boot
the kernel using `./scripts/boot.ml` (or `./scripts/boot.sh`).

```bash
./qemu/build/qemu-system-x86_64 \
    -enable-kvm \
    -cpu host \
    -kernel linux/build/arch/x86_64/boot/bzImage \
    -append "console=ttyS0  root=/dev/vda devtmpfs.mount=1" \
    -drive format=raw,file=buildroot/output/images/rootfs.ext2,if=virtio \
    -m 1024M
```

## Build a hello world kernel module
- Taken from [The Linux Kernel Module Programming Guide](https://tldp.org/LDP/lkmpg/2.6/html/x279.html)
- We created a `hello.c` and build it into `driver/block`
- We don't build it as a module because currently our rootfs is built with buildroot and our kernel is built
indenpendently. We did that because we are compiling the kernel many times so it is easier and it is not that
different to built it in the kernel or as a module.


## Implementing a module using Virtio is to create a simple Virtio-based device

*This is a work in progress, steps are defined but are under investigation*.

*... Reflexions ...*

A good first step for implementing a module using Virtio is to create a simple Virtio-based
device, such as a Virtio block device, and then extend it gradually.

Here's an easy path forward:

1. **Understand the Virtio Framework**
The Linux kernel has an extensive **Virtio framework** for handling Virtio devices, which
are widely used in virtualized environments like QEMU. Virtio drivers in Linux communicate
with corresponding Virtio device implementations in QEMU.

Virtio block devices are an excellent entry point because they are simpler than networking
or GPU devices. These devices interact with QEMU's backend through a shared memory
mechanism (Virtqueue) to perform I/O operations.

2. **Modify QEMU to Add a Simple Virtio Device**

QEMU provides interfaces for creating custom Virtio devices. We can start by modifying or
adding a new Virtio device in QEMU.

- **Steps**:
  - Navigate to the **`hw/virtio/`** directory in QEMU’s source code. This directory contains implementations for Virtio devices.
  - Copy the existing `virtio-blk.c` file, which implements a block device.
  - Modify the new file to define a custom device (e.g., `virtio-hello.c`).
  - Add the device to `hw/virtio/Makefile.objs`.
  - Register the new device in `hw/virtio/virtio.c` by adding it to the list of supported Virtio devices.

3. **Create a Simple Linux Kernel Module Using Virtio**

On the kernel side, we will write a module that acts as a Virtio driver for our custom Virtio device.

- **Steps**:
  - In our Linux source tree, navigate to `drivers/virtio`.
  - Create a new file for our module, for example, `hello_virtio.c`.
  - Use the `virtio_driver` structure, which is used to register a Virtio driver with the kernel.
  - Implement our own `probe()` and `remove()` functions to initialize and tear down the device.
  - Our `probe()` function will be called when a Virtio device that matches our driver is detected.
  - Communicate with QEMU's backend using the Virtqueue mechanism.

Example of registering a Virtio driver:

```c
#include <linux/module.h>
#include <linux/virtio.h>

static int hello_virtio_probe(struct virtio_device *vdev) {
    printk(KERN_INFO "Hello Virtio device detected!\n");
    return 0;
}

static void hello_virtio_remove(struct virtio_device *vdev) {
    printk(KERN_INFO "Hello Virtio device removed!\n");
}

static struct virtio_device_id hello_virtio_id_table[] = {
    { VIRTIO_ID_YOUR_DEVICE, VIRTIO_DEV_ANY_ID },
    { 0 },
};

static struct virtio_driver hello_virtio_driver = {
    .driver.name = KBUILD_MODNAME,
    .driver.owner = THIS_MODULE,
    .id_table = hello_virtio_id_table,
    .probe = hello_virtio_probe,
    .remove = hello_virtio_remove,
};

module_virtio_driver(hello_virtio_driver);

MODULE_DEVICE_TABLE(virtio, hello_virtio_id_table);
MODULE_AUTHOR("Me");
MODULE_DESCRIPTION("Simple Virtio Driver");
MODULE_LICENSE("GPL");
```

4. **Launch QEMU with Our Custom Device**

To test our Virtio device, we'll need to launch QEMU with support for the device we
added in step 2. Add the new Virtio device as an option in the QEMU command line when
starting our virtual machine.

For example, if we created a `virtio-hello` device, we would specify it when launching QEMU:

```bash
qemu-system-x86_64 -device virtio-hello-pci
```

5. **Test the Virtio Module in our Kernel**
Once QEMU is running with our new Virtio device, load the Linux kernel with the `hello_virtio.ko` module:

```bash
sudo insmod hello_virtio.ko
```

Check the kernel logs to ensure the device is detected:

```bash
dmesg | grep Virtio
```

### Next Steps:
- **Handle Data I/O**: We can extend this simple Virtio driver to handle data I/O by using Virtqueues to transfer data between the guest (kernel module) and the host (QEMU).
- **Experiment with Different Virtio Types**: After understanding Virtio block, we can try implementing Virtio-net or other types.
- **Performance Tuning**: We can optimize Virtio drivers for better performance as we grow familiar with Virtqueue mechanisms.

# Notes

- We provide an OCaml script just for fun but you can use `boot.sh`
    - to format ocaml file `ocamlformat -i <file.ml>`
- We are using a fork of linux, qemu and buildroot. We are on the master branch
but not uptodate. Check our repo to see SHA1.
- **linux** and **buildroot** are using Kconfig so both can be configured using `make menuconfig`
    - See `steps`
- **qemu** is configured to only build x86_64.
    - See `steps`
