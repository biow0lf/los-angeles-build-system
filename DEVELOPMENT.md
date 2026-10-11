# Stages of project

## Stage 1: bootstrap base system.

Goal: system that can build itself and build more packages.

Status: in progress.

## Stage 2: add kernel, linux-firmware

At this stage we are adding packages:

* kernel
* linux-firmware
* grub

Goal: bootable linux system

Status: planned

## Stage 3: Wayland / X11 graphical system

At this stage we are adding wayland, labwc and small utils.
So, we can boot in labwc and start working in it.

Packages:

* labwc
* wlroots
* xwayland
* terminal

Goal: bootable linux system with UI

Status: planned

## Stage 4: fully self hosted system

At this stage we want fully self hosted system.
We can rebuild all packages in repo without any 3rd party repo(s).

Goal: fully self hosted system

Status: planned

## Stage 5: Noctalia Shell

At this stage we want fully working Noctalia Shell.

Packages:

* noctalia
* labwc
* greetd
* umbriel
* noctalia-greeter

Goal: working Noctalia Shell

Status: planned

## Stage 6: multimedia

At this stage we want to watch any video files and play any audio files.

Packages:

* mpv
* pulseaudio
* pipewire
* mpg123
* mpg321
* ogg123

Goal: watch videos and play audio.

Status: planned

## Stage 7: Docker client and docker server

Goal: docker should works

Status: planned

