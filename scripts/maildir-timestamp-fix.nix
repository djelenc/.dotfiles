{ pkgs, ... }:
let scriptContents = builtins.readFile ./maildir-timestamp-fix.sh;
in pkgs.writeShellScriptBin "maildir-timestamp-fix" scriptContents
