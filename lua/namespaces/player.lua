function NS:GetPlayer(uniqueid)
	local ply = player.GetByUniqueID(uniqueid)
	
	if not ply then
		error('Invalid player.', 0)
	end
	
	return ply
end

function NS:GetPlayers()
	local t = {}
	
	for k, v in pairs(player.GetAll()) do
		local ply = api.Call('player', 'GetPlayer', { uniqueid = v:UniqueID() }, true)
		table.insert(t, ply)
	end
	
	return t
end