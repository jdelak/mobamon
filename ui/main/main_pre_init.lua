-- Beginning-main initialization stuff
mainUI 					= mainUI 					or {}
mainUI.savedLocally 	= mainUI.savedLocally 		or {}
mainUI.savedRemotely 	= mainUI.savedRemotely 		or {}
mainUI.savedAnonymously	= mainUI.savedAnonymously 	or {}

-- Main values for other interfaces to use
mainUI.MainValues = mainUI.MainValues or {}
mainUI.MainValues.lobby			= 12
mainUI.MainValues.profile		= 23
mainUI.MainValues.options		= 26
mainUI.MainValues.controlPresets= 43
mainUI.MainValues.news			= 101
mainUI.MainValues.preGame		= 102
mainUI.MainValues.TOS			= 103
mainUI.MainValues.selectMode	= 104
mainUI.MainValues.captainsMode	= 105
mainUI.MainValues.blank			= 9999

Friends = Friends or {}
Friends.friendData = {}

WindowManager.CloseAllWindowsExceptMainWindow()

local function GetCvarBool(cvar, checkForNil)
	--println('GetCvarBool: ' .. tostring(cvar))
	if (cvar) then
		if (Cvar.GetCvar(cvar)) then
			return Cvar.GetCvar(cvar):GetBoolean()
		elseif (checkForNil) then
			return nil
		else
			return false
		end
	else
		println('GetCvarBool: ' .. tostring(cvar))
	end		
end

if (not GetCvarBool('_resetTabCaps09')) then
	SetSave('_resetTabCaps09', 'true', 'bool')
	if GetCvarBool('ui_scoreboardDefaultsToTab') then
		Cmd([[GameBind gameShowMoreInfo TriggerToggle "gameShowMoreInfo" button game "CAPS_LOCK" "F1"]])
		Cmd([[GameBind gameToggleScoreboard TriggerToggle "gameToggleScoreboard" button game "TAB" "INVALID"]])
	else
		Cmd([[GameBind gameShowMoreInfo TriggerToggle "gameShowMoreInfo" button game "CAPS_LOCK" "F1"]])
		Cmd([[GameBind gameToggleScoreboard TriggerToggle "gameToggleScoreboard" button game "TAB" "INVALID"]])
	end
end
