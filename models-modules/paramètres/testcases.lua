local tests = require("Module:UnitTests")
local m_params = require("Module:paramètres")

-- Fonctions utilitaires --

--- Fonction permettant de tester si la méthode
--- process retourne la bonne valeur pour les valeurs
--- données.
--- @param args table les arguments passés à la fonction process
--- @param p table les paramètres définis
--- @param expected_value table la valeur attendue
--- @param testName string le nom du test
local function test(self, args, p, expected_value, testName)
  self:equals_deep(testName or "", m_params.process(args, p), expected_value)
end

--- Fonction permettant de tester si la méthode
--- process lance une erreur pour les paramètres
--- donnés. Si ce n’est pas le cas, une erreur
--- est lancée et le test échoue. Elle teste aussi que
--- le mode silencieux retourne le bon argument.
--- @param args table les arguments passés à la fonction process
--- @param p table les paramètres définis
--- @param expected_error_message string le message d’erreur attendu
--- @param expected_param table|nil les valeurs attendues en mode silencieux ; passer nil désactive ce test
local function handle_error(self, testName, args, p, expected_error_message, expected_param)
  self:expect_error(testName, m_params.process, { args, p }, expected_error_message)

  if expected_param then
    local result, success = m_params.process(args, p, true)
    table.insert(expected_param, expected_error_message)
    self:equals_deep(
        "''(Test d’erreur silencieuse)'' Paramètre erroné « " .. expected_param[1] .. " »",
        { result, success },
        { expected_param, false }
    )
  end
end

-- Tests --

function tests:test_empty_value()
  local p = {
    [1] = {},
  }
  local args = {
    [1] = ""
  }
  local e = {
    [1] = nil
  }

  test(self, args, p, e, 'Arg = ""')
end

function tests:test_whitespace_only_value()
  local p = {
    [1] = {},
  }
  local args = {
    [1] = " "
  }
  local e = {
    [1] = nil
  }

  test(self, args, p, e, 'Arg = " "')
end

function tests:test_no_arg()
  local p = {
    [1] = {},
  }
  local args = {}
  local e = {}

  test(self, args, p, e, "Argument absent")
end

function tests:test_alias()
  local p = {
    [1] = {},
    ["lang"] = { alias_of = 1 }
  }
  local args = {
    ["lang"] = "test"
  }
  local e = {
    [1] = "test"
  }

  test(self, args, p, e, "Alias défini uniquement")
end

function tests:test_alias_to_required()
  local p = {
    [1] = { required = true },
    ["test"] = { alias_of = 1 }
  }
  local args = {
    ["test"] = "valeur"
  }
  local e = {
    [1] = "valeur"
  }

  test(self, args, p, e, "Alias vers requis, alias renseigné")
end

function tests:test_alias_no_override()
  local p = {
    [1] = {},
    ["lang"] = { alias_of = 1 }
  }
  local args = {
    [1] = "test",
    ["lang"] = "test2"
  }
  local e = {
    [1] = "test"
  }

  test(self, args, p, e, "Alias et argument de base définis")
end

function tests:test_default()
  local p = {
    [1] = { default = "test" }
  }
  local args = {}
  local e = {
    [1] = "test"
  }

  test(self, args, p, e, "Valeur par défaut")
end

function tests:test_required_on_alias_no_arg()
  local p = {
    [1] = { },
    ["test"] = { required = true, alias_of = 1 }
  }
  local args = {}
  local e = {}

  test(self, args, p, e, "Requis et alias, arg de base manquant")
end

