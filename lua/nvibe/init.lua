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
  
  -- Create horizontal split
  vim.cmd("split")
  
  -- Run cursor-agent in the top half
  vim.cmd("terminal " .. config.cursor_agent_cmd)
  
  -- Switch to the bottom half
  vim.cmd("wincmd j")
  
  -- Run coderabbit in the bottom half
  vim.cmd("terminal " .. config.coderabbit_cmd)
  
  -- Switch back to the main window
  vim.cmd("wincmd l")
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