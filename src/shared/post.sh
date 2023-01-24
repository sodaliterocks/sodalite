#!/usr/bin/env bash

buildinfo_file="/usr/lib/sodalite-buildinfo"
core_file="/usr/lib/sodalite-core"

function del_property() {
    file=$1
    property=$2

    if [[ -f $file ]]; then
        if [[ ! -z $(get_property $file $property) ]]; then
            sed -i "s/^\($property=.*\)$//g" $file
        fi
    fi
}

function get_property() {
    file=$1
    property=$2

    if [[ -f $file ]]; then
        echo $(grep -oP '(?<=^'"$property"'=).+' $file | tr -d '"')
    fi
}

function set_property() {
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

core=""
variant=""
variant_pretty=""
version_tag=""

if [[ -f $core_file ]]; then
    core="$(cat $core_file)"
fi

if [[ $(cat $buildinfo_file) != "" ]]; then
    [[ -z $(get_property $buildinfo_file "GIT_TAG") ]] && \
        version_tag="$(get_property $buildinfo_file "GIT_COMMIT")"
    [[ ! -z $(get_property $buildinfo_file "VARIANT") ]] && \
        variant="$(get_property $buildinfo_file "VARIANT")"
fi

if [[ -n $variant ]]; then
    case "$variant" in
        "desktop-gnome") variant_pretty="GNOME" ;;
        *) variant_pretty="$variant" ;;
    esac
fi

###################
# OSTREE MUTATING #
###################

cpe="cpe:\/o:sodaliterocks:sodalite" # cpe:/<part>:<vendor>:<product>:<version>:<update>:<edition>:<language>

if [[ $(get_property /etc/os-release VERSION) =~ (([0-9]{1,3})-([0-9]{2}.[0-9]{1,})(.([0-9]{1,}){0,1}).+) ]]; then
    version="${BASH_REMATCH[2]}-${BASH_REMATCH[3]}"
    version_id="${BASH_REMATCH[2]}"

    [[ ${BASH_REMATCH[5]} > 0 ]] && version+=".${BASH_REMATCH[5]}"
    [[ ! -z $version_tag ]] && version+="+$version_tag"

    if [[ ! -z $variant ]] && [[ $variant != "desktop"* ]]; then
        version_pretty="$version ($variant_pretty)"
    else
        version_pretty="$version"
    fi

    cpe+=":$version_id:$(echo $version | cut -f2- -d"-")"
else
    version=$(get_property /etc/os-release VERSION)
    version_id=$(get_property /etc/os-release VERSION_ID)
    version_pretty="$version"

    cpe+=":$version_id:-"
fi

if [[ ! -z $variant ]]; then
    set_property /usr/lib/os-release "VARIANT" "$variant_pretty"
    set_property /usr/lib/os-release "VARIANT_ID" $variant

    cpe+=":$variant"
fi

if [[ ! -z $version_id ]]; then
    set_property /etc/upstream-release/lsb-release "ID" "fedora"
    set_property /etc/upstream-release/lsb-release "PRETTY_NAME" "Fedora Linux $version_id"
    set_property /etc/upstream-release/lsb-release "VERSION_ID" "$version_id"
fi

pretty_name="Sodalite $version_pretty"

set_property /usr/lib/os-release "BUG_REPORT_URL" "https:\/\/sodalite.rocks\/bug-report"
set_property /usr/lib/os-release "CPE_NAME" "$cpe"
set_property /usr/lib/os-release "DOCUMENTATION_URL" "https:\/\/sodalite.rocks\/docs"
set_property /usr/lib/os-release "HOME_URL" "https:\/\/sodalite.rocks"
set_property /usr/lib/os-release "ID" "sodalite"
set_property /usr/lib/os-release "ID_LIKE" "fedora"
set_property /usr/lib/os-release "NAME" "Sodalite"
set_property /usr/lib/os-release "PRETTY_NAME" "$pretty_name"
set_property /usr/lib/os-release "SUPPORT_URL" "https:\/\/sodalite.rocks\/support"
set_property /usr/lib/os-release "VERSION" "$version_pretty"
set_property /usr/lib/os-release "VERSION_ID" "$version_id"

