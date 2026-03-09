{ pkgs, pkgsUnstable, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "latitude";
  networking.modemmanager.enable = true;
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

  networking.networkmanager.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  security.polkit.enable = true;

  services.blueman.enable = true;
  services.flatpak = {
    enable = true;
    remote = {
      name = "flathub";
      url = "https://flathub.org/repo/flathub.flatpakrepo";
    };
	packages = [
	  "app.zen_browser.zen"
	  "com.obsproject.Studio"
	  "com.discordapp.Discord"
	  "com.spotify.Client"
	];
  };
  services.gvfs.enable = true;
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
    package = pkgsUnstable.hyprland;
    portalPackage = pkgsUnstable.xdg-desktop-portal-hyprland;
    xwayland.enable = true;
  };
  programs.nm-applet.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgsUnstable.xdg-desktop-portal-hyprland
    ];
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      kdePackages.fcitx5-configtool
      fcitx5-gtk
      fcitx5-mozc
      kdePackages.fcitx5-qt
    ];
    fcitx5.waylandFrontend = true;
  };

  fonts.packages = with pkgs; [
    adwaita-fonts
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    font-awesome
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];

  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    blueman
    bluez
    brightnessctl
    kdePackages.breeze-icons
    clang
    cmake
	clipse
    dnsmasq
    git
    ghostty
    gsettings-desktop-schemas
    hicolor-icon-theme
    htop
    inkscape
    iw
    iwd
    loupe
    man-db
    meson
    nautilus
    neovim
    ninja
    nix
	go
    nodejs_24
    pavucontrol
    playerctl
    pyright
    python3
    kdePackages.qt6ct
    quickshell
    rustup
    tmux
    usb-modeswitch
    vim
    curl
    wget
    which
    wl-clipboard
    zed-editor
  ] ++ (with pkgsUnstable; [
    hyprcursor
    hypridle
    hyprlang
    hyprlock
    hyprpaper
    hyprpicker
    hyprpolkitagent
    hyprshot
	hyprwire
    hyprsunset
    hyprutils
    hyprwayland-scanner
	hyprgraphics
	hyprland-qt-support
	hyprland-qtutils
	hyprsysteminfo
	hyprcursor
	hyprnotify
  ]);

  # Arch-only items from pkgs.lua that still need separate NixOS handling:
  # hyprgraphics, hyprland-protocols, hyprland-qt-support, hyprland-guiutils,
  # hyprshutdown, hyprtoolkit, yay, clipse, hyprlauncher, and the Flatpak apps.

  system.stateVersion = "25.11";
}
