#!/bin/bash

step="$1"
branch="$2"
variant="$3"

function die() {
    echo "$1"
    exit 255
}

function step_update_submodules() {
    git pull --recurse-submodules
    git submodule update --remote --recursive
}

case $step in
    "update-submodules") step_update_submodules ;;
    *)
        die "Step '$step' does not exist"
esac
