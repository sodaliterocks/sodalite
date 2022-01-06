#!/usr/bin/env bash

if [[ $(realpath -s "$0") == "/usr/bin/sodalite-"* ]]; then
    . /usr/libexec/sodalite-common
    oem_logo_root="/usr/share/oem-logos"
else
    . "$(dirname "$(realpath -s "$0")")/common.sh"
    oem_logo_root="$(dirname "$(realpath -s "$0")")/../oem-logos"
fi

function get_oem_logo_path() {
    manufacturer=${1,,}
    root=$2

    if [[ -z $root ]]; then
        root=$oem_logo_root
    fi

    echo "$root/$manufacturer.png"
}

test_root

set_export SODALITE_GENERATE_OEM_NO_HACKS false
set_export SODALITE_OEM_MANUFACTURER ""
set_export SODALITE_OEM_PRODUCT ""
set_export SODALITE_OEM_VERSION ""
set_export SODALITE_OEM_LOGO ""
set_export SODALITE_OEM_URL ""

echo "Generating OEM information..."

oem_file="/etc/oem.conf"
oem_logo_file="/etc/oem-logo.png"

hw_manufacturer=$(get_hwinfo 'Manufacturer')
hw_product=$(get_hwinfo 'Product Name')
hw_version=$(get_hwinfo 'Version')
hw_logo=""
hw_url=""

case ${hw_manufacturer,,} in
    "acer")
        hw_url="https://acer.com/support"
        ;;
    "apple")
        hw_url="https://support.apple.com"
        ;;
    "asus")
        hw_url="https://www.asus.com/support"
        ;;
    "hp")
        hw_url="https://support.hp.com"
        ;;
    "huawei")
        hw_url="https://consumer.huawei.com" # No canon URL to support site
        ;;
    "ibm"|"lenovo")
        hw_url="https://support.lenovo.com"
        ;;
    "lg")
        hw_url="https://www.lg.com/support"
        ;;
    "microsoft")
        hw_url="https://support.microsoft.com"
        ;;
    "msi"|"micro-star international"*)
        hw_logo=$(get_oem_logo_path msi)
        hw_url="https://www.msi.com/support"
        ;;
    "qemu")
        hw_url="https://www.qemu.org/docs/master"
        ;;
    "samsung")
        hw_url="https://www.samsung.com/support"
        ;;
    "system76"*)
        hw_logo=$(get_oem_logo_path system76)
        hw_url="https://support.system76.com"
        ;;
esac

if [[ $SODALITE_GENERATE_OEM_NO_HACKS == false ]]; then
    case ${hw_manufacturer,,} in
        "google") # Chromebook's (are annoying)
            if [[ $hw_manufacturer == "GOOGLE" ]]; then
                hw_product_original=$hw_product

                hw_manufacturer="Google"
                hw_product="Chromebook"
                hw_version=$hw_product_original
                hw_logo=$(get_oem_logo_path chromebook)
            fi
            ;;
        "hp")
            if [[ $hw_version == "Type1ProductConfigId" ]]; then
                hw_version=""
            fi

            if [[ $hw_product == HP* ]]; then
                hw_product_original=${hw_product/HP /}
                hw_product=${hw_product_original%-*}
                hw_version=${hw_product_original#*-}

                [[ -z $hw_product ]] && hw_product=$hw_product_original
            fi
            ;;
        "msi"|"micro-star international"*)
            alt_hw_product=$(get_hwinfo 'Product Name' 2)
            [[ ! -z $alt_hw_product ]] && hw_product=$alt_hw_product

            if { [[ $hw_product == *"("* ]] && [[ $hw_product == *")"* ]]; }; then
                hw_product_original=$hw_product
                hw_product=${hw_product_original%(*}

                hw_version=${hw_product_original#*\(}
                hw_version=${hw_version%)*}
            fi
            ;;
    esac
fi

[[ ! -z $SODALITE_OEM_MANUFACTURER ]] && hw_manufacturer=$SODALITE_OEM_MANUFACTURER
[[ ! -z $SODALITE_OEM_PRODUCT ]] && hw_product=$SODALITE_OEM_PRODUCT
[[ ! -z $SODALITE_OEM_VERSION ]] && hw_version=$SODALITE_OEM_VERSION
[[ ! -z $SODALITE_OEM_LOGO ]] && hw_logo=$SODALITE_OEM_LOGO
[[ ! -z $SODALITE_OEM_SUPPORT_URL ]] && hw_support_url=$SODALITE_OEM_URL

if [[ -z $hw_logo ]]; then
    hw_logo_path=$(get_oem_logo_path ${hw_manufacturer,,})
    hw_logo_path_local=$(get_oem_logo_path ${hw_manufacturer,,} "/usr/local/share/oem-logos")
    hw_logo_path_local_file="/usr/local/share/oem-logo.png"

    if [[ -f $hw_logo_path_local_file ]]; then
        hw_logo=$hw_logo_path_local_file
    elif [[ -f $hw_logo_path_local ]]; then
        hw_logo=$hw_logo_path_local
    elif [[ -f $hw_logo_path ]]; then
        hw_logo=$hw_logo_path
    else
        cpu_vendor=$(get_cpu_vendor)

        case $cpu_vendor in
            "AuthenticAMD") hw_logo=$(get_oem_logo_path amd) ;;
            "GenuineIntel") hw_logo=$(get_oem_logo_path intel) ;;
        esac
    fi
fi

echo "[OEM]" > $oem_file
[[ ! -z $hw_manufacturer ]] && echo "Manufacturer=$hw_manufacturer" >> $oem_file
[[ ! -z $hw_product ]] && echo "Product=$hw_product" >> $oem_file
[[ ! -z $hw_version ]] && echo "Version=$hw_version" >> $oem_file
[[ ! -z $hw_logo ]] && echo "Logo=$hw_logo" >> $oem_file
[[ ! -z $hw_url ]] && echo "URL=$hw_url" >> $oem_file
