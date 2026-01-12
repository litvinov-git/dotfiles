-- ==========================
-- Bootstrap lazy.nvim
-- ==========================

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- ==========================
-- lazy.nvim plugin setup
-- ==========================

require("lazy").setup({

  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      require('nvim-treesitter').setup {
        install_dir = vim.fn.stdpath('data').. '/site',
      }
      require'nvim-treesitter'.install { 'rust', 'python', 'zig', 'bash', 'c', 'lua', 'hyprlang' }
    end
    },

   {
     "neovim/nvim-lspconfig",
   },

   {
      "mason-org/mason.nvim",
      opts = {}

   },


  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- Library paths can be absolute
        "~/projects/my-awesome-lib",
        -- Or relative, which means they will be resolved from the plugin dir.
        "lazy.nvim",
        -- It can also be a table with trigger words / mods
        -- Only load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        -- always load the LazyVim library
        "LazyVim",
        -- Only load the lazyvim library when the `LazyVim` global is found
        { path = "LazyVim", words = { "LazyVim" } },
        -- Load the wezterm types when the `wezterm` module is required
        -- Needs `DrKJeff16/wezterm-types` to be installed
        { path = "wezterm-types", mods = { "wezterm" } },
        -- Load the xmake types when opening file named `xmake.lua`
        -- Needs `LelouchHe/xmake-luals-addon` to be installed
        { path = "xmake-luals-addon/library", files = { "xmake.lua" } },
      },
      -- always enable unless `vim.g.lazydev_enabled = false`
      -- This is the default
      enabled = function(root_dir)
        return vim.g.lazydev_enabled == nil and true or vim.g.lazydev_enabled
      end,
    },
  },

  {
    "RRethy/vim-illuminate",
  },

  {
    "lunarvim/lunar.nvim",
  },

  { "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
     require("catppuccin").setup({
         flavour = "mocha"
     })
    end
  },

  -- Autocompletion
  { "hrsh7th/nvim-cmp",
    config = function()
        require("cmp").setup{
          performance = {
            max_view_entries = 5,
            debounce = 60,
            throttle = 30,
            fetching_timeout = 200,
            filtering_context_budget = 3,
            confirm_resolve_timeout = 80,
            async_budget = 1,
          },
        }
    end
  },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "hrsh7th/cmp-cmdline" },
  { "L3MON4D3/LuaSnip" },
  { "saadparwaiz1/cmp_luasnip" },
})

-- ==========================
-- nvim-cmp setup
-- ==========================

local cmp_ok, cmp = pcall(require, "cmp")
if cmp_ok then
  cmp.setup({
    snippet = {
      expand = function(args)
        require("luasnip").lsp_expand(args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ["<C-b>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({
      { name = "nvim_lsp" },
      { name = "luasnip" },
    }, {
      { name = "buffer" },
    }),
  })
end


