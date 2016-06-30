local addon, pt = ...

local bar = {}
bar.__index = bar

function bar.new(context)
	local self = setmetatable({}, bar)
	self.percentage = 0
	self.backgroundUI = UI.CreateFrame("Frame", "BarBackground", context)
	self.backgroundUI:SetPoint("TOPCENTER", UIParent, "TOPCENTER", 0, 250)
	self.backgroundUI:SetBackgroundColor(0,0,0,.7)
	self.innerUI = UI.CreateFrame("Frame", "BarInner", context)
	self.innerUI:SetPoint("CENTERLEFT", self.backgroundUI, "CENTERLEFT", 0, 0)
	self.innerUI:SetBackgroundColor(1,1,1,1)
	self.innerUI:SetLayer(2)
	self.textUI = UI.CreateFrame("Text", "BarText", context)
	self.textUI:SetPoint("CENTERRIGHT", self.backgroundUI, "CENTERRIGHT", -20, 0)
	self.textUI:SetFontColor(.1,.7,1,1)
	self.textUI:SetLayer(3)
	return self
end

function bar:SetPercentage(percentage)
	self.percentage = math.min(1, math.max(0, percentage))
	self.innerUI:SetWidth(self.backgroundUI:GetWidth() * (1-self.percentage))
end

function bar:SetText(text)
	self.textUI:SetText(text)
end

function bar:SetFontSize(size)
	self.textUI:SetFontSize(size)
end

function bar:SetWidth(width)
	self.backgroundUI:SetWidth(width)
	self.innerUI:SetWidth(width * (1-self.percentage))
end

function bar:SetHeight(height)
	self.backgroundUI:SetHeight(height)
	self.innerUI:SetHeight(height)
end

function bar:SetVisible(visible)
	self.backgroundUI:SetVisible(visible)
	self.innerUI:SetVisible(visible)
	self.textUI:SetVisible(visible)
end


pt.Bar = bar