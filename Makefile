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
# (see packages/README.md), melange build environments resolve it from
# Wolfi's public repo -- same glibc/systemd family, itself melange-built.
BOOTSTRAP_REPO := https://packages.wolfi.dev/os
BOOTSTRAP_KEY := https://packages.wolfi.dev/os/wolfi-signing.rsa.pub

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
build-package: build-builder-image
	@if [ -z "$(PKG)" ]; then echo "usage: make build-package PKG=<name>"; exit 1; fi
	mkdir -p packages-out
	# -v /tmp:/tmp: melange's docker runner is a sibling container talking to
	# the host daemon over the socket, so the workspace dirs it bind-mounts
	# into build-guest containers must exist at identical paths on the host
	# -- sharing /tmp verbatim keeps that true.
	docker run --rm --privileged --platform $(PLATFORM) \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v /tmp:/tmp \
		-v $(CURDIR):/work -w /work $(BUILDER_IMAGE) \
		melange build packages/$(PKG).yaml \
		--arch $(ARCH) \
		--runner=docker \
		--repository-append=$(BOOTSTRAP_REPO) \
		--keyring-append=$(BOOTSTRAP_KEY) \
		--signing-key=keys/melange.rsa \
		--out-dir=./packages-out

build-index: build-builder-image
	$(DOCKER_RUN) melange index \
		-o packages-out/$(ARCH)/APKINDEX.tar.gz \
		--signing-key=keys/melange.rsa \
		packages-out/$(ARCH)/*.apk

serve-repo:
	docker run --rm -p 8080:80 -v $(CURDIR)/packages-out:/usr/share/nginx/html:ro nginx:alpine

build-rootfs: build-builder-image
	mkdir -p work
	$(DOCKER_RUN) apko build apko/los-angeles-linux.yaml \
		la-linux:dev work/la-linux-oci.tar --arch $(ARCH) \
		--sbom-path=work

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
