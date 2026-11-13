vim.pack.add({
    { src = "https://github.com/m4xshen/autoclose.nvim" },
})

require("autoclose").setup({
    keys = {
        ["'"] = { escape = true, close = true, pair = "''" },
        ["`"] = { escape = true, close = true, pair = "``" },
        ['"'] = { escape = true, close = true, pair = '""' },
        ["("] = { escape = false, close = true, pair = "()" },
        ["["] = { escape = false, close = true, pair = "[]" },
        ["{"] = { escape = false, close = true, pair = "{}" },
    },
    options = {
        disable_when_touch = true,
        disable_command_mode = true,
        pair_spaces = true,
        auto_indent = true,
        disabled_filetypes = { "tex", "markdown", "rmd" },
    },
})
