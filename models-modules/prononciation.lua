local m_params = require("Module:paramètres")
local m_langues = require("Module:langues")
local m_bases = require("Module:bases")
--local m_rimes = require('Module:rimes')

local export = {}

--- Page principale des annexes de prononciations
export.racine_pron = 'Annexe:Prononciation'

--- Retourne la page de l’annexe de prononciation pour une langue donnée.
--- @param lang_code string le code de langue
--- @return string|nil la page de prononciation si elle existe, nil sinon
function export.page_pron(lang_code)
  local lang_name = m_langues.get_nom(lang_code)

  if lang_name then
    local pron_page = export.racine_pron .. '/' .. lang_name
    if m_bases.page_existe(export.racine_pron .. '/' .. lang_name) then
      return pron_page
    end
  end

  return nil
end

--- Met en forme une prononciation avec un lien vers l’annexe dédiée si elle existe.
--- Cette fonction destinée à être appelée par d’autres modules lua.
--- @param pron string la prononciation API ; si la valeur "-" est passé, la prononciation n’est pas affichée
--- @param lang_code string le code de la langue ; s’il est absent, un message d’erreur est affichée à la place de la prononciation et la page est catégorisée dans Wiktionnaire:Prononciations avec langue manquante
--- @param delimiters string les délimiteurs ("[]", "//" ou "\\") ; la valeur par défaut est "\\"
--- @param is_audio_linked boolean indique si un fichier audio est associé à la prononciation pour ajouter la catégorie adéquate
--- @return string la prononciation formatée
function export.lua_pron(pron, lang_code, delimiters, is_audio_linked)
  delimiters = delimiters or '\\\\' -- valeur par défaut
  is_audio_linked = is_audio_linked or false -- valeur par défaut
  local delimiter1 = string.sub(delimiters, 1, 1)
  local delimiter2 = string.sub(delimiters, 2, 2)
  local lang_name = m_langues.get_nom(lang_code)
  local current_page_title = mw.title.getCurrentTitle()

  if not lang_code or lang_code == '' or not lang_name then
    return m_bases.fait_categorie_contenu("Wiktionnaire:Prononciations avec langue manquante") .. [[<span style="color:red">'''Erreur sur la langue !'''</span>]]
  end

  local text = ""

  -- Pas de prononciation donnée : invite + catégorie
  if not pron or pron == '' then
    -- Invitation à ajouter la prononciation
    text = ('<span title="Prononciation à préciser">' .. delimiter1 .. '<small><span class="plainlinks stubedit">['
        .. tostring(mw.uri.fullUrl(current_page_title.fullText, 'action=edit'))
        .. ' Prononciation ?]</span></small>' .. delimiter2 .. '</span>')

    -- Catégorisation de cette absence de prononciation
    local category_lang = lang_name and ('en ' .. lang_name) or 'sans langue précisée'
    local category_name = 'Prononciations '
    if is_audio_linked then
      category_name = category_name .. 'phonétiques'
    end
    category_name = category_name .. ' manquantes ' .. category_lang
    local category = m_bases.fait_categorie_contenu('Wiktionnaire:' .. category_name)
    if category then
      text = text .. category
    end
  elseif pron ~= '-' then
    -- Page d’aide de la prononciation dans la langue donnée
    local pron_page = export.page_pron(lang_code) or export.racine_pron
    -- On affiche la prononciation avec le lien vers la page d’aide
    text = '[[' .. pron_page .. '|<span class="API" title="Prononciation API">' .. delimiter1 .. pron .. delimiter2 .. '</span>]]'
  end

  return text
end

--- Extrait les paramètres de l’objet frame.
--- Lance une erreur si les paramètres ne sont pas corrects, sauf si uniquement la langue est erronée ou absente.
--- @param frame table le 1er paramètre est la prononciation en API, le 2e le code de la langue
--- @return table|nil,boolean les paramètres si la langue est correcte, nil sinon ; un booléen indiquant si la langue est correctement renseignée
local function get_params(frame)
  local params = {
    [1] = { required = true, allow_empty = true },
    [2] = { required = true },
    ["pron"] = { alias_of = 1 },
    ["lang"] = { alias_of = 2 },
  }
  local args, success = m_params.process(frame:getParent().args, params, true)
  if success then
    return { args[1], args[2] }, true
  elseif args[1] == 2 and (args[2] == m_params.EMPTY_PARAM or args[2] == m_params.MISSING_PARAM) then
    return nil, false
  end
  error(args[3])
end

