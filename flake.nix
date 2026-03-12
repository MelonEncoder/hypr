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

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      nix-flatpak,
      ...
    }:
    let
      system = "x86_64-linux";

      unstablePkgs = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations.nixos-latitude = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit unstablePkgs;
        };

        modules = [
          nix-flatpak.nixosModules.nix-flatpak
          ./nix/hosts/nixos-latitude/configuration.nix
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

      nixosConfigurations.nixos-pc-nvidia = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit unstablePkgs;
        };

        modules = [
          nix-flatpak.nixosModules.nix-flatpak
          ./nix/hosts/nixos-pc-nvidia/configuration.nix
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
    };
}
