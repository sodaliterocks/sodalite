#!/usr/bin/env bash

# TODO: A way to restore removed GNOME apps

echo "Uninstalling stock GNOME apps installed via Flatpak..."

declare -a gnome_apps=(
    "org.gnome.Calculator"
    "org.gnome.Calendar"
    "org.gnome.Characters"
    "org.gnome.Connections"
    "org.gnome.Contacts"
    "org.gnome.Evince"
    "org.gnome.FileRoller"
    "org.gnome.Logs"
    "org.gnome.Maps"
    "org.gnome.NautilusPreviewer"
    "org.gnome.Screenshot"
    "org.gnome.Weather"
    "org.gnome.baobab"
    "org.gnome.clocks"
    "org.gnome.eog"
    "org.gnome.font-viewer"
    "org.gnome.gedit"
)

gnome_apps_string=""

for i in "${gnome_apps[@]}"
do
    gnome_apps_string+="$i "
done

flatpak uninstall $gnome_apps_string
flatpak uninstall --unused