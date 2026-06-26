vim.keymap.set("n", "<leader>rp", function()
    vim.cmd([[s/\k\+\$//ge]])
    vim.cmd("nohlsearch")
end, { desc = "Remove df$ prefix from current line" })

vim.keymap.set("x", "<leader>rp", function()
    local a = vim.fn.getpos("v")[2]
    local b = vim.fn.getpos(".")[2]
    local first = math.min(a, b)
    local last = math.max(a, b)

    vim.cmd(("%d,%ds/\\k\\+\\$//ge"):format(first, last))
    vim.cmd([[nohlsearch]])
    vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
        "n",
        false
    )
end, { desc = "Remove df$ prefix from selection" })

vim.bo.shiftwidth = 2
