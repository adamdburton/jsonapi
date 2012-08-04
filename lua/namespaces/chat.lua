NS.Dependencies = { 'core' }

function NS:GetLatestChats(limit)
	return api.Data.ChatHistory
end

function NS:AddChat(player, text, public)
	hook.Call('PlayerSay', player, text, public)
	-- TODO: Does this need sending to clients too?
end

--------------------------------------

api.Data.ChatHistory = {}

hook.Add('PlayerSay', 'JSONAPI.Chat.PlayerSay', function(ply, text, public)
	local ply = api.Call('player', 'GetPlayer', { uniqueid = ply:UniqueID() }, true)
	
	table.insert(api.Data.ChatHistory, {player = ply, text = text, public = public, time = os.time()})
end)