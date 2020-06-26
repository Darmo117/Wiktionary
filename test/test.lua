local m_unicode = require("Module:données Unicode")

local export = {}

function export.test(frame)
  local title = mw.title.getCurrentTitle()
  local result = title.text
  if title.nsText and title.nsText ~= "" then
    result = title.nsText .. ':' .. result
  end
  return frame:callParserFunction("DISPLAYTITLE", m_unicode.set_writing_mode_for_text(result))
end

return export