function tests:test_type()
  local cases = {
    ["number"] = {
      { [1] = { type = m_params.NUMBER } },
      { [1] = "42" },
      { [1] = 42 }
    },
    ["number"] = {
      { [1] = { type = m_params.NUMBER } },
      { [1] = "42.5" },
      { [1] = 42.5 }
    },
    ["number"] = {
      { [1] = { type = m_params.NUMBER } },
      { [1] = "0x1" },
      { [1] = 1 }
    },
    ["int"] = {
      { [1] = { type = m_params.INT } },
      { [1] = "42" },
      { [1] = 42 }
    },
    ["int"] = {
      { [1] = { type = m_params.INT } },
      { [1] = "0x1" },
      { [1] = 1 }
    },
    ["float"] = {
      { [1] = { type = m_params.FLOAT } },
      { [1] = "42.5" },
      { [1] = 42.5 }
    },
    ["float"] = {
      { [1] = { type = m_params.FLOAT } },
      { [1] = "42" },
      { [1] = 42 }
    },
    ["float"] = {
      { [1] = { type = m_params.FLOAT } },
      { [1] = "0x1" },
      { [1] = 1 }
    },
    ["boolean « 1 »"] = {
      { [1] = { type = m_params.BOOLEAN } },
      { [1] = "1" },
      { [1] = true }
    },
    ["boolean « oui »"] = {
      { [1] = { type = m_params.BOOLEAN } },
      { [1] = "oui" },
      { [1] = true }
    },
    ["boolean « vrai »"] = {
      { [1] = { type = m_params.BOOLEAN } },
      { [1] = "vrai" },
      { [1] = true }
    },
    ["boolean « 0 »"] = {
      { [1] = { type = m_params.BOOLEAN } },
      { [1] = "0" },
      { [1] = false }
    },
    ["boolean « non »"] = {
      { [1] = { type = m_params.BOOLEAN } },
      { [1] = "non" },
      { [1] = false }
    },
    ["boolean « faux »"] = {
      { [1] = { type = m_params.BOOLEAN } },
      { [1] = "faux" },
      { [1] = false }
    },
    ["string (type = nil)"] = {
      { [1] = { type = nil } },
      { [1] = "test" },
      { [1] = "test" }
    },
    ["string (type absent)"] = {
      { [1] = {} },
      { [1] = "test" },
      { [1] = "test" }
    }
  }

  for test_name, case in pairs(cases) do
    local p, args, e = case[1], case[2], case[3]
    test(self, args, p, e, test_name)
  end
end

function tests:test_required_allow_empty()
  local p = {
    [1] = { required = true, allow_empty = true }
  }
  local args = {}
  local e = {}

  local result, _ = m_params.process(args, p)
  self:equals_deep("Requis et allow_empty, arg de base manquant", result, e)
  test(self, args, p, e, "Requis et allow_empty, arg de base manquant")
end

function tests:test_list_positional()
  tests:ignore()
  local p = {
    [1] = { list = true }
  }
  local args = {
    [1] = "test1",
    [2] = "test2"
  }
  local e = {
    [1] = { "test1", "test2" }
  }

  test(self, args, p, e, "Liste positionnelle")
end

function tests:test_list_named()
  tests:ignore()
  local p = {
    ["e"] = { list = true }
  }
  local args = {
    ["e1"] = "test1",
    ["e2"] = "test2"
  }
  local e = {
    ["e"] = { "test1", "test2" }
  }

  test(self, args, p, e, "Liste nommée")
end

function tests:test_list_positional_max_length()
  tests:ignore()
  local p = {
    [1] = { list = true, max_length = 3 }
  }
  local args = {
    [1] = "test1",
    [2] = "test2"
  }
  local e = {
    [1] = { "test1", "test2" }
  }

  test(self, args, p, e, "Liste positionnelle")
end

function tests:test_list_named()
  tests:ignore()
  local p = {
    ["e"] = { list = true, max_length = 3 }
  }
  local args = {
    ["e1"] = "test1",
    ["e2"] = "test2"
  }
  local e = {
    ["e"] = { "test1", "test2" }
  }

  test(self, args, p, e, "Liste nommée")
end

