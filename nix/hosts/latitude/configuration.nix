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
  services.flatpak.enable = true;
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
    mako
    man-db
    meson
    nautilus
    neovim
    ninja
    nix
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
    wofi
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
    hyprsunset
    hyprutils
    hyprwayland-scanner
  ]);

  # Arch-only items from pkgs.lua that still need separate NixOS handling:
  # hyprgraphics, hyprland-protocols, hyprland-qt-support, hyprland-guiutils,
  # hyprshutdown, hyprtoolkit, yay, clipse, hyprlauncher, and the Flatpak apps.

  system.stateVersion = "25.11";
}
