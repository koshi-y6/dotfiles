local config = function()
    require('copilot').setup({
        panel = {
            enabled = true,
            auto_refresh = false,
            keymap = {
                jump_prev = "[[",
                jump_next = "]]",
                accept = "<CR>",
                refresh = "gr",
                open = "<M-CR>"
            },
            layout = {
                position = "bottom", -- | top | left | right
                ratio = 0.4
            },
        },
        suggestion = {
            enabled = true,
            auto_trigger = true,
            hide_during_completion = true,
            debounce = 75,
            keymap = {
                accept = "<C-a>", -- Accept suggestion with Tab key
                accept_word = false,
                accept_line = false,
                next = "<C-h>",    -- Move to next suggestion with Ctrl + n
                prev = "<C-H>",    -- Move to previous suggestion with Ctrl + p
                dismiss = "<C-b>", -- Dismiss suggestion with Ctrl + e
            },
        },
        filetypes = {
            yaml = true,
            markdown = true,
            help = true,
            gitcommit = true,
            gitrebase = true,
            hgcommit = true,
            svn = true,
            cvs = true,
            ["."] = true,
        },
        copilot_node_command = 'node', -- Node.js version must be > 18.x
        server_opts_overrides = {
            -- model = "claude-3.7-sonnet",
        },
    })
end

return config
