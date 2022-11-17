{ pkgs ? import <nixpkgs> { } }:

let
  nix2lua = import ./lib.nix;
  inherit (nix2lua) toLua;
in
pkgs.lib.runTests {
  "test returns an empty string" = {
    expr = toLua null;
    expected = "";
  };
  "test returns a lua string" = {
    expr = toLua "hello world";
    expected = "'hello world'";
  };
  "test returns an integer number" = {
    expr = toLua 10;
    expected = "10";
  };
  "test returns a float number" = {
    expr = toLua 10.1;
    expected = "10.100000";
  };
  "test returns true" = {
    expr = toLua true;
    expected = "true";
  };
  "test returns false" = {
    expr = toLua false;
    expected = "false";
  };
  "test returns array with all primitive types" = {
    expr = toLua [ "hello" 10 10.1 true ];
    expected = "{ 'hello', 10, 10.100000, true }";
  };
}
