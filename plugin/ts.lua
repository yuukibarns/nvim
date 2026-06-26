vim.api.nvim_create_autocmd('PackChanged', {
    callback = function(ev)
        local name, kind = ev.data.spec.name, ev.data.kind
        if name == 'nvim-treesitter' and kind == 'update' then
            if not ev.data.active then vim.cmd.packadd('nvim-treesitter') end
            vim.cmd('TSUpdate')
        end
    end
})

vim.pack.add({
    { src = "https://github.com/nvim-treesitter/nvim-treesitter",            version = "main" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter-context" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects" },
})

require('nvim-treesitter').install({
    'latex', 'html', 'bash', 'rust',
    "gitcommit", "gitignore",
    "ini", "git_config", "json", "cpp", "c", "kdl", "javascript",
    "r", "rnoweb", "yaml", "python"
})

vim.api.nvim_create_autocmd('FileType', {
    pattern = {
        'tex', 'html', 'bash', 'rust',
        "gitcommit", "gitignore",
        "ini", "git_config", "json", "cpp", "c", "kdl", "javascript",
        "r", "yaml", "rmd", "python", "quarto"
    },
    callback = function()
        vim.treesitter.start()
    end
})

vim.keymap.set("n", "<leader>th", function()
    vim.treesitter.start()
end, { desc = "Enable Treesitter Highlight" })

vim.keymap.set("n", "<leader>ts", function()
    vim.treesitter.stop()
end, { desc = "Disable Treesitter Highlight" })

vim.g.no_plugin_maps = true

require("treesitter-context").setup({
    multiwindow = true,
    max_lines = 4,
    mode = "topline",
    trim_scope = "outer",
})

require("nvim-treesitter-textobjects").setup({
    select = {
        lookahead = true,
        selection_modes = {
            ["@function.outer"] = "V",
            ["@class.outer"] = "V",
        },
        include_surrounding_whitespace = false,
    },
    move = {
        set_jumps = true,
    },
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "markdown", "rmd", "quarto" },
    callback = function()
        vim.keymap.set({ "x", "o" }, "ao", function()
            require("nvim-treesitter-textobjects.select").select_textobject("@codeblock.outer", "textobjects")
        end)
        vim.keymap.set({ "x", "o" }, "io", function()
            require("nvim-treesitter-textobjects.select").select_textobject("@codeblock.inner", "textobjects")
        end)
    end,
})

vim.keymap.set({ "x", "o" }, "am", function()
    require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
end)

vim.keymap.set({ "x", "o" }, "im", function()
    require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
end)

vim.keymap.set({ "x", "o" }, "ac", function()
    require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
end)

vim.keymap.set({ "x", "o" }, "ic", function()
    require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
end)

vim.keymap.set({ "n", "x", "o" }, "]m", function()
    require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
end)

vim.keymap.set({ "n", "x", "o" }, "]]", function()
    require("nvim-treesitter-textobjects.move").goto_next_start("@class.outer", "textobjects")
end)

vim.keymap.set({ "n", "x", "o" }, "]M", function()
    require("nvim-treesitter-textobjects.move").goto_next_end("@function.outer", "textobjects")
end)

vim.keymap.set({ "n", "x", "o" }, "][", function()
    require("nvim-treesitter-textobjects.move").goto_next_end("@class.outer", "textobjects")
end)

vim.keymap.set({ "n", "x", "o" }, "[m", function()
    require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
end)

vim.keymap.set({ "n", "x", "o" }, "[[", function()
    require("nvim-treesitter-textobjects.move").goto_previous_start("@class.outer", "textobjects")
end)

vim.keymap.set({ "n", "x", "o" }, "[M", function()
    require("nvim-treesitter-textobjects.move").goto_previous_end("@function.outer", "textobjects")
end)

vim.keymap.set({ "n", "x", "o" }, "[]", function()
    require("nvim-treesitter-textobjects.move").goto_previous_end("@class.outer", "textobjects")
end)
