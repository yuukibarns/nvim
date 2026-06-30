vim.pack.add({
    { src = "https://github.com/MunifTanjim/nui.nvim" },
    { src = "https://github.com/esmuellert/codediff.nvim" },
    { src = "https://github.com/lewis6991/gitsigns.nvim" },
    -- { src = "https://github.com/neogitorg/neogit" }
})

require("codediff").setup({
    diff = {
        layout = "inline",
    },
    explorer = {
        position = "left",
        width = 30,
    },
    history = {
        height = 10,
    },
    keymaps = {
        view = {
            toggle_explorer = "<leader>e",
            focus_explorer = false,
            -- Built-in discard_hunk have :checktime issue
            discard_hunk = false,
        },
    },
})

-- vim.keymap.set("n", "<leader>gg", "<cmd>Neogit<CR>", { desc = "Show Neogit UI" })

vim.keymap.set("n", "<leader>dd", "<cmd>CodeDiff<CR>", { desc = "Show git status in explorer", })
vim.keymap.set("n", "<leader>dh", "<cmd>CodeDiff history<CR>", { desc = "Show history commits", })

require("gitsigns").setup({
    preview_config = { border = "rounded" },
    signcolumn = false,
    numhl = true,
})

vim.keymap.set("n", "]h", "<cmd>Gitsigns next_hunk<CR>", { desc = "Next Hunk", })
vim.keymap.set("n", "[h", "<cmd>Gitsigns prev_hunk<CR>", { desc = "Prev Hunk", })
vim.keymap.set("n", "<leader>hr", "<cmd>Gitsigns reset_hunk<CR>", { desc = "Hunk Reset", })
vim.keymap.set("n", "<leader>hp", "<cmd>Gitsigns preview_hunk<CR>", { desc = "Hunk Preview", })
vim.keymap.set({ 'o', 'x' }, 'ih', '<cmd>Gitsigns select_hunk<CR>')
