local Error = require("Module:bac à sable/Darmo117/test")
local m_debug = require("Module:debug")

local export = {}

function export.test(_)
  local err = Error:new({ test = "test" }, "erreur")
  local _, e = pcall(function()
    error(err)
  end)
  return m_debug.dump(e)
end

function export.test2(_)
  local err = Error:new({ test = "test" }, "erreur")
  error(err)
end

return export
