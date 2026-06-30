local tex = require("mySnippets.tex")

local function align_o()
    if not tex.in_align() then
        return "o"
    end

    local cursor = vim.api.nvim_win_get_cursor(0)
    local row = cursor[1] - 1 -- Convert to 0-based index
    local line = vim.api.nvim_buf_get_lines(0, row, row + 1, true)[1]
    local indent = string.match(line, "^%s*")

    -- Exit Insert mode first
    local escape = vim.api.nvim_replace_termcodes('<Esc>', true, true, true)
    vim.api.nvim_feedkeys(escape, 'n', true)

    -- Schedule buffer modifications after exiting Insert mode
    vim.schedule(function()
        local new_line = indent .. ' \\\\'

        -- Insert the new line below the current line
        vim.api.nvim_buf_set_lines(0, row + 1, row + 1, true, { new_line })

        -- Move cursor to the new line and position after '&'
        vim.api.nvim_win_set_cursor(0, { row + 2, #indent })
        vim.api.nvim_feedkeys('i', 'n', false) -- Enter Insert mode after '&'
    end)

    return ""
end

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "tex", "markdown", "rmd", "quarto" },
    callback = function()
        if vim.bo.buftype ~= "nofile" then
            vim.opt_local.conceallevel = 2
            vim.opt_local.spell = true
            vim.opt_local.spelllang = "en_us,cjk"
            vim.opt_local.spellfile = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"
            vim.opt_local.spellsuggest = "best,5"
            vim.opt_local.colorcolumn = "80"

            -- Inserts a new line with proper alignment characters when in align environment
            vim.keymap.set('n', 'o', align_o, { expr = true, buffer = 0 })
            vim.keymap.set("n", "<C-j>", "[s1z=", { buf = 0 })
        else
            vim.opt_local.concealcursor = "nc"
        end
    end,
})
