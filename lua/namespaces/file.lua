function NS.FileExists(filename)
	local f = file.Open(filename, "r", "GAME")
	return f
end

function NS.ReadFile(filename)
	local f = file.Open(filename, "r", "GAME")
	
	if (!f) then error('File doesn\'t exist.', 0) end
	
	local str = f:ReadString(f:Size())
	f:Close()
	
	return str
end

function NS.WriteFile(filename, content)
	local f = file.Open(filename, "w", "GAME")
	
	if (!f) then error('Couldn\'t open file for writing.', 0) end
	
	f:Write(content)
	f:Close()
end

function NS.AppendFile(filename, content)
	local f = file.Open(filename, "a", "GAME")
	
	if (!f) then error('Couldn\'t open file for appending.', 0) end
	
	f:Write(content)
	f:Close()
end