local m_params = require("Module:paramètres")
local export = {}

local function postprocess(args, data)
  data.actv = true
  data.pasv = true

  if args["v"] == "actv" then
    data.pasv = false
  elseif args["v"] == "pasv" then
    data.actv = false
    data.info = data.info .. ", deponent"
  end

  for key, form in pairs(data.forms) do
    -- Do not show singular or plural forms for nominals that don't have them
    if (args["v"] == "actv" and key:find("pasv")) or (args["v"] == "pasv" and key:find("actv")) then
      form = nil
    end

    data.forms[key] = form
  end
end

local function present(data, stem)
  if not stem then
    stem = "?"
  end

  local stem_e = stem
  local stem_o = stem
  local stem_u = stem
  local stem_i = stem
  local pres_1sg = stem

  if mw.ustring.find(stem, "e$") then
    table.insert(data.info, "présent thématique")
    stem_o = mw.ustring.gsub(stem, "e$", "o")
    stem_u = mw.ustring.gsub(stem, "e$", "ū")
    stem_i = mw.ustring.gsub(stem, "e$", "ī")
    pres_1sg = stem_u
  elseif mw.ustring.find(stem, "a$") then
    table.insert(data.info, "présent thématique avec a")
    stem_o = mw.ustring.gsub(stem, "a$", "o")
    stem_u = mw.ustring.gsub(stem, "a$", "ū")
    stem_i = mw.ustring.gsub(stem, "a$", "ī")
    pres_1sg = stem .. "mi"
  elseif mw.ustring.find(stem, "ā$") then
    table.insert(data.info, "présent ā")
    pres_1sg = stem .. "mi"
  else
    stem = "?"
  end

  -- Present indicative
  data.forms["actv_pres_indc_1sg"] = { pres_1sg }
  data.forms["actv_pres_indc_2sg"] = { stem_e .. "si" }
  data.forms["actv_pres_indc_3sg"] = { stem_e .. "ti" }
  data.forms["actv_pres_indc_1pl"] = { stem_o .. "mu" }
  data.forms["actv_pres_indc_2pl"] = { stem_e .. "te" }
  data.forms["actv_pres_indc_3pl"] = { stem_o .. "nti" }

  data.forms["pasv_pres_indc_1sg"] = { stem_u .. "r" }
  data.forms["pasv_pres_indc_2sg"] = { stem_e .. "tar" }
  data.forms["pasv_pres_indc_3sg"] = { stem_e .. "tor" }
  data.forms["pasv_pres_indc_1pl"] = { stem_o .. "mmor" }
  data.forms["pasv_pres_indc_2pl"] = { stem_e .. "dwe" }
  data.forms["pasv_pres_indc_3pl"] = { stem_o .. "ntor" }

  -- Imperfect indicative
  data.forms["actv_impf_indc_1sg"] = { stem_e .. "nnem" }
  data.forms["actv_impf_indc_2sg"] = { stem_i .. "tū" }
  data.forms["actv_impf_indc_3sg"] = { stem_e .. "(to)" }
  data.forms["actv_impf_indc_1pl"] = { stem_e .. "mmets" }
  data.forms["actv_impf_indc_2pl"] = { stem_e .. "tes", stem .. "swīs" }
  data.forms["actv_impf_indc_3pl"] = { stem_e .. "ntets" }

  data.forms["pasv_impf_indc_3sg"] = { stem_e .. "tey" }
  data.forms["pasv_impf_indc_3pl"] = { stem_e .. "ntits" }

  -- Imperative
  data.forms["actv_impr_2sg"] = { stem_i }
  data.forms["actv_impr_3sg"] = { stem_e .. "t" }
  data.forms["actv_impr_1pl"] = { stem_o .. "mu" }
  data.forms["actv_impr_2pl"] = { stem_e .. "tīs" }
  data.forms["actv_impr_3pl"] = { stem_o .. "nt" }

  data.forms["pasv_impr_2sg"] = { stem_e .. "tar" }
  data.forms["pasv_impr_3sg"] = { stem_o .. "r" }
  data.forms["pasv_impr_1pl"] = { stem_o .. "mmor" }
  data.forms["pasv_impr_2pl"] = { stem_e .. "dwe" }
  data.forms["pasv_impr_3pl"] = { stem_o .. "ntor" }

  -- Non-finite forms
  data.forms["actv_pres_ptcp"] = { stem_o .. "nts" }
  data.forms["pasv_pres_ptcp"] = { stem_o .. "mnos" }
