{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "nixos";
  time.timeZone = "US/Eastern";

  users.users.ian = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  services.xserver.enable = true;
  programs.hyprland.enable = true;

  environment.systemPackages = with pkgs; [
    git
    neovim
  ];

  system.stateVersion = "25.05";
}
