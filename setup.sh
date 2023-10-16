#!/bin/bash

set -e # exit on errors
set -o pipefail # exit on pipe failure
set -u # exit on unset variables

base_dir="$HOME/.pnpmvm"
cmds_dir="$base_dir/cmds"
cmd_files="install.sh"

ensure_dir() {
  if [ ! -d "$1" ]; then
    mkdir -p "$1"
    echo "Created directory $1"
  fi
}

# ensure the base dir exists:
ensure_dir "$base_dir"

# clear out cmds dir, if it exists:
if [ -d "$cmds_dir" ]; then
  rm -rf "$cmds_dir" > /dev/null 2>&1
fi
ensure_dir "$cmds_dir"

# copy specific pnpmvm command scripts to local $cmds_dir:
for file in $cmd_files
do
  # download the file:
  echo "Downloading: https://raw.githubusercontent.com/pkg-mgr/pnpmvm/main/cmds/$file"
  # disable cache, fail on 404, silence progress (but not errors) and save locally:
  curl -H 'Cache-Control: no-cache' -fsS -o "$cmds_dir/$file" "https://raw.githubusercontent.com/pkg-mgr/pnpmvm/main/cmds/$file"
  # make it executable:
  chmod +x "$cmds_dir/$file"
done

echo "Installed pnpmvm cmds: $cmd_files"
