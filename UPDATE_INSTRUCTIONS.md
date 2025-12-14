# Update Instructions - You Haven't Updated Your Files Yet!

## The Problem

Your `/etc/nixos/flake.nix` hasn't been updated with the changes. You need to actually edit the file.

## Option 1: Copy the Corrected File (Easiest)

```bash
# Backup your current flake
sudo cp /etc/nixos/flake.nix /etc/nixos/flake.nix.backup

# Copy the corrected flake from the dots repo
sudo cp ~/path/to/dots/flake.nix.final /etc/nixos/flake.nix

# Or if you're in the dots directory:
sudo cp flake.nix.final /etc/nixos/flake.nix
```

## Option 2: Manual Edit (If you prefer)

Edit `/etc/nixos/flake.nix`:

```bash
sudo nano /etc/nixos/flake.nix
```

Make these exact changes:

### Change 1: Update the outputs line (around line 24)

**FROM:**
```nix
outputs = { self, nixpkgs, home-manager, dots, ... }:
```

**TO:**
```nix
outputs = { self, nixpkgs, home-manager, dots, nvf, ... }@inputs:
```

### Change 2: Add specialArgs (around line 29, after `inherit system;`)

**ADD THIS LINE:**
```nix
nixosConfigurations.my-nixos = nixpkgs.lib.nixosSystem {
  inherit system;
  
  specialArgs = { inherit inputs; };  # ← ADD THIS LINE
  
  modules = [
```

### Change 3: Update extraSpecialArgs (around line 42)

**FROM:**
```nix
home-manager.extraSpecialArgs = {
  inherit dots;
};
```

**TO:**
```nix
home-manager.extraSpecialArgs = {
  inherit dots inputs;
};
```

### Change 4: Update nvf input (around line 18)

**FROM:**
```nix
nvf.url = "github:notashelf/nvf";
```

**TO:**
```nix
nvf = {
  url = "github:notashelf/nvf";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

## Verify Your Changes

After editing, verify the changes were made:

```bash
# Check for specialArgs
grep "specialArgs" /etc/nixos/flake.nix

# Should output something like:
# specialArgs = { inherit inputs; };
```

## Then Rebuild

```bash
cd /etc/nixos
sudo nix flake update
sudo nixos-rebuild switch --flake /etc/nixos#my-nixos
```

## Complete Corrected File

Here's the COMPLETE file you should have in `/etc/nixos/flake.nix`:

```nix
{
  description = "Bob's NixOS with Hyprland + Home Manager + dots wallpaper";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dots = {
      url = "github:BBooijLiewes/dots";
      flake = false;
    };

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, dots, nvf, ... }@inputs:
  let
    system = "x86_64-linux";
  in {
    nixosConfigurations.my-nixos = nixpkgs.lib.nixosSystem {
      inherit system;
      
      specialArgs = { inherit inputs; };

      modules = [
        ./configuration.nix

        home-manager.nixosModules.home-manager

        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.extraSpecialArgs = {
            inherit dots inputs;
          };

          home-manager.users.bob = import ./home-bob.nix;
        }
      ];
    };
  };
}
```

Copy this entire file to `/etc/nixos/flake.nix` and you're done!
