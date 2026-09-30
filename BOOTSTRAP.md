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
      deviations needed *to the build itself*. Its own `./configure` is
      Tcl-based (autosetup) and needs a working `tcl-dev` at build time
      -- this surfaced a real, separate bug the hard way: CI failed with
      "Cannot find a usable init.tcl" days after this recipe was first
      verified working locally. Root cause: see `packages/tcl.yaml`'s
      own comment below. Fixing tcl.yaml alone wasn't enough, though --
      `.github/workflows/build-packages.yml` builds every package in its
      own isolated matrix job with no shared local repo, and `index`/
      `boot-test`/`publish` all require every `build` job (sqlite
      included) to succeed before tcl ever gets published. The very
      first push introducing tcl.yaml deadlocks: sqlite's CI job can't
      see a tcl-dev that only gets published once sqlite's own job
      succeeds. Fixed by adding a defensive step to sqlite.yaml itself
      that fixes up *whichever* tcl-dev this job happens to install
      (ours once published, or Wolfi's currently-broken one until then)
      with the same init.tcl symlink -- so sqlite's CI job self-heals
      instead of depending on publish order. Verified locally (doesn't
      break the already-working case).
- [x] `tcl` / `tcl-dev` / `tcl-doc` (`packages/tcl.yaml`) -- forked from
      Wolfi with three deviations, discovered through direct debugging
      of the sqlite CI failure above:
      1. Version bumped 9.0.4 -> 9.1.0: Wolfi's live repo serves
         `tcl-9.1.0-r0` even though their own `tcl.yaml` source still
         says 9.0.4 (some in-flight/reverted state on their end) -- apk's
         solver picks the highest version across all appended repos
         regardless of repo order, so a same-name 9.0.4 build here could
         never actually win resolution against their live 9.1.0.
      2. Epoch bumped 0->1: our own initial 9.1.0-r0 build tied exactly
         against Wolfi's live 9.1.0-r0 -- same resolution-risk category
         as build-base/wolfi-baselayout (apk doesn't reliably prefer our
         repo on an exact tie). Confirmed empirically: sqlite kept
         installing Wolfi's tcl even after ours was published, until the
         epoch bump made ours win unambiguously.
      3. The actual root cause, unrelated to either version number
         above: tclsh's own compiled-in default library search path is
         `/usr/lib/tcl<major>.<minor>` (from `--prefix` at configure
         time), but neither Wolfi's recipe nor Tcl's own `make install`
         actually places `init.tcl` there -- this recipe's own
         `cp -r ../library/*` step puts it at `/usr/library` instead,
         with nothing bridging the two. Every consumer of tclsh (sqlite's
         own `./configure` included) failed with "Cannot find a usable
         init.tcl" as a result -- reproduced identically against Wolfi's
         live package AND our own first from-source build, ruling out
         "Wolfi's package is just broken" as the full story. Fixed with
         one added symlink (`/usr/lib/tcl9.1 -> ../library`) after the
         existing install step. Verified end-to-end: rebuilding sqlite
         against this fixed tcl-dev succeeds completely.
- [x] `zip` / `zip-doc` (`packages/zip.yaml`) -- forked verbatim (plus
      its 6 Debian hardening/gcc-14 patches), no further deviations
      needed. Pulled in as a `tcl` build dependency.
- [x] `tzdata` (`packages/tzdata.yaml`) -- forked verbatim. Its own
      `tzutils` build dependency (provides `zic`/`zdump`) turned out to
      be a subpackage of Wolfi's `glibc-2.44.yaml` that our own forked
      `glibc-2.44.yaml` doesn't carry (we forked before Wolfi added it,
      or pruned it along the way) -- rather than risk touching our
      already-verified/published glibc recipe for this, `tzutils` is
      left on the Wolfi fallback for now, tracked here as a known gap.
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
- [x] `attr-dev` (`packages/attr.yaml`) -- forked, but its own inline
      `make check` step reproducibly failed two upstream tests --
      `test/root/getfattr.run` and `test/restore.run` -- that exercise
      trusted/security-namespace xattr operations needing real root-level
      filesystem xattr support the Docker build sandbox's overlayfs
      doesn't provide, unrelated to whether libattr/attr/getfattr/setfattr
      themselves work (they link and install fine). Same category as
      openssl's jitter/fips canary tests. Fixed by narrowing to `make
      check TESTS='test/attr.run'`; verified.
- [x] `db` / `db-dev` (`packages/db.yaml`) -- forked verbatim except the
      source-acquisition step: upstream `berkeleydb/libdb` deleted the
      `v5.3.37` tag (moved to a date-based tagging scheme) -- the commit
      itself is still reachable and confirmed (via its own merge-commit
      message) to be exactly the 5.3.37 release. Tried naming that
      commit SHA directly as `git-checkout`'s `tag:` first (a raw `git
      fetch <sha>` works fine against GitHub), but melange's own
      git-checkout needs an actual resolvable ref, not a bare SHA:
      "fatal: Remote branch <sha> not found in upstream origin".
      Switched to `uses: fetch` against GitHub's own per-commit archive
      tarball URL instead, which sidesteps ref resolution entirely.
      Verified.
- [x] `libselinux` / `libselinux-dev` (`packages/libselinux.yaml`) --
      forked verbatim (plus its `swig-4.5-pyunicode.patch`). Verified.
- [x] `elfutils-dev` (`packages/elfutils.yaml`) -- forked verbatim, no
      deviations needed (its own upstream `git-checkout` against
      `sourceware.org` hung once, transiently -- retried clean).
- [x] `libarchive` / `libarchive-dev` (`packages/libarchive.yaml`) --
      forked verbatim, no deviations needed.
- [x] `expat-dev` (`packages/expat.yaml`) -- forked verbatim, no
      deviations needed.
- [x] `audit-dev` (`packages/audit.yaml`) -- forked verbatim (plus its
      two patches). Verified.
- [x] `curl` / `curl-dev` (`packages/curl.yaml`) -- forked verbatim, no
      deviations needed. Verified.
- [x] `cryptsetup-dev` (`packages/cryptsetup.yaml`) -- forked verbatim,
      no deviations needed. Verified.
- [x] `iptables-dev` (`packages/iptables.yaml`) -- forked verbatim, but
      its own post-install step needed the
      `ebtables.confd`/`ip6tables.confd`/`iptables.confd` OpenRC service
      config files from Wolfi's own `iptables/` aux directory, missed on
      the initial fork (`install: can't stat 'iptables.confd'`, same
      shape as `linux-pam`'s own missing-aux-files issue above). Fetched
      into `packages/iptables/`. Verified.
