require('glsock2')

local port = 6678

local authentication = {
	username = 'thisisausername',
	password = 'thisisapassword',
	key = 'thisisakey'
}

local function CheckAuthentication(headerdata)
	local headers = string.gmatch(headerdata, "(%w+): (%w+)")
	
	-- TODO: Implement this
	
	return true
end

local function ParseRequest(headerdata)
	local lines = string.Split(headerdata, "\r\n")
	
	local uri_string = table.remove(lines, 1)
	local uri_params = {}
	
	for k, v in string.gmatch(uri_string, "(%w+)=(%w+)") do
		uri_params[k] = v
	end
	
	local headers = {}
	
	for _, line in pairs(lines) do
		-- parse the other headers
	end
	
	local namespace = uri_params.namespace
	local method = uri_params.method
	
	uri_params.namespace = nil
	uri_params.method = nil
	
	return { namespace = namespace, method = method, args = uri_params }, headers
end

local function OnReadHeader(sock, data, errno)	
	if errno == GLSOCK_ERROR_SUCCESS then
		local read, headerdata = data:Read(data:Size())
		
		local params, headers = ParseRequest(headerdata)
		
		local buffer = GLSockBuffer()
		buffer:Write("HTTP/1.1 200 OK\r\n")
		buffer:Write("Connection: close\r\n")
		buffer:Write("Server: JSONAPI\r\n")
		buffer:Write("Content-Type: application/json\r\n")
		
		local result
		
		if(CheckAuthentication(headerdata)) then
			result = api.Call(params.namespace, params.method, params.args) or ""
		else
			result = api.Error('Authentication failed.')
		end
		
		buffer:Write("Content-Length: " .. string.len(result) .. "\r\n")
		buffer:Write("\r\n")
		
		buffer:Write(result)
		
		sock:Send(buffer, function() end)
	else
		MsgN('JSON API SERVER: [error] Failed to read headerdata (' .. errno .. ')')
	end
end

local function OnAccept(sock, client, errno)
	if errno == GLSOCK_ERROR_SUCCESS then
		MsgN('JSON API SERVER: [info] New connection from ' .. tostring(client))
		
		client:Read(100, OnReadHeader)
		
		sock:Accept(OnAccept)
	else
		MsgN('JSON API SERVER: [error] Failed to accept (' .. errno .. ')')
	end
end

local function OnListen(sock, errno)
	if errno == GLSOCK_ERROR_SUCCESS then
		MsgN('JSON API SERVER: [info] Listening on port ' .. port)
		sock:Accept(OnAccept)
	else
		MsgN('JSON API SERVER: [error] Failed to listen on port ' .. port .. ' (' .. errno .. ')')
	end
end

local function OnBind(sock, errno)
	if errno == GLSOCK_ERROR_SUCCESS then
		MsgN('JSON API SERVER: [info] Bound to port ' .. port)
		sock:Listen(10, OnListen)
	else
		MsgN('JSON API SERVER: [error] Failed to bind to port ' .. port .. ' (' .. errno .. ')')
	end
end

hook.Add('InitPostEntity', 'api.InitPostEntity', function()
	local socket = GLSock(GLSOCK_TYPE_ACCEPTOR)
	socket:Bind("", port, OnBind)
end)