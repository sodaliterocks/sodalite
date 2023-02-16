# HACK: Removing files here instead because we're not using --unified-core
#       (see https://github.com/sodaliterocks/sodalite/issues/9#issuecomment-1010384738)
#!/usr/bin/env bash

declare -a to_remove

if [[ $_os_core == "gnome" ]]; then
    to_remove+=(
        # misc.
        "/usr/share/gnome-shell/extensions/apps-menu@gnome-shell-extensions.gcampax.github.com"
        "/usr/share/gnome-shell/extensions/launch-new-instance@gnome-shell-extensions.gcampax.github.com"
        "/usr/share/gnome-shell/extensions/places-menu@gnome-shell-extensions.gcampax.github.com"
        "/usr/share/gnome-shell/extensions/window-list@gnome-shell-extensions.gcampax.github.com"
    )
fi

if [[ $_os_core == "pantheon" ]]; then
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
        # switchboard-plug-locale
        "/usr/lib64/switchboard/personal/liblocale-plug.so"
        "/usr/share/doc/switchboard-plug-locale/"
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

    if [ $_os_base_version -gt 36 ]; then
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

    if [[ -f "/usr/sbin/lightdm-gtk-greeter" ]]; then
        to_remove+=(
            "/etc/lightdm/io.elementary.greeter.conf"
            "/etc/lightdm/lightdm.conf.d/40-io.elementary.greeter.conf"
            "/usr/bin/io.elementary.greeter-compositor"
            "/usr/sbin/io.elementary.greeter"
            "/usr/share/doc/elementary-greeter/"
            "/usr/share/licenses/elementary-greeter/"
            "/usr/share/locale/*/LC_MESSAGES/io.elementary.greeter.mo"
            "/usr/share/metainfo/io.elementary.greeter.appdata.xml"
            "/usr/share/xgreeters/io.elementary.greeter.desktop"
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
    "/usr/share/backgrounds/f38"
    "/usr/share/backgrounds/fedora-workstation"
)

for file in ${to_remove[@]}; do
    echo "Removing: $file"
    rm -rf $file
done
