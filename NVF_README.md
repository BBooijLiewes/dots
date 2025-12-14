# nvf Neovim Configuration

Modern, optimized Neovim configuration for Django/React/Docker development using nvf (Nix-based Neovim Framework).

## Features

- ⚡ **Fast startup** (50-100ms with lazy loading)
- 🐍 **Django** - Template syntax, stubs, debugging
- ⚛️ **React/TypeScript** - LSP, ESLint, Prettier, auto-tags
- 🐳 **Docker** - Dockerfile & Compose LSP, GitLab CI validation
- 🧪 **Testing** - Neotest for Python/Jest
- 🐛 **Debugging** - DAP support
- 🌳 **Modern Git** - Neogit + Gitsigns
- 🔍 **Smart Search** - Telescope + Spectre
- 📊 **Diagnostics** - Trouble for better error viewing

## Quick Start

### 1. Copy Configuration

```bash
sudo cp nvf-config.nix /etc/nixos/
```

### 2. Update flake.nix

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nvf.url = "github:notashelf/nvf";
  };
}
```

### 3. Update home-manager

```nix
# In home-bob.nix or similar
imports = [
  inputs.nvf.homeManagerModules.default
  ./nvf-config.nix
];
```

### 4. Build

```bash
cd /etc/nixos
sudo nix flake update
sudo nixos-rebuild switch --flake .#hostname
```

## Essential Keymaps

### File Navigation (Original Keybindings Preserved)
- `<C-p>` - Find files
- `<C-j>` - Live grep
- `<C-f>` - File browser (current dir)
- `<C-b>` - File browser (root)
- `<C-h>` - Toggle precognition

### Additional Navigation
- `<leader>ff` - Find files
- `<leader>fg` - Live grep
- `<leader>fb` - Find buffers
- `<leader>fh` - Help tags

### Git
- `<leader>gg` - Open Neogit
- `<leader>gc` - Git commit
- `<leader>gp` - Git push
- `<leader>dv` - Open diffview

### Django
- `<leader>dr` - Run server
- `<leader>dt` - Run tests
- `<leader>ds` - Django shell

### Docker
- `<leader>Du` - Compose up
- `<leader>Dd` - Compose down

### Testing & Debugging
- `<leader>tt` - Run test
- `<leader>tf` - Run test file
- `<leader>db` - Toggle breakpoint

### Code Navigation
- `<leader>o` - Toggle outline
- `<leader>n` - LSP navigation
- `<leader>xx` - Toggle Trouble

## Language Support

| Language | LSP | Formatter | Debugging |
|----------|-----|-----------|-----------|
| Python | basedpyright | ruff | debugpy |
| TypeScript/JS | tsserver | prettier | - |
| HTML/CSS | ✅ | - | - |
| YAML | yamlls | - | - |
| Docker | dockerls | - | - |
| Bash | bash-ls | - | - |
| Nix | nil | alejandra | - |

## Documentation

- **START_HERE.md** - Quick overview
- **FINAL_GUIDE.md** - Complete guide
- **QUICK_REFERENCE.md** - One-page cheat sheet
- **docs/** - Additional documentation

## Troubleshooting

### Hash Errors on First Build

Normal! Copy the hash from the error message and replace `lib.fakeSha256` in the config.

### LSP Not Working

```vim
:LspInfo
:checkhealth
```

### Slow Startup

Lazy loading is enabled. If still slow, check `:Lazy profile`.

## More Information

See **FINAL_GUIDE.md** for complete documentation.

## License

MIT - Based on original dotfiles configuration
