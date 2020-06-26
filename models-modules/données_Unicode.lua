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

  for i = 1, mw.ustring.len(text) do
    local c = mw.ustring.sub(text, i, i)
    local script = p.getScriptForChar(c)
    local name = script.code

    if not commonFound and name == "Common" then
      commonFound = true
    elseif not inheritedFound and name == "Inherited" then
      inheritedFound = true
    elseif name ~= "Common" and name ~= "Inherited" then
      if res == nil or res.code == "Unknown" then
        res = script
      elseif res ~= nil and script.code ~= "Unknown" and script.code ~= res.code then
        return p.getScript("Common")
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

--- Indicates wether the given text is in the given Unicode script.
--- @param text string The text.
--- @param scriptCode string The scripts code.
--- @return boolean True if the code exists and the text is in this script,
---                 false otherwise.
function p.textHasScript(text, scriptCode)
  local script = p.getScript(scriptCode)
  return script ~= nil and p.getScriptForText(text).code == script.code
end

local directionToCss = {
  ["lr"] = "horizontal-tb",
  ["rl"] = "horizontal-tb",
  ["tb"] = "vertical-lr",
  ["i"] = "inherit",
  ["m"] = "inherit",
}

--- Sets the writing direction for the given text, based on its Unicode script,
--- by inserting it inside a span tag.
--- @param text string The text.
--- @return string The text, included in a span tag with the writing-mode CSS rule.
function p.setWritingDirection(text)
  local script = p.getScriptForText(text)
  return mw.ustring.format('<span style="writing-mode:%s">%s</span>', directionToCss[script.direction or "i"], text)
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

  if blockCode ~= nil then
    block = p.getBlock(blockCode)
  else
    block = p.getBlockForChar(mw.title.getCurrentTitle().text)
  end

  if block ~= nil then
    return mw.ustring.format("Unicode, Inc., ''[%s %s]'', The Unicode Standard, version %s, %d",
        block.url, block.name.en, block.version, block.year)
  end

  error("Bloc Unicode incorrect")
end

--- Sets the writing direction for the given text, based on its Unicode script,
--- by inserting it inside a span tag.
---  frame.args[1] (string): The text.
--- @return string The text, included in a span tag with the writing-mode CSS rule.
function p.writingDirection(frame)
  local args = m_params.process(frame.args, {
    [1] = { required = true, allow_empty = true },
  })
  return p.setWritingDirection(args[1])
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

return p
