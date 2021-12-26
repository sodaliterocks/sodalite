#!/usr/bin/env bash

source "$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/.common.sh"

echo "Generating repository summary..."
ostree summary --repo="$OSTREE_REPO_DIR" --update