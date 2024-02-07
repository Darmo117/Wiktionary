local p = {}

p.avoirConj = {
  infinitif = {
    present = "avoir",
  },
  participe = {
    present = "ayant",
    passe = "eu",
  },
  indicatif = {
    present = { "ai", "as", "a", "avons", "avez", "ont" },
    imparfait = { "avais", "avais", "avait", "avions", "aviez", "avaient" },
    passeSimple = { "eus", "eus", "eut", "eûmes", "eûtes", "eurent" },
    futur = { "aurai", "auras", "aura", "aurons", "aurez", "auront" },
  },
  subjonctif = {
    present = { "aie", "aies", "ait", "ayons", "ayez", "aient" },
    imparfait = { "eusse", "eusses", "eût", "eussions", "eussiez", "eussent" }
  },
  conditionnel = {
    present = { "aurais", "aurais", "aurait", "aurions", "auriez", "auraient" }
  },
  imperatif = {
    present = { "aie", "ayons", "ayez" }
  },
}
p.etreConj = {
  infinitif = {
    present = "être",
  },
  participe = {
    present = "étant",
    passe = "été",
  },
  indicatif = {
    present = { "suis", "es", "est", "sommes", "êtes", "sont" },
    imparfait = { "étais", "étais", "était", "étions", "étiez", "étaient" },
    passeSimple = { "fus", "fus", "fut", "fûmes", "fûtes", "furent" },
    futur = { "serai", "seras", "sera", "serons", "serez", "seront" },
  },
  subjonctif = {
    present = { "sois", "sois", "soit", "soyons", "soyez", "soient" },
    imparfait = { "fusse", "fusses", "fût", "fussions", "fussiez", "fussent" }
  },
  conditionnel = {
    present = { "serais", "serais", "serait", "serions", "seriez", "seraient" }
  },
  imperatif = {
    present = { "sois", "soyons", "soyez" }
  },
}

local function generateGroup1Endings(firstLetter, consonants)
  local endings = {}
  for _, c in ipairs(consonants) do
    endings[firstLetter .. c .. "er"] = c
  end
  return endings
end

local eCONSer_verbs = generateGroup1Endings("e", {
  "c",
  "d",
  "g",
  "m",
  "n",
  "p",
  "r",
  "s",
  "v",
  "vr",
})
local eacuteCONSer_verbs = generateGroup1Endings("é", {
  "b",
  "br",
  "c",
  "ch",
  "cr",
  "d",
  "fl",
  "g",
  "gn",
  "gr",
  "gu",
  "j",
  "l",
  "m",
  "n",
  "p",
  "qu",
  "r",
  "s",
  "t",
  "tr",
  "v",
  "vr",
})

local function startsWithAO(s)
  local firstLetter = mw.ustring.sub(s, 1, 1)
  return firstLetter == "a" or firstLetter == "â" or firstLetter == "o"
end

--- Generate the simple tense forms of the given group-1 verb.
--- @param infinitive string The infinitive form of the verb.
--- @param mapper function A function that, given the verb’s root and an ending, builds the associated verb form.
--- @return table A table containing all simple tense forms of the verb.
local function generateGroup1Forms_(infinitive, mapper)
  mapper = mapper or function(root, ending)
    return root .. ending
  end
  local root = mw.ustring.sub(infinitive, 1, -3)
  return {
    infinitif = {
      present = infinitive,
    },
    participe = {
      present = mapper(root, "ant"),
      passe = mapper(root, "é"),
    },
    indicatif = {
      present = {
        mapper(root, "e"),
        mapper(root, "es"),
        mapper(root, "e"),
        mapper(root, "ons"),
        mapper(root, "ez"),
        mapper(root, "ent")
      },
      imparfait = {
        mapper(root, "ais"),
        mapper(root, "ais"),
        mapper(root, "ait"),
        mapper(root, "ions"),
        mapper(root, "iez"),
        mapper(root, "aient")
      },
      passeSimple = {
        mapper(root, "ai"),
        mapper(root, "as"),
        mapper(root, "a"),
        mapper(root, "âmes"),
        mapper(root, "âtes"),
        mapper(root, "èrent")
      },
      futur = {
        infinitive .. "ai",
        infinitive .. "as",
        infinitive .. "a",
        infinitive .. "ons",
        infinitive .. "ez",
        infinitive .. "ont"
      },
    },
    subjonctif = {
      present = {
        mapper(root, "e"),
        mapper(root, "es"),
        mapper(root, "e"),
        mapper(root, "ions"),
        mapper(root, "iez"),
        mapper(root, "ent")
      },
      imparfait = {
        mapper(root, "asse"),
        mapper(root, "asses"),
        mapper(root, "ât"),
        mapper(root, "assions"),
        mapper(root, "assiez"),
        mapper(root, "assent")
      }
    },
    conditionnel = {
      present = {
        infinitive .. "ais",
        infinitive .. "ais",
        infinitive .. "ait",
        infinitive .. "ions",
        infinitive .. "iez",
        infinitive .. "aient"
      }
    },
    imperatif = {
      present = {
        mapper(root, "e"),
        mapper(root, "ons"),
        mapper(root, "ez")
      }
    },
  }
