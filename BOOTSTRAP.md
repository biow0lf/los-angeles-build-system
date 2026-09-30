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

- [x] `binutils` (`packages/binutils.yaml`) -- forked verbatim from Wolfi's
      recipe, no deviations needed. Unlike `wolfi-baselayout`, this one did
      *not* need `apko/self-hosted.yaml`-style handling: that mechanism is
      specific to `apko lock`'s rootfs-want resolution, and binutils is a
      build-time-only tool that never appears in `apko/los-angeles-linux.yaml`.
      What actually matters here is melange's own build-environment
      installer (a different code path, driven by the Makefile's
      `--repository-append` order) -- confirmed via `make build-package
      PKG=binutils`'s log: `installing wolfi-baselayout (20230201-r31)`,
      `installing glibc-2.44 (2.44-r7)`, `installing glibc-2.44-dev
      (2.44-r7)`, all our own epochs, pulled from `PUBLISHED_REPO`.
- [x] `gcc` (`packages/gcc.yaml`) -- forked verbatim from Wolfi's recipe, no
      deviations needed in the end. The `apko/self-hosted.yaml`-style
      handling anticipated here never applied (that mechanism is specific
      to `apko lock`'s rootfs-want resolution; gcc is build-time-only,
      like binutils). What *did* surface, self-hosting gcc, was an
      unrelated real bug: `packages/gcc/` (this package's own patch
      directory) made every OTHER package's build think it was sitting in
      a combined gcc+binutils source tree, since nothing scoped a
      package's build-time workspace to just its own aux directory --
      see the Makefile's `SOURCE_DIR_FLAG` fix and
      `packages/.empty-source-dir/`. Confirmed end-to-end via CI:
      `discover` -> all 21 package builds -> `index` -> `boot-test` ->
      `publish`, all green.
- [x] `make` (`packages/make.yaml`) -- forked verbatim except
      `bootstrap-args: --skip-po` (avoids the same translationproject.org
      hang as coreutils, see that file) plus `--disable-nls` (--skip-po
      alone leaves `po/Makefile` trying to build `.gmo` files from `.po`
      files that were never fetched, a hard `make` error, not just a
      slow/unreliable step -- discovered self-hosting make, then applied
      to m4/bison below too).
- [x] `m4` (`packages/m4.yaml`) -- forked verbatim except the same
      `--skip-po` + `--disable-nls` pair as make, for the identical
      reason (also uses `git/gnulib-bootstrap`).
- [x] `bison` (`packages/bison.yaml`) -- forked verbatim except the same
      `--skip-po` + `--disable-nls` pair as make/m4. Also needed
      `pipelines/test/tw/langpackage.yaml` fetched from Wolfi's os repo
      (missing custom pipeline, used by the `bison-lang` subpackage's
      test).
