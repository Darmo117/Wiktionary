local consts = require("Module:donées Unicode/constantes")
local p = {}

local function binary_range_search(codepoint, ranges)
  local low, mid, high
  low, high = 1, ranges.length
  while low <= high do
    mid = math.floor((low + high) / 2)
    local range = ranges[mid]
    if codepoint < range.lower then
      high = mid - 1
    elseif codepoint <= range.upper then
      return range, mid
    else
      low = mid + 1
    end
  end
  return nil, mid
end

--- Cet objet permet d’instancier un module en l’indexant sans le préfixe "Module:données Unicode/".
--- Par exemple, loader.blocs retourne [[Module:Unicode data/blocs]]. Si un module ne peut pas être
--- chargé, la valeur "false" est retournée.
local loader = setmetatable({}, {
  __index = function(self, key)
    local success, data = pcall(mw.loadData, "Module:données Unicode/" .. key)
    if not success then
      data = false
    end
    self[key] = data
    return data
  end
})

-- Pour l’algorithme de génération des noms des syllabes hangûles, se référer à « Hangul Syllable Name Generation »
-- dans la section 3.12 de la spécification Unicode : https://www.unicode.org/versions/Unicode11.0.0/ch03.pdf
local name_hooks = {
  { lower = 0x00, upper = 0x1F, name = { en = "<control-%04X>", fr = "<commande-%04X>" } }, -- Commandes C0
  { lower = 0x7F, upper = 0x9F, name = { en = "<control-%04X>", fr = "<commande-%04X>" } }, -- DEL et commandes C1
  { lower = 0x3400, upper = 0x4DB5, name = { en = "CJK UNIFIED IDEOGRAPH-%04X", fr = "IDÉOGRAPHE UNIFIÉ CJC-%04X" } }, -- Idéographes unifiés CJC supplément A
  { lower = 0x4E00, upper = 0x9FEF, name = { en = "CJK UNIFIED IDEOGRAPH-%04X", fr = "IDÉOGRAPHE UNIFIÉ CJC-%04X" } }, -- Idéographes unifiés CJC
  { lower = 0xAC00, upper = 0xD7A3, name = function(codepoint)
    -- Syllables hangûles
    local hangul_data = loader.Hangul
    local syllable_index = codepoint - 0xAC00
    local s1 = hangul_data.leads[math.floor(syllable_index / hangul_data.final_count)]
    local s2 = hangul_data.vowels[math.floor((syllable_index % hangul_data.final_count) / hangul_data.trail_count)]
    local s3 = hangul_data.trails[syllable_index % hangul_data.trail_count]

    return ("HANGUL SYLLABLE %s%s%s"):format(s1, s2, s3), ("SYLLABLE HANGÛLE %s%s%s"):format(s1, s2, s3)
  end },
  { lower = 0xD800, upper = 0xDFFF, name = { en = "<surrogate-%04X>", fr = "<surrogate-%04X>" } }, -- Zones d’indirection
  { lower = 0xE000, upper = 0xF8FF, name = { en = "<private-use-%04X>", fr = "<usage-privé-%04X>" } }, -- Utilisation privée
  -- Idéogrammes de compatibilité CJC
  { lower = 0xF900, upper = 0xFA6D, name = { en = "CJK COMPATIBILITY IDEOGRAPH-%04X", fr = "IDÉOGRAPHE DE COMPATIBILITÉ CJC-%04X" } },
  { lower = 0xFA70, upper = 0xFAD9, name = { en = "CJK COMPATIBILITY IDEOGRAPH-%04X", fr = "IDÉOGRAPHE DE COMPATIBILITÉ CJC-%04X" } },
  { lower = 0x17000, upper = 0x187F7, name = { en = "TANGUT IDEOGRAPH-%04X", fr = "IDÉOGRAPHE TANGOUTE-%04X" } }, -- Tangoute
  { lower = 0x18800, upper = 0x18AF2, name = function(codepoint)
    local c = codepoint - 0x187FF
    return ("TANGUT COMPONENT-%03d"):format(c), ("COMPOSANT TANGOUTE-%03d"):format(c)
  end },
  { lower = 0x1B170, upper = 0x1B2FB, name = { en = "NUSHU CHARACTER-%04X", fr = "CARACTÈRE NÜSHU-%04X" } }, -- Nüshu
  { lower = 0x20000, upper = 0x2A6D6, name = { en = "CJK UNIFIED IDEOGRAPH-%04X", fr = "IDÉOGRAPHE UNIFIÉ CJC-%04X" } }, -- Idéographes unifiés CJC - extension B
  { lower = 0x2A700, upper = 0x2B734, name = { en = "CJK UNIFIED IDEOGRAPH-%04X", fr = "IDÉOGRAPHE UNIFIÉ CJC-%04X" } }, -- Idéographes unifiés CJC - extension C
  { lower = 0x2A740, upper = 0x2B81D, name = { en = "CJK UNIFIED IDEOGRAPH-%04X", fr = "IDÉOGRAPHE UNIFIÉ CJC-%04X" } }, -- Idéographes unifiés CJC - extension D
  { lower = 0x2B820, upper = 0x2CEA1, name = { en = "CJK UNIFIED IDEOGRAPH-%04X", fr = "IDÉOGRAPHE UNIFIÉ CJC-%04X" } }, -- Idéographes unifiés CJC - extension E
  { lower = 0x2CEB0, upper = 0x2EBE0, name = { en = "CJK UNIFIED IDEOGRAPH-%04X", fr = "IDÉOGRAPHE UNIFIÉ CJC-%04X" } }, -- Idéographes unifiés CJC - extension F
  -- Supplément aux idéogrammes de compatibilité
  { lower = 0x2F800, upper = 0x2FA1D, name = { en = "CJK COMPATIBILITY IDEOGRAPH-%04X", fr = "IDÉOGRAPHE DE COMPATIBILITÉ CJC-%04X" } },
  { lower = 0xE0100, upper = 0xE01EF, name = function(codepoint)
    -- Sélecteurs de variante - supplément
    local c = codepoint - 0xE0100 + 17
    return ("VARIATION SELECTOR-%d"):format(c), ("SÉLECTEUR DE VARIATION-%d"):format(c)
  end },
  { lower = 0xF0000, upper = 0xFFFFD, name = { en = "<private-use-%04X>", fr = "<usage-privé-%04X>" } }, -- Zone à usage privé - extension A
  { lower = 0x100000, upper = 0x10FFFD, name = { en = "<private-use-%04X>", fr = "<usage-privé-%04X>" } }  -- Zone à usage privé - extension B
}
name_hooks.length = #name_hooks

