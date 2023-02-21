#!/usr/bin/env bash

ln -s /usr/bin/rocks.sodalite.hacks /usr/bin/sodalite-hacks
ln -s /usr/bin/firefox /usr/bin/rocks.sodalite.firefox

glib-compile-schemas /usr/share/glib-2.0/schemas
dconf update

systemctl enable sodalite-migrate
