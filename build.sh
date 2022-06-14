#!/usr/bin/env bash
# Usage: ./build.sh [<variant>] [<working-dir>]

variant=$1
working_dir=$2
base_dir="$(dirname "$(realpath -s "$0")")"
buildinfo_file="$base_dir/src/sysroot/usr/lib/sodalite-buildinfo"
tests_dir="$base_dir/tests"
start_time=$(date +%s)

function die() {
    echo -e "🛑 \033[1;31mError: $@\033[0m"
    cleanup
    exit 255
}

function cleanup() {
    echo "🗑️ Cleaning up..."

    rm -f $buildinfo_file
    rm -rf  /var/tmp/rpm-ostree.*
    chown -R $SUDO_USER:$SUDO_USER $working_dir
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

function ost() {
    command=$1
    options="${@:2}"

    if [[ -z $ostree_repo_dir ]]; then
        die "\$ostree_repo_dir not set"
    fi

    ostree $command --repo="$ostree_repo_dir" $options
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
   echo "🆕 Initializing OSTree repository..."
   ost init --mode=archive
fi

buildinfo_content="BUILD_DATE=\"$(date +"%Y-%m-%d %T %z")\"
\nBUILD_HOST_KERNEL=\"$(uname -srp)\"
\nBUILD_HOST_NAME=\"$(hostname -f)\"
\nBUILD_HOST_OS=\"$(cat /usr/lib/os-release | grep "PRETTY_NAME" | sed "s/PRETTY_NAME=//" | tr -d '"')\"
\nBUILD_TOOL=\"rpm-ostree $(echo "$(rpm-ostree --version)" | grep "Version:" | sed "s/ Version: //" | tr -d "'")+$(echo "$(rpm-ostree --version)" | grep "Git:" | sed "s/ Git: //")\"
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

[[ $build_failed == "true" ]] && die "Failed to build tree"

test_failed_count=0

if [[ -d $tests_dir ]]; then
    if (( $(ls -A "$tests_dir" | wc -l) > 0 )); then
        echo "🧪 Testing tree..."

        all_commits="$(ost log $ref | grep "commit " | sed "s/commit //")"
        commit="$(echo "$all_commits" | head -1)"
        commit_prev="$(echo "$all_commits" | head -2 | tail -1)"

        [[ $commit == $commit_prev ]] && commit_prev=""

        for test_file in $tests_dir/*.sh; do
            export -f ost

            result=$(. "$test_file" 2>&1)

            if [[ $result != "true" ]]; then
                test_message_prefix="Fail"
                test_message_color="31"
                ((test_failed_count++))
            else
                test_message_prefix="Pass"
                test_message_color="32"
            fi

            echo -e "   ⤷ \033[0;${test_message_color}m${test_message_prefix}: $(basename "$test_file" | cut -d. -f1)\033[0m"

            if [[ $result != "true" ]]; then
                if [[ ! -z $result ]] && [[ $result != "false" ]]; then
                    echo -e "     \033[0;37m${result}\033[0m"
                fi
            fi
        done
    fi
fi

if (( $test_failed_count > 0 )); then
    if [[ -z $commit_prev ]]; then
        ost refs --delete $ref
    else
        ost reset $ref $commit_prev
    fi

    die "Failed to satisfy tests ($test_failed_count failed). Removed commit '$commit'"
else
    echo "✏️ Generating summary..."
    ost summary --update
fi

cleanup

end_time=$(( $(date +%s) - $start_time ))
echo "✅ Success (took $(print_time $end_time))"
