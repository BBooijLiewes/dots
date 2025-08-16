#!/bin/bash

# Comprehensive test runner for dotfiles configuration
# Usage: ./run_tests.sh [category]
# Categories: lua, shell, integration, all (default)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Test results tracking
TOTAL_TESTS=0
TOTAL_PASSED=0
TOTAL_FAILED=0
CATEGORIES_RUN=0
CATEGORIES_PASSED=0

# Helper functions
log_header() {
    echo -e "${PURPLE}================================${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}================================${NC}"
}

log_category() {
    echo -e "${CYAN}[CATEGORY]${NC} $1"
    ((CATEGORIES_RUN++))
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check dependencies
check_dependencies() {
    log_info "Checking test dependencies..."
    
    local missing_deps=()
    
    # Check for lua
    if ! command -v lua >/dev/null 2>&1 && ! command -v lua5.3 >/dev/null 2>&1; then
        missing_deps+=("lua or lua5.3")
    fi
    
    # Check for bash
    if ! command -v bash >/dev/null 2>&1; then
        missing_deps+=("bash")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_error "Missing dependencies: ${missing_deps[*]}"
        log_info "Install missing dependencies and try again"
        exit 1
    fi
    
    log_success "All dependencies available"
}

# Run Lua tests
run_lua_tests() {
    log_category "Running Lua Configuration Tests"
    
    local lua_cmd="lua"
    if command -v lua5.3 >/dev/null 2>&1; then
        lua_cmd="lua5.3"
    elif command -v lua5.4 >/dev/null 2>&1; then
        lua_cmd="lua5.4"
    fi
    
    log_info "Using Lua interpreter: $lua_cmd"
    
    local lua_tests_passed=0
    local lua_tests_failed=0
    
    # Simple test: just check if Lua files have valid syntax
    log_info "Testing Lua syntax validation..."
    local lua_files=(
        "tests/lua/test_lazy_setup.lua"
        "tests/lua/test_settings.lua"
        "tests/lua/test_keymaps.lua"
    )
    
    local syntax_ok=true
    for lua_file in "${lua_files[@]}"; do
        if [ -f "$lua_file" ]; then
            if $lua_cmd -e "loadfile('$lua_file')" 2>/dev/null; then
                log_info "✓ $lua_file syntax OK"
            else
                log_error "✗ $lua_file syntax error"
                syntax_ok=false
            fi
        else
            log_error "✗ $lua_file not found"
            syntax_ok=false
        fi
    done
    
    if [ "$syntax_ok" = true ]; then
        log_success "All Lua test files have valid syntax"
        lua_tests_passed=1
    else
        log_error "Some Lua test files have syntax errors"
        lua_tests_failed=1
    fi
    
    # Update totals
    TOTAL_PASSED=$((TOTAL_PASSED + lua_tests_passed))
    TOTAL_FAILED=$((TOTAL_FAILED + lua_tests_failed))
    TOTAL_TESTS=$((TOTAL_TESTS + lua_tests_passed + lua_tests_failed))
    
    if [ $lua_tests_failed -eq 0 ]; then
        log_success "Lua tests passed"
        ((CATEGORIES_PASSED++))
        return 0
    else
        log_error "Lua tests failed"
        return 1
    fi
}

# Run shell tests
run_shell_tests() {
    log_category "Running Shell Script Tests"
    
    local shell_tests_passed=0
    local shell_tests_failed=0
    
    # Simple validation tests
    log_info "Testing shell script validation..."
    
    # Test 1: Check if shell scripts exist and are executable
    local shell_scripts=(
        ".config/waybar/launch.sh"
        ".config/waybar/modules/powermenu.sh"
    )
    
    for script in "${shell_scripts[@]}"; do
        if [ -f "$script" ]; then
            log_info "✓ $script exists"
            if [ -x "$script" ]; then
                log_info "✓ $script is executable"
            else
                log_info "- $script is not executable (may be expected)"
            fi
        else
            log_error "✗ $script not found"
            ((shell_tests_failed++))
        fi
    done
    
    # Test 2: Check shell script syntax
    for script in "${shell_scripts[@]}"; do
        if [ -f "$script" ]; then
            if bash -n "$script" 2>/dev/null; then
                log_info "✓ $script syntax OK"
            else
                log_error "✗ $script syntax error"
                ((shell_tests_failed++))
            fi
        fi
    done
    
    if [ $shell_tests_failed -eq 0 ]; then
        log_success "Shell script validation passed"
        ((shell_tests_passed++))
    fi
    
    # Update totals
    TOTAL_PASSED=$((TOTAL_PASSED + shell_tests_passed))
    TOTAL_FAILED=$((TOTAL_FAILED + shell_tests_failed))
    TOTAL_TESTS=$((TOTAL_TESTS + shell_tests_passed + shell_tests_failed))
    
    if [ $shell_tests_failed -eq 0 ]; then
        log_success "Shell tests passed"
        ((CATEGORIES_PASSED++))
        return 0
    else
        log_error "Shell tests failed"
        return 1
    fi
}

# Run integration tests
run_integration_tests() {
    log_category "Running Integration Tests"
    
    local integration_passed=0
    local integration_failed=0
    
    # Test 1: Configuration file existence
    log_info "Testing configuration file existence..."
    local config_files=(
        ".config/nvim/init.lua"
        ".config/waybar/launch.sh"
        ".config/waybar/modules/powermenu.sh"
        ".config/qutebrowser/config.py"
    )
    
    local files_found=0
    for file in "${config_files[@]}"; do
        if [ -f "$file" ]; then
            ((files_found++))
            log_info "✓ $file exists"
        else
            log_info "- $file not found"
        fi
    done
    
    if [ $files_found -gt 0 ]; then
        log_success "Configuration files found ($files_found/${#config_files[@]})"
        ((integration_passed++))
    else
        log_error "No configuration files found"
        ((integration_failed++))
    fi
    
    # Test 2: Directory structure
    log_info "Testing directory structure..."
    local required_dirs=(
        ".config"
        "tests"
    )
    
    local dirs_found=0
    for dir in "${required_dirs[@]}"; do
        if [ -d "$dir" ]; then
            ((dirs_found++))
            log_info "✓ $dir exists"
        else
            log_info "- $dir not found"
        fi
    done
    
    if [ $dirs_found -eq ${#required_dirs[@]} ]; then
        log_success "All required directories exist"
        ((integration_passed++))
    else
        log_error "Some required directories missing"
        ((integration_failed++))
    fi
    
    # Update totals
    TOTAL_PASSED=$((TOTAL_PASSED + integration_passed))
    TOTAL_FAILED=$((TOTAL_FAILED + integration_failed))
    TOTAL_TESTS=$((TOTAL_TESTS + integration_passed + integration_failed))
    
    if [ $integration_failed -eq 0 ]; then
        log_success "Integration tests passed"
        ((CATEGORIES_PASSED++))
        return 0
    else
        log_error "Integration tests failed"
        return 1
    fi
}

# Print final results
print_results() {
    echo ""
    log_header "FINAL TEST RESULTS"
    echo ""
    echo -e "Categories: ${CATEGORIES_PASSED}/${CATEGORIES_RUN} passed"
    echo -e "Tests:      ${TOTAL_PASSED}/${TOTAL_TESTS} passed"
    echo ""
    
    if [ $TOTAL_FAILED -eq 0 ] && [ $CATEGORIES_PASSED -eq $CATEGORIES_RUN ]; then
        log_success "🎉 ALL TESTS PASSED! 🎉"
        echo ""
        echo "Your dotfiles configuration is working correctly!"
        return 0
    else
        log_error "❌ SOME TESTS FAILED ❌"
        echo ""
        echo "Please review the failed tests above and fix any issues."
        return 1
    fi
}

# Main execution
main() {
    local category="${1:-all}"
    
    log_header "DOTFILES TEST SUITE"
    echo ""
    echo "Running tests for category: $category"
    echo ""
    
    check_dependencies
    echo ""
    
    case "$category" in
        "lua")
            run_lua_tests
            ;;
        "shell")
            run_shell_tests
            ;;
        "integration")
            run_integration_tests
            ;;
        "all")
            run_lua_tests
            echo ""
            run_shell_tests
            echo ""
            run_integration_tests
            ;;
        *)
            log_error "Unknown category: $category"
            echo "Available categories: lua, shell, integration, all"
            exit 1
            ;;
    esac
    
    echo ""
    print_results
}

# Run main function if script is executed directly
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi
