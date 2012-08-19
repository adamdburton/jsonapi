function NS:GetCurrent()
	return gmod.GetGamemode()
end

function NS:Change(gamemode)
	if not table.HasValue(GetGamemodes(), gamemode) then
		error('Gamemode doesn\t exist.', 0)
	end
	
	RunConsoleCommand('gamemode', gamemode)
end