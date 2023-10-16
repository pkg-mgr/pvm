#!/bin/bash

set -e # exit on errors
set -o pipefail # exit on pipe failure
set -u # exit on unset variables

base_dir="$HOME/.pnpmvm"
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

# If we didn't find a package.json file
if [[ -z "$pkg_json_path" ]]; then
  echo "No package.json file found. Todo - how to handle this?"
  exit 1
fi

echo "Found package.json at $dir"

# Check for a .pnpmvmrc file:
pnpmrc_file="$dir/.pnpmvmrc"
if [ -f "$pnpmrc_file" ]; then
    pnpm_version=$(head -n 1 "$pnpmrc_file")
    echo "Using version: $pnpm_version"
	 # for now, assume this is a full semantic version
	 # todo: support major versions as well
	 # todo: infer version from lockfileVersion in pnpm-lock.yaml file
else
    echo ".pnpmvmrc file does not exist in the directory $pkg_json_path"
	 echo "todo: what to check next?"
	 exit 1
fi

# todo: Check if the version is already installed and install it, if not:
# pnpm_version_dir="$base_dir/$pnpm_version"

# for now, assume the version is installed

# Pass all the original arguments to the pnpm executable
pnpm_executable_path="$base_dir/$pnpm_version/pnpm"
"$pnpm_executable_path" "$@"
