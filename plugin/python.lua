-- Helper to check if the terminal buffer exists and its process is still running
local function is_terminal_alive(buf_id)
    if not buf_id or not vim.api.nvim_buf_is_valid(buf_id) then
        return false
    end
    -- In Neovim, vim.bo[buf_id].channel gets the channel associated with the terminal buffer.
    -- If the process exits, this channel becomes 0.
    local success, channel = pcall(function()
        return vim.bo[buf_id].channel
    end)
    return success and channel and channel > 0
end

-- Helper to scroll any windows displaying the terminal buffer to the very bottom.
-- This keeps the terminal in "follow" (autoscroll) mode.
local function scroll_to_bottom(buf_id)
    local win_ids = vim.fn.win_findbuf(buf_id)
    for _, win_id in ipairs(win_ids) do
        if vim.api.nvim_win_is_valid(win_id) then
            local line_count = vim.api.nvim_buf_line_count(buf_id)
            if line_count > 0 then
                -- Sets the cursor in that window to the last line, column 0
                pcall(vim.api.nvim_win_set_cursor, win_id, { line_count, 0 })
            end
        end
    end
end

-- Helper to make the terminal visible without stealing editor focus
local function show_terminal(buf_id)
    local win_ids = vim.fn.win_findbuf(buf_id)
    if #win_ids == 0 then
        -- Remember the window we are currently working in
        local current_win = vim.api.nvim_get_current_win()

        -- Open a new split and place the terminal buffer in it
        vim.cmd("new")
        vim.api.nvim_win_set_buf(0, buf_id)

        -- Scroll the newly opened terminal window to the bottom
        scroll_to_bottom(buf_id)

        -- Restore focus back to our original code window
        if vim.api.nvim_win_is_valid(current_win) then
            vim.api.nvim_set_current_win(current_win)
        end
    else
        -- If already visible, ensure it remains scrolled to the bottom
        scroll_to_bottom(buf_id)
    end
end

-- Helper to hide the terminal window(s)
local function hide_terminal(buf_id)
    local win_ids = vim.fn.win_findbuf(buf_id)
    for _, win_id in ipairs(win_ids) do
        if vim.api.nvim_win_is_valid(win_id) then
            vim.api.nvim_win_close(win_id, true)
        end
    end
end

-- Function to toggle the terminal window
local function toggle_terminal()
    local buf_id = vim.g.last_terminal_buf_id

    if is_terminal_alive(buf_id) then
        local win_ids = vim.fn.win_findbuf(buf_id)
        if #win_ids > 0 then
            hide_terminal(buf_id)
        else
            -- Open split and focus the terminal
            vim.cmd("new")
            vim.api.nvim_win_set_buf(0, buf_id)
            scroll_to_bottom(buf_id)
            vim.cmd("startinsert")
        end
    else
        -- If a dead terminal buffer is still hanging around, wipe it out
        if buf_id and vim.api.nvim_buf_is_valid(buf_id) then
            vim.api.nvim_buf_delete(buf_id, { force = true })
        end

        -- Determine the directory (fallback to current working directory if empty)
        local dir = vim.fn.expand('%:p:h')
        if dir == "" then
            dir = vim.fn.getcwd()
        end

        -- Create a fresh terminal session
        vim.cmd("new term://" .. dir .. "//fish")

        -- Enable local toggle hotkey inside the terminal buffer itself
        vim.keymap.set({ 'n', 't' }, '<C-`>', toggle_terminal, { buffer = true, desc = "Toggle terminal" })

        -- Store the buffer ID and the channel/job ID
        vim.g.last_terminal_buf_id = vim.api.nvim_get_current_buf()
        vim.g.last_terminal_job_id = vim.b.terminal_job_id

        vim.cmd("startinsert")
    end
end

-- Function to send text
local function send_to_term(srow, erow)
    local buf_id = vim.g.last_terminal_buf_id

    if not is_terminal_alive(buf_id) then
        vim.notify("No active terminal found! Open one with <C-`> first.", vim.log.levels.WARN)
        return
    end

    -- Check if the terminal is visible. If not, open it.
    show_terminal(buf_id)

    -- Handle backwards selection
    if srow > erow then
        srow, erow = erow, srow
    end

    -- nvim_buf_get_lines expects 0-indexed start row and end-exclusive row limits
    local lines = vim.api.nvim_buf_get_lines(0, srow - 1, erow, false)

    -- Join lines
    local text = table.concat(lines, "\n") .. "\n"

    local bracketed_text = "\x1b[200~" .. text .. "\x1b[201~" .. "\r"

    vim.api.nvim_chan_send(vim.g.last_terminal_job_id, bracketed_text)

    -- Defer slightly to allow the terminal process to receive/print the text,
    -- then force the terminal window(s) to scroll to the very bottom.
    vim.defer_fn(function()
        scroll_to_bottom(buf_id)
    end, 50)
end

-- Create an autocommand to bind keymaps *only* for Python and Markdown buffers
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "python" },
    callback = function(ev)
        -- Toggle terminal keymap in normal mode (buffer-local)
        vim.keymap.set('n', '<C-`>', toggle_terminal, { buffer = ev.buf, desc = "Toggle terminal" })

        -- Send current line in Normal mode (buffer-local)
        vim.keymap.set('n', '<C-Enter>', function()
            local row = vim.fn.line(".")
            send_to_term(row, row)
        end, { buffer = ev.buf, desc = "Send current line to terminal" })

        -- Send selection in Visual mode (buffer-local)
        vim.keymap.set('v', '<C-Enter>', function()
            -- Get selection bounds (1-indexed)
            local _, srow, _, _ = unpack(vim.fn.getpos("v"))
            local _, erow, _, _ = unpack(vim.fn.getpos("."))

            send_to_term(srow, erow)
            vim.cmd("normal! \x1b")
        end, { buffer = ev.buf, desc = "Send selection to terminal" })
    end,
})
