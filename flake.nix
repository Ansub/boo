{
  description = "Boo — a CLI for managing Ghostty + Zsh terminal themes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        boo = pkgs.callPackage ./package.nix { };
      in
      {
        packages = {
          default = boo;
          boo = boo;
        };
      }
    );
}
