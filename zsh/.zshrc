####################
# Oh my Zsh config #
####################

# Oh my Zsh setup
ZSH="$HOME/.oh-my-zsh"
ZSH_CUSTOM="$ZSH/custom"

# Don't load any Oh my Zsh theme
ZSH_THEME=""

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# Caution: this setting can cause issues with multiline prompts (zsh 5.7.1 and newer seem to work)
# See https://github.com/ohmyzsh/ohmyzsh/issues/5765
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git
    git-flow
    sudo
    zsh-autosuggestions
    zsh-syntax-highlighting
    colored-man-pages
)

### Source oh my zsh
source $ZSH/oh-my-zsh.sh


############################################


######################
# User configuration #
######################

### Starship prompt
eval "$(starship init zsh)"

### Exports

export ZSH="$HOME/.oh-my-zsh" # oh-my-zsh
export DOTFILES="$HOME/.dotfiles" # my dotfiles
export FILE_MANAGER="thunar"
export HISTORY_IGNORE="(ls|cd|pwd|exit|sudo reboot|history|cd -|cd ..)" # history ignore
export PATH=$HOME/.npm/bin:$PATH # Path to npm bin
export VISUAL="nvim" # $VISUAL use nvim
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH" # RMagick gem
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export VOLTA_HOME="$HOME/.volta" # volta config
export PATH="$VOLTA_HOME/bin:$PATH" # volta config
# export MANPATH="/usr/local/man:$MANPATH"
# export ARCHFLAGS="-arch x86_64" # Compilation flags
# export SSH_KEY_PATH="~/.ssh/rsa_id" # ssh
# export LANG=en_US.UTF-8 # You may need to manually set your language environment

### Paths
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH" # Path to Yarn
if [ -d "$HOME/.bin" ] ;
  then PATH="$HOME/.bin:$PATH"
fi
if [ -d "$HOME/.local/bin" ] ;
  then PATH="$HOME/.local/bin:$PATH"
fi
if [ -d "$HOME/Applications" ] ;
  then PATH="$HOME/Applications:$PATH"
fi
if [ -d "/opt/bin" ] ;
  then PATH="/opt/bin:$PATH"
fi

### Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nvim'
else
  export EDITOR='nvim'
fi

### vi-mode
# bindkey -v
# export KEYTIMEOUT=1
#
# # Use vim keys in tab complete menu:
# bindkey -M menuselect 'h' vi-backward-char
# bindkey -M menuselect 'k' vi-up-line-or-history
# bindkey -M menuselect 'l' vi-forward-char
# bindkey -M menuselect 'j' vi-down-line-or-history
# bindkey -v '^?' backward-delete-char
#
# # Change cursor shape for different vi modes.
# function zle-keymap-select {
#   if [[ ${KEYMAP} == vicmd ]] ||
#      [[ $1 = 'block' ]]; then
#     echo -ne '\e[1 q'
#   elif [[ ${KEYMAP} == main ]] ||
#        [[ ${KEYMAP} == viins ]] ||
#        [[ ${KEYMAP} = '' ]] ||
#        [[ $1 = 'beam' ]]; then
#     echo -ne '\e[5 q'
#   fi
# }
# zle -N zle-keymap-select
# zle-line-init() {
#     zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
#     echo -ne "\e[5 q"
# }
# zle -N zle-line-init
# echo -ne '\e[5 q' # Use beam shape cursor on startup.
# preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.
#
# # Edit line in vim with ctrl-e:
# autoload edit-command-line; zle -N edit-command-line
# bindkey '^e' edit-command-line


### Aliases
source $HOME/.zsh/arcolinux.aliases
source $HOME/.zsh/me.aliases

### Manual plugins install

# https://github.com/zsh-users/zsh-autosuggestions
# source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh

# https://github.com/zsh-users/zsh-syntax-highlighting
# source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh

# broot
source /home/knth/.config/broot/launcher/bash/br

# zsh-vi-mode: https://github.com/jeffreytse/zsh-vi-mode
source /usr/share/zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh
function init_zsh_vi_mode() {
  [ -f /usr/share/skim/key-bindings.zsh ] && source /usr/share/skim/key-bindings.zsh
  [ -f /usr/share/skim/completion.zsh ] && source /usr/share/skim/completion.zsh
}
zvm_after_init_commands+=(init_zsh_vi_mode)

### the fuck https://github.com/nvbn/thefuck
# eval $(thefuck --alias)

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
source $HOME/.rvm/scripts/rvm

### Init z.lua https://github.com/skywind3000/z.lua
eval "$(lua /usr/share/z.lua/z.lua --init zsh)"

### Hook direnv: https://direnv.net/docs/hook.html
eval "$(direnv hook zsh)"

alias luamake=/home/knth/.config/nvim/lua-language-server/3rd/luamake/luamake

### solana-cli
export PATH="/home/knth/.local/share/solana/install/active_release/bin:$PATH"


### Fly.io flyctl
export FLYCTL_INSTALL="/home/knth/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"

### surrealdb
export PATH=/home/knth/.surrealdb:$PATH

### dotfiles bin
export PATH=/home/knth/.dotfiles/bin:$PATH
