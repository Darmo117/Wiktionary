local p = {}

--[=[
Authorship:
  Original source code from enwikt: Ben Wing <benwing2>
  Conversion for frwikt: Darmo117

]=]
--[=[
TERMINOLOGY:
-- "slot" = A particular combination of tense/mood/person/number/etc.
	 Example slot names for verbs are "pres_1s" (present first singular) and
	 "subc_subii_3p" (subordinate-clause subjunctive II third plural).
	 Each slot is filled with zero or more forms.
-- "form" = The conjugated German form representing the value of a given slot.
-- "lemma" = The dictionary form of a given German term. For German, always the infinitive.
]=]
--[=[
FIXME:
1. Handle fensterln. (DONE)
2. Handle spie- past tense of speien. (DONE)
3. Make sure rathen, verheirathen work. (DONE)
4. Modify einfix to better handle managen, framen. (DONE)
5. Use variant codes so variant imperatives with and without -e match up in conjoined verbs e.g. [[ausschneiden und einfügen]].
6. In conjoined verbs e.g. [[ausschneiden und einfügen]], don't repeat auxiliaries.
--]=]

local lang = require("Module:languages").getByCode("de")
local m_string_utilities = require("Module:string utilities")
local m_links = require("Module:links")
local m_table = require("Module:table")
local iut = require("Module:inflection utilities")

local rfind = mw.ustring.find
local rmatch = mw.ustring.match
local rsplit = mw.text.split

local function link_term(term, face)
  return m_links.full_link({ lang = lang, term = term }, face)
end

local vowel = "aeiouyäëïöüÿáéíóúýàèìòùỳâêîôûŷãẽĩõũỹ"
local vowel_c = "[" .. vowel .. "]"
local not_vowel_c = "[^" .. vowel .. "]"

local function ends_in_dt(stem)
  return stem:find("[dt]h?$")
end

local inseparable_prefixes = {
  "be", "emp", "ent", "er", "ge", "miss", "miß", "ver", "zer",
  -- can also be separable
  "durch", "hinter", "über", "um", "unter", "voll", "wider", "wieder",
}

local wuerde = link_term("würde", "term")
local past_subjunctive_single_word_preferred = m_table.listToSet {
  "haben", "sein", "können", "müssen", "dürfen", "mögen", "sollen", "wollen", "werden"
}
local past_subjunctive_single_word_preferred_footnote = "[preferred; avoid the alternative in " .. wuerde .. "]"

local past_subjunctive_single_word_often_used = m_table.listToSet {
  "brauchen", "finden", "geben", "gehen", "halten", "heißen", "heissen", "kommen", "lassen", "stehen", "tun", "thun", "wissen"
}
local past_subjunctive_single_word_often_used_footnote = "[this form and alternative in " .. wuerde .. " both found]"

local past_subjunctive_single_word_rare_footnote = "[rare except in very formal contexts; alternative in " .. wuerde .. " normally preferred]"

local schst_footnote = "[permitted officially in Austria; used colloquially throughout the German-speaking area]"

local all_persons_numbers = {
  ["1s"] = "1|s",
  ["2s"] = "2|s",
  ["3s"] = "3|s",
  ["1p"] = "1|p",
  ["2p"] = "2|p",
  ["3p"] = "3|p",
}

local person_number_list = { "1s", "2s", "3s", "1p", "2p", "3p", }
local persnum_to_index = {}
for k, v in pairs(person_number_list) do
  persnum_to_index[v] = k
end
local imp_person_number_list = { "2s", "2p", }

local verb_slots_basic = {
  { "infinitive", "inf" },
  { "infinitive_linked", "inf" },
  { "pres_part", "pres|part" },
  { "perf_part", "perf|part" },
  { "zu_infinitive", "zu" }, -- will be handled specially by [[Module:accel/de]]
  { "aux", "-" },
}

local verb_slots_subordinate_clause = {
}

local verb_slots_composed = {
}

-- Add entries for a slot with person/number variants.
-- `verb_slots` is the table to add to.
-- `slot_prefix` is the prefix of the slot, typically specifying the tense/aspect.
-- `tag_suffix` is the set of inflection tags to add after the person/number tags,
-- or "-" to use "-" as the inflection tags (which indicates that no accelerator entry
-- should be generated).
local function add_slot_personal(verb_slots, slot_prefix, tag_suffix)
  for persnum, persnum_tag in pairs(all_persons_numbers) do
    local slot = slot_prefix .. "_" .. persnum
    if tag_suffix == "-" then
      table.insert(verb_slots, { slot, "-" })
    else
      table.insert(verb_slots, { slot, persnum_tag .. "|" .. tag_suffix })
    end
  end
end

add_slot_personal(verb_slots_basic, "pres", "pres")
add_slot_personal(verb_slots_basic, "subi", "sub|I")
add_slot_personal(verb_slots_basic, "pret", "pret")
add_slot_personal(verb_slots_basic, "subii", "sub|II")
table.insert(verb_slots_basic, { "imp_2s", "s|imp" })
table.insert(verb_slots_basic, { "imp_2p", "p|imp" })
add_slot_personal(verb_slots_subordinate_clause, "subc_pres", "dep|pres")
add_slot_personal(verb_slots_subordinate_clause, "subc_subi", "dep|sub|I")
add_slot_personal(verb_slots_subordinate_clause, "subc_pret", "dep|pret")
add_slot_personal(verb_slots_subordinate_clause, "subc_subii", "dep|sub|II")
add_slot_personal(verb_slots_composed, "perf_ind", "-")
add_slot_personal(verb_slots_composed, "perf_sub", "-")
add_slot_personal(verb_slots_composed, "plup_ind", "-")
add_slot_personal(verb_slots_composed, "plup_sub", "-")
table.insert(verb_slots_composed, { "futi_inf", "-" })
add_slot_personal(verb_slots_composed, "futi_subi", "-")
add_slot_personal(verb_slots_composed, "futi_ind", "-")
add_slot_personal(verb_slots_composed, "futi_subii", "-")
table.insert(verb_slots_composed, { "futii_inf", "-" })
add_slot_personal(verb_slots_composed, "futii_subi", "-")
add_slot_personal(verb_slots_composed, "futii_ind", "-")
add_slot_personal(verb_slots_composed, "futii_subii", "-")

local all_verb_slots = {}
for _, slot_and_accel in ipairs(verb_slots_basic) do
  table.insert(all_verb_slots, slot_and_accel)
end
for _, slot_and_accel in ipairs(verb_slots_subordinate_clause) do
  table.insert(all_verb_slots, slot_and_accel)
end
for _, slot_and_accel in ipairs(verb_slots_composed) do
  table.insert(all_verb_slots, slot_and_accel)
end

local pronouns = { "ich", "du", "er", "wir", "ihr", "sie", }

irreg_verbs = {
  ["haben"] = {
    ["pres"] = { "habe", "hast", "hat", "haben", "habt", "haben", },
    ["pret"] = { "hatte", "hattest", "hatte", "hatten", "hattet", "hatten", },
    ["subi"] = { "habe", "habest", "habe", "haben", "habet", "haben", },
    ["subii"] = { "hätte", "hättest", "hätte", "hätten", "hättet", "hätten", },
    ["imp"] = { { "hab", "habe" }, "habt", },
    ["presp"] = "habend",
    ["pp"] = "habt",
  },
  ["sein"] = {
    ["pres"] = { "bin", "bist", "ist", "sind", "seid", "sind", },
    ["pret"] = { "war", "warst", "war", "waren", "wart", "waren", },
    ["subi"] = { "sei", { "seist", "seiest" }, "sei", "seien", "seiet", "seien", },
    ["subii"] = { "wäre", { "wärst", "wärest" }, "wäre", "wären", { "wärt", "wäret" }, "wären", },
    ["imp"] = { "sei", "seid", },
    ["presp"] = "seiend",
    ["pp"] = "wesen",
  },
  ["tun"] = {
    ["pres"] = { "tue", "tust", "tut", "tun", "tut", "tun", },
    ["pret"] = { "tat", { "tatest", "tatst" }, "tat", "taten", "tatet", "taten", },
    ["subi"] = { "tue", "tuest", "tue", "tuen", "tuet", "tuen", },
    ["subii"] = { "täte", "tätest", "täte", "täten", "tätet", "täten", },
    ["imp"] = { { "tu", "tue" }, "tut", },
    ["presp"] = "tuend",
    ["pp"] = "tan",
  },
  -- FIXME, maybe we should construct this automatically from "tun".
  ["thun"] = {
    ["pres"] = { "thue", "thust", "thut", "thun", "thut", "thun", },
    ["pret"] = { "that", { "thatest", "thatst" }, "that", "thaten", "thatet", "thaten", },
    ["subi"] = { "thue", "thuest", "thue", "thuen", "thuet", "thuen", },
    ["subii"] = { "thäte", "thätest", "thäte", "thäten", "thätet", "thäten", },
    ["imp"] = { { "thu", "thue" }, "thut", },
    ["presp"] = "thuend",
    ["pp"] = "than",
  },
  ["werden"] = {
    ["pres"] = { "werde", "wirst", "wird", "werden", "werdet", "werden", },
    ["pret"] = {
      { "wurde", { form = "ward", footnotes = { "[archaic]" } } },
      { "wurdest", { form = "wardst", footnotes = { "[archaic]" } } },
      { "wurde", { form = "ward", footnotes = { "[archaic]" } } },
      "wurden",
      "wurdet",
      "wurden",
    },
    ["subi"] = { "werde", "werdest", "werde", "werden", "werdet", "werden", },
    ["subii"] = { "würde", "würdest", "würde", "würden", "würdet", "würden", },
    ["imp"] = { { "werd", "werde" }, "werdet", },
    ["presp"] = "werdend",
    ["pp"] = "worden",
  },
}

local sein_forms = {
  ["sein"] = { "mein", "dein", "sein", "unser", "euer", "ihr" },
  ["seine"] = { "meine", "deine", "seine", "unsere", "eure", "ihre" },
  ["seinen"] = { "meinen", "deinen", "seinen", "unseren", "euren", "ihren" },
  ["seinem"] = { "meinem", "deinem", "seinem", "unserem", "eurem", "ihrem" },
  ["seiner"] = { "meiner", "deiner", "seiner", "unserer", "eurer", "ihrer" },
  ["seines"] = { "meines", "deines", "seines", "unseses", "eures", "ihres" },
}

local sich_forms = {
  ["accpron"] = { "mich", "dich", "sich", "uns", "euch", "sich" },
  ["datpron"] = { "mir", "dir", "sich", "uns", "euch", "sich" },
}

