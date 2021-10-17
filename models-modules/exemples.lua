local m_params = require("Module:paramètres")
local m_bases = require("Module:bases")
local m_langs = require("Module:langues")
local m_unicode = require("Module:données Unicode")

local p = {}

--- Formats an example.
--- @param text string The quoted text.
--- @param transcription string The text’s transcription if it uses another script than Latin.
--- @param meaning string The translation in French.
--- @param source string The quote’s source (without {{source}} template).
--- @param link string The link to the source (requires source parameter).
--- @param heading string The characters to add before the translation (usually #*).
--- @param lang string The quote’s language code.
--- @param scriptLang string The language code for the script.
--- @param frame table The frame object for expanding templates.
--- @return string The wikicode.
local function _formatExample(text, transcription, meaning, source, link, heading, lang, scriptLang, disableTranslation, frame)
  if not text then
    return mw.ustring.format(
        [=[<span class="example">''[[Aide:Exemples|Exemple d’utilisation]] manquant.'' <span class="plainlinks stubedit">([%s Ajouter])</span><!--
        --><span lang="%s" style="display: none"><!-- Balise de marquage pour le gadget wikt.add-examples, ne pas retirer ! --></span></span><!--
        -->[[Catégorie:Wiktionnaire:Exemples manquants en %s]]]=],
        mw.title.getCurrentTitle():fullUrl({ action = "edit" }), lang, m_langs.get_nom(lang)
    )
  end

  local italics = m_unicode.shouldItalicize(text) and "''" or ""
  local wikicode = m_bases.balise_langue(italics .. m_unicode.setWritingDirection(text) .. italics, scriptLang)

  if source then
    wikicode = wikicode .. " " .. frame:expandTemplate { title = "source", args = { source, lien = link } }
  end

  wikicode = mw.ustring.format('<span class="example">%s</span>', wikicode)

  if lang ~= "fr" then
    if transcription then
      wikicode = wikicode .. "<br/>" .. m_bases.balise_langue("''" .. transcription .. "''", scriptLang .. "-Latn")
    end
  end

  if disableTranslation then
    wikicode = wikicode .. m_bases.fait_categorie_contenu(
        mw.ustring.format("Exemples en %s avec traduction désactivée", m_langs.get_nom(lang)))
  else
    local translation
    if meaning then
      translation = meaning
    elseif lang ~= "fr" then
      translation = frame:expandTemplate { title = "trad-exe", args = { lang } }
    end
    if translation then
      wikicode = wikicode .. mw.ustring.format("\n%s: ", heading) .. translation
    end
  end

  return wikicode .. m_bases.fait_categorie_contenu("Exemples en " .. m_langs.get_nom(lang))
end

--- Formats an example. Function to call from templates.
--- Throws an error if the language is missing or undefined.
--- Parameters:
---  parent frame.args[1] (string): The quoted text.
---  parent frame.args[2]/frame.args["sens"] (string): The translation in French.
---  parent frame.args[3]/frame.args["tr"] (string): The text’s transcription if it uses another script than Latin.
---  parent frame.args["source"] (string): The quote’s source (without {{source}} template).
---  parent frame.args["lien"] (string): The link to the source.
---  parent frame.args["tête"] (string): The characters to add before the translation (usually #*).
---  parent frame.args["lang"] (string): The quote’s language code.
--- @return string The wikicode.
function p.formatExample(frame)
  local parentFrame = frame:getParent()
  local args = m_params.process(parentFrame.args, {
    [1] = {},
    ["sens"] = {},
    [2] = { alias_of = "sens" },
    ["tr"] = {},
    [3] = { alias_of = "tr" },
    ["source"] = {},
    ["lien"] = {},
    ["tête"] = { default = "#*" },
    ["lang"] = { required = true, checker = function(lang)
      return m_langs.specialCodes[lang] ~= nil or m_langs.get_nom(lang) ~= nil
    end },
    ["pas-trad"] = { type = m_params.BOOLEAN, default = false }
  })

  local scriptLang = args["lang"]
  local lang = m_langs.specialCodes[args["lang"]] or args["lang"]

  return _formatExample(args[1], args["tr"], args["sens"], args["source"], args["lien"], args["tête"], lang, scriptLang, args["pas-trad"], parentFrame)
end

return p
