####################
# Oh my Zsh config #
####################

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

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git
    git-flow
    sudo
    command-not-found
    colored-man-pages
    # npm
    # zsh-autosuggestions
    # zsh-syntax-highlighting
)

### Source oh my zsh
source $ZSH/oh-my-zsh.sh


############################################


######################
# User configuration #
######################

### Starship prompt
eval "$(starship init zsh)"

### Aliases
source $HOME/.zsh/arcolinux.aliases
source $HOME/.zsh/me.aliases

### Exports
export DOTFILES="$HOME/.dotfiles" # my dotfiles
export ZSH="$HOME/.oh-my-zsh" # oh-my-zsh
export HISTORY_IGNORE="(ls|cd|pwd|exit|sudo reboot|history|cd -|cd ..)" # history ignore
export PATH=$HOME/.npm/bin:$PATH # Path to npm bin
export EDITOR="emacs -nw" # $EDITOR use Emacs in terminal
export VISUAL="code" # $VISUAL use Code
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH" # RMagick gem
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
# export VOLTA_HOME="$HOME/.volta"
# export MANPATH="/usr/local/man:$MANPATH"
# export ARCHFLAGS="-arch x86_64" # Compilation flags

### Paths
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH" # Path to Yarn
# export PATH="$VOLTA_HOME/bin:$PATH"
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

### You may need to manually set your language environment
# export LANG=en_US.UTF-8


### Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='emacs -nw'
else
  export EDITOR='code'
fi

### ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

### fuzzy finder https://github.com/junegunn/fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

### the fuck https://github.com/nvbn/thefuck
# eval $(thefuck --alias)

### for WSL: https://github.com/microsoft/WSL/issues/1801
# umask 22
# export BROWSER="wsl-open"
