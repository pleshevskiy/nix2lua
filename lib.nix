let
  inherit (builtins) isString isFloat isInt isBool isList isAttrs isNull;
  inherit (builtins) concatStringsSep filter mapAttrs attrValues;

  mkLuaRaw = raw: { _type = "raw"; inherit raw; };
  isLuaRaw = val: getType val == "raw";

  mkLuaNil = { _type = "nil"; };
  isLuaNil = val: getType val == "nil";

  mkNamedField = name: value: {
    _type = "table_field";
    name = validString name;
    value = toLua value;
  };
  isNamedField = val: getType val == "table_field";
  toLuaNamedField = name: value:
    if isNull value then null
    else "[${toLuaStr name}] = ${value}";

  toLua = val: toLuaInternal 0 val;

  toLuaInternal = depth: val:
    let nextDepth = depth + 1; in
    if isLuaNil val then "nil"
    else if isLuaRaw val then val.raw
    else if isNamedField val then
      if depth > 0 then toLuaNamedField val.name val.value
      else error "You cannot render table field at the top level"
    else if isAttrs val then toLuaTable nextDepth val
    else if isList val then toLuaList nextDepth val
    else if isString val then toLuaStr val
    else if isFloat val || isInt val then toString val
    else if isBool val then toLuaBool val
    else if isNull val then null
    else error "Value '${toString val}' is not supported";

  toLuaList = depth: val:
    wrapObj (excludeNull (map (toLuaInternal depth) val));

  toLuaTable = depth: val: toLuaInternal depth (attrValues (mapAttrs mkNamedField val));

  excludeNull = val: filter (v: !(isNull v)) val;

  wrapObj = val: "{ ${concatStringsSep ", " val} }";

  toLuaStr = val: "\"${validString val}\"";

  toLuaBool = val: if val then "true" else "false";

  getType = val: if isAttrs val && val ? _type then val._type else null;

  validString = value:
    if isString value then value
    else error "Value '${toString value}' is not a valid string";

  error = message: throw "[nix2lua] ${message}";
in
{
  inherit toLua;
  inherit mkLuaNil mkLuaRaw mkNamedField;
}
