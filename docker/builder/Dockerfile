# Builder toolchain image: melange + apko + everything needed to assemble
# a bootable disk image and boot-test it in QEMU.
#
# melange/apko are pulled from Wolfi (they're statically linked Go binaries,
# so they run fine on the Alpine/musl base below) rather than Wolfi itself,
# because Wolfi's own repo has no bootloader/kernel/squashfs packages at all
# (it's a container-only "undistro" -- containers use the host's kernel) --
# Alpine's repo has all of those.
#
# linux-lts + mkinitfs supply the KERNEL and INITRAMFS baked into every
# built image (see image/stage-kernel.sh): the kernel/modules are userspace
# libc-agnostic (modules don't link against glibc or musl), and mkinitfs's
# generated init script is a generic switch_root into whatever /sbin/init
# exists in the real root (verified against its actual source) -- so an
# Alpine/musl-built kernel+initramfs booting into our glibc/systemd rootfs
# is standard practice, not a hack. grub (BIOS+EFI) is used the same way:
# run from here against the target rootfs's /boot, not installed as an apk
# package inside that rootfs.

FROM cgr.dev/chainguard/wolfi-base:latest AS tools
RUN apk add --no-cache melange apko

FROM alpine:3.20

RUN apk add --no-cache \
      bash \
      curl \
      ca-certificates \
      docker-cli \
      util-linux \
      e2fsprogs \
      dosfstools \
      mtools \
      sgdisk \
      sfdisk \
      grub \
      grub-bios \
      grub-efi \
      xorriso \
      squashfs-tools \
      qemu-system-x86_64 \
      qemu-img \
      rsync \
      linux-lts \
      mkinitfs \
      tar
      # ^ real GNU tar, not busybox's tar applet: busybox tar fails to
      #   recreate device nodes (/dev/null etc.) from `docker export`'s
      #   archive format, even as root with full capabilities.

COPY --from=tools /usr/bin/melange /usr/bin/melange
COPY --from=tools /usr/bin/apko /usr/bin/apko

WORKDIR /work
