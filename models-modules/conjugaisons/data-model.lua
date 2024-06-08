local m_table = require("Module:table")

local p = {}

p.DISABLED = "-"
p.RARE = "rare"
p.GRAY = "gris"

p.STATES = {
  p.DISABLED, p.RARE, p.GRAY
}

local PRONOUNS = {
  [-1] = { "en" },
  { "je", "j’" },
  { "tu" },
  { "il/elle/on" },
  { "nous" },
  { "vous" },
  { "ils/elles" },
}
local REFLEXIVE_PRONOUNS = {
  [-1] = { "se", "s’" },
  [0] = { "se", "s’" },
  { "me", "m’" },
  { "te", "t’" },
  { "se", "s’" },
  { "nous" },
  { "vous" },
  { "se", "s’" },
}
local DEMONSTRATIVE_PRONOUNS = { [2] = "toi", [4] = "nous", [5] = "vous", }

local QUE = { "que", "qu’" }

local LIAISON_LETTERS = { "a", "â", "e", "ê", "é", "è", "ë", "i", "î", "ï", "o", "ô", "u", "û", "y" }

local STRUCT = {
  infinitif = {
    tenses = {
      present = { 0 },
      passe = { 0 },
    },
  },
  participe = {
    tenses = {
      present = { -2 }, -- No pronoun
      passe = { -2 },
    },
  },
  gerondif = {
    tenses = {
      present = { -1 },
      passe = { -1 },
    },
  },
  indicatif = {
    tenses = {
      present = { 1, 2, 3, 4, 5, 6 },
      passeCompose = { 1, 2, 3, 4, 5, 6 },
      imparfait = { 1, 2, 3, 4, 5, 6 },
      plusQueParfait = { 1, 2, 3, 4, 5, 6 },
      passeSimple = { 1, 2, 3, 4, 5, 6 },
      passeAnterieur = { 1, 2, 3, 4, 5, 6 },
      futur = { 1, 2, 3, 4, 5, 6 },
      futurAnterieur = { 1, 2, 3, 4, 5, 6 },
    },
  },
  subjonctif = {
    tenses = {
      present = { 1, 2, 3, 4, 5, 6 },
      passe = { 1, 2, 3, 4, 5, 6 },
      imparfait = { 1, 2, 3, 4, 5, 6 },
      plusQueParfait = { 1, 2, 3, 4, 5, 6 },
    },
    usesQue = true,
  },
  conditionnel = {
    tenses = {
      present = { 1, 2, 3, 4, 5, 6 },
      passe = { 1, 2, 3, 4, 5, 6 },
    },
  },
  imperatif = {
    tenses = {
      present = { 2, 4, 5 },
      passe = { 2, 4, 5 },
    },
    reversedPronouns = true,
  },
}

------------------------
--- Helper functions ---
------------------------

--- Check whether a liaison is required for the given word.
--- @param w string The word to check.
--- @param aspiratedH boolean Whether a "h" should be ignored for liaison.
--- @return boolean True if a liaison is needed, false otherwise.
local function requiresLiaison(w, aspiratedH)
  local char = mw.ustring.sub(mw.ustring.lower(w), 1, 1)
  return char == "h" and not aspiratedH or m_table.contains(LIAISON_LETTERS, char)
end

----------------------
--- Specifications ---
----------------------

--- @class FormSpec
p.FormSpec = {
  --- @type string|nil
  status = nil,
  --- @type string|nil
  form = nil,
  --- @type TenseSpec
  tenseSpec = nil,
}

--- @param status string|nil
--- @return FormSpec
function p.FormSpec:new(status)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  self.status = status
  return o
end

--- @class TenseSpec
p.TenseSpec = {
  --- @type string|nil
  status = nil,
  --- @type FormSpec[]
  formSpecs = {},
  --- @type ModeSpec
  modeSpec = nil,
}

--- @param status string|nil
--- @param formSpecs FormSpec[]
--- @return TenseSpec
function p.TenseSpec:new(status, formSpecs)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  self.status = status
  self.formSpecs = formSpecs
  for _, formSpec in ipairs(formSpecs) do
    formSpec.tenseSpec = self
  end
  return o
end

--- @class ModeSpec
p.ModeSpec = {
  --- @type string|nil
  status = nil,
  --- @type table<string, TenseSpec>
  tenseSpecs = {},
  --- @type VerbSpec
  verbSpec = nil,
}

