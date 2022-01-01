#!/usr/bin/env bash

if [[ $(realpath -s "$0") == "/usr/bin/sodalite-"* ]]; then
    . /usr/libexec/sodalite-common
else
    . "$(dirname "$(realpath -s "$0")")/common.sh"
fi

VARIANT_STRING=$(cat /etc/sodalite-variant)
IFS=';' read -ra VARIANT_ARRAY <<< $VARIANT_STRING

echo "  ID: ${VARIANT_ARRAY[0]}"
echo "Name: ${VARIANT_ARRAY[1]}"
