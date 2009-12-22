local globalNames = setmetatable({}, {__index = function(self, index)
	for k,v in pairs(_G) do
		if(v == index) then
			self[index] = k
			return k
		end
	end
	return tostring(index)
end})
LuaConsole.GlobalNames = globalNames

local typeFormat = LuaConsole.TypeFormat
setmetatable(typeFormat, {__index = function(self, index) return typeFormat.default end})

typeFormat["default"] = function(value)
	return "ffffff", tostring(value)
end

typeFormat["string"] = function(value)
	return "ffff00", '"'..value:gsub("|", "||")..'"'
end

typeFormat["function"] = function(value)
	return "00cc99", globalNames[value]
end

typeFormat["number"] = function(value)
	return "00ff00", value
end

typeFormat["nil"] = function(value)
	return "ff5050", "nil"
end

typeFormat["table"] = function(value)
	local type = (value.GetFrameType and value:GetFrameType()) or (value.GetObjectType and value:GetObjectType())
	return "ee8800", globalNames[value]..(type and "<"..type..">" or "")
end

typeFormat["boolean"] = function(value)
	return "aad372", tostring(value)
end