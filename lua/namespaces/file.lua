function NS:Exists(filename)
	local f = file.Open(filename, "r", "GAME")
	return f
end

function NS:Read(filename)
	local f = file.Open(filename, "r", "GAME")
	
	if (!f) then error('File doesn\'t exist.', 0) end
	
	local str = f:ReadString(f:Size())
	f:Close()
	
	return str
end

function NS:Write(filename, content)
	local f = file.Open(filename, "w", "DATA")
	
	if (!f) then error('Couldn\'t open file for writing.', 0) end
	
	f:Write(content)
	f:Close()
	
	return true
end

function NS:Append(filename, content)
	local f = file.Open(filename, "a", "GAME")
	
	if (!f) then error('Couldn\'t open file for appending.', 0) end
	
	f:Write(content)
	f:Close()
	
	return true
end