--- @param status string|nil
--- @param tenseSpecs table<string, TenseSpec>
--- @return ModeSpec
function p.ModeSpec:new(status, tenseSpecs)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  self.status = status
  self.tenseSpecs = tenseSpecs
  for _, tenseSpec in pairs(tenseSpecs) do
    tenseSpec.modeSpec = self
  end
  return o
end

--- @class VerbSpec
p.VerbSpec = {
  --- @type boolean
  aspiratedH = false,
  --- @type boolean
  pronominal = false,
  --- @type boolean
  auxEtre = false,
  --- @type table<string, ModeSpec>
  modeSpecs = {},
}

--- @param aspiratedH boolean
--- @param pronominal boolean
--- @param auxEtre boolean
--- @param modeSpecs table<string, ModeSpec>
--- @return VerbSpec
function p.VerbSpec:new(aspiratedH, pronominal, auxEtre, modeSpecs)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  self.aspiratedH = aspiratedH
  self.pronominal = pronominal
  self.auxEtre = auxEtre
  self.modeSpecs = modeSpecs
  for _, modeSpec in pairs(modeSpecs) do
    modeSpec.verbSpec = self
  end
  return o
end

-------------
--- Verbs ---
-------------

--- @class VerbForm
p.VerbForm = {
  --- @type FormSpec
  spec = nil,
  --- @type VerbTense
  tense = nil,
  --- @type number
  _pronounIndex = 0,
  --- @type string|nil
  _pronoun = nil,
  --- @type string|nil
  _form = nil,
}

--- @param spec FormSpec
--- @param pronounIndex number
--- @return VerbForm
function p.VerbForm:new(spec, pronounIndex)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  self.spec = spec
  self._pronounIndex = pronounIndex
  self:setForm(nil)
  return o
end

--- @return boolean
function p.VerbForm:isGray()
  return not self._form or self.spec.status or self.spec.tenseSpec.status or self.spec.tenseSpec.modeSpec.status
end

--- @return string|nil
function p.VerbForm:getPronoun()
  return self._pronoun
end

--- @return string|nil
function p.VerbForm:getForm()
  return self._form
end

--- @param form string|nil
function p.VerbForm:setForm(form)
  if form and self.spec.status == p.DISABLED
      or self.spec.tenseSpec.status == p.DISABLED
      or self.spec.tenseSpec.modeSpec.status == p.DISABLED then
    error("Une flexion désactivée ne peut pas être renseignée")
  end

  self._form = form
  if not form then
    self._pronoun = nil
  else
    local i = self._pronounIndex

    if self.tense.mode.reversedPronouns then
      self._pronoun = "-" .. DEMONSTRATIVE_PRONOUNS[i]
    else
      --- @param table string[]
      --- @param liaison boolean
      --- @return string
      local function getPronoun(table, liaison)
        return liaison and table[i] and table[i][2] or (table[i] and (table[i][1] .. " ") or "")
      end

      local liaison = requiresLiaison(form, self.spec.tenseSpec.modeSpec.verbSpec.aspiratedH)

      if self.spec.tenseSpec.modeSpec.verbSpec.pronominal then
        self._pronoun = (PRONOUNS[i] and (PRONOUNS[i][1] .. " ") or "") .. getPronoun(REFLEXIVE_PRONOUNS, liaison)
      else
        self._pronoun = getPronoun(PRONOUNS, liaison)
      end
      if self.tense.mode.prependQue then
        self._pronoun = getPronoun(QUE, requiresLiaison(self._pronoun)) .. self._pronoun
      end
    end
  end

  self.tense:_onFormUpdate()
end

--- @class VerbTense
p.VerbTense = {
  --- @type TenseSpec
  spec = nil,
  --- @type VerbMode
  mode = nil,
  --- @type table<string, VerbForm>
  forms = {},
  --- @type boolean
  _isEmpty = true,
}

--- @param spec TenseSpec
--- @param forms table<string, VerbForm>
--- @return VerbTense
function p.VerbTense:new(spec, forms)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  self.spec = spec
  self.forms = forms
  for _, form in pairs(forms) do
    form.tense = self
  end
  return o
end

--- @return boolean
function p.VerbTense:isGray()
  return self._isEmpty or self.spec.status or self.spec.modeSpec.status
end

--- @return string|nil
function p.VerbTense:getStatus()
  return self._isEmpty and p.DISABLED or self.spec.status or self.spec.modeSpec.status
end

function p.VerbTense:_onFormUpdate()
  for _, form in pairs(self.forms) do
    if form._form then
      self._isEmpty = false
      return
    end
  end
  self._isEmpty = true
  self.mode:_onTenseUpdate()
