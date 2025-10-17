-- Nvibe Plugin for Neovim
-- Opens a terminal pane on the left with cursor-agent and coderabbit

local M = {}

-- Configuration
local config = {
  width_percent = 30,
  cursor_agent_cmd = "cursor-agent",
  coderabbit_cmd = "coderabbit",
}

-- Function to get terminal width based on $COLS
local function get_terminal_width()
  local cols = os.getenv("COLS")
  if cols then
    return math.floor(tonumber(cols) * (config.width_percent / 100))
  else
    -- Fallback to 30% of current window width
    return math.floor(vim.o.columns * (config.width_percent / 100))
  end
end

-- Function to create the terminal split
function M.create_terminal_split()
  -- Get the calculated width
  local width = get_terminal_width()
  
  -- Create vertical split to the left
  vim.cmd("leftabove vnew")
  
  -- Set the width
  vim.cmd("vertical resize " .. width)
  
  -- Create cursor-agent terminal in top-left using NvChad method
  require("nvchad.term").new {
    pos = "sp",
    cmd = config.cursor_agent_cmd,
    size = 0.5  -- 50% of the left panel
  }
  
  -- Create coderabbit terminal in bottom-left using NvChad method
  require("nvchad.term").new {
    pos = "sp", 
    cmd = config.coderabbit_cmd,
    size = 0.5  -- 50% of the left panel
  }
  
  -- Close the empty buffer above cursor-agent (go up twice to get to the empty editor)
  vim.cmd("wincmd k")
  vim.cmd("wincmd k")
  vim.cmd("close")
  
  -- Switch back to main window (right side)
  vim.cmd("wincmd l")
  
  -- Exit insert mode if we're in it
  vim.cmd("stopinsert")
end

-- Function to setup the plugin
function M.setup(opts)
  if opts then
    config = vim.tbl_deep_extend("force", config, opts)
  end
  
  -- Create autocmd to run on VimEnter
  vim.api.nvim_create_autocmd("VimEnter", {
    pattern = "*",
    callback = function()
      -- Only run if we're not in a terminal buffer already
      if vim.bo.buftype ~= "terminal" then
        M.create_terminal_split()
      end
    end,
  })
end

return M