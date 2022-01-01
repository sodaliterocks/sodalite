#!/usr/bin/env bash

if [[ $(realpath -s "$0") == "/usr/bin/sodalite-"* ]]; then
    . /usr/libexec/sodalite-common
else
    . "$(dirname "$(realpath -s "$0")")/common.sh"
fi

function invoke_cleanup() {
    CMD=$1
    ARGS=$2
    MESSAGE=$3

    MESSAGE="$CMD: $MESSAGE. Continue?"

    if [[ $(get_answer $MESSAGE) == true ]]; then
        eval "$CMD $ARGS"
    fi
}

test_root

invoke_cleanup "rpm-ostree" "cleanup --pending --rollback" "Removing pending and rollback deployments"
invoke_cleanup "rpm-ostree" "cleanup --base --repomd" "Removing cached and temporary data"
invoke_cleanup "flatpak" "uninstall --unused" "Removing unused packages"
