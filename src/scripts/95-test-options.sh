#!/usr/bin/env bash

if [[ $(get_buildopt "say-hello") == true ]]; then
	echo "Hello!"
fi
