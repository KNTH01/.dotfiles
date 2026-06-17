function fish_user_key_bindings
    for mode in insert default visual
        bind -M $mode \cY accept-autosuggestion
        bind -M $mode \cE complete
    end

    # fzf.fish binds Ctrl+R to its history search by default.
    # Keep fzf.fish for its other bindings, but let Atuin own history search.
    if functions -q _atuin_search
        bind \cr _atuin_search
        bind -M insert \cr _atuin_search
    end
end
