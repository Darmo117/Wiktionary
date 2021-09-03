local m_params = require("Module:paramètres")

local p = {}

---------------------------------
-- Functions for other modules --
---------------------------------

-- Data loading functions --

--- Returns the list of all Unicode blocks.
--- @return table
function p.getBlocks()
  return mw.loadData("Module:données Unicode/data/blocks")
end

--- Returns the list of all Unicode scripts.
--- @return table
function p.getScripts()
  return mw.loadData("Module:données Unicode/data/scripts")
end

--- Returns the list of all Unicode script ranges.
--- @return table
function p.getScriptRanges()
  -- Loaded with require() instead of mw.loadData() as the returned table
  -- has tables as keys.
  return require("Module:données Unicode/data/script ranges")
end

-- Block-related functions --

--- Returns the Unicode block that has the given lowest codepoint.
--- @param lowerCodepoint number The lowest codepoint of the block.
--- @return table|nil The block or nil if none were found.
function p.getBlock(lowerCodepoint)
  return p.getBlocks()[lowerCodepoint]
end

--- Returns the Unicode block that contains the given character.
--- Throws an error if zero or more than 1 characters were given.
--- @param char string The character.
--- @return table|nil The block or nil if the character doesn’t belong to any block.
function p.getBlockForChar(char)
  local len = mw.ustring.len(char)
  if len ~= 1 then
    error(mw.ustring.format('Un seul caractère attendu, %d donnés ("%s")', len, char))
  end
  local code = mw.ustring.codepoint(char)

  for _, block in pairs(p.getBlocks()) do
    if block.lower <= code and code <= block.upper then
      return block
    end
  end

  return nil
end

-- Script-related functions --

--- Returns the Unicode script for the given code.
--- @param code string The script’s code.
--- @return table|nil The script or nil if none were found.
function p.getScript(code)
  return p.getScripts()[code]
end

--- Returns the Unicode script for the given character.
--- Throws an error if zero or more than 1 characters were given.
--- @param char string The character.
--- @return table|nil The script or nil if the character doesn’t belong to any block.
function p.getScriptForChar(char)
  local len = mw.ustring.len(char)
  if len ~= 1 then
    error(mw.ustring.format("Un seul caractère attendu, %d donnés", len))
  end
  local code = mw.ustring.codepoint(char)
  local scripts = p.getScripts()

  for range, script_code in pairs(p.getScriptRanges()) do
    if range[1] <= code and code <= range[2] then
      return scripts[script_code]
    end
  end

  return scripts["Unknown"]
end

--- Returns the Unicode script for the given text.
--- If the text contains character from several scripts other than
--- Common or Inherited, the returned script is Common.
--- @param text string The text.
--- @return table The script.
function p.getScriptForText(text)
  local inheritedFound = false
  local commonFound = false
  local res

  for _, script in pairs(p.getScriptsForText(text)) do
    local name = script.code

    if not commonFound and name == "Common" then
      commonFound = true
    elseif not inheritedFound and name == "Inherited" then
      inheritedFound = true
    elseif name ~= "Common" and name ~= "Inherited" then
      if res == nil or res.code == "Unknown" then
        res = script
      elseif res and script.code ~= "Unknown" and script.code ~= res.code then
        return p.getScript("Unknown")
      end
    end
  end

  if res == nil then
    if inheritedFound then
      return p.getScript("Inherited")
    elseif commonFound then
      return p.getScript("Common")
    end
  end

  return res
end

