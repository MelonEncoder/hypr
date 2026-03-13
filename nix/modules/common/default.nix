{
  pkgs,
  unstablePkgs,
  ...
}:
{
  imports = [
    ./packages.nix
    ./i18n.nix
  ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.modemmanager.enable = true;
  networking.networkmanager.enable = true;

  time.timeZone = "US/Eastern";

  users.users.ian = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  security.polkit.enable = true;

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
  programs.ssh.enableAskPassword = false;
  programs.steam.enable = true;

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

  system.stateVersion = "25.11";
}
