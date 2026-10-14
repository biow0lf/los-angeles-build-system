#! /bin/bash

set -euo pipefail

raw_github_url="https://raw.githubusercontent.com/wolfi-dev/os/refs/heads/main"

packages=(
	actionlint
	perl
)

echo "Sync packages with https://github.com/wolfi-dev/os ..."

for package in "${packages[@]}"; do
	echo "Sync: $package package"
	curl -s "$raw_github_url/$package.yaml" -o "packages/$package.yaml"
done
