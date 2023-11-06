#!/usr/bin/env bash

ln -s /usr/bin/rocks.sodalite.hacks /usr/bin/sodalite-hacks
ln -s /usr/bin/firefox /usr/bin/rocks.sodalite.firefox
ln -s /usr/share/fontconfig/conf.avail/63-inter.conf /etc/fonts/conf.d/63-inter.conf

glib-compile-schemas /usr/share/glib-2.0/schemas
dconf update
fc-cache -f -v

systemctl enable sodalite-migrate
