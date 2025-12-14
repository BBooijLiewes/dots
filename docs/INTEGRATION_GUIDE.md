# nvf Integration Guide for Existing NixOS Setup

This guide shows how to integrate the nvf Neovim configuration into your existing NixOS setup with the structure:
```
/etc/nixos/
├── configuration.nix
├── flake.lock
├── flake.nix
├── hardware-configuration.nix
└── home-bob.nix
```

## Integration Steps

### Step 1: Copy Configuration Files

Copy the nvf configuration to your NixOS directory:

```bash
# Copy the nvf configuration file
sudo cp nvf-config.nix /etc/nixos/

# Optionally, copy documentation for reference
sudo cp NVF_*.md /etc/nixos/docs/  # Create docs directory if desired
```

### Step 2: Update Your flake.nix

Add nvf as an input to your existing `/etc/nixos/flake.nix`:

```nix
# /etc/nixos/flake.nix
{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # Add nvf input
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";  # Use your nixpkgs
    };
    
    # If you're using home-manager (recommended for user configs)
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nvf, home-manager, ... }@inputs: {
    nixosConfigurations = {
      # Replace 'your-hostname' with your actual hostname
      your-hostname = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          ./hardware-configuration.nix
          
          # Option A: If using home-manager (recommended)
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.bob = import ./home-bob.nix;
            home-manager.extraSpecialArgs = { inherit inputs; };
          }
        ];
      };
    };
  };
}
```

### Step 3: Update home-bob.nix (Recommended Method)

This is the **recommended approach** for user-specific configurations:

```nix
# /etc/nixos/home-bob.nix
{ config, pkgs, inputs, ... }:

{
  # Import nvf configuration
  imports = [
    inputs.nvf.homeManagerModules.default
    ./nvf-config.nix
  ];

  # Your existing home-manager configuration
  home.username = "bob";
  home.homeDirectory = "/home/bob";
  home.stateVersion = "24.11";  # Adjust to your version

  # Other home-manager settings...
  programs.git = {
    enable = true;
    userName = "Bob";
    userEmail = "bob@example.com";
  };

  # ... rest of your home-manager config
}
```

### Step 4: Alternative - System-Wide Installation

If you prefer system-wide installation instead of home-manager:

```nix
# /etc/nixos/configuration.nix
{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    inputs.nvf.nixosModules.default
    ./nvf-config.nix
  ];

  # Your existing system configuration...
  
  # ... rest of your configuration.nix
}
```

### Step 5: Update flake.lock

Update your flake.lock to include nvf:

```bash
cd /etc/nixos
sudo nix flake update
```

### Step 6: Build and Switch

Rebuild your system:

```bash
# Test the configuration first
sudo nixos-rebuild test --flake /etc/nixos#your-hostname

# If everything works, switch permanently
sudo nixos-rebuild switch --flake /etc/nixos#your-hostname
```

## Handling First Build Errors

On first build, you'll encounter hash mismatches for plugins. This is expected:

```
error: hash mismatch in fixed-output derivation
  specified: lib.fakeSha256
  got:       sha256-abc123def456...
```

**Fix:**
1. Copy the correct hash from the error message
2. Edit `/etc/nixos/nvf-config.nix`
3. Replace `lib.fakeSha256` with the correct hash
4. Rebuild

Example:
```nix
# Before
sha256 = lib.fakeSha256;

# After (use hash from error)
sha256 = "sha256-abc123def456...";
```

## Directory Structure After Integration

```
/etc/nixos/
├── configuration.nix          # System configuration
├── flake.lock                 # Lock file (updated)
├── flake.nix                  # Flake with nvf input (updated)
├── hardware-configuration.nix # Hardware config
├── home-bob.nix              # Home-manager config (updated)
├── nvf-config.nix            # nvf Neovim configuration (new)
└── docs/                      # Optional documentation
    ├── NVF_QUICKSTART.md
    ├── NVF_README.md
    └── ...
```

## Verification Steps

After rebuilding, verify the installation:

```bash
# Check Neovim is available
which nvim

# Check version
nvim --version

# Test Neovim starts
nvim

# Inside Neovim, check health
:checkhealth

# Check LSP
:LspInfo

# Check plugins
:Telescope
```

## Troubleshooting

### Issue: "attribute 'nvf' missing"

**Cause**: nvf input not properly added to flake.nix

**Fix**: Ensure nvf is in inputs and run `sudo nix flake update`

### Issue: "programs.nvf not found"

**Cause**: nvf module not imported

**Fix**: 
- For home-manager: Add `inputs.nvf.homeManagerModules.default` to imports
- For system: Add `inputs.nvf.nixosModules.default` to imports

### Issue: Hash mismatch errors

**Cause**: First build needs actual plugin hashes

**Fix**: Copy hashes from error messages and update nvf-config.nix

### Issue: Neovim not in PATH

**Cause**: Using system-wide install but not in environment.systemPackages

**Fix**: Home-manager method automatically adds to PATH. For system-wide, nvf handles this automatically when the module is imported.

## Home-Manager vs System-Wide

### Use Home-Manager When:
- ✅ You want per-user configurations
- ✅ You manage dotfiles per user
- ✅ You want to test without sudo
- ✅ You have multiple users with different configs

### Use System-Wide When:
- ✅ You want the same config for all users
- ✅ You prefer centralized system management
- ✅ You're the only user
- ✅ You want Neovim available at system level

**Recommendation**: Use Home-Manager for better separation and flexibility.

## Next Steps

1. ✅ Integrate nvf into your flake.nix
2. ✅ Update home-bob.nix or configuration.nix
3. ✅ Run `sudo nix flake update`
4. ✅ Build and fix hash errors
5. ✅ Test Neovim functionality
6. ✅ Customize keymaps and settings
7. ✅ Review and add project-specific plugins (see IMPROVEMENTS.md)

## Quick Reference Commands

```bash
# Update flake inputs
sudo nix flake update

# Test configuration
sudo nixos-rebuild test --flake /etc/nixos#hostname

# Switch to new configuration
sudo nixos-rebuild switch --flake /etc/nixos#hostname

# Rollback if needed
sudo nixos-rebuild switch --rollback

# Check what changed
nix store diff-closures /nix/var/nix/profiles/system-*-link
```

## Additional Resources

- **nvf Documentation**: https://nvf.notashelf.dev/
- **Home-Manager Manual**: https://nix-community.github.io/home-manager/
- **NixOS Manual**: https://nixos.org/manual/nixos/stable/
- **Flakes Guide**: https://nixos.wiki/wiki/Flakes

## Support

If you encounter issues:
1. Check this guide's troubleshooting section
2. Review NVF_README.md for detailed troubleshooting
3. Check nvf GitHub issues: https://github.com/NotAShelf/nvf/issues
4. Ask in NixOS Discourse: https://discourse.nixos.org/
