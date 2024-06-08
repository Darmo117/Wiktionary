local m_params = require("Module:paramètres")
local m_table = require("Module:table")
local m_model = require("Module:conjugaisons/data-model")
local m_gen = require("Module:conjugaisons/tense-generators")

local p = {}

local GRAY_STYLE = "color: gray; font-style: italic"

--- Generate a wikicode link with a #fr anchor for the given page title.
--- @param title string The title of the page to link to.
--- @return string The link.
local function link(title)
  return mw.ustring.format("[[%s#fr|%s]]", title, title)
end

--- Create an HTML table element with a width of 100%, center-aligned text and collapsed borders.
--- @return html The table element.
local function createTable()
  return mw.html.create("table")
           :attr("style", "width: 100%; text-align: center; border-collapse: collapse")
end

--- Format a title.
--- @param base string The base title.
--- @param tense VerbTense|VerbMode The verb tense/mode this title represents.
--- @return string The formatted header.
local function formatTitle(base, tense)
  local state = tense:getStatus()
  if state then
    local text
    if state == m_model.DISABLED then
      text = "défectif"
    elseif state == m_model.RARE then
      text = "rare"
    else
      error("État invalide : " .. state)
    end
    return base .. mw.ustring.format(" (%s)", state)
  end
  return base
end

--- Add an HTML TR tag to the given header.
--- @param headerRow html The parent tag.
--- @param tense VerbTense The tense this header represents.
--- @param title string The header’s title.
--- @param color string The header’s background color.
--- @param width number The header’s width in %.
--- @param colspan number Optional. The header’s "colspan", defaults to 2.
local function createTenseTableHeader(headerRow, tense, title, color, width, colspan)
  local style = mw.ustring.format("width: %d%%; background-color: %s;", width, color)
  if tense:isGray() then
    style = style .. GRAY_STYLE
  end
  local element = headerRow
      :tag("th")
      :attr("scope", colspan > 2 and "colgroup" or "col")
      :attr("style", style)
      :wikitext(formatTitle(title, tense))
  if colspan > 1 then
    element = element:attr("colspan", tostring(colspan))
  end
  return element
end

--- Format the given verb form.
--- @param verbForm VerbForm The verb form to format.
--- @param asLink boolean Whether to wrap the verb form inside a link.
--- @return string The formatted verb form.
local function formatVerbForm(verbForm, asLink)
  local form = verbForm:getForm()
  if not form then
    return "—"
  end
  return asLink and link(form) or form
end

