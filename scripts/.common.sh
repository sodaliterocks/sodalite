#!/usr/bin/env bash

if ! [ $(id -u) = 0 ]; then
   echo "Must be ran as root!"
   exit 1
fi

# TODO: Check ostree and rpm-ostree are installed
# TODO: Make sure submodules we need for build are pulled in

BASE_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/.."
BUILD_DIR="$BASE_DIR/build"
if [ "$1" != "" ]; then
   BUILD_DIR=$1
fi

OSTREE_CACHE_DIR="$BUILD_DIR/cache"
OSTREE_REPO_DIR="$BUILD_DIR/repo"