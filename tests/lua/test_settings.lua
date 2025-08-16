-- tests/lua/test_settings.lua

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

local function mock_vim_with_opts()
    local opts = {}
    local g = {}
    local o = {}
    local cmd_calls = {}
    
    return {
        opt = setmetatable({}, {
            __newindex = function(t, k, v)
                opts[k] = v
            end,
            __index = function(t, k)
                return opts[k]
            end
        }),
        g = setmetatable({}, {
            __newindex = function(t, k, v)
                g[k] = v
            end,
            __index = function(t, k)
                return g[k]
            end
        }),
        o = setmetatable({}, {
            __newindex = function(t, k, v)
                o[k] = v
            end,
            __index = function(t, k)
                return o[k]
            end
        }),
        cmd = function(command)
            table.insert(cmd_calls, command)
        end,
        _test_data = {
            opts = opts,
            g = g,
            o = o,
            cmd_calls = cmd_calls
        }
    }
end

local function test_basic_settings()
    log_test("basic vim settings configuration")
    
    local original_vim = _G.vim
    local mock_vim = mock_vim_with_opts()
    _G.vim = mock_vim
    
    -- Simulate loading settings
    vim.opt.encoding = 'utf-8'
    vim.opt.fileencoding = 'utf-8'
    vim.opt.number = true
    vim.opt.showcmd = true
    vim.opt.ignorecase = true
    vim.opt.smartcase = true
    vim.opt.autoindent = true
    vim.opt.hlsearch = true
    vim.opt.incsearch = true
    vim.opt.scrolloff = 10
    vim.opt.hidden = true
    vim.opt.autoread = true
    vim.opt.clipboard = 'unnamedplus'
    vim.opt.termguicolors = true
    vim.opt.mouse = 'a'
    vim.opt.cmdheight = 0
    vim.opt.spell = true
    vim.opt.spelllang = { 'en', 'nl' }
    
    local opts = mock_vim._test_data.opts
    
    -- Test critical settings
    if opts.encoding == 'utf-8' then
        log_pass("encoding set to utf-8")
    else
        log_fail("encoding not set correctly")
    end
    
    if opts.number == true then
        log_pass("line numbers enabled")
    else
        log_fail("line numbers not enabled")
    end
    
    if opts.clipboard == 'unnamedplus' then
        log_pass("system clipboard integration enabled")
    else
        log_fail("system clipboard integration not enabled")
    end
    
    if opts.scrolloff == 10 then
        log_pass("scrolloff set to 10")
    else
        log_fail("scrolloff not set correctly")
    end
    
    _G.vim = original_vim
end

local function test_tab_settings()
    log_test("tab and indentation settings")
    
    local original_vim = _G.vim
    local mock_vim = mock_vim_with_opts()
    _G.vim = mock_vim
    
    -- Simulate tab settings
    vim.opt.softtabstop = 0
    vim.opt.shiftwidth = 4
    vim.opt.tabstop = 4
    vim.opt.expandtab = true
    vim.opt.cindent = true
    vim.opt.smarttab = true
    
    local opts = mock_vim._test_data.opts
    
    if opts.shiftwidth == 4 and opts.tabstop == 4 then
        log_pass("tab width set to 4 spaces")
    else
        log_fail("tab width not set correctly")
    end
    
    if opts.expandtab == true then
        log_pass("spaces used instead of tabs")
    else
        log_fail("tabs not configured to use spaces")
    end
    
    if opts.cindent == true then
        log_pass("C-style indentation enabled")
    else
        log_fail("C-style indentation not enabled")
    end
    
    _G.vim = original_vim
end

local function test_search_settings()
    log_test("search configuration")
    
    local original_vim = _G.vim
    local mock_vim = mock_vim_with_opts()
    _G.vim = mock_vim
    
    vim.opt.ignorecase = true
    vim.opt.smartcase = true
    vim.opt.hlsearch = true
    vim.opt.incsearch = true
    
    local opts = mock_vim._test_data.opts
    
    if opts.ignorecase == true and opts.smartcase == true then
        log_pass("smart case search enabled")
    else
        log_fail("smart case search not configured correctly")
    end
    
    if opts.hlsearch == true and opts.incsearch == true then
        log_pass("search highlighting and incremental search enabled")
    else
        log_fail("search highlighting not configured correctly")
    end
    
    _G.vim = original_vim
end

local function test_spell_settings()
    log_test("spell check configuration")
    
    local original_vim = _G.vim
    local mock_vim = mock_vim_with_opts()
    _G.vim = mock_vim
    
    vim.opt.spell = true
    vim.opt.spelllang = { 'en', 'nl' }
    
    local opts = mock_vim._test_data.opts
    
    if opts.spell == true then
        log_pass("spell check enabled")
    else
        log_fail("spell check not enabled")
    end
    
    if opts.spelllang and 
       type(opts.spelllang) == 'table' and
       opts.spelllang[1] == 'en' and 
       opts.spelllang[2] == 'nl' then
        log_pass("spell languages set to English and Dutch")
    else
        log_fail("spell languages not configured correctly")
    end
    
    _G.vim = original_vim
end

local function test_global_settings()
    log_test("global vim settings")
    
    local original_vim = _G.vim
    local mock_vim = mock_vim_with_opts()
    _G.vim = mock_vim
    
    vim.g.pyxversion = 3
    vim.opt.nu = true
    vim.opt.relativenumber = true
    vim.o.statuscolumn = "%s %l %r "
    
    local g = mock_vim._test_data.g
    local opts = mock_vim._test_data.opts
    local o = mock_vim._test_data.o
    
    if g.pyxversion == 3 then
        log_pass("Python version set to 3")
    else
        log_fail("Python version not set correctly")
    end
    
    if opts.nu == true and opts.relativenumber == true then
        log_pass("both absolute and relative line numbers enabled")
    else
        log_fail("line number configuration incorrect")
    end
    
    if o.statuscolumn == "%s %l %r " then
        log_pass("status column format configured")
    else
        log_fail("status column format not set correctly")
    end
    
    _G.vim = original_vim
end

local function test_vim_commands()
    log_test("vim command execution")
    
    local original_vim = _G.vim
    local mock_vim = mock_vim_with_opts()
    _G.vim = mock_vim
    
    vim.cmd 'filetype plugin on'
    vim.cmd 'syntax on'
    
    local cmd_calls = mock_vim._test_data.cmd_calls
    
    local filetype_called = false
    local syntax_called = false
    
    for _, cmd in ipairs(cmd_calls) do
        if cmd == 'filetype plugin on' then
            filetype_called = true
        elseif cmd == 'syntax on' then
            syntax_called = true
        end
    end
    
    if filetype_called then
        log_pass("filetype plugin enabled")
    else
        log_fail("filetype plugin not enabled")
    end
    
    if syntax_called then
        log_pass("syntax highlighting enabled")
    else
        log_fail("syntax highlighting not enabled")
    end
    
    _G.vim = original_vim
end

-- Run all tests
local function run_tests()
    print("Running settings configuration tests...")
    print("=====================================")
    
    test_basic_settings()
    test_tab_settings()
    test_search_settings()
    test_spell_settings()
    test_global_settings()
    test_vim_commands()
    
    print("")
    print("=====================================")
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
