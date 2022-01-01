#!/usr/bin/env bash

if [[ $(realpath -s "$0") == "/usr/bin/sodalite-"* ]]; then
    . /usr/libexec/sodalite-common
else
    . "$(dirname "$(realpath -s "$0")")/common.sh"
fi

PROPERTY_NAME=$1

SODALITE_VARIANT_CONTENT=$(cat /etc/sodalite-variant)

function get_property() {
    PROPERTY_NAME=$1

    IFS=';' read -ra VARIANT_ARRAY <<< $SODALITE_VARIANT_CONTENT
    VARIANT_ARRAY_INDEX=-1

    case $PROPERTY_NAME in
        id) VARIANT_ARRAY_INDEX=0 ;;
        name) VARIANT_ARRAY_INDEX=1 ;;
    esac

    if [[ $VARIANT_ARRAY_INDEX -gt -1 ]]; then
        echo ${VARIANT_ARRAY[$VARIANT_ARRAY_INDEX]}
    else
        echoc error "Property '$PROPERTY_NAME' does not exist"
    fi
}

if [[ -n $PROPERTY_NAME ]]; then
    echo $(get_property $PROPERTY_NAME)
else
    echo "  ID: $(get_property id)"
    echo "Name: $(get_property name)"
fi