--- Generate the table for all impersonal tenses for the given verb.
--- @param verb Verb A Verb object.
--- @return string The generated table.
local function generateImpersonalTable(verb)
  local tableElement = createTable()

  local headerRow = tableElement:tag("tr")
  headerRow:tag("th")
           :attr("scope", "col")
           :attr("style", "width: 8%; background-color: #ffddaa")
           :wikitext("[[mode#fr|Mode]]")
  headerRow:tag("th")
           :attr("scope", "colgroup")
           :attr("style", "width: 46%; background-color: #ffeebb")
           :wikitext("[[présent#fr|Présent]]")
  headerRow:tag("th")
           :attr("scope", "colgroup")
           :attr("style", "width: 46%; background-color: #ffeebb")
           :wikitext("[[passé#fr|Passé]]")

  local infinitifPresent = verb.modes["infinitif"].tenses["present"].forms[1]
  local infinitifPasse = verb.modes["infinitif"].tenses["passe"].forms[1]
  local gerondifPresent = verb.modes["gerondif"].tenses["present"].forms[1]
  local gerondifPasse = verb.modes["gerondif"].tenses["passe"].forms[1]
  local participePresent = verb.modes["participe"].tenses["present"].forms[1]
  local participePasse = verb.modes["participe"].tenses["passe"].forms[1]

  local infinitiveRow = tableElement:tag("tr")
  infinitiveRow:tag("th")
               :attr("scope", "row")
               :wikitext("[[infinitif#fr|Infinitif]]")
  infinitiveRow:tag("td")
               :attr("style", "width: 23%; text-align: right; padding-right: 0")
               :wikitext(infinitifPresent:getPronoun() or "")
  infinitiveRow:tag("td")
               :attr("style", "width: 23%; text-align: left; padding-left: 0")
               :wikitext(formatVerbForm(infinitifPresent:getForm(), true))
  infinitiveRow:tag("td")
               :attr("style", "width: 23%; text-align: right; padding-right: 0;" .. (infinitifPasse:isGray() and GRAY_STYLE or ""))
               :wikitext(infinitifPasse:getPronoun() or "")
  infinitiveRow:tag("td")
               :attr("style", "width: 23%; text-align: left; padding-left: 0;" .. (infinitifPasse:isGray() and GRAY_STYLE or ""))
               :wikitext(formatVerbForm(infinitifPasse:getForm()))

  local gerundRow = tableElement:tag("tr")
  gerundRow:tag("th")
           :attr("scope", "row")
           :wikitext("[[gérondif#fr|Gérondif]]")
  gerundRow:tag("td")
           :attr("style", "text-align: right; padding-right: 0;" .. (gerondifPresent:isGray() and GRAY_STYLE or ""))
           :wikitext(gerondifPresent:getPronoun() or "")
  gerundRow:tag("td")
           :attr("style", "text-align: left; padding-left: 0;" .. (gerondifPresent:isGray() and GRAY_STYLE or ""))
           :wikitext(formatVerbForm(gerondifPresent:getForm()))
  gerundRow:tag("td")
           :attr("style", "text-align: right; padding-right: 0;" .. (gerondifPasse:isGray() and GRAY_STYLE or ""))
           :wikitext(gerondifPasse:getPronoun() or "")
  gerundRow:tag("td")
           :attr("style", "text-align: left; padding-left: 0;" .. (gerondifPasse:isGray() and GRAY_STYLE or ""))
           :wikitext(formatVerbForm(gerondifPasse:getForm()))

  local participleRow = tableElement:tag("tr")
  participleRow:tag("th")
               :attr("scope", "row")
               :wikitext("[[participe#fr|Participe]]")
  participleRow:tag("td")
  participleRow:tag("td")
               :attr("style", "text-align: left;" .. (participePresent:isGray() and GRAY_STYLE or ""))
               :wikitext(formatVerbForm(participePresent:getForm(), true))
  participleRow:tag("td")
  participleRow:tag("td")
               :attr("style", "text-align: left;" .. (participePasse:isGray() and GRAY_STYLE or ""))
               :wikitext(formatVerbForm(participePasse:getForm(), true))

  return tostring(tableElement)
end

--- Generate the rows for the given simple tense and its corresponding compound tense.
--- @param tableElement html The table element to add the generated rows to.
--- @param verb Verb An array containing the flexions of the verb.
--- @param mode string The key of the mode.
--- @param simpleTenseName string The key of the simple tense.
--- @param title1 string Title for the simple tense.
--- @param compoundTenseName string The key of the compound tense.
--- @param title2 string Title for the compound tense.
local function generateTensesRows(tableElement, verb, mode, simpleTenseName, title1, color1, compoundTenseName, title2, color2)
  local headerRow = tableElement:tag("tr")

  local simpleTense = verb.modes[mode].tenses[simpleTenseName]
  local compoundTense = verb.modes[mode].tenses[compoundTenseName]

  local reversedPronouns = simpleTense.mode.reversedPronouns
  local colsNb = reversedPronouns and not verb.spec.pronominal and 1 or 2

  createTenseTableHeader(headerRow, simpleTense, title1, color1, 50, colsNb)
  createTenseTableHeader(headerRow, compoundTense, title2, color2, 50, colsNb)

  for i = 1, #simpleTense.forms do
    local row = tableElement:tag("tr")

    local simpleForm = simpleTense.forms[i]
    local compoundForm = compoundTense.forms[i]
    local simpleStyle = simpleForm:isGray() and GRAY_STYLE or ""
    local compoundStyle = compoundForm:isGray() and GRAY_STYLE or ""

    local formattedSimpleForm = formatVerbForm(simpleForm:getForm(), true)
    local formattedCompoundForm = formatVerbForm(compoundForm:getForm())

    if colsNb == 2 then
      local simplePronoun = simpleForm:getPronoun() or ""
      local compoundPronoun = compoundForm:getPronoun() or ""

      row:tag("td")
         :attr("style", "width: 25%; text-align: right; padding-right: 0;" .. simpleStyle)
         :wikitext(reversedPronouns and formattedSimpleForm or simplePronoun)
      row:tag("td")
         :attr("style", "width: 25%; text-align: left; padding-left: 0;" .. simpleStyle)
         :wikitext(reversedPronouns and simplePronoun and formattedSimpleForm)

      row:tag("td")
         :attr("style", "width: 25%; text-align: right; padding-right: 0;" .. compoundStyle)
         :wikitext(reversedPronouns and formattedCompoundForm or compoundPronoun)
      row:tag("td")
         :attr("style", "width: 25%; text-align: left; padding-left: 0;" .. compoundStyle)
         :wikitext(reversedPronouns and compoundPronoun or formattedCompoundForm)
    else
      row:tag("td")
         :attr("style", simpleStyle)
         :wikitext(formattedSimpleForm)
      row:tag("td")
         :attr("style", compoundStyle)
         :wikitext(formattedCompoundForm)
    end
  end
