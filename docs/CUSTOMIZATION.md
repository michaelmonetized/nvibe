# Nvibe Customization Guide

This guide covers all the configuration options available in Nvibe v0.1.1.

## Basic Configuration

The simplest way to configure Nvibe is through the setup function:

```lua
require('nvibe').setup({
  -- Your configuration options here
})
```

## Configuration Options

### Panel Sizing

#### `width_percent` (number, default: 20)
Controls the width of the left panel as a percentage of the total screen width.

```lua
require('nvibe').setup({
  width_percent = 25,  -- 25% of screen width
})
```

#### `bottom_panel_height_percent` (number, default: 20)
Controls the height of the bottom panel as a percentage of the total screen height.

```lua
require('nvibe').setup({
  bottom_panel_height_percent = 25,  -- 25% of screen height
})
```

### Terminal Commands

#### `cursor_agent_cmd` (string, default: "cursor-agent")
Command to run the Cursor Agent in the top-left terminal.

```lua
require('nvibe').setup({
  cursor_agent_cmd = "cursor-agent --custom-flag",
})
```

#### `coderabbit_cmd` (string, default: "coderabbit")
Command to run CodeRabbit in the bottom-left terminal.

```lua
require('nvibe').setup({
  coderabbit_cmd = "coderabbit --config /path/to/config",
})
```

#### `lazygit_cmd` (string, default: "lazygit")
Command to run LazyGit in the bottom panel.

```lua
require('nvibe').setup({
  lazygit_cmd = "lazygit --config /path/to/config",
})
```

#### `shell_cmd` (string, default: vim.o.shell)
Command to run shell terminals in the bottom panel.

```lua
require('nvibe').setup({
  shell_cmd = "zsh",  -- Use zsh instead of default shell
})
```

### Layout Management

#### `watch_leader_e` (boolean, default: true)
Whether to watch for `<leader>e` keypress and automatically restore the layout after nvimtree operations.

```lua
require('nvibe').setup({
  watch_leader_e = true,  -- Automatically restore layout when <leader>e is pressed
})
```

#### `auto_restore_layout` (boolean, default: true)
Whether to automatically restore the layout after nvimtree operations.

```lua
require('nvibe').setup({
  auto_restore_layout = true,  -- Automatically restore layout after operations
})
```

#### `toggle_minimap` (boolean, default: true)
Whether to toggle minimap before opening nvimtree if the current buffer is not empty.

```lua
require('nvibe').setup({
  toggle_minimap = true,  -- Toggle minimap before nvimtree if buffer has content
})
```

### Advanced: Custom Bottom Panel Terminals

#### `bottom_panel_terminals` (table, default: see below)
Array of terminal configurations for the bottom panel. Each terminal can have its own command and name.

**Default configuration:**
```lua
bottom_panel_terminals = {
  { cmd = "lazygit", name = "LazyGit" },
  { cmd = vim.o.shell, name = "Shell 1" },
  { cmd = vim.o.shell, name = "Shell 2" },
}
```

**Custom example:**
```lua
require('nvibe').setup({
  bottom_panel_terminals = {
    { cmd = "lazygit", name = "Git" },
    { cmd = "htop", name = "System Monitor" },
    { cmd = "docker ps", name = "Docker" },
    { cmd = vim.o.shell, name = "Shell" },
  }
})
```

**Terminal configuration fields:**
- `cmd` (string): Command to run in the terminal
- `name` (string): Name used in error messages (optional, defaults to "terminal")

## Complete Configuration Example

Here's a complete configuration example with all options:

```lua
require('nvibe').setup({
  -- Panel sizing
  width_percent = 25,                    -- Left panel: 25% width
  bottom_panel_height_percent = 30,     -- Bottom panel: 30% height
  
  -- AI assistant commands
  cursor_agent_cmd = "cursor-agent --verbose",
  coderabbit_cmd = "coderabbit --config ~/.coderabbit.yml",
  
  -- Development tool commands
  lazygit_cmd = "lazygit --config ~/.lazygit.yml",
  shell_cmd = "zsh",
  
  -- Custom bottom panel layout
  bottom_panel_terminals = {
    { cmd = "lazygit", name = "Git Operations" },
    { cmd = "htop", name = "System Monitor" },
    { cmd = "docker ps -a", name = "Docker Status" },
    { cmd = "zsh", name = "Development Shell" },
  }
})
```

