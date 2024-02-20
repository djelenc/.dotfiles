# help:
#  man configuration.nix(5) 
#  ‘nixos-help’

{ config, pkgs, lib, ... }:
{
  imports = [ 
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.david = {
    isNormalUser = true;
    description = "David";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
    shell = pkgs.fish;
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
    # neovim 
    bat
    emacs
    lf
    nix-index
    python3
    libreoffice-qt
    hunspell
    onlyoffice-bin
    hunspellDicts.en_US-large
    htop tree mtr dig wget curl 
    kitty
    rofi-wayland rofi-bluetooth rofi-power-menu
    brave
    jetbrains.pycharm-community-bin
    git
    cinnamon.nemo-with-extensions
    fishPlugins.bobthefisher fishPlugins.plugin-git fishPlugins.fzf-fish
    fzf
    brightnessctl
    waybar
    dunst
    libnotify
    wireplumber
    swww networkmanagerapplet waybar
    pavucontrol
    gsimplecal
    swaylock
    hyprnome
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;
  };
 

  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
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
    StandardError = "journal"; # Without this errors will spam on screen

    # Without these bootlogs will spam on screen
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  programs.fish.enable = true;

  # VirtualBox
  # virtualisation.virtualbox.host.enable = true;
  # users.extraGroups.vboxusers.members = [ "david" ];
  # virtualisation.virtualbox.host.enableExtensionPack = true;
  # virtualisation.virtualbox.guest.enable = true;
  # virtualisation.virtualbox.guest.x11 = true;

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
    NIXOS_OZONE_WL = "1";
  };

  # opengl
  hardware = {
    opengl.enable = true;
  };

  # XDG
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  # power management
  powerManagement.enable = true;
  powerManagement.powertop.enable = true;

  # bluetooth
  hardware.bluetooth.enable = true;

  # flakes
  nix.settings.experimental-features = [
    "nix-command" "flakes"
  ];

  # swaylock
  security.pam.services.swaylock = {
    text = ''
      auth include login
    '';
  };
}
