---@meta

---@class NvibeConfig
---@field width_percent number Percentage of screen width for terminal panel (default: 30)
---@field cursor_agent_cmd string Command to run cursor-agent (default: "cursor-agent")
---@field coderabbit_cmd string Command to run coderabbit (default: "coderabbit")

---@class NvibeModule
---@field create_terminal_split fun(): nil Creates the terminal split layout
---@field create_bottom_panel fun(): nil Creates the bottom panel with shell
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

---Cached NvChad term module
---@type table|nil
local nvchad_term = nil

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
  -- Check if NvChad term module is available
  if not nvchad_term then
    vim.notify(
      "Nvibe Error: nvchad.term module not available!\n\n" ..
      "Nvibe requires NvChad to function properly.\n" ..
      "Please install NvChad: https://github.com/NvChad/NvChad",
      vim.log.levels.ERROR,
      { title = "Nvibe - Missing Dependency" }
    )
    return
  end

  -- Validate that required commands are executable
  if vim.fn.executable(config.cursor_agent_cmd) ~= 1 then
    vim.notify(
      "Nvibe Error: cursor-agent command not found!\n\n" ..
      "Command: " .. config.cursor_agent_cmd .. "\n" ..
      "Please install cursor-agent or update the cursor_agent_cmd configuration.",
      vim.log.levels.ERROR,
      { title = "Nvibe - Command Not Found" }
    )
    return
  end

  if vim.fn.executable(config.coderabbit_cmd) ~= 1 then
    vim.notify(
      "Nvibe Error: coderabbit command not found!\n\n" ..
      "Command: " .. config.coderabbit_cmd .. "\n" ..
      "Please install coderabbit or update the coderabbit_cmd configuration.",
      vim.log.levels.ERROR,
      { title = "Nvibe - Command Not Found" }
    )
    return
  end

  -- Get the calculated width
  local width = get_terminal_width()
  
  -- Create vertical split to the left
  vim.cmd("leftabove vnew")
  
  -- Set the width
  vim.cmd("vertical resize " .. width)
  
  -- Create cursor-agent terminal in top-left using NvChad method
  local success, err = pcall(function()
    nvchad_term.new {
      pos = "sp",
      cmd = config.cursor_agent_cmd,
      size = 0.5  -- 50% of the left panel
    }
  end)
  
  if not success then
    vim.notify(
      "Nvibe Error: Failed to create cursor-agent terminal\n\n" ..
      "Command: " .. config.cursor_agent_cmd .. "\n" ..
      "Error: " .. tostring(err),
      vim.log.levels.ERROR,
      { title = "Nvibe - Terminal Creation Failed" }
    )
  end
  
  -- Create coderabbit terminal in bottom-left using NvChad method
  local success2, err2 = pcall(function()
    nvchad_term.new {
      pos = "sp", 
      cmd = config.coderabbit_cmd,
      size = 0.5  -- 50% of the left panel
    }
  end)
  
  if not success2 then
    vim.notify(
      "Nvibe Error: Failed to create coderabbit terminal\n\n" ..
      "Command: " .. config.coderabbit_cmd .. "\n" ..
      "Error: " .. tostring(err2),
      vim.log.levels.ERROR,
      { title = "Nvibe - Terminal Creation Failed" }
    )
  end
  
  -- Close the empty buffer above cursor-agent (go up twice to get to the empty editor)
  vim.cmd("wincmd k")
  vim.cmd("wincmd k")
  vim.cmd("close")
  
  -- Switch back to main window (right side)
  vim.cmd("wincmd l")

  -- Create bottom panel
  M.create_bottom_panel()

  -- Switch back to main window (top area)
  vim.cmd("wincmd k")

  -- Exit insert mode if we're in it
  vim.cmd("stopinsert")
end

---Creates the bottom panel with a shell terminal
---
---This function:
---1. Creates a horizontal split at the bottom
---2. Resizes the bottom panel to 20% of screen height
---3. Launches a shell terminal (same as <leader>h)
---4. Returns focus to the main editor window
---
---@return nil
function M.create_bottom_panel()
  -- Check if NvChad term module is available
  if not nvchad_term then
    vim.notify(
      "Nvibe Error: nvchad.term module not available!\n\n" ..
      "Nvibe requires NvChad to function properly.\n" ..
      "Please install NvChad: https://github.com/NvChad/NvChad",
      vim.log.levels.ERROR,
      { title = "Nvibe - Missing Dependency" }
    )
    return
  end

  -- Create horizontal split at the bottom
  vim.cmd("belowright split")
  
  -- Set the height to 20% of screen
  vim.cmd("resize " .. math.floor(vim.o.lines * 0.2))
  
  -- Create shell terminal using NvChad method
  local success, err = pcall(function()
    nvchad_term.new {
      pos = "sp",
      cmd = vim.o.shell,  -- Use user's default shell
      size = 1.0  -- Full width of bottom panel
    }
  end)
  
  if not success then
    vim.notify(
      "Nvibe Error: Failed to create bottom terminal\n\n" ..
      "Shell: " .. vim.o.shell .. "\n" ..
      "Error: " .. tostring(err),
      vim.log.levels.ERROR,
      { title = "Nvibe - Terminal Creation Failed" }
    )
  end
  
  -- Switch back to main window (top area)
  vim.cmd("wincmd k")
  
  -- Exit insert mode if we're in it
  vim.cmd("stopinsert")
end

---Initializes the Nvibe plugin with optional configuration
---
---This function sets up the plugin by:
---1. Checking for required dependencies (NvChad)
---2. Merging user-provided options with default configuration
---3. Creating an autocmd that runs on VimEnter
---4. Ensuring the terminal split only runs when not already in a terminal buffer
---
---@param opts NvibeConfig|nil Optional configuration table
---@return nil
function M.setup(opts)
  -- Check for NvChad dependency first and store the module
  local success, term_module = pcall(require, "nvchad.term")
  if not success then
    vim.notify(
      "Nvibe Setup Error: nvchad.term module not found!\n\n" ..
      "Nvibe requires NvChad to function properly.\n" ..
      "Please install NvChad: https://github.com/NvChad/NvChad\n\n" ..
      "Error: " .. tostring(term_module),
      vim.log.levels.ERROR,
      { title = "Nvibe - Missing Dependency" }
    )
    return
  end
  
  -- Store the module for reuse
  nvchad_term = term_module

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