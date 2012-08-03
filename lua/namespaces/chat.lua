NS.dependencies = { 'core' }

NS.chats = {}

function NS:GetLatestChats(limit)
	return table.slice(self.chats, #self.chats, -limit)
end

function NS:AddChat(player, text, public)
	hook.Call('PlayerSay', player, text, public)
	-- TODO: Does this need sending to clients too?
end

--------------------------------------

hook.Add('PlayerSay', 'JSONAPI.Chat.PlayerSay', function(ply, text, public)
	local ply = api.Call('core', 'getPlayer', { uniqueid = ply:UniqueID() }, true)
	
	table.insert(NS.chats, {player = ply, text = text, public = public, time = os.time()})
end)