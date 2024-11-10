-- Crafted Item Tip

-- selectableComponentTypeList	= { 'power', 'hp', 'mp', 'hpregen', 'mpregen' }
craftedItemStatNameList	= { 'power', 'health', 'healthRegen', 'mana', 'manaRegen', 'baseAttackSpeed' }	-- As seen in custom triggers

-- ================================

local function craftedItemTipComponentRegister(index)
	local container	= object:GetWidget('craftedItemTipComponent'..index)
	local icon		= object:GetWidget('craftedItemTipComponent'..index..'Icon')

	container:RegisterWatchLua('craftedItemTipInfo', function(widget, trigger) widget:SetVisible(trigger['component'..index..'Exists']) end, false, nil, 'component'..index..'Exists')
	icon:RegisterWatchLua('craftedItemTipInfo', function(widget, trigger) widget:SetTexture(trigger['component'..index..'Icon']) end, false, nil, 'component'..index..'Icon')
end

function craftedItemTipStatRegister(itemType, typeID)
	local label		= object:GetWidget('craftedItemTipStat'..itemType)

	label:RegisterWatchLua('craftedItemTipInfo', function(widget, trigger)
		widget:SetText(
			itemStatTypeFormat[craftedItemStatNameList[typeID]](trigger[itemType])

		)
	end, false, nil, itemType)
end

