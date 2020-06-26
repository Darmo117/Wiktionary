local m_wordTypes = require("Module:types de mots")
local m_langs = require("Module:langues")

local p = {}

-- Critères basés sur [[Wiktionnaire:Prise de décision/Catégories de lemmes]]

local validLangs = {
  'fr',
  'de',
  'en',
  'eo',
  'es',
  'it',
  'ru',
  'bg',
  'ga',
  'gallo',
  'se',
  'la',
  'sl',
  'cs',
  'sv',
  'nl',
  'pt',
  'fi',
}
local invalidSectionTypes = {
  'faute d’orthographe',
  'variante par contrainte typographique',
  'nom propre',
  'prénom',
  'nom de famille',
  'nom scientifique',
  'infixe',
  'interfixe',
  'préfixe',
  'suffixe',
  'circonfixe',
  'symbole',
}

function p.is_lemme(lang, type, isInflection, isLocution)
  return not (not lang or not validLangs[lang] or isInflection or not type
      or not m_wordTypes.is_type(type) or invalidSectionTypes[m_wordTypes.get_nom(type)]
      or isLocution)
end

function p.cat_lemme(lang, type, isInflection, isLocution)
  if lang == nil or type == nil or isInflection == nil or isLocution == nil then
    return ""
  end

  if p.is_lemme(lang, type, isInflection, isLocution) then
    local langName = m_langs.get_nom(lang)
    if langName then
      return "Lemmes en " .. langName
    else
      return ""
    end
  end

  return ""
end

return p
