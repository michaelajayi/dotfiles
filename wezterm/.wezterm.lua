local wezterm = require("wezterm")

local config = {
	-- Window settings
	initial_cols = 120,
	initial_rows = 28,
	native_macos_fullscreen_mode = false,
	enable_tab_bar = false,
	window_close_confirmation = "NeverPrompt",
	window_decorations = "RESIZE",
	adjust_window_size_when_changing_font_size = false,

	-- Font configuration
	font = wezterm.font_with_fallback({
		{ family = "MonoLisa", weight = "Medium" },
		-- "JetBrainsMono Nerd Font Mono", -- Fallback for Nerd Font icons in tmux
	}),
	font_size = 14,
	line_height = 1.2,
	harfbuzz_features = { "liga=1", "calt=1", "ss02=1" },

	-- Appearance
	color_scheme = "rose-pine",
	default_cursor_style = "BlinkingBar",

	-- Performance
	max_fps = 60,
	front_end = "WebGpu",
	animation_fps = 1,

	underline_thickness = "200%",
	underline_position = "-4pt",

	-- Uncomment for transparency:
	window_background_opacity = 0.95,
	macos_window_background_blur = 10,
}

return config
