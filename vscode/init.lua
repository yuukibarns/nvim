local vscode = require("vscode")

vim.pack.add({
    { src = "https://github.com/kylechui/nvim-surround" },
})

require("nvim-surround").setup({
    move_cursor = "sticky",
})

-- Use VSCode-native navigation where an equivalent exists.
vim.keymap.set("n", "H", function() vscode.action("workbench.action.previousEditorInGroup") end,
    { desc = "Previous editor" })
vim.keymap.set("n", "L", function() vscode.action("workbench.action.nextEditorInGroup") end, { desc = "Next editor" })
vim.keymap.set("n", "[d", function() vscode.action("editor.action.marker.prev") end, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", function() vscode.action("editor.action.marker.next") end, { desc = "Next diagnostic" })
vim.keymap.set("n", "[D", function() vscode.action("editor.action.marker.prevInFiles") end,
    { desc = "Previous diagnostic in files" })
vim.keymap.set("n", "]D", function() vscode.action("editor.action.marker.nextInFiles") end,
    { desc = "Next diagnostic in files" })
vim.keymap.set("n", "<C-s>", function() vscode.action("workbench.action.files.save") end, { desc = "Save file" })
vim.keymap.set("n", "za", function() vscode.action("editor.toggleFold") end, { desc = "Toggle fold" })
vim.keymap.set("n", "zA", function() vscode.action("editor.toggleFoldRecursively") end,
    { desc = "Toggle fold recursively" })
vim.keymap.set("n", "zc", function() vscode.action("editor.fold") end, { desc = "Close fold" })
vim.keymap.set("n", "zC", function() vscode.action("editor.foldRecursively") end,
    { desc = "Close fold recursively" })
vim.keymap.set("n", "zo", function() vscode.action("editor.unfold") end, { desc = "Open fold" })
vim.keymap.set("n", "zO", function() vscode.action("editor.unfoldRecursively") end,
    { desc = "Open fold recursively" })
vim.keymap.set("n", "zM", function() vscode.action("editor.foldAll") end, { desc = "Close all folds" })
vim.keymap.set("n", "zR", function() vscode.action("editor.unfoldAll") end, { desc = "Open all folds" })
vim.keymap.set("n", "zj", function() vscode.action("editor.gotoNextFold") end, { desc = "Next fold" })
vim.keymap.set("n", "zk", function() vscode.action("editor.gotoPreviousFold") end, { desc = "Previous fold" })

-- Remove defaults backed by Neovim-only lists.
vim.keymap.del("n", "[a")
vim.keymap.del("n", "]a")
vim.keymap.del("n", "[A")
vim.keymap.del("n", "]A")
vim.keymap.del("n", "[b")
vim.keymap.del("n", "]b")
vim.keymap.del("n", "[B")
vim.keymap.del("n", "]B")
vim.keymap.del("n", "[q")
vim.keymap.del("n", "]q")
vim.keymap.del("n", "[Q")
vim.keymap.del("n", "]Q")
vim.keymap.del("n", "[<C-Q>")
vim.keymap.del("n", "]<C-Q>")
vim.keymap.del("n", "[l")
vim.keymap.del("n", "]l")
vim.keymap.del("n", "[L")
vim.keymap.del("n", "]L")
vim.keymap.del("n", "[<C-L>")
vim.keymap.del("n", "]<C-L>")
vim.keymap.del("n", "[t")
vim.keymap.del("n", "]t")
vim.keymap.del("n", "[T")
vim.keymap.del("n", "]T")
vim.keymap.del("n", "[<C-T>")
vim.keymap.del("n", "]<C-T>")

-- HACK: issue #2117
local redraw_fix = vim.api.nvim_create_augroup('VSCodeRedrawFix', { clear = true })
vim.api.nvim_create_autocmd('CursorHold', {
    group = redraw_fix,
    callback = function()
        vim.cmd('silent! mode')
    end,
})
local redraw_group = vim.api.nvim_create_augroup('RedrawOnDelete', { clear = true })
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = redraw_group,
    callback = function()
        if vim.fn.mode() == 'n' then
            vim.cmd('silent! mode')
        end
    end,
})
