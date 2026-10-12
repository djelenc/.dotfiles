{
  pkgs,
  ...
}:
{
  # TEMPORARY WORKAROUND
  #
  # Purpose:
  #   Mirror eDP-1 to temporary/unknown projectors while preserving aspect ratio
  #   and using black letterboxing/pillarboxing instead of Hyprland native mirror.
  #
  # Why:
  #   Hyprland native output mirroring currently does not provide the desired
  #   aspect-preserving letterboxed behavior for mismatched outputs.
  #
  # To remove this workaround once Hyprland supports it natively:
  #   1. Remove ./projector-mirror.nix from imports in default.nix.
  #   2. In config.nix, restore `mirror = "eDP-1";` to the fallback monitor.
  #   3. Remove the clearly marked projector-mirror exclusion in lua/binds.lua.
  #
  # No other Hyprland configuration should need changing.

  home.packages = with pkgs; [
    wl-mirror
    procps # pkill used to stop a per-output wl-mirror instance
  ];

  wayland.windowManager.hyprland = {
    extraLuaFiles.projector_mirror = ./lua/projector_mirror.lua;

    settings.config.binds = {
      # The wl-mirror window is pinned so it remains visible while linked
      # workspaces are switched on the other monitors.
      allow_pin_fullscreen = true;
    };
  };
}
