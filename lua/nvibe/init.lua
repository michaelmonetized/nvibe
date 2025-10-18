---@meta

---@class NvibeConfig
---@field width_percent number Percentage of screen width for terminal panel (default: 20)
---@field cursor_agent_cmd string Command to run cursor-agent (default: "cursor-agent")
---@field coderabbit_cmd string Command to run coderabbit (default: "coderabbit")
---@field bottom_panel_height_percent number Percentage of screen height for bottom panel (default: 20)
---@field lazygit_cmd string Command to run lazygit (default: "lazygit")
---@field shell_cmd string Command to run shell terminals (default: vim.o.shell)
---@field bottom_panel_terminals table Array of terminal configurations for bottom panel
---@field watch_leader_e boolean Whether to watch for <leader>e and restore layout (default: true)
---@field auto_restore_layout boolean Whether to automatically restore layout after nvimtree operations (default: true)
---@field toggle_minimap boolean Whether to toggle minimap before nvimtree if buffer is not empty (default: true)

---@class NvibeModule
---@field create_terminal_split fun(): nil Creates the terminal split layout
---@field create_bottom_panel fun(): nil Creates the bottom panel with configurable terminals
---@field restore_layout fun(): nil Manually restores the Nvibe layout
---@field setup fun(opts?: NvibeConfig): nil Initializes the plugin with optional configuration

-- Nvibe Plugin for Neovim
-- Creates a comprehensive coding environment with AI assistants and development tools
--
-- This plugin automatically creates a split terminal layout on Neovim startup:
-- - Left panel: Cursor Agent (top) and CodeRabbit (bottom) - AI assistants
-- - Bottom panel: Configurable terminals (LazyGit, Shell terminals) - development tools
-- - Main editor: Takes up the remaining space for your code
--
-- Features:
-- - All panel sizes and terminal commands are configurable
-- - Automatic layout restoration when <leader>e is pressed
-- - Smart window management that prevents layout breaking
-- - Manual layout restoration via M.restore_layout()

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
	watch_leader_e = true,
	auto_restore_layout = true,
	toggle_minimap = true,
}

---Cached NvChad term module
---@type table|nil
local nvchad_term = nil

---Layout state tracking
---@type table
local layout_state = {
	initialized = false,
	left_panel_width = 0,
	bottom_panel_height = 0,
	original_leader_e_mapping = nil,
}

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

---Saves the current layout state for restoration
---@return nil
local function save_layout_state()
	layout_state.left_panel_width = get_terminal_width()
	layout_state.bottom_panel_height = get_bottom_panel_height()
	layout_state.initialized = true
end

---Restores the Nvibe layout after nvimtree operations
---@return nil
local function restore_layout()
	if not layout_state.initialized then
		return
	end

	-- Get all windows and identify the layout
	local windows = vim.api.nvim_list_wins()
	local left_panel_wins = {}
	local bottom_panel_wins = {}
	local main_editor_win = nil

	-- Categorize windows by their position and size
	for _, win in ipairs(windows) do
		local win_config = vim.api.nvim_win_get_config(win)
		local width = vim.api.nvim_win_get_width(win)
		local height = vim.api.nvim_win_get_height(win)
		
		-- Check if this looks like our left panel (narrow width)
		if width <= layout_state.left_panel_width + 5 and width >= layout_state.left_panel_width - 5 then
			table.insert(left_panel_wins, win)
		-- Check if this looks like our bottom panel (short height)
		elseif height <= layout_state.bottom_panel_height + 5 and height >= layout_state.bottom_panel_height - 5 then
			table.insert(bottom_panel_wins, win)
		-- This is likely the main editor
		else
			main_editor_win = win
		end
	end

	-- Restore left panel width
	for _, win in ipairs(left_panel_wins) do
		vim.api.nvim_win_set_width(win, layout_state.left_panel_width)
	end

	-- Restore bottom panel height
	for _, win in ipairs(bottom_panel_wins) do
		vim.api.nvim_win_set_height(win, layout_state.bottom_panel_height)
	end

	-- Focus back to main editor
	if main_editor_win then
		vim.api.nvim_set_current_win(main_editor_win)
	end
end

---Checks if minimap is available and toggles it if needed
---@return boolean Whether minimap was toggled
local function toggle_minimap_if_needed()
	if not config.toggle_minimap then
		return false
	end

	-- Check if current buffer is not empty
	local current_buf = vim.api.nvim_get_current_buf()
	local buf_lines = vim.api.nvim_buf_line_count(current_buf)
	local is_empty = buf_lines <= 1 and vim.api.nvim_buf_get_lines(current_buf, 0, 1, false)[1] == ""

	if is_empty then
		return false
	end

	-- Try to toggle minimap
	local minimap_main_success, minimap_main = pcall(require, "minimap")
	if minimap_main_success and minimap_main.toggle then
		minimap_main.toggle()
		return true
	end

	-- Try alternative minimap patterns
	local minimap_api_success, minimap_api = pcall(require, "minimap.api")
	if minimap_api_success and minimap_api.toggle then
		minimap_api.toggle()
		return true
	end

	-- Try minimap command
	local minimap_cmd_success, _ = pcall(vim.cmd, "MinimapToggle")
	if minimap_cmd_success then
		return true
	end

	return false
end

