local config = function()
    local cmp = require("cmp")
    local null_ls = require("null-ls")
    require("mason").setup()
    vim.opt.pumblend = 0
    vim.opt.winblend = 0
    cmp.setup({
        snippet = {
            -- REQUIRED - you must specify a snippet engine
        },
        window = {
            completion = cmp.config.window.bordered({
                winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
                border = "rounded",
                col_offset = -3,
                side_padding = 0,
            }),
            documentation = cmp.config.window.bordered({
                winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
                border = "rounded",
            }),
        },
        mapping = cmp.mapping.preset.insert({
            ["<C-b>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),
            ["<C-e>"] = cmp.mapping.abort(),
            ["<CR>"] = cmp.mapping.confirm({ select = false }),
            ["<Tab>"] = cmp.mapping.select_next_item(),
            ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "vsnip" },
        }, {
            { name = "buffer" },
        }),
    })

    -- Apply shared capabilities (from cmp) to all servers
    vim.lsp.config("*", {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
    })

    -- Per-server config for lua_ls (replaces the old lspconfig.lua_ls.setup)
    vim.lsp.config("lua_ls", {
        settings = {
            Lua = {
                runtime = {
                    version = "LuaJIT",
                    path = vim.split(package.path, ";"),
                },
                diagnostics = {
                    globals = { "vim" },
                    disable = { "undefined-global", "lowercase-global" },
                },
                workspace = {
                    library = vim.api.nvim_get_runtime_file("", true),
                    checkThirdParty = false,
                    preloadFileSize = 10000,
                },
                telemetry = {
                    enable = false,
                },
                completion = {
                    callSnippet = "Replace",
                },
            },
        },
    })

    require("mason-lspconfig").setup({
        ensure_installed = {
            "pyright", "clangd", "lua_ls", "rust_analyzer",
            "texlab", "html", "ts_ls", "jsonls",
        },
        automatic_enable = true, -- Auto-enable installed servers via vim.lsp.enable()
    })

    require("mason-null-ls").setup({
        ensure_installed = { "black", "prettier", "rustfmt", "hadolint" },
        automatic_installation = true,
    })

    null_ls.setup({
        sources = {
            null_ls.builtins.formatting.black,
            null_ls.builtins.formatting.prettier.with({
                filetypes = {
                    "html", "htmldjango", "json", "yaml",
                    "markdown", "css", "javascript", "typescript",
                },
            }),
        },
    })

    vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(_)
            vim.keymap.set("n", "gh", "<cmd>lua vim.lsp.buf.hover()<CR>")
            vim.keymap.set("n", "gf", "<cmd>lua vim.lsp.buf.format { async = true }<CR>")
            vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>")
            vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
            vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>")
            vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")
            vim.keymap.set("n", "gt", "<cmd>lua vim.lsp.buf.type_definition()<CR>")
            vim.keymap.set("n", "gn", "<cmd>lua vim.lsp.buf.rename()<CR>")
            vim.keymap.set("n", "ga", "<cmd>lua vim.lsp.buf.code_action()<CR>")
            vim.keymap.set("n", "ge", "<cmd>lua vim.diagnostic.open_float()<CR>")
            vim.keymap.set("n", "g]", "<cmd>lua vim.diagnostic.goto_next()<CR>")
            vim.keymap.set("n", "g[", "<cmd>lua vim.diagnostic.goto_prev()<CR>")
        end,
    })

    vim.diagnostic.config({
        virtual_text = {
            format = function(diagnostic)
                return string.format("%s (%s: %s)", diagnostic.message, diagnostic.source, diagnostic.code)
            end,
        },
        virtual_lines = true,
    })
end
return config
