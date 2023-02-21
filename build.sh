#!/usr/bin/env bash

_PLUGIN_TITLE="Sodalite Builder"
_PLUGIN_DESCRIPTION=""
_PLUGIN_OPTIONS=(
    "variant;v;\tVariant of Sodalite (from ./src/treefiles/sodalite-*.yaml)"
    "container;c;Build tree inside Podman container"
    "working-dir;w;Directory to output build artifacts to"
    "buildinfo-anon;;Do not print sensitive information into buildinfo file"
    "ci;;\t\tUse remote Git repository when building with --container"
    "ci-branch;;\tBranch to use when building with --ci"
    "skip-cleanup;;Skip cleaning up (removing useless files, fixing permissions) on exit"
    "skip-tests;;\tSkip executing tests"
    "unified-core;;Use --unified-core option with rpm-ostree"
)
_PLUGIN_ROOT="true"

build_meta_dir=""
buildinfo_file=""
git_commit=""
git_tag=""
failed="false"
lockfile=""
ostree_cache_dir=""
ostree_repo_dir=""
ref=""
src_dir=""
tests_dir=""
treefile=""
vendor=""

start_time=$(date +%s)

# Utilities

function build_die() {
    say error "$@"
    cleanup
    exit 255
}

function build_emj() {
    if [[ -f /.sodalite-containerenv ]]; then
        echo "$1 "
    else
        echo $(emj "$1")
    fi
}

function cleanup() {
    if [[ "$skip_cleanup" == "" ]]; then
        say primary "$(build_emj "🗑️")Cleaning up..."

        rm -f "$buildinfo_file"
        rm -rf /var/tmp/rpm-ostree.*

        if [[ $SUDO_USER != "" ]]; then
            chown -R $SUDO_USER:$SUDO_USER "$working_dir"
        fi
    else
        say warning "Not cleaning up (--skip-cleanup used)"
    fi
}

function get_variant_file() {
    passed_variant="$variant"
    computed_variant=""
    treefile_dir="$src_dir/src/treefiles"

    if [[ -f "$treefile_dir/sodalite-desktop-$passed_variant.yaml" ]]; then
        computed_variant="desktop-$passed_variant"
    else
        [[ $passed_variant == *.yaml ]] && passed_variant="$(echo $passed_variant | sed s/.yaml//)"
        [[ $passed_variant == sodalite* ]] && passed_variant="$(echo $passed_variant | sed s/sodalite-//)"

        computed_variant="$passed_variant"
    fi

    echo "$treefile_dir/sodalite-$computed_variant.yaml"
}

function nudo() { # "Normal User DO"
    cmd="$@"
    eval_cmd="$cmd"

    if [[ $SUDO_USER != "" ]]; then
        eval_cmd="sudo -E -u $SUDO_USER $eval_cmd"
    fi

    eval "$eval_cmd"
}

function ost() {
    command=$1
    options="${@:2}"

    if [[ -z $ostree_repo_dir ]]; then
        die "\$ostree_repo_dir not set"
    fi

    ostree $command --repo="$ostree_repo_dir" $options
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

    output=""

    [[ $h != "0" ]] && output+="$h $h_string"
    [[ $m != "0" ]] && output+=" $m $m_string"
    [[ $s != "0" ]] && output+=" $s $s_string"

    echo $output
}

# Main Functions

