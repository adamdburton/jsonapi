NS.Dependencies = { 'core' }

NS.Chats = {}

function NS:GetLatestChats(limit)
	return self.chats
end

function NS:AddChat(player, text, public)
	hook.Call('PlayerSay', player, text, public)
	-- TODO: Does this need sending to clients too?
end

--------------------------------------

hook.Add('PlayerSay', 'JSONAPI.Chat.PlayerSay', function(ply, text, public)
	local ply = api.Call('player', 'GetPlayer', { uniqueid = ply:UniqueID() }, true)
	
	table.insert(api.namespaces['chat'].chats, {player = ply, text = text, public = public, time = os.time()})
end)