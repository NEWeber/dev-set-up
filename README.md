The repo currently has my WSL setup, will need to tweak for Mac.

Setting up the repo:
Get the `.bashrc`: `cp ~/.bashrc ./.bashrc`
Get the `.gitconfig`: `cp ~/.gitconfig ./.gitconfig`

Use simlinks to point your system's config locations to the repo files:
```bash
ln -s ~/code/dev-set-up/.gitconfig ~/.gitconfig
ln -s ~/code/dev-set-up/.bashrc ~/.bashrc
```