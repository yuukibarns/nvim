-- better up/down
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

vim.keymap.set('x', 'il', '<Esc>^vg_', { desc = 'Select inner line' })
vim.keymap.set('o', 'il', '<cmd>normal! ^vg_<cr>', { desc = 'Select inner line' })

-- al (around line): first non-whitespace to absolute end of line
vim.keymap.set({'x', 'o'}, 'al', function()
  vim.cmd('normal! ^v$')
end, { desc = 'Select line content to end' })

-- Map Ctrl-C to Esc
vim.keymap.set({ "x", "i", "s" }, "<C-c>", "<Esc>", { noremap = true, silent = true })

-- Map Ctrl-Backspace to Ctrl-W
vim.keymap.set("i", "<C-BS>", "<C-w>", { noremap = true })
vim.keymap.set("i", "<C-w>", "<Nop>", { noremap = true })
vim.keymap.set("i", "<C-h>", "<Nop>", { noremap = true })

-- Paste command mode
vim.keymap.set({ "c", "i" }, "<C-v>", "<C-R>+")

-- Terminal
vim.keymap.set("t", "<C-\\>", "<C-\\><C-n>")
vim.keymap.set("t", "<C-v>", '<C-\\><C-o>"+p')

-- Save or undo
vim.keymap.set("n", "<C-s>", "<cmd>w<CR>")

local function get_cwd_terminal()
	-- For regular buffers
	if vim.bo.buftype == "" then
		return vim.fn.expand("%:p:h")
	end

	-- Fallback to current working directory
	return vim.fn.getcwd()
end

vim.keymap.set("n", "<leader>tm", function()
	vim.cmd("new term://" .. get_cwd_terminal() .. "//fish")
end, { desc = "Open Terminal Below(half height)" })

vim.keymap.set("n", "<leader>q", function()
	vim.cmd("edit term://" .. get_cwd_terminal() .. "//fish")
end, { desc = "Open Terminal (parent directory)" })

vim.keymap.set("n", "<leader>Q", function()
	vim.cmd("tabedit term://" .. get_cwd_terminal() .. "//fish")
end, { desc = "Open Terminal (parent directory)" })

vim.keymap.set("n", "<C-t>", "<cmd>tab split<cr>", {})
vim.keymap.set("n", "<C-S-t>", "<C-w>T", {})
vim.keymap.set("n", "<C-Tab>", "gt", {})
vim.keymap.set("n", "<C-S-Tab>", "gT", {})
vim.keymap.set("n", "<S-L>", "gt", {})
vim.keymap.set("n", "<S-H>", "gT", {})
vim.keymap.set("n", "<C-S-L>", "<cmd>tabmove +<CR>", {})
vim.keymap.set("n", "<C-S-H>", "<cmd>tabmove -<CR>", {})
vim.keymap.set("n", "<C-q>", "<cmd>q<CR>", {})
vim.keymap.set("n", "<S-q>", "<cmd>bd<CR>", {})

-- Function to create and edit the next sequential note
local function create_next_note(path)
	local notes_dir = vim.fn.expand(path)

	-- Ensure directory exists
	if vim.fn.isdirectory(notes_dir) == 0 then
		vim.fn.mkdir(notes_dir, "p")
	end

	-- Count existing .md files to determine next number
	local file_count = vim.fn.len(vim.fn.globpath(notes_dir, "*.md", false, true))
	local next_number = file_count + 1

	local filepath = notes_dir .. next_number .. ".md"
	vim.cmd("edit " .. vim.fn.fnameescape(filepath))
end

-- Function to open the latest note.
local function open_latest_note(path)
	local notes_dir = vim.fn.expand(path)

	-- Ensure directory exists
	if vim.fn.isdirectory(notes_dir) == 0 then
		vim.fn.mkdir(notes_dir, "p")
	end

	-- Count existing .md files
	local file_count = vim.fn.len(vim.fn.globpath(notes_dir, "*.md", false, true))

	local filepath = notes_dir .. file_count .. ".md"
	vim.cmd("edit " .. vim.fn.fnameescape(filepath))
end

-- Function to open specific note by number
local function open_specific_note(path)
	local number = vim.fn.input("Enter note number: ")

	if not string.match(number, "^-?%d*$") then
		print("Invalid number")
		return
	end

	local notes_dir = vim.fn.expand(path)
	local file_count = vim.fn.len(vim.fn.globpath(notes_dir, "*.md", false, true))

	if number == "" or number == "0" then
		number = tostring(file_count)
	elseif number:match("^-") then
		number = tostring(file_count + tonumber(number))
	end

	local filepath = notes_dir .. number .. ".md"

	-- Check if file exists
	if vim.fn.filereadable(filepath) == 0 then
		local create = vim.fn.confirm("File doesn't exist. Create it?", "&Yes\n&No", 1)
		if create == 1 then
			vim.cmd("edit " .. vim.fn.fnameescape(filepath))
		end
	else
		vim.cmd("edit " .. vim.fn.fnameescape(filepath))
	end
end

-- Set up keymaps (adjust the keybindings as needed)
vim.keymap.set("n", "<leader>nn", function()
	create_next_note("~/Learn/work/NOTES/")
end, { desc = "Create next sequential note" })
vim.keymap.set("n", "<leader>nl", function()
	open_latest_note("~/Learn/work/NOTES/")
end, { desc = "Open latest note" })
vim.keymap.set("n", "<leader>nf", function()
	open_specific_note("~/Learn/work/NOTES/")
end, { desc = "Find specific note by number" })
