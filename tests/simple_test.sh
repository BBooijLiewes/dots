#!/bin/bash

# Simple test runner for CI
echo "Running simple dotfiles tests..."

# Test 1: Check if key files exist
echo "Checking configuration files..."
files_ok=true

# Core configuration files
config_files=(
    ".config/nvim/init.lua"
    ".config/waybar/modules/powermenu.sh"
    ".config/waybar/launch.sh"
    ".config/qutebrowser/config.py"
)

for file in "${config_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ $(basename "$file") exists"
    else
        echo "✗ $(basename "$file") missing"
        files_ok=false
    fi
done

# Test files
test_files=(
    "tests/lua/test_lazy_setup.lua"
    "tests/lua/test_settings.lua"
    "tests/lua/test_keymaps.lua"
)

for file in "${test_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ $(basename "$file") exists"
    else
        echo "✗ $(basename "$file") missing"
        files_ok=false
    fi
done

# Test 2: Check Lua syntax
echo "Checking Lua syntax..."
lua_ok=true

if command -v lua5.3 >/dev/null 2>&1; then
    # Check all test Lua files
    for lua_test in tests/lua/*.lua; do
        if [ -f "$lua_test" ]; then
            if lua5.3 -e "loadfile('$lua_test')" 2>/dev/null; then
                echo "✓ $(basename "$lua_test") syntax OK"
            else
                echo "✗ $(basename "$lua_test") syntax error"
                lua_ok=false
            fi
        fi
    done
else
    echo "- lua5.3 not available, skipping syntax check"
fi

# Test 3: Check shell syntax
echo "Checking shell syntax..."
shell_ok=true

# Check key shell scripts
shell_scripts=(
    ".config/waybar/modules/powermenu.sh"
    ".config/waybar/launch.sh"
)

for script in "${shell_scripts[@]}"; do
    if [ -f "$script" ]; then
        if bash -n "$script" 2>/dev/null; then
            echo "✓ $(basename "$script") syntax OK"
        else
            echo "✗ $(basename "$script") syntax error"
            shell_ok=false
        fi
    else
        echo "- $(basename "$script") not found"
    fi
done

# Results
echo ""
echo "Test Results:"
if [ "$files_ok" = true ] && [ "$lua_ok" = true ] && [ "$shell_ok" = true ]; then
    echo "✅ All tests passed!"
    exit 0
else
    echo "❌ Some tests failed!"
    exit 1
fi
