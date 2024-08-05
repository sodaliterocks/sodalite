#!/usr/bin/env bash

if [[ $_os_core == "gnome" ]]; then
    gnome_extensions_prefix="/usr/share/gnome-shell/extensions"

    declare -a gnome_extensions=(
        "AlphabeticalAppGrid@stuarthayhurst"
        "blur-my-shell@aunetx"
        "dash-to-dock@micxgx.gmail.com"
    )

    for gnome_extension in ${gnome_extensions[@]}; do
        gnome_extension_dir="$gnome_extensions_prefix/$gnome_extension"
        gnome_extension_schemas_dir="$gnome_extension_dir/schemas"
        sodalite_schema_file="00_sodalite.gschema.override"

        mkdir -p "$gnome_extension_dir"
        unzip "$gnome_extension_dir.shell-extension.zip" -d "$gnome_extension_dir"

        if [[ -d "$gnome_extension_schemas_dir" ]]; then
            cp "/usr/share/glib-2.0/schemas/$sodalite_schema_file" "$gnome_extension_schemas_dir/$sodalite_schema_file"
            glib-compile-schemas "$gnome_extension_schemas_dir"
            rm "$gnome_extension_schemas_dir/$sodalite_schema_file"
        fi

        rm "$gnome_extension_dir.shell-extension.zip"
    done
fi
