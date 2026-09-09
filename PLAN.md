# Nvibe Development Plan

## Project Overview

Nvibe is a Neovim plugin that transforms the editor into an AI-powered coding environment with integrated terminals. It creates a multi-panel layout with AI assistants (Cursor Agent, CodeRabbit), LazyGit, and shell terminals always visible alongside your code. Requires NvChad for terminal integration.

**Tech Stack:** Lua, Neovim 0.7+, NvChad (required dependency)

## Current State

- Version 0.1.x released (see CHANGELOG; git history starts **2025-10-17**)
- Core layout system working (left panel for AI, bottom panel for tools)
- NvChad terminal integration via `nvchad.term`
- Cursor Agent, CodeRabbit, LazyGit, and shell terminals supported
- Smart layout restoration with `<leader>e` keybinding
- Minimap integration
- Test suite + Makefile
- **LICENSE:** MIT file present at repo root

## Phase 1: Stability & Compatibility (open)

### Deliverables
- [ ] Optional NvChad dependency (fallback to toggleterm)
- [ ] Graceful degradation when tools unavailable
- [ ] Windows/Linux/macOS testing
- [ ] Better error messages for missing dependencies
- [ ] Configuration validation on setup
- [ ] Documentation for non-NvChad users

## Phase 2: Enhanced Features (open)

### Deliverables
- [ ] GitHub Copilot Chat integration option
- [ ] Claude/ChatGPT CLI integrations
- [ ] Layout persistence across sessions
- [ ] Quick-switch between layout presets
- [ ] Terminal session persistence
- [ ] Custom keybinding configuration
- [ ] Per-project configuration support

## Phase 3: Polish & Community (open)

### Deliverables
- [ ] Lazy loading for faster startup
- [ ] Memory usage optimization
- [ ] Theme integration (match Neovim colorscheme)
- [ ] Plugin API for extensions
- [ ] Community layout preset sharing
- [ ] Video tutorials and demos
- [ ] ~~Product Hunt launch preparation~~ **Deferred** — README badges currently point at producthunt.com root, not a real launch page. Do not treat PH launch as an active milestone.

## Success Metrics

| Metric | Target |
|--------|--------|
| GitHub stars | 500+ |
| Plugin manager installs | 1000+ |
| Issues resolved | < 5 open |
| Startup time impact | < 50ms |
| Test coverage | maintain high coverage |

*PLAN parity sync: 2026-09-08 — deferred fictitious Product Hunt launch; noted LICENSE + git history date.*
