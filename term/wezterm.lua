-- ~/.wezterm.lua
local wezterm = require('wezterm')
local config

-- Create configuration object
if wezterm.config_builder then
    config = wezterm.config_builder()
else
    config = {}
end

-- Color scheme settings
config.color_scheme = 'Dracula'

-- Font settings
config.font = wezterm.font('JetBrains Mono')
config.font_size = 14

-- Opacity settings
config.window_background_opacity = 0.87

-- Window decoration settings (hide window control buttons)
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.macos_window_background_blur = 30

-- Connect to the most recently used tmux session at startup, or start a new one
config.default_prog = {
    '/bin/zsh',
    '-c',
    'LATEST=$(/opt/homebrew/bin/tmux list-sessions -F "#{session_last_attached} #{session_name}" | sort -nr | head -n1 | cut -d" " -f2) && (/opt/homebrew/bin/tmux attach -t "$LATEST" || /opt/homebrew/bin/tmux); exec /bin/zsh'
} -- Key binding settings
config.enable_kitty_keyboard = true
config.colors = {
    compose_cursor = 'rgba(0, 0, 0, 0)',
}

local mux = wezterm.mux
wezterm.on("gui-startup", function(cmd)
    local tab, pane, window = mux.spawn_window(cmd or {})
    window:gui_window():maximize()
end)

return config
