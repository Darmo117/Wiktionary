local data = require("Module:données Unicode")
local p = {}

--- Indique si une chaine de caractères est vide ou nulle.
--- @param s string : la chaine à tester
--- @return boolean
local function is_empty(s)
  return s == "" or s == nil
end

--- Retourne la référence du bloc Unicode donné.
---  frame.args[1] : La borne inférieure du bloc en hexadécimal (avec ou sans préfixe 0x).
function p.reference_bloc(frame)
  local success, id = pcall(tonumber, frame.args[1], 16)

  if not success or id == nil then
    return "&lt;''Veuillez renseigner un bloc Unicode !''&gt;"
  end

  local block = data.blocs()[id]
  if block ~= nil then
    return mw.ustring.format("Unicode, Inc., ''[%s %s]'', The Unicode Standard, version %s, %s",
        block.url, block.name.en, block.version, block.year)
  end

  return "&lt;''Veuillez renseigner un bloc Unicode correct !''&gt;"
end

--- Retourne le point de code Unicode du caractère donné.
---  frame.args[1] : Le caractère.
---  frame.args[2] : Une valeur non vide et non nulle indique que la valeur retournée doit être en hexadécimal.
function p.point_de_code(frame)
  local char = frame.args[1]

  if is_empty(char) then
    return "&lt;''Veuillez renseigner un caractère !''&gt;"
  elseif mw.ustring.len(char) ~= 1 then
    return "&lt;''Veuillez renseigner un seul caractère !''&gt;"
  end

  local code = mw.ustring.codepoint(char)
  if not is_empty(frame.args[2]) then
    return string.format("%04X", code)
  end
  return code
end

--- Retourne le caractère correspondant au point de code Unicode donné.
---  frame.args[1] : Le point de code.
---  frame.args[2] : La base du nombre (défaut : 10).
function p.caractere(frame)
  local ok, base = pcall(tonumber, not is_empty(frame.args[2]) and frame.args[2] or 10)

  if ok and base ~= nil and 2 <= base and base <= 36 then
    local code = tonumber(frame.args[1], base)

    if code ~= nil then
      local success, char = pcall(mw.ustring.char, code)
      if success then
        return char
      end
    end

    return "&lt;''Point de code incorrect !''&gt;"
  end

  return "&lt;''Base incorrecte !''&gt;"
end

return p
