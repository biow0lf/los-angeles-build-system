#!/bin/sh
# Headless QEMU boot of the produced disk image; the end-to-end MVP gate.
# Success signal: los-angeles-linux-base's la-linux-boot-marker.service
# (WantedBy=multi-user.target) echoes LA-LINUX-BOOT-OK to /dev/console,
# which the grub.cfg kernel cmdline (console=ttyS0) routes to this serial
# log. Uses KVM acceleration when /dev/kvm is available (passed through by
# the Makefile's KVM_DEVICE), falls back to TCG software emulation
# otherwise -- don't hard-depend on KVM (the macOS dev host has none).
set -eu
cd "$(dirname "$0")/.."

IMG="${1:-work/la-linux.img}"
LOG=work/boot.log
TIMEOUT=120

ACCEL=tcg
CPU=max
[ -e /dev/kvm ] && ACCEL=kvm && CPU=host
# -cpu max: Wolfi/Chainguard build glibc & co. for a modern x86-64
# microarchitecture baseline (SSE4.x and beyond), which crashes as an
# illegal instruction under QEMU TCG's conservative default CPU model
# ("qemu64"). -cpu max exposes everything TCG can emulate; -cpu host
# passes through the real CPU's features under KVM.

timeout "$TIMEOUT" qemu-system-x86_64 \
  -m 2048 -smp 2 \
  -accel "$ACCEL" -cpu "$CPU" \
  -drive file="$IMG",format=raw,if=virtio \
  -display none -serial mon:stdio \
  -no-reboot \
  > "$LOG" 2>&1 || true

if grep -q "LA-LINUX-BOOT-OK" "$LOG"; then
  echo "boot smoke test: PASS"
  exit 0
fi

echo "boot smoke test: FAIL (marker not seen within ${TIMEOUT}s) -- last 60 lines of $LOG:"
tail -n 60 "$LOG"
exit 1
