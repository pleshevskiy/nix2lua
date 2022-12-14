/**
 * Copyright (C) 2022, Dmitriy Pleshevskiy <dmitriy@pleshevski.ru>
 *
 * nix2lua is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * nix2lua is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with nix2lua.  If not, see <https://www.gnu.org/licenses/>.
 */
{ pkgs ? import <nixpkgs> { } }:

let
  nix2lua = import ./lib.nix;
  inherit (nix2lua) toLua mkLuaNil mkLuaRaw mkNamedField;
  inherit (builtins) tryEval;

  failed = { success = false; value = false; };
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
  "test returns table with all primitive types" = {
    expr = toLua [ "hello" 10 10.1 true ];
    expected = "{ \"hello\", 10, 10.100000, true }";
  };
  "test returns table without null values" = {
    expr = toLua [ null "hello" null 10 null 10.1 null true null ];
    expected = "{ \"hello\", 10, 10.100000, true }";
  };
  "test returns named table" = {
    expr = toLua {
      foo = "hello";
      int = 10;
      float = 10.1;
      success = true;
      fail = false;
    };
    expected = "{ [\"fail\"] = false, [\"float\"] = 10.100000, [\"foo\"] = \"hello\", [\"int\"] = 10, [\"success\"] = true }";
  };
  "test returns named table without nullable items" = {
    expr = toLua { foo = "hello"; bar = null; };
    expected = "{ [\"foo\"] = \"hello\" }";
  };
  "test returns recursive named table" = {
    expr = toLua {
      first = {
        second = {
          last = "hello";
        };
      };
    };
    expected = "{ [\"first\"] = { [\"second\"] = { [\"last\"] = \"hello\" } } }";
  };
  "test return recursive table" = {
    expr = toLua [ [ [ "foo" ] "bar" ] ];
    expected = "{ { { \"foo\" }, \"bar\" } }";
  };
  "test returns table with one named field" = {
    expr = toLua [
      "foo"
      (mkNamedField "foo" "hello")
      10
    ];
    expected = "{ \"foo\", [\"foo\"] = \"hello\", 10 }";
  };
  "test returns raw string" = {
    expr = toLua (mkLuaRaw "hello");
    expected = "hello";
  };
  "test returns path as string" = {
    expr = toLua /foo/bar;
    expected = "\"/foo/bar\"";
  };
  "test throws an error when you try to use named field withoun table" = {
    expr = tryEval (toLua (mkNamedField "foo" "bar"));
    expected = failed;
  };
}
