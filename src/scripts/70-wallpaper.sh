#!/usr/bin/env bash

_fallback_wallpaper="phil-botha-a0TJ3hy-UD8-unsplash"
_wallpaper_dir="/usr/share/backgrounds/default"

wallpaper=""
pantheon_accent=""

case $_os_version_id in
    "4.0"*) wallpaper="jeremy-gerritsen-_iviuukstI4-unsplash" ;;
    "4.1"*) wallpaper="dustin-humes-OrO_HSqlZMY-unsplash" ;;
    "4.2"*) wallpaper="piermanuele-sberni-9jVmJ_mBRE8-unsplash~3967x2645" ;;
    "4.3"*)
        wallpaper="marek-piwnicki-fIxvIQ6mH-E-unsplash"
        pantheon_accent="bubblegum"
    "5.0"*)
        wallpaper="zara-walker-_pC5hT6aXfs-unsplash"
        pantheon_accent="cocoa"
        ;;
    *) wallpaper="$_fallback_wallpaper" ;;
esac

if [[ -f "${_wallpaper_dir}/$wallpaper.jpg" ]]; then
    set_property /usr/share/glib-2.0/schemas/00_sodalite.gschema.override picture-uri "'file:\/\/$(echo "${_wallpaper_dir}/$wallpaper" | sed "s|/|\\\/|g").jpg'"

    if [[ $_os_core == "pantheon" ]]; then
        ln -s "${_wallpaper_dir}/$wallpaper.jpg" /usr/share/backgrounds/elementaryos-default

        if [[ $pantheon_accent != "" ]]; then
            pantheon_stylesheet="io.elementary.stylesheet.$pantheon_accent"

            if [[ -d "/usr/share/themes/$pantheon_stylesheet" ]]; then
                set_property /usr/share/glib-2.0/schemas/00_sodalite.gschema.override gtk-theme "'$pantheon_stylesheet'"

                sed -i "s/gtk-theme-name.*/gtk-theme-name = $pantheon_stylesheet/g" /etc/gtk-3.0/settings.ini
            fi
        fi
    fi
fi
