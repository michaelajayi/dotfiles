local wezterm = require("wezterm")

local function basename(path)
	if not path then
		return ""
	end
	return path:gsub("(.*[/\\])", "")
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local pane = tab.active_pane

	-- Prefer cwd-based title
	local cwd_uri = pane.current_working_dir
	local title = ""

	if cwd_uri then
		-- cwd_uri is like "file:///Users/you/code/myproj"
		local cwd = cwd_uri.file_path or tostring(cwd_uri)
		title = basename(cwd)
	end

	-- Fallbacks
	if title == "" then
		title = pane.title or "term"
	end

	-- Optional: add tab index
	local idx = tab.tab_index + 1
	return string.format(" %d:%s ", idx, title)
end)

local config = {
	-- Window settings
	initial_cols = 120,
	initial_rows = 28,
	native_macos_fullscreen_mode = false,
	enable_tab_bar = true,
	window_close_confirmation = "NeverPrompt",
	window_decorations = "RESIZE",
	adjust_window_size_when_changing_font_size = false,

	-- Font configuration
	font = wezterm.font_with_fallback({
		{ family = "MonoLisa", weight = "Medium" },
		-- "JetBrainsMono Nerd Font Mono", -- Fallback for Nerd Font icons in tmux
	}),
	font_size = 13,
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
	window_background_opacity = 0.99,
	macos_window_background_blur = 50,
	keys = {
		{
			key = "q",
			mods = "CMD",
			action = wezterm.action.DisableDefaultAssignment,
		},
	},
}

return config
