#!/usr/bin/env bash

. /usr/libexec/sodalite/bash/common.sh

function set_property() {
    # TODO: Handle missing properties
    file=$1
    property=$2
    value=$3

    if [[ -f $file ]]; then
        if [[ $value =~ [[:space:]]+ ]]; then
            value="\"$value\""
        fi

        sed -i "s/^\($property=\)\(.*\)$/\1$value/g" $file
    fi
}

set -xeuo pipefail

# HACK: This gets set with the build.sh script, so no biggy if we miss it
variant=""
if [[ -f /etc/sodalite-variant ]]; then
    if [[ -s /etc/sodalite-variant ]]; then
        variant="$(cat /etc/sodalite-variant)"
    fi

    rm -f /etc/sodalite-variant
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

# TODO: Handle other version styles (useful for forked repos)
version_base="0"
version_release="00.0"
version_build="0"
if [[ $(get_config_item /etc/os-release VERSION) =~ (([0-9]{1,3})-([0-9]{2}.[0-9]{1,})(.([0-9]{1,}){0,1}).+) ]]; then
    version_base="${BASH_REMATCH[2]}"
    version_release="${BASH_REMATCH[3]}"
    [[ ! -z ${BASH_REMATCH[5]} ]] && version_build="${BASH_REMATCH[5]}"
fi

osr_id="sodalite" # TODO: Programatically set this
osr_name="Sodalite" # TODO: Programatically set this
osr_variant="" # TODO: Programatically set this
osr_variant_id="" # TODO: Programatically set this
osr_version="$version_base-$version_release"
osr_version_id="$version_base"

if [[ ! -z $variant ]]; then
    osr_variant_id=$variant
    osr_variant=$variant
fi

if [[ $version_build > 0 ]]; then
    osr_version+=".$version_build"
fi

if [[ ! -z $osr_variant ]] && [[ $osr_variant != "base" ]]; then
    osr_version+=" ($osr_variant)"
fi

[[ ! -z $osr_id ]] && set_property /etc/os-release "ID" $osr_id
[[ ! -z $osr_name ]] && set_property /etc/os-release "NAME" $osr_name
[[ ! -z $osr_name ]] && set_property /etc/os-release "PRETTY_NAME" "$osr_name $osr_version"
#[[ ! -z $osr_variant ]] && set_property /etc/os-release "VARIANT" $osr_variant
[[ ! -z $osr_variant ]] && echo "VARIANT=\"$osr_variant\"" >> /etc/os-release
#[[ ! -z $osr_variant_id ]] && set_property /etc/os-release "VARIANT_ID" $osr_variant_id
[[ ! -z $osr_variant_id ]] && echo "VARIANT_ID=\"$osr_variant_id\"" >> /etc/os-release
[[ ! -z $osr_version ]] && set_property /etc/os-release "VERSION" "$osr_version"
[[ ! -z $osr_version_id ]] && set_property /etc/os-release "VERSION_ID" $osr_version_id

if [[ ! -z $version_base ]]; then
    set_property /etc/upstream-release/lsb-release "ID" fedora
    set_property /etc/upstream-release/lsb-release "PRETTY_NAME" "Fedora Linux $version_base"
    set_property /etc/upstream-release/lsb-release "VERSION_ID" $version_base
fi

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
ln -s $(get_config_item /usr/share/glib-2.0/schemas/io.elementary.desktop.gschema.override picture-uri | sed -E 's/file:\/\///' | sed -E "s/'//g") /usr/share/backgrounds/elementaryos-default

glib-compile-schemas /usr/share/glib-2.0/schemas

systemctl disable gdm
systemctl enable generate-oemconf
systemctl enable lightdm
systemctl enable touchegg
systemctl enable update-appcenter-flatpak
