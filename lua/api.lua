api = {}

api.namespaces = {}
api.hooks = {}

function api.LoadNamespaces()
	-- Load namespaces
	for _, filename in pairs(file.Find("namespaces/*.lua", LUA_PATH)) do
		NS = {}
		NS.__index = NS
		NS.dependencies = {}
		
		include("namespaces/" .. filename)
		
		api.namespaces[string.gsub(filename, '.lua', '')] = namespace
	end
	
	-- Check dependencies and remove any namespaces with missing ones.
	for name, namespace in pairs(api.namespaces) do
		for _, dependency in pairs(namespace.dependencies) do
			if not api.namespaces[dependency] then
				api.namespaces[name] = nil
				RemoveDependentNamespaces(name)
			end
		end
	end
end

function api.Call(namespace, method, call_args, plain)	
	call_args = call_args or {}
	plain = plain or false
	
	if not namespace then
		return api.Error('Missing namespace parameter.', plain)
	end
	
	if not method then
		return api.Error('Missing method parameter.', plain)
	end
	
	if not api.namespaces[namespace] then
		return api.Error('Invalid namespace parameter (' .. namespace .. ').', plain)
	end
	
	if not api.namespaces[namespace][method] then
		return api.Error('Invalid method parameter (' .. method .. ').', plain)
	end
	
	local func = api.namespaces[namespace][method]
	
	local function_args = get_args(func)
	
	-- Check the arguments table matches up with the function
	for k, v in pairs(call_args) do
		if not table.HasValue(function_args, k) then
			return api.Error('Unexpected argument (' .. k .. ')', plain)
		end
	end
	
	-- Check the number of arguments match
	if table.Count(call_args) != #function_args then
		return api.Error('Incorrect number of parameters to ' .. namespace .. '.' .. method .. ' (expecting ' .. #function_args .. ', got ' .. table.Count(call_args) .. ').', plain)
	end
	
	MsgN('JSONAPI: [info] Calling ' .. method .. ' in ' .. namespace .. ' with args: ' .. table.ToString(call_args))
	
	local unpack_args = {}
	
	table.insert(unpack_args, api.namespaces[namespace])
	
	for k, v in pairs(call_args) do
		table.insert(unpack_args, v)
	end
	
	local status, ret = pcall(func, unpack(unpack_args))
	
	if status then
		-- Run hooks
		ret = api.RunHook(namespace .. '.' .. method, ret)
		
		return api.Success(ret, plain)
	else
		return api.Error(ret, plain)
	end
end

function api.RunHook(hook, data)
	if not api.hooks[hook] then return data end
	
	-- Run the data through all of the hooks. They can return whatever they like.
	for k, v in pairs(api.hooks[hook]) do
		data = v(data)
	end
	
	return data
end

function api.RegisterHook(hook, func)
	if not api.hooks[hook] then
		api.hooks[hook] = {}
	end
	
	table.insert(api.hooks[hook], func)
end

function api.Success(data, plain)
	return not plain and json_encode({result = 'success', success = data}) or data
end

function api.Error(message, plain)
	--error('JSONAPI: [error] ' .. message, 0)
	return not plain and json_encode({result = 'error', error = message}) or message
end

---------------------------------------------------------------

-- Thanks and credit to deco for get_args

function get_args(f)
	local co = coroutine.create(f)
	local params = {}
	debug.sethook(co, function()
		local i, k = 1, debug.getlocal(co, 2, 1)
		while k do
			if k ~= "(*temporary)" then
				table.insert(params, k)
			end
			i = i+1
			k = debug.getlocal(co, 2, i)
		end
		error("~~end~~")
	end, "c")
	local res, err = coroutine.resume(co)
	if res then
		error("The function provided defies the laws of the universe.", 2)
	elseif string.sub(tostring(err), -7) ~= "~~end~~" then
		error("The function failed with the error: "..tostring(err), 2)
	end
	return params
end

local function RemoveDependentNamespaces(dependent)
	-- Loop all namespaces and remove any namespace that depends on dependent, which in turn removes anything that depends on it, and so on.
	for name, namespace in pairs(api.namespaces) do
		if table.HasValue(namespace.dependencies, dependent) then
			api.namespaces[name] = nil
			api.RemoveDependents(name)
		end
	end
end

-- Why isn't this in lua by default
function table.slice(values, i1, i2)
	local res = {}
	local n = #values
	-- default values for range
	i1 = i1 or 1
	i2 = i2 or n
	if i2 < 0 then
		i2 = n + i2 + 1
	elseif i2 > n then
		i2 = n
	end
	if i1 < 1 or i1 > n then
		return {}
	end
	local k = 1
	for i = i1, i2 do
		res[k] = values[i]
		k = k + 1
	end
	return res
end

function table.concat(tab, at)
	local s = ""
	
	for _, v in pairs(tab) do
		s = s .. v .. at
	end
	
	return string.sub(s, 0, -string.len(at) - 1)
end

-- Custom json encoding support!
function json_encode(data)
	if type(data) == 'table' then
		local t = {}
		if table.IsSequential(data) then
			for k, v in pairs(data) do
				table.insert(t, json_encode(v))
			end
		else
			for k, v in pairs(data) do
				table.insert(t, json_encode(k) .. ':' .. json_encode(v))
			end
		end
		return table.IsSequential(data) and '[' .. table.concat(t, ',') .. ']' or '{' .. table.concat(t, ',') .. '}'
	elseif type(data) == 'string' then
		return '"' .. string.gsub(data, '"', '\\"') .. '"'
	elseif type(data) == 'number' then
		return '"' .. data .. '"'
	elseif type(data) == 'Player' then
		-- TODO: Encode player
		return json_encode(tostring(data))
		--[[
		name = ply:Name(),
		uniqueid = ply:UniqueID(),
		alive = ply:Alive(),
		health = ply:Health(),
		armor = ply:Armor(),
		deaths = ply:Deaths(),
		couching = ply:Crouching(),
		frags = ply:Frags(),
		admin = ply:IsAdmin(),
		superadmin = ply:IsSuperAdmin(),
		vehicle = ply:InVehicle(),
		bot = ply:IsBot(),
		--frozen = ply:Frozen(),
		ping = ply:Ping(),
		steamid = ply:SteamID(),
		position = tostring(ply:GetPos()),
		angles = tostring(ply:GetAngles())
		]]--
	elseif type(data) == 'vehicle' then
		-- TODO: Encode vehicle
		return json_encode('Vehicle [' .. data:GetClass() .. ']')
	elseif type(data) == 'Vector' then
		return json_encode({x = data.x, y = data.y, z = data.z})
	elseif type(data) == 'Entity' then
		-- TODO: Encode entity
		return json_encode({
			entindex = data:EntIndex(),
			position = data:GetPos(),
			angle = data:GetAngles(),
			class = data:GetClass(),
			color = data:GetColor(),
			model = data:GetModel(),
			material = data:GetMaterial(),
			skin = data:GetSkin(),
			world = data:IsWorld(),
			onground = data:IsOnGround()
		})
	elseif type(data) == 'Angle' then
		return json_encode({p = data.p, y = data.y, r = data.r})
	elseif type(data) == 'Weapon' then
		-- TODO: Encode weapon
		return json_encode(tostring(data))
	elseif type(data) == 'boolean' then
		return data == true and 'true' or 'false'
	else
		error("Unhandled type:" .. type(data) .. "\n", 0)
	end
end