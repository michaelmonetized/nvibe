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
-- OVERVIEW:
-- =========
-- Nvibe transforms your Neovim into a powerful AI-powered coding environment by automatically
-- creating a sophisticated split terminal layout. This eliminates the need to constantly
-- switch between windows, providing everything you need for modern development in one place.
--
-- LAYOUT STRUCTURE:
-- =================
-- ┌──────────┬─────────────────────────┐
-- │          │                         │
-- │          │     Your Code           │
-- │ Cursor   │                         │
-- │ Agent    │                         │
-- │          │                         │
-- ├──────────┤                         │
-- │          │                         │
-- │CodeRabbit│                         │
-- │          ├───────┬───────┬─────────┤
-- │          │ Shell │ Shell │ LazyGit │
-- └──────────┴───────┴───────┴─────────┘
--
-- - Left Panel (20% width): AI assistants (Cursor Agent + CodeRabbit)
-- - Bottom Panel (20% height): Development tools (LazyGit + Shell terminals)
-- - Main Editor: Takes up the remaining space for your code
--
-- KEY FEATURES:
-- =============
-- 1. CONFIGURABLE LAYOUT: All panel sizes and terminal commands are customizable
-- 2. SMART LAYOUT MANAGEMENT: Automatic restoration when <leader>e is pressed
-- 3. MINIMAP INTEGRATION: Auto-toggles minimap before nvimtree when buffer has content
-- 4. WINDOW BALANCING PROTECTION: Prevents nvimtree from breaking your layout
-- 5. MANUAL CONTROL: M.restore_layout() function for manual layout restoration
-- 6. ERROR RESILIENCE: Graceful handling of missing dependencies and failed terminals
-- 7. ZERO CONFIGURATION: Works out of the box with sensible defaults
--
-- DEPENDENCIES:
-- =============
-- - Neovim 0.7+ (required for Lua support)
-- - NvChad (required for nvchad.term module)
-- - Cursor Agent (AI coding assistant)
-- - CodeRabbit (Code review assistant)
-- - LazyGit (Git operations)
--
-- USAGE:
-- ======
-- Basic setup:
--   require('nvibe').setup()
--
-- Advanced configuration:
--   require('nvibe').setup({
--     width_percent = 25,
--     bottom_panel_height_percent = 30,
--     watch_leader_e = true,
--     toggle_minimap = true,
--     bottom_panel_terminals = {
--       { cmd = "lazygit", name = "Git" },
--       { cmd = "htop", name = "System" },
--       { cmd = vim.o.shell, name = "Shell" },
--     }
--   })
--
-- Manual layout restoration:
--   require('nvibe').restore_layout()
--
-- AUTHOR: Michael Monetized
-- VERSION: 0.1.1
-- LICENSE: MIT

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

---Calculates the left terminal panel width based on configuration and environment
---
---This function determines the appropriate width for the left panel containing
---the AI assistant terminals (Cursor Agent and CodeRabbit). It prioritizes
---environment variables for consistent sizing across different terminal sessions.
---
---WIDTH CALCULATION:
---==================
---1. ENVIRONMENT CHECK: Looks for COLS environment variable first
---2. FALLBACK CALCULATION: Uses vim.o.columns if COLS not available
---3. PERCENTAGE APPLICATION: Applies config.width_percent to the base width
---4. ROUNDING: Floors the result to ensure integer column count
---
---ENVIRONMENT VARIABLES:
---=====================
---- COLS: Terminal column count (preferred for consistency)
---- Falls back to vim.o.columns if COLS not set
---
---CONFIGURATION:
---==============
---- config.width_percent: Percentage of screen width to use (default: 20)
---- Applied to either COLS or vim.o.columns
---
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

