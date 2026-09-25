#!/bin/sh
# Runs inside the builder container, --privileged. Orchestrates the whole
# rootfs-to-disk-image pipeline in one container invocation, writing only
# the final regular-file disk image back to the bind-mounted /work:
#
#   1. extract-rootfs.sh: apko's OCI tar -> container-local rootfs dir
#   2. stage-kernel.sh:    Alpine kernel+initramfs -> that rootfs's /boot
#   3. partition, format, copy the rootfs in, embed GRUB
#
# The rootfs is kept entirely on the container's own overlay filesystem
# (/root/rootfs) rather than a bind mount or Docker volume -- see
# extract-rootfs.sh for why. GPT + BIOS-boot partition + ext4 root,
# BIOS/legacy boot only for MVP (UEFI is a deliberate post-MVP addition).
#
# The root partition IS mounted here (unlike an earlier version of this
# script): grub-install probes the filesystem backing --boot-directory to
# find its device, and that probe fails outright if --boot-directory
# points at a plain directory not yet backed by a real block device (as it
# would if we tried to populate /boot before formatting, then bake
# everything in with `mke2fs -d`) -- "failed to get canonical path of
# 'overlay'". Mounting first, like a normal installer would, is what makes
# grub-install's own device detection work correctly, so we don't have to
# hand-list its boot modules ourselves.
set -eu
cd "$(dirname "$0")/.."

ROOTFS=/root/rootfs
MNT=/mnt/la-linux-root
IMG=work/la-linux.img
SIZE=4G
ROOT_LABEL=la-linux-root
ROOT_UUID=$(cat /proc/sys/kernel/random/uuid)

image/extract-rootfs.sh "$ROOTFS"
image/stage-kernel.sh "$ROOTFS"

rm -f "$IMG"
truncate -s "$SIZE" "$IMG"

sgdisk -Z "$IMG" >/dev/null
sgdisk -n 1:0:+1M -t 1:ef02 -c 1:"BIOS boot" "$IMG" >/dev/null
sgdisk -n 2:0:0   -t 2:8300 -c 2:"$ROOT_LABEL" "$IMG" >/dev/null

LOOPDEV=$(losetup -fP --show "$IMG")
cleanup() {
	umount "$MNT" 2>/dev/null || true
	losetup -d "$LOOPDEV" 2>/dev/null || true
}
trap cleanup EXIT

# losetup -P asks the kernel to scan the partition table, and it does
# (visible in dmesg: "loop1: p1 p2") -- but with no udev running in this
# container to react to that and create the /dev/loop1pN nodes, they never
# appear. Create them ourselves from the info the kernel already exposes
# in sysfs.
LOOPNAME=$(basename "$LOOPDEV")
for part in "/sys/block/$LOOPNAME"/"$LOOPNAME"p*; do
	pname=$(basename "$part")
	devt=$(cat "$part/dev")
	[ -e "/dev/$pname" ] || mknod "/dev/$pname" b "${devt%%:*}" "${devt##*:}"
done

mkfs.ext4 -q -L "$ROOT_LABEL" -U "$ROOT_UUID" "${LOOPDEV}p2"

mkdir -p "$MNT"
mount "${LOOPDEV}p2" "$MNT"
cp -a "$ROOTFS/." "$MNT/"

mkdir -p "$MNT/boot/grub"
sed "s/@ROOT_UUID@/$ROOT_UUID/g" image/grub/grub.cfg.tmpl > "$MNT/boot/grub/grub.cfg"

grub-install --target=i386-pc --boot-directory="$MNT/boot" "$LOOPDEV"

umount "$MNT"

echo "wrote $IMG (root UUID $ROOT_UUID)"
