## Bootstrap

First-time setup:

```bash
mkdir -p ~/code/playground
cd ~/code/playground
git clone git@personal:NEWeber/dev-set-up.git
```

Run:

```bash
cd ~/code/playground/dev-set-up
bash ./setup.sh
```

The script is idempotent and includes safety checks:

- Copies config files into your home directory (no symlinks).
- Skips steps that are already complete.
- Does not overwrite existing files unless `--force` is used.
- Creates timestamped backups before overwrite when `--force` is used.
- Installs VS Code extensions only when missing.
- Prompts for work and personal emails when generating git configs.

To overwrite existing dotfiles with repo templates:

```bash
bash ./setup.sh --force
```

For non-interactive runs, pass emails via environment variables:

```bash
WORK_EMAIL="you@company.com" PERSONAL_EMAIL="you@gmail.com" bash ./setup.sh
```

## Git identity split

Template files in `git/` are copied to:

- `~/.gitconfig`
- `~/.gitconfig-work`
- `~/.gitconfig-personal`

`~/.gitconfig` routes repos by path:

- `~/code/**` -> work profile
- `~/code/playground/**` -> personal profile