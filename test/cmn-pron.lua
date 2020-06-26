local export = {}

local find = mw.ustring.find
local gsub = mw.ustring.gsub
local len = mw.ustring.len
local match = mw.ustring.match
local split = mw.text.split

local m_zh = require("Module:zh")
local _m_zh_data

-- if not empty
local function ine(var)
  if var == "" then
    return nil
  else
    return var
  end
end

local breve, hacek = mw.ustring.char(0x306), mw.ustring.char(0x30C)
local decompose = mw.ustring.toNFD
local function breve_error(text)
  if type(text) ~= "string" then
    return
  end
  text = decompose(text)
  if text:find(breve) then
    error('The pinyin text "' .. text .. '" contains a breve. Replace it with "' .. text:gsub(breve, hacek) .. '".', 2)
  end
end

local function m_zh_data()
  if _m_zh_data == nil then _m_zh_data = mw.loadData("Module:zh/data/cmn-tag") end;
  return _m_zh_data;
end

local py_detone = {
  ['ā'] = 'a', ['á'] = 'a', ['ǎ'] = 'a', ['à'] = 'a',
  ['ō'] = 'o', ['ó'] = 'o', ['ǒ'] = 'o', ['ò'] = 'o',
  ['ē'] = 'e', ['é'] = 'e', ['ě'] = 'e', ['è'] = 'e',
  ['ê̄'] = 'ê', ['ế'] = 'ê', ['ê̌'] = 'ê', ['ề'] = 'ê',
  ['ī'] = 'i', ['í'] = 'i', ['ǐ'] = 'i', ['ì'] = 'i',
  ['ū'] = 'u', ['ú'] = 'u', ['ǔ'] = 'u', ['ù'] = 'u',
  ['ǖ'] = 'ü', ['ǘ'] = 'ü', ['ǚ'] = 'ü', ['ǜ'] = 'ü',
  ['m̄'] = 'm', ['ḿ'] = 'm', ['m̌'] = 'm', ['m̀'] = 'm',
  ['n̄'] = 'n', ['ń'] = 'n', ['ň'] = 'n', ['ǹ'] = 'n',
}

local py_tone = {
  ['̄'] = '1',
  ['́'] = '2',
  ['̌'] = '3',
  ['̀'] = '4'
}

function export.py_transform(text, detone, not_spaced)
  if type(text) == 'table' then text, detone, not_spaced = text.args[1], text.args[2], text.args[3] end
  if find(text, '​') then
    error("Pinyin contains the hidden character: ​ (U+200B). Please remove that character from the text.")
  end
  detone = ine(detone)
  not_spaced = ine(not_spaced)
  text = gsub(gsub(mw.ustring.toNFD(text), mw.ustring.toNFD('ê'), 'ê'), mw.ustring.toNFD('ü'), 'ü')
  local tones = '[̄́̌̀]'
  if find(mw.ustring.lower(text), '[aeiouêü]' .. tones .. '[aeiou]?[aeiouêü]' .. tones .. '') and not not_spaced then
    error(("Missing apostrophe before null-initial syllable - should be \"%s\" instead."):format(gsub(text, '([aeiouêü]' .. tones .. '[aeiou]?)([aeiouêü]' .. tones .. ')', "%1'%2"))) end
  text = mw.ustring.lower(text)
  if not mw.ustring.find(text, tones) and text:find('[1-5]') then
    return gsub(text, '(%d)(%l)', '%1 %2')
  end
  if find(text, '[一不,.?]') then
    text = gsub(text, '([一不])$', {['一'] = ' yī', ['不'] = ' bù'})
    text = gsub(text, '([一不])', ' %1 ')
    text = gsub(text, '([,.?])', ' %1 ')
    text = gsub(text, ' +', ' ')
    text = gsub(text, '^ ', '')
    text = gsub(text, ' $', '')
    text = gsub(text, '%. %. %.', '...')
  end
  text = gsub(text, "['’%-]", ' ')
  text = gsub(text, '([aeiouêü]' .. tones .. '?n?g?r?)([bpmfdtnlgkhjqxzcsywr]h?)', '%1 %2')
  text = gsub(text, ' ([grn])$', '%1')
  text = gsub(text, ' ([grn]) ', '%1 ')
  if detone then
    text = mw.ustring.gsub(text, tones, py_tone)
    text = gsub(text, '([1234])([^ ]*)', '%2%1')
    text = mw.ustring.gsub(text, '([%lüê]) ', '%15 ')
    text = mw.ustring.gsub(text, '([%lüê])$', '%15')
  end
  if not_spaced then
    text = gsub(text, ' ', '')
  end
  return mw.ustring.toNFC(text)
end