--- Fonction qui récupère les paramètres de l’objet frame et retourne la pronoctiation formatée.
--- @param frame table le 1er paramètre est la prononciation en API, le 2e le code de la langue
--- @param delimiters string les délimiteurs ("[]", "//" ou "\\")
--- @return string la prononciation formatée
local function pronunciation(frame, delimiters)
  local args, success = get_params(frame)
  local api_pron = ""
  local lang_code = ""

  if success then
    api_pron = args[1]
    lang_code = args[2]
  end

  return export.lua_pron(api_pron, lang_code, delimiters)
end

--- Fonction destinée à être utilisée directement depuis le modèle pron.
--- @param frame table le 1er paramètre est la prononciation en API, le 2e le code de la langue
function export.pron(frame)
  -- Rimes
  --    local extra = ""
  --    local cat_rimes = m_rimes.get_categorie(texte_api)
  --    if m_bases.page_principale() and code_lang == 'fr' and cat_rimes and cat_rimes ~= '' then
  --      extra = '[[' .. cat_rimes .. ']]'
  --      local cat_rimes_missing = ""
  --      if not m_bases.page_existe(cat_rimes) then
  --        extra = extra .. "[[Catégorie:Pages sans catégorie de rimes]]"
  --      end
  --    end

  -- Prononciation entre barres contre-obliques
  return pronunciation(frame, '\\\\')
end

--- Fonction destinée à être utilisée directement depuis le modèle phon.
--- @param frame table le 1er paramètre est la prononciation en API, le 2e le code de la langue
function export.phon(frame)
  -- Prononciation entre crochets
  return pronunciation(frame, '[]')
end

--- Fonction destinée à être utilisée directement depuis le modèle phono.
--- @param frame table le 1er paramètre est la prononciation en API, le 2e le code de la langue
function export.phono(frame)
  -- Prononciation entre barres obliques
  return pronunciation(frame, '//')
end

--- Fonction destinée à être utilisée directement depuis le modèle écouter.
--- @param frame table Paramètres :
--- 1 = pays/région
--- 2 ou pron = prononciation en API
--- 3 ou lang = code ISO de la langue (obligatoire)
--- audio = nom du fichier audio (sans le préfixe File:)
--- titre = texte prononcé si différent du mot vedette
function export.pron_reg(frame)
  local params = {
    [1] = { default = '<small>(Région à préciser)</small>' },
    [2] = {},
    [3] = { required = true },
    ["pron"] = { alias_of = 2 },
    ["lang"] = { alias_of = 3 },
    ["audio"] = {},
    ["titre"] = { default = mw.title.getCurrentTitle().text },
  }
  local args = m_params.process(frame:getParent().args, params)
  local country = args[1]
  local pron = args[2]
  local lang_code = args[3]
  local audio_file = args["audio"]
  local title = args["titre"]

  -- Génération du wikicode
  local text = country .. ' : '

  if pron or audio_file then
    if audio_file and audio_file ~= '' then
      text = text .. 'écouter « ' .. title
      if lang_code and mw.title.getCurrentTitle().namespace == 0 then
        local lang_name = m_langues.get_nom(lang_code)
        if lang_name then
          text = text .. '[[Catégorie:Prononciations audio en ' .. lang_name .. ']]'
        else
          text = text .. '[[Catégorie:Prononciations audio sans langue précisée]]'
        end
      end
      text = text .. ' ' .. export.lua_pron(pron, lang_code, '[]', true)
      text = text .. ' »[[File:' .. audio_file .. ']]'
    else
      text = text .. export.lua_pron(pron, lang_code, '[]', true)
    end
  else
    text = text .. '<small>merci de préciser une prononciation phonétique ou un fichier audio (voir la [[Modèle:écouter|notice]])</small>'
  end

  return text
end

--- Fonction destinée à être utilisée directement depuis le modèle h aspiré.
--- Pour les paramètres, voir la doc du modèle h_aspiré (c'est un peu compliqué).
function export.h_aspire(frame)
  local params = {
    ["nocat"] = { type = "boolean" },
  }
  local args = m_params.process(frame:getParent().args, params)
  local nocat = args["nocat"]
  local txt = '<sup style="font-size:83.33%;line-height:1"><small>([[h aspiré]])</small></sup>'

  -- catégorisation si dans "principal" (namespace = 0)
  if mw.title.getCurrentTitle().namespace == 0 and not nocat then
    txt = txt .. '[[Catégorie:Termes en français à h aspiré]]'
  end

  return txt
end

return export
