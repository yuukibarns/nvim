return {
    settings = {
        texlab = {
            bibtexFormatter = "texlab",
            build = {
                args = { "-xelatex", "-output-directory=build", "-interaction=nonstopmode", "-synctex=1", "%f" },
                executable = "latexmk",
                forwardSearchAfter = false,
                onSave = false,
                auxDirectory = "./build",
                logDirectory = "./build",
                pdfDirectory = "./build",
            },
            chktex = {
                onEdit = false,
                onOpenAndSave = false
            },
            diagnosticsDelay = 300,
            formatterLineLength = 80,
            latexFormatter = "latexindent",
            latexindent = {
                modifyLineBreaks = false
            },
            forwardSearch = {
                executable = "org.kde.okular",
                args = { "--unique", "file:%p#src:%l%f" },
            },
        },
    }
}