function export.py_ipa(text)
  local ipa_initial = {
    ['b'] = 'p', ['p'] = 'pʰ', ['m'] = 'm', ['f'] = 'f',
    ['d'] = 't', ['t'] = 'tʰ', ['n'] = 'n', ['l'] = 'l',
    ['g'] = 'k', ['k'] = 'kʰ', ['h'] = 'x', ['ng'] = 'ŋ',
    ['j'] = 't͡ɕ', ['q'] = 't͡ɕʰ', ['x'] = 'ɕ',
    ['z'] = 't͡s', ['c'] = 't͡sʰ', ['s'] = 's', ['r'] = 'ʐ',
    ['zh'] = 'ʈ͡ʂ', ['ch'] = 'ʈ͡ʂʰ', ['sh'] = 'ʂ',
    [''] = ''
  }

  local ipa_initial_tl = {
    ['p'] = 'b̥', ['t'] = 'd̥', ['k'] = 'g̊', ['t͡ɕ'] = 'd͡ʑ̥', ['t͡s'] = 'd͡z̥', ['ʈ͡ʂ'] = 'ɖ͡ʐ̥'
  }

  local ipa_final = {
    ['yuanr'] = 'ɥɑɻ', ['iangr'] = 'jɑ̃ɻ', ['yangr'] = 'jɑ̃ɻ', ['uangr'] = 'wɑ̃ɻ', ['wangr'] = 'wɑ̃ɻ', ['yingr'] = 'jɤ̃ɻ', ['wengr'] = 'ʊ̃ɻ', ['iongr'] = 'jʊ̃ɻ', ['yongr'] = 'jʊ̃ɻ',
    ['yuan'] = 'y̯ɛn', ['iang'] = 'i̯ɑŋ', ['yang'] = 'i̯ɑŋ', ['uang'] = 'u̯ɑŋ', ['wang'] = 'u̯ɑŋ', ['ying'] = 'iŋ', ['weng'] = 'u̯əŋ', ['iong'] = 'i̯ʊŋ', ['yong'] = 'i̯ʊŋ', ['ianr'] = 'jɑɻ', ['yanr'] = 'jɑɻ', ['uair'] = 'wɑɻ', ['wair'] = 'wɑɻ', ['uanr'] = 'wɑɻ', ['wanr'] = 'wɑɻ', ['iaor'] = 'jaʊɻʷ', ['yaor'] = 'jaʊɻʷ', ['üanr'] = 'ɥɑɻ', ['vanr'] = 'ɥɑɻ', ['angr'] = 'ɑ̃ɻ', ['yuer'] = 'ɥɛɻ', ['weir'] = 'wəɻ', ['wenr'] = 'wəɻ', ['your'] = 'jɤʊɻʷ', ['yinr'] = 'jəɻ', ['yunr'] = 'ɥəɻ', ['engr'] = 'ɤ̃ɻ', ['ingr'] = 'jɤ̃ɻ', ['ongr'] = 'ʊ̃ɻ',
    ['uai'] = 'u̯aɪ̯', ['wai'] = 'u̯aɪ̯', ['yai'] = 'i̯aɪ̯', ['iao'] = 'i̯ɑʊ̯', ['yao'] = 'i̯ɑʊ̯', ['ian'] = 'i̯ɛn', ['yan'] = 'i̯ɛn', ['uan'] = 'u̯a̠n', ['wan'] = 'u̯a̠n', ['üan'] = 'y̯ɛn', ['van'] = 'y̯ɛn', ['ang'] = 'ɑŋ', ['yue'] = 'y̯œ', ['wei'] = 'u̯eɪ̯', ['you'] = 'i̯oʊ̯', ['yin'] = 'in', ['wen'] = 'u̯ən', ['yun'] = 'yn', ['eng'] = 'ɤŋ', ['ing'] = 'iŋ', ['ong'] = 'ʊŋ', ['air'] = 'ɑɻ', ['anr'] = 'ɑɻ', ['iar'] = 'jɑɻ', ['yar'] = 'jɑɻ', ['uar'] = 'wɑɻ', ['war'] = 'wɑɻ', ['aor'] = 'aʊɻʷ', ['ier'] = 'jɛɻ', ['yer'] = 'jɛɻ', ['uor'] = 'wɔɻ', ['wor'] = 'wɔɻ', ['üer'] = 'ɥɛɻ', ['ver'] = 'ɥɛɻ', ['eir'] = 'əɻ', ['enr'] = 'əɻ', ['uir'] = 'wəɻ', ['unr'] = 'wəɻ', ['our'] = 'ɤʊɻʷ', ['iur'] = 'jɤʊɻ', ['inr'] = 'jəɻ', ['ünr'] = 'ɥəɻ', ['vnr'] = 'ɥəɻ', ['yir'] = 'jəɻ', ['wur'] = 'wuɻ', ['yur'] = 'ɥəɻ',
    ['yo'] = 'i̯ɔ', ['ia'] = 'i̯a̠', ['ya'] = 'i̯a̠', ['ua'] = 'u̯a̠', ['wa'] = 'u̯a̠', ['ai'] = 'aɪ̯', ['ao'] = 'ɑʊ̯', ['an'] = 'a̠n', ['ie'] = 'i̯ɛ', ['ye'] = 'i̯ɛ', ['uo'] = 'u̯ɔ', ['wo'] = 'u̯ɔ', ['ue'] = 'ɥ̯œ', ['üe'] = 'ɥ̯œ', ['ve'] = 'ɥ̯œ', ['ei'] = 'eɪ̯', ['ui'] = 'u̯eɪ̯', ['ou'] = 'oʊ̯', ['iu'] = 'i̯oʊ̯', ['en'] = 'ən', ['in'] = 'in', ['un'] = 'u̯ən', ['ün'] = 'yn', ['vn'] = 'yn', ['yi'] = 'i', ['wu'] = 'u', ['yu'] = 'y', ['mˋ'] = 'm̩', ['ng'] = 'ŋ̩', ['ňg'] = 'ŋ̩', ['ńg'] = 'ŋ̩', ['ê̄'] = 'ɛ', ['ê̌'] = 'ɛ', ['ar'] = 'ɑɻ', ['er'] = 'ɤɻ', ['or'] = 'wɔɻ', ['ir'] = 'iəɻ', ['ur'] = 'uɻ', ['ür'] = 'yəɻ', ['vr'] = 'yəɻ',
    ['a'] = 'a̠', ['e'] = 'ɤ', ['o'] = 'u̯ɔ', ['i'] = 'i', ['u'] = 'u', ['ü'] = 'y', ['v'] = 'y', ['m'] = 'm̩', ['ḿ'] = 'm̩', ['n'] = 'n̩', ['ń'] = 'n̩', ['ň'] = 'n̩', ['ê'] = 'ɛ'
  }

  local ipa_null = {
    ['a'] = true, ['o'] = true, ['e'] = true, ['ê'] = true,
    ['ai'] = true, ['ei'] = true, ['ao'] = true, ['ou'] = true,
    ['an'] = true, ['en'] = true, ['er'] = true,
    ['ang'] = true, ['ong'] = true, ['eng'] = true,
  }

  local ipa_tl_ts = {
    ['1'] = '˨', ['2'] = '˧', ['3'] = '˦', ['4'] = '˩', ['5'] = '˩'
  }

  local ipa_third_t_ts = {
    ['1'] = '˨˩', ['3'] = '˧˥', ['5'] = '˨˩˦', ['2'] = '˨˩', ['1-2'] = '˨˩', ['4-2'] = '˨˩', ['4'] = '˨˩', ['1-4'] = '˨˩'
  }

  local ipa_t_values = {
    ['4'] = '˥˩', ['1-4'] = '˥˩', ['1'] = '˥', ['2'] = '˧˥', ['1-2'] = '˧˥', ['4-2'] = '˧˥'
  }

  local tone = {}
  local tone_cat = {}
  text = gsub(export.py_transform(text), '[,.]', '')
  text = gsub(text, ' +', ' ')
  local p = split(text, " ")

  for i = 1, #p do
    tone_cat[i] = m_zh.tone_determ(p[i])
    p[i] = gsub(p[i], '.[̄́̌̀]?', py_detone)

    if p[i] == '一' then
      tone_cat[i] = (m_zh.tone_determ(p[i+1]) == '4' or p[i+1] == 'ge') and '1-2' or '1-4'
      p[i] = 'yi'
    elseif p[i] == '不' then
      tone_cat[i] = (m_zh.tone_determ(p[i+1]) == '4') and '4-2' or '4'
      p[i] = 'bu'
    end
  end

  tone_cat.length = #tone_cat

  for i, item in ipairs(p) do
    if ipa_null[item] then item = 'ˀ' .. item end
    item = gsub(item, '([jqx])u', '%1ü')

    if item == 'ng' then
      item = ipa_final['ng']
    else
      item = gsub(item, '^(ˀ?)([bcdfghjklmnpqrstxz]?h?)(.+)$',
          function(a, b, c) return a ..
              (ipa_initial[b] or error(("Unrecognised initial: \"%s\""):format(b))) ..
              (ipa_final[c] or error(("Unrecognised final: \"%s\". Are you missing an apostrophe before the null-initial syllable, or using an invalid Pinyin final?"):format(c))) end)
    end

    item = gsub(item, '(ʈ?͡?[ʂʐ]ʰ?)i', '%1ʐ̩')
    item = gsub(item, '(t?͡?sʰ?)i', '%1z̩')
    item = gsub(item, 'ˀu̯ɔ', 'ˀ̯ɔ')
    item = gsub(item, 'ʐʐ̩', 'ʐ̩')

    local curr_tone_cat, next_tone_cat = tone_cat[i], tone_cat[i+1]

    if curr_tone_cat == '5' then
      item = gsub(item, '^([ptk])([^͡ʰ])', function(a, b) return ipa_initial_tl[a] .. b end)
      item = gsub(item, '^([tʈ]͡[sɕʂ])([^ʰ])', function(a, b) return ipa_initial_tl[a] .. b end)
      item = gsub(item, 'ɤ$', 'ə')
      tone[i] = ipa_tl_ts[tone_cat[i-1]] or ""

    elseif curr_tone_cat == '3' then
      if i == tone_cat.length then
        if i == 1 then tone[i] = '˨˩˦' else tone[i] = '˨˩' end
      else
        tone[i] = ipa_third_t_ts[next_tone_cat]
      end

    elseif curr_tone_cat == '4' and next_tone_cat == '4' then
      tone[i] = '˥˧'

    elseif curr_tone_cat == '4' and next_tone_cat == '1-4' then
      tone[i] = '˥˧'

    elseif curr_tone_cat == '1-4' and next_tone_cat == '4' then
      tone[i] = '˥˧'

    else
      tone[i] = ipa_t_values[curr_tone_cat]
    end
    p[i] = item .. tone[i]
  end
  return table.concat(p, " ")
