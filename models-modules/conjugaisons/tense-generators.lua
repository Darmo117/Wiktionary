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

--- Generate the simple tense forms of the given group-1 verb.
--- @param infinitive string The infinitive form of the verb.
--- @return table A table containing all simple tense forms of the verb.
--- @see [[Conjugaison:français/Premier groupe]] for exceptions.
function p.generateGroup1Forms(infinitive)
  -- TODO cas particuliers (https://fr.wiktionary.org/wiki/Conjugaison:fran%C3%A7ais/Premier_groupe)
  local root = mw.ustring.sub(infinitive, 1, -3)
  return {
    infinitif = {
      present = infinitive,
    },
    participe = {
      present = root .. "ant",
      passe = root .. "é",
    },
    indicatif = {
      present = {
        root .. "e",
        root .. "es",
        root .. "e",
        root .. "ons",
        root .. "ez",
        root .. "ent"
      },
      imparfait = {
        root .. "ais",
        root .. "ais",
        root .. "ait",
        root .. "ions",
        root .. "iez",
        root .. "aient"
      },
      passeSimple = {
        root .. "ai",
        root .. "as",
        root .. "a",
        root .. "âmes",
        root .. "âtes",
        root .. "èrent"
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
        root .. "e",
        root .. "es",
        root .. "e",
        root .. "ions",
        root .. "iez",
        root .. "ent"
      },
      imparfait = {
        root .. "asse",
        root .. "asses",
        root .. "ât",
        root .. "assions",
        root .. "assiez",
        root .. "assent"
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
        root .. "e",
        root .. "ons",
        root .. "ez"
      }
    },
  }
end

--- Generate the simple tense forms of the given group-2 verb.
--- @param infinitive string The infinitive form of the verb.
--- @param dropDiaeresis boolean Whether to drop the “ï”
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
--- @param dropDiaeresis boolean For group-2 verbs in “ïr”, whether to drop the “ï”
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
