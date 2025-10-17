# Nvibe Plugin for Neovim

A Neovim plugin that automatically opens a terminal pane on the left side of the editor with `cursor-agent` and `coderabbit` running in split terminals.

## Features

- Automatically opens on Neovim launch
- Terminal pane takes 30% of the width (based on `$COLS` environment variable)
- Horizontally splits the terminal pane
- Runs `cursor-agent` in the top half
- Runs `coderabbit` in the bottom half
- Configurable commands and width percentage

## Installation

### Using a plugin manager (recommended)

#### Packer
```lua
use {
  'your-username/nvibe',
  config = function()
    require('nvibe').setup()
  end
}
```

#### Lazy.nvim
```lua
{
  'your-username/nvibe',
  config = function()
    require('nvibe').setup()
  end
}
```

### Manual installation

1. Copy the `lua/nvibe/` directory to your Neovim configuration directory:
   ```bash
   cp -r lua/nvibe ~/.config/nvim/lua/
   ```

2. Add the following to your `init.lua`:
   ```lua
   require('nvibe').setup()
   ```

## Configuration

You can customize the plugin by passing options to the setup function:

```lua
require('nvibe').setup({
  width_percent = 30,           -- Width percentage (default: 30)
  cursor_agent_cmd = "cursor-agent",  -- Command for top terminal (default: "cursor-agent")
  coderabbit_cmd = "coderabbit"       -- Command for bottom terminal (default: "coderabbit")
})
```

## Usage

The plugin automatically activates when you launch Neovim. It will:

1. Create a vertical split on the left side
2. Set the width to 30% of your terminal width (based on `$COLS`)
3. Split the terminal pane horizontally
4. Run `cursor-agent` in the top half
5. Run `coderabbit` in the bottom half

## Requirements

- Neovim 0.7+
- `cursor-agent` command available in PATH
- `coderabbit` command available in PATH
- `$COLS` environment variable set (optional, falls back to window width)

## Troubleshooting

If the `$COLS` environment variable is not set, the plugin will fall back to using 30% of the current Neovim window width.

Make sure both `cursor-agent` and `coderabbit` commands are available in your PATH before launching Neovim.