end

function export.py_number_to_mark(text)
  local priority = { "a", "o", "e", "ê", "i", "u", "ü" }
  local toneMark = { ["1"] = "̄", ["2"] = "́", ["3"] = "̌", ["4"] = "̀", ["5"] = "", ["0"] = "", [""] = "" }

  local mark = toneMark[match(text, "[0-5]?$")]
  local toneChars = "[̄́̌̀]"
  text = gsub(text, "[0-5]?$", "")

  for _, letter in ipairs(priority) do
    text = gsub(text, letter, letter .. mark)
    if find(text, toneChars) then break end
  end
  return mw.ustring.toNFC(gsub(text, "i("..toneChars..")u", "iu%1"))
end

function export.yale_number_to_mark(text)
  local priority = { "a", "o", "e", "ê", "i", "u", "ü", "r", "z" }
  local toneMark = { ["1"] = "̄", ["2"] = "́", ["3"] = "̌", ["4"] = "̀", ["5"] = "", ["0"] = "", [""] = "" }

  local mark = toneMark[match(text, "[0-5]?$")]
  local toneChars = "[̄́̌̀]"
  text = gsub(text, "[0-5]?$", "")

  for _, letter in ipairs(priority) do
    text = gsub(text, letter, letter .. mark)
    if find(text, toneChars) then break end
  end
  return mw.ustring.toNFC(gsub(text, "i("..toneChars..")u", "iu%1"))
