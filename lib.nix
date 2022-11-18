let
  inherit (builtins) isString isFloat isInt isBool isList isAttrs isNull;
  inherit (builtins) concatStringsSep filter mapAttrs attrValues;

  mkLuaNil = { _type = "nil"; };
  isLuaNil = val: isAttrs val && val ? _type && val._type == "nil";

  toLua = val:
    if isLuaNil val then "nil"
    else if isAttrs val then toLuaDict val
    else if isList val then toLuaList val
    else if isString val then toLuaStr val
    else if isFloat val || isInt val then toString val
    else if isBool val then toLuaBool val
    else if isNull val then null
    else null;

  toLuaList = val:
    wrapObj (excludeNull (map toLua val));

  toLuaDict = val:
    let
      toDictItem = name: value:
        let luaValue = toLua value;
        in
        if isNull luaValue then null
        else "[${toLuaStr name}] = ${luaValue}";

      dictItems = excludeNull (attrValues (mapAttrs toDictItem val));
    in
    wrapObj dictItems;

  excludeNull = val: filter (v: !(isNull v)) val;

  wrapObj = val: "{ ${concatStringsSep ", " val} }";

  toLuaStr = val: "\"${val}\"";

  toLuaBool = val: if val then "true" else "false";


in
{
  inherit toLua;
  inherit mkLuaNil;
}
