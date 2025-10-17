-- Test script for the nvibe plugin
-- This can be run with: nvim -c "source test_plugin.lua"

-- Load the plugin
local nvibe = require('nvibe')

-- Test the setup function
print("Testing nvibe plugin...")

-- Test configuration
local test_config = {
  width_percent = 25,
  cursor_agent_cmd = "echo 'Testing cursor-agent'",
  coderabbit_cmd = "echo 'Testing coderabbit'"
}

-- Setup the plugin with test configuration
nvibe.setup(test_config)

print("Plugin setup complete!")
print("The terminal split should be created automatically on VimEnter")
print("You can also manually trigger it with: lua require('nvibe').create_terminal_split()")