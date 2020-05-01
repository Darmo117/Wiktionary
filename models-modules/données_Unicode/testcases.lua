local tests = require("Module:UnitTests")
local m_unicode = require("Module:données Unicode")

-- Tests --

function tests:test_get_block()
  self:equals("Bloc", m_unicode.get_block(0).name.en, "Basic Latin")
end

function tests:test_get_block_for_char()
  self:equals("Caractère", m_unicode.get_block_for_char("A").name.en, "Basic Latin")
end

function tests:test_get_script()
  self:equals("Script", m_unicode.get_script("Latin").code, "Latin")
end

function tests:test_get_script_for_char()
  self:equals("Caractère", m_unicode.get_script_for_char("A").code, "Latin")
end

function tests:test_get_script_for_unknown_char()
  self:equals("Caractère inconnu", m_unicode.get_script_for_char(mw.ustring.char(0x100000)).code, "Unknown")
end

function tests:test_get_script_for_text_one_script()
  self:equals("Un seul script", m_unicode.get_script_for_text("ABCDE").code, "Latin")
end

function tests:test_get_script_for_text_script_and_common()
  self:equals("Un script et Common", m_unicode.get_script_for_text("Texte principalement en Latin").code, "Latin")
end

function tests:test_get_script_for_text_inherited_majority()
  self:equals("Inherited majoritaire", m_unicode.get_script_for_text("T̀ ̀").code, "Latin")
end

function tests:test_get_script_for_text_only_common()
  self:equals("Common uniquement", m_unicode.get_script_for_text(" ").code, "Common")
end

function tests:test_get_script_for_text_only_inherited()
  self:equals("Inherited uniquement", m_unicode.get_script_for_text("̀").code, "Inherited")
end

function tests:test_get_script_for_text_only_common_and_inherited()
  self:equals("Inherited, Common majoritaire", m_unicode.get_script_for_text("̀ ").code, "Inherited")
end

function tests:test_get_script_for_text_script_and_unknown_char()
  self:equals("Script et caractère inconnu à la fin", m_unicode.get_script_for_text("A" .. mw.ustring.char(0x100000)).code, "Latin")
  self:equals("Script et caractère inconnu au début", m_unicode.get_script_for_text(mw.ustring.char(0x100000) .. "A").code, "Latin")
end

function tests:test_get_script_for_text_common_and_unknown_char()
  self:equals("Script et caractère inconnu", m_unicode.get_script_for_text(" " .. mw.ustring.char(0x100000)).code, "Unknown")
end

function tests:test_get_script_for_text_inherited_and_unknown_char()
  self:equals("Script et caractère inconnu", m_unicode.get_script_for_text("̀" .. mw.ustring.char(0x100000)).code, "Unknown")
end

function tests:test_get_script_for_text_several()
  self:equals("Plusieurs scripts", m_unicode.get_script_for_text("Texte en Latin et en ελληνικά").code, "Common")
end

-- Tests d’erreurs --

function tests:test_get_unknown_block()
  self:equals("Bloc invalide (négatif)", m_unicode.get_block(-1), nil)
  self:equals("Bloc invalide (trop grand)", m_unicode.get_block(0x1000000), nil)
end

function tests:test_get_block_for_invalid_char()
  self:expect_error("Chaine vide", m_unicode.get_block_for_char, { "" }, "Un seul caractère attendu, 0 donnés")
  self:expect_error("Trop de caractères", m_unicode.get_block_for_char, { "AA" }, "Un seul caractère attendu, 2 donnés")
end

function tests:test_get_unknown_script()
  self:equals("Script inconnu", m_unicode.get_script("script invalide"), nil)
end

function tests:test_get_script_for_invalid_char()
  self:expect_error("Chaine vide", m_unicode.get_script_for_char, { "" }, "Un seul caractère attendu, 0 donnés")
  self:expect_error("Trop de caractères", m_unicode.get_script_for_char, { "AA" }, "Un seul caractère attendu, 2 donnés")
end

return tests
