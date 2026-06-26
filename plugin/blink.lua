vim.pack.add({
    {
        src = "https://github.com/Saghen/blink.cmp",
        version = vim.version.range("1.*")
    },
    { src = "https://github.com/yuukibarns/blink-cmp-bm.nvim" },
    { src = "https://github.com/yuukibarns/blink-cmp-dictionary" },
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
            if vim.tbl_contains({ "markdown", "tex", "rmd", "quarto" }, vim.bo.filetype) then
                if require("mySnippets.tex").in_math() then
                    return { "lsp", "snippets" }
                elseif require("mySnippets.tex").in_code() then
                    return { "lsp", "path", "buffer" }
                else
                    return { "lsp", "path", "buffer", "snippets", "dictionary" }
                end
            end
            return { "lsp", "path", "buffer" }
        end,

        providers = {
            lsp = {
                fallbacks = {},
            },
            dictionary = {
                module = "blink-cmp-dictionary",
                score_offset = -3,
                min_keyword_length = 2,
                name = "Dict",
                opts = {
                    dictionary_files = {
                        vim.fn.stdpath("config") .. "/spell/en.utf-8.add",
                    },
                },
            },
            bookmark = {
                module = "blink-cmp-bm",
                name = "Bookmark",
                score_offset = -3,
                opts = {
                    prefix_min_len = 3,
                },
            },
        },
    },
})
