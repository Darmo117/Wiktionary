local m_bases = require("Module:bases")
local m_params = require("Module:paramètres")

local p = {}

--- Remove all diacritics from a UTF-8 string.
--- @param s string The string.
--- @return string The same string with all diacritics stripped.
local function removeDiacritics(s)
  return mw.ustring.gsub(mw.ustring.lower(s), "%w", function(c)
    -- Decompose the character into NFD form (letter followed by eventual combining diacritics)
    -- then keep only the letter (first char)
    return mw.ustring.sub(mw.ustring.toNFD(c), 1, 1)
  end)
end

local function _toTable(title, rawTable)
  local i = 1
  local maxLinks = 200
  local alphasTable = {}
  local paramsTable = {}

  while rawTable[i] ~= nil and i <= maxLinks do
    local item = mw.text.trim(rawTable[i])

    if item ~= title then
      local alpha = mw.ustring.gsub(removeDiacritics(item), "-", "")

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

local function _makeText(title, values)
  local alphas, args = _toTable(title, values)
  return _buildListText(_getValues(alphas, args))
end

function p.listeAnagrammes(frame)
  return _makeText(mw.title.getCurrentTitle().fullText, frame:getParent().args)
end

function p.alphagramme(frame)
  local args = m_params.process(frame.args, {
    [1] = { },
    [2] = { },
  })

  -- Do not remove, not used yet.
  local lang = args[1]
  local pageName = mw.ustring.gsub(removeDiacritics(args[2]), "[/ ’-]", "")
  local tablePageName = {}

  -- Sépare le mot, caractère par caractère
  mw.ustring.gsub(pageName, ".", function(c)
    table.insert(tablePageName, c)
  end)
  -- Trie les lettres
  table.sort(tablePageName)

  local alphagramme = table.concat(tablePageName, "")
  local templateName = mw.ustring.format("anagrammes/%s/%s", lang, alphagramme)

  if mw.title.new("Modèle:" .. templateName).exists then
    return mw.ustring.format("→ [[Spécial:EditPage/Modèle:%s|Modifier la liste d’anagrammes]]", templateName)
        .. frame:expandTemplate { title = templateName }
  else
    return mw.ustring.format('<span style="color:red">Le modèle d’anagrammes n’existe pas. '
        .. 'Cliquez [[Modèle:%s|ici]] pour le créer.</span>[[Catégorie:Pages avec modèle d’anagrammes manquant]]', templateName)
  end
end

return p
