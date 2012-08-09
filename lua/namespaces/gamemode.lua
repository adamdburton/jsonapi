function NS:GetGamemode()
	return gmod.GetGamemode()
end

function NS:ChangeGamemode(gamemode)
	if not table.HasValue(GetGamemodes(), gamemode) then
		error('Gamemode doesn\t exist.', 0)
	end
	
	RunConsoleCommand('gamemode', gamemode)
end