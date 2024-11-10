-- Ability tips

local function abilityTipRegister(object)
	local container					= object:GetWidget('abilityLevelUpTip')
	local channelOffset				= object:GetWidget('abilityTipChannelOffset')
	local name						= object:GetWidget('abilityTipName')
	local icon						= object:GetWidget('abilityTipIcon')
	local cost						= object:GetWidget('abilityTipManaCost')
	local binding					= object:GetWidget('abilityTipBinding')
	local description				= object:GetWidget('abilityTipDescription')
	
	local propertyTable				= object:GetWidget('abilityTipProperties')
	local properties				= {}
	local propertyHeaders			= {}
	local propertiesMax				= 10
	
	local currentTriggerDescription	= nil
	local currentTriggerProperties	= nil
	local currentTriggerInventory	= nil
	
	local levelHighlightCurrent		= object:GetWidget('abilityTipLevelHighlightCurrent')
	local levelHighlightNext		= object:GetWidget('abilityTipLevelHighlightNext')
	
	local cooldown					= object:GetWidget('abilityTipCooldown')
	local cooldownContainer	= object:GetWidget('abilityTipCooldownContainer')

	for i=1,4,1 do
		propertyHeaders[i]		= object:GetWidget('abilityTipHeaderLevel'..i)
	end
	
	-- libGeneral.createGroupTrigger('abilityTipYPos', { 'heroHealthVis', 'heroManaVis', 'ModifierKeyStatus', 'channelBarVis', 'respawnBarVis', 'HeroUnit' })
	
	--[[
	container:RegisterWatchLua('abilityTipYPos', function(widget, groupTrigger)
		local triggerHealth		= groupTrigger[1]
		local triggerMana		= groupTrigger[2]
		local triggerKey		= groupTrigger[3]
		local triggerChannel	= groupTrigger[4]
		local triggerLevel		= groupTrigger[5]
		local showInfo			= triggerKey.moreInfoKey
		local targY				= styles_abilityTipBaseY
		
		if triggerHealth.isVisible or showInfo then
			targY	= targY - styles_heroHealthHeightOffset
		end
		
		if triggerMana.isVisible or showInfo then
			targY	= targY - styles_heroManaHeightOffset
		end
		
		if triggerChannel.isChanneling then
			targY	= targY - styles_abilityTipChannelOffset
		end
		
		if triggerLevel.availablePoints > 0 then
			targY	= targY - styles_heroLevelUpButtonHeightOffset
		end
		
		if widget:IsVisible() then
			widget:SlideY(targY, styles_uiSpaceShiftTime)
			widget:Sleep(styles_uiSpaceShiftTime, function() widget:SetY(targY) end)
		else
			widget:SetY(targY)
		end
	end)
	--]]

	for i=1,propertiesMax,1 do
		properties[i]	= {
			row		= object:GetWidget('abilityTipPropertyRow' .. i),
			rule	= object:GetWidget('abilityTipHorzRule' .. i),
			name	= object:GetWidget('abilityTipProperty' .. i .. 'Name'),
			values	= {}
		}
		for j=1,4,1 do
			properties[i].values[j]	= object:GetWidget('abilityTipProperty'..i..'Value'..j)
		end
	end
	
	local function watchRegister(triggerDescription, triggerProperties, triggerInventory)
		currentTriggerDescription	= LuaTrigger.GetTrigger(triggerDescription)
		currentTriggerProperties	= triggerProperties and LuaTrigger.GetTrigger(triggerProperties)
		currentTriggerInventory		= LuaTrigger.GetTrigger(triggerInventory)
		
		icon:RegisterWatchLua(triggerDescription, function(widget, trigger) widget:SetTexture(trigger.icon) end, true, 'abilityTipWatch', 'icon')
		cost:RegisterWatchLua(triggerDescription, function(widget, trigger) widget:SetText(trigger.manaCost) end, true, 'abilityTipWatch', 'manaCost')
		if currentTriggerProperties then
			binding:RegisterWatchLua(triggerDescription, function(widget, trigger) widget:SetText(trigger.keyBind) end, true, 'abilityTipWatch', 'keyBind')
			name:RegisterWatchLua(triggerDescription, function(widget, trigger) widget:SetText(trigger.name) end, true, 'abilityTipWatch', 'name')
		else
			name:RegisterWatchLua(triggerDescription, function(widget, trigger) widget:SetText(trigger.displayName) end, true, 'abilityTipWatch', 'displayName')
		end
		description:RegisterWatchLua(triggerDescription, function(widget, trigger) widget:SetText(trigger.description) end, true, 'abilityTipWatch', 'description')
		
		cooldownContainer:RegisterWatchLua(triggerInventory, function(widget, trigger)
			widget:SetVisible(trigger.cooldownTime > 0)
		end, true, 'abilityTipWatch', 'cooldownTime')
		
		cooldown:RegisterWatchLua(triggerInventory, function(widget, trigger)
			widget:SetText(Translate('general_seconds_amount', 'amount', FtoA2(trigger.cooldownTime / 1000, 0, 2)))
		end, true, 'abilityTipWatch', 'cooldownTime')
		
		for i=1,4,1 do
			propertyHeaders[i]:RegisterWatchLua(triggerInventory, function(widget, trigger)
				local maxLevel			= trigger.maxLevel
				local currentLevel		= trigger.level
				if i <= maxLevel then
					widget:SetVisible(true)
					if i == currentLevel then
						widget:SetColor(0, 1, 0)
					elseif i < currentLevel then
						widget:SetColor(1,1,1)
					else
						widget:SetColor(0.5, 0.5, 0.5)
					end
				else
					widget:SetVisible(false)
				end
				
			end, false, 'abilityTipWatch', 'maxLevel', 'level')
		end
		levelHighlightCurrent:RegisterWatchLua(triggerInventory, function(widget, trigger)
			local currentLevel	= trigger.level
			if currentLevel >= 1 then
				widget:SetVisible(true)
				widget:SetX(propertyHeaders[currentLevel]:GetX())
			else
				widget:SetVisible(false)				
			end
		end, false, 'abilityTipWatch', 'level')

		levelHighlightNext:RegisterWatchLua(triggerInventory, function(widget, trigger)
			local currentLevel	= trigger.level
			local maxLevel		= trigger.maxLevel
			
			if currentLevel < maxLevel then
				widget:SetVisible(true)
				widget:SetX(propertyHeaders[currentLevel + 1]:GetX())
			else
				widget:SetVisible(false)
			end
		end, false, 'abilityTipWatch', 'level', 'maxLevel')
		
		if (currentTriggerProperties) then
			for i=1,propertiesMax,1 do
				for j=1,4,1 do
					properties[i].values[j]:RegisterWatchLua(triggerInventory, function(widget, trigger) widget:SetVisible(j <= trigger.maxLevel) end, false, 'abilityTipWatch', 'maxLevel')
				end
			
				properties[i].row:RegisterWatchLua(triggerProperties, function(widget, trigger)
					local propertyIndex = 1
					local valueIndex = 1
					local lastIndex = 0
					local index = 1
					while index <= #trigger do
						propertyTable:SetVisible(true)

						properties[propertyIndex].row:SetVisible(true)
						properties[propertyIndex].rule:SetVisible(true)
						properties[propertyIndex].name:SetText(trigger[index])
						
						valueCount = trigger[index + 1]
						index = index + 2
						for i=1, valueCount do
							lastIndex = propertyIndex
							properties[propertyIndex].row:SetVisible(true)
							--properties[propertyIndex].values[i]:SetText(libNumber.round(trigger[index],1))
							properties[propertyIndex].values[i]:SetText(trigger[index])
							index = index + 1
						end
						
						propertyIndex = propertyIndex + 1
					end

					if lastIndex == 0 then
						propertyTable:SetVisible(false)
					else
						for i = lastIndex + 1, #properties do
							properties[i].row:SetVisible(false)
							properties[i].rule:SetVisible(false)
						end
					end
				end, false, 'abilityTipWatch')
			end
		end
		
		currentTriggerDescription:Trigger()
		if currentTriggerProperties then currentTriggerProperties:Trigger() end
		currentTriggerInventory:Trigger()
	end
	
	local function watchUnregister()
		container:UnregisterAllWatchLuaByKey('abilityTipWatch')
		--[[
		if currentTriggerDescription then
			name:UnregisterWatchLua(currentTriggerDescription)
			icon:UnregisterWatchLua(currentTriggerDescription)
			cost:UnregisterWatchLua(currentTriggerDescription)
			binding:UnregisterWatchLua(currentTriggerDescription)
			description:UnregisterWatchLua(currentTriggerDescription)
		end
		
		if currentTriggerProperties then
			for i=1,propertiesMax,1 do
				properties[i].row:UnregisterWatchLua(currentTriggerProperties)
			end
		end
		
		if currentTriggerInventory then
			for i=1,4,1 do
				propertyHeaders[i]:UnregisterWatchLua(currentTriggerInventory)
			end
			for i=1,propertiesMax,1 do
				for j=1,4,1 do
					properties[i].values[j]:UnregisterWatchLua(currentTriggerInventory)
				end
			end
			cooldown:UnregisterWatchLua(currentTriggerInventory)
			cooldownContainer:UnregisterWatchLua(currentTriggerInventory)
		end
		--]]
	end
	
	
	--[[
		Type:
		0	- Hero
		1	- Selected
		2	- Active
	--]]
	
	container:RegisterWatch('abilityTipShow', function(widget, unitType, abilityID)
		local triggerType			= AtoN(unitType)
		local triggerPrefix			= 'HeroInventory'

		if triggerType == 1 then
			triggerPrefix	= 'SelectedInventory'
		end
		
		--[[
		if triggerType == 1 then
			triggerPrefix	= 'SelectedInventory'
		elseif triggerType == 2 then
			triggerPrefix	= 'ActiveInventory'
		end
		--]]
		
		local abilID				= AtoN(abilityID)
		local triggerDescription	= triggerPrefix..'AbilityTipDescription'..abilID
		local triggerProperties		= triggerPrefix..'AbilityTipProperties'..abilID
		local triggerInventory			= triggerPrefix..abilID
		
		if triggerType >= 10 then -- triggerType >= 10 indicates it is for spectators.
			triggerDescription	= 'SpectatorHeroAbility'..abilID..'Info'..(triggerType-10)
			triggerProperties = nil
			triggerInventory = 'SpectatorHeroAbility'..abilID..'Info'..(triggerType-10)
		end
		
		watchUnregister()	-- Clear old if exists
		watchRegister(triggerDescription, triggerProperties, triggerInventory)
		
		widget:SetVisible(true)
	end)
	
	container:RegisterWatch('abilityTipHide', function(widget)
		widget:SetVisible(false)
		watchUnregister()
	end)
end

abilityTipRegister(object)