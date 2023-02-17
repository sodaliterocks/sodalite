#!/usr/bin/env bash

base_id=""
base_name="Fedora Linux"
base_version="$_os_base_version"
channel=""
channel_id=""
id=""
name="Sodalite"
pretty_name=""
pretty_version=""
variant=""
variant_id="$_os_variant"
vendor="$_vendor"
version=""
version_v_major=""
version_v_minor=""
version_v_build=""
version_v_hash=""
version_codename=""
version_id=""

function get_codename() {
    # Codename inspiration:
    # * https://en.wikipedia.org/wiki/Ancient_history

    case "$1" in
        "4.0"*) echo "Nubia" ;;
        "5.0"*) echo "Iberia" ;;
    esac
}

function get_id() {
    name="$1"

    name="$(echo $name | sed "s/ Linux//")"
    echo $(echo ${name,,} | sed "s/ /-/")
}

function get_variant() {
    decoded_variant=""

    if [[ $1 == "desktop-"* ]]; then
        decoded_variant="$(echo $1 | sed "s/desktop-//")"

        case "$decoded_variant" in
            "gnome") decoded_variant="GNOME" ;;
            *) decoded_variant="${decoded_variant^}" ;;
        esac
    else
        decoded_variant="${1^}"
    fi

    echo $decoded_variant
}

base_id="$(get_id "$base_name")"
id="$(get_id "$name")"
variant="$(get_variant "$variant_id")"

if [[ $(get_property /etc/os-release VERSION) =~ (([0-9]{1,2}).([0-9]{1,3})(rc[0-9]{1,3}){0,1}-([0-9]{5})(\.([0-9]{1,})){0,1}) ]]; then
    version_v_major="${BASH_REMATCH[2]}"
    version_v_minor="${BASH_REMATCH[3]}"

    if [[ ${BASH_REMATCH[4]} != "" ]]; then
        version_v_minor+="${BASH_REMATCH[4]}"
    fi

    version_v_build="${BASH_REMATCH[5]}.${BASH_REMATCH[7]}"

    if [[ $_git_hash != "" ]]; then
        version_v_hash="$_git_hash"
    fi
fi

if [[ $version_v_major != "" ]]; then
    version="$version_v_major"
    version_id="$version_v_major.$version_v_minor"
    channel_id="${BASH_REMATCH[1]}"

    if [[ $_os_ref =~ sodalite\/([^;]*)\/([^;]*)\/([^;]*) ]]; then
        channel_id="${BASH_REMATCH[1]}"

        [[ $channel_id == "stable" ]] && channel_id="current"

        if [[ $channel_id != "" ]]; then
            case $channel_id in
                "current") channel="Current" ;;
                "next") channel="Next" ;;
                "long-"*|"f"*) channel="Long" ;;
                "devel") channel="Devel" ;;
                *) channel="$channel_id" ;;
            esac
        fi
    fi

    if [[ $_git_tag != "" ]]; then
        # Tagged (Releases)

        [[ $version_v_minor != "0" ]] && version+=".$version_v_minor"
        version_codename="$(get_codename $version_id)"

        if [[ $variant_id == "desktop" ]]; then
            pretty_version="$version $version_codename"
        else
            pretty_version="$version $variant"
        fi

        if [[ $channel_id == "current" ]]; then
            channel=""
        fi
    else
        # Un-tagged (Devel)

        version+=".$version_v_minor"
        [[ $version_v_build != "" ]] && version+="-$version_v_build"
        [[ $version_v_hash != "" ]] && version+="+$version_v_hash"

        if [[ $channel_id == "devel" ]]; then
            channel=""
        else
            channel="$channel_id"
        fi

        pretty_version="$version"

        mkdir -p /etc/apt/sources.list.d/
        echo "daily" > /etc/apt/sources.list.d/elementary.list
    fi

    if [[ $channel != "" ]]; then
        pretty_version="$pretty_version ($channel)"
    fi
fi

if [[ ! -z $base_version ]]; then
    touch /usr/lib/upstream-os-release

    set_property /usr/lib/upstream-os-release "ID" "$base_id"
    set_property /usr/lib/upstream-os-release "VERSION_ID" "$base_version"
    set_property /usr/lib/upstream-os-release "PRETTY_NAME" "$base_name $base_version"
fi

cpe="cpe:\/o:$vendor:$id:$version_id:$version_v_build+$version_v_hash$([[ $channel_id != "" ]] && echo "\/$channel_id"):$variant_id"
pretty_name="$name $pretty_version"

del_property /usr/lib/os-release "ANSI_COLOR"
del_property /usr/lib/os-release "DEFAULT_HOSTNAME"
del_property /usr/lib/os-release "PRIVACY_POLICY_URL"
del_property /usr/lib/os-release "REDHAT_BUGZILLA_PRODUCT"
del_property /usr/lib/os-release "REDHAT_BUGZILLA_PRODUCT_VERSION"
del_property /usr/lib/os-release "REDHAT_SUPPORT_PRODUCT"
del_property /usr/lib/os-release "REDHAT_SUPPORT_PRODUCT_VERSION"
del_property /usr/lib/os-release "VERSION_CODENAME"

set_property /usr/lib/os-release "CPE_NAME" "$cpe"
set_property /usr/lib/os-release "ID" "$id"
set_property /usr/lib/os-release "ID_LIKE" "$base_id"
set_property /usr/lib/os-release "NAME" "$name"
set_property /usr/lib/os-release "LOGO" "distributor-logo"
set_property /usr/lib/os-release "PRETTY_NAME" "$pretty_name"
set_property /usr/lib/os-release "VARIANT" "$variant"
set_property /usr/lib/os-release "VARIANT_ID" "$variant_id"
set_property /usr/lib/os-release "VERSION" "$pretty_version"
set_property /usr/lib/os-release "VERSION_CODENAME" "$version_codename"
set_property /usr/lib/os-release "VERSION_ID" "$base_version"

if [[ $vendor == "sodaliterocks" ]]; then
    url_prefix="https:\/\/sodalite.rocks"
    set_property /usr/lib/os-release "BUG_REPORT_URL" "$url_prefix\/bug-report"
    set_property /usr/lib/os-release "DOCUMENTATION_URL" "$url_prefix\/docs"
    set_property /usr/lib/os-release "HOME_URL" "$url_prefix"
    set_property /usr/lib/os-release "SUPPORT_URL" "$url_prefix\/support"
else
    del_property /usr/lib/os-release "BUG_REPORT_URL"
    del_property /usr/lib/os-release "DOCUMENTATION_URL"
    del_property /usr/lib/os-release "HOME_URL"
    del_property /usr/lib/os-release "SUPPORT_URL"
fi

sed -i "/^$/d" /usr/lib/os-release

echo "$pretty_name" > /usr/lib/sodalite-release

rm -f /etc/os-release
rm -f /etc/system-release
rm -f /etc/system-release-cpe
rm -f /usr/lib/system-release

ln -s /usr/lib/os-release /etc/os-release
ln -s /usr/lib/sodalite-release /etc/sodalite-release
ln -s /usr/lib/sodalite-release /usr/lib/system-release
ln -s /usr/lib/system-release /etc/system-release
ln -s /usr/lib/system-release-cpe /etc/system-release-cpe

_os_version="$version"
_os_version_id="$version_id"

cat /usr/lib/os-release