function tests:test_list_positional_last()
  tests:ignore()
  local p = {
    [1] = { list = true },
    [-1] = { required = true }
  }
  local args = {
    [1] = "test1",
    [2] = "test2"
  }
  local e = {
    [1] = { "test1", "test2" }
  }

  test(self, args, p, e, "Liste positionnelle, dernier élément")
end

function tests:test_list_positional_last_is_alias()
  tests:ignore()
  local p = {
    [1] = { list = true },
    [-1] = { alias_of = "lang" },
    ["lang"] = { required = true }
  }
  local args = {
    [1] = "test1",
    [2] = "test2",
    [3] = "fr"
  }
  local e = {
    [1] = { "test1", "test2" },
    ["lang"] = "fr"
  }

  test(self, args, p, e, "Liste positionnelle, dernier élément est un alias")
end

function tests:test_list_positional_last_is_alias2()
  tests:ignore()
  local p = {
    [1] = { list = true },
    [-1] = { alias_of = "lang" },
    ["lang"] = { required = true }
  }
  local args = {
    [1] = "test1",
    [2] = "test2",
    ["lang"] = "fr"
  }
  local e = {
    [1] = { "test1", "test2" },
    ["lang"] = "fr"
  }

  test(self, args, p, e, "Liste positionnelle, dernier élément est un alias")
end

function tests:test_list_named_last()
  tests:ignore()
  local p = {
    ["e"] = { list = true },
    ["e-1"] = { required = true }
  }
  local args = {
    ["e1"] = "test1",
    ["e2"] = "test2"
  }
  local e = {
    ["e"] = { "test1", "test2" }
  }

  test(self, args, p, e, "Liste nommée, dernier élément")
end

function tests:test_list_named_last_is_alias()
  tests:ignore()
  local p = {
    ["e"] = { list = true },
    ["e-1"] = { alias_of = "lang" },
    ["lang"] = { required = true }
  }
  local args = {
    ["e1"] = "test1",
    ["e2"] = "test2",
    ["e3"] = "fr"
  }
  local e = {
    ["e"] = { "test1", "test2" },
    ["lang"] = "fr"
  }

  test(self, args, p, e, "Liste nommée, dernier élément est un alias")
end

function tests:test_list_named_last_is_alias2()
  tests:ignore()
  local p = {
    ["e"] = { list = true },
    ["e-1"] = { alias_of = "lang" },
    ["lang"] = { required = true }
  }
  local args = {
    ["e1"] = "test1",
    ["e2"] = "test2",
    ["lang"] = "fr"
  }
  local e = {
    ["e"] = { "test1", "test2" },
    ["lang"] = "fr"
  }

  test(self, args, p, e, "Liste nommée, dernier élément est un alias")
end

function tests:test_list_positional_start_not_1()
  tests:ignore()
  local p = {
    [1] = {},
    [2] = { list = true }
  }
  local args = {
    [1] = "test1",
    [2] = "test2",
    [3] = "test3"
  }
  local e = {
    [1] = "test1",
    [2] = { "test2", "test3" }
  }

  test(self, args, p, e, "Liste positionnelle, indice début > 1")
end

function tests:test_enum()
  local p = {
    [1] = { enum = { "a", "b" } }
  }
  local args = {
    [1] = "a"
  }
  local e = {
    [1] = "a"
  }

  test(self, args, p, e, "Énumération")
end

function tests:test_enum_number()
  local p = {
    [1] = { enum = { 1, 2 }, type = m_params.NUMBER }
  }
  local args = {
    [1] = "1"
  }
  local e = {
    [1] = 1
  }

  test(self, args, p, e, "Énumération de nombres")
end

function tests:test_checker_string()
  local p = {
    [1] = { checker = function(s)
      return s == "a"
    end }
  }
  local args = {
    [1] = "a"
  }
  local e = {
    [1] = "a"
  }

  test(self, args, p, e, "Prédicat sur chaine")
end

