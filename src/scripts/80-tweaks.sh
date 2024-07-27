#!/usr/bin/env bash

if [[ $_os_core == "pantheon" ]]; then
    if [[ -f "/usr/bin/gnome-software-wrapper" ]]; then
        mv /usr/bin/gnome-software /usr/bin/gnome-software-bin
        mv /usr/bin/gnome-software-wrapper /usr/bin/gnome-software
    fi
fi

ln -s /usr/bin/rocks.sodalite.hacks /usr/bin/sodalite-hacks
ln -s /usr/bin/firefox /usr/bin/rocks.sodalite.firefox
ln -s /usr/share/fontconfig/conf.avail/63-inter.conf /etc/fonts/conf.d/63-inter.conf
