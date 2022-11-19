# nix2lua

This is a small but functional library that converts your nix configurations
into lua format.

This library was initially designed for my personal
[neovim flake](https://git.pleshevski.ru/mynix/neovim).

# Installation

Add nix2lua as input to your flake.nix

```nix
{
  inputs.nix2lua.url = "git+https://git.pleshevski.ru/mynix/nix2lua";
  
  outputs = { nix2lua }:
    let
      luaTable = nix2lua.lib.toLua {
        foo = "bar";

        nvimTree.settings = {
          open_on_setup = true;
          renderer = {
            group_empty = true;
            full_name = true;
          };
        };
      };
    in luaTable;
}
```

# References

`toLua expr`

> Returns a string containing Lua representation of `expr`. Strings, integers,
> floats, booleans, lists and sets are mapped to their Lua equivalents.
>
> Null will be skipped. This is useful when you want to use an optional value.
> To render `nil` you should use the `mkLuaNil` function.
>
> ```nix
> toLua { foo = "bar"; }
> toLua [ 10 "foo" [ "bar" ] ]
> ```

`mkLuaNil expr`

> Creates a type that will mapped by the `toLua` as `nil`
>
> ```nix
> toLua mkLuaNil
> ```

`mkLuaRaw expr`

> Creates a type that instructs `toLua` not to change the passed expression
> `expr`.
>
> ```nix
> toLua (mkLuaRaw "require('bar').baz")
> ```

`mkNamedField name expr`

> Creates a type that represents a named field in the lua table. This type
> cannot exist outside of a list or set.
>
> This is usefull to create table with some named fields.
>
> ```nix
> toLua [
>   "foo"
>   (mkNamedField "bar" "baz")
> ]
> ```

# License

GNU General Public License v3.0 or later

See [COPYING](./COPYING) to see the full text.
