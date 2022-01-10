#!/usr/bin/env bash

. "$(dirname "$(realpath -s "$0")")/src/include/tools/common.sh"

base_dir="$(dirname "$(realpath -s "$0")")"
variant=$1
working_dir=$2

test_root

[[ $variant == *.yaml ]] && variant="$(echo $variant | sed s/.yaml//)"
[[ $variant == sodalite* ]] && variant="$(echo $variant | sed s/sodalite-//)"
[[ $variant == "fedora-sodalite" ]] && variant="legacy" # BUG: Kinda breaks various messages but whatever
[[ -z $variant ]] && variant="base"
[[ -z $working_dir ]] && working_dir="$base_dir/build"

treefile="$base_dir/src/sodalite-$variant.yaml"
[[ $variant == "legacy" ]] & treefile="$base_dir/src/fedora-sodalite.yaml"

if [[ ! -f $treefile ]]; then
    echoc error "sodalite-$variant does not exist"
    exit
fi

ostree_cache_dir="$working_dir/cache"
ostree_repo_dir="$working_dir/repo"
mkdir -p $ostree_cache_dir
mkdir -p $ostree_repo_dir

chown -R root:root $working_dir

if [ ! "$(ls -A $ostree_repo_dir)" ]; then
   echoc "$(write_emoji "🆕")Initializing OSTree repository at '$ostree_repo_dir'..."
   ostree --repo="$ostree_repo_dir" init --mode=archive
fi

echoc "$(write_emoji "⚡")Building tree for sodalite-$variant..."
rpm-ostree compose tree \
    --unified-core \
    --cachedir="$ostree_cache_dir" \
    --repo="$ostree_repo_dir" \
    $treefile

if [[ $? != 0 ]]; then
    echoc error "Failed to build tree"
else
    echoc "$(write_emoji "✏️")Generating summary for sodalite-$variant..."
    ostree summary --repo="$ostree_repo_dir" --update
fi

# TODO: Get owner and perms of parent directory
echoc "$(write_emoji "🛡️")Correcting permissions for build directory..."
real_user=$(get_sudo_user)
chown -R $real_user:$real_user $working_dir
