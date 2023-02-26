#!/usr/bin/env bash

_fallback_wallpaper="phil-botha-a0TJ3hy-UD8-unsplash"
_wallpaper_dir="/usr/share/backgrounds/default"

wallpaper=""

case $_os_version_id in
    "4.0"*) wallpaper="jeremy-gerritsen-_iviuukstI4-unsplash" ;;
    "4.1"*) wallpaper="dustin-humes-OrO_HSqlZMY-unsplash" ;;
    "5.0"*) wallpaper="zara-walker-_pC5hT6aXfs-unsplash" ;;
    *) wallpaper="$_fallback_wallpaper" ;;
esac

if [[ -f "${_wallpaper_dir}/$wallpaper.jpg" ]]; then
    set_property /usr/share/glib-2.0/schemas/00_sodalite.gschema.override picture-uri "'file:\/\/$(echo "${_wallpaper_dir}/$wallpaper" | sed "s|/|\\\/|g").jpg'"

    if [[ $_os_core == "pantheon" ]]; then
        ln -s "${_wallpaper_dir}/$wallpaper.jpg" /usr/share/backgrounds/elementaryos-default
    fi
fi
