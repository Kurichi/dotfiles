#!/bin/sh

# fish
cp -rf ~/.config/fish/* ./config/fish/

# nvim (lazy-lock.json などを同期)
cp -rf ~/.config/nvim/* ./config/nvim/

# vim
cp -rf ~/.vimrc ./vim/