--- Returns the Unicode scripts for the given text.
--- @param text string The text.
--- @param getRanges boolean If true, ranges for each script will be returned
--- @return table The list of scripts (unsorted).
function p.getScriptsForText(text, getRanges)
  local res = {}
  local scriptsRanges = {}

  local i = 1
  while i <= mw.ustring.len(text) do
    local c = mw.ustring.sub(text, i, i)

    -- Skip HTML tags
    local skip = false
    if c == "<" then
      local j = mw.ustring.find(text, ">", i, true)
      if j ~= nil then
        table.insert(scriptsRanges, { script = nil, from = i, to = j })
        i = j
        skip = true
      end
    end

    if not skip then
      local script = p.getScriptForChar(c)
      local name = script.code

      if not res[name] then
        res[name] = script
        table.insert(scriptsRanges, { script = name, from = i, to = i })
      else
        local lastRange = scriptsRanges[#scriptsRanges]
        if lastRange.script == name and lastRange.to + 1 == i then
          lastRange.to = i
        else
          table.insert(scriptsRanges, { script = name, from = i, to = i })
        end
      end
    end

    i = i + 1
  end

  if getRanges then
    return res, scriptsRanges
  end
  return res
end

--- Indicates whether the given text contains characters in the given Unicode script.
--- @param text string The text.
--- @param scriptCode string The script’s code.
--- @return boolean True if the code exists and the text contains characters in this script,
---                 false otherwise.
function p.textHasScript(text, scriptCode)
  local script = p.getScript(scriptCode)
  return script ~= nil and p.getScriptsForText(text)[script.code] ~= nil
end

--- Indicates whether the given text should be in italics, based on the different character scripts.
--- A text should be in italics if and only if p.getScriptForText(text) returns either Latin, Common or Inherit;
--- in all other cases, it should not.
--- @param text string The text.
--- @return boolean True if the text should be in italics.
function p.shouldItalicize(text)
  local name = p.getScriptForText(text).code
  return name == "Latin" or name == "Common" or name == "Inherited"
end

local directionToCss = {
  ["lr"] = "horizontal-tb",
  ["rl"] = "horizontal-tb",
  ["tb"] = "vertical-lr",
  ["i"] = "inherit",
  ["m"] = "inherit",
}

local directionToDir = {
  ["lr"] = "ltr",
  ["rl"] = "rtl",
  ["tb"] = "ltr",
}

--- Sets the writing direction for the given text, based on its Unicode scripts,
--- by inserting span tags.
--- @param text string The text.
--- @return string The text which contains span tags with the writing-mode CSS rule and dir attribute.
function p.setWritingDirection(text)
  local res = ""
  local scripts, intervals = p.getScriptsForText(text, true)

  local prevScriptName
  local inSpan = false
  for i, interval in ipairs(intervals) do
    local substr = mw.ustring.sub(text, interval.from, interval.to)

    if interval.script then
      local script = scripts[interval.script]
      local scriptName = script.name
      local scriptDir = script.direction or "i"
      local nextScript = intervals[i + 1] and scripts[intervals[i + 1].script] or nil
      local nextScriptDir = nextScript and (nextScript.direction or "i") or nil

      if inSpan and scriptDir ~= "i" and scriptDir ~= "m" and scriptName ~= prevScriptName then
        res = res .. "</span>"
        inSpan = false
      end

      if scriptDir == "lr" or prevScriptName == scriptName
          -- Special case for when text begins with i or m scripts and is followed by script ≠ lr
          or ((scriptDir == "i" or scriptDir == "m") and (i == 1 and nextScriptDir == "lr" or i > 1 or not nextScript)) then
        res = res .. substr
      else
        local dir
        local cssDir
        -- Include current span in next script’s span
        if scriptDir ~= "i" and scriptDir ~= "m" then
          dir = directionToDir[scriptDir]
          cssDir = scriptDir
          prevScriptName = scriptName
        elseif nextScriptDir then
          dir = directionToDir[nextScriptDir]
          cssDir = nextScriptDir
          prevScriptName = nextScript.name
        end

        if dir then
          local dirAttr = dir and ('dir="' .. dir .. '"') or ""
          local writingMode = directionToCss[cssDir]
          res = res .. mw.ustring.format('<span %s style="writing-mode:%s">', dirAttr, writingMode) .. substr
          inSpan = true
        end
      end

    else
      if inSpan then
        res = res .. "</span>"
        inSpan = false
      end
      res = res .. substr
      prevScriptName = nil
    end
  end

  if inSpan then
    res = res .. "</span>"
  end

  return res
end

--- Converts an integer into another system.
--- @param n number The number to convert.
--- @param system string The target number system.
--- @return string The converted number as a string of digits.
function p.convertNumber(n, system)
  if n < 0 then
    error("number must be a positive integer")
  end
  -- TODO
end

-----------------------------
-- Functions for templates --
-----------------------------

--- Returns the wikitext for template [[Modèle:Bloc Unicode]].
---  frame.args[1] (int, optional): The lower bound of the Unicode block
---   (decimal or hexadecimal with “0x” prefix).
---   If undefined, the code will be extracted from the page’s title.
--- @return string The template’s wikicode.
function p.blockReference(frame)
  local args = m_params.process(frame.args, {
    [1] = { type = m_params.INT },
  })
  local blockCode = args[1]
  local block

  if blockCode then
    block = p.getBlock(blockCode)
  else
    block = p.getBlockForChar(mw.title.getCurrentTitle().text)
  end

  if block then
    return mw.ustring.format("Unicode, Inc., ''[%s %s]'', The Unicode Standard, version %s, %d",
        block.url, block.name.en, block.version, block.year)
  end

  error(mw.ustring.format("Bloc Unicode «&nbsp;%s&nbsp;» invalide", blockCode))
end

--- Sets the writing direction for the given text, based on its Unicode script,
--- by inserting it inside a span tag.
---  frame.args[1] (string): The text.
--- @return string The text, included in a span tag with the writing-mode CSS rule.
function p.writingDirection(frame)
  local args = m_params.process(frame.args, {
    [1] = { required = true, allow_empty = true },
  })
  if args[1] then
    return p.setWritingDirection(args[1])
  end
  return ""
end

--- Returns the Unicode codepoint of the given character.
--- Throws an error if zero or more than 1 characters were given.
---  frame.args[1] (string, only one character): The character.
---  frame.args[2] (boolean, default = false) : Indicates wether the returned codepoint
---   will be in hexadecimal.
--- @return string|number The character’s codepoint without the “0x” prefix if it is in hexadecimal.
function p.codepoint(frame)
  local args = m_params.process(frame.args, {
    [1] = {
      required = true,
      checker = function(value)
        return mw.ustring.len(value) == 1
      end,
    },
    ["hexa"] = { type = m_params.BOOLEAN, default = false },
  })
  local char = args[1]
  local isHex = args["hexa"]

  local code = mw.ustring.codepoint(char)
  if isHex then
    return string.format("%04X", code)
  end
  return code
end

--- Returns the character with the given Unicode codepoint.
--- Throws an error if the codepoint is invalid.
---  frame.args[1] (int): The codepoint.
--- @return string The character.
function p.character(frame)
  local args = m_params.process(frame.args, {
    [1] = { required = true, type = m_params.INT },
  })
  local code = tonumber(args[1])

  if code ~= nil then
    local success, char = pcall(mw.ustring.char, code)
    if success then
      return char
    end
  end

  error("Point de code incorrect")
end

--- Converts an arab number into the given system.
---  frame.args[1] (int): The number.
---  frame.args["script"] (string): The target system.
--- @return string The converted number as a string of digits.
function p.number(frame)
  local args = m_params.process(frame.args, {
    [1] = { required = true, type = m_params.INT, checker = function(i)
      return tonumber(i) >= 0
    end },
    ["script"] = { enum = {} } -- TODO définir les systèmes numériques (positionels, grec, etc.)
  })

  return p.convertNumber(args[1], args["script"])
end

return p
