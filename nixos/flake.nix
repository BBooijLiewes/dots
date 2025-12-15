{
  description = "Bob's NixOS with Hyprland + Home Manager + dots wallpaper";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
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

  outputs = inputs@{ self, nixpkgs, home-manager, dots, nvf, ... }:
  let
    system = "x86_64-linux";
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

          home-manager.extraSpecialArgs = {
            inherit dots nvf;
          };

          home-manager.users.bob = import ./home-bob.nix;
        })
      ];
    };
  };
}

