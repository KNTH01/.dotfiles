local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "Catppuccin Frappe" -- or Macchiato, Frappe, Latte, Mocha

-- config.font = wezterm.font("MesloLGS Nerd Font Mono")
config.font = wezterm.font("JetBrainsMono Nerd Font Mono")
config.font_size = 12

config.enable_tab_bar = false

-- config.window_decorations = "NONE"

config.window_background_opacity = 1

config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

config.ssh_domains = {
	{
		name = "pixel-pirate",
		remote_address = "192.168.1.44",
		username = "knth",
	},
}

return config
