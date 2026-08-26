return {
    {
        {
            "Gentleman-Programming/gentleman-kanagawa-blur",
            name = "gentleman-kanagawa-blur",
            priority = 1000,
        },
        {
            "wnkz/monoglow.nvim",
            lazy = false,
            priority = 1000,
            opts = {
                transparent = true,
                on_highlights = function(hl, c)
                    hl["@function"] = { fg = c.syntax.func_def, italic = false, bold = true }
                    hl["@keyword"] = { fg = c.syntax.keyword, italic = true, bold = true }
                    hl["@comment"] = { fg = c.syntax.comment, italic = true }
                    hl["@type"] = { fg = c.syntax.type, italic = true, bold = false }

                    -- Transparent floating windows, popups and menus
                    hl["NormalFloat"] = { bg = "none" }
                    hl["FloatBorder"] = { bg = "none" }
                    hl["FloatTitle"] = { bg = "none" }
                    hl["Pmenu"] = { bg = "none" }
                    hl["PmenuSel"] = { bg = "none" }
                    hl["PmenuSbar"] = { bg = "none" }
                    hl["TelescopeNormal"] = { bg = "none" }
                    hl["TelescopeBorder"] = { bg = "none" }
                    hl["WhichKeyFloat"] = { bg = "none" }
                    hl["WhichKeyBorder"] = { bg = "none" }
                end,
            },
        },
        {
            "catppuccin/nvim",
            name = "catppuccin",
            priority = 1000,
            opts = {
                flavour = "mocha",
                transparent_background = true,
                float = {
                    transparent = true,
                },
            },
        },

        {
            "zenbones-theme/zenbones.nvim",
            dependencies = "rktjmp/lush.nvim",
            lazy = false,
            priority = 1000,
            config = function()
                vim.g.zenwritten = {
                    transparent_background = true,
                    float_background = "none",
                }
                vim.o.background = "dark"
                vim.cmd.colorscheme("zenwritten")
                vim.api.nvim_create_autocmd("ColorScheme", {
                    pattern = "*",
                    callback = function()
                        vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
                        vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" })
                        vim.api.nvim_set_hl(0, "FloatTitle", { bg = "none" })

                        vim.api.nvim_set_hl(0, "SnacksPicker", { bg = "none" })
                        vim.api.nvim_set_hl(0, "SnacksPickerBorder", { bg = "none" })
                        vim.api.nvim_set_hl(0, "SnacksPickerTitle", { bg = "none" })
                        vim.api.nvim_set_hl(0, "SnacksPickerRow", { bg = "none" })
                    end,
                })
            end,
        },

        {
            "LazyVim/LazyVim",
            opts = {
                colorscheme = "zenwritten",
            },
        },
    },
}
