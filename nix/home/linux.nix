{
  config,
  lib,
  pkgs,
  ...
}:
{
  xdg.configFile."fcitx5".source = ../../home/linux/.config/fcitx5;
  xdg.configFile."hypr".source = ../../home/linux/.config/hypr;
  xdg.configFile."quickshell".source = ../../home/linux/.config/quickshell;
  xdg.configFile."nixpkgs".source = ../../home/linux/.config/nixpkgs;
  home.file.".local/share/wallpapers".source = ../../home/linux/.local/share/wallpapers;

  qt = {
    enable = true;
    platformTheme.name = "kde";
    style.name = "breeze";
    kde.settings = {
      kdeglobals = {
        General = {
          ColorScheme = "BreezeDark";
        };
        Icons = {
          Theme = "breeze-dark";
        };
        KDE = {
          widgetStyle = "Breeze";
        };
      };
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      cursor-theme = "Adwaita";
      cursor-size = 22;
      gtk-theme = "Adwaita-dark";
      icon-theme = "Adwaita";
    };
  };

  home.sessionVariables = {
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    GTK_USE_PORTAL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop = "${config.home.homeDirectory}/Desktop";
    documents = "${config.home.homeDirectory}/Documents";
    download = "${config.home.homeDirectory}/Downloads";
    music = "${config.home.homeDirectory}/Music";
    pictures = "${config.home.homeDirectory}/Pictures";
    publicShare = "${config.home.homeDirectory}/Public";
    templates = "${config.home.homeDirectory}/Templates";
    videos = "${config.home.homeDirectory}/Videos";

    extraConfig = {
      PROJECTS = "${config.home.homeDirectory}/Projects";
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
    };
  };

  home.activation.createScreenshotDirectory = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "${config.home.homeDirectory}/Pictures/Screenshots"
  '';

  home.activation.configureRustup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if command -v rustup >/dev/null 2>&1; then
      ${pkgs.rustup}/bin/rustup default stable
      ${pkgs.rustup}/bin/rustup component add rust-analyzer
      ${pkgs.rustup}/bin/rustup target add wasm32-wasip1
    fi
  '';

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
