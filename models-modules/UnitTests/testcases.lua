local tests = require("Module:UnitTests")
-- Suppression de l’entrée pour pouvoir charger le module une deuxième fois.
package.loaded["Module:UnitTests"] = nil
local m_tests = require("Module:UnitTests")

-- Fonctions utilitaires --

local function test(testName, functionName, testedTestName, actual, expected, expectedResultsTable)
  m_tests.resultsTable = {}
  getmetatable(m_tests).__index[functionName](m_tests, testedTestName, actual, expected)
  tests:equals_deep(testName, m_tests.resultsTable, { expectedResultsTable })
end

-- Tests --

function tests:test_equals_strings()
  local testName = "test"
  test("equals(), chaines", "equals", testName, "a", "a", {
    testName = testName,
    success = true,
    actual = "a",
    expected = "a",
  })
end

function tests:test_equals_numbers()
  local testName = "test"
  test("equals(), nombres", "equals", testName, 1, 1, {
    testName = testName,
    success = true,
    actual = "1",
    expected = "1",
  })
end

function tests:test_equals_booleans()
  local testName = "test"
  test("equals(), booléens", "equals", testName, true, true, {
    testName = testName,
    success = true,
    actual = "true",
    expected = "true",
  })
end

function tests:test_equals_nil()
  local testName = "test"
  test("equals(), nil", "equals", testName, nil, nil, {
    testName = testName,
    success = true,
    actual = "''nil''",
    expected = "''nil''",
  })
end

function tests:test_equals_deep_not_table()
  local testName = "test"
  test("equals_deep(), pas une table", "equals_deep", testName, 1, 1, {
    testName = testName,
    success = true,
    actual = "1",
    expected = "1",
  })
end

function tests:test_equals_deep_1_level()
  local testName = "test"
  test("equals_deep(), 1 niveau", "equals_deep", testName, { 1 }, { 1 }, {
    testName = testName,
    success = true,
    actual = "&#123;1&#125;",
    expected = "&#123;1&#125;",
  })
end

function tests:test_equals_deep_1_level_keys()
  local testName = "test"
  test("equals_deep(), 1 niveau", "equals_deep", testName, { a = 1 }, { a = 1 }, {
    testName = testName,
    success = true,
    actual = "&#123;a&#61;1&#125;",
    expected = "&#123;a&#61;1&#125;",
  })
end

function tests:test_equals_deep_2_levels()
  local testName = "test"
  test("equals_deep(), 2 niveaux", "equals_deep", testName, { { 1 } }, { { 1 } }, {
    testName = testName,
    success = true,
    actual = "&#123;&#123;1&#125;&#125;",
    expected = "&#123;&#123;1&#125;&#125;",
  })
end

function tests:test_equals_deep_2_levels_keys()
  local testName = "test"
  test("equals_deep(), 2 niveaux", "equals_deep", testName, { a = { b = 1 } }, { a = { b = 1 } }, {
    testName = testName,
    success = true,
    actual = "&#123;a&#61;&#123;b&#61;1&#125;&#125;",
    expected = "&#123;a&#61;&#123;b&#61;1&#125;&#125;",
  })
end

function tests:test_ignore_flag()
  m_tests:ignore()
  self:equals("ignore() flag", m_tests.ignoreCurrentTests, true)
end

-- Tests négatifs --

function tests:test_not_equals_strings()
  local testName = "test"
  test("equals() négatif, chaines", "equals", testName, "b", "a", {
    testName = testName,
    success = false,
    actual = "b",
    expected = "a",
  })
end

function tests:test_not_equals_numbers()
  local testName = "test"
  test("equals() négatif, nombres", "equals", testName, 2, 1, {
    testName = testName,
    success = false,
    actual = "2",
    expected = "1",
  })
end

function tests:test_not_equals_booleans()
  local testName = "test"
  test("equals() négatif, booléens", "equals", testName, false, true, {
    testName = testName,
    success = false,
    actual = "false",
    expected = "true",
  })
end

function tests:test_not_equals_nil()
  local testName = "test"
  test("equals() négatif, nil", "equals", testName, "nil", nil, {
    testName = testName,
    success = false,
    actual = "nil",
    expected = "''nil''",
  })
end

function tests:test_not_equals_deep_not_table()
  local testName = "test"
  test("equals_deep() négatif, pas une table", "equals_deep", testName, 2, 1, {
    testName = testName,
    success = false,
    actual = "2",
    expected = "1",
  })
end

function tests:test_not_equals_deep_1_level()
  local testName = "test"
  test("equals_deep() négatif, 1 niveau", "equals_deep", testName, { 2 }, { 1 }, {
    testName = testName,
    success = false,
    actual = "&#123;2&#125;",
    expected = "&#123;1&#125;",
  })
end

function tests:test_not_equals_deep_1_level_2_elements()
  local testName = "test"
  test("equals_deep() négatif, 1 niveau, 2 éléments", "equals_deep", testName, { 2, 1 }, { 1, 2 }, {
    testName = testName,
    success = false,
    actual = "&#123;2, 1&#125;",
    expected = "&#123;1, 2&#125;",
  })
end

function tests:test_not_equals_deep_1_level_keys_same_values_diff()
  local testName = "test"
  test("equals_deep() négatif, 1 niveau, clés identiques, valeurs différentes", "equals_deep", testName, { a = 2 }, { a = 1 }, {
    testName = testName,
    success = false,
    actual = "&#123;a&#61;2&#125;",
    expected = "&#123;a&#61;1&#125;",
  })
end

function tests:test_not_equals_deep_1_level_keys_diff_values_same()
  local testName = "test"
  test("equals_deep() négatif, 1 niveau, clés différentes, valeurs identiques", "equals_deep", testName, { b = 1 }, { a = 1 }, {
    testName = testName,
    success = false,
    actual = "&#123;b&#61;1&#125;",
    expected = "&#123;a&#61;1&#125;",
  })
end

function tests:test_not_equals_deep_2_levels()
  local testName = "test"
  test("equals_deep() négatif, 2 niveaux, valeurs différentes", "equals_deep", testName, { { 2 } }, { { 1 } }, {
    testName = testName,
    success = false,
    actual = "&#123;&#123;2&#125;&#125;",
    expected = "&#123;&#123;1&#125;&#125;",
  })
end

function tests:test_not_equals_deep_2_levels_keys()
  local testName = "test"
  test("equals_deep() négatif, 2 niveaux, clés différentes", "equals_deep", testName, { b = { a = 1 } }, { a = { b = 1 } }, {
    testName = testName,
    success = false,
    actual = "&#123;b&#61;&#123;a&#61;1&#125;&#125;",
    expected = "&#123;a&#61;&#123;b&#61;1&#125;&#125;",
  })
end

return tests
