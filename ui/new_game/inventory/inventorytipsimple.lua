-- Simple Inventory tip (states, inherent, etc)

function inventoryTipSimpleRegister(object)
	local container				= object:GetWidget('abilityTipSimple')
	-- local frame				= object:GetWidget('abilityTipSimpleFrame')
	local icon					= object:GetWidget('abilityTipSimpleIcon')
	local name					= object:GetWidget('abilityTipSimpleName')
	local level					= object:GetWidget('abilityTipSimpleLevel')
	local manaCost				= object:GetWidget('abilityTipSimpleManaCost')
	local hotkeyContainer		= object:GetWidget('abilityTipSimpleHotkeyContainer')
	local hotkeyLabel			= object:GetWidget('abilityTipSimpleHotkeyLabel')
	local description			= object:GetWidget('abilityTipSimpleDescription')
	local activateInfoContainer	= object:GetWidget('abilityTipSimpleActivateInfoContainer')
	local distance				= object:GetWidget('abilityTipSimpleDistance')
	local cooldown				= object:GetWidget('abilityTipSimpleCooldown')
	local valueLabel			= object:GetWidget('abilityTipSimpleValueLabel')
	
	local lastInvID			= nil
	local lastInvType		= nil	--'Hero'
	
	--[[
	container:RegisterWatchLua('abilityTipYPos', function(widget, groupTrigger)
		local triggerHealth		= groupTrigger[1]
		local triggerMana		= groupTrigger[2]
		local triggerKey		= groupTrigger[3]
		local triggerChannel	= groupTrigger[4]
		local triggerLevel		= groupTrigger[5]
		local showInfo			= triggerKey.isDown
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
	
	local function tipRegister(invType, invID)
		local triggerInventory			= LuaTrigger.GetTrigger(invType..'Inventory'..invID)
		local triggerCooldownVis	= nil
		
		icon:RegisterWatchLua(invType..'Inventory'..invID, function(widget, trigger) widget:SetTexture(trigger.icon) end, false, nil, 'icon')
		name:RegisterWatchLua(invType..'Inventory'..invID, function(widget, trigger) widget:SetText(trigger.displayName) end, false, nil, 'displayName')
		level:RegisterWatchLua(invType..'Inventory'..invID, function(widget, trigger)
			local abilityLevel	= trigger.level
			if abilityLevel > 0 then
				widget:SetVisible(true)
				widget:SetText(
					Translate('abilitytip_level', 'level', math.floor(abilityLevel))
				)
			else
				widget:SetVisible(false)
			end
		end, false, nil, 'level')
		manaCost:RegisterWatchLua(invType..'Inventory'..invID, function(widget, trigger)
			local manaCost	= trigger.manaCost
			if manaCost > 0 then
				widget:SetVisible(true)
				widget:SetText(
					Translate('abilitytip_manacost', 'manacost', math.floor(manaCost))
				)
			else
				widget:SetVisible(false)
			end
		end, false, nil, 'manaCost')
		hotkeyContainer:RegisterWatchLua(invType..'Inventory'..invID, function(widget, trigger) widget:SetVisible(trigger.numHotKeys > 0) end, true, nil, 'numHotKeys')
		hotkeyLabel:RegisterWatchLua(invType..'Inventory'..invID, function(widget, trigger) widget:SetVisible(trigger.numHotKeys > 0); widget:SetText(trigger.binding1) end, true, nil, 'numHotKeys', 'binding1')
		description:RegisterWatchLua(invType..'Inventory'..invID, function(widget, trigger) widget:SetText(trigger.simpleDescription) end, true, nil, 'simpleDescription')
		--[[
		activateInfoContainer:RegisterWatchLua(invType..'Inventory'..invID, function(widget, groupTrigger)
			
			widget:SetVisible(trigCooldown.cooldownTime > 0 or trigDescription.castRange > 0 or trigDescription.targetRadius > 0)	-- Aura range is the DEVIL!!!! ||||  or (triggerDescription.auraRange and AtoN(triggerDescription.auraRange) > 0)
		end)	-- simpleDescription
		--]]
		--[[
		distance:RegisterWatchLua(invType..'Inventory'..invID, function(widget, trigger)
			local castRange		= trigger.castRange
			local targetRadius	= trigger.targetRadius
			-- local auraRange		= trigger.auraRange
			if castRange > 0 then
				widget:SetVisible(true)
				widget:SetText(Translate('tooltip_range')..castRange)
			elseif targetRadius > 0 then
				widget:SetText(Translate('tooltip_radius')..targetRadius)
				widget:SetVisible(true)
			elseif false then	-- auraRange and AtoN(auraRange) > 0 then
				-- widget:SetText(Translate('heroinfo_range')..auraRange)
				-- widget:SetVisible(true)
			else
				widget:SetVisible(false)
			end
		end)
		--]]
		cooldown:RegisterWatchLua(invType..'Inventory'..invID, function(widget, trigger)
			local cooldownTime	= trigger.cooldownTime
			if cooldownTime > 0 then
				widget:SetVisible(true)
				widget:SetText(
					Translate('abilitytip_cooldownamt', 'cooldown', math.floor(cooldownTime))
				)	
			else
				widget:SetVisible(false)
			end
		end, true, nil, 'cooldownTime')
		valueLabel:RegisterWatchLua(invType..'Inventory'..invID, function(widget, trigger)
		widget:SetText(libNumber.commaFormat(trigger.sellValue))
			local sellValue	= trigger.sellValue
			if sellValue > 0 then
				widget:SetVisible(true)
				widget:SetText(
					Translate('abilitytip_value', 'value', math.floor(sellValue))
				)
			else
				widget:SetVisible(false)
			end
		end, true, nil, 'sellValue')
	
		lastInvID	= invID
		lastInvType	= invType
		
		triggerInventory:Trigger()
	end
	
	local function tipUnregister()
		if lastInvID then
			icon:UnregisterWatchLua(lastInvType..'Inventory'..lastInvID)				-- iconPath
			name:UnregisterWatchLua(lastInvType..'Inventory'..lastInvID)			-- displayName
			level:UnregisterWatchLua(lastInvType..'Inventory'..lastInvID)		-- abilityLevel
			manaCost:UnregisterWatchLua(lastInvType..'Inventory'..lastInvID)		-- manaCost
			hotkeyContainer:UnregisterWatchLua(lastInvType..'Inventory'..lastInvID)	-- numHotkeys, binding1
			hotkeyLabel:UnregisterWatchLua(lastInvType..'Inventory'..lastInvID)		-- numHotkeys, binding1
			description:UnregisterWatchLua(lastInvType..'Inventory'..lastInvID)	-- simpleDescription
			activateInfoContainer:UnregisterWatchLua(lastInvType..'Inventory'..lastInvID)

			distance:UnregisterWatchLua(lastInvType..'Inventory'..lastInvID)	-- simpleDescription
			cooldown:UnregisterWatchLua(lastInvType..'Inventory'..lastInvID)		-- cooldownTime
			valueLabel:UnregisterWatchLua(lastInvType..'Inventory'..lastInvID)		-- sellValue

			lastInvID	= nil
			lastInvType	= nil
		end
	end
	
	container:RegisterWatch('inventoryTipSimpleShow', function(widget, itemType, itemID)
		tipUnregister()
		tipRegister(itemType, AtoN(itemID))
		widget:SetVisible(true)
	end)

	container:RegisterWatch('inventoryTipSimpleHide', function(widget)
		tipUnregister()
		widget:SetVisible(false)
	end)
	
end

inventoryTipSimpleRegister(object)