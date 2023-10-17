#!/bin/bash

# This script serves as the entrypoint for the pnpmvm alias.
# It determines which script the user is trying to run and executes it, passing on all other args.

set -e # exit on errors
set -o pipefail # exit on pipe failure
set -u # exit on unset variables

# Check if at least one argument is provided
if [ $# -eq 0 ]; then
  echo "No arguments provided. Please supply a command. See pnpmvm help for more details."
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

echo "Running command: $cmd"
# For troubleshooting, echo the args (remove this later):
if [ -z "$*" ]; then
  echo "No args provided"
else
  echo "Args:"
  echo "$@"
fi

# Export original PID (needed for use command)
export pnpmvm_parent_pid=$PPID

# Run the script for the command with all remaining arguments
"$cmds_dir/$cmd.sh" "$@"
