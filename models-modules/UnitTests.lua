local m_params = require("Module:paramètres")

local UnitTester = {}

local tick = "[[File:OOjs UI icon check-constructive.svg|20px|alt=Passed|link=|Test réussi]]"
local cross = "[[File:OOjs UI icon close-ltr-destructive.svg|20px|alt=Failed|link=|Test échoué]]"

--- Détermine la position de la première différence entre deux chaines.
--- @param s1 string Une chaine.
--- @param s2 string Une chaine.
--- @return number|nil La position de la première différence,
---         -1 s’il n’y a aucune différence ou nil si une des deux
---         valeurs n’est pas une chaine.
local function first_difference(s1, s2)
  if type(s1) ~= "string" or type(s2) ~= "string" then
    return nil
  end
  if s1 == s2 then
    return -1
  end

  local iter1 = mw.ustring.gmatch(s1, ".")
  local iter2 = mw.ustring.gmatch(s2, ".")
  local max = math.min(mw.ustring.len(s1) or #s1, mw.ustring.len(s2) or #s2)

  for i = 1, max do
    local c1 = iter1()
    local c2 = iter2()
    if c1 ~= c2 then
      return i
    end
  end

  return max + 1
end

--- Convertit une valeur en chaine de caractères.
--- @param value any La valeur à convertir.
--- @return string La représentation sous forme de chaine de la valeur.
local function val_to_str(value)
  if type(value) == "string" then
    value = mw.ustring.gsub(value, "\n", "\\n")

    if mw.ustring.match(mw.ustring.gsub(value, "[^'\"]", ""), '^"+$') then
      return "'" .. value .. "'"
    end

    return '"' .. mw.ustring.gsub(value, '"', '\\"') .. '"'
  elseif type(value) == "table" then
    local result, done = {}, {}

    for k, val in ipairs(value) do
      table.insert(result, val_to_str(val))
      done[k] = true
    end

    for k, v in pairs(value) do
      if not done[k] then
        if (type(k) ~= "string") or not mw.ustring.match(k, "^[_%a][_%a%d]*$") then
          k = "[" .. val_to_str(k) .. "]"
        end
        table.insert(result, k .. "=" .. val_to_str(v))
      end
    end

    return "{" .. table.concat(result, ", ") .. "}"
  else
    return tostring(value)
  end
end

--- Compare deux valeurs. Si les deux sont des tables, la comparaison
--- est effectuée pour chaque sous-table.
--- @param value1 any La première valeur.
--- @param value2 any La deuxième valeur.
--- @param ignore_metatable boolean
local function deep_compare(value1, value2, ignore_metatable)
  local type1 = type(value1)
  local type2 = type(value2)

  if type1 ~= type2 then
    return false
  end
  if type1 ~= "table" and type2 ~= "table" then
    return value1 == value2
  end

  local metatable = getmetatable(value1)
  if not ignore_metatable and metatable and metatable.__eq then
    return value1 == value2
  end

  for k1, v1 in pairs(value1) do
    local v2 = value2[k1]
    if v2 == nil or not deep_compare(v1, v2) then
      return false
    end
  end
  for k2, v2 in pairs(value2) do
    local v1 = value1[k2]
    if v1 == nil or not deep_compare(v1, v2) then
      return false
    end
  end

  return true
end

--- Teste l’égalité de deux valeurs.
--- @param test_name string Le nom du test.
--- @param actual any La valeur retournée par l’opération à tester.
--- @param expected any La valeur attendue.
--- @param comment string|nil Un commentaire optionnel.
--- @private
function UnitTester:_equals(equals, to_string, test_name, actual, expected, comment)
  local result = {
    test_name = test_name,
    success = equals(actual, expected),
  }

  local actual_str, expected_str

  if expected == nil then
    expected_str = "''nil''"
  else
    expected_str = mw.text.nowiki(to_string(expected))
  end
  if actual == nil then
    actual_str = "''nil''"
  else
    actual_str = mw.text.nowiki(to_string(actual))
  end

  result.actual = actual_str
  result.expected = expected_str

  if self.differs_at then
    result.diff = first_difference(expected_str, actual_str)
  end
  if self.comments then
    result.comment = comment or "''Pas de commentaire''"
  end

  table.insert(self.result_table, result)
end

--- Teste si deux valeurs sont égales.
--- @param test_name string Le nom du test.
--- @param actual string|number|boolean La valeur retournée par l’opération à tester.
--- @param expected string|number|boolean La valeur attendue.
--- @param comment string|nil Un commentaire optionnel.
function UnitTester:equals(test_name, actual, expected, comment)
  self:_equals(function(v1, v2)
    return v1 == v2
  end, tostring, test_name, actual, expected, comment)
end

--- Teste l’égalité de deux valeurs en profondeur.
--- @param test_name string Le nom du test.
--- @param actual table|string|number|boolean La valeur retournée par l’opération à tester.
--- @param expected table|string|number|boolean La valeur attendue.
--- @param comment string|nil Un commentaire optionnel.
function UnitTester:equals_deep(test_name, actual, expected, comment)
  self:_equals(deep_compare, val_to_str, test_name, actual, expected, comment)
end

--- Fonction permettant de tester si la fonction donnée
--- lance une erreur précise pour les paramètres donnés.
--- Si ce n’est pas le cas, une erreur est lancée et
--- le test échoue.
--- @param test_name string Le nom du test.
--- @param func function La fonction à tester.
--- @param args table Les paramètres de la fonction.
--- @param expected_error_message string Le message d’erreur attendu.
--- @param comment string|nil Un commentaire optionnel.
function UnitTester:expect_error(test_name, func, args, expected_error_message, comment)
  local function_returned, actual_result = pcall(func, unpack(args))
  test_name = test_name .. " ''(Test d’erreur)''"

  if function_returned then
    local result = {
      test_name = test_name,
      success = false,
    }

    local expected_str = mw.text.nowiki(expected_error_message)
    local actual_str

    if actual_result == nil then
      actual_str = "''nil''"
    else
      actual_str = mw.text.nowiki(val_to_str(actual_result))
    end

    result.actual = mw.ustring.format("''Valeur retournée :'' %s", actual_str)
    result.expected = expected_str

    if self.differs_at then
      result.diff = first_difference(expected_str, actual_str)
    end
    if self.comments then
      result.comment = comment or "''Pas de commentaire''"
    end

    table.insert(self.result_table, result)
  else
    actual_result = mw.ustring.sub(actual_result, mw.ustring.find(actual_result, ": ") + 2)
    self:equals(test_name, actual_result, expected_error_message, options)
  end
end

--- Exécute les tests.
---  frame.args["differs_at"] (booléen) : Si vrai, ajoute une colonne
---     montrant les différences entre les valeurs attendue et obtenue.
---  frame.args["comments"] : Si vrai, ajoute une colonne affichant les
---     commentaires des tests qui en ont.
---  frame.args["summarize"] : Si vrai, les tableaux de résultat seront
---     cachés, seul le pourcentage de réussite sera affiché.
function UnitTester:run(frame)
  local params = {
    differs_at = { type = m_params.BOOLEAN, default = false, },
    comments = { type = m_params.BOOLEAN, default = false, },
    summarize = { type = m_params.BOOLEAN, default = false, },
  }
  local args = m_params.process(frame.args, params)
  self.differs_at = args.differs_at
  self.comments = args.comments
  local summarize = args.summarize

  local columns = 4
  local table_header = '{| class="wikitable"\n ! title="Liste des tests" | &nbsp; !! Texte !! Attendu !! Obtenu'

  -- Ajout des colonnes supplémentaires.
  if self.differs_at then
    columns = columns + 1
    table_header = table_header .. " !! Différence à la position"
  end
  if self.comments then
    columns = columns + 1
    table_header = table_header .. " !! Commentaires"
  end

  local test_methods = {}

  -- Extraction des méthodes de test.
  for key, _ in pairs(self) do
    if key:find("^test") then
      table.insert(test_methods, key)
    end
  end

  table.sort(test_methods)

  local num_failures = 0
  local total_tests = 0
  local results = {}

  -- Exécution des tests.
  for _, key in ipairs(test_methods) do
    local results_table = {}

    table.insert(results_table, mw.ustring.format(
        '%s\n|+ style="text-align:left" | %s&nbsp;:\n|-\n',
        table_header, key
    ))

    --- Contient les résultats des tests de la méthode en train d’être évaluée.
    self.result_table = {}

    local traceback = "''(pas de trace d’appel)''"
    local success, message = xpcall(function()
      return self[key](self)
    end, function(msg)
      traceback = debug.traceback("", 2)
      return msg
    end)

    if not success then
      table.insert(results_table, mw.ustring.format(
          '|-\n| colspan="%u" style="text-align:left" | <strong class="error">Erreur de script pendant le test : %s</strong>%s\n',
          columns, mw.text.nowiki(message), frame:extensionTag("pre", traceback)
      ))
      total_tests = total_tests + 1
      num_failures = num_failures + 1
    else
      for _, result in pairs(self.result_table) do
        total_tests = total_tests + 1
        if result.success then
          table.insert(results_table, '|-\n| ' .. tick)
        else
          table.insert(results_table, '|-\n| ' .. cross)
          num_failures = num_failures + 1
        end

        local diff = ""
        if result.diff ~= nil then
          diff = " || " .. result.diff
        end

        local comment = ""
        if result.comment ~= nil then
          comment = " || " .. result.comment
        end

        table.insert(results_table, mw.ustring.format(
            " || %s || %s || %s%s%s\n",
            result.test_name, result.expected, result.actual, diff, comment
        ))
      end
    end

    table.insert(results_table, "|}\n\n")
    table.insert(results, table.concat(results_table))
  end

  -- Construction des tableaux des résultats.

  local failure_cat = "[[Catégorie:Modules avec tests unitaires ayant échoué]]"
  if mw.title.getCurrentTitle().text:find("/documentation$") then
    failure_cat = ""
  end

  local num_successes = total_tests - num_failures

  -- Résumé des résultats, tableaux non affichés
  if summarize then
    local successes, css_class

    if num_failures == 0 then
      successes = total_tests
      css_class = "success"
    else
      successes = num_successes
      css_class = "error"
    end

    local s = successes == 1 and "" or "s"

    return mw.ustring.format(
        '<strong class="%s">%u/%u test%s réussi%s</strong>',
        css_class, successes, total_tests, s, s
    )
    -- Résultats complets
  else
    local message, css_class

    if num_failures == 0 then
      css_class = "success"
      message = "Tous les tests ont réussi."
    else
      local s = num_failures == 1 and "" or "s"
      local verb = num_failures == 1 and "a" or "ont"

      css_class = "error"
      message = mw.ustring.format('%u test%s %s échoué.', num_failures, s, verb)
    end

    local status = mw.ustring.format('<strong class="%s">%s</strong>', css_class, message)
    if num_failures ~= 0 then
      status = status .. failure_cat
    end

    local refresh_link = tostring(mw.uri.fullUrl(mw.title.getCurrentTitle().fullText, "action=purge&forcelinkupdate"))

    return mw.ustring.format(
        '%s <span class="plainlinks">[%s (rafraichir)]</span>\n\n%s',
        status, refresh_link, table.concat(results)
    )
  end
end

--- Instancie le testeur.
function UnitTester:new()
  local o = {}
  setmetatable(o, self)
  self.__index = self
  return o
end

local export = UnitTester:new()

--- Exécute les tests.
function export.run_tests(frame)
  return export:run(frame)
end

return export
