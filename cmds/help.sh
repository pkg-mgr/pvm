#!/bin/bash

# Displays a list of commands.

set -e # exit on errors
set -o pipefail # exit on pipe failure
set -u # exit on unset variables

echo ""
echo "Available commands:"
echo "default - displays default version"
echo "default <version> - sets the default (ex: pvm default 8.9.2)"
echo "help - displays basic usage info (this script)."
echo "install - installs the latest pnpm binary."
echo "install <version> - installs the specified pnpm binary - ex: pnpm install 8.9.2"
echo "list - lists installed pnpm binaries"
echo "list --remote - lists versions available to install"
echo "uninstall <version> - removes the specified pnpm binary - ex: pvm uninstall 8.9.2"
echo "update - re-installs the latest pvm scripts as well as pnpm versions list"
echo "use <version> - sets a pnpm version for the current shell session - ex: pvm use 8.9.2"
echo ""
