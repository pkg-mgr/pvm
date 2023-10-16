#!/bin/bash

# Displays a list of commands

set -e # exit on errors
set -o pipefail # exit on pipe failure
set -u # exit on unset variables

echo ""
echo "Available commands:"
echo "help - displays basic usage info (this script)."
echo "install - installs a pnpm binary. Defaults to latest, or you can specify an exact version - ex: 8.9.2"
echo "list - lists installed pnpm binaries"
echo "uninstall - removes the specified pnpm binary. You must specify a version."
echo "update - re-installs the latest pnpmvm scripts."
echo ""
