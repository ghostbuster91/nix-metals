{ pkgs, ... }:
{ version, outputHash }:

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
      --add-flags "${extraJavaOpts} \$NIX_METALS_RUNTIME_ARGS -cp $CLASSPATH scala.meta.metals.Main"
  '';

  meta = with pkgs.lib; {
    homepage = "https://scalameta.org/metals/";
    license = licenses.asl20;
    description = "Work-in-progress language server for Scala";
    maintainers = with maintainers; [ fabianhjr tomahna ];
  };
}
