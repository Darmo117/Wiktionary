local m_bases = require("Module:bases")
local m_table = require("Module:table")
local m_params = require("Module:paramètres")

local p = {}

--- Normalize a string before building its alphagramme.
--- @param langCode string Language code.
--- @param s string The string.
--- @return string The same string with all diacritics stripped.
local function normalize(langCode, s)
  local langConfig
  local dataModuleTitle = "Module:anagrammes/" .. langCode
  if mw.title.new(dataModuleTitle).exists then
    langConfig = require(dataModuleTitle)
  else
    langConfig = {
      keep = {},
      mappings = {},
    }
  end
  local res = mw.ustring.gsub(mw.ustring.lower(s), "%w", function(c)
    if m_table.contains(langConfig.keep, c) then
      return c
    else
      -- Decompose the character into NFD form (base letter followed by eventual combining diacritics)
      -- then keep only the letter (first char)
      return mw.ustring.sub(mw.ustring.toNFD(c), 1, 1)
    end
  end)
  for k, v in pairs(langConfig.mappings) do
    res = mw.ustring.gsub(res, k, v)
  end
  return res
end

local function _toTable(langCode, title, rawTable)
  local i = 1
  local maxLinks = 200
  local alphasTable = {}
  local paramsTable = {}
  local alpha_title = mw.ustring.gsub(normalize(langCode, title), "[()’ -]", "")

  while rawTable[i] ~= nil and i <= maxLinks do
    local item = mw.text.trim(rawTable[i])

    local alpha = mw.ustring.gsub(normalize(langCode, item), "[()’ -]", "")
    if alpha ~= alpha_title then
      if paramsTable[alpha] ~= nil then
        paramsTable[alpha] = mw.ustring.format("%s, [[%s]]", paramsTable[alpha], item)
      else
        table.insert(alphasTable, alpha)
        paramsTable[alpha] = "[[" .. item .. "]]"
      end
    end
    i = i + 1
  end

  return alphasTable, paramsTable
end

local function _getValues(alphas, args)
  local values = {}
  for _, alpha in pairs(alphas) do
    table.insert(values, args[alpha])
  end
  return values
end

local function _buildListText(list)
  local text

  if #list > 0 then
    text = "* " .. table.concat(list, "\n* ")
  else
    text = "(Merci de rajouter les articles en paramètres, ou à défaut d’enlever ce modèle)"
    text = text .. m_bases.fait_categorie_contenu("Modèle anagramme sans paramètre valide")
  end

  return text
end

local function _makeText(langCode, title, values)
  local alphas, args = _toTable(langCode, title, values)
  return _buildListText(_getValues(alphas, args))
end

--- Invoqué par [[Modèle:anagrammes]]
--- @param frame frame
function p.listeAnagrammes(frame)
  local langCode = frame:getParent().args["lang"]
  return _makeText(langCode, mw.title.getCurrentTitle().fullText, frame:getParent().args)
end

--- Invoqué par [[Modèle:voir anagrammes]]
--- @param frame frame
function p.alphagramme(frame)
  local args = m_params.process(frame.args, {
    [1] = { },
    [2] = { },
  })

  local langCode = args[1]
  if langCode == nil then
    return '<span style="color:red">Code de langue absent !</span>[[Catégorie:Appel au modèle voir anagrammes sans code de langue]]'
  end

  local pageName = mw.ustring.gsub(normalize(langCode, args[2]), "[/ ’-]", "")
  local tablePageName = {}

  -- Sépare le mot, caractère par caractère
  mw.ustring.gsub(pageName, ".", function(c)
    table.insert(tablePageName, c)
  end)
  -- Trie les lettres
  table.sort(tablePageName)

  local alphagramme = table.concat(tablePageName, "")
  local templateName = mw.ustring.format("anagrammes/%s/%s", langCode, alphagramme)

  if mw.title.new("Modèle:" .. templateName).exists then
    return mw.ustring.format("→ [[Spécial:EditPage/Modèle:%s|Modifier la liste d’anagrammes]]", templateName)
        .. frame:expandTemplate { title = templateName }
  else
    return mw.ustring.format('<span style="color:red">Le modèle d’anagrammes n’existe pas. '
        .. 'Cliquez [[Modèle:%s|ici]] pour le créer.</span>[[Catégorie:Pages avec modèle d’anagrammes manquant]]', templateName)
  end
end

return p
