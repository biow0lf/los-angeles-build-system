#! /bin/bash

set -euo pipefail

raw_github_url="https://raw.githubusercontent.com/wolfi-dev/os/refs/heads/main"

# TODO: aws-cli-2
#       cmatrix
#       dbus-glib
#       brew
#       cargo-audit
#       ccache
#       chrpath
#       codex
#       dart
#       docker-29
#       dua

# Our package:
#   aquamarine
#   cliamp
#   concord
#   dbus-broker
#   dracut
#   dysk
#   dejagnu
#   dos2unix
#   dust
#   edgepad
#   efibootmgr
#   efivar
#   exo
#   expect
#   calamares

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
    atop
    attr
    audit
    autoconf-archive
    autoconf
    automake
    avahi
    bash-completion
    bash
    bat
    bc
    bdftopcf
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
    cabextract
    cairo
    cargo-auditable
    cargo-c
    cdparanoia
    check
    chezmoi
    cjson
    cmake-3
    cmake
    cmocka
    command-not-found
    coreutils
    cpio
    cppunit
    cryptsetup
    ctop
    cups
    curl
    cyrus-sasl-heimdal
    cython-0
    dash
    dav1d
    db
    dbus
    delta
    diffutils
    direnv
    dive
    dns-root-hints
    dnssec-root
    docbook-xml
    dosfstools
    doxygen
    dua
    duktape
    e2fsprogs
    ed
    elfutils
    ell
    encodings
    execline
    expat
)

echo "Sync packages with https://github.com/wolfi-dev/os ..."

for package in "${packages[@]}"; do
	echo "Sync: $package package"
	curl -s "$raw_github_url/$package.yaml" -o "packages/$package.yaml"
done
