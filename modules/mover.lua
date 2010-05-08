local function getEffectiveScale(self)
 return self.GetEffectiveScale and self:GetEffectiveScale() or self:GetParent():GetEffectiveScale()
end

local function getAbsAnchorPos(self, anchor)
	local x, y
	if(anchor:match("TOP")) then
		y = self:GetTop()
	elseif(anchor:match("BOTTOM")) then
		y = self:GetBottom()
	else
		y = select(2, self:GetCenter())
	end

	if(anchor:match("LEFT")) then
		x = self:GetLeft()
	elseif(anchor:match("RIGHT")) then
		x = self:GetRight()
	else
		x = self:GetCenter()
	end

	local eff = getEffectiveScale(self)
	return x*eff, y*eff
end

local mover = CreateFrame("Button", nil, UIParent)
mover:SetPoint("CENTER")
mover:SetMovable(true)
mover:SetScript("OnMouseDown", mover.StartMoving)
mover:SetBackdrop{
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 16, edgeSize = 16,
	insets = {left = 4, right = 4, top = 4, bottom = 4},
}
mover:SetBackdropColor(0, 0, 0, 0.5)
mover:SetBackdropBorderColor(1, 0.5, 0.5, 1)

local coord = mover:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
coord:SetPoint("BOTTOMLEFT", mover, "TOPLEFT", 0, 5)

local anchorA, effA, bX, bY
local effM = getEffectiveScale(mover)

mover:SetScript("OnMouseUp", function(self, button)
	mover:StopMovingOrSizing()

	local x, y = getAbsAnchorPos(mover, anchorA)
	coord:SetFormattedText("rel: %d, %d", (x-bX)/effA, (y-bY)/effA)

	if(button == "RightButton") then self:Hide() end
end)

function LuaConsole:Mover(regionA)
	local regionB, anchorB
	anchorA, regionB, anchorB = regionA:GetPoint()

	effA = getEffectiveScale(regionA)

	bX, bY = getAbsAnchorPos(regionB, anchorB)

	mover:SetWidth(regionA:GetWidth() * effA / effM)
	mover:SetHeight(regionA:GetHeight() * effA / effM)

	mover:Show()
end

LuaConsole.KeyWords["^mover "] = function(text)
	return "LuaConsole:Mover("..text..")"
end
