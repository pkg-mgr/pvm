#!/bin/bash

set -e # exit on errors
set -o pipefail # exit on pipe failure
set -u # exit on unset variables

base_dir="$HOME/.pnpmvm"
cmds_dir="$base_dir/cmds"
cmd_list="cmd default help install list nuke run uninstall update use"
NUKE_PNPM=${NUKE_PNPM:-0}

ensure_dir() {
  if [ ! -d "$1" ]; then
    mkdir -p "$1"
    echo "Created directory $1"
  fi
}

if [ "$NUKE_PNPM" -eq 1 ]; then
  echo Optional pnpm uninstall requested, removing any existing pnpm installations...
  while true; do
    if pnpm_path=$(which pnpm 2>/dev/null); then
      echo "Deleting $pnpm_path"
      rm "$pnpm_path"
    else
      echo "pnpm not found"
      break
    fi
  done
fi

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
for cmd_name in $cmd_list
do
  file_name="$cmd_name.sh"
  if [ "$file_source" = "local" ]; then
    echo "Copying file from local: ./cmds/$file_name"
    cp "./cmds/$file_name" "$cmds_dir/$file_name"
    elif [ "$file_source" = "github" ]; then
    # download the file:
    echo "Downloading: https://raw.githubusercontent.com/pkg-mgr/pnpmvm/main/cmds/$file_name"
    # disable cache, fail on 404, silence progress (but not errors) and save locally:
    curl -H 'Cache-Control: no-cache' -fsS -o "$cmds_dir/$file_name" "https://raw.githubusercontent.com/pkg-mgr/pnpmvm/main/cmds/$file_name"
  else
    echo "Unknown file source."
    exit 1
  fi
  # make it executable:
  chmod +x "$cmds_dir/$file_name"
done

# copy pnpm's package.json to local:
echo "Caching pnpm's package.json."
curl -H 'Cache-Control: no-cache' -fsS -o "$base_dir/pnpm-package.json" "https://registry.npmjs.org/@pnpm/exe"
if [ "$file_source" = "local" ]; then
  # also update the local copy:
  cp "$base_dir/pnpm-package.json" "./pnpm-package.json"
fi

# install versions list (versions.txt):
if [ "$file_source" = "local" ]; then
  cp "./versions.txt" "$base_dir/versions.txt"
else
  curl -H 'Cache-Control: no-cache' -fsS -o "$base_dir/versions.txt" "https://raw.githubusercontent.com/pkg-mgr/pnpmvm/main/versions.txt"
fi

# if $base_dir/default-version.txt does not exist:
if [ ! -f "$base_dir/default-version.txt" ]; then
  if [ "$file_source" = "local" ]; then
    cp "./default-version.txt" "$base_dir/default-version.txt"
  else
    curl -H 'Cache-Control: no-cache' -fsS -o "$base_dir/default-version.txt" "https://raw.githubusercontent.com/pkg-mgr/pnpmvm/main/default-version.txt"
  fi
fi
# otherwise, do not override default version!

echo "Installed pvm cmds: $cmd_list"

echo "Installing scripts in bin folder."
cp "$cmds_dir/run.sh" "/usr/local/bin/pnpm"
cp "$cmds_dir/cmd.sh" "/usr/local/bin/pnpmvm"
cp "$cmds_dir/cmd.sh" "/usr/local/bin/pvm"

echo Setup completed.