function tests:test_checker_number()
  local p = {
    [1] = { type = m_params.NUMBER, checker = function(n)
      return 0 <= n and n < 10
    end }
  }
  local args = {
    [1] = 0
  }
  local e = {
    [1] = 0
  }

  test(self, args, p, e, "Prédicat sur nombre")
end

function tests:test_checker_no_value()
  local p = {
    [1] = { checker = function(s)
      return s == "a"
    end }
  }
  local args = {
  }
  local e = {
  }

  test(self, args, p, e, "Prédicat sur paramètre non renseigné")
end

-- Tests d’erreurs --

function tests:test_missing_required()
  local p = {
    [1] = { required = true }
  }
  local args = {}

  handle_error(self, "Paramètre requis manquant", args, p, "Paramètre requis « 1 » absent", { 1, m_params.MISSING_PARAM })
end

function tests:test_required_empty()
  local p = {
    [1] = { required = true }
  }
  local args = {
    [1] = ""
  }

  handle_error(self, "Paramètre requis vide", args, p, "Paramètre requis « 1 » vide", { 1, m_params.EMPTY_PARAM })
end

function tests:test_unknown()
  local p = {
    [1] = {}
  }
  local args = {
    [2] = "test"
  }

  handle_error(self, "Paramètre inconnu", args, p, "Paramètre « 2 » inconnu", { 2, m_params.UNKNOWN_PARAM })
end

function tests:test_invalid_type_number()
  local p = {
    [1] = { type = m_params.NUMBER }
  }
  local args = {
    [1] = "test"
  }

  handle_error(self, "Type invalide, nombre", args, p, 'Valeur invalide pour le paramètre « 1 » ("test") de type nombre', { 1, m_params.INVALID_VALUE })
end

function tests:test_invalid_type_int()
  local p = {
    [1] = { type = m_params.INT }
  }
  local args = {
    [1] = "42.5"
  }

  handle_error(self, "Type invalide, entier", args, p, 'Valeur invalide pour le paramètre « 1 » ("42.5") de type entier', { 1, m_params.INVALID_VALUE })
end

function tests:test_invalid_type_float()
  local p = {
    [1] = { type = m_params.FLOAT }
  }
  local args = {
    [1] = "test"
  }

  handle_error(self, "Type invalide, flottant", args, p, 'Valeur invalide pour le paramètre « 1 » ("test") de type flottant', { 1, m_params.INVALID_VALUE })
end

function tests:test_invalid_type_boolean()
  local p = {
    [1] = { type = m_params.BOOLEAN }
  }
  local args = {
    [1] = "test"
  }

  handle_error(self, "Type invalide, booléen", args, p, 'Valeur invalide pour le paramètre « 1 » ("test") de type booléen', { 1, m_params.INVALID_VALUE })
end

function tests:test_checker_string_invalid()
  local p = {
    [1] = { checker = function(s)
      return s == "a"
    end }
  }
  local args = {
    [1] = "b"
  }

  handle_error(self, "Checker, valeur invalide, chaine", args, p, 'Valeur invalide pour le paramètre « 1 » ("b") de type chaine', { 1, m_params.INVALID_VALUE })
end

function tests:test_checker_number_invalid()
  local p = {
    [1] = { type = m_params.NUMBER, checker = function(n)
      return 0 <= n and n < 10
    end }
  }
  local args = {
    [1] = -1
  }

  handle_error(self, "Checker, valeur invalide, nombre", args, p, 'Valeur invalide pour le paramètre « 1 » ("-1") de type nombre', { 1, m_params.INVALID_VALUE })
end

function tests:test_list_positional_last_missing()
  tests:ignore()
  local p = {
    [1] = { list = true },
    [-1] = { required = true }
  }
  local args = {}

  handle_error(self, "Liste positionnelle, dernier requis manquant", args, p, 'Paramètre requis « -1 » absent', { -1, m_params.MISSING_PARAM })
end

