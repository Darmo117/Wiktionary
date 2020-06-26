local tests = require("Module:UnitTests")
local m_unicode = require("Module:données Unicode")

-- Tests --

function tests:testGetBlock()
  self:equals("Bloc", m_unicode.getBlock(0).name.en, "Basic Latin")
end

function tests:testGetBlockForChar()
  self:equals("Caractère", m_unicode.getBlockForChar("A").name.en, "Basic Latin")
end

function tests:testGetScript()
  self:equals("Script", m_unicode.getScript("Latin").code, "Latin")
end

function tests:testGetScriptForChar()
  self:equals("Caractère", m_unicode.getScriptForChar("A").code, "Latin")
end

function tests:testGetScriptForUnknownChar()
  self:equals("Caractère inconnu", m_unicode.getScriptForChar(mw.ustring.char(0x100000)).code, "Unknown")
end

function tests:testGetScriptForTextOneScript()
  self:equals("Un seul script", m_unicode.getScriptForText("ABCDE").code, "Latin")
end

function tests:testGetScriptForTextScriptAndCommon()
  self:equals("Un script et Common", m_unicode.getScriptForText("Texte principalement en Latin").code, "Latin")
end

function tests:testGetScriptForTextInheritedMajority()
  self:equals("Inherited majoritaire", m_unicode.getScriptForText("T̀ ̀").code, "Latin")
end

function tests:testGetScriptForTextOnlyCommon()
  self:equals("Common uniquement", m_unicode.getScriptForText(" ").code, "Common")
end

function tests:testGetScriptForTextOnlyInherited()
  self:equals("Inherited uniquement", m_unicode.getScriptForText("̀").code, "Inherited")
end

function tests:testGetScriptForTextOnlyCommonAndInherited()
  self:equals("Inherited, Common majoritaire", m_unicode.getScriptForText("̀ ").code, "Inherited")
end

function tests:testGetScriptForTextScriptAndUnknownChar()
  self:equals("Script et caractère inconnu à la fin", m_unicode.getScriptForText("A" .. mw.ustring.char(0x100000)).code, "Latin")
  self:equals("Script et caractère inconnu au début", m_unicode.getScriptForText(mw.ustring.char(0x100000) .. "A").code, "Latin")
end

function tests:testGetScriptForText_commonAndUnknownChar()
  self:equals("Script et caractère inconnu", m_unicode.getScriptForText(" " .. mw.ustring.char(0x100000)).code, "Unknown")
end

function tests:testGetScriptForTextInheritedAndUnknownChar()
  self:equals("Script et caractère inconnu", m_unicode.getScriptForText("̀" .. mw.ustring.char(0x100000)).code, "Unknown")
end

function tests:testGetScriptForTextSeveral()
  self:equals("Plusieurs scripts", m_unicode.getScriptForText("Texte en Latin et en ελληνικά").code, "Common")
end

-- Error tests --

function tests:testGetUnknownBlock()
  self:equals("Bloc invalide (négatif)", m_unicode.getBlock(-1), nil)
  self:equals("Bloc invalide (trop grand)", m_unicode.getBlock(0x1000000), nil)
end

function tests:testGetBlockForInvalidChar()
  self:expect_error("Chaine vide", m_unicode.getBlockForChar, { "" }, 'Un seul caractère attendu, 0 donnés ("")')
  self:expect_error("Trop de caractères", m_unicode.getBlockForChar, { "AA" }, 'Un seul caractère attendu, 2 donnés ("AA")')
end

function tests:testGetUnknownScript()
  self:equals("Script inconnu", m_unicode.getScript("script invalide"), nil)
end

function tests:testGetScriptForInvalidChar()
  self:expect_error("Chaine vide", m_unicode.getScriptForChar, { "" }, "Un seul caractère attendu, 0 donnés")
  self:expect_error("Trop de caractères", m_unicode.getScriptForChar, { "AA" }, "Un seul caractère attendu, 2 donnés")
end

return tests
