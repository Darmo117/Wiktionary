local m_params = require("Module:paramètres")
local m_table = require("Module:table")
local m_gen = require("Module:conjugaisons/tense-generators")

local p = {}

-- TODO distinguer les pronoms des 3èmes personnes
local pronouns = {
  { "je", "j’" }, { "tu", nil }, { "il/elle/on", nil }, { "nous", nil }, { "vous", nil }, { "ils/elles", nil }
}
local reflexivePronouns = {
  { "me", "m’" }, { "te", "t’" }, { "se", "s’" }, { "nous", nil }, { "vous", nil }, { "se", "s’" }
}
local imperativePronouns = { "toi", "nous", "vous" }
local liaisonLetters = { "a", "â", "e", "ê", "é", "è", "ë", "i", "î", "ï", "o", "ô", "u", "û", "y" }
local que = { "que", "qu’" }
local undefined = "—"
local GRAYED_OUT = "rare"
local NON_EXISTENT = "-"
local FLEXION_STATES = {
  GRAYED_OUT, NON_EXISTENT,
}

--- Check whether a liaison is required for the given word.
--- @param s string The word to check.
--- @param aspiratedH boolean Whether a "h" should be ignored for liaison.
--- @return boolean True if a liaison is needed, false otherwise.
local function requiresLiaison(s, aspiratedH)
  local char = mw.ustring.sub(mw.ustring.lower(s), 1, 1)
  return char == "h" and not aspiratedH or m_table.contains(liaisonLetters, char)
end

--- Generate a composed tense using the given auxiliary verb table and past participle.
--- @param auxTable table A table containing flexions of the auxiliary verb.
--- @param pastParticiple string The past participle.
--- @return table A table containing the generated composed tense.
local function generateComposedTense(auxTable, pastParticiple)
  local res = {}
  for _, t in ipairs(auxTable) do
    table.insert(res, t .. " " .. pastParticiple)
  end
  return res
end

--- Complete the given verb table by generating composed tenses with the given auxiliary verb table.
--- @param auxTable table A table containing flexions of the auxiliary verb for all simple tenses.
--- @param verbTable table A table containing flexions of the verb for all simple tenses.
local function completeTable(auxTable, verbTable)
  verbTable.auxiliaire = auxTable.infinitif.present

  if verbTable.participe.present ~= m_gen.EMPTY_OBJECT then
    verbTable.gerondif = {
      present = verbTable.participe.present,
    }
    if verbTable.participe.passe ~= m_gen.EMPTY_OBJECT then
      verbTable.gerondif.passe = auxTable.participe.present .. " " .. verbTable.participe.passe
    end
  end

  if verbTable.participe.passe ~= m_gen.EMPTY_OBJECT then
    verbTable.infinitif.passe = auxTable.infinitif.present .. " " .. verbTable.participe.passe

    verbTable.indicatif.passeCompose = generateComposedTense(auxTable.indicatif.present, verbTable.participe.passe)
    verbTable.indicatif.plusQueParfait = generateComposedTense(auxTable.indicatif.imparfait, verbTable.participe.passe)
    verbTable.indicatif.passeAnterieur = generateComposedTense(auxTable.indicatif.passeSimple, verbTable.participe.passe)
    verbTable.indicatif.futurAnterieur = generateComposedTense(auxTable.indicatif.futur, verbTable.participe.passe)

    verbTable.subjonctif.passe = generateComposedTense(auxTable.subjonctif.present, verbTable.participe.passe)
    verbTable.subjonctif.plusQueParfait = generateComposedTense(auxTable.subjonctif.imparfait, verbTable.participe.passe)

    verbTable.conditionnel.passe = generateComposedTense(auxTable.conditionnel.present, verbTable.participe.passe)

    verbTable.imperatif.passe = generateComposedTense(auxTable.imperatif.present, verbTable.participe.passe)
  end

  return verbTable
end

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

--- Return the pronoun for the given person from the given table.
--- @param pronounsTable string[] The table to get pronouns from.
--- @param person number The index of the grammatical person (1 to 6).
--- @param useContraction boolean True if the contracted form should be returned.
--- @return string The pronoun.
local function getPronounFrom(pronounsTable, person, useContraction)
  local normal, abbr = unpack(pronounsTable[person])
  return useContraction and abbr or (normal .. "&nbsp;")
end

