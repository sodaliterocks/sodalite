#!/usr/bin/env bash

os_version="$(ost cat $commit /usr/lib/os-release | grep "VERSION_ID=" | sed "s/VERSION_ID=//")"
treefile_version="$(cat "$base_dir/src/common/core.yaml" | grep "releasever:" | sed "s/releasever: //" | sed "s/\"//g")"

if [[ "$os_version" == "$treefile_version" ]]; then
    echo "true"
else
    echo "Incorrect version (OS: $os_version / Treefile: $treefile_version)"
fi
