vim.bo.tabstop = 2
vim.bo.shiftwidth = 2
vim.bo.softtabstop = 2
-- vim.bo.matchpairs = { "(:)", "[:]", "{:}" }
vim.bo.commentstring = "<!-- %s -->"
vim.bo.formatoptions = "qnjl"
vim.bo.textwidth = 80

vim.keymap.set({ "n", "v" }, 'g>', [[:s/^/> /<CR>:nohlsearch<CR>]], {
    noremap = true,
    silent = true,
    desc = "Add '> ' prefix to selected lines"
})

vim.keymap.set({ "n", "v" }, 'g<', [[:s/^> //<CR>:nohlsearch<CR>]], {
    noremap = true,
    silent = true,
    desc = "Remove '> ' prefix of selected lines"
})

vim.api.nvim_buf_create_user_command(0, "FixMath", function()
    -- Standardize delimiters: \( \) to $ and \[ \] to $$
    vim.cmd("%s/\\\\(\\s*/$/ge")
    vim.cmd("%s/\\s*\\\\)/$/ge")
    vim.cmd("%s/\\\\\\[/$$/ge")
    vim.cmd("%s/\\\\\\]/$$/ge")

    -- Ensure a blank line exists BEFORE display math
    -- vim.cmd([[%s/\(.\)\n\(\s*\)\$\$/\1\r\r\2$$/ge]])

    -- Ensure a blank line exists AFTER display math
    -- vim.cmd([[%s/\$\$\n\(\s*\)\(.\)/\$$\r\r\1\2/ge]])

    -- Multi-line blocks
    -- vim.cmd([[%s/^\$\$\n\(\_.\{-}\)\n\$\$/\r$$\1$$\r/ge]])
    -- vim.cmd([[%s/\v(\s*)\$\$(\n)\s*(\S.*)\n\s*\$\$/\1\2\1$$\3$$\r\1/ge]])

    vim.cmd("nohlsearch")
end, {})

---@param image_dir string
---@return string?
local function paste_image_from_clipboard(image_dir)
    -- 1. Check if wl-paste is available
    if vim.fn.executable('wl-paste') == 0 then
        vim.api.nvim_echo({ { 'Error: wl-paste not found. Please install wl-clipboard', 'ErrorMsg' } }, true, {})
        return
    end

    image_dir = vim.fn.expand(image_dir)

    -- 2. Create directory if it doesn't exist
    if vim.fn.isdirectory(image_dir) == 0 then
        vim.fn.mkdir(image_dir, 'p')
    end

    -- 3. Check clipboard content type
    local clipboard_types = vim.fn.systemlist('wl-paste -l')
    local image_type = nil

    for _, type in ipairs(clipboard_types) do
        if string.match(type, '^image/') then
            image_type = type
            break
        end
    end

    if not image_type then
        vim.notify("No image found in clipboard", vim.log.levels.INFO)
        return
    end

    -- 4. Configuration for conversion
    local is_svg = (image_type == "image/svg+xml")
    local file_extension = "png"
    local needs_conversion = false
    local density = 300 -- High DPI for AI vision clarity

    if is_svg then
        file_extension = "png"
        needs_conversion = true

        -- Check if ImageMagick is available
        if vim.fn.executable('magick') == 0 and vim.fn.executable('convert') == 0 then
            vim.api.nvim_echo({ { 'Error: ImageMagick not found. Required to convert SVG.', 'ErrorMsg' } }, true, {})
            return
        end
    else
        -- Standard mapping for other types
        if image_type == "image/png" then
            file_extension = "png"
        elseif image_type == "image/jpeg" then
            file_extension = "jpg"
        elseif image_type == "image/gif" then
            file_extension = "gif"
        elseif image_type == "image/webp" then
            file_extension = "webp"
        elseif image_type == "image/bmp" then
            file_extension = "bmp"
        elseif image_type == "image/tiff" then
            file_extension = "tiff"
        else
            file_extension = string.match(image_type, "^image/(.+)$") or "unknown"
        end
    end

    -- 5. Generate filename
    local timestamp = os.date('%Y-%m-%d_%H-%M-%S')
    local filename = timestamp .. "." .. file_extension
    -- Ensure path ends with separator
    local separator = package.config:sub(1, 1)
    if image_dir:sub(-1) ~= separator then
        image_dir = image_dir .. separator
    end
    local full_path = image_dir .. filename

    -- 6. Construction of the command
    local cmd = ""
    if needs_conversion then
        local conv_bin = vim.fn.executable('magick') == 1 and 'magick' or 'convert'

        -- EXPLANATION OF FLAGS:
        -- -density: Increases resolution of the SVG rasterization
        -- -background white: AI handles white backgrounds better than transparent
        -- -alpha remove: Flatten transparency onto the background color
        cmd = string.format(
            "wl-paste -t %s | %s -density %d svg:- -background white -alpha remove -alpha off png:%s",
            vim.fn.shellescape(image_type),
            conv_bin,
            density,
            vim.fn.shellescape(full_path)
        )
    else
        cmd = string.format("wl-paste -t %s > %s",
            vim.fn.shellescape(image_type),
            vim.fn.shellescape(full_path)
        )
    end

    -- 7. Execute
    local result = vim.fn.system(cmd)

    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({ { 'Error saving image: ' .. result, 'ErrorMsg' } }, true, {})
        return nil
    end

    -- 8. Success notification
    vim.api.nvim_echo({
        { '✓ Image ' .. (needs_conversion and ('(Converted ' .. density .. 'dpi) ') or '') .. 'saved: ', 'None' },
        { full_path, 'Directory' }
    }, true, {})

    return full_path
end

vim.keymap.set("n", "p", function()
    local path = paste_image_from_clipboard("~/Learn/IMAGES/")
    if path then
        vim.api.nvim_paste('<img src="' .. path .. '" alt="" width="">', false, -1)
    else
        vim.api.nvim_feedkeys("p", "n", false)
    end
end, { buffer = 0, desc = "Wayland Paste" })

-- local fzf = require("fzf-lua")
-- local root = vim.fs.root(0, ".git")
--
-- local function GetHeading()
--     local bufnr = vim.api.nvim_get_current_buf()
--     local cursor_pos = vim.api.nvim_win_get_cursor(0)
--     local row, col = cursor_pos[1], cursor_pos[2] -- row (1-based), col (0-based)
--
--     local pos_info = vim.inspect_pos(
--         bufnr,
--         row - 1,
--         col,
--         { treesitter = true, syntax = false, extmarks = false, semantic_tokens = false }
--     )
--
--     if not pos_info.treesitter then return false end
--
--     local is_heading = false
--
--     for _, node in ipairs(pos_info.treesitter) do
--         if node.capture:match("^markup%.heading") then
--             is_heading = true
--             break
--         end
--         if node.capture:match("comment") then
--             local heading = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
--             if heading:match("^<!%-%-%s+#+") then
--                 is_heading = true
--                 break
--             end
--         end
--     end
--
--     if is_heading then
--         local heading = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
--         heading = heading:gsub("^<!%-%-%s+", ""):gsub("%s+%-%->$", ""):gsub("^#+%s+", "")
--         return heading
--     end
-- end
--
-- local function GetLink()
--     local bufnr = vim.api.nvim_get_current_buf()
--     local cursor_pos = vim.api.nvim_win_get_cursor(0)
--     local row, col = cursor_pos[1], cursor_pos[2] -- row (1-based), col (0-based)
--
--     local pos_info = vim.inspect_pos(
--         bufnr,
--         row - 1,
--         col,
--         { treesitter = true, syntax = false, extmarks = false, semantic_tokens = false }
--     )
--
--     if not pos_info.treesitter then return false end
--
--     local is_strong = false
--
--     for _, node in ipairs(pos_info.treesitter) do
--         if node.capture == "markup.strong" then
--             is_strong = true
--             break
--         end
--     end
--
--     if not is_strong then return false end
--
--     -- Search backward for opening '**' (returns {lnum, col, 0})
--     local open_pos = vim.fn.searchpos('\\*\\*', 'bcnW')
--     if open_pos[1] == 0 then return false end -- No opening found
--
--     -- Extract line and column from the position tuple
--     local open_lnum, open_col = open_pos[1], open_pos[2]
--
--     local close_pos = vim.fn.searchpos('\\*\\*', 'cnW')
--     if close_pos[1] == 0 then return false end -- No closing found
--
--     local close_lnum, close_col = close_pos[1], close_pos[2] + 1
--
--     -- Check if the cursor is between the opening and closing '**'
--     local cursor_pos_1based = { row, col + 1 } -- Convert to 1-based column
--     local is_inside = (cursor_pos_1based[1] > open_lnum or (cursor_pos_1based[1] == open_lnum and cursor_pos_1based[2] > open_col + 1)) and
--         (cursor_pos_1based[1] < close_lnum or (cursor_pos_1based[1] == close_lnum and cursor_pos_1based[2] < close_col - 1))
--
--     if not is_inside then return false end
--
--     -- Extract text between the opening and closing '**'
--     local lines = vim.api.nvim_buf_get_lines(0, open_lnum - 1, close_lnum, false)
--     if #lines == 0 then return false end
--
--     -- Calculate start and end positions (1-based to Lua's 1-based strings)
--     local start_char = open_col + 2 -- Skip the opening '**'
--
--     local end_line_idx = #lines
--     local end_char = close_col - 2 -- Stop before the closing '**'
--
--     -- Adjust for single-line vs multi-line
--     local parts = {}
--     if open_lnum == close_lnum then
--         -- Single line: extract substring directly
--         parts[1] = lines[1]:sub(start_char, end_char)
--     else
--         -- Multi-line: handle first line, middle lines, and last line
--         parts[1] = lines[1]:sub(start_char)
--         for i = 2, end_line_idx - 1 do
--             parts[#parts + 1] = lines[i]
--         end
--         parts[#parts + 1] = lines[end_line_idx]:sub(1, end_char)
--     end
--
--     local bold_text = table.concat(parts, ' ')
--     return bold_text ~= '' and bold_text or false
-- end
--
-- local function GetPath()
--     -- Get the current line and cursor position
--     local line = vim.api.nvim_get_current_line()
--     local col = vim.api.nvim_win_get_cursor(0)[2] + 1 -- Lua is 1-indexed
--
--     -- Find all pairs of backticks in the line
--     local backtick_pairs = {}
--     for i = 1, #line do
--         if line:sub(i, i) == '`' then
--             table.insert(backtick_pairs, i)
--         end
--     end
--
--     -- Check if the cursor is inside a pair of backticks
--     for i = 1, #backtick_pairs - 1, 2 do
--         local start = backtick_pairs[i]
--         local finish = backtick_pairs[i + 1]
--         if col > start and col < finish then
--             -- Extract and return the text inside the backticks
--             return line:sub(start + 1, finish - 1)
--         end
--     end
--
--     -- If not inside backticks, return nil
--     return false
-- end
--
-- vim.api.nvim_buf_set_keymap(0, 'n', 'gy', '', {
--     desc = "Copy Reference",
--     callback = function()
--         -- Get the relative path matching the last 3 components
--         local full_path = vim.fn.expand('%:p')
--         local path_match = full_path:match('([^/]+/[^/]+/[^/]+)$')
--
--         -- If the grandparent is "work", use only parent/filename
--         if path_match then
--             local grandparent, parent, filename = path_match:match('([^/]+)/([^/]+)/([^/]+)$')
--             if grandparent == "work" then
--                 path_match = parent .. "/" .. filename
--             end
--         end
--
--         local heading = vim.api.nvim_get_current_line()
--         if not heading:find("^#+%s+") then
--             vim.notify("Not A Heading", 3)
--         end
--         heading = heading:gsub("^#+%s+", "")
--         vim.fn.setreg("+", path_match .. "#" .. heading)
--         vim.fn.setreg('"', path_match .. "#" .. heading)
--     end
-- })
--
-- vim.api.nvim_buf_set_keymap(0, 'n', 'grr', '', {
--     desc = "Go to References",
--     callback = function()
--         local heading = GetHeading()
--         if heading then
--             fzf.grep({
--                 prompt  = "Rg❯ ",
--                 cwd     = root,
--                 search  = "**" .. heading .. "**",
--                 no_esc  = false,
--                 rg_opts =
--                 "--column --line-number --no-heading --color=always --ignore-case --type=md --max-columns=4096 -e"
--             })
--             return true
--         end
--         local def = GetLink()
--         if def then
--             if def:match("^Definition%s+%((.-)%)") or def:match("^Theorem%s+%((.-)%)") or def:match("^Corollary%s+%((.-)%)") or def:match("^Lemma%s+%((.-)%)") or def:match("^Proposition%s+%((.-)%)") or def:match("^Claim%s+%((.-)%)") or def:match("^Example%s+%((.-)%)") or def:match("^Problem%s+%((.-)%)") then
--                 def = def:match("%((.-)%)")
--                 fzf.grep({
--                     prompt  = "Rg❯ ",
--                     cwd     = root,
--                     search  = "**" .. def .. "**",
--                     no_esc  = false,
--                     rg_opts =
--                     "--column --line-number --no-heading --color=always --ignore-case --type=md --max-columns=4096 -e"
--                 })
--                 return true
--             end
--         end
--         return false
--     end,
-- })
--
-- vim.api.nvim_buf_set_keymap(0, 'n', '<C-]>', '', {
--     desc = "Jump to definition",
--     callback = function()
--         local link = GetLink()
--         if link then
--             link = link:gsub("([%$%(%))%.%+%*%?%[%]%^%|\\%-%{}])", "\\%1"):gsub("%s+", " ")
--             fzf.grep({
--                 prompt  = "Rg❯ ",
--                 cwd     = root,
--                 search  =
--                     "(" ..
--                     "^(<!-- )?#+\\s+" ..
--                     link ..
--                     ")" ..
--                     "|" ..
--                     "(" ..
--                     "^\\*\\*(Definition|Theorem|Lemma|Corollary|Proposition|Claim|Example|Problem)\\s+\\(" ..
--                     link ..
--                     "\\)(\\.)?\\*\\*" ..
--                     ")",
--                 no_esc  = true,
--                 rg_opts =
--                 "--column --line-number --no-heading --color=always --ignore-case --type=md --max-columns=4096 -e"
--             })
--         end
--     end,
-- })
--
-- vim.api.nvim_buf_set_keymap(0, 'n', 'gf', '', {
--     desc = "Go to File",
--     callback = function()
--         local path = GetPath()
--         if path then
--             local hash_pos = path:find("#")
--             if hash_pos then
--                 local before = path:sub(1, hash_pos - 1)
--                 local after = path:sub(hash_pos + 1)
--                 vim.fn.setreg("+", before)
--                 vim.fn.setreg('"', before)
--                 fzf.grep({
--                     cwd = root,
--                     search = "\\#+\\s+" .. after,
--                     no_esc = true,
--                 })
--             else
--                 fzf.files({
--                     cwd = root,
--                     query = path,
--                 })
--             end
--         else
--             vim.api.nvim_feedkeys("gf", "n", false)
--         end
--     end,
-- })
--
-- local minor_words = {
--     -- Articles
--     'a', 'an', 'the',
--     -- Conjunctions
--     'and', 'but', 'or', 'nor', 'for', 'yet', 'so', 'if',
--     -- Long conjunctions
--     -- 'because', 'although', 'though', 'while', 'whereas', 'whether', 'unless',
--     -- Prepositions
--     'as', 'at', 'by', 'in', 'of', 'on', 'to', 'up', 'via',
--     -- Prepositions with length >= 4 are considered to be major words, "off" and "out" their grammar role are tricky to determine
--     -- 'with', 'about', 'above', 'across', 'after', 'against', 'along', 'among', 'around', 'before', 'behind', 'below', 'beneath', 'beside', 'between', 'beyond', 'concerning', 'despite', 'down', 'during', 'except', 'from', 'inside', 'into', 'like', 'near', 'onto', 'out', 'outside', 'over', 'past', 'since', 'through', 'toward', 'under', 'underneath', 'until', 'unto', 'upon', 'within', 'without',
--     -- Short auxiliary verbs
--     'is', 'am', 'are', 'be', 'been', 'being', 'was', 'were', 'has', 'have', 'had', 'do', 'does', 'did',
--     -- Modal auxiliary verbs
--     -- 'can', 'could', 'may', 'might', 'must', 'shall', 'should', 'will', 'would', 'it', 'he', 'she', 'they', 'we', 'you'
-- }
--
-- local function get_spell_regions(bufnr, start_line, end_line)
--     local regions = {}
--
--     -- Original region detection logic
--     for line = start_line, end_line do
--         local row = line - 1
--         local line_text = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ''
--         local max_col = #line_text
--
--         local current_start = nil
--
--         for col = 0, max_col do
--             local pos_info = vim.inspect_pos(
--                 bufnr,
--                 row,
--                 col,
--                 { treesitter = true, syntax = false, extmarks = false, semantic_tokens = false }
--             )
--
--             local has_spell = false
--             local has_nospell = false
--             local is_space = false
--
--             if pos_info.treesitter == {} then
--                 is_space = true
--             else
--                 for _, capture in ipairs(pos_info.treesitter) do
--                     if capture.capture == 'spell' then
--                         has_spell = true
--                     elseif capture.capture == 'nospell' then
--                         has_nospell = true
--                     end
--                 end
--             end
--
--             if is_space or (has_spell and not has_nospell) then
--                 current_start = current_start or col
--             else
--                 if current_start then
--                     table.insert(regions, {
--                         start_line = line,
--                         start_col = current_start + 1,
--                         end_line = line,
--                         end_col = col + 1
--                     })
--                     current_start = nil
--                 end
--             end
--         end
--
--         if current_start then
--             table.insert(regions, {
--                 start_line = line,
--                 start_col = current_start + 1,
--                 end_line = line,
--                 end_col = max_col + 2
--             })
--         end
--     end
--
--     -- Split regions into sentences
--     local new_regions = {}
--     local current_sentence = 1
--
--     for _, region in ipairs(regions) do
--         local line = region.start_line
--         local s_col = region.start_col
--         local e_col = region.end_col
--         local row = line - 1
--         local line_text = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ''
--         local substring = line_text:sub(s_col, e_col - 1)
--
--         local split_positions = {}
--         for i = 1, #substring - 1 do
--             local c = substring:sub(i, i)
--             if c == '.' or c == '!' or c == '?' then
--                 table.insert(split_positions, i)
--             end
--         end
--
--         local current_split_start = s_col
--         for _, split_pos in ipairs(split_positions) do
--             local split_point = s_col + split_pos - 1
--             local sub_end = split_point + 1
--             table.insert(new_regions, {
--                 start_line = line,
--                 start_col = current_split_start,
--                 end_line = line,
--                 end_col = sub_end,
--                 sentence = current_sentence
--             })
--             current_split_start = sub_end
--             current_sentence = current_sentence + 1
--         end
--
--         if current_split_start < e_col then
--             table.insert(new_regions, {
--                 start_line = line,
--                 start_col = current_split_start,
--                 end_line = line,
--                 end_col = e_col,
--                 sentence = current_sentence
--             })
--         end
--     end
--
--     return new_regions
-- end
--
-- local function capitalize(word)
--     if word:find('-') then
--         return word:gsub('(%w+)(%-?)(%w*)', function(a, sep, b)
--             return a:sub(1, 1):upper() .. a:sub(2) .. sep .. (b ~= '' and b:sub(1, 1):upper() .. b:sub(2) or '')
--         end)
--     end
--     return word:sub(1, 1):upper() .. word:sub(2)
-- end
--
-- local function title_case_word(word)
--     if word:match('^%W*$') then return word end
--
--     if word:find('-') then
--         return word:gsub('(%w+)(%-?)(%w*)', function(a, sep, b)
--             return capitalize(a) .. sep .. (b ~= '' and capitalize(b) or '')
--         end)
--     end
--
--     return vim.tbl_contains(minor_words, word:lower()) and word:lower() or capitalize(word)
-- end
--
-- local function process_text(text, is_first_in_sentence, is_last_in_sentence)
--     local leading_spaces = text:match('^%s*') or ''
--     local trailing_spaces = text:match('%s*$') or ''
--
--     local words = {}
--     for word in text:gmatch('%S+') do
--         local prefix = word:match('^(%p+)')
--         local suffix = word:match('(%p+)$')
--         local core = word:sub((prefix and #prefix or 0) + 1, suffix and -(#suffix + 1) or nil)
--
--         table.insert(words, {
--             prefix = prefix or '',
--             core = core,
--             suffix = suffix or ''
--         })
--     end
--
--     local processed = {}
--     for i, parts in ipairs(words) do
--         local prev = words[i - 1]
--         local is_first = i == 1
--         local is_last = i == #words
--         local core = parts.core
--
--         if is_first_in_sentence and is_first then
--             core = capitalize(core)
--         elseif is_last_in_sentence and is_last then
--             core = capitalize(core)
--         else
--             if prev and (prev.suffix:match('[:%-]$') or prev.core:match('[:%-]$')) then
--                 core = capitalize(core)
--             else
--                 core = title_case_word(core)
--             end
--         end
--
--         -- In case the parts = ? then only need add prefix
--         if parts.core == "" and parts.prefix == parts.suffix then
--             processed[i] = parts.prefix
--         else
--             processed[i] = parts.prefix .. core .. parts.suffix
--         end
--     end
--
--     return leading_spaces .. table.concat(processed, ' ') .. trailing_spaces
-- end
--
-- local function process_lines(start_line, end_line)
--     local bufnr = vim.api.nvim_get_current_buf()
--     local regions = get_spell_regions(bufnr, start_line, end_line)
--     local lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)
--
--     -- Group regions by line and sort columns
--     local regions_by_line = {}
--     for _, region in ipairs(regions) do
--         local line = region.start_line
--         if not regions_by_line[line] then
--             regions_by_line[line] = {}
--         end
--         table.insert(regions_by_line[line], region)
--     end
--
--     -- Process each line with proper interval handling
--     for line_idx = start_line, end_line do
--         local line_regions = regions_by_line[line_idx] or {}
--         local original_line = lines[line_idx - start_line + 1]
--         local max_col = #original_line
--
--         -- Sort regions by start column
--         table.sort(line_regions, function(a, b)
--             return a.start_col < b.start_col
--         end)
--
--         -- Build intervals covering the entire line
--         local intervals = {}
--         local prev_end = 0
--
--         -- Add spell regions and interspersed non-spell regions
--         for _, reg in ipairs(line_regions) do
--             local start = reg.start_col - 1 -- Convert to 0-based
--             local end_col = reg.end_col - 1 -- Convert to 0-based (exclusive)
--
--             -- Add non-spell region before this spell region
--             if start > prev_end then
--                 table.insert(intervals, {
--                     start = prev_end,
--                     ["end"] = start,
--                     type = "non-spell",
--                     sentence = reg.sentence
--                 })
--             end
--
--             -- Add spell region
--             table.insert(intervals, {
--                 start = start,
--                 ["end"] = end_col,
--                 type = "spell",
--                 sentence = reg.sentence
--             })
--             prev_end = end_col
--         end
--
--         -- Add final non-spell region if needed
--         if prev_end < max_col then
--             table.insert(intervals, {
--                 start = prev_end,
--                 ["end"] = max_col,
--                 type = "non-spell",
--                 sentence = line_regions[#line_regions] and line_regions[#line_regions].sentence or 1
--             })
--         end
--
--         -- Group intervals by sentence
--         local intervals_by_sentence = {}
--         for _, interval in ipairs(intervals) do
--             local sentence = interval.sentence
--             if not intervals_by_sentence[sentence] then
--                 intervals_by_sentence[sentence] = {}
--             end
--             table.insert(intervals_by_sentence[sentence], interval)
--         end
--
--         -- Process each sentence
--         local parts = {}
--         for _, sentence_intervals in pairs(intervals_by_sentence) do
--             local is_first_in_sentence = true
--             for i, interval in ipairs(sentence_intervals) do
--                 local text = original_line:sub(interval.start + 1, interval["end"])
--                 local is_last_in_sentence = i == #sentence_intervals
--                 if i == 1 and string.match(text, "^%s*#+%s*$") and interval.type == "non-spell" then
--                     table.insert(parts, text)
--                 else
--                     if interval.type == "spell" then
--                         text = process_text(text, is_first_in_sentence, is_last_in_sentence)
--                     end
--                     table.insert(parts, text)
--                     is_first_in_sentence = false
--                 end
--             end
--         end
--
--         -- Rebuild the line
--         lines[line_idx - start_line + 1] = table.concat(parts)
--     end
--
--     vim.api.nvim_buf_set_lines(bufnr, start_line - 1, end_line, false, lines)
-- end
--
-- -- Normal mode mapping (gll): Convert current line to title case
-- vim.api.nvim_buf_set_keymap(0, 'n', 'gll', '', {
--     noremap = true,
--     silent = true,
--     desc = "Convert current line to title case",
--     callback = function()
--         local start_line = vim.fn.line('.')
--         local end_line = vim.fn.line('.')
--         process_lines(start_line, end_line) -- Assuming process_lines handles title case conversion
--     end,
-- })
--
-- -- Visual mode mapping (gl): Convert selected lines to title case
-- vim.api.nvim_buf_set_keymap(0, 'x', 'gl', '', {
--     noremap = true,
--     silent = true,
--     desc = "Convert selected lines to title case",
--     callback = function()
--         local start_line = vim.fn.line('v')
--         local end_line = vim.fn.line('.')
--         for line = math.min(start_line, end_line), math.max(start_line, end_line) do
--             process_lines(line, line)
--         end
--         vim.cmd("normal! \x1b")
--     end,
-- })