## Layout Behavior

### Automatic Layout Creation
Nvibe automatically creates the layout when Neovim starts, but only if you're not already in a terminal buffer. This prevents the layout from being created when you're already in a terminal session.

### Layout Restoration
Nvibe includes smart layout management features:

#### Automatic Restoration
- **`<leader>e` Monitoring**: When you press `<leader>e` to open nvimtree, Nvibe automatically restores the layout after the operation completes
- **Minimap Integration**: If minimap is available and the current buffer has content, Nvibe will toggle minimap before opening nvimtree
- **Window Balancing Protection**: Prevents nvimtree from breaking your carefully crafted layout

#### Manual Restoration
You can manually restore the layout at any time:

```lua
-- In your Neovim config or via command
require('nvibe').restore_layout()
```

This is useful if:
- The layout gets disrupted by other plugins
- You want to reset the layout after manual window operations
- You're debugging layout issues

### Window Management
- The left panel contains AI assistants (Cursor Agent + CodeRabbit)
- The bottom panel contains development tools (configurable terminals)
- The main editor area takes up the remaining space
- All panels are automatically sized based on your configuration

### Error Handling
If any terminal fails to start, Nvibe will:
1. Display an error notification with the terminal name and command
2. Continue creating the remaining terminals
3. Not interrupt the overall layout creation

## Troubleshooting

### Terminal Command Not Found
If you get "command not found" errors:
1. Ensure the command is installed and in your PATH
2. Use absolute paths if needed: `cmd = "/usr/local/bin/lazygit"`
3. Check that the command works in your terminal before using it in Nvibe

### Panel Sizing Issues
If panels appear too small or large:
1. Adjust the percentage values (1-50 recommended)
2. Consider your screen resolution and Neovim window size
3. Test different values to find what works best for your setup

### Layout Not Creating
If the layout doesn't appear:
1. Ensure NvChad is installed and loaded
2. Check that you're not already in a terminal buffer
3. Look for error messages in the notification area
4. Verify your configuration syntax is correct

## Layout Management

### Automatic Layout Restoration

Nvibe includes sophisticated layout management that automatically restores your layout when `<leader>e` is pressed to open nvimtree. This prevents nvimtree from permanently disrupting your carefully crafted layout.

#### How It Works
1. **Layout State Saving**: Nvibe saves the dimensions of your panels when first created
2. **Key Monitoring**: When you press `<leader>e`, Nvibe intercepts the action
3. **Original Function**: Executes the original `<leader>e` mapping (usually nvimtree toggle)
4. **Automatic Restoration**: After nvimtree completes, the layout is automatically restored
5. **Minimap Integration**: Toggles minimap before nvimtree if the buffer has content

#### Configuration Options
```lua
require('nvibe').setup({
  watch_leader_e = true,        -- Enable <leader>e monitoring (default: true)
  auto_restore_layout = true,   -- Automatically restore layout (default: true)
  toggle_minimap = true,        -- Toggle minimap before nvimtree (default: true)
})
```

### Manual Layout Restoration

You can manually restore the layout at any time using the `M.restore_layout()` function:

```lua
-- In your Neovim config or via command
require('nvibe').restore_layout()
```

This is useful when:
- The layout gets disrupted by other plugins
- You want to reset the layout after manual window operations
- You're debugging layout issues
- The automatic restoration didn't work as expected

### Layout State Management

Nvibe maintains internal state about your layout dimensions:
- `left_panel_width`: Width of the left panel in columns
- `bottom_panel_height`: Height of the bottom panel in lines
- `initialized`: Whether the layout state has been saved

This state is automatically managed, but you can access it if needed for debugging.

## Migration from v0.1.0

If you're upgrading from v0.1.0, the new configuration options are backward compatible:
- Existing `width_percent`, `cursor_agent_cmd`, and `coderabbit_cmd` options work as before
- New bottom panel options use sensible defaults
- New layout management options are enabled by default
- No changes required to existing configurations