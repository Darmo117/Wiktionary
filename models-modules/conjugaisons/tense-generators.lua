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

--- For group-1 verbs ending in `-eler/-eter`, mutate the root in `-ell-/-ett-` instead of `-èl-/-èt-`.
local MUTATION_DOUBLE_CONS = "double consonne"
local MUTATION_AYER_YE = "ayer-ye"
--- For group-2 verbs ending in `-ïr`, replace the `ï` by a `i` for the 3 singular persons of indicative
--- and the singular imperative present.
local MUTATION_I = "ï-i"

--- All available root mutation types.
p.mutationTypes = {
  MUTATION_DOUBLE_CONS,
  MUTATION_AYER_YE,
  MUTATION_I,
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
  "l",
  "m",
  "n",
  "p",
  "r",
  "s",
  "t",
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

local function isGroup1EndingSilent(ending)
  return ending == "e" or ending == "es" or ending == "ent"
end

--- Generate the simple tense forms of the given group-1 verb.
--- @param infinitive string The infinitive form of the verb.
--- @param rootMapper function Optional. A function that, given the verb’s root and an ending,
---        builds the associated verb form.
--- @param infinitiveMapper function Optional. A function that, given a verb’s ending,
---        builds the associated verb form based on its infinitive.
--- @return table A table containing all simple tense forms of the verb.
local function generateGroup1Forms_(infinitive, rootMapper, infinitiveMapper)
  rootMapper = rootMapper or function(root, ending)
    return root .. ending
  end
  infinitiveMapper = infinitiveMapper or function(ending)
    return infinitive .. ending
  end
  local root = mw.ustring.sub(infinitive, 1, -3)
  return {
    infinitif = {
      present = infinitive,
    },
    participe = {
      present = rootMapper(root, "ant"),
      passe = rootMapper(root, "é"),
    },
    indicatif = {
      present = {
        rootMapper(root, "e"),
        rootMapper(root, "es"),
        rootMapper(root, "e"),
        rootMapper(root, "ons"),
        rootMapper(root, "ez"),
        rootMapper(root, "ent")
      },
      imparfait = {
        rootMapper(root, "ais"),
        rootMapper(root, "ais"),
        rootMapper(root, "ait"),
        rootMapper(root, "ions"),
        rootMapper(root, "iez"),
        rootMapper(root, "aient")
      },
      passeSimple = {
        rootMapper(root, "ai"),
        rootMapper(root, "as"),
        rootMapper(root, "a"),
        rootMapper(root, "âmes"),
        rootMapper(root, "âtes"),
        rootMapper(root, "èrent")
      },
      futur = {
        infinitiveMapper("ai"),
        infinitiveMapper("as"),
        infinitiveMapper("a"),
        infinitiveMapper("ons"),
        infinitiveMapper("ez"),
        infinitiveMapper("ont")
      },
    },
    subjonctif = {
      present = {
        rootMapper(root, "e"),
        rootMapper(root, "es"),
        rootMapper(root, "e"),
        rootMapper(root, "ions"),
        rootMapper(root, "iez"),
        rootMapper(root, "ent")
      },
      imparfait = {
        rootMapper(root, "asse"),
        rootMapper(root, "asses"),
        rootMapper(root, "ât"),
        rootMapper(root, "assions"),
        rootMapper(root, "assiez"),
        rootMapper(root, "assent")
      }
    },
    conditionnel = {
      present = {
        infinitiveMapper("ais"),
        infinitiveMapper("ais"),
        infinitiveMapper("ait"),
        infinitiveMapper("ions"),
        infinitiveMapper("iez"),
        infinitiveMapper("aient")
      }
    },
    imperatif = {
      present = {
        rootMapper(root, "e"),
        rootMapper(root, "ons"),
        rootMapper(root, "ez")
      }
    },
  }
end

--- Mutate the given group-1 verb root according to the given ending.
--- @param root string The verb’s root.
--- @param ending string A verb ending.
--- @return string The mutated root if it ends in `g` or `c`, the argument root otherwise.
local function mutateRoot_cer_ger(root, ending)
  local lastLetter = mw.ustring.sub(root, -1)
  if lastLetter ~= "g" and lastLetter ~= "c" then
    return root
  end
  local mutation = lastLetter == "g" and "ge" or "ç"
  return startsWithAO(ending) and (mw.ustring.sub(root, 1, -2) .. mutation) or root
end

--- Generate the simple tense forms of the given group-1 verb ending in `[cg]er`.
--- @param infinitive string The infinitive form of the verb.
--- @return table A table containing all simple tense forms of the verb.
local function generateGroup1Forms_cer_ger(infinitive)
  return generateGroup1Forms_(infinitive, function(root, ending)
    return mutateRoot_cer_ger(root, ending) .. ending
  end)
end

--- Generate the simple tense forms of the given group-1 verb ending in `[eè]<consonant(s)>er`.
--- @param infinitive string The infinitive form of the verb.
--- @param consonants string The consonant(s) that precede the mutating `e`.
--- @param doubleConsonant boolean True to double the consonant instead of mutating the `e/é` into an `è`.
--- @return table A table containing all simple tense forms of the verb.
local function generateGroup1Forms_eCONSer(infinitive, consonants, doubleConsonant)
  local base = mw.ustring.sub(infinitive, 1, -4 - mw.ustring.len(consonants))
  local mutatedRoot = base .. (doubleConsonant and ("e" .. consonants) or "è") .. consonants
  return generateGroup1Forms_(infinitive, function(root, ending)
    return mutateRoot_cer_ger(isGroup1EndingSilent(ending) and mutatedRoot or root, ending) .. ending
  end, function(ending)
    return mutatedRoot .. "er" .. ending
  end)
end

--- Generate the simple tense forms of the given group-1 verb ending in `[aeou]yer`.
--- @param infinitive string The infinitive form of the verb.
--- @param mutateYe boolean If the verb ends in `ayer` and this argument is true the `y`
---        in the root is mutated as `i` before neutral endings.
--- @return table A table containing all simple tense forms of the verb.
local function generateGroup1Forms_yer(infinitive, mutateYe)
  local base = mw.ustring.sub(infinitive, 1, -4)
  local vowel = mw.ustring.sub(base, -1)
  local mutatedRoot
  if vowel == "a" and mutateYe or vowel == "e" then
    mutatedRoot = base .. "y"
  else
    mutatedRoot = base .. "i"
  end
  return generateGroup1Forms_(infinitive, function(root, ending)
    return (isGroup1EndingSilent(ending) and mutatedRoot or root) .. ending
  end, function(ending)
    return mutatedRoot .. "er" .. ending
  end)
end

--- Generate the simple tense forms of the given group-1 verb.
--- @param infinitive string The infinitive form of the verb.
--- @param mutationType string The type of mutation to apply to the verb’s root instead of the default one.
--- @return table A table containing all simple tense forms of the verb.
--- @see [[Conjugaison:français/Premier groupe]] for exceptions.
function p.generateGroup1Forms(infinitive, mutationType)
  local last4 = mw.ustring.sub(infinitive, -4)
  local last5 = mw.ustring.sub(infinitive, -5)
  local consonants = eCONSer_verbs[last4] or eCONSer_verbs[last5]
  if consonants then
    local doubleConsonant = (consonants == "l" or consonants == "t") and mutationType == MUTATION_DOUBLE_CONS
    return generateGroup1Forms_eCONSer(infinitive, consonants, doubleConsonant)
  end
  consonants = eacuteCONSer_verbs[last4] or eacuteCONSer_verbs[last5]
  if consonants then
    return generateGroup1Forms_eCONSer(infinitive, consonants)
  end

  if mw.ustring.sub(infinitive, -7) == "envoyer" then
    return generateGroup1Forms_envoyer(infinitive) -- TODO
  end

  local last3 = mw.ustring.sub(infinitive, -3)
  if last3 == "yer" then
    return generateGroup1Forms_yer(infinitive, mutationType == MUTATION_AYER_YE)
  end
  if last3 == "cer" or last3 == "ger" then
    return generateGroup1Forms_cer_ger(infinitive)
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
--- @param mutationType string The type of mutation to apply to the verb’s root instead of the default one.
--- @return (table, number) A tuple with a table containing all simple tense forms of the verb, and the verb’s group.
function p.generateFlexions(infinitive, group, mutationType)
  if infinitive == "être" then
    -- Special case to avoid unnecessary checks
    return p.etreConj, 3
  end
  if infinitive == "avoir" then
    -- Special case to avoid unnecessary checks
    return p.avoirConj, 3
  end
  local ending = mw.ustring.sub(infinitive, -2)
  if not group and ending == "er" or group == 1 then
    return p.generateGroup1Forms(infinitive, mutationType), 1
  end
  if not group and (ending == "ir" or ending == "ïr") or group == 2 then
    return p.generateGroup2Forms(infinitive, mutationType == MUTATION_I), 2
  end
  if not group or group == 3 then
    return p.generateGroup3Forms(infinitive), 3
  end
  error("Groupe invalide : " .. tostring(group))
end

return p
