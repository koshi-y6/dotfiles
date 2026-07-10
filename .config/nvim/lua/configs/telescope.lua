local config = function()
    local telescope = require('telescope')

    -- Telescopeの設定
    telescope.setup({
        defaults = {
            layout_strategy = "horizontal",
            sorting_strategy = "ascending",
            layout_config = {
                prompt_position = "top",
                horizontal = {
                    preview_width = 0.58,
                    width = 0.92,
                    height = 0.88,
                },
            },
            preview = {
                hide_on_startup = false,
            },
        },
        pickers = {
            find_files = {
                hidden = true,
            },
            live_grep = {
                hidden = true,
                layout_strategy = "horizontal",
                layout_config = {
                    prompt_position = "top",
                    horizontal = {
                        preview_width = 0.6,
                        width = 0.95,
                        height = 0.9,
                    },
                },
            },
            buffers = {
                hidden = true,
            }
        }

    })

    local builtin = require('telescope.builtin')
    vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = "#d08770" })
    vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = "#d08770" })
    vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { fg = "#5e81ac" })
    vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { fg = "#5e81ac" })
    vim.api.nvim_set_hl(0, "TelescopeTitle", { fg = "#eceff4", bold = true })
    vim.api.nvim_set_hl(0, "TelescopeResultsIdentifier", { fg = "#88c0d0", bold = true })
    vim.api.nvim_set_hl(0, "TelescopeResultsComment", { fg = "#81a1c1" })


    vim.keymap.set('n', 'fff', builtin.find_files, {})
    vim.keymap.set('n', 'ffg', builtin.live_grep, {})
    vim.keymap.set('n', 'ffb', builtin.buffers, {})
    vim.keymap.set('n', 'ffh', builtin.help_tags, {})
end

return config
