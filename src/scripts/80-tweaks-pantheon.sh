#!/usr/bin/env bash

if [[ $_os_core == "pantheon" ]]; then
    if [[ -f "/usr/bin/gnome-software-wrapper" ]]; then
        mv /usr/bin/gnome-software /usr/bin/gnome-software-bin
        mv /usr/bin/gnome-software-wrapper /usr/bin/gnome-software
    fi

    #systemctl disable gdm

    systemctl enable generate-oemconf
    [[ $_os_base_version != "38" ]] && systemctl enable lightdm
    systemctl enable touchegg
    systemctl --global enable io.elementary.files.xdg-desktop-portal
fi
