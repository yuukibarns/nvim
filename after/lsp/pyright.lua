return {
    pyright = {
        -- Using Ruff's import organizer
        disableOrganizeImports = false,
    },
    python = {
        analysis = {
            -- Ignore all files for analysis to exclusively use Ruff for linting
            ignore = { "*" },
        },
    },
}
