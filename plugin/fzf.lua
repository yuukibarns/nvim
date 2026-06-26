vim.pack.add({
    { src = "https://github.com/ibhagwan/fzf-lua" },
})

require("fzf-lua").setup({
    previewers = {
        builtin = {
            snacks_image = { enabled = false, render_inline = false },
        },
    },
    winopts = {
        height = 0.95,
        width = 0.90,
        preview = {
            vertical = "down:60%",
            flip_columns = 120,
            scrollbar = false,
            winopts = {
                conceallevel = 2,
            },
        },
    },
    keymap = {
        fzf = {
            ["tab"] = "down",
            ["shift-tab"] = "up",
        }
    }
})

vim.keymap.set("n", "<leader>ff", function()
    require("fzf-lua").files({
        cwd = vim.fs.root(0, ".git"),
    })
end, {
    desc = "Find Files (Git)",
})

vim.keymap.set("n", "<leader>fg", function()
    require("fzf-lua").live_grep({
        cwd = vim.fs.root(0, ".git"),
    })
end, {
    desc = "Live Grep (Git)",
})

vim.keymap.set("n", "<leader>fb", "<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>", { desc = "Switch Buffer", })
vim.keymap.set("n", "<leader>fr", "<cmd>FzfLua resume<cr>", { desc = "Fzf Resume", })
vim.keymap.set("n", "<leader>fo", "<cmd>FzfLua oldfiles include_current_session=true<cr>", { desc = "Fzf Oldfiles", })
vim.keymap.set("n", "<leader>fl", "<cmd>FzfLua lines<cr>", { desc = "Lines", })
vim.keymap.set("n", "<leader>fm", "<cmd>FzfLua manpages<cr>", { desc = "Manpage", })
vim.keymap.set("n", "grr", "<cmd>FzfLua lsp_references jump1=true ignore_current_line=true<cr>", { desc = "References", })
vim.keymap.set("n", "gri", "<cmd>FzfLua lsp_implementations jump1=true ignore_current_line=true<cr>",
    { desc = "Goto Implementation", })
