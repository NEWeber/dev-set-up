#!/bin/bash
# After installing git, setting up GitHub SSH Key and VS Code, make a ~/code/playground directory: this will be where your personal work lives
cd ~/code/playground
git clone git@github.com:NEWeber/dev-set-up.git 
cd ~/dev-set-up
ln -s ~/code/playground/dev-set-up/.gitconfig ~/.gitconfig
ln -s ~/code/playground/dev-set-up/bash/.bashrc ~/.bashrc
xargs -n 1 code --install-extension < ./vscode/vscode-extensions.txt
