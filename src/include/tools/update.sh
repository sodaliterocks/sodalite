#!/usr/bin/env bash

if [[ $(realpath -s "$0") == "/usr/bin/sodalite-"* ]]; then
    . /usr/libexec/sodalite-common
else
    . "$(dirname "$(realpath -s "$0")")/common.sh"
fi

test_root

echoc "Updating OSTree..."
rpm-ostree upgrade

echoc "Updating Flatpak..."
flatpak update --noninteractive --system
