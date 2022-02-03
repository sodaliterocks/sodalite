#!/usr/bin/env bash

. /usr/libexec/sodalite/bash/common.sh

function get_property() {
    file=$1
    item=$2
    echo $(grep -oP '(?<=^'"$item"'=).+' $file | tr -d '"')
}

function set_property() {
    # TODO: Handle missing properties
    file=$1
    property=$2
    value=$3

    if [[ -f $file ]]; then
        if [[ -z $(get_property $file $property) ]]; then
            echo "$property=\"$value\"" >> $file
        else
            if [[ $value =~ [[:space:]]+ ]]; then
                value="\"$value\""
            fi

            sed -i "s/^\($property=\)\(.*\)$/\1$value/g" $file
        fi
    fi
}

set -xeuo pipefail

# HACK: This gets set with the build.sh script, so no biggy if we miss it
if [[ $(cat /etc/sodalite-variant) != "" ]]; then
    variant="$(cat /etc/sodalite-variant)"
    rm -f /etc/sodalite-variant
else
    variant="unknown"
fi

#########
# HACKS #
#########

# TODO: Work out if we even need these. These issues are pretty old.

# BUG: https://github.com/projectatomic/rpm-ostree/issues/1542#issuecomment-419684977
for x in /etc/yum.repos.d/*modular.repo; do
    sed -i -e 's,enabled=[01],enabled=0,' ${x}
done

# BUG: https://bugzilla.redhat.com/show_bug.cgi?id=1265295
if ! grep -q '^Storage=persistent' /etc/systemd/journald.conf; then
    (cat /etc/systemd/journald.conf && echo 'Storage=persistent') > /etc/systemd.journald.conf.new
    mv /etc/systemd.journald.conf{.new,}
fi

# SEE: https://src.fedoraproject.org/rpms/glibc/pull-request/4
# Basically that program handles deleting old shared library directories
# mid-transaction, which never applies to rpm-ostree. This is structured as a
# loop/glob to avoid hardcoding (or trying to match) the architecture.
for x in /usr/sbin/glibc_post_upgrade.*; do
    if test -f ${x}; then
        ln -srf /usr/bin/true ${x}
    fi
done

###################
# OSTREE MUTATING #
###################

if [[ $(get_property /etc/os-release VERSION) =~ (([0-9]{1,3})-([0-9]{2}.[0-9]{1,})(.([0-9]{1,}){0,1}).+) ]]; then
    version="${BASH_REMATCH[2]}-${BASH_REMATCH[3]}"
    version_id="${BASH_REMATCH[2]}"

    [[ ${BASH_REMATCH[5]} > 0 ]] && version+=".${BASH_REMATCH[5]}"

    if [[ $(cat /etc/sodalite-commit) != "" ]]; then
        version+="+$(cat /etc/sodalite-commit)"
        rm -r /etc/sodalite-commit
    fi

    [[ ! -z $variant ]] && [[ $variant != "base" ]] && version+=" ($variant)"
else
    version=$(get_property /etc/os-release VERSION)
    version_id=$(get_property /etc/os-release VERSION_ID)
fi

pretty_name="Sodalite $version"

if [[ ! -z $variant ]]; then
    set_property /etc/os-release "VARIANT" $variant
    set_property /etc/os-release "VARIANT_ID" $variant
fi

if [[ ! -z $version_id ]]; then
    set_property /etc/upstream-release/lsb-release "ID" fedora
    set_property /etc/upstream-release/lsb-release "PRETTY_NAME" "Fedora Linux $version_id"
    set_property /etc/upstream-release/lsb-release "VERSION_ID" $version_id
fi

set_property /etc/os-release "ID" "sodalite"
set_property /etc/os-release "NAME" "Sodalite"
set_property /etc/os-release "PRETTY_NAME" $pretty_name
set_property /etc/os-release "VERSION" $version
set_property /etc/os-release "VERSION_ID" $version_id

############
# REMOVALS #
############

# HACK: Removing files here instead because we're not using --unified-core (see https://github.com/electricduck/sodalite/issues/9#issuecomment-1010384738)

declare -a to_remove=(
    # evolution-data-server
    "/etc/xdg/autostart/org.gnome.Evolution-alarm-notify.desktop"
    "/usr/libexec/evolution-data-server/evolution-alarm-notify"
    # fedora-workstation-backgrounds
    "/usr/share/backgrounds/fedora-workstation"
    "/usr/share/doc/fedora-workstation-backgrounds"
    "/usr/share/gnome-background-properties/fedora-workstation-backgrounds.xml"
    # gnome-control-center
    #"/usr/bin/gnome-control-center"
    "/usr/libexec/cc-remote-login-helper"
    "/usr/libexec/gnome-control-center-print-renderer"
    "/usr/libexec/gnome-control-center-search-provider"
    "/usr/share/applications/gnome-applications-panel.desktop"
    "/usr/share/applications/gnome-background-panel.desktop"
    "/usr/share/applications/gnome-bluetooth-panel.desktop"
    "/usr/share/applications/gnome-camera-panel.desktop"
    "/usr/share/applications/gnome-color-panel.desktop"
    "/usr/share/applications/gnome-control-center.desktop"
    "/usr/share/applications/gnome-datetime-panel.desktop"
    "/usr/share/applications/gnome-default-apps-panel.desktop"
    "/usr/share/applications/gnome-diagnostics-panel.desktop"
    "/usr/share/applications/gnome-display-panel.desktop"
    "/usr/share/applications/gnome-info-overview-panel.desktop"
    "/usr/share/applications/gnome-keyboard-panel.desktop"
    "/usr/share/applications/gnome-location-panel.desktop"
    "/usr/share/applications/gnome-lock-panel.desktop"
    "/usr/share/applications/gnome-microphone-panel.desktop"
    "/usr/share/applications/gnome-mouse-panel.desktop"
    "/usr/share/applications/gnome-multitasking-panel.desktop"
    "/usr/share/applications/gnome-network-panel.desktop"
    "/usr/share/applications/gnome-notifications-panel.desktop"
    "/usr/share/applications/gnome-online-accounts-panel.desktop"
    "/usr/share/applications/gnome-power-panel.desktop"
    "/usr/share/applications/gnome-printers-panel.desktop"
    "/usr/share/applications/gnome-region-panel.desktop"
    "/usr/share/applications/gnome-removable-media-panel.desktop"
    "/usr/share/applications/gnome-search-panel.desktop"
    "/usr/share/applications/gnome-sharing-panel.desktop"
    "/usr/share/applications/gnome-sound-panel.desktop"
    "/usr/share/applications/gnome-thunderbolt-panel.desktop"
    "/usr/share/applications/gnome-universal-access-panel.desktop"
    "/usr/share/applications/gnome-usage-panel.desktop"
    "/usr/share/applications/gnome-user-accounts-panel.desktop"
    "/usr/share/applications/gnome-wacom-panel.desktop"
    "/usr/share/applications/gnome-wifi-panel.desktop"
    "/usr/share/applications/gnome-wwan-panel.desktop"
    "/usr/share/bash-completion/completions/gnome-control-center"
    "/usr/share/dbus-1/services/org.gnome.ControlCenter.SearchProvider.service"
    "/usr/share/doc/gnome-control-center"
    "/usr/share/doc/gnome-control-center/NEWS"
    "/usr/share/doc/gnome-control-center/README.md"
    "/usr/share/dbus-1/services/org.gnome.ControlCenter.service"
    "/usr/share/glib-2.0/schemas/org.gnome.ControlCenter.gschema.xml"
    "/usr/share/gnome-control-center/keybindings/00-multimedia.xml"
    "/usr/share/gnome-control-center/keybindings/01-input-sources.xml"
    "/usr/share/gnome-control-center/keybindings/01-launchers.xml"
    "/usr/share/gnome-control-center/keybindings/01-screenshot.xml"
    "/usr/share/gnome-control-center/keybindings/01-system.xml"
    "/usr/share/gnome-control-center/keybindings/50-accessibility.xml"
    "/usr/share/gnome-control-center/pixmaps/noise-texture-light.png"
    "/usr/share/gnome-shell/search-providers/gnome-control-center-search-provider.ini"
    "/usr/share/man/man1/gnome-control-center.1.gz"
    "/usr/share/metainfo/gnome-control-center.appdata.xml"
    "/usr/share/pixmaps/faces/astronaut.jpg"
    "/usr/share/pixmaps/faces/baseball.png"
    "/usr/share/pixmaps/faces/bicycle.jpg"
    "/usr/share/pixmaps/faces/book.jpg"
    "/usr/share/pixmaps/faces/butterfly.png"
    "/usr/share/pixmaps/faces/calculator.jpg"
    "/usr/share/pixmaps/faces/cat-eye.jpg"
    "/usr/share/pixmaps/faces/cat.jpg"
    "/usr/share/pixmaps/faces/chess.jpg"
    "/usr/share/pixmaps/faces/coffee.jpg"
    "/usr/share/pixmaps/faces/coffee2.jpg"
    "/usr/share/pixmaps/faces/dice.jpg"
    "/usr/share/pixmaps/faces/energy-arc.jpg"
    "/usr/share/pixmaps/faces/fish.jpg"
    "/usr/share/pixmaps/faces/flake.jpg"
    "/usr/share/pixmaps/faces/flower.jpg"
    "/usr/share/pixmaps/faces/flower2.jpg"
    "/usr/share/pixmaps/faces/gamepad.jpg"
    "/usr/share/pixmaps/faces/grapes.jpg"
    "/usr/share/pixmaps/faces/guitar.jpg"
    "/usr/share/pixmaps/faces/guitar2.jpg"
    "/usr/share/pixmaps/faces/headphones.jpg"
    "/usr/share/pixmaps/faces/hummingbird.jpg"
    "/usr/share/pixmaps/faces/launch.jpg"
    "/usr/share/pixmaps/faces/leaf.jpg"
    "/usr/share/pixmaps/faces/legacy/astronaut.jpg"
    "/usr/share/pixmaps/faces/legacy/baseball.png"
    "/usr/share/pixmaps/faces/legacy/butterfly.png"
    "/usr/share/pixmaps/faces/legacy/cat-eye.jpg"
    "/usr/share/pixmaps/faces/legacy/chess.jpg"
    "/usr/share/pixmaps/faces/legacy/coffee.jpg"
    "/usr/share/pixmaps/faces/legacy/dice.jpg"
    "/usr/share/pixmaps/faces/legacy/energy-arc.jpg"
    "/usr/share/pixmaps/faces/legacy/fish.jpg"
    "/usr/share/pixmaps/faces/legacy/flake.jpg"
    "/usr/share/pixmaps/faces/legacy/flower.jpg"
    "/usr/share/pixmaps/faces/legacy/grapes.jpg"
    "/usr/share/pixmaps/faces/legacy/guitar.jpg"
    "/usr/share/pixmaps/faces/legacy/launch.jpg"
    "/usr/share/pixmaps/faces/legacy/leaf.jpg"
    "/usr/share/pixmaps/faces/legacy/lightning.jpg"
    "/usr/share/pixmaps/faces/legacy/penguin.jpg"
    "/usr/share/pixmaps/faces/legacy/puppy.jpg"
    "/usr/share/pixmaps/faces/legacy/sky.jpg"
    "/usr/share/pixmaps/faces/legacy/soccerball.png"
    "/usr/share/pixmaps/faces/legacy/sunflower.jpg"
    "/usr/share/pixmaps/faces/legacy/sunset.jpg"
    "/usr/share/pixmaps/faces/legacy/tennis-ball.png"
    "/usr/share/pixmaps/faces/legacy/yellow-rose.jpg"
    "/usr/share/pixmaps/faces/lightning.jpg"
    "/usr/share/pixmaps/faces/mountain.jpg"
    "/usr/share/pixmaps/faces/penguin.jpg"
    "/usr/share/pixmaps/faces/plane.jpg"
    "/usr/share/pixmaps/faces/puppy.jpg"
    "/usr/share/pixmaps/faces/sky.jpg"
    "/usr/share/pixmaps/faces/soccerball.png"
    "/usr/share/pixmaps/faces/sunflower.jpg"
    "/usr/share/pixmaps/faces/sunset.jpg"
    "/usr/share/pixmaps/faces/surfer.jpg"
    "/usr/share/pixmaps/faces/tennis-ball.png"
    "/usr/share/pixmaps/faces/tomatoes.jpg"
    "/usr/share/pixmaps/faces/tree.jpg"
    "/usr/share/pixmaps/faces/yellow-rose.jpg"
    "/usr/share/polkit-1/rules.d/gnome-control-center.rules"
    "/usr/share/sounds/gnome/default/alerts/bark.ogg"
    "/usr/share/sounds/gnome/default/alerts/drip.ogg"
    "/usr/share/sounds/gnome/default/alerts/glass.ogg"
    "/usr/share/sounds/gnome/default/alerts/sonar.ogg"
    # gnome-session
    "/usr/share/wayland-sessions/gnome.desktop"
    "/usr/share/wayland-sessions/gnome-wayland.desktop"
    "/usr/share/xsessions/gnome.desktop"
    "/usr/share/xsessions/gnome-xorg.desktop"
    # light-locker
    "/etc/xdg/autostart/light-locker.desktop"
    # plank
    "/etc/xdg/autostart/plank.desktop"
    # misc.
    "/usr/share/icewm"
)

if [[ $variant != "elementary-nightly" ]]; then
    # These elementary packages are considered broken, so we'll only keep them
    # for this variant
    to_remove+=(
        # switchboard-plug-datetime
        "/usr/lib64/switchboard/system/libdatetime.so"
        "/usr/share/doc/switchboard-plug-datetime/"
        # switchboard-plug-locale
        "/usr/lib64/switchboard/personal/liblocale-plug.so"
        "/usr/share/doc/switchboard-plug-locale/"
        # switchboard-plug-parental-controls
        "/usr/lib64/switchboard/system/libparental-controls.so"
        "/usr/share/doc/switchboard-plug-parental-controls/"
        # switchboard-plug-security-privacy
        "/usr/lib64/switchboard/personal/libsecurity-privacy.so"
        "/usr/share/doc/switchboard-plug-security-privacy/"
    )
fi

for file in ${to_remove[@]}; do
    rm -rf $file
done

########
# MISC #
########

# Sets the background System (in Switchboard) can use behind the logo
ln -s $(get_property /usr/share/glib-2.0/schemas/io.elementary.desktop.gschema.override picture-uri | sed -E 's/file:\/\///' | sed -E "s/'//g") /usr/share/backgrounds/elementaryos-default

glib-compile-schemas /usr/share/glib-2.0/schemas

systemctl disable gdm
systemctl enable generate-oemconf
systemctl enable lightdm
systemctl enable touchegg
systemctl enable update-appcenter-flatpak
