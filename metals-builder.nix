{ pkgs, ... }:
{ version, outputHash }:

# based on https://github.com/gvolpe/nix-config/blob/2761969d7db588e2c839d613abe88dc9188c5ffa/home/programs/neovim-ide/update-metals.nix#L6
pkgs.stdenv.mkDerivation rec {
  pname = "metals";
  inherit version;

  deps = pkgs.stdenv.mkDerivation {
    inherit outputHash;
    name = "metals-deps-${version}";
    buildCommand = ''
      export COURSIER_CACHE=$(pwd)
      ${pkgs.coursier}/bin/cs fetch org.scalameta:metals_2.13:${version} \
        -r bintray:scalacenter/releases \
        -r sonatype:snapshots > deps
      mkdir -p $out/share/java
      cp -n $(< deps) $out/share/java/
    '';
    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
  };

  nativeBuildInputs = with pkgs; [ makeWrapper setJavaClassPath ];
  buildInputs = [ deps ];

  dontUnpack = true;

  extraJavaOpts = "-XX:+UseG1GC -XX:+UseStringDeduplication -Xss4m -Xms100m";

  installPhase = ''
    mkdir -p $out/bin

    makeWrapper ${pkgs.jre}/bin/java $out/bin/metals \
      --add-flags "${extraJavaOpts} -cp $CLASSPATH" \
      --append-flags "scala.meta.metals.Main"
  '';

  meta = with pkgs.lib; {
    homepage = "https://scalameta.org/metals/";
    license = licenses.asl20;
    description = "Work-in-progress language server for Scala";
    maintainers = with maintainers; [ fabianhjr tomahna ];
  };
}
