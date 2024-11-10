 local tipContainer	= object:GetWidget('gamePetTip')

 -- Pet tips
local function inventoryRegisterPet(object)
	local activatableID		= 18
	local passiveActiveID	= 17
	local passiveID			= 16

	object:GetWidget('gamePetTipDescription'):RegisterWatchLua('HeroUnit', function(widget, trigger)
		widget:SetText(trigger.familiarDescription)
	end, false, nil, 'familiarDescription')

	object:GetWidget('gamePetTipIcon'):RegisterWatchLua('HeroUnit', function(widget, trigger)
		if (trigger.familiar) and ValidateEntity(trigger.familiar) then
			widget:SetTexture(GetEntityIconPath((trigger.familiar)))
		end
	end, false, nil, 'familiar')	
	
	object:GetWidget('gamePetTipActive'):RegisterWatchLua('ActiveInventory'..activatableID, function(widget, trigger) widget:SetVisible(trigger.exists) end, false, nil, 'exists')
	object:GetWidget('gamePetTipActiveName'):RegisterWatchLua('ActiveInventory'..activatableID, function(widget, trigger) widget:SetText(trigger.displayName) end, false, nil, 'displayName')
	object:GetWidget('gamePetTipActiveIcon'):RegisterWatchLua('ActiveInventory'..activatableID, function(widget, trigger) widget:SetTexture(trigger.icon) end, false, nil, 'icon')
	object:GetWidget('gamePetTipActiveDescription'):RegisterWatchLua('ActiveInventory'..activatableID, function(widget, trigger) widget:SetText(trigger.description) end, false, nil, 'description')
	object:GetWidget('gamePetTipActiveCooldown'):RegisterWatchLua('ActiveInventory'..activatableID, function(widget, trigger) widget:SetText(libNumber.timeFormat(trigger.cooldownTime)) end, false, nil, 'cooldownTime')
	object:GetWidget('gamePetTipActiveHotkey'):RegisterWatchLua('ActiveInventory'..activatableID, function(widget, trigger) widget:SetText(trigger.binding1) end, false, nil, 'binding1')

	object:GetWidget('gamePetTipTriggered'):RegisterWatchLua('ActiveInventory'..passiveActiveID, function(widget, trigger) widget:SetVisible(trigger.exists) end, false, nil, 'exists')
	object:GetWidget('gamePetTipTriggeredName'):RegisterWatchLua('ActiveInventory'..passiveActiveID, function(widget, trigger) widget:SetText(trigger.displayName) end, false, nil, 'displayName')
	object:GetWidget('gamePetTipTriggeredIcon'):RegisterWatchLua('ActiveInventory'..passiveActiveID, function(widget, trigger) widget:SetTexture(trigger.icon) end, false, nil, 'icon')
	object:GetWidget('gamePetTipTriggeredDescription'):RegisterWatchLua('ActiveInventory'..passiveActiveID, function(widget, trigger) widget:SetText(trigger.description) end, false, nil, 'description')
	object:GetWidget('gamePetTipTriggeredCooldown'):RegisterWatchLua('ActiveInventory'..passiveActiveID, function(widget, trigger) widget:SetText(libNumber.timeFormat(trigger.cooldownTime)) end, false, nil, 'cooldownTime')

	object:GetWidget('gamePetTipPassive'):RegisterWatchLua('ActiveInventory'..passiveID, function(widget, trigger) widget:SetVisible(trigger.exists) end, false, nil, 'exists')
	object:GetWidget('gamePetTipPassiveName'):RegisterWatchLua('ActiveInventory'..passiveID, function(widget, trigger) widget:SetText(trigger.displayName) end, false, nil, 'displayName')
	object:GetWidget('gamePetTipPassiveIcon'):RegisterWatchLua('ActiveInventory'..passiveID, function(widget, trigger) widget:SetTexture(trigger.icon) end, false, nil, 'icon')
	object:GetWidget('gamePetTipPassiveDescription'):RegisterWatchLua('ActiveInventory'..passiveID, function(widget, trigger) widget:SetText(trigger.description) end, false, nil, 'description')

end

function gamePetTipShow()
	tipContainer:SetVisible(true)
end

function gamePetTipHide()
	tipContainer:SetVisible(false)
end
inventoryRegisterPet(object)