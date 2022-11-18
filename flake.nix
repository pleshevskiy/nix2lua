{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        runTests = pkgs.writeShellScript "runTests" ''
          nix eval --impure --expr 'import ./lib.test.nix {}'
        '';
      in
      {
        apps.tests = {
          type = "app";
          program = toString runTests;
        };
      });
}