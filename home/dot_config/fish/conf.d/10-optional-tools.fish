if type -q zoxide
    zoxide init --cmd cd fish | source
end

if type -q fzf
    fzf --fish | source
end

if type -q atuin
    atuin init fish | source
end

if type -q mise
    mise activate fish | source
end
