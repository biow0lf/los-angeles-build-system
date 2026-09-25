#!/bin/sh
# Runs inside the builder container. Stages the builder's own Alpine-sourced
# kernel + mkinitfs-generated initramfs + modules into $1 (the extracted
# rootfs).
#
# Wolfi ships none of these (it's a container-only "undistro"), but the
# kernel and its modules don't link against glibc or musl -- they're
# userspace-libc-agnostic -- and mkinitfs's generated init script is a
# generic switch_root into whatever /sbin/init exists in the real root
# (confirmed by reading it: `exec switch_root ... $sysroot ... "$KOPT_init"`,
# KOPT_init defaulting to /sbin/init). So an Alpine-built kernel+initramfs
# booting into our glibc/systemd rootfs needs no chroot/nspawn regeneration
# step -- it's already generic.
set -eu

ROOTFS="$1"
KVER=$(ls /lib/modules)

mkdir -p "$ROOTFS/boot" "$ROOTFS/lib/modules"
cp /boot/vmlinuz-lts "$ROOTFS/boot/vmlinuz"
cp /boot/initramfs-lts "$ROOTFS/boot/initramfs"
cp -a "/lib/modules/$KVER" "$ROOTFS/lib/modules/"
echo "$KVER" > "$ROOTFS/boot/kernel-version"

echo "staged kernel $KVER into $ROOTFS/boot"