end

function export.py_zhuyin(text)
  local zhuyin_initial = {
    ['b'] = 'ㄅ', ['p'] = 'ㄆ', ['m'] = 'ㄇ', ['f'] = 'ㄈ',
    ['d'] = 'ㄉ', ['t'] = 'ㄊ', ['n'] = 'ㄋ', ['l'] = 'ㄌ',
    ['g'] = 'ㄍ', ['k'] = 'ㄎ', ['h'] = 'ㄏ',
    ['j'] = 'ㄐ', ['q'] = 'ㄑ', ['x'] = 'ㄒ',
    ['z'] = 'ㄗ', ['c'] = 'ㄘ', ['s'] = 'ㄙ', ['r'] = 'ㄖ',
    ['zh'] = 'ㄓ', ['ch'] = 'ㄔ', ['sh'] = 'ㄕ',
    [''] = ''
  }

  local zhuyin_final = {
    ['yuan'] = 'ㄩㄢ', ['iang'] = 'ㄧㄤ', ['yang'] = 'ㄧㄤ', ['uang'] = 'ㄨㄤ', ['wang'] = 'ㄨㄤ', ['ying'] = 'ㄧㄥ', ['weng'] = 'ㄨㄥ', ['iong'] = 'ㄩㄥ', ['yong'] = 'ㄩㄥ',
    ['uai'] = 'ㄨㄞ', ['wai'] = 'ㄨㄞ', ['yai'] = 'ㄧㄞ', ['iao'] = 'ㄧㄠ', ['yao'] = 'ㄧㄠ', ['ian'] = 'ㄧㄢ', ['yan'] = 'ㄧㄢ', ['uan'] = 'ㄨㄢ', ['wan'] = 'ㄨㄢ', ['üan'] = 'ㄩㄢ', ['ang'] = 'ㄤ', ['yue'] = 'ㄩㄝ', ['wei'] = 'ㄨㄟ', ['you'] = 'ㄧㄡ', ['yin'] = 'ㄧㄣ', ['wen'] = 'ㄨㄣ', ['yun'] = 'ㄩㄣ', ['eng'] = 'ㄥ', ['ing'] = 'ㄧㄥ', ['ong'] = 'ㄨㄥ',
    ['yo'] = 'ㄧㄛ', ['ia'] = 'ㄧㄚ', ['ya'] = 'ㄧㄚ', ['ua'] = 'ㄨㄚ', ['wa'] = 'ㄨㄚ', ['ai'] = 'ㄞ', ['ao'] = 'ㄠ', ['an'] = 'ㄢ', ['ie'] = 'ㄧㄝ', ['ye'] = 'ㄧㄝ', ['uo'] = 'ㄨㄛ', ['wo'] = 'ㄨㄛ', ['ue'] = 'ㄩㄝ', ['üe'] = 'ㄩㄝ', ['ei'] = 'ㄟ', ['ui'] = 'ㄨㄟ', ['ou'] = 'ㄡ', ['iu'] = 'ㄧㄡ', ['en'] = 'ㄣ', ['in'] = 'ㄧㄣ', ['un'] = 'ㄨㄣ', ['ün'] = 'ㄩㄣ', ['yi'] = 'ㄧ', ['wu'] = 'ㄨ', ['yu'] = 'ㄩ',
    ['a'] = 'ㄚ', ['e'] = 'ㄜ', ['o'] = 'ㄛ', ['i'] = 'ㄧ', ['u'] = 'ㄨ', ['ü'] = 'ㄩ', ['ê'] = 'ㄝ', [''] = ''
  }

  local zhuyin_er = {
    ['r'] = 'ㄦ', [''] = ''
  }

  local zhuyin_tone = {
    ['1'] = '', ['2'] = 'ˊ', ['3'] = 'ˇ', ['4'] = 'ˋ', ['5'] = '˙', ['0'] = '˙'
  }

  if type(text) == 'table' then
    if text.args[1] == '' then
      text = mw.title.getCurrentTitle().text
      return ""
    else
      text = text.args[1]
    end
  end
  breve_error(text)
  text = export.py_transform(text, true)
  text = gsub(text, '([jqx])u', '%1ü')
  text = gsub(text, '([zcs]h?)i', '%1')
  text = gsub(text, '([r])i', '%1')
  local word = split(text, " ", true)
  for i, syllable in ipairs(word) do
    if find(syllable, '^[hn][mg][012345]$') then
      syllable = gsub(syllable, '^([hn][mg])([012345])$', function(a, b) return (({['ng'] = 'ㄫ', ['hm'] = 'ㄏㄇ'})[a] or a) .. zhuyin_tone[b] end)
    elseif find(syllable, '^hng[012345]$') then
      syllable = gsub(syllable, '^hng([012345])$', function(number) return 'ㄏㄫ' .. zhuyin_tone[number] end)
    elseif find(syllable, '^er[012345]$') then
      syllable = gsub(syllable, '^er([012345])$', function(number) return 'ㄦ' .. zhuyin_tone[number] end)
    else
      syllable = gsub(syllable, '^([bpmfdtnlgkhjqxzcsr]?h?)([aeiouêüyw]?[aeioun]?[aeioung]?[ng]?)(r?)([012345])$',
          function(a, b, c, d) return zhuyin_initial[a] .. zhuyin_final[b] .. zhuyin_tone[d] .. zhuyin_er[c] end)
    end
    if find(syllable, '[%l%d]') then
      error(("Zhuyin conversion unsuccessful: \"%s\". Are you using a valid Pinyin syllable? Is the text using a breve letter instead of a caron one?"):format(syllable))
    end
    word[i] = syllable
  end
  text = gsub(table.concat(word, " "), ' , ', ', ')
  return text
