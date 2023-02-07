#!/usr/bin/env bash

base_id=""
base_name="Fedora Linux"
base_version="$_os_base_version"
id=""
name="Sodalite"
pretty_name=""
pretty_version=""
version=""
version_v_major=""
version_v_minor=""
version_v_build=""
version_v_hash=""
version_codename=""
version_id=""

function get_codename() {
    case "$1" in
        "4.0"*) echo "Nubia" ;;
        "5.0"*) echo "Qatna" ;;
    esac
}

function get_id() {
    name="$1"

    name="$(echo $name | sed "s/ Linux//")"
    echo $(echo ${name,,} | sed "s/ /-/")
}

base_id="$(get_id "$base_name")"
id="$(get_id "$name")"

if [[ $(get_property /etc/os-release VERSION) =~ (([0-9]{1,2}).([0-9]{1,3})-([0-9]{5})(\.([0-9]{1,})){0,1}) ]]; then
    version_v_major="${BASH_REMATCH[2]}"
    version_v_minor="${BASH_REMATCH[3]}"

    if [[ ${BASH_REMATCH[6]} == "0" ]]; then
        version_v_build="${BASH_REMATCH[4]}"
    else
        version_v_build="${BASH_REMATCH[4]}.${BASH_REMATCH[6]}"
    fi

    if [[ $_git_hash != "" ]]; then
        version_v_hash="$_git_hash"
    fi
fi

if [[ $version_v_major != "" ]]; then
    version="$version_v_major"
    version_id="$version_v_major.$version_v_minor"

    if [[ $_git_tag != "" ]]; then
        # Production Release

        [[ $version_v_minor != "0" ]] && version+=".$version_v_minor"
        version_codename="$(get_codename $version_id)"

        pretty_version="$version “$version_codename”"
    else
        # Early Release

        version+=".$version_v_minor"
        [[ $version_v_build != "" ]] && version+="-$version_v_build"
        [[ $version_v_hash != "" ]] && version+="+$version_v_hash"

        pretty_version="$version"

        mkdir -p /etc/apt/sources.list.d/
        echo "daily" > /etc/apt/sources.list.d/elementary.list
    fi
fi

if [[ ! -z $base_version ]]; then
    touch /usr/lib/upstream-os-release

    set_property /usr/lib/upstream-os-release "ID" "$base_id"
    set_property /usr/lib/upstream-os-release "VERSION_ID" "$base_version"
    set_property /usr/lib/upstream-os-release "PRETTY_NAME" "$base_name $base_version"

    if [[ $base_version == "36" ]]; then
        mkdir -p /etc/upstream-release
        ln -s /usr/lib/upstream-os-release /etc/upstream-release/lsb-release
    fi
fi

cpe="cpe:\/o:sodaliterocks:$id:$version_id:$version_v_build+$version_v_hash"
pretty_name="$name $pretty_version"
url_prefix="https:\/\/sodalite.rocks"

del_property /usr/lib/os-release "ANSI_COLOR"
del_property /usr/lib/os-release "DEFAULT_HOSTNAME"
del_property /usr/lib/os-release "PRIVACY_POLICY_URL"
del_property /usr/lib/os-release "REDHAT_BUGZILLA_PRODUCT"
del_property /usr/lib/os-release "REDHAT_BUGZILLA_PRODUCT_VERSION"
del_property /usr/lib/os-release "REDHAT_SUPPORT_PRODUCT"
del_property /usr/lib/os-release "REDHAT_SUPPORT_PRODUCT_VERSION"
del_property /usr/lib/os-release "VERSION_CODENAME"

set_property /usr/lib/os-release "BUG_REPORT_URL" "$url_prefix\/bug-report"
set_property /usr/lib/os-release "CPE_NAME" "$cpe"
set_property /usr/lib/os-release "DOCUMENTATION_URL" "$url_prefix\/docs"
set_property /usr/lib/os-release "HOME_URL" "$url_prefix"
set_property /usr/lib/os-release "ID" "$id"
set_property /usr/lib/os-release "ID_LIKE" "$base_id"
set_property /usr/lib/os-release "NAME" "$name"
set_property /usr/lib/os-release "LOGO" "distributor-logo"
set_property /usr/lib/os-release "PRETTY_NAME" "$pretty_name"
set_property /usr/lib/os-release "SUPPORT_URL" "$url_prefix\/support"
set_property /usr/lib/os-release "VERSION" "$pretty_version"
set_property /usr/lib/os-release "VERSION_CODENAME" "$version_codename"
set_property /usr/lib/os-release "VERSION_ID" "$base_version"

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