function build_sodalite() {
    say primary "$(build_emj "🪛")Setting up..."

    if [[ ! -f "$(get_variant_file)" ]]; then
        build_die "'sodalite-$variant.yaml' does not exist"
    else
        treefile="$(get_variant_file)"
    fi

    [[ $unified != "true" ]] && unified="false"

    buildinfo_file="$src_dir/src/sysroot/common/usr/lib/sodalite-buildinfo"
    lockfile="$src_dir/src/shared/overrides.yaml"
    ostree_cache_dir="$working_dir/cache"
    ostree_repo_dir="$working_dir/repo"

    ref="$(echo "$(cat "$treefile")" | grep "ref:" | sed "s/ref: //" | sed "s/\${basearch}/$(uname -m)/")"

    mkdir -p $ostree_cache_dir
    mkdir -p $ostree_repo_dir

    if [ ! "$(ls -A $ostree_repo_dir)" ]; then
        say primary "$(build_emj "🆕")Initializing OSTree repository..."
        ost init --mode=archive
    fi

    if [[ $(command -v "git") ]]; then
        if [[ -d "$src_dir/.git" ]]; then
            git config --global --add safe.directory $src_dir

            git_commit=$(git -C $src_dir rev-parse --short HEAD)
            git_origin_url="$(git config --get remote.origin.url)"

            if [[ "$(git -C $src_dir status --porcelain --untracked-files=no)" == "" ]]; then
                git_tag="$(git -C $src_dir describe --exact-match --tags $(git -C $src_dir log -n1 --pretty='%h') 2>/dev/null)"
            fi

            if [[ "$git_origin_url" != "" ]]; then
                if [[ "$git_origin_url" =~ ([a-zA-Z0-9.-_]+\@[a-zA-Z0-9.-_]+:([a-zA-Z0-9.-_]+)\/([a-zA-Z0-9.-_]+).git) ]]; then
                    vendor="${BASH_REMATCH[2]}"
                elif [[ "$git_origin_url" =~ (https:\/\/github.com\/([a-zA-Z0-9.-_]+)\/([a-zA-Z0-9.-_]+).git) ]]; then
                    vendor="${BASH_REMATCH[2]}"
                fi
            fi

            say primary "$(build_emj "🗑️")Cleaning up Git repository..."
            nudo git fetch --prune
            nudo git fetch --prune-tags
        fi
    fi

    if [[ $git_commit != "" ]]; then
        build_meta_dir="$working_dir/meta/$git_commit"
    else
        build_meta_dir="$working_dir/meta/nogit"
    fi

    mkdir -p $build_meta_dir

    say primary "$(build_emj "📝")Generating buildinfo file (/usr/lib/sodalite-buildinfo)..."

    buildinfo_build_host_kernel="$(uname -srp)"
    buildinfo_build_host_name="$(hostname -f)"
    buildinfo_build_host_os="$(cat /usr/lib/os-release | grep "PRETTY_NAME" | sed "s/PRETTY_NAME=//" | tr -d '"')"
    buildinfo_build_tool="rpm-ostree $(echo "$(rpm-ostree --version)" | grep "Version:" | sed "s/ Version: //" | tr -d "'")+$(echo "$(rpm-ostree --version)" | grep "Git:" | sed "s/ Git: //")"

    if [[ $buildinfo_anon == "true" ]]; then
        buildinfo_build_host_kernel="(Undisclosed)"
        buildinfo_build_host_name="(Undisclosed)"
        buildinfo_build_host_os="(Undisclosed)"
        buildinfo_build_tool="(Undisclosed)"
    fi

    buildinfo_content="AWESOME=\"Yes\"
\nBUILD_DATE=\"$(date +"%Y-%m-%d %T %z")\"
\nBUILD_HOST_KERNEL=\"$buildinfo_build_host_kernel\"
\nBUILD_HOST_NAME=\"$buildinfo_build_host_name\"
\nBUILD_HOST_OS=\"$buildinfo_build_host_os\"
\nBUILD_TOOL=\"$buildinfo_build_tool\"
\nGIT_COMMIT=$git_commit
\nGIT_TAG=$git_tag
\nOS_REF=\"$ref\"
\nOS_UNIFIED=$unified
\nOS_VARIANT=\"$variant\"
\nVENDOR=\"$vendor\""

    echo -e $buildinfo_content > $buildinfo_file
    cat $buildinfo_file

    say primary "$(build_emj "⚡")Building tree..."

    compose_args="--repo=\"$ostree_repo_dir\""
    [[ $ostree_cache_dir != "" ]] && compose_args+=" --cachedir=\"$ostree_cache_dir\""
    [[ -s $lockfile ]] && compose_args+=" --ex-lockfile=\"$lockfile\""
    [[ $unified == "true" ]] && compose_args+=" --unified-core"

    eval "rpm-ostree compose tree $compose_args $treefile"

    [[ $? != 0 ]] && failed="true"
}

