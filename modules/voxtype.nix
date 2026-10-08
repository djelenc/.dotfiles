{ pkgs, ... }:

{
  # Offline dictation with Whisper; Vulkan accelerates inference on the AMD iGPU.
  services.voxtype = {
    enable = true;
    package = pkgs.voxtype-vulkan;
    loadModels = [ "large-v3-turbo" ];

    settings = {
      # Hyprland owns the hotkey, so Voxtype needs no evdev/input-group access.
      hotkey.enabled = false;
      state_file = "auto"; # Required for `voxtype record toggle`.

      whisper = {
        model = "large-v3-turbo";
        language = [ "sl" "en" ];
      };

      output = {
        mode = "paste";
        # Ctrl+V reads the regular CLIPBOARD selection in browsers and GUI apps.
        # Shift+Insert can read PRIMARY (old selected text) instead.
        paste_keys = "ctrl+v";
        # Keep the transcript on the clipboard for inspection and manual paste.
        restore_clipboard = false;
        notification.on_recording_start = true;
      };
    };
  };
}
