# Quick Fix for "programs.nvf does not exist" Error

## The Problem

Your flake.nix has `nvf` in inputs but doesn't pass it to home-manager, so the nvf module isn't available.

## The Solution

Make these 3 changes:

### 1. Update flake.nix

Change this line:
```nix
outputs = { self, nixpkgs, home-manager, dots, ... }:
```

To this:
```nix
outputs = { self, nixpkgs, home-manager, dots, nvf, ... }@inputs:
```

And change this:
```nix
home-manager.extraSpecialArgs = {
  inherit dots;
};
```

To this:
```nix
home-manager.extraSpecialArgs = {
  inherit dots inputs;
};
```

Also add this to nvf input:
```nix
nvf = {
  url = "github:notashelf/nvf";
  inputs.nixpkgs.follows = "nixpkgs";  # ← Add this line
};
```

### 2. Update home-bob.nix

Add `inputs` to the parameters:
```nix
{ config, pkgs, dots, inputs, ... }:  # ← Add inputs
```

Add imports at the top:
```nix
{
  imports = [
    inputs.nvf.homeManagerModules.default
    ./nvf-config.nix
  ];

  # ... rest of your config
}
```

### 3. Rebuild

```bash
cd /etc/nixos
sudo nix flake update
sudo nixos-rebuild switch --flake .#my-nixos
```

## Complete Examples

See:
- `flake.nix.example` - Complete corrected flake.nix
- `home-bob.nix.example` - Complete corrected home-bob.nix
- `INTEGRATION_EXAMPLE.md` - Detailed explanation

## What Changed

**flake.nix:**
- Added `nvf` to outputs parameters
- Added `@inputs` to capture all inputs
- Added `inputs` to `home-manager.extraSpecialArgs`
- Added `inputs.nixpkgs.follows` to nvf input

**home-bob.nix:**
- Added `inputs` parameter
- Added `imports` section with nvf module

This makes the nvf home-manager module available to your configuration.
