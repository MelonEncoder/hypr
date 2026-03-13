{ ... }:
{
  imports = [
    ../../modules/nixos.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "nixos-latitude";
}
