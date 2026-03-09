{ ... }:
{
  xdg.configFile."hypr".source = ../../home/linux/.config/hypr;
  xdg.configFile."mako".source = ../../home/linux/.config/mako;
  xdg.configFile."quickshell".source = ../../home/linux/.config/quickshell;
  xdg.configFile."wofi".source = ../../home/linux/.config/wofi;

  home.file.".local/share/wallpapers".source = ../../home/linux/.local/share/wallpapers;
  home.file.".config/swps.conf".source = ../../swps.conf;
}
