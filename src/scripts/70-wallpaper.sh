#!/usr/bin/env bash

_devel_wallpaper="devel-wallpaper"

wallpaper=""
pantheon_system_background=""

case $_os_version_id in
    "4.0"*) wallpaper="default/jeremy-gerritsen-_iviuukstI4-unsplash" ;;
    "4.1"*) wallpaper="default/dustin-humes-OrO_HSqlZMY-unsplash" ;;
    "5.0"*) wallpaper="default/zara-walker-_pC5hT6aXfs-unsplash" ;;
    *)
        wallpaper="$_devel_wallpaper" ;;
        pantheon_system_background="phil-botha-a0TJ3hy-UD8-unsplash"
        ;;
esac

[[ $pantheon_system_background == "" ]] && pantheon_system_background="$wallpaper"
[[ $wallpaper != $_devel_wallpaper ]] && rm "/usr/share/backgrounds/${_devel_wallpaper}.jpg"

if [[ -f "/usr/share/backgrounds/$wallpaper.jpg" ]]; then
    set_property /usr/share/glib-2.0/schemas/00_sodalite.gschema.override picture-uri "'file:\/\/\/usr\/share\/backgrounds\/$(echo $wallpaper | sed "s|/|\\\/|g").jpg'"

    if [[ $_os_core == "pantheon" ]]; then
        ln -s /usr/share/backgrounds/$pantheon_system_background.jpg /usr/share/backgrounds/elementaryos-default
    fi
fi
