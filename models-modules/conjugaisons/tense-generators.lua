local p = {}

--- Conjugation of the "avoir" auxiliary verb.
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
--- Conjugation of the "être" auxiliary verb.
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

--- For group-1 verbs ending in "-eler/-eter", mutate the root in "-ell-/-ett-" instead of "-èl-/-èt-".
local MUTATION_DOUBLE_CONS = "double consonne"
--- For group-1 verbs ending in "-ayer", keep the "y" instead of mutating it to "i" before silent endings.
local MUTATION_AYER_YE = "ayer-ye"
--- For group-2 verbs ending in "-ïr", replace the "ï" by a "i" for the 3 singular persons of indicative
--- and the singular imperative present.
local MUTATION_I = "ï-i"

--- All available root mutation types.
p.mutationTypes = {
  MUTATION_DOUBLE_CONS,
  MUTATION_AYER_YE,
  MUTATION_I,
}
--- All available template group-3 verb endings, indexed by the template verb.
p.group3Templates = mw.loadData("Module:conjugaisons/group3-templates")

--- Generate a list of group-1 verb endings of the form `<firstLetter><consonants>er`.
--- @param firstLetter string The first letter.
--- @param consonants string[] The list of consonnants to generate endings with.
--- @return string[] The list of generated endings.
local function generateGroup1Endings(firstLetter, consonants)
  local endings = {}
  for _, c in ipairs(consonants) do
    endings[firstLetter .. c .. "er"] = c
  end
  return endings
end

--- The list of all available group-1 endings of the form `e<consonants>er`.
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
--- The list of all available group-1 endings of the form `é<consonants>er`.
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

--- Raise an error for the given mutation type.
--- @param mutationType string The mutation type.
local function invalidMutationType(mutationType)
  error(mw.ustring.format('Valeur invalide pour le paramètre « mutation » ("%s").', mutationType))
end

--- Check whether the given string starts with an "a", "â" or "o".
--- @param s string The string to check.
--- @return boolean True if the string starts with "a", "â" or "o", false otherwise.
local function startsWithAO(s)
  local firstLetter = mw.ustring.sub(s, 1, 1)
  return firstLetter == "a" or firstLetter == "â" or firstLetter == "o"
end

--- Check whether the given group-1 ending is silent.
--- @param ending string The ending to check.
--- @return boolean True if the ending is silent, false otherwise.
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
--- @return string The mutated root if it ends in "g" or "c", the argument root otherwise.
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
--- @param consonants string The consonant(s) that precede the mutating "e".
--- @param doubleConsonant boolean True to double the consonant instead of mutating the "e/é" into an "è".
--- @return table A table containing all simple tense forms of the verb.
local function generateGroup1Forms_eCONSer(infinitive, consonants, doubleConsonant)
  if doubleConsonant and consonants ~= "l" and consonants ~= "t" then
    invalidMutationType(MUTATION_DOUBLE_CONS)
  end
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
--- @param mutateYe boolean If the verb ends in "-ayer" and this argument is true the "y"
---        in the root is mutated as "i" before neutral endings.
--- @return table A table containing all simple tense forms of the verb.
local function generateGroup1Forms_yer(infinitive, mutateYe)
  local base = mw.ustring.sub(infinitive, 1, -4)
  local vowel = mw.ustring.sub(base, -1)
  local mutatedRoot
  if mutateYe and vowel ~= "a" then
    invalidMutationType(MUTATION_AYER_YE)
  end
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

--- Generate the simple tense forms of the given group-1 verb ending in "envoyer".
--- @param infinitive string The infinitive form of the verb.
--- @return table A table containing all simple tense forms of the verb.
local function generateGroup1Forms_envoyer(infinitive)
  local mutatedRoot = mw.ustring.sub(infinitive, 1, -4) .. "i"
  local mutatedInfinitiveRoot = mw.ustring.sub(infinitive, 1, -5) .. "err"
  return generateGroup1Forms_(infinitive, function(root, ending)
    return (isGroup1EndingSilent(ending) and mutatedRoot or root) .. ending
  end, function(ending)
    return mutatedInfinitiveRoot .. ending
  end)
end

--- Generate the simple tense forms of the given group-1 verb.
--- @param infinitive string The infinitive form of the verb.
--- @param mutationType string The type of mutation to apply to the verb’s root instead of the default one.
--- @return table A table containing all simple tense forms of the verb.
--- @see [[Conjugaison:français/Premier groupe]] for exceptions.
function p.generateGroup1Forms(infinitive, mutationType)
  if mutationType and mutationType ~= MUTATION_DOUBLE_CONS and mutationType ~= MUTATION_AYER_YE then
    invalidMutationType(mutationType)
  end

  local last4 = mw.ustring.sub(infinitive, -4)
  local last5 = mw.ustring.sub(infinitive, -5)
  local consonants = eCONSer_verbs[last4] or eCONSer_verbs[last5]
  if consonants then
    if mutationType and mutationType ~= MUTATION_DOUBLE_CONS then
      invalidMutationType(mutationType)
    end
    local doubleConsonant = (consonants == "l" or consonants == "t") and mutationType == MUTATION_DOUBLE_CONS
    return generateGroup1Forms_eCONSer(infinitive, consonants, doubleConsonant)
  end
  if mutationType and mutationType == MUTATION_DOUBLE_CONS then
    invalidMutationType(mutationType)
  end

  if mw.ustring.sub(infinitive, -7) == "envoyer" then
    if mutationType then
      invalidMutationType(mutationType)
    end
    return generateGroup1Forms_envoyer(infinitive)
  end

  local last3 = mw.ustring.sub(infinitive, -3)
  if last3 == "yer" then
    if mutationType and mutationType ~= MUTATION_AYER_YE then
      invalidMutationType(mutationType)
    end
    return generateGroup1Forms_yer(infinitive, mutationType == MUTATION_AYER_YE)
  end
  if mutationType then
    invalidMutationType(mutationType)
  end

  consonants = eacuteCONSer_verbs[last4] or eacuteCONSer_verbs[last5]
  if consonants then
    return generateGroup1Forms_eCONSer(infinitive, consonants)
  end

  if last3 == "cer" or last3 == "ger" then
    return generateGroup1Forms_cer_ger(infinitive)
  end

  return generateGroup1Forms_(infinitive)
