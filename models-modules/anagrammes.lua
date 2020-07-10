local m_bases = require("Module:bases")
local m_params = require("Module:paramètres")

local p = {}
local diacriticsTable = {}
diacriticsTable["à"] = "a"
diacriticsTable["á"] = "a"
diacriticsTable["â"] = "a"
diacriticsTable["ã"] = "a"
diacriticsTable["ä"] = "a"
diacriticsTable["ç"] = "c"
diacriticsTable["è"] = "e"
diacriticsTable["é"] = "e"
diacriticsTable["ê"] = "e"
diacriticsTable["ë"] = "e"
diacriticsTable["ì"] = "i"
diacriticsTable["í"] = "i"
diacriticsTable["î"] = "i"
diacriticsTable["ï"] = "i"
diacriticsTable["ñ"] = "n"
diacriticsTable["ò"] = "o"
diacriticsTable["ó"] = "o"
diacriticsTable["ô"] = "o"
diacriticsTable["õ"] = "o"
diacriticsTable["ö"] = "o"
diacriticsTable["ù"] = "u"
diacriticsTable["ú"] = "u"
diacriticsTable["û"] = "u"
diacriticsTable["ü"] = "u"
diacriticsTable["ý"] = "y"
diacriticsTable["ÿ"] = "y"

local function _toTable(title, rawTable)
  local i = 1
  local maxLinks = 200
  local paramsTable = {}

  while rawTable[i] ~= nil and i <= maxLinks do
    local item = mw.text.trim(rawTable[i])

    -- To handle [[page (explication)]]
    local description = (mw.ustring.match(item, " %(([^%(%)%|]*)%)$")) or ""
    if description ~= "" then
      description = mw.ustring.format(" ''(%s)''", description)
      item = mw.ustring.gsub(item, " %([^%(%)%|]*%)$", "")
    end

    -- Caractères spéciaux non représentables avec une page : à écrire comme Lien{{!}}Caractère
    -- (Bricolage : pas possible de faire mieux ?)
    local link = mw.ustring.gsub(item, "|.*", "")

    if link ~= "" and link ~= title then
      table.insert(paramsTable, "[[" .. item .. "]]" .. description)
    end
    i = i + 1
  end

  return paramsTable
end

local function _buildListText(list)
  local text = ""

  if #list > 0 then
    text = "* " .. table.concat(list, "\n* ")
  else
    text = "(Merci de rajouter les articles en paramètres, ou à défaut d’enlever ce modèle)"
    text = text .. m_bases.fait_categorie_contenu("Modèle anagramme sans paramètre valide")
  end

  return text
end

local function _makeText(title, values)
  local args = _toTable(title, values)
  return _buildListText(args)
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
  local pageName = string.lower(args[2]):gsub("[%z\1-\127\194-\244][\128-\191]*", diacriticsTable)
  local tablePageName = {}

  pageName:gsub(".", function(c)
    table.insert(tablePageName, c)
  end)
  table.sort(tablePageName, function(a, b)
    return a < b
  end)
  return table.concat(tablePageName, "")
end

return p
