function fish_greeting
    if not type -q fastfetch
        return
    end

    set -l logo_type chafa
    set -l logo_width 25
    set -l logo_height 18
    set -l config_home "$HOME/.config"
    set -l term_program ''
    set -l term_name ''

    if set -q XDG_CONFIG_HOME
        set config_home "$XDG_CONFIG_HOME"
    end

    set -l logo_source "$config_home/fastfetch/pngs/*.png"

    if set -q TERM_PROGRAM
        set term_program (string lower -- "$TERM_PROGRAM")
    end

    if set -q TERM
        set term_name (string lower -- "$TERM")
    end

    if not set -q TMUX
        if test "$term_program" = kitty -o "$term_program" = ghostty -o "$term_name" = xterm-kitty -o "$term_name" = xterm-ghostty
            set logo_type kitty-direct
        end
    end

    fastfetch --logo $logo_source --logo-type $logo_type --logo-width $logo_width --logo-height $logo_height
end