end

--- Generate the simple tense forms of the given group-2 verb.
--- @param infinitive string The infinitive form of the verb.
--- @param dropDiaeresis boolean Whether to drop the "ï"
---        for the 3 singular persons of indicative and imperative present.
--- @return table A table containing all simple tense forms of the verb.
--- @see [[Conjugaison:français/Deuxième groupe]] for exceptions.
function p.generateGroup2Forms(infinitive, dropDiaeresis)
  local root = mw.ustring.sub(infinitive, 1, -3)
  local hasDiaeresis = mw.ustring.sub(infinitive, -2) == "ïr"
  if not hasDiaeresis and dropDiaeresis then
    invalidMutationType(MUTATION_I)
  end
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

--- Looks for the group-3 template whose ending has the longest match with the given infinitive.
--- @param infinitive string The infinitive form of the verb.
--- @return table|nil The group-3 template that matched the best, or nil if none matched.
local function longestMatchingGroup3Template(infinitive)
  local longestMatch
  local longestMatchLength = 0
  for _, template in pairs(p.group3Templates) do
    if not template.ignore_auto then
      local len = mw.ustring.len(template.ending)
      if mw.ustring.find(infinitive, template.ending .. "$") and (not longestMatch or longestMatchLength < len) then
        longestMatch = template
        longestMatchLength = len
      end
    end
  end
  return longestMatch
end

--- Generate the simple tense forms of the given group-3 verb.
--- @param infinitive string The infinitive form of the verb.
--- @param templateVerb string|nil The verb the given one should be conjugated like.
--- @return table A table containing all simple tense forms of the verb.
--- @see [[Conjugaison:français/Troisième groupe]] for sub-types.
function p.generateGroup3Forms(infinitive, templateVerb)
  if infinitive == "être" then
    return p.etreConj
  elseif infinitive == "avoir" then
    return p.avoirConj
  else
    local template
    if templateVerb then
      if not p.group3Templates[templateVerb] then
        error(mw.ustring.format('Modèle de verbe inconnu&nbsp;: "%s"', templateVerb))
      end
      template = p.group3Templates[templateVerb]
      if mw.ustring.sub(infinitive, -mw.ustring.len(template.ending)) ~= template.ending then
        error(mw.ustring.format('Le verbe "%s" ne se termine pas par "%s"', infinitive, template.ending))
      end
    elseif p.group3Templates[infinitive] then
      template = p.group3Templates[infinitive]
    else
      template = longestMatchingGroup3Template(infinitive)
    end
    local root = mw.ustring.sub(infinitive, 1, -mw.ustring.len(template.ending) - 1)
    local forms = {}
    for mode, tenses in pairs(template.endings) do
      forms[mode] = {}
      for tense, tenseEndings in pairs(tenses) do
        if type(tenseEndings) == "string" then
          forms[mode][tense] = root .. tenseEndings
        else
          forms[mode][tense] = {}
          for _, ending in ipairs(tenseEndings) do
            table.insert(forms[mode][tense], root .. ending)
          end
        end
      end
    end
    return forms
  end
end

--- Generate the simple tense forms of the given verb.
--- @param infinitive string The infinitive form of the verb.
--- @param group3 boolean If true, the verb will be classified as belonging to group 3.
--- @param mutationType string The type of mutation to apply to the verb’s root instead of the default one.
--- @param template string|nil For group-3 verbs, the verb the given one should be conjugated like.
--- @return (table, number) A tuple with a table containing all simple tense forms of the verb, and the verb’s group.
function p.generateFlexions(infinitive, group3, mutationType, template)
  if mutationType and template then
    error("Les paramètres « mutation » et « modèle » ne peuvent pas être spécifiés en même temps.")
  end
  if infinitive == "être" then
    if mutationType then
      invalidMutationType(mutationType)
    end
    -- Special case to avoid unnecessary checks
    return p.etreConj, 3
  end
  if infinitive == "avoir" then
    if mutationType then
      invalidMutationType(mutationType)
    end
    -- Special case to avoid unnecessary checks
    return p.avoirConj, 3
  end

  local ending = mw.ustring.sub(infinitive, -2)
  if not group3 and (ending == "ir" or ending == "ïr") then
    if mutationType and mutationType ~= MUTATION_I then
      invalidMutationType(mutationType)
    end
    return p.generateGroup2Forms(infinitive, mutationType == MUTATION_I), 2
  end
  if mutationType and mutationType == MUTATION_I then
    invalidMutationType(mutationType)
  end

  if not group3 and ending == "er" then
    return p.generateGroup1Forms(infinitive, mutationType), 1
  end
  if mutationType and mutationType == MUTATION_DOUBLE_CONS or mutationType == MUTATION_AYER_YE then
    invalidMutationType(mutationType)
  end

  return p.generateGroup3Forms(infinitive, template), 3
end

return p
