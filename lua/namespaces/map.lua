function NS:GetCurrent()
	return game.GetMap()
end

function NS:GetNext()
	return game.GetMapNext()
end

function NS:GetAll()
	local t = {}
	
	for k, v in pairs(file.Find('maps/*.bsp', "GAME")) do
		local map = string.gsub(string.lower(v), '.bsp', '')
		table.insert(t, map)
	end
	
	return t
end

function NS:Change(map)
	if not file.Exists('maps/' .. map .. '.bsp', "GAME") then
		error('Map doesn\'t exist.', 0)
	end
	
	RunConsoleCommand('map', map)
end