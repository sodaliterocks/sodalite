#!/usr/bin/env bash

_PLUGIN_TITLE="Sodalite Builder"
_PLUGIN_DESCRIPTION=""
_PLUGIN_OPTIONS=(
    "tree;t;\tTreefile from ./src/treefiles (default: custom)"
    "container;c;Build tree inside Podman container"
    "working-dir;w;Directory to output build artifacts to (default: ./build)"
    "buildinfo-anon;;Do not print sensitive information into buildinfo file"
    "skip-cleanup;;Skip cleaning up on exit"
    "skip-tests;;\tSkip executing tests"
    "unified-core;;Use --unified-core option with rpm-ostree"
    "vendor;;\tVendor to use in CPE (default: \$USER)"
    "ex-container-args;;"
    "ex-container-hostname;;"
    "ex-container-image;;"
    "ex-log;;"
    "ex-ntfy;;"
    "ex-ntfy-endpoint;;"
    "ex-ntfy-password;;"
    "ex-ntfy-topic;;"
    "ex-ntfy-username;;"
    "ex-remote-version;;"
    "ex-remote-version-branch;;"
    "ex-override-starttime;;"
    "ex-test-print;;"
)
_PLUGIN_ROOT="true"

build_log_dir=""
build_log_file=""
build_log_filename=""
build_meta_dir=""
buildinfo_file=""
built_commit=""
built_version=""
git_commit=""
git_tag=""
lockfile=""
ostree_cache_dir=""
ostree_repo_dir=""
ref=""
ref_arch=""
ref_channel=""
ref_variant=""
start_time=""
src_dir=""
tests_dir=""
treefile=""

# Utilities

function build_die() {
    exit_code=255
    message="$@"

    say error "$message"
    cleanup
    trigger_ntfy $exit_code

    [[ $ex_log != "" ]] && say error "$message" >&3

    exit $exit_code
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
            if [[ -d "$working_dir" ]]; then
                chown -R $SUDO_USER:$SUDO_USER "$working_dir"
            fi
        fi
    else
        say warning "Not cleaning up (--skip-cleanup used)"
    fi
}

function get_treefile() {
    passed_tree="$tree"
    computed_tree=""
    treefile_dir="$src_dir/src/treefiles"

    if [[ -f "$treefile_dir/sodalite-desktop-$passed_tree.yaml" ]]; then
        computed_variant="desktop-$passed_tree"
    else
        [[ $passed_tree == *.yaml ]] && passed_tree="$(echo $passed_tree | sed s/.yaml//)"
        [[ $passed_tree == sodalite* ]] && passed_tree="$(echo $passed_tree | sed s/sodalite-//)"

        computed_tree="$passed_tree"
    fi

    echo "$treefile_dir/sodalite-$computed_tree.yaml"
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
        build_die "\$ostree_repo_dir not set"
    fi

    ostree $command --repo="$ostree_repo_dir" $options
}

