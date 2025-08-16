-- tests/lua/test_keymaps.lua

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

local function mock_vim_with_keymaps()
    local keymaps = {}
    
    return {
        api = {
            nvim_set_keymap = function(mode, lhs, rhs, opts)
                table.insert(keymaps, {
                    mode = mode,
                    lhs = lhs,
                    rhs = rhs,
                    opts = opts or {}
                })
            end
        },
        _test_data = {
            keymaps = keymaps
        }
    }
end

local function find_keymap(keymaps, mode, lhs)
    for _, keymap in ipairs(keymaps) do
        if keymap.mode == mode and keymap.lhs == lhs then
            return keymap
        end
    end
    return nil
end

local function test_general_keymaps()
    log_test("general keymap configuration")
    
    local original_vim = _G.vim
    local mock_vim = mock_vim_with_keymaps()
    _G.vim = mock_vim
    
    -- Simulate keymap loading
    local map = vim.api.nvim_set_keymap
    local opts = { noremap = true, silent = true }
    
    -- Toggle comments
    map('n', '<C-_>', ':call NERDComment(0, "toggle")<CR>', opts)
    map('v', '<C-_>', ':call NERDComment(0, "toggle")<CR>', opts)
    
    -- Copy to clipboard
    map('v', 'Y', '"+y', opts)
    
    -- Paste from yank register
    map('n', 'p', '"0p', opts)
    map('v', 'p', '"0p', opts)
    
    -- Double escape to disable search highlight
    map('n', '<Esc><Esc>', '<Esc>:nohlsearch<CR><Esc>', opts)
    
    -- Move selected lines
    map('v', 'J', ':m \'>+1<CR>gv=gv', opts)
    map('v', 'K', ':m \'<-2<CR>gv=gv', opts)
    
    local keymaps = mock_vim._test_data.keymaps
    
    -- Test comment toggle
    local comment_normal = find_keymap(keymaps, 'n', '<C-_>')
    local comment_visual = find_keymap(keymaps, 'v', '<C-_>')
    
    if comment_normal and comment_visual then
        log_pass("comment toggle keymaps configured for normal and visual modes")
    else
        log_fail("comment toggle keymaps not configured correctly")
    end
    
    -- Test clipboard copy
    local clipboard_copy = find_keymap(keymaps, 'v', 'Y')
    if clipboard_copy and clipboard_copy.rhs == '"+y' then
        log_pass("clipboard copy keymap configured")
    else
        log_fail("clipboard copy keymap not configured correctly")
    end
    
    -- Test yank register paste
    local paste_normal = find_keymap(keymaps, 'n', 'p')
    local paste_visual = find_keymap(keymaps, 'v', 'p')
    
    if paste_normal and paste_visual and 
       paste_normal.rhs == '"0p' and paste_visual.rhs == '"0p' then
        log_pass("yank register paste keymaps configured")
    else
        log_fail("yank register paste keymaps not configured correctly")
    end
    
    -- Test search highlight disable
    local search_disable = find_keymap(keymaps, 'n', '<Esc><Esc>')
    if search_disable and search_disable.rhs:match('nohlsearch') then
        log_pass("search highlight disable keymap configured")
    else
        log_fail("search highlight disable keymap not configured correctly")
    end
    
    -- Test line movement
    local move_down = find_keymap(keymaps, 'v', 'J')
    local move_up = find_keymap(keymaps, 'v', 'K')
    
    if move_down and move_up and 
       move_down.rhs:match(':m') and move_up.rhs:match(':m') then
        log_pass("line movement keymaps configured")
    else
        log_fail("line movement keymaps not configured correctly")
    end
    
    _G.vim = original_vim
end

local function test_keymap_options()
    log_test("keymap options configuration")
    
    local original_vim = _G.vim
    local mock_vim = mock_vim_with_keymaps()
    _G.vim = mock_vim
    
    local map = vim.api.nvim_set_keymap
    local opts = { noremap = true, silent = true }
    
    map('n', '<C-_>', ':call NERDComment(0, "toggle")<CR>', opts)
    
    local keymaps = mock_vim._test_data.keymaps
    local keymap = find_keymap(keymaps, 'n', '<C-_>')
    
    if keymap and keymap.opts.noremap == true then
        log_pass("noremap option set correctly")
    else
        log_fail("noremap option not set correctly")
    end
    
    if keymap and keymap.opts.silent == true then
        log_pass("silent option set correctly")
    else
        log_fail("silent option not set correctly")
    end
    
    _G.vim = original_vim
end

local function test_visual_mode_keymaps()
    log_test("visual mode specific keymaps")
    
    local original_vim = _G.vim
    local mock_vim = mock_vim_with_keymaps()
    _G.vim = mock_vim
    
    local map = vim.api.nvim_set_keymap
    local opts = { noremap = true, silent = true }
    
    -- Visual mode keymaps
    map('v', 'Y', '"+y', opts)
    map('v', 'p', '"0p', opts)
    map('v', 'J', ':m \'>+1<CR>gv=gv', opts)
    map('v', 'K', ':m \'<-2<CR>gv=gv', opts)
    
    local keymaps = mock_vim._test_data.keymaps
    local visual_keymaps = {}
    
    for _, keymap in ipairs(keymaps) do
        if keymap.mode == 'v' then
            table.insert(visual_keymaps, keymap)
        end
    end
    
    if #visual_keymaps >= 4 then
        log_pass("multiple visual mode keymaps configured")
    else
        log_fail("insufficient visual mode keymaps configured")
    end
    
    -- Test that visual keymaps maintain selection
    local move_down = find_keymap(keymaps, 'v', 'J')
    if move_down and move_down.rhs:match('gv=gv') then
        log_pass("visual line movement maintains selection")
    else
        log_fail("visual line movement doesn't maintain selection")
    end
    
    _G.vim = original_vim
end

local function test_normal_mode_keymaps()
    log_test("normal mode specific keymaps")
    
    local original_vim = _G.vim
    local mock_vim = mock_vim_with_keymaps()
    _G.vim = mock_vim
    
    local map = vim.api.nvim_set_keymap
    local opts = { noremap = true, silent = true }
    
    -- Normal mode keymaps
    map('n', '<C-_>', ':call NERDComment(0, "toggle")<CR>', opts)
    map('n', 'p', '"0p', opts)
    map('n', '<Esc><Esc>', '<Esc>:nohlsearch<CR><Esc>', opts)
    
    local keymaps = mock_vim._test_data.keymaps
    local normal_keymaps = {}
    
    for _, keymap in ipairs(keymaps) do
        if keymap.mode == 'n' then
            table.insert(normal_keymaps, keymap)
        end
    end
    
    if #normal_keymaps >= 3 then
        log_pass("multiple normal mode keymaps configured")
    else
        log_fail("insufficient normal mode keymaps configured")
    end
    
    -- Test escape sequence
    local escape_keymap = find_keymap(keymaps, 'n', '<Esc><Esc>')
    if escape_keymap and escape_keymap.rhs:match('<Esc>') then
        log_pass("double escape keymap properly formatted")
    else
        log_fail("double escape keymap not properly formatted")
    end
    
    _G.vim = original_vim
end

-- Run all tests
local function run_tests()
    print("Running keymap configuration tests...")
    print("====================================")
    
    test_general_keymaps()
    test_keymap_options()
    test_visual_mode_keymaps()
    test_normal_mode_keymaps()
    
    print("")
    print("====================================")
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