end

--- Generate the simple tense forms of the given group-1 verb ending in `[gc]er`.
--- @param infinitive string The infinitive form of the verb.
--- @return table A table containing all simple tense forms of the verb.
local function generateGroup1Forms_ger_cer(infinitive)
  local mutation = mw.ustring.sub(infinitive, -3, -3) == "g" and "ge" or "ç"
  local base = mw.ustring.sub(infinitive, 1, -4)
  return generateGroup1Forms_(infinitive, function(root, ending)
    return (startsWithAO(ending) and base .. mutation or root) .. ending
  end)
end

--- Generate the simple tense forms of the given group-1 verb.
--- @param infinitive string The infinitive form of the verb.
--- @return table A table containing all simple tense forms of the verb.
--- @see [[Conjugaison:français/Premier groupe]] for exceptions.
function p.generateGroup1Forms(infinitive)
  local last4 = mw.ustring.sub(infinitive, -4)
  local last5 = mw.ustring.sub(infinitive, -5)
  local consonants = eCONSer_verbs[last4] or eCONSer_verbs[last5]
  if consonants then
    return generateGroup1Forms_eCONSer(infinitive, consonants) -- TODO
  end
  if last4 == "eler" then
    return generateGroup1Forms_eler(infinitive) -- TODO
  end
  if last4 == "eter" then
    return generateGroup1Forms_eter(infinitive) -- TODO
  end
  consonants = eacuteCONSer_verbs[last4] or eacuteCONSer_verbs[last5]
  if consonants then
    return generateGroup1Forms_eacuteCONSer(infinitive, consonants) -- TODO
  end

  if mw.ustring.sub(infinitive, -7) == "envoyer" then
    return generateGroup1Forms_envoyer(infinitive) -- TODO
  end
  if last4 == "ayer" then
    return generateGroup1Forms_ayer(infinitive) -- TODO
  end
  if last4 == "oyer" or last4 == "uyer" then
    return generateGroup1Forms_oyer_uyer(infinitive) -- TODO
  end
  if last4 == "eyer" then
    return generateGroup1Forms_eyer(infinitive) -- TODO
  end

  local last3 = mw.ustring.sub(infinitive, -3)
  if last3 == "cer" or last3 == "ger" then
    return generateGroup1Forms_ger_cer(infinitive)
  end

  return generateGroup1Forms_(infinitive)
end

