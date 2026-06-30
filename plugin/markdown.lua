vim.api.nvim_create_autocmd('PackChanged', {
    callback = function(ev)
        local name, kind = ev.data.spec.name, ev.data.kind

        if name == 'markdown-preview.nvim' and (kind == 'install' or kind == 'update') then
            vim.notify("Building markdown-preview.nvim...")
            vim.system(
                { 'yarn', 'install' },
                { cwd = ev.data.path .. '/app' },
                function(obj)
                    if obj.code == 0 then
                        vim.notify("markdown-preview.nvim built successfully!")
                    else
                        vim.notify("markdown-preview.nvim build failed!", vim.log.levels.ERROR)
                    end
                end
            )
        end
    end,
})

vim.pack.add({
    { src = "https://github.com/iamcco/markdown-preview.nvim" },
})

-- markdown-preview.nvim globals
vim.g.mkdp_theme = "dark"
vim.g.mkdp_page_title = "${name}"
vim.g.mkdp_auto_close = 0

-- markdown-only keymap
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "markdown", "rmd" },
    callback = function(event)
        vim.keymap.set("n", "<leader>cp", "<cmd>MarkdownPreview<cr>", {
            buffer = event.buf,
            desc = "Markdown Preview",
        })
    end,
})