function tests:test_list_named_last_missing()
  tests:ignore()
  local p = {
    ["e"] = { list = true },
    ["e-1"] = { required = true }
  }
  local args = {}

  handle_error(self, "Liste nommée, dernier requis manquant", args, p, 'Paramètre requis « e-1 » absent', { "e-1", m_params.MISSING_PARAM })
end

function tests:test_list_positional_max_length_exceeded()
  tests:ignore()
  local p = {
    [1] = { list = true, max_length = 3 }
  }
  local args = {
    [1] = "test1",
    [2] = "test2",
    [3] = "test3",
    [4] = "test4",
  }

  handle_error(self, "Liste positionnelle, taille max dépassée", args, p, 'Taille de la liste « 1 » dépassée (4 > 3)', { "1", m_params.LIST_SIZE_EXCEEDED })
end

function tests:test_list_named_max_length_exceeded()
  tests:ignore()
  local p = {
    ["e"] = { list = true, max_length = 3 }
  }
  local args = {
    ["e1"] = "test1",
    ["e2"] = "test2",
    ["e3"] = "test3",
    ["e4"] = "test4",
  }

  handle_error(self, "Liste nommée, taille max dépassée", args, p, 'Taille de la liste « e » dépassée (4 > 3)', { "e", m_params.LIST_SIZE_EXCEEDED })
end

function tests:test_list_positional_duplicates()
  tests:ignore()
  local p = {
    [1] = { list = true, no_duplicates = true }
  }
  local args = {
    [1] = "test1",
    [2] = "test1",
  }

  handle_error(self, "Liste positionnelle, pas de doublons", args, p, 'Valeur en double dans la liste « 1 »', { "e", m_params.DUPLICATE_VALUE })
end

function tests:test_list_named_duplicates()
  tests:ignore()
  local p = {
    ["e"] = { list = true, no_duplicates = true }
  }
  local args = {
    ["e1"] = "test1",
    ["e2"] = "test1",
  }

  handle_error(self, "Liste nommée, pas de doublons", args, p, 'Valeur en double dans la liste « e »', { "e", m_params.DUPLICATE_VALUE })
end

function tests:test_enum_invalid_value()
  local p = {
    [1] = { enum = { "a", "b" } }
  }
  local args = {
    [1] = "c"
  }

  handle_error(self, "Énumération, valeur invalide", args, p, 'Valeur invalide pour le paramètre « 1 » ("c")', { 1, m_params.VALUE_NOT_IN_ENUM })
end

function tests:test_enum_invalid_type_number()
  local p = {
    [1] = { enum = { 1, 2 }, type = m_params.NUMBER }
  }
  local args = {
    [1] = "a"
  }

  handle_error(self, "Énumération, valeur invalide, nombre", args, p, 'Valeur invalide pour le paramètre « 1 » ("a") de type nombre', { 1, m_params.INVALID_VALUE })
end

--
-- Erreurs internes
--

function tests:test_list_positional_arg_overlap()
  tests:ignore()
  local p = {
    [1] = { list = true },
    [2] = {}
  }
  local args = {
    [1] = "test1"
  }

  handle_error(self, "Conflit paramètre et liste positionnelle", args, p, "Erreur interne : Paramètre « 2 » déjà défini par la liste « 1 »", { "e1", m_params.LIST_PARAM_OVERLAP })
end

function tests:test_list_named_arg_overlap()
  tests:ignore()
  local p = {
    ["e"] = { list = true },
    ["e1"] = {}
  }
  local args = {
    ["e1"] = "test1"
  }

  handle_error(self, "Conflit paramètre et liste nommée", args, p, "Erreur interne : Paramètre « e1 » déjà défini par la liste « e »", { "e1", m_params.LIST_PARAM_OVERLAP })
end

function tests:test_unknown_type()
  local p = {
    [1] = { type = "test" }
  }
  local args = {
    [1] = "test"
  }

  handle_error(self, "Type inconnu", args, p, 'Erreur interne : Type inconnu pour le paramètre « 1 » ("test")')
  handle_error(self, "Type inconnu, pas args", {}, p, 'Erreur interne : Type inconnu pour le paramètre « 1 » ("test")')
