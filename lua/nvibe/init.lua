---@meta

---@class NvibeConfig
---@field width_percent number Percentage of screen width for terminal panel (default: 20)
---@field cursor_agent_cmd string Command to run cursor-agent (default: "cursor-agent")
---@field coderabbit_cmd string Command to run coderabbit (default: "coderabbit")
---@field bottom_panel_height_percent number Percentage of screen height for bottom panel (default: 20)
---@field lazygit_cmd string Command to run lazygit (default: "lazygit")
---@field shell_cmd string Command to run shell terminals (default: vim.o.shell)
---@field bottom_panel_terminals table Array of terminal configurations for bottom panel

---@class NvibeModule
---@field create_terminal_split fun(): nil Creates the terminal split layout
---@field create_bottom_panel fun(): nil Creates the bottom panel with configurable terminals
---@field setup fun(opts?: NvibeConfig): nil Initializes the plugin with optional configuration

-- Nvibe Plugin for Neovim
-- Creates a comprehensive coding environment with AI assistants and development tools
--
-- This plugin automatically creates a split terminal layout on Neovim startup:
-- - Left panel: Cursor Agent (top) and CodeRabbit (bottom) - AI assistants
-- - Bottom panel: Configurable terminals (LazyGit, Shell terminals) - development tools
-- - Main editor: Takes up the remaining space for your code
--
-- All panel sizes and terminal commands are configurable via the setup function.

local M = {}

