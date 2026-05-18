## SSH setup

Set up your personal SSH key before using `git@personal:` remotes:

```bash
ssh-keygen -t ed25519 -C "you@personal.com" -f ~/.ssh/id_ed25519_github_personal
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

## Neovim setup

This repo tracks Neovim config in `nvim/`.

`setup.sh` symlinks:

- `~/.config/nvim` -> `~/code/playground/dev-set-up/nvim`

This keeps Neovim tinkering commit-friendly because edits under `~/.config/nvim` are edits in this repo.

Neovim dependencies to install on your machine:

- `nvim`
- `git`
- compiler toolchain for Treesitter parsers (for macOS, install Xcode Command Line Tools)
- optional but useful: `ripgrep` (used by Telescope live grep)

## Bootstrap

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

The script is idempotent and includes safety checks:

- Copies config files into your home directory (no symlinks).
- Skips steps that are already complete.
- Does not overwrite existing files unless `--force` is used.
- Creates timestamped backups before overwrite when `--force` is used.
- Installs VS Code extensions only when missing.
- Prompts for work and personal emails when generating git configs.
- Symlinks Neovim config to `~/.config/nvim`.

To overwrite existing dotfiles with repo templates:

```bash
bash ./setup.sh --force
```

For non-interactive runs, pass emails via environment variables:

```bash
WORK_EMAIL="you@company.com" PERSONAL_EMAIL="you@personal.com" bash ./setup.sh
```

If `~/.config/nvim` already exists and you want a lighter-touch one-time migration to the repo symlink, do it manually:

```bash
mv ~/.config/nvim ~/.config/nvim.backup.$(date +%Y%m%d%H%M%S)
ln -s ~/code/playground/dev-set-up/nvim ~/.config/nvim
```

This avoids using `--force` on a working setup.

## Git identity split

Template files in `git/` are copied to:

- `~/.gitconfig`
- `~/.gitconfig-work`
- `~/.gitconfig-personal`

`~/.gitconfig` routes repos by path:

- `~/code/**` -> work profile
- `~/code/playground/**` -> personal profile