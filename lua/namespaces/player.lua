function NS:GetByUniqueID(uniqueid)
	local ply = player.GetByUniqueID(uniqueid)
	
	if not ply then
		error('Invalid player.', 0)
	end
	
	return ply
end

function NS:GetBySteamID(steamid)
	local players = player.GetAll()
	
	for _, ply in pairs(players) do
		if ply:SteamID() == steamid then
			return ply
		end
	end
	
	error('Couldn\'t find player with that SteamID.', 0)
end

function NS:GetBySteamID64(steamid64)
	local players = player.GetAll()
	
	for _, ply in pairs(players) do
		if ply:SteamID64() == steamid64 then
			return ply
		end
	end
	
	error('Couldn\'t find player with that SteamID64.', 0)
end

function NS:GetAll()
	return player.GetAll()
end

------------------------------------------------------

function NS:Ban(steamid64, minutes, reason)
	local ply = api.Call('player', 'GetBySteamID64', { steamid64 = steamid64 }, true)
	
	ply:Ban(minutes, reason)
	ply:Kick(reason)
end

function NS:ChatPrint(steamid64, message)
	local ply = api.Call('player', 'GetBySteamID64', { steamid64 = steamid64 }, true)
	
	ply:ChatPrint(message)
end

function NS:ConCommand(steamid64, command)
	local ply = api.Call('player', 'GetBySteamID64', { steamid64 = steamid64 }, true)
	
	ply:ConCommand(command)
end

function NS:GetPData(steamid64, key)
	local ply = api.Call('player', 'GetBySteamID64', { steamid64 = steamid64 }, true)
	
	ply:GetPData(key, nil)
end

function NS:Kick(steamid64, reason)
	local ply = api.Call('player', 'GetBySteamID64', { steamid64 = steamid64 }, true)
	
	ply:Kick(reason)
end

function NS:SetPData(steamid64, key, value)
	local ply = api.Call('player', 'GetBySteamID64', { steamid64 = steamid64 }, true)
	
	ply:SetPData(key, value)
end

------------------------------------------------------

util.AddNetworkString('PlayerInfo')

hook.Add('PlayerInitialSpawn', 'api.GetPlayerInfo', function(ply)
	ply:SendLua('net.Start("PlayerInfo") net.WriteString((system.IsLinux() and "Linux") or (system.IsWindows() and "Windows") or (system.IsOSX() and "OSX")) net.WriteString(system.GetCountry()) net.SendToServer()')
end)

net.Receive("PlayerInfo", function(length, ply)
	ply.OS = net.ReadString()
	ply.Country = net.ReadString()
end)