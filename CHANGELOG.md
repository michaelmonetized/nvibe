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

### Changed
- Bottom panel creation is now fully configurable instead of hardcoded
- Terminal commands can be customized per terminal in the bottom panel
- Improved error messages with terminal names for better debugging

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