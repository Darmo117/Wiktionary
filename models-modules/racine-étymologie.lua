local m_bases = require("Module:bases")
local m_params = require("Module:paramètres")
local m_langs = require("Module:langues")

local p = {}

local ROOT = 0
local PREFIX = 1
local SUFFIX = 2
local FINALE = 3

local function getType(element)
  if mw.ustring.match(element, "^.+/$") then
    return ROOT
  elseif mw.ustring.match(element, "^[^-]+-$") then
    return PREFIX
  elseif mw.ustring.match(element, "^-[^-]+-$") then
    return SUFFIX
  elseif mw.ustring.match(element, "^-[^-]+$") then
    return FINALE
  else
    error("Élément de type inconnu : " .. element)
  end
end

local function formatRoot(root, langue)
  return "[[Racine:" .. langue .. "/" .. root .. "|" .. root .. "]]"
end

local function formatWord(word, code)
  return "[[" .. word .. "#" .. code .. "|" .. word .. "]]"
end

-- TODO retirer le paramètre "language"
function p._generateEtymology(elements, code, language)
  local etymology = "Composé"
  local roots = {}
  local prefixes = {}
  local suffixes = {}
  local final = ""
  local categories = ""
  local language = m_langs.get_nom(code)

  for _, element in ipairs(elements) do
    local type = getType(element)
    if type == ROOT then
      element = mw.ustring.gsub(element, "/", "")
      table.insert(roots, element)
    elseif type == PREFIX then
      table.insert(prefixes, element)
    elseif type == SUFFIX then
      table.insert(suffixes, element)
    elseif type == FINALE then
      if final == "" then
        final = element
      else
        error("Une finale est déjà définie ! Conflit entre " .. final .. " et " .. element .. ".")
      end
    end
  end

  -- Gestion des préfixes
  if #prefixes == 1 then
    etymology = etymology .. " du préfixe " .. formatWord(prefixes[1], code)
    categories = categories .. "[[Catégorie:Mots en " .. language .. " préfixés avec " .. prefixes[1] .. "]]"
  elseif #prefixes > 1 then
    etymology = etymology .. " des préfixes "
    local i = 1
    while i <= #prefixes do
      if i ~= #prefixes then
        etymology = etymology .. formatWord(prefixes[i], code)
        if i ~= #prefixes - 1 then
          etymology = etymology .. ", "
        end
      else
        etymology = etymology .. " et " .. formatWord(prefixes[i], language)
      end
      categories = categories .. "[[Catégorie:Mots en " .. language .. " préfixés avec " .. prefixes[i] .. "]]"
      i = i + 1
    end
  end

  if #prefixes ~= 0 and #roots ~= 0 then
    etymology = etymology .. ", "
  end

  -- Gestion des racines
  if #roots == 1 then
    etymology = etymology .. " de la racine " .. formatRoot(roots[1], language)
    categories = categories .. "[[Catégorie:Mots en " .. language .. " comportant la racine " .. roots[1] .. "]]"
  elseif #roots > 1 then
    etymology = etymology .. " des racines "
    local i = 1
    while i <= #roots do
      if i ~= #roots then
        etymology = etymology .. formatRoot(roots[i], language)
        if i ~= #roots - 1 then
          etymology = etymology .. ", "
        end
      else
        etymology = etymology .. " et " .. formatRoot(roots[i], language)
      end
      categories = categories .. "[[Catégorie:Mots en " .. language .. " comportant la racine " .. roots[i] .. "]]"
      i = i + 1
    end
  end

  if (#prefixes ~= 0 or #roots ~= 0) and #suffixes ~= 0 then
    etymology = etymology .. ", "
  end

  -- Gestion des suffixes
  if #suffixes == 1 then
    etymology = etymology .. " du suffixe " .. formatWord(suffixes[1], code)
    categories = categories .. "[[Catégorie:Mots en " .. language .. " suffixés avec " .. suffixes[1] .. "]]"
  elseif #suffixes > 1 then
    etymology = etymology .. " des suffixes "
    local i = 1
    while i <= #suffixes do
      if i ~= #suffixes then
        etymology = etymology .. formatWord(suffixes[i], code)
        if i ~= #suffixes - 1 then
          etymology = etymology .. ", "
        end
      else
        etymology = etymology .. " et " .. formatWord(suffixes[i], code)
      end
      categories = categories .. "[[Catégorie:Mots en " .. language .. " suffixés avec " .. suffixes[i] .. "]]"
      i = i + 1
    end
  end

  -- Gestion de la finale
  etymology = etymology .. " et de la finale " .. formatWord(final, code)

  return etymology .. (m_bases.page_principale() and categories or "")
end

function p.generateEtymology(frame)
  local langCode = m_params.process(frame.args, {
    [1] = {
      required = true,
      checker = function(v)
        return m_langs.get_nom(v) ~= nil
      end
    },
  })[1]
  return p._generateEtymology(frame:getParent().args, langCode)
end

return p
