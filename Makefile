# Makefile for Nvibe plugin development

.PHONY: test test-coverage install-deps clean help

# Default target
all: test

# Install test dependencies
install-deps:
	@echo "📦 Installing test dependencies..."
	luarocks install busted
	luarocks install luacheck

# Run tests
test:
	@echo "🧪 Running tests..."
	busted tests/ --verbose

# Run tests with coverage
test-coverage:
	@echo "📊 Running tests with coverage..."
	busted tests/ --verbose --coverage

# Run linter
lint:
	@echo "🔍 Running linter..."
	luacheck lua/ tests/ --globals vim os

# Run all checks
check: lint test
	@echo "✅ All checks passed!"

# Clean up
clean:
	@echo "🧹 Cleaning up..."
	rm -f coverage.json
	rm -rf .busted

# Help
help:
	@echo "Available targets:"
	@echo "  install-deps  - Install test dependencies"
	@echo "  test         - Run tests"
	@echo "  test-coverage- Run tests with coverage"
	@echo "  lint         - Run linter"
	@echo "  check        - Run linter and tests"
	@echo "  clean        - Clean up generated files"
	@echo "  help         - Show this help"