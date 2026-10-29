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
#       libass
#       libXxf86misc
#       lshw
#       mtools
#       netcat-openbsd
#       nss-mdns
#       nushell
#       ollama
#       opam
#       py3-beautifulsoup4
#       python-3.15
#       python-as-wrapper

# Our packages:
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
#   labwc
#   libdisplay-info
#   libei
#   libgudev
#   libliftoff
#   libmbim
#   libndp
#   libplacebo
#   libqalculate
#   libqmi
#   libqrtr-glib
#   libsfdo
#   libxfce4ui
#   libxfce4util
#   linux-firmware
#   linux-zen
#   los-angeles-linux-base
#   los-angeles-linux-release
#   lowdown
#   mpv
#   munit ???
#   man-pages
#   mangowm
#   mcfly
#   md4c
#   mobile-broadband-provider-info
#   modemmanager
#   mpg123
#   muparser
#   libao
#   nettle-3
#   networkmanager
#   noctalia-greeter
#   noctalia
#   sound-theme-freedesktop
#   libcanberra
#   paprefs
#   pavucontrol
#   po4a

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
    lame
    lazydocker
    lazygit
    lcms2
    less
    libaio
    libarchive
    libass
    libassuan
    libasyncns
    libavif
    libbpf
    libbsd
    libburn
    libcap-ng
    libcap
    libdaemon
    libde265
    libdrm
    libeconf
    libedit
    libepoxy
    libev
    libevdev
    libevent
    libffi
    libfontenc
    libgcrypt
    libglvnd
    libgpg-error
    libgsf
    libheif
    libical
    libice
    libid3tag
    libidn2
    libinput
    libisoburn
    libisofs
    libjpeg-turbo
    libjxl
    libkcapi
    libksba
    libmd
    libmicrohttpd
    libmnl
    libmpack
    libmspack
    libnftnl
    libnl3
    libnotify
    libnspr
    libnvme
    libogg
    libpaper
    libpciaccess
    libpipeline
    libpng
    libpsl
    libpthread-stubs
    librsvg
    libsamplerate
    libsass
    libsdl2
    libseccomp
    libsecret
    libselinux
    libsemanage
    libsepol
    libsm
    libsndfile
    libsodium
    libspiro
    libsrt
    libssh
    libssh2
    libtasn1
    libtheora
    libtirpc
    libtool
    libtraceevent
    libtracefs
    libtree
    libunistring
    liburing
    libusb
    libutempter
    libuv
    libva
    libvdpau
    libverto
    libvorbis
    libvpx
    libwebp
    libwebsockets
    libx11
    libxau
    libxaw
    libxcb
    libxcomposite
    libxcrypt
    libxcursor
    libxcvt
    libxdamage
    libxdmcp
    libxext
    libxfixes
    libxfont
    libxft
    libxi
    libxinerama
    libxkbcommon
    libxkbfile
    libxml2
    libxmu
    libxpm
    libxrandr
    libxrender
    libxscrnsaver
    libxshmfence
    libxslt
    libxt
    libxtst
    libxv
    libxxf86vm
    libzip
    linenoise
    linux-headers
    linux-pam
    llvm-22
    llvm-23
    lmdb
    lsb-release-minimal
    lsof
    lua-lpeg
    lua-luv
    lua-mpack
    lua5.3-lzlib
    lua5.3
    lua5.4
    luajit
    luit
    lvm2
    lynx
    lz4
    lzip
    lzo
    m4
    make
    man-db
    melange
    mercurial
    mesa
    meson
    midnight-commander
    mkfontscale
    mold
    mosquitto
    mpc
    mpdecimal
    mpfr
    msgpack-c
    mtdev
    nano
    nasm
    ncurses
    neovim
    nettle
    nfs-utils
    nftables
    nghttp2
    nghttp3
    ngtcp2
    ninja-build
    nlohmann-json
    npth
    nss
    ocaml-findlib
    ocaml-num
    ocaml
    ocamlbuild
    omnibump
    oniguruma
    openbox
    opencore-amr
    openh264
    openjpeg
    openjph
    openldap-2.7
    openssf-compiler-options
    openssh
    openssl-3.6
    openssl-4.0
    openssl-hardened-3.6
    openssl-hardened-4.0
    openssl-provider-legacy-allowed
    openssl
    opus
    orc
    p11-kit
    pango
    parted
    patch
    pax-utils-bootstrap
    pax-utils
    pciutils
    pcre2
    perl-aliased
    perl-app-cmd
    perl-b-hooks-endofscope
    perl-capture-tiny
    perl-carp-clan
    perl-class-data-inheritable
    perl-class-inspector
    perl-class-load-xs
    perl-class-load
    perl-class-method-modifiers
    perl-class-singleton
    perl-class-tiny
    perl-clone
    perl-config-autoconf
    perl-config-ini
    perl-config-mvp-reader-ini
    perl-config-mvp
    perl-cpan-meta-check
    perl-cpan-uploader
    perl-data-optlist
    perl-data-section
    perl-date-format
    perl-datetime-locale
    perl-datetime-timezone
    perl-datetime
    perl-devel-globaldestruction
    perl-devel-overloadinfo
    perl-devel-ppport
    perl-devel-stacktrace
    perl-dist-checkconflicts
    perl-dist-zilla
    perl-encode-locale
    perl-eval-closure
    perl-exception-class
    perl-exporter-tiny
    perl-extutils-config
    perl-extutils-helpers
    perl-extutils-installpaths
    perl-file-copy-recursive
    perl-file-find-rule
    perl-file-listing
    perl-file-pushd
    perl-file-remove
    perl-file-sharedir-install
    perl-file-sharedir
    perl-font-ttf
    perl-getopt-long-descriptive
    perl-hook-lexwrap
    perl-html-parser
    perl-html-tagset
    perl-http-cookies
    perl-http-date
    perl-http-message
    perl-http-negotiate
    perl-inc-latest
    perl-io-html
    perl-io-string
    perl-io-tiecombine
    perl-ipc-run3
    perl-json-maybexs
    perl-json
    perl-libwww
    perl-locale-gettext
    perl-log-dispatch-array
    perl-log-dispatch
    perl-log-dispatchouli
    perl-log-message-simple
    perl-log-message
    perl-lwp-mediatypes
    perl-lwp-protocol-https
    perl-mailtools
    perl-mixin-linewise
    perl-module-build-tiny
    perl-module-build
    perl-module-implementation
    perl-module-install
    perl-module-path
    perl-module-pluggable
    perl-module-runtime-conflicts
    perl-module-runtime
    perl-module-scandeps
    perl-moo
    perl-moose
    perl-moosex-lazyrequire
    perl-moosex-oneargnew
    perl-moosex-role-parameterized
    perl-moosex-setonce
    perl-moosex-types-perl
    perl-moosex-types
    perl-mro-compat
    perl-namespace-autoclean
    perl-namespace-clean
    perl-net-http
    perl-number-compare
    perl-package-deprecationmanager
    perl-package-stash-xs
    perl-package-stash
    perl-params-someutil
    perl-params-util
    perl-params-validate
    perl-params-validationcompiler
    perl-parse-yapp
    perl-path-tiny
    perl-perl-prereqscanner
    perl-perlio-utf8-strict
    perl-ppi
    perl-role-hasmessage
    perl-role-identifiable
    perl-role-tiny
    perl-safe-isa
    perl-scope-guard
    perl-software-license
    perl-specio
    perl-string-errf
    perl-string-flogger
    perl-string-formatter
    perl-string-rewriteprefix
    perl-sub-exporter-formethods
    perl-sub-exporter-globexporter
    perl-sub-exporter-progressive
    perl-sub-exporter
    perl-sub-identify
    perl-sub-install
    perl-sub-quote
    perl-sub-uplevel
    perl-task-weaken
    perl-term-encoding
    perl-term-readkey
    perl-term-ui
    perl-test-deep
    perl-test-exception
    perl-test-failwarnings
    perl-test-fatal
    perl-test-file-sharedir
    perl-test-needs
    perl-test-nowarnings
    perl-test-object
    perl-test-pod
    perl-test-requires
    perl-test-simple
    perl-test-subcalls
    perl-test-warnings
    perl-test-without-module
    perl-test2-plugin-nowarnings
    perl-text-glob
    perl-text-template
    perl-throwable
    perl-tie-ixhash
    perl-try-tiny
    perl-type-tiny
    perl-uri
    perl-www-robotrules
    perl-xml-parser
    perl-yaml-pp
    perl-yaml-syck
    perl-yaml-tiny
    perl
    pipewire.yaml
    pixman.yaml
    pkgconf.yaml
    polkit.yaml
    popt.yaml
    posix-cc-wrappers.yaml
    potrace.yaml
    powertop.yaml
    procps-ng.yaml
    protobuf-29.5.yaml
    protobuf-c.yaml
    psmisc.yaml
    pugixml.yaml
    pulseaudio.yaml
    pwgen.yaml
    py3-alabaster.yaml
    py3-babel.yaml
    py3-build.yaml
    py3-cairo.yaml
    py3-calver.yaml
    py3-colorama.yaml
    py3-cython.yaml
    py3-docutils.yaml
    py3-flit-core.yaml
    py3-gobject3.yaml
    py3-gpep517.yaml
    py3-gyp-next.yaml
    py3-hatchling.yaml
    py3-imagesize.yaml
    py3-importlib-metadata.yaml
    py3-installer.yaml
    py3-jinja2.yaml
    py3-lxml.yaml
    py3-markdown.yaml
    py3-markupsafe.yaml
    py3-meson-python.yaml
    py3-packaging.yaml
    py3-pathspec.yaml
    py3-pefile.yaml
    py3-pip.yaml
    py3-pluggy.yaml
    py3-poetry-core.yaml
    py3-pyelftools.yaml
    py3-pygments.yaml
    py3-pyparsing.yaml
    py3-pyproject-hooks.yaml
    py3-pyproject-metadata.yaml
    py3-requests.yaml
    py3-roman-numerals-py.yaml
    py3-setuptools-scm.yaml
    py3-setuptools-wheel.yaml
    py3-setuptools.yaml
    py3-snowballstemmer.yaml
    py3-sphinx.yaml
    py3-sphinxcontrib-applehelp.yaml
    py3-sphinxcontrib-devhelp.yaml
    py3-supported-python.yaml
    py3-tomli.yaml
    py3-tomlkit.yaml
    py3-trove-classifiers.yaml
    py3-typing-extensions.yaml
    py3-typogrify.yaml
    py3-wheel.yaml
    py3-zipp.yaml
    py3.14-babel.yaml
    py3.14-build.yaml
    py3.14-calver.yaml
    py3.14-colorama.yaml
    py3.14-docutils.yaml
    py3.14-flit-core.yaml
    py3.14-gpep517.yaml
    py3.14-gyp-next.yaml
    py3.14-hatchling.yaml
    py3.14-imagesize.yaml
    py3.14-importlib-metadata.yaml
    py3.14-installer.yaml
    py3.14-jinja2.yaml
    py3.14-markdown.yaml
    py3.14-markupsafe.yaml
    py3.14-maturin.yaml
    py3.14-packaging.yaml
    py3.14-pathspec.yaml
    py3.14-pefile.yaml
    py3.14-pluggy.yaml
    py3.14-poetry-core.yaml
    py3.14-pygments.yaml
    py3.14-pyparsing.yaml
    py3.14-pyproject-hooks.yaml
    py3.14-pyproject-metadata.yaml
    py3.14-requests.yaml
    py3.14-roman-numerals-py.yaml
    py3.14-setuptools-scm.yaml
    py3.14-sphinxcontrib-devhelp.yaml
    py3.14-tomli.yaml
    py3.14-tomlkit.yaml
    py3.14-trove-classifiers.yaml
    py3.14-typing-extensions.yaml
    py3.14-wheel.yaml
    py3.14-zipp.yaml
    python-3.10
    python-3.11
    python-3.12
    python-3.13
    python-3.14
)

echo "Sync packages with https://github.com/wolfi-dev/os ..."

for package in "${packages[@]}"; do
	echo "Sync: $package package"
	curl -s "$raw_github_url/$package.yaml" -o "packages/$package.yaml"
done