end

local function future(data, stem)
  if not stem then
    stem = "?"
  elseif stem == "-" then
    return
  end

  if mw.ustring.find(stem, "ā$") then
    table.insert(data.info, "futur ā")
  else
    stem = "?"
  end

  data.forms["actv_futr_indc_1sg"] = { stem .. "m" }
  data.forms["actv_futr_indc_2sg"] = { stem .. "si" }
  data.forms["actv_futr_indc_3sg"] = { stem .. "ti" }
  data.forms["actv_futr_indc_1pl"] = { stem .. "mes" }
  data.forms["actv_futr_indc_2pl"] = { stem .. "te" }
  data.forms["actv_futr_indc_3pl"] = { stem .. "nti" }

  data.forms["pasv_futr_indc_1sg"] = { stem .. "r" }
  data.forms["pasv_futr_indc_2sg"] = { stem .. "tar" }
  data.forms["pasv_futr_indc_3sg"] = { stem .. "tor" }
  data.forms["pasv_futr_indc_1pl"] = { stem .. "mmor" }
  data.forms["pasv_futr_indc_2pl"] = { stem .. "dwe" }
  data.forms["pasv_futr_indc_3pl"] = { stem .. "ntor" }
end

local function preterite_actv(data, stem)
  if not stem then
    stem = "?"
  elseif stem == "-" then
    return
  end

  if mw.ustring.find(stem, "t$") then
    table.insert(data.info, "prétérit t")
  else
    stem = "?"
  end

  data.forms["actv_pret_indc_1sg"] = { stem .. "ū" }
  data.forms["actv_pret_indc_2sg"] = { stem .. "es" }
  data.forms["actv_pret_indc_3sg"] = { stem }
  data.forms["actv_pret_indc_1pl"] = { stem .. "omu" }
  data.forms["actv_pret_indc_2pl"] = { stem .. "ete" }
  data.forms["actv_pret_indc_3pl"] = { stem .. "ont" }
end

local function preterite_pasv(data, stem)
  if not stem then
    stem = "?"
  elseif stem == "-" then
    return
  end

  if mw.ustring.find(stem, "[st]$") then
    -- Nothing?
  else
    stem = "?"
  end

  data.forms["pasv_pret_indc_3sg"] = { stem .. "o" }
  data.forms["pasv_pret_indc_3pl"] = { stem .. "ūnts" }

  data.forms["pasv_pret_ptcp"] = { stem .. "os" }
end

local function subjunctive(data, stem)
  if not stem then
    stem = "?"
  elseif stem == "-" then
    return
  end

  if mw.ustring.find(stem, "ā$") then
    table.insert(data.info, "subjonctif ā")
  elseif mw.ustring.find(stem, "s$") then
    table.insert(data.info, "subjonctif s")
    stem = "?" -- Until the endings of the s-subjunctive are provided
  else
    stem = "?"
  end

  data.forms["actv_pres_subj_1sg"] = { stem .. "m" }
  data.forms["actv_pres_subj_2sg"] = { stem .. "si" }
  data.forms["actv_pres_subj_3sg"] = { stem .. "ti" }
  data.forms["actv_pres_subj_1pl"] = { stem .. "mes" }
  data.forms["actv_pres_subj_2pl"] = { stem .. "te" }
  data.forms["actv_pres_subj_3pl"] = { stem .. "nti" }

  data.forms["pasv_pres_subj_1sg"] = { stem .. "r" }
  data.forms["pasv_pres_subj_2sg"] = { stem .. "tar" }
  data.forms["pasv_pres_subj_3sg"] = { stem .. "tor" }
  data.forms["pasv_pres_subj_1pl"] = { stem .. "mmor" }
  data.forms["pasv_pres_subj_2pl"] = { stem .. "dwe" }
  data.forms["pasv_pres_subj_3pl"] = { stem .. "ntor" }

  data.forms["actv_past_subj_1sg"] = { stem .. "nnem" }
  data.forms["actv_past_subj_2sg"] = { stem .. "tū" }
  data.forms["actv_past_subj_3sg"] = { stem .. "(to)" }
  data.forms["actv_past_subj_1pl"] = { stem .. "mmets" }
  data.forms["actv_past_subj_2pl"] = { stem .. "tes", stem .. "swīs" }
  data.forms["actv_past_subj_3pl"] = { stem .. "ntets" }
