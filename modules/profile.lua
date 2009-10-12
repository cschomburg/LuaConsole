local funcString = [[
	local start = GetTime()
	local count = collectgarbage("count")
	for i=1, $iterations do
		$msg
	end
	LuaConsole:Print("%.3fs for %d iterations (used %.2fkb memory)", GetTime()-start, $iterations, collectgarbage("count")-count)
]]

LuaConsole.KeyWords["^profile"] = function(msg)
	local iterations
	iterations, msg = msg:match("^(%x+)%s+(.*)$")
	local str = funcString:gsub("$iterations", iterations):gsub("$msg", msg)
	return str
end

profiled = {}
function profile(name, point)
	local now = GetTime()
	local start = profiled[name] or now
	profiled[name] = now
	if(point ~= "start") then LuaConsole:Print("%.3fs for '%s' of '%s'", now-start, name, point) end
	if(point == "reset") then profiled[name] = nil end
end
