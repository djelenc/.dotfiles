{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.hyprland.wlMirror;
in
{
  # Temporary aspect-preserving mirroring. To remove it entirely, delete this
  # directory, its import in ../../default.nix and the enable line in home.nix.
  options.my.hyprland.wlMirror.enable = lib.mkEnableOption "the wl-mirror projector workaround";

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      home.packages = with pkgs; [
        wl-mirror
        procps
      ];
      wayland.windowManager.hyprland.extraLuaFiles.wl_mirror = ./projector_mirror.lua;
      my.hyprland.fallbackMonitor = lib.mkForce {
        output = "";
        mode = "preferred";
        position = "auto";
        scale = 1;
      };
    })

    (lib.mkIf (!cfg.enable) {
      # Also handles upgrading directly from the former always-on helper, which
      # has no config.unload cleanup. Match only this user's managed instances.
      home.activation.stopWlMirror = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run ${lib.getExe' pkgs.procps "pkill"} -u ${lib.escapeShellArg config.home.username} -f -- \
          '(^|/)wl-mirror .*--title hypr-projector-mirror:[^ ]+ eDP-1$' || true
      '';
    })
  ];
}
