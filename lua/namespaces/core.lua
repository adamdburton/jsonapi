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
			t[k] = get_args(v)
		end
	end
	
	return t
end