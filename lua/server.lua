require('glsock')

local port = 6678

local authentication = {
	username = 'thisisausername',
	password = 'thisisapassword',
	key = 'thisisakey'
}

local function CheckAuthentication(headerdata)
	-- TODO: Implement this
	return true
end

local function ParseHeaders(headerdata)
	local lines = string.Split(headerdata, "\r\n")
	
	local http_method = string.gmatch(lines[1], "(%w+)=(%w+)")
	
	local namespace = http_method.namespace
	local method = http_method.method
	
	http_method.namespace = nil
	http_method.method = nil
		
	return { namespace = namespace, method = method, args = http_method }
end

local function OnReadHeader(sock, data, errno)
	if errno == GLSOCK_ERROR_SUCCESS then
		local read, headerdata = data:Read(data:Size())
		
		local params = ParseRequest(headerdata)
		
		local buffer = GLSockBuffer()
		buffer:Write("HTTP/1.1 200 OK\r\n")
		buffer:Write("Connection: close\r\n")
		buffer:Write("Server: JSONAPI\r\n")
		buffer:Write("Content-Type: application/json\r\n")
		buffer:Write("\r\n")
		
		if(CheckAuthentication(headerdata)) then
			buffer:Write(api.Call(params.namespace, params.method, params.args))
		else
			buffer:Write(api.Error('Authentication failed.'))
		end
		
		sock:Send(buffer, function() end)
	else
		MsgN('JSON API: [error] Failed to read headerdata (' .. errno .. ')')
	end
end

local function OnAccept(sock, client, errno)
	if errno == GLSOCK_ERROR_SUCCESS then
		MsgN('JSON API: [info] New connection from ' .. tostring(client))
		
		client:ReadUntil("\r\n\r\n", OnReadHeader)
		
		sock:Accept(OnAccept)
	else
		MsgN('JSON API: [error] Failed to accept (' .. errno .. ')')
	end
end

local function OnListen(sock, errno)
	if errno == GLSOCK_ERROR_SUCCESS then
		MsgN('JSON API: [info] Listening on port ' .. port)
		sock:Accept(OnAccept)
	else
		MsgN('JSON API: [error] Failed to listen on port ' .. port .. ' (' .. errno .. ')')
	end
end

local function OnBind(sock, errno)
	if errno == GLSOCK_ERROR_SUCCESS then
		MsgN('JSON API: [info] Bound to port ' .. port)
		sock:Listen(10, OnListen)
	else
		MsgN('JSON API: [error] Failed to bind to port ' .. port .. ' (' .. errno .. ')')
	end
end

--[[ Don't bother for now until the binary modules are fixed
hook.Add('InitPostEntity', 'api.InitPostEntity', function()
	local socket = GLSock(GLSOCK_TYPE_ACCEPTOR)
	socket:Bind("", port, OnBind)
end)
]]--