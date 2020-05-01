local m_params = require("Module:paramètres")

local export = {}

--- Permet de ne charger qu’une seule fois les plages de scripts.
--- Ne pas utiliser directement, passer par la fonctions associées.
local script_ranges_cache = {}

-- Fonctions pour les modules --

-- Fonctions de chargement des données --

--- Retourne la liste de tous les blocs Unicode.
--- @return table La liste de tous les blocs Unicode.
function export.get_blocks()
  return mw.loadData("Module:données Unicode/data/blocks")
end

--- Retourne la liste de tous les scripts Unicode.
--- @return table La liste de tous les scripts Unicode.
function export.get_scripts()
  return mw.loadData("Module:données Unicode/data/scripts")
end

--- Retourne la liste des plages de tous les scripts Unicode.
--- @return table La liste des plages de tous les scripts Unicode.
function export.get_script_ranges()
  if next(script_ranges_cache) == nil then
    -- On en peut pas utiliser mw.loadData car les clés sont des tables.
    script_ranges_cache = require("Module:données Unicode/data/script ranges")
  end
  return script_ranges_cache
end

-- Fonctions pour les blocs --

--- Retourne le bloc Unicode correspondant à la valeur donnée.
--- @param lower_codepoint number La borne inférieure du bloc (point de code).
--- @return table|nil Le bloc ou nil si le code n’existe pas.
function export.get_block(lower_codepoint)
  return export.get_blocks()[lower_codepoint]
end

--- Retourne le bloc Unicode correspondant au caractère donné.
--- Lance une erreur si aucun caractère ou plusieurs sont passés.
--- @param char string Le caractère.
--- @return table|nil Le bloc ou nil si le caractère n’appartient à aucun bloc.
function export.get_block_for_char(char)
  local len = mw.ustring.len(char)
  if len ~= 1 then
    error(mw.ustring.format('Un seul caractère attendu, %d donnés ("%s")', len, char))
  end
  local code = mw.ustring.codepoint(char)

  for _, block in pairs(export.get_blocks()) do
    if block.lower <= code and code <= block.upper then
      return block
    end
  end

  return nil
end

-- Fonctions pour les scripts --

--- Retourne le script Unicode correspondant à la valeur donnée.
--- @param code string Le code du script.
--- @return table|nil Le script ou nil si le code n’existe pas.
function export.get_script(code)
  return export.get_scripts()[code]
end

--- Retourne le script Unicode correspondant au caractère donné.
--- Lance une erreur si aucun caractère ou plusieurs sont passés.
--- @param char string Le caractère.
--- @return table Le script.
function export.get_script_for_char(char)
  local len = mw.ustring.len(char)
  if len ~= 1 then
    error(mw.ustring.format("Un seul caractère attendu, %d donnés", len))
  end
  local code = mw.ustring.codepoint(char)
  local scripts = export.get_scripts()

  for range, script_code in pairs(export.get_script_ranges()) do
    if range[1] <= code and code <= range[2] then
      return scripts[script_code]
    end
  end

  return scripts["Unknown"]
end

--- Retourne le script Unicode correspondant au texte donné.
--- Si le texte est composé de caractères dans plusieurs scripts,
--- autres que Common ou Inherited, le script retourné est Common.
--- @param text string Le texte.
--- @return table Le script.
function export.get_script_for_text(text)
  local inherited_found = false
  local common_found = false
  local res

  for i = 1, mw.ustring.len(text) do
    local c = mw.ustring.sub(text, i, i)
    local script = export.get_script_for_char(c)
    local name = script.code

    if not common_found and name == "Common" then
      common_found = true
    elseif not inherited_found and name == "Inherited" then
      inherited_found = true
    elseif name ~= "Common" and name ~= "Inherited" then
      if res == nil or res.code == "Unknown" then
        res = script
      elseif res ~= nil and script.code ~= "Unknown" and script.code ~= res.code then
        return export.get_script("Common")
      end
    end
  end

  if res == nil then
    if inherited_found then
      return export.get_script("Inherited")
    elseif common_found then
      return export.get_script("Common")
    end
  end

  return res
end

--- Indique si le texte donné est dans le script donné.
--- @param text string Le texte.
--- @param scriptCode string Le code Unicode du script.
--- @return boolean Vrai si le code existe et que le texte est
---                 effectivement dans ce script, faux sinon.
function export.textHasScript(text, scriptCode)
  local script = export.get_script(scriptCode)
  return script ~= nil and export.get_script_for_text(text).code == script.code
end

local direction_to_css = {
  ["lr"] = "horizontal-tb",
  ["rl"] = "horizontal-tb",
  ["tb"] = "vertical-lr",
  ["i"] = "inherit",
  ["m"] = "inherit",
}

--- Définit le sens d’écriture pour le texte donné en l’incluant dans une balise span.
--- @param text string Le texte.
--- @return string Le text inclut dans le code HTML définissant le sens d’écriture.
function export.set_writing_mode_for_text(text)
  local script = export.get_script_for_text(text)
  return mw.ustring.format('<span style="writing-mode:%s">%s</span>', direction_to_css[script.direction or "i"], text)
end

-- Fonctions pour les modèles --

--- Retourne la référence du bloc Unicode donné.
---  frame.args[1] : Le code de la borne inférieure du bloc (entier).
---   Si ce paramètre n’est pas renseigné, le titre de la page sera utilisé.
--- @return string La référence vers le bloc.
function export.reference_bloc(frame)
  local params = {
    [1] = { type = "int" },
  }
  local args = m_params.process(frame.args, params)
  local block_code = args[1]
  local block

  if block_code ~= nil then
    block = export.get_block(block_code)
  else
    block = export.get_block_for_char(mw.title.getCurrentTitle().text)
  end

  if block ~= nil then
    return mw.ustring.format("Unicode, Inc., ''[%s %s]'', The Unicode Standard, version %s, %d",
        block.url, block.name.en, block.version, block.year)
  end

  error("Bloc Unicode incorrect")
end

--- Définit le sens d’écriture pour le texte donné.
---  frame.args[1] : Le texte.
--- @return string Le text inclut dans le code HTML définissant le sens d’écriture.
function export.sens_ecriture(frame)
  local params = {
    [1] = { required = true, allow_empty = true, }
  }
  local args = m_params.process(frame.args, params)
  return export.set_writing_mode_for_text(args[1])
end

--- Retourne le point de code Unicode du caractère donné.
---  frame.args[1] : Le caractère.
---  frame.args[2] : Booléen indiquant si le point de code doit être retourné en hexadécimal (défaut : false).
--- @return string|number Le point de code du caractère.
function export.point_de_code(frame)
  local params = {
    [1] = {
      required = true,
      checker = function(value)
        return mw.ustring.len(value) == 1
      end,
    },
    ["hexa"] = {
      type = "boolean",
      default = false,
    },
  }
  local args = m_params.process(frame.args, params)
  local char = args[1]
  local is_hex = args["hexa"]

  local code = mw.ustring.codepoint(char)
  if is_hex then
    return string.format("%04X", code)
  end
  return code
end

--- Retourne le caractère correspondant au point de code Unicode donné.
---  frame.args[1] : Le point de code (entier).
--- @return string Le caractère.
function export.caractere(frame)
  local params = {
    [1] = {
      required = true,
      type = "int",
    },
  }
  local args = m_params.process(frame.args, params)
  local code = tonumber(args[1])

  if code ~= nil then
    local success, char = pcall(mw.ustring.char, code)
    if success then
      return char
    end
  end

  error("Point de code incorrect")
end

return export
