local m_unicode = require('Module:Unicode data')

local export = {}

local dingbat_scripts = {
	["Zsym"] = true;
	["Zmth"] = true;
	["Zyyy"] = true;
}

function export.exotic_symbol_warning(frame)
	local title = mw.title.getCurrentTitle()
	if title.exists then
		return ""
	end
	if mw.ustring.len(title.fullText) ~= 1 then
		return ""
	end

	local codepoint = mw.ustring.codepoint(title.fullText)
	local script_code = m_unicode.char_to_script(codepoint)

	if dingbat_scripts[script_code] then
		return frame:expandTemplate { title = "editnotice-exotic symbols" }
	end

	return ""
end

local function get_codepoint(codepoint, param_name)
	if codepoint then
		codepoint = mw.text.trim(codepoint)
		codepoint = tonumber(codepoint) or mw.text.decode(codepoint)
		if (type(codepoint) == "string") and (mw.ustring.len(codepoint) == 1) then
			codepoint = mw.ustring.codepoint(codepoint)
		elseif type(codepoint) ~= "number" then
			error("Unrecognised string given for the " .. param_name
				.. " parameter")
		end
	end
	return codepoint
end

function export._show(args, parent_title)
	local codepoint = args.codepoint or args[1] or "";
	local image
	local title = mw.title.getCurrentTitle()
	local to_boolean = require('Module:yesno')

	if codepoint ~= "" then
		codepoint = get_codepoint(codepoint, "codepoint")
	else
		if title.fullText == parent_title then
			codepoint = 0xfffd
		elseif mw.ustring.len(title.fullText) == 1 then
			codepoint = mw.ustring.codepoint(title.fullText)
		else
			if title.nsText == "Template" then return "" end
			error("Page title is not a single Unicode character")
		end
	end

	args.image = args.image and mw.text.trim(args.image)
	if args.image == "" then
		image = nil
	else
		image = args.image or m_unicode.lookup_image(codepoint)
	end

	local table_markup = {}
	table.insert(table_markup,
		'{| class="wikitable floatright" style="width:25em;"\n')

	if image then
		if not image:match("\127") then -- <hiero> tags generate these; pass them through
			if image:match("^%[?%[?[Ff]ile:") or image:match("^%[?%[?[Ii]mage:") then
				image = image:gsub("^%[%[", ""):gsub("^[Ff]ile:", ""):gsub("^[Ii]mage:", ""):gsub("|.*", ""):gsub("]]", "")
			end
			image = "[[Category:Character boxes with images|*" .. string.format("%010d", codepoint) .. "]][[File:" .. image .. "|120x140px]]"
		end

		table.insert(table_markup,
			('|-\n| colspan="2" style="text-align: center;" | %s<br/>%s\n'):format(
				image, args.caption or ""
			)
		)
	elseif args.caption then
		table.insert(table_markup,
			('|-\n| colspan="2" style="text-align: center;" | %s\n'):format(
				args.caption
			)
		)
	end

	local script_code = args.sc or m_unicode.char_to_script(codepoint)
	local script_data = mw.loadData("Module:scripts/data")[script_code]
		or error("No data for script code " .. script_code .. ".")
	local script_name = script_data.canonicalName

	local NAMESPACE = title.namespace

	local cat_name
	if not args.nocat and ((NAMESPACE == 0) or (NAMESPACE == 100)) then -- main and Appendix
		if script_data.character_category ~= nil then
			-- false means no category, overriding the default below
			cat_name = script_data.character_category or nil
		elseif script_name then
			cat_name = script_name .. " script characters"
		end
	end

	local latex_result = ""
	if args.latex then
		local latex, n = { '<code>' .. args.latex .. '</code>' }, 2
		while args["latex" .. n] do
			table.insert(latex, '<code>' .. args["latex" .. n] .. '</code>')
			n = n + 1
		end

		latex_result = ('<br>(LaTeX: %s)[[Category:Character boxes with LaTeX inputs]]'):format(table.concat(latex, ", "))
	end

	local block_name = mw.text.encode(args.block or m_unicode.lookup_block(codepoint))

	local aliases
	if args.aliases == "" then
		aliases = nil
	else
		aliases = mw.loadData('Module:Unicode data/aliases')[codepoint]
	end

	local function parse_aliases(aliases)

		local result = {}

		if aliases then
			local classif = {}
			for i, alias in ipairs(aliases) do
				if not classif[alias[1]] then
					classif[alias[1]] = {}
				end
				table.insert(classif[alias[1]], mw.text.encode(alias[2]))
			end

			if classif.correction then
				for i, name in ipairs(classif.correction) do
					table.insert(result,
						('[[Category:Character boxes with corrected names]]Corrected: %s'):format(
							name
						)
					)
				end
			end

			if classif.alternate then
				for i, name in ipairs(classif.alternate) do
					table.insert(result,
						('[[Category:Character boxes with alternative names]]Alternative: %s'):format(
							name
						)
					)
				end
			end

			if classif.abbreviation then
				table.insert(result,
					('[[Category:Character boxes with abbreviations]]Abbreviation: %s'):format(
						table.concat(classif.abbreviation, ", ")
					)
				)
			end

			local parsed_result = table.concat(result, ", ")

			return '<div>(' .. parsed_result .. ')</div>'

		end

		return ""

	end

	local li, vi, ti = nil, nil, nil

	if block_name == "Hangul Syllables" then
		local m_Kore = require('Module:ko-hangul')
		li, vi, ti = m_Kore.syllable2JamoIndices(codepoint)
	end

	local initial_to_letter = { [0] =
		0x3131, 0x3132, 0x3134, 0x3137, 0x3138, 0x3139, 0x3141, 0x3142,
		0x3143, 0x3145, 0x3146, 0x3147, 0x3148, 0x3149, 0x314A, 0x314B,
		0x314C, 0x314D, 0x314E,
	}

	local vowel_to_letter = { [0] =
		0x314F, 0x3150, 0x3151, 0x3152, 0x3153, 0x3154, 0x3155, 0x3156,
		0x3157, 0x3158, 0x3159, 0x315A, 0x315B, 0x315C, 0x315D, 0x315E,
		0x315F, 0x3160, 0x3161, 0x3162, 0x3163,
	}

	local final_to_letter = {
		0x3131, 0x3132, 0x3133, 0x3134, 0x3135, 0x3136, 0x3137, 0x3139,
		0x313A, 0x313B, 0x313C, 0x313D, 0x313E, 0x313F, 0x3140, 0x3141,
		0x3142, 0x3144, 0x3145, 0x3146, 0x3147, 0x3148, 0x314A, 0x314B,
		0x314C, 0x314D, 0x314E, -- KIYEOK-RIEUL = ???
	}

	local function parse_composition()

		local result = nil

		if block_name == "Hangul Syllables" then

			result = ((ti ~= 0) and
				'<big class="Kore" lang="">[[&#%u;]] + [[&#%u;]] + [[&#%u;]]</big>' or
				'<big class="Kore" lang="">[[&#%u;]] + [[&#%u;]]</big>'):format(
					initial_to_letter[li],
					vowel_to_letter[vi],
					final_to_letter[ti]
				)

		else
			local nfd = mw.ustring.toNFD(mw.ustring.char(codepoint))
			if mw.ustring.len(nfd) ~= 1 then
				local compo = {}

				for nfdcp in mw.ustring.gcodepoint(nfd)	do

					local dotted_circle = (m_unicode.is_combining(nfdcp) and "◌" or "")
					local link_target = m_unicode.get_entry_title(nfdcp)
					if not link_target or not mw.title.new(link_target).exists then
						link_target = nil
					end

					local script = m_unicode.char_to_script(nfdcp)

					local character_text =
						link_target and ('[[&#%u;|<span class="%s">%s&#%u;</span> &#91;U+%04X&#93;]]')
									:format(nfdcp, script, dotted_circle, nfdcp, nfdcp)
						or ('<span class="%s">%s&#%u;</span> &#91;U+%04X&#93;')
									:format(script, dotted_circle, nfdcp, nfdcp)

					table.insert(compo, '<span class="character-sample-secondary">' .. character_text .. '</span> ')
				end

				result = table.concat(compo, " + ")

			end
		end

		if result then
			return "Composition", result, "[[Category:Character boxes with compositions]]"
		end

		return nil

	end

	local function parse_dubeolsik()

		local result = nil

		if block_name == "Hangul Syllables" then

			local dubeolsik_table = {
				['ㅂ'] = 'q'; ['ㅃ'] = 'Q'; ['ㅈ'] = 'w'; ['ㅉ'] = 'W'; ['ㄷ'] = 'e';
				['ㄸ'] = 'E'; ['ㄱ'] = 'r'; ['ㄲ'] = 'R'; ['ㅅ'] = 't'; ['ㅆ'] = 'T';
				['ㅛ'] = 'y'; ['ㅕ'] = 'u'; ['ㅑ'] = 'i'; ['ㅐ'] = 'o'; ['ㅒ'] = 'O';
				['ㅔ'] = 'p'; ['ㅖ'] = 'P'; ['ㅁ'] = 'a'; ['ㄴ'] = 's'; ['ㅇ'] = 'd';
				['ㄹ'] = 'f'; ['ㅎ'] = 'g'; ['ㅗ'] = 'h'; ['ㅓ'] = 'j'; ['ㅏ'] = 'k';
				['ㅣ'] = 'l'; ['ㅋ'] = 'z'; ['ㅌ'] = 'x'; ['ㅊ'] = 'c'; ['ㅍ'] = 'v';
				['ㅠ'] = 'b'; ['ㅜ'] = 'n'; ['ㅡ'] = 'm';

				['ㅘ'] = 'h-k'; ['ㅙ'] = 'h-o'; ['ㅚ'] = 'h-l'; ['ㅝ'] = 'n-j';
				['ㅞ'] = 'n-p'; ['ㅟ'] = 'n-l'; ['ㅢ'] = 'm-l';

				['ㄳ'] = 'r-t'; ['ㄶ'] = 's-g'; ['ㄽ'] = 'f-t'; ['ㄵ'] = 's-w';
				['ㄺ'] = 'f-r'; ['ㄻ'] = 'f-a'; ['ㄼ'] = 'f-q'; ['ㅆ'] = 'T';
				['ㄾ'] = 'f-x'; ['ㄿ'] = 'f-v'; ['ㅀ'] = 'f-g'; ['ㅄ'] = 'q-t';
			}

			result = ((ti ~= 0) and
				'%s-%s-%s\n' or
				'%s-%s\n'):format(
					dubeolsik_table[mw.ustring.char(initial_to_letter[li])],
					dubeolsik_table[mw.ustring.char(vowel_to_letter[vi])],
					dubeolsik_table[mw.ustring.char(final_to_letter[ti] or 0)] -- or 0 to silence an error
				)
		end


		if result then
			return "''[[w:Keyboard_layout#Hangul|Dubeolsik]]'' input", result, ""
		end

		return nil

	end


	local function parse_languages()

		if args.langs then
			return "Used in languages", args.langs, "[[Category:Character boxes with languages]]"
		end

		return nil

	end

	local function parse_standards()

		if args.standards then
			return "In other standards", args.standards, "[[Category:Character boxes with other standards]]"
		end

		return nil

	end

	-- [[ Egyptian Hieroglyphs
	local function parse_gardiner()

		local result = nil

		if args.gardiner then

			result =
			(
				'[http://vincent.euverte.free.fr/Rosette/Rosette_410.php?Hiero=%s&Lang=E %s]\n'):format(
				args.gardiner, args.gardiner
			)

			return "Gardiner number", result, "[[Category:Character boxes with additional information for Egyptian Hieroglyphs]]"
		end

		return nil

	end

	local function parse_mdc()

		local result = nil

		if args.mdc then

			result = args.mdc

			return "Manuel de Codage", result, "[[Category:Character boxes with additional information for Egyptian Hieroglyphs]]"
		end

		return nil

	end

	local function parse_egpz()

		local result = nil

		if args.egpz then

			result = args.egpz

			return "EGPZ 1.0", result, "[[Category:Character boxes with additional information for Egyptian Hieroglyphs]]"
		end

		return nil

	end

	-- ]]

	local function middle_part()

		local rows = {}

		local function insert_row(row_title, row_contents, row_category)

			if row_contents then

				table.insert(rows,
					('<tr><td style="text-align: left">%s:</td><td>%s%s</td></tr>'):format(row_title, row_contents, row_category))

			end

		end

		insert_row(parse_composition())
		insert_row(parse_dubeolsik())
		insert_row(parse_languages())
		insert_row(parse_standards())
		insert_row(parse_gardiner())
		insert_row(parse_egpz())
		insert_row(parse_mdc())

		if rows[1] then

			return ('<table style="margin: 0 auto;">%s</table>')
				:format(table.concat(rows, ""))

		end

		return ""

	end

	local function present_codepoint(codepoint, np, script, combining, name, printable, title)
		local display
		local link_target

		if combining then
			combining = to_boolean(combining)
		else
			combining = m_unicode.is_combining(codepoint)
		end

		if printable then
			printable = to_boolean(printable)
		else
			printable = m_unicode.is_printable(codepoint)
		end

		if printable then
			if title == "self" then
				link_target = mw.ustring.char(codepoint)
			elseif title ~= "" then
				link_target = m_unicode.get_entry_title(codepoint)
			end

			display = ('<span class="character-sample-secondary %s">%s&#%u;</span>'):format(
				script or m_unicode.char_to_script(codepoint),
				combining and "◌" or "", codepoint
			)
		end

		return (
			(link_target and '[[%s|' or '<!-- %s -->') .. '<span title="%s">'
			.. (np and '%s →' or '← %s') .. '<br><small>[U+%04X]</small>'
			.. (link_target and '</span>]]' or '</span>')
		):format(
			link_target or "", mw.text.encode(name or m_unicode.lookup_name(codepoint)),
			display or "", codepoint
		)
	end

	local function get_next(codepoint, step)
		-- Skip past noncharacters and reserved characters (Cn), private-use
		-- characters (Co), surrogates (Cs), and control characters (Cc), all
		-- of which have a label beginning in "<" rather than a proper name.
		if step < 0 and 0 < codepoint or step > 0 and codepoint < 0x10FFFF then
			repeat
				codepoint = codepoint + step
			until m_unicode.lookup_name(codepoint):sub(1, 1) ~= "<"
				or not (0 < codepoint and codepoint < 0x10FFFF)
		end

		return codepoint
	end

	local previous_codepoint =
		get_codepoint(args.previous_codepoint, "previous_codepoint")
		and tonumber(args.previous_codepoint, 16) or get_next(codepoint, -1)
	local next_codepoint = get_codepoint(args.next_codepoint, "next_codepoint")
		and tonumber(args.next_codepoint, 16) or get_next(codepoint, 1)

	local combining
	if args.combining then
		combining = to_boolean(args.combining)
	else
		combining = m_unicode.is_combining(codepoint)
	end

	table.insert(table_markup,
		'|-\n| style="width: 70px;" colspan="2" | ' ..
		'<table>' ..
		'<tr>' ..
		'<td>' ..
			('<span class="character-sample-primary %s">%s&#%u;</span>')
				:format(script_code, combining and "◌" or "", codepoint) ..
		'</td>' ..
		'<td>' ..
			(' [http://unicode.org/cldr/utility/character.jsp?a=%.4X U+%.4X]'):format(codepoint, codepoint) ..
			', [[w:List of XML and HTML character entity references|&amp;#' .. codepoint .. ';]]' ..  latex_result .. '\n' ..
		'<div class="character-sample-name">' ..
		mw.text.encode(args.name or m_unicode.lookup_name(codepoint)) ..
		'</div>' ..
		parse_aliases(aliases) ..
		'</td>' ..
		'</tr>' ..
		'</table>'
	)

	table.insert(table_markup,
		middle_part()
	)

	local previous_unassigned_first = previous_codepoint + 1
	local previous_unassigned_last = codepoint - 1
	local next_unassigned_first = codepoint + 1
	local next_unassigned_last = next_codepoint - 1

	local left_unassigned_text
	local right_unassigned_text

	if previous_codepoint == 0 then
		previous_unassigned_first = 0
	end

	if previous_unassigned_first <= previous_unassigned_last or next_unassigned_first <= next_unassigned_last then
		if previous_unassigned_first < previous_unassigned_last then
			left_unassigned_text = ('[unassigned: U+%.4X–U+%.4X]'):format(previous_unassigned_first, previous_unassigned_last)
		elseif previous_unassigned_first == previous_unassigned_last then
			left_unassigned_text = ('[unassigned: U+%.4X]'):format(previous_unassigned_first)
		end

		if next_unassigned_first < next_unassigned_last then
			right_unassigned_text = ('[unassigned: U+%.4X–U+%.4X]'):format(next_unassigned_first, next_unassigned_last)
		elseif next_unassigned_first == next_unassigned_last then
			right_unassigned_text = ('[unassigned: U+%.4X]'):format(next_unassigned_first)
		end
	end

	local unassignedsRow =
		mw.html.create('table'):css('width', '100%'):css('font-size', '80%'):css('white-space', 'nowrap')
			:tag('tr')
				:tag('td'):css('width', '50%'):css('text-align', 'left'):wikitext(left_unassigned_text or ''):done()
				:tag('td'):css('width', '50%'):css('text-align', 'right'):wikitext(right_unassigned_text or ''):done()
			:allDone()
	table.insert(table_markup, tostring(unassignedsRow) ..'\n')
	if left_unassigned_text or right_unassigned_text then
		table.insert(table_markup,
			'[[Category:Character boxes with unassigned previous/next codepoints| ' .. string.format('%06X', codepoint) .. ']]')
	end

	local previous_codepoint_text = ""
	local next_codepoint_text = ('%s\n')
		:format(present_codepoint(next_codepoint, true,
			args.next_codepoint_sc, args.next_codepoint_combining,
			args.next_codepoint_name, args.next_codepoint_printable,
			args.next_codepoint_title))

	if previous_codepoint > 0 then
		previous_codepoint_text = ('%s\n')
			:format(present_codepoint(previous_codepoint, false,
				args.previous_codepoint_sc, args.previous_codepoint_combining,
				args.previous_codepoint_name, args.previous_codepoint_printable,
				args.previous_codepoint_title))
	end

	local block_name_text = ('[[Appendix:Unicode/%s|%s]][[Category:%s block|*%010d]]\n')
		:format(block_name, block_name, block_name, codepoint)

	local lastRow =
		mw.html.create('table'):css('width', '100%'):css('text-align', 'center')
			:tag('tr')
				:tag('td'):css('width', '20%'):wikitext(previous_codepoint_text):done()
				--:tag('td'):css('width', '15%')
				--	:tag('span'):wikitext(left_unassigned_text and "'''...'''" or ""):attr('title', left_unassigned_text or ""):done():done()
				:tag('td'):css('width', '60%'):css('font-size', '110%'):css('font-weight', 'bold'):wikitext(block_name_text)
				--:tag('td'):css('width', '15%')
				--	:tag('span'):wikitext(right_unassigned_text and "'''...'''" or ""):attr('title', right_unassigned_text or ""):done():done()
				:tag('td'):css('width', '20%'):wikitext(next_codepoint_text):done()
			:allDone()

	table.insert(table_markup, tostring(lastRow) ..'\n')

	table.insert(table_markup, '|}')

	if cat_name then
		table.insert(table_markup, "[[Category:" .. cat_name .. "| " .. mw.ustring.char(codepoint) .. "]]")
	end

	table.insert(table_markup, require("Module:TemplateStyles")("Template:character info/style.css"))

	return table.concat(table_markup)
end

function export.show(frame)
	local parent_frame = frame:getParent()
	return export._show(parent_frame.args, parent_frame:getTitle())
end

return export
