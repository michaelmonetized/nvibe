-- Unit tests for Nvibe plugin
-- Run with: busted tests/

local busted = require("busted")
local assert = require("luassert")
local spy = require("luassert.spy")
local stub = require("luassert.stub")

-- Mock Neovim API
local mock_vim = {
  api = {
    nvim_create_autocmd = spy.new(function() end),
  },
  cmd = spy.new(function() end),
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
  new = spy.new(function() end)
}

-- Mock os module
local mock_os = {
  getenv = spy.new(function(name)
    if name == "COLS" then
      return "160"
    end
    return nil
  end)
}

-- Set up mocks before requiring the module
_G.vim = mock_vim
_G.os = mock_os
package.loaded["nvchad.term"] = mock_nvchad_term

-- Now require the module
local nvibe = require("nvibe")

describe("Nvibe Plugin", function()
  
  describe("get_terminal_width", function()
    it("should calculate width based on COLS environment variable", function()
      -- This tests the internal function indirectly through create_terminal_split
      nvibe.create_terminal_split()
      
      -- Verify that vertical resize was called with correct width
      -- 160 * 0.3 = 48
      assert.spy(mock_vim.cmd).was_called_with("vertical resize 48")
    end)
    
    it("should fallback to vim.o.columns when COLS is not set", function()
      -- Reset the mock
      mock_os.getenv:clear()
      mock_os.getenv:return_values({nil})
      
      nvibe.create_terminal_split()
      
      -- Verify fallback calculation: 120 * 0.3 = 36
      assert.spy(mock_vim.cmd).was_called_with("vertical resize 36")
    end)
  end)
  
  describe("create_terminal_split", function()
    beforeEach(function()
      -- Reset all spies before each test
      mock_vim.cmd:clear()
      mock_nvchad_term.new:clear()
    end)
    
    it("should create vertical split and resize window", function()
      nvibe.create_terminal_split()
      
      assert.spy(mock_vim.cmd).was_called_with("leftabove vnew")
      assert.spy(mock_vim.cmd).was_called_with("vertical resize 48")
    end)
    
    it("should create cursor-agent terminal", function()
      nvibe.create_terminal_split()
      
      assert.spy(mock_nvchad_term.new).was_called_with({
        pos = "sp",
        cmd = "cursor-agent",
        size = 0.5
      })
    end)
    
    it("should create coderabbit terminal", function()
      nvibe.create_terminal_split()
      
      assert.spy(mock_nvchad_term.new).was_called_with({
        pos = "sp",
        cmd = "coderabbit", 
        size = 0.5
      })
    end)
    
    it("should close empty buffer and return to main window", function()
      nvibe.create_terminal_split()
      
      assert.spy(mock_vim.cmd).was_called_with("wincmd k")
      assert.spy(mock_vim.cmd).was_called_with("wincmd k")
      assert.spy(mock_vim.cmd).was_called_with("close")
      assert.spy(mock_vim.cmd).was_called_with("wincmd l")
      assert.spy(mock_vim.cmd).was_called_with("stopinsert")
    end)
  end)
  
  describe("setup", function()
    beforeEach(function()
      mock_vim.api.nvim_create_autocmd:clear()
    end)
    
    it("should create VimEnter autocmd", function()
      nvibe.setup()
      
      assert.spy(mock_vim.api.nvim_create_autocmd).was_called_with("VimEnter", {
        pattern = "*",
        callback = assert.is_function()
      })
    end)
    
    it("should merge user options with default config", function()
      local user_opts = {
        width_percent = 40,
        cursor_agent_cmd = "custom-cursor-agent"
      }
      
      nvibe.setup(user_opts)
      
      -- Verify autocmd was created
      assert.spy(mock_vim.api.nvim_create_autocmd).was_called()
    end)
    
    it("should not run terminal split if already in terminal buffer", function()
      mock_vim.bo.buftype = "terminal"
      
      nvibe.setup()
      
      -- Get the callback function
      local autocmd_call = mock_vim.api.nvim_create_autocmd.calls[1]
      local callback = autocmd_call[2].callback
      
      -- Mock the create_terminal_split function
      local create_terminal_split_spy = spy.on(nvibe, "create_terminal_split")
      
      -- Call the callback
      callback()
      
      -- Should not have called create_terminal_split
      assert.spy(create_terminal_split_spy).was_not_called()
    end)
    
    it("should run terminal split if not in terminal buffer", function()
      mock_vim.bo.buftype = "normal"
      
      nvibe.setup()
      
      -- Get the callback function
      local autocmd_call = mock_vim.api.nvim_create_autocmd.calls[1]
      local callback = autocmd_call[2].callback
      
      -- Mock the create_terminal_split function
      local create_terminal_split_spy = spy.on(nvibe, "create_terminal_split")
      
      -- Call the callback
      callback()
      
      -- Should have called create_terminal_split
      assert.spy(create_terminal_split_spy).was_called()
    end)
  end)
  
  describe("configuration", function()
    it("should use default configuration when no options provided", function()
      nvibe.setup()
      
      -- The default config should be used
      -- This is tested indirectly through the terminal creation
      nvibe.create_terminal_split()
      
      assert.spy(mock_nvchad_term.new).was_called_with({
        pos = "sp",
        cmd = "cursor-agent",
        size = 0.5
      })
    end)
  end)
end)