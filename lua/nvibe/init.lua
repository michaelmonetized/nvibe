---@meta

---@class NvibeConfig
---@field width_percent number Percentage of screen width for terminal panel (default: 30)
---@field cursor_agent_cmd string Command to run cursor-agent (default: "cursor-agent")
---@field coderabbit_cmd string Command to run coderabbit (default: "coderabbit")

---@class NvibeModule
---@field create_terminal_split fun(): nil Creates the terminal split layout
---@field setup fun(opts?: NvibeConfig): nil Initializes the plugin with optional configuration

-- Nvibe Plugin for Neovim
-- Opens a terminal pane on the left with cursor-agent and coderabbit
-- 
-- This plugin automatically creates a split terminal layout on Neovim startup,
-- with cursor-agent running in the top terminal and coderabbit in the bottom terminal.
-- The terminal panel takes up 30% of the screen width by default.

local M = {}

---Default configuration for the Nvibe plugin
---@type NvibeConfig
local config = {
  width_percent = 30,
  cursor_agent_cmd = "cursor-agent",
  coderabbit_cmd = "coderabbit",
}

---Calculates the terminal panel width based on environment or current window
---@return number The calculated width in columns
local function get_terminal_width()
  local cols = os.getenv("COLS")
  if cols then
    return math.floor(tonumber(cols) * (config.width_percent / 100))
  else
    -- Fallback to 30% of current window width
    return math.floor(vim.o.columns * (config.width_percent / 100))
  end
end

---Creates the terminal split layout with cursor-agent and coderabbit
---
---This function:
---1. Creates a vertical split to the left of the current window
---2. Resizes the left panel to the calculated width
---3. Creates cursor-agent terminal in the top half
---4. Creates coderabbit terminal in the bottom half
---5. Closes any empty editor buffers
---6. Returns focus to the main editor window
---
---@return nil
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

---Initializes the Nvibe plugin with optional configuration
---
---This function sets up the plugin by:
---1. Merging user-provided options with default configuration
---2. Creating an autocmd that runs on VimEnter
---3. Ensuring the terminal split only runs when not already in a terminal buffer
---
---@param opts NvibeConfig|nil Optional configuration table
---@return nil
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