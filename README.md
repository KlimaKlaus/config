# Nix Config

## Commands

```bash
nrs                     # rebuild everything + reload shell
nix-search <name>       # find a package in nixpkgs
nix-which <tool>        # check which version (shows Nix vs Brew)
nix-update              # update all packages to latest
nix-rollback            # list generations, show rollback command

# NOT managed by nrs/nix-update:
omp update              # update omp (bun global package, not in nixpkgs)
```

Open a **new terminal** (or `exec zsh`) once after first setup for these to load.

## Where everything lives

```
~/config/
  nix_secrets              # SSH keys, API tokens (GITIGNORED)
  starship.toml            # prompt
  config.ghostty           # terminal
  .aerospace.toml          # window manager
  .tmux.conf               # tmux
  .vimrc                   # vim
  lazygit/config.yml       # lazygit

  nix/home/
    shell.nix              # zsh config, aliases, PATH
    packages.nix           # CLI tools from nixpkgs
    git.nix                # git, gh, gpg
    dotfiles.nix           # symlinks for dotfiles above

  nix/darwin/
    homebrew.nix           # brew packages
    system.nix             # macos settings (dock, finder, trackpad)
    services.nix           # hostname, user, daemon
```

## How to...

| Task | Do this | Then |
|------|---------|------|
| Add Nix package | Add to `nix/home/packages.nix` | `nrs` |
| Add Brew package | Add to `nix/darwin/homebrew.nix` | `nrs` |
| Add shell alias (permanent) | Add to `nix/home/shell.nix` | `nrs` |
| Add shell alias (quick test) | `echo 'alias ...' >> ~/.zshrc_local` | `exec zsh` |
| Change dotfile | Edit the file directly | `nrs` |
| Change macOS settings | Edit `nix/darwin/system.nix` | `nrs` |
| Change git config | Edit `nix/home/git.nix` | `nrs` |

## New machine setup

### Before you start (on old machine)

You'll need to copy these from your old machine — they're gitignored, never in the repo:

- GPG private key (`gpg --export-secret-keys > key.asc`)
- SSH keys (`~/.ssh/id_*`)
- `~/config/nix_secrets` (SSH aliases, API tokens)
- Agent auth files: `~/.claude/.credentials.json`, `~/.claude/anthropic_key.sh`, `~/.pi/agent/auth.json`, `~/.hermes/auth.json`, `~/.omp/agent/`

### On the new machine

```bash
# 1. Install Nix
sh <(curl -L https://nixos.org/nix/install)

# 2. Enable flakes
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
sudo launchctl kickstart -k system/org.nixos.nix-daemon

# 3. Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 4. Clone
git clone git@github.com:lucasfth/config.git ~/config
cd ~/config

# 5. Edit machine-specific settings BEFORE first build:
#    - nix/darwin/services.nix: change hostName and username
#    - flake.nix: change darwinConfigurations key and username variable
#    - nix/home.nix: change username and homeDirectory
touch nix_secrets                          # create (copy from old machine)

# 6. Bootstrap
nix build .#darwinConfigurations.<your-hostname>.system
./result/sw/bin/darwin-rebuild switch --flake .

# 7. Switch shell
sudo chsh -s ~/.nix-profile/bin/zsh $USER
```

### After bootstrap

```bash
gpg --import key.asc                       # import GPG key
gh auth login                              # GitHub CLI
# Copy ~/.ssh from old machine
# Copy agent auth files from old machine
brew services start postgresql@14          # if using postgres
brew services start redis                  # if using redis
```

## What's gitignored (never pushed)

`nix_secrets`, `.claude/.credentials.json`, `.claude/anthropic_key.sh`, `.omp/agent/*.db*`, `node_modules/`, `result`, `/Code/User/profiles/`

## Brew vs Nix

**Nix:** git, gh, curl, fzf, starship, lazygit, tmux, python, node, go, rust, zig, ffmpeg, imagemagick, cmake, gcc, pandoc, tesseract, jupyter — all CLI tools.

**Brew:** opencode, multica, claude-code, cmux, ghostty, betterdisplay, postgresql, redis — things not in nixpkgs or GUI apps.

## Caveats

- `tmux` from brew (dep of `aoe`), same version as Nix — no impact
- Postgres/Redis are still brew services, not Nix services
- `nix/darwin/services.nix` has machine-specific hostname/username — change for new machines
