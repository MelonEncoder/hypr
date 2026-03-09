{ lib, ... }:
{
  home.username = lib.mkDefault "ian";
  home.homeDirectory = lib.mkDefault "/home/ian";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  xdg.configFile."nvim".source = ../../home/common/.config/nvim;
}
