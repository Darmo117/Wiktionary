local m_table = require("Module:table")

local export = {}

-- Types
export.NUMBER = "number"
export.INT = "int"
export.FLOAT = "float"
export.BOOLEAN = "boolean"

-- Constantes d’erreur
export.UNKNOWN_PARAM = "unknown parameter"
export.MISSING_PARAM = "missing required parameter"
export.EMPTY_PARAM = "empty required parameter"
export.INVALID_VALUE = "invalid value"
export.VALUE_NOT_IN_ENUM = "value not in enum"
export.INVALID_TYPE = "invalid type"
export.ALIAS_TO_UNKNOWN = "alias to undefined parameter"
export.ALIAS_TO_ALIAS = "alias to alias parameter"
export.ALIAS_TO_ITSELF = "alias to itself"
export.ENUM_WITH_CHECKER = "enum with checker"

--- Liste des erreurs non masquées par le mode silencieux.
local UNCATCHABLE_ERRORS = {
  export.INVALID_TYPE,
  export.ALIAS_TO_UNKNOWN,
  export.ALIAS_TO_ALIAS,
  export.ALIAS_TO_ITSELF,
  export.ENUM_WITH_CHECKER,
}

--- Liste des templates de messages d’erreur.
local ERROR_MESSAGES = {
  [export.UNKNOWN_PARAM] = "Paramètre « %s » inconnu",
  [export.MISSING_PARAM] = "Paramètre requis « %s » absent",
  [export.EMPTY_PARAM] = "Paramètre requis « %s » vide",
  [export.INVALID_VALUE] = 'Valeur invalide pour le paramètre « %s » ("%s") de type %s',
  [export.VALUE_NOT_IN_ENUM] = 'Valeur invalide pour le paramètre « %s » ("%s")',
  [export.INVALID_TYPE] = 'Type inconnu pour le paramètre « %s » ("%s")',
  [export.ALIAS_TO_UNKNOWN] = 'Paramètre « %s », alias vers un paramètre non défini « %s »',
  [export.ALIAS_TO_ALIAS] = 'Paramètre « %s », alias vers un autre alias (« %s »)',
  [export.ALIAS_TO_ITSELF] = 'Paramètre « %s », alias vers lui-même',
  [export.ENUM_WITH_CHECKER] = "Le paramètre « %s » est une énumération avec une précondition",
}

--- Construit l’objet d’erreur.
--- @param error_type string le type de l’erreur
--- @vararg string les données pour formater le message d’erreur
--- @return table un objet contenant le type d’erreur à l’indice "error_type" et les autres données à l’indice "error_data"
local function build_error_message(error_type, ...)
  return {
    ["error_type"] = error_type,
    ["error_data"] = { ... }
  }
end

--- Convertit une chaine en booléen.
--- true = "1", "oui" ou "vrai"
--- false = "0", "non" ou "faux"
--- @param arg_value string la valeur à convertir
--- @param arg_name string le nom de l’argument correspondant à la valeur
--- @param type_fr string le type attendu en français
--- @return boolean la valeur booléenne du premier argument
local function to_boolean(arg_value, arg_name, type_fr)
  if m_table.contains({ "1", "oui", "vrai" }, arg_value) then
    return true
  elseif m_table.contains({ "0", "non", "faux" }, arg_value) then
    return false
  else
    error(build_error_message(export.INVALID_VALUE, arg_name, arg_value, type_fr))
  end
end

--- Convertit une chaine en nombre.
--- @param arg_value string la valeur à convertir
--- @param arg_name string le nom de l’argument correspondant à la valeur
--- @param to_int boolean indique si le nombre doit être un entier
--- @param type_fr string le type attendu en français
--- @return number la valeur numérique du premier argument
local function to_number(arg_value, arg_name, to_int, type_fr)
  local val = tonumber(arg_value)

  if val ~= nil then
    if not to_int or to_int and val == math.floor(val) then
      return val
    end
  end

  error(build_error_message(export.INVALID_VALUE, arg_name, arg_value, type_fr))
end

