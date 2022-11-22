{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    {
      lib = import ./lib.nix;
    }
    // flake-utils.lib.eachDefaultSystem (system:
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
