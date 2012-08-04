include('api.lua')
include('server.lua')

api.LoadNamespaces()

-- json_encode tests
concommand.Add('json_encode', function(ply, cmd, args)
	local tstart = SysTime()
	MsgN('-- json_encode test --')

	local t = {
		[1] = 'numbered index with string',
		test = 'string index with string',
		[3] = 456,
		players = player.GetAll(),
		vector = Vector(123, 456, 789),
		angle = Angle(1, 2, 3),
		sequentialtable = {
			'this', 'is', 'a', 'table'
		},
		nonsequentialtable = {
			a = 'b',
			'what'
		},
		--worldEntity = GetWorldEntity()
	}
	
	file.Write('test.txt', json_encode(t))
	--MsgN(json_encode(t))
	MsgN('-- end json_encode test (' .. SysTime() - tstart .. ') --')
end)