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
#       firefox
#       fish
#       freerdp-3
#       fuse3
#       gperftools
#       gst-libav
#       howdy-yall
#       hunspell-dictionaries-all

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
#   iana-etc
#   fwupd
#   garcon
#   grub
#   greetd
#   hyprcursor
#   hyprgraphics
#   hyprland-protocols
#   hyprland
#   hyprlang
#   hyprpaper
#   hyprtoolkit
#   hyprutils
#   hyprwayland-scanner
#   hyprwire
#   difi
#   iana-etc
#   kanshi

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
    fastfetch
    fd
    ffmpeg-7
    ffmpeg-9.0
    fftw
    fig2dev
    file
    findutils
    flac
    flex
    fluxbox
    fmt
    font-misc
    font-util
    font-xorg-dirs
    fontconfig
    fontforge
    freetype
    fribidi
    fstrm
    fzf
    gawk
    gc
    gcc
    gd
    gdbm
    gdk-pixbuf
    gengen
    gengetopt
    gettext
    gh
    ghostscript
    gi-docgen
    giflib
    git
    github-mcp-server
    glib-gir
    glib
    glibc-2.44
    glslang
    glycin-2
    gmp
    gnu-libiconv
    gnulib
    gnupg
    gnutar
    gnutls
    go-1.27
    gobject-introspection
    gperf
    gpgme
    graphene
    graphite2
    graphviz
    grep
    groff
    gsl
    gst-plugins-bad
    gst-plugins-base
    gst-plugins-good
    gstreamer
    gtest
    gtk-2.0
    gtk-3
    gtk-4
    gtk-doc
    guile
    gzip
    harfbuzz
    heimdal
    help2man
    hicolor-icon-theme
    highway
    htop
    hunspell
    hwdata
    icu
    imlib2
    inih
    iniparser
    inotify-tools
    intltool
    iperf
    iproute2
    iptables
    iputils
    isl
    iso-codes
    itstool
    jack
    jansson
    jbig2dec
    jemalloc
    jitterentropy-library
    jq
    json-c
    jsoncpp
    just
    kbd
    keyutils
    kmod
    krb5-conf
    krb5
)

echo "Sync packages with https://github.com/wolfi-dev/os ..."

for package in "${packages[@]}"; do
	echo "Sync: $package package"
	curl -s "$raw_github_url/$package.yaml" -o "packages/$package.yaml"
done