end

function export.zhuyin_py(text)
  local zhuyin_py_initial = {
    ["ㄅ"] = "b", ["ㄆ"] = "p", ["ㄇ"] = "m", ["ㄈ"] = "f",
    ["ㄉ"] = "d", ["ㄊ"] = "t", ["ㄋ"] = "n", ["ㄌ"] = "l",
    ["ㄍ"] = "g", ["ㄎ"] = "k", ["ㄏ"] = "h",
    ["ㄐ"] = "j", ["ㄑ"] = "q", ["ㄒ"] = "x",
    ["ㄓ"] = "zh", ["ㄔ"] = "ch", ["ㄕ"] = "sh", ["ㄖ"] = "r",
    ["ㄗ"] = "z", ["ㄘ"] = "c", ["ㄙ"] = "s",
    [""] = ""
  }

  local zhuyin_py_final = {
    ['ㄚ'] = 'a', ['ㄛ'] = 'o', ['ㄜ'] = 'e', ['ㄝ'] = 'ê', ['ㄞ'] = 'ai', ['ㄟ'] = 'ei', ['ㄠ'] = 'ao', ['ㄡ'] = 'ou', ['ㄢ'] = 'an', ['ㄣ'] = 'en', ['ㄤ'] = 'ang', ['ㄥ'] = 'eng',
    ['ㄧ'] = 'i', ['ㄧㄚ'] = 'ia', ['ㄧㄛ'] = 'io', ['ㄧㄝ'] = 'ie', ['ㄧㄞ'] = 'iai', ['ㄧㄠ'] = 'iao', ['ㄧㄡ'] = 'iu', ['ㄧㄢ'] = 'ian', ['ㄧㄣ'] = 'in', ['ㄧㄤ'] = 'iang', ['ㄧㄥ'] = 'ing',
    ['ㄨ'] = 'u', ['ㄨㄚ'] = 'ua', ['ㄨㄛ'] = 'uo', ['ㄨㄞ'] = 'uai', ['ㄨㄟ'] = 'ui', ['ㄨㄢ'] = 'uan', ['ㄨㄣ'] = 'un', ['ㄨㄤ'] = 'uang', ['ㄨㄥ'] = 'ong',
    ['ㄩ'] = 'ü', ['ㄩㄝ'] = 'ue', ['ㄩㄝ'] = 'üe', ['ㄩㄢ'] = 'üan', ['ㄩㄣ'] = 'ün', ['ㄩㄥ'] = 'iong',
    ['ㄦ'] = 'er', ['ㄫ'] = 'ng', ['ㄇ'] = 'm', [''] = 'i'
  }

  local zhuyin_py_tone = {
    ["ˊ"] = "\204\129", ["ˇ"] = "\204\140", ["ˋ"] = "\204\128", ["˙"] = "", [""] = "\204\132"
  }

  if type(text) == "table" then text = text.args[1] end
  local word = split(text, " ", true)

  for i, syllable in ipairs(word) do
    syllable = gsub(syllable, '^([ㄓㄔㄕㄖㄗㄘㄙ])([ˊˇˋ˙]?)$', '%1ㄧ%2')
    word[i] = gsub(syllable, '([ㄅㄆㄇㄈㄉㄊㄋㄌㄍㄎㄏㄐㄑㄒㄓㄔㄕㄖㄗㄘㄙ]?)([ㄧㄨㄩ]?[ㄚㄛㄜㄝㄞㄟㄠㄡㄢㄣㄤㄥㄦㄫㄧㄨㄩㄇ])([ˊˇˋ˙]?)(ㄦ?)', function(initial, final, tone, erhua)
      initial = zhuyin_py_initial[initial]
      final = zhuyin_py_final[final]

      if erhua ~= '' then
        final = final .. 'r'
      end
      if initial == '' then
        final = final:gsub('^([iu])(n?g?)$', function(a, b) return a:gsub('[iu]', {['i'] = 'yi', ['u'] = 'wu'}) .. b end)
        final = final:gsub('^(w?u)([in])$', 'ue%2')
        final = final:gsub('^iu$', 'iou')
        final = final:gsub('^([iu])', {['i'] = 'y', ['u'] = 'w'})
        final = final:gsub('^ong', 'weng')
        final = gsub(final, '^ü', 'yu')
      end
      if initial:find('[jqx]') then
        final = gsub(final, '^ü', 'u')
      end
      tone = zhuyin_py_tone[tone]

      if final:find('[ae]') then
        final = final:gsub("([ae])", "%1" .. tone)
      elseif final:find('i[ou]') then
        final = final:gsub("(i[ou])", "%1" .. tone)
      elseif final:find('[io]') then
        final = final:gsub("([io])", "%1" .. tone)
      else
        final = gsub(final, "^([wy]?)(.)", "%1" .. "%2" .. tone)
      end

      return initial .. final
    end)
  end
  return mw.ustring.toNFC(table.concat(word, " "))
