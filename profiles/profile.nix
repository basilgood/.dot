{ config, lib, pkgs, ... }:
{
  imports = [
    ./local.nix
    ./general.nix
    ../X11/i3.nix
    # ../X11/dwm.nix
  ];
}
