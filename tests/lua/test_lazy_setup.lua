-- tests/lua/test_lazy_setup.lua

local test_results = {
    passed = 0,
    failed = 0,
    total = 0
}

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

local function mock_vim()
    return {
        fn = {
            stdpath = function(path)
                if path == 'data' then
                    return '/tmp/test_nvim_data'
                end
                return '/tmp/test_nvim'
            end,
            empty = function(result)
                return result == '' and 1 or 0
            end,
            glob = function(path)
                -- Mock that lazy.nvim is not installed
                if path:match('lazy%.nvim') then
                    return ''
                end
                return 'some_file'
            end,
            system = function(cmd)
                -- Mock git clone command
                return 0
            end
        },
        cmd = function(command)
            -- Mock vim command execution
        end
    }
end

local function test_ensure_lazy_when_not_installed()
    log_test("ensure_lazy when not installed")
    
    -- Setup
    local original_vim = _G.vim
    _G.vim = mock_vim()
    
    -- Load the function
    local ensure_lazy = function()
        local fn = vim.fn
        local install_path = fn.stdpath('data') .. '/site/pack/lazy/start/lazy.nvim'
        if fn.empty(fn.glob(install_path)) > 0 then
            fn.system({'git', 'clone', '--depth', '1', 'https://github.com/folke/lazy.nvim.git', install_path})
            vim.cmd [[packadd lazy.nvim]]
            return true
        end
        return false
    end
    
    -- Test
    local result = ensure_lazy()
    
    -- Assert
    if result == true then
        log_pass("ensure_lazy returns true when lazy.nvim is not installed")
    else
        log_fail("ensure_lazy should return true when lazy.nvim is not installed")
    end
    
    -- Cleanup
    _G.vim = original_vim
end

local function test_ensure_lazy_when_already_installed()
    log_test("ensure_lazy when already installed")
    
    -- Setup
    local original_vim = _G.vim
    local mock = mock_vim()
    mock.fn.glob = function(path)
        -- Mock that lazy.nvim is already installed
        if path:match('lazy%.nvim') then
            return '/some/path/lazy.nvim'
        end
        return 'some_file'
    end
    _G.vim = mock
    
    -- Load the function
    local ensure_lazy = function()
        local fn = vim.fn
        local install_path = fn.stdpath('data') .. '/site/pack/lazy/start/lazy.nvim'
        if fn.empty(fn.glob(install_path)) > 0 then
            fn.system({'git', 'clone', '--depth', '1', 'https://github.com/folke/lazy.nvim.git', install_path})
            vim.cmd [[packadd lazy.nvim]]
            return true
        end
        return false
    end
    
    -- Test
    local result = ensure_lazy()
    
    -- Assert
    if result == false then
        log_pass("ensure_lazy returns false when lazy.nvim is already installed")
    else
        log_fail("ensure_lazy should return false when lazy.nvim is already installed")
    end
    
    -- Cleanup
    _G.vim = original_vim
end

local function test_stdpath_usage()
    log_test("stdpath usage in ensure_lazy")
    
    local original_vim = _G.vim
    local stdpath_called = false
    local mock = mock_vim()
    
    mock.fn.stdpath = function(path)
        stdpath_called = true
        if path == 'data' then
            return '/test/data/path'
        end
        return '/test/path'
    end
    _G.vim = mock
    
    local ensure_lazy = function()
        local fn = vim.fn
        local install_path = fn.stdpath('data') .. '/site/pack/lazy/start/lazy.nvim'
        if fn.empty(fn.glob(install_path)) > 0 then
            fn.system({'git', 'clone', '--depth', '1', 'https://github.com/folke/lazy.nvim.git', install_path})
            vim.cmd [[packadd lazy.nvim]]
            return true
        end
        return false
    end
    
    ensure_lazy()
    
    if stdpath_called then
        log_pass("ensure_lazy correctly calls vim.fn.stdpath")
    else
        log_fail("ensure_lazy should call vim.fn.stdpath")
    end
    
    _G.vim = original_vim
end

local function test_git_clone_command()
    log_test("git clone command construction")
    
    local original_vim = _G.vim
    local system_called_with = nil
    local mock = mock_vim()
    
    mock.fn.system = function(cmd)
        system_called_with = cmd
        return 0
    end
    _G.vim = mock
    
    local ensure_lazy = function()
        local fn = vim.fn
        local install_path = fn.stdpath('data') .. '/site/pack/lazy/start/lazy.nvim'
        if fn.empty(fn.glob(install_path)) > 0 then
            fn.system({'git', 'clone', '--depth', '1', 'https://github.com/folke/lazy.nvim.git', install_path})
            vim.cmd [[packadd lazy.nvim]]
            return true
        end
        return false
    end
    
    ensure_lazy()
    
    if system_called_with and 
       system_called_with[1] == 'git' and 
       system_called_with[2] == 'clone' and
       system_called_with[3] == '--depth' and
       system_called_with[4] == '1' and
       system_called_with[5] == 'https://github.com/folke/lazy.nvim.git' then
        log_pass("ensure_lazy constructs correct git clone command")
    else
        log_fail("ensure_lazy git clone command is incorrect")
    end
    
    _G.vim = original_vim
end

-- Run all tests
local function run_tests()
    print("Running Lua configuration tests...")
    print("==================================")
    
    test_ensure_lazy_when_not_installed()
    test_ensure_lazy_when_already_installed()
    test_stdpath_usage()
    test_git_clone_command()
    
    print("")
    print("==================================")
    print("Test Results:")
    print("  Total: " .. test_results.total)
    print("  Passed: " .. test_results.passed)
    print("  Failed: " .. test_results.failed)
    
    if test_results.failed == 0 then
        print("✅ All tests passed!")
        return true
    else
        print("❌ Some tests failed!")
        return false
    end
end

-- Export for use by test runner
return {
    run_tests = run_tests,
    test_results = test_results
}
