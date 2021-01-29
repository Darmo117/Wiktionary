local m_bases = require("Module:bases")

local p = {}

-- Functions that do the actual inflecting by creating the forms of a basic term.
local inflections = {}

-- The main entry point.
-- This is the only function that can be invoked from a template.
function p.show(frame)
  local infl_type = frame.args[1] or error("Inflection type has not been specified. Please pass parameter 1 to the module invocation")
  local args = frame:getParent().args

  if not inflections[infl_type] then
    error("Unknown inflection type '" .. infl_type .. "'")
  end

  local data = { forms = {}, title = nil, categories = {} }

  -- Generate the forms
  inflections[infl_type](args, data)

  -- Postprocess
  postprocess(args, data)

  if args["nosg"] then
    table.insert(data.categories, "et-decl with nosg")
  end

  if args["nopl"] then
    table.insert(data.categories, "Noms indénombrables en estonien")
  end

  if args["type"] then
    table.insert(data.categories, "et-decl with type")
  end

  local categories = ""

  for _, category in ipairs(data.categories) do
    categories = categories .. m_bases.fait_categorie_contenu(category)
  end

  return make_table(data) .. categories
end

function get_params(args, num, gradation)
  local params = {}

  params.base = args[1] or (mw.title.getCurrentTitle().nsText == "Template" and "{{{1}}}");
  if not params.base or params.base == "" then
    error("Parameter 1 (base stem) may not be empty.")
  end

  if gradation then
    if num == 5 then
      params.strong = args[2] or (mw.title.getCurrentTitle().nsText == "Template" and "{{{2}}}") or ""
      params.weak = args[3] or (mw.title.getCurrentTitle().nsText == "Template" and "{{{3}}}") or ""
      params.final = args[4] or (mw.title.getCurrentTitle().nsText == "Template" and "{{{4}}}");
      if not params.final or params.final == "" then
        error("Parameter 4 (final letter(s)) may not be empty.")
      end
      params.final_nom_sg = args[5] or (mw.title.getCurrentTitle().nsText == "Template" and "{{{5}}}") or ""
    elseif num == 4 then
      params.strong = args[2] or (mw.title.getCurrentTitle().nsText == "Template" and "{{{2}}}") or ""
      params.weak = args[3] or (mw.title.getCurrentTitle().nsText == "Template" and "{{{3}}}") or ""
      params.final = args[4] or (mw.title.getCurrentTitle().nsText == "Template" and "{{{4}}}");
      if not params.final or params.final == "" then
        error("Parameter 4 (final letter(s)) may not be empty.")
      end
    elseif num == 3 then
      params.strong = args[2] or (mw.title.getCurrentTitle().nsText == "Template" and "{{{2}}}") or ""
      params.weak = args[3] or (mw.title.getCurrentTitle().nsText == "Template" and "{{{3}}}") or ""
    end
  else
    if num == 3 then
      params.final = args[2] or (mw.title.getCurrentTitle().nsText == "Template" and "{{{2}}}");
      if not params.final or params.final == "" then
        error("Parameter 2 (final letter(s)) may not be empty.")
      end
      params.final_nom_sg = args[3] or (mw.title.getCurrentTitle().nsText == "Template" and "{{{3}}}") or ""
    elseif num == 2 then
      params.final = args[2] or (mw.title.getCurrentTitle().nsText == "Template" and "{{{2}}}") or ""
    end
  end

  return params
end


--[=[
    Inflection functions
]=]--

local stem_endings = {}

stem_endings["nom_sg"] = {
  ["nom_sg"] = "",
}

stem_endings["sg"] = {
  ["gen_sg"] = "",
  ["ill_sg_long"] = "sse",
  ["ine_sg"] = "s",
  ["ela_sg"] = "st",
  ["all_sg"] = "le",
  ["ade_sg"] = "l",
  ["abl_sg"] = "lt",
  ["tra_sg"] = "ks",
  ["ter_sg"] = "ni",
  ["ess_sg"] = "na",
  ["abe_sg"] = "ta",
  ["com_sg"] = "ga",
  ["nom_pl"] = "d",
}

stem_endings["par_sg"] = {
  ["par_sg"] = "",
}

stem_endings["ill_sg_short"] = {
  ["ill_sg_short"] = "",
}

stem_endings["pl_long"] = {
  ["gen_pl"] = "",
  ["ill_pl_long"] = "sse",
  ["ine_pl_long"] = "s",
  ["ela_pl_long"] = "st",
  ["all_pl_long"] = "le",
  ["ade_pl_long"] = "l",
  ["abl_pl_long"] = "lt",
  ["tra_pl_long"] = "ks",
  ["ter_pl"] = "ni",
  ["ess_pl"] = "na",
  ["abe_pl"] = "ta",
  ["com_pl"] = "ga",
}

stem_endings["pl_short"] = {
  ["ill_pl_short"] = "sse",
  ["ine_pl_short"] = "s",
  ["ela_pl_short"] = "st",
  ["all_pl_short"] = "le",
  ["ade_pl_short"] = "l",
  ["abl_pl_short"] = "lt",
  ["tra_pl_short"] = "ks",
}

stem_endings["par_pl"] = {
  ["par_pl"] = "",
}