end

function tests:test_alias_to_nonexistant()
  local p = {
    [1] = { alias_of = 2 }
  }
  local args = {
    [1] = "test"
  }

  handle_error(self, "Alias vers non défini", args, p, "Erreur interne : Paramètre « 1 », alias vers un paramètre non défini « 2 »")
  handle_error(self, "Alias vers non défini, pas args", {}, p, "Erreur interne : Paramètre « 1 », alias vers un paramètre non défini « 2 »")
end

function tests:test_alias_to_alias()
  local p = {
    [1] = {},
    [2] = { alias_of = 1 },
    [3] = { alias_of = 2 }
  }
  local args = {
    [1] = "test"
  }

  handle_error(self, "Alias vers alias", args, p, "Erreur interne : Paramètre « 3 », alias vers un autre alias (« 2 »)")
  handle_error(self, "Alias vers alias, pas args", {}, p, "Erreur interne : Paramètre « 3 », alias vers un autre alias (« 2 »)")
end

function tests:test_alias_to_itself()
  local p = {
    [1] = { alias_of = 1 }
  }
  local args = {
    [1] = "test"
  }

  handle_error(self, "Alias vers lui-même", args, p, "Erreur interne : Paramètre « 1 », alias vers lui-même")
  handle_error(self, "Alias vers lui-même, pas args", {}, p, "Erreur interne : Paramètre « 1 », alias vers lui-même")
end

function tests:test_enum_and_checker()
  local p = {
    [1] = { enum = { "a", "b" }, checker = function(_)
      return true
    end }
  }
  local args = {
    [1] = "a"
  }

  handle_error(self, "Énumération et checker", args, p, "Erreur interne : Le paramètre « 1 » est une énumération avec une précondition")
  handle_error(self, "Énumération et checker, pas args", {}, p, "Erreur interne : Le paramètre « 1 » est une énumération avec une précondition")
end

function tests:test_enum_invalid_values()
  local p = {
    [1] = { enum = { 1, 2 } }
  }
  local args = {
    [1] = "a"
  }

  handle_error(self, "Énumération, valeur invalide", args, p, 'Erreur interne : Valeur énumérée invalide pour le paramètre « 1 » ("1") de type chaine')
end

function tests:test_enum_invalid_values_number()
  local p = {
    [1] = { enum = { "a", "b" }, type = m_params.NUMBER }
  }
  local args = {
    [1] = "1"
  }

  handle_error(self, "Énumération, valeur invalide, nombre", args, p, 'Erreur interne : Valeur énumérée invalide pour le paramètre « 1 » ("a") de type nombre')
end

function tests:test_enum_invalid_values_int()
  local p = {
    [1] = { enum = { "a", "b" }, type = m_params.INT }
  }
  local args = {
    [1] = "1"
  }

  handle_error(self, "Énumération, valeur invalide, entier", args, p, 'Erreur interne : Valeur énumérée invalide pour le paramètre « 1 » ("a") de type entier')
end

function tests:test_enum_invalid_values_float()
  local p = {
    [1] = { enum = { "a", "b" }, type = m_params.FLOAT }
  }
  local args = {
    [1] = "1.0"
  }

  handle_error(self, "Énumération, valeur invalide, flottant", args, p, 'Erreur interne : Valeur énumérée invalide pour le paramètre « 1 » ("a") de type flottant')
end

function tests:test_enum_invalid_values_boolean()
  local p = {
    [1] = { enum = { "a", "b" }, type = m_params.BOOLEAN }
  }
  local args = {
    [1] = "vrai"
  }

  handle_error(self, "Énumération, valeur invalide, booléen", args, p, 'Erreur interne : Valeur énumérée invalide pour le paramètre « 1 » ("a") de type booléen')
end

return tests
