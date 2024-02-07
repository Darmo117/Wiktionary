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
local liaisonLetters = { "a", "â", "e", "ê", "é", "è", "ë", "i", "î", "ï", "o", "ô", "u", "û", "y", "h" }
local que = { "que", "qu’" }
local undefined = tostring(
    mw.html.create("span")
      :attr("style", "color: grey")
      :wikitext("—")
)

--- Check whether a liaison is required for the given word.
--- @param s string The word to check.
--- @return boolean True if a liaison is needed, false otherwise.
local function requiresLiaison(s)
  return m_table.contains(liaisonLetters, mw.ustring.sub(mw.ustring.lower(s), 1, 1))
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

  verbTable.infinitif.passe = auxTable.infinitif.present .. " " .. verbTable.participe.passe

  verbTable.gerondif = {
    present = verbTable.participe.present,
    passe = auxTable.participe.present .. " " .. verbTable.participe.passe
  }

  verbTable.indicatif.passeCompose = generateComposedTense(auxTable.indicatif.present, verbTable.participe.passe)
  verbTable.indicatif.plusQueParfait = generateComposedTense(auxTable.indicatif.imparfait, verbTable.participe.passe)
  verbTable.indicatif.passeAnterieur = generateComposedTense(auxTable.indicatif.passeSimple, verbTable.participe.passe)
  verbTable.indicatif.futurAnterieur = generateComposedTense(auxTable.indicatif.futur, verbTable.participe.passe)

  verbTable.subjonctif.passe = generateComposedTense(auxTable.subjonctif.present, verbTable.participe.passe)
  verbTable.subjonctif.plusQueParfait = generateComposedTense(auxTable.subjonctif.imparfait, verbTable.participe.passe)

  verbTable.conditionnel.passe = generateComposedTense(auxTable.conditionnel.present, verbTable.participe.passe)

  verbTable.imperatif.passe = generateComposedTense(auxTable.imperatif.present, verbTable.participe.passe)
  return verbTable
end

--- Generate a wikicode link with a #fr anchor for the given page title.
--- @param title string The title of the page to link to.
--- @return string The link.
local function link(title)
  return mw.ustring.format("[[%s#fr|%s]]", title, title)
end

--- Create a HTML table element with a width of 100%, center-aligned text and collapsed borders.
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

--- Generate the table for all impersonal tenses for the given verb.
--- @param verbTable string[] An array containing the flexions of the verb.
---        for all impersonal tenses in present and past forms: infinitive, gerund, participle.
--- @param reflexive boolean True if the verb is reflexive, false otherwise.
--- @return string The generated table.
local function generateImpersonalTable(verbTable, reflexive)
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
               :attr("style", "width: 23%; text-align: right")
               :wikitext(reflexive and getReflexivePronoun(3, requiresLiaison(verbTable.infinitif.present)) or "")
  infinitiveRow:tag("td")
               :attr("style", "width: 23%; text-align: left")
               :wikitext(link(verbTable.infinitif.present))
  infinitiveRow:tag("td")
               :attr("style", "width: 23%; text-align: right")
               :wikitext(reflexive and getReflexivePronoun(3, requiresLiaison(verbTable.infinitif.passe)) or "")
  infinitiveRow:tag("td")
               :attr("style", "width: 23%; text-align: left")
               :wikitext(link(verbTable.infinitif.passe))

  local gerundRow = tableElement:tag("tr")
  gerundRow:tag("th")
           :attr("scope", "row")
           :wikitext("[[gérondif#fr|Gérondif]]")
  gerundRow:tag("td")
           :attr("style", "text-align: right")
           :wikitext("en&nbsp;" .. (reflexive and getReflexivePronoun(3, requiresLiaison(verbTable.gerondif.present)) or ""))
  gerundRow:tag("td")
           :attr("style", "text-align: left")
           :wikitext(link(verbTable.gerondif.present))
  gerundRow:tag("td")
           :attr("style", "text-align: right")
           :wikitext("en&nbsp;" .. (reflexive and getReflexivePronoun(3, requiresLiaison(verbTable.gerondif.passe)) or ""))
  gerundRow:tag("td")
           :attr("style", "text-align: left")
           :wikitext(link(verbTable.gerondif.passe))

  local participleRow = tableElement:tag("tr")
  participleRow:tag("th")
               :attr("scope", "row")
               :wikitext("[[participe#fr|Participe]]")
  participleRow:tag("td")
  participleRow:tag("td")
               :attr("style", "text-align: left")
               :wikitext(link(verbTable.participe.present))
  participleRow:tag("td")
  participleRow:tag("td")
               :attr("style", "text-align: left")
               :wikitext(link(verbTable.participe.passe))

  return tostring(tableElement)
