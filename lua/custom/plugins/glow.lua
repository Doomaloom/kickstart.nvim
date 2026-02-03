return {
    -- 1. The Mason Plugin Manager (needed to install the binary)
    { "williamboman/mason.nvim", opts = {} },

    -- 2. The Glow Plugin
    {
        "ellisonleao/glow.nvim",
        config = function()
            require("glow").setup({
                install_path = "~/.local/bin", -- Where to install the glow binary
                border = "shadow",     -- Floating window border
                style = "dark",        -- 'dark' or 'light'
                pager = false,         -- Use pager for long output
            })
        end,
        cmd = { "Glow" }, -- Lazy load plugin
    },
}
