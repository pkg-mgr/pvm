# pnpmvm
Version Manager for pnpm

## Installation

First, install the script:
```sh
curl -H 'Cache-Control: no-cache' -o- https://raw.githubusercontent.com/pkg-mgr/pnpmvm/main/setup.sh | bash
```

Second, add an alias to your profile (ex: `~/.bashrc` or `~/.zshrc`):
```sh
alias pnpmvm="~/.pnpmvm/cmds/cmd.sh"
```

## Uninstalling

First, remove the install directory:
```sh
rm -rf ~/.pnpmvm
```

Second, remove the alias `pnpmvm` from your profile.

## How It Works
* Individual command scripts are installed to `~/.pnpmvm/cmds`` folder
* pnpm binaries are installed to `~/.pnpmvm/version` folders (ex: `~/.pnpmvm/8.9.2`)

## Commands
Note: after running setup and adding the alias, you can run `pnpmvm help` to see the list of available commands.
* `pnpmvm help` aka `~/.pnpmvm/cmds/help.sh` - lists all available commands
* `pnpmvm install` aka `~/.pnpmvm/cmds/install.sh` - installs specified pnpm version. If no exact version is installed, the latest version is installed.
* `pnpmvm list` aka `~/.pnpmvm/cmds/list.sh` - lists all currently installed versions of pnpm
* `pnpmvm run` aka `~/.pnpmvm/cmds/run.sh` - runs a command using the version defined in the `.pnpmvmrc` file in the nearest directory containing a package.json file. (In the future, additional auto-detection methods will be available.)
* `pnpmvm uninstall` aka `~/.pnpmvm/cmds/uninstall.sh` - uninstalls specified pnpm version
* `pnpmvm update` aka `~/.pnpmvm/cmds/` - updates all pnpmvm scripts

## Local Development Setup
### Local Dev Install:
* VS Code
* [Code Spell Checker](https://marketplace.visualstudio.com/items?itemName=streetsidesoftware.code-spell-checker)
* [shellcheck](https://github.com/koalaman/shellcheck) via the [VS Code Extension](https://marketplace.visualstudio.com/items?itemName=timonwong.shellcheck) for script linting
* [shell-format](https://marketplace.visualstudio.com/items?itemName=foxundermoon.shell-format) for auto-formatting

### Local Testing
Make code changes, then run `./setup.sh` which will perform setup using your local code. Assuming you have your `pnpmvm` alias set up (see Installation for details), you can now test your local changes with using the pnpmvm command.

Once you've tested the commands locally, raise a PR. The changes are live once they are merged to master.