-- Create forms based on each stem, by adding endings to it
local function process_stems(data, stems)
  -- Go through each of the stems given
  for stem_key, substems in pairs(stems) do
    for _, stem in ipairs(substems) do
      -- Attach the endings to the stem
      for form_key, ending in pairs(stem_endings[stem_key]) do
        if not data.forms[form_key] then
          data.forms[form_key] = {}
        end

        table.insert(data.forms[form_key], stem .. ending)
      end
    end
  end
end

inflections["ohutu"] = function(args, data)
  data.title = "Type ÕS [[Annexe:Déclinaison nominale estonienne|1/ohutu]], sans gradation"
  table.insert(data.categories, "Formes nominales en estonien de type ohutu")

  local params = get_params(args, 1)
  local i_stem = mw.ustring.gsub(params.base, "i$", "e")

  local stems = {}
  stems["nom_sg"] = { params.base }
  stems["sg"] = { params.base }
  stems["par_sg"] = { params.base .. "t" }
  stems["ill_sg_short"] = nil
  stems["pl_long"] = { params.base .. "te" }
  stems["pl_short"] = { i_stem .. "i" }
  stems["par_pl"] = { i_stem .. "id" }

  process_stems(data, stems)
end

inflections["õpik"] = function(args, data)
  data.title = "Type ÕS [[Annexe:Déclinaison nominale estonienne|2/õpik]], sans gradation"
  table.insert(data.categories, "Formes nominales en estonien de type õpik")

  local params = get_params(args, 3)
  local i_stem = mw.ustring.gsub(params.base .. params.final, "i$", "e")

  local stems = {}
  stems["nom_sg"] = { params.base .. params.final_nom_sg }
  stems["sg"] = { params.base .. params.final }
  stems["par_sg"] = { params.base .. params.final .. "t" }
  stems["ill_sg_short"] = nil
  stems["pl_long"] = { params.base .. params.final .. "te" }
  stems["pl_short"] = { i_stem .. "i" }
  stems["par_pl"] = { i_stem .. "id" }

  process_stems(data, stems)
end

inflections["vaher"] = function(args, data)
  data.title = "Type ÕS [[Annexe:Déclinaison nominale estonienne|3/vaher]]"
  table.insert(data.categories, "Formes nominales en estonien de type vaher")

  local params = get_params(args, 5, true)
  local i_stem = mw.ustring.gsub(params.base .. params.strong .. params.final, "i$", "e")

  if params.strong == params.weak then
    data.title = data.title .. ", length gradation"
  else
    data.title = data.title .. ", ''" .. params.strong .. "-" .. (params.weak == "" and "ø" or params.weak) .. "'' gradation"
  end

  local stems = {}
  stems["nom_sg"] = { params.base .. params.weak .. params.final_nom_sg }
  stems["sg"] = { params.base .. params.strong .. params.final }
  stems["par_sg"] = { params.base .. params.strong .. params.final .. "t" }
  stems["ill_sg_short"] = nil
  stems["pl_long"] = { params.base .. params.strong .. params.final .. "te" }
  stems["pl_short"] = { i_stem .. "i" }
  stems["par_pl"] = { i_stem .. "id" }

  process_stems(data, stems)
end

inflections["ase"] = function(args, data)
  data.title = "Type ÕS [[Annexe:Déclinaison nominale estonienne|4/ase]], sans gradation"
  table.insert(data.categories, "Formes nominales en estonien de type ase")

  local params = get_params(args, 2)

  local stems = {}
  stems["nom_sg"] = { params.base }
  stems["sg"] = { params.base .. "me" }
  stems["par_sg"] = { params.base .. params.final }
  stems["ill_sg_short"] = nil
  stems["pl_long"] = { params.base .. "mete" }
  stems["pl_short"] = { params.base .. "mei" }
  stems["par_pl"] = { params.base .. "meid" }

  process_stems(data, stems)
end

inflections["liige"] = function(args, data)
  data.title = "Type ÕS [[Annexe:Déclinaison nominale estonienne]]"
  table.insert(data.categories, "Formes nominales en estonien de type liige")

  local params = get_params(args, 5, true)
  local i_stem = mw.ustring.gsub(params.base .. params.strong .. params.final, "i$", "e")

  if params.strong == params.weak then
    data.title = data.title .. ", length gradation"
  else
    data.title = data.title .. ", ''" .. params.strong .. "-" .. (params.weak == "" and "ø" or params.weak) .. "'' gradation"
  end

  local stems = {}
  stems["nom_sg"] = { params.base .. params.weak .. params.final_nom_sg }
  stems["sg"] = { params.base .. params.strong .. params.final }
  stems["par_sg"] = { params.base .. params.weak .. params.final_nom_sg .. "t" }
  stems["ill_sg_short"] = nil
  stems["pl_long"] = { params.base .. params.strong .. params.final .. "te" }
  stems["pl_short"] = { i_stem .. "i" }
  stems["par_pl"] = { i_stem .. "id" }

  process_stems(data, stems)
end