local function skip_slot(base, slot)
  if not slot:find("[123]") then
    -- Don't skip non-personal slots.
    return false
  end

  if base.nofinite then
    return true
  end

  if base.only3s and not slot:find("3s") or
      base.only3sp and not slot:find("3[sp]") then
    return true
  end

  return false
end

local function strip_spaces(text)
  return text:gsub("^%s*(.-)%s*", "%1")
end

local function escape_sein_sich_indicators(arg1)
  if not arg1:find("pron>") then
    return arg1
  end
  local segments = iut.parse_balanced_segment_run(arg1, "<", ">")
  -- Loop over every other segment. The even-numbered segments are angle-bracket specs while
  -- the odd-numbered segments are the text between them.
  for i = 2, #segments - 1, 2 do
    if segments[i] == "<accpron>" then
      segments[i] = "⦃⦃accpron⦄⦄"
    elseif segments[i] == "<datpron>" then
      segments[i] = "⦃⦃datpron⦄⦄"
    elseif segments[i] == "<pron>" then
      segments[i] = "⦃⦃pron⦄⦄"
    end
  end
  return table.concat(segments)
end

local function undo_escape_form(form)
  -- assign to var to throw away second value
  local newform = form:gsub("⦃⦃", "<"):gsub("⦄⦄", ">")
  return newform
end

local function remove_sein_sich_indicators(form)
  -- assign to var to throw away second value
  local newform = form:gsub("⦃⦃.-⦄⦄", "")
  return newform
end

local function replace_sein_sich_indicators(slot, form)
  if not form:find("⦃") then
    return form
  end
  local persnum = slot:match("^.*_([123][sp])$")
  local index
  if persnum then
    index = persnum_to_index[persnum]
  else
    index = 3
  end
  form = form:gsub("sich(%]*)⦃⦃accpron⦄⦄", function(brackets)
    return sich_forms.accpron[index] .. brackets
  end)
  form = form:gsub("sich(%]*)⦃⦃datpron⦄⦄", function(brackets)
    return sich_forms.datpron[index] .. brackets
  end)
  form = form:gsub("(seine?[mnrs]?)(%]*)⦃⦃pron⦄⦄", function(sein_form, brackets)
    if sein_forms[sein_form] then
      return sein_forms[sein_form][index] .. brackets
    else
      error("Unrecognized sein-form '" .. sein_form .. "' in slot " .. slot .. ": " .. undo_escape_form(form))
    end
  end)
  form = form:gsub("sein%]%](e?[mnrs]?)⦃⦃pron⦄⦄", function(sein_ending, _)
    local sein_form = "sein" .. sein_ending
    if sein_forms[sein_form] then
      return sein_forms["sein"][index] .. "|" .. sein_forms[sein_form][index] .. "]]"
    else
      error("Unrecognized sein-form '" .. sein_form .. "' in slot " .. slot .. ": " .. undo_escape_form(form))
    end
  end)
  if form:find("⦃⦃") or form:find("⦄⦄") then
    error("Unrecognized pronoun substitution in slot " .. slot .. ": " .. undo_escape_form(form))
  end
  return form
end

local function combine_stem_ending(slot, stem, ending)
  local ending_with_pound = ending .. "#"
  if ending_with_pound:find("^st[ #]") then
    if rfind(stem, "[sxzß]$") then
      ending = ending:gsub("^s", "")
    elseif stem:find("st$") then
      -- bersten
      ending = ending:gsub("^st", "")
    end
  elseif ending_with_pound:find("^t[ #]") and stem:find("th?$") then
    ending = ending:gsub("^t", "")
  end
  return replace_sein_sich_indicators(slot, stem .. ending)
end

local function add(base, slot, stems, endings, footnotes)
  if skip_slot(base, slot) then
    return
  end
  local function do_combine_stem_ending(stem, ending)
    return combine_stem_ending(slot, stem, ending)
  end
  iut.add_forms(base.forms, slot, stems, endings, do_combine_stem_ending, nil, nil,
      iut.combine_footnotes(footnotes, base.all_footnotes))
end

local function add_multi(base, slot, stems_and_endings, footnotes)
  if skip_slot(base, slot) then
    return
  end
  local function do_combine_stem_ending(stem, ending)
    return combine_stem_ending(slot, stem, ending)
  end
  iut.add_multiple_forms(base.forms, slot, stems_and_endings, do_combine_stem_ending, nil, nil,
      iut.combine_footnotes(footnotes, base.all_footnotes))
end

local function add3(base, slot, stems1, stems2, endings, _)
  return add_multi(base, slot, { stems1, stems2, endings })
end

local function add4(base, slot, stems1, stems2, stems3, endings, _)
  return add_multi(base, slot, { stems1, stems2, stems3, endings })
end

local function add5(base, slot, stems1, stems2, stems3, stems4, endings, _)
  return add_multi(base, slot, { stems1, stems2, stems3, stems4, endings })
end

local function get_subii_note(base)
  if base.from_headword then
    -- don't include autogenerated note if from_headword, so it doesn't end up in the headword qualifiers
    return nil
  end
  if past_subjunctive_single_word_preferred[base.base_verb] then
    return { past_subjunctive_single_word_preferred_footnote }
  elseif past_subjunctive_single_word_often_used[base.base_verb] then
    return { past_subjunctive_single_word_often_used_footnote }
  end
  return { past_subjunctive_single_word_rare_footnote }
end

local function add_zu_infinitive(base)
  if base.any_pre_pref then
    local zu
    if base.pre_pref == "" or base.pre_pref:find(" $") then
      zu = "zu "
    else
      zu = "zu"
    end
    add(base, "zu_infinitive", base.pre_pref .. zu, base.bare_infinitive)
  end
end

local function add_present(base, pretpres)
  local stems = base.infstem
  local stems23 = base.pres_23 or stems

  local function doadd(slot_pref, form_pref)
    -- Do forms based off the infinitive stem.
    for _, stemform in ipairs(stems) do
      local prefixed_stem = form_pref .. stemform.form
      local syncopated_stem = base.unstressed_el_er and prefixed_stem:gsub("e([lr])$", "%1")

      local function addit(slot, stem, ending, footnotes)
        add(base, slot_pref .. slot, stem, ending .. (slot_pref == "" and base.post_pref or ""),
            iut.combine_footnotes(footnotes, stemform.footnotes))
      end

      -- first singular present indicative
      if not pretpres then
        -- pres_1s for preterite-present verbs used pres23 stem
        if base.unstressed_el_er then
          addit("pres_1s", syncopated_stem, "e")
          addit("pres_1s", prefixed_stem, "e")
          addit("pres_1s", prefixed_stem, "")
        else
          addit("pres_1s", prefixed_stem, "e")
        end
      end

      -- plural present indicative
      local e_in_2p = ends_in_dt(prefixed_stem) or base.unstressed_e_infix
      if e_in_2p then
        addit("pres_2p", prefixed_stem, "et")
      else
        addit("pres_2p", prefixed_stem, "t")
      end
      if base.unstressed_el_er or base.unstressed_erl then
        addit("pres_1p", prefixed_stem, "n")
        addit("pres_3p", prefixed_stem, "n")
      else
        addit("pres_1p", prefixed_stem, "en")
        addit("pres_3p", prefixed_stem, "en")
      end

      -- subjunctive I
      addit("subi_1s", prefixed_stem, "e")
      addit("subi_2s", prefixed_stem, "est")
      addit("subi_3s", prefixed_stem, "e")
      addit("subi_2p", prefixed_stem, "et")
      if base.unstressed_el_er then
        addit("subi_1s", syncopated_stem, "e")
        addit("subi_2s", syncopated_stem, "est")
        addit("subi_3s", syncopated_stem, "e")
        addit("subi_2p", syncopated_stem, "et")
      end
      if base.unstressed_el_er then
        addit("subi_1p", prefixed_stem, "n")
        addit("subi_3p", prefixed_stem, "n")
      else
        addit("subi_1p", prefixed_stem, "en")
        addit("subi_3p", prefixed_stem, "en")
      end

      -- imperative plural; most preterite-present verbs don't have it, and [[wissen]] is handled below
      if slot_pref == "" and not pretpres then
        if e_in_2p then
          addit("imp_2p", prefixed_stem, "et")
        else
          addit("imp_2p", prefixed_stem, "t")
        end
      end
    end

    -- Do forms based off of pres23 stem (also includes pres_1sg in preterite-present verbs).
    for _, stem23form in ipairs(stems23) do
      local prefixed_stem23 = form_pref .. stem23form.form

      local function addit(slot, stem, ending, footnotes)
        add(base, slot_pref .. slot, stem, ending .. (slot_pref == "" and base.post_pref or ""),
            iut.combine_footnotes(footnotes, stem23form.footnotes))
      end

      if pretpres then
        -- Totally different code for preterite-present singular and imperative.
        addit("pres_1s", prefixed_stem23, "")
        addit("pres_2s", prefixed_stem23, "st")
        addit("pres_3s", prefixed_stem23, "")
        if slot_pref == "" and base.base_verb == "wissen" then
          -- Only [[wissen]] among the preterite-present verbs has an imperative.
          addit("imp_2s", "wiss", "e")
          -- dewikt mentions 'wisset' as an alternative, but not in Duden
          addit("imp_2p", "wiss", "t")
        end
      else
        -- Normal code path.
        local stem23_is_same_as_stem
        for _, stemform in ipairs(stems) do
          if stemform.form == stem23form.form then
            stem23_is_same_as_stem = true
            break
          end
        end

        -- present 2/3 singular
        local e_in_23s = base.unstressed_e_infix or stem23_is_same_as_stem and ends_in_dt(prefixed_stem23)
        if e_in_23s then
          addit("pres_2s", prefixed_stem23, "est")
          addit("pres_3s", prefixed_stem23, "et")
        else
          addit("pres_2s", prefixed_stem23, "st")
          if prefixed_stem23:find("sch$") then
            addit("pres_2s", prefixed_stem23, "t",
                not base.from_headword and { schst_footnote } or nil)
          end
          addit("pres_3s", prefixed_stem23, "t")
        end

        -- imperative singular; this may or may not be based off the pres23 stem
        -- Specifically, if the pres23 stem is different from the infinitive stem and does not have an ä or ö
        -- in it ([[fahren]], er [[fährt]] but imperative [[fahr]]/[[fahre]]; [[stoßen]], er [[stößt]] but
        -- imperative [[stoß]]/[[stoße]]), use it. Don't add -e unless '.longimp' is given (for [[sehen]], with
        -- imperatives [[sieh]] and [[siehe]]; but normally [[geben]] with imperative only [[gib]], similarly
        -- for [[treten]], [[gelten]], [[bergen]], [[etc.]]). In all other cases, use the infinitive stem, and
        -- under normal circumstances include two variants, without -e and with -e. We include only the variant
        -- with -e if '.e' is given ([[atmen]], [[zeichnen]], etc.), and we include only the variant without -e
        -- if '.shortimp' is given (unclear if this is needed for any verb).
        if slot_pref == "" then
          if not rfind(prefixed_stem23, "[äö]") and not stem23_is_same_as_stem then
            addit("imp_2s", prefixed_stem23, "")
            if base.longimp then
              addit("imp_2s", prefixed_stem23, "e")
            end
          else
            assert(form_pref == "")
            for _, stemform in ipairs(stems) do
              local function addimp(stem, ending)
                add(base, "imp_2s", stem, ending .. base.post_pref, stemform.footnotes)
              end
              local stem = stemform.form
              if base.unstressed_el_er then
                local syncopated_stem = stem:gsub("e([lr])$", "%1")
                addimp(syncopated_stem, "e")
              end
              if base.unstressed_e_infix then
                addimp(stem, "e")
              elseif base.shortimp then
                addimp(stem, "")
              else
                addimp(stem, "")
                addimp(stem, "e")
              end
            end
          end
        end
      end
    end
  end

  -- Do the basic forms
  doadd("", "")
  -- Also do the subordinate clause forms if any alternants have a prefix.
  if base.any_pre_pref then
    doadd("subc_", base.pre_pref)
  end

  -- Do the miscellaneous non-finite forms
  add3(base, "pres_part", base.pre_pref, base.bare_infinitive, "d")
  add_zu_infinitive(base)
