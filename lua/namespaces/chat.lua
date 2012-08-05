NS.Dependencies = { 'core' }

function NS:GetLatest(limit)
	return api.Data.ChatHistory
end

function NS:Add(player, text, team, dead)
	hook.Call('PlayerSay', player, text, team, dead)
	-- TODO: Does this need sending to clients too?
end

--------------------------------------

api.Data.ChatHistory = {}

hook.Add('PlayerSay', 'JSONAPI.Chat.PlayerSay', function(ply, text, team)	
	table.insert(api.Data.ChatHistory, {player = ply, text = text, team = team, time = os.time()})
end)