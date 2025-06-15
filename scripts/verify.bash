#!/usr/bin/env bash

for file in $(ls -d plugins/toolchains/tools/*/*/)
do 
    version="$(basename "$file")"
    tool="$(basename "$(dirname "$file")")"
    asdf install "$tool" "$version"
done