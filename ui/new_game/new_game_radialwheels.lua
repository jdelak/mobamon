-- new_game_radialWheels.lua
-- functionality for the ping wheel and chat wheel
local floor = math.floor
local ceil	= math.ceil
local max	= math.max
local min	= math.min
local interface = object
gameUI = gameUI or {}

local radialWaitTime = GetCvarNumber('cg_commandDialOpen')

-- Register Ping Wheel
function registerRadialCommand(object)
	local waitingThread = nil
	local rotatingThread = nil
	local masterWidget = object:GetWidget("radial_selection_command")
	
	masterWidget:RegisterWatchLua('PingWheelInfo', function(widget, trigger)
		local startX = tonumber(string.sub(trigger.mousePos, 0, string.find(trigger.mousePos, " ")))
		local startY = tonumber(string.sub(trigger.mousePos,    string.find(trigger.mousePos, " ")+1))
		openRadialCommand(1, Input.GetCursorPosX()-startX, Input.GetCursorPosY()-startY, trigger.worldPos, trigger.isMiniMap)
	end)
end

-- Register Chat Wheel
function registerRadialChat(object)
	local waitingThread = nil
	local rotatingThread = nil
	local masterWidget = object:GetWidget("radial_selection_chat")
	
	masterWidget:RegisterWatch('gameShowChatWheel', function(widget, keyDown)
		if AtoB(keyDown) then	
			openRadialChat(1)
		else
			if GameUI.RadialSelection.RadialSelectionOpen['chat'] then
				GameUI.RadialSelection.confirmSelection()
			end
			GameUI.RadialSelection:hide('chat')
		end	
	end)
end

local function heroRegister(object)
	if (Strife_Region.regionTable[Strife_Region.activeRegion]) and (Strife_Region.regionTable[Strife_Region.activeRegion].disabledFeatures ~= nil)  and (not (type(Strife_Region.regionTable[Strife_Region.activeRegion].disabledFeatures)=='table' and libGeneral.isInTable(Strife_Region.regionTable[Strife_Region.activeRegion].disabledFeatures, 'chat_wheel'))) then
		registerRadialChat(object)
		if not GetCvarBool('cg_ChatWheelEnabled') then
			SetSave('cg_ChatWheelEnabled', 'true', 'bool')
			SetSave('cg_chatWheelOpen', '100', 'int')
		end		
	end
	
	if (Strife_Region.regionTable[Strife_Region.activeRegion]) and (Strife_Region.regionTable[Strife_Region.activeRegion].disabledFeatures ~= nil)  and (not (type(Strife_Region.regionTable[Strife_Region.activeRegion].disabledFeatures)=='table' and libGeneral.isInTable(Strife_Region.regionTable[Strife_Region.activeRegion].disabledFeatures, 'command_wheel'))) then
		registerRadialCommand(object)	
		if not GetCvarBool('cg_CommandDial_Enabled') then
			SetSave('cg_CommandDial_Enabled', 'true', 'bool')
			SetSave('cg_commandDialOpen', '100', 'int')
		end	
	end
end

heroRegister(object)	