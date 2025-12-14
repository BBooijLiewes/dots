# Neovim Configuration Migration to nvf

This document describes the migration from the Lua-based Neovim configuration to nvf (Nix-based Neovim Framework) for NixOS 25.11.

## Overview

nvf is a highly modular, configurable Neovim configuration framework built for Nix/NixOS. This migration translates your existing Lua configuration into a declarative Nix configuration.

## Installation Methods

### 1. NixOS Module (Recommended)

Add to your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nvf.url = "github:notashelf/nvf";
  };

  outputs = { nixpkgs, nvf, ... }: {
    nixosConfigurations.your-hostname = nixpkgs.lib.nixosSystem {
      modules = [
        nvf.nixosModules.default
        ./nvf-config.nix  # Your nvf configuration
        # ... other modules
      ];
    };
  };
}
```

### 2. Home-Manager Module

Add to your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    nvf.url = "github:notashelf/nvf";
  };

  outputs = { nixpkgs, home-manager, nvf, ... }: {
    homeConfigurations."user@hostname" = home-manager.lib.homeManagerConfiguration {
      modules = [
        nvf.homeManagerModules.default
        ./nvf-config.nix  # Your nvf configuration
        # ... other modules
      ];
    };
  };
}
```

### 3. Standalone Package

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nvf.url = "github:notashelf/nvf";
  };

  outputs = { nixpkgs, nvf, ... }: {
    packages.x86_64-linux.neovim = (nvf.lib.neovimConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [ ./nvf-config.nix ];
    }).neovim;
  };
}
```

## Plugin Migration Status

### ✅ Fully Supported (Native nvf Modules)

| Original Plugin | nvf Module | Status |
|----------------|------------|--------|
| nvim-treesitter | `vim.treesitter` | ✅ Fully supported |
| nvim-lspconfig | `vim.lsp` | ✅ Fully supported |
| mason.nvim | `vim.lsp` | ✅ Integrated (nvf manages LSPs directly) |
| mason-lspconfig.nvim | `vim.lsp` | ✅ Integrated |
| nvim-cmp | `vim.autocomplete` | ✅ Fully supported |
| cmp-nvim-lsp | `vim.autocomplete` | ✅ Integrated |
| cmp-buffer | `vim.autocomplete` | ✅ Integrated |
| cmp-path | `vim.autocomplete` | ✅ Integrated |
| telescope.nvim | `vim.telescope` | ✅ Fully supported |
| telescope-fzf-native.nvim | `vim.telescope` | ✅ Integrated |
| telescope-file-browser.nvim | `vim.telescope` | ✅ Integrated |
| gitsigns.nvim | `vim.git.gitsigns` | ✅ Fully supported |
| lualine.nvim | `vim.statusline.lualine` | ✅ Fully supported |
| tokyonight.nvim | `vim.theme` | ✅ Fully supported |
| nvim-web-devicons | `vim.ui.icons` | ✅ Integrated |
| diffview.nvim | `vim.utility.diffview-nvim` | ✅ Fully supported |
| undotree | `vim.utility.undotree` | ✅ Fully supported |

### ⚠️ Requires extraPlugins (Not Native)

| Original Plugin | Alternative/Status | Notes |
|----------------|-------------------|-------|
| barbar.nvim | Use `vim.tabline.nvimBufferline` | nvf uses nvim-bufferline instead |
| vim-smoothie | Add via `extraPlugins` | Smooth scrolling plugin |
| kommentary | Use `vim.comments.comment-nvim` | nvf uses comment.nvim instead |
| nvim-navic | Add via `extraPlugins` | Breadcrumbs/context |
| nvim-lightbulb | Add via `extraPlugins` | Code action indicator |
| hardtime.nvim | Add via `extraPlugins` | Habit building |
| precognition.nvim | Add via `extraPlugins` | Motion hints |
| codecompanion.nvim | Use `vim.assistant.codecompanion-nvim` | ✅ Native support available! |
| qalc.nvim | Add via `extraPlugins` | Calculator plugin |
| lush.nvim | Not needed | Theme dependency |
| vim-polyglot | Not needed | Treesitter handles syntax |
| vim-snippets | Not needed | LuaSnip handles snippets |
| lsp-zero.nvim | Not needed | nvf manages LSP directly |
| FixCursorHold.nvim | Not needed | Fixed in modern Neovim |
| nvim-code-action-menu | Not needed | Use native LSP code actions |
| plenary.nvim | Automatic | Dependency, auto-included |
| nui.nvim | Automatic | Dependency, auto-included |

### ❌ Removed/Deprecated

| Original Plugin | Reason |
|----------------|--------|
| nvim-highlight-colors | Use `vim.utility.ccc` (better alternative) |
| sheerun/vim-polyglot | Replaced by Treesitter |
| vim-snippets | Replaced by LuaSnip |
| lsp-zero.nvim | nvf has native LSP management |

## Configuration Mapping

### General Settings

| Lua Setting | nvf Option |
|------------|-----------|
| `vim.opt.number = true` | `vim.options.number = true` |
| `vim.opt.relativenumber = true` | `vim.options.relativenumber = true` |
| `vim.opt.clipboard = 'unnamedplus'` | `vim.clipboard.enable = true` |
| `vim.opt.spell = true` | `vim.spellcheck.enable = true` |
| `vim.opt.spelllang = {'en', 'nl'}` | `vim.spellcheck.languages = ["en" "nl"]` |

### LSP Configuration

**Original (Lua):**
```lua
require("mason-lspconfig").setup({
  ensure_installed = { "basedpyright", "ruff" },
})
```

**nvf (Nix):**
```nix
vim.languages.python = {
  enable = true;
  lsp = {
    enable = true;
    server = "basedpyright";
  };
  format = {
    enable = true;
    type = "ruff";
  };
};
```

### Theme Configuration

**Original (Lua):**
```lua
vim.cmd 'colorscheme tokyonight-night'
```

**nvf (Nix):**
```nix
vim.theme = {
  enable = true;
  name = "tokyonight";
  style = "night";
};
```

### Keymaps

**Original (Lua):**
```lua
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<CR>')
```

**nvf (Nix):**
```nix
vim.keymaps = [
  {
    key = "<leader>ff";
    mode = "n";
    action = "<cmd>Telescope find_files<CR>";
    options.desc = "Find files";
  }
];
```

## Language Support

nvf provides native support for many languages. Here's what's configured:

- **Python**: basedpyright LSP + ruff formatter
- **Nix**: nil LSP + alejandra formatter
- **Rust**: rust-analyzer LSP
- **Go**: gopls LSP
- **TypeScript/JavaScript**: tsserver LSP
- **HTML/CSS**: Native support
- **Markdown**: Native support
- **Bash**: bash-ls LSP

## Custom Lua Configuration

For custom Lua code that doesn't fit into nvf's declarative model, use `vim.luaConfigRC`:

```nix
vim.luaConfigRC = {
  custom_config = ''
    -- Your custom Lua code here
    vim.g.custom_variable = "value"
  '';
};
```

## Extra Plugins

For plugins not natively supported by nvf, use `vim.extraPlugins`:

```nix
vim.extraPlugins = {
  my-plugin = {
    package = pkgs.vimPlugins.my-plugin;
    setup = ''
      require("my-plugin").setup({
        -- configuration
      })
    '';
  };
};
```

## Migration Checklist

- [x] Core settings migrated
- [x] Theme configuration migrated
- [x] Treesitter configuration migrated
- [x] LSP configuration migrated
- [x] Autocomplete configuration migrated
- [x] Telescope configuration migrated
- [x] Git integration migrated
- [x] Statusline configuration migrated
- [ ] All keymaps migrated (review keymaps/*.lua files)
- [ ] Custom Lua configurations migrated
- [ ] Test all language servers
- [ ] Test all plugins
- [ ] Update plugin hashes in extraPlugins

## Next Steps

1. **Review Keymaps**: Check `keymaps/*.lua` files and add all keymaps to the nvf configuration
2. **Update Hashes**: Replace placeholder SHA256 hashes in `extraPlugins` with actual values
3. **Test Configuration**: Build and test the configuration
4. **Customize**: Adjust settings to your preferences
5. **Remove Old Config**: Once satisfied, remove the old `.config/nvim` directory

## Resources

- [nvf Documentation](https://nvf.notashelf.dev/)
- [nvf GitHub](https://github.com/NotAShelf/nvf)
- [nvf Options Reference](https://nvf.notashelf.dev/options.html)
- [nvf Examples](https://github.com/NotAShelf/nvf/tree/main/docs)

## Troubleshooting

### Build Errors

If you encounter build errors:

1. Check that all plugin hashes are correct
2. Verify NixOS/nixpkgs version compatibility
3. Review nvf documentation for breaking changes
4. Check nvf GitHub issues for similar problems

### Missing Features

If a feature from your old config is missing:

1. Check if nvf has a native module for it
2. Consider using `extraPlugins` for custom plugins
3. Use `luaConfigRC` for custom Lua code
4. Open an issue on nvf GitHub if it's a common use case

### Performance Issues

If Neovim feels slow:

1. Disable unused language servers
2. Reduce Treesitter grammars to only what you need
3. Check `lazy.enable` option for lazy loading
4. Profile with `:checkhealth` and `:Lazy profile`
