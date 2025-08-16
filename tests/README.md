# Dotfiles Test Suite

This directory contains comprehensive tests for the dotfiles configuration.

## Structure

- `lua/` - Tests for Neovim Lua configurations
- `shell/` - Tests for shell scripts and utilities
- `integration/` - Integration tests for complete workflows
- `run_tests.sh` - Main test runner script

## Running Tests

```bash
# Run all tests
./tests/run_tests.sh

# Run specific test category
./tests/run_tests.sh lua
./tests/run_tests.sh shell
./tests/run_tests.sh integration
```

## Test Categories

### Lua Tests
- Neovim configuration validation
- Plugin setup verification
- Keymap functionality
- Settings validation

### Shell Tests
- Waybar module functionality
- Script execution validation
- Environment setup

### Integration Tests
- Complete configuration loading
- Cross-component compatibility
- Performance benchmarks