end

function export.py_wg(text)
  local py_wg_initial = {
    ["b"] = "p", ["p"] = "p’",
    ["d"] = "t", ["t"] = "t’",
    ["g"] = "k", ["k"] = "k’",
    ["j"] = "chi", ["q"] = "ch’i", ["x"] = "hsi",
    ["z"] = "ts", ["c"] = "ts’", ["r"] = "j",
    ["zh"] = "ch", ["ch"] = "ch’",
  }

  local py_wg_final = {
    ["^([yw]?)e([^ih])"] = "%1ê%2",
    ["^e$"] = "ê",
    ["([iy])an$"] = "%1en",
    ["(i?)ong"] = "%1ung",
    ["([iy])e$"] = "%1eh",
    ["[uü]e"] = "üeh",
    ["r$"] = "rh",
    ["^ê$"] = "eh",
    ["^i$"] = "ih",
    ["yi$"] = "i",
  }

  local py_wg_syl = {
    ["iih"] = "i", ["ii"] = "i", ["iü"] = "ü",
    ["(ts?’?)uo"] = "%1o",
    ["([njls])uo"] = "%1o",
    ["(ch’?)uo"] = "%1o",
    ["tsih"] = "tzŭ", ["ts’ih"] = "tz’ŭ", ["^sih"] = "ssŭ",
    ["^([kh]’?)ê$"] = "%1o",
    ["yên"] = "yen",
    ["you"] = "yu", ["^ih"] = "i",
    ["([pmtnl])ih"] = "%1i",
    ["t’ih"] = "t’i" , ["p’ih"] = "p’i"
  }

  local wg_tones = {
    ['1'] = '¹', ['2'] = '²', ['3'] = '³', ['4'] = '⁴', ['5'] = '⁵'
  }

  if type(text) == 'table' then text = text.args[1] end
  text = gsub(export.py_transform(text, true), '[,%.]', '')
  text = gsub(gsub(text, ' +', ' '), '[一不]', {['一'] = 'yi1', ['不'] = 'bu4'})
  text = gsub(text, '([jqxy])u', '%1ü')
  local p = split(text, " ", true)

  for i = 1, #p do
    p[i] = gsub(p[i], '^([bcdfghjklmnpqrstxz]?h?)(.+)([1-5])$', function(initial, final, tone)
      for t, replace in pairs(py_wg_final) do
        final = gsub(final, t, replace)
      end
      local untoned = (py_wg_initial[initial] or initial) .. final
      for t, replace in pairs(py_wg_syl) do
        untoned = gsub(untoned, t, replace)
      end
      untoned = gsub(untoned, "k(’?)ui", "k%1uei")
      return untoned .. wg_tones[tone] end)
  end
  return table.concat(p, "-")
end

function export.py_yale(text)
  local py_yale_initial = {
    ["q"] = "chh", ["x"] = "sy",
    ["z"] = "dz", ["c"] = "ts",
    ["zh"] = "jh"
  }

  local py_yale_final = {
    ["iong"] = "yung",
    ["ong"] = "ung",
    ["ao"] = "au",
    ["iao"] = "yau",
    ["iu"] = "you",
    ["i([aeo])"] = "y%1",
    ["^u([in])$"] = "we%1",
    ["u([ao])"] = "w%1",
    ["^o$"] = "o",
    ["ü([ae])"] = "w%1",
    ["^ü([ae])"] = "yw%1",
    ["ü([n]?)$"] = "yu%1",
    ["ê"] = "e"
  }

  local py_yale_syl = {
    ["jhi"] = "jr",
    ["jh"] = "j",
    ["chi"] = "chr",
    ["chh"] = "ch",
    ["shi"] = "shr",
    ["ri"] = "r",
    ["dzi"] = "dz",
    ["tsi"] = "tsz",
    ["si"] = "sz",
    ["yy"] = "y",
    ["shwen"] = "shwun",
    ["rwen"] = "rwun",
    ["lwen"] = "lwun",
    ["gwen"] = "gwun",
    ["^([bpmf])o$"] = "%1wo"
  }

  if type(text) == 'table' then text = text.args[1] end
  text = gsub(export.py_transform(text, true), '[,%.]', '')
  text = gsub(gsub(text, ' +', ' '), '[一不]', {['一'] = 'yi1', ['不'] = 'bu4'})
  text = gsub(text, '([jqxy])u', '%1ü')
  local p = split(text, " ", true)

  for i = 1, #p do
    p[i] = gsub(p[i], '^([bcdfghjklmnpqrstxz]?h?)(.+)([1-5])$', function(initial, final, tone)
      for t, replace in pairs(py_yale_final) do
        final = gsub(final, t, replace)
      end
      local untoned = (py_yale_initial[initial] or initial) .. final
      for t, replace in pairs(py_yale_syl) do
        untoned = gsub(untoned, t, replace)
      end
      untoned = gsub(untoned, "k('?)ui", "k%1uei")
      return export.yale_number_to_mark(untoned .. tone) end)
  end
  return table.concat(p, "")
