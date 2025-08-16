# Testing Guide

This repository includes a comprehensive testing suite to validate the dotfiles configuration across different environments and use cases.

## Quick Start

```bash
# Run all tests
./tests/run_tests.sh

# Run specific test categories
./tests/run_tests.sh lua
./tests/run_tests.sh shell
./tests/run_tests.sh integration
```

## Test Categories

### 1. Lua Configuration Tests (`tests/lua/`)

Tests for Neovim Lua configurations including:

- **lazy_setup.lua**: Plugin manager installation and configuration
- **settings.lua**: Vim options and global settings
- **keymaps.lua**: Key binding configurations

**What's tested:**
- Function behavior with different inputs
- Configuration option validation
- Keymap registration and options
- Mock vim API interactions

### 2. Shell Script Tests (`tests/shell/`)

Tests for shell scripts and utilities:

- **waybar modules**: JSON output validation, script execution
- **launch scripts**: Process management, error handling

**What's tested:**
- Script output format validation
- JSON structure verification
- Process management logic
- Error handling scenarios

### 3. Integration Tests (`tests/integration/`)

End-to-end validation of the complete configuration:

- File existence and permissions
- Directory structure validation
- Cross-component compatibility
- Syntax validation

**What's tested:**
- All required configuration files exist
- Scripts have proper permissions
- Lua syntax is valid (with vim-specific considerations)
- Directory structure is correct

## Test Structure

```
tests/
├── README.md              # Test documentation
├── run_tests.sh           # Main test runner
├── lua/                   # Lua configuration tests
│   ├── test_lazy_setup.lua
│   ├── test_settings.lua
│   └── test_keymaps.lua
├── shell/                 # Shell script tests
│   └── test_waybar_modules.sh
└── integration/           # Integration tests (built into runner)
```

## Dependencies

The test suite requires:

- **Lua 5.3 or 5.4**: For running Lua configuration tests
- **Bash**: For shell script tests and test runner
- **Python 3** (optional): For enhanced JSON validation

Install on Ubuntu/Debian:
```bash
sudo apt-get install lua5.3 python3
```

## Continuous Integration

The repository includes GitHub Actions workflow (`.github/workflows/test.yml`) that:

- Runs tests on multiple Lua versions
- Performs shell script linting with shellcheck
- Validates Lua syntax
- Runs on push/PR to master/main branches

## Writing New Tests

### Lua Tests

Create a new test file in `tests/lua/`:

```lua
-- tests/lua/test_new_feature.lua

local test_results = { passed = 0, failed = 0, total = 0 }

local function log_test(name)
    print("🧪 Testing: " .. name)
    test_results.total = test_results.total + 1
end

local function log_pass(message)
    print("✅ PASS: " .. message)
    test_results.passed = test_results.passed + 1
end

local function log_fail(message)
    print("❌ FAIL: " .. message)
    test_results.failed = test_results.failed + 1
end

local function test_your_feature()
    log_test("your feature description")
    
    -- Your test logic here
    if condition then
        log_pass("test passed")
    else
        log_fail("test failed")
    end
end

local function run_tests()
    print("Running new feature tests...")
    test_your_feature()
    
    return test_results.failed == 0
end

return { run_tests = run_tests, test_results = test_results }
```

### Shell Tests

Add test functions to `tests/shell/test_waybar_modules.sh` or create new shell test files following the same pattern.

### Integration Tests

Add new integration tests to the `run_integration_tests()` function in `tests/run_tests.sh`.

## Test Output

The test runner provides colored output:

- 🧪 **Yellow**: Test being executed
- ✅ **Green**: Test passed
- ❌ **Red**: Test failed
- 🔵 **Blue**: Informational messages
- 🟣 **Purple**: Section headers

## Troubleshooting

### Common Issues

1. **Lua not found**: Install lua5.3 or lua5.4
2. **Permission denied**: Make sure test scripts are executable (`chmod +x`)
3. **Vim-specific syntax errors**: Expected for some Lua files that use vim APIs

### Debug Mode

Run individual test categories to isolate issues:

```bash
# Debug Lua tests only
./tests/run_tests.sh lua

# Debug shell tests only  
./tests/run_tests.sh shell

# Debug integration tests only
./tests/run_tests.sh integration
```

### Manual Test Execution

Run individual test files directly:

```bash
# Lua tests
lua5.3 -e "package.path='./tests/lua/?.lua;'..package.path; require('test_lazy_setup').run_tests()"

# Shell tests
./tests/shell/test_waybar_modules.sh
```

## Contributing

When adding new configuration files or features:

1. Add corresponding tests in the appropriate category
2. Update the integration tests if new files/directories are added
3. Run the full test suite before submitting changes
4. Ensure CI passes on your branch

The test suite helps maintain configuration quality and prevents regressions across different environments.
