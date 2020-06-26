-- Page de test : Utilisateur:Darkdadaah/Test:Sections
local m_bases = require('Module:bases')

local p = {}

-- Charge la table une fois pour toutes pour ce module
p.types = mw.loadData('Module:types de mots/data')

-- S'agit-il d'un type de mot reconnu (ou d'un alias) ?
function p.is_type(word)
  if word == nil then
    return nil
  end

  word = m_bases.lcfirst(word)

  return p.types['alias'][word] or p.types['texte'][word]
end

-- S'agit-il d'un alias?
function p.is_alias(word)
  if word == nil then
    return nil
  end

  return (p.types['alias'][m_bases.lcfirst(word)])
end

-- Crée un nom de flexion selon que le nom commence par une voyelle ou pas
local function getInflectionTitle(word, plural)
  local wordInflection = ''

  -- Forme: pluriel ou singulier
  local forme = 'forme'
  if plural then
    forme = 'formes'
  end

  if m_bases.is_elidable(word) then
    wordInflection = forme .. ' d’' .. word
  else
    wordInflection = forme .. ' de ' .. word
  end

  return wordInflection
end

-- Fonction de récupération du nom standard à partir de son code et de ses propriétés
function p.get_nom(code, locution, inflection, plural)
  if code == nil then
    return nil
  end

  -- Pour chercher dans les listes, le texte doit être en minuscule et sans tirets
  code = m_bases.lcfirst(code);

  -- Alias?
  if p.types['alias'][code] then
    code = p.types['alias'][code]
  end

  local locutionId = 'locution'
  local wordId = 'mot'
  if plural then
    locutionId = 'locution_pl'
    wordId = 'mot_pl'
  end

  -- Type défini ?
  if p.types['texte'][code] ~= nil then
    local name = ''
    if locution and p.types['texte'][code][locutionId] ~= nil then
      name = p.types['texte'][code][locutionId]
    else
      name = p.types['texte'][code][wordId]
    end

    -- Flexion
    if inflection then
      name = getInflectionTitle(name, plural)
    end

    return name
  else
    return 'type indéfini'
  end

  return nil
end

function p.get_nom_singulier(code, locution, inflection)
  return p.get_nom(code, locution, inflection, false)
end

function p.get_nom_pluriel(code, locution, inflection)
  return p.get_nom(code, locution, inflection, true)
end

-- Fonction qui créé une version abrégée du nom
function p.get_abrev(name, _, inflection)
  if name == nil then
    return 'indef'
  end
  name = m_bases.lcfirst(name)

  -- Alias?
  if p.types['alias'][name] then
    name = p.types['alias'][name]
  end

  if (p.types['texte'][name]) then
    local abbreviation = p.types['texte'][name]['abrev']
    if inflection then
      abbreviation = 'flex-' .. abbreviation
    end

    return abbreviation
  else
    return 'indef'
  end
end

return p
