# Nvibe Roadmap

## 🚀 v0.1.0

- 🚀 Initial release

## 🚀 v0.1.1

- 🔧 Fix nvimtree window balancing issue
- 📝 Add v0.1.1 roadmap outline
- 🎯 Implement <leader>e keybind solution for layout stability
- ⚙️ Make bottom panel commands and sizes configurable
- 🔍 Watch for <leader>e and counter-act window balancing
- 🗺️ Toggle minimap before nvimtree if buffer not empty
- 🏷️ Rename variables and functions to remove ambiguity

@ISSUES
 - [x] opening nvimtree balances the window sizes, breaking the layout.
 - [ ] nvimtree takes up the full height of the right side not just the right side of the editor.

@TODO
 - [x] try opening NVIMTREE and switching back to the editor before we start splitting and launching terms
 - [x] create a roadmap
 - [x] make bottom panel commands and sizes configurable
 - [x] try watching for <leader>e and counter-acting the window balancing it does or make <leader>[ cycle through the windows and resize them according to the config.
 - [x] test with minimap
 - [x] toggle minimap before nvimtree if there is a not empty buffer in the original window.
 - [x] rename success/err vars and functions, minimap_toggle, nvimtree_toggle, left_top, left_bottom, bottom_left, bottom_middle, bottom_right to remove ambiguity from the dx
 - [ ] add more documentation to the plugin init.lua file.
 - [ ] update the README.md file with the new features and usage.
 - [ ] add a screenshot to the README.md file. [@screenshot.png]
 - [ ] update docs/CUSTOMIZATION.md with the new features and usage.
 - [ ] add a LICENSE.md file.
 - [ ] add a CONTRIBUTING.md file.