function craftedItemTipRegister(object)
	local itemTipTrigger				= LuaTrigger.GetTrigger('craftedItemTipInfo')

	local craftedItemEffectPerType	= {
		power		= 'power',
		baseAttackSpeed	= 'baseAttackSpeed',
		hp			= 'maxHealth',
		mp			= 'maxMana',
		hpregen		= 'baseHealthRegen',
		mpregen		= 'baseManaRegen',

		power_comp			= 'power',
		attack_speed_comp	= 'baseAttackSpeed',
		health_comp			= 'maxHealth',
		mana_comp			= 'maxMana',
		health_regen_comp	= 'baseHealthRegen',
		mana_regen_comp		= 'baseManaRegen'
	}

	-- ======================================================================================

	local craftedItemTipContainer		= object:GetWidget('craftedItemTip')
	local craftedItemTipTitle			= object:GetWidget('craftedItemTipTitle')
	-- local craftedItemTipIcon			= object:GetWidget('craftedItemTipIcon')
	local craftedItemTipCost			= object:GetWidget('craftedItemTipCost')
	local craftedItemTipDescription					= object:GetWidget('craftedItemTipDescription')

	local craftedItemTipAnalogBonusContainer		= object:GetWidget('craftedItemTipAnalogBonusContainer')
	local craftedItemTipAnalogBonusDescription		= object:GetWidget('craftedItemTipAnalogBonusDescription')
	local craftedItemTipAnalogBonusName				= object:GetWidget('craftedItemTipAnalogBonusTitle')
	local craftedItemTipRareBonusContainer			= object:GetWidget('craftedItemTipRareBonusContainer')
	local craftedItemTipRareBonusIcon				= object:GetWidget('craftedItemTipRareBonusIcon')
	local craftedItemTipRareBonusTitle				= object:GetWidget('craftedItemTipRareBonusTitle')
	local craftedItemTipRareBonusDescription		= object:GetWidget('craftedItemTipRareBonusDescription')
	local craftedItemTipLegendaryBonusContainer		= object:GetWidget('craftedItemTipLegendaryBonusContainer')
	local craftedItemTipLegendaryBonusIcon			= object:GetWidget('craftedItemTipLegendaryBonusIcon')
	local craftedItemTipLegendaryBonusTitle			= object:GetWidget('craftedItemTipLegendaryBonusTitle')
	local craftedItemTipLegendaryBonusDescription	= object:GetWidget('craftedItemTipLegendaryBonusDescription')

	craftedItemTipAnalogBonusName:RegisterWatchLua('craftedItemTipInfo', function(widget, trigger) widget:SetText('Analog Bonus'..trigger.analogTierString) end, false, nil, 'analogTierString')
	craftedItemTipAnalogBonusContainer:SetVisible(true)
	craftedItemTipAnalogBonusDescription:RegisterWatchLua('craftedItemTipInfo', function(widget, trigger) widget:SetText(trigger.analogBonusDescription) end, false, nil, 'analogBonusDescription')

	craftedItemTipRareBonusIcon:RegisterWatchLua('craftedItemTipInfo', function(widget, trigger) widget:SetTexture(trigger.rareBonusIcon) end, false, nil, 'rareBonusIcon')
	craftedItemTipRareBonusTitle:RegisterWatchLua('craftedItemTipInfo', function(widget, trigger) widget:SetText(trigger.rareBonusTitle) end, false, nil, 'rareBonusTitle')
	craftedItemTipRareBonusDescription:RegisterWatchLua('craftedItemTipInfo', function(widget, trigger) widget:SetText(trigger.rareBonusDescription) end, false, nil, 'rareBonusDescription')

	craftedItemTipLegendaryBonusIcon:RegisterWatchLua('craftedItemTipInfo', function(widget, trigger)
		if (not Empty(trigger.legendaryBonusIcon)) then
			widget:SetTexture(trigger.legendaryBonusIcon)
		else
			widget:SetTexture('$invis')
		end
	end, false, nil, 'legendaryBonusIcon')
	craftedItemTipLegendaryBonusTitle:RegisterWatchLua('craftedItemTipInfo', function(widget, trigger) widget:SetText(trigger.legendaryBonusTitle) end, false, nil, 'legendaryBonusTitle')
	craftedItemTipLegendaryBonusDescription:RegisterWatchLua('craftedItemTipInfo', function(widget, trigger) widget:SetText(trigger.legendaryBonusDescription) end, false, nil, 'legendaryBonusDescription')

	craftedItemTipContainer:RegisterWatchLua('craftedItemTipInfo', function(widget, trigger) widget:SetVisible(trigger.visible) end, false, nil, 'visible')
	craftedItemTipTitle:RegisterWatchLua('craftedItemTipInfo', function(widget, trigger) widget:SetText(trigger.title) end, false, nil, 'title')
	-- craftedItemTipIcon:RegisterWatchLua('craftedItemTipInfo', function(widget, trigger) widget:SetTexture(trigger.icon) end, false, nil, 'icon')
	craftedItemTipCost:RegisterWatchLua('craftedItemTipInfo', function(widget, trigger) widget:SetText(libNumber.commaFormat(trigger.cost)) end, false, nil, 'cost')
	craftedItemTipDescription:RegisterWatchLua('craftedItemTipInfo', function(widget, trigger) widget:SetText(trigger.description) end, false, nil, 'description')

	craftedItemTipRareBonusContainer:RegisterWatchLua('craftedItemTipInfo', function(widget, trigger) widget:SetVisible(trigger.rareBonusExists) end, false, nil, 'rareBonusExists')
	craftedItemTipLegendaryBonusContainer:RegisterWatchLua('craftedItemTipInfo', function(widget, trigger)
		widget:SetVisible(trigger.legendaryBonusExists)
	end, false, nil, 'legendaryBonusExists')

	for i=1,3,1 do
		craftedItemTipComponentRegister(i)
	end

	tipStatTypeList	= { 'power', 'hp', 'mp', 'hpregen', 'mpregen' }

	for k,v in pairs(tipStatTypeList) do
		craftedItemTipStatRegister(v, k)
	end

	-- ======================================================================================

	function craftedItemTipHide()
		local tipTrigger	= LuaTrigger.GetTrigger('craftedItemTipInfo')
		tipTrigger.visible	= false
		tipTrigger:Trigger(false)
	end

	LuaTrigger.CreateCustomTrigger('craftedItemInfoShop', {	-- Styled after ShopItem
		{ name		= 'icon',							type	= 'string' },
		{ name		= 'displayName',					type	= 'string' },
		{ name		= 'description',					type	= 'string' },
		{ name		= 'cooldown',						type	= 'number' },
		{ name		= 'cost',							type	= 'number' },
		{ name		= 'manaCost',						type	= 'number' },
		{ name		= 'isRecipe',						type	= 'boolean' },
		{ name		= 'exists',							type	= 'boolean' },
		{ name		= 'recipeComponentDetail0exists',	type	= 'boolean' },
		{ name		= 'recipeComponentDetail1exists',	type	= 'boolean' },
		{ name		= 'recipeComponentDetail2exists',	type	= 'boolean' },
		{ name		= 'recipeComponentDetail0icon',		type	= 'string' },
		{ name		= 'recipeComponentDetail1icon',		type	= 'string' },
		{ name		= 'recipeComponentDetail2icon',		type	= 'string' },
		
		{ name		= 'recipeComponentDetail0power',		type	= 'number' },
		{ name		= 'recipeComponentDetail1power',		type	= 'number' },
		{ name		= 'recipeComponentDetail2power',		type	= 'number' },
		
		
		{ name		= 'recipeComponentDetail0maxHealth',		type	= 'number' },
		{ name		= 'recipeComponentDetail1maxHealth',		type	= 'number' },
		{ name		= 'recipeComponentDetail2maxHealth',		type	= 'number' },
		
		{ name		= 'recipeComponentDetail0cost',		type	= 'number' },
		{ name		= 'recipeComponentDetail1cost',		type	= 'number' },
		{ name		= 'recipeComponentDetail2cost',		type	= 'number' },		
		
		{ name		= 'recipeComponentDetail0maxMana',		type	= 'number' },
		{ name		= 'recipeComponentDetail1maxMana',		type	= 'number' },
		{ name		= 'recipeComponentDetail2maxMana',		type	= 'number' },
		
		{ name		= 'recipeComponentDetail0baseHealthRegen',		type	= 'number' },
		{ name		= 'recipeComponentDetail1baseHealthRegen',		type	= 'number' },
		{ name		= 'recipeComponentDetail2baseHealthRegen',		type	= 'number' },
		
		{ name		= 'recipeComponentDetail0baseManaRegen',		type	= 'number' },
		{ name		= 'recipeComponentDetail1baseManaRegen',		type	= 'number' },
		{ name		= 'recipeComponentDetail2baseManaRegen',		type	= 'number' },
		
		{ name		= 'recipeComponentDetail0baseAttackSpeed',		type	= 'number' },
		{ name		= 'recipeComponentDetail1baseAttackSpeed',		type	= 'number' },
		{ name		= 'recipeComponentDetail2baseAttackSpeed',		type	= 'number' },
		
		{ name		= 'recipeComponentDetail0description',		type	= 'string' },
		{ name		= 'recipeComponentDetail1description',		type	= 'string' },
		{ name		= 'recipeComponentDetail2description',		type	= 'string' },
		
		{ name		= 'recipeComponentDetail0displayName',		type	= 'string' },
		{ name		= 'recipeComponentDetail2displayName',		type	= 'string' },
		{ name		= 'recipeComponentDetail1displayName',		type	= 'string' },
		
		{ name		= 'recipeComponentDetail0entity',		type	= 'string' },
		{ name		= 'recipeComponentDetail2entity',		type	= 'string' },
		{ name		= 'recipeComponentDetail1entity',		type	= 'string' },
		
		{ name		= 'isActivatable',					type	= 'boolean' },
		{ name		= 'power',							type	= 'number' },
		{ name		= 'baseAttackSpeed',				type	= 'number' },
		{ name		= 'armor',							type	= 'number' },
		{ name		= 'magicArmor',						type	= 'number' },
		{ name		= 'mitigation',						type	= 'number' },
		{ name		= 'resistance',						type	= 'number' },
		{ name		= 'maxHealth',						type	= 'number' },
		{ name		= 'maxMana',						type	= 'number' },
		{ name		= 'baseHealthRegen',				type	= 'number' },
		{ name		= 'baseManaRegen',					type	= 'number' },

		{ name	= 'active',											type		= 'boolean' },
		{ name	= 'isExpired',										type		= 'boolean' },
		{ name	= 'isPermanent',									type		= 'boolean' },
		{ name	= 'days',											type		= 'number' },
		{ name	= 'monthsLeft',										type		= 'number' },
		{ name	= 'daysLeft',										type		= 'number' },
		{ name	= 'hoursLeft',										type		= 'number' },
		{ name	= 'minutesLeft',									type		= 'number' },		
		
		{ name		= 'isPlayerCrafted',				type	= 'boolean' },
		
		{ name		= 'bonusDescription',				type	= 'string' },
		{ name		= 'normalQuality',					type	= 'number' },
		
		{ name		= 'isRare',							type	= 'boolean' },
		{ name		= 'rareDisplayName',				type	= 'string' },
		{ name		= 'rareDescription',				type	= 'string' },
		{ name		= 'rareQuality',					type	= 'number' },
		{ name		= 'rareIcon',						type	= 'string' },
		
		{ name		= 'isLegendary',					type	= 'boolean' },
		{ name		= 'legendaryDisplayName',			type	= 'string' },
		{ name		= 'legendaryDescription',			type	= 'string' },
		{ name		= 'legendaryQuality',				type	= 'number' },
		{ name		= 'legendaryIcon',					type	= 'string' },
		
		{ name		= 'currentEmpoweredEffectEntityName',			type	= 'string' },
		{ name		= 'currentEmpoweredEffectCost',					type	= 'number' },
		{ name		= 'currentEmpoweredEffectDisplayName',					type	= 'string' },
		{ name		= 'currentEmpoweredEffectDescription',			type	= 'string' },

	})

	function craftedItemTipPopulate(index, dataOnly, incTipTrigger, isCraftingEntity, isRecipe, isUnfinishedCraft, craftedDataOverride, shopInfoPulled)	-- isCraftingEntity and isRecipe are used for crafting
		index = index or -1
		dataOnly = dataOnly or false
		isCraftingEntity = isCraftingEntity or false
		isUnfinishedCraft = isUnfinishedCraft or false
		shopInfoPulled = shopInfoPulled or false
		isRecipe = isRecipe or false

		local itemInfo
		
		if isCraftingEntity then
			if isRecipe then
				itemInfo		= craftingGetRecipe(index) or Crafting.GetRecipes()[index]
			else
				itemInfo		= craftingGetComponentByName(index) or Crafting.GetComponents()[index]
			end
			
		else
			itemInfo		= LuaTrigger.GetTrigger('CraftedItems'..index)
		end
		
		
		local componentInfo
		local tipTrigger
		local overrideTrigger

		if (incTipTrigger) then
		
			tipTrigger = LuaTrigger.GetTrigger('craftedItemTipInfo')
			tipTrigger.visible						= 1
			tipTrigger.cost							= tonumber(incTipTrigger.cost)
			tipTrigger.icon							= incTipTrigger.icon
			tipTrigger.title						= incTipTrigger.displayName
			tipTrigger.displayName					= incTipTrigger.displayName
			tipTrigger.description					= incTipTrigger.description
			tipTrigger.analogTierString				= incTipTrigger.analogTierString
			tipTrigger.analogBonusDescription		= incTipTrigger.analogBonusDescription

			tipTrigger.rareBonusExists				= (incTipTrigger.rareBonusExists)
			tipTrigger.rareBonusIcon				= incTipTrigger.rareBonusIcon
			tipTrigger.rareBonusTitle				= incTipTrigger.rareBonusTitle
			tipTrigger.rareBonusDescription			= incTipTrigger.rareBonusDescription
			tipTrigger.legendaryBonusExists			= (incTipTrigger.legendaryBonusExists)
			tipTrigger.legendaryBonusIcon			= incTipTrigger.legendaryBonusIcon
			tipTrigger.legendaryBonusTitle			= incTipTrigger.legendaryBonusTitle
			tipTrigger.legendaryBonusDescription	= incTipTrigger.legendaryBonusDescription

			tipTrigger.currentEmpoweredEffectEntityName	= itemInfo.currentEmpoweredEffectEntityName or ''
			tipTrigger.currentEmpoweredEffectCost	= itemInfo.currentEmpoweredEffectCost or 0
			tipTrigger.currentEmpoweredEffectDisplayName		= itemInfo.currentEmpoweredEffectDisplayName or ''
			tipTrigger.currentEmpoweredEffectDescription		= itemInfo.currentEmpoweredEffectDescription or ''				
			
			tipTrigger.active 			= true
			tipTrigger.isExpired 		= incTipTrigger['isExpired']
			tipTrigger.isPermanent 		= incTipTrigger['isPermanent']
			tipTrigger.days 			= incTipTrigger['days']
			tipTrigger.monthsLeft 		= incTipTrigger['monthsLeft']
			tipTrigger.daysLeft 		= incTipTrigger['daysLeft']
			tipTrigger.hoursLeft 		= incTipTrigger['hoursLeft']
			tipTrigger.minutesLeft 		= incTipTrigger['minutesLeft']			
			
			for i=1,3,1 do
				tipTrigger['component'..i..'Exists']	= (incTipTrigger['component'..i..'Exists'])
				if tipTrigger['component'..i..'Exists'] then
					tipTrigger['component'..i..'Icon'] = incTipTrigger['component'..i..'Icon']
					
					componentInfo = craftingGetComponentByName(itemInfo.Components[i])
						
					tipTrigger['recipeComponentDetail'..(i - 1)..'power']			= componentInfo.power
					tipTrigger['recipeComponentDetail'..(i - 1)..'baseAttackSpeed']	= componentInfo.baseAttackSpeed
					tipTrigger['recipeComponentDetail'..(i - 1)..'maxHealth']		= componentInfo.maxHealth
					tipTrigger['recipeComponentDetail'..(i - 1)..'maxMana']			= componentInfo.maxMana
					tipTrigger['recipeComponentDetail'..(i - 1)..'baseHealthRegen']	= componentInfo.baseHealthRegen
					tipTrigger['recipeComponentDetail'..(i - 1)..'baseManaRegen']	= componentInfo.baseManaRegen
					tipTrigger['recipeComponentDetail'..(i - 1)..'description']		= componentInfo.description
					tipTrigger['recipeComponentDetail'..(i - 1)..'displayName']		= componentInfo.displayName
					tipTrigger['recipeComponentDetail'..(i - 1)..'entity']			= componentInfo.name
					tipTrigger['recipeComponentDetail'..(i - 1)..'cost']			= componentInfo.cost
				end
			end

			for k,v in pairs(tipStatTypeList) do
				tipTrigger[v]	= incTipTrigger[v]
			end		
		
		elseif dataOnly then
		
			if shopInfoPulled then
				overrideTrigger				= craftedDataOverride or LuaTrigger.GetTrigger('CraftingUnfinishedDesign')	
				tipTrigger					= LuaTrigger.GetTrigger('craftedItemInfoShop')

				if craftedDataOverride then
					index = craftedDataOverride.name or craftedDataOverride.entity
				end
				
				tipTrigger.exists			= true
				tipTrigger.icon				= GetEntityIconPath(index)
				tipTrigger.displayName		= GetEntityDisplayName(index)
				tipTrigger.description		= overrideTrigger.description
				tipTrigger.cooldown			= overrideTrigger.cooldown or 0				-- rmm need this
				
				tipTrigger.manaCost			= overrideTrigger.manaCost or 0				-- rmm need this
				tipTrigger.isRecipe			= isRecipe
				tipTrigger.isActivatable	= false			-- rmm need this
				
				tipTrigger.active 			= true
				tipTrigger.isExpired 		= overrideTrigger['isExpired']
				tipTrigger.isPermanent 		= overrideTrigger['isPermanent']
				tipTrigger.days 			= overrideTrigger['days']
				tipTrigger.monthsLeft 		= overrideTrigger['monthsLeft']
				tipTrigger.daysLeft 		= overrideTrigger['daysLeft']
				tipTrigger.hoursLeft 		= overrideTrigger['hoursLeft']
				tipTrigger.minutesLeft 		= overrideTrigger['minutesLeft']					
				
				local totalCost = 0
				
				if isRecipe then	-- zeroed out so it doesn't visually factor in components
					overrideTrigger.recipeCost	= overrideTrigger.recipeCost or 0
					overrideTrigger.cost 		= overrideTrigger.cost or 0
					tipTrigger.power			= 0
					tipTrigger.baseAttackSpeed	= 0
					tipTrigger.armor		    = 0
					tipTrigger.magicArmor		= 0
					tipTrigger.magicArmor		= 0
					tipTrigger.mitigation		= 0
					tipTrigger.resistance		= 0
					tipTrigger.maxHealth		= 0
					tipTrigger.maxMana			= 0
					tipTrigger.baseHealthRegen	= 0
					tipTrigger.baseManaRegen	= 0
					totalCost = totalCost + overrideTrigger.recipeCost
				else
					overrideTrigger.cost 		= overrideTrigger.cost or 0
					overrideTrigger.recipeCost 	= overrideTrigger.recipeCost or 0
					tipTrigger.power			= overrideTrigger.power or 0
					tipTrigger.baseAttackSpeed	= overrideTrigger.baseAttackSpeed or overrideTrigger.attackSpeed
					tipTrigger.armor		    = overrideTrigger.armor or 0
					tipTrigger.magicArmor		= overrideTrigger.magicArmor or 0
					tipTrigger.mitigation		= overrideTrigger.mitigation or 0
					tipTrigger.resistance		= overrideTrigger.resistance or 0
					tipTrigger.maxHealth		= overrideTrigger.maxHealth or 0
					tipTrigger.maxMana			= overrideTrigger.maxMana or 0
					tipTrigger.baseHealthRegen	= overrideTrigger.baseHealthRegen or 0
					tipTrigger.baseManaRegen	= overrideTrigger.baseManaRegen or overrideTrigger.maxBaseManaRegen or 0
					totalCost = totalCost + overrideTrigger.cost
				end
				
				tipTrigger.isPlayerCrafted	= (craftedDataOverride and true) or false
				tipTrigger.isRare			= (craftedDataOverride and craftedDataOverride.isRare) or false
				tipTrigger.isLegendary		= false

				tipTrigger.currentEmpoweredEffectEntityName		= overrideTrigger.currentEmpoweredEffectEntityName or ''
				tipTrigger.currentEmpoweredEffectCost			= overrideTrigger.currentEmpoweredEffectCost or 0
				tipTrigger.currentEmpoweredEffectDisplayName	= overrideTrigger.currentEmpoweredEffectDisplayName or ''
				tipTrigger.currentEmpoweredEffectDescription	= overrideTrigger.currentEmpoweredEffectDescription or ''				
				
				if isRecipe then
					for i=1,3,1 do
						tipTrigger['recipeComponentDetail'..(i - 1)..'exists'] = overrideTrigger['recipeComponentDetail'..(i - 1)..'exists']
						if tipTrigger['recipeComponentDetail'..(i - 1)..'exists'] then
							tipTrigger['recipeComponentDetail'..(i - 1)..'icon'] 			= GetEntityIconPath(overrideTrigger['recipeComponentDetail'..(i - 1)..'entity'])
							tipTrigger['recipeComponentDetail'..(i - 1)..'power']			= overrideTrigger['recipeComponentDetail'..(i - 1)..'power']
							tipTrigger['recipeComponentDetail'..(i - 1)..'baseAttackSpeed']	= overrideTrigger['recipeComponentDetail'..(i - 1)..'baseAttackSpeed']
							tipTrigger['recipeComponentDetail'..(i - 1)..'maxHealth']		= overrideTrigger['recipeComponentDetail'..(i - 1)..'maxHealth']
							tipTrigger['recipeComponentDetail'..(i - 1)..'maxMana']			= overrideTrigger['recipeComponentDetail'..(i - 1)..'maxMana']
							tipTrigger['recipeComponentDetail'..(i - 1)..'baseHealthRegen']	= overrideTrigger['recipeComponentDetail'..(i - 1)..'baseHealthRegen']
							tipTrigger['recipeComponentDetail'..(i - 1)..'baseManaRegen']	= overrideTrigger['recipeComponentDetail'..(i - 1)..'baseManaRegen']
							tipTrigger['recipeComponentDetail'..(i - 1)..'description']		= overrideTrigger['recipeComponentDetail'..(i - 1)..'description']
							tipTrigger['recipeComponentDetail'..(i - 1)..'displayName']		= overrideTrigger['recipeComponentDetail'..(i - 1)..'displayName']
							tipTrigger['recipeComponentDetail'..(i - 1)..'entity']			= overrideTrigger['recipeComponentDetail'..(i - 1)..'entity']
							tipTrigger['recipeComponentDetail'..(i - 1)..'cost']			= overrideTrigger['recipeComponentDetail'..(i - 1)..'cost']
							
							totalCost = totalCost + overrideTrigger['recipeComponentDetail'..(i - 1)..'cost']
						end
					end
					
				else
					for i=1,3,1 do
						tipTrigger['recipeComponentDetail'..(i - 1)..'exists'] = false
					end
				end		
				
				if (overrideTrigger['currentEmpoweredEffectEntityName']) and (not Empty((overrideTrigger['currentEmpoweredEffectEntityName']))) and ValidateEntity((overrideTrigger['currentEmpoweredEffectEntityName'])) then
					if (overrideTrigger['currentEmpoweredEffectCost']) and tonumber((overrideTrigger['currentEmpoweredEffectCost'])) then
						totalCost = totalCost + tonumber((overrideTrigger['currentEmpoweredEffectCost']))
					end
				end
				
				tipTrigger.cost = overrideTrigger.cost or totalCost		
		
			elseif isUnfinishedCraft then
				overrideTrigger				= craftedDataOverride or LuaTrigger.GetTrigger('CraftingUnfinishedDesign')	
				tipTrigger					= LuaTrigger.GetTrigger('craftedItemInfoShop')
				
				if craftedDataOverride then
					index = craftedDataOverride.name
				end
				
				tipTrigger.exists			= true
				tipTrigger.icon				= GetEntityIconPath(index)
				tipTrigger.displayName		= GetEntityDisplayName(index)
				tipTrigger.description		= overrideTrigger.description
				tipTrigger.cooldown			= 0				-- rmm need this
				
				tipTrigger.manaCost			= 0				-- rmm need this
				tipTrigger.isRecipe			= isRecipe
				tipTrigger.isActivatable	= false			-- rmm need this
				
				tipTrigger.active 			= true
				tipTrigger.isExpired 		= overrideTrigger['isExpired']
				tipTrigger.isPermanent 		= overrideTrigger['isPermanent']
				tipTrigger.days 			= overrideTrigger['days']
				tipTrigger.monthsLeft 		= overrideTrigger['monthsLeft']
				tipTrigger.daysLeft 		= overrideTrigger['daysLeft']
				tipTrigger.hoursLeft 		= overrideTrigger['hoursLeft']
				tipTrigger.minutesLeft 		= overrideTrigger['minutesLeft']					
				
				local totalCost = 0
				
				if isRecipe then	-- zeroed out so it doesn't visually factor in components
					tipTrigger.power			= 0
					tipTrigger.baseAttackSpeed	= 0
					tipTrigger.armor		    = 0
					tipTrigger.magicArmor		= 0
					tipTrigger.mitigation		= 0
					tipTrigger.resistance		= 0
					tipTrigger.maxHealth		= 0
					tipTrigger.maxMana			= 0
					tipTrigger.baseHealthRegen	= 0
					tipTrigger.baseManaRegen	= 0
					totalCost = totalCost + overrideTrigger.recipeCost
				else
					tipTrigger.power			= overrideTrigger.power
					tipTrigger.baseAttackSpeed	= overrideTrigger.baseAttackSpeed
					tipTrigger.armor		    = overrideTrigger.armor
					tipTrigger.magicArmor		= overrideTrigger.magicArmor
					tipTrigger.mitigation		= overrideTrigger.mitigation
					tipTrigger.resistance		= overrideTrigger.resistance
					tipTrigger.maxHealth		= overrideTrigger.maxHealth
					tipTrigger.maxMana			= overrideTrigger.maxMana
					tipTrigger.baseHealthRegen	= overrideTrigger.baseHealthRegen
					tipTrigger.baseManaRegen	= overrideTrigger.baseManaRegen
					totalCost = totalCost + overrideTrigger.cost
				end
				
				tipTrigger.isPlayerCrafted	= (craftedDataOverride and true) or false
				tipTrigger.isRare			= (craftedDataOverride and craftedDataOverride.isRare) or false
				tipTrigger.isLegendary		= false

				tipTrigger.currentEmpoweredEffectEntityName		= overrideTrigger.currentEmpoweredEffectEntityName or ''
				tipTrigger.currentEmpoweredEffectCost			= overrideTrigger.currentEmpoweredEffectCost or 0
				tipTrigger.currentEmpoweredEffectDisplayName	= overrideTrigger.currentEmpoweredEffectDisplayName or ''
				tipTrigger.currentEmpoweredEffectDescription	= overrideTrigger.currentEmpoweredEffectDescription or ''				
				
				if isRecipe then
					for i=1,3,1 do
						tipTrigger['recipeComponentDetail'..(i - 1)..'exists'] = ((overrideTrigger['component'..i] ~= nil) and (not Empty((overrideTrigger['component'..i]))))
						if tipTrigger['recipeComponentDetail'..(i - 1)..'exists'] then
							tipTrigger['recipeComponentDetail'..(i - 1)..'icon'] = GetEntityIconPath(overrideTrigger['component'..i])
							
							componentInfo = craftingGetComponentByName(overrideTrigger['component'..i]) or Crafting.GetComponents()[overrideTrigger['component'..i]]

							tipTrigger['recipeComponentDetail'..(i - 1)..'power']			= componentInfo.power
							tipTrigger['recipeComponentDetail'..(i - 1)..'baseAttackSpeed']	= componentInfo.baseAttackSpeed
							tipTrigger['recipeComponentDetail'..(i - 1)..'maxHealth']		= componentInfo.maxHealth
							tipTrigger['recipeComponentDetail'..(i - 1)..'maxMana']			= componentInfo.maxMana
							tipTrigger['recipeComponentDetail'..(i - 1)..'baseHealthRegen']	= componentInfo.baseHealthRegen
							tipTrigger['recipeComponentDetail'..(i - 1)..'baseManaRegen']	= componentInfo.baseManaRegen
							tipTrigger['recipeComponentDetail'..(i - 1)..'description']		= componentInfo.description
							tipTrigger['recipeComponentDetail'..(i - 1)..'displayName']		= componentInfo.displayName
							tipTrigger['recipeComponentDetail'..(i - 1)..'entity']			= componentInfo.name
							tipTrigger['recipeComponentDetail'..(i - 1)..'cost']			= componentInfo.cost

							totalCost = totalCost + componentInfo.cost
							
						end
					end
					
				else
					for i=1,3,1 do
						tipTrigger['recipeComponentDetail'..(i - 1)..'exists'] = false
					end
				end		
				
				if (overrideTrigger['currentEmpoweredEffectEntityName']) and (not Empty((overrideTrigger['currentEmpoweredEffectEntityName']))) and ValidateEntity((overrideTrigger['currentEmpoweredEffectEntityName'])) then
					if (overrideTrigger['currentEmpoweredEffectCost']) and tonumber((overrideTrigger['currentEmpoweredEffectCost'])) then
						totalCost = totalCost + tonumber((overrideTrigger['currentEmpoweredEffectCost']))
					end
				end
				
				tipTrigger.cost = totalCost		
		
			elseif isCraftingEntity then	-- ugh
				tipTrigger					= LuaTrigger.GetTrigger('craftedItemInfoShop')
				tipTrigger.exists			= true
				tipTrigger.icon				= GetEntityIconPath(index)
				tipTrigger.displayName		= GetEntityDisplayName(index)
				tipTrigger.description		= itemInfo.description
				tipTrigger.cooldown			= 0				-- rmm need this
				
				tipTrigger.manaCost			= 0				-- rmm need this
				tipTrigger.isRecipe			= isRecipe
				tipTrigger.isActivatable	= false			-- rmm need this

				tipTrigger.active 			= true
				tipTrigger.isExpired 		= itemInfo['isExpired'] or false
				tipTrigger.isPermanent 		= itemInfo['isPermanent'] or false
				tipTrigger.days 			= itemInfo['days'] or 0
				tipTrigger.monthsLeft 		= itemInfo['monthsLeft'] or 0
				tipTrigger.daysLeft 		= itemInfo['daysLeft'] or 0
				tipTrigger.hoursLeft 		= itemInfo['hoursLeft'] or 0
				tipTrigger.minutesLeft 		= itemInfo['minutesLeft'] or 0					
				
				if isRecipe then	-- zeroed out so it doesn't visually factor in components
					tipTrigger.power			= 0
					tipTrigger.baseAttackSpeed		= 0
					tipTrigger.armor		    = 0
					tipTrigger.magicArmor		= 0
					tipTrigger.mitigation		= 0
					tipTrigger.resistance		= 0
					tipTrigger.maxHealth		= 0
					tipTrigger.maxMana			= 0
					tipTrigger.baseHealthRegen	= 0
					tipTrigger.baseManaRegen	= 0
					tipTrigger.cost				= itemInfo.craftingRecipeCost
				else
					tipTrigger.power			= itemInfo.power
					tipTrigger.baseAttackSpeed	= itemInfo.baseAttackSpeed
					tipTrigger.armor		    = itemInfo.armor
					tipTrigger.magicArmor		= itemInfo.magicArmor
					tipTrigger.mitigation		= itemInfo.mitigation
					tipTrigger.resistance		= itemInfo.resistance
					tipTrigger.maxHealth		= itemInfo.maxHealth
					tipTrigger.maxMana			= itemInfo.maxMana
					tipTrigger.baseHealthRegen	= itemInfo.baseHealthRegen
					tipTrigger.baseManaRegen	= itemInfo.baseManaRegen
					tipTrigger.cost				= itemInfo.cost
				end
				
				tipTrigger.isPlayerCrafted	= false
				tipTrigger.isRare			= false
				tipTrigger.isLegendary		= false

				tipTrigger.currentEmpoweredEffectEntityName	= itemInfo.currentEmpoweredEffectEntityName or ''
				tipTrigger.currentEmpoweredEffectCost	= itemInfo.currentEmpoweredEffectCost or 0
				tipTrigger.currentEmpoweredEffectDisplayName		= itemInfo.currentEmpoweredEffectDisplayName or ''
				tipTrigger.currentEmpoweredEffectDescription		= itemInfo.currentEmpoweredEffectDescription		 or ''			
				
				if isRecipe then
					for i=1,3,1 do
						tipTrigger['recipeComponentDetail'..(i - 1)..'exists'] = (itemInfo.components[i] ~= nil)
						if tipTrigger['recipeComponentDetail'..(i - 1)..'exists'] then
							tipTrigger['recipeComponentDetail'..(i - 1)..'icon'] = GetEntityIconPath(itemInfo.components[i])
							
							componentInfo = craftingGetComponentByName(itemInfo.components[i]) or Crafting.GetComponents()[itemInfo.components[i]]
							
							tipTrigger['recipeComponentDetail'..(i - 1)..'power']			= componentInfo.power
							tipTrigger['recipeComponentDetail'..(i - 1)..'baseAttackSpeed']	= componentInfo.baseAttackSpeed
							tipTrigger['recipeComponentDetail'..(i - 1)..'maxHealth']		= componentInfo.maxHealth
							tipTrigger['recipeComponentDetail'..(i - 1)..'maxMana']			= componentInfo.maxMana
							tipTrigger['recipeComponentDetail'..(i - 1)..'baseHealthRegen']	= componentInfo.baseHealthRegen
							tipTrigger['recipeComponentDetail'..(i - 1)..'baseManaRegen']	= componentInfo.baseManaRegen
							tipTrigger['recipeComponentDetail'..(i - 1)..'description']		= componentInfo.description
							tipTrigger['recipeComponentDetail'..(i - 1)..'displayName']		= componentInfo.displayName
							tipTrigger['recipeComponentDetail'..(i - 1)..'entity']			= componentInfo.name
							tipTrigger['recipeComponentDetail'..(i - 1)..'cost']			= componentInfo.cost

						end
					end
				else
					for i=1,3,1 do
						tipTrigger['recipeComponentDetail'..(i - 1)..'exists'] = false
					end
				end

			else
				local itemCost = nil
			
				tipTrigger					= LuaTrigger.GetTrigger('craftedItemInfoShop')
				tipTrigger.exists			= true
				if (itemInfo.name) and (not Empty(itemInfo.name)) then
					tipTrigger.icon				= GetEntityIconPath(itemInfo.name)
					tipTrigger.displayName		= GetEntityDisplayName(itemInfo.name)
				else
					tipTrigger.icon			 = '$checker'
					tipTrigger.displayName	 = 'N/A'
				end
				tipTrigger.description		= itemInfo.description
				tipTrigger.cooldown			= 0				-- rmm need this
				itemCost					= itemInfo.recipeCost
				tipTrigger.manaCost			= 0				-- rmm need this
				tipTrigger.isRecipe			= true
				tipTrigger.isActivatable	= false			-- rmm need this

				tipTrigger.power			= itemInfo.power
				tipTrigger.baseAttackSpeed		= itemInfo.baseAttackSpeed
				tipTrigger.armor		    = itemInfo.armor
				tipTrigger.magicArmor		= itemInfo.magicArmor
				tipTrigger.mitigation		= itemInfo.mitigation
				tipTrigger.resistance		= itemInfo.resistance
				tipTrigger.maxHealth		= itemInfo.maxHealth
				tipTrigger.maxMana			= itemInfo.maxMana
				tipTrigger.baseHealthRegen	= itemInfo.baseHealthRegen
				tipTrigger.baseManaRegen	= itemInfo.baseManaRegen
				
				tipTrigger.isPlayerCrafted	= true
				tipTrigger.isRare			= itemInfo.isRare
				tipTrigger.isLegendary		= itemInfo.isLegendary
				
				
				tipTrigger.bonusDescription		= itemInfo.bonusDescription
				tipTrigger.normalQuality		= itemInfo.normalQuality

				tipTrigger.rareDisplayName		= itemInfo.rareBonusName
				tipTrigger.rareDescription		= itemInfo.rareBonusDescription
				tipTrigger.rareQuality			= itemInfo.rareQuality
				tipTrigger.rareIcon				= itemInfo.rareBonusIcon

				tipTrigger.legendaryDisplayName	= itemInfo.legendaryBonusName
				tipTrigger.legendaryDescription	= itemInfo.legendaryBonusDescription
				tipTrigger.legendaryQuality		= itemInfo.legendaryQuality
				tipTrigger.legendaryIcon		= itemInfo.legendaryBonusIcon
				
				tipTrigger.currentEmpoweredEffectEntityName	= itemInfo.currentEmpoweredEffectEntityName or ''
				tipTrigger.currentEmpoweredEffectCost	= itemInfo.currentEmpoweredEffectCost or 0
				tipTrigger.currentEmpoweredEffectDisplayName		= itemInfo.currentEmpoweredEffectDisplayName or ''
				tipTrigger.currentEmpoweredEffectDescription		= itemInfo.currentEmpoweredEffectDescription or ''				

				tipTrigger.active 			= true
				tipTrigger.isExpired 		= itemInfo['isExpired'] or false
				tipTrigger.isPermanent 		= itemInfo['isPermanent'] or false
				tipTrigger.days 			= itemInfo['days'] or 0
				tipTrigger.monthsLeft 		= itemInfo['monthsLeft'] or 0
				tipTrigger.daysLeft 		= itemInfo['daysLeft'] or 0
				tipTrigger.hoursLeft 		= itemInfo['hoursLeft'] or 0
				tipTrigger.minutesLeft 		= itemInfo['minutesLeft']	 or 0				
				
				for i=1,3,1 do
					tipTrigger['recipeComponentDetail'..(i - 1)..'exists'] = (string.len(itemInfo['component'..i]) > 0)
					if tipTrigger['recipeComponentDetail'..(i - 1)..'exists'] then
						tipTrigger['recipeComponentDetail'..(i - 1)..'icon'] = GetEntityIconPath(itemInfo['component'..i])
						
						componentInfo = craftingGetComponentByName(itemInfo['component'..i]) or Crafting.GetComponents()[itemInfo['component'..i]]
						
						
						itemCost = itemCost + componentInfo.cost
						tipTrigger['recipeComponentDetail'..(i - 1)..'power']			= componentInfo.power
						tipTrigger['recipeComponentDetail'..(i - 1)..'baseAttackSpeed']	= componentInfo.baseAttackSpeed
						tipTrigger['recipeComponentDetail'..(i - 1)..'maxHealth']		= componentInfo.maxHealth
						tipTrigger['recipeComponentDetail'..(i - 1)..'maxMana']			= componentInfo.maxMana
						tipTrigger['recipeComponentDetail'..(i - 1)..'baseHealthRegen']	= componentInfo.baseHealthRegen
						tipTrigger['recipeComponentDetail'..(i - 1)..'baseManaRegen']	= componentInfo.baseManaRegen
						tipTrigger['recipeComponentDetail'..(i - 1)..'description']		= componentInfo.description
						tipTrigger['recipeComponentDetail'..(i - 1)..'displayName']		= componentInfo.displayName
						tipTrigger['recipeComponentDetail'..(i - 1)..'entity']			= componentInfo.name
						tipTrigger['recipeComponentDetail'..(i - 1)..'cost']			= componentInfo.cost
						
					end
				end
				
				if (itemInfo['currentEmpoweredEffectEntityName']) and (not Empty((itemInfo['currentEmpoweredEffectEntityName']))) and ValidateEntity((itemInfo['currentEmpoweredEffectEntityName'])) then
					if (itemInfo['currentEmpoweredEffectCost']) and tonumber((itemInfo['currentEmpoweredEffectCost'])) then
						itemCost = itemCost + tonumber((itemInfo['currentEmpoweredEffectCost']))
					end
				end				
				
				tipTrigger.cost = itemCost

			end


		else
		
			local itemCost = nil
		
			tipTrigger = LuaTrigger.GetTrigger('craftedItemTipInfo')
			tipTrigger.visible						= true
			itemCost								= itemInfo.recipeCost
			tipTrigger.icon							= GetEntityIconPath(itemInfo.name)
			tipTrigger.title						= GetEntityDisplayName(itemInfo.name)
			tipTrigger.description					= itemInfo.description
			tipTrigger.analogTierString				= ' (Tier '..math.floor(itemInfo.normalQuality * 10)..')'
			tipTrigger.analogBonusDescription		= itemInfo.bonusDescription

			tipTrigger.rareBonusExists				= itemInfo.isRare
			tipTrigger.rareBonusIcon				= itemInfo.rareBonusIcon
			tipTrigger.rareBonusTitle				= itemInfo.rareBonusName..' Tier ('..math.floor(itemInfo.rareQuality * 10)..')'
			tipTrigger.rareBonusDescription			= itemInfo.rareBonusDescription
			tipTrigger.legendaryBonusExists			= itemInfo.isLegendary
			tipTrigger.legendaryBonusIcon			= itemInfo.legendaryBonusIcon
			tipTrigger.legendaryBonusTitle			= itemInfo.legendaryBonusName..' Tier ('..math.floor(itemInfo.legendaryQuality * 10)..')'
			tipTrigger.legendaryBonusDescription	= itemInfo.legendaryBonusDescription

			tipTrigger.currentEmpoweredEffectEntityName	= itemInfo.currentEmpoweredEffectEntityName or ''
			tipTrigger.currentEmpoweredEffectCost	= itemInfo.currentEmpoweredEffectCost or 0
			tipTrigger.currentEmpoweredEffectDisplayName		= itemInfo.currentEmpoweredEffectDisplayName or ''
			tipTrigger.currentEmpoweredEffectDescription		= itemInfo.currentEmpoweredEffectDescription or ''			
			
			tipTrigger.active 			= true
			tipTrigger.isExpired 		= itemInfo['isExpired'] or false
			tipTrigger.isPermanent 		= itemInfo['isPermanent'] or false
			tipTrigger.days 			= itemInfo['days'] or 0
			tipTrigger.monthsLeft 		= itemInfo['monthsLeft'] or 0
			tipTrigger.daysLeft 		= itemInfo['daysLeft'] or 0
			tipTrigger.hoursLeft 		= itemInfo['hoursLeft'] or 0
			tipTrigger.minutesLeft 		= itemInfo['minutesLeft'] or 0				
			
			for i=1,3,1 do
				tipTrigger['component'..i..'Exists']	= (string.len(itemInfo['component'..i]) > 0)
				if tipTrigger['component'..i..'Exists'] then
					tipTrigger['component'..i..'Icon'] = GetEntityIconPath(itemInfo['component'..i])
					
					componentInfo = craftingGetComponentByName(itemInfo['component'..i])
					
					itemCost = itemCost + componentInfo.cost
					tipTrigger['recipeComponentDetail'..(i - 1)..'power']			= componentInfo.power
					tipTrigger['recipeComponentDetail'..(i - 1)..'baseAttackSpeed']	= componentInfo.baseAttackSpeed
					tipTrigger['recipeComponentDetail'..(i - 1)..'maxHealth']		= componentInfo.maxHealth
					tipTrigger['recipeComponentDetail'..(i - 1)..'maxMana']			= componentInfo.maxMana
					tipTrigger['recipeComponentDetail'..(i - 1)..'baseHealthRegen']	= componentInfo.baseHealthRegen
					tipTrigger['recipeComponentDetail'..(i - 1)..'baseManaRegen']	= componentInfo.baseManaRegen
					tipTrigger['recipeComponentDetail'..(i - 1)..'description']		= componentInfo.description
					tipTrigger['recipeComponentDetail'..(i - 1)..'displayName']		= componentInfo.displayName
					tipTrigger['recipeComponentDetail'..(i - 1)..'cost']			= componentInfo.cost
					
				end
			end

			if (itemInfo['currentEmpoweredEffectEntityName']) and (not Empty((itemInfo['currentEmpoweredEffectEntityName']))) and ValidateEntity((itemInfo['currentEmpoweredEffectEntityName'])) then
				if (itemInfo['currentEmpoweredEffectCost']) and tonumber((itemInfo['currentEmpoweredEffectCost'])) then
					itemCost = itemCost + tonumber((itemInfo['currentEmpoweredEffectCost']))
				end
			end				
			
			tipTrigger.cost = itemCost
			
			for k,v in pairs(tipStatTypeList) do
				tipTrigger[v]	= itemInfo[craftedItemEffectPerType[v]]
			end
		end

		tipTrigger:Trigger(false)
	end

	-- ======================================================================================

	itemTipTrigger.visible						= false
	itemTipTrigger.icon							= ''
	itemTipTrigger.title						= ''
	itemTipTrigger.description					= ''
	itemTipTrigger.cost							= -1
	itemTipTrigger.power						= -1
	itemTipTrigger.hp							= -1
	itemTipTrigger.mp							= -1
	itemTipTrigger.hpregen						= -1
	itemTipTrigger.mpregen						= -1
	itemTipTrigger.component1Icon				= ''
	itemTipTrigger.component2Icon				= ''
	itemTipTrigger.component3Icon				= ''
	itemTipTrigger.component1Exists				= false
	itemTipTrigger.component2Exists				= false
	itemTipTrigger.component3Exists				= false
	itemTipTrigger.analogBonusDescription		= ''
	itemTipTrigger.rareBonusExists				= false
	itemTipTrigger.rareBonusIcon				= ''
	itemTipTrigger.rareBonusTitle				= ''
	itemTipTrigger.rareBonusDescription			= ''
	itemTipTrigger.legendaryBonusExists			= false
	itemTipTrigger.legendaryBonusIcon			= ''
	itemTipTrigger.legendaryBonusTitle			= ''
	itemTipTrigger.legendaryBonusDescription	= ''
	itemTipTrigger.currentEmpoweredEffectEntityName	= ''
	itemTipTrigger.currentEmpoweredEffectCost		= 0
	itemTipTrigger.currentEmpoweredEffectDisplayName		= ''
	itemTipTrigger.currentEmpoweredEffectDescription = ''
	itemTipTrigger:Trigger(true)

end

craftedItemTipRegister(object)