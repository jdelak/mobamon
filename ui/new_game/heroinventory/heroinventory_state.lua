-- Hero States
local function heroStateRegister(object, index)
	local shadow			= object:GetWidget('heroState'..index..'Shadow')
	local backer			= object:GetWidget('heroState'..index..'Backer')
	local corner			= object:GetWidget('heroState'..index..'Corner')
	local icon				= object:GetWidget('heroState'..index..'Icon')
	local frame				= object:GetWidget('heroState'..index..'Frame')

	local duration				= object:GetWidget('heroState'..index..'Duration')
	local durationBacker		= object:GetWidget('heroState'..index..'DurationBacker')
	local durationBar			= object:GetWidget('heroState'..index..'DurationBar')
	local durationContainer		= object:GetWidget('heroState'..index..'DurationContainer')

	---[[
	durationBacker:RegisterWatchLua('HeroInventory'..index, function(widget, trigger)
		widget:SetVisible(trigger.exists and trigger.duration > 0)
	end, false, nil, 'exists', 'duration')

	durationContainer:RegisterWatchLua('HeroInventory'..index, function(widget, trigger)
		widget:SetVisible(trigger.exists and trigger.duration > 0)
	end, false, nil, 'exists', 'duration')
	--]]
	
	libGeneral.createGroupTrigger('heroState'..index..'TimerLabelVis', {
		'HeroInventory'..index..'.duration',
		'HeroInventory'..index..'.exists',
		'GamePhase.gamePhase'
	})
	
	duration:RegisterWatchLua('heroState'..index..'TimerLabelVis', function(widget, groupTrigger)
		local triggerTimer	= groupTrigger['HeroInventory'..index]
		local duration		= triggerTimer.duration
		local gamePhase		= groupTrigger['GamePhase'].gamePhase
		local exists		= (triggerTimer.exists and gamePhase < 7)
		if exists and duration > 0 then
			widget:SetText(math.ceil(duration * 0.001)..'s')
			widget:SetVisible(true)
		else
			widget:SetVisible(false)
		end
		widget:SetVisible(exists and duration > 0)
	end)	-- , false, nil, 'duration', 'exists'

	durationBar:RegisterWatchLua('HeroInventory'..index, function(widget, trigger) widget:SetWidth(ToPercent(trigger.durationPercent)) end, false, nil, 'durationPercent')
	
	libGeneral.createGroupTrigger('heroState'..index..'vis', {
		'HeroInventory'..index..'.exists',
		'GamePhase.gamePhase'
	})
	
	object:RegisterWatchLua('heroState'..index..'vis', function(widget, groupTrigger)
		local showWidget = (groupTrigger['HeroInventory'..index].exists and groupTrigger['GamePhase'].gamePhase < 7)
		
		frame:SetVisible(showWidget)
		corner:SetVisible(showWidget)
		backer:SetVisible(showWidget)
		icon:SetVisible(showWidget)
		shadow:SetVisible(showWidget)
	end)	-- , false, nil, 'exists'

	icon:RegisterWatchLua('HeroInventory'..index, function(widget, trigger) widget:SetTexture(trigger.icon) end, false, nil, 'icon')
	
	--[[
	backer:RegisterWatchLua('HeroInventory'..index, function(widget, trigger)
		local stateColorR = styles_stateNeutralR
		local stateColorG = styles_stateNeutralG
		local stateColorB = styles_stateNeutralB
		if trigger.isBuff then
			stateColorR = styles_stateBuffR
			stateColorG = styles_stateBuffG
			stateColorB = styles_stateBuffB
		end
		
		if trigger.isDebuff then
			stateColorR = styles_stateDebuffR
			stateColorG = styles_stateDebuffG
			stateColorB = styles_stateDebuffB
		end
		
		widget:SetBorderColor(stateColorR, stateColorG, stateColorB)
	end, false, nil, 'isBuff', 'isDebuff')
	
	corner:RegisterWatchLua('HeroInventory'..index, function(widget, trigger)
		local stateColorR = styles_stateNeutralR
		local stateColorG = styles_stateNeutralG
		local stateColorB = styles_stateNeutralB
		if trigger.isBuff then
			stateColorR = styles_stateBuffR
			stateColorG = styles_stateBuffG
			stateColorB = styles_stateBuffB
		end
		
		if trigger.isDebuff then
			stateColorR = styles_stateDebuffR
			stateColorG = styles_stateDebuffG
			stateColorB = styles_stateDebuffB
		end
		
		corner:SetBorderColor(stateColorR, stateColorG, stateColorB)
	end, false, nil, 'isBuff', 'isDebuff')
	--]]
	
	icon:SetCallback('onmouseover', function(widget)
		Trigger('inventoryTipSimpleShow', 'Hero', index)
	end)
	
	icon:SetCallback('onmouseout', function(widget)
		Trigger('inventoryTipSimpleHide')
	end)
end

function heroStatesRegister(object)
	local containers	= object:GetGroup('heroStatesContainers')

	for k,v in pairs(containers) do

		v:RegisterWatchLua('ModifierKeyStatus', function(widget, trigger)
			local targY			= styles_heroStatesYPositionBase
			
			if (trigger.moreInfoKey or trigger_gamePanelInfo.heroVitalsVis) then
				targY = targY - libGeneral.HtoP(4.5)
			end
			
			widget:SlideY(targY, styles_shopTransitionTime)
		end)

	end
end

heroStatesRegister(object)

for i=32,41,1 do
	heroStateRegister(object, i)
end