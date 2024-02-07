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
  return {} -- TODO
end

--- Generate the simple tense forms of the given group-2 verb.
--- @param infinitive string The infinitive form of the verb.
--- @return table A table containing all simple tense forms of the verb.
function p.generateGroup2Forms(infinitive)
  return {} -- TODO
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
    return {} -- TODO détecter type de verbe
  end
end

return p
