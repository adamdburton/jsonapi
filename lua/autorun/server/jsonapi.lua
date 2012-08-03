include('api.lua')
include('server.lua')

api.LoadNamespaces()

-- json_encode tests
concommand.Add('json_encode', function(ply, cmd, args)
	MsgN('-- json_encode test --')

	local t = {
		[1] = 'numbered index with string',
		test = 'string index with string',
		[3] = 456,
		player = player.GetAll()[1],
		vector = Vector(123, 456, 789),
		angle = Angle(1, 2, 3),
		sequentialtable = {
			'this', 'is', 'a', 'table'
		},
		nonsequentialtable = {
			a = 'b',
			'what'
		},
		worldEntity = GetWorldEntity()
	}
	
	--for i = 1, 100 do
	--	t[i] = i
	--end
	
	file.Write('test.txt', json_encode(t))
	--MsgN(json_encode(t))
	MsgN('-- end json_encode test --')
end)