# nvf Quick Start Guide

## 🚀 Get Started in 3 Steps

### Step 1: Add nvf to your flake

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nvf.url = "github:notashelf/nvf";
  };
}
```

### Step 2: Import the module

**NixOS:**
```nix
nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
  modules = [
    nvf.nixosModules.default
    ./nvf-config.nix
  ];
};
```

**Home-Manager:**
```nix
homeConfigurations."user@host" = home-manager.lib.homeManagerConfiguration {
  modules = [
    nvf.homeManagerModules.default
    ./nvf-config.nix
  ];
};
```

### Step 3: Build and enjoy!

```bash
# NixOS
sudo nixos-rebuild switch --flake .

# Home-Manager
home-manager switch --flake .

# Standalone
nix build
```

## 📋 What's Included

- ✅ Tokyo Night theme
- ✅ LSP for Python, Nix, Rust, Go, TypeScript, Bash
- ✅ Treesitter syntax highlighting (20+ languages)
- ✅ Telescope fuzzy finder
- ✅ Git integration (gitsigns)
- ✅ Autocomplete (nvim-cmp)
- ✅ Statusline (lualine)
- ✅ Buffer management (nvim-bufferline)
- ✅ AI assistant (codecompanion)
- ✅ Utilities: undotree, diffview, color highlighting

## ⌨️ Essential Keymaps

| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Find buffers |
| `<leader>u` | Toggle undotree |
| `K` | Hover documentation |
| `gd` | Go to definition |
| `<leader>ca` | Code actions |

## 🔧 First Build Fix

You'll see hash errors on first build. This is normal!

```
error: hash mismatch
  got: sha256-abc123...
```

Copy the hash and update `nvf-config.nix`:
```nix
sha256 = "sha256-abc123...";  # Replace lib.fakeSha256
```

## 📚 Documentation

- **Full Guide**: `NVF_README.md`
- **Migration Details**: `NVF_MIGRATION.md`
- **Summary**: `NVF_SUMMARY.md`
- **nvf Docs**: https://nvf.notashelf.dev/

## 🎯 Next Steps

1. Build the configuration
2. Update plugin hashes
3. Add your custom keymaps
4. Customize to your preferences
5. Remove old `.config/nvim` when satisfied

## 💡 Pro Tips

- Use `:checkhealth` to diagnose issues
- Run `:LspInfo` to see active LSP servers
- Check `:Telescope` for all available pickers
- Use `:Lazy` to manage plugins (if lazy loading enabled)

## 🆘 Need Help?

1. Check the documentation files in this directory
2. Visit https://nvf.notashelf.dev/
3. Open an issue: https://github.com/NotAShelf/nvf/issues

---

**Ready to go!** Your Neovim configuration is now declarative, reproducible, and ready for NixOS 25.11. 🎉