end

--- Generate the table for the indicative tenses of the given verb.
--- @param verb Verb A Verb object.
--- @return string The generated table.
local function generateIndicativeTable(verb)
  local tableElement = createTable()
  generateTensesRows(tableElement, verb, "indicatif", "present", "Présent", "#ddd", "passeCompose", "Passé composé", "#ececff")
  generateTensesRows(tableElement, verb, "indicatif", "imparfait", "Imparfait", "#ddd", "plusQueParfait", "Plus-que-parfait", "#ececff")
  generateTensesRows(tableElement, verb, "indicatif", "passeSimple", "Passé simple", "#ddd", "passeAnterieur", "Passé antérieur", "#ececff")
  generateTensesRows(tableElement, verb, "indicatif", "futur", "Futur simple", "#ddd", "futurAnterieur", "Futur antérieur", "#ececff")
  return tostring(tableElement)
end

--- Generate the table for the subjunctive tenses of the given verb.
--- @param verb Verb A Verb object.
--- @return string The generated table.
local function generateSubjunctiveTable(verb)
  local tableElement = createTable()
  generateTensesRows(tableElement, verb, "subjonctif", "present", "Présent", "#ddd", "passe", "Passé", "#fec")
  generateTensesRows(tableElement, verb, "subjonctif", "imparfait", "Imparfait", "#ddd", "plusQueParfait", "Plus-que-parfait", "#fec")
  return tostring(tableElement)
end

--- Generate the table for the conditional tenses of the given verb.
--- @param verb Verb A Verb object.
--- @return string The generated table.
local function generateConditionalTable(verb)
  local tableElement = createTable()
  generateTensesRows(verb, "conditionnel", "present", "Présent", "#ddd", "passe", "Passé", "#cfc")
  return tostring(tableElement)
end

--- Generate the table for the imperative tenses of the given verb.
--- @param verb Verb A Verb object.
--- @return string The generated table.
local function generateImperativeTable(verb)
  local tableElement = createTable()
  generateTensesRows(verb, "imperatif", "present", "Présent", "#ffe5e5", "passe", "Passé", "#ffe5e5")
  return tostring(tableElement)
end

--- Format the given verb group as a link.
--- Throws an error if the group is different than 1, 2 or 3.
--- @param group number The verb group.
--- @return string The generated link.
local function formatGroup(group)
  local res = "[[Conjugaison:français/"
  if group == 1 then
    res = res .. "Premier groupe|1<sup>er</sup>"
  elseif group == 2 then
    res = res .. "Deuxième groupe|2<sup>e</sup>"
  elseif group == 3 then
    res = res .. "Troisième groupe|3<sup>e</sup>"
  else
    error("Groupe invalide : " .. tostring(group))
  end
  return res .. " groupe]]"
end

--- Render the full page for the given verb.
--- @param verb Verb A Verb object.
--- @param group number The verb’s group, either 1, 2 or 3.
--- @return string The generated wikicode.
local function renderPage(verb, group)
  local page = mw.html.create()

  local inf = verb.modes["infinitif"].tenses["present"].forms[1]
  page:wikitext(mw.ustring.format(
      "Conjugaison de '''%s''', ''verbe %s du %s, conjugé avec l’auxiliaire %s''.",
      link((inf:getPronoun() or "") .. inf:getForm()),
      verb.spec.pronominal and "pronominal" or "",
      formatGroup(group), link(verb.spec.auxEtre and "être" or "avoir")
  ))

  page:tag("h3")
      :wikitext(formatTitle("Modes impersonnels"))
  page:tag("div")
      :attr("style", "margin: 0.5em 2em")
      :wikitext(generateImpersonalTable(verb))

  page:tag("h3")
      :wikitext("Indicatif")
  page:tag("div")
      :attr("style", "margin: 0.5em 2em")
      :wikitext(generateIndicativeTable(verb))

  page:tag("h3")
      :wikitext("Subjonctif")
  page:tag("div")
      :attr("style", "margin: 0.5em 2em")
      :wikitext(generateSubjunctiveTable(verb))

  page:tag("h3")
      :wikitext("Conditionnel")
  page:tag("div")
      :attr("style", "margin: 0.5em 2em")
      :wikitext(generateConditionalTable(verb))

  page:tag("h3")
      :wikitext("Impératif")
  page:tag("div")
      :attr("style", "margin: 0.5em 2em")
      :wikitext(generateImperativeTable(verb))

  return tostring(page)
