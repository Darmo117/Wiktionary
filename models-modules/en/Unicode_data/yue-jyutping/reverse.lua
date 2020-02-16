local data = {}

for i = 0x003, 0x02f do -- change the limits when more data appears
	local success, straight = pcall(mw.loadData, ("Module:Unicode data/yue-jyutping/%03X"):format(i))
	if success then
		for key, readings in pairs(straight) do
			for i, jyut in ipairs(readings) do
				if not data[jyut] then
					data[jyut] = {}
				end
				table.insert(data[jyut], key)
			end
		end
	end
end

return data