local name_range_cache

local function generate_name(data, codepoint)
  if type(data) == "table" then
    return data.en:format(codepoint), data.fr:format(codepoint)
  else
    return data(codepoint)
  end
end

--- Retourne le nom du caractère ayant le point de code donné.
--- @param codepoint number : Le point de code.
--- @return table Le nom du caractère en anglais et en français.
--- https://www.unicode.org/versions/Unicode11.0.0/ch04.pdf, section 4.8
function p.nom_caractere(codepoint)
  -- Les points de code de U+FDD0 à U+FDEF et tous ceux terminant en FFFE ou FFFF sont non assignés.
  -- https://www.unicode.org/faq/private_use.html#nonchar4
  if 0xFDD0 <= codepoint and (codepoint <= 0xFDEF
      or math.floor(codepoint % 0x10000) >= 0xFFFE) then
    return ("<noncharacter-%04X>"):format(codepoint), ("<non-caractère-%04X>"):format(codepoint)
  end

  if name_range_cache -- Vérifie que le "name hook" utilisé précédement s’applique à ce point de code.
      and codepoint >= name_range_cache.lower
      and codepoint <= name_range_cache.upper then
    return generate_name(name_range_cache.name, codepoint)
  end

  local range = binary_range_search(codepoint, name_hooks)
  if range then
    name_range_cache = range
    return generate_name(range.name, codepoint)
  end

  local data = loader[('noms/%03X'):format(codepoint / 0x1000)]

  if data and data[codepoint] then
    return data[codepoint]
    -- Non-assigné (Cn) désigne les non-caractères et les caractères réservés.
    -- Le caractère a été défini comme étant un non-caractère et, s’il avait
    -- été assigné, son nom aurait déjà été retrouvé, il doit donc être réservé.
  else
    return ("<reserved-%04X>"):format(codepoint), ("<réservé-%04X>"):format(codepoint)
  end
end

function p.blocs()
  return loader.blocs
end

--- Retourne le bloc avec le nom donné.
--- @param name string : le nom en anglais ou français.
--- @return table|nil
function p.bloc_nom(name)
  for _, block in ipairs(loader.blocs) do
    if block.name.en == name or block.name.fr == name then
      return block
    end
  end

  return nil
end

--- Retourne le bloc correspondant au caractère donné.
--- @param char string : le caractère.
--- @return table|nil
function p.bloc_caractere(char)
  local code = mw.ustring.codepoint(char)

  for _, block in pairs(loader.blocs) do
    if block.lower <= code and code <= block.upper then
      return block
    end
  end

  return nil
end

function p.nom_de_page_valide(pagename)
  local has_nonws = false

  for cp in mw.ustring.gcodepoint(pagename) do
    if cp == 0x0023 -- #
        or cp == 0x005B -- [
        or cp == 0x005D -- ]
        or cp == 0x007B -- {
        or cp == 0x007C -- |
        or cp == 0x007D -- }
        or cp == 0x180E -- SÉPARATEUR DE VOYELLES MONGOL (MONGOLIAN VOWEL SEPARATOR)
        or cp >= 0x2000 and cp <= 0x200A -- Espaces dans le bloc Ponctuation générale
        or cp == 0xFFFD -- REMPLACEMENT (REPLACEMENT CHARACTER)
    then
      return false
    end

    local printable, result = p.est_affichable(cp)
    if not printable then
      return false
    end

    if result ~= consts.space_separator then
      has_nonws = true
    end
  end

  return has_nonws