inflections["mõte"] = function(args, data)
  data.title = "Type ÕS [[Annexe:Déclinaison nominale estonienne|6/mõte]]"
  table.insert(data.categories, "Formes nominales en estonien de type mõte")

  local params = get_params(args, 4, true)

  if params.strong == params.weak then
    data.title = data.title .. ", length gradation"
  else
    data.title = data.title .. ", ''" .. params.strong .. "-" .. (params.weak == "" and "ø" or params.weak) .. "'' gradation"
  end

  local stems = {}
  stems["nom_sg"] = { params.base .. params.weak .. params.final }
  stems["sg"] = { params.base .. params.strong .. params.final }
  stems["par_sg"] = { params.base .. params.weak .. params.final .. "t" }
  stems["ill_sg_short"] = nil
  stems["pl_long"] = { params.base .. params.weak .. params.final .. "te" }
  stems["pl_short"] = { params.base .. params.strong .. params.final .. "i" }
  stems["par_pl"] = { params.base .. params.strong .. params.final .. "id" }

  process_stems(data, stems)
end

inflections["kallas"] = function(args, data)
  data.title = "Type ÕS [[Annexe:Déclinaison nominale estonienne|7/kallas]]"
  table.insert(data.categories, "Formes nominales en estonien de type kallas")

  local params = get_params(args, 5, true)
  local i_stem = mw.ustring.gsub(params.base .. params.strong .. params.final, "i$", "e")

  if params.strong == params.weak then
    data.title = data.title .. ", length gradation"
  else
    data.title = data.title .. ", ''" .. params.strong .. "-" .. (params.weak == "" and "ø" or params.weak) .. "'' gradation"
  end

  local stems = {}
  stems["nom_sg"] = { params.base .. params.weak .. params.final_nom_sg }
  stems["sg"] = { params.base .. params.strong .. params.final }
  stems["par_sg"] = { params.base .. params.weak .. params.final_nom_sg .. "t" }
  stems["ill_sg_short"] = nil
  stems["pl_long"] = { params.base .. params.weak .. params.final_nom_sg .. "te" }
  stems["pl_short"] = { i_stem .. "i" }
  stems["par_pl"] = { i_stem .. "id" }

  process_stems(data, stems)
end

inflections["küünal"] = function(args, data)
  data.title = "Type ÕS [[Annexe:Déclinaison nominale estonienne|8/küünal]]"
  table.insert(data.categories, "Formes nominales en estonien de type küünal")

  local params = get_params(args, 5, true)

  if params.strong == params.weak then
    data.title = data.title .. ", length gradation"
  else
    data.title = data.title .. ", ''" .. params.strong .. "-" .. (params.weak == "" and "ø" or params.weak) .. "'' gradation"
  end

  local stems = {}
  stems["nom_sg"] = { params.base .. params.weak .. params.final_nom_sg }
  stems["sg"] = { params.base .. params.strong .. params.final }
  stems["par_sg"] = { params.base .. params.weak .. params.final_nom_sg .. "t" }
  stems["ill_sg_short"] = nil
  stems["pl_long"] = { params.base .. params.weak .. params.final_nom_sg .. "de" }
  stems["pl_short"] = { params.base .. params.strong .. params.final .. "i" }
  stems["par_pl"] = { params.base .. params.strong .. params.final .. "id" }

  process_stems(data, stems)
end

inflections["katus"] = function(args, data)
  data.title = "Type ÕS [[Annexe:Déclinaison nominale estonienne|9/katus]], sans gradation"
  table.insert(data.categories, "Formes nominales en estonien de type katus")

  local params = get_params(args, 1)

  local stems = {}
  stems["nom_sg"] = { params.base .. "s" }
  stems["sg"] = { params.base .. "se" }
  stems["par_sg"] = { params.base .. "st" }
  stems["ill_sg_short"] = nil
  stems["pl_long"] = { params.base .. "ste" }
  stems["pl_short"] = { params.base .. "sei" }
  stems["par_pl"] = { params.base .. "seid" }

  process_stems(data, stems)
end

inflections["soolane"] = function(args, data)
  data.title = "Type ÕS [[Annexe:Déclinaison nominale estonienne|10/soolane]], sans gradation"
  table.insert(data.categories, "Formes nominales en estonien de type soolane")

  local params = get_params(args, 2)

  local stems = {}
  stems["nom_sg"] = { params.base .. params.final }
  stems["sg"] = { params.base .. "se" }
  stems["par_sg"] = { params.base .. "st" }
  stems["ill_sg_short"] = nil
  stems["pl_long"] = { params.base .. "ste" }
  stems["pl_short"] = { params.base .. "sei" }
  stems["par_pl"] = { params.base .. "seid" }

  process_stems(data, stems)
end

inflections["harjutus"] = function(args, data)
  data.title = "Type ÕS [[Annexe:Déclinaison nominale estonienne|11/harjutus]], sans gradation"
  table.insert(data.categories, "Formes nominales en estonien de type harjutus")

  local params = get_params(args, 1)

  local stems = {}
  stems["nom_sg"] = { params.base .. "s" }
  stems["sg"] = { params.base .. "se" }
  stems["par_sg"] = { params.base .. "st" }
  stems["ill_sg_short"] = { params.base .. "sse" }
  stems["pl_long"] = { params.base .. "ste" }
  stems["pl_short"] = { params.base .. "si" }
  stems["par_pl"] = { params.base .. "si" }

  process_stems(data, stems)
end

