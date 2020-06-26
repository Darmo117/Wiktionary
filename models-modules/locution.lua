local m_word_types = require('Module:types de mots')
local locLangs = mw.loadData('Module:locution/data')

local p = {}

function p.contient_espaces(word)
  if word == nil then
    return nil
  end
  return mw.ustring.find(word, ". .") ~= nil
end

function p.is_locution(args, article, lang)
  if article == nil or article.text == nil or args == nil then
    return false
  end
  local title = article.text

  -- Annexe ? Ne garde que la dernière sous-page
  if article.namespace == 100 then
    title = mw.ustring.gsub(title, ".+\/", "")
  end

  -- Forcé par un paramètre
  if args['locution'] then
    _addCategory('Wiktionnaire:Sections de type avec locution forcée')

    if args['locution'] == 'oui' then
      return true
    elseif args['locution'] == 'non' then
      return false
    else
      _addCategory('Wiktionnaire:Sections avec paramètre locution invalide')
    end
  end

  -- Liste blanche : on peut deviner automatiquement
  if locLangs[lang] then
    return p.devine_locution(args, article, lang)
  else
    return false
  end
end

function p.devine_locution(args, article, _)
  if article == nil or article.text == nil or args == nil then
    return false
  end
  local title = article.text

  -- Cas spéciaux (par langue)
  if args[1] ~= nil and args[2] ~= nil then
    -- Verbes pronominaux français
    if args[2] == 'fr' and m_word_types.get_nom_singulier(args[1]) == 'verbe' and mw.ustring.find(title, "^se ") then
      return mw.ustring.find(title, "^se [^ ]+ ")
      -- Verbes pronominaux bretons
      -- https://fr.wiktionary.org/wiki/Wiktionnaire:Wikidémie/mars_2018#Verbes_pronominaux_en_breton
    elseif args[2] == 'br' and m_word_types.get_nom_singulier(args[1]) == 'verbe' and mw.ustring.find(title, "^en em ") then
      return mw.ustring.find(title, "^en em [^ ]+ ")
      -- Verbes pronominaux néerlandais
    elseif args[2] == 'nl' and m_word_types.get_nom_singulier(args[1]) == 'verbe' and mw.ustring.find(title, "^zich ") then
      return mw.ustring.find(title, "^zich [^ ]+ ")
      -- Verbes à particule néerlandais
    elseif args[2] == 'nl' and m_word_types.get_nom_singulier(args[1]) == 'verbe'
        -- est-ce que le verbe finit par " aan", " achter", " af", etc ?
        and (mw.ustring.find(title, " aan$")
        or mw.ustring.find(title, " aaneen$")
        or mw.ustring.find(title, " achter")
        or mw.ustring.find(title, " achterna$")
        or mw.ustring.find(title, " achterover$")
        or mw.ustring.find(title, " achteruit$")
        or mw.ustring.find(title, " achteruit$")
        or mw.ustring.find(title, " af$")
        or mw.ustring.find(title, " beet$")
        or mw.ustring.find(title, " bij$")
        or mw.ustring.find(title, " bijeen$")
        or mw.ustring.find(title, " binnen$")
        or mw.ustring.find(title, " bloot$")
        or mw.ustring.find(title, " boven$")
        or mw.ustring.find(title, " buiten$")
        or mw.ustring.find(title, " deel$")
        or mw.ustring.find(title, " dicht$")
        or mw.ustring.find(title, " dood$")
        or mw.ustring.find(title, " door$")
        or mw.ustring.find(title, " droog$")
        or mw.ustring.find(title, " fijn$")
        or mw.ustring.find(title, " gaar$")
        or mw.ustring.find(title, " gelijk$")
        or mw.ustring.find(title, " glad$")
        or mw.ustring.find(title, " goed$")
        or mw.ustring.find(title, " groot$")
        or mw.ustring.find(title, " hard$")
        or mw.ustring.find(title, " in$")
        or mw.ustring.find(title, " ineen$")
        or mw.ustring.find(title, " klein$")
        or mw.ustring.find(title, " kort$")
        or mw.ustring.find(title, " kwijt$")
        or mw.ustring.find(title, " lang$")
        or mw.ustring.find(title, " langs$")
        or mw.ustring.find(title, " leeg$")
        or mw.ustring.find(title, " los$")
        or mw.ustring.find(title, " mede$")
        or mw.ustring.find(title, " mee$")
        or mw.ustring.find(title, " mis$")
        or mw.ustring.find(title, " na$")
        or mw.ustring.find(title, " neer$")
        or mw.ustring.find(title, " om$")
        or mw.ustring.find(title, " omver$")
        or mw.ustring.find(title, " onder$")
        or mw.ustring.find(title, " op$")
        or mw.ustring.find(title, " open$")
        or mw.ustring.find(title, " opeen$")
        or mw.ustring.find(title, " over$")
        or mw.ustring.find(title, " raak$")
        or mw.ustring.find(title, " recht$")
        or mw.ustring.find(title, " rond$")
        or mw.ustring.find(title, " samen$")
        or mw.ustring.find(title, " scheef$")
        or mw.ustring.find(title, " schoon$")
        or mw.ustring.find(title, " stil$")
        or mw.ustring.find(title, " stuk$")
        or mw.ustring.find(title, " tegen$")
        or mw.ustring.find(title, " terecht$")
        or mw.ustring.find(title, " terug$")
        or mw.ustring.find(title, " toe$")
        or mw.ustring.find(title, " uit$")
        or mw.ustring.find(title, " vast$")
        or mw.ustring.find(title, " vlak$")
        or mw.ustring.find(title, " vol$")
        or mw.ustring.find(title, " voor$")
        or mw.ustring.find(title, " voort$")
        or mw.ustring.find(title, " voorbij$")
        or mw.ustring.find(title, " vooruit$")
        or mw.ustring.find(title, " vrij$")
        or mw.ustring.find(title, " weg$")
        or mw.ustring.find(title, " warm$")
        or mw.ustring.find(title, " zwart$")) then
      -- On teste la présence d'une seule espace
      return mw.ustring.find(title, "^[^ ]+ [^ ]+$")
    end
  end

  -- Par défaut : espaces = locution
  return p.contient_espaces(title)
end

return p
