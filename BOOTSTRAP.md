# Bootstrap dependency tracking

Every package that ships in the final rootfs image is self-hosted (see
`apko/los-angeles-linux.yaml` -- Track A is empty). This file tracks the
other layer: the build-time dependencies (`environment.contents.packages` in
each `packages/*.yaml`) that melange still resolves from
`https://packages.wolfi.dev/os` (the `BOOTSTRAP_REPO` fallback in `Makefile`)
rather than our own repo, because they haven't been self-hosted yet.

`make build-package` already prefers our own `packages-out` over the Wolfi
fallback (see that target's comment in `Makefile`) -- once a package below is
self-hosted, every *other* recipe that lists it as a build dependency picks
up our copy automatically, no further wiring needed.

Check a box once a package builds via `make build-package PKG=<name>` and a
recipe that depends on it during `environment.contents.packages` no longer
needs the Wolfi fallback for that name (confirm via that package's own build
log: `installing <name> (<our-epoch>)`, not Wolfi's).

## Already reachable from our own repo (no new work, just Phase 0 wiring)

These are subpackages of software we already self-host at runtime; other
recipes' build environments just weren't looking at our repo before Phase 0.

- [x] `wolfi-baselayout` (`packages/wolfi-baselayout.yaml`)
- [x] `busybox` (`packages/busybox.yaml`)
- [x] `ca-certificates-bundle` (`packages/ca-certificates.yaml`)
- [x] `glibc-2.44`, `glibc-2.44-dev`, `glibc-2.44-locale-posix`, `glibc-iconv`, `ld-linux-2.44` (`packages/glibc-2.44.yaml`)
- [ ] `util-linux-dev` (`packages/util-linux.yaml` -- confirm no recipe still needs a newer subpackage split first)
- [ ] `dbus-dev` (`packages/dbus.yaml`)
- [ ] `systemd-dev`, `systemd-boot`, `systemd-systemctl`, `fstrim` (`packages/systemd.yaml`)
- [ ] `openssh-client`, `openssh-server`, `openssh-sftp-server` (`packages/openssh.yaml`)

## Phase 1 -- GNU toolchain (highest leverage; do first)

Needed to build almost everything else. `gcc` must be built against our own
`glibc-2.44` (already self-hosted), so this phase couldn't start before this
session's work.

- [ ] `binutils`
- [ ] `gcc` (expect this one to need `apko/self-hosted.yaml`-style handling for
      transitive-edge pin failures, same as `wolfi-baselayout` -- see that
      file's comment for the pattern)
- [ ] `make`
- [ ] `m4`
- [ ] `bison`
- [ ] `flex`
- [ ] `gperf`
- [ ] `patch`
- [ ] `texinfo`
- [ ] `autoconf`
- [ ] `automake`
- [ ] `libtool`
- [ ] `pkgconf`

## Phase 2 -- *-dev header/library packages

- [ ] `openssl` / `openssl-*-dev`
- [ ] `zlib` / `zlib-dev`
- [ ] `ncurses` / `ncurses-dev`
- [ ] `pcre2-dev`
- [ ] `sqlite-dev`
- [ ] `libselinux` / `libselinux-dev`
- [ ] `libcap` / `libcap-dev` / `libcap-ng-dev`
- [ ] `elfutils-dev`
- [ ] `libarchive` / `libarchive-dev`
- [ ] `expat-dev`
- [ ] `audit-dev`
- [ ] `curl` / `curl-dev`
- [ ] `cryptsetup-dev`
- [ ] `iptables-dev`
- [ ] `nftables-dev`
- [ ] `kmod` / `kmod-dev`
- [ ] `libidn2-dev`
- [ ] `gettext` / `gettext-dev`
- [ ] `libmicrohttpd-dev`
- [ ] `libmnl-dev`
- [ ] `libx11-dev`
- [ ] `libsm-dev`
- [ ] `libtirpc-dev`
- [ ] `xz` / `xz-dev`
- [ ] `python3` / `python3-dev`
- [ ] `perl`
- [ ] `lua5.3` / `lua5.3-dev` / `lua5.3-lzlib`
- [ ] `meson`
- [ ] `ninja`
- [ ] `cmake`
- [ ] `db` / `db-dev`
- [ ] `libbpf` / `libbpf-dev`
- [ ] `libseccomp` / `libseccomp-dev`
- [ ] `linux-pam` / `linux-pam-dev`
- [ ] `libedit-dev`
- [ ] `libeconf-dev`
- [ ] `libgcrypt-dev` / `libgpg-error-dev`
- [ ] `attr-dev` / `acl-dev` / `libacl1`
- [ ] `valgrind-dev`
- [ ] `gawk`, `findutils`, `gnutar`, `rsync`, `wget` (used by `make check`/gnulib-bootstrap in a few recipes -- confirm whether these need self-hosting or are only ever needed transiently in a sandbox that's discarded)

## Phase 3 -- builder image tooling (`docker/builder/Dockerfile`)

Blocked on Phase 1/2 (needs a self-hosted toolchain to build these against).

- [ ] `grub`, `grub-bios`, `grub-efi`
- [ ] `xorriso`
- [ ] `squashfs-tools`
- [ ] `qemu-system-x86_64`, `qemu-img`
- [ ] `mtools`, `sgdisk`, `sfdisk`
- [ ] Linux kernel (replaces Alpine's `linux-lts`) -- build from source via melange
- [ ] initramfs generation (replaces Alpine's `mkinitfs`) -- Alpine-specific
      approach, likely needs reimplementing rather than forking

## Phase 4 -- melange and apko themselves (lowest priority)

Currently copied as prebuilt binaries from
`cgr.dev/chainguard/wolfi-base:latest` in `docker/builder/Dockerfile`. Never
ship in the final image; building from source needs a self-hosted Go
toolchain first (its own bootstrap-seed problem, since Go bootstraps from an
older prebuilt Go release).

- [ ] Go toolchain
- [ ] `melange` (built from https://github.com/chainguard-dev/melange)
- [ ] `apko` (built from https://github.com/chainguard-dev/apko)

## Layer 3: the unavoidable seed

Phase 1 needs an *existing* C compiler to build our first self-hosted `gcc`
with -- currently Wolfi's `build-base` (gcc), pulled the same way every other
recipe pulls its build deps. There is no way around needing some external
seed compiler to bootstrap the first one; every real distro (Alpine, Gentoo,
LFS) has this same problem and documents it rather than hiding it. The
honest target here is "every compiler after the first one is self-hosted,"
not "zero external bytes ever."
