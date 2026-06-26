if not vim.g.neovide then
    local fcitx5_last_state = 1

    local function fcitx5_state()
        if vim.fn.executable("fcitx5-remote") ~= 1 then
            return nil
        end

        local result = vim.fn.system("fcitx5-remote")
        if vim.v.shell_error ~= 0 then
            return nil
        end

        return tonumber(vim.trim(result))
    end

    local function fcitx5_activate()
        if vim.fn.executable("fcitx5-remote") == 1 then
            vim.fn.system("fcitx5-remote -o")
        end
    end

    local function fcitx5_deactivate()
        if vim.fn.executable("fcitx5-remote") == 1 then
            vim.fn.system("fcitx5-remote -c")
        end
    end

    local group = vim.api.nvim_create_augroup("Fcitx5AutoSwitch", { clear = true })

    vim.api.nvim_create_autocmd("InsertLeave", {
        group = group,
        callback = function()
            local state = fcitx5_state()
            if state == nil then
                return
            end

            fcitx5_last_state = state

            if state == 2 then
                fcitx5_deactivate()
            end
        end,
    })

    vim.api.nvim_create_autocmd("InsertEnter", {
        group = group,
        callback = function()
            if fcitx5_last_state == 2 then
                fcitx5_activate()
            end
        end,
    })
end
