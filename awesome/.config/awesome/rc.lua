--[[

     Awesome WM configuration template
     https://github.com/awesomeWM

     Freedesktop : https://github.com/lcpz/awesome-freedesktop

     Copycats themes : https://github.com/lcpz/awesome-copycats

     lain : https://github.com/lcpz/lain

--]]

-- {{{ Required libraries
local awesome, client, mouse, screen, tag = awesome, client, mouse, screen, tag
local ipairs, string, os, table, tostring, tonumber, type = ipairs, string, os, table, tostring, tonumber, type

-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

--https://awesomewm.org/doc/api/documentation/05-awesomerc.md.html
-- Standard awesome library
local gears = require("gears") --Utilities such as color parsing and objects
local awful = require("awful") --Everything related to window managment
require("awful.autofocus")

-- Widget and layout library
local wibox = require("wibox")

-- Theme handling library
local beautiful = require("beautiful")

-- Notification library
local naughty = require("naughty")
naughty.config.defaults["icon_size"] = 100

--local menubar       = require("menubar")
local lain = require("lain")
local freedesktop = require("freedesktop")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")

local my_table = awful.util.table or gears.table -- 4.{0,1} compatibility
local dpi = require("beautiful.xresources").apply_dpi
-- }}}

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors,
	})
end

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal("debug::error", function(err)
		if in_error then
			return
		end
		in_error = true

		naughty.notify({
			preset = naughty.config.presets.critical,
			title = "Oops, an error happened!",
			text = tostring(err),
		})
		in_error = false
	end)
end
-- }}}

-- {{{ Autostart windowless processes

-- This function will run once every time Awesome is started
local function run_once(cmd_arr)
	for _, cmd in ipairs(cmd_arr) do
		awful.spawn.with_shell(string.format("pgrep -u $USER -fx '%s' > /dev/null || (%s)", cmd, cmd))
	end
end

run_once({ "unclutter -root" }) -- entries must be comma-separated
-- }}}

-- This function implements the XDG autostart specification
--[[
awful.spawn.with_shell(
    'if (xrdb -query | grep -q "^awesome\\.started:\\s*true$"); then exit; fi;' ..
    'xrdb -merge <<< "awesome.started:true";' ..
    -- list each of your autostart commands, followed by ; inside single quotes, followed by ..
    'dex --environment Awesome --autostart --search-paths "$XDG_CONFIG_DIRS/autostart:$XDG_CONFIG_HOME/autostart"' -- https://github.com/jceb/dex
)
--]]

-- }}}

