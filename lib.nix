let
  inherit (builtins) isString isFloat isInt isBool isList isAttrs isNull;
  inherit (builtins) concatStringsSep filter mapAttrs attrValues;

  mkLuaNil = { _type = "nil"; };
  isLuaNil = val: getType val == "nil";

  mkDictItem = name: value: {
    _type = "dict_item";
    name = validString name;
    value = toLua value;
  };
  isDictItem = val: getType val == "dict_item";
  toLuaDictItem = name: value:
    if isNull value then null
    else "[${toLuaStr name}] = ${value}";

  toLua = val:
    if isLuaNil val then "nil"
    else if isDictItem val then toLuaDictItem val.name val.value
    else if isAttrs val then toLuaDict val
    else if isList val then toLuaList val
    else if isString val then toLuaStr val
    else if isFloat val || isInt val then toString val
    else if isBool val then toLuaBool val
    else if isNull val then null
    else throw "[nix2lua] Value '${toString val}' is not supported";

  toLuaList = val:
    wrapObj (excludeNull (map toLua val));

  toLuaDict = val: toLua (attrValues (mapAttrs mkDictItem val));

  excludeNull = val: filter (v: !(isNull v)) val;

  wrapObj = val: "{ ${concatStringsSep ", " val} }";

  toLuaStr = val: "\"${validString val}\"";

  toLuaBool = val: if val then "true" else "false";

  getType = val: if isAttrs val && val ? _type then val._type else null;

  validString = value:
    if isString value then value
    else throw "[nix2lua] Value '${toString value}' is not a valid string";
in
{
  inherit toLua;
  inherit mkLuaNil mkDictItem;
}
