-- ── Neovim — Catppuccin Mocha ──────────────────────────────────
-- Freyr workstation config — Lua-based, minimal

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ── Options ────────────────────────────────────────────────────
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.background = "dark"
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.showmatch = true
vim.opt.matchtime = 2
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.autoindent = true
vim.opt.laststatus = 2
vim.opt.scrolloff = 999  -- "set so=999"  — keep cursor centered
vim.opt.mouse = "a"

-- ── Minimal plugin manager (lazy.nvim bootstrap) ──────────────
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- Catppuccin theme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = false,
      integrations = {
        treesitter = true,
        native_lsp = { enabled = true },
        which_key = true,
        telescope = true,
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin-mocha")
    end,
  },

  -- Lightline
  {
    "itchyny/lightline.vim",
    lazy = false,
    config = function()
      vim.g.lightline = {
        colorscheme = "catppuccin",
        active = {
          left = { { "mode", "paste" }, { "readonly", "filename", "modified" } },
          right = { { "lineinfo" }, { "percent" }, { "filetype" } },
        },
        component = { lineinfo = "⧗ %3l:%-2v" },
        component_function = {
          readonly = "LightlineReadonly",
          filename = "LightlineFilename",
        },
      }
      vim.cmd([[
        function! LightlineReadonly()
          return &readonly ? "⛔" : ""
        endfunction
        function! LightlineFilename()
          return expand("%:t") !=# "" ? expand("%:t") . (&modified ? " +" : "") : "[No Name]"
        endfunction
      ]])
    end,
  },

  -- Treesitter
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- Telescope
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },

  -- Which-key
  { "folke/which-key.nvim" },
})

-- ── Keymaps ────────────────────────────────────────────────────
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>")
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>")
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>")
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>")
