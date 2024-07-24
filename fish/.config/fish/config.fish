# envars
set -gx EDITOR nvim

# vi key bindings
set -g fish_key_bindings fish_vi_key_bindings

# open command buffer in vim when alt+e is pressed
bind \ee edit_command_buffer

# added by Nix installer
if test -e /home/knth/.nix-profile/etc/profile.d/nix.fish
    . /home/knth/.nix-profile/etc/profile.d/nix.fish
end

if not type -q tide
    and type -q starship
    starship init fish | source
end

if type -q zoxide
    zoxide init --cmd cd fish | source
end

if type -q atuin
    atuin init fish | source
end

# changing cat to bat
# if string match -rq "Debian" (uname -a); or string match -rq "WSL2" (uname -a)
#     # Alias for Debian or WSL2
#   alias cat="batcat" 
# else
#   alias cat="bat" 
# end
# alias oldcat="/usr/bin/cat"

# x server for wsl2
# set -Ux DISPLAY (awk "/nameserver / {print \$2; exit}" /etc/resolv.conf 2>/dev/null):0
# set -Ux LIBGL_ALWAYS_INDIRECT 1


# cargo and rust
# fish_add_path ~/.cargo/bin

# flyctl
# fish_add_path ~/.fly/bin

# my bin
fish_add_path ~/.dotfiles/bin


# pnpm + npm
set -gx PNPM_HOME "/home/knth/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end

# npm config set prefix '/home/knth/.local/share/npm'
set -gx NPM_HOME "/home/knth/.local/share/npm"
if not string match -q -- $NPM_HOME $PATH
    set -gx PATH "$NPM_HOME/bin" $PATH
end
# pnpm end

#### aliases

# alias cat="bat"
if command -v batcat >/dev/null
    alias cat='batcat'
else if command -v bat >/dev/null
    alias cat='bat'
end

alias oldcat="/usr/bin/cat"
alias oldls="/usr/bin/ls"

# changing "ls" to "exa"
alias ls="eza --color=always --group-directories-first --icons" # normal listing;
alias la="eza -a --color=always --group-directories-first --icons" # all files and dirs;
alias ll="eza -l --color=always --group-directories-first --icons" # long format;
alias lla="eza -la --color=always --group-directories-first --icons" # long format with hidden files;
alias lt="eza -aT --color=always --group-directories-first --icons" # ; tree listing;
alias llg="eza -l --git --color=always --group-directories-first --icons" # git;
alias llag="eza -la --git --color=always --group-directories-first --icons" # git;
alias llt="eza -laT --color=always --group-directories-first --icons" # tree listing;
alias lt1="eza -aT --level=1 --color=always --group-directories-first --icons" # tree listing;
alias lt3="eza -aT --level=3 --color=always --group-directories-first --icons" # tree listing;
alias lt2="eza -aT --level=2 --color=always --group-directories-first --icons" # tree listing; 

# xclip;
alias setclip="xclip -selection c"
alias getclip="xclip -selection c -o"

# source shell
alias sourceme="source $HOME/.config/fish/config.fish"
alias reshell="exec fish"

#### Abbr
abbr -a pn pnpm
abbr -a remap setxkbmap -layout us,us -variant ,intl -option 'grp:alt_space_toggle'
abbr -a cl clear

# restart imwheel;
# reimwheel = "killall imwheel && imwheel";

# programs
# rg = "rg --sort path"; # search content with ripgrep;

# colorize grep output (good for log files);
# egrep = "egrep --color=auto";
# grep = "grep --color=auto";
# fgrep = "fgrep --color=auto";

# nvim
abbr -a v nvim
abbr -a lg lazygit
abbr -a lk lazydocker

alias fix-key='sudo rm /var/lib/pacman/sync/* && sudo rm -rf /etc/pacman.d/gnupg/* && sudo pacman-key --init && sudo pacman-key --populate && sudo pacman -Sy --noconfirm archlinux-keyring && sudo pacman --noconfirm -Su'
alias update-mirrors='sudo reflector --verbose --score 100 --latest 20 --fastest 5 --sort rate --save /etc/pacman.d/mirrorlist && sudo pacman -Syyu'
alias update-grub='sudo grub-mkconfig -o /boot/grub/grub.cfg'
alias clean-arch='paru -Sc && paru -c'


### yazi
function yy
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        cd -- "$cwd"
    end
    rm -f -- "$tmp"
end