--- Return the pronoun for the given person.
--- @param person number The index of the grammatical person (1 to 6).
--- @param useContraction boolean True if the contracted form should be returned.
--- @return string The pronoun.
local function getPronoun(person, useContraction)
  return getPronounFrom(pronouns, person, useContraction)
end

--- Return the reflexive pronoun for the given person.
--- @param person number The index of the grammatical person (1 to 6).
--- @param useContraction boolean True if the contracted form should be returned.
--- @return string The reflexive pronoun.
local function getReflexivePronoun(person, useContraction)
  return getPronounFrom(reflexivePronouns, person, useContraction)
end

--- Get the flexion at the given path in the table.
--- @param verbTable table|string The table where to find the flexion.
--- @param path table A list containing the path to the flexion.
--- @return string The flexion or "—" if it does not exist.
local function getFlexion(verbTable, path)
  local node = verbTable
  for _, k in ipairs(path) do
    node = node[k]
    if not node then
      return undefined
    end
  end
  if type(node) ~= "string" then
    return undefined
  end
  return node
end

--- Format the flexion at the given path in the table.
--- @param verbTable table|string The table where to find the flexion.
--- @param path table A list containing the path to the flexion.
--- @param asLink boolean Whether to put the flexion in a link.
--- @return string The formatted flexion.
local function formatFlexion(verbTable, path, asLink)
  local flexion = getFlexion(verbTable, path)
  if flexion == "—" then
    return undefined
  end
  return asLink and link(flexion) or flexion
end

--- Generate the table for all impersonal tenses for the given verb.
--- @param verbTable string[] An array containing the flexions of the verb.
---        for all impersonal tenses in present and past forms: infinitive, gerund, participle.
--- @param reflexive boolean True if the verb is reflexive, false otherwise.
--- @param aspiratedH boolean True if the contracted pronoun forms should be used where relevant.
--- @return string The generated table.
local function generateImpersonalTable(verbTable, reflexive, aspiratedH)
  local tableElement = createTable()

  local headerRow = tableElement:tag("tr")
  headerRow:tag("th")
           :attr("scope", "col")
           :attr("style", "width: 8%; background-color: #ffddaa")
           :wikitext("[[mode#fr|Mode]]")
  headerRow:tag("th")
           :attr("scope", "colgroup")
           :attr("style", "width: 46%; background-color: #ffeebb")
           :attr("colspan", "2")
           :wikitext("[[présent#fr|Présent]]")
  headerRow:tag("th")
           :attr("scope", "colgroup")
           :attr("style", "width: 46%; background-color: #ffeebb")
           :attr("colspan", "2")
           :wikitext("[[passé#fr|Passé]]")

  local infinitiveRow = tableElement:tag("tr")
  infinitiveRow:tag("th")
               :attr("scope", "row")
               :wikitext("[[infinitif#fr|Infinitif]]")
  infinitiveRow:tag("td")
               :attr("style", "width: 23%; text-align: right; padding-right: 0")
               :wikitext(reflexive and getReflexivePronoun(3, requiresLiaison(verbTable.infinitif.present, aspiratedH)) or "")
  infinitiveRow:tag("td")
               :attr("style", "width: 23%; text-align: left; padding-left: 0")
               :wikitext(formatFlexion(verbTable, { "infinitif", "present" }, true))
  infinitiveRow:tag("td")
               :attr("style", "width: 23%; text-align: right; padding-right: 0")
               :wikitext(reflexive and getReflexivePronoun(3, requiresLiaison(getFlexion(verbTable, { "infinitif", "passe" }), aspiratedH)) or "")
  infinitiveRow:tag("td")
               :attr("style", "width: 23%; text-align: left; padding-left: 0")
               :wikitext(formatFlexion(verbTable, { "infinitif", "passe" }))

  local gerundRow = tableElement:tag("tr")
  gerundRow:tag("th")
           :attr("scope", "row")
           :wikitext("[[gérondif#fr|Gérondif]]")
  gerundRow:tag("td")
           :attr("style", "text-align: right; padding-right: 0")
           :wikitext("en&nbsp;" .. (reflexive and getReflexivePronoun(3, requiresLiaison(getFlexion(verbTable, { "gerondif", "passe" }), aspiratedH)) or ""))
  gerundRow:tag("td")
           :attr("style", "text-align: left; padding-left: 0")
           :wikitext(formatFlexion(verbTable, { "gerondif", "present" }, true))
  gerundRow:tag("td")
           :attr("style", "text-align: right; padding-right: 0")
           :wikitext("en&nbsp;" .. (reflexive and getReflexivePronoun(3, requiresLiaison(getFlexion(verbTable, { "gerondif", "passe" }), aspiratedH)) or ""))
  gerundRow:tag("td")
           :attr("style", "text-align: left; padding-left: 0")
           :wikitext(formatFlexion(verbTable, { "gerondif", "passe" }))

  local participleRow = tableElement:tag("tr")
  participleRow:tag("th")
               :attr("scope", "row")
               :wikitext("[[participe#fr|Participe]]")
  participleRow:tag("td")
  participleRow:tag("td")
               :attr("style", "text-align: left")
               :wikitext(formatFlexion(verbTable, { "participe", "present" }, true))
  participleRow:tag("td")
  participleRow:tag("td")
               :attr("style", "text-align: left")
               :wikitext(formatFlexion(verbTable, { "participe", "passe" }))

  return tostring(tableElement)
