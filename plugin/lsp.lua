vim.pack.add({
    { src = "https://github.com/williamboman/mason.nvim" },
    { src = "https://github.com/neovim/nvim-lspconfig" },
    { src = "https://github.com/stevearc/conform.nvim" },
})

require("mason").setup({
    ui = {
        border = "rounded",
        height = 0.8,
    },
})

vim.lsp.enable({ "lua_ls", "ty" })
vim.diagnostic.config({ virtual_text = true })

require("conform").setup({
    formatters_by_ft = {
        rust = { "rustfmt" },
        bib = { "bibtex-tidy" },
        markdown = { "deno_fmt" },
        html = { "deno_fmt" },
        javascript = { "deno_fmt" },
        typescript = { "deno_fmt" },
        typescriptreact = { "deno_fmt" },
        json = { "deno_fmt" },
        jsonc = { "deno_fmt" },
        yaml = { "deno_fmt" },
        ipynb = { "deno_fmt" },
        -- lua = { "stylua" },
        tex = { "tex-fmt" },
        python = { "ruff_format" },
        cpp = { "clang-format" },
        c = { "clang-format" },
    },
})

vim.keymap.set("n", "<leader>bf", function()
    require("conform").format({
        async = true,
        timeout_ms = 5000,
        lsp_fallback = true,
    })
end, { desc = "Format buffer" })

vim.keymap.set("v", "<leader>bf", function()
    require("conform").format({ async = true }, function(err)
        if not err then
            local mode = vim.api.nvim_get_mode().mode
            if vim.startswith(string.lower(mode), "v") then
                vim.api.nvim_feedkeys(
                    vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
                    "n",
                    true
                )
            end
        end
    end)
end, {
    desc = "Range Format",
    silent = true,
})