del_property /usr/lib/os-release "ANSI_COLOR"
del_property /usr/lib/os-release "PRIVACY_POLICY_URL"
del_property /usr/lib/os-release "REDHAT_BUGZILLA_PRODUCT"
del_property /usr/lib/os-release "REDHAT_BUGZILLA_PRODUCT_VERSION"
del_property /usr/lib/os-release "REDHAT_SUPPORT_PRODUCT"
del_property /usr/lib/os-release "REDHAT_SUPPORT_PRODUCT_VERSION"
del_property /usr/lib/os-release "VERSION_CODENAME"

sed -i "/^$/d" /usr/lib/os-release

echo "$pretty_name" > /usr/lib/sodalite-release
echo "$pretty_name" > /usr/lib/system-release
echo $(echo "$cpe" | sed "s@\\\\@@g") > /usr/lib/system-release-cpe

rm /etc/os-release
rm /etc/system-release
rm /etc/system-release-cpe

ln -s /usr/lib/os-release /etc/os-release
ln -s /usr/lib/sodalite-release /etc/sodalite-release
ln -s /usr/lib/system-release /etc/system-release
ln -s /usr/lib/system-release-cpe /etc/system-release-cpe

#########
# HACKS #
#########

# TODO: Work out if we even need some of these, as the related issues are
#       pretty old.

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

if [[ $core == "pantheon" ]]; then
    # Some hacks for libayatana to work properly. Might stop working one day.
    ln -s /usr/lib64/libwingpanel.so.3 /usr/lib64/libwingpanel-2.0.so.0
    sed -i 's/lib\/x86_64-linux-gnu/lib64/g' /etc/xdg/autostart/indicator-application.desktop
fi

############
# REMOVALS #
############

# HACK: Removing files here instead because we're not using --unified-core
#       (see https://github.com/sodaliterocks/sodalite/issues/9#issuecomment-1010384738)

declare -a to_remove

if [[ $core == "gnome" ]]; then
    to_remove+=(
        # misc.
        "/usr/share/gnome-shell/extensions/apps-menu@gnome-shell-extensions.gcampax.github.com"
        "/usr/share/gnome-shell/extensions/launch-new-instance@gnome-shell-extensions.gcampax.github.com"
        "/usr/share/gnome-shell/extensions/places-menu@gnome-shell-extensions.gcampax.github.com"
        "/usr/share/gnome-shell/extensions/window-list@gnome-shell-extensions.gcampax.github.com"
    )
fi

