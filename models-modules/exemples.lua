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
--- @param heading string The characters to add before the translation (usually #*).
--- @param lang string The quote’s language code.
--- @param scriptLang string The language code for the script.
--- @param frame table The frame object for expanding templates.
--- @return string The wikicode.
local function _example(text, transcription, meaning, source, heading, lang, scriptLang, frame)
  if not text then
    return frame:expandTemplate { title = "ébauche-exe", args = { lang } }
  end

  local isLatin = m_unicode.textHasScript(text, "Latin")
  local italics = isLatin and "''" or ""
  local wikicode = m_bases.balise_langue(italics .. text .. italics, scriptLang)

  if source then
    wikicode = wikicode .. " " .. frame:expandTemplate { title = "source", args = { source } }
  end

  if lang ~= "fr" then
    if transcription then
      wikicode = wikicode .. "<br/>" .. m_bases.balise_langue("''" .. text .. "''", scriptLang .. "-Latn")
    end
    wikicode = wikicode .. mw.ustring.format("\n%s: ", heading)
    if meaning then
      wikicode = wikicode .. meaning
    else
      wikicode = wikicode .. frame:expandTemplate { title = "ébauche-trad-exe", args = { lang } }
    end
  end

  return wikicode
end

--- Formats an example.
--- Parameters:
---  parent frame.args[1] (string): The quoted text.
---  parent frame.args[2]/frame.args["sens"] (string): The translation in French.
---  parent frame.args[3]/frame.args["tr"] (string): The text’s transcription if it uses another script than Latin.
---  parent frame.args["source"] (string): The quote’s source (without {{source}} template).
---  parent frame.args["tête"] (string): The characters to add before the translation (usually #*).
---  parent frame.args["lang"] (string): The quote’s language code.
--- @return string The wikicode.
function p.example(frame)
  local additionalLangCodes = {
    ["zh-Hans"] = "zh",
    ["zh-Hant"] = "zh",
  }

  local actualFrame = frame:getParent()
  local args = m_params.process(actualFrame.args, {
    [1] = {},
    ["sens"] = {},
    [2] = { alias_of = "sens" },
    ["tr"] = {},
    [3] = { alias_of = "tr" },
    ["source"] = {},
    ["tête"] = { default = "#*" },
    ["lang"] = { default = "fr", checker = function(lang)
      return additionalLangCodes[lang] or m_langs.get_nom(lang) ~= nil
    end },
  })

  local scriptLang = args["lang"]
  args["lang"] = additionalLangCodes[args["lang"]] or args["lang"]

  return _example(args[1], args["tr"], args["sens"], args["source"], args["tête"], args["lang"], scriptLang, actualFrame)
end

return p
