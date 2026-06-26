vim.pack.add({
    { src = "https://github.com/ibhagwan/fzf-lua" },
    { src = "https://github.com/yuukibarns/gp.nvim" },
})

vim.keymap.set({ "n", "v" }, "[g", function()
    vim.fn.search('\\(^#\\+\\s*[💬🤖]\\|^</think>\\)', 'b')
    vim.cmd("normal! zz")
end, { desc = "Backward to 💬/🤖 header" })

vim.keymap.set({ "n", "v" }, "]g", function()
    vim.fn.search('\\(^#\\+\\s*[💬🤖]\\|^</think>\\)')
    vim.cmd("normal! zz")
end, { desc = "Forward to 💬/🤖 header" })

vim.keymap.set("n", "<leader>gn", function()
    vim.api.nvim_feedkeys(':GpAgent ', 'n', false)
end, { desc = "Pick Agent" })

vim.keymap.set("n", "<leader>gc", "<cmd>GpChatNew<cr>", { desc = "Open Chat" })
vim.keymap.set("n", "<leader>gt", "<cmd>GpChatNew tabnew<cr>", { desc = "Open Chat in new tab" })
vim.keymap.set("n", "<leader>go", function()
    require("fzf-lua").grep({
        cwd = vim.fn.stdpath("data") .. "/gp/chats",
        prompt = "# topic: ",
        search = "^# topic: ",
        no_esc = true,
        rg_opts =
        "--column --line-number --no-heading --color=always --ignore-case --type=md --max-columns=4096 --sortr=modified -e",
    })
end, { desc = "Chat Finder" })

-- Plugin setup
local conf = {
    chat_shortcut_respond = { modes = { "n" }, shortcut = "<C-CR>" },
    chat_shortcut_delete = { modes = { "n" }, shortcut = "<leader>gd" },
    chat_shortcut_stop = { modes = { "n" }, shortcut = "<leader>gs" },
    chat_shortcut_new = { modes = { "n" }, shortcut = "<leader>gc" },
    chat_user_prefix = "## 💬:",
    chat_assistant_prefix = { "## 🤖:", "[{{agent}}]" },
    chat_free_cursor = true,
    providers = {
        deepseek = {
            disable = false,
            endpoint = "https://api.deepseek.com/chat/completions",
            secret = { "cat", "/home/yuukibarns/.deepseek_api_key" },
        },
        volcengine = {
            disable = false,
            endpoint = "https://ark.cn-beijing.volces.com/api/v3/chat/completions",
            secret = { "cat", "/home/yuukibarns/.volcengine_api_key" },
        },
        moonshot = {
            disable = false,
            endpoint = "https://api.moonshot.cn/v1/chat/completions",
            secret = { "cat", "/home/yuukibarns/.moonshot_api_key" },
        },
        chatanywhere = {
            disable = false,
            endpoint = "https://api.chatanywhere.tech/v1/chat/completions",
            secret = { "cat", "/home/yuukibarns/.chatanywhere_api_key" },
        },
        gemini = {
            disable = false,
            endpoint = "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions",
            secret = { "cat", "/home/yuukibarns/.gemini_api_key" },
        },
    },
    agents = {
        {
            name = "Gemini-3.5-Flash",
            provider = "gemini",
            chat = true,
            command = false,
            model = {
                model = "gemini-3.5-flash",
                thinking = "high",
            },
            system_prompt = require("gp.defaults").chat_system_prompt,
        },
        {
            name = "DeepSeek-V4-Flash",
            provider = "deepseek",
            chat = true,
            command = false,
            model = {
                model = "deepseek-v4-flash",
            },
            system_prompt = require("gp.defaults").chat_system_prompt,
        },
        {
            name = "DeepSeek-V4-Pro",
            provider = "deepseek",
            chat = true,
            command = false,
            model = "deepseek-v4-pro",
            system_prompt = "",
        },
        {
            name = "GPT-5.5",
            provider = "chatanywhere",
            chat = true,
            command = false,
            model = "gpt-5.5",
            system_prompt = require("gp.defaults").chat_system_prompt,
        },
        {
            name = "GPT-5.4",
            provider = "chatanywhere",
            chat = true,
            command = false,
            model = "gpt-5.4",
            system_prompt = require("gp.defaults").chat_system_prompt,
        },
        {
            name = "GPT-5.3-Codex",
            provider = "chatanywhere",
            chat = true,
            command = false,
            model = "gpt-5.3-codex",
            system_prompt = require("gp.defaults").chat_system_prompt,
        },
        {
            name = "Gemini-3.1-Pro-Preview",
            provider = "chatanywhere",
            chat = true,
            command = false,
            model = "gemini-3.1-pro-preview",
            system_prompt = require("gp.defaults").chat_system_prompt,
        },
        {
            name = "Gemini-3.1-Flash-Lite-Preview",
            provider = "chatanywhere",
            chat = true,
            command = false,
            model = "gemini-3.1-flash-lite-preview",
            system_prompt = require("gp.defaults").chat_system_prompt,
        },
    },
}

require("gp").setup(conf)
