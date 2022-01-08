#!/usr/bin/env bash

if [[ -f "$(dirname "$(realpath -s "$0")")/common.sh" ]]; then
    . "$(dirname "$(realpath -s "$0")")/common.sh"
else
    . /usr/libexec/sodalite-common
fi

#echoc "Updating Flatpak..."
#flatpak update --noninteractive --system

test_root

if [[ ! -f "/usr/libexec/sodalite-common" ]]; then
    echoc error "Not a Sodalite install"
    exit
fi

latest_major_ref=""
latest_major_remote=""
latest_minor_commit=""
prompt_major_update=false
prompt_minor_update=false

# TODO: Handle 3xx HTTP codes
if [[ $(get_http_code "https://ostree.zio.sh") == "200" ]]; then
    rpmostree_status_cmd=$(rpm-ostree status --booted)
    rpmostree_status_cmd_regex="((.+● ([A-Za-z0-9]{1,}):)([A-Za-z0-9\-\/\_]{1,}).+BaseCommit: ([a-z0-9]{64}))"

    if [[ $rpmostree_status_cmd =~ $rpmostree_status_cmd_regex  ]]; then
        ostree_commit=${BASH_REMATCH[5]}
        ostree_ref=${BASH_REMATCH[4]}
        ostree_remote=${BASH_REMATCH[3]}

        os_arch=""
        os_variant=""
        os_version=""

        if [[ $ostree_ref =~ $REGEX_OSTREE_REF ]]; then
            os_arch=${BASH_REMATCH[3]}
            os_variant=${BASH_REMATCH[4]}
            os_version=${BASH_REMATCH[2]}
        fi

        if [[ -f "/ostree/repo/refs/remotes/$ostree_remote/$ostree_ref" ]]; then
            ostree_remote_latest_minor_commit=$(get_latest_minor_commit $ostree_ref)
            ostree_remote_latest_major_ref=$(get_latest_major_ref $ostree_ref)

            if { [[ ! -z $ostree_remote_latest_minor_commit ]] && [[ $ostree_commit != $ostree_remote_latest_minor_commit ]]; }; then
                latest_minor_commit=$ostree_remote_latest_minor_commit
                prompt_minor_update=true
            fi

            if { [[ ! -z $ostree_remote_latest_major_ref ]] && [[ $ostree_ref != $ostree_remote_latest_major_ref ]]; }; then
                latest_major_remote=$ostree_remote
                latest_major_ref=$ostree_remote_latest_major_ref
                prompt_major_update=true
            fi
        fi
    fi
else
    echoc error "Unable to contact server"
    exit
fi

if { [[ $prompt_major_update == false ]] && [[ $prompt_minor_update == false ]]; }; then
    echoc "No updates available!"
fi

if [[ $prompt_major_update == true ]]; then
    if [[ $(get_answer "Release update available ($latest_major_release). Update?") == true ]]; then
        rpm-ostree rebase $latest_major_remote:$latest_major_ref
        prompt_minor_update=false
    fi
fi

if [[ $prompt_minor_update == true ]]; then
    if [[ $(get_answer "Incremental update available ($latest_minor_commit). Update?") == true ]]; then
        rpm-ostree upgrade
    fi
fi
