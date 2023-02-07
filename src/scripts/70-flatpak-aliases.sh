#!/usr/bin/env bash

declare -a flatpak_app_aliases

if [[ $_os_core == "pantheon" ]]; then
    flatpak_app_aliases+=(
        "org.gnome.Evince:org.gnome.Evince"
        "org.gnome.FileRoller:org.gnome.FileRoller"
        "io.elementary.calculator:io.elementary.calculator"
        "io.elementary.calendar:io.elementary.calendar"
        "io.elementary.camera:io.elementary.camera"
        "io.elementary.capnet-assist:io.elementary.capnet-assist"
        "io.elementary.screenshot:io.elementary.screenshot"
        "io.elementary.videos:io.elementary.videos"
    )
fi

for flatpak_app_alias in ${flatpak_app_aliases[@]}; do
    app="$(echo $flatpak_app_alias | cut -d ":" -f1)"
    alias="$(echo $flatpak_app_alias | cut -d ":" -f2)"
    alias_path="/usr/bin/$alias"

    if [[ ! -f "$alias_path" ]]; then
        echo -e "#\x21/usr/bin/env sh" > "$alias_path"
        echo -e "rocks.sodalite.flatpak-helper $app \$@" >> "$alias_path"
        chmod +x "$alias_path"
    fi
done
