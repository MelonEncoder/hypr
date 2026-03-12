{ lib, ... }:
{
  home.username = lib.mkDefault "ian";
  home.homeDirectory = lib.mkDefault "/home/ian";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userName = "MelonEncoder";
    userEmail = "iangillette@proton.me";

    signing = {
      key = "~/.ssh/id_ed25519.pub";
      signByDefault = true;
    };

    extraConfig = {
      core.editor = "zeditor";
      init.defaultBranch = "main";
      gpg.format = "ssh";
      pull.rebase = false;
    };
  };

  xdg.configFile."nvim".source = ../../home/common/.config/nvim;
  xdg.configFile."zed".source = ../../home/common/.config/zed;
}