end

--- Generate the rows for the given simple tense and its corresponding composed tense.
--- @param simpleTense string[] An array containing the flexions of the simple tense.
--- @param title1 string Title for the simple tense.
--- @param composedTense string[] An array table containing the flexions of the composed tense.
--- @param title2 string Title for the composed tense.
--- @param reflexive boolean True if the verb is reflexive, false otherwise.
--- @param tableElement html The table element to add the generated rows to.
--- @param useQue boolean Optional. If true, “que” will be appended before each pronoun.
local function generateTensesRows(simpleTense, title1, color1, composedTense, title2, color2, reflexive, tableElement, useQue)
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
  function pronounSequence(person, verb)
    local liaison = requiresLiaison(verb)
    local ps
    if reflexive then
      ps = getPronoun(person, false) .. getReflexivePronoun(person, liaison)
    else
      ps = getPronoun(person, liaison)
    end
    if useQue then
      ps = getPronounFrom({ que }, 1, requiresLiaison(ps)) .. ps
    end
    return ps
  end

  for i, simple in ipairs(simpleTense) do
    local row = tableElement:tag("tr")

    row:tag("td")
       :attr("style", "width: 25%; text-align: right")
       :wikitext(pronounSequence(i, simple))
    row:tag("td")
       :attr("style", "width: 25%; text-align: left")
       :wikitext(link(simple))

    local composed = composedTense[i]
    row:tag("td")
       :attr("style", "width: 25%; text-align: right")
       :wikitext(pronounSequence(i, composed))
    row:tag("td")
       :attr("style", "width: 25%; text-align: left")
       :wikitext(link(composed))
  end
end

--- Generate the table for the indicative tenses of the given verb.
--- @param verbTable table A table containing the flexions of the verb.
---        for all indicative tenses: present/passé composé, imparfait/plus-que-parfait,
---        passé simple/passé antérieur, and futur simple/futur antérieur.
--- @param reflexive boolean True if the verb is reflexive, false otherwise.
--- @return string The generated table.
local function generateIndicativeTable(verbTable, reflexive)
  local tableElement = createTable()
  generateTensesRows(verbTable.indicatif.present, "Présent", "#ddd", verbTable.indicatif.passeCompose, "Passé composé", "#ececff", reflexive, tableElement)
  generateTensesRows(verbTable.indicatif.imparfait, "Imparfait", "#ddd", verbTable.indicatif.plusQueParfait, "Plus-que-parfait", "#ececff", reflexive, tableElement)
  generateTensesRows(verbTable.indicatif.passeSimple, "Passé simple", "#ddd", verbTable.indicatif.passeAnterieur, "Passé antérieur", "#ececff", reflexive, tableElement)
  generateTensesRows(verbTable.indicatif.futur, "Futur simple", "#ddd", verbTable.indicatif.futurAnterieur, "Futur antérieur", "#ececff", reflexive, tableElement)
  return tostring(tableElement)
end

--- Generate the table for the subjunctive tenses of the given verb.
--- @param verbTable table A table containing the flexions of the verb.
---        for all subjunctive tenses: present/passé and imparfait/plus-que-parfait.
--- @param reflexive boolean True if the verb is reflexive, false otherwise.
--- @return string The generated table.
local function generateSubjunctiveTable(verbTable, reflexive)
  local tableElement = createTable()
  generateTensesRows(verbTable.subjonctif.present, "Présent", "#ddd", verbTable.subjonctif.passe, "Passé", "#fec", reflexive, tableElement, "que")
  generateTensesRows(verbTable.subjonctif.imparfait, "Imparfait", "#ddd", verbTable.subjonctif.plusQueParfait, "Plus-que-parfait", "#fec", reflexive, tableElement, "que")
  return tostring(tableElement)