end

function export.py_efeo(text)
  local py_efeo_initial = {
    ["b"] = "p", ["p"] = "p’",
    ["d"] = "t", ["t"] = "t’",
    ["g"] = "k", ["k"] = "k’", ["r"] = "j",
    ["sh"] = "chv", ["zh"] = "tchv", ["ch"] = "tch’v",
    ["z"] = "tsv", ["j"] = "k/ts",
    ["c"] = "ts’v", ["q"] = "k’/ts’",
    ["s"] = "sv", ["x"] = "h/s"
  }

  local py_efeo_final = {
    ["^ou$"] = "eou",
    ["^u$"] = "ou",
    ["^u([ao])"] = "ou%1",
    ["^u([in])$"] = "oue%1",
    ["^([iy])an$"] = "%1en",
    ["^iu$"] = "ieou",
    ["^e?r$"] = "eul",
  }

  local py_efeo_syl = {
    ["^a([ino]g?)$"] = "nga%1",
    ["^[eöo]$"] = "ngo",
    ["^en(g?)$"] = "ngen%1",
    ["^eou$"] = "ngeou",

    ["(t?s’?)ve$"] = "%1ö",
    ["(t?ch’?)ve$"] = "%1ö",
    ["(t?ch’?)vi"] = "%1e",
    ["tsvi"] = "tseu",
    ["ts’vi"] = "ts'eu",
    ["svi"] = "sseu",
    ["ji"] = "je",

    ["([fmw])eng"] = "%1ong",
    ["liang"] = "leang",
    ["liao"] = "leao",

    ["k(’?)/ts’?ia$"] = "k%1ia",
    ["h/sia$"] = "hia",
    ["k(’?)/ts’?ie$"] = "k%1iai, k%1ie, ts%1ie",
    ["h/sie$"] = "hiai, hie, sie",
    ["k(’?)/ts’?iong"] = "k%1iong",
    ["h/siong"] = "hiong",
    ["k(’?)/ts’?üe"] = "k%1io, k%1iue, ts%1io, ts%1iue",

    ["(t?s’?)vouo"] = "%1o",
    ["([tlnjs]’?)ouo"] = "%1o",

    ["^([tlj]’?)e$"] = "%1ö",
    ["^([hk]’?)e$"] = "%1o, %1ö",

    ["k(’?)/ts’?ü(a?n?)$"] = "k%1/ts%1iu%2",
    ["h/sü(e?a?n?)$"] = "h/siu%1",
    ["([ln])ü"] = "%1iu",
    ["lüe"] = "liue, lio",
    ["nüe"] = "nio",
    ["yü"] = "yu",
    ["you"] = "yeou"
  }
  local py_efeo_cleanup = {
    ["v"] = "",
    ["k/ts(.*)"] = "k%1, ts%1",
    ["k’/ts’(.*)"] = "k’%1, ts’%1",
    ["h/s(.*)"] = "h%1, s%1"
  }

  if type(text) == 'table' then text = text.args[1] end
  text = gsub(export.py_transform(text, true), '[,%.]', '')
  text = gsub(gsub(text, ' +', ' '), '[一不]', {['一'] = 'yi1', ['不'] = 'bu4'})
  text = gsub(text, '([jqxy])u', '%1ü')
  local p = split(text, " ", true)

  for i = 1, #p do
    p[i] = gsub(p[i], '^([bcdfghjklmnpqrstxz]?h?)(.+)([1-5])$', function(initial, final, _)
      for t, replace in pairs(py_efeo_final) do
        final = gsub(final, t, replace)
      end
      local untoned = (py_efeo_initial[initial] or initial) .. final
      for t, replace in pairs(py_efeo_syl) do
        untoned = gsub(untoned, t, replace)
      end
      for t, replace in pairs(py_efeo_cleanup) do
        untoned = gsub(untoned, t, replace)
      end
      untoned = gsub(untoned, "k('?)ui", "k%1uei")
      return untoned end)
  end
  return table.concat(p, "-")
end