end

local function manual_unpack(what, from)
  if what[from + 1] == nil then
    return what[from]
  end

  local result = {}
  from = from or 1
  for i, item in ipairs(what) do
    if i >= from then
      table.insert(result, item)
    end
  end
  return unpack(result)
end

local function compare_ranges(range1, range2)
  return range1.lower < range2.lower
end

-- Creates a function to look up data in a module that contains "singles" (a
-- code point-to-data map) and "ranges" (an array containing arrays that contain
-- the low and high code points of a range and the data associated with that
-- range).
-- "loader" loads and returns the "singles" and "ranges" tables.
-- "match_func" is passed the code point and either the data or the "dots", and
-- generates the final result of the function.
-- The varargs ("dots") describes the default data to be returned if there wasn't
-- a match.
-- In case the function is used more than once, "cache" saves ranges that have
-- already been found to match, or a range whose data is the default if there
-- was no match.
local function memo_lookup(data_module_subpage, match_func, ...)
  local dots = { ... }
  local cache = {}
  local singles, ranges

  return function(codepoint)
    if not singles then
      local data_module = loader[data_module_subpage]
      singles, ranges = data_module.singles, data_module.ranges
    end

    if singles[codepoint] then
      return match_func(codepoint, singles[codepoint])
    end

    local range = binary_range_search(codepoint, cache)
    if range then
      return match_func(codepoint, manual_unpack(range, 3)) -- TODO vérifier from (partir de 1 ?)
    end

    local index
    range, index = binary_range_search(codepoint, ranges)
    if range then
      table.insert(cache, range)
      table.sort(cache, compare_ranges)
      return match_func(codepoint, manual_unpack(range, 3)) -- TODO vérifier from (partir de 1 ?)
    end

    if ranges[index] then
      local dots_range
      if codepoint > ranges[index].upper then
        dots_range = {
          ranges[index].upper + 1,
          ranges[index + 1] and ranges[index + 1].lower - 1 or 0x10FFFF,
          unpack(dots)
        }
      else
        -- codepoint < range[index].lower
        dots_range = {
          ranges[index - 1] and ranges[index - 1].upper + 1 or 0,
          ranges[index].lower - 1,
          unpack(dots)
        }
      end
      table.sort(cache, compare_ranges)
    end

    return match_func(codepoint)
  end
end

-- Get a code point's combining class value in [[Module:Unicode data/combining]],
-- and return whether this value is not zero. Zero is assigned as the default
-- if the combining class value is not found in this data module.
-- That is, return true if character is combining, or false if it is not.
-- See https://www.unicode.org/reports/tr44/#Canonical_Combining_Class_Values for
-- more information.
p.est_combinant = memo_lookup(
    "combinants",
    function(_, combining_class)
      return combining_class and combining_class ~= 0 or false
    end,
    0
)

function p.ajouter_cercle_pointilles(str)
  return (mw.ustring.gsub(str, ".",
      function(char)
        if p.est_combinant(mw.ustring.codepoint(char)) then
          return '◌' .. char
        end
      end
  ))
end

local lookup_control = memo_lookup(
    "contrôles",
    function(_, ccc)
      return ccc or consts.assigned
    end,
    consts.assigned
)

function p.est_assigne(codepoint)
  return lookup_control(codepoint) ~= consts.unassigned
end

function p.est_affichable(codepoint)
  local result = lookup_control(codepoint)
  return result == consts.assigned or result == consts.space_separator, result
end

function p.est_blanc(codepoint)
  local result = lookup_control(codepoint)
  return (result == consts.space_separator), result
end

local unsupported_titles = {
  [0x0020] = "Titres non pris en charge/Espace";
  [0x0023] = "Titres non pris en charge/Croisillon";
  [0x002E] = "Titres non pris en charge/Point";
  [0x003A] = "Titres non pris en charge/:";
  [0x003C] = "Titres non pris en charge/Signe inférieur à";
  [0x003E] = "Titres non pris en charge/Signe supérieur à";
  [0x005B] = "Titres non pris en charge/Crochet gauche";
  [0x005D] = "Titres non pris en charge/Crochet droit";
  [0x005F] = "Titres non pris en charge/Tiret bas";
  [0x007B] = "Titres non pris en charge/Accolade gauche";
  [0x007C] = "Titres non pris en charge/Barre verticale";
  [0x007D] = "Titres non pris en charge/Accolade droite";
  [0x1680] = "Titres non pris en charge/Espace oghamique";
  [0xFFFD] = "Titres non pris en charge/Remplacement";
}

function p.titre_entree(codepoint)
  if unsupported_titles[codepoint] then
    return unsupported_titles[codepoint]
  end
  if lookup_control(codepoint) ~= consts.assigned then
    return nil
  end
  return mw.ustring.char(codepoint)
end

return p