end


-- Add the past forms and/or subjunctive II forms. `is_past` should be true if we're conjugating the past tense
-- (not the past subjunctive), in which case the stems in `stem` should be the actual 1s/3s forms, ending in -te
-- or -de if weak. If `is_past` is false, we're conjugating the past subjunctive. In that case, the stems passed
-- in should include -e if that needs to be preserved in all forms (specifically, for [[spie]] past of [[speien]];
-- syncopated #'spist' is not allowed). (In practice, we chop off the final -e of explicitly user-specified past
-- subjunctive forms and otherwise pass in the actual past tense. This means that user-specified past subjunctives
-- in -te (e.g. [[brächte]]) will be passed in as 'brächt' but past subjunctives defaulted from the past tense
-- will be passed in e.g. as 'lachte'. This works because for stems in -t and -d, the result is the same.)
local function add_past_or_subii(base, slot_pref, stems, is_past)
  local function doadd(full_slot_pref, form_pref)
    for _, stemform in ipairs(stems) do
      local prefixed_stem = form_pref .. stemform.form
      local ends_in_e = prefixed_stem:find("e$")
      -- Normally, the weak past tense ends in -te and the strong past does not end in -e. An exception is
      -- [[spie]] (past tense of [[speien]]), which will be treated as weak (superseded spellings like
      -- 'spieen' will not be generated).
      local is_strong = is_past and not ends_in_e
      prefixed_stem = prefixed_stem:gsub("e$", "")
      local stem_ends_in_dt = ends_in_dt(prefixed_stem)

      local function addit(slot, ending, footnotes)
        local subii_footnotes
        if full_slot_pref:find("subii") then
          subii_footnotes = get_subii_note(base)
        end
        add(base, full_slot_pref .. slot, prefixed_stem, ending .. (full_slot_pref == slot_pref and base.post_pref or ""),
            iut.combine_footnotes(subii_footnotes, iut.combine_footnotes(footnotes, stemform.footnotes)))
      end

      if is_strong then
        addit("1s", "")
        addit("3s", "")
        if not stem_ends_in_dt then
          if rfind(prefixed_stem, "[sxzß]$") then
            addit("2s", "est")
          end
          addit("2s", "st")
          addit("2p", "t")
        else
          -- bitten -> batest or batst, similarly for laden, raten, etc.
          addit("2s", "est")
          if not prefixed_stem:find("st$") then
            -- bersten
            addit("2s", "st")
          end
          addit("2p", "et")
        end
      else
        -- Weak past and past subjunctive have same endings when ending in -d or -t (always the case for weak past).
        addit("1s", "e")
        addit("3s", "e")
        if not stem_ends_in_dt and not ends_in_e then
          addit("2s", "est") -- more formal; FIXME: should we footnote this?
          addit("2p", "et") -- more formal; FIXME: should we footnote this?
          addit("2s", "st")
          addit("2p", "t")
        else
          addit("2s", "est")
          addit("2p", "et")
        end
      end

      -- Both pasts, as well as past subjunctive, have same endings in 1p and 3p.
      addit("1p", "en")
      addit("3p", "en")
    end
  end

  -- Do the basic forms
  doadd(slot_pref, "")
  -- Also do the subordinate clause forms if any alternants have a prefix.
  if base.any_pre_pref then
    doadd("subc_" .. slot_pref, base.pre_pref)
  end
end

local conjs = {}

conjs["normal"] = function(base)
  add_present(base)
  add_past_or_subii(base, "pret_", base.past, "past")
  add_past_or_subii(base, "subii_", base.past_sub or base.past)
end

conjs["pretpres"] = function(base)
  add_present(base, "pretpres")
  add_past_or_subii(base, "pret_", base.past, "past")
  add_past_or_subii(base, "subii_", base.past_sub or base.past)
end

conjs["irreg"] = function(base)
  local function doadd(slot_pref)
    local function addit(slot, forms, footnotes)
      if slot_pref == "" then
        add3(base, slot, base.insep_prefix, forms, base.post_pref, footnotes)
      else
        add(base, slot_pref .. slot, base.pre_pref .. base.insep_prefix, forms, footnotes)
      end
    end

    -- Do present, preterite, subjunctive I and II.
    for _, slot_tense in ipairs({ "pres", "pret", "subi", "subii" }) do
      for index, forms in ipairs(base.irregverbobj[slot_tense]) do
        local persnum = person_number_list[index]
        local footnotes
        if slot_tense == "subii" then
          footnotes = get_subii_note(base)
        end
        addit(slot_tense .. "_" .. persnum, forms, footnotes)
      end
    end

    -- Do imperative.
    if slot_pref == "" then
      for index, forms in ipairs(base.irregverbobj["imp"]) do
        local persnum = imp_person_number_list[index]
        addit("imp_" .. persnum, forms)
      end
    end
  end

  -- Do the basic forms
  doadd("")
  -- Also do the subordinate clause forms if any alternants have a prefix.
  if base.any_pre_pref then
    doadd("subc_")
  end

  -- Do the miscellaneous non-finite forms
  iut.add_multiple_forms(base, "pp", { base.ge_prefix, base.insep_prefix, base.irregverbobj["pp"] },
  -- We don't want to use combine_stem_ending because we want sein-sich indicators to be left alone,
  -- so they get replaced later when constructing composed forms.
      function(stem, ending)
        return stem .. ending
      end)
  add(base, "perf_part", base.pre_pref, base.pp)
  -- only [[werden]] by itself; not [[loswerden]], [[fertigwerden]], etc.
  if base.lemma == "werden" then
    iut.insert_form(base.forms, "perf_part", { form = "worden", footnotes = { "[as an auxiliary]" } })
  end
  add(base, "pres_part", base.pre_pref .. base.insep_prefix, base.irregverbobj["presp"])
  add_zu_infinitive(base)
end

local function add_composed_forms(base)
  local function add_composed(tense_mood, index, persnum, auxforms, participle, suffix, footnotes)
    local pers_auxforms = iut.convert_to_general_list_form(auxforms[index])
    local linked_pers_auxforms = iut.map_forms(pers_auxforms, function(form)
      return "[[" .. form .. "]] "
    end)
    add4(base, tense_mood .. "_" .. persnum, linked_pers_auxforms, "[[" .. base.pre_pref, participle, "]]" .. suffix, footnotes)
  end

  local function add_composed_perf(tense_mood, index, persnum, haben_auxforms, sein_auxforms, haben_suffix, sein_suffix)
    for _, auxform in ipairs(base.aux) do
      if auxform.form == "haben" then
        add_composed(tense_mood, index, persnum, haben_auxforms, base.pp, haben_suffix, auxform.footnotes)
      end
      if auxform.form == "sein" then
        add_composed(tense_mood, index, persnum, sein_auxforms, base.pp, sein_suffix, auxform.footnotes)
      end
    end
  end

  local haben_forms = irreg_verbs["haben"]
  local sein_forms_ = irreg_verbs["sein"]
  local werden_forms = irreg_verbs["werden"]
  for index, persnum in ipairs(person_number_list) do
    add_composed_perf("perf_ind", index, persnum, haben_forms["pres"], sein_forms_["pres"], "", "")
    add_composed_perf("perf_sub", index, persnum, haben_forms["subi"], sein_forms_["subi"], "", "")
    add_composed_perf("plup_ind", index, persnum, haben_forms["pret"], sein_forms_["pret"], "", "")
    add_composed_perf("plup_sub", index, persnum, haben_forms["subii"], sein_forms_["subii"], "", "")
    for _, mood in ipairs({ "ind", "subi", "subii" }) do
      local tense = mood == "ind" and "pres" or mood
      add_composed("futi_" .. mood, index, persnum, werden_forms[tense], base.bare_infinitive, "")
      add_composed_perf("futii_" .. mood, index, persnum, werden_forms[tense], werden_forms[tense], " [[haben]]", " [[sein]]")
    end
  end

  add3(base, "futi_inf", "[[" .. base.pre_pref, base.bare_infinitive, "]] [[werden]]")
  add5(base, "futii_inf", "[[" .. base.pre_pref, base.pp, "]] [[", base.aux, "]] [[werden]]")
end

local function handle_derived_slots(base)
  -- Compute linked versions of potential lemma slots, for use in {{de-verb}}.
  -- We substitute the original lemma (before removing links) for forms that
  -- are the same as the lemma, if the original lemma has links.
  for _, slot in ipairs({ "infinitive" }) do
    iut.insert_forms(base.forms, slot .. "_linked", iut.map_forms(base.forms[slot], function(form)
      if form == base.lemma and rfind(base.linked_lemma, "%[%[") then
        return base.linked_lemma
      else
        return form
      end
    end))
  end
