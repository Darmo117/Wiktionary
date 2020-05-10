local m_bases = require('Module:bases')
local m_params = require('Module:paramètres')
local m_langues = require('Module:langues')
local m_table = require('Module:table')
local m_Unicode_data = require('Module:données Unicode')

local checkLang = function(langCode)
  return m_langues.get_nom(langCode) ~= nil
end

local p = {}

--- Fonction destinée aux modèles {{sigle}}, {{abréviation}}, {{acronyme}}, etc.
---  frame.args["terme"] (chaine) : Le nom du procédé étymologique (sigle, verlan, etc.).
---  frame.args["terme-pluriel"] (chaine, optionnel) : Le pluriel du paramètre précédent ;
---    s’il n’est pas renseigné, le pluriel sera formé en ajoutant un « s » à la fin du terme.
---  frame.args["de"] (chaine, optionnel) : Le mot ou la locution à l’origine du mot vedette.
---  frame.args["de2"] (chaine, optionnel) : Le deuxième mot ou locution à l’origine du mot vedette.
---  frame.args["texte"] (chaine, optionnel) : Le texte à afficher à la place du paramètre « de »
---    dans le lien.
---  frame.args["texte2"] (chaine, optionnel) : Le texte à afficher à la place du paramètre « de2 »
---    dans le lien.
---  frame.args["adjectif"] (chaine, requis si nocat est false) : L’adjectif à ajouter entre
---    le « terme » et le « de ».
---  frame.args["lang"] (chaine, requis si nocat est false) : Le code de langue du mot vedette.
---  frame.args["lang-lien"] (chaine, optionnel) : Le code langue du mot lié (« de ») ; s’il
---    n’est pas renseigné, la paramètre « lang » sera utilisé.
---  frame.args["m"] (chaine, optionnel) : Si vrai, le premier terme aura une majuscule.
---  frame.args["nolien"] (booléen, optionnel) : Si vrai, aucun lien ne sera fait vers le mot
---    lié (« de »).
---  frame.args["nocat"] (booléen, optionnel) : Si vrai, la page ne sera pas catégorisée.
---  frame.args["clé"] (chaine, optionnel) : La clé de tri pour la catégorie.
---  frame.args["nom-cat"] (chaine, optionnel) : Le nom complet de la catégorie.
---  frame.args["nom-cat2"] (chaine, optionnel) : Le début du nom de la deuxième catégorie.
--- @return string Le texte formaté et la catégorie éventuelle.
function p.modele_etym(frame)
  local params = {
    ["terme"] = { required = true },
    ["terme-pluriel"] = {},
    ["de"] = {},
    ["de2"] = {},
    ["texte"] = {},
    ["texte2"] = {},
    ["adjectif"] = {},
    ["lang"] = { checker = checkLang },
    ["lang-lien"] = { checker = checkLang },
    ["m"] = { type = m_params.BOOLEAN, default = false },
    ["nolien"] = { type = m_params.BOOLEAN, default = false },
    ["nocat"] = { type = m_params.BOOLEAN, default = false },
    ["clé"] = { default = mw.title.getCurrentTitle().text },
    ["nom-cat"] = {},
    ["nom-cat2"] = {},
  }
  local args = m_params.process(frame.args, params)
  local term = args["terme"]
  local term_plural = args["terme-pluriel"] or (term .. "s")
  local caps = args["m"]
  local from = args["de"]
  local from2 = args["de2"]
  local text = args["texte"] or from
  local text2 = args["texte2"] or from2
  local adj = args["adjectif"]
  local no_link = args["nolien"]
  local no_categorization = args["nocat"]
  local lang = args["lang"]
  local link_lang = args["lang-lien"] or (lang or "fr")
  local sorting_key = args["clé"]
  local category = args["nom-cat"]
  local category2 = args["nom-cat2"]

  local res = mw.ustring.format("[[%s#fr|%s]]", term, caps and m_bases.ucfirst(term) or term)

  local format = function(base_word, replacement_text, base_string, additional_text)
    if base_word then
      local word
      if no_link then
        word = base_word
      else
        word = mw.ustring.format("[[%s#%s|%s]]", base_word, link_lang, replacement_text)
      end
      base_string = base_string .. mw.ustring.format(additional_text .. " de ''%s''", word)
    end
    return base_string
  end

  local get_category = function(cat_name)
    return m_bases.ucfirst(cat_name) .. " " ..
        (lang and "en " .. m_langues.get_nom(lang) or "sans langue précisée")
  end

  res = format(from, text, res, adj and (" " .. adj) or "")
  res = format(from2, text2, res, " et")

  if no_categorization then
    return res
  else
    local category_name
    if category then
      category_name = category
    else
      if lang == nil then
        error("Code de langue manquant")
      end
      category_name = get_category(term_plural)
    end
    res = res .. m_bases.fait_categorie_contenu(category_name, sorting_key)

    if category2 then
      if lang == nil then
        error("Code de langue manquant")
      end
      category_name = get_category(category2)
      res = res .. m_bases.fait_categorie_contenu(category_name, sorting_key)
    end

    return res
  end
