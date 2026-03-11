{
  description = "Ian's cross-platform dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixpkgs-unstable, home-manager, nix-flatpak, ... }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      unstablePkgs = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      nixosConfigurations.latitude = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit unstablePkgs;
        };

        modules = [
          nix-flatpak.nixosModules.nix-flatpak
          ./nix/hosts/latitude/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.ian.imports = [
              ./nix/home/common.nix
              ./nix/home/linux.nix
            ];
          }
        ];
      };

      nixosConfigurations.desktop-nvidia = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit unstablePkgs;
        };

        modules = [
          nix-flatpak.nixosModules.nix-flatpak
          ./nix/hosts/desktop-nvidia/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.ian.imports = [
              ./nix/home/common.nix
              ./nix/home/linux.nix
            ];
          }
        ];
      };

      homeConfigurations."ian@arch" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./nix/home/common.nix
          ./nix/home/linux.nix
        ];
      };
    };
}
