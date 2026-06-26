-- DISABLE REMOTE PLUGINS
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0

-- MAPLEADER
vim.g.mapleader = " "

-- PLAINTEX NEVER
vim.g.tex_flavor = "latex"

-- ENV
vim.pack.add({
    { src = "https://github.com/yuukibarns/mySnippets" }
})

-- vim.opt.rtp:append(vim.fn.expand("~/mySnippets"))
-- LOCAL PLUGINS
-- vim.opt.rtp:append(vim.fn.expand("~/R.nvim"))
-- vim.opt.rtp:append(vim.fn.expand("~/gp.nvim/"))
-- Node
vim.env.PATH = vim.fn.expand("~/.nvm/versions/node/v22.12.0/bin/") .. ":" .. vim.env.PATH
-- Python
-- vim.env.PATH = vim.fn.expand("~/.virtualenvs/neovim/bin/") .. ":" .. vim.env.PATH
-- vim.env.PATH = vim.fn.expand("~/tex2png/") .. ":" .. vim.env.PATH
-- vim.env.PATH = vim.fn.expand("~/.local/share/r-pandoc/3.9.0.2/") .. ":" .. vim.env.PATH

-- UI2
require("vim._core.ui2").enable({
    enable = true, -- Whether to enable or disable the UI.
    msg = {        -- Options related to the message module.
        ---@type 'cmd'|'msg' Default message target, either in the
        ---cmdline or in a separate ephemeral message window.
        ---@type string|table<string, 'cmd'|'msg'|'pager'> Default message target
        ---or table mapping |ui-messages| kinds and triggers to a target.
        targets = "cmd",
        cmd = {             -- Options related to messages in the cmdline window.
            height = 0.5,   -- Maximum height while expanded for messages beyond 'cmdheight'.
        },
        dialog = {          -- Options related to dialog window.
            height = 0.5,   -- Maximum height.
        },
        msg = {             -- Options related to msg window.
            height = 0.5,   -- Maximum height.
            timeout = 4000, -- Time a message is visible in the message window.
        },
        pager = {           -- Options related to message window.
            height = 1,     -- Maximum height.
        },
    },
})

-- BASICS

vim.pack.add({
    {
        src = "https://github.com/L3MON4D3/LuaSnip",
        version = vim.version.range("2.*"),
    },
    { src = "https://github.com/echasnovski/mini.icons" },
})

require("mini.icons").setup({
    lsp = {
        ["function"] = { glyph = "" },
        object = { glyph = "" },
        value = { glyph = "" },
    },
})

local ls = require("luasnip")
local types = require("luasnip.util.types")

ls.setup({
    update_events = "TextChanged,TextChangedI",
    delete_check_events = "TextChanged",
    ext_opts = {
        [types.insertNode] = {
            active = { virt_text = { { "●", "Boolean" } } },
            unvisited = {
                virt_text = { { "|", "Comment" } },
                virt_text_pos = "inline",
            },
        },
        [types.choiceNode] = {
            active = { virt_text = { { "○", "Special" } } },
        },
        [types.exitNode] = {
            unvisited = {
                virt_text = { { "|", "Comment" } },
                virt_text_pos = "inline",
            },
        },
    },
    enable_autosnippets = true,
})

require("luasnip.loaders.from_lua").lazy_load({
    paths = { vim.fn.expand("~/mySnippets") .. "/snippets" },
})

ls.filetype_extend("markdown", { "math" })
ls.filetype_extend("tex", { "math" })

local tex = require("mySnippets.tex")
local env_names = {
    ["inline math"] = true,
    ["display math"] = true,
    ["text (math)"] = true,
    aligned = true,
}

vim.api.nvim_create_autocmd({ "InsertEnter" }, {
    pattern = { "*.tex", "*.md", "*.Rmd", "*.qmd" },
    callback = function(args)
        tex.schedule_update(args.buf, 50)
    end,
})

vim.api.nvim_create_autocmd("User", {
    pattern = "LuasnipInsertNodeEnter",
    callback = function()
        if vim.tbl_contains({ "markdown", "tex", "rmd", "quarto" }, vim.bo.filetype) then
            tex.schedule_update(vim.api.nvim_get_current_buf(), 50)
        end
    end,
})

vim.api.nvim_create_autocmd("User", {
    pattern = "LuasnipInsertNodeLeave",
    callback = function()
        if vim.tbl_contains({ "markdown", "tex", "rmd", "quarto" }, vim.bo.filetype) then
            tex.schedule_update(vim.api.nvim_get_current_buf(), 50)
        end
    end,
})

vim.api.nvim_create_autocmd("User", {
    pattern = "LuasnipPreExpand",
    callback = function()
        if vim.tbl_contains({ "markdown", "tex", "rmd", "quarto" }, vim.bo.filetype) then
            local snippet = require("luasnip").session.event_node
            local name = snippet.name

            if env_names[name] then
                tex.schedule_update(vim.api.nvim_get_current_buf(), 50)
            end
        end
    end,
})
