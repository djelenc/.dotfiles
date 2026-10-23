{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Directory containing encrypted NetworkManager profiles
  dir = ../secrets/wireguard;

  entries = builtins.readDir dir;

  # Discover encrypted profiles
  files = builtins.filter (
    name: entries.${name} == "regular" && lib.hasSuffix ".nmconnection.enc" name
  ) (builtins.attrNames entries);

  # Use unique filenames for the managed runtime profiles.
  outputName = file: "nixos-wg-" + lib.removeSuffix ".nmconnection.enc" file + ".nmconnection";

  # Check that SOPS has decrypted each file.
  checkSecrets = lib.concatMapStringsSep "\n" (file: ''
    test -r ${lib.escapeShellArg config.sops.secrets.${file}.path}
  '') files;

  # Install decrypted profiles with root-only permissions.
  installProfiles = lib.concatMapStringsSep "\n" (file: ''
    ${pkgs.coreutils}/bin/install \
      -o root -g root -m 0600 \
      ${lib.escapeShellArg config.sops.secrets.${file}.path} \
      "$dir"/${lib.escapeShellArg (outputName file)}
  '') files;

in
{
  # Every encrypted file becomes one SOPS binary secret.
  sops.secrets = lib.genAttrs files (file: {
    sopsFile = dir + "/${file}";
    format = "binary";

    restartUnits = [
      "nm-wireguard-profiles.service"
    ];
  });

  systemd.services.nm-wireguard-profiles = {
    description = "Install encrypted NetworkManager profiles";

    wantedBy = [ "multi-user.target" ];
    requires = [ "NetworkManager.service" ];

    after = [
      "NetworkManager.service"
      "sops-install-secrets.service"
    ];

    restartTriggers = map (file: dir + "/${file}") files;

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      set -eu

      dir=/run/NetworkManager/system-connections

      ${checkSecrets}

      ${pkgs.coreutils}/bin/install \
        -d -o root -g root -m 0700 "$dir"

      # Clean up previously managed files.
      for old in "$dir"/nixos-wg-*.nmconnection; do
        [ -e "$old" ] || continue
        rm -- "$old"
      done

      # Install the decrypted profiles.
      ${installProfiles}

      # Tell NetworkManager to re-read connection files.
      ${pkgs.networkmanager}/bin/nmcli connection reload
    '';
  };
}
