local m_params = require("Module:paramètres")
local m_ga_common = require("Module:ga-common")

local export = {}

local function replace(forms, param)
  local form = forms[param]
  if param ~= "normal" and form == forms["normal"] then
    return "''pas applicable''"
  end

  local ret = "[[" .. form .. "#ga|" .. form .. "]]"

  if param == "len" and forms.an ~= forms.normal then
    ret = ret .. "<br/>''après an'', [[" .. forms.an .. "#ga|" .. forms.an .. "]]"
  end

  return ret
end

local table_cons = [=[
{| border="1" cellpadding="4" cellspacing="0" class="inflection-table" style="align: left; margin: 0.5em 0 0 0; border-style: solid; border: 1px solid #7f7f7f; border-right-width: 2px; border-bottom-width: 2px; border-collapse: collapse; background-color: #F8F8F8; font-size: 95%;"
|-
! colspan="3" | [[Annexe:Mutation en gaélique irlandais|Mutation en gaélique irlandais]]
|-
! Radical
! [[w:Lénition|Lénition]]
! [[w:Éclipse (linguistique)|Éclipse]]
|-
| {{{normal}}}
| {{{len}}}
| {{{ecl}}}
|-
| colspan="3" | <small style="font-size:85%;">''Note :'' Toutes les formes mutées d'un mot ne sont pas nécessairement utilisées.</small>
|}]=]

function export.mut_cons(frame)
  local params = {
    [1] = { required = true, default = "{{{1}}}" },
    [2] = { required = true, default = "{{{2}}}" },
  }

  local args = m_params.process(frame:getParent().args, params)
  local forms = m_ga_common.mutations(args[1] .. args[2])

  return (mw.ustring.gsub(table_cons, "{{{([a-z0-9_]+)}}}", function(param)
    return replace(forms, param)
  end))
end

local table_vowel = [=[
{| border="1" cellpadding="4" cellspacing="0" class="inflection-table" style="align: left; margin: 0.5em 0 0 0; border-style: solid; border: 1px solid #7f7f7f; border-right-width: 2px; border-bottom-width: 2px; border-collapse: collapse; background-color: #F8F8F8; font-size: 95%;"
|-
! colspan="4" | [[Annexe:Mutation en gaélique irlandais|Mutation en gaélique irlandais]]
|-
! Radical !! [[w:Éclipse (linguistique)|Éclipse]] !! [[w:Prothèse (linguistique)|Prothèse]] en « h » !! [[w:Prothèse (linguistique)|Prothèse]] en « t »
|-
| {{{normal}}}
| {{{ecl}}}
| {{{hpro}}}
| {{{tpro}}}
|-
| colspan="4" | <small style="font-size:85%;">''Note :'' Toutes les formes mutées d'un mot ne sont pas nécessairement utilisées.</small>
|}]=]

function export.mut_vowel(_)
  local forms = m_ga_common.mutations(mw.title.getCurrentTitle().subpageText, "msn")

  return (mw.ustring.gsub(table_vowel, "{{{([a-z0-9_]+)}}}", function(param)
    return replace(forms, param)
  end))
end

function export.mut(frame)
  local params = {
    [1] = {},
    ["rad"] = {}
  }

  local args = m_params.process(frame:getParent().args, params)
  local word = mw.title.getCurrentTitle().subpageText
  if args["rad"] then
    word = args["rad"]
  end
  local forms = m_ga_common.mutations(word, args[1])
  local wikicode = mw.ustring.find(mw.ustring.lower(word), "^[aeiouáéíóú]") and table_vowel or table_cons

  return (mw.ustring.gsub(wikicode, "{{{([a-z_]+)}}}", function(param)
    return replace(forms, param)
  end))
end

return export
