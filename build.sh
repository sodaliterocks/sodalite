#!/usr/bin/env bash
# Usage: ./build.sh [<variant>] [<working-dir>]

base_dir="$(dirname "$(realpath -s "$0")")"
variant=$1
working_dir=$2

function die() {
    message=$@
    echo -e "\033[1;31mError: $message\033[0m"
    exit 255
}

if ! [[ $(id -u) = 0 ]]; then
    die "Permission denied (are you root?)"
fi

if [[ ! $(command -v "rpm-ostree") ]]; then
    die "rpm-ostree not installed"
fi

echo "🪛 Setting up..."

[[ $variant == *.yaml ]] && variant="$(echo $variant | sed s/.yaml//)"
[[ $variant == sodalite* ]] && variant="$(echo $variant | sed s/sodalite-//)"
[[ $variant == "fedora-sodalite" ]] && variant="legacy" # BUG: Kinda breaks various messages but whatever
[[ -z $variant ]] && variant="custom"
[[ -z $working_dir ]] && working_dir="$base_dir/build"

treefile="$base_dir/src/sodalite-$variant.yaml"
[[ $variant == "legacy" ]] && treefile="$base_dir/src/fedora-sodalite.yaml"

if [[ ! -f $treefile ]]; then
    die "sodalite-$variant does not exist"
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
    
[[ $? != 0 ]] && build_failed="true"

echo "================================================================================"

if [[ $build_failed == "true" ]]; then
    die "Failed to build tree"
else
    echo "✏️ Generating summary..."
    ostree summary --repo="$ostree_repo_dir" --update
fi

echo "🗑️ Cleaning up..."

rm "$base_dir/src/sysroot/usr/lib/sodalite-buildinfo"
rm -rf  /var/tmp/rpm-ostree.*
chown -R $SUDO_USER:$SUDO_USER $working_dir
