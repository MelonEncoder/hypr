{
  lib,
  config,
  pkgs,
  unstablePkgs,
  homePath,
  ...
}:
{
  home.username = lib.mkDefault "ian";
  home.homeDirectory = lib.mkDefault "/home/ian";
  home.stateVersion = "25.11";
  home.sessionVariables = {
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    GTK_USE_PORTAL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };

  xdg.configFile."fcitx5".source = homePath + "/.config/fcitx5";
  xdg.configFile."hypr".source = homePath + "/.config/hypr";
  xdg.configFile."quickshell".source = homePath + "/.config/quickshell";
  xdg.configFile."nixpkgs".source = homePath + "/.config/nixpkgs";
  xdg.configFile."nvim".source = homePath + "/.config/nvim";
  xdg.configFile."zed".source = homePath + "/.config/zed";

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

  home.file.".local/share/wallpapers".source = homePath + "/.local/share/wallpapers";

  home.activation.createScreenshotDirectory = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "${config.home.homeDirectory}/Pictures/Screenshots"
  '';

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
      "image/png" = [ "org.gnome.Loupe.desktop" ];
      "image/jpeg" = [ "org.gnome.Loupe.desktop" ];
      "image/gif" = [ "org.gnome.Loupe.desktop" ];
      "image/webp" = [ "org.gnome.Loupe.desktop" ];
      "image/bmp" = [ "org.gnome.Loupe.desktop" ];
      "image/tiff" = [ "org.gnome.Loupe.desktop" ];
      "image/svg+xml" = [ "org.gnome.Loupe.desktop" ];
      "application/pdf" = [ "org.gnome.Papers.desktop" ];
      "application/postscript" = [ "org.gnome.Papers.desktop" ];
      "application/x-dvi" = [ "org.gnome.Papers.desktop" ];
      "application/vnd.comicbook+zip" = [ "org.gnome.Papers.desktop" ];
      "application/vnd.comicbook-rar" = [ "org.gnome.Papers.desktop" ];
      "video/mp4" = [ "org.gnome.Showtime.desktop" ];
      "video/x-matroska" = [ "org.gnome.Showtime.desktop" ];
      "video/webm" = [ "org.gnome.Showtime.desktop" ];
      "video/x-msvideo" = [ "org.gnome.Showtime.desktop" ];
      "video/mpeg" = [ "org.gnome.Showtime.desktop" ];
      "video/quicktime" = [ "org.gnome.Showtime.desktop" ];
      "audio/mpeg" = [ "org.gnome.Decibels.desktop" ];
      "audio/flac" = [ "org.gnome.Decibels.desktop" ];
      "audio/ogg" = [ "org.gnome.Decibels.desktop" ];
      "audio/wav" = [ "org.gnome.Decibels.desktop" ];
      "audio/webm" = [ "org.gnome.Decibels.desktop" ];
      "audio/aac" = [ "org.gnome.Decibels.desktop" ];
      "text/plain" = [ "zeditor.desktop" ];
      "text/markdown" = [ "org.gnome.Apostrophe.desktop" ];
      "application/zip" = [ "org.gnome.FileRoller.desktop" ];
      "application/x-tar" = [ "org.gnome.FileRoller.desktop" ];
      "application/x-7z-compressed" = [ "org.gnome.FileRoller.desktop" ];
      "application/x-rar" = [ "org.gnome.FileRoller.desktop" ];
      "application/gzip" = [ "org.gnome.FileRoller.desktop" ];
      "application/x-bzip2" = [ "org.gnome.FileRoller.desktop" ];
    };
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      unstablePkgs.xdg-desktop-portal-hyprland
    ];
    config = {
      common = {
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
        "org.freedesktop.impl.portal.OpenURI" = [ "gtk" ];
      };
      hyprland = {
        default = [
          "hyprland"
          "gtk"
        ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
        "org.freedesktop.impl.portal.OpenURI" = [ "gtk" ];
      };
    };
  };

  xdg.dataFile."dbus-1/services/org.freedesktop.Notifications.service".text = ''
    [D-BUS Service]
    Name=org.freedesktop.Notifications
    Exec=${pkgs.quickshell}/bin/qs -p ${config.home.homeDirectory}/.config/quickshell
    SystemdService=quickshell.service
  '';

  qt = {
    enable = true;
    platformTheme.name = "kde";
    style.name = "breeze";
    kde.settings = {
      kdeglobals = {
        General.ColorScheme = "BreezeDark";
        Icons.Theme = "breeze-dark";
        KDE.widgetStyle = "Breeze";
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

  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    cursor-theme = "Adwaita";
    cursor-size = 22;
    gtk-theme = "Adwaita-dark";
    icon-theme = "Adwaita";
  };

  systemd.user.services.quickshell = {
    Unit.Description = "Quickshell";
    Service = {
      ExecStart = "${pkgs.quickshell}/bin/qs -p %h/.config/quickshell";
      Restart = "on-failure";
      RestartSec = 1;
    };
  };

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
}
