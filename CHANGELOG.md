# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.1] - 2024-12-19

### Added
- Configurable bottom panel height via `bottom_panel_height_percent` option
- Configurable terminal commands via `lazygit_cmd` and `shell_cmd` options
- Flexible bottom panel terminal configuration via `bottom_panel_terminals` array
- Individual terminal naming for better error reporting
- `create_bottom_panel()` function for modular bottom panel creation
- Smart layout management with `<leader>e` monitoring and automatic restoration
- Minimap integration that toggles before nvimtree when buffer has content
- Manual layout restoration via `M.restore_layout()` function
- Configuration options for layout management: `watch_leader_e`, `auto_restore_layout`, `toggle_minimap`

### Changed
- Bottom panel creation is now fully configurable instead of hardcoded
- Terminal commands can be customized per terminal in the bottom panel
- Improved error messages with terminal names for better debugging
- Renamed all ambiguous variable names (success/err) to be more descriptive
- Enhanced nvimtree handling with multiple fallback methods
- Improved layout stability with automatic restoration system

### Fixed
- nvimtree window balancing issue that was breaking the layout
- Layout stability when opening file explorer

## [0.1.0] - 2024-12-19

### Added
- Initial release
- Left panel with Cursor Agent and CodeRabbit terminals
- Bottom panel with LazyGit and Shell terminals
- Automatic layout creation on Neovim startup
- Basic configuration options for panel width and terminal commands