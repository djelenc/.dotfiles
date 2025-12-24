{ pkgs ? import <nixpkgs> { } }:

pkgs.writeShellApplication {
  name = "record-screen";
  runtimeInputs = with pkgs; [ wf-recorder ffmpeg coreutils gnugrep ];
  text = ''
    set -euo pipefail

    OUT="''${HOME}/Videos/''${USER}-$(date +'%Y-%m-%d-%H%M%S').mp4"

    if [ -e /dev/dri/renderD128 ] && ffmpeg -hide_banner -encoders 2>/dev/null | grep -q 'h264_vaapi'; then
      exec wf-recorder -f "$OUT" \
        -c h264_vaapi \
        -d /dev/dri/renderD128 \
        -F "scale_vaapi=w=1920:h=-2:format=nv12,fps=30" \
        -p qp=26
    else
      exec wf-recorder -f "$OUT" \
        -c libx264 \
        -F "scale=1920:-2,fps=30" \
        -p crf=28 -p preset=veryfast
    fi
  '';
}