function export.str_analysis(text, conv_type, sichuan)
  if type(text) == 'table' then text, conv_type = text.args[1], (text.args[2] or "") end
  local MT = m_zh_data().MT

  text = gsub(text, '=', '—')
  text = gsub(text, ',', '隔')
  text = gsub(text, '隔 ', ', ')
  if conv_type == 'head' or conv_type == 'link' then
    if find(text, ', cap—') then
      text = gsub(text, '[一不]', {['一'] = 'Yī', ['不'] = 'Bù'})
    end
    text = gsub(text, '[一不]', {['一'] = 'yī', ['不'] = 'bù'})
  end
  local comp = split(text, '隔', true)
  local reading = {}
  local alternative_reading = {}
  local zhuyin = {}

  if conv_type == '' then
    return comp[1]
  elseif conv_type == 'head' or conv_type == 'link' then
    for i, item in ipairs(comp) do
      if not find(item, '—') then
        if find(item, '[一-龯㐀-䶵]') then
          local M, T, t = {}, {}, {}
          for a, b in pairs(MT) do
            M[a] = b[1]; T[a] = b[2]; t[a] = b[3];
            M[a] = gsub(M[a], "^([āōēáóéǎǒěàòèaoe])", "'%1")
            T[a] = gsub(T[a], "^([āōēáóéǎǒěàòèaoe])", "'%1")
            if t[a] then t[a] = gsub(t[a], "^([āōēáóéǎǒěàòèaoe])", "'%1") end
          end
          local mandarin = gsub(item, '.', M)
          local taiwan = gsub(item, '.', T)
          mandarin = gsub(mandarin, "^'", "")
          mandarin = gsub(mandarin, " '", " ")
          if conv_type == 'link' then return mandarin end
          taiwan = gsub(taiwan, "^'", "")
          taiwan = gsub(taiwan, " '", " ")
          local tt = gsub(item, '.', t)
          if find(text, 'cap—') then
            mandarin = gsub(mandarin, '^%l', string.upper)
            taiwan = gsub(taiwan, '^%l', string.upper)
            tt = gsub(tt, '^%l', string.upper)
          end
          if tt == item then
            zhuyin[i] = export.py_zhuyin(mandarin, true) .. ', ' .. export.py_zhuyin(taiwan, true)
            reading[i] = mandarin .. ']], [[' .. taiwan
          else
            tt = gsub(tt, "^'", "")
            tt = gsub(tt, " '", " ")
            zhuyin[i] = export.py_zhuyin(mandarin, true) .. ', ' .. export.py_zhuyin(taiwan, true) .. ', ' .. export.py_zhuyin(tt, true)
            reading[i] = mandarin .. ']], [[' .. taiwan .. ']], [[' .. tt
          end
        else
          if conv_type == 'link' then return item end
          zhuyin[i] = export.py_zhuyin(item, true)
          reading[i] = item
          if len(mw.title.getCurrentTitle().text) == 1 and #mw.text.split(export.py_transform(item), " ") == 1 then
            alternative_reading[i] = "[[" .. m_zh.py_transf(reading[i]) .. "|" .. mw.ustring.gsub(m_zh.py_transf(reading[i]), '([1-5])', '<sup>%1</sup>') .. "]]"
          end
        end
        if reading[i] ~= '' then reading[i] = '[[' .. reading[i] .. ']]' end
      end
      comp[i] = item
      if conv_type == 'link' then return comp[1] end
    end
    local id = m_zh.ts_determ(mw.title.getCurrentTitle().text)
    local accel
    if id == 'trad' then
      accel = '<span class="form-of pinyin-t-form-of transliteration-' .. m_zh.ts(mw.title.getCurrentTitle().text) .. '" lang="cmn">'
    elseif id == 'simp' then
      accel = '<span class="form-of pinyin-s-form-of transliteration-' .. m_zh.st(mw.title.getCurrentTitle().text) .. '" lang="cmn">'
    elseif id == 'both' then
      accel = '<span class="form-of pinyin-ts-form-of" lang="cmn">'
    end
    local result = sichuan and sichuan ~= "" and "*: <small>(''[[w:Standard Chinese|Standard]]'')</small>\n*::" or "*:"
    result = result .. "<small>(''[[w:Pinyin|Pinyin]]'')</small>: <tt>" .. accel .. gsub(table.concat(reading, ", "), ", ,", ",") .. "</span>"
    if alternative_reading[1] then
      result = result .. " (" .. table.concat(alternative_reading, ", ") .. ")"
    end
    result = result .. (sichuan and sichuan ~= "" and "</tt>\n*::" or "</tt>\n*:")
    result = result .. "<small>(''[[w:Zhuyin|Zhuyin]]'')</small>: " .. '<span lang="zh" class="Bopo">' .. gsub(table.concat(zhuyin, ", "), ", ,", ",") .. "</span>"
    return result

  elseif conv_type == '2' or conv_type == '3' or conv_type == '4' or conv_type == '5' then
    if not find(text, '隔') or (comp[tonumber(conv_type)] and find(comp[tonumber(conv_type)], '—')) then
      return ''
    else
      return comp[tonumber(conv_type)]
    end
  else
    for i = 1, #comp, 1 do
      local target = '^' .. conv_type .. '—'
      if find(comp[i], target) then
        text = gsub(comp[i], target, '')
        return text
      end
    end
    text = ''
  end
  return text
end

function export.homophone_link(text)
  text = text.args[1]
  if text == "" then
    return ""
  end
  local detoned = gsub(export.py_transform(text, true), '[,.]', '')
  detoned = gsub(detoned, ' +', ' ')
  local p = split(detoned, " ")
  local outlink = ""
  for i = 1, #p do
    local link = gsub(p[i], "([a-z])([a-z]*)[1-5]", "%1#%1%2")
    link = mw.ustring.gsub(link, "^%S", mw.ustring.upper)
    link = "[[Annexe:Sinogrammes/Pinyin/".. link
    outlink = outlink .. link .. '|' .. export.py_number_to_mark(p[i]) .. ']], '
  end
  return mw.ustring.sub(outlink,1,mw.ustring.len(outlink)-2)
end

return export
