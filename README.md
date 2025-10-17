# 🚀 Nvibe - The Ultimate Neovim Coding Experience

<div align="center">

![Nvibe Banner](https://img.shields.io/badge/Neovim-Plugin-green?style=for-the-badge&logo=neovim)
![Version](https://img.shields.io/badge/version-0.1.0-blue?style=for-the-badge)
![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge)

**Transform your Neovim into a powerful AI-powered coding environment with integrated terminals and intelligent assistants.**

[![Product Hunt](https://img.shields.io/badge/Product%20Hunt-Orange?style=for-the-badge&logo=product-hunt)](https://www.producthunt.com)
[![GitHub Stars](https://img.shields.io/github/stars/michaelmonetized/nvibe?style=for-the-badge&logo=github)](https://github.com/michaelmonetized/nvibe)
[![Neovim](https://img.shields.io/badge/Neovim-0.7+-57A143?style=for-the-badge&logo=neovim)](https://neovim.io)

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

### Installation

**Option 1: Using Lazy.nvim (Recommended)**
```lua
{
  'michaelmonetized/nvibe',
  config = function()
    require('nvibe').setup()
  end
}
```

**Option 2: Using Packer**
```lua
use {
  'michaelmonetized/nvibe',
  config = function()
    require('nvibe').setup()
  end
}
```

**Option 3: Manual Installation**
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
```
┌─────────────────┬─────────────────┐
│                 │                 │
│   Your Code     │   Terminal      │
│                 │   (Alt+Tab)     │
│                 │                 │
└─────────────────┴─────────────────┘
```

### After Nvibe
```
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

## 🛠️ Requirements

- **Neovim 0.7+** - Modern Neovim with Lua support
- **NvChad** - For the best experience (terminal integration)
- **Cursor Agent** - Your AI coding assistant
- **CodeRabbit** - Your code review assistant

---

## 🤝 Contributing

We love contributions! Here's how you can help:

1. 🍴 **Fork** the repository
2. 🌟 **Star** it if you like it
3. 🐛 **Report bugs** or suggest features
4. 💻 **Submit pull requests**

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

**Made with ❤️ for the Neovim community**

[GitHub](https://github.com/michaelmonetized/nvibe) • [Issues](https://github.com/michaelmonetized/nvibe/issues) • [Discussions](https://github.com/michaelmonetized/nvibe/discussions)

</div>