set -g fish_key_bindings fish_vi_key_bindings

# cargo and rust
fish_add_path ~/.cargo/bin

# flyctl
fish_add_path ~/.fly/bin

# my bin
fish_add_path ~/.dotfiles/bin

if not type -q tide
  and type -q starship 
  starship init fish | source
end

if type -q zoxide 
  zoxide init fish | source
end

if type -q atuin
  atuin init fish | source
end

# pnpm
set -gx NPM_HOME "/home/knth/.npm/bin"
if not string match -q -- $NPM_HOME $PATH
  set -gx PATH "$NPM_HOME" $PATH
end

# pnpm
set -gx PNPM_HOME "/home/knth/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
alias pn="pnpm"
# pnpm end

# Set Catppuccin-mocha theme to bat
# set -U BAT_THEME "Catppuccin-mocha"

# changing cat to bat
# if string match -rq "Debian" (uname -a); or string match -rq "WSL2" (uname -a)
#     # Alias for Debian or WSL2
#   alias cat="batcat" 
# else
# end
alias cat="bat" 
alias oldcat="/usr/bin/cat"

### ALIAS
alias pn="pnpm"

# source shell
alias sourceme="source $HOME/.config/fish/config.fish"
alias reshell="exec fish"
alias remap="setxkbmap -layout us,us -variant ,intl -option 'grp:alt_space_toggle'"

# restart imwheel
alias reimwheel="killall imwheel && imwheel"

# programs
alias rg="rg --sort path" # search content with ripgrep
alias ls="exa"

# confirm before overwriting something
alias cp="cp -i"
alias mv='mv -i'
alias rm='rm -i'

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

# x server for wsl2
set -Ux DISPLAY (awk "/nameserver / {print \$2; exit}" /etc/resolv.conf 2>/dev/null):0
set -Ux LIBGL_ALWAYS_INDIRECT 1