end


-- Inflection functions

export["reg"] = function(frame)
  local params = {
    [1] = { required = true },
    [2] = {},
    [3] = {},
    [4] = {},
    [5] = {},

    ["v"] = {},
  }

  local args = m_params.process(frame:getParent().args, params)
  local data = { forms = {}, info = {} }

  present(data, args[1])
  future(data, args[2])
  preterite_actv(data, args[3])
  preterite_pasv(data, args[4])
  subjunctive(data, args[5])

  data.info = table.concat(data.info, ", ")

  postprocess(args, data)

  return make_table(data)
end

export["them"] = function(frame)
  local params = {
    [1] = { required = true, default = "{{{1}}}" },
    ["v"] = {},
  }

  local args = m_params.process(frame:getParent().args, params)
  local data = { forms = {}, info = "thématique" }

  -- Present indicative
  data.forms["actv_pres_indc_1sg"] = { args[1] .. "ū" }
  data.forms["actv_pres_indc_2sg"] = { args[1] .. "esi" }
  data.forms["actv_pres_indc_3sg"] = { args[1] .. "eti" }
  data.forms["actv_pres_indc_1pl"] = { args[1] .. "omu" }
  data.forms["actv_pres_indc_2pl"] = { args[1] .. "ete" }
  data.forms["actv_pres_indc_3pl"] = { args[1] .. "onti" }

  data.forms["pasv_pres_indc_1sg"] = { args[1] .. "ūr" }
  data.forms["pasv_pres_indc_2sg"] = { args[1] .. "etar" }
  data.forms["pasv_pres_indc_3sg"] = { args[1] .. "etor" }
  data.forms["pasv_pres_indc_1pl"] = { args[1] .. "ommor" }
  data.forms["pasv_pres_indc_2pl"] = { args[1] .. "edwe" }
  data.forms["pasv_pres_indc_3pl"] = { args[1] .. "ontor" }

  -- Present subjunctive
  data.forms["actv_pres_subj_1sg"] = { args[1] .. "ām" }
  data.forms["actv_pres_subj_2sg"] = { args[1] .. "āsi" }
  data.forms["actv_pres_subj_3sg"] = { args[1] .. "āti" }
  data.forms["actv_pres_subj_1pl"] = { args[1] .. "āmes" }
  data.forms["actv_pres_subj_2pl"] = { args[1] .. "āte" }
  data.forms["actv_pres_subj_3pl"] = { args[1] .. "ānti" }

  data.forms["pasv_pres_subj_1sg"] = { args[1] .. "ār" }
  data.forms["pasv_pres_subj_2sg"] = { args[1] .. "ātar" }
  data.forms["pasv_pres_subj_3sg"] = { args[1] .. "ātor" }
  data.forms["pasv_pres_subj_1pl"] = { args[1] .. "āmmor" }
  data.forms["pasv_pres_subj_2pl"] = { args[1] .. "ādwe" }
  data.forms["pasv_pres_subj_3pl"] = { args[1] .. "āntor" }

  -- Imperative
  data.forms["actv_impr_2sg"] = { args[1] .. "ī" }
  data.forms["actv_impr_3sg"] = { args[1] .. "et" }
  data.forms["actv_impr_1pl"] = { args[1] .. "omu" }
  data.forms["actv_impr_2pl"] = { args[1] .. "etīs" }
  data.forms["actv_impr_3pl"] = { args[1] .. "ont" }

  data.forms["pasv_impr_2sg"] = { args[1] .. "etar" }
  data.forms["pasv_impr_3sg"] = { args[1] .. "or" }
  data.forms["pasv_impr_1pl"] = { args[1] .. "ommor" }
  data.forms["pasv_impr_2pl"] = { args[1] .. "edwe" }
  data.forms["pasv_impr_3pl"] = { args[1] .. "ontor" }

  -- Non-finite forms
  data.forms["actv_pres_ptcp"] = { args[1] .. "onts" }

  postprocess(args, data)

  return make_table(data)
