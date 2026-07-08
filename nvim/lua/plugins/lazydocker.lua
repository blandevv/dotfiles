return {
    "crnvl96/lazydocker.nvim",
    dependencies = {
        "MunifTanjim/nui.nvim",
    },
    keys = {
        {
            "<leader>gd",
            function()
                require("lazydocker").open()
            end,
            desc = "Open LazyDocker",
        },
    },
}
