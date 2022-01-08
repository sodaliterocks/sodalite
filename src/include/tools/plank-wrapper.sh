#!/usr/bin/env bash

if [[ $(realpath -s "$0") == "/usr/bin/sodalite-"* ]]; then
    . /usr/libexec/sodalite-common
else
    . "$(dirname "$(realpath -s "$0")")/common.sh"
fi

shopt -s extglob

current_plank_items=$(dconf read /net/launchpad/plank/docks/dock1/dock-items | sed 's/ //g')
default_plank_items="['gala-multitaskingview.dockitem','firefox.dockitem','io.elementary.calendar.dockitem','io.elementary.music.dockitem','io.elementary.photos.dockitem','io.elementary.files.dockitem','org.gnome.Software.dockitem']"
plank_launchers_dir="$HOME/.config/plank/dock1/launchers"
revert_to_default=false

declare -a default_plank_items_regex=(
    "(\['firefox\.dockitem','io\.elementary\.calendar\.dockitem','io\.elementary\.music\.dockitem','io\.elementary\.videos\.dockitem','io\.elementary\.photos-viewer\.dockitem','io\.elementary\.mail\.dockitem'\])"
    "(\['gala-multitaskingview\.dockitem','firefox\.dockitem','io\.elementary\.calendar\.dockitem','io\.elementary\.music\.dockitem','io\.elementary\.photos\.dockitem','io\.elementary\.files\.dockitem','org\.gnome\.Software\.dockitem'\])"
)

if [[ -z $current_plank_items ]]; then
    revert_to_default=true
elif [[ $current_plank_items == "@as[]" ]]; then
    revert_to_default=true
else
    for val in ${default_plank_items_regex[@]}; do
        if { [[ $revert_to_default == false ]] && [[ $current_plank_items =~ $val ]]; }; then
            revert_to_default=true
        fi
    done
fi

if [[ $revert_to_default == true ]]; then
    if [[ "$current_plank_items" != "$default_plank_items" ]]; then
        [[ ! -d $plank_launchers_dir ]] && mkdir -p $plank_launchers_dir
        rsync -av --delete-after /etc/skel/.config/plank/dock1/launchers/ $plank_launchers_dir
        dconf write /net/launchpad/plank/docks/dock1/dock-items $default_plank_items
    fi
fi

plank