end

--- Generate the table for the conditional tenses of the given verb.
--- @param verbTable table A table containing the flexions of the verb.
---        for all conditional tenses: present/passé.
--- @param reflexive boolean True if the verb is reflexive, false otherwise.
--- @return string The generated table.
local function generateConditionalTable(verbTable, reflexive)
  local tableElement = createTable()
  generateTensesRows(verbTable.conditionnel.present, "Présent", "#ddd", verbTable.conditionnel.passe, "Passé", "#cfc", reflexive, tableElement)
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
                           :wikitext(link(present))
    if reflexive then
      presentCell:attr("style", "width: 25%; text-align: right")
      row:tag("td")
         :attr("style", "width: 25%; text-align: left")
         :wikitext(reflexive and ("-" .. imperativePronouns[i]) or "")
    end
    row:tag("td")
       :wikitext(reflexive and undefined or link(verbTable.imperatif.passe[i]))
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
--- @return string The generated wikicode.
local function renderPage(verbTable, group, reflexive)
  local page = mw.html.create()

  page:wikitext(mw.ustring.format(
      "Conjugaison de '''%s''', ''verbe %s du %s, conjugé avec l’auxiliaire %s''.",
      link(verbTable.infinitif.present), reflexive and "pronominal" or "", formatGroup(group), link(verbTable.auxiliaire)
  ))

  page:tag("h3")
      :wikitext("Modes impersonnels")
  page:tag("div")
      :attr("style", "margin: 0.5em 2em")
      :wikitext(generateImpersonalTable(verbTable, reflexive))

  page:tag("h3")
      :wikitext("Indicatif")
  page:tag("div")
      :attr("style", "margin: 0.5em 2em")
      :wikitext(generateIndicativeTable(verbTable, reflexive))

  page:tag("h3")
      :wikitext("Subjonctif")
  page:tag("div")
      :attr("style", "margin: 0.5em 2em")
      :wikitext(generateSubjunctiveTable(verbTable, reflexive))

  page:tag("h3")
      :wikitext("Conditionnel")
  page:tag("div")
      :attr("style", "margin: 0.5em 2em")
      :wikitext(generateConditionalTable(verbTable, reflexive))

  page:tag("h3")
      :wikitext("Impératif")
  page:tag("div")
      :attr("style", "margin: 0.5em 2em")
      :wikitext(generateImperativeTable(verbTable, reflexive))

  return tostring(page)
end

--- Render the conjugation tables for the given verb.
--- Parameters:
---  frame.args[1] (string): The verb in its infinitive present form.
---  frame.args["aux-être"] (boolean): If true, use the “être” auxiliary instead of “avoir”.
---  frame.args["groupe"] (number): Optional. The verb’s group if it cannot be guessed automatically.
---  frame.args["pronominal"] (number): Optional. Whether the verb is reflexive.
---  frame.args["pas-ï"] (boolean): Optional. For group-2 verbs in “ïr”, whether to drop the “ï”
---   for the 3 singular persons of indicative and imperative present.
--- @return string The generated wikicode.
function p.conj(frame)
  -- TODO utiliser frame:getParent().args
  local args = m_params.process(frame.args, {
    [1] = { required = true },
    ["aux-être"] = { type = m_params.BOOLEAN, default = false },
    ["groupe"] = { type = m_params.INT, enum = { 1, 2, 3 } },
    ["pronominal"] = { type = m_params.BOOLEAN, default = false },
    ["pas-ï"] = { type = m_params.BOOLEAN, default = false },
  })
  local infinitive = args[1]
  local reflexive = args["pronominal"]
  local auxiliary = (reflexive or args["aux-être"]) and m_gen.etreConj or m_gen.avoirConj
  local group = args["groupe"]
  local dropDiaeresis = args["pas-ï"]
  -- TODO autres paramètres :
  -- * flexions entières
  -- * radicaux de flexions
  -- * h aspirés pour formes contractées des pronoms
  -- * modes/temps/personnes défectives
  local simpleTenses, actualGroup = m_gen.generateFlexions(infinitive, group, dropDiaeresis)
  return renderPage(completeTable(auxiliary, simpleTenses), actualGroup, reflexive)
end

return p