function print_log_header() {
    print_separator="$1"

    header="🕒 $(date --date="@$start_time" "+%Y-%m-%d %H:%M:%S %Z") • 📄 $tree • 🖥️ $(hostname -f)"
    header_length=$((${#header} + 1))

    echo "$header"
    [[ $print_separator != "false" ]] && echo "$(repeat "-" $header_length)"
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

function trigger_ntfy() {
    exit_code=$1

    [[ $exit_code == "" ]] && exit_code=0

    if [[ $ex_ntfy != "" ]]; then
        [[ "$ex_ntfy_topic" = "" ]] && ex_ntfy_topic="sodalite"

        title="Sodalite ("

        if [[ $ref_channel != "" ]]; then
            title+="$ref_channel:"
        else
            title+="?:"
        fi

        if [[ $ref_variant != "" ]]; then
            title+="$ref_variant"
        else
            title+="?"
        fi

        title+=") — "

        if [[ $exit_code != 0 ]]; then
            title+="💥 Fail"
        else
            title+="✅ "

            if [[ $built_version != "" ]]; then
                title+=" $built_version"
            else
                title+=" Success"
            fi
        fi

        [[ -f "$build_log_file" ]] && cp "$build_log_file" "${build_log_file}_copy"

        say primary "$(build_emj "💬")Sending notification ($ex_ntfy_endpoint/$ex_ntfy_topic)..."

        if [[ -f "$build_log_file" ]]; then
            curl \
                -u "$ex_ntfy_username:$ex_ntfy_password" \
                -T "${build_log_file}_copy" \
                -H "Filename: $build_log_filename" \
                -H "Title: $title" \
                "$ex_ntfy_endpoint/$ex_ntfy_topic"

            rm "${build_log_file}_copy"
        else
            curl \
                -u "$ex_ntfy_username:$ex_ntfy_password" \
                -H "Title: $title" \
                -d "$(print_log_header false)" \
                "$ex_ntfy_endpoint/$ex_ntfy_topic"
        fi
    fi
}

# Main Functions

function build_sodalite() {
    say primary "$(build_emj "🪛")Setting up..."

    if [[ ! -f "$(get_treefile)" ]]; then
        build_die "'sodalite-$tree.yaml' does not exist"
    else
        treefile="$(get_treefile)"
    fi

    [[ $unified_core == "true" ]] && unified="true"

    buildinfo_file="$src_dir/src/sysroot/common/usr/lib/sodalite-buildinfo"
    lockfile="$src_dir/src/shared/overrides.yaml"
    ostree_cache_dir="$working_dir/cache"
    ostree_repo_dir="$working_dir/repo"

    ref="$(echo "$(cat "$treefile")" | grep "ref:" | sed "s/ref: //" | sed "s/\${basearch}/$(uname -m)/")"

    if [[ $ref =~ sodalite\/([^;]*)\/([^;]*)\/([^;]*) ]]; then
        ref_channel="${BASH_REMATCH[1]}"
        ref_arch="${BASH_REMATCH[2]}"
        ref_variant="${BASH_REMATCH[3]}"
    else
        build_die "Ref is an invalid format (should be 'sodalite/<channel>/<arch>/<variant>'; is '$ref')"
    fi

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
    buildinfo_build_host_os="$(get_property /usr/lib/os-release "PRETTY_NAME")"
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
\nOS_ARCH=\"$ref_arch\"
\nOS_CHANNEL=\"$ref_channel\"
\nOS_REF=\"$ref\"
\nOS_UNIFIED=$unified
\nOS_VARIANT=\"$ref_variant\"
\nVENDOR=\"$vendor\""

    echo -e $buildinfo_content > $buildinfo_file
    cat $buildinfo_file

    say primary "$(build_emj "⚡")Building tree..."

    compose_args="--repo=\"$ostree_repo_dir\""
    [[ $ostree_cache_dir != "" ]] && compose_args+=" --cachedir=\"$ostree_cache_dir\""
    [[ -s $lockfile ]] && compose_args+=" --ex-lockfile=\"$lockfile\""
    [[ $unified == "true" ]] && compose_args+=" --unified-core"

    eval "rpm-ostree compose tree $compose_args $treefile"

    [[ $? != 0 ]] && build_die "Failed to build tree"
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
        build_die "Failed to satisfy tests ($test_failed_count failed). Removing commit '$commit'..."

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
    src_dir="$(realpath -s "$base_dir/../../..")"
    me_filename="$(basename "$plugin")"

    [[ ! -d $src_dir ]] && build_die "Unable to compute source directory"

    [[ "$ex_ntfy_endpoint" == "true" ]] && build_die "--ex-ntfy-endpoint needs a value (example: https://ntfy.myserver.com)"
    [[ "$ex_ntfy_password" == "true" ]] && build_die "--ex-ntfy-password needs a value (example: abc123XYZ)"
    [[ "$ex_ntfy_topic" == "true" ]] && build_die "--ex-ntfy-topic needs a value (example: sodalite)"
    [[ "$ex_ntfy_username" == "true" ]] && build_die "--ex-ntfy-username needs a value (example: theduckster)"
    [[ "$ex_override_starttime" == "true" ]] && build_die "--ex-override-starttime needs a value (example: 1640551980)"

    [[ "$ex_remote_version_branch" == "true" ]] || [[ -z "$ex_remote_version_branch" ]] && ex_remote_version_branch="main"
    [[ "$tree" == "true" ]] || [[ -z "$tree" ]] && tree="custom"
    [[ "$working_dir" == "true" ]] || [[ -z "$working_dir" ]] && working_dir="$src_dir/build"

    if [[ "$vendor" == "true" ]] || [[ -z "$vendor" ]]; then
        if [[ $SUDO_USER != "" ]]; then
            vendor="$SUDO_USER"
        else
            vendor="$USER"
        fi

        if [[ $vendor == "root" ]]; then
            vendor="unknown"
        fi
    fi

    [[ ! -d "$working_dir" ]] && mkdir -p "$working_dir"

    if [[ $ex_remote_version != "" ]]; then
        online_file_branch="$(echo $ex_remote_version_branch | sed "s|/|__|g")"
        online_file="https://raw.githubusercontent.com/sodaliterocks/sodalite/main/build.sh"
        downloaded_file="$src_dir/$me_filename+$online_file_branch"

        me_md5sum="$(cat "$src_dir/$me_filename" | md5sum | cut -d ' ' -f1)"
        online_md5sum="$(curl -sL $online_file | md5sum | cut -d ' ' -f1)"

        if [[ $? == 0 ]]; then
            if [[ $me_md5sum != $online_md5sum ]]; then
                curl -sL $online_file > "$downloaded_file"
                chmod +x "$downloaded_file"

                say primary "$(emj "🌐")Executing remote version ($online_file_branch)..."

                bash -c "$downloaded_file $(echo $options | sed "s|--ex-remote-version||")"
                downloaded_file_result="$?"

                rm -f "$downloaded_file"
                exit $downloaded_file_result
            fi
        else
            build_die "Unable to check latest remote version of $me_filename"
        fi
    fi

    if [[ $ex_test_print  != "" ]]; then
        echo "3"
        exit 0
    fi

    if [[ $container == "true" ]]; then # BUG: Podman sets $container (usually to "oci"), so we need to look for "true" instead
        if [[ $(command -v "podman") ]]; then
            container_start_time=$(date +%s)

            container_name="sodalite-build_$(get_random_string 6)"
            container_hostname="$(echo $container_name | sed s/_/-/g)"
            container_image="fedora:37"

            container_build_args="--working-dir /wd/out"
            [[ $ex_log != "" ]] && container_build_args+=" --ex-log $ex_log"
            [[ $ex_ntfy != "" ]] && container_build_args+=" --ex-ntfy $ex_ntfy"
            [[ $ex_ntfy_endpoint != "" ]] && container_build_args+=" --ex-ntfy-endpoint $ex_ntfy_endpoint"
            [[ $ex_ntfy_password != "" ]] && container_build_args+=" --ex-ntfy-password $ex_ntfy_password"
            [[ $ex_ntfy_topic != "" ]] && container_build_args+=" --ex-ntfy-topic $ex_ntfy_topic"
            [[ $ex_ntfy_username != "" ]] && container_build_args+=" --ex-ntfy-username $ex_ntfy_username"
            [[ $skip_cleanup != "" ]] && container_build_args+=" --skip-cleanup $skip_cleanup"
            [[ $skip_test != "" ]] && container_build_args+=" --skip-test $skip_test"
            [[ $tree != "" ]] && container_build_args+=" --tree $tree"
            [[ $unified_core != "" ]] && container_build_args+=" --unified-core $unified_core"
            [[ $vendor != "" ]] && container_build_args+=" --vendor $vendor"

            if [[ $ex_override_starttime != "" ]]; then
                container_build_args+=" --ex-override-starttime $ex_override_starttime"
            else
                container_build_args+=" --ex-override-starttime $container_start_time"
            fi

            [[ ! -z "$ex_container_hostname" ]] && container_hostname="$ex_container_hostname"
            [[ ! -z "$ex_container_image" ]] && container_image="$ex_container_image"

            container_args="run --rm --privileged \
                --hostname \"$container_hostname\" \
                --name \"$container_name\" \
                --volume \"$working_dir:/wd/out/\" \
                --volume \"$src_dir:/wd/src\" "
            [[ $ex_conatiner_args != "" ]] && container_args+="$ex_container_args "
            container_command="touch /.sodalite-containerenv;"
            container_command+="dnf install -y curl git-core git-lfs hostname policycoreutils rpm-ostree selinux-policy selinux-policy-targeted;"

            container_command+="cd /wd/src; /wd/src/$me_filename $container_build_args;"
            container_args+="$container_image /bin/bash -c \"$container_command\""

            say primary "$(build_emj "⬇️")Pulling container image ($container_image)..."
            podman pull $container_image

            say primary "$(build_emj "📦")Executing container ($container_name)..."
            eval "podman $container_args"
        else
            build_die "Podman not installed. Cannot build with --container"
        fi
    else
        if [[ $ex_override_starttime == "" ]]; then
            start_time=$(date +%s)
        else
            start_time=$ex_override_starttime # TODO: Validate?
        fi

        build_log_dir="$working_dir/logs"
        build_log_filename="sodalite_${start_time}_${tree}_$(hostname -s).out"
        build_log_file="$build_log_dir/$build_log_filename"

        if [[ $ex_log != "" ]]; then
            mkdir -p "$build_log_dir"

            exec 3>&1 4>&2
            trap 'exec 2>&4 1>&3' 0 1 2 3
            exec 1>"$build_log_file" 2>&1

            print_log_header

            say warning "Logging to file ($build_log_file)" >&3
        else
            if [[ -d $build_log_dir ]]; then
                echo "$(print_log_header)" > $build_log_file
                echo "No output captured (use --ex-log)" >> $build_log_file
            fi
        fi

        chown -R root:root "$working_dir"

        if [[ ! $(command -v "rpm-ostree") ]]; then
            build_die "rpm-ostree not installed (try --container)"
        fi

        build_sodalite
        test_sodalite

        end_time=$(( $(date +%s) - $start_time ))
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

        cleanup

        echo "$(repeat "-" 80)"

        built_commit="$(echo "$(ost log $ref | grep "commit " | sed "s/commit //")" | head -1)"
        built_version="$(ost cat $built_commit /usr/lib/os-release | grep "OSTREE_VERSION=" | sed "s/OSTREE_VERSION=//" | sed "s/'//g")"

        say "$(build_emj "ℹ️")\033[1;35mName: \033[0;0m$(ost cat $built_commit /usr/lib/os-release | grep "PRETTY_NAME=" | sed "s/PRETTY_NAME=//" | sed "s/\"//g")"
        say "   \033[1;35mBase: \033[0;0m$(ost cat $built_commit /usr/lib/upstream-os-release | grep "PRETTY_NAME=" | sed "s/PRETTY_NAME=//" | sed "s/\"//g")"
        say "   \033[1;35mCPE: \033[0;0m$(ost cat $built_commit /usr/lib/system-release-cpe)"
        say "   \033[1;35mVersion: \033[0;0m$built_version"
        say "   \033[1;35mCommit: \033[0;0m$built_commit"

        echo "$(repeat "-" 80)"

        say primary "$(build_emj "✅")Success ($(print_time $end_time))"
        [[ $highscore == "true" ]] && echo "$(build_emj "🏆") You're Winner (previous: $(print_time $prev_highscore))!"

        trigger_ntfy
    fi

    exit 0
}

# Hacks Invoker

if [[ $SODALITE_HACKS_INVOKED != "true" ]]; then
    hacks_dir="$(dirname "$(realpath -s "$0")")/lib/sodaliterocks.hacks"

    if [[ ! -f "$hacks_dir/src/hacks.sh" ]]; then
        git submodule update --init "$hacks_dir"
    fi

    "$hacks_dir"/src/hacks.sh $0 $@
fi