end

--- Generate the rows for the given simple tense and its corresponding composed tense.
--- @param simpleTense string[] An array containing the flexions of the simple tense.
--- @param title1 string Title for the simple tense.
--- @param composedTense string[] An array table containing the flexions of the composed tense.
--- @param title2 string Title for the composed tense.
--- @param reflexive boolean True if the verb is reflexive, false otherwise.
--- @param aspiratedH boolean True if the contracted pronoun forms should be used where relevant.
--- @param tableElement html The table element to add the generated rows to.
--- @param useQue boolean Optional. If true, “que” will be appended before each pronoun.
local function generateTensesRows(simpleTense, title1, color1, composedTense, title2, color2, reflexive, aspiratedH, tableElement, useQue)
  local headerRow = tableElement:tag("tr")

  headerRow:tag("th")
           :attr("scope", "colgroup")
           :attr("colspan", "2")
           :attr("style", "width: 50%; background-color: " .. color1)
           :wikitext(title1)
  headerRow:tag("th")
           :attr("scope", "colgroup")
           :attr("colspan", "2")
           :attr("style", "width: 50%; background-color: " .. color2)
           :wikitext(title2)

  --- Returns the pronoun sequence for the given person and verb form.
  --- @param person number The index of the pronoun.
  --- @param verb string The verb form.
  --- @return string The pronoun sequence
  local function pronounSequence(person, verb)
    local liaison = verb ~= m_gen.EMPTY_OBJECT and requiresLiaison(verb, aspiratedH)
    local ps
    if reflexive then
      ps = getPronoun(person, false) .. getReflexivePronoun(person, liaison)
    else
      ps = getPronoun(person, liaison)
    end
    if useQue then
      ps = getPronounFrom({ que }, 1, requiresLiaison(ps, aspiratedH)) .. ps
    end
    return ps
  end

  for i, simple in ipairs(simpleTense) do
    local row = tableElement:tag("tr")

    row:tag("td")
       :attr("style", "width: 25%; text-align: right; padding-right: 0")
       :wikitext(pronounSequence(i, simple))
    row:tag("td")
       :attr("style", "width: 25%; text-align: left; padding-left: 0")
       :wikitext(formatFlexion(simple, {}, true))

    local composed = composedTense and composedTense[i] or m_gen.EMPTY_OBJECT
    row:tag("td")
       :attr("style", "width: 25%; text-align: right; padding-right: 0")
       :wikitext(pronounSequence(i, composed))
    row:tag("td")
       :attr("style", "width: 25%; text-align: left; padding-left: 0")
       :wikitext(formatFlexion(composed, {}))
  end
end

--- Generate the table for the indicative tenses of the given verb.
--- @param verbTable table A table containing the flexions of the verb.
---        for all indicative tenses: present/passé composé, imparfait/plus-que-parfait,
---        passé simple/passé antérieur, and futur simple/futur antérieur.
--- @param reflexive boolean True if the verb is reflexive, false otherwise.
--- @param aspiratedH boolean True if the contracted pronoun forms should be used where relevant.
--- @return string The generated table.
local function generateIndicativeTable(verbTable, reflexive, aspiratedH)
  local tableElement = createTable()
  generateTensesRows(verbTable.indicatif.present, "Présent", "#ddd", verbTable.indicatif.passeCompose, "Passé composé", "#ececff", reflexive, aspiratedH, tableElement)
  generateTensesRows(verbTable.indicatif.imparfait, "Imparfait", "#ddd", verbTable.indicatif.plusQueParfait, "Plus-que-parfait", "#ececff", reflexive, aspiratedH, tableElement)
  generateTensesRows(verbTable.indicatif.passeSimple, "Passé simple", "#ddd", verbTable.indicatif.passeAnterieur, "Passé antérieur", "#ececff", reflexive, aspiratedH, tableElement)
  generateTensesRows(verbTable.indicatif.futur, "Futur simple", "#ddd", verbTable.indicatif.futurAnterieur, "Futur antérieur", "#ececff", reflexive, aspiratedH, tableElement)
  return tostring(tableElement)