---Sets up monitoring for <leader>e keypress to restore layout
---@return nil
local function setup_leader_e_monitoring()
	if not config.watch_leader_e then
		return
	end

	-- Store the original <leader>e mapping if it exists
	local leader_e_mapping = vim.fn.maparg("<leader>e", "n", false, true)
	if leader_e_mapping and leader_e_mapping.rhs then
		layout_state.original_leader_e_mapping = leader_e_mapping
	end

	-- Create a custom <leader>e mapping that restores layout
	vim.keymap.set("n", "<leader>e", function()
		-- Toggle minimap if needed
		toggle_minimap_if_needed()

		-- Execute the original mapping if it exists
		if layout_state.original_leader_e_mapping then
			local cmd = layout_state.original_leader_e_mapping.rhs
			if layout_state.original_leader_e_mapping.expr then
				cmd = vim.fn.eval(cmd)
			end
			vim.cmd("normal " .. cmd)
		else
		-- Fallback to nvimtree toggle
		local leader_e_nvimtree_success, leader_e_nvimtree = pcall(require, "nvim-tree.api")
		if leader_e_nvimtree_success and leader_e_nvimtree.tree then
			leader_e_nvimtree.tree.toggle()
		else
			vim.cmd("NvimTreeToggle")
		end
		end

		-- Restore layout after a short delay to allow nvimtree to complete
		vim.defer_fn(function()
			restore_layout()
		end, 100)
	end, { desc = "Toggle nvimtree and restore Nvibe layout" })
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

	-- Save layout state before any operations
	save_layout_state()

	-- Toggle minimap if needed before opening nvimtree
	toggle_minimap_if_needed()

	-- Try to open nvimtree and trigger window balancing
	-- This prevents nvimtree from balancing windows later and breaking our layout
	local nvimtree_api_success, nvimtree_api = pcall(require, "nvim-tree.api")
	if nvimtree_api_success and nvimtree_api.tree then
		-- Use nvimtree API directly
		nvimtree_api.tree.toggle()
	else
		-- Try alternative nvimtree require patterns
		local nvimtree_main_success, nvimtree_main = pcall(require, "nvim-tree")
		if nvimtree_main_success and nvimtree_main.toggle then
			nvimtree_main.toggle()
		else
			-- Try the old nvim-tree pattern
			local nvimtree_legacy_success, nvimtree_legacy = pcall(require, "nvim-tree.api.tree")
			if nvimtree_legacy_success and nvimtree_legacy.toggle then
				nvimtree_legacy.toggle()
			else
				-- Try using the NvimTreeToggle command directly
				local nvimtree_cmd_success, _ = pcall(vim.cmd, "NvimTreeToggle")
				if not nvimtree_cmd_success then
					-- Fallback to keybind simulation
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<leader>e", true, false, true), "n", true)
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
	local cursor_agent_success, cursor_agent_error = pcall(function()
		nvchad_term.new({
			pos = "sp",
			cmd = config.cursor_agent_cmd,
			size = 0.5, -- 50% of the left panel
		})
	end)

	if not cursor_agent_success then
		vim.notify(
			"Nvibe Error: Failed to create cursor-agent terminal\n\n"
				.. "Command: "
				.. config.cursor_agent_cmd
				.. "\n"
				.. "Error: "
				.. tostring(cursor_agent_error),
			vim.log.levels.ERROR,
			{ title = "Nvibe - Terminal Creation Failed" }
		)
	end

	-- Create coderabbit terminal in bottom-left using NvChad method
	local coderabbit_success, coderabbit_error = pcall(function()
		nvchad_term.new({
			pos = "sp",
			cmd = config.coderabbit_cmd,
			size = 0.5, -- 50% of the left panel
		})
	end)

	if not coderabbit_success then
		vim.notify(
			"Nvibe Error: Failed to create coderabbit terminal\n\n"
				.. "Command: "
				.. config.coderabbit_cmd
				.. "\n"
				.. "Error: "
				.. tostring(coderabbit_error),
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

	-- Set up monitoring for <leader>e to restore layout
	setup_leader_e_monitoring()
end

---Manually restores the Nvibe layout
---
---This function can be called manually to restore the layout after
---nvimtree or other operations that might have changed window sizes.
---It's also automatically called when <leader>e is pressed if
---watch_leader_e is enabled.
---
---@return nil
function M.restore_layout()
	restore_layout()
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
		local terminal_success, terminal_error = pcall(function()
			nvchad_term.new({
				pos = "sp",
				cmd = terminal_config.cmd,
				size = config.bottom_panel_height_percent / 100, -- Convert percentage to decimal
			})
		end)

		if not terminal_success then
			vim.notify(
				"Nvibe Error: Failed to create " .. (terminal_config.name or "terminal") .. "\n\n"
					.. "Command: " .. terminal_config.cmd .. "\n"
					.. "Error: " .. tostring(terminal_error),
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
	local nvchad_term_success, nvchad_term_module = pcall(require, "nvchad.term")
	if not nvchad_term_success then
		vim.notify(
			"Nvibe Setup Error: nvchad.term module not found!\n\n"
				.. "Nvibe requires NvChad to function properly.\n"
				.. "Please install NvChad: https://github.com/NvChad/NvChad\n\n"
				.. "Error: "
				.. tostring(nvchad_term_module),
			vim.log.levels.ERROR,
			{ title = "Nvibe - Missing Dependency" }
		)
		return
	end

	-- Store the module for reuse
	nvchad_term = nvchad_term_module

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
