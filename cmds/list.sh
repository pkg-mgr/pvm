#!/bin/bash

# Lists installed pnpm binaries
# When run with --remote option, lists all versions available for install

set -e # exit on errors
set -o pipefail # exit on pipe failure
set -u # exit on unset variables

base_dir="$HOME/.pvm"

if [ "${1:-}" = "--remote" ]; then
  echo "Available remote versions:"
  cat "$base_dir/versions.txt"
  echo "Use pvm install <version> to install."
else
    # List all folders in the base dir, excluding "cmds":
  echo "Available local versions:"
  for dir in "$base_dir"/*; do
    dir_name=$(basename "$dir")
    if [ -d "$dir" ] && [ "$dir_name" != "cmds" ]; then
      echo "$dir_name"
    fi
  done
  echo "Use \"pvm list --remote\" to list available remote versions."
fi
