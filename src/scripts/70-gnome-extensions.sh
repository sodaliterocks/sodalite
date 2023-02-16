#!/usr/bin/env bash

if [[ $_os_core == "gnome" ]]; then
    gnome_extensions_prefix="/usr/share/gnome-shell/extensions"

    declare -a gnome_extensions=(
        "AlphabeticalAppGrid@stuarthayhurst"
    )

    for gnome_extension in ${gnome_extensions[@]}; do
        mkdir -p "$gnome_extensions_prefix/$gnome_extension"
        unzip "$gnome_extensions_prefix/$gnome_extension.shell-extension.zip" -d "$gnome_extensions_prefix/$gnome_extension"
        rm "$gnome_extensions_prefix/$gnome_extension.shell-extension.zip"
    done
fi
