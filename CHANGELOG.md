# Changelog

All notable changes to the Nvibe plugin will be documented in this file.

## [0.1.0] - 2025-01-17

### Added
- Initial release of Nvibe plugin for Neovim
- Automatic terminal pane creation on Neovim launch
- Left-side terminal panel with 30% width based on `$COLS` environment variable
- Horizontal split terminal layout
- `cursor-agent` terminal in top-left pane
- `coderabbit` terminal in bottom-left pane
- Configurable commands and width percentage
- Integration with NvChad terminal module for proper interactive terminals

### Fixed
- **Terminal Interactivity Issue**: Initially terminals were not interactive and showed line numbers
  - **Problem**: Using `vim.cmd("terminal command")` created non-interactive terminals in editor mode
  - **Solution**: Switched to using NvChad's `require("nvchad.term").new()` method which creates proper interactive terminals with shell profile
- **Window Layout Issue**: Empty editor window was created above cursor-agent terminal
  - **Problem**: Manual horizontal split created empty buffer that wasn't replaced by terminal
  - **Solution**: Let NvChad handle horizontal splitting automatically, then close empty buffer with `wincmd k` twice + `close`
- **Insert Mode Issue**: Main window was left in insert mode after terminal creation
  - **Problem**: NvChad terminals automatically enter insert mode
  - **Solution**: Added `vim.cmd("stopinsert")` after switching back to main window

### Technical Details
- Uses NvChad's terminal module for consistent behavior with `<leader>v` keybinding
- Proper window management with automatic cleanup of empty buffers
- Terminal sizing based on `$COLS` environment variable with fallback to window width
- Full shell profile integration for interactive terminal sessions

### Configuration
```lua
require('nvibe').setup({
  width_percent = 30,           -- Width percentage (default: 30)
  cursor_agent_cmd = "cursor-agent",  -- Command for top terminal
  coderabbit_cmd = "coderabbit"       -- Command for bottom terminal
})
```

### Requirements
- Neovim 0.7+
- NvChad configuration
- `cursor-agent` command available in PATH
- `coderabbit` command available in PATH
- `$COLS` environment variable set (optional, falls back to window width)