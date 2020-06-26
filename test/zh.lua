local m_params = require("Module:paramètres")

local M = {}

local sub = mw.ustring.sub
local gsub = mw.ustring.gsub
local match = mw.ustring.match
local cmn_pron

local function format_Chinese_text(text)
  return '<span class="Hani" lang="zh">' .. text .. '</span>'
end
local function format_rom(text)
  return text and '<i><span class="tr Latn">' .. text .. '</span></i>' or nil
end
local function format_gloss(text)
  return text and '« ' .. text .. ' »' or nil
end

local tones = '[̄́̌̀]'

local function replace_chars(s, tab)
  return gsub(s, ".", tab)
end

function M.py_detone(f)
  local text = type(f) == 'table' and f.args[1] or f
  return mw.ustring.toNFC(gsub(mw.ustring.toNFD(text), tones, ''))
end

function M.py_transf(f)
  local text = type(f) == 'table' and f.args[1] or f
  return M.py_detone(text) .. M.tone_determ(text)
end

function M.tone_determ(f)
  local text = type(f) == 'table' and f.args[1] or f
  text = mw.ustring.toNFD(text)
  local tone_num = { ['̄'] = '1', ['́'] = '2', ['̌'] = '3', ['̀'] = '4' }
  return tone_num[match(text, tones)] or '5'
end

function M.ts_determ(f)
  local m_ts_data = mw.loadData("Module:zh/data/ts")
  local m_st_data = mw.loadData("Module:zh/data/st")
  local text = type(f) == 'table' and f.args[1] or f
  local i = 0
  for cp in mw.ustring.gcodepoint(text) do
    local ch = mw.ustring.char(cp)
    if m_ts_data.ts[ch] then
      return 'trad'
    end
    if m_st_data.st[ch] then
      if i > 1 then
        return 'simp'
      else
        i = i + 1
      end
    end
  end
  return (i > 0 and 'simp' or 'both')
end

function M.ts(f)
  local m_ts_data = mw.loadData("Module:zh/data/ts")
  local text = type(f) == 'table' and f.args[1] or f
  text = replace_chars(text, m_ts_data.ts)
  return text
end

function M.st(f)
  local m_st_data = mw.loadData("Module:zh/data/st")
  local text = type(f) == 'table' and f.args[1] or f
  text = replace_chars(text, m_st_data.st)
  return text
end

function M.extract_pron(title, variety)
  local tr
  if mw.title.new(title).exists then
    local content = mw.title.new(title):getContent()
    content = gsub(content, ",([^ ])", ";%1")
    local template = match(content, "{{zh%-pron[^}]*|" .. variety .. "=([^};|\n]+)")
    if template and template ~= "" then
      if cmn_pron == nil then
        cmn_pron = require("Module:cmn-pron")
      end
      tr = cmn_pron.str_analysis(template, 'link')
    end
  end
  return tr
end