end

local function conjugate_verb(base)
  if not conjs[base.conj] then
    error("Internal error: Unrecognized conjugation type '" .. base.conj .. "'")
  end
  conjs[base.conj](base)
  add_composed_forms(base)
  -- No overrides implemented currently.
  -- process_slot_overrides(base)
  handle_derived_slots(base)
end

local function parse_indicator_spec(angle_bracket_spec)
  local base = {}
  local function parse_err(msg)
    error(msg .. ": " .. angle_bracket_spec)
  end
  local function fetch_footnotes(separated_group)
    local footnotes
    for j = 2, #separated_group - 1, 2 do
      if separated_group[j + 1] ~= "" then
        parse_err("Extraneous text after bracketed footnotes: '" .. table.concat(separated_group) .. "'")
      end
      if not footnotes then
        footnotes = {}
      end
      table.insert(footnotes, separated_group[j])
    end
    return footnotes
  end

  local function fetch_specs(comma_separated_group, transform_form)
    if not comma_separated_group then
      return { {} }
    end
    local specs = {}

    local colon_separated_groups = iut.split_alternating_runs(comma_separated_group, ":")
    for _, colon_separated_group in ipairs(colon_separated_groups) do
      local form = colon_separated_group[1]
      if transform_form then
        form = transform_form(form)
      end
      table.insert(specs, { form = form, footnotes = fetch_footnotes(colon_separated_group) })
    end
    return specs
  end

  local inside = angle_bracket_spec:match("^<(.*)>$")
  assert(inside)
  if inside == "" then
    return base
  end
  local segments = iut.parse_balanced_segment_run(inside, "[", "]")
  local dot_separated_groups = iut.split_alternating_runs(segments, "%.")
  for _, dot_separated_group in ipairs(dot_separated_groups) do
    local comma_separated_groups = iut.split_alternating_runs(dot_separated_group, "%s*[,#]%s*", "preserve splitchar")
    local first_element = comma_separated_groups[1][1]
    if first_element == "haben" or first_element == "sein" then
      for j = 1, #comma_separated_groups, 2 do
        if j > 1 and strip_spaces(comma_separated_groups[j - 1][1]) ~= "," then
          parse_err("Separator of # not allowed with haben or sein")
        end
        local aux = comma_separated_groups[j][1]
        if aux ~= "haben" and aux ~= "sein" then
          parse_err("Unrecognized auxiliary '" .. aux .. "'")
        end
        if base.aux then
          for _, existing_aux in ipairs(base.aux) do
            if existing_aux.form == aux then
              parse_err("Auxiliary '" .. aux .. "' specified twice")
            end
          end
        else
          base.aux = {}
        end
        table.insert(base.aux, { form = aux, footnotes = fetch_footnotes(comma_separated_groups[j]) })
      end
    elseif first_element == "-ge" or first_element == "+ge" then
      for j = 1, #comma_separated_groups, 2 do
        if j > 1 and strip_spaces(comma_separated_groups[j - 1][1]) ~= "," then
          parse_err("Separator of # not allowed with +ge or -ge")
        end
        local prefix = comma_separated_groups[j][1]
        if prefix ~= "+ge" and prefix ~= "-ge" then
          parse_err("Unrecognized ge- prefix '" .. prefix .. "'")
        end
        local ge_prefix
        if prefix == "+ge" then
          ge_prefix = "ge"
        else
          ge_prefix = ""
        end
        if base.ge_prefix then
          for _, existing_prefix in ipairs(base.ge_prefix) do
            if existing_prefix.form == ge_prefix then
              parse_err("Ge- prefix '" .. prefix .. "' specified twice")
            end
          end
        else
          base.ge_prefix = {}
        end
        table.insert(base.ge_prefix, { form = ge_prefix, footnotes = fetch_footnotes(comma_separated_groups[j]) })
      end
    elseif #comma_separated_groups > 1 then
      -- principal parts specified
      if base.past then
        parse_err("Can't specify principal parts twice")
      end
      assert(#comma_separated_groups[2] == 1)
      local past_index
      local first_separator = strip_spaces(comma_separated_groups[2][1])
      if first_separator == "#" then
        -- present 3rd singular specified
        base.pres_23 = fetch_specs(comma_separated_groups[1], function(form)
          local stem
          if base.conj == "pretpres" then
            stem = form
          else
            stem = form:match("^(.-)%-$")
            if not stem then
              stem = form:match("^(.-)e?t$")
            end
          end
          if stem then
            return stem
          else
            parse_err("Present 3sg form '" .. form .. "' should end in - (for the stem) or -t")
          end
        end)
        past_index = 3
      else
        past_index = 1
      end

      base.past = fetch_specs(comma_separated_groups[past_index], function(form)
        return form
      end)

      if #comma_separated_groups < past_index + 2 then
        parse_err("Missing past participle spec")
      end
      assert(#comma_separated_groups[past_index + 1] == 1)
      if strip_spaces(comma_separated_groups[past_index + 1][1]) ~= "," then
        parse_err("Only first separator can be a #")
      end
      base.pp = fetch_specs(comma_separated_groups[past_index + 2], function(form)
        if form:find("e[nd]$") or form:find("t$") then
          return form
        else
          parse_err("Past participle '" .. form .. "' should end in -en, -t, or -ed")
        end
      end)

      if #comma_separated_groups > past_index + 2 then
        assert(#comma_separated_groups[past_index + 3] == 1)
        if strip_spaces(comma_separated_groups[past_index + 3][1]) ~= "," then
          parse_err("Only first separator can be a #")
        end
        base.past_sub = fetch_specs(comma_separated_groups[past_index + 4], function(form)
          local stem = form:match("^(.-)e$")
          if not stem then
            parse_err("Past subjunctive '" .. form .. "' should end in -e")
          end
          return stem
        end)
        if #comma_separated_groups > past_index + 4 then
          parse_err("Too many specs given")
        end
      end
    elseif first_element == "pretpres" or first_element == "irreg" then
      if #comma_separated_groups[1] > 1 then
        parse_err("No footnotes allowed with '" .. first_element .. "' spec")
      end
      if base.conj then
        parse_err("Conjugation specified as '" .. first_element .. "' but already specified or autodetermined as '" .. base.conj .. "'")
      end
      base.conj = first_element
    elseif first_element == "einfix" or first_element == "-einfix" then
      if #comma_separated_groups[1] > 1 then
        parse_err("No footnotes allowed with '" .. first_element .. "' spec")
      end
      base.unstressed_e_infix = first_element == "einfix"
    elseif first_element == "shortimp" or first_element == "longimp" or
        first_element == "only3s" or first_element == "only3sp" or
        first_element == "nofinite" then
      if #comma_separated_groups[1] > 1 then
        parse_err("No footnotes allowed with '" .. first_element .. "' spec")
      end
      base[first_element] = true
    elseif first_element == "" or first_element == "inf" then
      local footnotes = fetch_footnotes(comma_separated_groups[1])
      if not footnotes then
        parse_err("Empty spec and 'inf' spec without footnotes not allowed")
      end
      if first_element == "inf" then
        base.infstem_footnotes = footnotes
      else
        base.all_footnotes = footnotes
      end
    else
      parse_err("Unrecognized spec '" .. comma_separated_groups[1][1] .. "'")
    end
  end

  return base
end


-- Normalize all lemmas, splitting off separable prefixes and substituting the pagename for blank lemmas.
local function normalize_all_lemmas(alternant_multiword_spec, from_headword)
  local any_pre_pref
  iut.map_word_specs(alternant_multiword_spec, function(base)
    if base.lemma == "" then
      local PAGENAME = mw.title.getCurrentTitle().text
      base.lemma = PAGENAME
    end
    if base.lemma:find("_") and not base.lemma:find("%[%[") then
      -- If lemma is multiword and has no links, add links automatically.
      base.lemma = "[[" .. base.lemma:gsub("_", "]]_[[") .. "]]"
    end
    base.orig_lemma = base.lemma
    base.orig_lemma_no_links = m_links.remove_links(base.lemma)
    -- Normalize the linked lemma by removing dot, underscore, and <pron> and such indicators.
    base.linked_lemma = remove_sein_sich_indicators(base.lemma:gsub("%.", ""):gsub("_", " "))
    base.lemma = m_links.remove_links(base.linked_lemma)
    local lemma = base.orig_lemma_no_links
    base.pre_pref, base.post_pref = "", ""
    local prefix, verb = lemma:match("^(.*)_(.-)$")
    if prefix then
      prefix = prefix:gsub("_", " ") -- in case of multiple preceding words
      base.pre_pref = base.pre_pref .. prefix .. " "
      base.post_pref = base.post_pref .. " " .. prefix
    else
      verb = lemma
    end
    prefix, base.base_verb = verb:match("^(.*)%.(.-)$")
    if prefix then
      -- There may be multiple separable prefixes (e.g. [[wiedergutmachen]], ich mache wieder gut)
      base.pre_pref = base.pre_pref .. prefix:gsub("%.", "")
      base.post_pref = base.post_pref .. " " .. prefix:gsub("%.", " ")
    else
      base.base_verb = verb
    end
    if base.pre_pref ~= "" then
      any_pre_pref = true
    end
    if base.only3s then
      alternant_multiword_spec.only3s = true
    end
    if base.only3sp then
      alternant_multiword_spec.only3sp = true
    end
    -- Remove <pron> indicators and such.
    local reconstructed_lemma = remove_sein_sich_indicators(base.pre_pref .. base.base_verb)
    if reconstructed_lemma ~= base.lemma then
      error("Internal error: Raw lemma '" .. base.lemma .. "' differs from reconstructed lemma '" .. reconstructed_lemma .. "'")
    end
    base.from_headword = from_headword
  end)
  if any_pre_pref then
    iut.map_word_specs(alternant_multiword_spec, function(base)
      base.any_pre_pref = true
    end)
  end
  if alternant_multiword_spec.only3s then
    iut.map_word_specs(alternant_multiword_spec, function(base)
      if not base.only3s then
        error("If some alternants specify 'only3s', all must")
      end
    end)
  end
  if alternant_multiword_spec.only3sp then
    iut.map_word_specs(alternant_multiword_spec, function(base)
      if not base.only3sp then
        error("If some alternants specify 'only3sp', all must")
      end
    end)
  end
end

local function detect_verb_type(base, verb_types)
  local this_verb_types = {}

  local function set_verb_type()
    base.verb_types = this_verb_types

    if verb_types then
      for _, verb_type in ipairs(this_verb_types) do
        m_table.insertIfNot(verb_types, verb_type)
      end
    end
  end

  if base.conj == "pretpres" then
    m_table.insertIfNot(this_verb_types, "pretpres")
    set_verb_type()
    return
  elseif base.conj == "irreg" then
    m_table.insertIfNot(this_verb_types, "irreg")
    set_verb_type()
    return
  end

  local infstem = m_table.deepcopy(base.infstem)
  local past = m_table.deepcopy(base.past)
  local pp = m_table.deepcopy(base.pp)

  local function matches_forms(forms, expected, ending_to_chop)
    expected = expected:gsub("C", not_vowel_c) .. "$"
    local seen = false
    for _, form in ipairs(forms) do
      local stem
      if ending_to_chop then
        stem = rmatch(form.form, "^(.*)" .. ending_to_chop .. "$")
      else
        stem = form.form
      end
      if stem and rfind("#" .. stem, expected) then
        seen = true
        form.seen = form.seen or "maybe"
      end
    end
    return seen
  end

  local function reset_maybes(forms, value)
    for _, form in ipairs(forms) do
      if form.seen == "maybe" then
        form.seen = value
      end
    end
  end

  local function reset_all_maybes(value)
    reset_maybes(infstem, value)
    reset_maybes(past, value)
    reset_maybes(pp, value)
  end

  local function has_unseen_weak_pp()
    for _, form in ipairs(pp) do
      if not form.seen and form.form:find("[dt]$") then
        return true
      end
    end
    return false
  end

  local function has_unseen_strong_pp()
    for _, form in ipairs(pp) do
      if not form.seen and form.form:find("n$") then
        return true
      end
    end
    return false
  end

  local function check(verbtype, infre, pastre, ppre, exclude)
    if exclude then
      for _, form in ipairs(infstem) do
        if exclude(form.form) then
          return
        end
      end
    end
    if matches_forms(infstem, infre) and
        matches_forms(past, pastre) and
        matches_forms(pp, ppre, "en") then
      m_table.insertIfNot(this_verb_types, verbtype)
      reset_all_maybes(true)
    else
      reset_all_maybes(false)
    end
  end

  local function check_strong()
    check("1", "Ce[iy]C*", "CieC*", "Cie?C*") -- beigen, bleiben, gedeihen, leihen, meiden, preisen, reiben, reihen,
    -- scheiden, scheinen, schreiben, schreien, schweigen, speiben, speien, speisen, steigen, treiben, weisen,
    -- zeihen; use 'Cie?C*' for past participle to handle 'schrien', 'spien'
    check("1", "Ce[iy]C*", "CiC*", "CiC*") -- beißen/beissen/beyßen/beyssen, bleichen, fleißen/fleissen, gleichen,
    -- gleiten, greifen, kneifen, kreischen, leiden, pfeifen, reißen/reissen, reiten, scheißen/scheissen,
    -- schleichen, schleifen, schleißen/schleissen, schmeißen/schmeissen, schneiden/schneyden, schreiten,
    -- spleißen/spleissen, streichen, streiten, weichen
    check("2", "CieC*", "CoC*", "CoC*") -- biegen, bieten, fliegen, fliehen, fließen/fliessen, frieren,
    -- genießen/geniessen, gießen/giessen, kiesen, kriechen, riechen, schieben, schießen/schiessen, schliefen,
    -- schließen/schliessen, sieden, sprießen/spriessen, stieben, triefen, verdrießen/verdriessen, verlieren,
    -- wiegen, ziehen
    check("2", "CauC*", "CoC*", "CoC*") -- krauchen, saufen, saugen
    check("2", "CüC", "CoC", "CoC") -- lügen, trügen
    local function exclude_nehmen_sprechen(form)
      -- need to exclude nehmen, stehlen, befehlen/empfehlen, sprechen, brechen, stechen
      return rfind(form, vowel_c .. "ch$") or rfind(form, vowel_c .. "h" .. not_vowel_c .. "$")
    end
    check("3", "C[ei]CC+", "CaCC+", "C[ou]CC+", exclude_nehmen_sprechen) -- [with e, + o in pp]: bergen, bersten,
    -- gelten, helfen, schelten, sterben, verderben, werben, werfen; [with i, + u in pp]: binden, brinnen, dringen,
    -- finden, gelingen, klingen, misslingen, ringen, schlingen, schwinden, schwingen, singen, sinken, springen,
    -- stinken, trinken, winden, wringen, zwingen; [with i, + o in pp]: rinnen, gewinnen, schwimmen, sinnen,
    -- spinnen
    check("3", "C[eiaö]CC+", "CoCC+", "CoCC+", exclude_nehmen_sprechen)
    -- [with e]: dreschen, fechten, flechten, melken, quellen, schmelzen, schwellen; [with i]: glimmen, klimmen;
    -- [with a]: schallen (geschallt), erschallen; [with ö]: erlöschen
    check("3", "quell", "quoll", "quoll") -- need to special-case quellen due to u preceding e
    check("3", "schind", "schund", "schund") -- need to special-case due to 'u' in past
    check("4", "C[eäo]C*", "Cah?Ch?", "CoC*") -- [with e]: befehlen, brechen, schrecken, nehmen, sprechen, stechen,
    -- stecken (gesteckt), stehlen, treffen; [with ä]: gebären; [with o]: kommen
    check("4", "C[äe]C", "Coh?C", "Coh?C", function(form)
      return form:find("heb$")
    end)
    -- [with ä]: gären, wägen, schwären; [with e]: bewegen, weben, scheren (but not heben)
    check("5", "C[ei]C*", "CaC", "CeC*") -- [with e, one C]: geben, genesen, geschehen, lesen, meßen, sehen, treten;
    -- [with e, two C]: essen, fressen, messen, vergessen; [with i, two C]: bitten, sitzen
    check("5", "C[ei]C*", "Cass", "Cess") -- essen, fressen, messen, sitzen in Swiss spelling
    check("5", "CieC", "CaC", "CeC") -- liegen
    check("6", "CaC*", "CuC*", "CaC*") -- backen, fragen (gefragt), graben, laden, mahlen, schaffen, schlagen,
    -- tragen, wachsen, waschen
    check("6", "heb", "h[ou]b", "hob") -- we need to special-case this because heben (class 6 per Wikipedia) has the
    -- exact same vowels as weben (class 4 per Wikipedia)
    check("6", "schwör", "schw[ou]r", "schwor") -- only strong verb with these vowels
    check("7", "CaC*", "CieC*", "CaC*") -- blasen, braten, fallen, halten, lassen, raten/rathen, schlafen
    check("7", "C[aäe]C*", "CiC*", "CaC*") -- [with a]: fangen; [with ä]: hängen; [with e]: gehen
    check("7", "Ce[iy]C*", "CieC*", "Ce[iy]C*") -- heißen/heissen/heyßen/heyssen
    check("7", "CauC*", "CieC*", "CauC*") -- hauen, laufen
    check("7", "CoC*", "CieC*", "CoC*") -- stoßen/stossen
    check("7", "CuC*", "CieC*", "CuC*") -- rufen
  end

  for _, form in ipairs(past) do
    local past_stem = form.form:match("^(.*)te$")
    if past_stem then
      if matches_forms(infstem, "#" .. past_stem) then
        -- Need to run matches_forms() on all possibilities even if earlier ones match,
        -- to mark the seen forms correctly.
        local matches_pp = matches_forms(pp, "#" .. past_stem .. "t")
        matches_pp = matches_forms(pp, "#ge" .. past_stem .. "t") or matches_pp
        if matches_pp then
          m_table.insertIfNot(this_verb_types, "weak")
          form.seen = true
          reset_all_maybes(true)
        else
          reset_all_maybes(false)
        end
      end
    end
    if not form.seen and form.form:find("ete$") then
      if matches_forms(infstem, "#" .. past_stem:gsub("e$", "")) then
        -- Need to run matches_forms() on all possibilities even if earlier ones match,
        -- to mark the seen forms correctly.
        local matches_pp = matches_forms(pp, "#" .. past_stem .. "t")
        matches_pp = matches_forms(pp, "#ge" .. past_stem .. "t") or matches_pp
        matches_pp = matches_forms(pp, "#" .. past_stem .. "d") or matches_pp
        matches_pp = matches_forms(pp, "#ge" .. past_stem .. "d") or matches_pp
        if matches_pp then
          m_table.insertIfNot(this_verb_types, "weak")
          form.seen = true
          reset_all_maybes(true)
        else
          reset_all_maybes(false)
        end
      end
    end
    if past_stem and not form.seen then
      if not has_unseen_weak_pp() and has_unseen_strong_pp() then
        m_table.insertIfNot(this_verb_types, "mixed")
      else
        m_table.insertIfNot(this_verb_types, "irregweak")
      end
      matches_forms(pp, "#" .. past_stem .. "t")
      matches_forms(pp, "#ge" .. past_stem .. "t")
      form.seen = true
      reset_all_maybes(true)
    end
    if not form.seen then
      check_strong()
    end
    if not form.seen then
      if not has_unseen_strong_pp() and has_unseen_weak_pp() then
        m_table.insertIfNot(this_verb_types, "mixed")
      else
        m_table.insertIfNot(this_verb_types, "irregstrong")
      end
    end
  end

  for _, form in ipairs(pp) do
    if not form.seen then
      if form.form:find("n$") then
        if m_table.contains(this_verb_types, "strong") then
          m_table.insertIfNot(this_verb_types, "irregstrong")
        elseif m_table.contains(this_verb_types, "weak") then
          m_table.insertIfNot(this_verb_types, "mixed")
        end
      elseif form.form:find("[dt]$") then
        if m_table.contains(this_verb_types, "weak") then
          m_table.insertIfNot(this_verb_types, "irregweak")
        elseif m_table.contains(this_verb_types, "strong") then
          m_table.insertIfNot(this_verb_types, "mixed")
        end
      end
    end
  end

  base.verb_types = this_verb_types

  if verb_types then
    for _, verb_type in ipairs(this_verb_types) do
      m_table.insertIfNot(verb_types, verb_type)
    end
  end

  set_verb_type()
end

local function detect_indicator_spec(base)
  base.forms = {}
  base.aux = base.aux or { { form = "haben" } }
  base.bare_infinitive = { { form = base.base_verb, footnotes = base.infstem_footnotes } }
  add(base, "infinitive", base.pre_pref, base.bare_infinitive)

  if base.only3s and base.only3sp then
    error("'only3s' and 'only3sp' cannot both be specified")
  end

  if base.conj == "irreg" then
    for irregverb, verbobj in pairs(irreg_verbs) do
      base.insep_prefix = base.base_verb:match("^(.-)" .. irregverb .. "$")
      if base.insep_prefix then
        base.irregverb = irregverb
        base.irregverbobj = verbobj
        if not base.ge_prefix then
          if base.insep_prefix ~= "" then
            base.ge_prefix = { { form = "" } }
          else
            base.ge_prefix = { { form = "ge" } }
          end
        end
        return
      end
    end
    error("Unrecognized irregular base verb '" .. base.base_verb .. "'")
  end

  -- The following applies to everything but 'irreg' verbs.

  local infstem, infroot = base.base_verb:match("^((.*)e[lr])n$")
  if infstem then
    base.unstressed_el_er = true
  else
    infstem, infroot = base.base_verb:match("^((.*)erl)n$") -- [[fensterln]]
    if infstem then
      base.unstressed_erl = true
    else
      infstem = base.base_verb:match("^(.*)en$")
      infroot = infstem
      if not infstem then
        error("Unrecognized infinitive, should end in -en, -eln, -ern or -erln: '" .. base.base_verb .. "'")
      end
    end
  end
  base.infstem = { { form = infstem, footnotes = base.infstem_footnotes } }

  if base.unstressed_e_infix == nil then
    -- Autodetect whether we need an -e- infix in the pres_2s and pres_3s ([[atmen]], [[eignen]], etc.).
    -- Almost all such cases have -Cmen or -Cnen where C is a consonant other than r or l and other than the
    -- following m or n (hence [[meinen]], [[lernen]], [[filmen]], [[schwimmen]] should be excluded); we also
    -- need to exclue -Vhmen and -Vhnen ([[wohnen]], [[rühmen]]), but not -Chmen and -Chnen ([[zeichnen]]).
    if base.base_verb:find("[mn]en$") and not base.base_verb:find("([mn])%1en$") and
        not rfind(base.base_verb, vowel_c .. "[hrl]?[mn]en$") then
      base.unstressed_e_infix = true
    end
  end

  if not base.conj then
    base.conj = "normal"
  end
  if base.conj == "normal" then
    local weak_past
    if not base.past then
      if base.unstressed_e_infix or ends_in_dt(infstem) then
        weak_past = infstem .. "et"
      else
        weak_past = infstem .. "t"
      end
      base.past = { { form = weak_past .. "e" } }
    end
    if not base.pp then
      if not weak_past then
        error("Internal error: past was explicitly given but not past participle")
      end
      if not base.ge_prefix then
        local no_ge
        for _, insep_prefix in ipairs(inseparable_prefixes) do
          -- There must be a vowel following the inseparable prefix; excludes beben, bechern, belfern, bellen, bessern,
          -- beten, betteln, betten, erben, erden, ernten, erzen, entern, gecken, gehren, gellen, gerben, geten, missen,
          -- zergen, zerren, etc.
          if rfind(infroot, "^" .. insep_prefix .. ".*" .. vowel_c .. ".*") and
              -- Exclude cases like beigen, beichten, beugen, beulen, geifern; this also wrongly excludes
              -- beirren, which needs -ge.
              not rfind(infroot, "^[bg]e[iu]" .. not_vowel_c .. "*$") then
            no_ge = true
            break
          end
          -- Check for -ier preceded by a vowel (excludes bieren, frieren, gieren, schmieren, stieren, zieren, etc.)
          if not base.unstressed_el_er and not base.unstressed_erl and rfind(infroot, "^.*" .. vowel_c .. ".*ier$") then
            no_ge = true
            break
          end
        end
        if no_ge then
          base.ge_prefix = { { form = "" } }
        else
          base.ge_prefix = { { form = "ge" } }
        end
      end
      base.pp = iut.map_forms(base.ge_prefix, function(form)
        if base.unstressed_el_er or base.unstressed_erl then
          return form .. base.base_verb:gsub("n$", "") .. "t"
        else
          return form .. weak_past
        end
      end)
    end
  else
    if not base.pp then
      error("For '" .. base.conj .. "' type verbs, past participle must be explicitly given")
    end
  end

  add(base, "perf_part", base.pre_pref, base.pp)
end

local function detect_all_indicator_specs(alternant_multiword_spec)
  iut.map_word_specs(alternant_multiword_spec, function(base)
    detect_indicator_spec(base)
    detect_verb_type(base)
  end)
end


-- Set the overall auxiliary or auxiliaries. We can't do this using the normal inflection
-- code as it will produce e.g. '[[haben]] und [[haben]]' for conjoined verbs.
local function compute_auxiliary(alternant_multiword_spec)
  iut.map_word_specs(alternant_multiword_spec, function(base)
    iut.insert_forms(alternant_multiword_spec.forms, "aux", base.aux)
  end)
end

function p.process_verb_classes(classes)
  local class_descs = {}
  local cats = {}

  local function insert_desc(desc)
    m_table.insertIfNot(class_descs, desc)
  end

  local function insert_cat(cat)
    m_table.insertIfNot(cats, "German " .. cat)
  end

  for _, class in ipairs(classes) do
    if class == "weak" then
      insert_desc("[[Appendix:Glossary#weak verb|weak]]")
      insert_cat("weak verbs")
    elseif class == "irregweak" then
      insert_desc("[[Appendix:Glossary#irregular|irregular]] [[Appendix:Glossary#weak verb|weak]]")
      insert_cat("weak verbs")
      insert_cat("irregular weak verbs")
    elseif class == "pretpres" then
      insert_desc("[[Appendix:Glossary#preterite-present verb|preterite-present]]")
      insert_cat("preterite-present verbs")
    elseif class == "irreg" then
      insert_desc("[[Appendix:Glossary#irregular|irregular]]")
      insert_cat("irregular verbs")
    elseif class == "mixed" then
      insert_desc("mixed")
      insert_cat("mixed verbs")
    elseif class == "irregstrong" then
      insert_desc("[[Appendix:Glossary#irregular|irregular]] [[Appendix:Glossary#strong verb|strong]]")
      insert_cat("strong verbs")
      insert_cat("irregular strong verbs")
    elseif class:find("^[1-7]$") then
      insert_desc("class " .. class .. " [[Appendix:Glossary#strong verb|strong]]")
      insert_cat("strong verbs")
      insert_cat("class " .. class .. " strong verbs")
    else
      error("Unrecognized verb class '" .. class .. "'")
    end
  end

  return class_descs, cats
end

local function add_categories_and_annotation(alternant_multiword_spec, base, from_headword, manual)
  local function insert_cat(full_cat)
    m_table.insertIfNot(alternant_multiword_spec.categories, full_cat)
  end

  if not from_headword then
    for _, slot_and_accel in ipairs(all_verb_slots) do
      local slot = slot_and_accel[1]
      local forms = base.forms[slot]
      local must_break = false
      if forms then
        for _, form in ipairs(forms) do
          if not form.form:find("%[%[") then
            local title = mw.title.new(form.form)
            if title and not title.exists then
              insert_cat("German verbs with red links in their inflection tables")
              must_break = true
              break
            end
          end
        end
      end
      if must_break then
        break
      end
    end
  end

  if manual then
    return
  end

  local class_descs, cats = p.process_verb_classes(base.verb_types)
  for _, desc in ipairs(class_descs) do
    m_table.insertIfNot(alternant_multiword_spec.verb_types, desc)
  end
  -- Don't place multiword terms in categories like 'German class 4 strong verbs' to avoid spamming the
  -- categories with such terms.
  if from_headword and not base.lemma:find(" ") then
    for _, cat in ipairs(cats) do
      insert_cat(cat)
    end
  end

  for _, aux in ipairs(base.aux) do
    m_table.insertIfNot(alternant_multiword_spec.auxiliaries, link_term(aux.form, "term"))
    if from_headword and not base.lemma:find(" ") then
      -- see above
      insert_cat("German verbs using " .. aux.form .. " as auxiliary")
      -- Set flags for use below in adding 'German verbs using haben and sein as auxiliary'
      alternant_multiword_spec["saw_" .. aux.form] = true
    end
  end
end


-- Compute the categories to add the verb to, as well as the annotation to display in the
-- conjugation title bar. We combine the code to do these functions as both categories and
-- title bar contain similar information.
local function compute_categories_and_annotation(alternant_multiword_spec, from_headword, manual)
  alternant_multiword_spec.categories = {}
  alternant_multiword_spec.verb_types = {}
  alternant_multiword_spec.auxiliaries = {}
  iut.map_word_specs(alternant_multiword_spec, function(base)
    add_categories_and_annotation(alternant_multiword_spec, base, from_headword)
  end)
  if manual then
    alternant_multiword_spec.annotation = ""
    return
  end
  local ann_parts = {}
  table.insert(ann_parts, table.concat(alternant_multiword_spec.verb_types, " or "))
  if #alternant_multiword_spec.auxiliaries > 0 then
    table.insert(ann_parts, ", auxiliary " .. table.concat(alternant_multiword_spec.auxiliaries, " or "))
  end
  if from_headword and alternant_multiword_spec.saw_haben and alternant_multiword_spec.saw_sein then
    m_table.insertIfNot(alternant_multiword_spec.categories, "German verbs using haben and sein as auxiliary")
  end
  alternant_multiword_spec.annotation = table.concat(ann_parts)
end

local function show_forms(alternant_multiword_spec)
  local lemmas = iut.map_forms(alternant_multiword_spec.forms.infinitive,
      remove_sein_sich_indicators)
  alternant_multiword_spec.lemmas = lemmas -- save for later use in make_table()
  local linked_pronouns = {}
  for index, pronoun in ipairs(pronouns) do
    -- use 'es' instead of 'er' for 3s-only verbs
    if index == 3 and alternant_multiword_spec.only3s then
      linked_pronouns[index] = link_term("es")
    else
      linked_pronouns[index] = link_term(pronoun)
    end
  end
  dass = link_term("dass") .. " "
  local function add_pronouns(slot, link)
    local persnum = slot:match("^imp_(2[sp])$")
    if persnum then
      link = link .. " (" .. linked_pronouns[persnum_to_index[persnum]] .. ")"
    else
      persnum = slot:match("^.*_([123][sp])$")
      if persnum then
        link = linked_pronouns[persnum_to_index[persnum]] .. " " .. link
      end
      if slot:find("^subc_") then
        link = dass .. link
      end
    end
    return link
  end
  local function join_spans(slot, spans)
    if slot == "aux" then
      return table.concat(spans, " or ")
    else
      return table.concat(spans, "<br />")
    end
  end
  local props = {
    lang = lang,
    lemmas = lemmas,
    transform_link = add_pronouns,
    join_spans = join_spans,
  }
  props.slot_list = verb_slots_basic
  iut.show_forms(alternant_multiword_spec.forms, props)
  alternant_multiword_spec.footnote_basic = alternant_multiword_spec.forms.footnote
  props.slot_list = verb_slots_subordinate_clause
  iut.show_forms(alternant_multiword_spec.forms, props)
  alternant_multiword_spec.footnote_subordinate_clause = alternant_multiword_spec.forms.footnote
  props.slot_list = verb_slots_composed
  iut.show_forms(alternant_multiword_spec.forms, props)
  alternant_multiword_spec.footnote_composed = alternant_multiword_spec.forms.footnote
end

local notes_template = [=[
<div style="width:100%;text-align:left;background:#d9ebff">
<div style="display:inline-block;text-align:left;padding-left:1em;padding-right:1em">
{footnote}
</div></div>
]=]

local zu_infinitive_table = [=[
|-
! colspan="2" style="background:#d0d0d0" | zu-infinitive
| colspan="4" | {zu_infinitive}
]=]

local basic_table = [=[
<div class="NavFrame" style="">
<div class="NavHead" style="">Conjugation of {title}</div>
<div class="NavContent">
{\op}| border="1px solid #000000" style="border-collapse:collapse; background:#fafafa; text-align:center; width:100%" class="inflection-table"
|-
! colspan="2" style="background:#d0d0d0" | <span title="Infinitiv">infinitive</span>
| colspan="4" | {infinitive}
|-
! colspan="2" style="background:#d0d0d0" | <span title="Partizip I (Partizip Präsens)">present participle</span>
| colspan="4" | {pres_part}
|-
! colspan="2" style="background:#d0d0d0" | <span title="Partizip II (Partizip Perfekt)">past participle</span>
| colspan="4" | {perf_part}
{zu_infinitive_table}|-
! colspan="2" style="background:#d0d0d0" | <span title="Hilfsverb">auxiliary</span>
| colspan="4" | {aux}
|-
| style="background:#a0ade3" |
! colspan="2" style="background:#a0ade3" | <span title="Indikativ">indicative</span>
| style="background:#a0ade3" |
! colspan="2" style="background:#a0ade3" | <span title="Konjunktiv">subjunctive</span>
|-
! rowspan="3" style="background:#c0cfe4; width:7em" | <span title="Präsens">present</span>
| {pres_1s}
| {pres_1p}
! rowspan="3" style="background:#c0cfe4; width:7em" | <span title="Konjunktiv I (Konjunktiv Präsens)">i</span>
| {subi_1s}
| {subi_1p}
|-
| {pres_2s}
| {pres_2p}
| {subi_2s}
| {subi_2p}
|-
| {pres_3s}
| {pres_3p}
| {subi_3s}
| {subi_3p}
|-
| colspan="6" style="background:#d5d5d5; height: .25em" | 
|-
! rowspan="3" style="background:#c0cfe4" | <span title="Präteritum">preterite</span>
| {pret_1s}
| {pret_1p}
! rowspan="3" style="background:#c0cfe4" | <span title="Konjunktiv II (Konjunktiv Präteritum)">ii</span>
| {subii_1s}
| {subii_1p}
|-
| {pret_2s}
| {pret_2p}
| {subii_2s}
| {subii_2p}
|-
| {pret_3s}
| {pret_3p}
| {subii_3s}
| {subii_3p}
|-
| colspan="6" style="background:#d5d5d5; height: .25em" | 
|-
! style="background:#c0cfe4" | <span title="Imperativ">imperative</span>
| {imp_2s}
| {imp_2p}
| colspan="3" style="background:#e0e0e0" |
|{\cl}{notes_clause}</div></div>
]=]

local subordinate_clause_table = [=[
<div class="NavFrame" style="">
<div class="NavHead" style="">Subordinate-clause forms of {title}</div>
<div class="NavContent">
{\op}| border="1px solid #000000" style="border-collapse:collapse; background:#fafafa; text-align:center; width:100%" class="inflection-table"
|-
| style="background:#a0ade3" |
! colspan="2" style="background:#a0ade3" | <span title="Indikativ">indicative</span>
| style="background:#a0ade3" |
! colspan="2" style="background:#a0ade3" | <span title="Konjunktiv">subjunctive</span>
|-
! rowspan="3" style="background:#c0cfe4; width:7em" | <span title="Präsens">present</span>
| {subc_pres_1s}
| {subc_pres_1p}
! rowspan="3" style="background:#c0cfe4; width:7em" | <span title="Konjunktiv I (Konjunktiv Präsens)">i</span> 
| {subc_subi_1s}
| {subc_subi_1p}
|-
| {subc_pres_2s}
| {subc_pres_2p}
| {subc_subi_2s}
| {subc_subi_2p}
|-
| {subc_pres_3s}
| {subc_pres_3p}
| {subc_subi_3s}
| {subc_subi_3p}
|-
| colspan="6" style="background:#d5d5d5; height: .25em" | 
|-
! rowspan="3" style="background:#c0cfe4" | <span title="Präteritum">preterite</span>
| {subc_pret_1s}
| {subc_pret_1p}
! rowspan="3" style="background:#c0cfe4" | <span title="Konjunktiv II (Konjunktiv Präteritum)">ii</span>
| {subc_subii_1s}
| {subc_subii_1p}
|-
| {subc_pret_2s}
| {subc_pret_2p}
| {subc_subii_2s}
| {subc_subii_2p}
|-
| {subc_pret_3s}
| {subc_pret_3p}
| {subc_subii_3s}
| {subc_subii_3p}
|{\cl}{notes_clause}</div></div>
]=]

local composed_table = [=[
<div class="NavFrame" style="">
<div class="NavHead" style="">Composed forms of {title}</div>
<div class="NavContent">
{\op}| border="1px solid #000000" style="border-collapse:collapse; background:#fafafa; text-align:center; width:100%" class="inflection-table"
|-
! colspan="6" style="background:#99cc99" | <span title="Perfekt">perfect</span>
|-
! rowspan="3" style="background:#cfedcc; width:7em" | <span title="Indikativ">indicative</span>
| {perf_ind_1s}
| {perf_ind_1p}
! rowspan="3" style="background:#cfedcc; width:7em" | <span title="Konjunktiv">subjunctive</span>
| {perf_sub_1s}
| {perf_sub_1p}
|-
| {perf_ind_2s}
| {perf_ind_2p}
| {perf_sub_2s}
| {perf_sub_2p}
|-
| {perf_ind_3s}
| {perf_ind_3p}
| {perf_sub_3s}
| {perf_sub_3p}
|-
! colspan="6" style="background:#99CC99" | <span title="Plusquamperfekt">pluperfect</span>
|-
! rowspan="3" style="background:#cfedcc" | <span title="Indikativ">indicative</span>
| {plup_ind_1s}
| {plup_ind_1p}
! rowspan="3" style="background:#cfedcc" | <span title="Konjunktiv">subjunctive</span>
| {plup_sub_1s}
| {plup_sub_1p}
|-
| {plup_ind_2s}
| {plup_ind_2p}
| {plup_sub_2s}
| {plup_sub_2p}
|-
| {plup_ind_3s}
| {plup_ind_3p}
| {plup_sub_3s}
| {plup_sub_3p}
|-
! colspan="6" style="background:#9999DF" | <span title="Futur I">future i</span>
|-
! rowspan="3" style="background:#ccccff" | <span title="Infinitiv">infinitive</span>
| rowspan="3" colspan="2" | {futi_inf}
! rowspan="3" style="background:#ccccff" | <span title="Konjunktiv I (Konjunktiv Präsens)">subjunctive i</span>
| {futi_subi_1s}
| {futi_subi_1p}
|-
| {futi_subi_2s}
| {futi_subi_2p}
|-
| {futi_subi_3s}
| {futi_subi_3p}
|-
! colspan="6" style="background:#d5d5d5; height: .25em" |
|-
! rowspan="3" style="background:#ccccff" | <span title="Indikativ">indicative</span>
| {futi_ind_1s}
| {futi_ind_1p}
! rowspan="3" style="background:#ccccff" | <span title="Konjunktiv II (Konjunktiv Präteritum)">subjunctive ii</span>
| {futi_subii_1s}
| {futi_subii_1p}
|-
| {futi_ind_2s}
| {futi_ind_2p}
| {futi_subii_2s}
| {futi_subii_2p}
|-
| {futi_ind_3s}
| {futi_ind_3p}
| {futi_subii_3s}
| {futi_subii_3p}
|-
! colspan="6" style="background:#9999DF" | <span title="Futur II">future ii</span>
|-
! rowspan="3" style="background:#ccccff" | <span title="Infinitiv">infinitive</span>
| rowspan="3" colspan="2" | {futii_inf}
! rowspan="3" style="background:#ccccff" | <span title="Konjunktiv I (Konjunktiv Präsens)">subjunctive i</span>
| {futii_subi_1s}
| {futii_subi_1p}
|-
| {futii_subi_2s}
| {futii_subi_2p}
|-
| {futii_subi_3s}
| {futii_subi_3p}
|-
! colspan="6" style="background:#d5d5d5; height: .25em" |
|-
! rowspan="3" style="background:#ccccff" | <span title="Indikativ">indicative</span>
| {futii_ind_1s}
| {futii_ind_1p}
! rowspan="3" style="background:#ccccff" | <span title="Konjunktiv II (Konjunktiv Präteritum)">subjunctive ii</span>
| {futii_subii_1s}
| {futii_subii_1p}
|-
| {futii_ind_2s}
| {futii_ind_2p}
| {futii_subii_2s}
| {futii_subii_2p}
|-
| {futii_ind_3s}
| {futii_ind_3p}
| {futii_subii_3s}
| {futii_subii_3p}
|{\cl}{notes_clause}</div></div>]=]

local function make_table(alternant_multiword_spec)
  local forms = alternant_multiword_spec.forms

  forms.title = link_term(alternant_multiword_spec.lemmas[1].form, "term")
  if alternant_multiword_spec.annotation ~= "" then
    forms.title = forms.title .. " (" .. alternant_multiword_spec.annotation .. ")"
  end

  -- Maybe format the subordinate clause table.
  local formatted_subordinate_clause_table
  if forms.subc_pres_3s ~= "—" then
    -- use 3s in case of only3s verb
    forms.zu_infinitive_table = m_string_utilities.format(zu_infinitive_table, forms)
    forms.footnote = alternant_multiword_spec.footnote_subordinate_clause
    forms.notes_clause = forms.footnote ~= "" and m_string_utilities.format(notes_template, forms) or ""
    formatted_subordinate_clause_table = m_string_utilities.format(subordinate_clause_table, forms)
  else
    forms.zu_infinitive_table = ""
    formatted_subordinate_clause_table = ""
  end

  -- Format the basic table.
  forms.footnote = alternant_multiword_spec.footnote_basic
  forms.notes_clause = forms.footnote ~= "" and m_string_utilities.format(notes_template, forms) or ""
  local formatted_basic_table = m_string_utilities.format(basic_table, forms)

  -- Format the composed table.
  forms.footnote = alternant_multiword_spec.footnote_composed
  forms.notes_clause = forms.footnote ~= "" and m_string_utilities.format(notes_template, forms) or ""
  local formatted_composed_table = m_string_utilities.format(composed_table, forms)

  -- Paste them together.
  return formatted_basic_table .. formatted_subordinate_clause_table .. formatted_composed_table
end


--- Externally callable function to parse and conjugate a verb given user-specified arguments.
--- Return value is WORD_SPEC, an object where the conjugated forms are in `WORD_SPEC.forms`
--- for each slot. If there are no values for a slot, the slot key will be missing. The value
--- for a given slot is a list of objects {form=FORM, footnotes=FOOTNOTES}.
function p.do_generate_forms(parent_args, from_headword, def)
  local params = {
    [1] = {},
  }

  if from_headword then
    params["lemma"] = { list = true }
    params["id"] = {}
  end

  local args = require("Module:parameters").process(parent_args, params)
  local PAGENAME = mw.title.getCurrentTitle().text

  if not args[1] then
    if PAGENAME == "de-conj" or PAGENAME == "de-verb" then
      args[1] = def or "aus.fahren<fährt#fuhr,gefahren,führe.haben,sein>"
    else
      args[1] = PAGENAME
      -- If pagename has spaces in it, add links around each word
      if args[1]:find(" ") then
        args[1] = "[[" .. args[1]:gsub(" ", "]] [[") .. "]]"
      end
    end
  end
  local parse_props = {
    parse_indicator_spec = parse_indicator_spec,
    lang = lang,
    allow_default_indicator = true,
    allow_blank_lemma = true,
  }
  local escaped_arg1 = escape_sein_sich_indicators(args[1])
  local alternant_multiword_spec = iut.parse_inflected_text(escaped_arg1, parse_props)
  alternant_multiword_spec.pos = pos or "verbs"
  alternant_multiword_spec.args = args
  normalize_all_lemmas(alternant_multiword_spec, from_headword)
  detect_all_indicator_specs(alternant_multiword_spec)
  local inflect_props = {
    slot_list = all_verb_slots,
    lang = lang,
    inflect_word_spec = conjugate_verb,
    -- We add links around the generated verbal forms rather than allow the entire multiword
    -- expression to be a link, so ensure that user-specified links get included as well.
    include_user_specified_links = true,
  }
  iut.inflect_multiword_or_alternant_multiword_spec(alternant_multiword_spec, inflect_props)
  compute_auxiliary(alternant_multiword_spec)
  compute_categories_and_annotation(alternant_multiword_spec, from_headword)
  return alternant_multiword_spec
end


--- Entry point for {{de-conj}}. Template-callable function to parse and conjugate a verb given
--- user-specified arguments and generate a displayable table of the conjugated forms.
function p.show(frame)
  local parent_args = frame:getParent().args
  local alternant_multiword_spec = p.do_generate_forms(parent_args)
  show_forms(alternant_multiword_spec)
  return make_table(alternant_multiword_spec) .. require("Module:utilities").format_categories(alternant_multiword_spec.categories, lang)
end


--- Concatenate all forms of all slots into a single string of the form
--- "SLOT=FORM,FORM,...|SLOT=FORM,FORM,...|...". Embedded pipe symbols (as might occur
--- in embedded links) are converted to <!>. If INCLUDE_PROPS is given, also include
--- additional properties (currently, none). This is for use by bots.
local function concat_forms(alternant_multiword_spec, include_props)
  local ins_text = {}
  for _, slot_and_accel in ipairs(all_verb_slots) do
    local slot = slot_and_accel[1]
    local formtext = iut.concat_forms_in_slot(alternant_multiword_spec.forms[slot])
    if formtext then
      table.insert(ins_text, slot .. "=" .. formtext)
    end
  end
  if include_props then
    local verb_types = {}
    iut.map_word_specs(alternant_multiword_spec, function(base)
      detect_verb_type(base, verb_types)
    end)
    table.insert(ins_text, "class=" .. table.concat(verb_types, ","))
  end
  return table.concat(ins_text, "|")
end

local numbered_params = {
  -- required params
  [1] = "infinitive",
  [2] = "pres_part",
  [3] = "perf_part",
  [4] = "aux",
  [5] = "pres_1s",
  [6] = "pres_2s",
  [7] = "pres_3s",
  [8] = "pres_1p",
  [9] = "pres_2p",
  [10] = "pres_3p",
  [11] = "pret_1s",
  [12] = "pret_2s",
  [13] = "pret_3s",
  [14] = "pret_1p",
  [15] = "pret_2p",
  [16] = "pret_3p",
  [17] = "subi_1s",
  [18] = "subi_2s",
  [19] = "subi_3s",
  [20] = "subi_1p",
  [21] = "subi_2p",
  [22] = "subi_3p",
  [23] = "subii_1s",
  [24] = "subii_2s",
  [25] = "subii_3s",
  [26] = "subii_1p",
  [27] = "subii_2p",
  [28] = "subii_3p",
  [29] = "imp_2s",
  [30] = "imp_2p",
  -- [31] formerly the 2nd variant of imp_2s; now no longer allowed (use comma-separated 29=)
  -- [32] formerly indicated whether the 2nd variant of imp_2s was present
  -- optional params
  [33] = "subc_pres_1s",
  [34] = "subc_pres_2s",
  [35] = "subc_pres_3s",
  [36] = "subc_pres_1p",
  [37] = "subc_pres_2p",
  [38] = "subc_pres_3p",
  [39] = "subc_pret_1s",
  [40] = "subc_pret_2s",
  [41] = "subc_pret_3s",
  [42] = "subc_pret_1p",
  [43] = "subc_pret_2p",
  [44] = "subc_pret_3p",
  [45] = "subc_subi_1s",
  [46] = "subc_subi_2s",
  [47] = "subc_subi_3s",
  [48] = "subc_subi_1p",
  [49] = "subc_subi_2p",
  [50] = "subc_subi_3p",
  [51] = "subc_subii_1s",
  [52] = "subc_subii_2s",
  [53] = "subc_subii_3s",
  [54] = "subc_subii_1p",
  [55] = "subc_subii_2p",
  [56] = "subc_subii_3p",
  [57] = "zu_infinitive",
}

local max_required_param = 30



--- Externally callable function to parse and conjugate a verb where all forms are given manually.
--- Return value is WORD_SPEC, an object where the conjugated forms are in `WORD_SPEC.forms`
--- for each slot. If there are no values for a slot, the slot key will be missing. The value
--- for a given slot is a list of objects {form=FORM, footnotes=FOOTNOTES}.
function p.do_generate_forms_manual(parent_args)
  local params = {
    ["generate_forms"] = { type = "boolean" },
  }
  for paramnum, _ in pairs(numbered_params) do
    params[paramnum] = { required = paramnum <= max_required_param }
  end

  local args = require("Module:parameters").process(parent_args, params)

  local base = {
    forms = {},
    manual = true,
  }
  local function process_numbered_param(paramnum)
    local argval = args[paramnum]
    if paramnum == 4 then
      if argval == "h" then
        base.aux = { { form = "haben" } }
      elseif argval == "s" then
        base.aux = { { form = "sein" } }
      elseif argval == "hs" then
        base.aux = { { form = "haben" }, { form = "sein" } }
      elseif argval == "sh" then
        base.aux = { { form = "sein" }, { form = "haben" } }
      elseif not argval then
        error("Missing auxiliary in 4=")
      else
        error("Unrecognized auxiliary 4=" .. argval)
      end
    elseif argval and argval ~= "-" then
      local split_vals = rsplit(argval, "%s*,%s*")
      for _, val in ipairs(split_vals) do
        -- FIXME! This won't work with commas or brackets in footnotes.
        -- To fix this, use functions from [[Module:inflection utilities]].
        local form, footnote = val:match("^(.-)%s*(%[[^%]%[]-%])$")
        local footnotes
        if form then
          footnotes = { footnote }
        else
          form = val
        end
        local slot = numbered_params[paramnum]
        --if slot:find("subii") then
        --	local subii_footnotes = get_subii_note(base)
        --	footnotes = iut.combine_footnotes(subii_footnotes, footnotes)
        --end
        iut.insert_form(base.forms, slot, { form = form, footnotes = footnotes })
      end
    end
  end

  -- Do the infinitive first as we need to reference it in subjunctive II footnotes.
  process_numbered_param(1)
  for paramnum, _ in pairs(numbered_params) do
    if paramnum ~= 1 then
      process_numbered_param(paramnum)
    end
  end

  add_composed_forms(base)
  compute_categories_and_annotation(base, nil, "manual")
  return base, args.generate_forms
end


--- Entry point for {{de-conj-table}}. Template-callable function to parse and conjugate a verb given
--- manually-specified inflections and generate a displayable table of the conjugated forms.
function p.show_manual(frame)
  local parent_args = frame:getParent().args
  local base, generate_forms = p.do_generate_forms_manual(parent_args)
  if generate_forms then
    return concat_forms(base)
  end
  show_forms(base)
  return make_table(base) .. require("Module:utilities").format_categories(base.categories, lang)
end


--- Template-callable function to parse and conjugate a verb given user-specified arguments and return
--- the forms as a string "SLOT=FORM,FORM,...|SLOT=FORM,FORM,...|...". Embedded pipe symbols (as might
--- occur in embedded links) are converted to <!>. If |include_props=1 is given, also include
--- additional properties (currently, none). This is for use by bots.
function p.generate_forms(frame)
  local include_props = frame.args["include_props"]
  local parent_args = frame:getParent().args
  local alternant_multiword_spec = p.do_generate_forms(parent_args)
  return concat_forms(alternant_multiword_spec, include_props)
end

return p
