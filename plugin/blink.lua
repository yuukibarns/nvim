vim.pack.add({
    {
        src = "https://github.com/Saghen/blink.cmp",
        version = vim.version.range("1.*")
    },
    { src = "https://github.com/nvim-lua/plenary.nvim" },
})

require("blink.cmp").setup({
    snippets = { preset = "luasnip" },

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
            if vim.tbl_contains({ "markdown", "tex" }, vim.bo.filetype) then
                if require("mySnippets.tex").in_math() then
                    return { "lsp", "snippets" }
                elseif require("mySnippets.tex").in_code() then
                    return { "lsp", "path", "buffer" }
                else
                    return { "lsp", "path", "buffer", "snippets" }
                end
            end
            return { "lsp", "path", "buffer" }
        end,

        providers = {
            lsp = {
                fallbacks = {},
            },
        },
    },
})
