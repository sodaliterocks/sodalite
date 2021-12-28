#!/usr/bin/env bash

if ! [ $(id -u) = 0 ]; then
   echo "Must be ran as root!"
   exit 1
fi

echo "Installing Epiphany..."

sodalite-install-appcenter-flatpak
flatpak remote-add --if-not-exists --system flathub https://flathub.org/repo/flathub.flatpakrepo

flatpak install --noninteractive --or-update --system flathub org.freedesktop.Platform.GL.default//21.08
flatpak install --noninteractive --or-update --system appcenter org.gnome.Epiphany//stable
