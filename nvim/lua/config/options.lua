-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Detect the OS
-- local is_mac = vim.fn.has 'macunix' == 1
-- local is_linux = vim.fn.has 'unix' == 1 and not is_mac
-- local in_tmux = os.getenv 'TMUX' ~= nil
-- local has_xclip = vim.fn.executable 'xclip' == 1

-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = "a"

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`

----vim.schedule(function()
vim.opt.clipboard:append("unnamedplus")
--end)

if vim.fn.has("macunix") == 1 then
  -- macOS clipboard configuration
  -- macOS usually works with the system clipboard out of the box
  -- No additional configuration needed
elseif os.getenv("TMUX") ~= nil then
  -- Use tmux clipboard
  vim.g.clipboard = {
    name = "tmux",
    copy = {
      ["+"] = "tmux load-buffer -",
      ["*"] = "tmux load-buffer -",
    },
    paste = {
      ["+"] = "tmux save-buffer -",
      ["*"] = "tmux save-buffer -",
    },
    cache_enabled = false,
  }
elseif vim.fn.has("unix") == 1 and vim.fn.has("macunix") ~= 1 and vim.fn.executable("xclip") == 1 then
  -- Use xclip for Linux with X11
  vim.g.clipboard = {
    name = "xclip",
    copy = {
      ["+"] = "xclip -selection clipboard",
      ["*"] = "xclip -selection primary",
    },
    paste = {
      ["+"] = "xclip -selection clipboard -o",
      ["*"] = "xclip -selection primary -o",
    },
    cache_enabled = true,
  }
else
  -- Fallback to OSC52 for other cases
  local function copy_osc52(text)
    local encoded = vim.fn.system("base64", text)
    encoded = string.gsub(encoded, "\n", "")
    local osc = string.format("\x1b]52;c;%s\x07", encoded)
    io.stdout:write(osc)
  end

  vim.g.clipboard = {
    name = "osc52",
    copy = {
      ["+"] = function(lines)
        copy_osc52(table.concat(lines, "\n"))
      end,
      ["*"] = function(lines)
        copy_osc52(table.concat(lines, "\n"))
      end,
    },
    paste = {
      ["+"] = function()
        return { vim.fn.getreg("+") }
      end,
      ["*"] = function()
        return { vim.fn.getreg("*") }
      end,
    },
  }
end

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

vim.opt.wrap = true

