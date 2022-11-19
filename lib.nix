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
let
  inherit (builtins) isString isFloat isInt isBool isList isAttrs isNull isPath;
  inherit (builtins) concatStringsSep filter mapAttrs attrValues;

  mkLuaRaw = raw: { _type = "raw"; inherit raw; };
  isLuaRaw = expr: getType expr == "raw";

  mkLuaNil = { _type = "nil"; };
  isLuaNil = expr: getType expr == "nil";

  mkNamedField = name: expr: {
    _type = "table_field";
    name = validString name;
    value = toLua expr;
  };
  isNamedField = expr: getType expr == "table_field";
  toLuaNamedField = name: expr:
    if isNull expr then null
    else "[${toLuaStr name}] = ${expr}";

  toLua = val: toLuaInternal 0 val;

  toLuaInternal = depth: expr:
    let nextDepth = depth + 1; in
    if isLuaNil expr then "nil"
    else if isLuaRaw expr then expr.raw
    else if isNamedField expr then
      if depth > 0 then toLuaNamedField expr.name expr.value
      else error "You cannot render table field at the top level"
    else if isAttrs expr then toLuaTable nextDepth expr
    else if isList expr then toLuaList nextDepth expr
    else if isString expr || isPath expr then toLuaStr expr
    else if isFloat expr || isInt expr then toString expr
    else if isBool expr then toLuaBool expr
    else if isNull expr then null
    else error "Value '${toString expr}' is not supported yet";

  toLuaList = depth: expr:
    wrapObj (excludeNull (map (toLuaInternal depth) expr));

  toLuaTable = depth: expr: toLuaInternal depth (attrValues (mapAttrs mkNamedField expr));

  excludeNull = expr: filter (v: !(isNull v)) expr;

  wrapObj = expr: "{ ${concatStringsSep ", " expr} }";

  toLuaStr = expr: "\"${validString expr}\"";

  toLuaBool = expr: if expr then "true" else "false";

  getType = expr: if isAttrs expr && expr ? _type then expr._type else null;

  validString = expr:
    if isString expr || isPath expr then toString expr
    else error "Value '${toString expr}' is not a valid string";

  error = message: throw "[nix2lua] ${message}";
in
{
  inherit toLua;
  inherit mkLuaNil mkLuaRaw mkNamedField;
}
