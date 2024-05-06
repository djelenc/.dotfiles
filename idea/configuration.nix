{ config, inputs, pkgs, lib, ... }: {
  imports = [
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.default
    inputs.xremap-flake.nixosModules.default
    inputs.nixvim.nixosModules.nixvim
    ../modules/nixvim.nix
    ../modules/fish.nix
  ];

  dotFilesRoot = "/home/david/.dotfiles";

  home-manager.backupFileExtension = "backup";

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
    extraSpecialArgs = { inherit inputs; };
    users = { "david" = import ./home.nix; };
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
    nixfmt
    firefox
    lf
    nix-index
    python3
    libreoffice-qt
    onlyoffice-bin
    hunspell
    hunspellDicts.en_US-large
    htop
    tree
    jq
    dig
    wget
    curl
    fuzzel
    rofi-wayland
    rofi-power-menu
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
    swww
    xarchiver
    pavucontrol
    vscodium.fhs
    vlc
    fontpreview
    wlsunset
    # inputs.anyrun.packages.${system}.anyrun
  ];

  # force brave to run under wayland
  nixpkgs.overlays = [
    (self: super: {
      brave = super.brave.override {
        commandLineArgs =
          "--enable-features=UseOzonePlatform --ozone-platform=wayland";
      };
    })
  ];

  # Virtualizacija
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "david" ];

  programs.mtr.enable = true;

  # terminal greeter
  # programs.regreet.enable = true; # GUI login -- dela le, ce rocno vpises sejo
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command =
          "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
        user = "david";
      };
    };
  };
  # izgleda brez efekta na nextcloud
  security.pam.services.greetd.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;

  # https://www.reddit.com/r/NixOS/comments/u0cdpi/tuigreet_with_xmonad_how/
  # systemd.services.greetd.serviceConfig = {
  #   Type = "idle";
  #   StandardInput = "tty";
  #   StandardOutput = "tty";
  #   StandardError = "journal";
  #   # Without these bootlogs will spam on screen
  #   TTYReset = true;
  #   TTYVHangup = true;
  #   TTYVTDisallocate = true;
  # };

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
