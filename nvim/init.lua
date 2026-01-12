-- ==============================
-- Minimal init.lua with custom keymaps
-- ==============================
print("init.lua loaded ✔")

require("config.lazy")

-- ==============
-- Global options
-- ==============

vim.cmd.colorscheme "lunar"
vim.api.nvim_set_hl(0, "Visual", {
  bg = "#3b4252", -- background color
  fg = "NONE",    -- keep text color
})
vim.api.nvim_set_hl(0, "@variable", {
  fg = "#C2687C", })

vim.o.number = true           -- show line numbers
vim.o.expandtab = true        -- use spaces instead of tabs
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.clipboard = "unnamedplus" -- use system clipboard
vim.o.mouse = "a"


-- ==================
-- LSP and Treesitter
-- ==================

-- Lua
vim.lsp.enable('lua_ls')
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lua" },
  callback = function()
    vim.treesitter.start()
  end,
})


-- Bash
vim.lsp.enable('bashls')
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "sh" },
  callback = function()
    vim.treesitter.start()
  end,
})


-- C
vim.lsp.enable('clangd')
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c" },
  callback = function()
    vim.treesitter.start()
  end,
})



-- CSS
vim.lsp.enable('cssls')
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "css" },
  callback = function()
    vim.treesitter.start()
  end,
})


-- Go
vim.lsp.enable('gopls')
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go" },
  callback = function()
    vim.treesitter.start()
  end,
})


-- Rust
vim.lsp.enable('rust_analyzer')
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "rs" },
  callback = function()
    vim.treesitter.start()
  end,
})


-- Global diagnostic config
vim.diagnostic.config({
  virtual_text = true,   -- show inline errors
  signs = true,          -- show gutter signs
  underline = true,      -- underline errors/warnings
  update_in_insert = false, -- only update outside insert mode
  severity_sort = true,
})

vim.diagnostic.config({
  virtual_text = {
    format = function(diagnostic)
      local line = vim.api.nvim_buf_get_lines(
        diagnostic.bufnr,
        diagnostic.lnum,
        diagnostic.lnum + 1,
        false
      )[1]

      if line:match("^%s*$") then
        return nil
      end

      return diagnostic.message
    end,
  },
})


local opts = { noremap = true, silent = true }

vim.g.mapleader = " "

-- Navigation

vim.keymap.set({"n", "v"}, "a", "h", opts)  -- a → left
vim.keymap.set({"n", "v"}, "s", "j", opts)  -- s → down
vim.keymap.set({"n", "v"}, "w", "k", opts)  -- w → up
vim.keymap.set({"n", "v"}, "d", "l", opts)  -- d → right

-- Shift boost
vim.keymap.set({"n", "v"}, "A", "14h", opts)
vim.keymap.set({"n", "v"}, "S", "7j", opts)
vim.keymap.set({"n", "v"}, "W", "7k", opts)
vim.keymap.set({"n", "v"}, "D", "14l", opts)

-- Alt + movement in insert mode
vim.keymap.set({"n","i"}, "<A-i>", "<Up>", opts)        -- Alt+i → up
vim.keymap.set({"n","i"}, "<A-k>", "<Down>", opts)      -- Alt+k → down
vim.keymap.set({"n","i"}, "<A-j>", "<Left>", opts)      -- Alt+j → left
vim.keymap.set({"n","i"}, "<A-l>", "<Right>", opts)     -- Alt+l → right

-- helper function to repeat a key in insert mode
local function repeat_key(key, times)
  for _ = 1, times do
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), "n", false)
  end
end

-- Shift boost
vim.keymap.set({"n","i"}, "<A-I>", function() repeat_key("<Up>", 7) end, opts)
vim.keymap.set({"n","i"}, "<A-K>", function() repeat_key("<Down>", 7) end, opts)
vim.keymap.set({"n","i"}, "<A-J>", function() repeat_key("<Left>", 14) end, opts)
vim.keymap.set({"n","i"}, "<A-L>", function() repeat_key("<Right>", 14) end, opts)

