api = {}

api.Namespaces = {}
api.Hooks = {}
api.Data = {}

function api.LoadNamespaces()
	-- Load namespaces
	local f, d = file.Find("namespaces/*.lua", 'LUA')
	
	for _, filename in pairs(f) do
		NS = {}
		NS.__index = NS
		NS.Name = string.gsub(filename, '.lua', '')
		NS.Dependencies = {}
		
		include("namespaces/" .. filename)
		
		api.Namespaces[NS.Name] = NS
	end
	
	-- Check dependencies and remove any namespaces with missing ones.
	for name, namespace in pairs(api.Namespaces) do
		for _, dependency in pairs(namespace.Dependencies) do
			if not api.Namespaces[dependency] then
				RemoveDependentNamespaces(name)
				api.Namespaces[name] = nil
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
	
	if not api.Namespaces[namespace] then
		return api.Error('Invalid namespace parameter (' .. namespace .. ').', plain)
	end
	
	if not api.Namespaces[namespace][method] and not type(api.Namespaces[namespace][method]) == 'function' then
		return api.Error('Invalid method parameter (' .. method .. ') (' .. namespace .. ').', plain)
	end
	
	local func = api.Namespaces[namespace][method]
	
	if not func then
		return api.Error('Invalid function (' .. method .. ') (' .. namespace .. ').', plain)
	end
	
	local function_args = get_args(func)
	
	-- remove the self arg, we pass that anyway
	for k, v in pairs(function_args) do
		if v == 'self' then
			table.remove(function_args, k)
		end
	end
	
	-- Check the arguments table matches up with the function
	for k, v in pairs(function_args) do
		if not call_args[v] then
			return api.Error('Missing argument (' .. v .. ')', plain)
		end
	end
	
	-- Check the number of arguments match
	if table.Count(call_args) != #function_args then
		return api.Error('Incorrect number of parameters to ' .. namespace .. '.' .. method .. ' (expecting ' .. #function_args .. ', got ' .. table.Count(call_args) .. ').', plain)
	end
	
	MsgN('JSON API: [info] Calling ' .. namespace .. '.' .. method .. ' with args: ' .. table.ToString(call_args))
	
	local pcall_args = {}
	
	for _, param in pairs(function_args) do
		table.insert(pcall_args, call_args[param])
	end
	
	local status, ret = pcall(func, api.Namespaces[namespace], unpack(pcall_args))
	
	if status then
		-- Run hooks
		ret = api.RunHook(namespace .. '.' .. method, ret)
		
		return api.Success(ret, plain)
	else
		MsgN('JSON API: [error] (' .. namespace .. '.' .. method .. ') ' .. ret)
		return api.Error(ret, plain)
	end
end

function api.RunHook(hook, data)
	if not api.Hooks[hook] then return data end
	
	-- Run the data through all of the hooks. They can return whatever they like.
	for k, v in pairs(api.Hooks[hook]) do
		data = v(data)
	end
	
	return data
end

function api.RegisterHook(hook, func)
	if not api.Hooks[hook] then
		api.Hooks[hook] = {}
	end
	
	table.insert(api.Hooks[hook], func)
end

function api.Success(data, plain)
	return not plain and json_encode({result = 'success', success = data}) or data
end

function api.Error(message, plain)
	return not plain and json_encode({result = 'error', error = message}) or message
end

---------------------------------------------------------------

-- Thanks and credit to deco for get_args/debug.getparamnames - http://www.facepunch.com/showthread.php?t=884409

function get_args(func)
	local func_paramInfoDict = debug.getinfo(func, 'u')
	local func_paramCount = func_paramInfoDict.nparams
	local func_isVarArg = func_paramInfoDict.isvararg
	local paramNameList = {}
	for i = 1, func_paramCount do
		local param_name, param_value = debug.getlocal(func, i)
		paramNameList[i] = param_name
	end
	return paramNameList, func_isVarArg
end

local function RemoveDependentNamespaces(dependent)
	MsgN('JSON API: [info] Removing namespaces dependent on ' .. dependent.name)
	
	-- Loop all namespaces and remove any namespace that depends on dependent, which in turn removes anything that depends on it, and so on.
	for name, namespace in pairs(api.Namespaces) do
		if table.HasValue(namespace.Dependencies, dependent) then
			api.Namespaces[name] = nil
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

-- Replaced because the default adds  the 'at' argument on the end, which isn't valid json...
function table.concat(tab, at)
	local s = ""
	
	for _, v in pairs(tab) do
		s = s .. v .. at
	end
	
	return string.sub(s, 0, -string.len(at) - 1)
end

-- Replaced because it's ugly...
function table.ToString(tab)
	local s = ''
	
	for k, v in pairs(tab) do
		s = s .. tostring(k) .. ' = "' .. tostring(v) .. '", '
	end
	
	return '{ ' .. string.sub(s, 0, -3) .. ' }'
end

-- Custom json encoding support! May not be the fastest but who cares.
function json_encode(data)
	local function entity_data(ent)
		return IsValid(ent) and {
			entindex = ent:EntIndex(),
			position = ent:GetPos(),
			angle = ent:GetAngles(),
			class = ent:GetClass(),
			color = ent:GetColor(),
			model = ent:GetModel(),
			material = ent:GetMaterial(),
			skin = ent:GetSkin(),
			isworld = ent:IsWorld(),
			isonground = ent:IsOnGround()
		} or false
	end
	
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
		return json_encode(table.Merge(entity_data(data), {
			name = data:Name(),
			uniqueid = data:UniqueID(),
			alive = data:Alive(),
			health = data:Health(),
			armor = data:Armor(),
			deaths = data:Deaths(),
			couching = data:Crouching(),
			frags = data:Frags(),
			isadmin = data:IsAdmin(),
			issuperadmin = data:IsSuperAdmin(),
			isfroze = data:IsFrozen(),
			--isspeaking = data:IsSpeaking(),
			invehicle = data:InVehicle(),
			vehicle = data:GetVehicle(),
			isbot = data:IsBot(),
			ping = data:Ping(),
			ipaddress = data:IPAddress(),
			steamid = data:SteamID(),
			steamid64 = data:SteamID64(),
			weapons = data:GetWeapons(),
			activeweapon = data:GetActiveWeapon():GetClass(),
			team = team.GetName(data:Team()),
			os = data.OS,
			country = data.Country
		}))
	elseif type(data) == 'Vector' then
		return json_encode({x = data.x, y = data.y, z = data.z})
	elseif type(data) == 'Entity' or type(data) == 'Vehicle' then
		return json_encode(entity_data(data))
	elseif type(data) == 'Angle' then
		return json_encode({p = data.p, y = data.y, r = data.r})
	elseif type(data) == 'Weapon' then
		return json_encode(table.Merge(entity_data(data), {
			clip1 = data:Clip1(),
			clip2 = data:Clip2()
		}))
	elseif type(data) == 'boolean' then
		return data == true and 'true' or 'false'
	else
		error("Unhandled type:" .. type(data) .. "\n", 0)
	end
end

-- Here we go!
api.LoadNamespaces()