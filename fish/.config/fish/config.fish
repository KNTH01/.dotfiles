
fish_add_path ~/.cargo/bin

starship init fish | source

set -g fish_key_bindings fish_vi_key_bindings

### ALIAS

# source shell
alias sourceme="source $HOME/.config/fish/config.fish"
alias reshell="exec fish"

# restart imwheel
alias reimwheel="killall imwheel && imwheel"

# programs
alias rg="rg --sort path" # search content with ripgrep
alias ls="exa"

# confirm before overwriting something
alias cp="cp -i"
alias mv='mv -i'
alias rm='rm -i'

# changing cat to bat
alias cat="batcat --theme=gruvbox-dark"
alias oldcat="/usr/bin/cat"

# changing "ls" to "exa"
alias ls='exa' # normal listing
alias ll='exa -l --color=always --group-directories-first'  # long format
alias lla='exa -la --color=always --group-directories-first'  # long format with hidden files
alias lli='exa -l --color=always --group-directories-first --icons'  # long format with icons
alias la='exa -a --color=always --group-directories-first'  # all files and dirs
alias lai='exa -la --color=always --group-directories-first --icons'  # all files and dirs with icons
alias lt='exa -aT --color=always --group-directories-first' # tree listing
alias llg="exa -l --git --color=always --group-directories-first" # git
alias llag="exa -la --git --color=always --group-directories-first" # git
alias llt='exa -laT --color=always --group-directories-first' # tree listing
alias lt1='exa -aT --level=1 --color=always --group-directories-first' # tree listing
alias lt2='exa -aT --level=2 --color=always --group-directories-first' # tree listing
alias lt3='exa -aT --level=3 --color=always --group-directories-first' # tree listing
alias l.='exa -a --color=always --group-directories-first | grep "^\."'
alias ll.='exa -la --color=always --group-directories-first | grep "^\."'
alias oldls='/usr/bin/ls'

# colorize grep output (good for log files)
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# xclip
alias setclip="xclip -selection c"
alias getclip="xclip -selection c -o"

# nvim
alias v="nvim"
