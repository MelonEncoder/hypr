{ lib, ... }:
{
  home.homeDirectory = lib.mkDefault "/Users/ian";

  # Add macOS-specific Home Manager entries here.
}
