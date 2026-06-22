{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  xz,
  fontconfig,
}:

let
  version = "0.2.0";

  cli = fetchurl {
    url = "https://github.com/gianlucasb/hallucinator/releases/download/v${version}/hallucinator-cli-x86_64-unknown-linux-gnu.tar.xz";
    hash = "sha256-Nr+UqT1BzShRQfP5NpBBYjEU8/3JfCTk+aXqCgG9Cbo=";
  };

  tui = fetchurl {
    url = "https://github.com/gianlucasb/hallucinator/releases/download/v${version}/hallucinator-tui-x86_64-unknown-linux-gnu.tar.xz";
    hash = "sha256-iqUni88kWZuXvHhRMcKyAuyQPXV0NgmZ2dSFLZ/yX6s=";
  };
in
stdenv.mkDerivation {
  pname = "hallucinator-bin";
  inherit version;

  srcs = [
    cli
    tui
  ];

  nativeBuildInputs = [
    autoPatchelfHook
    xz
  ];

  buildInputs = [
    fontconfig
    stdenv.cc.cc.lib
  ];

  unpackPhase = ''
    runHook preUnpack

    for src in $srcs; do
      tar -xf "$src"
    done

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    install -Dm755 "$(find . -type f -name hallucinator-cli -print -quit)" \
      "$out/bin/hallucinator-cli"

    install -Dm755 "$(find . -type f -name hallucinator-tui -print -quit)" \
      "$out/bin/hallucinator-tui"

    runHook postInstall
  '';

  meta = {
    description = "Detect potentially hallucinated or fabricated references in academic PDF papers";
    homepage = "https://github.com/gianlucasb/hallucinator";
    license = lib.licenses.agpl3Plus;
    platforms = [ "x86_64-linux" ];
    mainProgram = "hallucinator-tui";
  };
}