inflections["oluline"] = function(args, data)
  data.title = "Type ÕS [[Annexe:Déclinaison nominale estonienne|12/oluline]], sans gradation"
  table.insert(data.categories, "Formes nominales en estonien de type oluline")

  local params = get_params(args, 2)

  local stems = {}
  stems["nom_sg"] = { params.base .. params.final }
  stems["sg"] = { params.base .. "se" }
  stems["par_sg"] = { params.base .. "st" }
  stems["ill_sg_short"] = { params.base .. "sse" }
  stems["pl_long"] = { params.base .. "ste" }
  stems["pl_short"] = { params.base .. "si" }
  stems["par_pl"] = { params.base .. "si" }

  process_stems(data, stems)
end

inflections["suur"] = function(args, data)
  data.title = "Type ÕS [[Annexe:Déclinaison nominale estonienne|13/suur]], gradation en lingueur"
  table.insert(data.categories, "Formes nominales en estonien de type suur")

  local params = get_params(args, 1)

  local stems = {}
  stems["nom_sg"] = { params.base }
  stems["sg"] = { params.base .. "e" }
  stems["par_sg"] = { params.base .. "t" }
  stems["ill_sg_short"] = { params.base .. "de" }
  stems["pl_long"] = { params.base .. "te" }
  stems["pl_short"] = { params.base .. "i" }
  stems["par_pl"] = { params.base .. "i" }

  process_stems(data, stems)
end

inflections["uus"] = function(args, data)
  data.title = "Type ÕS [[Annexe:Déclinaison nominale estonienne|14/uus]]"
  table.insert(data.categories, "Formes nominales en estonien de type uus")

  local params = get_params(args, 2)
  local s_stem = mw.ustring.gsub(params.base .. params.final, "n$", "")

  if params.final ~= "" then
    data.title = data.title .. ", ''" .. params.final .. "d/" .. params.final .. "t-" .. params.final .. params.final .. "-" .. params.final .. "s'' gradation"
  else
    data.title = data.title .. ", ''d/t-ø-s'' gradation"
  end

  local stems = {}
  stems["nom_sg"] = { s_stem .. "s" }
  stems["sg"] = { params.base .. params.final .. params.final .. "e" }
  stems["par_sg"] = { params.base .. params.final .. "t" }
  stems["ill_sg_short"] = { params.base .. params.final .. "de" }
  stems["pl_long"] = { params.base .. params.final .. "te" }
  stems["pl_short"] = { s_stem .. "si" }
  stems["par_pl"] = { s_stem .. "si" }

  process_stems(data, stems)
end

inflections["käsi"] = function(args, data)
  data.title = "Type ÕS [[Annexe:Déclinaison nominale estonienne|15/käsi]], ''d/t-ø-s'' gradation"
  table.insert(data.categories, "Formes nominales en estonien de type käsi")

  local params = get_params(args, 1)
  local weak_stem = params.base

  if mw.ustring.find(params.base, "u$") then
    -- susi
    weak_stem = mw.ustring.gsub(params.base, "u$", "o")
  end

  local stems = {}
  stems["nom_sg"] = { params.base .. "si" }
  stems["sg"] = { weak_stem .. "e" }
  stems["par_sg"] = { params.base .. "tt" }
  stems["ill_sg_short"] = { params.base .. "tte" }
  stems["pl_long"] = { params.base .. "te" }
  stems["pl_short"] = { params.base .. "si" }
  stems["par_pl"] = { params.base .. "si" }

  process_stems(data, stems)
end

inflections["pere"] = function(args, data)
  data.title = "Type ÕS [[Annexe:Déclinaison nominale estonienne|16/pere]], sans gradation"
  table.insert(data.categories, "Formes nominales en estonien de type pere")

  local params = get_params(args, 1)
  local ill_sg_stem = params.base

  if mw.ustring.find(ill_sg_stem, "[^aeiouõäöü][aeiouõäöü][^aeiouõäöü][aeiouõäöü]$") or mw.ustring.find(ill_sg_stem, "^[aeiouõäöü][^aeiouõäöü][aeiouõäöü]$") then
    ill_sg_stem = mw.ustring.gsub(ill_sg_stem, "(.)(.)$", "%1%1%2")
  end

  local stems = {}
  stems["nom_sg"] = { params.base }
  stems["sg"] = { params.base }
  stems["par_sg"] = { params.base .. "t" }
  stems["ill_sg_short"] = { ill_sg_stem }
  stems["pl_long"] = { params.base .. "de" }
  stems["pl_short"] = {}
  stems["par_pl"] = { params.base .. "sid" }

  process_stems(data, stems)
end

inflections["elu"] = function(args, data)
  data.title = "Type ÕS [[Annexe:Déclinaison nominale estonienne|17/elu]], sans gradation"
  table.insert(data.categories, "Formes nominales en estonien de type elu")

  local params = get_params(args, 1)
  local ill_sg_stem = params.base

  if mw.ustring.find(ill_sg_stem, "[^aeiouõäöü][aeiouõäöü][^aeiouõäöü][aeiouõäöü]$") or mw.ustring.find(ill_sg_stem, "^[aeiouõäöü][^aeiouõäöü][aeiouõäöü]$") then
    local base, cons, vowel = mw.ustring.match(ill_sg_stem, "^(.-)(.)(.)$")

    if cons == "b" then
      ill_sg_stem = base .. "pp" .. vowel
    elseif cons == "d" then
      ill_sg_stem = base .. "tt" .. vowel
    elseif cons == "g" then
      ill_sg_stem = base .. "kk" .. vowel
    else
      ill_sg_stem = base .. cons .. cons .. vowel
    end
  end

  local stems = {}
  stems["nom_sg"] = { params.base }
  stems["sg"] = { params.base }
  stems["par_sg"] = { params.base }
  stems["ill_sg_short"] = { ill_sg_stem }
  stems["pl_long"] = { params.base .. "de" }
  stems["pl_short"] = {}
  stems["par_pl"] = { params.base .. "sid" }

  process_stems(data, stems)
