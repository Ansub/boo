{ lib, stdenvNoCC, makeWrapper, bash, coreutils, gnused, gnugrep, gawk, findutils }:

stdenvNoCC.mkDerivation {
  pname = "boo";
  version = "0-unstable";

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./bin
      ./art
      ./themes
      ./shell
      ./configs
      ./scripts
    ];
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    # Preserve repo layout at $out so bin/boo's fallback paths
    # (../themes, ../art, ../shell, ../configs) resolve correctly
    mkdir -p $out/bin
    cp -r art themes shell configs scripts $out/

    install -Dm755 bin/boo $out/bin/boo
    wrapProgram $out/bin/boo \
      --prefix PATH : ${lib.makeBinPath [ bash coreutils gnused gnugrep gawk findutils ]}

    runHook postInstall
  '';

  meta = {
    description = "CLI for managing Ghostty + Zsh terminal themes, fonts, and splash art";
    homepage = "https://github.com/Ansub/boo";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "boo";
  };
}
