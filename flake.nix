{
  description = "Ian's cross-platform dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      mkPkgs = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      nixosConfigurations.latitude = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./nix/hosts/latitude/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.ian.imports = [
              ./nix/home/common.nix
              ./nix/home/linux.nix
            ];
          }
        ];
      };

      homeConfigurations."ian@arch" = home-manager.lib.homeManagerConfiguration {
        pkgs = mkPkgs "x86_64-linux";
        modules = [
          ./nix/home/common.nix
          ./nix/home/linux.nix
        ];
      };
    };
}