end

inflections["kivi"] = function(args, data)
  data.title = "Type ÕS [[Annexe:Déclinaison nominale estonienne|17e/kivi]], sans gradation"
  table.insert(data.categories, "Formes nominales en estonien de type kivi")

  local params = get_params(args, 1)
  local pl_stem = mw.ustring.gsub(params.base, "[aeiouõäöü]$", "e")
  local ill_sg_stem = params.base

  if mw.ustring.find(ill_sg_stem, "[^aeiouõäöü][aeiouõäöü][^aeiouõäöü][aeiouõäöü]$") or mw.ustring.find(ill_sg_stem, "^[aeiouõäöü][^aeiouõäöü][aeiouõäöü]$") then
    ill_sg_stem = mw.ustring.gsub(ill_sg_stem, "(.)(.)$", "%1%1%2")
  end

  local stems = {}
  stems["nom_sg"] = { params.base }
  stems["sg"] = { params.base }
  stems["par_sg"] = { params.base }
  stems["ill_sg_short"] = { ill_sg_stem }
  stems["pl_long"] = { params.base .. "de" }
  stems["pl_short"] = { pl_stem }
  stems["par_pl"] = { pl_stem, params.base .. "sid" }

  process_stems(data, stems)
end

inflections["pesa"] = function(args, data)
  data.title = "Type ÕS [[Annexe:Déclinaison nominale estonienne|17i/pesa]], sans gradation"
  table.insert(data.categories, "Formes nominales en estonien de type pesa")

  local params = get_params(args, 1)
  local pl_stem = mw.ustring.gsub(params.base, "[aeiouõäöü]$", "i")
  local ill_sg_stem = params.base

  if mw.ustring.find(ill_sg_stem, "[^aeiouõäöü][aeiouõäöü][^aeiouõäöü][aeiouõäöü]$") or mw.ustring.find(ill_sg_stem, "^[aeiouõäöü][^aeiouõäöü][aeiouõäöü]$") then
    ill_sg_stem = mw.ustring.gsub(ill_sg_stem, "(.)(.)$", "%1%1%2")
  end

  local stems = {}
  stems["nom_sg"] = { params.base }
  stems["sg"] = { params.base }
  stems["par_sg"] = { params.base }
  stems["ill_sg_short"] = { ill_sg_stem }
  stems["pl_long"] = { params.base .. "de" }
  stems["pl_short"] = { pl_stem }
  stems["par_pl"] = { pl_stem, params.base .. "sid" }

  process_stems(data, stems)
end

inflections["sõna"] = function(args, data)
  data.title = "Type ÕS [[Annexe:Déclinaison nominale estonienne|17u/sõna]], sans gradation"
  table.insert(data.categories, "Formes nominales en estonien de type sõna")

  local params = get_params(args, 1)
  local pl_stem = mw.ustring.gsub(params.base, "[aeiouõäöü]$", "u")
  local ill_sg_stem = params.base

  if mw.ustring.find(ill_sg_stem, "[^aeiouõäöü][aeiouõäöü][^aeiouõäöü][aeiouõäöü]$") or mw.ustring.find(ill_sg_stem, "^[aeiouõäöü][^aeiouõäöü][aeiouõäöü]$") then
    local base, cons, vowel = mw.ustring.match(ill_sg_stem, "^(.-)(.)(.)$")

    if cons == "b" then
      ill_sg_stem = base .. "pp" .. vowel
    else
      ill_sg_stem = base .. cons .. cons .. vowel
    end
  end

  local stems = {}
  stems["nom_sg"] = { params.base }
  stems["sg"] = { params.base }
  stems["par_sg"] = { params.base }
  stems["ill_sg_short"] = { ill_sg_stem }
  stems["pl_long"] = { params.base .. "de" }
  stems["pl_short"] = { pl_stem }
  stems["par_pl"] = { pl_stem, params.base .. "sid" }

  process_stems(data, stems)
end