---Calculates the bottom panel height based on configuration and environment
---
---This function determines the appropriate height for the bottom panel containing
---development tool terminals (LazyGit, Shell terminals). It prioritizes
---environment variables for consistent sizing across different terminal sessions.
---
---HEIGHT CALCULATION:
---===================
---1. ENVIRONMENT CHECK: Looks for LINES environment variable first
---2. FALLBACK CALCULATION: Uses vim.o.lines if LINES not available
---3. PERCENTAGE APPLICATION: Applies config.bottom_panel_height_percent to the base height
---4. ROUNDING: Floors the result to ensure integer line count
---
---ENVIRONMENT VARIABLES:
---=====================
---- LINES: Terminal line count (preferred for consistency)
---- Falls back to vim.o.lines if LINES not set
---
---CONFIGURATION:
---==============
---- config.bottom_panel_height_percent: Percentage of screen height to use (default: 20)
---- Applied to either LINES or vim.o.lines
---
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

---Saves the current layout state for later restoration
---
---This function captures the current layout dimensions and stores them in the
---layout_state table. This information is used by restore_layout() to return
---the layout to its original configuration after nvimtree or other operations.
---
---SAVED STATE:
---============
---- left_panel_width: Width of the left panel in columns
---- bottom_panel_height: Height of the bottom panel in lines
---- initialized: Flag indicating layout state has been saved
---
---USAGE:
---======
---Called automatically during create_terminal_split() to capture the
---initial layout state. Can also be called manually to update the
---saved state after layout changes.
---
---@return nil
local function save_layout_state()
	layout_state.left_panel_width = get_terminal_width()
	layout_state.bottom_panel_height = get_bottom_panel_height()
	layout_state.initialized = true
end

---Restores the Nvibe layout to its saved dimensions after nvimtree operations
---
---This function is the core of the layout restoration system. It analyzes all
---current windows and restores them to their saved dimensions, preventing
---nvimtree from permanently disrupting the carefully crafted Nvibe layout.
---
---WINDOW ANALYSIS:
---================
---1. WINDOW DISCOVERY: Gets list of all current windows
---2. DIMENSION ANALYSIS: Checks width and height of each window
---3. CATEGORIZATION: Groups windows by their likely purpose:
---   - Left panel: Width matches saved left_panel_width (±5 columns)
---   - Bottom panel: Height matches saved bottom_panel_height (±5 lines)
---   - Main editor: All other windows
---
---RESTORATION PROCESS:
---====================
---1. LEFT PANEL: Restores width of all left panel windows
---2. BOTTOM PANEL: Restores height of all bottom panel windows
---3. FOCUS: Returns focus to main editor window
---
---ERROR HANDLING:
---==============
---- Uninitialized state: Returns early if layout not previously saved
---- Missing windows: Gracefully handles windows that no longer exist
---- Focus restoration: Safely handles missing main editor window
---
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

---Checks if minimap is available and toggles it if the current buffer has content
---
---This function provides intelligent minimap management by checking if the current
---buffer contains content before attempting to toggle minimap. This prevents
---unnecessary minimap operations on empty buffers and ensures a clean layout.
---
---PROCESS FLOW:
---=============
---1. CONFIGURATION CHECK: Verifies toggle_minimap is enabled
---2. BUFFER ANALYSIS: Checks if current buffer has content
---3. MINIMAP DETECTION: Attempts to find minimap module using multiple patterns
---4. TOGGLE EXECUTION: Toggles minimap if found and buffer has content
---5. SUCCESS REPORTING: Returns whether minimap was successfully toggled
---
---BUFFER CONTENT CHECK:
---=====================
---- Checks if buffer has more than 1 line
---- Checks if the single line is not empty
---- Only proceeds if buffer contains actual content
---
---MINIMAP DETECTION:
---=================
---Attempts multiple minimap patterns in order:
---- require("minimap") - Standard minimap module
---- require("minimap.api") - API-based minimap module
---- vim.cmd("MinimapToggle") - Command-based minimap
---
---CONFIGURATION:
---==============
---- config.toggle_minimap: Whether to enable minimap toggling (default: true)
---
---@return boolean Whether minimap was successfully toggled
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

