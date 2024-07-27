#!/usr/bin/env bash

glib-compile-schemas /usr/share/glib-2.0/schemas
dconf update
fc-cache -f -v
