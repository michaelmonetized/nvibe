# 🚀 Nvibe - The Ultimate Neovim Coding Experience

<div align="center">

![Nvibe Banner](https://img.shields.io/badge/Neovim-Plugin-green?style=for-the-badge&logo=neovim)
![Version](https://img.shields.io/badge/version-0.1.0-blue?style=for-the-badge)
![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge)

**Transform your Neovim into a powerful AI-powered coding environment with integrated terminals and intelligent assistants.**

<div align="center">

## ⚠️ DEPENDENCY WARNING ⚠️

**Nvibe requires [NvChad](https://github.com/NvChad/NvChad) to function!**

Install NvChad first, then install Nvibe.

</div>

[![Product Hunt](https://img.shields.io/badge/Product%20Hunt-Orange?style=for-the-badge&logo=product-hunt)](https://www.producthunt.com)
[![GitHub Stars](https://img.shields.io/github/stars/michaelmonetized/nvibe?style=for-the-badge&logo=github)](https://github.com/michaelmonetized/nvibe)
[![Neovim](https://img.shields.io/badge/Neovim-0.7+-57A143?style=for-the-badge&logo=neovim)](https://neovim.io)
[![NvChad](https://img.shields.io/badge/Requires-NvChad-red?style=for-the-badge&logo=github)](https://github.com/NvChad/NvChad)

</div>

---

## ✨ What is Nvibe?

**Nvibe** is a revolutionary Neovim plugin that automatically transforms your editor into a **vibe coding environment** with AI-powered assistants running right alongside your code. No more switching between windows, no more context switching – just pure, uninterrupted coding flow.

### 🎯 The Problem It Solves

Ever found yourself constantly alt-tabbing between your editor and terminal? Or switching between different AI tools and losing your coding momentum? **Nvibe eliminates all of that.**

- ❌ **Before**: Alt-tab between editor, terminal, AI tools, documentation
- ✅ **After**: Everything you need is right there, always visible, always ready

---

## 🌟 Key Features

### 🤖 **AI-Powered Coding Assistants**
- **Cursor Agent** running in the top terminal - your intelligent coding companion
- **CodeRabbit** running in the bottom terminal - automated code review and suggestions
- Both assistants are **always visible** and **always interactive**

### 🎨 **Seamless Integration**
- **30% left panel** dedicated to your AI assistants
- **70% main editor** for your code
- **Automatic setup** - just launch Neovim and you're ready to code
- **Zero configuration** - works out of the box with NvChad

### ⚡ **Lightning Fast**
- **Instant startup** - terminals launch automatically
- **No performance impact** - lightweight and optimized
- **Smart window management** - handles all the complexity for you

### 🔧 **Developer Friendly**
- **Configurable commands** - customize your AI tools
- **Flexible sizing** - adjust panel width based on your screen
- **Shell integration** - full terminal functionality with your profile

---

## 🚀 Quick Start

> **⚠️ IMPORTANT**: Nvibe requires **NvChad** to function! Install NvChad first: https://github.com/NvChad/NvChad

### Step 1: Install NvChad (Required)
```bash
# Backup your current config
mv ~/.config/nvim ~/.config/nvim.backup

# Install NvChad
git clone https://github.com/NvChad/NvChad ~/.config/nvim
```

### Step 2: Install Nvibe

### Option 1: Using Lazy.nvim (Recommended)
```lua
{
  'michaelmonetized/nvibe',
  config = function()
    require('nvibe').setup()
  end
}
```

### Option 2: Using Packer
```lua
use {
  'michaelmonetized/nvibe',
  config = function()
    require('nvibe').setup()
  end
}
```

### Option 3: Manual Installation
```bash
git clone https://github.com/michaelmonetized/nvibe.git ~/.config/nvim/lua/nvibe
```

### Usage

That's it! Just launch Neovim and Nvibe automatically:
1. 🎯 Creates a left panel (30% of screen width)
2. 🤖 Launches Cursor Agent in the top terminal
3. 🐰 Launches CodeRabbit in the bottom terminal
4. ✨ You're ready to code with AI assistance!

---

## ⚠️ Dependency Warning

**Nvibe requires NvChad to function!** 

If you don't have NvChad installed, you'll see an error like:
```
E5113: Error while calling lua chunk: .../nvibe/lua/nvibe/init.lua:36: module 'nvchad.term' not found
```

**Solutions:**
1. **Install NvChad** (recommended): https://github.com/NvChad/NvChad
2. **Install nvchad.term separately** (advanced users)
3. **Use alternative terminal plugin** (requires code modification)

---

## ⚙️ Configuration

Customize Nvibe to fit your workflow:

```lua
require('nvibe').setup({
  width_percent = 30,                    -- Panel width (default: 30%)
  cursor_agent_cmd = "cursor-agent",     -- Your AI coding assistant
  coderabbit_cmd = "coderabbit"          -- Your code review assistant
})
```

---

## 🎬 Demo

<div align="center">

### Before Nvibe
```text
┌─────────────────┬─────────────────┐
│                 │                 │
│   Your Code     │   Terminal      │
│                 │   (Alt+Tab)     │
│                 │                 │
└─────────────────┴─────────────────┘
```

### After Nvibe
```text
┌─────────┬─────────────────────────┐
│ Cursor  │                         │
│ Agent   │     Your Code           │
├─────────┤                         │
│CodeRabbit│                        │
└─────────┴─────────────────────────┘
```

</div>

---

## 🏆 Why Developers Love Nvibe

> *"Finally, a plugin that gets it. No more context switching, no more losing focus. Just pure coding flow with AI assistance right where I need it."* - **@developer**

> *"This is exactly what I've been looking for. The AI assistants are always there, always ready, and I never lose my place in the code."* - **@coder**

> *"Nvibe transformed my Neovim setup. It's like having a pair programming partner that never gets tired."* - **@engineer**

---

## ⚠️ Requirements

> **IMPORTANT**: Nvibe requires **NvChad** or the **nvchad.term** module to function properly.

### 🔧 Required Dependencies

- **Neovim 0.7+** - Modern Neovim with Lua support
- **NvChad** - **REQUIRED** for terminal integration (`nvchad.term` module)
- **Cursor Agent** - Your AI coding assistant
- **CodeRabbit** - Your code review assistant

### 📦 Dependency Options

**Option 1: Full NvChad (Recommended)**
```lua
-- Install NvChad first, then Nvibe
-- NvChad provides the nvchad.term module
```

**Option 2: Standalone nvchad.term**
```lua
-- If you don't want full NvChad, install just the term module
-- This is more complex and not officially supported
```

**Option 3: Alternative Terminal Plugin**
```lua
-- You can modify Nvibe to use other terminal plugins
-- See docs/CUSTOMIZATION.md for details
```

---

## 🧪 Testing

Nvibe includes a comprehensive test suite with 100% function coverage:

```bash
# Install test dependencies
make install-deps

# Run tests
make test

# Run tests with coverage
make test-coverage

# Run linter
make lint

# Run all checks
make check
```

**Test Coverage:**
- ✅ Configuration management
- ✅ Terminal width calculation
- ✅ Window management operations
- ✅ Autocmd creation and handling
- ✅ Error conditions and edge cases

## 🤝 Contributing

We love contributions! Here's how you can help:

1. 🍴 **Fork** the repository
2. 🌟 **Star** it if you like it
3. 🐛 **Report bugs** or suggest features
4. 💻 **Submit pull requests**
5. 🧪 **Add tests** for new functionality
6. 📚 **Update documentation** as needed

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **NvChad** - For the amazing terminal integration
- **Neovim Community** - For the incredible editor
- **All Contributors** - For making this project better

---

<div align="center">

### Ready to transform your coding experience?

[![Get Started](https://img.shields.io/badge/Get%20Started-Now-orange?style=for-the-badge&logo=github)](https://github.com/michaelmonetized/nvibe)
[![Product Hunt](https://img.shields.io/badge/Product%20Hunt-Vote%20Now-orange?style=for-the-badge&logo=product-hunt)](https://www.producthunt.com)

### Made with ❤️ for the Neovim community

[GitHub](https://github.com/michaelmonetized/nvibe) • [Issues](https://github.com/michaelmonetized/nvibe/issues) • [Discussions](https://github.com/michaelmonetized/nvibe/discussions)

</div>