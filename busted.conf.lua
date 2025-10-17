-- Busted configuration for Nvibe plugin tests
-- Run with: busted tests/

return {
  default = {
    coverage = true,
    coverage_file = "coverage.json",
    verbose = true,
    suppress = {
      "luacheck"
    }
  },
  -- Test patterns
  pattern = "tests/",
  -- Coverage patterns
  coverage = {
    "lua/nvibe/init.lua"
  }
}