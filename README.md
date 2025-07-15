# dotfiles
My dotfiles

`git clone {repo} .dotfiles`

Add `~/.gitconfig.user` with you Git credentials

```plaintext
// ~/.gitconfig.user
[user]
  name = My name
  email = my-email@gmail.com
```

```bash
ln -s ~/.dotfiles/.gitconfig ~/.gitconfig
ln -s ~/.dotfiles/.zshrc ~/.zshrc
```

## How to

- Copy the env file `ln -s .dotfiles_env $HOME/.dotfiles_env` and change the values if needed

## TODO

- [ ] .zshrc
- [ ] .profile
- [ ] npm / yarn bin location configuration

## stow

```
$> stow $folder
$stow -t / $folder (for e.g: /etc, like for pacman.conf)
```
