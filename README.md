# Nix Config

## Commands

```bash
nrs                     # rebuild everything + reload shell (current window)
                        # other windows: omz reload
nix-search <name>       # find a package in nixpkgs
nix-which <tool>        # check which version (shows Nix vs Brew)
nix-update              # update all packages to latest
nix-rollback            # list generations, show rollback command

# NOT managed by nrs/nix-update:
omp update              # update omp (bun global package, not in nixpkgs)

# New CLI tools
bat <file>               # cat with syntax highlighting and line numbers
fd <pattern>             # find replacement (fzf auto-uses it for Ctrl+T)
jq '.' file.json         # JSON processor — pipe curl output through it
jq '.[] | .name'         # extract fields from JSON arrays
zi                       # zoxide interactive picker (fzf-powered cd)
z <dirname>              # jump to frecent directory (replaced z plugin)
delta                    # wired as git pager — git diff/show/log/blame
#                        n/N jumps between diff sections, / searches

# direnv — per-project env auto-loading
echo 'use flake' > .envrc && direnv allow   # auto-load flake on cd
echo 'use nixpkgs#python312' > .envrc        # auto-load python on cd
direnv allow                                  # trust a new .envrc
direnv runs automatically on `cd`. It loads/unloads the env as you move in
and out of directories. First time with a new `.envrc`, run `direnv allow`.

### Common .envrc patterns

# Project with flake.nix (has devShells.default)
echo 'use flake' > .envrc

# Project with shell.nix or default.nix
echo 'use nix' > .envrc

# Quick Python env — no Nix file needed
echo 'use nixpkgs#python312' > .envrc

# Python with packages
echo 'use nixpkgs#python312WithPackages(ps: with ps; [ numpy pandas ])' > .envrc

# Node / Go / Rust
echo 'use nixpkgs#nodejs_22' > .envrc
echo 'use nixpkgs#go' > .envrc
echo 'use nixpkgs#rustup' > .envrc

# Multiple tools at once
echo 'use nixpkgs#nodejs_22 nixpkgs#python312 nixpkgs#postgresql_14' > .envrc

# Apply after creating or changing a .envrc:
direnv allow
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
  lazygit/config.yml       # lazygit
  zed/settings.json        # zed editor

  nix/common/
    packages/              # Nix packages (cli, languages, data, cloud, media, apps, extras)
    shell/                 # zsh config (init, aliases, paths, completions, env)
    git.nix                # git, gh, GPG
    tmux.nix               # tmux binary
    vim.nix                # vim + catppuccin theme
    dotfiles.nix           # symlinks (starship, ghostty, tmux, zed, sioyek, etc.)

  nix/darwin/
    system.nix             # macos settings (dock, finder, trackpad)
    hostname.nix           # hostname, user, nix daemon, GC
    launchd.nix            # launchd agents (borders, tailwind cleanup)
    services.nix           # Nix services stubs (postgres, redis)
    homebrew/
      brews.nix            # brew formulas
      casks.nix            # brew casks (GUI apps)
      mas.nix              # Mac App Store apps
      activation.nix       # brew trust + cleanup scripts
```

## How to...
| Task | Do this | Then |
|------|---------|------|
| Add Nix package | Add to `nix/common/packages/<category>.nix` | `nrs` |
| Add Brew formula | Add to `nix/darwin/homebrew/brews.nix` | `nrs` |
| Add Brew cask (GUI app) | Add to `nix/darwin/homebrew/casks.nix` | `nrs` |
| Add App Store app | Add to `nix/darwin/homebrew/mas.nix` | `nrs` |
| Add shell alias | Add to `nix/common/shell/aliases.nix` | `nrs` |
| Quick alias test | `echo 'alias ...' >> ~/.zshrc_local` | `exec zsh` |
| Change dotfile | Edit the file directly | `nrs` |
| Change macOS settings | Edit `nix/darwin/system.nix` | `nrs` |
| Change borders colors | Edit `nix/darwin/launchd.nix` | `nrs` |
| Change git config | Edit `nix/common/git.nix` | `nrs` |

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
# 5. Edit machine-specific settings BEFORE first build:
#    - nix/darwin/hostname.nix: change hostName and username
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
gh auth login                              # GitHub CLI
# Copy ~/.ssh from old machine
# Copy agent auth files from old machine
brew services start postgresql@14          # if using postgres
brew services start redis                  # if using redis
```

## Raycast config

Raycast preferences are configured through the app UI (not Nix-managed).
To back up your settings, export them and commit the snapshot:

```bash
raycast export --output ~/config/Raycast-$(date +%Y-%m-%d).rayconfig
git add *.rayconfig && git commit -m "backup: raycast settings"
```

Custom scripts (like `invert-scroll.applescript`) live in `raycast-scripts/`
and are symlinked into Raycast's extensions folder by `common/dotfiles.nix`.

## What's gitignored (never pushed)

`nix_secrets`, `.claude/.credentials.json`, `.claude/anthropic_key.sh`, `.omp/agent/*.db*`, `node_modules/`, `result`, `/Code/User/profiles/`

## Brew vs Nix

**Nix:** CLI tools — git, gh, curl, fzf, bat, fd, jq, zoxide, delta, ripgrep, python, node, go, rust, zig, ffmpeg, imagemagick, pandoc, tesseract, cmake, gcc, and ~70 more. See `nix/common/packages/`.

**Brew (formulas):** Tools not in nixpkgs — opencode, multica, claude-code, cmux, minio-warp, mole, nightlight, and others. See `nix/darwin/homebrew/brews.nix`.

**Brew (casks):** GUI apps — ghostty, zed, vscode, discord, signal, slack, telegram, obsidian, notion, bitwarden, raycast, google-chrome, zen, betterdisplay, and ~20 more. See `nix/darwin/homebrew/casks.nix`.

**Brew services:** postgresql@14, redis — not yet migrated to Nix services.

## Caveats

- `nix/darwin/hostname.nix` has machine-specific hostname/username — change for new machines
- Postgres/Redis are still brew services, not Nix services
