{ pkgs, unstablePkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.modemmanager.enable = true;
  networking.networkmanager.enable = true;

  time.timeZone = "US/Eastern";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "ja_JP.UTF-8/UTF-8"
  ];

  users.users.ian = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  security.polkit.enable = true;

  services.blueman.enable = true;
  services.flatpak = {
    enable = true;
    remotes = [{
      name = "flathub";
      location = "https://flathub.org/repo/flathub.flatpakrepo";
    }];
    packages = [
      "app.zen_browser.zen"
      "com.obsproject.Studio"
      "com.discordapp.Discord"
    ];
  };
  services.gvfs.enable = true;
  services.power-profiles-daemon.enable = true;
  services.printing.enable = true;
  services.xserver.enable = true;
  services.xserver.desktopManager.runXdgAutostartIfNone = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  programs.dconf.enable = true;
  programs.hyprland = {
    enable = true;
    package = unstablePkgs.hyprland;
    portalPackage = unstablePkgs.xdg-desktop-portal-hyprland;
    xwayland.enable = true;
  };
  programs.nm-applet.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      unstablePkgs.xdg-desktop-portal-hyprland
    ];
  };

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

  fonts.packages = [
    pkgs.adwaita-fonts
    pkgs.noto-fonts
    pkgs.noto-fonts-cjk-sans
    pkgs.noto-fonts-color-emoji
    pkgs.font-awesome
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.symbols-only
  ];

  environment.systemPackages = [
    pkgs.adwaita-icon-theme
    pkgs.blueman
    pkgs.bluez
    pkgs.brightnessctl
    pkgs.kdePackages.breeze-icons
    pkgs.clang
    pkgs.clipse
    pkgs.cmake
    pkgs.curl
    pkgs.dnsmasq
    pkgs.git
    pkgs.go
    pkgs.ghostty
    pkgs.gsettings-desktop-schemas
    pkgs.hicolor-icon-theme
    pkgs.htop
    pkgs.inkscape
    pkgs.iw
    pkgs.iwd
    pkgs.loupe
    pkgs.man-db
    pkgs.meson
    pkgs.nautilus
    pkgs.ninja
    pkgs.nix
    pkgs.nodejs_24
    pkgs.pavucontrol
    pkgs.playerctl
    pkgs.power-profiles-daemon
    pkgs.pyright
    pkgs.python3
    pkgs.kdePackages.qt6ct
    pkgs.quickshell
    pkgs.rustup
    pkgs.spotify
    pkgs.tmux
    pkgs.usb-modeswitch
    pkgs.vim
    pkgs.wget
    pkgs.which
    pkgs.wl-clipboard
    pkgs.zed-editor
    unstablePkgs.hyprcursor
    unstablePkgs.hypridle
    unstablePkgs.hyprlang
    unstablePkgs.hyprlock
    unstablePkgs.hyprpaper
    unstablePkgs.hyprpicker
    unstablePkgs.hyprpolkitagent
    unstablePkgs.hyprshot
    unstablePkgs.hyprsunset
    unstablePkgs.hyprsysteminfo
    unstablePkgs.hyprutils
    unstablePkgs.hyprwayland-scanner
    unstablePkgs.hyprwire
    unstablePkgs.hyprgraphics
    unstablePkgs.hyprland-qt-support
    unstablePkgs.hyprland-qtutils
    unstablePkgs.hyprnotify
    unstablePkgs.neovim
  ];

  system.stateVersion = "25.11";
}
