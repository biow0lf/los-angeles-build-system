#!/bin/sh
# Runs inside the builder container. Extracts apko's docker-save-format
# output (work/la-linux-oci.tar) directly with tar -- no docker daemon
# involved at all, since it's just tar files: an outer tar containing
# manifest.json + one *.tar.gz per image layer (apko produces a single
# layer for us).
#
# Writes into $1, which must be container-local storage (e.g. under /root),
# NOT the bind-mounted /work tree and NOT a Docker named volume: the rootfs
# contains real device nodes (/dev/null etc.), and in this environment
# (Rancher Desktop/Lima on macOS) only the container's own overlay
# filesystem can actually create them -- both the virtiofs bind mount and
# volume-backed mounts refuse mknod/open with EPERM even running as root
# with full capabilities. A plain container filesystem doesn't have that
# restriction, which is why this whole pipeline (extract, stage-kernel,
# partition/format) runs as one privileged container writing only the
# final regular-file disk image back to /work.
set -eu
cd "$(dirname "$0")/.."

OUT="$1"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

tar -x -f work/la-linux-oci.tar -C "$TMP" manifest.json
LAYERS=$(grep -oE '[a-f0-9]{64}\.tar\.gz' "$TMP/manifest.json")

rm -rf "$OUT"
mkdir -p "$OUT"
for layer in $LAYERS; do
  tar -x -f work/la-linux-oci.tar -C "$TMP" "$layer"
  tar -xz -f "$TMP/$layer" -C "$OUT"
done

echo "extracted rootfs to $OUT"
