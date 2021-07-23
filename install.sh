#!/usr/bin/env zsh
# src: https://github.com/ThePrimeagen/.dotfiles/blob/master/install
pushd $DOTFILES
for folder in $(echo $STOW_FOLDERS | sed "s/,/ /g")
do
    stow -D $folder
    stow $folder
done
popd
