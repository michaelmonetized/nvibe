# Testing Guide for Nvibe

## Overview

Nvibe includes a comprehensive test suite using the Busted testing framework. This guide explains how to run tests, add new tests, and understand the testing architecture.

## Prerequisites

Install test dependencies:
```bash
make install-deps
# or manually:
luarocks install busted
luarocks install luacheck
```

## Running Tests

### Quick Test Run
```bash
make test
```

### Tests with Coverage
```bash
make test-coverage
```

### Linting Only
```bash
make lint
```

### All Checks
```bash
make check
```

## Test Structure

```
tests/
├── test_nvibe.lua          # Main test suite
└── fixtures/               # Test fixtures (if needed)

scripts/
└── run_tests.lua           # Custom test runner

busted.conf.lua             # Busted configuration
Makefile                    # Build and test commands
```

## Test Categories

### 1. Configuration Tests
- Default configuration values
- User option merging
- Configuration validation

### 2. Terminal Width Calculation
- COLS environment variable handling
- Fallback to vim.o.columns
- Width percentage calculations

### 3. Terminal Split Creation
- Window management operations
- Terminal creation with correct parameters
- Buffer cleanup
- Focus management

### 4. Setup and Initialization
- Autocmd creation
- Terminal buffer detection
- Plugin initialization

## Writing Tests

### Basic Test Structure
```lua
describe("Feature Name", function()
  it("should do something specific", function()
    -- Arrange
    local input = "test"
    
    -- Act
    local result = function_under_test(input)
    
    -- Assert
    assert.are.equal("expected", result)
  end)
end)
```

### Mocking Neovim API
```lua
local mock_vim = {
  cmd = spy.new(function() end),
  api = {
    nvim_create_autocmd = spy.new(function() end),
  },
  bo = { buftype = "normal" },
  o = { columns = 120 }
}
```

### Testing Async Operations
```lua
it("should handle async operations", function()
  local callback_called = false
  
  -- Set up async test
  some_async_function(function()
    callback_called = true
  end)
  
  -- Wait for completion
  assert.is_true(callback_called)
end)
```

## Test Coverage

The test suite aims for:
- **Function Coverage**: All public functions tested
- **Branch Coverage**: All conditional paths tested
- **Edge Cases**: Error conditions and boundary values
- **Integration**: End-to-end workflow testing

## Mocking Strategy

### Neovim API Mocking
- Mock `vim.cmd` for command execution
- Mock `vim.api.nvim_create_autocmd` for event handling
- Mock `vim.bo` and `vim.o` for buffer/window options

### External Dependencies
- Mock `nvchad.term` for terminal creation
- Mock `os.getenv` for environment variables
- Mock file system operations if needed

## Continuous Integration

### GitHub Actions (if implemented)
```yaml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install Lua
        run: sudo apt-get install lua5.3
      - name: Install dependencies
        run: make install-deps
      - name: Run tests
        run: make check
```

## Debugging Tests

### Verbose Output
```bash
busted tests/ --verbose
```

### Single Test File
```bash
busted tests/test_nvibe.lua
```

### Debug Mode
```lua
-- In test file
local busted = require("busted")
busted.setup({ verbose = true })
```

## Best Practices

### 1. Test Naming
- Use descriptive test names
- Follow "should [expected behavior] when [condition]"
- Group related tests in describe blocks

### 2. Test Organization
- One test per behavior
- Clear arrange/act/assert structure
- Reset mocks between tests

### 3. Assertions
- Use specific assertions (`are.equal`, `is_true`, etc.)
- Test both positive and negative cases
- Verify side effects and state changes

### 4. Mocking
- Mock external dependencies
- Verify mock interactions
- Keep mocks simple and focused

## Performance Testing

### Memory Usage
```lua
it("should not leak memory", function()
  local initial_memory = collectgarbage("count")
  
  -- Run operation multiple times
  for i = 1, 100 do
    nvibe.create_terminal_split()
  end
  
  local final_memory = collectgarbage("count")
  assert.is_true(final_memory - initial_memory < 1000) -- 1MB threshold
end)
```

### Execution Time
```lua
it("should complete within reasonable time", function()
  local start_time = os.clock()
  
  nvibe.create_terminal_split()
  
  local end_time = os.clock()
  assert.is_true(end_time - start_time < 1.0) -- 1 second threshold
end)
```

## Troubleshooting

### Common Issues

1. **Tests not running**: Check Lua path and dependencies
2. **Mock failures**: Verify mock setup and spy configuration
3. **Async test failures**: Ensure proper async handling
4. **Coverage issues**: Add tests for uncovered code paths

### Debug Commands
```bash
# Run specific test
busted tests/test_nvibe.lua --verbose

# Check Lua syntax
luacheck lua/ tests/

# Run with debug output
LUA_CPATH="./?.so" busted tests/
```

## Contributing

When adding new tests:
1. Follow existing test patterns
2. Add tests for new functionality
3. Update this documentation
4. Ensure all tests pass
5. Maintain good test coverage