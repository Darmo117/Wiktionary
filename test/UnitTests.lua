local UnitTester = {}

local tick, cross =
'[[File:OOjs UI icon check-constructive.svg|20px|alt=Passed|link=|Test réussi]]',
'[[File:OOjs UI icon close-ltr-destructive.svg|20px|alt=Failed|link=|Test échoué]]'

local result_table_header = '{| class="unit-tests wikitable"\n! class="unit-tests-img-corner" style="cursor:pointer" title="Liste des tests"| !! Texte !! Attendu !! Obtenu'
local result_table = {}
local num_failures = 0
local total_tests = 0

local function first_difference(s1, s2)
  if type(s1) ~= 'string' then return 'N/A' end
  if type(s2) ~= 'string' then return 'N/A' end
  if s1 == s2 then return '' end
  local iter1 = mw.ustring.gmatch(s1, '.')
  local iter2 = mw.ustring.gmatch(s2, '.')
  local max = math.min(mw.ustring.len(s1) or #s1, mw.ustring.len(s2) or #s2)
  for i = 1, max do
    local c1 = iter1()
    local c2 = iter2()
    if c1 ~= c2 then return i end
  end
  return max + 1
end

local function val_to_str(v)
  if type(v) == 'string' then
    v = mw.ustring.gsub(v, '\n', '\\n')
    if mw.ustring.match(mw.ustring.gsub(v, '[^\'"]', ''), '^"+$') then
      return "'" .. v .. "'"
    end
    return '"' .. mw.ustring.gsub(v, '"', '\\"' ) .. '"'
  elseif type(v) == 'table' then
    local result, done = {}, {}
    for k, val in ipairs(v) do
      table.insert(result, val_to_str(val))
      done[k] = true
    end
    for k, val in pairs(v) do
      if not done[k] then
        if (type(k) ~= "string") or not mw.ustring.match(k, '^[_%a][_%a%d]*$') then
          k = '[' .. val_to_str(k) .. ']'
        end
        table.insert(result, k .. '=' .. val_to_str(val))
      end
    end
    return '{' .. table.concat(result, ', ') .. '}'
  else
    return tostring(v)
  end
end

local function deep_compare(t1, t2, ignore_mt)
  local ty1 = type(t1)
  local ty2 = type(t2)
  if ty1 ~= ty2 then return false end
  if ty1 ~= 'table' and ty2 ~= 'table' then return t1 == t2 end

  local mt = getmetatable(t1)
  if not ignore_mt and mt and mt.__eq then return t1 == t2 end

  for k1, v1 in pairs(t1) do
    local v2 = t2[k1]
    if v2 == nil or not deep_compare(v1, v2) then return false end
  end
  for k2, v2 in pairs(t2) do
    local v1 = t1[k2]
    if v1 == nil or not deep_compare(v1, v2) then return false end
  end

  return true
end

function UnitTester:preprocess_equals(text, expected, options)
  local actual = self.frame:preprocess(text)
  if actual == expected then
    table.insert(result_table, '|- class="unit-test-pass"\n | ' .. tick)
  else
    table.insert(result_table, '|- class="unit-test-fail"\n | ' .. cross)
    num_failures = num_failures + 1
  end
  local differs_at = self.differs_at and (' || ' .. first_difference(expected, actual)) or ''
  local comment = self.comments and (' || ' .. (options and options.comment or '')) or ''
  actual   = tostring(actual)
  expected = tostring(expected)
  if self.nowiki or options and options.nowiki then
    expected = mw.text.nowiki(expected)
    actual = mw.text.nowiki(actual)
  end
  table.insert(result_table, ' || ' .. mw.text.nowiki(text) .. ' || ' .. expected .. ' || ' .. actual .. differs_at .. comment .. "\n")
end

function UnitTester:preprocess_equals_many(prefix, suffix, cases, options)
  for _, case in ipairs(cases) do
    self:preprocess_equals(prefix .. case[1] .. suffix, case[2], options)
  end
end

function UnitTester:preprocess_equals_preprocess(text1, text2, options)
  local actual = self.frame:preprocess(text1)
  local expected = self.frame:preprocess(text2)
  if actual == expected then
    table.insert(result_table, '|- class="unit-test-pass"\n | ' .. tick)
  else
    table.insert(result_table, '|- class="unit-test-fail"\n | ' .. cross)
    num_failures = num_failures + 1
  end
  if self.nowiki or options and options.nowiki then
    expected = mw.text.nowiki(expected)
    actual = mw.text.nowiki(actual)
  end
  local differs_at = self.differs_at and (' || ' .. first_difference(expected, actual)) or ''
  local comment = self.comments and (' || ' .. (options and options.comment or '')) or ''
  table.insert(result_table, ' || ' .. mw.text.nowiki(text1) .. ' || ' .. expected .. ' || ' .. actual .. differs_at .. comment .. "\n")
end

function UnitTester:preprocess_equals_preprocess_many(prefix1, suffix1, prefix2, suffix2, cases, options)
  for _, case in ipairs(cases) do
    self:preprocess_equals_preprocess(prefix1 .. case[1] .. suffix1, prefix2 .. (case[2] and case[2] or case[1]) .. suffix2, options)
  end
end

function UnitTester:equals(name, actual, expected, options)
  if actual == expected then
    table.insert(result_table, '|- class="unit-test-pass"\n | ' .. tick)
  else
    table.insert(result_table, '|- class="unit-test-fail"\n | ' .. cross)
    num_failures = num_failures + 1
  end
  if self.nowiki or options and options.nowiki then
    expected = mw.text.nowiki(expected)
    actual = mw.text.nowiki(actual)
  end
  local differs_at = self.differs_at and (' || ' .. first_difference(expected, actual)) or ''
  local comment = self.comments and (' || ' .. (options and options.comment or '')) or ''
  if expected == nil then
    expected = '(nil)'
  else
    expected = tostring(expected)
  end
  if actual == nil then
    actual = '(nil)'
  else
    actual = tostring(actual)
  end
  table.insert(result_table, ' || ' .. name .. ' || ' .. expected .. ' || ' .. actual .. differs_at .. comment .. "\n")
end

function UnitTester:equals_deep(name, actual, expected, options)
  if deep_compare(actual, expected) then
    table.insert(result_table, '|- class="unit-test-pass"\n | ' .. tick)
  else
    table.insert(result_table, '|- class="unit-test-fail"\n | ' .. cross)
    num_failures = num_failures + 1
  end
  local actual_str = val_to_str(actual)
  local expected_str = val_to_str(expected)
  if self.nowiki or options and options.nowiki then
    expected_str = mw.text.nowiki(expected_str)
    actual_str = mw.text.nowiki(actual_str)
  end
  local differs_at = self.differs_at and (' || ' .. first_difference(expected_str, actual_str)) or ''
  local comment = self.comments and (' || ' .. (options and options.comment or '')) or ''
  table.insert(result_table, ' || ' .. name .. ' || ' .. expected_str .. ' || ' .. actual_str .. differs_at .. comment .. "\n")
end

function UnitTester:heading(text)
  local columns = 4
  if self.differs_at then
    columns = columns + 1
  end
  if self.comments then
    columns = columns + 1
  end
  table.insert(result_table, (' |-\n ! colspan="%u" style="text-align: left" | %s\n'):format(columns, text))
end

function UnitTester:run(frame)
  num_failures = 0
  result_table = {}

  self.frame = frame
  self.nowiki = frame.args['nowiki']
  self.differs_at = frame.args['differs_at']
  self.comments = frame.args['comments']
  self.summarize = frame.args['summarize']

  local columns = 4
  local table_header = result_table_header
  if self.differs_at then
    columns = columns + 1
    table_header = table_header .. ' !! Différence à la position'
  end
  if self.comments then
    columns = columns + 1
    table_header = table_header .. ' !! Commentaires'
  end

  -- Sort results into alphabetical order.
  local self_sorted = {}
  for key, _ in pairs(self) do
    if key:find('^test') then
      total_tests = total_tests + 1
      table.insert(self_sorted, key)
    end
  end
  table.sort(self_sorted)
  -- Add results to the results table.
  for _, key in ipairs(self_sorted) do
    table.insert(result_table, table_header .. "\n")
    table.insert(result_table, '|+ style="text-align: left; font-weight: bold;" | ' .. key .. ':\n|-\n')
    local traceback = "(pas de trace d’appel)"
    local success, mesg = xpcall(function ()
      return self[key](self)
    end, function (mesg)
      traceback = debug.traceback("", 2)
      return mesg
    end)
    if not success then
      table.insert(result_table, (' |-\n | colspan="%u" style="text-align: left" | <strong class="error">Erreur de script pendant le test : %s</strong>%s\n'):format(
          columns, mw.text.nowiki(mesg), frame:extensionTag("pre", traceback)
      ))
      num_failures = num_failures + 1
    end
    table.insert(result_table, "|}\n\n")
  end

  local refresh_link = tostring(mw.uri.fullUrl(mw.title.getCurrentTitle().fullText, 'action=purge&forcelinkupdate'))

  local failure_cat = '[[Catégorie:Modules avec tests unitaires ayant échoué]]'
  if mw.title.getCurrentTitle().text:find("/documentation$") then
    failure_cat = ''
  end

  total_tests = (#result_table - 3) / 2
  local num_successes = total_tests - num_failures

  if (self.summarize) then
    if (num_failures == 0) then
      return '<strong class="success">' .. total_tests .. '/' .. total_tests .. ' tests réussis</strong>'
    else
      return '<strong class="error">' .. num_successes .. '/' .. total_tests .. ' tests réussis</strong>'
    end
  else
    local status
    if num_failures == 0 then
      status = '<strong class="success">Tous les tests ont réussi.</strong>'
    else
      local s = num_failures == 1 and '' or 's'
      local verb = num_failures == 1 and 'a' or 'ont'
      status = '<strong class="error">' .. num_failures .. ' test' .. s .. ' ' .. verb .. ' échoué.</strong>' .. failure_cat
    end
    return status .. " <span class='plainlinks'>[" .. refresh_link .. " (rafraîchir)]</span>\n\n" .. table.concat(result_table)
  end
end

function UnitTester:new()
  local o = {}
  setmetatable(o, self)
  self.__index = self
  return o
end

local p = UnitTester:new()

function p.run_tests(frame)
  return p:run(frame)
end

return p