---Default configuration for the Nvibe plugin
---@type NvibeConfig
local config = {
	width_percent = 20,
	cursor_agent_cmd = "cursor-agent",
	coderabbit_cmd = "coderabbit",
	bottom_panel_height_percent = 20,
	lazygit_cmd = "lazygit",
	shell_cmd = vim.o.shell,
	bottom_panel_terminals = {
		{ cmd = "lazygit", name = "LazyGit" },
		{ cmd = vim.o.shell, name = "Shell 1" },
		{ cmd = vim.o.shell, name = "Shell 2" },
	},
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
		-- Fallback to configured percentage of current window width
		return math.floor(vim.o.columns * (config.width_percent / 100))
	end
end

---Calculates the bottom panel height based on configuration
---@return number The calculated height in lines
local function get_bottom_panel_height()
	local lines = os.getenv("LINES")
	if lines then
		return math.floor(tonumber(lines) * (config.bottom_panel_height_percent / 100))
	else
		-- Fallback to configured percentage of current window height
		return math.floor(vim.o.lines * (config.bottom_panel_height_percent / 100))
	end
end

---Creates the terminal split layout with cursor-agent and coderabbit
---
---This function:
---1. Sends <leader>e to open nvimtree and trigger window balancing
---2. Switches back to editor to reset window layout
---3. Creates a vertical split to the left of the current window
---4. Resizes the left panel to the calculated width
---5. Creates cursor-agent terminal in the top half
---6. Creates coderabbit terminal in the bottom half
---7. Closes any empty editor buffers
---8. Returns focus to the main editor window
---
---@return nil
function M.create_terminal_split()
	-- Check if NvChad term module is available
	if not nvchad_term then
		vim.notify(
			"Nvibe Error: nvchad.term module not available!\n\n"
				.. "Nvibe requires NvChad to function properly.\n"
				.. "Please install NvChad: https://github.com/NvChad/NvChad",
			vim.log.levels.ERROR,
			{ title = "Nvibe - Missing Dependency" }
		)
		return
	end

	-- Try to open nvimtree and trigger window balancing
	-- This prevents nvimtree from balancing windows later and breaking our layout
	local success, nvimtree = pcall(require, "nvim-tree.api")
	if success and nvimtree.tree then
		-- Use nvimtree API directly
		nvimtree.tree.toggle()
		vim.notify("1", vim.log.levels.INFO, { title = "Nvibe - NvimTree Toggled" })
	else
		-- Try alternative nvimtree require patterns
		local success2, nvimtree2 = pcall(require, "nvim-tree")
		if success2 and nvimtree2.toggle then
			nvimtree2.toggle()
			vim.notify("2", vim.log.levels.INFO, { title = "Nvibe - NvimTree Toggled" })
		else
			-- Try the old nvim-tree pattern
			local success3, nvimtree3 = pcall(require, "nvim-tree.api.tree")
			if success3 and nvimtree3.toggle then
				nvimtree3.toggle()
				vim.notify("3", vim.log.levels.INFO, { title = "Nvibe - NvimTree Toggled" })
			else
				-- Try using the NvimTreeToggle command directly
				local success4, _ = pcall(vim.cmd, "NvimTreeToggle")
				if not success4 then
					-- Fallback to keybind simulation
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<leader>e", true, false, true), "n", true)
					vim.notify("4", vim.log.levels.INFO, { title = "Nvibe - NvimTree Toggled" })
				end
			end
		end
	end

	-- Switch back to the editor to reset the window layout
	-- This ensures we start with a clean slate for our terminal layout
	vim.cmd("wincmd h")

	-- Validate that required commands are executable
	if vim.fn.executable(config.cursor_agent_cmd) ~= 1 then
		vim.notify(
			"Nvibe Error: cursor-agent command not found!\n\n"
				.. "Command: "
				.. config.cursor_agent_cmd
				.. "\n"
				.. "Please install cursor-agent or update the cursor_agent_cmd configuration.",
			vim.log.levels.ERROR,
			{ title = "Nvibe - Command Not Found" }
		)
		return
	end

	if vim.fn.executable(config.coderabbit_cmd) ~= 1 then
		vim.notify(
			"Nvibe Error: coderabbit command not found!\n\n"
				.. "Command: "
				.. config.coderabbit_cmd
				.. "\n"
				.. "Please install coderabbit or update the coderabbit_cmd configuration.",
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
		nvchad_term.new({
			pos = "sp",
			cmd = config.cursor_agent_cmd,
			size = 0.5, -- 50% of the left panel
		})
	end)

	if not success then
		vim.notify(
			"Nvibe Error: Failed to create cursor-agent terminal\n\n"
				.. "Command: "
				.. config.cursor_agent_cmd
				.. "\n"
				.. "Error: "
				.. tostring(err),
			vim.log.levels.ERROR,
			{ title = "Nvibe - Terminal Creation Failed" }
		)
	end

	-- Create coderabbit terminal in bottom-left using NvChad method
	local success2, err2 = pcall(function()
		nvchad_term.new({
			pos = "sp",
			cmd = config.coderabbit_cmd,
			size = 0.5, -- 50% of the left panel
		})
	end)

	if not success2 then
		vim.notify(
			"Nvibe Error: Failed to create coderabbit terminal\n\n"
				.. "Command: "
				.. config.coderabbit_cmd
				.. "\n"
				.. "Error: "
				.. tostring(err2),
			vim.log.levels.ERROR,
			{ title = "Nvibe - Terminal Creation Failed" }
		)
	end

	-- Close the empty buffer above cursor-agent (go up twice to get to the empty editor)
	vim.cmd("wincmd k")
	vim.cmd("wincmd k")
	vim.cmd("close")
	vim.cmd("vertical resize " .. width)

	-- Switch back to main window (right side)
	vim.cmd("wincmd l")

	-- Create the bottom panel with configurable terminals
	M.create_bottom_panel()

	vim.cmd("wincmd h")
	vim.cmd("vertical resize " .. width)
	vim.cmd("wincmd l")
	vim.cmd("stopinsert")
end

---Creates the bottom panel with configurable terminals
---
---This function creates a bottom panel with terminals configured via the
---bottom_panel_terminals configuration option. Each terminal can have
---its own command and name for error reporting.
function M.create_bottom_panel()
	-- Check if nvchad.term is available
	if not nvchad_term then
		vim.notify(
			"Nvibe Error: nvchad.term module not found\n\n"
				.. "Please ensure NvChad is installed and loaded.\n"
				.. "Nvibe requires the nvchad.term module to create terminals.",
			vim.log.levels.ERROR,
			{ title = "Nvibe - Missing Dependency" }
		)
		return
	end

	local bottom_height = get_bottom_panel_height()
	local terminal_count = #config.bottom_panel_terminals

	-- Create bottom split
	vim.cmd("belowright split")
	vim.cmd("resize " .. bottom_height)

	-- Create terminals in the bottom panel
	for i, terminal_config in ipairs(config.bottom_panel_terminals) do
		-- Create vertical split for each terminal (except the first one)
		if i > 1 then
			vim.cmd("belowright vnew")
			-- Calculate width for each terminal (equal distribution)
			local terminal_width = math.floor(vim.o.columns / terminal_count)
			vim.cmd("vertical resize " .. terminal_width)
		end

		-- Create the terminal
		local success, err = pcall(function()
			nvchad_term.new({
				pos = "sp",
				cmd = terminal_config.cmd,
				size = config.bottom_panel_height_percent / 100, -- Convert percentage to decimal
			})
		end)

		if not success then
			vim.notify(
				"Nvibe Error: Failed to create " .. (terminal_config.name or "terminal") .. "\n\n"
					.. "Command: " .. terminal_config.cmd .. "\n"
					.. "Error: " .. tostring(err),
				vim.log.levels.ERROR,
				{ title = "Nvibe - Terminal Creation Failed" }
			)
		end

		-- Move to next terminal position
		if i < terminal_count then
			vim.cmd("wincmd k")
			vim.cmd("close")
			vim.cmd("wincmd h")
			vim.cmd("resize " .. bottom_height)
		end
	end

	-- Final cleanup and positioning
	vim.cmd("wincmd k")
	vim.cmd("close")
	vim.cmd("resize " .. bottom_height)
	vim.cmd("wincmd k")
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
			"Nvibe Setup Error: nvchad.term module not found!\n\n"
				.. "Nvibe requires NvChad to function properly.\n"
				.. "Please install NvChad: https://github.com/NvChad/NvChad\n\n"
				.. "Error: "
				.. tostring(term_module),
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
