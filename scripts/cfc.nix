{ pkgs, ... }:
let scriptContents = builtins.readFile ./cfc.sh;
in pkgs.writeShellScriptBin "cfc" scriptContents