if [[ $core == "pantheon" ]]; then
    to_remove+=(
        # desktop-backgrounds-compat
        "/usr/share/backgrounds/default.png"
        "/usr/share/backgrounds/default.xml"
        "/usr/share/backgrounds/images"
        "/usr/share/backgrounds/images/default-16_10.png"
        "/usr/share/backgrounds/images/default-16_9.png"
        "/usr/share/backgrounds/images/default-5_4.png"
        "/usr/share/backgrounds/images/default.png"
        # evolution-data-server
        "/etc/xdg/autostart/org.gnome.Evolution-alarm-notify.desktop"
        "/usr/libexec/evolution-data-server/evolution-alarm-notify"
        # fedora-workstation-backgrounds
        "/usr/share/backgrounds/fedora-workstation/"
        "/usr/share/doc/fedora-workstation-backgrounds/"
        "/usr/share/gnome-background-properties/fedora-workstation-backgrounds.xml"
        "/usr/share/licenses/fedora-workstation-backgrounds"
        # firefox
        "/usr/lib64/firefox/browser/defaults/preferences/firefox-redhat-default-prefs.js"
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
        "/usr/share/dbus-1/services/org.gnome.ControlCenter.service"
        "/usr/share/doc/gnome-control-center/"
        "/usr/share/glib-2.0/schemas/org.gnome.ControlCenter.gschema.xml"
        "/usr/share/gnome-control-center/"
        "/usr/share/gnome-shell/search-providers/gnome-control-center-search-provider.ini"
        "/usr/share/locale/*/LC_MESSAGES/gnome-control-center-2.0.mo"
        "/usr/share/locale/*/LC_MESSAGES/gnome-control-center-2.0-timezones.mo"
        "/usr/share/man/man1/gnome-control-center.1.gz"
        "/usr/share/metainfo/gnome-control-center.appdata.xml"
        "/usr/share/polkit-1/actions/org.gnome.controlcenter.datetime.policy"
        "/usr/share/polkit-1/actions/org.gnome.controlcenter.remote-login-helper.policy"
        "/usr/share/polkit-1/actions/org.gnome.controlcenter.user-accounts.policy"
        "/usr/share/polkit-1/rules.d/gnome-control-center.rules"
        "/usr/share/sounds/gnome/"
        # gnome-session
        "/usr/share/wayland-sessions/gnome.desktop"
        "/usr/share/wayland-sessions/gnome-wayland.desktop"
        "/usr/share/xsessions/gnome.desktop"
        "/usr/share/xsessions/gnome-xorg.desktop"
        # gnome-themes-extra
        "/usr/share/doc/gnome-themes-extra/"
        "/usr/share/licenses/gnome-themes-extra/"
        "/usr/share/themes/Adwaita-dark/"
        "/usr/share/themes/Adwaita/"
        "/usr/share/themes/HighContrast/"
        # light-locker
        "/etc/xdg/autostart/light-locker.desktop"
        # plank
        "/etc/xdg/autostart/plank.desktop"
        # ufw
        "/etc/ufw/"
        "/usr/lib/python3.10/site-packages/ufw/"
        "/usr/lib/systemd/system/ufw.service"
        "/usr/libexec/ufw/"
        "/usr/sbin/ufw"
        "/usr/share/doc/ufw/"
        "/usr/share/licenses/ufw/"
        "/usr/share/locale/*/LC_MESSAGES/ufw.mo"
        "/usr/share/man/man8/ufw-framework.8.gz"
        "/usr/share/man/man8/ufw.8.gz"
        "/usr/share/ufw/"
        # misc.
        "/usr/share/bookmarks/"
        "/usr/share/glib-2.0/schemas/io.elementary.desktop.gschema.override"
        "/usr/share/icewm/"
        "/usr/share/pixmaps/faces/"
    )

    if [ $version_id -gt 36 ]; then
        # Indicators are broken on f37+
        to_remove+=(
            "/etc/xdg/autostart/indicator-application.desktop"
            "/usr/lib64/switchboard/personal/libindicators.so"
            "/usr/lib64/wingpanel/libayatana.so"
            "/usr/lib/indicators3/7/libapplication.so"
            "/usr/lib/systemd/user/indicator-application.service"
            "/usr/lib64/indicator-application/indicator-application-service"
        )
    fi

    if [[ $variant != "experimental-pantheon-nightly" ]]; then
        # These Pantheon packages are considered broken, so we'll only keep them
        # for this variant
        to_remove+=(
            # elementary-greeter
            "/etc/lightdm/io.elementary.greeter.conf"
            "/etc/lightdm/lightdm.conf.d/40-io.elementary.greeter.conf"
            "/usr/bin/io.elementary.greeter-compositor"
            "/usr/sbin/io.elementary.greeter"
            "/usr/share/doc/elementary-greeter/"
            "/usr/share/licenses/elementary-greeter/"
            "/usr/share/locale/*/LC_MESSAGES/io.elementary.greeter.mo"
            "/usr/share/metainfo/io.elementary.greeter.appdata.xml"
            "/usr/share/xgreeters/io.elementary.greeter.desktop"
            # switchboard-plug-locale
            "/usr/lib64/switchboard/personal/liblocale-plug.so"
            "/usr/share/doc/switchboard-plug-locale/"
        )
    else
        # If we're on this variant, remove the lightdm-gtk-greeter files so it
        # doesn't interfere with elementary-greeter
        to_remove+=(
            # lightdm-gtk-greeter
            "/etc/lightdm/lightdm-gtk-greeter.conf"
            "/usr/share/lightdm/lightdm.conf.d/60-lightdm-gtk-greeter.conf"
        )
    fi
fi

