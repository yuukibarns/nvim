vim.pack.add({
    { src = "https://github.com/m4xshen/autoclose.nvim" },
    { src = "https://github.com/kylechui/nvim-surround" },
    { src = "https://github.com/MagicDuck/grug-far.nvim" },
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

require("nvim-surround").setup({
    move_cursor = "sticky",
})

require('grug-far').setup({
    windowCreationCommand = 'tabnew',
    startInInsertMode = false,

    openTargetWindow = {
        preferredLocation = 'left',
        useScratchBuffer = true,
    },
})
