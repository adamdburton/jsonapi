function NS.GetGamemodes()
	return GetGamemodes()
end

function NS.ChangeGamemode(gamemode)
	if not table.HasValue(GetGamemodes(), gamemode) then
		error('Gamemode doesn\t exist.', 0)
	end
	
	RunConsoleCommand('changegamemode ' .. game.GetMap() .. ' ' .. gamemode)
end