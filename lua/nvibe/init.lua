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
	width_percent = 20,
	cursor_agent_cmd = "cursor-agent",
	coderabbit_cmd = "coderabbit",
}

---Cached NvChad term module
---@type table|nil
local nvchad_term = nil

---Main editor window ID (tracked after layout creation)
---@type number|nil
local main_editor_win = nil

---Cached editor-row height (used to constrain NvimTree, issues #4 #5)
---@type number|nil
local editor_height_cache = nil

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
			"Nvibe Error: nvchad.term module not available!\n\n"
				.. "Nvibe requires NvChad to function properly.\n"
				.. "Please install NvChad: https://github.com/NvChad/NvChad",
			vim.log.levels.ERROR,
			{ title = "Nvibe - Missing Dependency" }
		)
		return
	end

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

	-- Switch back to main window (right side)
	vim.cmd("wincmd l")

	vim.cmd("belowright split")
	vim.cmd("resize " .. math.floor(vim.o.lines * 0.2))

	vim.cmd("belowright vnew")
	vim.cmd("vertical resize " .. math.floor(vim.o.columns * 0.33))

	-- -- Create lazygit terminal full width of the bottom panel.
	local success3, err3 = pcall(function()
		nvchad_term.new({
			pos = "sp",
			cmd = "lazygit",
			size = 0.2, -- Full height of bottom panel
		})
	end)

	if not success3 then
		vim.notify(
			"Nvibe Error: Failed to create lazygit terminal\n\n" .. "Command: lazygit\n" .. "Error: " .. tostring(err3),
			vim.log.levels.ERROR,
			{ title = "Nvibe - Terminal Creation Failed" }
		)
	end

	-- Switch to left side of bottom panel
	-- vim.cmd("wincmd k")
	vim.cmd("wincmd k")
	vim.cmd("close")
	vim.cmd("wincmd h")
	vim.cmd("resize " .. math.floor(vim.o.lines * 0.2))
	--
	vim.cmd("belowright vnew")
	-- vim.cmd("vertical resize " .. math.floor(vim.o.columns * 0.5))
	--
	local success4, err4 = pcall(function()
		nvchad_term.new({
			pos = "sp",
			cmd = vim.o.shell, -- Use user's default shell
			size = 0.2, -- Full height of bottom panel
		})
	end)

	if not success4 then
		vim.notify(
			"Nvibe Error: Failed to create shell terminal\n\n"
				.. "Shell: "
				.. vim.o.shell
				.. "\n"
				.. "Error: "
				.. tostring(err4),
			vim.log.levels.ERROR,
			{ title = "Nvibe - Terminal Creation Failed" }
		)
	end

	vim.cmd("wincmd k")
	vim.cmd("close")
	vim.cmd("wincmd h")
	vim.cmd("resize " .. math.floor(vim.o.lines * 0.2))

	local success5, err5 = pcall(function()
		nvchad_term.new({
			pos = "sp",
			cmd = vim.o.shell, -- Use user's default shell
			size = 0.2, -- Full height of bottom panel
		})
	end)

	if not success5 then
		vim.notify(
			"Nvibe Error: Failed to create shell terminal\n\n"
				.. "Shell: "
				.. vim.o.shell
				.. "\n"
				.. "Error: "
				.. tostring(err5),
			vim.log.levels.ERROR,
			{ title = "Nvibe - Terminal Creation Failed" }
		)
	end

	vim.cmd("wincmd k")
	vim.cmd("close")
	vim.cmd("resize " .. math.floor(vim.o.lines * 0.2))
	vim.cmd("wincmd k")

	vim.cmd("stopinsert")
end

---Restores nvibe terminal panel widths after external plugins (e.g. NvimTree) disrupt layout
---@return nil
function M.rebalance_panels()
	local width = get_terminal_width()
	-- Resize the left terminal panel (cursor-agent / coderabbit windows)
	-- We do this by finding windows whose buftype is "terminal" on the left column
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_is_valid(win) then
			local pos = vim.api.nvim_win_get_position(win)
			local bt = vim.bo[vim.api.nvim_win_get_buf(win)].buftype
			-- Left-column terminal windows (col 0) belong to nvibe's side panel
			if pos[2] == 0 and bt == "terminal" then
				vim.api.nvim_win_set_width(win, width)
			end
		end
	end
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
				-- Capture editor window + height after layout is built (for NvimTree fix)
				vim.defer_fn(function()
					main_editor_win = vim.api.nvim_get_current_win()
					editor_height_cache = vim.api.nvim_win_get_height(main_editor_win)
				end, 300)
			end
		end,
	})

	-- NvimTree integration: prevent full-height takeover and layout breakage
	-- Fixes issues #4 (window rebalancing breaks layout) and #5 (full height)
	local nvimtree_group = vim.api.nvim_create_augroup("NvibeNvimTree", { clear = true })

	-- When NvimTree opens: constrain its height to the editor row only
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "NvimTree",
		group = nvimtree_group,
		callback = function()
			vim.defer_fn(function()
				local tree_win = vim.api.nvim_get_current_win()
				-- Use cached editor height (set when layout was created)
				if editor_height_cache and vim.api.nvim_win_is_valid(tree_win) then
					vim.api.nvim_win_set_height(tree_win, editor_height_cache)
				end
				-- Restore nvibe panel widths after NvimTree opens
				M.rebalance_panels()
			end, 50)
		end,
	})

	-- When NvimTree closes: restore nvibe panel widths
	vim.api.nvim_create_autocmd({ "BufWinLeave", "BufUnload" }, {
		group = nvimtree_group,
		callback = function()
			if vim.bo[vim.api.nvim_get_current_buf()].filetype == "NvimTree" then
				vim.defer_fn(M.rebalance_panels, 50)
			end
		end,
	})
end

return M