-- Alt + Arrow boost
vim.keymap.set({"n","i"}, "<A-Up>",    function() repeat_key("<Up>", 7) end, opts)
vim.keymap.set({"n","i"}, "<A-Down>",  function() repeat_key("<Down>", 7) end, opts)
vim.keymap.set({"n","i"}, "<A-Left>",  function() repeat_key("<Left>", 14) end, opts)
vim.keymap.set({"n","i"}, "<A-Right>", function() repeat_key("<Right>", 14) end, opts)

-- ==============================
-- Save / Cancel / Quit
-- ==============================
vim.keymap.set({"n", "i", "v"}, "<C-s>", "<Esc>:w<CR>", opts)   -- save
vim.keymap.set({"n", "i", "v"}, "<C-z>", "<Esc>:undo<CR>", opts) -- cancel / undo
vim.keymap.set({"n", "i", "v"}, "<C-q>", "<Esc>:q!<CR>", opts)   -- quit

-- ==============================
-- Clipboard
-- ==============================
vim.keymap.set({"n", "v", "v"}, "<C-c>", '"+y', opts)  -- copy
vim.keymap.set({"n", "v", "v"}, "<C-x>", '"+d', opts)  -- cut
vim.keymap.set("i", "<C-v>", '<C-r>+', opts) -- paste in insert mode
vim.keymap.set("n", "<C-v>", '"+p', opts)  -- paste in normal mode
vim.keymap.set("v", "<C-v>", '"+p', opts)  -- Paste over selection
vim.keymap.set("v", "<leader>d", '"_d', opts) -- Destroy selection

-- Ctrl+V paste literally
vim.keymap.set({"n", "i", "v"}, "<C-S-v>", function()
    -- paste literally from system clipboard
    vim.api.nvim_put({vim.fn.getreg("+")}, "c", true, true)
end, opts)

-- Mode switches
vim.keymap.set("n", "e", "i", opts)
vim.keymap.set("i", "<M-e>", "<Esc>", opts)
vim.keymap.set("i", "<C-e>", "<Esc>", opts)

-- Custom macro binds

local function PrependRange(start_line, end_line, symbol)
  for i = start_line, end_line do
    local line = vim.fn.getline(i)
    vim.fn.setline(i, symbol .. line)
  end
end

-- Create the command with a single-char splitter
vim.api.nvim_create_user_command(
  "Prepend",
  function(opts)
    local arg = opts.args
    local symbol

    -- If the first char is the separator, take the rest as symbol
    -- Example: :Prepend /-- → symbol = "--"
    if #arg > 1 then
      local sep = arg:sub(1,1)
      symbol = arg:sub(2)
    else
      -- fallback if no separator: use the whole arg
      symbol = arg
    end

    -- Convert \t and \s if used
    symbol = symbol:gsub("\\t", "\t"):gsub("\\s", " ")

    PrependRange(opts.line1, opts.line2, symbol)
  end,
  { nargs = 1, range = true }
)
-- 


-- Visual mode keymap to prepend with auto-splitter
vim.keymap.set("v", "<leader>p", function()
  -- Get the current visual selection range
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")

  -- Build the command with the range
  local cmd = string.format(":'%d,'%dPrepend /", start_line, end_line)

  -- Feed the command into the command line (wait for user to type argument)
  vim.fn.feedkeys(cmd, "n")
end, { noremap = true, silent = false, desc = "Prepend with splitter" })


-- Function to remove first character from a line range
local function remove_first_char(start_line, end_line)
  for i = start_line, end_line do
    local line = vim.fn.getline(i)
    if #line > 0 then
      vim.fn.setline(i, line:sub(2))
    end
  end
end

-- Keymap for visual mode
vim.keymap.set("v", "<leader>r", function()
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")
  remove_first_char(start_line, end_line)
end, { noremap = true, silent = true, desc = "Remove first char from selection" })

-- ==============================
-- Done!
-- ==============================
--print("Custom keymaps loaded ✔")
