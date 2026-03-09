{ pkgs, ... }:
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
    xwayland.enable = true;
  };
  programs.nm-applet.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
    ];
  };

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-configtool
      fcitx5-gtk
      fcitx5-mozc
      fcitx5-qt
    ];
  };

  fonts.packages = with pkgs; [
    adwaita-fonts
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    font-awesome
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];

  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    blueman
    bluez
    brightnessctl
    breeze-icons
    clang
    cmake
    curl
    dnsmasq
    git
    ghostty
    gsettings-desktop-schemas
    hicolor-icon-theme
    htop
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
    nm-connection-editor
    nodejs
    npm
    pavucontrol
    playerctl
    pyright
    python3
    qt6ct
    quickshell
    rustup
    tmux
    usb-modeswitch
    vim
    wayland
    wayland-protocols
    wayland-utils
    wcurl
    websocat
    wget
    which
    wl-clipboard
    wofi
    zed-editor
  ];

  # Arch-only items from pkgs.lua that still need separate NixOS handling:
  # hyprgraphics, hyprland-protocols, hyprland-qt-support, hyprland-guiutils,
  # hyprshutdown, hyprtoolkit, yay, clipse, hyprlauncher, and the Flatpak apps.

  system.stateVersion = "25.11";
}
