#!/usr/bin/env lua
-- Test runner script for Nvibe plugin
-- Usage: lua scripts/run_tests.lua

local busted = require("busted")

-- Set up test environment
local original_require = require
local mock_modules = {}

-- Mock Neovim API
local mock_vim = {
  api = {
    nvim_create_autocmd = function() end,
  },
  cmd = function() end,
  bo = {
    buftype = "normal"
  },
  o = {
    columns = 120
  },
  tbl_deep_extend = function(behavior, target, ...)
    local sources = {...}
    for _, source in ipairs(sources) do
      for k, v in pairs(source) do
        target[k] = v
      end
    end
    return target
  end
}

-- Mock NvChad term module
local mock_nvchad_term = {
  new = function() end
}

-- Mock os module
local mock_os = {
  getenv = function(name)
    if name == "COLS" then
      return "160"
    end
    return nil
  end
}

-- Override require to inject mocks
require = function(module_name)
  if module_name == "nvchad.term" then
    return mock_nvchad_term
  end
  return original_require(module_name)
end

-- Set global mocks
_G.vim = mock_vim
_G.os = mock_os

print("🧪 Running Nvibe Plugin Tests...")
print("=" .. string.rep("=", 50))

-- Run the tests
busted.run({
  pattern = "tests/",
  verbose = true,
  coverage = true
})

print("=" .. string.rep("=", 50))
print("✅ Tests completed!")