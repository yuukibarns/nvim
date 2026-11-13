vim.pack.add({
    {
        src = "https://github.com/Saghen/blink.cmp",
        version = vim.version.range("1.*")
    },
    { src = "https://github.com/nvim-lua/plenary.nvim" },
})

require("blink.cmp").setup({
    -- snippets = { preset = "luasnip" },

    keymap = {
        preset = "default",
        ["<Tab>"] = { "snippet_forward", "accept", "fallback" },
        ["<Enter>"] = { "accept", "fallback" },
    },
    cmdline = {
        completion = {
            list = { selection = { preselect = false, auto_insert = true } },
            menu = { auto_show = true },
        },
    },

    sources = {
        default = function()
            return { "lsp", "path", "buffer" }
        end,

        providers = {
            lsp = {
                fallbacks = {},
            },
        },
    },
})
