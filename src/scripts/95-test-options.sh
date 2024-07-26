#!/usr/bin/env bash

if [[ $(get_buildopt "say-hello") ]]; then
	echo "Hello!"
fi
