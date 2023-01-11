#!/usr/bin/env bash

_PLUGIN_TITLE="Sodalite Builder"
_PLUGIN_DESCRIPTION=""
_PLUGIN_OPTIONS=(
    "variant;v;"
    "working-dir;;"
)
_PLUGIN_ROOT="true"

basedir="$(dirname "$(realpath -s "$0")")"

function build_die() {
    echo -e "$(emj "🛑")\033[1;31mError: $@\033[0m"
    #cleanup
    exit 255
}


function main() {
    echo "Doing things..."
}

if [[ $SODALITE_HACKS_INVOKED != "true" ]]; then
    if [[ -d "$basedir/lib/sodaliterocks.hacks" ]]; then
        "$basedir"/lib/sodaliterocks.hacks/src/hacks.sh $0 $@
    else
        git submodule update --init "$basedir"/lib/sodaliterocks.hacks

        if [[ $? -ne 0 ]]; then
            build_die "Failed to pull required submodule"
        fi
    fi
fi
