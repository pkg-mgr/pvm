#!/bin/bash

set -e # exit on errors
set -o pipefail # exit on pipe failure
set -u # exit on unset variables

# Check if at least one argument is provided
if [ $# -eq 0 ]; then
    echo "No arguments provided. Please supply a command: install, list, run"
    exit 1
fi

base_dir="$HOME/.pnpmvm"
cmds_dir="$base_dir/cmds"

# Get the command from the first argument
cmd=$1

# Shift all arguments to the left (original $1 gets lost)
shift

# Check if the script for the command exists
if [ ! -f "$cmds_dir/$cmd.sh" ]; then
    echo "Command not found: $cmd at $cmds_dir/$cmd.sh"
    exit 1
fi

# Run the script for the command with all remaining arguments
"$cmds_dir/$cmd.sh" "$@"
