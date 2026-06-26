vim.keymap.set("n", "<leader>lf", "<cmd>LspTexlabForward<cr>",
    { buf = 0, desc = "Texlab forward search" })
vim.keymap.set("n", "<leader>lb", "<cmd>LspTexlabBuild<cr>",
    { buf = 0, desc = "Texlab build" })

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
        vim.api.nvim_paste(
            "\\begin{figure}[htbp]\n" ..
            "    \\centering\n" ..
            "    \\includegraphics[width=0.8\\linewidth]{" .. path .. "}\n" ..
            "    \\caption{}\n" ..
            "    \\label{fig:}\n" ..
            "\\end{figure}",
            false,
            -1
        )
    else
        vim.api.nvim_feedkeys("p", "n", false)
    end
end, { buffer = 0, desc = "Wayland Paste" })
