#!/usr/bin/env bash
# Usage: ./build.sh [<variant>] [<working-dir>]

base_dir="$(dirname "$(realpath -s "$0")")"
variant=$1
working_dir=$2
buildinfo_file="$base_dir/src/sysroot/usr/lib/sodalite-buildinfo"

function cleanup() {
    echo "🗑️ Cleaning up..."

    rm $buildinfo_file
    rm -rf  /var/tmp/rpm-ostree.*
    chown -R $SUDO_USER:$SUDO_USER $working_dir
}

function die() {
    echo -e "🛑 \033[1;31mError: $@\033[0m"
    cleanup
    exit 255
}

function print_time() {
    ((h=${1}/3600))
    ((m=(${1}%3600)/60))
    ((s=${1}%60))
    
    h_string="hours"
    m_string="minutes"
    s_string="seconds"
    
    [[ $h == 1 ]] && h_string="hour"
    [[ $m == 1 ]] && m_string="minute"
    [[ $s == 1 ]] && s_string="second"
    
    printf "%d $h_string %d $m_string %d $s_string\n" $h $m $s
}

if ! [[ $(id -u) = 0 ]]; then
    die "Permission denied (are you root?)"
fi

if [[ ! $(command -v "rpm-ostree") ]]; then
    die "rpm-ostree not installed"
fi

start_time=$(date +%s)
echo "🪛 Setting up..."
[[ $variant == *.yaml ]] && variant="$(echo $variant | sed s/.yaml//)"
[[ $variant == sodalite* ]] && variant="$(echo $variant | sed s/sodalite-//)"
[[ -z $variant ]] && variant="custom"
[[ -z $working_dir ]] && working_dir="$base_dir/build"

ostree_cache_dir="$working_dir/cache"
ostree_repo_dir="$working_dir/repo"
lockfile="$base_dir/src/common/overrides.yaml"
treefile="$base_dir/src/sodalite-$variant.yaml"

ref="$(echo "$(cat "$treefile")" | grep "ref:" | sed "s/ref: //" | sed "s/\${basearch}/$(uname -m)/")"

if [[ $(command -v "git") ]]; then
    if [[ -d "$base_dir/.git" ]]; then
        git config --global --add safe.directory $base_dir

        git_commit=$(git -C $base_dir rev-parse --short HEAD)
        git_tag=$(git -C $base_dir describe --exact-match --tags $(git -C $base_dir log -n1 --pretty='%h') 2>/dev/null)
    fi
fi

mkdir -p $ostree_cache_dir
mkdir -p $ostree_repo_dir
chown -R root:root $working_dir

if [[ ! -f $treefile ]]; then
    die "sodalite-$variant does not exist"
fi

if [ ! "$(ls -A $ostree_repo_dir)" ]; then
   echo "🆕 Initializing OSTree repository at '$ostree_repo_dir'..."
   ostree --repo="$ostree_repo_dir" init --mode=archive
fi

echo "📄 Generating buildinfo file..."

rpmostree_version="$(rpm-ostree --version)"

buildinfo_content="BUILD_DATE=\"$(date +"%Y-%m-%d %T %z")\"
\nBUILD_HOST_NAME=\"$(hostname -f)\"
\nBUILD_HOST_OS=\"$(cat /usr/lib/os-release | grep "PRETTY_NAME" | sed "s/PRETTY_NAME=//" | tr -d '"')\"
\nBUILD_HOST_KERNEL=\"$(uname -srp)\"
\nBUILD_RPMOSTREE=\"rpm-ostree $(echo "$rpmostree_version" | grep "Version:" | sed "s/ Version: //" | tr -d "'")+$(echo "$rpmostree_version" | grep "Git:" | sed "s/ Git: //")\"
\nGIT_COMMIT=$git_commit
\nGIT_TAG=$git_tag
\nREF=\"$ref\"
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
    tests_dir="$base_dir/tests"
    test_failed_count=0

    if [[ -d $tests_dir ]]; then
        if (( $(ls -A "$tests_dir" | wc -l) > 0 )); then
            echo "🧪 Testing tree..."

            commit="$(ostree --repo="$ostree_repo_dir" log $ref)" | grep commit | head -1 | sed "s/commit //"

            function ost() {
                command="$@"
                echo "$(ostree --repo="$ostree_repo_dir" $@)"
            }

            for test_file in $tests_dir/*.sh; do
                export -f ost

                result=$(. "$test_file" 2>&1)

                if [[ $result != "true" ]]; then
                    test_message_prefix="   Fail"
                    test_message_color="31"
                    ((test_failed_count++))
                else
                    test_message_prefix="Success"
                    test_message_color="32"
                fi

                echo -e "   ⤷ \033[0;${test_message_color}m${test_message_prefix}: $(basename "$test_file" | cut -d. -f1)\033[0m"
            done
        fi
    fi

    if (( $test_failed_count > 0 )); then
        ostree prune --repo="$ostree_repo_dir" --delete-commit="$commit"
        die "Failed to satisfy tests ($test_failed_count failed)"
    else
        echo "✏️ Generating summary..."
        ostree summary --repo="$ostree_repo_dir" --update
    fi
fi

cleanup

end_time=$(( $(date +%s) - $start_time ))
echo "✅ Success (took $(print_time $end_time))"
