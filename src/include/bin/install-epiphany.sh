#!/usr/bin/env bash

echo "Installing Epiphany..."

sodalite-install-appcenter-flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

flatpak install flathub org.freedesktop.Platform.GL.default//21.08 --noninteractive
flatpak install appcenter org.gnome.Epiphany//stable --noninteractive