- [x] `flex` (`packages/flex.yaml`) -- forked verbatim, no deviations
      needed (doesn't use `git/gnulib-bootstrap`).
- [x] `gperf` (`packages/gperf.yaml`) -- forked verbatim, no deviations
      needed (uses `./autopull.sh`/`./autogen.sh` rather than
      `git/gnulib-bootstrap`, so the po-fetch issue doesn't apply).
- [x] `patch` (`packages/patch.yaml`) -- forked verbatim except the same
      `--skip-po` + `--disable-nls` pair as make/m4/bison (also uses
      `git/gnulib-bootstrap`), this time added to the built-in
      `autoconf/configure` pipeline's own `opts` field.
- [x] `texinfo` (`packages/texinfo.yaml`) -- forked verbatim, no
      deviations needed.
- [x] `autoconf` (`packages/autoconf.yaml`) -- forked verbatim, no
      deviations needed.
- [x] `automake` (`packages/automake.yaml`) -- forked verbatim except
      adding `automake` itself to `environment.contents.packages` (a
      self-dependency, same shape as busybox/flex/wolfi-baselayout
      elsewhere in this repo): automake's own build rebuilds its bundled
      `doc/amhello` example project via `autoreconf`, which needs the
      versioned `aclocal-1.19` already on PATH -- that binary is only
      produced, not yet installed, later in this same build, so an
      already-installed automake has to be present first.
- [x] `libtool` (`packages/libtool.yaml`) -- forked verbatim (plus its
      `libtool-fix-cross-compile.patch`), no further deviations needed.
- [x] `pkgconf` (`packages/pkgconf.yaml`) -- forked verbatim, no
      deviations needed.

**Phase 1 complete** -- the full GNU toolchain (binutils, gcc, make, m4,
bison, flex, gperf, patch, texinfo, autoconf, automake, libtool, pkgconf)
is now self-hosted.

## `build-base` -- the highest-leverage single fix

- [x] `build-base` (`packages/build-base.yaml`) -- forked verbatim from
      Wolfi's trivial metapackage (epoch bumped 9->10 to avoid an
      exact-tie resolution risk, same reasoning as `wolfi-baselayout`).
      27 of our ~30 recipes list `build-base` in
      `environment.contents.packages` -- since every one of the six
      things it bundles (binutils, gcc, glibc-dev, make, pkgconf,
      wolfi-baselayout) was already self-hosted, publishing our own
      `build-base` immediately stops all 27 recipes from touching Wolfi
      for this one name, no other file needed to change. Verified: a
      rebuild of binutils (using packages-out as the local repo tier)
      now installs `build-base (1-r10)`, ours, not Wolfi's r9.

## Phase 2 -- *-dev header/library packages

- [x] `openssl` / `openssl-*-dev` (`packages/openssl.yaml`) -- forked
      verbatim (plus its FIPS/TLS patches and `ca.cnf`/`openssl.cnf`),
      except the "throw-away canary tests of jitter and non-validated
      fips" step is skipped: its own output is never shipped (`rm -rf`'d
      immediately after in Wolfi's own recipe), and it reproducibly (not
      a flake, seen twice) fails two subtests --
      `75-test_quicapi.t`/`90-test_threads.t` -- that plausibly don't
      tolerate QEMU x86_64-on-Apple-Silicon emulation's timing behavior,
      same category as systemd's `-Dbpf-framework=false`. The *real*
      build's own `make tests` run (same suite, real ./Configure flags)
      passed cleanly, confirming the canary's jitter/fips-specific flags
      were the actual trigger, not the test files themselves.
- [x] `zlib` / `zlib-dev` (`packages/zlib.yaml`) -- forked verbatim (plus
      its `gz_write` patch), no further deviations needed.
- [x] `ncurses` / `ncurses-dev` (`packages/ncurses.yaml`) -- forked
      verbatim, no deviations needed.
- [x] `pcre2-dev` (`packages/pcre2.yaml`) -- forked verbatim, no
      deviations needed.
- [x] `openssf-compiler-options` (`packages/openssf-compiler-options.yaml`)
      -- forked verbatim (a vendored-static-files package, no upstream
      source build at all: gcc/clang hardening spec files and a
      gcc-wrapper script, matching wolfi-baselayout's own vendored-files
      shape). Referenced by gcc.yaml, binutils.yaml, openssl.yaml, and
      others as a build-time dependency.
- [x] `sqlite-dev` (`packages/sqlite.yaml`) -- forked verbatim, no
      deviations needed.
- [x] `gmp-dev` (`packages/gmp.yaml`) -- forked verbatim, no deviations
      needed. Not previously tracked in this checklist even though gcc's
      own recipe lists `gmp-dev` as a build dependency -- an oversight in
      the original Phase 2 audit, caught and fixed this pass.
- [x] `mpfr-dev` (`packages/mpfr.yaml`) -- forked verbatim, no deviations
      needed. Same oversight as gmp above.
- [x] `mpc-dev` (`packages/mpc.yaml`) -- forked verbatim, no deviations
      needed. Same oversight as gmp above.
- [x] `isl-dev` (`packages/isl.yaml`) -- forked verbatim, no deviations
      needed. Same oversight as gmp above -- with this, gcc's own
      `gmp-dev`/`mpfr-dev`/`mpc-dev`/`isl-dev` build deps are now all
      self-hosted too.
