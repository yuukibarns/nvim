vim.pack.add({
    { src = "https://github.com/ibhagwan/fzf-lua" },
    { src = "https://github.com/echasnovski/mini.icons" },
    { src = "https://github.com/stevearc/oil.nvim" },
    { src = "https://github.com/JezerM/oil-lsp-diagnostics.nvim" }
})

local oil = require("oil")
local detail = false

oil.setup({
    default_file_explorer = true,
    delete_to_trash = true,
    skip_confirm_for_simple_edits = true,
    watch_for_changes = true,
    keymaps = {
        ["g?"] = { "actions.show_help", mode = "n" },
        ["<CR>"] = "actions.select",
        ["<C-s>"] = false,
        ["<C-h>"] = false,
        ["<C-t>"] = { "actions.select", opts = { tab = true, close = true } },
        ["<C-p>"] = false,
        ["<C-c>"] = { "actions.close", mode = "n" },
        ["<C-l>"] = "actions.refresh",
        ["-"] = { "actions.parent", mode = "n" },
        ["_"] = { "actions.open_cwd", mode = "n" },
        ["`"] = { "actions.cd", mode = "n" },
        ["g~"] = false,
        ["gs"] = { "actions.change_sort", mode = "n" },
        ["gx"] = "actions.open_external",
        ["g."] = { "actions.toggle_hidden", mode = "n" },
        ["g\\"] = { "actions.toggle_trash", mode = "n" },
        ["gd"] = {
            callback = function()
                detail = not detail
                if detail then
                    oil.set_columns({ "icon", "permissions", "size", "mtime" })
                else
                    oil.set_columns({ "icon" })
                end
            end,
            mode = "n",
            desc = "Toggle file detail view",
        },
        ["<leader>tm"] = {
            callback = function()
                local cwd = oil.get_current_dir(0)
                vim.cmd("new term://" .. cwd .. "/fish")
            end,
            mode = "n",
            desc = "Open Terminal Below (half height)"
        },
        ["<leader>q"] = {
            callback = function()
                local cwd = oil.get_current_dir(0)
                vim.cmd("edit term://" .. cwd .. "/fish")
            end,
            mode = "n",
            desc = "Open Terminal (parent directory)"
        },
        ["<leader>Q"] = {
            callback = function()
                local cwd = oil.get_current_dir(0)
                vim.cmd("tabedit term://" .. cwd .. "/fish")
            end,
            mode = "n",
            desc = "Open Terminal (parent directory)"
        },
        ["Y"] = {
            callback = function()
                local cwd = oil.get_current_dir(0)
                local entry = oil.get_cursor_entry()

                if not (cwd and entry) then return end

                local full_path = vim.fn.expand(cwd) .. entry.parsed_name

                vim.system({ "sh", "-c", "wl-copy < " .. vim.fn.shellescape(full_path) })

                vim.notify("Entry copied: " .. entry.parsed_name)
            end,
            mode = "n",
            desc = "Copy the entry to clipboard"
        },
        ["<leader>ff"] = {
            callback = function()
                require("fzf-lua").files({
                    cwd = oil.get_current_dir()
                })
            end,
            mode = "n",
            nowait = true,
            desc = "Find files in the current directory"
        },
        ["<leader>fg"] = {
            callback = function()
                require("fzf-lua").live_grep({
                    cwd = oil.get_current_dir()
                })
            end,
            mode = "n",
            nowait = true,
            desc = "Live grep in the current directory"
        },
    },
})

vim.keymap.set("n", "-", "<Cmd>Oil<CR>", { desc = "Open parent directory" })

require("oil-lsp-diagnostics").setup()
