local m_debug = require("Module:debug")

local export = {}

-- Fonction permettant d’échapper les caractères réservés de regex dans une chaine.
-- Caractères concernés : ^$()%.[]*+-?
local escape = require("Module:string").pattern_escape

-- Fonction permettant de supprimer les indices numériques vides dans une table.
local remove_holes = require("Module:table").compressSparseArray

local function extract_parameters(declared_parameters)
  local args_new = {}
  local required = {}
  local patterns = {}
  local list_from_index

  for name, param in pairs(declared_parameters) do
    if param.required then
      if param.alias_of then
        m_debug.track("parameters/required alias")
      end
      required[name] = true
    end

    if param.list then
      local key = name
      if type(name) == "string" then
        key = string.gsub(name, "=", "")
      end
      if param.default ~= nil then
        args_new[key] = { param.default, maxindex = 1 }
      else
        args_new[key] = { maxindex = 0 }
      end

      if type(param.list) == "string" then
        -- Si la propriété list est une chaine elle représente le nom à
        -- utiliser pour préfixer les items de la liste. Elle est utile
        -- pour les listes dont le premier paramètre est un indice numérique
        -- et les suivants sont nommés (ex : 1, pl2, pl3).
        if string.find(param.list, "=") then
          patterns["^" .. string.gsub(escape(param.list), "=", "(%%d+)") .. "$"] = name
        else
          patterns["^" .. escape(param.list) .. "(%d+)$"] = name
        end
      elseif type(name) == "number" then
        -- Si le nom est un nombre, tous les autres paramètres indexé
        -- à partir de ce point vont dans la liste.
        list_from_index = name
      else
        if string.find(name, "=") then
          patterns["^" .. string.gsub(escape(name), "=", "(%%d+)") .. "$"] = string.gsub(name, "=", "")
        else
          patterns["^" .. escape(name) .. "(%d+)$"] = name
        end
      end

      if string.find(name, "=") then
        m_debug.track("parameters/name with equals")
        declared_parameters[string.gsub(name, "=", "")] = declared_parameters[name]
        declared_parameters[name] = nil
      end
    elseif param.default ~= nil then
      args_new[name] = param.default
    end
  end

  return args_new, required, patterns, list_from_index
end

local function process_parameters(args, list_from_index, patterns, declared_parameters, return_unknown_parameters, required, args_new)
  local args_unknown = {}

  for name, val in pairs(args) do
    local index

    if type(name) == "number" then
      if list_from_index ~= nil and name >= list_from_index then
        index = name - list_from_index + 1
        name = list_from_index
      end
    else
      -- Est-ce que ce paramètre correspond à la regex ?
      for pattern, pname in pairs(patterns) do
        index = mw.ustring.match(name, pattern)

        -- S’il correspond on conserve le nom et
        -- l’indice numérique extrait du nom.
        if index then
          index = tonumber(index)
          name = pname
          break
        end
      end
    end

    -- Si aucun indice n’a été trouvé, utiliser 1 comme valeur par défaut.
    -- Cela donne une liste de paramètres du type g, g2, g3 avec g à l’indice 1.
    index = index or 1

    local param = declared_parameters[name]

    -- Si l’argument n’est pas dans la liste des paramètres,
    -- lancer une erreur (si return_unknown_parameters est faux).
    if not param then
      if return_unknown_parameters then
        args_unknown[name] = val
      else
        error("Le paramètre « " .. name .. " » n’est pas utilisé par ce modèle.", 2)
      end
    else
      if not param.allow_whitespace then
        val = mw.text.trim(val)
      end

      if val == "" and not param.allow_empty then
        val = nil
      end

      if param.type == "boolean" then
        val = not (not val or val == "" or val == "0" or val == "no" or val == "n" or val == "false")
      elseif param.type == "number" then
        val = tonumber(val)
      elseif param.type then
        m_debug.track {
          "parameters/unrecognized type",
          "parameters/unrecognized type/" .. tostring(param.type)
        }
      end

      if val ~= nil then
        -- Marquer le paramètre comme n’étant plus requis,
        -- puisqu’il est présent.
        required[param.alias_of or name] = nil

        -- Stockage de la valeur du paramètre.
        if param.list then
          -- Si le paramètre est un alias, le stocker avec le nom de base
          -- sans l’écraser : le nom de base est prioritaire.
          if not param.alias_of then
            args_new[name][index] = val
            -- Stockage du plus haut indice trouvé.
            args_new[name].maxindex = math.max(index, args_new[name].maxindex)
          elseif args[param.alias_of] == nil then
            if declared_parameters[param.alias_of] and declared_parameters[param.alias_of].list then
              args_new[param.alias_of][index] = val
              -- Stockage du plus haut indice trouvé.
              args_new[param.alias_of].maxindex = math.max(1, args_new[param.alias_of].maxindex)
            else
              args_new[param.alias_of] = val
            end
          end
        else
          -- Si le paramètre est un alias, le stocker avec le nom de base
          -- sans l’écraser : le nom de base est prioritaire.
          if not param.alias_of then
            args_new[name] = val
          elseif args[param.alias_of] == nil then
            if declared_parameters[param.alias_of] and declared_parameters[param.alias_of].list then
              args_new[param.alias_of][1] = val
              -- Stockage du plus haut indice trouvé.
              args_new[param.alias_of].maxindex = math.max(1, args_new[param.alias_of].maxindex)
            else
              args_new[param.alias_of] = val
            end
          end
        end
      end
    end
  end

  return args_new, required, args_unknown
end

--- Fonction permettant d’extraire les paires clé-valeur d’une liste de paramètres.
--- Structure des items du paramètre declared_parameters :
--- {
---   required: boolean,
---   alias_of: string,
---   default: string,
---   list: ?,
---   allow_whitespace: boolean,
---   allow_empty: boolean,
---   type: string,
--- }
---
--- @param args table la liste des paramètres et leur valeur
--- @param declared_parameters table la liste des paramètres possibles
--- @param return_unknown_parameters boolean si vrai, retourne la liste des paramètres inconnus plutôt que de lancer une erreur
function export.process(args, declared_parameters, return_unknown_parameters)
  local args_new, required, patterns, list_from_index = extract_parameters(declared_parameters)

  local args_unknown
  args_new, required, args_unknown = process_parameters(args, list_from_index, patterns, declared_parameters, return_unknown_parameters, required, args_new)

  -- La liste required devrait être vide.
  -- Si ce n’est pas le cas, lancer une erreur (sauf si l’espace de nom est Modèle).
  if mw.title.getCurrentTitle().nsText ~= "Modèle" then
    local list = {}
    for name, _ in pairs(required) do
      table.insert(list, name)
    end

    local count = #list
    if count == 1 then
      error('Le paramètre « ' .. list[1] .. ' » est requis.', 2)
    elseif count == 2 then
      error('Le paramètre « ' .. table.concat(list, ' » et « ') .. ' » sont requis.', 2)
    elseif count > 2 then
      error('Le paramètre « ' .. mw.text.listToText(list, ' », « ', ' » et « ') .. ' » sont requis.', 2)
    end
  end

  -- Suppression des trous dans les listes de paramètres si besoin.
  for name, val in pairs(args_new) do
    if type(val) == "table" and not declared_parameters[name].allow_holes then
      args_new[name] = remove_holes(val)
    end
  end

  if return_unknown_parameters then
    return args_new, args_unknown
  else
    return args_new
  end
end

return export
