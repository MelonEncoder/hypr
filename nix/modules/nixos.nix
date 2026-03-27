{ pkgs, unstablePkgs, ... }:
{
  imports = [
    ./packages.nix
  ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    configurationLimit = 100;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  networking.modemmanager.enable = true;
  networking.networkmanager.enable = true;

  time.timeZone = "US/Eastern";

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

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  security.polkit.enable = true;

  users.users.ian = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "dialout"
      "docker"
    ];
  };

  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      log-driver = "journald"; # integrates with NixOS logging
      storage-driver = "overlay2"; # best performance on most filesystems
      default-address-pools = [
        {
          base = "172.30.0.0/16"; # avoids conflicts with common home networks
          size = 24;
        }
      ];
    };
  };

  environment.variables = {
    GST_PLUGIN_PATH = "/run/current-system/sw/lib/gstreamer-1.0/";
  };

  services.upower.enable = true;
  services.blueman.enable = true;
  services.flatpak = {
    enable = true;
    remotes = [
      {
        name = "flathub";
        location = "https://flathub.org/repo/flathub.flatpakrepo";
      }
    ];
    packages = [
      "com.discordapp.Discord"
      "org.prismlauncher.PrismLauncher"
      "com.obsproject.Studio"
      "com.spotify.Client"
      "app.zen_browser.zen"
    ];
  };
  services.flatpak.update.auto = {
    enable = true;
    onCalendar = "weekly";
  };
  services.gvfs.enable = true;
  services.power-profiles-daemon.enable = true;
  services.printing.enable = true;
  services.xserver.desktopManager.runXdgAutostartIfNone = true;
  services.accounts-daemon.enable = true;
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
  programs.ssh.enableAskPassword = false;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    gamescopeSession.enable = true;
  };
  programs.java.enable = true;
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  system.stateVersion = "25.11";
}
