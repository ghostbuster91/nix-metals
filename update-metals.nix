{ pkgs, ... }:
let
  cl = "${pkgs.curl}/bin/curl";
  rg = "${pkgs.ripgrep}/bin/rg";
  file = "metals-lock.nix";
  name = "metals-updater-script";
  jq = "${pkgs.jq}/bin/jq";

  src = pkgs.writeShellScript name ''
    NEW=$(${cl} https://scalameta.org/metals/latests.json | ${jq} ".release" | awk -F '"' '{print $2}')
    OLD=$(awk -F'"' '/"version" = /{print $4}' ${file})

    echo "Old version: $OLD"
    echo "New version: $NEW"

    if [ "$NEW" != "$OLD" ]; then
      echo "Updating metals"
      sed -i "s/$OLD/$NEW/g" ${file}

      nix build .#metals 2> build-result

      OLD_HASH=$(cat build-result | ${rg} specified: | awk -F ':' '{print $2}' | sed 's/ //g')
      NEW_HASH=$(cat build-result | ${rg} got: | awk -F ':' '{print $2}' | sed 's/ //g')

      echo "Old hash: $OLD_HASH"
      echo "New hash: $NEW_HASH"

      rm build-result

      sed -i "s|$OLD_HASH|$NEW_HASH|g" ${file}

      echo "metals_version=$NEW" >> $GITHUB_OUTPUT
    else
      echo "Versions are identical, aborting."
    fi
  '';
in
pkgs.stdenv.mkDerivation
{
  inherit name src;

  phases = [ "installPhase" "patchPhase" ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/${name}
    chmod +x $out/bin/${name}
  '';
}
