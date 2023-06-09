#!/bin/sh

# fish
cp -rf ~/.config/fish/* ./fish/.config/fish/

# nvim
cp -rf ~/.config/nvim/* ./nvim/.config/nvim/
rm -rf ./nvim/.config/nvim/dein/repos/*

# vim
cp -rf ~/.vimrc ./vim/
