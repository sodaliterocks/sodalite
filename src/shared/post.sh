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

function get_buildopt() {
    option="$1"

    if [ ! -z $(grep "$option" "/common/usr/lib/sodalite-buildopts") ]; then
        echo true
    else
        echo false
    fi
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
_post_scripts_dir="/usr/libexec/sodalite/post-build"

_git_hash=""
_git_tag=""
_naked_build="false"
_os_arch=""
_os_base_version=""
_os_core=""
_os_ref=""
_os_version=""
_os_version_id=""
_os_variant=""
_vendor=""

# Setup

if [[ ! -f $_buildinfo_file ]]; then
    _naked_build="true"
else
    if [[ "$(cat $_buildinfo_file)" == "" ]]; then
        _naked_build="true"
    fi
fi

if [[ $_naked_build == "true" ]]; then
    echo ""
    echo " ############################################################ "
    echo " #                                                          # "
    echo " #   Building Sodalite without build.sh is not supported!   # "
    echo " #                     We did warn you.                     # "
    echo " #                                                          # "
    echo " ############################################################ "
    echo ""

    exit 255
fi

declare -a ran_scripts

[[ -f "$_core_file" ]] && _os_core="$(cat "$_core_file")"
[[ $(cat /usr/lib/fedora-release) =~ ([0-9]{2}) ]] && _os_base_version="${BASH_REMATCH[1]}"

if [[ $(cat $_buildinfo_file) != "" ]]; then
    [[ ! -z $(get_property $_buildinfo_file "GIT_COMMIT") ]] && \
        _git_hash="$(get_property $_buildinfo_file "GIT_COMMIT")"

    [[ ! -z $(get_property $_buildinfo_file "GIT_TAG") ]] && \
        _git_tag="$(get_property $_buildinfo_file "GIT_TAG")"

    [[ ! -z $(get_property $_buildinfo_file "TREE_REF") ]] && \
        _os_ref="$(get_property $_buildinfo_file "TREE_REF")"

    [[ ! -z $(get_property $_buildinfo_file "TREE_REF_ARCH") ]] && \
        _os_arch="$(get_property $_buildinfo_file "TREE_REF_ARCH")"

    [[ ! -z $(get_property $_buildinfo_file "TREE_REF_CHANNEL") ]] && \
        _os_channel="$(get_property $_buildinfo_file "TREE_REF_CHANNEL")"

    [[ ! -z $(get_property $_buildinfo_file "TREE_REF_VARIANT") ]] && \
        _os_variant="$(get_property $_buildinfo_file "TREE_REF_VARIANT")"

    [[ ! -z $(get_property $_buildinfo_file "VENDOR") ]] && \
        _vendor="$(get_property $_buildinfo_file "VENDOR")"
fi

check_variable "_git_hash" "0000000"
check_variable "_os_arch"
check_variable "_os_base_version"
check_variable "_os_channel"
check_variable "_os_core" "pantheon"
check_variable "_os_ref"
check_variable "_os_variant"
check_variable "_vendor" "unknown-vendor"

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

