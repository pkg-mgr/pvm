#!/bin/bash

set -e # exit on errors
set -o pipefail # exit on pipe failure
set -u # exit on unset variables

base_dir="$HOME/.pnpmvm"

# List all folders in the base dir, excluding "cmds":
for dir in "$base_dir"/*; do
  dir_name=$(basename "$dir")
  if [ -d "$dir" ] && [ "$dir_name" != "cmds" ]; then
    echo "$dir_name"
  fi
done