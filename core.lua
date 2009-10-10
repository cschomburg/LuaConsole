local LuaConsole = CreateFrame("Frame", "LuaConsole", UIParent)
local inset = 3

BINDING_HEADER_LUACONSOLE = "LuaConsole"
BINDING_NAME_LUACONSOLE = "Open LuaConsole"

-- Just a gimmick
local user = UnitName("player").."@"..GetRealmName()

local prefix
local keywords = {}
LuaConsole.KeyWords = keywords
local currTable, currTableName

typeColors = {
	["string"] = "ffff00",
	["function"] = "00cc99",
	["number"] = "00ff00",
	["nil"] = "ff5050",
	["table"] = "ee8800",
	["boolean"] = "aad372",
}
LuaConsole.TypeColors = typeColors

LuaConsole:Hide()
LuaConsole:SetWidth(UIParent:GetWidth())
LuaConsole:SetHeight(300)
LuaConsole:SetPoint("TOPLEFT", 0, 0)
LuaConsole:SetBackdrop{bgFile=[[Interface\ChatFrame\ChatFrameBackground]]}
LuaConsole:SetBackdropColor(0, 0, 0, 0.5)
LuaConsole:SetFrameStrata("DIALOG")

local prefixText = LuaConsole:CreateFontString()
prefixText:SetFontObject(ChatFontNormal)
prefixText:SetPoint("BOTTOMLEFT", inset, inset)
prefixText:SetText()

local editBox = CreateFrame("EditBox", nil, LuaConsole)
editBox:SetPoint("BOTTOMLEFT", prefixText, "BOTTOMRIGHT", 1, 0)
editBox:SetPoint("BOTTOMRIGHT", LuaConsole, "BOTTOMLEFT", LuaConsole:GetWidth()*0.75, inset)
editBox:SetHeight(16)
editBox:SetFontObject(ChatFontNormal)
editBox:SetAutoFocus(false)
editBox:SetHistoryLines(20)

local outputFrame = CreateFrame("ScrollingMessageFrame", nil, LuaConsole)
outputFrame:SetPoint("TOPLEFT", inset, -inset)
outputFrame:SetPoint("BOTTOMRIGHT", editBox, "TOPRIGHT", 0, 1)
outputFrame:SetFontObject(ChatFontNormal)
outputFrame:SetJustifyH("LEFT")
outputFrame:SetFading(false)
outputFrame:SetHyperlinksEnabled(true)
outputFrame:SetMaxLines(128)
outputFrame:EnableMouseWheel(true)
outputFrame:SetScript("OnMouseWheel", function(self, dir)
	if(dir > 0) then
		if(IsShiftKeyDown()) then
			self:ScrollToTop()
		else
			self:ScrollUp()
		end
	elseif(dir < 0) then
		if(IsShiftKeyDown()) then
			self:ScrollToBottom()
		else
			self:ScrollDown()
		end
	end
end)

local scriptBox = CreateFrame("EditBox", nil, LuaConsole)
scriptBox:SetPoint("BOTTOMLEFT", editBox, "BOTTOMRIGHT", 1, 0)
scriptBox:SetPoint("TOPRIGHT", -inset, -inset)
scriptBox:SetFontObject(ChatFontNormal)
scriptBox:SetAutoFocus(false)
scriptBox:SetMultiLine(true)
scriptBox:SetScript("OnTabPressed", function() editBox:SetFocus() end)
scriptBox:SetScript("OnEscapePressed", function(self) LuaConsole:Hide() end)
LuaConsole.ScriptBox = scriptBox

local cache
local function addToCache(text)
	cache = cache and cache.."\n"..text or text
end

local function processCache()
	getReturnValues = nil
	local text = cache
	cache = nil

	for word, func in pairs(keywords) do
		if(text and text:match(word)) then
			text = func(text:gsub(word, ""), text)
		end
	end

	if(text) then
		local func, errorMsg = loadstring(text)
		if(errorMsg) then return LuaConsole:AddMessage(errorMsg, 1, 0, 0) end
		local success, errorMsg = pcall(func)
		if(not success) then return LuaConsole:AddMessage(errorMsg, 1, 0, 0) end
	end
end

local function setPrefix(text)
	prefix = ("|cff9090ff%s:%s%s|r "):format(user, currTableName, text)
	prefixText:SetText(prefix)
end

LuaConsole:RegisterEvent("PLAYER_LOGIN")
LuaConsole:SetScript("OnEvent", function(self)
	LuaConsoleHome = LuaConsoleHome or {}
	scriptBox:SetText(LuaConsoleHome.ScriptBox or "")
	self:SetCurrentTable()
	setPrefix("$")
end)

scriptBox:SetScript("OnTextChanged", function(self)
	LuaConsoleHome.ScriptBox = scriptBox:GetText()
end)

editBox:SetScript("OnEscapePressed", function(self) LuaConsole:Hide() end)
editBox:SetScript("OnEnterPressed", function(self)
	local text = editBox:GetText()
	editBox:AddHistoryLine(text)
	editBox:SetText("")
	outputFrame:AddMessage(prefix..text)
	addToCache(text)
	if(IsShiftKeyDown()) then
		setPrefix(">")
	else
		processCache()
		setPrefix("$")
	end
end)
editBox:SetScript("OnTextChanged", function(self)
	if(self:GetText() == "^") then
		self:SetText("")
	end
end)
editBox:SetScript("OnShow", function(self)
	self:SetFocus()
end)
editBox:SetScript("OnTabPressed", function() scriptBox:SetFocus() end)

function LuaConsole:AddMessage(...) outputFrame:AddMessage(...) end
function LuaConsole:Clear() outputFrame:Clear() end
function LuaConsole:Print(...)
	local strText
	for i=1, select("#", ...) do
		local value = select(i, ...)
		if(strText) then strText = strText..", " else strText = "" end
		strText = ("%s|cff%s%s|r"):format(strText, typeColors[type(value)] or "ffffff", tostring(value):gsub("|", "||"))
	end
	if(strText) then LuaConsole:AddMessage(strText) end
	ans = ...
end

function LuaConsole:SetCurrentTable(table, name)
	name = name and name:gsub("LuaConsole%.GetCurrentTable%(%)", currTableName)
	currTable = table or LuaConsoleHome
	currTableName = (currTable == _G and "_G") or (currTable == LuaConsoleHome and "~") or name or tostring(table):trim("table: ")
end

function LuaConsole:GetCurrentTable()
	return currTable, currTableName
end
LuaConsole:AddMessage("|cff00ff00Welcome in the LuaConsole! Type in 'help' for more info!")

debug = function(...) LuaConsole:Print("debug:", ...) end