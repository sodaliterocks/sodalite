#!/usr/bin/env bash

ln -s /usr/bin/rocks.sodalite.hacks /usr/bin/sodalite-hacks
ln -s /usr/bin/firefox /usr/bin/rocks.sodalite.firefox

glib-compile-schemas /usr/share/glib-2.0/schemas
dconf update

if [[ $_os_core == "pantheon" ]]; then
   mv /usr/bin/gnome-software /usr/bin/gnome-software-bin
   mv /usr/bin/gnome-software-wrapper /usr/bin/gnome-software

   systemctl disable gdm
   systemctl enable generate-oemconf
   systemctl enable lightdm
   systemctl enable touchegg
   systemctl --global enable io.elementary.files.xdg-desktop-portal
fi

systemctl enable sodalite-migrate
