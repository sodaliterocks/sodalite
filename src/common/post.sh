#!/usr/bin/env bash

set -xeuo pipefail

. /usr/libexec/sodalite-common

function set_osrelease_property() {
    # TODO: Handle missing properties
    property=$1
    value=$2

    if [[ $value =~ [[:space:]]+ ]]; then
        value="\"$value\""
    fi

    sed -i "s/^\($property=\)\(.*\)$/\1$value/g" /etc/os-release
}

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

sodalite_version_base="0"
sodalite_version_build="00000000.0"
if [[ $(get_config_item /etc/os-release VERSION) =~ (([0-9]{1,3})-([0-9]{8}.[0-9]{1,}).+) ]]; then
    sodalite_version_base="${BASH_REMATCH[2]}"
    sodalite_version_build="${BASH_REMATCH[3]}"
fi

osr_id="$(get_config_item /etc/sodalite-release ID)"
osr_name="$(get_config_item /etc/sodalite-release NAME)"
osr_variant="$(get_config_item /etc/sodalite-release VARIANT)"
osr_variant_id="$(get_config_item /etc/sodalite-release VARIANT_ID)"
osr_version="$sodalite_version_build" # INVESTIGATE: Good idea? Could break things?
osr_version_id="$sodalite_version_base"

if [[ ! -z $osr_variant ]]; then
    osr_version="$osr_version ($osr_variant)"
fi

set_osrelease_property "ID" $osr_id
set_osrelease_property "NAME" $osr_name
set_osrelease_property "PRETTY_NAME" "$osr_name $osr_version"
#set_osrelease_property "VARIANT" $osr_variant
echo "VARIANT=\"$osr_variant\"" >> /etc/os-release
#set_osrelease_property "VARIANT_ID" $osr_variant_id
echo "VARIANT_ID=\"$osr_variant_id\"" >> /etc/os-release
set_osrelease_property "VERSION" "$osr_version"
set_osrelease_property "VERSION_ID" $osr_version_id

########
# MISC #
########

# TODO: Get default wallpaper from gschema
ln -s /usr/share/backgrounds/default/karsten-wurth-7BjhtdogU3A-unsplash.jpg /usr/share/backgrounds/elementaryos-default

glib-compile-schemas /usr/share/glib-2.0/schemas

systemctl disable gdm
systemctl enable lightdm
systemctl enable sodalite-generate-oem
systemctl enable sodalite-install-appcenter-flatpak
systemctl enable touchegg
