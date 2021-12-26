#!/usr/bin/env bash

if ! [ $(id -u) = 0 ]; then
   echo "Must be ran as root!"
   exit 1
fi

BASE_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/build"
if [ "$1" != "" ]; then
   BASE_DIR=$1
fi

CACHE_DIR="$BASE_DIR/cache"
REPO_DIR="$BASE_DIR/repo"
VARIANT="fedora-sodalite"

mkdir -p $CACHE_DIR
mkdir -p $REPO_DIR

if [ ! "$(ls -A $REPO_DIR)" ]; then
   ostree --repo="${REPO_DIR}" init --mode=archive
fi

rpm-ostree compose tree \
    --unified-core \
    --cachedir="$CACHE_DIR" \
    --repo="$REPO_DIR" \
    src/${VARIANT}.yaml