#!/bin/bash

# Completely removes pnpmvm from your system.
# This includes all installed versions of pnpm.

set -e # exit on errors
set -o pipefail # exit on pipe failure
set -u # exit on unset variables

echo "Are you sure you wish to completely uninstall pvm, config, and installed pnpm binaries? [y/N]"
read -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]
then
    base_dir="$HOME/.pnpmvm"
	 echo Removing "$base_dir"
    rm -rf "$base_dir"
	 echo Removing scripts from /usr/local/bin
	 rm -f /usr/local/bin/pnpm
	 rm -f /usr/local/bin/pnpmvm
	 rm -f /usr/local/bin/pvm
	 echo "Uninstall complete."
else
	 echo "Aborted."
fi