-- {{{ Variable definitions

local themes = {
	"multicolor", -- 1
	"powerarrow", -- 2
	"powerarrow-blue", -- 3
	"blackburn", -- 4
	"rosebox", -- 5
}
local chosen_theme = themes[5] -- choose your theme here
local theme_path = string.format("%s/.config/awesome/themes/%s/theme.lua", os.getenv("HOME"), chosen_theme)
beautiful.init(theme_path)

-- modKey or mod4 = super key
local modKey = "Mod4"
local altKey = "Mod1"
local ctrlKey = "Control"
local shiftKey = "Shift"

-- personal variables
-- change these variables if you want
local browser1 = "vivaldi-stable"
local browser2 = "firefox"
local browser3 = "chromium -no-default-browser-check"
local editor = os.getenv("EDITOR") or "nano"
local editorgui = "code"
local filemanager = "thunar"
local mailclient = "evolution"
local musicplayer = "spotify"
local terminal = "alacritty"
local virtualmachine = "virtualbox"

-- awesome variables
awful.util.terminal = terminal
awful.util.tagnames = { "一", "二", "三", "四", "五", "六", "七", "八", "九" } -- #10 => "十"
-- awful.util.tagnames = { "➊", "➋", "➌", "➍", "➎", "➏", "➐", "➑", "➒", "➓" }
--awful.util.tagnames = { "⠐", "⠡", "⠲", "⠵", "⠻", "⠿" }
-- Use this : https://fontawesome.com/cheatsheet
-- awful.util.tagnames = { "", "", "", "", "" }

awful.layout.suit.tile.left.mirror = true

awful.layout.layouts = {
	awful.layout.suit.tile,
	awful.layout.suit.floating,
	awful.layout.suit.tile.left,
	awful.layout.suit.tile.bottom,
	awful.layout.suit.tile.top,
	--awful.layout.suit.fair,
	--awful.layout.suit.fair.horizontal,
	--awful.layout.suit.spiral,
	--awful.layout.suit.spiral.dwindle,
	awful.layout.suit.max,
	--awful.layout.suit.max.fullscreen,
	awful.layout.suit.magnifier,
	--awful.layout.suit.corner.nw,
	--awful.layout.suit.corner.ne,
	--awful.layout.suit.corner.sw,
	--awful.layout.suit.corner.se,
	--lain.layout.cascade,
	--lain.layout.cascade.tile,
	--lain.layout.centerwork,
	--lain.layout.centerwork.horizontal,
	--lain.layout.termfair,
	--lain.layout.termfair.center,
}

-- TODO: comment this
lain.layout.termfair.nmaster = 3
lain.layout.termfair.ncol = 1
lain.layout.termfair.center.nmaster = 3
lain.layout.termfair.center.ncol = 1
lain.layout.cascade.tile.offset_x = dpi(2)
lain.layout.cascade.tile.offset_y = dpi(32)
lain.layout.cascade.tile.extra_padding = dpi(5)
lain.layout.cascade.tile.nmaster = 5
lain.layout.cascade.tile.ncol = 2

awful.util.taglist_buttons = my_table.join(
	awful.button({}, 1, function(t)
		t:view_only()
	end),
	awful.button({ modKey }, 1, function(t)
		if client.focus then
			client.focus:move_to_tag(t)
		end
	end),
	awful.button({}, 3, awful.tag.viewtoggle),
	awful.button({ modKey }, 3, function(t)
		if client.focus then
			client.focus:toggle_tag(t)
		end
	end),
	awful.button({}, 4, function(t)
		awful.tag.viewnext(t.screen)
	end),
	awful.button({}, 5, function(t)
		awful.tag.viewprev(t.screen)
	end)
)

awful.util.tasklist_buttons = my_table.join(
	awful.button({}, 1, function(c)
		if c == client.focus then
			c.minimized = true
		else
			c:emit_signal("request::activate", "tasklist", { raise = true })
		end
	end),
	awful.button({}, 3, function()
		local instance = nil

		return function()
			if instance and instance.wibox.visible then
				instance:hide()
				instance = nil
			else
				instance = awful.menu.clients({ theme = { width = dpi(250) } })
			end
		end
	end),
	awful.button({}, 4, function()
		awful.client.focus.byidx(1)
	end),
	awful.button({}, 5, function()
		awful.client.focus.byidx(-1)
	end)
)

-- }}}

-- {{{ Menu
local myawesomemenu = {
	{
		"hotkeys",
		function()
			return false, hotkeys_popup.show_help
		end,
	},
	{ "arandr", "arandr" },
}

-- TODO: remove mymainmenu this as I don't need this!
awful.util.mymainmenu = freedesktop.menu.build({
	before = {
		{ "Awesome", myawesomemenu },
		--{ "Atom", "atom" },
		-- other triads can be put here
	},
	after = {
		{ "Terminal", terminal },
		{
			"Log out",
			function()
				awesome.quit()
			end,
		},
		{ "Sleep", "systemctl suspend" },
		{ "Restart", "systemctl reboot" },
		{ "Shutdown", "systemctl poweroff" },
		-- other triads can be put here
	},
})
-- hide menu when mouse leaves it
--awful.util.mymainmenu.wibox:connect_signal("mouse::leave", function() awful.util.mymainmenu:hide() end)

--menubar.utils.terminal = terminal -- Set the Menubar terminal for applications that require it
-- }}}

