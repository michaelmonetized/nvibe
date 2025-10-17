-- Test script for the nvibe plugin
-- This can be run with: nvim -c "source test_plugin.lua"

-- Load the plugin
local nvibe = require('nvibe')

-- Test the setup function
print("Testing nvibe plugin...")

-- Test configuration
local test_config = {
  width_percent = 25,
  cursor_agent_cmd = "cursor-agent",
  coderabbit_cmd = "coderabbit"
}

-- Setup the plugin with test configuration
nvibe.setup(test_config)

print("Plugin setup complete!")
print("The terminal split should be created automatically on VimEnter")
print("You can also manually trigger it with: lua require('nvibe').create_terminal_split()")
print("Note: The terminals should be interactive and not show line numbers")
print("Cursor-agent should be in the top-left pane, coderabbit in the bottom-left pane")
print("If coderabbit is not available, a fallback message will be shown")