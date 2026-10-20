#! /bin/bash

set -euo pipefail

raw_github_url="https://raw.githubusercontent.com/wolfi-dev/os/refs/heads/main"

# TODO: aws-cli-2
#       cmatrix
#       command-not-found

packages=(
    7zip
    abi-compliance-checker
    abi-dumper
    abseil-cpp-20250127
    acl
	actionlint
	alsa-lib
	aom
	apk-tools
	apko
	argon2
	asciidoc
	asciidoctor
	at-spi2-core
	attr
	audit
	autoconf
	autoconf-archive
	automake
	avahi
	bash
	bash-completion
	bat
	bc
	bind
	binutils
	bison
	bluez
	bpftool
	brotli
	btop
	btrfs-progs
	bubblewrap
	build-base
	busybox
	bzip2
	c-ares
	ca-certificates
	cairo
	cargo-auditable
	cargo-c
	cdparanoia
	check
	chezmoi
	cjson
	cmake
	cmake-3
	cmatrix
	cmocka
	coreutils
	# cryptsetup
	# cyrus-sasl-heimdal
	# dash
	# dav1d
	# db
	# dbus
	# delta
	# diffutils
	# direnv
	# docbook-xml
	# dosfstools
	# doxygen
	# duktape
	# e2fsprogs
	# ed
	# ell
	# encodings
	# expat
	# fftw
	# file
	# findutils
	# flac
	# flex
	# font-util
	# freerdp-3
	# freetype
	# gawk
	# gdbm
	# gengetopt
	# gettext
	# gh
	# giflib
	# git
	# github-mcp-server
	# glib
	# glibc-2.44
	# glslang
	# gmp
	# gnu-libiconv
	# gnulib
	# gnutar
	# gnutls
	# gobject-introspection
	# gperf
	# graphene
	# graphite2
	# graphviz
	# grep
	# gst-libav
	# gst-plugins-base
	# gst-plugins-good
	# gstreamer
	# guile
	# harfbuzz
	# heimdal
	# help2man
	# htop
	# imlib2
	# intltool
	# iproute2
	# iptables
	# iputils
	# isl
	# jack
	# jansson
	# json-c
	# jsoncpp
	# kbd
	# keyutils
	# kmod
	# lame
	# lazygit
	# libarchive
	# libasyncns
	# libbpf
	# libbsd
	# libcap-ng
	# libcap
	# libdrm
	# libeconf
	# libedit
	# libev
	# libffi
	# libfontenc
	# libglvnd
	# libgpg-error
	# libice
	# libidn2
	# libisofs
	# libjpeg-turbo
	# libkcapi
	# libmicrohttpd
	# libmnl
	# libnftnl
	# libnl3
	# libogg
	# libpciaccess
	# libpipeline
	# libpsl
	# libpthread-stubs
	# libsamplerate
	# libsass
	# libsdl2
	# libseccomp
	# libsecret
	# libsm
	# libsndfile
	# libsodium
	# libtasn1
	# libtheora
	# libtool
	# libtracefs
	# libunistring
	# libutempter
	# libva
	# libvdpau
	# libverto
	# libvorbis
	# libwebp
	# libxau
	# libxcomposite
	# libxcrypt
	# libxcursor
	# libxdamage
	# libxdmcp
	# libxext
	# libxfixes
	# libxft
	# libxinerama
	# libxkbcommon
	# libxml2
	# libxrandr
	# libxrender
	# libxshmfence
	# libxslt
	# libxt
	# libxtst
	# libxv
	# libxxf86vm
	# linenoise
	# linux-headers
	# linux-pam
	# llvm-22
	# llvm-23
	# lsof
	# lua-lpeg
	# lua-mpack
	# lua5.3-lzlib
	# lua5.3
	# luajit
	# lz4
	# lzip
	# m4
	# make
	# man-db
	# mesa
	# mold
	# ncurses
	# neovim
	# omnibump
	# openssf-compiler-options
	# openssh
	# openssl-4.0
	# openssl-provider-legacy-allowed
	# openssl-hardened-3.6
	# openssl-hardened-4.0
	# openssl
	# parted
	# patch
	# pcre2
	# perl-yaml-pp
	# perl-yaml-syck
	# perl
)

echo "Sync packages with https://github.com/wolfi-dev/os ..."

for package in "${packages[@]}"; do
	echo "Sync: $package package"
	curl -s "$raw_github_url/$package.yaml" -o "packages/$package.yaml"
done
