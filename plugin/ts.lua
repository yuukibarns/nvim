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
