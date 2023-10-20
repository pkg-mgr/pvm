# @pkg-mgr / pvm
## Version Manager for pnpm

Tested with zsh, bash and fish shells on macOS. May work with others as well. WSL may work but is not yet tested.

Project inspired by [nvm](https://github.com/nvm-sh/nvm), although implementation details are different. For pvm the focus is primarily performance and an easy-to-script integration in project repositories. Because pvm adds entries to the path, there is no startup cost for opening a new terminal, and package.json scripts or scripts running in any execution context can leverage pnpm and pvm commands without worrying about undefined aliases.

Additionally, each distinct function of pvm is implemented as a separate script. This allows quicker execution for individual commands, with the downside that some code may need to be repeated between scripts. This tradeoff is acceptable because the main focus is on runtime performance. If you are used to using sluggish version managers, you will be pleasantly surprised by the speed of pvm.

## Installation

First, remove any currently-installed pnpm versions. You can detect versions with `which pnpm` and then rm the file. You may need to do this more than once.

Next, install pvm:
```sh
curl -H 'Cache-Control: no-cache' -o- https://raw.githubusercontent.com/pkg-mgr/pvm/main/setup.sh | bash
```

Alternately, to auto-remove any existing pnpm installation before installing:
```sh
curl -H 'Cache-Control: no-cache' -o- https://raw.githubusercontent.com/pkg-mgr/pvm/main/setup.sh | NUKE_PNPM=1 bash
```

## Uninstalling

```sh
rm -rf ~/.pvm /usr/local/bin/pnpm /usr/local/bin/pvm
# or simply:
pvm nuke
```

## Usage

Once pvm is installed, you need to install at least one version of pnpm (ex: `pvm install 8.9.2`). You are now ready to use pnpm. You can then install additional versions the same way and switch between them with `pvm use <version>`.

You can also specify a default version (ex: `pvm default 8.9.5`) for any new shell session where you have not run the `pvm use <version>` command yet.

In addition, if you create a `.pvmrc` file with a version in the same folder as a `package.json` file, any pnpm command run in that folder will automatically use the specified version.

Example:
```sh
echo "8.9.2" > .pvmrc
pnpm --version
```
(The `.pvmrc` must be in the same directory as your project's `package.json` file.)

## How It Works
* Individual command scripts are installed to `~/.pvm/cmds` folder
* pnpm binaries are installed to `~/.pvm/version` folders (ex: `~/.pvm/8.9.2`)
* The `run.sh` script is copied to `/usr/local/bin/pnpm`. This allows us to intercept and run pnpm commands with the correct version of pnpm.
* The `cmd.sh` script is copied to `/usr/local/bin/pvm` and `/usr/local/bin/pvm`. This allows us to run the pvm commands which collectively allow pnpm version management.

## Commands
Note: after running setup, you can run `pvm help` to see the list of available commands.
* `pvm default` aka `~/.pvm/cmds/default.sh` - lists the default version. (Initially set to the latest at time of original setup.)
* `pvm default <version>` aka `~/.pvm/cmds/default.sh` - sets the default pnpm version
* `pvm help` aka `~/.pvm/cmds/help.sh` - lists all available commands
* `pvm install` aka `~/.pvm/cmds/install.sh` - installs the latest version of pnpm
* `pvm install <version>` aka `~/.pvm/cmds/install.sh` - installs specified pnpm version.
* `pvm list` aka `~/.pvm/cmds/list.sh` - lists all currently installed versions of pnpm
* `pvm list --remote` aka `~/.pvm/cmds/list.sh` - lists all versions available to install
* `pvm nuke` aka `~/.pvm/cmds/nuke.sh` - removes pvm and all pnpm binaries completely
* `pvm run` aka `~/.pvm/cmds/run.sh` - runs a pnpm command using automatic pnpm version detection. (The pnpm command will also do this directly.)
* `pvm uninstall <version>` aka `~/.pvm/cmds/uninstall.sh` - uninstalls specified pnpm version
* `pvm unuse` aka `~/.pvm/cmds/unuse.sh` - un-sets the pnpm version for the current terminal session
* `pvm update` aka `~/.pvm/cmds/` - updates all pvm scripts
* `pvm use` aka `~/.pvm/cmds/use.sh` - sets the pnpm version for the current terminal session

## Local Development Setup
### Local Dev Install:
* VS Code
* [Code Spell Checker](https://marketplace.visualstudio.com/items?itemName=streetsidesoftware.code-spell-checker)
* [shellcheck](https://github.com/koalaman/shellcheck) via the [VS Code Extension](https://marketplace.visualstudio.com/items?itemName=timonwong.shellcheck) for script linting
* [shell-format](https://marketplace.visualstudio.com/items?itemName=foxundermoon.shell-format) for auto-formatting

### Local Testing
Make code changes, then run `./setup.sh` which will perform setup using your local code. You can now test your local changes with using the pvm command.
Before preparing a PR, run ./extract-versions.js to update the `versions.txt` versions list and `default-version.txt` default default version.
Once you've tested the commands locally, raise a PR. The changes are live once they are merged to master.
