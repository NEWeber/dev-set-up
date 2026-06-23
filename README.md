# Development Setup

To set up your dev environment:
- Generate SSH keys
- Install dependencies
- Clone this repo and run its script

Details below

## SSH setup

Set up your personal SSH key before using `git@personal:` remotes:

```bash
ssh-keygen -t ed25519 -C "you@personal.example" -f ~/.ssh/id_ed25519_github_personal
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519_github_personal
pbcopy < ~/.ssh/id_ed25519_github_personal.pub
```

Add the copied key to GitHub under SSH keys, then verify direct host access:

```bash
ssh -T git@github.com
```

Set up a work key too (service-agnostic placeholder):

```bash
ssh-keygen -t ed25519 -C "you@company.com" -f ~/.ssh/id_ed25519_work
ssh-add ~/.ssh/id_ed25519_work
pbcopy < ~/.ssh/id_ed25519_work.pub
```

Add that key to your work git provider (GitLab/GitHub Enterprise/other), then verify against your work host:

```bash
ssh -T git@<your-work-git-host>
```

Required `~/.ssh/config` aliases:

```sshconfig
Host personal
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_github_personal
  IdentitiesOnly yes

Host work
  HostName <your-work-git-host>
  User git
  IdentityFile ~/.ssh/id_ed25519_work
  IdentitiesOnly yes
```

After adding aliases, verify alias-based access too:

```bash
ssh -T personal
ssh -T work
```

## Dependencies

Dependencies are installed manually (the script checks but does not auto-install):

```bash
# macOS (Homebrew)
brew install git neovim tmux starship ripgrep

# Ubuntu/Debian
sudo apt update
sudo apt install -y git neovim tmux starship ripgrep

# Fedora
sudo dnf install -y git neovim tmux starship ripgrep
```

## Clone and Setup 

First-time setup:

```bash
mkdir -p ~/code/playground
cd ~/code/playground
git clone https://github.com/NEWeber/dev-set-up.git
```

Run:

```bash
cd ~/code/playground/dev-set-up
bash ./setup.sh
```

Optional: switch this repo's remote from HTTPS to alias-based SSH after setup:

```bash
git remote set-url origin git@personal:NEWeber/dev-set-up.git
git remote -v
```

## Notes

### Tmux setup

This repo tracks tmux config in `tmux/tmux.conf`.

`setup.sh` symlinks:

- `~/.config/tmux/tmux.conf` -> `~/code/playground/dev-set-up/tmux/tmux.conf`

`setup.sh` also copies (no symlink) the startup launcher files:

- `~/code/tmux-startup.sh` (portable launcher)
- `~/code/tmux-startup.config.sh` (your editable local startup layout)

The startup config is copied from `tmux/tmux-startup.config.example.sh` if missing.

Tmux dependencies:

- `tmux`
- `git`
- TPM (Tmux Plugin Manager), installed to `~/.tmux/plugins/tpm`

Install TPM:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

After launching tmux, install plugins with:

```text
prefix + I
```

Run your startup session with:

```bash
bash ~/code/tmux-startup.sh
```

Edit `~/code/tmux-startup.config.sh` to set your project paths, notes files, and window layout.

### Neovim setup

This repo tracks Neovim config in `nvim/`.

`setup.sh` symlinks:

- `~/.config/nvim` -> `~/code/playground/dev-set-up/nvim`

This keeps Neovim tinkering commit-friendly because edits under `~/.config/nvim` are edits in this repo.

Neovim dependencies to install on your machine:

- `nvim`
- `git`
- compiler toolchain for Treesitter parsers (for macOS, install Xcode Command Line Tools)
- optional but useful: `ripgrep` (used by Telescope live grep)

### Starship setup

This repo tracks Starship config in `starship/starship.toml`.

`setup.sh` symlinks:

- `~/.config/starship.toml` -> `~/code/playground/dev-set-up/starship/starship.toml`

Dependency:

- `starship` (and shell initialization in your shell config)

### Setup Script
The script is idempotent and includes safety checks:

- Copies git/bash config files into your home directory.
- Skips steps that are already complete.
- Does not overwrite existing files unless `--force` is used.
- Creates timestamped backups before overwrite when `--force` is used.
- Installs VS Code extensions only when missing.
- Prompts for work and personal emails when generating git configs.
- Symlinks Neovim config to `~/.config/nvim`.
- Symlinks tmux config to `~/.config/tmux/tmux.conf`.
- Symlinks Starship config to `~/.config/starship.toml`.
- Copies tmux startup launcher/config into `~/code` (no symlinks).

To overwrite existing dotfiles with repo templates:

```bash
bash ./setup.sh --force
```

For non-interactive runs, pass emails via environment variables:

```bash
WORK_EMAIL="you@company.com" PERSONAL_EMAIL="you@personal.example" bash ./setup.sh
```

If `~/.config/nvim` already exists and you want a lighter-touch one-time migration to the repo symlink, do it manually:

```bash
mv ~/.config/nvim ~/.config/nvim.backup.$(date +%Y%m%d%H%M%S)
ln -s ~/code/playground/dev-set-up/nvim ~/.config/nvim
```

This avoids using `--force` on a working setup.

If `~/.config/tmux/tmux.conf` already exists and you want a lighter-touch one-time migration to the repo symlink, do it manually:

```bash
mkdir -p ~/.config/tmux
mv ~/.config/tmux/tmux.conf ~/.config/tmux/tmux.conf.backup.$(date +%Y%m%d%H%M%S)
ln -s ~/code/playground/dev-set-up/tmux/tmux.conf ~/.config/tmux/tmux.conf
```

If `~/.config/starship.toml` already exists and you want a lighter-touch one-time migration to the repo symlink, do it manually:

```bash
mkdir -p ~/.config
mv ~/.config/starship.toml ~/.config/starship.toml.backup.$(date +%Y%m%d%H%M%S)
ln -s ~/code/playground/dev-set-up/starship/starship.toml ~/.config/starship.toml
```

## Git identity split

Template files in `git/` are copied to:

- `~/.gitconfig`
- `~/.gitconfig-work`
- `~/.gitconfig-personal`

`~/.gitconfig` routes repos by path:

- `~/code/**` -> work profile
- `~/code/playground/**` -> personal profile