---Sets up monitoring for <leader>e keypress to automatically restore layout
---
---This function creates a custom <leader>e mapping that preserves the original
---functionality while adding automatic layout restoration. This ensures that
---nvimtree operations don't permanently disrupt the Nvibe layout.
---
---PROCESS FLOW:
---=============
---1. CONFIGURATION CHECK: Verifies watch_leader_e is enabled
---2. MAPPING PRESERVATION: Stores original <leader>e mapping if it exists
---3. CUSTOM MAPPING: Creates new <leader>e mapping that:
---   - Toggles minimap if needed
---   - Executes original mapping or nvimtree toggle
---   - Restores layout after operation completes
---4. ERROR HANDLING: Gracefully handles missing original mappings
---
---MAPPING PRESERVATION:
---=====================
---The original <leader>e mapping is preserved and executed as part of the
---custom mapping, ensuring compatibility with existing configurations.
---
---LAYOUT RESTORATION:
---==================
---After the nvimtree operation completes, the layout is automatically restored
---using a deferred function to ensure the operation has finished.
---
---CONFIGURATION:
---==============
---- config.watch_leader_e: Whether to enable <leader>e monitoring (default: true)
---- config.toggle_minimap: Whether to toggle minimap before nvimtree
---
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

---Creates the complete Nvibe terminal split layout
---
---This is the main function that orchestrates the creation of the entire Nvibe layout.
---It handles all the complex window management, terminal creation, and layout restoration
---to provide a seamless coding environment.
---
---PROCESS FLOW:
---=============
---1. DEPENDENCY CHECK: Verifies nvchad.term module is available
---2. LAYOUT STATE SAVE: Saves current layout dimensions for restoration
---3. MINIMAP HANDLING: Toggles minimap if buffer has content and minimap is available
---4. NVIMTREE TRIGGER: Opens nvimtree to trigger window balancing (prevents later issues)
---5. WINDOW RESET: Switches back to editor to reset window layout
---6. COMMAND VALIDATION: Checks that required commands (cursor-agent, coderabbit) are executable
---7. LEFT PANEL CREATION: Creates vertical split and resizes to configured width
---8. AI TERMINALS: Creates Cursor Agent (top) and CodeRabbit (bottom) terminals
---9. BOTTOM PANEL: Creates configurable bottom panel with development tools
---10. CLEANUP: Closes empty buffers and returns focus to main editor
---11. LAYOUT MONITORING: Sets up <leader>e monitoring for automatic restoration
---
---ERROR HANDLING:
---==============
---- Missing nvchad.term: Shows error notification and returns early
---- Missing commands: Shows error notification and returns early
---- Terminal creation failures: Shows error notification but continues with other terminals
---- Layout restoration: Gracefully handles missing dependencies
---
---CONFIGURATION:
---==============
---Uses the global config table for all settings:
---- width_percent: Left panel width as percentage of screen
---- cursor_agent_cmd: Command to run Cursor Agent
---- coderabbit_cmd: Command to run CodeRabbit
---- bottom_panel_terminals: Array of terminal configurations
---- watch_leader_e: Whether to monitor <leader>e for layout restoration
---- toggle_minimap: Whether to toggle minimap before nvimtree
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

---Manually restores the Nvibe layout to its configured dimensions
---
---This function provides manual control over layout restoration, allowing users
---to reset the layout after any operations that might have disrupted it.
---It's also automatically called when <leader>e is pressed if watch_leader_e is enabled.
---
---PROCESS FLOW:
---=============
---1. LAYOUT CHECK: Verifies layout was previously initialized
---2. WINDOW DISCOVERY: Scans all windows to categorize them by size and position
---3. WINDOW CATEGORIZATION:
---   - Left panel windows: Identified by width matching saved left_panel_width
---   - Bottom panel windows: Identified by height matching saved bottom_panel_height
---   - Main editor window: Remaining window (largest)
---4. DIMENSION RESTORATION:
---   - Restores left panel windows to saved width
---   - Restores bottom panel windows to saved height
---5. FOCUS RESTORATION: Returns focus to main editor window
---
---WINDOW IDENTIFICATION:
---=====================
---Windows are identified by comparing their dimensions to saved layout state:
---- Left panel: width within ±5 columns of saved left_panel_width
---- Bottom panel: height within ±5 lines of saved bottom_panel_height
---- Main editor: All other windows
---
---ERROR HANDLING:
---==============
---- Uninitialized layout: Returns early if layout state not saved
---- No matching windows: Gracefully handles missing windows
---- Focus restoration: Safely handles missing main editor window
---
---USAGE SCENARIOS:
---===============
---- After nvimtree operations that changed window sizes
---- After manual window resizing that disrupted the layout
---- After plugin operations that affected window dimensions
---- For debugging layout issues
---- As part of automated layout management
---
---@return nil
function M.restore_layout()
	restore_layout()