inflections["nägu"] = function(args, data)
  data.title = "Type ÕS [[Annexe:Déclinaison nominale estonienne|18/nägu]]"
  table.insert(data.categories, "Formes nominales en estonien de type nägu")

  local params = get_params(args, 4, true)

  if params.strong == params.weak then
    data.title = data.title .. ", sans gradation"
  else
    data.title = data.title .. ", ''" .. params.strong .. "-" .. (params.weak == "" and "ø" or params.weak) .. "'' gradation"
  end

  local extra_strong = params.strong
  local weak_stem = params.base .. params.weak .. params.final

  if params.strong == "b" then
    extra_strong = "pp"
  elseif params.strong == "d" then
    extra_strong = "tt"
  elseif params.strong == "g" then
    extra_strong = "kk"
  end

  if params.weak == "" then
    if mw.ustring.find(params.base, "ä$") and params.final == "u" then
      -- nägu
      weak_stem = params.base .. "o"
    end
  end

  local stems = {}
  stems["nom_sg"] = { params.base .. params.strong .. params.final }
  stems["sg"] = { weak_stem }
  stems["par_sg"] = { params.base .. params.strong .. params.final }
  stems["ill_sg_short"] = { params.base .. extra_strong .. params.final }
  stems["pl_long"] = { params.base .. params.strong .. params.final .. "de" }
  stems["pl_short"] = {}
  stems["par_pl"] = { params.base .. params.strong .. params.final .. "sid" }

  process_stems(data, stems)
end

inflections["tuba"] = function(args, data)
  data.title = "Type ÕS [[Annexe:Déclinaison nominale estonienne|18e/tuba]]"
  table.insert(data.categories, "Formes nominales en estonien de type tuba")

  local params = get_params(args, 4, true)

  if params.strong == params.weak then
    data.title = data.title .. ", sans gradation"
  else
    data.title = data.title .. ", ''" .. params.strong .. "-" .. (params.weak == "" and "ø" or params.weak) .. "'' gradation"
  end

  local extra_strong = params.strong
  local weak_stem = params.base .. params.weak .. params.final

  if params.strong == "b" then
    extra_strong = "pp"
  elseif params.strong == "d" then
    extra_strong = "tt"
  elseif params.strong == "g" then
    extra_strong = "kk"
  end

  if params.weak == "" then
    if mw.ustring.find(params.base, "u$") then
      -- tuba
      if params.final == "a" then
        weak_stem = mw.ustring.gsub(params.base, "u$", "o") .. params.final
      end
    end
  end

  local stems = {}
  stems["nom_sg"] = { params.base .. params.strong .. params.final }
  stems["sg"] = { weak_stem }
  stems["par_sg"] = { params.base .. params.strong .. params.final }
  stems["ill_sg_short"] = { params.base .. extra_strong .. params.final }
  stems["pl_long"] = { params.base .. params.strong .. params.final .. "de" }
  stems["pl_short"] = {}
  stems["par_pl"] = { params.base .. params.strong .. "e", params.base .. params.strong .. params.final .. "sid" }

  process_stems(data, stems)
end

inflections["sõda"] = function(args, data)
  data.title = "Type ÕS [[Annexe:Déclinaison nominale estonienne|18u/sõda]]"
  table.insert(data.categories, "Formes nominales en estonien de type sõda")

  local params = get_params(args, 4, true)

  if params.strong == params.weak then
    data.title = data.title .. ", sans gradation"
  else
    data.title = data.title .. ", ''" .. params.strong .. "-" .. (params.weak == "" and "ø" or params.weak) .. "'' gradation"
  end

  local extra_strong = params.strong
  local weak_stem = params.base .. params.weak .. params.final
  local weak_pl_stem = params.base .. params.weak .. "u"

  if params.strong == "b" then
    extra_strong = "pp"
  elseif params.strong == "d" then
    extra_strong = "tt"
  elseif params.strong == "g" then
    extra_strong = "kk"
  end

  if params.weak == "" then
    if mw.ustring.find(params.base, "i$") then
      -- rida
      if params.final == "a" then
        weak_stem = mw.ustring.gsub(params.base, "i$", "e") .. params.final
      end

      weak_pl_stem = nil
    end
  end

  local stems = {}
  stems["nom_sg"] = { params.base .. params.strong .. params.final }
  stems["sg"] = { weak_stem }
  stems["par_sg"] = { params.base .. params.strong .. params.final }
  stems["ill_sg_short"] = { params.base .. extra_strong .. params.final }
  stems["pl_long"] = { params.base .. params.strong .. params.final .. "de" }
  stems["pl_short"] = { weak_pl_stem }
  stems["par_pl"] = { params.base .. params.strong .. "u", params.base .. params.strong .. params.final .. "sid" }

  process_stems(data, stems)
end

inflections["seminar"] = function(args, data)
  data.title = "Type ÕS [[Annexe:Déclinaison nominale estonienne|19/seminar]], sans gradation"
  table.insert(data.categories, "Formes nominales en estonien de type seminar")

  local params = get_params(args, 1)

  local stems = {}
  stems["nom_sg"] = { params.base }
  stems["sg"] = { params.base .. "i" }
  stems["par_sg"] = { params.base .. "i" }
  stems["ill_sg_short"] = { params.base .. "i" }
  stems["pl_long"] = { params.base .. "ide" }
  stems["pl_short"] = { params.base .. "e" }
  stems["par_pl"] = { params.base .. "e", params.base .. "isid" }

  process_stems(data, stems)
end

