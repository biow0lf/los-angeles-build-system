#!/usr/bin/env bash
set -euo pipefail

# Generates the lockfile that `apko build --lockfile=...` (in the
# build-rootfs Makefile target) consumes.
#
# glibc-2.44 (and its family: glibc-2.44-iconv, glibc-2.44-locale-posix,
# ld-linux-2.44) can't be reliably pinned to our own build via a plain
# @local suffix directly in apko/los-angeles-linux.yaml's contents.packages.
# @local fixes the *direct* "glibc-2.44" want to our repo, but apk-tools
# (and everything dynamically linked) also needs so:libc.so.6 satisfied as
# a *separate*, transitive edge -- once the direct want is pinned, the
# solver disqualifies every other glibc revision for that edge (only one
# package may provide the shared "cmd:ldconfig"), then fails outright
# instead of reusing the pinned package to also satisfy it.
#
# Locking a MINIMAL config that wants only the self-hosted @local packages
# (apko/self-hosted.yaml) sidesteps that conflict: nothing else in that
# tiny want-list creates a competing so:-based edge, so @local resolves
# cleanly there, producing correct, checksum-verified lock entries for
# those packages. This script splices those entries over the same-named
# ones in the main config's own (unpinned) lock, so `apko build
# --lockfile=...` is left no other candidate per package name and
# installs ours.
#
# The splice is done with awk, not jq: the builder image is Alpine's
# minimal busybox userland by design (see docker/builder/Dockerfile), and
# apko's own lock output is stable, predictable pretty-JSON (2-space
# indent, one field per line, each contents.packages entry a "      {"
# .. "      }"/"      }," block) -- a dedicated JSON library is not worth
# the extra installed package and the layer-cache churn of adding one.
ARCH="${1:?usage: generate-lockfile.sh <arch> <output-path>}"
OUTPUT="${2:?usage: generate-lockfile.sh <arch> <output-path>}"

main_lock="$(mktemp)"
local_lock="$(mktemp)"
trap 'rm -f "$main_lock" "$local_lock"' EXIT

apko lock apko/los-angeles-linux.yaml --arch "$ARCH" --output "$main_lock"
apko lock apko/self-hosted.yaml --arch "$ARCH" --output "$local_lock"

awk -v localfile="$local_lock" '
  function block_name(block,    n, lines, i, name) {
    n = split(block, lines, "\n")
    for (i = 1; i <= n; i++) {
      if (lines[i] ~ /^        "name": /) {
        name = lines[i]
        sub(/^        "name": "/, "", name)
        sub(/",?$/, "", name)
        return name
      }
    }
    return ""
  }

  BEGIN {
    collecting = 0
    while ((getline line < localfile) > 0) {
      if (!collecting) {
        if (line == "      {") { block = line "\n"; collecting = 1 }
        continue
      }
      block = block line "\n"
      if (line == "      }," || line == "      }") {
        name = block_name(block)
        if (name != "") overrides[name] = block
        collecting = 0
      }
    }
    close(localfile)
  }

  {
    if (!inblock) {
      if ($0 == "      {") { inblock = 1; block = $0 "\n"; next }
      print
      next
    }
    block = block $0 "\n"
    if ($0 != "      }," && $0 != "      }") next

    inblock = 0
    trailing_comma = ($0 == "      },")
    name = block_name(block)
    if (!(name in overrides)) { printf "%s", block; next }

    ov = overrides[name]
    sub(/\n$/, "", ov)
    m = split(ov, ovlines, "\n")
    ovlines[m] = trailing_comma ? "      }," : "      }"
    for (j = 1; j <= m; j++) print ovlines[j]
  }
' "$main_lock" > "$OUTPUT"