if [[ -f "/usr/share/applications/rocks.sodalite.phone-mirror.desktop" ]]; then
    to_remove+=(
        "/usr/share/applications/scrcpy.desktop"
    )
fi

to_remove+=(
    "/usr/share/backgrounds/f36"
    "/usr/share/backgrounds/f37"
    "/usr/share/backgrounds/fedora-workstation"
)

for file in ${to_remove[@]}; do
    rm -rf $file
done

#############
# WALLPAPER #
#############

wallpaper=""

case $version_id in
    35) wallpaper="karsten-wurth-7BjhtdogU3A-unsplash" ;;
    36) wallpaper="max-okhrimenko-R-CoXmMrWFk-unsplash" ;;
    37) wallpaper="jeremy-gerritsen-_iviuukstI4-unsplash" ;;
    38) wallpaper="zara-walker-_pC5hT6aXfs-unsplash" ;;
    39) wallpaper="jack-b-vcNPMwS08UI-unsplash" ;;
esac

if [[ -f "/usr/share/backgrounds/default/$wallpaper.jpg" ]]; then
    set_property /usr/share/glib-2.0/schemas/00_sodalite.gschema.override picture-uri "'file:\/\/\/usr\/share\/backgrounds\/default\/$wallpaper.jpg'"
    [[ $core == "pantheon" ]] && ln -s /usr/share/backgrounds/default/$wallpaper.jpg /usr/share/backgrounds/elementaryos-default
fi

###################
# FLATPAK ALIASES #
###################

declare -a flatpak_app_aliases

if [[ $core == "pantheon" ]]; then
    flatpak_app_aliases+=(
        "org.gnome.Evince:org.gnome.Evince"
        "org.gnome.FileRoller:org.gnome.FileRoller"
        "io.elementary.calculator:io.elementary.calculator"
        "io.elementary.calendar:io.elementary.calendar"
        "io.elementary.camera:io.elementary.camera"
        "io.elementary.capnet-assist:io.elementary.capnet-assist"
        "io.elementary.screenshot:io.elementary.screenshot"
        "io.elementary.videos:io.elementary.videos"
    )
fi

for flatpak_app_alias in ${flatpak_app_aliases[@]}; do
    app="$(echo $flatpak_app_alias | cut -d ":" -f1)"
    alias="$(echo $flatpak_app_alias | cut -d ":" -f2)"
    alias_path="/usr/bin/$alias"

    if [[ ! -f "$alias_path" ]]; then
        echo -e "#\x21/usr/bin/env sh" > "$alias_path"
        echo -e "rocks.sodalite.flatpak-helper $app \$@" >> "$alias_path"
        chmod +x "$alias_path"
    fi
done

##########
# EXTRAS #
##########

ln -s /usr/bin/rocks.sodalite.hacks /usr/bin/sodalite-hacks
ln -s /usr/bin/firefox /usr/bin/rocks.sodalite.firefox

/usr/src/rocks.sodalite.firefox/setup.sh
rm -rf /usr/src/rocks.sodalite.firefox
rm -f /usr/lib64/firefox/browser/omni.ja_backup

glib-compile-schemas /usr/share/glib-2.0/schemas
dconf update

if [[ $core == "gnome" ]]; then
    gnome_extensions_prefix="/usr/share/gnome-shell/extensions"

    declare -a gnome_extensions=(
        "AlphabeticalAppGrid@stuarthayhurst"
    )

    for gnome_extension in ${gnome_extensions[@]}; do
        mkdir -p "$gnome_extensions_prefix/$gnome_extension"
        unzip "$gnome_extensions_prefix/$gnome_extension.shell-extension.zip" -d "$gnome_extensions_prefix/$gnome_extension"
        rm "$gnome_extensions_prefix/$gnome_extension.shell-extension.zip"
    done
fi

if [[ $core == "pantheon" ]]; then
  mv /usr/bin/gnome-software /usr/bin/gnome-software-bin
  mv /usr/bin/gnome-software-wrapper /usr/bin/gnome-software

  systemctl disable gdm
  systemctl enable generate-oemconf
  systemctl enable lightdm
  systemctl enable touchegg
fi

systemctl enable sodalite-migrate