end

--- Generate the table for the subjunctive tenses of the given verb.
--- @param verbTable table A table containing the flexions of the verb.
---        for all subjunctive tenses: present/passé and imparfait/plus-que-parfait.
--- @param reflexive boolean True if the verb is reflexive, false otherwise.
--- @param aspiratedH boolean True if the contracted pronoun forms should be used where relevant.
--- @return string The generated table.
local function generateSubjunctiveTable(verbTable, reflexive, aspiratedH)
  local tableElement = createTable()
  generateTensesRows(verbTable.subjonctif.present, "Présent", "#ddd", verbTable.subjonctif.passe, "Passé", "#fec", reflexive, aspiratedH, tableElement, "que")
  generateTensesRows(verbTable.subjonctif.imparfait, "Imparfait", "#ddd", verbTable.subjonctif.plusQueParfait, "Plus-que-parfait", "#fec", reflexive, aspiratedH, tableElement, "que")
  return tostring(tableElement)
end

--- Generate the table for the conditional tenses of the given verb.
--- @param verbTable table A table containing the flexions of the verb.
---        for all conditional tenses: present/passé.
--- @param reflexive boolean True if the verb is reflexive, false otherwise.
--- @param aspiratedH boolean True if the contracted pronoun forms should be used where relevant.
--- @return string The generated table.
local function generateConditionalTable(verbTable, reflexive, aspiratedH)
  local tableElement = createTable()
  generateTensesRows(verbTable.conditionnel.present, "Présent", "#ddd", verbTable.conditionnel.passe, "Passé", "#cfc", reflexive, aspiratedH, tableElement)
  return tostring(tableElement)
end

--- Generate the table for the imperative tenses of the given verb.
--- @param verbTable table A table containing the flexions of the verb.
---        for all imperative tenses: present/passé.
--- @param reflexive boolean True if the verb is reflexive, false otherwise.
--- @return string The generated table.
local function generateImperativeTable(verbTable, reflexive)
  local tableElement = createTable()

  local headerRow = tableElement:tag("tr")
  local presentHeader = headerRow:tag("th")
                                 :attr("scope", "colgroup")
                                 :attr("style", "width: 50%; background-color: #ffe5e5")
                                 :wikitext("Présent")
  if reflexive then
    presentHeader:attr("colspan", "2")
  end
  headerRow:tag("th")
           :attr("scope", "col")
           :attr("style", "width: 50%; background-color: #ffe5e5")
           :wikitext("Passé")

  for i, present in ipairs(verbTable.imperatif.present) do
    local row = tableElement:tag("tr")
    local presentCell = row:tag("td")
                           :wikitext(formatFlexion(present, {}, true))
    if reflexive then
      presentCell:attr("style", "width: 25%; text-align: right; padding-right: 0")
      row:tag("td")
         :attr("style", "width: 25%; text-align: left; padding-left: 0")
         :wikitext(reflexive and ("-" .. imperativePronouns[i]) or "")
    end
    row:tag("td")
       :wikitext(reflexive and undefined or formatFlexion(verbTable, { "imperatif", "passe", i }))
  end

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
--- @param verbTable table A table containing all the flexions of the verb.
--- @param group number The verb’s group, either 1, 2 or 3.
--- @param reflexive boolean True if the verb is reflexive, false otherwise.
--- @param aspiratedH boolean True if the contracted pronoun forms should be used where relevant.
--- @param defectiveForms table A table indicating for each mode/tense/person whether it is defective, grayed out or normal.
--- @return string The generated wikicode.
local function renderPage(verbTable, group, reflexive, aspiratedH, defectiveForms)
  -- TODO defective/grayed out forms
  local page = mw.html.create()

  local infinitive = verbTable.infinitif.present
  if reflexive then
    infinitive = getReflexivePronoun(3, requiresLiaison(infinitive, aspiratedH)) .. infinitive
  end
  page:wikitext(mw.ustring.format(
      "Conjugaison de '''%s''', ''verbe %s du %s, conjugé avec l’auxiliaire %s''.",
      link(infinitive), reflexive and "pronominal" or "", formatGroup(group), link(verbTable.auxiliaire)
  ))

  page:tag("h3")
      :wikitext("Modes impersonnels")
  page:tag("div")
      :attr("style", "margin: 0.5em 2em")
      :wikitext(generateImpersonalTable(verbTable, reflexive, aspiratedH))

  page:tag("h3")
      :wikitext("Indicatif")
  page:tag("div")
      :attr("style", "margin: 0.5em 2em")
      :wikitext(generateIndicativeTable(verbTable, reflexive, aspiratedH))

  page:tag("h3")
      :wikitext("Subjonctif")
  page:tag("div")
      :attr("style", "margin: 0.5em 2em")
      :wikitext(generateSubjunctiveTable(verbTable, reflexive, aspiratedH))

  page:tag("h3")
      :wikitext("Conditionnel")
  page:tag("div")
      :attr("style", "margin: 0.5em 2em")
      :wikitext(generateConditionalTable(verbTable, reflexive, aspiratedH))

  page:tag("h3")
      :wikitext("Impératif")
  page:tag("div")
      :attr("style", "margin: 0.5em 2em")
      :wikitext(generateImperativeTable(verbTable, reflexive, aspiratedH))

  return tostring(page)
