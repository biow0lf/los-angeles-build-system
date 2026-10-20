## Builder image tooling (`docker/builder/Dockerfile`)

Blocked on Phase 1/2 (needs a self-hosted toolchain to build these against).

- [ ] `grub`, `grub-bios`, `grub-efi`
- [ ] `xorriso`
- [ ] `squashfs-tools`
- [ ] `qemu-system-x86_64`, `qemu-img`
- [ ] `mtools`, `sgdisk`, `sfdisk`
- [ ] Linux kernel (replaces Alpine's `linux-lts`) -- build from source via melange
- [ ] initramfs generation (replaces Alpine's `mkinitfs`) -- Alpine-specific
      approach, likely needs reimplementing rather than forking

## melange and apko themselves (lowest priority)

Currently copied as prebuilt binaries from
`cgr.dev/chainguard/wolfi-base:latest` in `docker/builder/Dockerfile`. Never
ship in the final image; building from source needs a self-hosted Go
toolchain first (its own bootstrap-seed problem, since Go bootstraps from an
older prebuilt Go release).

## user-facing CLI tools requested for the shipped system

Not build-time dependencies of anything else in this repo -- these are
tools the user wants available in the final image/environment itself.
Tracked here so they aren't forgotten once Phase 2 wraps up.

- [ ] `aws-cli-2` (AWS CLI) -- Wolfi's own package name is `aws-cli-2`,
      not `awscli`/`aws-cli`; forkable verbatim; not yet
      fetched/evaluated.
- [ ] `ag` (the Silver Searcher, fast code-search grep replacement) --
      does **not** exist anywhere in Wolfi's repo under `ag`,
      `the-silver-searcher`, or any other name found via a full tree
      search. Needs a from-scratch recipe -- not started.