inflections["süli"] = function(args, data)
  data.title = "Type ÕS [[Annexe:Déclinaison nominale estonienne|20/süli]], sans gradation"
  table.insert(data.categories, "Formes nominales en estonien de type süli")

  local params = get_params(args, 1)
  local ill_sg_stem = params.base

  if mw.ustring.find(ill_sg_stem, "[^aeiouõäöü][aeiouõäöü][^aeiouõäöü]$") or mw.ustring.find(ill_sg_stem, "^[aeiouõäöü][^aeiouõäöü]$") then
    local base, cons = mw.ustring.match(ill_sg_stem, "^(.-)(.)$")
    ill_sg_stem = base .. cons .. cons
  end

  local stems = {}
  stems["nom_sg"] = { params.base .. "i" }
  stems["sg"] = { params.base .. "e" }
  stems["par_sg"] = { params.base .. "e" }
  stems["ill_sg_short"] = { ill_sg_stem .. "e" }
  stems["pl_long"] = { params.base .. "ede" }
  stems["pl_short"] = {}
  stems["par_pl"] = { params.base .. "esid" }

  process_stems(data, stems)
end

inflections["jõgi"] = function(args, data)
  data.title = "Type ÕS [[Annexe:Déclinaison nominale estonienne|21/jõgi]]"
  table.insert(data.categories, "Formes nominales en estonien de type jõgi")

  local params = get_params(args, 3, true)
  local extra_strong = params.strong

  if params.strong == "g" then
    extra_strong = "kk"
  end

  if params.strong == params.weak then
    data.title = data.title .. ", length gradation"
  else
    data.title = data.title .. ", ''" .. params.strong .. "-" .. (params.weak == "" and "ø" or params.weak) .. "'' gradation"
  end

  local stems = {}
  stems["nom_sg"] = { params.base .. params.strong .. "i" }
  stems["sg"] = { params.base .. params.weak .. "e" }
  stems["par_sg"] = { params.base .. params.strong .. "e" }
  stems["ill_sg_short"] = { params.base .. extra_strong .. "e" }
  stems["pl_long"] = { params.base .. params.strong .. "ede" }
  stems["pl_short"] = {}
  stems["par_pl"] = { params.base .. params.strong .. "esid" }

  process_stems(data, stems)
end

inflections["õnnelik"] = function(args, data)
  data.title = "Type ÕS [[Annexe:Déclinaison nominale estonienne|25/õnnelik]], ''kk-k'' gradation"
  table.insert(data.categories, "Formes nominales en estonien de type õnnelik")

  local params = get_params(args, 1)

  local stems = {}
  stems["nom_sg"] = { params.base .. "k" }
  stems["sg"] = { params.base .. "ku" }
  stems["par_sg"] = { params.base .. "kku" }
  stems["ill_sg_short"] = { params.base .. "kku" }
  stems["pl_long"] = { params.base .. "ke", params.base .. "kkude" }
  stems["pl_short"] = {}
  stems["par_pl"] = { params.base .. "kke", params.base .. "kkusid" }

  process_stems(data, stems)
end

inflections["koi"] = function(args, data)
  data.title = "Type ÕS [[Annexe:Déclinaison nominale estonienne|26/koi]], sans gradation"
  table.insert(data.categories, "Formes nominales en estonien de type koi")

  local params = get_params(args, 1)
  local par_sg = args["par_sg"];
  if par_sg == "" then
    par_sg = nil
  end  -- For nõu

  local stems = {}
  stems["nom_sg"] = { params.base }
  stems["sg"] = { params.base }
  stems["par_sg"] = { par_sg or params.base .. "d" }
  stems["ill_sg_short"] = {}
  stems["pl_long"] = { params.base .. "de" }
  stems["pl_short"] = {}
  stems["par_pl"] = { params.base .. "sid" }

  process_stems(data, stems)
end

inflections["idee"] = function(args, data)
  data.title = "Type ÕS [[Annexe:Déclinaison nominale estonienne|26i/idee]], sans gradation"
  table.insert(data.categories, "Formes nominales en estonien de type idee")

  local params = get_params(args, 1)
  local ill_sg2 = args["ill_sg2"];
  if ill_sg2 == "" then
    ill_sg2 = nil
  end
  local shortened_stem, vowel = mw.ustring.match(params.base, "^(.-)([aeiouõäöü]?)$")

  local stems = {}
  stems["nom_sg"] = { params.base }
  stems["sg"] = { params.base }
  stems["par_sg"] = { params.base .. "d" }
  stems["ill_sg_short"] = {}
  stems["pl_long"] = { params.base .. "de" }
  stems["pl_short"] = { shortened_stem .. "i" }
  stems["par_pl"] = { shortened_stem .. "id", params.base .. "sid" }

  process_stems(data, stems)

  if ill_sg2 then
    table.insert(data.forms["ill_sg_long"], shortened_stem .. "h" .. vowel)
  end
end


-- Helper functions

local function combine(forms1, forms2)
  if forms1 and forms2 then
    local ret = mw.clone(forms1)

    for _, form in ipairs(forms2) do
      table.insert(ret, form)
    end

    return ret
  elseif forms1 then
    return mw.clone(forms1)
  elseif forms2 then
    return mw.clone(forms2)
  else
    return nil
  end
end

