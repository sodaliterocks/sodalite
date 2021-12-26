#!/usr/bin/env bash

source "$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/.common.sh"

VARIANT="fedora-sodalite"

mkdir -p $OSTREE_CACHE_DIR
mkdir -p $OSTREE_REPO_DIR

if [ ! "$(ls -A $OSTREE_REPO_DIR)" ]; then
   echo "Initiating OSTree repository..."
   ostree --repo="${OSTREE_REPO_DIR}" init --mode=archive
fi

echo "Composing OSTree..."
rpm-ostree compose tree \
    --unified-core \
    --cachedir="$OSTREE_CACHE_DIR" \
    --repo="$OSTREE_REPO_DIR" \
    src/${VARIANT}.yaml

# TODO: Correct permissions to those of the BASE_DIR