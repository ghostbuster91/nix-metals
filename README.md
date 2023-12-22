# Nix metals

![ci-badge](https://img.shields.io/static/v1?label=Built%20with&message=nix&color=blue&style=flat&logo=nixos&link=https://nixos.org&labelColor=111212)
[![built with garnix](https://img.shields.io/endpoint?url=https%3A%2F%2Fgarnix.io%2Fapi%2Fbadges%2Fghostbuster91%2Fnix-metals%3Fbranch%3Dstable)](https://garnix.io)

Expose metals as a nix derivation

## Usage

Add to your inputs:

```nix
nix-metals = {
  url = "github:ghostbuster91/nix-metals/stable";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

(or use `nightly` branch if you would like to use snapshot versions)

Configure your editor to use provided metals package.

Example for neovim:

```lua
metals_config.settings = {
    metalsBinaryPath = binaries.metals_binary_path,
    showImplicitArguments = true,
    superMethodLensesEnabled = false,
    excludedPackages = {
        "akka.actor.typed.javadsl",
        "com.github.swagger.akka.javadsl",
    },
    enableSemanticHighlighting = false,
}
```

where `metals_binary_path` is set to:

```nix
"${nix-metals.packages.${system}.metals}/bin/metals",
```
