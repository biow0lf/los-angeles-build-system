#! /bin/bash

set -euxo pipefail

apko build \
        --log-level debug \
        --arch x86_64 \
        --format tar \
        --cache-dir ../base-image/.cache/ \
        apko.yaml unfriendly-kernel-build:latest output.tar