function test_sodalite() {
    tests_dir="$src_dir/tests"
    test_failed_count=0

    if [[ -d $tests_dir ]]; then
        if (( $(ls -A "$tests_dir" | wc -l) > 0 )); then
            say primary "$(build_emj "🧪")Testing tree..."

            all_commits="$(ost log $ref | grep "commit " | sed "s/commit //")"
            commit="$(echo "$all_commits" | head -1)"
            commit_prev="$(echo "$all_commits" | head -2 | tail -1)"

            [[ $commit == $commit_prev ]] && commit_prev=""

            for test_file in $tests_dir/*.sh; do
                export -f ost

                result=$(. "$test_file" 2>&1)

                if [[ $? -ne 0 ]]; then
                    test_message_prefix="Error"
                    test_message_color="33"
                    ((test_failed_count++))
                else
                    if [[ $result != "true" ]]; then
                        test_message_prefix="Fail"
                        test_message_color="31"
                        ((test_failed_count++))
                    else
                        test_message_prefix="Pass"
                        test_message_color="32"
                    fi
                fi

                say "   ⤷ \033[0;${test_message_color}m${test_message_prefix}: $(basename "$test_file" | cut -d. -f1)\033[0m"

                if [[ $result != "true" ]]; then
                    if [[ ! -z $result ]] && [[ $result != "false" ]]; then
                        say "     \033[0;37m${result}\033[0m"
                    fi
                fi
            done
        fi
    fi

    if (( $test_failed_count > 0 )); then
        say error "Failed to satisfy tests ($test_failed_count failed). Removing commit '$commit'..."
        failed="true"

        if [[ -z $commit_prev ]]; then
            ost refs --delete $ref
        else
            ost reset $ref $commit_prev
        fi
    else
        say primary "$(build_emj "✏️")Generating OSTree summary..."
        ost summary --update
    fi
}

# Entrypoint

function main() {
    if [[ ! $(command -v "rpm-ostree") ]]; then
        die "rpm-ostree not installed. Cannot build"
    fi

    src_dir="$(realpath -s "$base_dir/../../..")"
    [[ ! -d $src_dir ]] && build_die "Unable to compute source directory"

    [[ "$ci" != "" && "$container" == "" ]] && die "--ci cannot be used without --container"
    [[ "$ci_branch" != "" && "$ci" == "" ]] && die "--ci-branch cannot be used without --ci"
    [[ "$skip_test" != "" && "$ci" != "" ]] && die "--skip-test cannot be used with --ci"

    { [[ "$ci_branch" == "true" ]] || [[ -z "$ci_branch" ]] } && ci_branch="devel"
    { [[ "$working_dir" == "true" ]] || [[ -z "$working_dir" ]] } && working_dir="$src_dir/build"
    { [[ "$variant" == "true" ]] || [[ -z "$variant" ]] } && variant="custom"

    [[ ! -d "$working_dir" ]] && mkdir -p "$working_dir"
    chown -R root:root "$working_dir"

    if [[ $container == "true" ]]; then # BUG: Podman sets $container (usually to "oci"), so we need to look for "true" instead
        if [[ $(command -v "podman") ]]; then
            container_hostname="$(hostname)"
            container_name="sodalite_$(date +%s)"
            container_image="fedora:37"

            container_build_args="--working-dir /wd/out"
            [[ $skip_cleanup != "" ]] && container_build_args+=" --skip-cleanup $skip_cleanup"
            [[ $skip_test != "" ]] && container_build_args+=" --skip-test $skip_test"
            [[ $variant != "" ]] && container_build_args+=" --variant $variant"
            [[ $unified_core != "" ]] && container_build_args+=" --unified-core $unified_core"

            [[ ! -z "$SODALITE_BUILD_CONTAINER_HOSTNAME" ]] && container_hostname="$SODALITE_BUILD_CONTAINER_HOSTNAME"
            [[ ! -z "$SODALITE_BUILD_CONTAINER_IMAGE" ]] && container_image="$SODALITE_BUILD_CONTAINER_IMAGE"

            container_args="run --rm --privileged \
                --hostname \"$container_hostname\" \
                --name \"$container_name\" \
                --volume \"$working_dir:/wd/out/\" "
            container_command="touch /.sodalite-containerenv;"
            container_command+="dnf install -y git-core git-lfs hostname rpm-ostree selinux-policy selinux-policy-targeted policycoreutils;"

            if [[ $ci == "true" ]]; then
                #[[ $(git show-ref refs/heads/$ci_branch) == "" ]] && build_die "Branch '$ci_branch' does not exist"
                container_command+="git clone --recurse-submodules -b $ci_branch https://github.com/sodaliterocks/sodalite.git /wd/src;"
            else
                container_args+="--volume \"$src_dir:/wd/src\" "
            fi

            container_command+="cd /wd/src; /wd/src/build.sh $container_build_args;"
            container_args+="$container_image /bin/bash -c \"$container_command\""

            say primary "$(build_emj "⬇️")Pulling container image ($container_image)..."
            podman pull $container_image

            say primary "$(build_emj "📦")Executing container ($container_name)..."
            eval "podman $container_args"
        else
            die "$(hostname) Podman not installed. Cannot build with --container"
        fi
    else
        build_sodalite
        if [[ $failed == "false" && "$skip_tests" == "" ]]; then
            test_sodalite
        fi

        cleanup
        end_time=$(( $(date +%s) - $start_time ))

        if [[ $failed == "false" ]]; then
            highscore="false"
            highscore_file="$build_meta_dir/highscore"
            prev_highscore=""

            if [[ ! -f "$highscore_file" ]]; then
                touch "$highscore_file"
                echo "$end_time" > "$highscore_file"
            else
                prev_highscore="$(cat "$highscore_file")"
                if (( $end_time < $prev_highscore )); then
                    highscore="true"
                    echo "$end_time" > "$highscore_file"
                fi
            fi

            say primary "$(build_emj "✅")Success ($(print_time $end_time))"
            [[ $highscore == "true" ]] && echo "$(build_emj "🏆") You're Winner (previous: $(print_time $prev_highscore))!"
        else
            say "\033[1;31m$(build_emj "💥")Fail ($(print_time $end_time))"
            exit 255
        fi
    fi

    exit 0
}

# Hacks Invoker

if [[ $SODALITE_HACKS_INVOKED != "true" ]]; then
    hacks_dir="$(dirname "$(realpath -s "$0")")/lib/sodaliterocks.hacks"

    if [[ -f "$hacks_dir/src/hacks.sh" ]]; then
        "$hacks_dir"/src/hacks.sh $0 $@
    else
        git submodule update --init "$hacks_dir"

        if [[ $? -ne 0 ]]; then
            build_die "Unable to pull required submodule"
        fi
    fi
fi
