local wezterm = require("wezterm")
local mux = wezterm.mux

wezterm.on("gui-startup", function(cmd)
	local _, _, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

return {
	-- initial_cols = 138,
	-- initial_rows = 45,
	term = "xterm-256color",
	window_decorations = "NONE",
	enable_tab_bar = false,
	adjust_window_size_when_changing_font_size = false,
	window_background_opacity = 0.8,

	window_padding = {
		left = 10,
		right = 10,
		top = 15,
		bottom = 0,
	},

	font = wezterm.font("JetBrainsMono Nerd Font"),
	font_size = 14,

	colors = {
		foreground = "#D0CFCC",
		background = "#000000",
		cursor_bg = "#FFFFFF",
		cursor_border = "#FFFFFF",
		cursor_fg = "#171421",
		selection_bg = "#A2734C",
		selection_fg = "#171421",

		ansi = {
			"#171421", -- color0 (black)
			"#C01C28", -- color1 (red)
			"#26A270", -- color2 (green)
			"#A2734C", -- color3 (yellow)
			"#ffd701", -- color4 (blue)
			"#A347BA", -- color5 (magenta)
			"#2AA1B3", -- color6 (cyan)
			"#D0CFCC", -- color7 (white)
		},
		brights = {
			"#5E5C64", -- bright black
			"#ED1515", -- bright red
			"#11D116", -- bright green
			"#F67400", -- bright yellow
			"#ffd700", -- bright blue
			"#9B59B6", -- bright magenta
			"#1ABC9C", -- bright cyan
			"#FFFFFF", -- bright white
		},
	},

	keys = {
		{
			key = "Enter",
			mods = "ALT",
			action = wezterm.action.DisableDefaultAssignment,
		},
		{
			key = "f",
			mods = "ALT",
			action = wezterm.action.ToggleFullScreen,
		},
		-- 	{ key = "Home", mods = "NONE", action = wezterm.action.SendString("\x1b[H") },
		-- 	{ key = "End", mods = "NONE", action = wezterm.action.SendString("\x1b[F") },
	},

	-- Auto-Attach to Tmux or Start Zsh
	default_prog = {
		"/bin/zsh",
		"--login",
		"-c",
		"if command -v tmux >/dev/null 2>&1; then tmux attach || tmux new-session -s akbar; else exec zsh; fi",
	},
}
