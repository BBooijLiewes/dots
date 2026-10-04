{
  description = "Bob's NixOS with Hyprland + Home Manager + dots wallpaper";

  # Routine security updates (stable branches only):
  #   nix flake update nixpkgs home-manager
  #   sudo nixos-rebuild switch --flake .#my-nixos
  #
  # nvf tracks its main branch and breaks option names between releases;
  # bump it deliberately with:  nix flake update nvf
  #
  # nixpkgs-unstable is only used for opencode; bump it with:
  #   nix flake update nixpkgs-unstable

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # whole repo (for wallpapers/configs outside nixos/ too)
    dots = {
      url = "github:BBooijLiewes/dots";
      flake = false;
    };

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, home-manager, dots, nvf, ... }:
  let
    system = "x86_64-linux";

    # Unstable package set, used only for selected packages (opencode)
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    nixosConfigurations.my-nixos = nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = { inherit inputs; };

      modules = [
        ./hosts/my-nixos/configuration.nix

        home-manager.nixosModules.home-manager

        ({ ... }: {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          # Don't abort activation when a managed dotfile already exists;
          # rename the old one instead.
          home-manager.backupFileExtension = "hm-backup";

          home-manager.extraSpecialArgs = {
            inherit dots nvf pkgs-unstable;
          };

          home-manager.users.bob = import ./home-bob.nix;
        })
      ];
    };
  };
}
