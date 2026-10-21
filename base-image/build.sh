#! /bin/bash

set -euxo pipefail

apko build \
	--log-level debug \
	--arch x86_64 \
	--format tar \
	--cache-dir .cache/ \
	apko.yaml latest output.tar

