let
  inherit (builtins) isString isFloat isInt isBool isList concatStringsSep;

  toLua = val:
    if isList val then toLuaList val
    else if isString val then toLuaStr val
    else if isFloat val || isInt val then toString val
    else if isBool val then toLuaBool val
    else "";

  toLuaList = val: "{ ${concatStringsSep ", " (map toLua val)} }";

  toLuaStr = val: "'${val}'";

  toLuaBool = val: if val then "true" else "false";
in
{
  inherit toLua;
}