function M.link(frame, mention, args, pagename, no_transcript)
  local params = {
    [1] = {},
    [2] = {},
    [3] = {},
    [4] = {},
    ['gloss'] = {},
    ['tr'] = {},
    ['lit'] = {},
  }

  if mention then
    params['note'] = {}
  end

  local moduleCalled
  if args then
    moduleCalled = true
  end
  args = args or frame:getParent().args
  if not moduleCalled then
    params[1].required = true
  end
  args = m_params.process(args, params)
  if moduleCalled then
    if not args[1] then
      return ""
    end
  end
  pagename = pagename or mw.title.getCurrentTitle().text

  local text, tr, gloss

  if args[2] and match(args[2], '[一-龯㐀-䶵]') then
    gloss = args[4]
    tr = args[3]
    text = args[1] .. '/' .. args[2]
  else
    text = args[1]
    if args['gloss'] then
      tr = args[2]
      gloss = args['gloss']
    else
      if args[3] or (args[2] and (match(args[2], '[āōēīūǖáóéíúǘǎǒěǐǔǚàòèìùǜâêîôû̍ⁿ]') or match(args[2], '[bcdfghjklmnpqrstwz]h?y?[aeiou][aeiou]?[iumnptk]?g?[1-9]'))) then
        tr = args[2]
        gloss = args[3]
      else
        gloss = args[2]
      end
    end
  end
  if args['tr'] then
    tr = args['tr']
    gloss = gloss or args[2]
  end
  if text then
    if not text:match('[%[%]]') then
      local words = mw.text.split(text, "/", true)
      if #words == 1 and M.ts_determ(words[1]) == 'trad' and not match(words[1], '%*') then
        table.insert(words, M.ts(words[1]))
      end
      if not tr and not no_transcript and words[1] and text ~= pagename then
        tr = M.extract_pron(words[1], "m")
      end

      for i, word in ipairs(words) do
        word = gsub(word, '%*', '')
        if mention then
          words[i] = '<i class="Hani mention" lang="zh">[[' .. word .. '#Chinese|' .. word .. ']]</i>'
          --[[ (disabled to allow links to, for example, a link to 冥王星#Chinese from 冥王星#Japanese. 18 May, 2016)
                elseif word == pagename then
                  word = format_Chinese_text('<b>' .. word .. '</b>')
          ]]
        else
          words[i] = format_Chinese_text('[[' .. word .. '#Chinese|' .. word .. ']]')
        end
      end
      text = table.concat(words, "／")
    elseif text:match('[%[%]]') or text == pagename then
      if mention then
        text = '<i class="Hani mention" lang="zh">' .. gsub(text, "%*", "") .. '</i>'
      else
        text = format_Chinese_text(gsub(text, "%*", ""))
      end
    end
  end
  if tr == '-' or no_transcript then
    tr = nil -- allow translit to be disabled: remove translit if it is "-", just like normal {{l}}
  end
  local notes = args['note']
  if tr or gloss or notes then
    local annotations = {}
    if tr then
      tr = format_rom(tr)
      table.insert(annotations, tr)
    end
    if gloss then
      table.insert(annotations, format_gloss(gloss))
    end
    table.insert(annotations, notes)
    annotations = table.concat(annotations, ", ")
    text = text .. " (" .. annotations .. ")"
  end
  return text
end

function M.check_pron(text, variety, length, entry_creation)
  if type(text) == 'table' then
    text, variety = text.args[1], text.args[2]
  end
  if not text then
    return
  end
  local startpoint, address = { ['yue'] = 51, ['hak'] = 19968, ['nan'] = 19968 }, { ['yue'] = 'yue-word/%03d', ['hak'] = 'hak-pron/%02d', ['nan'] = 'nan-pron/%03d' }
  local unit = 1000
  local first_char = sub(text, 1, 1)
  local result, success, data
  if length == 1 and variety == "yue" then
    success, data = pcall(mw.loadData, 'Module:zh/data/Jyutping character')
  else
    local page_index = math.floor((mw.ustring.codepoint(first_char) - startpoint[variety]) / unit)
    success, data = pcall(mw.loadData,
        ('Module:zh/data/' .. address[variety]):format(page_index)
    )
  end
  if success then
    result = data[text] or false
  else
    result = false
  end
  if result then
    if variety == "nan" and entry_creation then
      result = gsub(result, "%-á%-", "-仔-")
      result = gsub(result, "%-á/", "-仔/")
      result = gsub(result, "%-á$", "-仔")
      result = gsub(result, "^(.+)%-%1%-%1$", "(%1)")
      result = gsub(result, "^(.+)%-%1%-%1([%-%/])", "(%1)%2")
      result = gsub(result, "([%-%/])(.+)%-%1%-%1$", "%1(%2)")
      result = gsub(result, "([%-%/])(.+)%-%1%-%1([%-%/])", "%1(%2)%3")
    end
  end
  return result
end

return M
