local tinsert, tremove, tsort, pi, sin, cos = table.insert, table.remove, table.sort, math.pi, math.sin, math.cos
local interface = object
controlPresets = controlPresets or {}

-- Constants for the not-so-readable controls
local USE_BOOTS = 'ActivateTool "96"'
local PET_ABILITY = 'ActivateTool "18"'
local TELEPORT_HOME = 'ActivateTool "8"'
local DELIVER_ITEMS = 'ActivateTool "11"'

-- This array holds all the control changes for the different schemes
local controlVariantApplyCommands = {
	{ -- 1: Strife default
	},
	{ -- 2: League of Legends
		-- P opens shop, D uses your pet's ability, and B teleports you home
		{'P', 'ToggleShop', true},
		{'D', PET_ABILITY},
		{'F', USE_BOOTS},
		{'B', TELEPORT_HOME},
		{'7', TELEPORT_HOME},
		{'O', 'TriggerToggle "gameShowSkills"'},
		{'C', 'TriggerToggle "gameShowSkills"'},
		{'CTRL+Q', 'LevelupAbility "0"', true},
		{'CTRL+W', 'LevelupAbility "1"', true},
		{'CTRL+E', 'LevelupAbility "2"', true},
		{'CTRL+R', 'LevelupAbility "3"', true},
		{'SHIFT+Q', 'QuickActivateTool "0"'},
		{'SHIFT+W', 'QuickActivateTool "1"'},
		{'SHIFT+E', 'QuickActivateTool "2"'},
		{'SHIFT+R', 'QuickActivateTool "3"'},
		{'Y', 'ToggleLockedCam ""', true},
		{'SHIFT+MOUSER', 'OrderQuickAttack ""', true},
		{'SHIFT+1', 'OrderEmote ""', true},
		{'X', 'OrderAttack ""', true},
	},
	{ -- 3: Dota 2 ZXCVBN uses items
		{'Z', 'ActivateUsableItem "1"'},
		{'X', 'ActivateUsableItem "2"'},
		{'C', 'ActivateUsableItem "3"'},
		{'V', 'ActivateUsableItem "4"'},
		{'B', 'ActivateUsableItem "5"'},
		{'N', 'ActivateUsableItem "6"'},
		{'F4', 'ToggleShop', true},
		{'F3', DELIVER_ITEMS},
		{'G', 'VoicePushToTalk ""', true},
		{'F5', 'TriggerToggle "gamePurchaseCurrentValidBookmark"'},
		
	},
	{ -- 4: Smite wasd moves camera, QERT uses skills
		{'W', 'MoveForward ""'},
		{'A', 'MoveLeft ""'},
		{'S', 'MoveBack	""'},
		{'D', 'MoveRight ""'},
		{'B', TELEPORT_HOME},
		{'1', 'ActivateTool "0"'},
		{'2', 'ActivateTool "1"'},
		{'3', 'ActivateTool "2"'},
		{'4', 'ActivateTool "3"'},
		{'F1', 'LevelupAbility "0"', true},
		{'F2', 'LevelupAbility "1"', true},
		{'F3', 'LevelupAbility "2"', true},
		{'F4', 'LevelupAbility "3"', true},
		{'K', 'TriggerToggle "gameShowSkills"'},
		{'I', 'ToggleShop', true},
		{'R', PET_ABILITY},
		{'Q', USE_BOOTS},
		{'E', DELIVER_ITEMS},
		{'F', 'ActivateUsableItem "1"'},
		{'G', 'ActivateUsableItem "2"'},
		{'H', 'ActivateUsableItem "3"'},
		{'J', 'ActivateUsableItem "4"'},
		{'K', 'ActivateUsableItem "5"'},
		{'L', 'ActivateUsableItem "6"'},
	},
	{ -- 5: Heroes of newerth
		{'ALT+Q', 'ActivateUsableItem "1"'},
		{'ALT+W', 'ActivateUsableItem "2"'},
		{'ALT+E', 'ActivateUsableItem "3"'},
		{'ALT+A', 'ActivateUsableItem "4"'},
		{'ALT+S', 'ActivateUsableItem "5"'},
		{'ALT+D', 'ActivateUsableItem "6"'},
		{'~', DELIVER_ITEMS},
		{'ALT+Z', 'LevelupAbility "0"', true},
		{'ALT+X', 'LevelupAbility "1"', true},
		{'ALT+C', 'LevelupAbility "2"', true},
		{'ALT+V', 'LevelupAbility "3"', true},
		{'L', 'TriggerToggle "gameShowSkills"'},
		{'N', 'OrderEmote ""', true},
		{'V', 'ToggleLockedCam ""', true},
	}
}

-- Helpful function to help apply the control changes from above.
local function changeBind(keybind)
	Cmd('Unbind game ' .. keybind[1])
	local command = 'Button'
	if keybind[3] then command = 'Impulse' end
	Cmd('Bind'..command..' game ' .. keybind[1] .. " " .. keybind[2])
end


local selected = 1;
-- Show the next control set
local function ShowPreset(variant, dontSetImage)
	if not interface then return end
	interface:GetWidget('options_control_presets_image_'..selected):SetVisible(false)
	interface:GetWidget('options_control_presets_image_'..variant):SetVisible(true)
	selected = variant
end

-- Applies the selected control set
local function ApplyPreset()
	if not interface then return end
	Strife_Options:ResetKeybinds()
	for _, v in pairs(controlVariantApplyCommands[tonumber(selected)]) do
		changeBind(v)
	end
	local mainTrigger = LuaTrigger.GetTrigger('mainPanelStatus')
	mainTrigger.main = mainUI.MainValues.options
	mainTrigger:Trigger()
end

local function ControlPresetsRegister(object)
	local parent = interface:GetWidget("control_presets")
	
	local function show()
		parent:FadeIn(styles_mainSwapAnimationDuration)
	end
	local function hide()
		parent:FadeOut(styles_mainSwapAnimationDuration)
	end
	
	-- use main trigger to show/hide
	parent:RegisterWatchLua('mainPanelStatus', function(widget, trigger)
		if trigger.main == mainUI.MainValues.controlPresets then
			show()
		else
			hide()
		end
	end, false, nil, 'main')
	
	-- Swap presets to fit initial font size
	ShowPreset(2, true)
	ShowPreset(1, true)
	
	-- Add options to dropdown
	local dropDown = interface:GetWidget("options_control_presets_SelectCombo")
	for n=1, #controlVariantApplyCommands do
		dropDown:AddTemplateListItem('simpleDropdownItem', tostring(n), 'label', Translate('options_control_presets_'..n))
	end
	dropDown:SetSelectedItemByValue('1', true)
	-- Watch dropdown selection
	dropDown:SetCallback('onselect', function(widget)
		ShowPreset(widget:GetValue())
	end)
	
	-- Apply/Close
	local apply = interface:GetWidget("options_control_presets_apply")
	apply:SetCallback('onclick', function(widget)
		ApplyPreset()
	end)
	
	local cancel = interface:GetWidget("options_control_presets_cancel")
	cancel:SetCallback('onclick', function(widget)
		local mainPanelStatus = LuaTrigger.GetTrigger('mainPanelStatus')
		mainPanelStatus.main = 101
		mainPanelStatus:Trigger(false)
	end)
end

ControlPresetsRegister(object)