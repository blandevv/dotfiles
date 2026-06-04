return {
    {
        {
            "Gentleman-Programming/gentleman-kanagawa-blur",
            name = "gentleman-kanagawa-blur",
            priority = 1000,
        },
        -- {
        --   "metalelf0/black-metal-theme-neovim",
        --   name = "black-metal",
        --   lazy = false,
        --   priority = 1000,
        --   config = function()
        --     -- Can be one of: bathory | burzum | dark-funeral | darkthrone | emperor | gorgoroth | immortal | impaled-nazarene | khold | marduk | mayhem | nile | taake | thyrfing | venom | windir
        --     require("black-metal").setup({
        --       theme = "bathory",
        --       transparent = true,
        --     })
        --     require("black-metal").load()
        --   end,
        -- },
        -- {
        --   "slugbyte/lackluster.nvim",
        --   lazy = false,
        --   priority = 1000,
        --   config = function()
        --     local lackluster = require("lackluster")
        --     lackluster.setup({
        --       tweak_syntax = {
        --         comment = lackluster.color.gray4,
        --       },
        --       tweak_background = {
        --         normal = "none", -- none for transparent or default for solid
        --         telescope = "none",
        --         menu = "none",
        --         popup = "none",
        --       },
        --     })
        --     vim.cmd.colorscheme("lackluster-hack")
        --   end,
        -- },
        {
            "diegoulloao/neofusion.nvim",
            priority = 1000,
            config = true,
            opts = {
                transparent_mode = true,
            },
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
            "LazyVim/LazyVim",
            opts = {
                colorscheme = "monoglow",
            },
        },
    },
}