end

-- Various latin codes accepted by {{étyl}}.
local LATIN_CODES = {
  'bas latin',
  'gallo-roman',
  'latin archaïque',
  'latin classique',
  'latin contemporain',
  'latin ecclésiastique',
  'latin humaniste',
  'latin impérial',
  'latin médiéval',
  'latin populaire',
  'latin tardif',
  'latin vulgaire',
  'néolatin',
}

local function checkLangExtended(langCode)
  return checkLang(m_table.contains(LATIN_CODES, langCode) and 'la' or langCode)
end

local function getLanguageName(langCode)
  return m_table.contains(LATIN_CODES, langCode) and langCode or m_langues.get_nom(langCode)
end

local function italicIfLatinScript(text)
  return m_Unicode_data.textHasScript(text, 'Latin') and mw.ustring.format("''%s''", text) or text
end

--- Fonction destinée au modèle {{étyl}}. Si au moins une des deux langues est inconnue
--- ou absente, un message d’erreur est affiché à la place du texte et la catégorie
--- [[:Catégorie:Wiktionnaire:Modèle étyl sans langue précisée]] est insérée.
---  frame.args[1] (string) : Code de la langue d’origine.
---  frame.args[2] (string) : Code de la langue du mot-vedette.
---  frame.args[mot, 3] (string) : Mot d’origine.
---  frame.args[tr, R, 4] (string) : Transcription du mot d’origine.
---  frame.args[sens, 5] (string) : Sens du mot d’origine.
---  frame.args[dif] (string) : Texte à afficher à la place du mot d’origine.
---  frame.args[type] (string) : Code de l’ancre de la section dans la page du mot d’origine.
---  frame.args[num] (int) : Numéro le l’ancre de la section dans la page du mot d’origine.
---  frame.args[nocat] (boolean) : Si vrai, la fonction ne catégorisera pas
---                               (sauf si il y a un problème avec les langues).
---  frame.args[lien] (boolean) : Si vrai, ajoute un lien vers la langue du mot d’origine.
--- @return string Le texte du modèle et les catégories éventuelles.
function p.modele_etymologie_langue(frame)
  local args = m_params.process(frame:getParent().args, {
    [1] = {},
    [2] = {},
    ['mot'] = {},
    [3] = { alias_of = 'mot' },
    ['tr'] = {},
    ['R'] = { alias_of = 'tr' },
    [4] = { alias_of = 'tr' },
    ['sens'] = {},
    [5] = { alias_of = 'sens' },
    ['dif'] = {},
    ['type'] = {},
    ['num'] = { type = m_params.INT, checker = function(n)
      return n > 0
    end },
    ['nocat'] = { type = m_params.BOOLEAN, default = false },
    ['lien'] = { type = m_params.BOOLEAN, default = false },
  })

  local originLang = args[1]
  local destLang = args[2]
  local word = args['mot']
  local transcription = args['tr']
  local meaning = args['sens']
  local alternativeText = args['dif']
  local anchorSection = args['type']
  local anchorNum = args['num']
  local noCat = args['nocat']
  local linkToLang = args['lien']

  if not checkLangExtended(originLang) or (not noCat and not checkLangExtended(destLang)) then
    return '<span style="color:red">Erreur modèle étyl&nbsp;: langue inconnue ou absente</span>' ..
        m_bases.fait_categorie_contenu('Wiktionnaire:Modèle étyl sans langue précisée')
  end

  local categories = ''
  local content = ''
  local anchor = ''
  local originLangName = getLanguageName(originLang)
  local destLangName = getLanguageName(destLang)
  local displayedLang = linkToLang and m_bases.lien_modele(originLangName, 'fr') or originLangName

  if word then
    if anchorSection then
      anchor = anchorSection
    end
    if anchorNum then
      anchor = anchor .. '-' .. tostring(anchorNum)
    end

    content = italicIfLatinScript(m_bases.lien_modele(word, originLang, anchor, alternativeText, true))

    if transcription then
      content = mw.ustring.format("%s, ''%s''", content, transcription)
    end
    if meaning then
      content = mw.ustring.format('%s («&nbsp;%s&nbsp;»)', content, meaning)
    end

    content = mw.ustring.format('%s %s', displayedLang, content)
  else
    content = displayedLang
  end

  if not noCat then
    if originLang == destLang then
      categories = categories .. m_bases.fait_categorie_contenu('Appels de modèles incorrects:étyl')
    elseif originLang == 'onom' then
      categories = categories .. m_bases.fait_categorie_contenu(mw.ustring.format(
          'Mots en %s issus d’une onomatopée',
          destLangName
      ))
    else
      categories = categories .. m_bases.fait_categorie_contenu(mw.ustring.format(
          'Mots en %s issus d’un mot en %s',
          destLangName,
          originLangName
      ))
    end
  end

  return content .. categories
end

return p
