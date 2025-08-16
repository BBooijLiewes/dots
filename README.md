# 🏠 Personal Development Environment

> A sophisticated Linux desktop configuration optimized for keyboard-driven development workflow

[![Neovim](https://img.shields.io/badge/Neovim-57A143?style=for-the-badge&logo=neovim&logoColor=white)](https://neovim.io/)
[![Sway](https://img.shields.io/badge/Sway-5294CF?style=for-the-badge&logo=wayland&logoColor=white)](https://swaywm.org/)
[![Kitty](https://img.shields.io/badge/Kitty-000000?style=for-the-badge&logo=gnome-terminal&logoColor=white)](https://sw.kovidgoyal.net/kitty/)
[![Lua](https://img.shields.io/badge/Lua-2C2D72?style=for-the-badge&logo=lua&logoColor=white)](https://www.lua.org/)

## 🎯 Overview

This repository contains my personal dotfiles and configuration for a complete Linux development environment. Built around **Sway** (Wayland compositor) with **Neovim** as the primary editor, it provides a consistent, vim-centric workflow across all applications.

## 🏗️ Architecture

```
.config/
├── 📝 nvim/           # Neovim configuration (Lua-based)
├── 🖥️  kitty/          # Terminal emulator settings
├── 🪟 sway/           # Wayland window manager
├── 📊 waybar/         # Status bar configuration
├── 🌐 qutebrowser/    # Vim-like web browser
└── 🎨 rofi/           # Application launcher

tests/
├── 🧪 lua/            # Neovim Lua configuration tests
├── 🐚 shell/          # Shell script and utility tests
├── 🔧 run_tests.sh    # Main test runner
└── 📋 simple_test.sh  # Quick validation tests

.github/
└── 🚀 workflows/      # CI/CD automation
```

## ⚡ Key Components

### 🔧 Neovim Configuration
- **📍 Entry Point**: `init.lua`
- **📦 Package Manager**: [lazy.nvim](https://github.com/folke/lazy.nvim)
- **🎨 Theme**: Tokyo Night
- **🔌 Key Features**:
  - LSP support with Mason
  - Treesitter syntax highlighting
  - Telescope fuzzy finder
  - Git integration with Gitsigns
  - Code completion with nvim-cmp

### 🖥️ Terminal Setup
- **Terminal**: Kitty with FiraCode Nerd Font
- **Shell**: Zsh with custom configuration
- **Theme**: Consistent Tokyo Night theming

### 🪟 Window Management
- **Compositor**: Sway (Wayland)
- **Keybindings**: Vim-inspired navigation
- **Status Bar**: Waybar with system monitoring
- **Launcher**: Rofi for application launching

### 🌐 Web Browsing
- **Browser**: Qutebrowser
- **Navigation**: Vim-like keybindings
- **Features**: Custom search engines, dark mode

## 🚀 Quick Start

### Prerequisites
- Linux system with Wayland support
- Git installed
- Basic development tools

### Installation

1. **Clone the repository**:
   ```bash
   git clone <your-repo-url> ~/dotfiles
   cd ~/dotfiles
   ```

2. **Backup existing configs** (if any):
   ```bash
   mv ~/.config ~/.config.backup
   ```

3. **Symlink configurations**:
   ```bash
   ln -sf ~/dotfiles/.config ~/.config
   ```

4. **Install dependencies**:
   ```bash
   # Install Neovim plugins
   nvim --headless "+Lazy! sync" +qa
   
   # Install required fonts
   # (Instructions vary by distribution)
   ```

5. **Validate installation**:
   ```bash
   # Run configuration tests
   ./tests/run_tests.sh
   
   # Quick validation
   ./tests/simple_test.sh
   ```

## 🎨 Customization

### 🔧 Neovim
- **Settings**: Edit `~/.config/nvim/lua/settings.lua`
- **Keymaps**: Modify files in `~/.config/nvim/lua/keymaps/`
- **Plugins**: Update `~/.config/nvim/lua/lazy_setup.lua`

### 🪟 Sway
- **Config**: `~/.config/sway/config`
- **Keybindings**: Vim-style (hjkl) navigation
- **Workspaces**: Numbered 1-10 with custom icons

### 🖥️ Terminal
- **Kitty**: `~/.config/kitty/kitty.conf`
- **Font**: FiraCode Nerd Font Mono, 16pt
- **Theme**: Tokyo Night integration

## 📁 Directory Structure

```
.config/
├── nvim/
│   ├── init.lua                    # Main entry point
│   ├── lazy-lock.json             # Plugin lockfile
│   └── lua/
│       ├── settings.lua           # Core settings
│       ├── keymaps/               # Key bindings
│       ├── plugin-configs/        # Plugin configurations
│       └── lazy_setup.lua         # Plugin management
├── kitty/
│   ├── kitty.conf                 # Terminal configuration
│   └── tokyonight_night.conf      # Theme file
├── sway/
│   ├── config                     # Window manager config
│   └── background.png             # Desktop wallpaper
├── waybar/
│   ├── config                     # Status bar config
│   ├── style.css                  # Styling
│   ├── launch.sh                  # Launch script
│   └── modules/
│       └── powermenu.sh           # Power management module
└── qutebrowser/
    └── config.py                  # Browser configuration

tests/
├── lua/
│   ├── test_keymaps.lua           # Keymap functionality tests
│   ├── test_lazy_setup.lua        # Plugin setup validation
│   └── test_settings.lua          # Settings configuration tests
├── shell/
│   └── test_waybar_modules.sh     # Waybar module tests
├── run_tests.sh                   # Comprehensive test runner
└── simple_test.sh                 # Quick validation tests

.github/
└── workflows/
    └── test.yml                   # CI/CD pipeline configuration
```

## 🎯 Key Features

- ✅ **Vim-centric workflow** across all applications
- ✅ **Consistent theming** (Tokyo Night)
- ✅ **Keyboard-driven navigation**
- ✅ **Modular configuration** structure
- ✅ **LSP-powered development** environment
- ✅ **Git integration** throughout
- ✅ **Wayland-native** applications
- ✅ **Comprehensive testing suite** with CI/CD
- ✅ **Automated configuration validation**

## 🛠️ Tech Stack

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Editor** | Neovim + Lua | Primary development environment |
| **Window Manager** | Sway | Wayland compositor |
| **Terminal** | Kitty | GPU-accelerated terminal |
| **Status Bar** | Waybar | System information display |
| **Browser** | Qutebrowser | Vim-like web browsing |
| **Launcher** | Rofi | Application launcher |
| **Font** | FiraCode Nerd Font | Programming font with ligatures |
| **Testing** | Custom Test Suite | Lua & Shell script validation |
| **CI/CD** | GitHub Actions | Automated testing & linting |

## 🧪 Testing

This repository includes a comprehensive testing suite to ensure configuration reliability:

### Running Tests

```bash
# Run all tests
./tests/run_tests.sh

# Run specific test categories
./tests/run_tests.sh lua      # Neovim Lua configuration tests
./tests/run_tests.sh shell    # Shell script tests
./tests/run_tests.sh integration  # Integration tests

# Quick validation
./tests/simple_test.sh
```

### Test Categories

- **🧪 Lua Tests**: Validate Neovim configurations, plugin setups, and keymaps
- **🐚 Shell Tests**: Test Waybar modules and shell script functionality  
- **🔧 Integration Tests**: End-to-end configuration validation
- **🚀 CI/CD**: Automated testing on every push and pull request

### Continuous Integration

GitHub Actions automatically:
- ✅ Runs all tests on push/PR
- ✅ Validates Lua syntax
- ✅ Lints shell scripts with shellcheck
- ✅ Ensures configuration integrity

## 🤝 Contributing

Feel free to fork this repository and adapt it to your needs! If you have improvements or suggestions:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. **Run tests**: `./tests/run_tests.sh`
5. Submit a pull request

All contributions are automatically tested via GitHub Actions.

## 📝 License

This configuration is provided as-is for personal use. Feel free to use and modify as needed.

---

<div align="center">

**Happy Coding!** 🚀

*Built with ❤️ for efficient development*

</div>
