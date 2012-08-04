function NS.GetCurrentMap()
	return game.GetMap()
end

function NS.GetNextMap()
	return game.GetMapNext()
end

function NS.GetMaps()
	local t = {}
	
	for k, v in pairs(file.Find('maps/*.bsp', "GAME")) do
		table.insert(t, string.gsub(string.lower(v), '.bsp', ''))
	end
	
	return t
end

function NS.ChangeMap(map)
	if not file.Exists('maps/' .. map .. '.bsp', "GAME") then
		error('Map doesn\'t exist.', 0)
	end
	
	RunConsoleCommand('changegamemode ' .. map .. ' ' .. GAMEMODE.FolderName)
end