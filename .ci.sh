#!/bin/bash

step="$1"

function die() {
    echo "Error: $1"
    exit 255
}

function step_build_tree() {
    tree="$1"
    ostree_repo="$2"

    container_hostname="$(hostname -f)"
    container_image="fedora:37"
    start_time="$(date +%s)"

    ./build.sh \
        --container \
        --tree "$tree" \
        --vendor "sodaliterocks" \
        --working-dir "$ostree_repo" \
        --ex-container-hostname "$container_hostname" \
        --ex-container-image "$container_image" \
        --ex-override-starttime "$start_time" \
        --ex-print-github-release-table-row

    if [[ $? != 0 ]]; then
        die "Failed to build"
    fi
}

function step_checkout_branch() {
    branch="$1"
    git checkout $branch
}

function step_update_submodules() {
    git submodule sync
    git submodule update --init --recursive
}

function step_test_environment() {
    if [[ $(id -u) != 0 ]]; then
        die "Unauthorized (are you root?)"
    fi
}

shift

case $step in
    "build-tree") step_build_tree $1 $2 ;;
    "checkout-branch") step_checkout_branch $1 $2 ;;
    "test-environment") step_test_environment ;;
    "update-submodules") step_update_submodules ;;
    *)
        die "Step '$step' does not exist"
esac
