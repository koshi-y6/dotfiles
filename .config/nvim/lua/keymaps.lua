-- key mapping
vim.api.nvim_set_keymap('i', 'jj', '<Esc>', { noremap = true, silent = true })
vim.keymap.set('n', 'J', '3j', { noremap = true })
vim.keymap.set('n', 'K', '3k', { noremap = true })
-- Move the cursor in insert mode with Ctrl+hjkl, similar to normal mode
vim.api.nvim_set_keymap('i', '<C-l>', '<Right>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-h>', '<Left>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-j>', '<Down>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-k>', '<Up>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-n>', '<C-w>w', { noremap = true, silent = true })

-- Move to the end of the line in normal mode with Shift+l
-- vim.api.nvim_set_keymap('n', '<S-h>', '^', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<S-h>', '^', { noremap = true, silent = true })
-- Move to the end of the line in normal mode with Shift+l
-- Move to the end of the line in normal mode with Shift+l
-- vim.api.nvim_set_keymap('n', '<S-l>', '$', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<S-h>', '^', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<S-h>', '^', { noremap = true, silent = true })

-- Window resize with Option+hjkl (Mac) - Fixed directions
local resize_step = 2
vim.keymap.set('n', '<A-h>', ':vertical resize +' .. resize_step .. '<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<A-l>', ':vertical resize -' .. resize_step .. '<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<A-k>', ':resize -' .. resize_step .. '<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<A-j>', ':resize +' .. resize_step .. '<CR>', { noremap = true, silent = true })