-- {{{ Screen
-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", function(s)
	-- Wallpaper
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		-- If wallpaper is a function, call it with the screen
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		end
		gears.wallpaper.maximized(wallpaper, s, true)
	end
end)

-- No borders when rearranging only 1 non-floating or maximized client
screen.connect_signal("arrange", function(s)
	local only_one = #s.tiled_clients == 1
	for _, c in pairs(s.clients) do
		if only_one and not c.floating or c.maximized or c.fullscreen then
			c.border_width = 0
		else
			c.border_width = beautiful.border_width
		end
	end
end)

-- Create a wibox for each screen and add it
awful.screen.connect_for_each_screen(function(s)
	beautiful.at_screen_connect(s)
	s.systray = wibox.widget.systray()
	s.systray.visible = true
end)

-- }}}

-- {{{ Mouse bindings
root.buttons(my_table.join(
	awful.button({}, 3, function()
		awful.util.mymainmenu:toggle()
	end),
	awful.button({}, 4, awful.tag.viewnext),
	awful.button({}, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
local globalkeys = my_table.join(

	--
	-- program launcher
	--

	awful.key({ modKey }, "Return", function()
		awful.spawn(terminal)
	end, { description = terminal, group = "super" }),

	awful.key({ modKey }, "b", function()
		awful.util.spawn(browser1)
	end, {
		description = browser1,
		group = "program launcher",
	}),
	awful.key({ modKey }, "e", function()
		awful.util.spawn(filemanager)
	end, {
		description = filemanager,
		group = "program launcher",
	}),
	awful.key({ modKey }, "c", function()
		awful.util.spawn("conky-toggle")
	end, {
		description = "conky-toggle",
		group = "program launcher",
	}),
	awful.key({ modKey }, "v", function()
		awful.util.spawn("pavucontrol")
	end, {
		description = "pulseaudio control",
		group = "program launcher",
	}),
	awful.key({ ctrlKey, altKey }, "Delete", function()
		awful.util.spawn("xfce4-taskmanager")
	end, {
		description = "task manager",
		group = "program launcher",
	}),
	awful.key({ modKey }, "x", function()
		awful.util.spawn("arcolinux-logout")
	end, {
		description = "exit",
		group = "program launcher",
	}),
	awful.key({ ctrlKey, altKey, shiftKey }, "v", function()
		awful.util.spawn("copyq show")
	end, {
		description = "copyq",
		group = "program launcher",
	}),

	--
	-- hotkeys
	--

	awful.key({ modKey }, "Escape", function()
		awful.util.spawn("xkill")
	end, {
		description = "Kill proces",
		group = "hotkeys",
	}),

	-- Brightness
	awful.key({}, "XF86MonBrightnessUp", function()
		os.execute("xbacklight -inc 10")
	end, {
		description = "+10%",
		group = "hotkeys",
	}),
	awful.key({}, "XF86MonBrightnessDown", function()
		os.execute("xbacklight -dec 10")
	end, {
		description = "-10%",
		group = "hotkeys",
	}),

	--
	-- menu launcher
	--

	-- dmenu
	-- awful.key({ modKey, shiftKey }, "d", function()
	-- 	awful.spawn(
	-- 		string.format(
	-- 			"dmenu_run -i -nb '#191919' -nf '#fea63c' -sb '#fea63c' -sf '#191919' -fn NotoMonoRegular:bold:pixelsize=14",
	-- 			beautiful.bg_normal,
	-- 			beautiful.fg_normal,
	-- 			beautiful.bg_focus,
	-- 			beautiful.fg_focus
	-- 		)
	-- 	)
	-- end, {
	-- 	description = "show dmenu",
	-- 	group = "hotkeys",
	-- }),

	awful.key({ modKey }, "p", function()
		awful.util.spawn("rofi -no-lazy-grab -show window -theme '~/.config/rofi/launchers/misc/kde_krunner'")
	end, {
		description = "rofi show windows",
		group = "menu launcher",
	}),
	awful.key({ modKey }, "Space", function()
		awful.util.spawn("rofi -no-lazy-grab -show window -theme '~/.config/rofi/launchers/misc/kde_krunner'")
	end, {
		description = "rofi show windows",
		group = "menu launcher",
	}),
	awful.key({ modKey, shiftKey }, "p", function()
		awful.util.spawn("rofi -no-lazy-grab -show drun -theme '~/.config/rofi/launchers/misc/kde_simplemenu'")
	end, {
		description = "rofi show desktop programs",
		group = "menu launcher",
	}),
	awful.key({ modKey, shiftKey }, "d", function()
		awful.util.spawn("rofi -no-lazy-grab -show run -theme '~/.config/rofi/launchers/misc/kde_krunner'")
	end, {
		description = "rofi show runner",
		group = "menu launcher",
	}),

	-- TODO: alacritty dropdown?
	-- Function keys
	-- awful.key({ }, "F12", function () awful.util.spawn( "xfce4-terminal --drop-down" ) end,
	--     { description = "dropdown terminal" , group = "function keys" }
	-- ),

	-- Hotkeys Awesome
	awful.key({ modKey }, "s", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),
	awful.key({ modKey, shiftKey }, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),
	-- run lua code
	awful.key({ altKey }, "x", function()
		awful.prompt.run({
			prompt = "Run Lua code: ",
			textbox = awful.screen.focused().mypromptbox.widget,
			exe_callback = awful.util.eval,
			history_path = awful.util.get_cache_dir() .. "/history_eval",
		})
	end, {
		description = "lua execute prompt",
		group = "awesome",
	}),
	-- Show/Hide Wibox
	awful.key({ modKey, shiftKey }, "b", function()
		for s in screen do
			s.mywibox.visible = not s.mywibox.visible
			if s.mybottomwibox then
				s.mybottomwibox.visible = not s.mybottomwibox.visible
			end
		end
	end, {
		description = "toggle wibox",
		group = "awesome",
	}),
	-- Show/Hide Systray
	awful.key({ modKey }, "\\", function()
		awful.screen.focused().systray.visible = not awful.screen.focused().systray.visible
	end, {
		description = "Toggle systray visibility",
		group = "awesome",
	}),

	-- screenshots
	awful.key({}, "Print", function()
		awful.util.spawn_with_shell("maim ~/Pictures/screenshots/screenshot_$(date +%F_%H:%M:%S).png")
	end, {
		description = "Capture desktop",
		group = "screenshots",
	}),
	awful.key({ modKey, shiftKey }, "s", function()
		awful.util.spawn_with_shell(
			"maim -s | tee ~/Pictures/screenshots/screenshot_$(date +%F_%H:%M:%S).png | xclip -selection clipboard -t image/png"
		)
	end, {
		description = "capture selection",
		group = "screenshots",
	}),

	--
	-- TAGS
	--

	-- tags browsing
	awful.key({ modKey, ctrlKey }, "Left", awful.tag.viewprev, { description = "view previous", group = "tag" }),
	awful.key({ modKey, ctrlKey }, "Right", awful.tag.viewnext, { description = "view next", group = "tag" }),
	awful.key({ altKey }, "Escape", awful.tag.history.restore, { description = "go back", group = "tag" }),
	-- Non-empty tag browsing
	awful.key({ altKey }, "Tab", function()
		lain.util.tag_view_nonempty(1)
	end, {
		description = "view next",
		group = "tag",
	}),
	awful.key({ altKey, shiftKey }, "Tab", function()
		lain.util.tag_view_nonempty(-1)
	end, {
		description = "view previous",
		group = "tag",
	}),

	-- Dynamic tagging
	-- awful.key({ modKey, shiftKey }, "n", function()
	-- 	lain.util.add_tag()
	-- end, {
	-- 	description = "add new tag",
	-- 	group = "tag",
	-- }),
	-- awful.key({ modKey, ctrlKey }, "r", function()
	-- 	lain.util.rename_tag()
	-- end, {
	-- 	description = "rename tag",
	-- 	group = "tag",
	-- }),
	-- awful.key({ modKey, shiftKey }, "Left", function()
	-- 	lain.util.move_tag(-1)
	-- end, {
	-- 	description = "move tag to the left",
	-- 	group = "tag",
	-- }),
	-- awful.key({ modKey, shiftKey }, "Right", function()
	-- 	lain.util.move_tag(1)
	-- end, {
	-- 	description = "move tag to the right",
	-- 	group = "tag",
	-- }),
	-- awful.key({ modKey, shiftKey }, "y", function()
	-- 	lain.util.delete_tag()
	-- end, {
	-- 	description = "delete tag",
	-- 	group = "tag",
	-- }),

	--
	-- Client
	--

	-- By direction client focus
	-- awful.key({ modKey }, "j", function()
	-- 	awful.client.focus.global_bydirection("down")
	-- 	if client.focus then
	-- 		client.focus:raise()
	-- 	end
	-- end, {
	-- 	description = "focus down",
	-- 	group = "client",
	-- }),
	-- awful.key({ modKey }, "k", function()
	-- 	awful.client.focus.global_bydirection("up")
	-- 	if client.focus then
	-- 		client.focus:raise()
	-- 	end
	-- end, {
	-- 	description = "focus up",
	-- 	group = "client",
	-- }),
	-- awful.key({ modKey }, "h", function()
	-- 	awful.client.focus.global_bydirection("left")
	-- 	if client.focus then
	-- 		client.focus:raise()
	-- 	end
	-- end, {
	-- 	description = "focus left",
	-- 	group = "client",
	-- }),
	-- awful.key({ modKey }, "l", function()
	-- 	awful.client.focus.global_bydirection("right")
	-- 	if client.focus then
	-- 		client.focus:raise()
	-- 	end
	-- end, {
	-- 	description = "focus right",
	-- 	group = "client",
	-- }),
	--
	--

	-- Default client focus
	awful.key({ modKey }, "Down", function()
		awful.client.focus.byidx(1)
	end, {
		description = "focus next by index",
		group = "client",
	}),
	awful.key({ modKey }, "Up", function()
		awful.client.focus.byidx(-1)
	end, {
		description = "focus previous by index",
		group = "client",
	}),
	awful.key({ modKey }, "j", function()
		awful.client.focus.byidx(1)
	end, {
		description = "focus next by index",
		group = "client",
	}),
	awful.key({ modKey }, "k", function()
		awful.client.focus.byidx(-1)
	end, {
		description = "focus previous by index",
		group = "client",
	}),

	-- Swap focused client position
	awful.key({ modKey, shiftKey }, "Down", function()
		awful.client.swap.byidx(1)
	end, {
		description = "swap with next client by index",
		group = "client",
	}),
	awful.key({ modKey, shiftKey }, "Up", function()
		awful.client.swap.byidx(-1)
	end, {
		description = "swap with previous client by index",
		group = "client",
	}),
	awful.key({ modKey, shiftKey }, "j", function()
		awful.client.swap.byidx(1)
	end, {
		description = "swap with next client by index",
		group = "client",
	}),
	awful.key({ modKey, shiftKey }, "k", function()
		awful.client.swap.byidx(-1)
	end, {
		description = "swap with previous client by index",
		group = "client",
	}),

	-- focus urgent client
	awful.key({ modKey }, "u", awful.client.urgent.jumpto, { description = "jump to urgent client", group = "client" }),

	-- restore minimized client
	awful.key({ modKey, ctrlKey }, "n", function()
		local c = awful.client.restore()
		-- Focus restored client
		if c then
			client.focus = c
			c:raise()
		end
	end, {
		description = "restore minimized",
		group = "client",
	}),

	--
	-- Layout
	--

	-- multi screen?
	awful.key({ modKey, ctrlKey }, "j", function()
		awful.screen.focus_relative(1)
	end, {
		description = "focus the next screen",
		group = "screen",
	}),
	awful.key({ modKey, ctrlKey }, "k", function()
		awful.screen.focus_relative(-1)
	end, {
		description = "focus the previous screen",
		group = "screen",
	}),

	-- On the fly useless gaps change
	awful.key({ modKey }, "=", function()
		lain.util.useless_gaps_resize(1)
	end, {
		description = "increment useless gaps",
		group = "layout",
	}),
	awful.key({ modKey }, "-", function()
		lain.util.useless_gaps_resize(-1)
	end, {
		description = "decrement useless gaps",
		group = "layout",
	}),

	-- master size
	awful.key({ modKey }, "l", function()
		awful.tag.incmwfact(0.05)
	end, {
		description = "increase master width factor",
		group = "layout",
	}),
	awful.key({ modKey }, "h", function()
		awful.tag.incmwfact(-0.05)
	end, {
		description = "decrease master width factor",
		group = "layout",
	}),
	awful.key({ modKey }, "Right", function()
		awful.tag.incmwfact(0.05)
	end, {
		description = "increase master width factor",
		group = "layout",
	}),
	awful.key({ modKey }, "Left", function()
		awful.tag.incmwfact(-0.05)
	end, {
		description = "decrease master width factor",
		group = "layout",
	}),

	-- master client number
	awful.key({ modKey, ctrlKey }, "Up", function()
		awful.tag.incnmaster(1, nil, true)
	end, {
		description = "increase the number of master clients",
		group = "layout",
	}),
	awful.key({ modKey, ctrlKey }, "Down", function()
		awful.tag.incnmaster(-1, nil, true)
	end, {
		description = "decrease the number of master clients",
		group = "layout",
	}),

	-- columns number
	awful.key({ modKey }, "]", function()
		awful.tag.incncol(1, nil, true)
	end, {
		description = "increase the number of columns",
		group = "layout",
	}),
	awful.key({ modKey }, "[", function()
		awful.tag.incncol(-1, nil, true)
	end, {
		description = "decrease the number of columns",
		group = "layout",
	}),

	-- layout navigation
	awful.key({ modKey }, "Tab", function()
		awful.layout.inc(1)
	end, {
		description = "select next",
		group = "layout",
	}),
	awful.key({ modKey, shiftKey }, "Tab", function()
		awful.layout.inc(-1)
	end, {
		description = "select previous",
		group = "layout",
	}),

	--
	-- ALSA volume control / media
	--

	awful.key({}, "XF86AudioRaiseVolume", function()
		os.execute(string.format("amixer -q set %s 1%%+", beautiful.volume.channel))
		beautiful.volume.update()
	end),
	awful.key({}, "XF86AudioLowerVolume", function()
		os.execute(string.format("amixer -q set %s 1%%-", beautiful.volume.channel))
		beautiful.volume.update()
	end),
	awful.key({}, "XF86AudioMute", function()
		os.execute(string.format("amixer -q set %s toggle", beautiful.volume.togglechannel or beautiful.volume.channel))
		beautiful.volume.update()
	end),
	awful.key({ ctrlKey, shiftKey }, "m", function()
		os.execute(string.format("amixer -q set %s 100%%", beautiful.volume.channel))
		beautiful.volume.update()
	end),
	awful.key({ ctrlKey, shiftKey }, "0", function()
		os.execute(string.format("amixer -q set %s 0%%", beautiful.volume.channel))
		beautiful.volume.update()
	end),

	--Media keys supported by vlc, spotify, audacious, xmm2, ...
	awful.key({}, "XF86AudioPlay", function()
		awful.util.spawn("playerctl play-pause", false)
	end),
	awful.key({}, "XF86AudioNext", function()
		awful.util.spawn("playerctl next", false)
	end),
	awful.key({}, "XF86AudioPrev", function()
		awful.util.spawn("playerctl previous", false)
	end),
	awful.key({}, "XF86AudioStop", function()
		awful.util.spawn("playerctl stop", false)
	end)
)

local clientkeys = my_table.join(
	-- close client
	awful.key({ modKey }, "q", function(c)
		c:kill()
	end, { description = "close", group = "hotkeys" }),

	-- magnify client
	awful.key({ modKey, shiftKey }, "m", lain.util.magnify_client, { description = "magnify client", group = "client" }),

	-- maximize client
	awful.key({ modKey }, "m", function(c)
		c.maximized = not c.maximized
		c:raise()
	end, {
		description = "maximize",
		group = "client",
	}),

	-- full screen
	awful.key({ modKey }, "f", function(c)
		c.fullscreen = not c.fullscreen
		c:raise()
	end, {
		description = "toggle fullscreen",
		group = "client",
	}),

	-- toggle float
	awful.key(
		{ modKey, shiftKey },
		"f",
		awful.client.floating.toggle,
		{ description = "toggle floating", group = "client" }
	),

	-- promote client to master
	awful.key({ modKey }, "backspace", function(c)
		c:swap(awful.client.getmaster())
	end, {
		description = "promote to master",
		group = "client",
	}),

	-- pin to top
	awful.key({ modKey }, "t", function(c)
		c.ontop = not c.ontop
	end, {
		description = "toggle keep on top",
		group = "client",
	}),

	-- ??
	awful.key({ modKey }, "o", function(c)
		c:move_to_screen()
	end, { description = "move to screen", group = "client" }),

	awful.key({ modKey }, "n", function(c)
		-- The client currently has the input focus, so it cannot be
		-- minimized, since minimized clients can't have the focus.
		c.minimized = true
	end, {
		description = "minimize",
		group = "client",
	})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
	-- Hack to only show tags 1 and 9 in the shortcut window (mod+s)
	local descr_view, descr_toggle, descr_move, descr_toggle_focus
	if i == 1 or i == 9 then
		descr_view = { description = "view tag #", group = "tag" }
		descr_toggle = { description = "toggle tag #", group = "tag" }
		descr_move = { description = "move focused client to tag #", group = "tag" }
		descr_toggle_focus = { description = "toggle focused client on tag #", group = "tag" }
	end
	globalkeys = my_table.join(
		globalkeys,
		-- View tag only.
		awful.key({ modKey }, "#" .. i + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				tag:view_only()
			end
		end, descr_view),
		-- Toggle tag display.
		awful.key({ modKey, ctrlKey }, "#" .. i + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				awful.tag.viewtoggle(tag)
			end
		end, descr_toggle),
		-- Move client to tag.
		awful.key({ modKey, shiftKey }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:move_to_tag(tag)
				end
			end
		end, descr_move),
		-- Toggle tag on focused client.
		awful.key({ modKey, ctrlKey, shiftKey }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:toggle_tag(tag)
				end
			end
		end, descr_toggle_focus)
	)
end

local clientbuttons = gears.table.join(
	awful.button({}, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
	end),
	awful.button({ modKey }, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.move(c)
	end),
	awful.button({ modKey }, 3, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.resize(c)
	end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
	-- All clients will match this rule.
	{
		rule = {},
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			raise = true,
			keys = clientkeys,
			buttons = clientbuttons,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen,
			size_hints_honor = false,
		},
	},

	-- Titlebars
	{
		rule_any = {
			type = { "dialog", "normal" },
		},
		properties = { titlebars_enabled = false },
	},

	-- Set applications to always map on the tag x on screen y.
	-- find class or role via xprop command
	{
		rule_any = {
			class = {
				browser1,
				browser2,
				"chromium (/home/knth/.config/Cypress/cy/production/browsers/chromium-stable/interactive)",
			},
		},
		properties = { screen = 1, tag = awful.util.tagnames[1], switchtotag = true },
	},
	{
		rule_any = {
			name = {
				"Spotify",
			},
			class = {
				"spotify",
			},
		},
		properties = { screen = 1, tag = awful.util.tagnames[4], switchtotag = false },
	},
	{
		rule_any = {
			class = {
				"Telegram",
				"telegram-desktop",
				"WhatsApp",
				"whatsapp-nativefier-d40211",
				"Signal",
				"discord",
			},
		},
		properties = { screen = 1, tag = awful.util.tagnames[5], switchtotag = false },
	},

	-- Set applications to be maximized at startup.
	{ rule = { class = "Gimp*", role = "gimp-image-window" }, properties = { maximized = true } },
	{ rule = { class = "Gnome-disks" }, properties = { maximized = true } },
	{ rule = { class = "inkscape" }, properties = { maximized = true } },
	{ rule = { class = musicplayer }, properties = { maximized = true } },
	{ rule = { class = "Vlc" }, properties = { maximized = true } },
	{ rule = { class = "VirtualBox Manager" }, properties = { maximized = true } },
	{ rule = { class = "VirtualBox Machine" }, properties = { maximized = true } },
	{ rule = { class = "Xfce4-settings-manager" }, properties = { floating = true } },

	-- Floating clients.
	{
		rule_any = {
			instance = {
				"DTA", -- Firefox addon DownThemAll.
				"copyq", -- Includes session name in class.
				"pinentry",
			},
			class = {
				"Arandr",
				"Blueman-manager",
				"Arcolinux-welcome-app.py",
				"Blueberry",
				"Galculator",
				"Gnome-font-viewer",
				"Gpick",
				"Imagewriter",
				"Font-manager",
				"Kruler",
				"MessageWin", -- kalarm.
				"arcolinux-logout",
				"Peek",
				"Skype",
				"System-config-printer.py",
				"Sxiv",
				"Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
				"Unetbootin.elf",
				"Wpa_gui",
				"veromix",
				"xtightvncviewer",
			},

			-- Note that the name property shown in xprop might be set slightly after creation of the client
			-- and the name shown there might not match defined rules here.
			name = {
				"Event Tester", -- xev.
			},
			role = {
				"AlarmWindow", -- Thunderbird's calendar.
				"ConfigManager", -- Thunderbird's about:config.
				"pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
				"Preferences",
				"setup",
			},
		},
		properties = { floating = true },
	},

	-- Floating clients but centered in screen
	{
		rule_any = {
			class = {
				"Polkit-gnome-authentication-agent-1",
				"Arcolinux-calamares-tool.py",
			},
		},
		properties = { floating = true },
		callback = function(c)
			awful.placement.centered(c, nil)
		end,
	},
}

-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
	-- Set the windows at the slave,
	-- i.e. put it at the end of others instead of setting it master.
	-- if not awesome.startup then awful.client.setslave(c) end

	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		-- Prevent clients from being unreachable after screen count changes.
		awful.placement.no_offscreen(c)
	end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
	-- Custom
	if beautiful.titlebar_fun then
		beautiful.titlebar_fun(c)
		return
	end

	-- Default
	-- buttons for the titlebar
	local buttons = my_table.join(
		awful.button({}, 1, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.move(c)
		end),
		awful.button({}, 3, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.resize(c)
		end)
	)

	awful.titlebar(c, { size = dpi(21) }):setup({
		{ -- Left
			awful.titlebar.widget.iconwidget(c),
			buttons = buttons,
			layout = wibox.layout.fixed.horizontal,
		},
		{ -- Middle
			{ -- Title
				align = "center",
				widget = awful.titlebar.widget.titlewidget(c),
			},
			buttons = buttons,
			layout = wibox.layout.flex.horizontal,
		},
		{ -- Right
			awful.titlebar.widget.floatingbutton(c),
			awful.titlebar.widget.maximizedbutton(c),
			awful.titlebar.widget.stickybutton(c),
			awful.titlebar.widget.ontopbutton(c),
			awful.titlebar.widget.closebutton(c),
			layout = wibox.layout.fixed.horizontal(),
		},
		layout = wibox.layout.align.horizontal,
	})
end)

client.connect_signal("focus", function(c)
	c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c)
	c.border_color = beautiful.border_normal
end)

-- awesome memory leak
gears.timer.start_new(600, function()
	collectgarbage("step", 1024)
	return true
end)
-- }}}

-- Autostart applications
awful.spawn.with_shell("~/.config/awesome/autostart.sh")
