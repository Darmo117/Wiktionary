local export = {}

local m_Unicode_data

local function errorf(level, ...)
	if type(level) == "number" then
		return error(string.format(...), level + 1)
	else -- level is actually the format string.
		return error(string.format(level, ...), 2)
	end
end

local function get_codepoint(args, arg)
	local codepoint_string = args[arg]
		or errorf(2, "Parameter %s is required", tostring(arg))
	local codepoint = tonumber(codepoint_string, 16)
		or mw.ustring.len(codepoint_string) == 1
			and mw.ustring.codepoint(codepoint_string)
		or errorf(2, "Parameter %s is not a code point in hexadecimal base",
			tostring(arg))
	if not (0 <= codepoint and codepoint <= 0x10FFFF) then
		errorf(2, "code point in parameter %s out of range", tostring(arg))
	end
	return codepoint
end

local function get_func(args, arg, prefix)
	local suffix = args[arg]
		or errorf(2, "Parameter %s is required", tostring(arg))
	suffix = mw.text.trim(suffix)
	local func_name = prefix .. suffix
	m_Unicode_data = m_Unicode_data or require "Module:Unicode data"
	local func = m_Unicode_data[func_name]
		or errorf(2, "There is no function '%s'", func_name)
	return func
end

-- This function allows any of the "lookup" functions to be invoked. The first
-- parameter is the word after "lookup_"; the second parameter is the code point
-- in hexadecimal base.
function export.lookup(frame)
	local func = get_func(frame.args, 1, "lookup_")
	local codepoint = get_codepoint(frame.args, 2)
	local result = func(codepoint)
	if func == m_Unicode_data.lookup_name then
		-- Prevent code point labels such as <control-0000> from being
		-- interpreted as HTML tags.
		result = result:gsub("<", "&lt;")
	end
	return result
end

function export.is(frame)
	local func = get_func(frame.args, 1, "is_")
	
	-- is_Latin and is_valid_pagename take strings.
	m_Unicode_data = m_Unicode_data or require "Module:Unicode data"
	if func == m_Unicode_data.is_Latin or func == m_Unicode_data.is_valid_pagename then
		return (func(frame.args[2]))
	else -- The rest take code points.
		local codepoint = get_codepoint(frame.args, 2)
		return (func(codepoint)) -- Adjust to one result.
	end
end

function export.has_aliases(frame)
	local codepoint = get_codepoint(frame.args, 1)
	return mw.loadData("Module:Unicode data/aliases")[codepoint] ~= nil
end

function export.get_special_title_value(frame)
	local codepoint = get_codepoint(frame.args, 1)
	local character = mw.ustring.char(codepoint)
	local title = require("Module:Unicode data").get_entry_title(codepoint)
	if not title then
		return ""
	elseif title == character then
		return "self"
	else
		return title
	end
end

return export
