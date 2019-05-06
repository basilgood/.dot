{ config, lib, pkgs,options, ... }:

{

  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (import ./overlays/waybar)
    # (import ../overlays/lxd)
  ];

  # imports = [
  #   ../virtualisation/lxc.nix
  #   ../virtualisation/lxd.nix
  #   # ../virtualisation/virtualbox.nix
  # ];

  nix.buildCores = 4;

  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  powerManagement = {
    enable = true;
  };

  programs = {
    # tmux.enable = true;
    java.enable = true;
  };

  hardware = {
    pulseaudio.enable = true;
    cpu.amd.updateMicrocode = true;
    opengl = {
      enable = true;
      extraPackages = with pkgs; [ libvdpau-va-gl vaapiVdpau ];
    };
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
  };

  users.defaultUserShell = "/run/current-system/sw/bin/bash";

  networking.networkmanager = {
    enable = true;
    dns = "dnsmasq";
    dynamicHosts =  {
      enable = true;
    };
  };

  environment.etc."NetworkManager/dnsmasq.d/10-dns-lxcd.conf".text = ''
      server=/local/10.0.3.1
      server=/lxd/10.0.4.1
  '';

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      corefonts
      nerdfonts
    ];
  };

  services.upower.enable = true;
  services.udev.packages = with pkgs; [
    brightnessctl
    android-udev-rules
  ];

  programs.ssh.startAgent = true;

}
