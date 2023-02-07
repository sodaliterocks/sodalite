#!/usr/bin/env bash

wallpaper=""

#case $_os_version_base in
#    35) wallpaper="karsten-wurth-7BjhtdogU3A-unsplash" ;;
#    36) wallpaper="max-okhrimenko-R-CoXmMrWFk-unsplash" ;;
#    37) wallpaper="jeremy-gerritsen-_iviuukstI4-unsplash" ;;
#    38) wallpaper="zara-walker-_pC5hT6aXfs-unsplash" ;;
#    39) wallpaper="jack-b-vcNPMwS08UI-unsplash" ;;
#esac

case $_os_version_id in
    4) wallpaper="zara-walker-_pC5hT6aXfs-unsplash" ;;
esac

if [[ -f "/usr/share/backgrounds/default/$wallpaper.jpg" ]]; then
    set_property /usr/share/glib-2.0/schemas/00_sodalite.gschema.override picture-uri "'file:\/\/\/usr\/share\/backgrounds\/default\/$wallpaper.jpg'"

    if [[ $_os_core == "pantheon" ]]; then
        ln -s /usr/share/backgrounds/default/$wallpaper.jpg /usr/share/backgrounds/elementaryos-default
    fi
fi