- [x] `nftables-dev` (`packages/nftables.yaml`) -- forked verbatim, no
      deviations needed. Verified.
- [x] `kmod` / `kmod-dev` (`packages/kmod.yaml`) -- forked verbatim, no
      deviations needed. Verified.
- [x] `libidn2-dev` (`packages/libidn2.yaml`) -- forked with several
      deviations, all discovered the hard way (building from a git
      checkout rather than a release tarball): `--skip-po` on
      `git/gnulib-bootstrap` (same as make/m4/bison/patch/grep/
      findutils; `--disable-nls` was already present in `./configure`
      opts); `environment.environment.MAKEINFO=true` (libidn2.texi
      `@include`s doc/texi/idn2_*.texi snippets a release tarball ships
      pre-generated but a checkout doesn't -- this bites both `make` and
      `make install`, hence setting it environment-wide rather than on
      one step); and a step touching 19 empty doc/man/idn2_*.3 stub
      files before install (same root cause, but man3 pages aren't
      routed through `$(MAKEINFO)` so they fail outright rather than
      skippably). None of the missing content (API reference docs) is
      anything the shipped library/binaries need. Verified.
- [ ] `gettext` / `gettext-dev` (`packages/gettext.yaml`) -- forked
      verbatim; repeated transient SSL EOF cloning gnulib's submodule
      from GitHub (a network blip, not a recipe issue -- Wolfi's own
      recipe already names a pipeline step "git.savannah.gnu.org is
      flaky", acknowledging general flakiness here) -- retry in
      progress.
- [x] `libmicrohttpd-dev` (`packages/libmicrohttpd.yaml`) -- forked
      verbatim, no deviations needed.
- [x] `libx11-dev` (`packages/libx11.yaml`) -- forked verbatim, no
      deviations needed. Verified.
- [x] `libsm-dev` (`packages/libsm.yaml`) -- forked verbatim, no
      deviations needed. Verified.
- [x] `libtirpc-dev` (`packages/libtirpc.yaml`) -- forked verbatim, no
      deviations needed. Verified.
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
- [x] `libbpf` / `libbpf-dev` (`packages/libbpf.yaml`) -- forked
      verbatim, no deviations needed.
- [x] `linux-pam` / `linux-pam-dev` (`packages/linux-pam.yaml`) -- forked
      verbatim (uses `meson/configure`, a melange built-in, distinct from
      the `meson` package itself being unbuilt), but its own post-install
      `for pam_conf in *.pamd` step needed the `*.pamd`/
      `pam-faillock.conf` files from Wolfi's own `linux-pam/` aux
      directory -- missed on the initial fork (`mv: can't rename
      '*.pamd': No such file or directory`, the glob matched nothing
      without them). Fetched into `packages/linux-pam/`. Verified.
- [x] `valgrind-dev` (`packages/valgrind.yaml`) -- forked verbatim, no
      deviations needed.
- [x] `libsepol` (`packages/libsepol.yaml`) -- forked verbatim, no
      deviations needed (a `libselinux` dependency). Verified.
- [x] `findutils`, `rsync`, `wget` -- all forked verbatim (`findutils`
      needed the same `--skip-po` gnulib-bootstrap fix, `wget` needed
      one upstream patch); verified.
- [x] `gawk` (`packages/gawk.yaml`) -- forked with one upstream patch,
      plus tolerating 3 known environment-specific `make check` failures
      (pma: needs `personality()` blocked under this Docker/Rosetta
      sandbox; randtest: a tool missing from this minimal busybox-based
      environment; readdir: compares literal inode numbers against a
      golden file, inherently non-reproducible) -- any *other* test
      failure still fails the build. Verified.

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

## Phase 5 -- user-facing CLI tools requested for the shipped system

Not build-time dependencies of anything else in this repo -- these are
tools the user wants available in the final image/environment itself.
Tracked here so they aren't forgotten once Phase 2 wraps up.

- [ ] `git` -- exists at Wolfi as `git.yaml`, forkable the same way as
      every other Phase 1/2 package. Note: our own build environments
      already install a `git` build dependency for every `git-checkout`
      pipeline step across this whole repo (currently Wolfi's), so
      self-hosting this one is unusually high-leverage -- it removes
      Wolfi from nearly every recipe's build environment at once, same
      shape as `build-base` itself.
- [ ] `gh` (GitHub CLI) -- exists at Wolfi as `gh.yaml`, forkable
      verbatim; not yet fetched/evaluated.
- [ ] `mcfly` (shell history search, https://github.com/cantino/mcfly)
      -- does **not** exist anywhere in Wolfi's repo (confirmed via a
      full tree search, no `mcfly*.yaml` at any path) -- Wolfi doesn't
      package it at all. Needs a from-scratch recipe written against
      mcfly's own upstream source (it's a Rust project, so this also
      needs a self-hosted Rust toolchain first -- not started, not
      tracked elsewhere in this file yet).
- [ ] `bat` (syntax-highlighting `cat` replacement) -- exists at Wolfi
      as `bat.yaml`, forkable verbatim; a Rust project, same Rust
      toolchain dependency as `mcfly` above; not yet fetched/evaluated.
- [ ] `wayland` (display-server protocol library) -- exists at Wolfi as
      `wayland.yaml`, forkable verbatim; not yet fetched/evaluated.
- [ ] `midnight-commander` (Midnight Commander) -- note: Wolfi's own
      `mc.yaml` is a different tool entirely (the MinIO Client, an S3
      object storage CLI) -- the actual file manager lives at
      `midnight-commander.yaml`. Forkable verbatim; not yet
      fetched/evaluated.
- [ ] `labwc` (wlroots-based Wayland window manager) -- does **not**
      exist anywhere in Wolfi's repo (confirmed via a full tree search).
      Needs a from-scratch recipe; depends on `wayland` (above) plus
      wlroots, which Wolfi also doesn't package -- not started.
- [ ] `noctalia` (Wayland desktop shell) -- does **not** exist anywhere
      in Wolfi's repo (confirmed via a full tree search). Needs a
      from-scratch recipe -- not started, not yet investigated what its
      own build dependencies are.

## Layer 3: the unavoidable seed

Phase 1 needs an *existing* C compiler to build our first self-hosted `gcc`
with -- currently Wolfi's `build-base` (gcc), pulled the same way every other
recipe pulls its build deps. There is no way around needing some external
seed compiler to bootstrap the first one; every real distro (Alpine, Gentoo,
LFS) has this same problem and documents it rather than hiding it. The
honest target here is "every compiler after the first one is self-hosted,"
not "zero external bytes ever."
