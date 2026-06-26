vim.pack.add({
    { src = "https://codeberg.org/mfussenegger/nvim-dap" },
    { src = "https://github.com/igorlfs/nvim-dap-view",  version = vim.version.range("1.*") },
})

local dap = require('dap')


vim.api.nvim_create_autocmd("FileType", {
    pattern = { "python" },
    callback = function(ev)
        vim.keymap.set('n', '<Leader>ec', "<cmd>DapContinue<cr>", { buf = ev.buf })
        vim.keymap.set('n', '<Leader>en', "<cmd>DapNew<cr>", { buf = ev.buf })
        vim.keymap.set('n', '<Leader>et', "<cmd>DapTerminate<cr>", { buf = ev.buf })
        vim.keymap.set('n', '<Leader>eb', "<cmd>DapToggleBreakpoint<cr>", { buf = ev.buf })
        vim.keymap.set('n', '<Leader>eB', "<cmd>DapClearBreakpoints<cr>", { buf = ev.buf })
        vim.keymap.set('n', '<Leader>ev', "<cmd>DapViewToggle<cr>", { buf = ev.buf })
        vim.keymap.set('n', '<Leader>ew', "<cmd>DapViewWatch<cr>", { buf = ev.buf })
    end,
})

-- Table to store buffer-local keymaps to restore later
local keymap_restore = {}

dap.listeners.after.event_initialized['dap_arrow_keymaps'] = function()
    -- 0 represents the current active buffer when the debug session starts
    local buf = 0

    local arrow_keys = {
        { key = '<Down>',  fn = dap.step_over,     desc = 'DAP Step Over' },
        { key = '<Right>', fn = dap.step_into,     desc = 'DAP Step Into' },
        { key = '<Left>',  fn = dap.step_out,      desc = 'DAP Step Out' },
        { key = '<Up>',    fn = dap.restart_frame, desc = 'DAP Restart Frame' },
    }

    -- Fetch existing buffer-local keymaps for the current buffer
    local current_maps = vim.api.nvim_buf_get_keymap(buf, 'n')

    for _, map_info in ipairs(arrow_keys) do
        local existing = nil
        for _, map in ipairs(current_maps) do
            if map.lhs == map_info.key then
                existing = map
                break
            end
        end

        -- Save the buffer identifier along with the mapping info
        table.insert(keymap_restore, { buf = buf, key = map_info.key, existing = existing })

        -- Set the temporary mapping only on this specific buffer
        vim.keymap.set('n', map_info.key, map_info.fn, { buffer = buf, desc = map_info.desc })
    end
end

local function restore_keymaps()
    for _, map in ipairs(keymap_restore) do
        -- Ensure the buffer is still valid/loaded before trying to modify it
        if vim.api.nvim_buf_is_valid(map.buf) then
            if map.existing then
                local opts = {
                    buffer = map.buf,
                    silent = map.existing.silent == 1,
                    noremap = map.existing.noremap == 1,
                    expr = map.existing.expr == 1,
                    desc = map.existing.desc,
                }
                if map.existing.callback then
                    vim.keymap.set('n', map.key, map.existing.callback, opts)
                else
                    vim.keymap.set('n', map.key, map.existing.rhs or map.existing.lhs, opts)
                end
            else
                -- Remove the buffer-local mapping to fall back to global/default behavior
                pcall(vim.keymap.del, 'n', map.key, { buffer = map.buf })
            end
        end
    end
    keymap_restore = {}
end

dap.listeners.before.event_terminated['dap_arrow_keymaps'] = restore_keymaps
dap.listeners.before.event_exited['dap_arrow_keymaps'] = restore_keymaps

dap.adapters.python = function(cb, config)
    if config.request == 'attach' then
        ---@diagnostic disable-next-line: undefined-field
        local port = (config.connect or config).port
        ---@diagnostic disable-next-line: undefined-field
        local host = (config.connect or config).host or '127.0.0.1'
        cb({
            type = 'server',
            port = assert(port, '`connect.port` is required for a python `attach` configuration'),
            host = host,
            options = {
                source_filetype = 'python',
            },
        })
    else
        cb({
            type = 'executable',
            command = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python",
            args = { '-m', 'debugpy.adapter' },
            options = {
                source_filetype = 'python',
            },
        })
    end
end

dap.configurations.python = {
    {
        -- The first three options are required by nvim-dap
        type = 'python', -- the type here established the link to the adapter definition: `dap.adapters.python`
        request = 'launch',
        name = "Launch file",

        -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options

        program = "${file}", -- This configuration will launch the current file if used.
        pythonPath = function()
            -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
            -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
            -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
            local cwd = vim.fn.getcwd()
            if vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
                return cwd .. '/venv/bin/python'
            elseif vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
                return cwd .. '/.venv/bin/python'
            else
                return '/usr/bin/python'
            end
        end,
    },
}