end

local names = {
  ["actv"] = "Voix active",
  ["pasv"] = "Voix passive",

  ["pres_indc"] = "Présent",
  ["impf_indc"] = "Imparfait",
  ["futr_indc"] = "Futur",
  ["pret_indc"] = "Prétérit",
  ["pres_subj"] = "Subjonctif présent",
  ["past_subj"] = "Subjonctif passé",
  ["impr"] = "Impératif",

  ["1sg"] = "1ère pers. sing.",
  ["2sg"] = "2ème pers. sing.",
  ["3sg"] = "3ème pers. sing.",
  ["1pl"] = "1ère pers. plur.",
  ["2pl"] = "2ème pers. plur.",
  ["3pl"] = "3ème pers. plur.",
}

-- Make the table
function make_table(data)
  local function repl(param)
    if param == "info" then
      return mw.getContentLanguage():ucfirst(data.info or "")
    end

    local form = data.forms[param]

    if not form or #form == 0 then
      return "&mdash;"
    end

    if mw.ustring.find(form[1], "^?") then
      return "?"
    end

    local ret = {}

    for _, subform in ipairs(form) do
      local link = "[[Aide:Formes reconstruites|<abbr title=\"Forme reconstruite\">*</abbr>]][[Reconstruction:proto-celtique/" .. subform .. "|" .. subform .. "]]"
      table.insert(ret, link)
    end

    return table.concat(ret, ", ")
  end

  local pns = { "1sg", "2sg", "3sg", "1pl", "2pl", "3pl" }
  local rows = {
    { "pres_indc", "impf_indc", "futr_indc", "pret_indc" },
    { "pres_subj", "past_subj", "impr" } }
  local voices = {}

  if data.actv then
    table.insert(voices, "actv")
  end

  if data.pasv then
    table.insert(voices, "pasv")
  end

  local colnum = 0

  for _, row in ipairs(rows) do
    colnum = math.max(colnum, #row)
  end

  local wikicode = {}

  table.insert(wikicode, "{| class=\"inflection-table vsSwitcher vsToggleCategory-inflection\" style=\"background: #FAFAFA; border: 1px solid #d0d0d0; text-align: left;\" cellspacing=\"1\" cellpadding=\"2\"")
  table.insert(wikicode, "|- style=\"background: #CCCCFF;\"\n! class=\"vsToggleElement\" colspan=\"" .. (colnum + 1) .. "\" | {{{info}}}")

  for _, voice in ipairs(voices) do
    table.insert(wikicode, "|- class=\"vsHide\" style=\"background: #CCCCFF;\"")
    table.insert(wikicode, "! colspan=\"" .. (colnum + 1) .. "\" style=\"text-align: center;\" | " .. names[voice])

    for _, row in ipairs(rows) do
      table.insert(wikicode, "|- class=\"vsHide\" style=\"background: #CCCCFF;\"")
      table.insert(wikicode, "!")

      local i = 0

      for _, tm in ipairs(row) do
        table.insert(wikicode, "! style=\"min-width: 11em; background: #CCCCFF;\" | " .. names[tm])
        i = i + 1
      end

      if i < colnum then
        table.insert(wikicode, "! style=\"min-width: 11em; background: #CCCCFF;\" rowspan=\"" .. (#pns + 1) .. "\" colspan=\"" .. (colnum - i) .. "\" |")
      end

      for _, pn in ipairs(pns) do
        table.insert(wikicode, "|- class=\"vsHide\" style=\"background-color: #F2F2FF;\"")
        table.insert(wikicode, "! style=\"min-width: 8em; background-color: #E6E6FF;\" | " .. names[pn])

        for _, tm in ipairs(row) do
          table.insert(wikicode, "| {{{" .. voice .. "_" .. tm .. "_" .. pn .. "}}}")
        end
      end
    end
  end

  table.insert(wikicode, "|}")

  wikicode = table.concat(wikicode, "\n")

  return (mw.ustring.gsub(wikicode, "{{{([a-z0-9_]+)}}}", repl))
end

return export
