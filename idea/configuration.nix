{ config, inputs, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.default
    inputs.nixvim.nixosModules.nixvim
    ../modules/nixvim.nix
    ../modules/fish.nix
  ];

  dotFilesRoot = ''/home/david/.dotfiles'';

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "idea";
  networking.wireless.userControlled.enable = true;
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Ljubljana";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sl_SI.UTF-8";
    LC_IDENTIFICATION = "sl_SI.UTF-8";
    LC_MEASUREMENT = "sl_SI.UTF-8";
    LC_MONETARY = "sl_SI.UTF-8";
    LC_NAME = "sl_SI.UTF-8";
    LC_NUMERIC = "sl_SI.UTF-8";
    LC_PAPER = "sl_SI.UTF-8";
    LC_TELEPHONE = "sl_SI.UTF-8";
    LC_TIME = "sl_SI.UTF-8";
  };

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };

  # automount
  services.gvfs.enable = true;

  # user account
  users.users.david = {
    isNormalUser = true;
    description = "David";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users = {
      "david" = import ./home.nix;
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Allow installation of unfree corefonts package
  nixpkgs.config.allowUnfreePredicate = pkg:
  builtins.elem (lib.getName pkg) [ "corefonts" ];

  fonts.packages = with pkgs; [
    corefonts
    powerline-fonts
    nerdfonts
    nerd-font-patcher
    font-awesome
  ];

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    bat
    firefox
    lf
    nix-index
    python3
    libreoffice-qt onlyoffice-bin
    hunspell hunspellDicts.en_US-large
    htop tree mtr dig wget curl
    rio
    fuzzel
    rofi-wayland rofi-power-menu
    brave
    jetbrains.pycharm-community-bin
    git
    cinnamon.nemo-with-extensions
    fzf
    brightnessctl
    waybar
    dunst
    libnotify
    wireplumber # part of pipewire suite
    swww networkmanagerapplet
    xarchiver
    pavucontrol
    gsimplecal
    # swaylock
    hyprlock
    vscodium.fhs
    vlc
    fontpreview
    wlsunset

    # emacs
    # emacs-git
    # emacs29
  ];
  # nixpkgs.overlays = [
  #   (import (builtins.fetchTarball {
  #     url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
  #     sha256 = "1c75fn31jvz74iq1a4vgiszy68rk5hh1l07cycj12hpir05xqwj0";
  #   }))
  # ];

  # Virtualizacija
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "david" ];

  programs.mtr.enable = true;

  # terminal greeter
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
        user = "david";
      };
    };
  };

  # https://www.reddit.com/r/NixOS/comments/u0cdpi/tuigreet_with_xmonad_how/
  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    # Without these bootlogs will spam on screen
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };

  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

  # sound
  sound.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    # maybe disable if VBOX has issues
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # useful envs
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    # NIXOS_OZONE_WL = "1";
  };

  # opengl
  hardware = {
    opengl.enable = true;
  };

  # power management
  powerManagement.enable = true;
  powerManagement.powertop.enable = true;

  # bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # flakes
  nix.settings.experimental-features = [
    "nix-command" "flakes"
  ];

  # swaylock
  security.pam.services.swaylock = {
    text = "auth include login";
  };
}
