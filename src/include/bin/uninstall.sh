#!/usr/bin/env bash

# Due to OSTree limitations, we're doing a few things that
# won't be reverted if the user wishes to remove Sodalite
# themselves. This script can do all this for them.

# Remove org.gnome.Evince [appcenter]
# Remove org.gnome.Epiphany [appcenter]
# Remove org.gnome.FileRoller [appcenter]
# Remove AppCenter Flatpak (if we can)