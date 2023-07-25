function fish_user_key_bindings
  for mode in insert default visual
    bind -M $mode \cY accept-autosuggestion
    bind -M $mode \cE complete
  end
end
