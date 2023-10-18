#!/bin/bash

# Runs pnpm commands with auto-pnpm version detection
# First, check for a .pnpmvmrc file
# Next, check for a current version set via pnpmvm use
# Finally, check for a default version
# If no version is found, fail with an error message

set -e # exit on errors
set -o pipefail # exit on pipe failure
set -u # exit on unset variables

base_dir="$HOME/.pnpmvm"
default_version_file="$base_dir/default-version.txt"
pkg_json_path=""

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
pnpmrc_file="$dir/.pnpmvmrc"
if [ -z "${pnpmvm_parent_pid+x}" ]; then
  parent_pid=$PPID
else
  parent_pid=$pnpmvm_parent_pid
fi
tmp_version_file="/tmp/PNPMVM_VERSION_$parent_pid"

# If we found a package.json file and that directory has a .pnpmvmrc file, use that explicit version:
if [ -n "$pkg_json_path" ] && [ -f "$pnpmrc_file" ]; then
  pnpm_version=$(head -n 1 "$pnpmrc_file")
  echo "Using version: $pnpm_version"
  # for now, assume this is a full semantic version
# Else, if we have a temp file with a version that matches the current shell PID (set via pnpmvm use), use that version:
elif [ -f "$tmp_version_file" ]; then
  pnpm_version=$(head -n 1 "$tmp_version_file")
  echo "Using version: $pnpm_version via $tmp_version_file"
# Else fall back to system-wide default version (if it exists):
elif [ -f "$default_version_file" ]; then
  pnpm_version=$(head -n 1 "$default_version_file")
  if [ "$PNPMVM_DEBUG" = "true" ]; then
    echo "DEBUG: falling back to default version"
    echo "DEBUG: default_version_file: $default_version_file"
  fi
  echo "Using version: $pnpm_version"
# Else throw an error because we don't know what version to run:
else
  echo "Unable to determine which version of pnpm to use."
  echo "Set a default version with pvm default <version>"
  echo "Or use a version for the current shell session with pvm use <version>"
  exit 1
fi

if [ ! -f "$HOME/.pnpmvm/$pnpm_version" ]; then
  echo "Version $pnpm_version is not installed. Please install it first. (pvm install $pnpm_version)"
  exit 1
fi

# Pass all the original arguments to the pnpm executable
pnpm_executable_path="$base_dir/$pnpm_version/pnpm"
"$pnpm_executable_path" "$@"
