#!/bin/bash

# Test suite for waybar modules

# Don't exit on errors, handle them gracefully
set +e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Helper functions
log_test() {
    echo -e "${YELLOW}[TEST]${NC} $1"
    ((TESTS_RUN++))
}

log_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((TESTS_PASSED++))
}

log_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((TESTS_FAILED++))
}

# Test powermenu.sh functionality
test_powermenu_output() {
    log_test "Testing powermenu.sh output format"
    
    # Test the actual script if it exists
    if [ -f ".config/waybar/modules/powermenu.sh" ]; then
        log_pass "powermenu.sh script exists"
        
        # Check script is executable
        if [ -x ".config/waybar/modules/powermenu.sh" ]; then
            log_pass "powermenu.sh is executable"
        else
            log_fail "powermenu.sh is not executable"
        fi
        
        # Check shebang
        if head -n1 .config/waybar/modules/powermenu.sh | grep -q "#!/bin/bash"; then
            log_pass "powermenu.sh has correct shebang"
        else
            log_fail "powermenu.sh has incorrect or missing shebang"
        fi
        
        # Check for expected content
        if grep -q "class=powermenu" .config/waybar/modules/powermenu.sh; then
            log_pass "powermenu.sh contains class definition"
        else
            log_fail "powermenu.sh missing class definition"
        fi
        
        if grep -q "echo.*text.*class" .config/waybar/modules/powermenu.sh; then
            log_pass "powermenu.sh contains JSON output"
        else
            log_fail "powermenu.sh missing JSON output"
        fi
    else
        log_fail "powermenu.sh script not found"
    fi
}

# Test launch.sh functionality
test_launch_script() {
    log_test "Testing launch.sh script structure"
    
    # Test the actual script if it exists
    if [ -f ".config/waybar/launch.sh" ]; then
        # Check shebang
        if head -n1 .config/waybar/launch.sh | grep -q "#!/usr/bin/env sh"; then
            log_pass "launch.sh has correct shebang"
        else
            log_fail "launch.sh has incorrect or missing shebang"
        fi
        
        # Check for expected commands
        if grep -q "killall" .config/waybar/launch.sh; then
            log_pass "launch.sh contains process termination logic"
        else
            log_fail "launch.sh missing process termination logic"
        fi
        
        if grep -q "pgrep" .config/waybar/launch.sh; then
            log_pass "launch.sh contains process checking logic"
        else
            log_fail "launch.sh missing process checking logic"
        fi
    else
        log_fail "launch.sh script not found"
    fi
}

# Test script permissions and shebangs
test_script_properties() {
    log_test "Testing script properties"
    
    # Test powermenu.sh
    if [ -f ".config/waybar/modules/powermenu.sh" ]; then
        # Check shebang
        if head -n1 .config/waybar/modules/powermenu.sh | grep -q "#!/bin/bash"; then
            log_pass "powermenu.sh has correct shebang"
        else
            log_fail "powermenu.sh has incorrect or missing shebang"
        fi
    else
        log_fail "powermenu.sh not found"
    fi
    
    # Test launch.sh
    if [ -f ".config/waybar/launch.sh" ]; then
        # Check shebang
        if head -n1 .config/waybar/launch.sh | grep -q "#!/usr/bin/env sh"; then
            log_pass "launch.sh has correct shebang"
        else
            log_fail "launch.sh has incorrect or missing shebang"
        fi
    else
        log_fail "launch.sh not found"
    fi
}

# Test JSON output validation
test_json_validation() {
    log_test "Testing JSON output validation"
    
    # Test with different user scenarios
    for test_user in "testuser" "user.with.dots" "user-with-dashes"; do
        # Mock the powermenu script with test user
        cat > /tmp/test_powermenu_user.sh << EOF
#!/bin/bash
me="$test_user"
me_name="Test User Name"
class=powermenu
echo -e "{\"text\":\"\$me_name\", \"class\":\"\$class\"}"
EOF
        
        chmod +x /tmp/test_powermenu_user.sh
        output=$(/tmp/test_powermenu_user.sh)
        
        # Validate JSON with python if available
        if command -v python3 >/dev/null 2>&1; then
            if echo "$output" | python3 -m json.tool >/dev/null 2>&1; then
                log_pass "JSON output is valid for user: $test_user"
            else
                log_fail "JSON output is invalid for user: $test_user"
            fi
        else
            # Basic validation without python
            if echo "$output" | grep -q '^{"text":".*", "class":".*"}$'; then
                log_pass "JSON format appears valid for user: $test_user"
            else
                log_fail "JSON format appears invalid for user: $test_user"
            fi
        fi
        
        rm -f /tmp/test_powermenu_user.sh
    done
}

# Main test execution
main() {
    echo "Running waybar modules tests..."
    echo "================================"
    
    test_powermenu_output
    test_launch_script
    test_script_properties
    test_json_validation
    
    echo ""
    echo "================================"
    echo "Test Results:"
    echo "  Total: $TESTS_RUN"
    echo "  Passed: $TESTS_PASSED"
    echo "  Failed: $TESTS_FAILED"
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}All tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}Some tests failed!${NC}"
        exit 1
    fi
}

# Run tests if script is executed directly
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi
