local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Check if we need to reload the file when it changed
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = augroup("CheckTime", {}),
    callback = function()
        if vim.o.buftype ~= "nofile" then
            vim.cmd("checktime")
        end
    end,
})

-- Highlight yanked text
autocmd("TextYankPost", {
    group = augroup("HighlightYank", {}),
    callback = function()
        vim.highlight.on_yank()
    end,
    desc = "Highlight the Yanked Text",
})

-- go to last loc when opening a buffer
autocmd("BufReadPost", {
    group = augroup("LastPlace", {}),
    callback = function(event)
        local exclude_bt = { "help", "nofile", "quickfix" }
        local exclude_ft = { "gitcommit" }
        local buf = event.buf

        if not vim.api.nvim_buf_is_valid(buf) then return end

        if
            vim.list_contains(exclude_bt, vim.bo[buf].buftype)
            or vim.list_contains(exclude_ft, vim.bo[buf].filetype)
            or vim.api.nvim_win_get_cursor(0)[1] > 1
            or vim.b[buf].last_pos
        then
            return
        end
        vim.b[buf].last_pos = true
        local mark = vim.api.nvim_buf_get_mark(buf, '"')
        local lcount = vim.api.nvim_buf_line_count(buf)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
    desc = "Last Position",
})

-- automatically regenerate spell file after editing dictionary
autocmd("BufWritePost", {
    pattern = "*/spell/*.add",
    callback = function()
        vim.cmd.mkspell({ "%", bang = true, mods = { silent = true } })
    end,
})
