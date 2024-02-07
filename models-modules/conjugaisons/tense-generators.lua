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
function p.generateGroup1Forms(infinitive)
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
      present = { root .. "e", root .. "es", root .. "e", root .. "ons", root .. "ez", root .. "ent" },
      imparfait = { root .. "ais", root .. "ais", root .. "ait", root .. "ions", root .. "iez", root .. "aient" },
      passeSimple = { root .. "ai", root .. "as", root .. "a", root .. "âmes", root .. "âtes", root .. "èrent" },
      futur = { infinitive .. "ai", infinitive .. "as", infinitive .. "a", infinitive .. "ons", infinitive .. "ez", infinitive .. "ont" },
    },
    subjonctif = {
      present = { root .. "e", root .. "es", root .. "e", root .. "ions", root .. "iez", root .. "ent" },
      imparfait = { root .. "asse", root .. "asses", root .. "ât", root .. "assions", root .. "assiez", root .. "assent" }
    },
    conditionnel = {
      present = { infinitive .. "ais", infinitive .. "ais", infinitive .. "ait", infinitive .. "ions", infinitive .. "iez", infinitive .. "aient" }
    },
    imperatif = {
      present = { root .. "e", root .. "ons", root .. "ez" }
    },
  }
end

--- Generate the simple tense forms of the given group-2 verb.
--- @param infinitive string The infinitive form of the verb.
--- @return table A table containing all simple tense forms of the verb.
function p.generateGroup2Forms(infinitive)
  local root = mw.ustring.sub(infinitive, 1, -3)
  return {
    infinitif = {
      present = infinitive,
    },
    participe = {
      present = root .. "issant",
      passe = root .. "i",
    },
    indicatif = {
      present = { root .. "is", root .. "is", root .. "it", root .. "issons", root .. "issez", root .. "issent" },
      imparfait = { root .. "issais", root .. "issais", root .. "issait", root .. "issions", root .. "issiez", root .. "issaient" },
      passeSimple = { root .. "is", root .. "is", root .. "it", root .. "îmes", root .. "îtes", root .. "irent" },
      futur = { infinitive .. "ai", infinitive .. "as", infinitive .. "a", infinitive .. "ons", infinitive .. "ez", infinitive .. "ont" },
    },
    subjonctif = {
      present = { root .. "isse", root .. "isses", root .. "isse", root .. "issions", root .. "issiez", root .. "issent" },
      imparfait = { root .. "isse", root .. "isses", root .. "ît", root .. "issions", root .. "issiez", root .. "issent" }
    },
    conditionnel = {
      present = { infinitive .. "ais", infinitive .. "ais", infinitive .. "ait", infinitive .. "ions", infinitive .. "iez", infinitive .. "aient" }
    },
    imperatif = {
      present = { root .. "is", root .. "issons", root .. "issez" }
    },
  }
end

--- Generate the simple tense forms of the given group-3 verb.
--- @param infinitive string The infinitive form of the verb.
--- @return table A table containing all simple tense forms of the verb.
function p.generateGroup3Forms(infinitive)
  if infinitive == "être" then
    return p.etreConj
  elseif infinitive == "avoir" then
    return p.avoirConj
  else
    return {} -- TODO détecter type de verbe et génerer en fonction
  end
end

return p
