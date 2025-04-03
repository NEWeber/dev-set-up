#!/bin/bash
# After installing git, setting up GitHub SSH Key and VS Code, make a ~/code directory
git clone git@github.com:NEWeber/dev-set-up.git 
cd ~/dev-set-up
ln -s ~/code/dev-set-up/.gitconfig ~/.gitconfig
ln -s ~/code/dev-set-up/.bashrc ~/.bashrc
xargs -n 1 code --install-extension < ./vscode/vscode-extensions.txt