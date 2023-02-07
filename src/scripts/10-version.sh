#!/usr/bin/env bash

name="Sodalite"
name_id="$(echo ${name,,} | sed "s/ /-/")"
pretty_name=""
pretty_version=""
version=""
version_v_major=""
version_v_minor=""
version_v_build=""
version_v_hash=""
version_base="$_os_version_base"
version_codename="Caral"
version_id=""

if [[ $(get_property /etc/os-release VERSION) =~ (([0-9]{1,2}).([0-9]{1,3})-([0-9]{5})(\.([0-9]{1,})){0,1}) ]]; then
    version_v_major="${BASH_REMATCH[2]}"
    version_v_minor="${BASH_REMATCH[3]}"

    if [[ ${BASH_REMATCH[6]} != "0" ]]; then
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
    version_id="$version_v_major"

    if [[ $version_v_minor != "0" ]]; then
        version+=".$version_v_minor"
        version_id+=".$version_v_minor"
    fi

    if [[ $version_v_hash != "" ]]; then
        if [[ $_git_tag != "" ]]; then
            version+="+$version_v_hash"
        fi
    fi

    if [[ $version_v_hash == "" ]]; then
        case "$version_id" in
            "4") version_codename="Nubia" ;;
            "5") version_codename="Qatna" ;;
        esac
    fi
fi

if [[ ! -z $version_base ]]; then
    touch /usr/lib/upstream-os-release

    set_property /usr/lib/upstream-os-release "ID" "fedora"
    set_property /usr/lib/upstream-os-release "VERSION_ID" "$version_base"
    set_property /usr/lib/upstream-os-release "PRETTY_NAME" "Fedora Linux $version_base"

    if [[ $version_base == "36" ]]; then
        mkdir -p /etc/upstream-release
        ln -s /usr/lib/upstream-os-release /etc/upstream-release/lsb-release
    fi
fi

pretty_version="$version $version_codename"
pretty_name="$name $pretty_version"
cpe="cpe:\/o:sodaliterocks:$name_id:$version_id:$version_v_build+$version_v_hash"

set_property /usr/lib/os-release "BUG_REPORT_URL" "https:\/\/sodalite.rocks\/bug-report"
set_property /usr/lib/os-release "CPE_NAME" "$cpe"
set_property /usr/lib/os-release "DOCUMENTATION_URL" "https:\/\/sodalite.rocks\/docs"
set_property /usr/lib/os-release "HOME_URL" "https:\/\/sodalite.rocks"
set_property /usr/lib/os-release "ID" "$name_id"
set_property /usr/lib/os-release "ID_LIKE" "fedora"
set_property /usr/lib/os-release "NAME" "$name"
set_property /usr/lib/os-release "LOGO" "distributor-logo"
set_property /usr/lib/os-release "PRETTY_NAME" "$pretty_name"
set_property /usr/lib/os-release "SUPPORT_URL" "https:\/\/sodalite.rocks\/support"
set_property /usr/lib/os-release "VERSION" "$pretty_version"
set_property /usr/lib/os-release "VERSION_ID" "$version_base"

del_property /usr/lib/os-release "ANSI_COLOR"
del_property /usr/lib/os-release "DEFAULT_HOSTNAME"
del_property /usr/lib/os-release "PRIVACY_POLICY_URL"
del_property /usr/lib/os-release "REDHAT_BUGZILLA_PRODUCT"
del_property /usr/lib/os-release "REDHAT_BUGZILLA_PRODUCT_VERSION"
del_property /usr/lib/os-release "REDHAT_SUPPORT_PRODUCT"
del_property /usr/lib/os-release "REDHAT_SUPPORT_PRODUCT_VERSION"
del_property /usr/lib/os-release "VERSION_CODENAME"

sed -i "/^$/d" /usr/lib/os-release

echo "$pretty_name" > /usr/lib/sodalite-release
echo "$pretty_name" > /usr/lib/system-release

_os_version="$version"
_os_version_id="$version_id"
