{ lib, ... }:
{
  home.username = lib.mkDefault "ian";
  home.homeDirectory = lib.mkDefault "/home/ian";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
  programs.git = {
    enable = true;

    signing = {
      key = "~/.ssh/id_ed25519.pub";
      signByDefault = true;
    };

    settings = {
      user.name = "MelonEncoder";
      user.email = "iangillette@proton.me";
      core.editor = "zeditor";
      init.defaultBranch = "main";
      gpg.format = "ssh";
      pull.rebase = false;
    };
  };

  xdg.configFile."nvim".source = ../../home/common/.config/nvim;
  xdg.configFile."zed".source = ../../home/common/.config/zed;
}
