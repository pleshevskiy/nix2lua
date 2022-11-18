{ pkgs ? import <nixpkgs> { } }:

let
  nix2lua = import ./lib.nix;
  inherit (nix2lua) toLua mkLuaNil;
in
pkgs.lib.runTests {
  "test returns null" = {
    expr = toLua null;
    expected = null;
  };
  "test returns nil" = {
    expr = toLua mkLuaNil;
    expected = "nil";
  };
  "test returns a lua string" = {
    expr = toLua "hello world";
    expected = "\"hello world\"";
  };
  "test returns an integer number" = {
    expr = toLua 10;
    expected = "10";
  };
  "test returns a negative integer number" = {
    expr = toLua (-10);
    expected = "-10";
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
    expected = "{ \"hello\", 10, 10.100000, true }";
  };
  "test returns array without null values" = {
    expr = toLua [ null "hello" null 10 null 10.1 null true null ];
    expected = "{ \"hello\", 10, 10.100000, true }";
  };
  "test returns dict" = {
    expr = toLua {
      foo = "hello";
      int = 10;
      float = 10.1;
      success = true;
      fail = false;
    };
    expected = "{ [\"fail\"] = false, [\"float\"] = 10.100000, [\"foo\"] = \"hello\", [\"int\"] = 10, [\"success\"] = true }";
  };
  "test returns dict without nullable items" = {
    expr = toLua { foo = "hello"; bar = null; };
    expected = "{ [\"foo\"] = \"hello\" }";
  };
  "test returns recursive dict" = {
    expr = toLua {
      first = {
        second = {
          last = "hello";
        };
      };
    };
    expected = "{ [\"first\"] = { [\"second\"] = { [\"last\"] = \"hello\" } } }";
  };
}
