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
#       netcat-openbsd
#       nss-mdns
#       nushell
#       ollama
#       opam
#       py3-beautifulsoup4
#       python-3.15
#       python-as-wrapper
#       procps
#       qt6-qtbase
#       ripgrep
#       s3fs-fuse
#       smartmontools

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
#   procps-ng
#   quickshell
#   slk
#   scenefx
#   sdbus-cpp
#   seatd
#   simdutf
#   sound-theme-freedesktop
#   stb_image_resize
#   stb
#   the_silver_searcher
#   tomlplusplus
#   umbriel
#   unfriendly-devtools
#   unfriendly-keys
#   unix2dos
#   vibez
#   vlc
#   vorbis-tools
#   vte
#   which
#   wireplumber
#   wlopm
#   wlr-randr
#   wlroots
#   xcb-util-errors
#   xdg-desktop-portal-umbriel
#   xfce-base-meta
#   xfce4-terminal
#   xfconf
#   xwayland
#   yt-dlp
#   squashfs-tools

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
    gptfdisk
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
    mtools
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
    perl-io-socket-ssl
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
    perl-mozilla-ca
    perl-mro-compat
    perl-namespace-autoclean
    perl-namespace-clean
    perl-net-http
    perl-net-ssleay
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
    perl-timedate
    perl-try-tiny
    perl-type-tiny
    perl-uri
    perl-www-robotrules
    perl-xml-parser
    perl-yaml-pp
    perl-yaml-syck
    perl-yaml-tiny
    perl
    pipewire
    pixman
    pkgconf
    polkit
    popt
    posix-cc-wrappers
    potrace
    powertop
    protobuf-29.5
    protobuf-c
    psmisc
    pugixml
    pulseaudio
    pwgen
    py3-alabaster
    py3-babel
    py3-beautifulsoup4
    py3-build
    py3-cairo
    py3-calver
    py3-colorama
    py3-cython
    py3-docutils
    py3-flit-core
    py3-gobject3
    py3-gpep517
    py3-gyp-next
    py3-hatchling
    py3-imagesize
    py3-importlib-metadata
    py3-installer
    py3-jinja2
    py3-lxml
    py3-markdown
    py3-markupsafe
    py3-meson-python
    py3-packaging
    py3-pathspec
    py3-pefile
    py3-pip
    py3-pluggy
    py3-poetry-core
    py3-pyelftools
    py3-pygments
    py3-pyparsing
    py3-pyproject-hooks
    py3-pyproject-metadata
    py3-requests
    py3-roman-numerals-py
    py3-setuptools-scm
    py3-setuptools-wheel
    py3-setuptools
    py3-snowballstemmer
    py3-soupsieve
    py3-sphinx
    py3-sphinxcontrib-applehelp
    py3-sphinxcontrib-devhelp
    py3-supported-python
    py3-tomli
    py3-tomlkit
    py3-trove-classifiers
    py3-typing-extensions
    py3-typogrify
    py3-wheel
    py3-zipp
    py3.14-babel
    py3.14-beautifulsoup4
    py3.14-build
    py3.14-calver
    py3.14-colorama
    py3.14-docutils
    py3.14-flit-core
    py3.14-gpep517
    py3.14-gyp-next
    py3.14-hatchling
    py3.14-imagesize
    py3.14-importlib-metadata
    py3.14-installer
    py3.14-jinja2
    py3.14-markdown
    py3.14-markupsafe
    py3.14-maturin
    py3.14-packaging
    py3.14-pathspec
    py3.14-pefile
    py3.14-pluggy
    py3.14-poetry-core
    py3.14-pygments
    py3.14-pyparsing
    py3.14-pyproject-hooks
    py3.14-pyproject-metadata
    py3.14-requests
    py3.14-roman-numerals-py
    py3.14-setuptools-scm
    py3.14-soupsieve
    py3.14-sphinxcontrib-devhelp
    py3.14-tomli
    py3.14-tomlkit
    py3.14-trove-classifiers
    py3.14-typing-extensions
    py3.14-wheel
    py3.14-zipp
    python-3.10
    python-3.11
    python-3.12
    python-3.13
    python-3.14
    quota-tools
    rav1e
    rdfind
    re2
    readline
    rhash
    rsync
    ruby-3.4
    ruby-4.0
    ruff
    rust-1.99
    s-lang
    s3cmd
    s3fs-fuse
    s6
    samba
    samurai
    sassc
    sbc
    scdoc
    screen
    sed
    shaderc
    shadow
    shared-mime-info
    skalibs
    smartypants
    snappy
    soxr
    speex
    speexdsp
    spirv-headers
    spirv-tools
    sqlite
    starship
    startup-notification
    strace
    subunit
    sudo
    svt-av1
    swig
    systemd
    talloc
    tcl
    tdb
    terraform-mcp-server
    tevent
    texinfo
    tiff
    tk
    tpm2-tss
    tree-sitter
    tree
    ttf-dejavu
    tzdata
    undock
    unibilium
    universal-ctags
    unixodbc
    unrtf
    unzip
    userspace-rcu
    utf8proc
    util-linux
    util-macros
    utmps
    uv
    vala-bootstrap
    vala
    valgrind
    vim
    vtable-dumper
    vulkan-headers
    vulkan-loader
    wasi-libc
    wasi-sdk
    wayland-protocols
    wayland
    wget
    woff2
    wolfi-base
    wolfi-baselayout
    wolfi-keys
    x264
    x265
    xbitmaps
    xcb-proto
    xcb-util-cursor
    xcb-util-image
    xcb-util-renderutil
    xcb-util-wm
    xcb-util
    xfsprogs
    xh
    xkbcomp
    xkeyboard-config
    xmlto
    xorg-server
    xorgproto
    xterm
    xtrans
    xxhash
    xz
    yam
    yaml-language-server
    yaml
    yasm
    yazi
    yq
    zed
    zeromq
    zip
    zizmor
    zlib
    zsh
    zstd
)

echo "Sync packages with https://github.com/wolfi-dev/os ..."

for package in "${packages[@]}"; do
	echo "Sync: $package package"
	curl -s "$raw_github_url/$package.yaml" -o "packages/$package.yaml"
done
