function NS:GetNamespaces()
	local t = {}
	
	for k, v in pairs(api.namespaces) do
		local ns = api.Call('core', 'getMethods', { namespace = k }, true)
		t[k] = ns
	end
	
	return t
end

function NS:GetMethods(namespace)
	if not api.namespaces[namespace] then
		error('Invalid namespace parameter (' .. namespace .. ').', 0)
	end
	
	local t = {}
	
	for k, v in pairs(api.namespaces[namespace]) do
		if type(v) == 'function' then
			table.insert(t, {method = k, args = get_args(v)})
		end
	end
	
	return t
end