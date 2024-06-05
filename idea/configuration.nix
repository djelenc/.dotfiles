{ config, inputs, pkgs, lib, unstable-pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix

    inputs.home-manager.nixosModules.default
    inputs.xremap-flake.nixosModules.default

    ../modules/fish.nix
    ../modules/stylix.nix
  ];

  dotFilesRoot = "/home/david/.dotfiles";

  # rebinds caps to ctrl and esc
  services.xremap = {
    withWlroots = true;
    userName = "david";
    config = {
      modmap = [{
        name = "main remaps";
        remap = {
          CapsLock = {
            held = "leftctrl";
            alone = "esc";
            alone_timeout_milis = 150;
          };
        };
      }];
    };
  };

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.kernelPackages = pkgs.linuxPackages_6_8;

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

  # To allow routing all traffic through VPN
  networking.firewall.checkReversePath = false;

  # user account
  users.users.david = {
    isNormalUser = true;
    description = "David";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [ ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs; };
    users.david = import ./home.nix;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Allow installation of unfree corefonts package
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "corefonts" ];

  fonts.packages = with pkgs; [
    corefonts
    fantasque-sans-mono
    powerline-fonts
    nerdfonts
    nerd-font-patcher
    font-awesome
  ];
  fonts.fontDir.enable = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    bat
    nh
    htop
    tree
    jq
    dig
    wget
    curl
    git
    mesa
  ];

  # Virtualizacija
  # virtualisation.virtualbox.host.enable = true;
  # virtualisation.virtualbox.host.package = unstable-pkgs.virtualbox;
  # virtualisation.virtualbox.host.enableExtensionPack = true;
  # virtualisation.virtualbox.host.enableKvm = true;
  # virtualisation.virtualbox.host.enableHardening = false;
  # virtualisation.virtualbox.host.addNetworkInterface = false;
  # virtualisation.virtualbox.guest.enable = true;
  # virtualisation.virtualbox.guest.draganddrop = true;
  # virtualisation.virtualbox.guest.clipboard = true;
  # users.extraGroups.vboxusers.members = [ "david" ];

  programs.mtr.enable = true;

  # Enables gnome-keyring: needed for remebering secrets (eg. nextcloud)
  services.gnome.gnome-keyring.enable = true;

  # Regreet login-manager
  programs.regreet.enable = true;

  # hyprland -- configured by HM (only to make it show in the login-manager)
  programs.hyprland.enable = true;
  programs.hyprland.package = inputs.hyprland.packages.${pkgs.system}.hyprland;

  # yet another nix helper
  programs.nh.enable = true;
  programs.nh.flake = config.dotFilesRoot;

  # Did you read the comment?
  system.stateVersion = "24.05";

  # sound
  sound.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
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
  hardware = { opengl.enable = true; };

  # power management
  powerManagement.enable = true;
  powerManagement.powertop.enable = true;

  # bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # swaylock
  security.pam.services.swaylock = { text = "auth include login"; };
}