--- Generate the simple tense forms of the given group-2 verb.
--- @param infinitive string The infinitive form of the verb.
--- @param dropDiaeresis boolean Whether to drop the `ï`
---        for the 3 singular persons of indicative and imperative present.
--- @return table A table containing all simple tense forms of the verb.
--- @see [[Conjugaison:français/Deuxième groupe]] for exceptions.
function p.generateGroup2Forms(infinitive, dropDiaeresis)
  local root = mw.ustring.sub(infinitive, 1, -3)
  local hasDiaeresis = mw.ustring.sub(infinitive, -2) == "ïr"
  local i = hasDiaeresis and "ï" or "i"
  local iCirc = hasDiaeresis and "ï" or "î"
  return {
    infinitif = {
      present = infinitive,
    },
    participe = {
      present = root .. i .. "ssant",
      passe = root .. i,
    },
    indicatif = {
      present = {
        root .. (dropDiaeresis and "is" or (i .. "s")),
        root .. (dropDiaeresis and "is" or (i .. "s")),
        root .. (dropDiaeresis and "it" or (i .. "t")),
        root .. i .. "ssons",
        root .. i .. "ssez",
        root .. i .. "ssent"
      },
      imparfait = {
        root .. i .. "ssais",
        root .. i .. "ssais",
        root .. i .. "ssait",
        root .. i .. "ssions",
        root .. i .. "ssiez",
        root .. i .. "ssaient"
      },
      passeSimple = {
        root .. i .. "s",
        root .. i .. "s",
        root .. i .. "t",
        root .. iCirc .. "mes",
        root .. iCirc .. "tes",
        root .. i .. "rent"
      },
      futur = {
        infinitive .. "ai",
        infinitive .. "as",
        infinitive .. "a",
        infinitive .. "ons",
        infinitive .. "ez",
        infinitive .. "ont"
      },
    },
    subjonctif = {
      present = {
        root .. i .. "sse",
        root .. i .. "sses",
        root .. i .. "sse",
        root .. i .. "ssions",
        root .. i .. "ssiez",
        root .. i .. "ssent"
      },
      imparfait = {
        root .. i .. "sse",
        root .. i .. "sses",
        root .. iCirc .. "t",
        root .. i .. "ssions",
        root .. i .. "ssiez",
        root .. i .. "ssent"
      }
    },
    conditionnel = {
      present = {
        infinitive .. "ais",
        infinitive .. "ais",
        infinitive .. "ait",
        infinitive .. "ions",
        infinitive .. "iez",
        infinitive .. "aient"
      }
    },
    imperatif = {
      present = {
        root .. (dropDiaeresis and "is" or (i .. "s")),
        root .. i .. "ssons",
        root .. i .. "ssez"
      }
    },
  }
end

--- Generate the simple tense forms of the given group-3 verb.
--- @param infinitive string The infinitive form of the verb.
--- @return table A table containing all simple tense forms of the verb.
--- @see [[Conjugaison:français/Troisième groupe]] for sub-types.
function p.generateGroup3Forms(infinitive)
  if infinitive == "être" then
    return p.etreConj
  elseif infinitive == "avoir" then
    return p.avoirConj
  else
    -- TODO détecter type de verbe et génerer en fonction
    -- cf. https://fr.wiktionary.org/wiki/Conjugaison:fran%C3%A7ais/Troisi%C3%A8me_groupe
    return {}
  end
end

--- Generate the simple tense forms of the given verb.
--- @param infinitive string The infinitive form of the verb.
--- @param group number Optional. The verb’s group. If undefined,
---        the function will attempt to detect it based on the infinitive form.
--- @param dropDiaeresis boolean For group-2 verbs in `ïr`, whether to drop the `ï`
---        for the 3 singular persons of indicative and imperative present.
--- @return (table, number) A tuple with a table containing all simple tense forms of the verb, and the verb’s group.
function p.generateFlexions(infinitive, group, dropDiaeresis)
  if infinitive == "être" then
    -- Special cases to avoid unnecessary checks
    return p.etreConj, 3
  end
  if infinitive == "avoir" then
    return p.avoirConj, 3
  end
  local ending = mw.ustring.sub(infinitive, -2)
  if not group and ending == "er" or group == 1 then
    return p.generateGroup1Forms(infinitive), 1
  end
  if not group and (ending == "ir" or ending == "ïr") or group == 2 then
    return p.generateGroup2Forms(infinitive, dropDiaeresis), 2
  end
  if not group or group == 3 then
    return p.generateGroup3Forms(infinitive), 3
  end
  error("Groupe invalide : " .. tostring(group))
end

return p
