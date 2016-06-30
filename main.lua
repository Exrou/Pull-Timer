--[[
							P U L L  T I M E R
      -----------------------------------------------------------------
							 Date: 06/11/2016
					   Game: RIFT - Planes of Telara
	  -----------------------------------------------------------------
--]]

local ptAddonID = "PT01"

local pull = nil

local secs = nil

local pull_initiated = false

local context = UI.CreateContext("SampleContext")

local colorize
local extractColors
local loadVars
local messages
local slash_pt
local updateTimer
local initPull
local spam
local round

-------------------------------------------------------
-- // ADD-ON FRAME
-------------------------------------------------------
local timer = UI.CreateFrame("Text", "SampleText", context)
timer:SetFontSize(250)
timer:SetFontColor(1, 0, 0, 1)
timer:SetText("Debug")
timer:SetWidth(timer:GetWidth())
timer:SetHeight(timer:GetHeight())
timer:SetPoint("TOPCENTER", UIParent, "TOPCENTER", 275, 250)
timer:SetVisible(false)

-------------------------------------------------------
-- // COLOR FUNCTION
-------------------------------------------------------
function colorize(text, fromHex, toHex)
	local colored = {}
	local len = text:len() - 1

	local from = {extractColors(fromHex)}
	local to = {extractColors(toHex)}

	local step = {
		r = (to[1] - from[1]) / len,
		g = (to[2] - from[2]) / len,
		b = (to[3] - from[3]) / len
	}

	for char in text:gmatch(".") do
		if char == " " then
			table.insert(colored, " ")
		else
			table.insert(colored, ("<font color=\"#%02x%02x%02x\">%s</font>"):format(from[1], from[2], from[3], char))
		end
		from[1] = from[1] + step.r
		from[2] = from[2] + step.g
		from[3] = from[3] + step.b
	end

	return table.concat(colored)
end

function extractColors(num)
	return bit.rshift(num, 16), bit.band(bit.rshift(num, 8), 0xff), bit.band(num, 0xff)
end

-------------------------------------------------------
-- // MESSAGE: INIT
-------------------------------------------------------
function loadVars(addon)
	if addon == "PullTimer" then
		Command.Console.Display("general", true, colorize("Pull Timer v1.0 loaded. /pt # (# is an input number between 0 and 59).", 0xC03029, 0xDDD03A), true)
	end
end

-------------------------------------------------------
-- // MESSAGE: RAID/PARTY
-------------------------------------------------------
function messages(handle, from, messagetype, channel, id, data)
	if channel == nil and id == ptAddonID and (messagetype == "party" or messagetype == "raid") then
		local seconds = data
		initPull(tonumber(seconds))
		if (tonumber(seconds) == 1) then
			Command.Console.Display("general", true, colorize(from, 0x00D0FF, 0x00D0FF) .. " has initiated a " .. colorize(data, 0xFF0000, 0xFF0000) .. " second pull timer.", true)
		else
			Command.Console.Display("general", true, colorize(from, 0x00D0FF, 0x00D0FF) .. " has initiated a " .. colorize(data, 0xFF0000, 0xFF0000) .. " seconds pull timer.", true)
		end
	end
end

-------------------------------------------------------
-- // SLASH COMMAND HANDLER
-------------------------------------------------------
function slash_pt(handle, parameter)
	if (tonumber(parameter) ~= nil and tonumber(parameter) > 0 and tonumber(parameter) < 59) then
		secs = tonumber(parameter)
		if (tonumber(parameter) == 1) then
			Command.Console.Display("general", true, "You initiated a " .. colorize(parameter, 0xFF0000, 0xFF0000) .. " second pull timer.", true)
		else
			Command.Console.Display("general", true, "You initiated a " .. colorize(parameter, 0xFF0000, 0xFF0000) .. " seconds pull timer.", true)
		end

		-- Party/Raid Broadcast
		Command.Message.Broadcast("party", nil, ptAddonID, tostring(secs));
		Command.Message.Broadcast("raid", nil, ptAddonID, tostring(secs));

		initPull(secs)

	elseif (parameter == "") then
		Command.Console.Display("general", true, colorize("============================", 0x0065FF, 0x00D0FF), true)
		Command.Console.Display("general", true, "  - <font color=\"#FFFF00\">/pt</font> <font color=\"#00D0FF\">number</font>", true)
		Command.Console.Display("general", true, "  - <font color=\"#00D0FF\">number</font> must be an integer between 0 and 59)", true)
		Command.Console.Display("general", true, colorize("============================", 0x0065FF, 0x00D0FF), true)
	else
		Command.Console.Display("general", true, "<font color=\"#FE2E2E\">Invalid input, please enter an integer between 0 and 59.</font>", true)
	end
end

-------------------------------------------------------
-- // MESSAGE: COUNT-DOWN TIMER
-------------------------------------------------------
function updateTimer(n)
	timer:SetText(n)
	timer:SetFontColor(1, 0, 0, 1)
	timer:SetVisible(true)
	-- You can create your own 0 timer message below, just make sure it is the same as the line with [***] below in the "Pull Timer - Initialise" section.
	if n == "" then
		timer:SetFontColor(0, 1, 0, 1)
	else
		timer:SetFontColor(1, 1, 1, 1)
	end
end

-------------------------------------------------------
-- // CALCULATIONS
-------------------------------------------------------
function initPull(n)
	if n == nil then
		return
	end
	pull = Inspect.Time.Frame() + n
	if pull > 59 then
		pull = pull - 60
	end
	pull_initiated = true
end

local previousTime = nil

function spam()
	local time = Inspect.Time.Frame()
	previousTime = time

	if pull_initiated == true and pull ~= nil then

		local remaining = pull - previousTime

		if remaining < -1 then
			remaining = remaining + 60
		end

		if remaining > 9 then
			updateTimer("")
			print(remaining)
		end

		if remaining < 10 then
			updateTimer(string.format("%.1f", remaining))
		end

		if remaining <= 0 and remaining > -1 then
		-- You can create your own 0 timer message below, just make sure it is the same as the line with [***] above in the "Pull Timer - Count Update" section.
			updateTimer("")
		end

		if remaining <= -1 then
			timer:SetVisible(false)
			pull = nil
			pull_initiated = false
		end
	end
end

-------------------------------------------------------
-- // ADD-ON INITIALISATION
-------------------------------------------------------
Command.Message.Accept(nil, ptAddonID)
table.insert(Event.Addon.SavedVariables.Load.End, {loadVars, "PullTimer", "Load variables"})
Command.Event.Attach(Event.Message.Receive, messages, "Event.Message.Receive")
Command.Event.Attach(Event.System.Update.Begin, spam, "Event.System.Update.Begin")
Command.Event.Attach(Command.Slash.Register("pt"), slash_pt, "PullTimerSlashPt")
