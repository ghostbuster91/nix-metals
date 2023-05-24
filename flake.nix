{
  description = "Smithy Language Server";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.11";
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          metalsBuilder = import ./metals-builder.nix { inherit pkgs; };
          metalsLock = import ./metals-lock.nix;
        in
        {
          packages = {
            metals = metalsBuilder {
              inherit (metalsLock) version outputHash;
            };
            update-metals = import ./update-metals.nix { inherit pkgs; isRelase = true; };
            update-metals-snapshot = import ./update-metals.nix { inherit pkgs; isRelase = false; };
          };
        }
      );
}