--- Traite les arguments.
--- @param args table Les arguments à traiter.
--- @param defined_parameters table La définition des paramètres.
--- @return table Les arguments traités.
local function parse_args(args, defined_parameters)
  local processed_args = {}

  for arg_name, arg_value in pairs(args) do
    local param = defined_parameters[arg_name]

    if param ~= nil then
      -- enum et checker ne peuvent pas être définis en même temps.
      if param.enum and param.checker then
        error(build_error_message(export.ENUM_WITH_CHECKER, arg_name))
      end

      local key

      if param.alias_of ~= nil then
        -- L’alias n’écrase pas la valeur du paramètre de base.
        if processed_args[param.alias_of] == nil then
          key = param.alias_of
          if defined_parameters[key] == nil then
            error(build_error_message(export.ALIAS_TO_UNKNOWN, arg_name, key))
          elseif key == arg_name then
            error(build_error_message(export.ALIAS_TO_ITSELF, arg_name))
          elseif defined_parameters[key].alias_of ~= nil then
            error(build_error_message(export.ALIAS_TO_ALIAS, arg_name, key))
          end
        end
      else
        key = arg_name
      end

      if key ~= nil then
        if mw.text.trim(arg_value) == "" then
          -- Un paramètre requis vide doit avoir la propriété allow_empty à true
          -- pour ne pas lancer d’erreur.
          if param.required and param.allow_empty or not param.required then
            arg_value = nil
            processed_args[key] = nil
          else
            error(build_error_message(export.EMPTY_PARAM, arg_name))
          end
        end

        if arg_value ~= nil then
          local fr_type = ""

          -- Vérification des types des arguments.
          if param.type == nil then
            fr_type = "chaine"
            processed_args[key] = arg_value
          elseif param.type == export.NUMBER then
            fr_type = "nombre"
            processed_args[key] = to_number(arg_value, key, false, fr_type)
          elseif param.type == export.INT then
            fr_type = "entier"
            processed_args[key] = to_number(arg_value, key, true, fr_type)
          elseif param.type == export.FLOAT then
            fr_type = "flottant"
            processed_args[key] = to_number(arg_value, key, false, fr_type)
          elseif param.type == export.BOOLEAN then
            fr_type = "booléen"
            processed_args[key] = to_boolean(arg_value, key, fr_type)
          else
            error(build_error_message(export.INVALID_TYPE, arg_name, param.type))
          end

          -- Vérification des contraintes d’énumération ou de la précondition.
          local value = processed_args[key]
          if type(param.enum) == "table" and not m_table.contains(param.enum, value) then
            error(build_error_message(export.VALUE_NOT_IN_ENUM, arg_name, value))
          elseif type(param.checker) == "function" and not param.checker(value) then
            error(build_error_message(export.INVALID_VALUE, arg_name, value, fr_type))
          end
        end
      end
    else
      -- Les paramètres non définis lancent une erreur.
      error(build_error_message(export.UNKNOWN_PARAM, arg_name))
    end
  end

  return processed_args
end

--- Vérifie la validité des paramètres et termine le traitement des arguments.
--- @param processed_args table Les arguments retournés par la fonction parse_args.
--- @param defined_parameters table La définition des paramètres.
--- @return table Les arguments traités.
local function check_params(processed_args, defined_parameters)
  local types = { export.BOOLEAN, export.NUMBER, export.INT, export.FLOAT }

  for param_name, param_value in pairs(defined_parameters) do
    if param_value.type ~= nil and not m_table.contains(types, param_value.type) then
      error(build_error_message(export.INVALID_TYPE, param_name, param_value.type))
    end
    if param_value.enum and param_value.checker then
      error(build_error_message(export.ENUM_WITH_CHECKER, param_name))
    end

    if param_value.alias_of ~= nil then
      local alias = param_value.alias_of

      if not defined_parameters[alias] then
        error(build_error_message(export.ALIAS_TO_UNKNOWN, param_name, param_value.alias_of))
      elseif alias == param_name then
        error(build_error_message(export.ALIAS_TO_ITSELF, param_name))
      elseif defined_parameters[alias].alias_of ~= nil then
        error(build_error_message(export.ALIAS_TO_ALIAS, param_name, param_value.alias_of))
      end
    end
    if processed_args[param_name] == nil and param_value.alias_of == nil then
      if param_value.required and not param_value.allow_empty then
        error(build_error_message(export.MISSING_PARAM, param_name))
      elseif param_value.default ~= nil then
        processed_args[param_name] = param_value.default
      end
    end
  end

  return processed_args
end

--- Fonction permettant de traiter les arguments du module appelant.
--- Pour plus de détails, voir la documentation du module.
--- @param args table les arguments du module appelant
--- @param defined_parameters table les paramètres définis
--- @param silent_errors boolean si true, les paramètres problématiques sont retournés au lieu de lancer une erreur ; ne devrait être utilisé que dans le cas où un comportement précis est nécessaire
--- @return table|string|number,boolean une table contenant les paramètres traités ou le nom du paramètre ayant déclanché une erreur et un booléen indiquant le statut
function export.process(args, defined_parameters, silent_errors)
  local success, result = pcall(function()
    local processed_args = parse_args(args, defined_parameters)
    return check_params(processed_args, defined_parameters)
  end)

  if not success then
    local error_type = result.error_type
    local error_data = result.error_data
    local error_message = mw.ustring.format(ERROR_MESSAGES[error_type], unpack(error_data))

    if silent_errors and not m_table.contains(UNCATCHABLE_ERRORS, error_type) then
      local arg_name = error_data[1]
      local arg_value = type(arg_name) == "number" and tonumber(arg_name) or arg_name
      return { arg_value, error_type, error_message }, false
    end
    -- Ajout d’une mention pour les erreurs internes.
    if m_table.contains(UNCATCHABLE_ERRORS, error_type) then
      error_message = "Erreur interne : " .. error_message
    end
    -- Suppression de la trace de l’erreur, on garde juste le message.
    error(error_message, 0)
  end

  return result, true
end

return export
