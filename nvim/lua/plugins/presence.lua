return {
    {
        "vyfor/cord.nvim",
        build = ":Cord update",
        opts = function()
            return {
                display = {
                    theme = "default",
                    flavor = "dark",
                },
                idle = {
                    icon = require("cord.api.icon").get("keyboard"),
                },
                text = {
                    editing = function(opts)
                        return string.format("Editing %s - %s:%s", opts.filename, opts.cursor_line, opts.cursor_char)
                    end,
                },
                advanced = {
                    discord = {
                        sync = {
                            interval = 1000,
                        },
                    },
                },
            }
        end,
    },
}
