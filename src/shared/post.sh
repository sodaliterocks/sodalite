#!/usr/bin/env bash

echo "--------------------------------------------------------------------------------"

# Utilities

function check_variable() {
    variable="$1"
    fallback_value="$2"

    if [[ $(echo "$(eval echo "\$${variable}")") == "" ]]; then
        if [[ $fallback_value != "" ]]; then
            eval "${variable}"='${fallback_value}'
        else
            exit 1
        fi
    fi
}

function del_property() {
    file=$1
    property=$2

    if [[ -f $file ]]; then
        if [[ ! -z $(get_property $file $property) ]]; then
            sed -i "s/^\($property=.*\)$//g" $file
        fi
    fi
}

function emj() {
    emoji="$1"
    emoji_length=${#emoji}
    echo "$emoji$(eval "for i in {1..$emoji_length}; do echo -n " "; done")"
}

function get_property() {
    file=$1
    property=$2

    if [[ -f $file ]]; then
        echo $(grep -oP '(?<=^'"$property"'=).+' $file | tr -d '"')
    fi
}

function set_property() {
    file=$1
    property=$2
    value=$3

    if [[ -f $file ]]; then
        if [[ -z $(get_property $file $property) ]]; then
            echo "$property=\"$value\"" >> $file
        else
            if [[ $value =~ [[:space:]]+ ]]; then
                value="\"$value\""
            fi

            sed -i "s/^\($property=\)\(.*\)$/\1$value/g" $file
        fi
    fi
}

# Variables

_buildinfo_file="/usr/lib/sodalite-buildinfo"
_core_file="/usr/lib/sodalite-core"
_post_scripts_dir="/usr/libexec/sodalite-post"

_git_hash=""
_git_tag=""
_os_base_version=""
_os_core=""
_os_ref=""
_os_version=""
_os_version_id=""
_os_variant=""
_vendor=""

# Setup

declare -a ran_scripts

[[ -f "$_core_file" ]] && _os_core="$(cat "$_core_file")"
[[ $(cat /usr/lib/fedora-release) =~ ([0-9]{2}) ]] && _os_base_version="${BASH_REMATCH[1]}"

if [[ $(cat $_buildinfo_file) != "" ]]; then
    [[ ! -z $(get_property $_buildinfo_file "GIT_COMMIT") ]] && \
        _git_hash="$(get_property $_buildinfo_file "GIT_COMMIT")"

    [[ ! -z $(get_property $_buildinfo_file "GIT_TAG") ]] && \
        _git_tag="$(get_property $_buildinfo_file "GIT_TAG")"

    [[ ! -z $(get_property $_buildinfo_file "OS_REF") ]] && \
        _os_variant="$(get_property $_buildinfo_file "OS_REF")"

    [[ ! -z $(get_property $_buildinfo_file "OS_VARIANT") ]] && \
        _os_variant="$(get_property $_buildinfo_file "OS_VARIANT")"

    [[ ! -z $(get_property $_buildinfo_file "VENDOR") ]] && \
        _vendor="$(get_property $_buildinfo_file "VENDOR")"
fi

check_variable "_git_hash" "0000000"
check_variable "_os_base_version"
check_variable "_os_core" "pantheon"
check_variable "_os_ref"
check_variable "_os_variant"
check_variable "_vendor" "self"

set -euo pipefail

# Runner

for post_script in $_post_scripts_dir/*.sh; do
    post_script_name="$(basename "$post_script" | sed s/.sh//)"

    echo -e "$(emj "⚙️")Running script: $post_script_name"
    chmod +x "$post_script"
    . "$post_script"

    if [[ $? != "0" ]]; then
        exit $?
    else
        ran_scripts+=("$post_script_name")
    fi
done

rm -rf $_post_scripts_dir

echo "--------------------------------------------------------------------------------"