end

local modeAbbreviations = {
  part = "participe",
  ind = "indicatif",
  subj = "subjonctif",
  cond = "conditionnel",
  imp = "imperatif",
}
local tenseAbbreviations = {
  pr = "present",
  p = "passe",
  i = "imparfait",
  ps = "passeSimple",
  f = "futur",
  pc = "passeCompose",
  pa = "passeAnterieur",
  pqp = "plusQueParfait",
  fa = "futurAnterieur",
}

--- Parse the arguments of the form "<mode>.<tense>[.<person>]" and "<mode>[.<tense>[.<person>]].état".
--- @param aspiratedH boolean Whether the initial "h" of the verb should prevent a liaison.
--- @param pronominal boolean Whether the verb is pronominal.
--- @param auxEtre boolean Whether the verb should use the verb "être" instead of "avoir" as its auxiliary.
--- @param args table The parsed frame arguments.
--- @return VerbSpec A VerbSpec object.
local function parseSpecs(aspiratedH, pronominal, auxEtre, args)
  local function personToIndex(mode, person)
    if mode == "imp" then
      if person == "2s" then
        return 1
      elseif person == "1p" then
        return 2
      elseif person == "2p" then
        return 3
      end
    end
    return tonumber(mw.ustring.sub(person, 1, 1))
        + (mw.ustring.sub(person, 2, 2) == "s" and 0 or 3)
  end

  --- @type VerbSpec
  local spec = m_model.newVerbSpec(aspiratedH, pronominal, auxEtre)

  for k, v in pairs(args) do
    if mw.ustring.find(k, ".", 1, true) then
      local parts = mw.text.split(k, ".", true)
      local nb = #parts

      if parts[nb] == "état" then
        table.remove(parts, nb)
        nb = nb - 1
        local node = spec
        for i, part in ipairs(parts) do
          if i < nb then
            if i == 1 then
              node = node.modeSpecs[modeAbbreviations[part]]
            else
              node = node.tenseSpecs[tenseAbbreviations[part]]
            end
          end
        end
        if mw.ustring.match(parts[nb], "[123][sp]") then
          node.formSpecs[personToIndex(parts[1], parts[nb])].status = v
        else
          if modeAbbreviations[parts[nb]] then
            node.modeSpecs[modeAbbreviations[parts[nb]]].status = v
          else
            node.tenseSpecs[tenseAbbreviations[parts[nb]]].status = v
          end
        end

      else
        local node = spec
        for i, part in ipairs(parts) do
          if i < nb then
            if i == 1 then
              node = node.modeSpecs[modeAbbreviations[part]]
            else
              node = node.tenseSpecs[tenseAbbreviations[part]]
            end
          end
        end
        if mw.ustring.match(parts[nb], "[123][sp]") then
          node.formSpecs[personToIndex(parts[1], parts[nb])].form = v
        else
          node.tenseSpecs[tenseAbbreviations[parts[nb]]].formSpecs[1].form = v
        end
      end

    end
  end

  return spec
end

