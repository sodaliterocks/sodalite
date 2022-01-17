#!/usr/bin/env bash

. "$(dirname "$(realpath -s "$0")")/lib/sodaliterocks.common/bash/common.sh"

base_dir="$(dirname "$(realpath -s "$0")")"
variant=$1
working_dir=$2

test_root

[[ -z $variant ]] && variant="custom"
[[ -z $working_dir ]] && working_dir="$base_dir/build"

mkdir -p $working_dir

cmd="dnf install -y rpm-ostree selinux-policy selinux-policy-targeted policycoreutils;"
cmd+="/wd/src/build.sh base /wd/out;"
cmd+="/wd/src/build.sh legacy /wd/out"

podman run --rm --privileged \
    --name "sodalite_$(date +"%y%m%d%H%M%S")" \
    -v $base_dir:/wd/src \
    -v $working_dir:/wd/out \
    fedora:latest /bin/bash -c "$cmd"

real_user=$(get_sudo_user)
chown -R $real_user:$real_user $working_dir
