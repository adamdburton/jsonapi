function NS:GetMaxPlayers()
	return MaxPlayers()
end

function NS:BroadcastLua(lua)
	BroadcastLua(lua)
	return true
end

function NS:RunConsoleCommand(command)
	local parts = string.Explode(command, ' ', true)
	local err, res = pcall(RunConsoleCommand, unpack(parts))
	
	return err
end

function NS:BanID(steamid, minutes)
	RunConsoleCommand('banid', minutes, steamid, true)
	
	return true
end

function NS:BanIP(ipaddress, minutes)
	RunConsoleCommand('banip', minutes, ipaddress)
	
	return true
end