- [x] `acl` / `acl-dev` (`packages/acl.yaml`) -- forked verbatim, no
      deviations needed.
- [x] `libcap` / `libcap-dev` (`packages/libcap.yaml`) -- forked
      verbatim, no deviations needed.
- [x] `libcap-ng-dev` (`packages/libcap-ng.yaml`) -- forked verbatim, no
      deviations needed.
- [x] `libgpg-error-dev` (`packages/libgpg-error.yaml`) -- forked
      verbatim, no deviations needed.
- [x] `libgcrypt-dev` (`packages/libgcrypt.yaml`) -- forked verbatim, no
      deviations needed.
- [x] `libedit-dev` (`packages/libedit.yaml`) -- forked verbatim, no
      deviations needed.
- [x] `libeconf-dev` (`packages/libeconf.yaml`) -- forked verbatim, no
      deviations needed (uses `meson/configure`; `meson` itself still
      falls back to Wolfi for now, see below).
- [x] `libmnl-dev` (`packages/libmnl.yaml`) -- forked verbatim (plus its
      `musl-fix-headers.patch`), no further deviations needed.
- [x] `libseccomp-dev` (`packages/libseccomp.yaml`) -- forked verbatim,
      no deviations needed.
- [ ] `attr-dev` (`packages/attr.yaml`) -- forked, but its own inline
      `make check` step reproducibly fails two upstream tests --
      `test/root/getfattr.run` and `test/restore.run` -- that exercise
      trusted/security-namespace xattr operations needing real root-level
      filesystem xattr support the Docker build sandbox's overlayfs
      doesn't provide, unrelated to whether libattr/attr/getfattr/setfattr
      themselves work (they link and install fine). Same category as
      openssl's jitter/fips canary tests. Fixed by narrowing to `make
      check TESTS='test/attr.run'`; not yet re-verified after the fix
      (blocked mid-session by an unrelated host disk-space exhaustion,
      see below).
- [ ] `db` / `db-dev` (`packages/db.yaml`) -- forked verbatim; first
      attempt failed on a Docker build-cache image race (`No such image:
      apko.local/cache:...`), not a recipe issue -- retry pending.
- [ ] `libselinux` / `libselinux-dev` (`packages/libselinux.yaml`) --
      forked verbatim (plus its `swig-4.5-pyunicode.patch`); not yet
      built.
- [ ] `elfutils-dev` (`packages/elfutils.yaml`) -- forked verbatim; not
      yet built.
- [ ] `libarchive` / `libarchive-dev` (`packages/libarchive.yaml`) --
      forked verbatim; not yet built.
- [ ] `expat-dev` (`packages/expat.yaml`) -- forked verbatim; not yet
      built (first attempt failed only due to the host disk-space
      exhaustion below, recipe itself untouched).
- [ ] `audit-dev` (`packages/audit.yaml`) -- forked verbatim (plus its
      two patches); not yet built.
- [ ] `curl` / `curl-dev` (`packages/curl.yaml`) -- forked verbatim; not
      yet built.
- [ ] `cryptsetup-dev` (`packages/cryptsetup.yaml`) -- forked verbatim;
      not yet built.
- [ ] `iptables-dev` (`packages/iptables.yaml`) -- forked verbatim; not
      yet built.
- [ ] `nftables-dev` (`packages/nftables.yaml`) -- forked verbatim; not
      yet built.
- [ ] `kmod` / `kmod-dev` (`packages/kmod.yaml`) -- forked verbatim; not
      yet built.
- [ ] `libidn2-dev` (`packages/libidn2.yaml`) -- forked with the same
      `git/gnulib-bootstrap` `--skip-po` deviation as make/m4/bison/
      patch/grep/findutils (`--disable-nls` was already present in its
      own `./configure` opts); not yet built.
- [ ] `gettext` / `gettext-dev` (`packages/gettext.yaml`) -- forked
      verbatim; not yet built (first attempt failed only due to the host
      disk-space exhaustion below, recipe itself untouched).
- [ ] `libmicrohttpd-dev` (`packages/libmicrohttpd.yaml`) -- forked
      verbatim; not yet built.
- [ ] `libx11-dev` (`packages/libx11.yaml`) -- forked verbatim; not yet
      built.
- [ ] `libsm-dev` (`packages/libsm.yaml`) -- forked verbatim; not yet
      built.
- [ ] `libtirpc-dev` (`packages/libtirpc.yaml`) -- forked verbatim; not
      yet built.
- [ ] `python3` / `python3-dev` (`packages/python-3.13.yaml`) -- forked
      verbatim (Wolfi's own package name is `python-3.13`, not `python3`
      -- it `provides: python3=...` for other recipes to depend on); not
      yet built. Heavy (5 CPU/8Gi hint), many still-Wolfi-fallback deps
      (`openssl-hardened-3.6-dev`, `bzip2-dev`, `tcl-dev`/`tk-dev`, etc).
- [ ] `perl` (`packages/perl.yaml`) -- forked verbatim; not yet built.
- [ ] `lua5.3` / `lua5.3-dev` (`packages/lua5.3.yaml`) -- forked verbatim
      (plus its 3 patches); not yet built.
- [ ] `meson` -- deferred: Wolfi's `meson.yaml` is a generic
      pip-install-based template (`py/pip-build-install`) shared across
      many `py3-*` packages and depends on `samurai` (not `ninja-build`
      -- ninja deliberately doesn't `provide: ninja`, see its own
      comment) plus `py3-supported-build-base`. Needs a self-hosted
      python3 first and more investigation than a plain fork; not
      started.
- [ ] `ninja` / `samurai` -- `packages/ninja-build.yaml` exists at Wolfi
      but deliberately does *not* provide `ninja` (their own comment:
      `samurai` is preferred and installs to a non-conflicting path);
      `samurai` itself not yet fetched/evaluated. Not started.
- [ ] `cmake` -- not yet fetched/evaluated in depth.
- [ ] `libbpf` / `libbpf-dev` (`packages/libbpf.yaml`) -- forked
      verbatim; not yet built.
- [ ] `linux-pam` / `linux-pam-dev` (`packages/linux-pam.yaml`) -- forked
      verbatim (uses `meson/configure`, a melange built-in, distinct from
      the `meson` package itself being unbuilt); not yet built.
- [ ] `valgrind-dev` (`packages/valgrind.yaml`) -- forked verbatim; not
      yet built.
- [ ] `libsepol` (`packages/libsepol.yaml`) -- forked verbatim; not yet
      built (a `libselinux` dependency).
- [ ] `gawk`, `findutils`, `rsync`, `wget` -- all forked verbatim
      (`findutils` needed the same `--skip-po` gnulib-bootstrap fix,
      `gawk`/`wget` needed one upstream patch each); all four failed
      their first attempt only due to the host disk-space exhaustion
      below, recipes themselves untouched -- retry pending.

### Host disk-space exhaustion (2026-09-30, mid-session)

Not a recipe bug: this session's own accumulated `melange:1-<hash>` and
`apko.local/cache:*` Docker images (one new tag per unique
`environment.contents.packages` set, never cleaned up automatically)
grew Rancher Desktop's VM disk (`~/Library/Application
Support/rancher-desktop/lima/0/diffdisk`) to 100G, filling the host's
460Gi boot disk down to 120Mi free and forcing the VM's own filesystem
read-only. Fixed by restarting Rancher Desktop (releases the VM disk
back to a sane state) plus removing all `melange:1-*`/
`apko.local/cache:*` tagged images (51.9GB reclaimed). The build driver
script now prunes those same tags every 3 packages to prevent recurrence
mid-batch. Packages that failed solely because of this (not a recipe
issue) are noted individually above; they get a clean retry once
encountered again.
- [x] `grep` (`packages/grep.yaml`) -- forked verbatim except the same
      `--skip-po` + `--disable-nls` pair as make/m4/bison/patch (also
      uses `git/gnulib-bootstrap`).
- [x] `file` / `libmagic` / `libmagic-dev` (`packages/file.yaml`) --
      forked verbatim, no deviations needed.
- [ ] `gnutar` -- heavier than most (325 upstream cherry-picks in Wolfi's
      recipe, custom `./bootstrap` rather than `git/gnulib-bootstrap`,
      git.savannah.gnu.org flakiness already flagged in Wolfi's own
      recipe). Deferred separately from the simpler batch above.
- [x] `xz` / `xz-dev` (`packages/xz.yaml`) -- forked verbatim, no
      deviations needed (uses `./autogen.sh --no-po4a`, its own upstream
      translation-skip flag, not `git/gnulib-bootstrap`).

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

- [x] Go toolchain (`packages/go.yaml`) -- loosely forked from Wolfi's
      go-1.27.yaml (named plain `go`, not `go-1.27`: we only need one
      stream, not their multi-version scheme), keeping only the two
      generically-useful upstream patches (always-emit-ldflags,
      telemetry-default-off) and dropping the two Chainguard-branding-only
      ones. Modern Go can't bootstrap from C source anymore -- building
      any Go release needs an *already-working* Go (or gccgo) as
      GOROOT_BOOTSTRAP. Per user decision (go.dev binary, not a gccgo
      bootstrap), fetches one official prebuilt release (go1.26.8, direct
      from go.dev, not Wolfi/Alpine) as a one-time seed -- exactly
      parallel to how gcc's first self-hosted build used Wolfi's
      build-base as its one-time seed. Every future Go release bootstraps
      from our own previous build via `PUBLISHED_REPO`, not from go.dev
      again. Verified locally via `make build-package PKG=go`: fetch
      checksum-verified, `make.bash` built successfully using the seed
      ("Building Go cmd/dist using /home/build/bootstrap-seed/go.
      (go1.26.8 linux/amd64)"), producing go-1.27.1-r0.apk and
      go-doc-1.27.1-r0.apk.
- [x] `bubblewrap` (`packages/bubblewrap.yaml`) -- forked verbatim from
      Wolfi; new runtime dependency of `melange` (unprivileged sandboxing
      used by melange's own build pipeline). Needed one missing custom
      test pipeline, `pipelines/test/tw/shell-syntax-check.yaml`, fetched
      from Wolfi. Still pulls `libcap-dev`/`meson` from Wolfi's fallback
      repo (not yet self-hosted themselves -- Phase 2 work).
- [x] `melange` (`packages/melange.yaml`, built from
      https://github.com/chainguard-dev/melange) -- forked from Wolfi with
      one deviation: `go-package: go-1.27` -> `go-package: go` throughout,
      matching our single-stream Go naming. Needed `pipelines/bump.yaml`
      (Wolfi's custom omnibump-based dependency-bump pipeline, used here
      to bump a transitive grpc module for a CVE) fetched from Wolfi;
      confirmed `go/build` is a genuine melange-native built-in pipeline
      (searched Wolfi's entire `pipelines/` tree, no such file exists
      there). Built successfully with our own self-hosted `go` as
      GOROOT -- no gccgo, no external Go binary beyond `go.yaml`'s own
      one-time seed.
- [x] `apko` (`packages/apko.yaml`, built from
      https://github.com/chainguard-dev/apko) -- same `go-package: go`
      deviation as melange. Built successfully with our own self-hosted
      `go`. Note: apko's own test step builds a throw-away image using
      `https://apk.cgr.dev/chainguard` (a live Chainguard repo) to
      exercise apko's general image-build capability -- this is testing
      apko itself, not a build-time dependency of our system, so left
      as-is for now.

## Layer 3: the unavoidable seed

Phase 1 needs an *existing* C compiler to build our first self-hosted `gcc`
with -- currently Wolfi's `build-base` (gcc), pulled the same way every other
recipe pulls its build deps. There is no way around needing some external
seed compiler to bootstrap the first one; every real distro (Alpine, Gentoo,
LFS) has this same problem and documents it rather than hiding it. The
honest target here is "every compiler after the first one is self-hosted,"
not "zero external bytes ever."