end

--- @class VerbMode
p.VerbMode = {
  --- @type ModeSpec
  spec = nil,
  --- @type Verb
  verb = nil,
  --- @type table<string, VerbTense>
  tenses = {},
  --- @type boolean
  prependQue = false,
  --- @type boolean
  reversedPronouns = false,
  --- @type boolean
  _isEmpty = true,
}

--- @param spec ModeSpec
--- @param tenses table<string, VerbTense>
--- @param prependQue boolean
--- @param reversedPronouns boolean
--- @return VerbMode
function p.VerbMode:new(spec, tenses, prependQue, reversedPronouns)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  self.spec = spec
  self.tenses = tenses
  for _, tense in pairs(tenses) do
    tense.mode = self
  end
  self.prependQue = prependQue
  self.reversedPronouns = reversedPronouns
  return o
end

--- @return boolean
function p.VerbMode:isGray()
  return self._isEmpty or self.spec.status
end

--- @return string|nil
function p.VerbMode:getStatus()
  return self._isEmpty and p.DISABLED or self.spec.status
end

function p.VerbMode:_onTenseUpdate()
  for _, tense in pairs(self.tenses) do
    if not tense._isEmpty then
      self._isEmpty = false
      return
    end
  end
  self._isEmpty = true
end

--- @class Verb
p.Verb = {
  --- @type VerbSpec
  spec = nil,
  --- @type VerbMode[]
  modes = {},
}

--- @param spec VerbSpec
--- @param modes VerbMode[]
--- @return Verb
function p.Verb:new(spec, modes)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  self.spec = spec
  self.modes = modes
  for _, mode in pairs(modes) do
    mode.verb = self
  end
  return o
end

-----------------
--- Functions ---
-----------------

-- FIXME revoir constructeurs
--- Create a new empty verb specification.
--- @param aspiratedH boolean Whether the initial "h" of the verb should prevent a liaison.
--- @param pronominal boolean Whether the verb is pronominal.
--- @param auxEtre boolean Whether the verb should use the verb "être" instead of "avoir" as its auxiliary.
--- @return VerbSpec A new empty VerbSpec object.
function p.newVerbSpec(aspiratedH, pronominal, auxEtre)
  local modeSpecs = {}
  for modeName, mode in pairs(STRUCT) do
    local tenseSpecs = {}
    for tenseName, indices in pairs(mode.tenses) do
      local formSpecs = {}
      for _ = 1, #indices do
        table.insert(formSpecs, p.FormSpec:new(nil))
      end
      tenseSpecs[tenseName] = p.TenseSpec:new(nil, formSpecs)
    end
    mw.logObject(modeName) -- DEBUG
    mw.logObject(tenseSpecs) -- DEBUG
    modeSpecs[modeName] = p.ModeSpec:new(nil, tenseSpecs)
  end
  mw.logObject(modeSpecs["indicatif"].tenseSpecs) -- DEBUG
  mw.logObject(modeSpecs["imperatif"].tenseSpecs) -- DEBUG
  mw.logObject(modeSpecs["infinitif"].tenseSpecs == modeSpecs["imperatif"].tenseSpecs) -- DEBUG
  return p.VerbSpec:new(aspiratedH, pronominal, auxEtre, modeSpecs)
end

--- Create a new unpopulated Verb object from the given spec.
--- @param spec VerbSpec A VerbSpec object.
--- @return Verb A new Verb object.
function p.newVerb(spec)
  local modes = {}
  for modeName, mode in pairs(STRUCT) do
    local tenses = {}
    -- DEBUG
    mw.logObject(modeName)
    mw.logObject(spec.modeSpecs[modeName].tenseSpecs)
    for tenseName, indices in pairs(mode.tenses) do
      -- DEBUG
      --mw.logObject(modeName .. " " .. tenseName)
      --mw.logObject(spec.modeSpecs[modeName].tenseSpecs[tenseName])
      local forms = {}
      for i, j in ipairs(indices) do
        --table.insert(forms, p.VerbForm:new(spec
        --    .modeSpecs[modeName]
        --    .tenseSpecs[tenseName] -- FIXME returns nil
        --    .formSpecs
        --[i],
        --    j))
      end
      tenses[tenseName] = p.VerbTense:new(spec.modeSpecs[modeName].tenseSpecs[tenseName], forms)
    end
    modes[modeName] = p.VerbMode:new(spec.modeSpecs[modeName], tenses, mode.usesQue, mode.reversedPronouns)
  end
  return p.Verb:new(spec, modes)
end

return p
