# Nvibe Development Plan

## Project Overview

Nvibe is a Neovim plugin that transforms the editor into an AI-powered coding environment with integrated terminals. It creates a multi-panel layout with AI assistants (Cursor Agent, CodeRabbit), LazyGit, and shell terminals always visible alongside your code. Requires NvChad for terminal integration.

**Tech Stack:** Lua, Neovim 0.7+, NvChad (required dependency)

## Current State

- Version 0.1.1 released
- Core layout system working (left panel for AI, bottom panel for tools)
- NvChad terminal integration via `nvchad.term`
- Cursor Agent, CodeRabbit, LazyGit, and shell terminals supported
- Smart layout restoration with `<leader>e` keybinding
- Minimap integration
- Comprehensive test suite with 100% function coverage
- Makefile for testing and linting

## Phase 1: Stability & Compatibility (Weeks 1-2)

### Goals
- Reduce NvChad hard dependency
- Improve error handling
- Cross-platform testing

### Deliverables
- [ ] Optional NvChad dependency (fallback to toggleterm)
- [ ] Graceful degradation when tools unavailable
- [ ] Windows/Linux/macOS testing
- [ ] Better error messages for missing dependencies
- [ ] Configuration validation on setup
- [ ] Documentation for non-NvChad users

## Phase 2: Enhanced Features (Weeks 3-5)

### Goals
- More AI tool integrations
- Layout persistence
- Session management

### Deliverables
- [ ] GitHub Copilot Chat integration option
- [ ] Claude/ChatGPT CLI integrations
- [ ] Layout persistence across sessions
- [ ] Quick-switch between layout presets
- [ ] Terminal session persistence
- [ ] Custom keybinding configuration
- [ ] Per-project configuration support

## Phase 3: Polish & Community (Weeks 6-8)

### Goals
- Performance optimization
- Community contributions
- Plugin ecosystem

### Deliverables
- [ ] Lazy loading for faster startup
- [ ] Memory usage optimization
- [ ] Theme integration (match Neovim colorscheme)
- [ ] Plugin API for extensions
- [ ] Community layout preset sharing
- [ ] Video tutorials and demos
- [ ] Product Hunt launch preparation

## Success Metrics

| Metric | Target |
|--------|--------|
| GitHub stars | 500+ |
| Plugin manager installs | 1000+ |
| Issues resolved | < 5 open |
| Startup time impact | < 50ms |
| Test coverage | 100% maintained |

## Timeline Summary

| Phase | Duration | Focus |
|-------|----------|-------|
| Phase 1 | Weeks 1-2 | Compatibility, error handling |
| Phase 2 | Weeks 3-5 | AI integrations, persistence |
| Phase 3 | Weeks 6-8 | Performance, community, launch |
