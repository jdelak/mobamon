-- Item Tip
function itemTipRegister(object)
	local container				= object:GetWidget('gameRecipeTip1')
	local name					= object:GetWidget('gameRecipeTip1Name')
	local icon					= object:GetWidget('gameRecipeTip1Icon')
	local cost					= object:GetWidget('gameRecipeTip1Cost')
	local description			= object:GetWidget('gameRecipeTip1Desc')
	local stats					= {}
	local statsContainer		= object:GetWidget('gameRecipeTip1StatsContainer')
	local statRow2				= object:GetWidget('gameRecipeTip1StatRow2')
	local components			= {}

	local componentHeader		= object:GetWidget('gameRecipeTip1ComponentHeader')
	local componentSpacer		= object:GetWidget('gameRecipeTip1ComponentSpacer')
	local componentContainer	= object:GetWidget('gameRecipeTip1ComponentContainer')

	local analogBonusSpacer			= object:GetWidget('gameRecipeTip1AnalogBonusSpacer')
	local analogBonusContainer		= object:GetWidget('gameRecipeTip1AnalogBonusContainer')
	local analogBonusIcon			= object:GetWidget('gameRecipeTip1AnalogBonusIcon')
	local analogBonusTitle			= object:GetWidget('gameRecipeTip1AnalogBonusTitle')
	local analogBonusDescription	= object:GetWidget('gameRecipeTip1AnalogBonusDescription')

	local rareBonusSpacer			= object:GetWidget('gameRecipeTip1RareBonusSpacer')
	local rareBonusContainer		= object:GetWidget('gameRecipeTip1RareBonusContainer')
	local rareBonusIcon				= object:GetWidget('gameRecipeTip1RareBonusIcon')
	local rareBonusTitle			= object:GetWidget('gameRecipeTip1RareBonusTitle')
	local rareBonusDescription		= object:GetWidget('gameRecipeTip1RareBonusDescription')

	local legendaryBonusSpacer			= object:GetWidget('gameRecipeTip1LegendaryBonusSpacer')
	local legendaryBonusContainer		= object:GetWidget('gameRecipeTip1LegendaryBonusContainer')
	local legendaryBonusIcon			= object:GetWidget('gameRecipeTip1LegendaryBonusIcon')
	local legendaryBonusTitle			= object:GetWidget('gameRecipeTip1LegendaryBonusTitle')
	local legendaryBonusDescription		= object:GetWidget('gameRecipeTip1LegendaryBonusDescription')

	local lastIsStash			= false

	local statTypes		= {
		{	property	= 'maxHealth',			icon	= '/ui/elements:itemtype_health',		format	= function(input) return libNumber.commaFormat(input) end	},
		{	property	= 'maxMana',			icon	= '/ui/elements:itemtype_mana',			format	= function(input) return libNumber.commaFormat(input) end	},
		{	property	= 'baseHealthRegen',	icon	= '/ui/elements:itemtype_healthregen',	format	= function(input) return libNumber.round(input, 1) end	},
		{	property	= 'baseManaRegen',		icon	= '/ui/elements:itemtype_manaregen',	format	= function(input) return libNumber.round(input, 1) end	},
		{	property	= 'armor',				icon	= '/ui/elements:itemtype_physdefense',	format	= function(input) return math.floor(input) end	},
		{	property	= 'magicArmor',			icon	= '/ui/elements:itemtype_magdefense',	format	= function(input) return math.floor(input) end	},
		{	property	= 'mitigation',			icon	= '/ui/elements:itemtype_physdefense',	format	= function(input) return math.floor(input) end	},
		{	property	= 'resistance',			icon	= '/ui/elements:itemtype_magdefense',	format	= function(input) return math.floor(input) end	},
		{	property	= 'power',				icon	= '/ui/elements:itemtype_damage',		format	= function(input) return math.floor(input) end	},
		{	property	= 'baseAttackSpeed',		icon	= '/ui/_textures/icons/itemtype_damage.tga',		format	= function(input) return math.floor(input) end	}
	}

	for i=1,8,1 do
		stats[i] = {
			container	= object:GetWidget('gameRecipeTip1Stat'..i),
			icon		= object:GetWidget('gameRecipeTip1Stat'..i..'Icon'),
			value		= object:GetWidget('gameRecipeTip1Stat'..i..'Value')
		}
	end

	for i=1,3,1 do
		components[i] = {
			container	= object:GetWidget('gameRecipeTip1Component'..i),
			name		= object:GetWidget('gameRecipeTip1Component'..i..'Name'),
			icon		= object:GetWidget('gameRecipeTip1Component'..i..'Icon'),
			description	= object:GetWidget('gameRecipeTip1Component'..i..'Desc')
		}
	end

	local lastItemID		= nil
	local lastItemType		= nil	--'Hero'

	local function itemRegister(itemType, itemID, isStash)
		isStash = isStash or false
		local typeSuffix	= 'Inventory'
		if isStash then
			typeSuffix = ''
		end

		local triggerInventory		= LuaTrigger.GetTrigger(itemType..typeSuffix..itemID)
		-- local triggerDescription	= LuaTrigger.GetTrigger(itemType..typeSuffix..'Description'..itemID)
		-- local triggerIcon			= LuaTrigger.GetTrigger(itemType..typeSuffix..'Icon'..itemID)
		-- local triggerStats			= LuaTrigger.GetTrigger(itemType..typeSuffix..'Stats'..itemID)
		-- local triggerComponent0		= LuaTrigger.GetTrigger(itemType..typeSuffix..'CraftedItemComponent0Info'..itemID)
		-- local triggerComponent1		= LuaTrigger.GetTrigger(itemType..typeSuffix..'CraftedItemComponent1Info'..itemID)
		-- local triggerComponent2		= LuaTrigger.GetTrigger(itemType..typeSuffix..'CraftedItemComponent2Info'..itemID)
		-- local triggerIsCrafted		= LuaTrigger.GetTrigger(itemType..typeSuffix..'IsPlayerCrafted'..itemID)
		-- local triggerCraftedBonus	= LuaTrigger.GetTrigger(itemType..typeSuffix..'CraftedItemBonusInfo'..itemID)
		
		if (not triggerInventory.exists) then
			return false
		end
		
		name:RegisterWatchLua(itemType..typeSuffix..itemID, function(widget, trigger) widget:SetText(trigger.displayName) end, true, nil, 'displayName')
		icon:RegisterWatchLua(itemType..typeSuffix..itemID, function(widget, trigger) widget:SetTexture(trigger.icon) end, false, nil, 'icon')
		cost:RegisterWatchLua(itemType..typeSuffix..itemID, function(widget, trigger) widget:SetText(math.floor(trigger.sellValue)) end, true, nil, 'sellValue')
		description:RegisterWatchLua(itemType..typeSuffix..itemID, function(widget, trigger) widget:SetText(StripColorCodes(trigger.description)) end, true, nil, 'description')

		componentHeader:RegisterWatchLua(itemType..typeSuffix..itemID, function(widget, trigger) widget:SetVisible(trigger.recipeComponentDetail0isValid) end, true, nil, 'recipeComponentDetail0isValid')
		componentSpacer:RegisterWatchLua(itemType..typeSuffix..itemID, function(widget, trigger) widget:SetVisible(trigger.recipeComponentDetail0isValid) end, true, nil, 'recipeComponentDetail0isValid')
		componentContainer:RegisterWatchLua(itemType..typeSuffix..itemID, function(widget, trigger) widget:SetVisible(trigger.recipeComponentDetail0isValid) end, true, nil, 'recipeComponentDetail0isValid')

		for i=0,2,1 do
			components[i + 1].container:RegisterWatchLua(itemType..typeSuffix..itemID, function(widget, trigger) widget:SetVisible(trigger['recipeComponentDetail'..i..'isValid']) end, true, nil, 'recipeComponentDetail'..i..'isValid')
			components[i + 1].icon:RegisterWatchLua(itemType..typeSuffix..itemID, function(widget, trigger) widget:SetTexture(trigger['recipeComponentDetail'..i..'icon']) end, true, nil, 'recipeComponentDetail'..i..'icon')
			components[i + 1].name:RegisterWatchLua(itemType..typeSuffix..itemID, function(widget, trigger) widget:SetText(trigger['recipeComponentDetail'..i..'displayName']) end, true, nil, 'recipeComponentDetail'..i..'displayName')
			components[i + 1].description:RegisterWatchLua(itemType..typeSuffix..itemID, function(widget, trigger) widget:SetText(StripColorCodes(trigger['recipeComponentDetail'..i..'description'])) end, true, nil, 'recipeComponentDetail'..i..'description')
		end

		analogBonusSpacer:RegisterWatchLua(itemType..typeSuffix..itemID, function(widget, trigger) widget:SetVisible(trigger.isPlayerCrafted) end, false, nil, 'isPlayerCrafted')
		analogBonusContainer:RegisterWatchLua(itemType..typeSuffix..itemID, function(widget, trigger) widget:SetVisible(trigger.isPlayerCrafted) end, false, nil, 'isPlayerCrafted')
		-- analogBonusIcon:RegisterWatchLua...
		analogBonusTitle:RegisterWatchLua(itemType..typeSuffix..itemID, function(widget, trigger)
			widget:SetText(
				Translate('abilitytip_craft_analogbonus', 'tier', math.floor(trigger.normalQuality * 10))
			)
		end, false, nil, 'normalQuality')

		analogBonusDescription:RegisterWatchLua(itemType..typeSuffix..itemID, function(widget, trigger) widget:SetText(trigger.bonusDescription) end, false, nil, 'bonusDescription')

		rareBonusSpacer:RegisterWatchLua(itemType..typeSuffix..itemID, function(widget, trigger) widget:SetVisible(trigger.isRare) end, false, nil, 'isRare')
		rareBonusContainer:RegisterWatchLua(itemType..typeSuffix..itemID, function(widget, trigger) widget:SetVisible(trigger.isRare) end, false, nil, 'isRare')
		rareBonusIcon:RegisterWatchLua(itemType..typeSuffix..itemID, function(widget, trigger) widget:SetTexture(trigger.rareIcon) end, false, nil, 'rareIcon')
		rareBonusTitle:RegisterWatchLua(itemType..typeSuffix..itemID, function(widget, trigger)
			widget:SetText(
				Translate('abilitytip_craft_rarebonus', 'bonusname', StripColorCodes(trigger.rareDisplayName), 'tier', math.floor(trigger.rareQuality * 10))
			)
		end, false, nil, 'rareDisplayName', 'rareQuality')

		rareBonusDescription:RegisterWatchLua(itemType..typeSuffix..itemID, function(widget, trigger) widget:SetText(StripColorCodes(trigger.rareDescription)) end, false, nil, 'rareDescription')

		legendaryBonusSpacer:RegisterWatchLua(itemType..typeSuffix..itemID, function(widget, trigger) widget:SetVisible(trigger.isLegendary) end, false, nil, 'isLegendary')
		legendaryBonusContainer:RegisterWatchLua(itemType..typeSuffix..itemID, function(widget, trigger) widget:SetVisible(trigger.isLegendary) end, false, nil, 'isLegendary')
		legendaryBonusIcon:RegisterWatchLua(itemType..typeSuffix..itemID, function(widget, trigger) widget:SetTexture(trigger.legendaryIcon) end, false, nil, 'legendaryIcon')
		legendaryBonusTitle:RegisterWatchLua(itemType..typeSuffix..itemID, function(widget, trigger)
			widget:SetText(
				Translate('abilitytip_craft_legbonus', 'bonusname', StripColorCodes(trigger.legendaryDisplayName), 'tier', math.floor(trigger.legendaryQuality * 10))
			)
		end, false, nil, 'legendaryDisplayName', 'legendaryQuality')
		legendaryBonusDescription:RegisterWatchLua(itemType..typeSuffix..itemID, function(widget, trigger) widget:SetText(StripColorCodes(trigger.legendaryDescription)) end, false, nil, 'legendaryDescription')
		
		container:RegisterWatchLua(itemType..typeSuffix..itemID, function(widget, trigger)
			local statInfo	= {}
			local showStats	= false
			local propertyValue
			for k,v in ipairs(statTypes) do
				propertyValue = trigger[v.property]
				if propertyValue > 0 then
					table.insert(statInfo, { icon	= v.icon,	value	= v.format(propertyValue),	color = style_crafting_componentTypeColors[v.property] })
					showStats = true
				end
			end

			for i=1,8,1 do
				if statInfo[i] then
					stats[i].container:SetVisible(true)
					stats[i].icon:SetTexture(statInfo[i].icon)
					stats[i].icon:SetColor(statInfo[i].color)
					stats[i].value:SetText(statInfo[i].value)
				else
					stats[i].container:SetVisible(false)
				end
			end
			statsContainer:SetVisible(showStats)
		end, false, nil, 'maxHealth', 'maxMana', 'baseHealthRegen', 'baseManaRegen', 'armor', 'magicArmor', 'power', 'mitigation', 'resistance')

		triggerInventory:Trigger()
		-- triggerDescription:Trigger()
		-- triggerIcon:Trigger()
		-- triggerStats:Trigger()
		-- triggerComponent0:Trigger()
		-- triggerComponent1:Trigger()
		-- triggerComponent2:Trigger()
		-- triggerIsCrafted:Trigger()
		-- triggerCraftedBonus:Trigger()

		lastItemID		= itemID
		lastItemType	= itemType
		
		return true
	end

	local function itemUnregister(isStash)
		isStash = isStash or false

		local typeSuffix = 'Inventory'
		if isStash then
			typeSuffix = ''
		end

		if lastItemID then
			name:UnregisterWatchLua(lastItemType..typeSuffix..lastItemID)
			icon:UnregisterWatchLua(lastItemType..typeSuffix..lastItemID)
			cost:UnregisterWatchLua(lastItemType..typeSuffix..lastItemID)
			description:UnregisterWatchLua(lastItemType..typeSuffix..lastItemID)
			container:UnregisterWatchLua(lastItemType..typeSuffix..lastItemID)

			for i=0,1,2 do
				components[i + 1].container:UnregisterWatchLua(lastItemType..typeSuffix..lastItemID)
				components[i + 1].icon:UnregisterWatchLua(lastItemType..typeSuffix..lastItemID)
				components[i + 1].name:UnregisterWatchLua(lastItemType..typeSuffix..lastItemID)
			end

			analogBonusSpacer:UnregisterWatchLua(lastItemType..typeSuffix..lastItemID)
			analogBonusContainer:UnregisterWatchLua(lastItemType..typeSuffix..lastItemID)
			-- analogBonusIcon:UnregisterWatchLua(lastItemType..typeSuffix..lastItemID)
			analogBonusTitle:UnregisterWatchLua(lastItemType..typeSuffix..lastItemID)
			analogBonusDescription:UnregisterWatchLua(lastItemType..typeSuffix..lastItemID)

			rareBonusSpacer:UnregisterWatchLua(lastItemType..typeSuffix..lastItemID)
			rareBonusContainer:UnregisterWatchLua(lastItemType..typeSuffix..lastItemID)
			rareBonusIcon:UnregisterWatchLua(lastItemType..typeSuffix..lastItemID)
			rareBonusTitle:UnregisterWatchLua(lastItemType..typeSuffix..lastItemID)
			rareBonusDescription:UnregisterWatchLua(lastItemType..typeSuffix..lastItemID)

			legendaryBonusSpacer:UnregisterWatchLua(lastItemType..typeSuffix..lastItemID)
			legendaryBonusContainer:UnregisterWatchLua(lastItemType..typeSuffix..lastItemID)
			legendaryBonusIcon:UnregisterWatchLua(lastItemType..typeSuffix..lastItemID)
			legendaryBonusTitle:UnregisterWatchLua(lastItemType..typeSuffix..lastItemID)
			legendaryBonusDescription:UnregisterWatchLua(lastItemType..typeSuffix..lastItemID)

			lastItemID		= nil
			lastItemType	= nil
		end
	end

	container:RegisterWatch('itemTipShow', function(widget, itemType, itemID, isStashString)
		isStashString = isStashString or 'false'
		local isStash = AtoB(isStashString) or false
		lastIsStash = isStash
		itemUnregister(isStash)
		widget:SetVisible(itemRegister(itemType, AtoN(itemID), isStash))
	end)

	container:RegisterWatch('itemTipHide', function(widget)
		itemUnregister(lastIsStash)
		widget:SetVisible(false)
	end)
	
	-- container:RegisterWatchLua('ModifierKeyStatus', function(widget, trigger)
		-- widget:GetWidget('gameRecipeTip1DescExpanded'):SetVisible(trigger.moreInfoKey and (string.len(widget:GetWidget('gameRecipeTip1DescExpanded'):GetText()) > 0))
	-- end)
	
end

itemTipRegister(object)