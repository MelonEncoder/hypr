{ config, pkgs, ... }:
{
  xdg.configFile."hypr".source = ../../home/linux/.config/hypr;
  xdg.configFile."quickshell".source = ../../home/linux/.config/quickshell;
  home.file.".local/share/wallpapers".source = ../../home/linux/.local/share/wallpapers;

  xdg.dataFile."dbus-1/services/org.freedesktop.Notifications.service".text = ''
    [D-BUS Service]
    Name=org.freedesktop.Notifications
    Exec=${pkgs.quickshell}/bin/qs -p ${config.home.homeDirectory}/.config/quickshell
    SystemdService=quickshell.service
  '';

  systemd.user.services.quickshell = {
    Unit = {
      Description = "Quickshell";
    };

    Service = {
      ExecStart = "${pkgs.quickshell}/bin/qs -p %h/.config/quickshell";
      Restart = "on-failure";
      RestartSec = 1;
    };
  };
}
