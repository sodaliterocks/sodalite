#!/usr/bin/env bash

set -xeuo pipefail

variant_id=$(sodalite-get-variant id)
variant_name=$(sodalite-get-variant name)

function set_osrelease_property() {
    property=$1
    value=$2

    if [[ $value =~ [[:space:]]+ ]]; then
        value="\"$value\""
    fi

    sed -i "s/^\($property=\)\(.*\)$/\1$value/g" /etc/os-release
}

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

# TODO: Work out the correct way to do this, since this isn't!
set_osrelease_property "ID" $variant_id
set_osrelease_property "NAME" $variant_name
set_osrelease_property "PRETTY_NAME" "$variant_name 35"
set_osrelease_property "VERSION" "35"

# TODO: Get default wallpaper from gschema
ln -s /usr/share/backgrounds/default/karsten-wurth-7BjhtdogU3A-unsplash.jpg /usr/share/backgrounds/elementaryos-default

glib-compile-schemas /usr/share/glib-2.0/schemas

systemctl enable sodalite-generate-oem
systemctl enable sodalite-install-appcenter-flatpak
systemctl enable touchegg
