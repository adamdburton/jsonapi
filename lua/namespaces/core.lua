function NS:GetNamespaces()
	local t = {}
	
	for k, v in pairs(api.Namespaces) do
		local ns = api.Call('core', 'GetMethods', { namespace = k }, true)
		t[k] = ns
	end
	
	return t
end

function NS:GetMethods(namespace)
	if not api.Namespaces[namespace] then
		error('Invalid namespace parameter (' .. namespace .. ').', 0)
	end
	
	local t = {}
	
	for k, v in pairs(api.Namespaces[namespace]) do
		if type(v) == 'function' then
			local args = get_args(v)
			
			for k, v in pairs(args) do
				if v == 'self' then
					table.remove(args, k)
				end
			end
			
			t[k] = args
		end
	end
	
	return t
end