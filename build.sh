#!/usr/bin/env bash
# Usage: ./build.sh [<variant>] [<working-dir>]

. "$(dirname "$(realpath -s "$0")")/lib/sodaliterocks.common/bash/common.sh"

base_dir="$(dirname "$(realpath -s "$0")")"
variant=$1
working_dir=$2

test_root

echo "🪛 Setting up..."

[[ $variant == *.yaml ]] && variant="$(echo $variant | sed s/.yaml//)"
[[ $variant == sodalite* ]] && variant="$(echo $variant | sed s/sodalite-//)"
[[ $variant == "fedora-sodalite" ]] && variant="legacy" # BUG: Kinda breaks various messages but whatever
[[ -z $variant ]] && variant="custom"
[[ -z $working_dir ]] && working_dir="$base_dir/build"

treefile="$base_dir/src/sodalite-$variant.yaml"
[[ $variant == "legacy" ]] && treefile="$base_dir/src/fedora-sodalite.yaml"

if [[ ! -f $treefile ]]; then
    echoc error "sodalite-$variant does not exist"
    exit
fi

lockfile="$base_dir/src/common/overrides.yaml"

ostree_cache_dir="$working_dir/cache"
ostree_repo_dir="$working_dir/repo"
mkdir -p $ostree_cache_dir
mkdir -p $ostree_repo_dir

chown -R root:root $working_dir

if [ ! "$(ls -A $ostree_repo_dir)" ]; then
   echo "🆕 Initializing OSTree repository at '$ostree_repo_dir'..."
   ostree --repo="$ostree_repo_dir" init --mode=archive
fi

echo "📄 Generating buildinfo file..."

# Only put stuff in here that we actually need!
buildinfo_file="$base_dir/src/sysroot/usr/lib/sodalite-buildinfo"
buildinfo_content="COMMIT=$(git rev-parse --short HEAD)
\nTAG=$(git describe --exact-match --tags $(git log -n1 --pretty='%h') 2>/dev/null)
\nVARIANT=\"$variant\""

echo -e $buildinfo_content > $buildinfo_file

echo "⚡ Building tree..."
echo "================================================================================"

rpm-ostree compose tree \
    --cachedir="$ostree_cache_dir" \
    --repo="$ostree_repo_dir" \
    `[[ -s $lockfile ]] && echo "--ex-lockfile="$lockfile""` $treefile

echo "================================================================================"

if [[ $? != 0 ]]; then
    echoc error "Failed to build tree"
else
    echo "✏️ Generating summary..."
    ostree summary --repo="$ostree_repo_dir" --update
fi

echo "🗑️ Cleaning up..."

rm "$base_dir/src/sysroot/usr/lib/sodalite-buildinfo"
rm -rf  /var/tmp/rpm-ostree.*

# TODO: Get owner and perms of parent directory
real_user=$(get_sudo_user)
chown -R $real_user:$real_user $working_dir
