-- Avant de publier toute modification, testez l’affichage dans [[Discussion module:voir]]

local b = require('Module:bases')
local p = {}

--- Formate les arguments 2 par 2 : les valeurs aux indices impairs correspondent
--- aux description des valeurs aux indices pairs.
--- @param raw_args table La liste des valeurs par paires.
--- @return table La liste des valeurs formatées "valeur (description)".
local function _format_descriptions(raw_args)
  local i = 1
  local values = {}

  while raw_args[i] ~= nil do
    table.insert(values, raw_args[i + 1] .. " (" .. raw_args[i] .. ")")
    i = i + 2
  end

  return values
end

--- Transforme une table ou une metatable en une table d’éléments acceptables.
--- @param raw_table table Table des paramètres bruts.
--- @param title string Titre de la page courante.
--- @return table La liste des valeurs et de leur description entre parenthèses.
local function _to_table(raw_table, title)
  local i = 1
  local max_links = 200
  local params_table = {}

  while raw_table[i] ~= nil and i <= max_links do
    local item = mw.text.trim(raw_table[i])

    -- Pour traiter [[page (explication)]]
    local description = (mw.ustring.match(item, " %(([^%(%)%|]*)%)$")) or ""
    if description ~= "" then
      description = " ''(" .. description .. ")''"
      item = mw.ustring.gsub(item, " %([^%(%)%|]*%)$", "")
    end

    -- Caractères spéciaux non représentables avec une page : à écrire comme Lien{{!}}Caractère
    -- (Bricolage : pas possible de faire mieux ?)
    local link = mw.ustring.gsub(item, "|.*", "")

    if link ~= '' and link ~= title then
      table.insert(params_table, "'''[[" .. item .. "]]'''" .. description)
    end
    i = i + 1
  end

  return params_table
end

--- Construit le texte à afficher.
--- @param list table Liste des valeurs à afficher.
--- @return string Le texte à afficher.
local function _build_list_text(list)
  local text = ''

  -- La liste contient-elle des éléments à afficher ? Sinon on affiche un message indiquant ce qu'il faut faire.
  if #list > 0 then
    -- Liste de liens wiki, en gras, séparés par des virgules
    text = table.concat(list, ", ")
  else
    text = "(Merci de rajouter les articles en paramètres, ou à défaut d’enlever ce modèle)"
    text = text .. b.fait_categorie_contenu('Modèle voir sans paramètre valide')
  end

  return text
end

--- Récupère le titre de la page et les valeurs données et retourne le texte.
--- @param values table Les valeurs brutes.
--- @return string Le texte à afficher.
local function _make_text(values)
  local title = mw.title.getCurrentTitle().fullText
  local args = _to_table(values, title)
  return _build_list_text(args)
end

--- Récupère les paramètres du modèle et renvoie la liste formatée en texte brut.
function p.liste_voir(frame)
  return _make_text(frame:getParent().args)
end

--- Construit la liste des valeurs pour le modèle {{voir autre alphabet}}.
function p.liste_voir_alphabet(frame)
  return _make_text(_format_descriptions(frame:getParent().args))
end

return p
