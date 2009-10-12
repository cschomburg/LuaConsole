local keys = LuaConsole.KeyWords

LuaConsole.KeyWords["^mouse"] = function(text)
	frame = GetMouseFocus()
	if(text == "") then
		LuaConsole:Print(frame:GetName())
	else
		return "frame"..text
	end
end

keys["^run$"] = function()
	return LuaConsole.ScriptBox:GetText()
end

keys["^height "] = function(text)
	if(text == "full") then
		text = UIParent:GetHeight()
	elseif(text == "default") then
		text = 300
	end
	LuaConsole:SetHeight(text)
end

keys["^clear$"] = function()
	LuaConsole:Clear()
end

keys["^exit$"] = function()
	LuaConsole:Hide()
end

keys["^rl$"] = function()
	ReloadUI()
end

keys["^<<"] = function(text)
	return "LuaConsole:Print("..text..")"
end

keys["^cd "] = function(text)
	if(text == "~") then text = "LuaConsole" end
	return ("LuaConsole:SetCurrentTable($1, '$1')"):gsub("$1", text)
end

keys["^ls"] = function(text)
	if(text:trim() == "") then text = "LuaConsole.GetCurrentTable()" end
	return ("for k,v in pairs($1) do LuaConsole:Print(k, v) end"):gsub("$1", text)
end

keys["%$"] = function(rest, all)
	return all:gsub("%$", "LuaConsole.GetCurrentTable()")
end

keys["~"] = function(rest, all)
	return all:gsub("~", "LuaConsoleHome")
end

keys["^%."] = function(text)
	return "LuaConsole.GetCurrentTable()."..text
end

keys["^%:"] = function(text)
	return "LuaConsole.GetCurrentTable():"..text
end

keys["||"] = function(rest, all)
	return all:gsub("||", "|")
end

keys["^/?help$"] = function(rest, all)
	LuaConsole:AddMessage("Overview over LuaConsole key words:")
	LuaConsole:AddMessage(" |cffee8800height [number]|r: Set the console's height (default 300)")
	LuaConsole:AddMessage(" |cffee8800mouse|r: The currently hovered frame")
	LuaConsole:AddMessage(" |cffee8800whereis [frame]|r: Draw a border around the defined frame")
	LuaConsole:AddMessage(" |cffee8800run|r: Run the code from the script box on the right")
	LuaConsole:AddMessage(" |cffee8800clear|r: Clear all lines")
	LuaConsole:AddMessage(" |cffee8800exit|r: Hide the console")
	LuaConsole:AddMessage(" |cffee8800rl|r: Reload the interface")
	LuaConsole:AddMessage(" |cffee8800<< [code]|r: Output the return values of the lua code")
	LuaConsole:AddMessage(" |cffee8800cd [table]|r: change current table")
	LuaConsole:AddMessage(" |cffee8800ls [table]|r: output contents of a table")
	LuaConsole:AddMessage(" |cffee8800$|r: inserts the current table in your code")
	LuaConsole:AddMessage(" |cffee8800~|r: inserts the the home table in your code")
end