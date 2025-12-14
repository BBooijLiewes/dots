# Integration Example for /etc/nixos

This file shows exactly how to integrate nvf into your existing NixOS setup.

## Error: `programs.nvf` does not exist

If you see this error, it means the nvf home-manager module isn't imported. Follow these steps:

## Step 1: Update flake.nix

Your `/etc/nixos/flake.nix` should look like this:

```nix
{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # ADD THIS - nvf input
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nvf, ... }@inputs: {
    nixosConfigurations = {
      # Replace 'my-nixos' with your actual hostname
      my-nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };  # IMPORTANT: Pass inputs
        modules = [
          ./configuration.nix
          ./hardware-configuration.nix
          
          # Home-manager module
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.bob = import ./home-bob.nix;
            home-manager.extraSpecialArgs = { inherit inputs; };  # IMPORTANT: Pass inputs
          }
        ];
      };
    };
  };
}
```

## Step 2: Update home-bob.nix

Your `/etc/nixos/home-bob.nix` should look like this:

```nix
{ config, pkgs, inputs, ... }:  # IMPORTANT: Add 'inputs' parameter

{
  # IMPORTANT: Import nvf home-manager module
  imports = [
    inputs.nvf.homeManagerModules.default
    ./nvf-config.nix
  ];

  home.username = "bob";
  home.homeDirectory = "/home/bob";
  home.stateVersion = "24.11";  # Match your NixOS version

  # Your other home-manager configuration...
  programs.git = {
    enable = true;
    userName = "Bob";
    userEmail = "bob@example.com";
  };

  # ... rest of your config
}
```

## Step 3: Update flake.lock

```bash
cd /etc/nixos
sudo nix flake update
```

## Step 4: Rebuild

```bash
sudo nixos-rebuild switch --flake /etc/nixos#my-nixos
```

Replace `my-nixos` with your actual hostname (run `hostname` to check).

## Common Issues

### Issue: "attribute 'inputs' missing"

**Cause**: `inputs` not passed to home-manager

**Fix**: Add to your flake.nix:
```nix
home-manager.extraSpecialArgs = { inherit inputs; };
```

### Issue: "programs.nvf does not exist"

**Cause**: nvf module not imported in home-bob.nix

**Fix**: Add to home-bob.nix:
```nix
imports = [
  inputs.nvf.homeManagerModules.default
  ./nvf-config.nix
];
```

### Issue: "attribute 'nvf' missing"

**Cause**: nvf not added to flake inputs

**Fix**: Add to flake.nix inputs:
```nix
nvf = {
  url = "github:notashelf/nvf";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

## Verification

After rebuilding, verify nvf is working:

```bash
# Check Neovim is available
which nvim

# Check version
nvim --version

# Test Neovim
nvim

# Inside Neovim, check health
:checkhealth

# Check LSP
:LspInfo
```

## Alternative: System-Wide Installation

If you prefer system-wide installation instead of home-manager:

### configuration.nix

```nix
{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    inputs.nvf.nixosModules.default
    ./nvf-config.nix
  ];

  # ... rest of your configuration
}
```

### flake.nix

```nix
{
  outputs = { self, nixpkgs, nvf, ... }@inputs: {
    nixosConfigurations = {
      my-nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          ./hardware-configuration.nix
        ];
      };
    };
  };
}
```

## Need Help?

If you're still having issues:

1. Check that `inputs` is in the function parameters
2. Check that nvf is in flake.nix inputs
3. Check that nvf module is imported
4. Run with `--show-trace` for more details:
   ```bash
   sudo nixos-rebuild switch --flake /etc/nixos#hostname --show-trace
   ```

5. Check the nvf documentation: https://nvf.notashelf.dev/
