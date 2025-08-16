{ config, inputs, pkgs, pkgs-24_05, lib, userInfo, ... }: {
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.enable = true;

  # Plymouth logo
  boot.plymouth.enable = true;

  # Use latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.kernelPackages = pkgs.linuxPackages_6_14;

  # networking
  networking.hostName = "idea";
  networking.networkmanager.enable = true;

  # localization
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

  # Configure keymap
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Caps as ctrl and esc
  services.xremap = {
    withWlroots = true;
    userName = userInfo.user;
    config.modmap = [{
      name = "main remaps";
      remap.CapsLock = {
        held = "leftctrl";
        alone = "esc";
        alone_timeout_milis = 150;
      };
    }];
  };

  # automount USB and other removable media
  services.gvfs.enable = true;

  # Allow routing all traffic through VPN
  networking.firewall.checkReversePath = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # docker
  virtualisation.docker.enable = true;

  # virtualbox
  virtualisation.virtualbox = {
    host = {
      enable = true;
      # enableKvm = true;
      # addNetworkInterface = false;
    };
    guest = {
      enable = true;
      dragAndDrop = true;
      clipboard = true;
    };
  };

  # virt-manager
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = [ "david" ];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  users.extraGroups.vboxusers.members = [ userInfo.user ];

  imports = [
    ./hardware-configuration.nix
    ../modules/stylix.nix
    ../modules/regreet.nix
    ../modules/sops-nix.nix

    ../modules/oauth2ms-config.nix
  ];

  # user account
  users.users.${userInfo.user} = {
    isNormalUser = true;
    description = userInfo.name;
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    # packages = with pkgs; [ ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs pkgs-24_05 userInfo; };
    users.${userInfo.user} = import ./home.nix;
  };

  # System packages
  environment.systemPackages = with pkgs; [
    nh
    busybox
    wineWowPackages.waylandFull
    (import ../scripts/moss.nix { inherit pkgs config; })
  ];

  # ZSH
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];

  # Gnome-keyring: needed for remebering secrets (eg. nextcloud)
  services.gnome.gnome-keyring.enable = true;

  # hyprland (configured by HM)
  programs.hyprland.enable = true;
  programs.hyprland.package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  # yet another nix helper
  programs.nh.enable = true;
  programs.nh.flake = userInfo.dotFiles;

  # Did you read the comment?
  system.stateVersion = "24.05";

  # sound
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    wireplumber = {
      enable = true;
      extraConfig = {
        # Set sink priorities
        "20-priorities" = {
          # Bluetooth: highest priority
          "monitor.bluez.rules" = [{
            matches = [{ "node.name" = "~bluez_output.*"; }];
            actions = { update-props = { "priority.session" = 4000; }; };
          }];

          # ALSA sinks: prefer analog, de-prioritize HDMI
          "monitor.alsa.rules" = [
            # Prefer internal analog outputs
            {
              matches = [{ "alsa.id" = "*Analog*"; }];
              actions = { update-props = { "priority.session" = 3000; }; };
            }
            # De-prioritize all HDMI sinks so they never become default
            {
              matches = [{ "alsa.id" = "~HDMI*"; }];
              actions = { update-props = { "priority.session" = 500; }; };
            }
          ];
        };
      };
    };
  };

  # envs
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    GTK_USE_PORTAL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    # NIXOS_OZONE_WL = "1";
  };

  # opengl
  hardware.graphics.enable = true;

  # power management
  powerManagement.enable = true;
  powerManagement.powertop.enable = true;

  # bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General.Experimental = true;
  };
  services.blueman.enable = true;

  # flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # hyprlock
  security.pam.services.hyprlock = { };

  # printers
  services.printing.enable = true;
  services.avahi = {
    # network printers autodiscovery
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # FONTS
  # Allow installation of unfree corefonts package
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "corefonts" ];

  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      corefonts
      fantasque-sans-mono
      powerline-fonts
      # nerdfonts
      # nerd-font-patcher
      font-awesome
    ];
  };

  nix.settings = {
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys =
      [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };
}
