local highlights = {
    Conceal = { link = "@function" },
    ["@none.latex"] = { link = "Normal" },
    ["@markup.math.latex"] = { link = "Identifier" },
    TreesitterContext = { link = "Normal" },
    TreesitterContextBottom = { undercurl = true, sp = "NvimLightCyan" },

    SpellBad = { undercurl = true, sp = "NvimLightRed" },
    SpellRare = { undercurl = true, sp = "NvimLightCyan" },
    SpellCap = { undercurl = true, sp = "NvimLightYellow" },
    SpellLocal = { undercurl = true, sp = "NvimLightGreen" },

    EndOfBuffer = { update = true, bg = "NONE" },

    -- BlinkCmpMenu = { bg = "Black" },
    -- BlinkCmpMenuBorder = { fg = "Grey40" },
    -- BlinkCmpMenuSelection = { link = "PmenuSel", bold = true },
    -- BlinkCmpScrollBarThumb = { bg = "Grey50" },
    -- BlinkCmpScrollBarGutter = { bg = "Grey20" },
    -- BlinkCmpLabel = { fg = "White" },
    BlinkCmpLabelDeprecated = { strikethrough = true },
    BlinkCmpLabelMatch = { link = "PmenuMatch" },
    BlinkCmpLabelDetail = { link = "Comment" },
    BlinkCmpLabelDescription = { link = "Comment" },
    BlinkCmpSource = { link = "Comment" },
    BlinkCmpMenu = { link = "Pmenu" },
    BlinkCmpMenuBorder = { link = "PmenuBorder" },
    -- BlinkCmpGhostText = { fg = "Grey60" },
    -- BlinkCmpDoc = { bg = "Black" },
    -- BlinkCmpDocBorder = { fg = "Grey40" },
    -- BlinkCmpDocSeparator = { fg = "Grey50" },
    -- BlinkCmpDocCursorLine = { bg = "Grey15" },
    -- BlinkCmpSignatureHelp = { bg = "Black" },
    -- BlinkCmpSignatureHelpBorder = { fg = "Grey40" },
    -- BlinkCmpSignatureHelpActiveParameter = { fg = "DodgerBlue", bold = true },

    -- BlinkCmpKindClass = { link = "Type" },
    -- BlinkCmpKindColor = {},
    -- BlinkCmpKindConstant = { link = "Constant" },
    -- BlinkCmpKindConstructor = { link = "Statement" },
    -- BlinkCmpKindEnum = { link = "Variable" },
    -- BlinkCmpKindEnumMember = { link = "Identifier" },
    -- BlinkCmpKindEvent = { link = "Repeat" },
    -- BlinkCmpKindField = { link = "Identifier" },
    -- BlinkCmpKindFile = { link = "String" },
    -- BlinkCmpKindFolder = { link = "Special" },
    -- BlinkCmpKindFunction = { link = "Function" },
    -- BlinkCmpKindInterface = { link = "Include" },
    -- BlinkCmpKindKeyword = { link = "Keyword" },
    -- BlinkCmpKindMethod = { link = "Method" },
    -- BlinkCmpKindModule = { link = "PreProc" },
    -- BlinkCmpKindOperator = { link = "Operator" },
    -- BlinkCmpKindProperty = { link = "Constant" },
    -- BlinkCmpKindReference = { link = "Label" },
    -- BlinkCmpKindSnippet = {},
    -- BlinkCmpKindStruct = { link = "Type" },
    -- BlinkCmpKindText = { link = "String" },
    -- BlinkCmpKindTypeParameter = { link = "Variable" },
    -- BlinkCmpKindUnit = { link = "Include" },
    -- BlinkCmpKindValue = { link = "Number" },
    -- BlinkCmpKindVariable = { link = "Variable" },
}

local function setup_highlight()
    for group, spec in pairs(highlights) do
        vim.api.nvim_set_hl(0, group, spec)
    end
end

vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
        setup_highlight()
    end,
})

local state_file = vim.fn.stdpath("state") .. "/theme_state"

local function ensure_state_file()
    local state_dir = vim.fn.fnamemodify(state_file, ":h")
    vim.fn.mkdir(state_dir, "p")

    local f = io.open(state_file, "r")
    if f then
        f:close()
        return
    end

    local wf = io.open(state_file, "w")
    if wf then
        local background = vim.o.background or "dark"
        local colorscheme = vim.g.colors_name or "default"
        wf:write(background .. "\n")
        wf:write(colorscheme .. "\n")
        wf:close()
    end
end

local function save_theme_state()
    ensure_state_file()

    local background = vim.o.background or "dark"
    local colorscheme = vim.g.colors_name or "default"

    local f = io.open(state_file, "w")
    if f then
        f:write(background .. "\n")
        f:write(colorscheme .. "\n")
        f:close()
    end
end

local function load_theme_state()
    ensure_state_file()

    local f = io.open(state_file, "r")
    if not f then
        return
    end

    local background = f:read("*l")
    local colorscheme = f:read("*l")
    f:close()

    if background == "light" or background == "dark" then
        vim.o.background = background
    end

    if colorscheme and colorscheme ~= "" then
        pcall(vim.cmd.colorscheme, colorscheme)
    end
end

load_theme_state()

vim.api.nvim_create_autocmd("ColorScheme", {
    callback = save_theme_state,
})

vim.api.nvim_create_autocmd("OptionSet", {
    pattern = "background",
    callback = function()
        save_theme_state()
    end,
})
