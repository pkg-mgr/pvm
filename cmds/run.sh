#!/bin/bash

# Runs pnpm commands with auto-pnpm version detection
# First, check for a .pvmrc file
# Next, check for a current version set via pvm use
# Finally, check for a default version
# If no version is found, fail with an error message

set -e # exit on errors
set -o pipefail # exit on pipe failure
set -u # exit on unset variables

base_dir="$HOME/.pvm"
default_version_file="$base_dir/default-version.txt"
pkg_dir="$HOME/.pnpm-store"

pkg_json_path=""
pvm_DEBUG=false
# Check for debug (verbose) output
if [ "$1" == "--debug" ]; then
  pvm_DEBUG=true
  shift
fi

# Look for a project directory (a dir that contains package.json):
# Start with the current directory
dir=$(pwd)
# While we're not at the root directory
while [[ "$dir" != "/" ]]; do
  # If a package.json file exists in the current directory
  if [[ -f "$dir/package.json" ]]; then
    # Set the variable and break the loop
    pkg_json_path="$dir/package.json"
    break
  fi
  # Go up a directory
  dir=$(dirname "$dir")
done

# Resolve the pnpm version to use
pnpmrc_file="$dir/.pvmrc"
if [ -z "${pvm_parent_pid+x}" ]; then
  parent_pid=$PPID
else
  parent_pid=$pvm_parent_pid
fi
tmp_version_file="/tmp/pvm_VERSION_$parent_pid"

# If we found a package.json file and that directory has a .pvmrc file, use that explicit version:
if [ -n "$pkg_json_path" ] && [ -f "$pnpmrc_file" ]; then
  pnpm_version=$(head -n 1 "$pnpmrc_file")
  if [ "$pvm_DEBUG" = "true" ]; then
    echo "Using version: $pnpm_version"
  fi
  # for now, assume this is a full semantic version
# Else, if we have a temp file with a version that matches the current shell PID (set via pvm use), use that version:
elif [ -f "$tmp_version_file" ]; then
  pnpm_version=$(head -n 1 "$tmp_version_file")
  if [ "$pvm_DEBUG" = "true" ]; then
    echo "Using version: $pnpm_version"
    echo "DEBUG: from temp file $tmp_version_file"
  fi
# Else fall back to system-wide default version (if it exists):
elif [ -f "$default_version_file" ]; then
  pnpm_version=$(head -n 1 "$default_version_file")
  if [ "$pvm_DEBUG" = "true" ]; then
    echo "DEBUG: falling back to default version"
    echo "DEBUG: default_version_file: $default_version_file"
  fi
# Else throw an error because we don't know what version to run:
else
  echo "Unable to determine which version of pnpm to use."
  echo "Set a default version with pvm default <version>"
  echo "Or use a version for the current shell session with pvm use <version>"
  exit 1
fi

if [ ! -f "$HOME/.pvm/$pnpm_version/pnpm" ]; then
  echo "Version $pnpm_version is not installed. Please install it first. (pvm install $pnpm_version)"
  exit 1
fi

#PNPM_HOME is required for global installs:
export PNPM_HOME="$pkg_dir"
# todo: check if packages installed on old v6 versions still work in the latest v9 version. If not maybe a per-major-version install?

# pnpm also requires the home dir to be in the path:
export PATH=$PNPM_HOME:$PATH

# Pass all the original arguments to the pnpm or pnpx executable
pnpm_executable_path="$base_dir/$pnpm_version/pnpm"
executable_name=$(basename "$0")
if [ "$executable_name" = "pnpm" ]; then
  "$pnpm_executable_path" "$@"
else
  # pnpx:
  "$pnpm_executable_path" exec "$@"
fi