end

---Creates the bottom panel with configurable development tool terminals
---
---This function creates a horizontal bottom panel containing multiple terminals
---for development tools. The terminals are configured via the bottom_panel_terminals
---configuration option, allowing complete customization of the development environment.
---
---PROCESS FLOW:
---=============
---1. DEPENDENCY CHECK: Verifies nvchad.term module is available
---2. HEIGHT CALCULATION: Calculates bottom panel height from configuration
---3. TERMINAL COUNT: Determines number of terminals to create
---4. BOTTOM SPLIT: Creates horizontal split for the bottom panel
---5. TERMINAL CREATION: Iterates through each terminal configuration:
---   - Creates vertical split for each terminal (except first)
---   - Calculates equal width distribution for terminals
---   - Creates terminal using nvchad.term.new()
---   - Handles errors gracefully with descriptive messages
---6. CLEANUP: Closes temporary windows and positions focus
---
---TERMINAL CONFIGURATION:
---=======================
---Each terminal in bottom_panel_terminals can have:
---- cmd: Command to run in the terminal (required)
---- name: Display name for error messages (optional, defaults to "terminal")
---
---ERROR HANDLING:
---==============
---- Missing nvchad.term: Shows error notification and returns early
---- Terminal creation failures: Shows error with terminal name and command
---- Continues creating other terminals even if one fails
---
---CONFIGURATION:
---==============
---- bottom_panel_height_percent: Height of bottom panel as percentage of screen
---- bottom_panel_terminals: Array of terminal configurations
---- Each terminal uses config.bottom_panel_height_percent for size
---
---@return nil
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
---This is the main entry point for the Nvibe plugin. It performs all necessary
---setup including dependency checking, configuration merging, and autocmd creation.
---The plugin will automatically create the layout when Neovim starts.
---
---PROCESS FLOW:
---=============
---1. DEPENDENCY CHECK: Verifies nvchad.term module is available
---2. ERROR HANDLING: Shows detailed error if NvChad not found
---3. MODULE STORAGE: Caches nvchad.term module for reuse
---4. CONFIGURATION MERGE: Merges user options with defaults using deep extend
---5. AUTOCMD CREATION: Creates VimEnter autocmd for automatic layout creation
---6. CONDITIONAL EXECUTION: Only runs if not already in a terminal buffer
---
---CONFIGURATION MERGING:
---=====================
---User-provided options are merged with defaults using vim.tbl_deep_extend:
---- Preserves all default values
---- Overwrites with user-provided values
---- Handles nested tables properly
---- Maintains type safety
---
---AUTOCMD BEHAVIOR:
---=================
---The VimEnter autocmd ensures layout creation happens automatically:
---- Runs on every VimEnter event
---- Checks if current buffer is not a terminal
---- Prevents layout creation in terminal buffers
---- Ensures clean startup experience
---
---ERROR HANDLING:
---==============
---- Missing NvChad: Shows detailed error with installation instructions
---- Configuration errors: Handled by vim.tbl_deep_extend
---- Autocmd failures: Gracefully handled by Neovim
---
---USAGE EXAMPLES:
---===============
---Basic setup:
---  require('nvibe').setup()
---
---With configuration:
---  require('nvibe').setup({
---    width_percent = 25,
---    watch_leader_e = true,
---    bottom_panel_terminals = {
---      { cmd = "lazygit", name = "Git" },
---      { cmd = "htop", name = "System" }
---    }
---  })
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
