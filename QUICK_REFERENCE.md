# Quick Reference Card

## 🚀 Integration (5 Steps)

```bash
# 1. Copy config
sudo cp nvf-config-improved.nix /etc/nixos/nvf-config.nix

# 2. Edit /etc/nixos/flake.nix - add:
#    nvf.url = "github:notashelf/nvf";

# 3. Edit /etc/nixos/home-bob.nix - add:
#    imports = [ inputs.nvf.homeManagerModules.default ./nvf-config.nix ];

# 4. Update and build
cd /etc/nixos && sudo nix flake update
sudo nixos-rebuild switch --flake .#hostname

# 5. Fix hash errors (copy from error messages)
```

## ⌨️ Essential Keymaps

### Navigation
- `<leader>ff` - Find files
- `<leader>fg` - Search in files
- `<leader>fb` - Find buffers
- `gd` - Go to definition
- `K` - Show documentation

### Git
- `<leader>gg` - Open Neogit
- `<leader>gc` - Git commit
- `<leader>dv` - View diff

### Django
- `<leader>dr` - Run server
- `<leader>dt` - Run tests
- `<leader>ds` - Django shell
- `<leader>dk` - Make migrations

### Docker
- `<leader>Du` - Compose up
- `<leader>Dd` - Compose down
- `<leader>Dl` - View logs

### Testing
- `<leader>tt` - Run test
- `<leader>tf` - Run file tests
- `<leader>ts` - Test summary

### Diagnostics
- `<leader>xx` - Toggle Trouble
- `]d` - Next diagnostic
- `[d` - Previous diagnostic

## 📊 Performance

| Metric | Improved Config |
|--------|----------------|
| Startup | 50-100ms |
| Memory | ~120MB |
| LSP | Instant |

## 🔧 Features

✅ Django templates
✅ React/TypeScript
✅ Docker Compose
✅ GitLab CI
✅ Testing (Neotest)
✅ Debugging (DAP)
✅ Git (Neogit)
✅ Fast search (fzf-lua)

## 📚 Documentation

- **Start**: `FINAL_GUIDE.md`
- **Integration**: `INTEGRATION_GUIDE.md`
- **Improvements**: `IMPROVEMENTS.md`
- **Quick Start**: `NVF_QUICKSTART.md`

## 🐛 Troubleshooting

**Hash errors?**
→ Copy hash from error, replace `lib.fakeSha256`

**LSP not working?**
→ `:LspInfo` and `:checkhealth`

**Slow startup?**
→ Use improved config with lazy loading

**Keymaps not working?**
→ Leader key is space, test with `:verbose map`

## 🎯 Files to Use

1. **Config**: `nvf-config-improved.nix` ⭐
2. **Guide**: `FINAL_GUIDE.md` ⭐
3. **Reference**: This file

---

**Ready to code!** 🚀
