#!/usr/bin/env bash

echo "Resetting Plank items..."

HOME_PATH="$( getent passwd "$USER" | cut -d: -f6 )"

if [ "$1" != "" ]; then
    HOME_PATH="$2"
fi

rm -r $HOME_PATH/.config/plank/dock1/launchers
cp -r /etc/skel/.config/plank/dock1/launchers $HOME_PATH/.config/plank/dock1/launchers
dconf write /net/launchpad/plank/docks/dock1/dock-items "['gala-multitaskingview.dockitem', 'firefox.dockitem', 'microsoft-edge.dockitem', 'io.elementary.calendar.dockitem', 'io.elementary.music.dockitem', 'io.elementary.photos.dockitem', 'io.elementary.files.dockitem', 'org.gnome.Software.dockitem']"
# TODO: Better way of restarting Plank
# Pantheon will restart Plank after killing (but only once!)
pkill plank