function postprocess(args, data)
  local n = args["n"];
  if n == "" then
    n = nil
  end

  data.forms["ill_sg"] = combine(data.forms["ill_sg_short"], data.forms["ill_sg_long"])

  for _, case in ipairs({ "ill", "ine", "ela", "all", "ade", "abl", "tra" }) do
    data.forms[case .. "_pl"] = combine(data.forms[case .. "_pl_long"], data.forms[case .. "_pl_short"])
  end

  if n == "pl" then
    table.insert(data.categories, "Formes nominales en estonien de type pluralia tantum")
  end

  -- TODO: This says "nouns", but this module is also used for adjectives!
  if n == "sg" then
    table.insert(data.categories, "Formes nominales en estonien de type uncountable nouns")
  end

  for key, form in pairs(data.forms) do
    -- Do not show singular or plural forms for nominals that don't have them
    if (n == "pl" and key:find("_sg$")) or (n == "sg" and key:find("_pl$")) then
      form = nil
    end

    data.forms[key] = form
  end

  -- Check if the lemma form matches the page name
  if data.forms[n == "pl" and "nom_pl" or "nom_sg"][1] ~= mw.title.getCurrentTitle().text then
    table.insert(data.categories, "Mots en estonien dont la déclinaison ne correspond pas au titre de la page")
  end
end

-- Make the table
function make_table(data)
  local function show_form(form)
    if not form then
      return "&mdash;"
    elseif type(form) ~= "table" then
      error("a non-table value was given in the list of inflected forms.")
    end

    local ret = {}

    for _, subform in ipairs(form) do
      table.insert(ret, mw.ustring.format("[[%s]]", subform))
    end

    return table.concat(ret, "<br/>")
  end

  local function repl(param)
    if param == "lemma" then
      return mw.ustring.format("[[%s]]", mw.title.getCurrentTitle().text)
    elseif param == "info" then
      return data.title and " (" .. data.title .. ")" or ""
    else
      return show_form(data.forms[param])
    end
  end

  local wikicode = [=[<div class="inflection-table {{#if:{{{appendix|}}}{{{nonav|}}}||mw-collapsible}}" style="float: right; max-width: 50%; min-width: 20%; overflow-x: auto; border: 1px solid #aaa; background: white;">
<div style="background:#DDF; text-align: center; font-weight: bold;">Déclinaison</div>
<div class="mw-collapsible-content">
{| class="flextable" style="margin: 0 auto; float: none;"
|+ Déclinaison de {{{lemma}}}{{{info}}}
! Cas
! Singulier
! Pluriel
|- style="background:rgb(95%,95%,100%);vertical-align:top;"
! style="background:rgb(80%,80%,100%);" | Nominatif
| {{{nom_sg}}}
| {{{nom_pl}}}
|- style="background:rgb(95%,95%,100%);vertical-align:top;"
! style="background:rgb(80%,80%,100%);" | Accusatif
| {{{gen_sg}}}
| {{{nom_pl}}}
|- style="background:rgb(95%,95%,100%);vertical-align:top;"
! style="background:rgb(80%,80%,100%);" | Génitif
| {{{gen_sg}}}
| {{{gen_pl}}}
|- style="background:rgb(95%,95%,100%);vertical-align:top;"
! style="background:rgb(80%,80%,100%);" | Partitif
| {{{par_sg}}}
| {{{par_pl}}}
|- style="background:rgb(95%,95%,100%);vertical-align:top;"
! style="background:rgb(80%,80%,100%);" | Illatif
| {{{ill_sg}}}
| {{{ill_pl}}}
|- style="background:rgb(95%,95%,100%);vertical-align:top;"
! style="background:rgb(80%,80%,100%);" | Inessif
| {{{ine_sg}}}
| {{{ine_pl}}}
|- style="background:rgb(95%,95%,100%);vertical-align:top;"
! style="background:rgb(80%,80%,100%);" | Élatif
| {{{ela_sg}}}
| {{{ela_pl}}}
|- style="background:rgb(95%,95%,100%);vertical-align:top;"
! style="background:rgb(80%,80%,100%);" | Allatif
| {{{all_sg}}}
| {{{all_pl}}}
|- style="background:rgb(95%,95%,100%);vertical-align:top;"
! style="background:rgb(80%,80%,100%);" | Adessif
| {{{ade_sg}}}
| {{{ade_pl}}}
|- style="background:rgb(95%,95%,100%);vertical-align:top;"
! style="background:rgb(80%,80%,100%);" | Ablatif
| {{{abl_sg}}}
| {{{abl_pl}}}
|- style="background:rgb(95%,95%,100%);vertical-align:top;"
! style="background:rgb(80%,80%,100%);" | Translatif
| {{{tra_sg}}}
| {{{tra_pl}}}
|- style="background:rgb(95%,95%,100%);vertical-align:top;"
! style="background:rgb(80%,80%,100%);" | Terminatif
| {{{ter_sg}}}
| {{{ter_pl}}}
|- style="background:rgb(95%,95%,100%);vertical-align:top;"
! style="background:rgb(80%,80%,100%);" | Essif
| {{{ess_sg}}}
| {{{ess_pl}}}
|- style="background:rgb(95%,95%,100%);vertical-align:top;"
! style="background:rgb(80%,80%,100%);" | Abessif
| {{{abe_sg}}}
| {{{abe_pl}}}
|- style="background:rgb(95%,95%,100%);vertical-align:top;"
! style="background:rgb(80%,80%,100%);" | Comitatif
| {{{com_sg}}}
| {{{com_pl}}}
|}
</div>

</div>]=]

  return mw.ustring.gsub(wikicode, "{{{([a-z0-9_]+)}}}", repl)
end

return p
