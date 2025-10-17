# Nvibe Installation Guide

## Prerequisites

Before installing Nvibe, you need to ensure you have the required dependencies.

## Required Dependencies

### 1. Neovim 0.7+
Nvibe requires Neovim 0.7 or higher for Lua support.

**Check your version:**
```bash
nvim --version
```

**Install/Update Neovim:**
- **macOS**: `brew install neovim`
- **Ubuntu/Debian**: `sudo apt install neovim`
- **Arch Linux**: `sudo pacman -S neovim`
- **Windows**: Download from [GitHub releases](https://github.com/neovim/neovim/releases)

### 2. NvChad (REQUIRED)
Nvibe depends on NvChad's terminal module (`nvchad.term`). You have several options:

#### Option A: Full NvChad Installation (Recommended)
This is the easiest and most reliable option.

```bash
# Backup your current config
mv ~/.config/nvim ~/.config/nvim.backup

# Install NvChad
git clone https://github.com/NvChad/NvChad ~/.config/nvim
```

#### Option B: NvChad as Base Config
If you want to use NvChad as your base configuration:

```bash
# Clone NvChad
git clone https://github.com/NvChad/NvChad ~/.config/nvim

# Install Nvibe
cd ~/.config/nvim/lua/custom/plugins
# Add Nvibe to your plugins list
```

#### Option C: Standalone nvchad.term (Advanced)
If you don't want full NvChad, you can install just the terminal module:

```bash
# Create the required directory structure
mkdir -p ~/.config/nvim/lua/nvchad

# Download just the term module
curl -o ~/.config/nvim/lua/nvchad/term.lua \
  https://raw.githubusercontent.com/NvChad/NvChad/main/lua/nvchad/term.lua
```

**Note**: This approach is not officially supported and may break with NvChad updates.

### 3. AI Assistant Commands
Install the AI assistants you want to use:

#### Cursor Agent
```bash
# Install cursor-agent (if not already installed)
# Follow instructions at: https://github.com/getcursor/cursor-agent
```

#### CodeRabbit
```bash
# Install coderabbit (if not already installed)
# Follow instructions at: https://github.com/CodeRabbitAI/coderabbit
```

## Installation Methods

### Method 1: Lazy.nvim (Recommended)

1. **Install NvChad first:**
```bash
git clone https://github.com/NvChad/NvChad ~/.config/nvim
```

2. **Add Nvibe to your Lazy.nvim config:**
```lua
-- In ~/.config/nvim/lua/plugins/init.lua
return {
  -- ... other plugins ...
  
  {
    'michaelmonetized/nvibe',
    config = function()
      require('nvibe').setup()
    end
  }
}
```

3. **Restart Neovim:**
```bash
nvim
```

### Method 2: Packer.nvim

1. **Install NvChad first:**
```bash
git clone https://github.com/NvChad/NvChad ~/.config/nvim
```

2. **Add Nvibe to your Packer config:**
```lua
-- In your packer config
use {
  'michaelmonetized/nvibe',
  config = function()
    require('nvibe').setup()
  end
}
```

3. **Install and sync:**
```lua
:PackerInstall
:PackerSync
```

### Method 3: Manual Installation

1. **Install NvChad first:**
```bash
git clone https://github.com/NvChad/NvChad ~/.config/nvim
```

2. **Clone Nvibe:**
```bash
git clone https://github.com/michaelmonetized/nvibe.git ~/.config/nvim/lua/nvibe
```

3. **Add to your init.lua:**
```lua
-- In ~/.config/nvim/init.lua
require('nvibe').setup()
```

## Verification

After installation, verify everything works:

1. **Open Neovim:**
```bash
nvim
```

2. **Check for errors:**
Look for any error messages in the command line or `:messages`

3. **Verify terminal split:**
You should see:
- A terminal panel on the left (30% width)
- Cursor Agent running in the top terminal
- CodeRabbit running in the bottom terminal

## Troubleshooting

### Common Issues

#### 1. "module 'nvchad.term' not found"
**Problem**: NvChad is not installed or not properly configured.

**Solution**:
```bash
# Make sure NvChad is installed
ls ~/.config/nvim/lua/nvchad/term.lua

# If missing, reinstall NvChad
rm -rf ~/.config/nvim
git clone https://github.com/NvChad/NvChad ~/.config/nvim
```

#### 2. "command not found: cursor-agent"
**Problem**: Cursor Agent is not installed or not in PATH.

**Solution**:
```bash
# Check if cursor-agent is installed
which cursor-agent

# If not found, install it following their documentation
# https://github.com/getcursor/cursor-agent
```

#### 3. "command not found: coderabbit"
**Problem**: CodeRabbit is not installed or not in PATH.

**Solution**:
```bash
# Check if coderabbit is installed
which coderabbit

# If not found, install it following their documentation
# https://github.com/CodeRabbitAI/coderabbit
```

#### 4. Terminals not interactive
**Problem**: Terminals are showing as text buffers instead of interactive shells.

**Solution**: This usually means NvChad's term module isn't working properly. Reinstall NvChad:
```bash
rm -rf ~/.config/nvim
git clone https://github.com/NvChad/NvChad ~/.config/nvim
```

### Debug Mode

Enable debug logging to see what's happening:

```lua
-- In your Neovim config
vim.g.nvibe_debug = true
```

Then check `:messages` for debug output.

## Alternative Configurations

### Using Different Terminal Plugin

If you want to use a different terminal plugin instead of NvChad's term module:

1. **Modify the plugin code:**
```lua
-- In lua/nvibe/init.lua, replace:
require("nvchad.term").new {
  pos = "sp",
  cmd = config.cursor_agent_cmd,
  size = 0.5
}

-- With your preferred terminal plugin's API
```

2. **Update the documentation:**
Make sure to document the changes for future maintenance.

### Custom Terminal Commands

You can customize the terminal commands:

```lua
require('nvibe').setup({
  cursor_agent_cmd = "cursor-agent --verbose",
  coderabbit_cmd = "coderabbit --config ~/.coderabbit.json"
})
```

## Uninstallation

To remove Nvibe:

1. **Remove from plugin manager:**
   - Lazy.nvim: Remove from plugins list
   - Packer: Remove from use() calls
   - Manual: Remove the lua/nvibe directory

2. **Remove configuration:**
   - Remove `require('nvibe').setup()` from init.lua
   - Remove any custom keybindings

3. **Restart Neovim:**
```bash
nvim
```

## Getting Help

If you're still having issues:

1. **Check the logs**: `:messages`
2. **Enable debug mode**: `vim.g.nvibe_debug = true`
3. **Open an issue**: [GitHub Issues](https://github.com/michaelmonetized/nvibe/issues)
4. **Join discussions**: [GitHub Discussions](https://github.com/michaelmonetized/nvibe/discussions)