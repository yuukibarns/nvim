vim.pack.add({
    { src = "https://github.com/ibhagwan/fzf-lua" },
    { src = "https://github.com/echasnovski/mini.icons" },
    { src = "https://github.com/stevearc/oil.nvim" },
})

require("mini.icons").setup({
    lsp = {
        ["function"] = { glyph = "" },
        object = { glyph = "" },
        value = { glyph = "" },
    },
})

require("oil").setup()

vim.keymap.set("n", "-", "<Cmd>Oil<CR>", { desc = "Open parent directory" })
