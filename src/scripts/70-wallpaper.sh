#!/usr/bin/env bash

_fallback_wallpaper="phil-botha-a0TJ3hy-UD8-unsplash"
_wallpaper_dir="/usr/share/backgrounds/default"

wallpaper=""
wallpaper_dark=""
pantheon_accent=""

case $_os_version_id in
    "6.0"|"6.1"*)
        wallpaper="marek-piwnicki-fIxvIQ6mH-E-unsplash"
        pantheon_accent="bubblegum"
        ;;
    "7.0"*)
        wallpaper="ashwini-chaudhary-monty-dAvJGJ54g5s-unsplash"
        pantheon_accent="slate"
        ;;
    "8.0"*)
        wallpaper="jack-b-vcNPMwS08UI-unsplash"
        pantheon_accent="orange"
        ;;
    *) wallpaper="$_fallback_wallpaper" ;;
esac

if [[ -f "${_wallpaper_dir}/$wallpaper.jpg" ]]; then
	if [[ ! -n "$wallpaper_dark" ]]; then
	    wallpaper_dark="$wallpaper"
	fi

    set_property /usr/share/glib-2.0/schemas/00_sodalite.gschema.override picture-uri "'file:\/\/$(echo "${_wallpaper_dir}/$wallpaper" | sed "s|/|\\\/|g").jpg'"

	if [[ $_os_core == "gnome" ]]; then
    	set_property /usr/share/glib-2.0/schemas/00_sodalite.gschema.override picture-uri-dark "'file:\/\/$(echo "${_wallpaper_dir}/$wallpaper_dark" | sed "s|/|\\\/|g").jpg'"
    fi

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
else
    set_property /usr/share/glib-2.0/schemas/00_sodalite.gschema.override picture-uri "'file:\/\/$(echo "${_wallpaper_dir}/$_fallback_wallpaper" | sed "s|/|\\\/|g").jpg'"
fi
