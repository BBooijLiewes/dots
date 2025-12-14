# nvf Neovim Configuration

This directory contains a complete nvf-based Neovim configuration, migrated from the original Lua-based setup.

## Files

- **`nvf-config.nix`** - Main nvf configuration file
- **`NVF_MIGRATION.md`** - Detailed migration guide and plugin mapping
- **`NVF_README.md`** - This file

## Quick Start

### Option 1: NixOS Module

1. Add nvf to your `flake.nix`:

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
        ./nvf-config.nix
      ];
    };
  };
}
```

2. Rebuild your system:

```bash
sudo nixos-rebuild switch --flake .#your-hostname
```

### Option 2: Home-Manager Module

1. Add nvf to your `flake.nix`:

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
        ./nvf-config.nix
      ];
    };
  };
}
```

2. Rebuild your home configuration:

```bash
home-manager switch --flake .#user@hostname
```

### Option 3: Standalone Package

1. Create a `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nvf.url = "github:notashelf/nvf";
  };

  outputs = { nixpkgs, nvf, ... }: {
    packages.x86_64-linux.default = (nvf.lib.neovimConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [ ./nvf-config.nix ];
    }).neovim;
  };
}
```

2. Build and run:

```bash
nix build
./result/bin/nvim
```

Or run directly:

```bash
nix run
```

## Configuration Overview

### Core Features

- **Theme**: Tokyo Night (night variant)
- **LSP**: Full language server support for Python, Nix, Rust, Go, TypeScript, Bash, and more
- **Treesitter**: Syntax highlighting for 20+ languages
- **Autocomplete**: nvim-cmp with LSP, buffer, and path sources
- **Fuzzy Finding**: Telescope with file browser and fzf integration
- **Git Integration**: Gitsigns with code actions
- **Statusline**: Lualine with Tokyo Night theme
- **Tabline**: nvim-bufferline for buffer management
- **Utilities**: Undotree, Diffview, color highlighting

### Language Support

| Language | LSP | Formatter | Treesitter |
|----------|-----|-----------|------------|
| Python | basedpyright | ruff | ✅ |
| Nix | nil | alejandra | ✅ |
| Rust | rust-analyzer | - | ✅ |
| Go | gopls | - | ✅ |
| TypeScript/JavaScript | tsserver | - | ✅ |
| Bash | bash-ls | - | ✅ |
| HTML/CSS | - | - | ✅ |
| Markdown | - | - | ✅ |
| JSON/YAML/TOML | - | - | ✅ |

### Extra Plugins

The following plugins are added via `extraPlugins` as they don't have native nvf modules:

- **vim-smoothie**: Smooth scrolling
- **nvim-navic**: Breadcrumbs/context in statusline
- **nvim-lightbulb**: Code action indicator
- **hardtime.nvim**: Habit building (discourages bad vim habits)
- **precognition.nvim**: Motion hints (disabled by default)
- **qalc.nvim**: Calculator integration

### AI Assistant

CodeCompanion.nvim is configured for AI-powered coding assistance. The configuration includes:

- Ollama adapter support
- Custom model configuration (GPT-OSS 20B)
- Chat and inline modes
- Custom keymaps for accepting/rejecting changes

**Note**: You'll need to configure the AI_URL environment variable to point to your Ollama instance.

## Customization

### Adding Keymaps

Add keymaps to the `vim.keymaps` list in `nvf-config.nix`:

```nix
vim.keymaps = [
  {
    key = "<leader>w";
    mode = "n";
    action = "<cmd>write<CR>";
    options.desc = "Save file";
  }
  # ... more keymaps
];
```

### Adding Custom Lua Code

Use `vim.luaConfigRC` for custom Lua configuration:

```nix
vim.luaConfigRC = {
  my_custom_config = ''
    -- Your Lua code here
    vim.g.my_variable = "value"
  '';
};
```

### Adding Extra Plugins

Add plugins via `vim.extraPlugins`:

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

### Enabling/Disabling Languages

Enable or disable language support in the `vim.languages` section:

```nix
vim.languages = {
  python.enable = true;  # Enable Python support
  rust.enable = false;   # Disable Rust support
};
```

## Keymaps Reference

### Telescope

- `<leader>ff` - Find files
- `<leader>fg` - Live grep
- `<leader>fb` - Find buffers
- `<leader>fh` - Help tags

### Utilities

- `<leader>u` - Toggle undotree
- `<leader>dv` - Open diffview
- `<leader>dc` - Close diffview

### LSP (Default nvf keymaps)

- `K` - Hover documentation
- `gd` - Go to definition
- `gD` - Go to declaration
- `gi` - Go to implementation
- `gr` - Go to references
- `<leader>ca` - Code actions
- `<leader>rn` - Rename symbol

**Note**: Review your original `keymaps/*.lua` files and add any custom keymaps you need.

## Troubleshooting

### First Build Issues

On first build, you may encounter hash mismatches for plugins fetched from GitHub. This is expected. The error message will show the correct hash - copy it and replace `lib.fakeSha256` in the configuration.

Example error:
```
error: hash mismatch in fixed-output derivation
  specified: sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
  got:       sha256-abc123def456...
```

Replace in `nvf-config.nix`:
```nix
sha256 = "sha256-abc123def456...";  # Use the hash from error message
```

### LSP Not Working

1. Check that the language is enabled in `vim.languages`
2. Verify the LSP server is specified correctly
3. Run `:checkhealth` in Neovim to diagnose issues
4. Check `:LspInfo` to see active LSP clients

### Plugin Not Loading

1. Verify the plugin is in `extraPlugins` or has a native nvf module
2. Check the `setup` code for syntax errors
3. Look for errors with `:messages` in Neovim
4. Ensure dependencies are included

### Performance Issues

1. Disable unused language servers
2. Reduce Treesitter grammars to only needed languages
3. Consider enabling lazy loading (check nvf docs for `vim.lazy`)
4. Profile with `:Lazy profile` if using lazy loading

## Migration Notes

### Removed Plugins

The following plugins from the original configuration were removed:

- **vim-polyglot**: Replaced by Treesitter
- **vim-snippets**: Replaced by LuaSnip
- **lsp-zero.nvim**: nvf manages LSP directly
- **FixCursorHold.nvim**: Fixed in modern Neovim
- **nvim-code-action-menu**: Use native LSP code actions
- **kommentary**: Replaced by comment.nvim (native nvf support)
- **barbar.nvim**: Replaced by nvim-bufferline (native nvf support)
- **nvim-highlight-colors**: Replaced by ccc.nvim (better alternative)

### Changed Plugins

- **barbar.nvim** → **nvim-bufferline**: Similar functionality, native nvf support
- **kommentary** → **comment.nvim**: More actively maintained
- **nvim-highlight-colors** → **ccc.nvim**: More features, better performance

## Next Steps

1. **Review Keymaps**: Check your original `keymaps/*.lua` files and add any missing keymaps
2. **Test Configuration**: Build and test the configuration thoroughly
3. **Update Hashes**: Replace `lib.fakeSha256` with actual hashes after first build
4. **Customize**: Adjust settings, colors, and plugins to your preferences
5. **Remove Old Config**: Once satisfied, you can remove the old `.config/nvim` directory

## Resources

- [nvf Documentation](https://nvf.notashelf.dev/)
- [nvf GitHub Repository](https://github.com/NotAShelf/nvf)
- [nvf Options Reference](https://nvf.notashelf.dev/options.html)
- [NVF_MIGRATION.md](./NVF_MIGRATION.md) - Detailed migration guide

## Support

If you encounter issues:

1. Check the [nvf documentation](https://nvf.notashelf.dev/)
2. Review [nvf GitHub issues](https://github.com/NotAShelf/nvf/issues)
3. Check [nvf discussions](https://github.com/NotAShelf/nvf/discussions)
4. Consult the [NVF_MIGRATION.md](./NVF_MIGRATION.md) guide

## License

This configuration is based on your original Neovim setup and uses nvf, which is licensed under MIT.
