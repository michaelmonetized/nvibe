# Nvibe API Documentation

## Overview

Nvibe is a Neovim plugin that automatically creates a terminal split layout with AI-powered coding assistants. This document describes the public API and configuration options.

## Installation

```lua
-- Using Lazy.nvim
{
  'michaelmonetized/nvibe',
  config = function()
    require('nvibe').setup()
  end
}

-- Using Packer
use {
  'michaelmonetized/nvibe',
  config = function()
    require('nvibe').setup()
  end
}
```

## Configuration

### `nvibe.setup(opts?)`

Initializes the Nvibe plugin with optional configuration.

**Parameters:**
- `opts` (table, optional): Configuration options

**Configuration Options:**

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `width_percent` | number | `30` | Percentage of screen width for terminal panel |
| `cursor_agent_cmd` | string | `"cursor-agent"` | Command to run cursor-agent |
| `coderabbit_cmd` | string | `"coderabbit"` | Command to run coderabbit |

**Example:**
```lua
require('nvibe').setup({
  width_percent = 40,
  cursor_agent_cmd = "my-cursor-agent",
  coderabbit_cmd = "my-coderabbit"
})
```

## Public Functions

### `nvibe.create_terminal_split()`

Creates the terminal split layout with cursor-agent and coderabbit.

**Description:**
This function creates a vertical split to the left of the current window, resizes it to the configured width, and launches both AI assistants in separate terminals.

**Returns:** `nil`

**Side Effects:**
- Creates a vertical split window
- Launches cursor-agent in top terminal
- Launches coderabbit in bottom terminal
- Closes empty editor buffers
- Returns focus to main editor window

**Example:**
```lua
-- Manually create terminal split
require('nvibe').create_terminal_split()
```

## Internal Functions

### `get_terminal_width()`

Calculates the terminal panel width based on environment or current window.

**Returns:** `number` - The calculated width in columns

**Logic:**
1. Checks for `COLS` environment variable
2. Falls back to `vim.o.columns` if `COLS` not available
3. Applies configured width percentage

## Events

### VimEnter Autocmd

The plugin automatically creates a `VimEnter` autocmd that:
- Runs only when not already in a terminal buffer
- Calls `create_terminal_split()` to set up the layout
- Ensures the plugin activates on every Neovim startup

## Dependencies

- **Neovim 0.7+** - Required for Lua support
- **NvChad** - Required for terminal integration (`nvchad.term` module)

## Error Handling

The plugin includes basic error handling:
- Graceful fallback when `COLS` environment variable is not set
- Terminal buffer detection to prevent recursive terminal creation
- Safe window management operations

## Examples

### Basic Setup
```lua
require('nvibe').setup()
```

### Custom Configuration
```lua
require('nvibe').setup({
  width_percent = 25,
  cursor_agent_cmd = "cursor-agent --verbose",
  coderabbit_cmd = "coderabbit --config ~/.coderabbit.json"
})
```

### Manual Terminal Creation
```lua
-- Create terminal split manually (useful for keybindings)
vim.keymap.set('n', '<leader>nt', function()
  require('nvibe').create_terminal_split()
end, { desc = 'Create Nvibe terminal split' })
```

## Troubleshooting

### Common Issues

1. **Terminals not interactive**: Ensure NvChad is properly installed
2. **Wrong terminal size**: Check `COLS` environment variable or adjust `width_percent`
3. **Commands not found**: Verify cursor-agent and coderabbit are in PATH

### Debug Mode

Enable debug logging by setting:
```lua
vim.g.nvibe_debug = true
```

## Contributing

When contributing to Nvibe:
1. Follow the existing code style
2. Add tests for new functionality
3. Update documentation for API changes
4. Ensure all tests pass before submitting PRs