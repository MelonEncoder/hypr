{ ... }:
{
  imports = [
    ../../modules/common/default.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "nixos-latitude";
}
