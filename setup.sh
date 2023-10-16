#!/bin/bash

set -e # exit on errors
set -o pipefail # exit on pipe failure
set -u # exit on unset variables

base_dir="$HOME/.pnpmvm"
cmds_dir="$base_dir/cmds"
cmd_files="cmd.sh help.sh install.sh list.sh run.sh uninstall.sh update.sh"

ensure_dir() {
  if [ ! -d "$1" ]; then
    mkdir -p "$1"
    echo "Created directory $1"
  fi
}

# Detect setup method, local or github:
if [[ -t 0 ]] && [[ -d "cmds" ]]; then
  # if standard input is a terminal and the cmds dir exists, use local install
  echo "Performing local install."
  file_source="local"
else
  # likely invoked via curl so default to the github download method
  file_source="github"
fi

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
  if [ "$file_source" = "local" ]; then
    echo "Copying file from local: ./cmds/$file"
    cp "./cmds/$file" "$cmds_dir/$file"
  elif [ "$file_source" = "github" ]; then
    # download the file:
    echo "Downloading: https://raw.githubusercontent.com/pkg-mgr/pnpmvm/main/cmds/$file"
    # disable cache, fail on 404, silence progress (but not errors) and save locally:
    curl -H 'Cache-Control: no-cache' -fsS -o "$cmds_dir/$file" "https://raw.githubusercontent.com/pkg-mgr/pnpmvm/main/cmds/$file"
  else
    echo "Unknown file source."
    exit 1
  fi
  # make it executable:
  chmod +x "$cmds_dir/$file"
done

echo "Installed pnpmvm cmds: $cmd_files"

# todo: add alias for pnpmvm in user's profile, if it doesn't exist
