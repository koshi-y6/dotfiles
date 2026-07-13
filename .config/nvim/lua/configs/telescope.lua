local config = function()
    local telescope = require('telescope')
    local actions = require('telescope.actions')
    local builtin = require('telescope.builtin')

    local exchange_url_filter = ""

    local function build_exchange_url_glob(filter_text)
        if filter_text == "" then
            return nil
        end

        if filter_text:find("[%*%?%[]") then
            return filter_text
        end

        return string.format("*%s*", filter_text)
    end

    local function open_exchange_url_picker()
        local filter_glob = build_exchange_url_glob(exchange_url_filter)

        builtin.find_files({
            prompt_title = string.format("exchange url files [%s]", exchange_url_filter),
            find_command = filter_glob
                    and {
                        "rg",
                        "--files",
                        "-g",
                        filter_glob,
                    }
                or {
                    "rg",
                    "--files",
                },
            attach_mappings = function(prompt_bufnr, map)
                local function reopen_picker()
                    vim.schedule(open_exchange_url_picker)
                end

                local function edit_filter()
                    actions.close(prompt_bufnr)
                    vim.schedule(function()
                        vim.ui.input({
                            prompt = "Exchange URL filter: ",
                            default = exchange_url_filter,
                        }, function(input)
                            if input and input ~= "" then
                                exchange_url_filter = input
                            end
                            reopen_picker()
                        end)
                    end)
                end

                local function reset_filter()
                    exchange_url_filter = ""
                    actions.close(prompt_bufnr)
                    reopen_picker()
                end

                map('i', '<C-e>', edit_filter)
                map('n', '<C-e>', edit_filter)
                map('i', '<C-r>', reset_filter)
                map('n', '<C-r>', reset_filter)

                return true
            end,
        })
    end

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
    vim.keymap.set('n', 'ffx', open_exchange_url_picker, { desc = 'Find exchange url files' })
    vim.api.nvim_create_user_command('TelescopeExchangeUrlFiles', open_exchange_url_picker, {})
end

return config
