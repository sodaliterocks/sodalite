#!/usr/bin/env bash
# TODO: Make this its own self-contained script. Would be useful for anyone on elementaryOS!

if [[ $(realpath -s "$0") == "/usr/bin/sodalite-"* ]]; then
    . /usr/libexec/sodalite-common
    oem_logo_root="/usr/share/oem-logos"
else
    . "$(dirname "$(realpath -s "$0")")/common.sh"
    oem_logo_root="$(dirname "$(realpath -s "$0")")/../../../lfs/oem-logos"
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

dmidecode_type=1

if [[ $(get_hwinfo 'Serial Number') == "To be filled by O.E.M." ]]; then
    # This is a custom build here so we'll use the motherboard info instead
    dmidecode_type=2
fi

hw_manufacturer=$(get_hwinfo 'Manufacturer' $dmidecode_type)
hw_product=$(get_hwinfo 'Product Name' $dmidecode_type)
hw_version=$(get_hwinfo 'Version' $dmidecode_type)
hw_logo=""
hw_url=""

if { 
    [[ $hw_version == "1.0" ]] ||
    [[ $hw_version == "Type1ProductConfigId" ]];
}; then
    hw_version=""
fi

case ${hw_manufacturer,,} in
    "asus"|"asustek"*) # ASUS (ASUSTek Computer Inc.)
        hw_manufacturer="ASUS"
        hw_url="https://www.asus.com/support"
        ;;
    "dell"|"dell inc"*) # Dell (Dell Inc.)
        hw_manufacturer="Dell"
        hw_url="https://www.dell.com/support"
        ;;
    "gigabyte technology"*|"giga-byte technology"*) # GIGABYTE (Gigabyte Technology Co., Ltd)
        hw_manufacturer="GIGABYTE"
        hw_url="https://www.gigabyte.com/Support"
        ;;
    "hp"|"hewlett-packard") # HP (HP Inc.)
        hw_manufacturer="HP"
        hw_url="https://support.hp.com"
        ;;
    "msi"|"micro-star international"*) # MSI (Micro-Star International Co., Ltd)
        hw_manufacturer="MSI"
        hw_url="https://www.msi.com/support"
        ;;
    "microsoft"|"microsoft corp"*) # Microsoft (Microsoft Corp.)
        hw_manufacturer="Microsoft"
        hw_url="https://support.microsoft.com"
        ;;
    "vmware"*) # VMware (VMware, Inc.)
        hw_manufacturer="VMware"
        hw_url="https://www.vmware.com/support"
        ;;
    "acer")
        hw_url="https://acer.com/support"
        ;;
    "apple")
        hw_url="https://support.apple.com"
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
    "medion")
        hw_url="https://www.medion.com" # No canon URL to support site
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
    case ${hw_manufacturer,,} in # The hw_manufacturer may have been modified up above
        "asus")
            if [[ $hw_product =~ (([A-Za-z]{1,})_ASUSLaptop ([A-Za-z0-9]{1,})[_]{0,}([A-Za-z0-9]{0,})) ]]; then
                hw_product="${BASH_REMATCH[2]}"
                hw_version="${BASH_REMATCH[4]}"
            fi
            ;;
        "dell")
            if [[ $hw_product =~ (Dell System ([A-Za-z0-9\-\ ]{1,})) ]]; then
                hw_product="${BASH_REMATCH[2]}"
            fi
            ;;
        "google") # Chromebook's (are annoying)
            if [[ $hw_manufacturer == "GOOGLE" ]]; then
                hw_logo=$(get_oem_logo_path chromebook)
                hw_version=$hw_product
                hw_manufacturer="Google"
                hw_product="Chromebook"
            fi
            ;;
        "hp")
            if [[ $hw_product == HP* ]]; then
                if [[ $hw_product =~ (HP ([A-Za-z0-9\ ]{1,})-([A-Za-z0-9]{1,})) ]];then
                    hw_product="${BASH_REMATCH[2]}"
                    hw_version="${BASH_REMATCH[3]}"
                fi
            fi
            ;;
        "microsoft")
            [[ $hw_product == "Virtual Machine" ]] && hw_product="Hyper-V VM"
            ;;
        "msi")
            if [[ $hw_product =~ ((.+) \(([A-Za-z0-9\-]{1,})\)) ]]; then
                hw_product="${BASH_REMATCH[2]}"
                hw_version="${BASH_REMATCH[3]}"
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
