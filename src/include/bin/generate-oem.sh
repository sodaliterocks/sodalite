#!/usr/bin/env bash

if ! [ $(id -u) = 0 ]; then
   echo "Must be ran as root!"
   exit 1
fi

function get_sysinfo() {
    KEY=$1
    sudo dmidecode -t1 | grep "$KEY:" | sed 's/\t'"${KEY}"': //g'
}

echo "Generating OEM information..."

OEM_FILE="/etc/oem.conf"
OEM_LOGO_FILE="/etc/oem-logo.png"

echo "[OEM]" > $OEM_FILE
echo "Manufacturer=$(get_sysinfo 'Manufacturer')" >> $OEM_FILE
echo "Product=$(get_sysinfo 'Product Name')" >> $OEM_FILE
echo "Version=$(get_sysinfo 'Version')" >> $OEM_FILE