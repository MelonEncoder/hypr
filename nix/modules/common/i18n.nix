{ pkgs, ... }:
{
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "ja_JP.UTF-8/UTF-8"
  ];

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = [
      pkgs.kdePackages.fcitx5-configtool
      pkgs.fcitx5-gtk
      pkgs.fcitx5-mozc
      pkgs.kdePackages.fcitx5-qt
    ];
    fcitx5.waylandFrontend = true;
  };
}