--- Render the conjugation tables for the given verb.
--- Parameters:
---  frame.args[1] (string): The verb in its infinitive present form.
---  frame.args["aux-être"] (boolean): Optional. If true, use the “être” auxiliary instead of “avoir”.
---  frame.args["groupe3"] (boolean): Optional. If true, the verb will be classified as belonging to group 3.
---  frame.args["pronominal"] (boolean): Optional. Whether the verb is reflexive.
---  frame.args["mutation"] (string): Optional. The type of mutation to apply to the verb’s root instead of the default one.
---  frame.args["modèle"] (string): Optional. For group-3 verbs, the verb to use as a template instead of the detected one.
---  frame.args["h-aspiré"] (boolean): Optional. If true, contracted pronoun forms will be used where relevant.
--- @return string The generated wikicode.
function p.conj(frame)
  -- TODO autres fonctionnalités :
  -- * spécifier flexions entières
  -- * modes/temps/personnes défectives/rares
  -- * verbes impersonnels (singulier + pluriel et seulement singulier)
  -- * verbes doubles/triples (ex : [[moissonner-battre]], [[copier-coller-voler]]), pas de groupe pour ceux comportant plusieurs groupes différents
  local templates = m_table.keysToList(m_gen.group3Templates)
  table.insert(templates, "-")
  local flexionStates = m_model.STATES

  -- TODO utiliser frame:getParent().args pour récupérer les arguments du modèle
  local args = m_params.process(frame.args, {
    [1] = { default = mw.title.getCurrentTitle().text }, -- TODO extraire le verbe du titre "<langue>/<verbe>"
    ["aux-être"] = { type = m_params.BOOLEAN, default = false },
    ["groupe3"] = { type = m_params.BOOLEAN, default = false },
    ["pronominal"] = { type = m_params.BOOLEAN, default = false },
    ["mutation"] = { enum = m_gen.mutationTypes },
    ["modèle"] = { enum = templates },
    ["h-aspiré"] = { type = m_params.BOOLEAN, default = false },

    -- Full forms and defective tenses

    -- Participes
    ["part.état"] = {},
    -- Participe présent
    ["part.pr"] = {},
    ["part.pr.état"] = {},
    -- Participe passé
    ["part.p"] = {},
    ["part.p.état"] = {},

    -- Indicatif
    ["ind.état"] = { enum = flexionStates },
    -- Indicatif présent
    ["ind.pr.1s"] = {},
    ["ind.pr.2s"] = {},
    ["ind.pr.3s"] = {},
    ["ind.pr.1p"] = {},
    ["ind.pr.2p"] = {},
    ["ind.pr.3p"] = {},
    ["ind.pr.état"] = { enum = flexionStates },
    ["ind.pr.1s.état"] = { enum = flexionStates },
    ["ind.pr.2s.état"] = { enum = flexionStates },
    ["ind.pr.3s.état"] = { enum = flexionStates },
    ["ind.pr.1p.état"] = { enum = flexionStates },
    ["ind.pr.2p.état"] = { enum = flexionStates },
    ["ind.pr.3p.état"] = { enum = flexionStates },
    -- Indicatif imparfait
    ["ind.i.1s"] = {},
    ["ind.i.2s"] = {},
    ["ind.i.3s"] = {},
    ["ind.i.1p"] = {},
    ["ind.i.2p"] = {},
    ["ind.i.3p"] = {},
    ["ind.i.état"] = { enum = flexionStates },
    ["ind.i.1s.état"] = { enum = flexionStates },
    ["ind.i.2s.état"] = { enum = flexionStates },
    ["ind.i.3s.état"] = { enum = flexionStates },
    ["ind.i.1p.état"] = { enum = flexionStates },
    ["ind.i.2p.état"] = { enum = flexionStates },
    ["ind.i.3p.état"] = { enum = flexionStates },
    -- Indicatif passé simple
    ["ind.ps.1s"] = {},
    ["ind.ps.2s"] = {},
    ["ind.ps.3s"] = {},
    ["ind.ps.1p"] = {},
    ["ind.ps.2p"] = {},
    ["ind.ps.3p"] = {},
    ["ind.ps.état"] = { enum = flexionStates },
    ["ind.ps.1s.état"] = { enum = flexionStates },
    ["ind.ps.2s.état"] = { enum = flexionStates },
    ["ind.ps.3s.état"] = { enum = flexionStates },
    ["ind.ps.1p.état"] = { enum = flexionStates },
    ["ind.ps.2p.état"] = { enum = flexionStates },
    ["ind.ps.3p.état"] = { enum = flexionStates },
    -- Indicatif futur
    ["ind.f.1s"] = {},
    ["ind.f.2s"] = {},
    ["ind.f.3s"] = {},
    ["ind.f.1p"] = {},
    ["ind.f.2p"] = {},
    ["ind.f.3p"] = {},
    ["ind.f.état"] = { enum = flexionStates },
    ["ind.f.1s.état"] = { enum = flexionStates },
    ["ind.f.2s.état"] = { enum = flexionStates },
    ["ind.f.3s.état"] = { enum = flexionStates },
    ["ind.f.1p.état"] = { enum = flexionStates },
    ["ind.f.2p.état"] = { enum = flexionStates },
    ["ind.f.3p.état"] = { enum = flexionStates },
    -- Indicatif passé composé
    ["ind.pc.état"] = { enum = flexionStates },
    -- Indicatif passé antérieur
    ["ind.pa.état"] = { enum = flexionStates },
    -- Indicatif plus-que-parfait
    ["ind.pqp.état"] = { enum = flexionStates },
    -- Indicatif futur antérieur
    ["ind.fa.état"] = { enum = flexionStates },

    -- Subjonctif
    ["subj.état"] = { enum = flexionStates },
    -- Subjonctif présent
    ["subj.pr.1s"] = {},
    ["subj.pr.2s"] = {},
    ["subj.pr.3s"] = {},
    ["subj.pr.1p"] = {},
    ["subj.pr.2p"] = {},
    ["subj.pr.3p"] = {},
    ["subj.pr.état"] = { enum = flexionStates },
    ["subj.pr.1s.état"] = { enum = flexionStates },
    ["subj.pr.2s.état"] = { enum = flexionStates },
    ["subj.pr.3s.état"] = { enum = flexionStates },
    ["subj.pr.1p.état"] = { enum = flexionStates },
    ["subj.pr.2p.état"] = { enum = flexionStates },
    ["subj.pr.3p.état"] = { enum = flexionStates },
    -- Subjonctif imparfait
    ["subj.imp.1s"] = {},
    ["subj.imp.2s"] = {},
    ["subj.imp.3s"] = {},
    ["subj.imp.1p"] = {},
    ["subj.imp.2p"] = {},
    ["subj.imp.3p"] = {},
    ["subj.imp.état"] = { enum = flexionStates },
    ["subj.imp.1s.état"] = { enum = flexionStates },
    ["subj.imp.2s.état"] = { enum = flexionStates },
    ["subj.imp.3s.état"] = { enum = flexionStates },
    ["subj.imp.1p.état"] = { enum = flexionStates },
    ["subj.imp.2p.état"] = { enum = flexionStates },
    ["subj.imp.3p.état"] = { enum = flexionStates },
    -- Subjonctif passé
    ["subj.p.état"] = { enum = flexionStates },
    -- Subjonctif plus-que-parfait
    ["subj.pqp.état"] = { enum = flexionStates },

    -- Conditionnel
    ["cond.état"] = { enum = flexionStates },
    -- Conditionnel présent
    ["cond.pr.1s"] = {},
    ["cond.pr.2s"] = {},
    ["cond.pr.3s"] = {},
    ["cond.pr.1p"] = {},
    ["cond.pr.2p"] = {},
    ["cond.pr.3p"] = {},
    ["cond.pr.état"] = { enum = flexionStates },
    ["cond.pr.1s.état"] = { enum = flexionStates },
    ["cond.pr.2s.état"] = { enum = flexionStates },
    ["cond.pr.3s.état"] = { enum = flexionStates },
    ["cond.pr.1p.état"] = { enum = flexionStates },
    ["cond.pr.2p.état"] = { enum = flexionStates },
    ["cond.pr.3p.état"] = { enum = flexionStates },
    -- Conditionnel passé
    ["cond.p.état"] = { enum = flexionStates },

    -- Impératif
    ["imp.état"] = { enum = flexionStates },
    -- Impératif présent
    ["imp.pr.2s"] = {},
    ["imp.pr.1p"] = {},
    ["imp.pr.2p"] = {},
    ["imp.pr.état"] = { enum = flexionStates },
    ["imp.pr.2s.état"] = { enum = flexionStates },
    ["imp.pr.1p.état"] = { enum = flexionStates },
    ["imp.pr.2p.état"] = { enum = flexionStates },
    -- Impératif passé
    ["imp.p.état"] = { enum = flexionStates },
  })

  local infinitive = args[1]
  local pronominal = args["pronominal"]
  local auxEtre = args["aux-être"]
  local group3 = args["groupe3"]
  local mutationType = args["mutation"]
  local template = args["modèle"]
  local aspiratedH = args["h-aspiré"]
  if aspiratedH and mw.ustring.sub(infinitive, 1, 1) ~= "h" then
    error(mw.ustring.format('Le verbe "%s" ne commence pas par un "h"', infinitive))
  end

  local spec = parseSpecs(aspiratedH, pronominal, auxEtre, args)
  local verb, group = m_gen.generateFlexions(infinitive, group3, mutationType, template, spec)
  return renderPage(verb, group, spec)
end

return p
