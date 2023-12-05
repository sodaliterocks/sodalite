#!/usr/bin/env bash

function die() {
    echo -e "\033[1;31mError: $1\033[0m"
    exit 255
}

if [[ $(id -u) == 0 ]]; then
    die "Cannot initialise Builder as root"
fi

base_dir="$(dirname "$(realpath -s "$0")")"
progs_submodule_dir="$(dirname "$(realpath -s "$0")")/lib/sodaliterocks.progs"
progs_invoker_submodule_dir="$progs_submodule_dir/lib/sodaliterocks.invoker"
builder_path=""

if [[ -n "$SODALITE_BUILDER_WRAPPER_PATH" ]]; then
    builder_path="$SODALITE_BUILDER_WRAPPER_PATH"
else
    builder_path="$base_dir/lib/sodaliterocks.progs/src/rocks.sodalite.builder"
fi

if [[ "$SODALITE_BUILDER_WRAPPER_NO_INIT" != "true" ]]; then
    git submodule update --init --recursive "$base_dir"
    [[ $? != 0 ]] && die "Failed to update submodules"
fi

[[ ! -f "$builder_path" ]] && die "Cannot find Sodalite Builder\n       ↳ $builder_path"

builder_command=""

if { [[ "$@" == "-h" ]] || [[ "$@" == "--help" ]] }; then
    builder_command="$builder_path --help"
else
    builder_args=""

    { [[ "$@" == *"-p "* ]] || [[ "$@" == *"--path "* ]] } && die "--path/-p is hardcoded by "$(basename $(realpath -s "$0"))" (set to \"$base_dir\")"

    builder_command="sudo $builder_path --path \"$base_dir\" $@"
fi

bash -c "$builder_command"
exit_code=$?

echo -c "Exit: $exit_code"
exit $exit_code