end

local abbreviations = {
  -- Modes
  part = "participe",
  ind = "indicatif",
  subj = "subjonctif",
  cond = "conditionnel",
  imp = "imperatif",
  -- Tenses
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

--- Parse the given parsed frame arguments.
--- @param infinitive string The infinitive of the current verb.
--- @param args table The parsed frame arguments.
--- @return (table, table) A table containing all arguments of the form "<mode>.<tense>[.<person>]"
---  and a second table containing all arguments of the form "<mode>[.<tense>[.<person>]].état".
local function parseFlexions(infinitive, args)
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

  local specifiedForms = m_gen.createEmptyTemplate()
  local defectiveForms = m_gen.createEmptyTemplate()

  specifiedForms.infinitif.present = infinitive

  defectiveForms.indicatif.passeCompose = { m_gen.EMPTY_OBJECT, m_gen.EMPTY_OBJECT, m_gen.EMPTY_OBJECT, m_gen.EMPTY_OBJECT, m_gen.EMPTY_OBJECT, m_gen.EMPTY_OBJECT }
  defectiveForms.indicatif.passeAnterieur = { m_gen.EMPTY_OBJECT, m_gen.EMPTY_OBJECT, m_gen.EMPTY_OBJECT, m_gen.EMPTY_OBJECT, m_gen.EMPTY_OBJECT, m_gen.EMPTY_OBJECT }
  defectiveForms.indicatif.plusQueParfait = { m_gen.EMPTY_OBJECT, m_gen.EMPTY_OBJECT, m_gen.EMPTY_OBJECT, m_gen.EMPTY_OBJECT, m_gen.EMPTY_OBJECT, m_gen.EMPTY_OBJECT }
  defectiveForms.indicatif.futurAnterieur = { m_gen.EMPTY_OBJECT, m_gen.EMPTY_OBJECT, m_gen.EMPTY_OBJECT, m_gen.EMPTY_OBJECT, m_gen.EMPTY_OBJECT, m_gen.EMPTY_OBJECT }
  defectiveForms.subjonctif.passe = { m_gen.EMPTY_OBJECT, m_gen.EMPTY_OBJECT, m_gen.EMPTY_OBJECT, m_gen.EMPTY_OBJECT, m_gen.EMPTY_OBJECT, m_gen.EMPTY_OBJECT }
  defectiveForms.subjonctif.plusQueParfait = { m_gen.EMPTY_OBJECT, m_gen.EMPTY_OBJECT, m_gen.EMPTY_OBJECT, m_gen.EMPTY_OBJECT, m_gen.EMPTY_OBJECT, m_gen.EMPTY_OBJECT }
  defectiveForms.conditionnel.passe = { m_gen.EMPTY_OBJECT, m_gen.EMPTY_OBJECT, m_gen.EMPTY_OBJECT, m_gen.EMPTY_OBJECT, m_gen.EMPTY_OBJECT, m_gen.EMPTY_OBJECT }
  defectiveForms.imperatif.passe = { m_gen.EMPTY_OBJECT, m_gen.EMPTY_OBJECT, m_gen.EMPTY_OBJECT }

  for k, v in pairs(args) do
    if mw.ustring.find(k, "%.") then
      local parts = mw.text.split(k, ".", true)
      local nb = #parts

      if parts[nb] == "état" then
        table.remove(parts, nb)
        nb = nb - 1
        local node = defectiveForms
        for i, part in ipairs(parts) do
          if i < nb then
            node = node[abbreviations[part]]
          end
        end
        if mw.ustring.match(parts[nb], "[123][sp]") then
          node[personToIndex(parts[1], parts[nb])] = v
        else
          node[abbreviations[parts[nb]]].state = v
        end

      else
        local node = specifiedForms
        for i, part in ipairs(parts) do
          if i < nb then
            node = node[abbreviations[part]]
          end
        end
        if mw.ustring.match(parts[nb], "[123][sp]") then
          node[personToIndex(parts[1], parts[nb])] = v
        else
          node[abbreviations[parts[nb]]] = v
        end
      end

    end
  end

  return specifiedForms, defectiveForms
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
    ["ind.état"] = { enum = FLEXION_STATES },
    -- Indicatif présent
    ["ind.pr.1s"] = {},
    ["ind.pr.2s"] = {},
    ["ind.pr.3s"] = {},
    ["ind.pr.1p"] = {},
    ["ind.pr.2p"] = {},
    ["ind.pr.3p"] = {},
    ["ind.pr.état"] = { enum = FLEXION_STATES },
    ["ind.pr.1s.état"] = { enum = FLEXION_STATES },
    ["ind.pr.2s.état"] = { enum = FLEXION_STATES },
    ["ind.pr.3s.état"] = { enum = FLEXION_STATES },
    ["ind.pr.1p.état"] = { enum = FLEXION_STATES },
    ["ind.pr.2p.état"] = { enum = FLEXION_STATES },
    ["ind.pr.3p.état"] = { enum = FLEXION_STATES },
    -- Indicatif imparfait
    ["ind.i.1s"] = {},
    ["ind.i.2s"] = {},
    ["ind.i.3s"] = {},
    ["ind.i.1p"] = {},
    ["ind.i.2p"] = {},
    ["ind.i.3p"] = {},
    ["ind.i.état"] = { enum = FLEXION_STATES },
    ["ind.i.1s.état"] = { enum = FLEXION_STATES },
    ["ind.i.2s.état"] = { enum = FLEXION_STATES },
    ["ind.i.3s.état"] = { enum = FLEXION_STATES },
    ["ind.i.1p.état"] = { enum = FLEXION_STATES },
    ["ind.i.2p.état"] = { enum = FLEXION_STATES },
    ["ind.i.3p.état"] = { enum = FLEXION_STATES },
    -- Indicatif passé simple
    ["ind.ps.1s"] = {},
    ["ind.ps.2s"] = {},
    ["ind.ps.3s"] = {},
    ["ind.ps.1p"] = {},
    ["ind.ps.2p"] = {},
    ["ind.ps.3p"] = {},
    ["ind.ps.état"] = { enum = FLEXION_STATES },
    ["ind.ps.1s.état"] = { enum = FLEXION_STATES },
    ["ind.ps.2s.état"] = { enum = FLEXION_STATES },
    ["ind.ps.3s.état"] = { enum = FLEXION_STATES },
    ["ind.ps.1p.état"] = { enum = FLEXION_STATES },
    ["ind.ps.2p.état"] = { enum = FLEXION_STATES },
    ["ind.ps.3p.état"] = { enum = FLEXION_STATES },
    -- Indicatif futur
    ["ind.f.1s"] = {},
    ["ind.f.2s"] = {},
    ["ind.f.3s"] = {},
    ["ind.f.1p"] = {},
    ["ind.f.2p"] = {},
    ["ind.f.3p"] = {},
    ["ind.f.état"] = { enum = FLEXION_STATES },
    ["ind.f.1s.état"] = { enum = FLEXION_STATES },
    ["ind.f.2s.état"] = { enum = FLEXION_STATES },
    ["ind.f.3s.état"] = { enum = FLEXION_STATES },
    ["ind.f.1p.état"] = { enum = FLEXION_STATES },
    ["ind.f.2p.état"] = { enum = FLEXION_STATES },
    ["ind.f.3p.état"] = { enum = FLEXION_STATES },
    -- Indicatif passé composé
    ["ind.pc.état"] = { enum = FLEXION_STATES },
    ["ind.pc.1s.état"] = { enum = FLEXION_STATES },
    ["ind.pc.2s.état"] = { enum = FLEXION_STATES },
    ["ind.pc.3s.état"] = { enum = FLEXION_STATES },
    ["ind.pc.1p.état"] = { enum = FLEXION_STATES },
    ["ind.pc.2p.état"] = { enum = FLEXION_STATES },
    ["ind.pc.3p.état"] = { enum = FLEXION_STATES },
    -- Indicatif passé antérieur
    ["ind.pa.état"] = { enum = FLEXION_STATES },
    ["ind.pa.1s.état"] = { enum = FLEXION_STATES },
    ["ind.pa.2s.état"] = { enum = FLEXION_STATES },
    ["ind.pa.3s.état"] = { enum = FLEXION_STATES },
    ["ind.pa.1p.état"] = { enum = FLEXION_STATES },
    ["ind.pa.2p.état"] = { enum = FLEXION_STATES },
    ["ind.pa.3p.état"] = { enum = FLEXION_STATES },
    -- Indicatif plus-que-parfait
    ["ind.pqp.état"] = { enum = FLEXION_STATES },
    ["ind.pqp.1s.état"] = { enum = FLEXION_STATES },
    ["ind.pqp.2s.état"] = { enum = FLEXION_STATES },
    ["ind.pqp.3s.état"] = { enum = FLEXION_STATES },
    ["ind.pqp.1p.état"] = { enum = FLEXION_STATES },
    ["ind.pqp.2p.état"] = { enum = FLEXION_STATES },
    ["ind.pqp.3p.état"] = { enum = FLEXION_STATES },
    -- Indicatif futur antérieur
    ["ind.fa.état"] = { enum = FLEXION_STATES },
    ["ind.fa.1s.état"] = { enum = FLEXION_STATES },
    ["ind.fa.2s.état"] = { enum = FLEXION_STATES },
    ["ind.fa.3s.état"] = { enum = FLEXION_STATES },
    ["ind.fa.1p.état"] = { enum = FLEXION_STATES },
    ["ind.fa.2p.état"] = { enum = FLEXION_STATES },
    ["ind.fa.3p.état"] = { enum = FLEXION_STATES },

    -- Subjonctif
    ["subj.état"] = { enum = FLEXION_STATES },
    -- Subjonctif présent
    ["subj.pr.1s"] = {},
    ["subj.pr.2s"] = {},
    ["subj.pr.3s"] = {},
    ["subj.pr.1p"] = {},
    ["subj.pr.2p"] = {},
    ["subj.pr.3p"] = {},
    ["subj.pr.état"] = { enum = FLEXION_STATES },
    ["subj.pr.1s.état"] = { enum = FLEXION_STATES },
    ["subj.pr.2s.état"] = { enum = FLEXION_STATES },
    ["subj.pr.3s.état"] = { enum = FLEXION_STATES },
    ["subj.pr.1p.état"] = { enum = FLEXION_STATES },
    ["subj.pr.2p.état"] = { enum = FLEXION_STATES },
    ["subj.pr.3p.état"] = { enum = FLEXION_STATES },
    -- Subjonctif imparfait
    ["subj.imp.1s"] = {},
    ["subj.imp.2s"] = {},
    ["subj.imp.3s"] = {},
    ["subj.imp.1p"] = {},
    ["subj.imp.2p"] = {},
    ["subj.imp.3p"] = {},
    ["subj.imp.état"] = { enum = FLEXION_STATES },
    ["subj.imp.1s.état"] = { enum = FLEXION_STATES },
    ["subj.imp.2s.état"] = { enum = FLEXION_STATES },
    ["subj.imp.3s.état"] = { enum = FLEXION_STATES },
    ["subj.imp.1p.état"] = { enum = FLEXION_STATES },
    ["subj.imp.2p.état"] = { enum = FLEXION_STATES },
    ["subj.imp.3p.état"] = { enum = FLEXION_STATES },
    -- Subjonctif passé
    ["subj.p.état"] = { enum = FLEXION_STATES },
    ["subj.p.1s.état"] = { enum = FLEXION_STATES },
    ["subj.p.2s.état"] = { enum = FLEXION_STATES },
    ["subj.p.3s.état"] = { enum = FLEXION_STATES },
    ["subj.p.1p.état"] = { enum = FLEXION_STATES },
    ["subj.p.2p.état"] = { enum = FLEXION_STATES },
    ["subj.p.3p.état"] = { enum = FLEXION_STATES },
    -- Subjonctif plus-que-parfait
    ["subj.pqp.état"] = { enum = FLEXION_STATES },
    ["subj.pqp.1s.état"] = { enum = FLEXION_STATES },
    ["subj.pqp.2s.état"] = { enum = FLEXION_STATES },
    ["subj.pqp.3s.état"] = { enum = FLEXION_STATES },
    ["subj.pqp.1p.état"] = { enum = FLEXION_STATES },
    ["subj.pqp.2p.état"] = { enum = FLEXION_STATES },
    ["subj.pqp.3p.état"] = { enum = FLEXION_STATES },

    -- Conditionnel
    ["cond.état"] = { enum = FLEXION_STATES },
    -- Conditionnel présent
    ["cond.pr.1s"] = {},
    ["cond.pr.2s"] = {},
    ["cond.pr.3s"] = {},
    ["cond.pr.1p"] = {},
    ["cond.pr.2p"] = {},
    ["cond.pr.3p"] = {},
    ["cond.pr.état"] = { enum = FLEXION_STATES },
    ["cond.pr.1s.état"] = { enum = FLEXION_STATES },
    ["cond.pr.2s.état"] = { enum = FLEXION_STATES },
    ["cond.pr.3s.état"] = { enum = FLEXION_STATES },
    ["cond.pr.1p.état"] = { enum = FLEXION_STATES },
    ["cond.pr.2p.état"] = { enum = FLEXION_STATES },
    ["cond.pr.3p.état"] = { enum = FLEXION_STATES },
    -- Conditionnel passé
    ["cond.p.état"] = { enum = FLEXION_STATES },
    ["cond.p.1s.état"] = { enum = FLEXION_STATES },
    ["cond.p.2s.état"] = { enum = FLEXION_STATES },
    ["cond.p.3s.état"] = { enum = FLEXION_STATES },
    ["cond.p.1p.état"] = { enum = FLEXION_STATES },
    ["cond.p.2p.état"] = { enum = FLEXION_STATES },
    ["cond.p.3p.état"] = { enum = FLEXION_STATES },

    -- Impératif
    ["imp.état"] = { enum = FLEXION_STATES },
    -- Impératif présent
    ["imp.pr.2s"] = {},
    ["imp.pr.1p"] = {},
    ["imp.pr.2p"] = {},
    ["imp.pr.état"] = { enum = FLEXION_STATES },
    ["imp.pr.2s.état"] = { enum = FLEXION_STATES },
    ["imp.pr.1p.état"] = { enum = FLEXION_STATES },
    ["imp.pr.2p.état"] = { enum = FLEXION_STATES },
    -- Impératif passé
    ["imp.p.état"] = { enum = FLEXION_STATES },
    ["imp.p.2s.état"] = { enum = FLEXION_STATES },
    ["imp.p.1p.état"] = { enum = FLEXION_STATES },
    ["imp.p.2p.état"] = { enum = FLEXION_STATES },
  })

  local infinitive = args[1]
  local reflexive = args["pronominal"]
  local auxiliary = (reflexive or args["aux-être"]) and m_gen.etreConj or m_gen.avoirConj
  local group3 = args["groupe3"]
  local mutationType = args["mutation"]
  local template = args["modèle"]
  local aspiratedH = args["h-aspiré"]
  if aspiratedH and mw.ustring.sub(infinitive, 1, 1) ~= "h" then
    error(mw.ustring.format('Le verbe "%s" ne commence pas par un "h"', infinitive))
  end

  local specifiedForms, defectiveForms = parseFlexions(infinitive, args)
  local simpleTenses, actualGroup = m_gen.generateFlexions(infinitive, group3, mutationType, template, specifiedForms)
  return renderPage(completeTable(auxiliary, simpleTenses), actualGroup, reflexive, aspiratedH, defectiveForms)
end

return p
