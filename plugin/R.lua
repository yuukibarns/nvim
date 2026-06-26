vim.pack.add({
    { src = "https://github.com/yuukibarns/R.nvim", version = "pipe" },
})

local opts = {
    hook = {
        on_filetype = function()
            vim.api.nvim_buf_set_keymap(0, "n", "<C-Enter>", "<Plug>RDSendLine", {})
            vim.api.nvim_buf_set_keymap(0, "v", "<C-Enter>", "<Plug>RSendSelection", {})
        end
    },
    R_args = { "--quiet", "--no-save" },
    min_editor_width = 72,
    rconsole_width = 78,
    auto_start = "always",
    register_treesitter = true,
    view_df = {
        open_app = "terminal:vd", -- How to open the CSV
        how = "tabnew",           -- How to display the data if doing it within Neovim
        csv_sep = "\t",           -- Field separator to be used when saving the CSV.
        n_lines = -1,             -- Number of lines to save in the CSV (0 for all lines).
        save_fun = "",            -- R function to save the data.frame in a CSV file
        open_fun = "",            -- R function to open the data.frame directly
    },
    r_ls = {
        completion = true,         -- enable the completion provider
        hover = true,              -- enable the hover provider
        signature = true,          -- enable the signature help provider
        implementation = true,     -- enable the implementation provider
        definition = true,         -- enable the definition provider
        use_git_files = true,      -- use git to find R files, skipping gitignored files
        references = true,         -- enable the references provider
        document_highlight = true, -- enable the document highlight provider
        document_symbol = true,    -- enable the document symbol provider
        workspace_symbol = true,   -- enable the workspace symbol provider
        rename = true,             -- enable the rename provider
        doc_width = 100,
        fun_data_1 = {
            -- base / stats
            "transform", "subset",
            "aggregate", "by",
            "lm", "glm", "aov",

            -- dplyr core verbs
            "select", "rename", "rename_with", "relocate",
            "mutate", "transmute",
            "filter", "arrange",
            "summarise", "summarize", "reframe",
            "group_by", "ungroup", "rowwise",
            "distinct", "count", "tally", "add_count", "add_tally",
            "slice", "slice_head", "slice_tail", "slice_min", "slice_max", "slice_sample",

            -- dplyr joins
            "left_join", "right_join", "inner_join", "full_join",
            "semi_join", "anti_join", "cross_join",
            "nest_join",

            -- tidyr
            "pivot_longer", "pivot_wider",
            "separate", "separate_wider_delim", "separate_wider_position",
            "unite", "extract",
            "drop_na", "replace_na", "fill",
            "complete",
            "nest", "unnest", "unnest_longer", "unnest_wider",
            "pack", "unpack",
            "expand", "expand_grid",
        },
        fun_data_2 = {
            -- ggplot mapping context
            ggplot = { "aes", "aes_string", "vars" },

            -- base data-mask evaluators
            with = { "*" },
            within = { "*" },
            transform = { "*" },
            subset = { "*" },

            -- dplyr verbs: propagate context into nested calls
            mutate = { "*" },
            transmute = { "*" },
            summarise = { "*" },
            summarize = { "*" },
            reframe = { "*" },
            filter = { "*" },
            arrange = { "*" },
            group_by = { "*" },
            rowwise = { "*" },
            distinct = { "*" },
            count = { "*" },
            tally = { "*" },
            add_count = { "*" },
            add_tally = { "*" },

            -- tidyselect / across-heavy contexts
            select = { "*" },
            rename = { "*" },
            rename_with = { "*" },
            relocate = { "*" },

            -- tidyr contexts where nested expressions can appear
            pivot_longer = { "*" },
            pivot_wider = { "*" },
            separate = { "*" },
            unite = { "*" },
            extract = { "*" },
            complete = { "*" },
            nest = { "*" },
            unnest = { "*" }
        },
        fun_data_formula = {
            ggplot = { 'facet_wrap', 'facet_grid', 'vars', 'aes' }
        },
        quarto_intel = nil,
    }
}

vim.g.R_filetypes = { "r", "rmd" }

require("r").setup(opts)

vim.keymap.set("n", "<LocalLeader>gd",
    "<cmd>lua require('r.send').cmd('tryCatch(httpgd::hgd_browse(),error=function(e) {httpgd::hgd();httpgd::hgd_browse()})')<CR>",
    { desc = "httpgd" })
