SHELL := /bin/bash
ARCH ?= x86_64
BUILDER_IMAGE := la-linux/builder
PKG ?=

# The builder image is always amd64, regardless of host arch (Docker runs it
# under QEMU emulation on non-amd64 hosts, same as melange already does for
# package builds). This matters beyond consistency: Alpine's `grub` package
# only ships module targets relevant to its OWN build arch -- the arm64
# build has arm64-efi only, no i386-pc (BIOS) modules -- so building this
# image for the host's native arch on an Apple Silicon Mac silently produces
# a grub that can't do BIOS-boot installs for our x86_64 target at all.
PLATFORM := linux/amd64

# Bootstrap repo/keyring: until a given build-time dependency is self-hosted
# (see BOOTSTRAP.md), melange build environments resolve it from Wolfi's
# public repo -- same glibc/systemd family, itself melange-built.
BOOTSTRAP_REPO := https://packages.wolfi.dev/os
BOOTSTRAP_KEY := https://packages.wolfi.dev/os/wolfi-signing.rsa.pub

# build-packages.yml's CI matrix builds each package in its own isolated
# checkout -- packages-out (below) only accumulates within a single working
# directory, so it can't help one matrix leg see another leg's output, or a
# leg on one CI run see a previous run's. The published repo (updated by
# that same workflow's publish job on every successful main build) is what
# makes a self-hosted build-time dependency actually reach CI, not just
# local dev.
PUBLISHED_REPO := https://biow0lf.github.io/los-angeles-build-system

# Every target below runs the same builder image; docker.sock and privileged
# access are opted into only by the specific targets that need them, so
# privilege never leaks into steps that don't require it.
DOCKER_RUN := docker run --rm --platform $(PLATFORM) -v $(CURDIR):/work -w /work $(BUILDER_IMAGE)

.PHONY: build-builder-image keygen build-package build-index serve-repo \
        build-rootfs build-image build-iso test-boot clean

build-builder-image:
	docker build --platform $(PLATFORM) -t $(BUILDER_IMAGE) -f docker/builder/Dockerfile .

keygen: build-builder-image
	mkdir -p keys
	$(DOCKER_RUN) melange keygen keys/melange.rsa

# make build-package PKG=los-angeles-linux-release
# --source-dir=packages/$(PKG): melange populates the build workspace from
# this directory (patches, embedded config files, etc. that pipeline steps
# reference by relative path), *not* from the directory containing the
# YAML. ALWAYS passed, even when packages/$(PKG)/ doesn't exist (pointing
# it at packages/.empty-source-dir/ instead, a directory checked into git
# containing only a .gitkeep) -- melange's default behavior when
# --source-dir is omitted entirely is to populate the guest workspace
# from melange's own CWD, which under this Makefile's `-w /work` is the
# ENTIRE repository, not nothing. That silently leaked every other
# package's own packages/<name>/ aux directory (patches, vendored
# tarballs, etc.) into builds that never asked for them -- harmless until
# packages/gcc/ started existing and a plain "test -d gcc" check in
# binutils's own (unrelated) build made binutils's configure think it was
# part of a combined gcc+binutils source tree, requiring gmp/mpc/mpfr/isl
# and a real gcc/lto frontend that was never actually there. Pointing
# every package's --source-dir at an explicitly empty directory by
# default closes this off for good, rather than special-casing gcc/
# specifically.
SOURCE_DIR_FLAG = --source-dir=$(if $(wildcard packages/$(PKG)),packages/$(PKG),packages/.empty-source-dir)

build-package: build-builder-image
	@if [ -z "$(PKG)" ]; then echo "usage: make build-package PKG=<name>"; exit 1; fi
	mkdir -p packages-out
	# -v /tmp:/tmp: melange's docker runner is a sibling container talking to
	# the host daemon over the socket, so the workspace dirs it bind-mounts
	# into build-guest containers must exist at identical paths on the host
	# -- sharing /tmp verbatim keeps that true.
	#
	# Repos tried in order: packages-out (this working directory's own
	# already-built output -- freshest, but invisible to other CI matrix
	# legs/runs), PUBLISHED_REPO (what actually makes a self-hosted
	# build-time dependency reach CI, not just local dev), then Wolfi's
	# live repo as the final fallback for whatever hasn't been
	# self-hosted yet (see BOOTSTRAP.md). Verified melange tolerates
	# packages-out/x86_64/APKINDEX.tar.gz not existing yet (a fresh
	# checkout, or before any package has been built this session): it's
	# just a WARN, not a fatal error, and resolution falls through to the
	# next repo in the list.
	docker run --rm --privileged --platform $(PLATFORM) \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v /tmp:/tmp \
		-v $(CURDIR):/work -w /work $(BUILDER_IMAGE) \
		melange build packages/$(PKG).yaml \
		--arch $(ARCH) \
		--runner=docker \
		--repository-append=packages-out \
		--repository-append=$(PUBLISHED_REPO) \
		--repository-append=$(BOOTSTRAP_REPO) \
		--keyring-append=keys/melange.rsa.pub \
		--keyring-append=$(BOOTSTRAP_KEY) \
		--signing-key=keys/melange.rsa \
		--out-dir=./packages-out \
		--pipeline-dir=pipelines \
		$(SOURCE_DIR_FLAG)

build-index: build-builder-image
	$(DOCKER_RUN) melange index \
		-o packages-out/$(ARCH)/APKINDEX.tar.gz \
		--signing-key=keys/melange.rsa \
		packages-out/$(ARCH)/*.apk

serve-repo:
	docker run --rm -p 8080:80 -v $(CURDIR)/packages-out:/usr/share/nginx/html:ro nginx:alpine

build-rootfs: build-builder-image
	mkdir -p work
	$(DOCKER_RUN) sh -c ' \
		apko/generate-lockfile.sh $(ARCH) work/apko.lock.json && \
		apko build apko/los-angeles-linux.yaml \
			la-linux:dev work/la-linux-oci.tar --arch $(ARCH) \
			--sbom-path=work --lockfile=work/apko.lock.json \
	'

# --privileged: needed for /dev/loop-control (partitioning) -- and also,
# incidentally, is what lets extract-rootfs.sh's tar recreate the rootfs's
# real device nodes on the container's own filesystem (see that script for
# why this has to be one container invocation rather than separate steps
# sharing a bind mount or Docker volume).
build-image: build-rootfs
	docker run --rm --privileged --platform $(PLATFORM) -v $(CURDIR):/work -w /work $(BUILDER_IMAGE) \
		image/build-disk-image.sh

build-iso: build-image
	docker run --rm --privileged --platform $(PLATFORM) -v $(CURDIR):/work -w /work $(BUILDER_IMAGE) \
		image/build-iso.sh

KVM_DEVICE := $(if $(wildcard /dev/kvm),--device /dev/kvm,)

test-boot: build-image
	docker run --rm --platform $(PLATFORM) -v $(CURDIR):/work -w /work $(KVM_DEVICE) $(BUILDER_IMAGE) \
		test/boot-smoke-test.sh work/la-linux.img

clean:
	rm -rf work packages-out
