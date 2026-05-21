-- =========================================
-- WezTerm Toggle (Ctrl + Cmd + J)
-- =========================================

-- Helper: find WezTerm window quickly
-- (app:mainWindow() returns nil for WezTerm due to window_decorations = "RESIZE",
--  and hs.window.filter is too slow for one-shot lookups)
local function findWezTermWindow()
    for _, w in ipairs(hs.window.orderedWindows()) do
        local wApp = w:application()
        if wApp and wApp:bundleID() == "com.github.wez.wezterm" then
            return w
        end
    end
    return nil
end

hs.hotkey.bind({ "ctrl", "cmd" }, "J", function()
    local app = hs.application.find("WezTerm")

    -- Case 1: not running -> launch
    if app == nil then
        hs.application.launchOrFocus("WezTerm")
        return
    end

    -- Case 2: WezTerm is frontmost -> hide
    local frontApp = hs.application.frontmostApplication()
    if frontApp and frontApp:bundleID() == app:bundleID() then
        app:hide()
        return
    end

    -- Find WezTerm window
    local win = findWezTermWindow()

    -- Case 3: no window found -> just activate
    if win == nil then
        app:activate()
        return
    end

    -- Case 4: minimized -> unminimize
    if win:isMinimized() then
        win:unminimize()
    end

    -- Case 5: move to current space
    local currentSpace = hs.spaces.focusedSpace()
    hs.spaces.moveWindowToSpace(win, currentSpace)

    -- Finalize
    app:activate()
    win:focus()
end)
