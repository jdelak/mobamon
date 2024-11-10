local REROLL_ANIMATION_TIME = 5000

craftingLastDraggedComponent	= ''

enchantLastNormalQuality	= 0
enchantLastRareQuality		= 0
enchantLastLegendaryQuality	= 0
enchantLastIsRare		= false
enchantLastIsLegendary	= false

local lastTotalCost = 0	
local lastJublieCost = 0
local lastPopupJublieValue = {0, 0, 0}
local lastStage
	
local CraftingAnimationStatus = LuaTrigger.GetTrigger('CraftingAnimationStatus') or LuaTrigger.CreateCustomTrigger('CraftingAnimationStatus',
	{
		{ name	= 'rerollAnimating',			type	= 'bool' },
		{ name	= 'enchantAnimating',			type	= 'bool' },
		{ name	= 'craftAnimating',				type	= 'bool' },
		{ name	= 'requestPending',				type	= 'bool' },
	}
)

local craftingStageMainPanelTrigger = LuaTrigger.GetTrigger('craftingStageMainPanelTrigger') or libGeneral.createGroupTrigger('craftingStageMainPanelTrigger', {
	'craftingStage.stage',
	'mainPanelStatus.main',
	'craftingCraftInfo.minComponentCost',
	'craftingCraftInfo.componentCost',
	'CraftingUnfinishedDesign.currentEmpoweredEffectEntityName',
	'CraftingUnfinishedDesign.name',
})	

local CraftingGroupStatus = LuaTrigger.GetTrigger('CraftingGroupStatus') or libGeneral.createGroupTrigger('CraftingGroupStatus', {
	'CraftingAnimationStatus.rerollAnimating',
	'CraftingAnimationStatus.enchantAnimating',
	'CraftingAnimationStatus.craftAnimating',
	'CraftingAnimationStatus.requestPending',
	'GameClientRequestsEnchantCraftedItem.status',
	'GameClientRequestsSalvageCraftedItem.status',
	'GameClientRequestsTemperCraftedItemWithEssence.status',
	'GameClientRequestsTemperCraftedItemWithGems.status',
	'GameClientRequestsRerollRareEffectOnCraftedItem.status',
	'CraftingCommodityInfo.essenceCount',
	'craftingStage.stage',	
	'GameClientRequestsCreateCraftedItem.status',
	'CraftingUnfinishedDesign.name',
	'craftingCraftInfo.componentCost',
	'craftingCraftInfo.minComponentCost',
	'craftingCraftInfo.oreCount',
	'craftingCraftInfo.oreCost',
	'craftingCraftInfo.gemCost',
	'craftingCraftInfo.entity',
	'craftingCraftInfo.selectedComponentIndex',
	'craftingStage.craftedItemCount',
	'CraftingUnclaimedDesign.oreCost',
	'CraftingUnclaimedDesign.salvageWorth',
	'CraftingCommodityInfo.oreCount',
})

local CraftingAnimGroupStatus = LuaTrigger.GetTrigger('CraftingAnimGroupStatus') or libGeneral.createGroupTrigger('CraftingAnimGroupStatus', {
	'GameClientRequestsEnchantCraftedItem.status',
	'GameClientRequestsSalvageCraftedItem.status',
	'GameClientRequestsTemperCraftedItemWithEssence.status',
	'GameClientRequestsTemperCraftedItemWithGems.status',
	'GameClientRequestsRerollRareEffectOnCraftedItem.status',
	'CraftingCommodityInfo.essenceCount',
	'craftingStage.stage',	
	'GameClientRequestsCreateCraftedItem.status',
	'CraftingUnfinishedDesign.name',
	'craftingCraftInfo.componentCost',
	'craftingCraftInfo.minComponentCost',
	'craftingCraftInfo.oreCount',
	'craftingCraftInfo.oreCost',
	'craftingCraftInfo.gemCost',
	'craftingCraftInfo.entity',
	'craftingCraftInfo.selectedComponentIndex',
	'craftingStage.craftedItemCount',
	'CraftingUnclaimedDesign.oreCost',
	'CraftingUnclaimedDesign.gemCost',
	'CraftingUnclaimedDesign.salvageWorth',
	'CraftingCommodityInfo.oreCount',
})

GetWidget('mainCrafting'):RegisterWatchLua('CraftingAnimGroupStatus', function(widget, groupTrigger)
	local triggerEnchantStatus		= groupTrigger['GameClientRequestsEnchantCraftedItem']
	local triggerTemperStatus		= groupTrigger['GameClientRequestsTemperCraftedItemWithEssence']
	local triggerTemperStatusGems	= groupTrigger['GameClientRequestsTemperCraftedItemWithGems']
	local triggerSalvageStatus		= groupTrigger['GameClientRequestsSalvageCraftedItem']
	local triggerRerollStatus		= groupTrigger['GameClientRequestsRerollRareEffectOnCraftedItem']
	local triggerCraftItemStatus	= groupTrigger['GameClientRequestsCreateCraftedItem']

	local notBusy		= (
		triggerEnchantStatus.status ~= 1 and
		triggerTemperStatus.status ~= 1 and
		triggerTemperStatusGems.status ~= 1 and
		triggerRerollStatus.status ~= 1 and
		triggerSalvageStatus.status ~= 1 and
		triggerCraftItemStatus.status ~= 1
	)		

	if (triggerCraftItemStatus.status ~= 1) then
		CraftingAnimationStatus.craftAnimating = false
	end
	
	CraftingAnimationStatus.requestPending = not notBusy
	CraftingAnimationStatus:Trigger(true)

end)

libGeneral.createGroupTrigger('craftingStageUnclaimed', {
	'craftingStage.stage',
	'CraftingUnclaimedDesign.available',
	'CraftingUnclaimedDesign.isRare',
	'CraftingUnclaimedDesign.isLegendary',
	'CraftingUnclaimedDesign.name',
	'CraftingUnclaimedDesign.craftingSlot',
	'CraftingUnclaimedDesign.id',
	'mainPanelAnimationStatus.main',
	'mainPanelAnimationStatus.newMain'
})

CraftingAnimationStatus.rerollAnimating = false
CraftingAnimationStatus.enchantAnimating = false
CraftingAnimationStatus.craftAnimating = false
CraftingAnimationStatus.requestPending = false
CraftingAnimationStatus:Trigger(false)

local function getCraftedItemQualityBar(object, prefix, suffix)
	--[[
	local barPips = {}
	for i=1,9,1 do
		barPips[i] = object:GetWidget(prefix..suffix..'Pip'..i)
	end
	--]]
	return {
		bar					= object:GetWidget(prefix..suffix..'Bar'),
		barLabel			= object:GetWidget(prefix..suffix..'BarLabel'),			-- Percent
		barEffect			= object:GetWidget(prefix..suffix..'BarEffect'),
		-- barPips				= barPips,
		barPipsContainer	= object:GetWidget(prefix..suffix..'BarPipsContainer'),
		unlockLabel			= object:GetWidget(prefix..suffix..'UnlockLabel')		-- 'Unlock X!'
	}
end

local bonusThread
local function craftedItemQualityInfoPopulateBonus(object, prefix, bonusType, bonusInfo, bonusChanged)
	if bonusType and bonusInfo then
		local locked		= object:GetWidget(prefix..bonusType..'Locked')
		local name			= object:GetWidget(prefix..bonusType..'BonusName')
		local description	= object:GetWidget(prefix..bonusType..'BonusDescription')
		local iconContainer	= object:GetWidget(prefix..bonusType..'IconContainer')
		local icon			= object:GetWidget(prefix..bonusType..'Icon')
		local animContainer	= object:GetWidget(prefix..bonusType..'IconAnimContainer')
		local animInsertion	= object:GetWidget(prefix..bonusType..'IconAnimInsertion')
		local backer		= object:GetWidget(prefix..bonusType..'Backer')
		local BackerGlow	= object:GetWidget(prefix..bonusType..'BackerGlow')

		if bonusInfo.exists then
			
			if (bonusChanged) and (animContainer) and (animInsertion) then
			
				if (bonusThread) then
					bonusThread:kill()
					backer:SetRenderMode('normal')
					backer:SetColor(1,1,1)					
					BackerGlow:SetVisible(true)					
					locked:SetVisible(false)
					if bonusType ~= 'Analog' then
						name:SetText(bonusInfo.name)
						icon:SetTexture(bonusInfo.icon)
					else
						name:SetVisible(false)
					end
					description:SetText(StripColorCodes(bonusInfo.description))
					iconContainer:SetVisible(true)					
					groupfcall(prefix .. bonusType.. 'RollAnim1', function(_, widget) widget:FadeIn(250) end)
					animContainer:SetVisible(0)
					groupfcall('mainEnchantBonusRerollIconTemplates', function(_, widget) widget:Destroy() end)						
					
					CraftingAnimationStatus.rerollAnimating = false
					CraftingAnimationStatus:Trigger(false)
					
					bonusThread = nil
				end				
				bonusThread = libThread.threadFunc(function()	

					CraftingAnimationStatus.rerollAnimating = true
					CraftingAnimationStatus:Trigger(false)				
				
					groupfcall(prefix .. bonusType.. 'RollAnim1', function(_, widget) widget:FadeOut(250) end)
					locked:FadeOut(250)
					wait(250)
							
					animContainer:SetVisible(1)
							
					local BONUS_ICON_TABLE = {
						'/items/rarecomponents/brutality/icon.tga',
						'/items/rarecomponents/casting/icon.tga',
						'/items/rarecomponents/fervor/icon.tga',
						'/items/rarecomponents/mastery/icon.tga',
						'/items/rarecomponents/perseverence/icon.tga',
						-- '/items/rarecomponents/power/icon.tga',
						'/items/rarecomponents/resistance/icon.tga',
						'/items/rarecomponents/siphoning/icon.tga',
						'/items/rarecomponents/swiftness/icon.tga',
						'/items/rarecomponents/toughness/icon.tga',
						'/items/rarecomponents/vampirism/icon.tga',
						'/items/rarecomponents/wisdom/icon.tga',
					}					
					
					table.insert(BONUS_ICON_TABLE, bonusInfo.icon)
					
					local transitionDuration = (REROLL_ANIMATION_TIME / #BONUS_ICON_TABLE) / 4.55
					
					local function SpawnIcon(iconPath, index, delayIndex, stopCenter)
						local spawnedIcons = animInsertion:InstantiateAndReturn('mainEnchantBonusRerollIconTemplate', 'icon', iconPath)
						local spawnedIcon = spawnedIcons[1]
						
						local tempTransitionDuration = (transitionDuration * ((delayIndex/10)) / 2)
						
						spawnedIcon:SetHeight('50%')
						spawnedIcon:SetWidth('50%')
						spawnedIcon:SetY('-80%')
						spawnedIcon:FadeIn(tempTransitionDuration / 2)

						spawnedIcon:Scale('100%', '100%', tempTransitionDuration)
						spawnedIcon:SlideY('0', tempTransitionDuration, true)	
						
						if (not stopCenter) then
							PlaySound('/ui/sounds/rewards/sfx_tally_oneshot.wav')
							wait(tempTransitionDuration * 1.01)
							
							spawnedIcon:Scale('50%', '50%', tempTransitionDuration)
							spawnedIcon:SlideY('150%', tempTransitionDuration, true)
							spawnedIcon:FadeOut(tempTransitionDuration)
						else
							PlaySound('/ui/sounds/rewards/sfx_tally_oneshot.wav')
						end
					end
					
					for index, path in ipairs(BONUS_ICON_TABLE) do
						if (path ~= bonusInfo.icon) then
							SpawnIcon(path, index, index)
						end
					end

					for index, path in ipairs(BONUS_ICON_TABLE) do
						if (path ~= bonusInfo.icon) then
							SpawnIcon(path, index, (index + #BONUS_ICON_TABLE))
						end
					end					

					for index, path in ipairs(BONUS_ICON_TABLE) do
						if (path ~= bonusInfo.icon) then
							SpawnIcon(path, index, (index + (2 * #BONUS_ICON_TABLE)))
						end
					end						
					
					for index, path in ipairs(BONUS_ICON_TABLE) do
						if (path ~= bonusInfo.icon) then
							SpawnIcon(path, index, (index + (3 * #BONUS_ICON_TABLE)))
						end
					end						
					
					SpawnIcon(bonusInfo.icon, 1, (4 * #BONUS_ICON_TABLE), true)
					
					wait(transitionDuration * 2)
					-- Return To Normal
					backer:SetRenderMode('normal')
					backer:SetColor(1,1,1)
					
					BackerGlow:SetVisible(true)					
					
					locked:SetVisible(false)
					if bonusType ~= 'Analog' then
						name:SetText(bonusInfo.name)
						icon:SetTexture(bonusInfo.icon)
					else
						name:SetVisible(false)
					end
					description:SetText(StripColorCodes(bonusInfo.description))
					iconContainer:SetVisible(true)					
					groupfcall(prefix .. bonusType.. 'RollAnim1', function(_, widget) widget:FadeIn(250) end)
					animContainer:SetVisible(0)
					groupfcall('mainEnchantBonusRerollIconTemplates', function(_, widget) widget:Destroy() end)				
					
					CraftingAnimationStatus.rerollAnimating = false
					CraftingAnimationStatus:Trigger(false)
					
					bonusThread = nil
				end)
			else
				backer:SetRenderMode('normal')
				backer:SetColor(1,1,1)				
				BackerGlow:SetVisible(true)				
				locked:SetVisible(true)
				locked:SetVisible(false)
				if bonusType ~= 'Analog' then
					name:SetText(bonusInfo.name)
					icon:SetTexture(bonusInfo.icon)
				else
					name:SetVisible(false)
				end
				
				description:SetText(StripColorCodes(bonusInfo.description))
				
				iconContainer:SetVisible(true)
			end
			
		else
			backer:SetRenderMode('grayscale')
			backer:SetColor(0.5, 0.5, 0.5)			
			BackerGlow:SetVisible(false)			
			locked:SetVisible(true)
			if bonusType ~= 'Analog' then
				name:SetText(Translate('crafting_locked'))
			else
				name:SetVisible(false)
			end
			description:SetText(Translate('crafting_bonus_'..bonusType..'_description'))
			iconContainer:SetVisible(false)
		end

	end
end

local function craftedItemQualityBarSetValue(widgets, value)	-- no anims
	if value <= 0 then
		widgets.bar:SetWidth(0)
		widgets.unlockLabel:SetVisible(true)
		widgets.barPipsContainer:SetVisible(false)
		widgets.barLabel:SetVisible(false)
	else
		if value < 1 then
			widgets.bar:SetWidth(ToPercent(value))
			widgets.unlockLabel:SetVisible(false)
			widgets.barPipsContainer:SetVisible(true)
		else
			widgets.bar:SetWidth('100%')
			widgets.unlockLabel:SetVisible(false)
			widgets.barPipsContainer:SetVisible(false)
		end
		widgets.barLabel:SetVisible(true)
		widgets.barLabel:SetText(libNumber.round((value * 100), 0)..'%')
		widgets.barEffect:SetUScale((widgets.barEffect:GetHeight() * 8)..'p')
	end
end

local lastItemQualityValues = {}

local nameQualityUpdateThread
local function updateItemNameFromQualityInfo(widget, itemName, isRare, isLegendary, rareBonus, legendaryBonus)
	widget:SetVisible(0)
	widget:SetColor(libGeneral.craftedItemGetNameColor(isRare, isLegendary))

	local fullItemName = libGeneral.craftedItemFormatName(itemName, isRare, rareBonus, isLegendary, legendaryBonus)
	FitFontToLabel(widget, fullItemName)
	widget:SetText(fullItemName)
	widget:FadeIn(250)
end

local updateCraftedItemQualityThread
function updateCraftedItemQuality(object, prefix, animate, newValues, forceUpdate, qualityInfo)	-- rmm local after testing
	animate		= animate or false
	forceUpdate	= forceUpdate or false

	local qualityBars = {
		common			= getCraftedItemQualityBar(object, prefix, 'Common'),
		rare			= getCraftedItemQualityBar(object, prefix, 'Rare'),
		legendary		= getCraftedItemQualityBar(object, prefix, 'Legendary')
	}
	
	if not lastItemQualityValues[prefix] then
		forceUpdate = true
		lastItemQualityValues[prefix] = {
			common		= 0,
			rare		= 0,
			legendary	= 0,
			commonBonus		= ((qualityInfo and qualityInfo.commonBonus) or 'None'),
			rareBonus		= ((qualityInfo and qualityInfo.rareBonus) or 'None'),
			legendaryBonus	= ((qualityInfo and qualityInfo.legendaryBonus) or 'None'),
			id				= ((qualityInfo and qualityInfo.id) or 'None'),
		}
	end

	local startValue = (
		lastItemQualityValues[prefix].common +
		lastItemQualityValues[prefix].rare +
		lastItemQualityValues[prefix].legendary
	)
	
	local newValue = ( newValues.common + newValues.rare + newValues.legendary )


	local commonBonusChanged, rareBonusChanged, legendaryBonusChanged = false, false, false
	if ((qualityInfo and qualityInfo.isNewCraft and qualityInfo.commonBonus and qualityInfo.commonBonus ~= 'None' and qualityInfo.commonBonus ~= '') or qualityInfo and qualityInfo.commonBonus and lastItemQualityValues[prefix].commonBonus and lastItemQualityValues[prefix].commonBonus ~= qualityInfo.commonBonus and ((lastItemQualityValues[prefix].commonBonus ~= 'None')) and qualityInfo.commonBonus ~= 'None' and qualityInfo.commonBonus ~= '' and  ((qualityInfo.id == lastItemQualityValues[prefix].id) or (lastItemQualityValues[prefix].id == 'None')) ) then
		-- commonBonusChanged = true -- just in case we decide to have multiple of these
	end
	if (qualityInfo and qualityInfo.isNewCraft and qualityInfo.rareBonus and qualityInfo.rareBonus ~= 'None' and qualityInfo.rareBonus ~= '') or (qualityInfo and qualityInfo.rareBonus and lastItemQualityValues[prefix].rareBonus and lastItemQualityValues[prefix].rareBonus ~= qualityInfo.rareBonus and qualityInfo.rareBonus ~= 'None' and qualityInfo.rareBonus ~= '' and ((lastItemQualityValues[prefix].rareBonus ~= 'None')) and ((qualityInfo.id == lastItemQualityValues[prefix].id) or (lastItemQualityValues[prefix].id == 'None')) ) then
		rareBonusChanged = true
	end
	if (qualityInfo and qualityInfo.isNewCraft and qualityInfo.legendaryBonus and qualityInfo.legendaryBonus ~= 'None' and qualityInfo.legendaryBonus ~= '') or (qualityInfo and qualityInfo.legendaryBonus and lastItemQualityValues[prefix].legendaryBonus and lastItemQualityValues[prefix].legendaryBonus ~= qualityInfo.legendaryBonus and ((lastItemQualityValues[prefix].legendaryBonus ~= 'None')) and qualityInfo.legendaryBonus ~= '' and qualityInfo.legendaryBonus ~= 'None'  and ((qualityInfo.id == lastItemQualityValues[prefix].id) or (lastItemQualityValues[prefix].id == 'None')) ) then
		-- legendaryBonusChanged = true -- just in case we decide to have multiple of these
	end

	if forceUpdate or newValue ~= startValue or commonBonusChanged or rareBonusChanged or legendaryBonusChanged then
		object:GetWidget(prefix..'AnalogIcon'):SetTexture('/ui/main/enchanting/textures/common_bonus.tga')
		if animate and newValue > startValue then
			local qualityDiff	= newValue - startValue
			local timeMult		= 2000
			local animTime		= qualityDiff * timeMult

			CraftingAnimationStatus.enchantAnimating = true
			CraftingAnimationStatus:Trigger(false)			
			
			if (updateCraftedItemQualityThread) then
				updateCraftedItemQualityThread:kill()
				CraftingAnimationStatus.enchantAnimating = false
				CraftingAnimationStatus:Trigger(false)				
				updateCraftedItemQualityThread = nil
			end
			
			updateCraftedItemQualityThread = libThread.threadFunc(function()	
				wait(animTime)			
				CraftingAnimationStatus.enchantAnimating = false
				CraftingAnimationStatus:Trigger(false)
				updateCraftedItemQualityThread = nil
			end)
			
			local isRare				= (startValue >= 1.1)
			local isLegendary			= (startValue >= 2.1)
			local isPerfectLegendary	= (startValue >= 3)

			if qualityInfo then
				if (commonBonusChanged) or (rareBonusChanged) or (legendaryBonusChanged) then
					if (nameQualityUpdateThread) then nameQualityUpdateThread:kill() nameQualityUpdateThread = nil end
					nameQualityUpdateThread = libThread.threadFunc(function()	
						wait(REROLL_ANIMATION_TIME * 1.1)
						updateItemNameFromQualityInfo(object:GetWidget(prefix..'ItemName'), qualityInfo.itemName, isRare, isLegendary, qualityInfo.rareBonus, qualityInfo.legendaryBonus)
						nameQualityUpdateThread = nil
					end)
				else
					updateItemNameFromQualityInfo(object:GetWidget(prefix..'ItemName'), qualityInfo.itemName, isRare, isLegendary, qualityInfo.rareBonus, qualityInfo.legendaryBonus)
				end						
					
				craftedItemQualityInfoPopulateBonus(object, prefix, 'Analog', {
					exists		= true,
					name		= '',
					description = qualityInfo.analogDescription,
					icon		= '/ui/main/enchanting/textures/common_bonus.tga'
				}, commonBonusChanged)
					
				craftedItemQualityInfoPopulateBonus(object, prefix, 'Rare', {
					exists		= isRare,
					name		= qualityInfo.rareBonus,
					description	= qualityInfo.rareDescription,
					icon		= qualityInfo.rareIcon
				}, rareBonusChanged)

				craftedItemQualityInfoPopulateBonus(object, prefix, 'Legendary', {
					exists		= isLegendary,
					name		= qualityInfo.legendaryBonus,
					description	= qualityInfo.legendaryDescription,
					icon		= qualityInfo.legendaryIcon
				}, legendaryBonusChanged)
			end
			
			mainUI.RefreshProducts()
			PlaySound('/ui/sounds/crafting/sfx_barfill_start.wav')
			
			if GetCvarBool('_thepriceiswrong') then
				PlaySound('/ui/sounds/crafting/sfx_barfill_yodel.wav', 1, 14)
			else
				PlaySound('/ui/sounds/crafting/sfx_barfill.wav', 1, 14)	-- , (startValue * timeMult)
			end

			if GetCvarBool('_thepriceiswrong') then
				object:GetWidget(prefix..'Marker'):SetVisible(true)
				libAnims.wobbleStart2(object:GetWidget(prefix..'MarkerBody'), 1000, 32, -16)
			else
				object:GetWidget(prefix..'Marker'):SetVisible(false)
			end
			
			local thePriceIsWrong = GetCvarBool('_thepriceiswrong')
			
			libAnims.customTween(qualityBars.common.bar, animTime, function(posPercent)
				local currentQuality = startValue + (qualityDiff * posPercent)
				
				if thePriceIsWrong then
					object:GetWidget(prefix..'Marker'):SetX(ToPercent(currentQuality / 3))
				end
				
				if currentQuality >= 2.8 and newValue >= 3 then
					if not isPerfectLegendary then
						-- sound_craftAchievePerfectLegendary
						PlaySound('/ui/sounds/crafting/sfx_legendary_perfect.wav')
						isPerfectLegendary = true
						if (commonBonusChanged) or (rareBonusChanged) or (legendaryBonusChanged) then
							if (nameQualityUpdateThread) then nameQualityUpdateThread:kill() nameQualityUpdateThread = nil end
							nameQualityUpdateThread = libThread.threadFunc(function()	
								wait(REROLL_ANIMATION_TIME * 1.1)						
								updateItemNameFromQualityInfo(object:GetWidget(prefix..'ItemName'), qualityInfo.itemName, isRare, isLegendary, qualityInfo.rareBonus, qualityInfo.legendaryBonus)
								nameQualityUpdateThread = nil
							end)
						else
							updateItemNameFromQualityInfo(object:GetWidget(prefix..'ItemName'), qualityInfo.itemName, isRare, isLegendary, qualityInfo.rareBonus, qualityInfo.legendaryBonus)
						end
						craftedItemQualityInfoPopulateBonus(object, prefix, 'Legendary', {
							exists		= true,
							name		= qualityInfo.legendaryBonus,
							description	= qualityInfo.legendaryDescription,
							icon		= qualityInfo.legendaryIcon
						}, legendaryBonusChanged)						
					end
				elseif currentQuality >= 1.9 and newValue >= 2.1 then
					if not isLegendary then
						PlaySound('/ui/sounds/crafting/sfx_legendary.wav')
						isLegendary = true
						if qualityInfo then
							if (commonBonusChanged) or (rareBonusChanged) or (legendaryBonusChanged) then
								if (nameQualityUpdateThread) then nameQualityUpdateThread:kill() nameQualityUpdateThread = nil end
								nameQualityUpdateThread = libThread.threadFunc(function()	
									wait(REROLL_ANIMATION_TIME * 1.1)							
									updateItemNameFromQualityInfo(object:GetWidget(prefix..'ItemName'), qualityInfo.itemName, isRare, isLegendary, qualityInfo.rareBonus, qualityInfo.legendaryBonus)
									nameQualityUpdateThread = nil
								end)
							else
								updateItemNameFromQualityInfo(object:GetWidget(prefix..'ItemName'), qualityInfo.itemName, isRare, isLegendary, qualityInfo.rareBonus, qualityInfo.legendaryBonus)
							end
							craftedItemQualityInfoPopulateBonus(object, prefix, 'Legendary', {
								exists		= true,
								name		= qualityInfo.legendaryBonus,
								description	= qualityInfo.legendaryDescription,
								icon		= qualityInfo.legendaryIcon
							}, legendaryBonusChanged)							
						end
					end
				elseif currentQuality >= 0.9 and newValue >= 1.1 then
					if not isRare then
						PlaySound('/ui/sounds/crafting/sfx_rare.wav')
						isRare = true
						if qualityInfo then
							if (commonBonusChanged) or (rareBonusChanged) or (legendaryBonusChanged) then
								if (nameQualityUpdateThread) then nameQualityUpdateThread:kill() nameQualityUpdateThread = nil end
								nameQualityUpdateThread = libThread.threadFunc(function()	
									wait(REROLL_ANIMATION_TIME * 1.1)								
									updateItemNameFromQualityInfo(object:GetWidget(prefix..'ItemName'), qualityInfo.itemName, isRare, isLegendary, qualityInfo.rareBonus, qualityInfo.legendaryBonus)
									nameQualityUpdateThread = nil
								end)
							else
								updateItemNameFromQualityInfo(object:GetWidget(prefix..'ItemName'), qualityInfo.itemName, isRare, isLegendary, qualityInfo.rareBonus, qualityInfo.legendaryBonus)
							end
							craftedItemQualityInfoPopulateBonus(object, prefix, 'Rare', {
								exists		= true,
								name		= qualityInfo.rareBonus,
								description	= qualityInfo.rareDescription,
								icon		= qualityInfo.rareIcon
							}, rareBonusChanged)
						end
					end
				end

				craftedItemQualityBarSetValue(qualityBars.common, math.min(1, math.max(0, currentQuality)))
				craftedItemQualityBarSetValue(qualityBars.rare, math.min(1, math.max(0, currentQuality - 1)))
				craftedItemQualityBarSetValue(qualityBars.legendary, math.min(1, math.max(0, currentQuality - 2)))
			
			end, function()
				if prefix == 'craftItemQuality' then
					-- CameraShake(1, 500, object:GetWidget('craftingItemCraftedBody'))
				end
				
				StopSound(14)
				
				if qualityDiff >= 0.7 then
					PlaySound('/ui/sounds/crafting/sfx_barfill_4.wav')
				elseif qualityDiff >= 0.5 then
					PlaySound('/ui/sounds/crafting/sfx_barfill_3.wav')
				elseif qualityDiff >= 0.3 then
					PlaySound('/ui/sounds/crafting/sfx_barfill_2.wav')
				else
					PlaySound('/ui/sounds/crafting/sfx_barfill_1.wav')
				end

				if GetCvarBool('_thepriceiswrong') then
					libAnims.wobbleStop2(object:GetWidget(prefix..'MarkerBody'))
					object:GetWidget(prefix..'Marker'):FadeOut(500)
				end
				
				local endQuality = libNumber.round(newValue, 1)
				craftedItemQualityBarSetValue(qualityBars.common, math.min(1, math.max(0, endQuality)))
				craftedItemQualityBarSetValue(qualityBars.rare, math.min(1, math.max(0, endQuality - 1)))
				craftedItemQualityBarSetValue(qualityBars.legendary, math.min(1, math.max(0, endQuality - 2)))
			end)
		else
			object:GetWidget(prefix..'Marker'):SetVisible(false)
			craftedItemQualityBarSetValue(qualityBars.common, newValues.common)
			craftedItemQualityBarSetValue(qualityBars.rare, newValues.rare)
			craftedItemQualityBarSetValue(qualityBars.legendary, newValues.legendary)
			
			CraftingAnimationStatus.enchantAnimating = false
			CraftingAnimationStatus:Trigger(false)
			
			local isRare				= (newValue >= 1.1)
			local isLegendary			= (newValue >= 2.1)

			if qualityInfo then
				if (commonBonusChanged) or (rareBonusChanged) or (legendaryBonusChanged) then
					if (nameQualityUpdateThread) then nameQualityUpdateThread:kill() nameQualityUpdateThread = nil end
					nameQualityUpdateThread = libThread.threadFunc(function()	
						wait(REROLL_ANIMATION_TIME * 1.1)
						updateItemNameFromQualityInfo(object:GetWidget(prefix..'ItemName'), qualityInfo.itemName, isRare, isLegendary, qualityInfo.rareBonus, qualityInfo.legendaryBonus)
						nameQualityUpdateThread = nil
					end)
				else
					updateItemNameFromQualityInfo(object:GetWidget(prefix..'ItemName'), qualityInfo.itemName, isRare, isLegendary, qualityInfo.rareBonus, qualityInfo.legendaryBonus)
				end				
				
				craftedItemQualityInfoPopulateBonus(object, prefix, 'Analog', {
					exists		= true,
					name		= '',
					description = qualityInfo.analogDescription,
					icon		= ''
					
				}, commonBonusChanged)
					
				craftedItemQualityInfoPopulateBonus(object, prefix, 'Rare', {
					exists		= isRare,
					name		= qualityInfo.rareBonus,
					description	= qualityInfo.rareDescription,
					icon		= qualityInfo.rareIcon
				}, rareBonusChanged)

				craftedItemQualityInfoPopulateBonus(object, prefix, 'Legendary', {
					exists		= isLegendary,
					name		= qualityInfo.legendaryBonus,
					description	= qualityInfo.legendaryDescription,
					icon		= qualityInfo.legendaryIcon
				}, legendaryBonusChanged)
				
			end
		end
	end
	
	lastItemQualityValues[prefix] = {
		common		= newValues.common,
		rare		= newValues.rare,
		legendary	= newValues.legendary,
		commonBonus		= ((qualityInfo and qualityInfo.commonBonus) or 'None'),
		rareBonus		= ((qualityInfo and qualityInfo.rareBonus) or 'None'),
		legendaryBonus	= ((qualityInfo and qualityInfo.legendaryBonus) or 'None'),
		id				= ((qualityInfo and qualityInfo.id) or 'None'),
	}
end

local lastEnchantItemQualityIndex = -1

local function enchantItemQualityUpdate(widget, trigger, useAnims)

	if useAnims == nil then useAnims = true end
	
	local displayName = ''
	local entityName = trigger.name
	if entityName and string.len(entityName) > 0 then
		displayName = GetEntityDisplayName(entityName)
	end
	updateCraftedItemQuality(widget, 'enchantItemQuality', useAnims, { common = trigger.normalQuality, rare = trigger.rareQuality, legendary = trigger.legendaryQuality }, (not useAnims), {
		itemName				= displayName,
		isRare					= trigger.isRare,
		isLegendary				= trigger.isLegendary,
		analogDescription		= trigger.bonusDescription,
		rareBonus				= trigger.rareBonusName,
		rareDescription			= trigger.rareBonusDescription,
		rareIcon				= trigger.rareBonusIcon,
		legendaryBonus			= trigger.legendaryBonusName,
		legendaryDescription	= trigger.legendaryBonusDescription,
		legendaryIcon			= trigger.legendaryBonusIcon,
		id						= trigger.id,
		
	})
end

object:GetWidget('enchantItemQualityCommonBar'):RegisterWatchLua('craftingStage', function(widget, trigger)
	local enchantSelectedIndex = trigger.enchantSelectedIndex
	
	if lastEnchantItemQualityIndex >= 0 then
		widget:UnregisterWatchLuaByKey('enchantItemQualityWatch')
	end

	if enchantSelectedIndex >= 0 then
		lastEnchantItemQualityIndex = enchantSelectedIndex
		enchantItemQualityUpdate(widget, LuaTrigger.GetTrigger('CraftedItems'..enchantSelectedIndex), false)
		widget:RegisterWatchLua('CraftedItems'..enchantSelectedIndex, function(widget, trigger, useAnims)
			enchantItemQualityUpdate(widget, trigger, useAnims)
		end, false, 'enchantItemQualityWatch', 'normalQuality', 'rareBonusName', 'rareQuality', 'legendaryQuality', 'isRare', 'isLegendary', 'name')
	else
		updateCraftedItemQuality(widget, 'enchantItemQuality', false, { common = 0, rare = 0, legendary = 0 }, true)
		
		craftedItemQualityInfoPopulateBonus(widget, 'enchantItemQuality', 'Analog', {
			exists		= true,
			name		= '',
			description = '',
			icon		= '/ui/main/enchanting/textures/common_bonus.tga'
		})
			
		craftedItemQualityInfoPopulateBonus(widget, 'enchantItemQuality', 'Rare', {
			exists		= false,
			name		= '',
			description	= '',
			icon		= ''
		})

		craftedItemQualityInfoPopulateBonus(widget, 'enchantItemQuality', 'Legendary', {
			exists		= false,
			name		= '',
			description	= '',
			icon		= ''
		})
	end
	
	
end, false, nil, 'enchantSelectedIndex')

object:GetWidget('craftItemQualityCommonBar'):RegisterWatchLua('CraftingUnclaimedDesign', function(widget, trigger)
	local displayName = ''
	local entityName = trigger.name
	if entityName and string.len(entityName) > 0 then
		displayName = GetEntityDisplayName(entityName)
	end

	updateCraftedItemQuality(widget, 'craftItemQuality', true, { common = trigger.normalQuality, rare = trigger.rareQuality, legendary = trigger.legendaryQuality }, nil, {
		itemName				= displayName,
		isRare					= trigger.isRare,
		isLegendary				= trigger.isLegendary,
		analogDescription		= trigger.bonusDescription,
		rareBonus				= trigger.rareBonusName,
		rareDescription			= trigger.rareBonusDescription,
		rareIcon				= trigger.rareBonusIcon,
		legendaryBonus			= trigger.legendaryBonusName,
		legendaryDescription	= trigger.legendaryBonusDescription,
		legendaryIcon			= trigger.legendaryBonusIcon,
		id						= trigger.id,
		isNewCraft				= true,
	})
end, false, nil, 'normalQuality', 'rareQuality', 'legendaryQuality', 'isRare', 'isLegendary', 'name')

--[[
	Crafting Stages:
	0	Not open
	1	Loading
	2	Loaded, show merchant, existing crafted items (inventory), etc.
	3	Crafting Create Item Panel
	4	-- unused
	5	Show Inventory
	6	Enchanting Station
	7	Craft new item (select recipe)

	Popups:
	0	No popup
	1	Temper prompt
	2	Enchant Prompt
	3	Salvage Prompt
	4	Select Component
	5	Item completed fanfare
	6	Masteries Popup (removed)
--]]

local keeperVOThrottle				= 4000	-- If performing a different action
local keeperVOThrottleSameType		= 7500	-- If performing the same action
local keeperVOThrottleSameChoice	= 10000	-- If it picks the exact same sound

local keeperLastVOType		= ''
local keeperLastVOChoice	= 0
local keeperLastVOTime		= 0

local keeperSounds = {
	enter							= {'vo_shop_enter_1',		'vo_shop_enter_2',		'vo_shop_enter_3'},
	craft							= {'vo_item_crafted',		'vo_item_impressive',	'vo_item_sublime'},
	temper							= {'vo_item_temper_1',		'vo_item_temper_2'},
	choose							= {'vo_select_component'},
	idle							= {'vo_idle_1',				'vo_idle_2',			'vo_idle_3'},
	enchant							= {'vo_item_enchant'},
	enchant_complete_nowlegendary	= {'vo_item_legendary' },
	enchant_complete_nowrare		= {'vo_item_sublime',		'vo_item_impressive' },
	enchant_complete				= {'vo_spendpoints_1',		'vo_spendpoints_2'},
	craft_complete_legendary		= {'vo_item_legendary' },
	craft_complete_rare				= {'vo_item_sublime',		'vo_item_impressive' },
	craft_complete					= {'vo_item_crafted'},
	salvage							= {'vo_item_salvage_1',		'vo_item_salvage_2',	'vo_item_salvage_3'},
	exit							= {'vo_shop_exit_1',		'vo_shop_exit_2',		'vo_shop_exit_3'},
}

function keeperPlayVO(keeperVOType, forceVO)

	if true then return end

	local triggerNPE = LuaTrigger.GetTrigger('newPlayerExperience')
	if triggerNPE.craftingIntroProgress == 0 then
		return
	end

	local keeperVOChoice
	local keeperVOTime		= GetTime()
	local playVOSound		= false
	forceVO = forceVO or false

	if keeperVOType then
		keeperVOChoice	= math.random(1, #keeperSounds[keeperVOType])


		if forceVO then
			playVOSound = true
		elseif keeperVOType == keeperLastVOType then
			if keeperVOChoice == keeperLastVOChoice then
				playVOSound = (keeperLastVOTime + keeperVOThrottleSameChoice <= keeperVOTime)
			else
				playVOSound = (keeperLastVOTime + keeperVOThrottleSameType <= keeperVOTime)
			end
		else
			playVOSound = (keeperLastVOTime + keeperVOThrottle <= keeperVOTime)
		end

		if playVOSound then
			keeperLastVOType	= keeperVOType
			keeperLastVOChoice	= keeperVOChoice
			keeperLastVOTime	= keeperVOTime

			PlaySound('/shared/sounds/keepers/draknia/' .. keeperSounds[keeperVOType][keeperVOChoice] .. '.wav')
		end
	end
end

local function buttonDisableViaCraftActions(widget, groupTrigger)
	widget:SetEnabled(
		(not CraftingAnimationStatus.requestPending) and
		(not CraftingAnimationStatus.enchantAnimating) and
		(not CraftingAnimationStatus.rerollAnimating) and
		(not CraftingAnimationStatus.craftAnimating)
	)
end

LuaTrigger.CreateCustomTrigger('craftingClickedComponent',
	{
		{ name	= 'entity',	type	= 'string'}
	}
)

LuaTrigger.CreateCustomTrigger('craftingClickedImbuement',
	{
		{ name	= 'index',	type	= 'number'},
		{ name	= 'active',	type	= 'boolean'},
	}
)

local itemTypeList = { 'power', 'health', 'mana', 'healthRegen', 'manaRegen', 'baseAttackspeed' }

local function craftingGetComponentInfoType(componentInfo)
	for k,v in ipairs(itemTypeList) do
		if componentInfo[v] > 0 then
			return v
		end
	end
end

for i=1,3,1 do
	LuaTrigger.CreateCustomTrigger('craftingItemCreatedBonusUpdateState'..i,
		{
			{ name	= 'state',	type	= 'number'}
		}
	)
	LuaTrigger.CreateCustomTrigger('craftingItemCreatedBonusInfo'..i,
		{
			{ name	= 'curState',	type	= 'number'},
			{ name	= 'prevState',	type	= 'number'},
			{ name	= 'icon',		type	= 'string'},
			{ name	= 'valid',		type	= 'boolean'}
		}
	)
end

LuaTrigger.CreateCustomTrigger('craftingCraftedItemFilter',
	{
		{ name	= 'filter',		type	= 'string'}
	}
)

LuaTrigger.CreateCustomTrigger('craftingItemCreatedBonusInfo',
	{
		{ name	= 'progress',		type	= 'number'},
		{ name	= 'progressPrev',	type	= 'number'}
	}
)

LuaTrigger.CreateCustomTrigger('craftingCurrentCraftedItemFilter',	-- To quickly and simply toggle between crafting prompts
	{
		{ name	= 'filter',		type	= 'string'}
	}
)

for i=1,3,1 do
	LuaTrigger.CreateCustomTrigger('craftingNewItemComponent'..i..'Info',
		{
			{ name	= 'exists',			type	= 'boolean'},
			{ name	= 'entity',			type	= 'string'},
			{ name	= 'name',			type	= 'string'},
			{ name	= 'description',	type	= 'string'},
			{ name	= 'cost',			type	= 'number'},
			{ name	= 'craftingValue',	type	= 'number'},
			{ name	= 'icon',			type	= 'string'},
			{ name	= 'health',			type	= 'number'},
			{ name	= 'mana',			type	= 'number'},
			{ name	= 'power',			type	= 'number'},
			{ name	= 'healthRegen',	type	= 'number'},
			{ name	= 'manaRegen',		type	= 'number'},
			{ name	= 'baseAttackSpeed',	type	= 'number'}
		}
	)
end

selectableComponentTypeList	= { 'power_comp', 'health_comp', 'mana_comp', 'health_regen_comp', 'mana_regen_comp', 'attack_speed_comp' }

for k,v in ipairs(selectableComponentTypeList) do
	for i=1,3,1 do
		LuaTrigger.CreateCustomTrigger('craftingSelectableComponent'..v..'Info'..i,
			{
				{ name	= 'icon',			type	= 'string'},
				{ name	= 'cost',			type	= 'number'},
				{ name	= 'value',			type	= 'number'},
				{ name	= 'craftingValue',	type	= 'number'},
				{ name	= 'entity',			type	= 'string'},
				{ name	= 'componentType',	type	= 'string'}
			}
		)
	end
end

itemStatTypeFormat	= {
	mana					= function(input, showName)
		local value = libNumber.commaFormat(input, 0)
		if showName then
			return Translate('item_stat_count_format_maxMana', 'amount', value)
		else
			return value
		end
	end,
	power					= function(input, showName)
		local value = FtoA2(input, 0, 0)
		if showName then
			return Translate('item_stat_count_format_power', 'amount', value)
		else
			return value
		end
	end,
	health				= function(input, showName)
		local value = libNumber.commaFormat(input, 0)
		if showName then
			return Translate('item_stat_count_format_maxHealth', 'amount', value)
		else
			return value
		end
	end,
	healthRegen	= function(input, showName)
		local value = libNumber.round(input, 1)
		if showName then
			return Translate('item_stat_count_format_baseHealthRegen', 'amount', value)
		else
			return value
		end
	end,
	manaRegen		= function(input, showName)
		local value = libNumber.round(input, 1)
		if showName then
			return Translate('item_stat_count_format_baseManaRegen', 'amount', value)
		else
			return value
		end
	end,
	baseAttackSpeed				= function(input, showName)
		local value = FtoA2(100 * input, 0, 1)
		if showName then
			return Translate('item_stat_count_format_baseAttackSpeed', 'amount', value)
		else
			return value
		end
	end,
	armor	= function(input, showName)
		local value = libNumber.round(input, 1)
		if showName then
			return Translate('item_stat_count_format_armor', 'amount', value)
		else
			return value
		end
	end,
	magicArmor	= function(input, showName)
		local value = libNumber.round(input, 1)
		if showName then
			return Translate('item_stat_count_format_magicArmor', 'amount', value)
		else
			return value
		end
	end,
	mitigation	= function(input, showName)
		local value = libNumber.round(input, 1)
		if showName then
			return Translate('item_stat_count_format_mitigation', 'amount', value)
		else
			return value
		end
	end,
	resistance	= function(input, showName)
		local value = libNumber.round(input, 1)
		if showName then
			return Translate('item_stat_count_format_resistance', 'amount', value)
		else
			return value
		end
	end,
}

itemStatTypeFormat.maxHealth		= itemStatTypeFormat.health
itemStatTypeFormat.maxMana			= itemStatTypeFormat.mana
itemStatTypeFormat.baseHealthRegen	= itemStatTypeFormat.healthRegen
itemStatTypeFormat.baseManaRegen	= itemStatTypeFormat.manaRegen

local function craftingEvaluateNPEAddComponentProgress()
	local triggerNPE = LuaTrigger.GetTrigger('newPlayerExperience')
	
	local craftingIntroProgress		= triggerNPE.craftingIntroProgress
	local craftingIntroStep			= triggerNPE.craftingIntroStep
	if triggerNPE.tutorialComplete and craftingIntroProgress == 0 then
		if craftingIntroStep == 4 or craftingIntroStep == 7 then
			newPlayerExperienceCraftingStep(5)
		end
	end
end

local function craftingRegisterDraggableComponent(object, itemType, index)
	local button			= object:GetWidget('craftingDraggableComponent'..itemType..index)
	local selectButton		= object:GetWidget('craftingDraggableComponent'..itemType..index..'SelectButton')		
	local Frame				= object:GetWidget('craftingDraggableComponent'..itemType..index..'Frame')	
	local hoverGlow			= object:GetWidget('craftingDraggableComponent'..itemType..index..'hoverGlow')
	local hoverFrame		= object:GetWidget('craftingDraggableComponent'..itemType..index..'hoverFrame')
	local icon				= object:GetWidget('craftingDraggableComponent'..itemType..index..'Icon')
	local cost				= object:GetWidget('craftingDraggableComponent'..itemType..index..'Cost')
	local clickDropTarget	= object:GetWidget('craftingDraggableComponent'..itemType..index..'ClickDropTarget')
	local infoTrigger		= LuaTrigger.GetTrigger('craftingSelectableComponent'..itemType..'Info'..index)
	infoTrigger.icon		= icon:GetTexture()
	infoTrigger.cost		= 0
	infoTrigger.value		= 0
	infoTrigger.entity		= ''

	cost:RegisterWatchLua('craftingSelectableComponent'..itemType..'Info'..index, function(widget, trigger)
		widget:SetText(math.floor(trigger.craftingValue / style_crafting_costPerComponentPip))
	end, false, nil, 'craftingValue')

	icon:RegisterWatchLua('craftingSelectableComponent'..itemType..'Info'..index, function(widget, trigger) widget:SetTexture(trigger.icon) end, false, nil, 'icon')

	icon:RegisterWatchLua('CraftingGroupStatus', function(widget, groupTrigger)
		local entityName = groupTrigger['CraftingUnfinishedDesign'].name
		if (
			entityName and string.len(entityName) > 0 and
			(not CraftingAnimationStatus.requestPending) and
			(not CraftingAnimationStatus.enchantAnimating) and
			(not CraftingAnimationStatus.rerollAnimating) and
			(not CraftingAnimationStatus.craftAnimating)
		) then
			widget:SetRenderMode('normal')
			Frame:SetRenderMode('normal')
		else
			widget:SetRenderMode('grayscale')
			Frame:SetRenderMode('grayscale')
		end
	end)
	
	button:RegisterWatchLua('CraftingGroupStatus', function(widget, groupTrigger)
		local entityName = groupTrigger['CraftingUnfinishedDesign'].name
		widget:SetEnabled(
			entityName and string.len(entityName) > 0 and
			(not CraftingAnimationStatus.requestPending) and
			(not CraftingAnimationStatus.enchantAnimating) and
			(not CraftingAnimationStatus.rerollAnimating) and
			(not CraftingAnimationStatus.craftAnimating)
		)
	end)
	
	button:SetCallback('onclick', function(widget)
	
		-- sound_craftingClickPickupComponentForRecipe
		PlaySound('/ui/sounds/crafting/sfx_component_drag.wav')
	
		local componentTrigger
		local openSlot = 0
		for i=1,3,1 do
			componentTrigger	= LuaTrigger.GetTrigger('craftingNewItemComponent'..i..'Info')
			if componentTrigger.exists and componentTrigger.entity and (not Empty(componentTrigger.entity)) then
			
			else
				openSlot = i
				break
			end
		end	
	
		if (openSlot > 0) then
			local clickedItemTrigger = LuaTrigger.GetTrigger('craftingClickedComponent')
			craftingAddComponentByName(infoTrigger.entity, openSlot)
			clickedItemTrigger.entity = ''
			clickedItemTrigger:Trigger(false)
		else
			local clickedItemTrigger = LuaTrigger.GetTrigger('craftingClickedComponent')
			-- if clickedItemTrigger.entity ~= infoTrigger.entity then
				-- clickedItemTrigger.entity = infoTrigger.entity
			-- else
				clickedItemTrigger.entity = ''
			-- end
			clickedItemTrigger:Trigger(false)
		end

		craftingEvaluateNPEAddComponentProgress()
	end)
	
	button:SetCallback('onrightclick', function(widget) -- remove first matching component in reverse order
		PlaySound('/ui/sounds/crafting/sfx_component_drag.wav')
		local componentTrigger
		for i=3,1,-1 do
			componentTrigger	= LuaTrigger.GetTrigger('craftingNewItemComponent'..i..'Info')
			if componentTrigger.exists and componentTrigger.entity and (not Empty(componentTrigger.entity)) then
				if (componentTrigger.entity == infoTrigger.entity) then
					Crafting.RemoveDesignComponent(i - 1)
					break
				end
			end
		end	
	end)	
	
	button:SetCallback('onmouseoverdisabled', function(widget)
		craftedItemTipPopulate(infoTrigger.entity, true, nil, true)
		shopItemTipShow(index, 'craftedItemInfoShop')
	end)
	
	button:SetCallback('onmouseoutdisabled', function(widget)
		shopItemTipHide()
	end)
	
	local function buttonOver(widget)
		craftedItemTipPopulate(infoTrigger.entity, true, nil, true)
		shopItemTipShow(index, 'craftedItemInfoShop')
		hoverFrame:FadeIn(150)
		hoverGlow:FadeIn(150)
	end
	
	local function buttonOut(widget)
		shopItemTipHide()
		hoverFrame:FadeOut(150)
		hoverGlow:FadeOut(150)
	end
	
	button:SetCallback('onmouseover', buttonOver)
	button:SetCallback('onmouseout', buttonOut)
	
	

	clickDropTarget:RegisterWatchLua('globalDragInfo', function(widget, trigger)
		widget:SetVisible(trigger.active and trigger.type == 1)
	end, false, nil, 'active', 'type')
	
	selectButton:SetCallback('onmouseover', buttonOver)
	selectButton:SetCallback('onmouseout', buttonOut)

	clickDropTarget:SetCallback('onmouseover', function(widget)
		globalDraggerReadTarget(widget, function()

			if craftingLastDraggedComponent == infoTrigger.entity then
				local clickedItemTrigger = LuaTrigger.GetTrigger('craftingClickedComponent')

				-- if clickedItemTrigger.entity ~= infoTrigger.entity then
					-- clickedItemTrigger.entity = infoTrigger.entity
				-- else
					clickedItemTrigger.entity = ''
				-- end
				clickedItemTrigger:Trigger(false)
			end
		end)
	end)

	button:SetCallback('onstartdrag', function(widget)
		-- sound_craftingPickupComponentForRecipe
		PlaySound('/ui/sounds/crafting/sfx_component_drag.wav')
		local infoTrigger			= LuaTrigger.GetTrigger('craftingSelectableComponent'..itemType..'Info'..index)
		local clickedItemTrigger = LuaTrigger.GetTrigger('craftingClickedComponent')
		clickedItemTrigger.entity = ''
		clickedItemTrigger:Trigger(false)

		craftingLastDraggedComponent = infoTrigger.entity
		
		craftingEvaluateNPEAddComponentProgress()
		
		local itemInfoDrag = LuaTrigger.GetTrigger('itemInfoDrag')
		itemInfoDrag.triggerName = 'craftingSelectableComponent'..itemType..'Info'
		itemInfoDrag.triggerIndex = index
		itemInfoDrag.type = 1
		itemInfoDrag.entityName = infoTrigger.entity
		itemInfoDrag:Trigger(false)		
	end)

	selectButton:SetCallback('onclick', function(widget)
		local triggerStage = LuaTrigger.GetTrigger('craftingStage')
		craftingAddComponentByName(infoTrigger.entity, triggerStage.craftClickedComponentSlotIndex)

		triggerStage.craftClickedComponentSlotIndex = -1
		triggerStage:Trigger(false)
		
		-- sound_craftingClickPlaceComponentInSlot
		PlaySound('/ui/sounds/crafting/sfx_component_drop.wav')		
	end)

	selectButton:RegisterWatchLua('craftingStage', function(widget, trigger)
		widget:SetVisible(trigger.craftClickedComponentSlotIndex >= 1)
	end, false, nil, 'craftClickedComponentSlotIndex')

	globalDraggerRegisterSource(button, 1)
end

local function craftingRegisterDraggableImbuement(object, index)
	local button			= object:GetWidget('craftingImbuement'..index)
	local frame				= object:GetWidget('craftingImbuement'..index..'Frame')	
	local hoverGlow			= object:GetWidget('craftingImbuement'..index..'hoverGlow')
	local hoverFrame		= object:GetWidget('craftingImbuement'..index..'hoverFrame')
	local icon				= object:GetWidget('craftingImbuement'..index..'Icon')
	local cost				= object:GetWidget('craftingImbuement'..index..'Cost')
	local name				= object:GetWidget('craftingImbuement'..index..'Name')
	local desc				= object:GetWidget('craftingImbuement'..index..'Desc')

	if (not button) then return end
	
	local CraftingUnfinishedDesign = LuaTrigger.GetTrigger('CraftingUnfinishedDesign')

	button:RegisterWatchLua('CraftingUnfinishedDesign', function(widget, trigger)
		if (not CraftingUnfinishedDesign['empoweredEffect'..index..'EntityName']) or Empty((CraftingUnfinishedDesign['empoweredEffect'..index..'EntityName'])) or (not ValidateEntity(CraftingUnfinishedDesign['empoweredEffect'..index..'EntityName'])) then
			button:SetVisible(0)
		else
			button:SetVisible(1)
		end
	end, false, nil)	
	
	cost:RegisterWatchLua('CraftingUnfinishedDesign', function(widget, trigger)
		widget:SetText('+' .. (trigger['empoweredEffect' .. index .. 'Cost']) or '?Cost?')
	end, false, nil)

	name:RegisterWatchLua('CraftingUnfinishedDesign', function(widget, trigger)
		widget:SetText((trigger['empoweredEffect' .. index .. 'Name']) or '?Name?')
	end, false, nil)	
	
	desc:RegisterWatchLua('CraftingUnfinishedDesign', function(widget, trigger)
		widget:SetText((trigger['empoweredEffect' .. index .. 'Description']) or '?Description?')
	end, false, nil)

	icon:RegisterWatchLua('CraftingUnfinishedDesign', function(widget, trigger)
		if (not CraftingUnfinishedDesign['currentEmpoweredEffectEntityName']) or Empty((CraftingUnfinishedDesign['currentEmpoweredEffectEntityName'])) or (not ValidateEntity(CraftingUnfinishedDesign['currentEmpoweredEffectEntityName'])) or (not CraftingUnfinishedDesign['empoweredEffect'..index..'EntityName']) or Empty((CraftingUnfinishedDesign['empoweredEffect'..index..'EntityName'])) or (not ValidateEntity(CraftingUnfinishedDesign['empoweredEffect'..index..'EntityName'])) or (CraftingUnfinishedDesign['empoweredEffect'..index..'EntityName'] ~= CraftingUnfinishedDesign['currentEmpoweredEffectEntityName']) then
			widget:SetTexture('/ui/main/crafting/textures/imbue_icon.tga')
		else	
			widget:SetTexture('/ui/main/crafting/textures/imbue_icon_selected.tga')
		end
	end, false, nil)	

	frame:RegisterWatchLua('CraftingUnfinishedDesign', function(widget, trigger)
		if (not CraftingUnfinishedDesign['currentEmpoweredEffectEntityName']) or Empty((CraftingUnfinishedDesign['currentEmpoweredEffectEntityName'])) or (not ValidateEntity(CraftingUnfinishedDesign['currentEmpoweredEffectEntityName'])) or (not CraftingUnfinishedDesign['empoweredEffect'..index..'EntityName']) or Empty((CraftingUnfinishedDesign['empoweredEffect'..index..'EntityName'])) or (not ValidateEntity(CraftingUnfinishedDesign['empoweredEffect'..index..'EntityName'])) or (CraftingUnfinishedDesign['empoweredEffect'..index..'EntityName'] ~= CraftingUnfinishedDesign['currentEmpoweredEffectEntityName']) then
			widget:SetTexture('/ui/main/crafting/textures/imbue_bg_up.tga')
		else	
			widget:SetTexture('/ui/main/crafting/textures/imbue_bg_selected.tga')
			hoverFrame:FadeOut(150)
		end
	end, false, nil)		
	
	icon:RegisterWatchLua('CraftingGroupStatus', function(widget, groupTrigger)
		local entityName = groupTrigger['CraftingUnfinishedDesign'].name
		if (
			entityName and string.len(entityName) > 0 and
			(not CraftingAnimationStatus.requestPending) and
			(not CraftingAnimationStatus.enchantAnimating) and
			(not CraftingAnimationStatus.rerollAnimating) and
			(not CraftingAnimationStatus.craftAnimating)
		) then
			widget:SetRenderMode('normal')
			frame:SetRenderMode('normal')
		else
			widget:SetRenderMode('grayscale')
			frame:SetRenderMode('grayscale')
		end
	end)
	
	button:RegisterWatchLua('CraftingGroupStatus', function(widget, groupTrigger)
		local entityName = groupTrigger['CraftingUnfinishedDesign'].name
		widget:SetEnabled(
			entityName and string.len(entityName) > 0 and
			(not CraftingAnimationStatus.requestPending) and
			(not CraftingAnimationStatus.enchantAnimating) and
			(not CraftingAnimationStatus.rerollAnimating) and
			(not CraftingAnimationStatus.craftAnimating)
		)
	end)
	
	button:SetCallback('onclick', function(widget)
		PlaySound('/ui/sounds/crafting/sfx_component_drag.wav')
		if (not CraftingUnfinishedDesign['empoweredEffect'..index..'EntityName']) or Empty((CraftingUnfinishedDesign['empoweredEffect'..index..'EntityName'])) or (not ValidateEntity(CraftingUnfinishedDesign['empoweredEffect'..index..'EntityName'])) then
			
		elseif (CraftingUnfinishedDesign['empoweredEffect'..index..'EntityName'] == CraftingUnfinishedDesign['currentEmpoweredEffectEntityName']) then
			Crafting.SetDesignEmpoweredEffect('')
		else
			Crafting.SetDesignEmpoweredEffect(CraftingUnfinishedDesign['empoweredEffect'..index..'EntityName'])
		end		
	end)
	
	button:SetCallback('onrightclick', function(widget)
		PlaySound('/ui/sounds/crafting/sfx_component_drag.wav')
		Crafting.SetDesignEmpoweredEffect('')	
	end)	
	
	local function buttonOver(widget)	
		hoverGlow:FadeIn(150)
		if (not CraftingUnfinishedDesign['currentEmpoweredEffectEntityName']) or Empty((CraftingUnfinishedDesign['currentEmpoweredEffectEntityName'])) or (not ValidateEntity(CraftingUnfinishedDesign['currentEmpoweredEffectEntityName'])) or (not CraftingUnfinishedDesign['empoweredEffect'..index..'EntityName']) or Empty((CraftingUnfinishedDesign['empoweredEffect'..index..'EntityName'])) or (not ValidateEntity(CraftingUnfinishedDesign['empoweredEffect'..index..'EntityName'])) or (CraftingUnfinishedDesign['empoweredEffect'..index..'EntityName'] ~= CraftingUnfinishedDesign['currentEmpoweredEffectEntityName']) then
			hoverFrame:FadeIn(150)
		else	

		end		
	end
	
	local function buttonOut(widget)
		hoverFrame:FadeOut(150)
		hoverGlow:FadeOut(150)
	end
	
	button:SetCallback('onmouseover', buttonOver)
	button:SetCallback('onmouseout', buttonOut)

	button:SetCallback('onstartdrag', function(widget)
		-- sound_craftingPickupComponentForRecipe
		PlaySound('/ui/sounds/crafting/sfx_component_drag.wav')
		local craftingClickedImbuement = LuaTrigger.GetTrigger('craftingClickedImbuement')
		craftingClickedImbuement.index = tonumber(index)
		craftingClickedImbuement.active = true
		craftingClickedImbuement:Trigger(false)
	end)
	
	button:SetCallback('onenddrag', function(widget)
		local craftingClickedImbuement = LuaTrigger.GetTrigger('craftingClickedImbuement')
		craftingClickedImbuement.active = false
		craftingClickedImbuement:Trigger(false)	
	end)
	
	globalDraggerRegisterSource(button, 9)
end

local function craftingRegisterCraftedItemComponent(object, itemIndex, index, infoTrigger)
	local container		= object:GetWidget('craftedItemEntry'..itemIndex..'Component'..index)
	local icon			= object:GetWidget('craftedItemEntry'..itemIndex..'Component'..index..'Icon')

	container:RegisterWatchLua('CraftedItems'..itemIndex, function(widget, trigger)
		local entityName	= trigger['component'..index]
		widget:SetVisible(string.len(entityName) > 0)
	end, false, nil, 'component'..index)

	icon:RegisterWatchLua('CraftedItems'..itemIndex, function(widget, trigger)
		local entityName	= trigger['component'..index]
		if string.len(entityName) > 0 then
			widget:SetTexture(GetEntityIconPath(entityName))
		end
	end, false, nil, 'component'..index)

	container:SetCallback('onmouseover', function(widget)
		local componentInfo	= craftingGetComponentByName(infoTrigger['component'..index])
		simpleTipGrowYUpdate(true, componentInfo.icon, componentInfo.displayName, componentInfo.description)
	end)

	container:SetCallback('onmouseout', function(widget)
		simpleTipGrowYUpdate(false)
	end)
end

local function craftingRegisterCraftedItemEntryStat(object, itemID, index, property, iconPath)
	local container		= object:GetWidget('craftedItem'..itemID..'Stat'..index)
	local icon			= object:GetWidget('craftedItem'..itemID..'Stat'..index..'Icon')
	local value			= object:GetWidget('craftedItem'..itemID..'Stat'..index..'Value')

	container:RegisterWatchLua('CraftedItems'..itemID, function(widget, trigger) widget:SetVisible(trigger[property] > 0) end, false, nil, property)
	value:RegisterWatchLua('CraftedItems'..itemID, function(widget, trigger) widget:SetText(itemStatTypeFormat[property](trigger[property])) end, false, nil, property)
	icon:SetTexture(iconPath)
end

local function craftingRegisterCraftedItemEntry2(object, index, itemListbox, statFieldListLCS)
	local button				= object:GetWidget('craftedItem'..index)
	local buttonBody			= object:GetWidget('craftedItem'..index..'ButtonBody')
	local backer				= object:GetWidget('craftedItem'..index..'Backer')
	local icon					= object:GetWidget('craftedItem'..index..'Icon')
	local duration				= object:GetWidget('craftedItem'..index..'Duration')
	local name					= object:GetWidget('craftedItem'..index..'Name')
	local description			= object:GetWidget('craftedItem'..index..'Description')
	local normalQualityBar		= object:GetWidget('craftedItem'..index..'NormalQualityBar')
	local duration				= object:GetWidget('craftedItem'..index..'Duration')
	local durationBar			= object:GetWidget('craftedItem'..index..'DurationBar')

	local infoTrigger		= LuaTrigger.GetTrigger('CraftedItems'..index)

	libGeneral.createGroupTrigger('craftedItems'..index..'Vis', { 'CraftedItems'..index..'.available', 'CraftedItems'..index..'.categories', 'craftingStage.craftedItemsFilter' })
	
	button:RegisterWatchLua('craftedItems'..index..'Vis', function(widget, groupTrigger)
		local triggerStage	= groupTrigger['craftingStage']
		local triggerItem	= groupTrigger['CraftedItems'..index]
		local validForFilter = false
		
		
		local craftedItemsFilter = triggerStage.craftedItemsFilter
		
		if triggerStage.craftedItemsFilter == '' then
			validForFilter = true
		else
			local categoryList = Explode(',', triggerItem.categories)
			
			for k,v in ipairs(categoryList) do
				if v == craftedItemsFilter then
					validForFilter = true
					break
				end
			end
		end

		if triggerItem.available and validForFilter then
			itemListbox:ShowItemByValue(index)
		else
			itemListbox:HideItemByValue(index)
		end
	end)

	button:SetCallback('onstartdrag', function(widget)
		local stageTrigger = LuaTrigger.GetTrigger('craftingStage')
		stageTrigger.enchantLastDraggedIndex = index
		stageTrigger:Trigger(false)
		
		local itemInfo = LuaTrigger.GetTrigger('CraftedItems' .. index)
		local itemInfoDrag = LuaTrigger.GetTrigger('itemInfoDrag')
		itemInfoDrag.triggerName = 'CraftedItems'
		itemInfoDrag.triggerIndex = index
		itemInfoDrag.type = 1
		itemInfoDrag.entityName = itemInfo.name
		itemInfoDrag:Trigger(false)
	end)

	globalDraggerRegisterSource(button, 5)

	-- duration:RegisterWatchLua('CraftedItems'..index, function(widget, trigger) widget:SetVisible(not trigger.isTempered) end, false, nil, 'isTempered')
	-- durationBar:RegisterWatchLua('CraftedItems'..index, function(widget, trigger)
		-- if not trigger.isTempered then
			-- local secondsLeft = (
				-- (86400 * trigger.daysLeft) +	-- Seconds per day
				-- (3600 * trigger.hoursLeft) + 	-- Seconds per hour
				-- (60 * trigger.minutesLeft)		-- Derps per second
			-- )

			-- widget:ScaleWidth(ToPercent(math.min(secondsLeft / 1209600, 1)), 250)	-- rmm 14 Days hardcoded expiration time
		-- end
	-- end, false, nil, 'isTempered', 'daysLeft', 'hoursLeft', 'minutesLeft')

	--[[
	for k,v in ipairs(statFieldListLCS) do
		craftingRegisterCraftedItemEntryStat(object, index, k, v, style_crafting_componentTypeIcons[v])
	end
	--]]

	for i=1,3,1 do
		craftingRegisterCraftedItemComponent(object, index, i, infoTrigger)
	end

	libGeneral.createGroupTrigger('craftedItemEntryFilterVis'..index, { 'craftingCraftedItemFilter', 'CraftedItems'..index })

	--[[
	cost:RegisterWatchLua('CraftedItems'..index, function(widget, trigger)
		widget:SetText(libNumber.commaFormat(trigger.recipeCost + trigger.componentCost))
	end, false, nil, 'recipeCost', 'componentCost')
	--]]

	--[[

	normalQualityBar:RegisterWatchLua('CraftedItems'..index, function(widget, trigger)
		widget:SetWidth(ToPercent(trigger.normalQuality / 3))
	end, false, nil, 'normalQuality')

	rareIcon:RegisterWatchLua('CraftedItems'..index, function(widget, trigger)
		widget:SetVisible(trigger.isRare)
		widget:SetTexture(trigger.rareBonusIcon)
	end, false, nil, 'isRare', 'rareBonusIcon')

	legendaryIcon:RegisterWatchLua('CraftedItems'..index, function(widget, trigger)
		widget:SetVisible(trigger.isLegendary)
		widget:SetTexture(trigger.legendaryBonusIcon)
	end, false, nil, 'isLegendary', 'legendaryBonusIcon')

	rareQualityBar:RegisterWatchLua('CraftedItems'..index, function(widget, trigger)
		widget:SetWidth(ToPercent(trigger.rareQuality / 3))
	end, false, nil, 'rareQuality')

	legendaryQualityBar:RegisterWatchLua('CraftedItems'..index, function(widget, trigger)
		widget:SetWidth(ToPercent(trigger.legendaryQuality / 3))
	end, false, nil, 'legendaryQuality')
	--]]

	button:RegisterWatchLua('craftedItemEntryFilterVis'..index, function(widget, groupTrigger)
		local triggerFilter	= groupTrigger[1]
		local triggerItem	= groupTrigger[2]
		local categories	= triggerItem.categories
		local validFilter	= false

		if categories and string.len(categories) > 0 then
			local filters		= Explode(',', categories)
			for k,v in ipairs(filters) do
				if triggerFilter.filter == v then
					validFilter = true
				end
			end
		end
	end)

	icon:RegisterWatchLua('CraftedItems'..index, function(widget, trigger)
		local entityName	= trigger.name
		if string.len(entityName) > 0 then
			widget:SetTexture(GetEntityIconPath(entityName))
		end
	end, false, nil, 'name')

	name:RegisterWatchLua('CraftedItems'..index, function(widget, trigger)
		local entityName		= trigger.name

		if string.len(entityName) > 0 then
			local isRare		= trigger.isRare
			local isLegendary	= trigger.isLegendary
			widget:SetColor(libGeneral.craftedItemGetNameColor(isRare, isLegendary))
			
			local rareBonus			= trigger.rareBonusName
			local legendaryBonus	= trigger.legendaryBonusName

			local fullItemName = libGeneral.craftedItemFormatName(GetEntityDisplayName(entityName), isRare, rareBonus, isLegendary, legendaryBonus)
			FitFontToLabel(widget, fullItemName, {'maindyn_24', 'maindyn_22', 'maindyn_20', 'maindyn_18', 'maindyn_16', 'maindyn_14', 'maindyn_13'} )
			widget:SetText(fullItemName)
		end		
	end, false, nil, 'name', 'rareBonusName', 'legendaryBonusName', 'isRare', 'isLegendary')

	description:RegisterWatchLua('CraftedItems'..index, function(widget, trigger)
		widget:SetText(trigger.description)	-- rmm description2?
	end, false, nil, 'description')

	button:SetCallback('onclick', function(widget)
		-- sound_enchantingSelectCraftedItem
		PlaySound('/ui/sounds/crafting/sfx_item_choose.wav')
		craftingUpdateStage(6,0)
		craftingPromptEnchantUpdate(index)
		keeperPlayVO('enchant')

		local triggerNPE = LuaTrigger.GetTrigger('newPlayerExperience')
		if triggerNPE.tutorialComplete and triggerNPE.enchantingIntroProgress == 0 and triggerNPE.enchantingIntroStep <= 2 then
			local selectedID	= LuaTrigger.GetTrigger('craftingStage').enchantSelectedIndex
			local itemInfo		= LuaTrigger.GetTrigger('CraftedItems'..selectedID)
			if (not itemInfo.isLegendary) or itemInfo.legendaryQuality < 1 then
				newPlayerExperienceEnchantingStep(3)
			else
				newPlayerExperienceEnchantingStep(1)
			end
			
		end		
	end)

	button:SetCallback('onmouseover', function(widget)
		craftedItemTipPopulate(index, true)	-- Only populate trigger, in Inventory Format
		shopItemTipShow(index, 'craftedItemInfoShop')
		
		backer:SetColor('#6d5d4a')
		backer:SetBorderColor('#6d5d4a')
	end)

	button:SetCallback('onmouseout', function(widget)
		-- craftedItemTipHide()
		
		shopItemTipHide()
		
		backer:SetColor('#4e453b')
		backer:SetBorderColor('#4e453b')
	end)

	if infoTrigger and infoTrigger.Trigger then
		infoTrigger:Trigger()
		
	else
		print('missing info trigger for item '..index..'\n')
	end
end

local function craftingRegisterBoostEnchantPackage(object, index)
	local container		= object:GetWidget('craftingBoostEnchantPackage'..index)
	local button		= object:GetWidget('craftingBoostEnchantPackage'..index..'Button')
	local icon			= object:GetWidget('craftingBoostEnchantPackage'..index..'Icon')
	local iconShadow	= object:GetWidget('craftingBoostEnchantPackage'..index..'IconShadow')
	local attemptLabel	= object:GetWidget('craftingBoostEnchantPackage'..index..'AttemptLabel')
	local gemLabel		= object:GetWidget('craftingBoostEnchantPackage'..index..'GemLabel')

	--attemptLabel:RegisterWatchLua('CraftingEnchantBoost', function(widget, trigger) widget:SetText(libNumber.commaFormat(trigger['charges'..index])) end, false, nil, 'charges'..index)
	--gemLabel:RegisterWatchLua('CraftingEnchantBoost', function(widget, trigger) widget:SetText(trigger['gemCost'..index]) end, false, nil, 'gemCost'..index)

	button:SetCallback('onclick', function(widget)
		PlaySound('/ui/sounds/sfx_button_generic.wav')
		Crafting.BuyEnchantBoost(index-1)
	end)
end

local function craftingRegisterBoostCraftPackage(object, index)
	local container		= object:GetWidget('craftingBoostCraftPackage'..index..'Container')
	local button		= object:GetWidget('craftingBoostCraftPackage'..index)
	local iconSpace		= object:GetWidget('craftingBoostCraftPackage'..index..'IconSpace')
	local icon			= object:GetWidget('craftingBoostCraftPackage'..index..'Icon')
	local iconShadow	= object:GetWidget('craftingBoostCraftPackage'..index..'IconShadow')
	local attemptLabel	= object:GetWidget('craftingBoostCraftPackage'..index..'AttemptLabel')
	local gemLabel		= object:GetWidget('craftingBoostCraftPackage'..index..'GemLabel')

	--attemptLabel:RegisterWatchLua('CraftingCraftBoost', function(widget, trigger) widget:SetText(libNumber.commaFormat(trigger['charges'..index])) end, false, nil, 'charges'..index)
	--gemLabel:RegisterWatchLua('CraftingCraftBoost', function(widget, trigger) widget:SetText(trigger['gemCost'..index]) end, false, nil, 'gemCost'..index)

	button:SetCallback('onclick', function(widget)
		PlaySound('/ui/sounds/sfx_button_generic.wav')
		Crafting.BuyCraftBoost(index-1)
	end)
end

function craftingSelectRecipe(recipe)
	lastTotalCost = 0	
	lastJublieCost = 0
	lastPopupJublieValue = {0, 0, 0}
	
	local componentInfo	= nil
	local recipeInfo	= craftingGetRecipe(recipe)
	Crafting.ClearDesign()
	Crafting.SetDesignEmpoweredEffect('')
	lastStage = nil
	
	if recipeInfo then
		Crafting.SetDesignRecipe(recipe)
		craftingUpdateStage(3, 0)
	end
end

local function craftingRegisterNewItemComponent(object, index, newItemInfo)
	local container				= object:GetWidget('craftingNewItemComponent'..index)
	local body					= object:GetWidget('craftingNewItemComponent'..index..'Body')
	local removeButton			= object:GetWidget('craftingNewItemComponent'..index..'RemoveButton')
	local addButton				= object:GetWidget('craftingNewItemComponent'..index..'AddButtonContainer')
	local swapButton			= object:GetWidget('craftingNewItemComponent'..index..'SwapButtonContainer')
	local icon					= object:GetWidget('craftingNewItemComponent'..index..'Icon')
	local cost					= object:GetWidget('craftingNewItemComponent'..index..'Cost')
	local goldcost				= object:GetWidget('craftingNewItemComponent'..index..'_gold_cost')
	local dropTarget			= object:GetWidget('craftingNewItemComponent'..index..'DropTarget')
	local clickDropTarget		= object:GetWidget('craftingNewItemComponent'..index..'ClickDropTarget')
	local selectComponentButton	= object:GetWidget('craftingNewItemComponent'..index..'SelectComponentButton')

	local dataTrigger		= LuaTrigger.GetTrigger('craftingNewItemComponent'..index..'Info')

	local alertThread
	local function componentAlert(color, show, hide)
		color = color or '.1 .55 .7 1'
		if (alertThread) then
			alertThread:kill()
			alertThread = nil
		end
		alertThread = libThread.threadFunc(function()	
			if (show) then
				-- for i=1,3,1 do
					-- GetWidget('craftingNewItemComponent' .. i .. '_dummyglows'):FadeOut(125)
				-- end
				groupfcall('craftingDraggableComponent_alert_glows', function(_, groupWidget)
					groupWidget:SetColor(color)
					groupWidget:SetBorderColor(color)
					groupWidget:FadeIn(500)
				end)				
				wait(750)
			end
			if (hide) then
				-- for i=1,3,1 do
					-- GetWidget('craftingNewItemComponent' .. i .. '_dummyglows'):FadeIn(500)
				-- end
				groupfcall('craftingDraggableComponent_alert_glows', function(_, groupWidget)
					groupWidget:FadeOut(125)
				end)					
			end
			alertThread = nil
		end)
	end	
	
	selectComponentButton:SetCallback('onclick', function(widget)
		-- sound_craftingSelectSlotForComponent
		PlaySound('/ui/sounds/crafting/sfx_component_drag.wav')

		local triggerStage = LuaTrigger.GetTrigger('craftingStage')
		local canCraftInfo = LuaTrigger.GetTrigger('craftingCraftInfo') 
		
		local triggerNPE = LuaTrigger.GetTrigger('newPlayerExperience')
		if triggerNPE.tutorialComplete and triggerNPE.craftingIntroProgress == 0 and triggerNPE.craftingIntroStep == 3 then
			newPlayerExperienceCraftingStep(4)
		end

		local CraftingUnfinishedDesign = LuaTrigger.GetTrigger('CraftingUnfinishedDesign')
		
		local parentEntity = CraftingUnfinishedDesign.name
		-- parentEntity = string.gsub(parentEntity, '$Local_UnfinishedDesign|', '')
		local recipeInfo	

		if parentEntity and (not Empty(parentEntity)) and ValidateEntity(parentEntity) then
			recipeInfo = craftingGetRecipe(parentEntity)
		end

		if (canCraftInfo.entity) and (not Empty(canCraftInfo.entity)) then
			if triggerStage.craftClickedComponentSlotIndex == index then
				triggerStage.craftClickedComponentSlotIndex = -1
				triggerStage:Trigger(false)
			else
				triggerStage.craftClickedComponentSlotIndex = index
				triggerStage:Trigger(false)
			end
			
			if not dataTrigger.exists then
				if recipeInfo and (recipeInfo.components) and (recipeInfo.components[index]) and (not Empty(recipeInfo.components[index])) and ValidateEntity(recipeInfo.components[index]) then
					craftingAddComponentByName(recipeInfo.components[index], index)
					componentAlert(nil, false, true)
				end
			end
			
			craftingUpdateStage(3)
			
		else
			craftingUpdateStage(7)
		end
	end)
	
	selectComponentButton:RegisterWatchLua('CraftingGroupStatus', buttonDisableViaCraftActions)
	
	selectComponentButton:SetCallback('onrightclick', function(widget)
		PlaySound('/ui/sounds/sfx_button_generic.wav')
		
		local triggerNPE = LuaTrigger.GetTrigger('newPlayerExperience')
		if triggerNPE.tutorialComplete and triggerNPE.craftingIntroProgress == 0 and triggerNPE.craftingIntroStep == 3 then
			newPlayerExperienceCraftingStep(4)
		end
		
		Crafting.RemoveDesignComponent(index - 1)	-- 0-2	
		
		craftingUpdateStage(3)
	end)
	
	
	local function buttonOver(widget)
		if dataTrigger.exists then
			craftedItemTipPopulate(dataTrigger.entity, true, nil, true)
			shopItemTipShow(index, 'craftedItemInfoShop')	
			componentAlert(nil, false, true)			
		else
			componentAlert(nil, true, false)
		end	
	end
	
	local function buttonOut(widget)
		shopItemTipHide()
		componentAlert(nil, false, true)
	end
	
	selectComponentButton:SetCallback('onmouseover', buttonOver)
	selectComponentButton:SetCallback('onmouseout', buttonOut)
	
	clickDropTarget:SetCallback('onmouseover', buttonOver)
	clickDropTarget:SetCallback('onmouseout', buttonOut)	

	clickDropTarget:RegisterWatchLua('craftingClickedComponent', function(widget, trigger)
		widget:SetVisible(string.len(trigger.entity) > 0)
	end, false, nil, 'entity')

	clickDropTarget:SetCallback('onclick', function(widget)
		-- sound_craftingClickPlaceComponentInSlot
		PlaySound('/ui/sounds/crafting/sfx_component_drop.wav')
	
		local clickedItemTrigger = LuaTrigger.GetTrigger('craftingClickedComponent')
		craftingAddComponentByName(clickedItemTrigger.entity, index)
		
		clickedItemTrigger.entity = ''
		clickedItemTrigger:Trigger(false)
	end)

	dropTarget:RegisterWatchLua('globalDragInfo', function(widget, trigger)
		widget:SetVisible(trigger.active and trigger.type == 1)
	end, false, nil, 'active', 'type')

	dropTarget:SetCallback('onmouseover', function(widget)
		buttonOver(widget)
		globalDraggerReadTarget(widget, function()
			-- sound_craftingDropPlaceComponentInSlot
			PlaySound('/ui/sounds/crafting/sfx_component_drop.wav')
			craftingAddComponentByName(craftingLastDraggedComponent, index)
		end)
	end)
	
	dropTarget:SetCallback('onmouseout', buttonOut)

	body:RegisterWatchLua('CraftingUnfinishedDesign', function(widget, trigger)
		local entity = trigger.name
		widget:SetVisible(entity and string.len(entity) > 0)
	end, false, nil, 'name')

	cost:RegisterWatchLua('craftingNewItemComponent'..index..'Info', function(widget, trigger)
		if trigger.exists then
			widget:SetText(math.floor(trigger.craftingValue / style_crafting_costPerComponentPip))
		else
			widget:SetText('0')
		end

	end, false, nil, 'craftingValue', 'exists')
	
	goldcost:RegisterWatchLua('craftingNewItemComponent'..index..'Info', function(widget, trigger)
		if trigger.exists then
			widget:SetText(math.floor(trigger.cost))
		else
			widget:SetText('0')
		end

	end, false, nil, 'cost', 'exists')

	dataTrigger.exists		= false
	dataTrigger.entity		= ''
	dataTrigger.cost		= 0
	dataTrigger.icon		= icon:GetTexture()

	local _ = LuaTrigger.GetTrigger('craftingNewItemComponent'..index..'InfoDesign') or LuaTrigger.CreateGroupTrigger('craftingNewItemComponent'..index..'InfoDesign', {
		'CraftingUnfinishedDesign',
		'craftingNewItemComponent'..index..'Info',
	})
	
	cost:RegisterWatchLua('craftingNewItemComponent'..index..'InfoDesign', function(widget, groupTrigger)
		local trigger = groupTrigger['craftingNewItemComponent'..index..'Info']
		local CraftingUnfinishedDesign = groupTrigger.CraftingUnfinishedDesign	
		local craftingCraftInfo = LuaTrigger.GetTrigger('craftingCraftInfo')	
		
		lastPopupJublieValue[index] = lastPopupJublieValue[index] or 0
		
		if string.len(CraftingUnfinishedDesign.name) == 0 then		
			lastPopupJublieValue[index] = 0
		else
		
			local function Popup(targetWidget, content)
				local popupTable = targetWidget:InstantiateAndReturn('craftPanelCurrentJubliePopup', 'content', content, 'icon', '/ui/main/crafting/textures/jublie.tga', 'font', 'maindyn_30', 'iconSize', '32s')
				local popup = popupTable[1]
				popup:SetY('-28s')
				popup:SlideY('-75s', 1750)
				popup:FadeIn(250)
				popup:Sleep(1500, function()
					popup:FadeOut(250)
					popup:Sleep(250, function()
						popup:Destroy()
					end)
				end)
				popup:BringToFront()
			end			
			
			local indexToOffset = {
				[1] = -375,
				[2] = -340,
				[3] = -375,
			}
			
			local function PopupToButton(targetWidget, content, index)
				local popupTable = targetWidget:InstantiateAndReturn('craftPanelCurrentJubliePopup', 'content', content, 'icon', '/ui/main/crafting/textures/jublie.tga', 'font', 'maindyn_30', 'iconSize', '32s')
				local popup = popupTable[1]
				popup:SetY('-4s')
				popup:SlideX(GetWidget('mainCraftingJublieCost2'):GetAbsoluteX() - cost:GetAbsoluteX(), 1200)
				popup:SlideY(cost:GetAbsoluteY() + indexToOffset[index], 600)
				popup:FadeIn(250)
				popup:Sleep(600, function()
					popup:SlideY(GetWidget('mainCraftingJublieCost2'):GetAbsoluteY() - cost:GetAbsoluteY(), 600)			
					popup:Sleep(400, function()
						popup:FadeOut(250)
						popup:Sleep(250, function()
							popup:Destroy()
						end)
					end)
				end)
				popup:BringToFront()
			end			

			local jublieValue = 0
			if (trigger.exists) and (trigger.entity) and (not Empty(trigger.entity)) and ValidateEntity(trigger.entity) then	
				jublieValue = math.floor(trigger.craftingValue / style_crafting_costPerComponentPip)
			end
			
			if (craftingCraftInfo.minComponentCost ~= craftingCraftInfo.componentCost) then
				if (jublieValue > lastPopupJublieValue[index]) then
					PopupToButton(widget, ('^090' .. math.floor(jublieValue - lastPopupJublieValue[index])), index)
				elseif (jublieValue < lastPopupJublieValue[index]) then 
					PopupToButton(widget, ('^900' .. math.floor(lastPopupJublieValue[index] - jublieValue)), index)
				end
			else
				if (jublieValue > lastPopupJublieValue[index]) then
					PopupToButton(widget, ('^090' .. math.floor(jublieValue - lastPopupJublieValue[index])), index)
				elseif (jublieValue < lastPopupJublieValue[index]) then 
					PopupToButton(widget, ('^900' .. math.floor(lastPopupJublieValue[index] - jublieValue)), index)
				end		
			end
			
			lastPopupJublieValue[index] = jublieValue
		end
	end, false, nil)
	
	icon:RegisterWatchLua('craftingNewItemComponent'..index..'InfoDesign', function(widget, groupTrigger)
		local trigger = groupTrigger['craftingNewItemComponent'..index..'Info']
		local CraftingUnfinishedDesign = groupTrigger.CraftingUnfinishedDesign

		local parentEntity = CraftingUnfinishedDesign.name
		-- parentEntity = string.gsub(parentEntity, '$Local_UnfinishedDesign|', '')
		
		local recipeInfo	

		if parentEntity and (not Empty(parentEntity)) and ValidateEntity(parentEntity) then
			recipeInfo = craftingGetRecipe(parentEntity)
		end

		local widgetWidth
		local widgetHeight
		if trigger.exists then
			widgetWidth	= '100@'
			widgetHeight	= '100%'
			widget:SetTexture(trigger.icon)
			widget:SetColor('1 1 1 1.0')
			widget:SetRenderMode('normal')
		elseif recipeInfo and (recipeInfo.components) and (recipeInfo.components[index]) and (not Empty(recipeInfo.components[index])) and ValidateEntity(recipeInfo.components[index]) then
			widgetWidth	= '100@'
			widgetHeight	= '100%'
			widget:SetTexture(GetEntityIconPath(recipeInfo.components[index]) or trigger.icon)
			widget:SetColor('.3 .3 .3 1.0')
			widget:SetRenderMode('normal')
		else
			widgetWidth		= '80@'
			widgetHeight	= '80%'
			widget:SetTexture(trigger.icon)		
			widget:SetColor('1 1 1 1.0')
			widget:SetRenderMode('normal')
		end
		widget:SetWidth(widgetWidth)
		widget:SetHeight(widgetHeight)

	end, false, nil)

	removeButton:RegisterWatchLua('craftingNewItemComponent'..index..'Info', function(widget, trigger) widget:SetVisible(trigger.exists) end, false, nil, 'exists')
	-- rmm hide this while in click move

	removeButton:SetCallback('onclick', function(widget)
		PlaySound('/ui/sounds/sfx_button_generic.wav')
		
		local triggerNPE = LuaTrigger.GetTrigger('newPlayerExperience')
		if triggerNPE.tutorialComplete and triggerNPE.craftingIntroProgress == 0 and triggerNPE.craftingIntroStep == 3 then
			newPlayerExperienceCraftingStep(4)
		end
		
		Crafting.RemoveDesignComponent(index - 1)	-- 0-2
		
		local clickedItemTrigger = LuaTrigger.GetTrigger('craftingClickedComponent')
		clickedItemTrigger.entity = ''
		clickedItemTrigger:Trigger(false)		
		
		local triggerStage = LuaTrigger.GetTrigger('craftingStage')
		triggerStage.craftClickedComponentSlotIndex = -1
		triggerStage:Trigger(false)	
		
		craftingUpdateStage(3)
	end)

	removeButton:SetCallback('onmouseover', function(widget)
		simpleTipGrowYUpdate(true, nil, Translate('crafting_prompt_newitem_component_remove'), Translate('crafting_prompt_newitem_component_remove_tip'), libGeneral.HtoP(31))
	end)

	removeButton:SetCallback('onmouseout', function(widget)
		simpleTipGrowYUpdate(false)
	end)
	
	removeButton:RegisterWatchLua('CraftingGroupStatus', buttonDisableViaCraftActions)
end

local function craftingRegisterNewItemImbuement(object, index, newItemInfo)
	local container				= object:GetWidget('craftingImbuement_slot_'..index)
	local icon					= object:GetWidget('craftingImbuement_slot_'..index..'_Icon')
	local cost					= object:GetWidget('craftingImbuement_slot_'..index..'_Cost')
	local costParent			= object:GetWidget('craftingImbuement_slot_'..index..'_CostParent')
	local desc					= object:GetWidget('craftingImbuement_slot_'..index..'_Name')
	local name					= object:GetWidget('craftingImbuement_slot_'..index..'_Desc')
	local dropTarget			= object:GetWidget('craftingImbuement_slot_'..index..'_DropTarget')
	local clickDropTarget		= object:GetWidget('craftingImbuement_slot_'..index..'_ClickDropTarget')
	local Frame					= object:GetWidget('craftingImbuement_slot_'..index..'_Frame')
	local hoverFrame			= object:GetWidget('craftingImbuement_slot_'..index..'_hoverFrame')
	local btn					= object:GetWidget('craftingImbuement_slot_'..index..'_btn')
	local btnLabel				= object:GetWidget('craftingImbuement_slot_'..index..'_btnLabel')

	if (not container) then return end
	
	local CraftingUnfinishedDesign = LuaTrigger.GetTrigger('CraftingUnfinishedDesign')
	
	container:RegisterWatchLua('CraftingUnfinishedDesign', function(widget, trigger)
		if (not CraftingUnfinishedDesign['currentEmpoweredEffectEntityName']) or Empty((CraftingUnfinishedDesign['currentEmpoweredEffectEntityName'])) or (not ValidateEntity(CraftingUnfinishedDesign['currentEmpoweredEffectEntityName'])) then
			container:SetVisible(1) -- rmm no imbuement coverup
		else
			container:SetVisible(1)
		end	
	end)
	
	btnLabel:RegisterWatchLua('CraftingUnfinishedDesign', function(widget, trigger)
		if (not CraftingUnfinishedDesign['currentEmpoweredEffectEntityName']) or Empty((CraftingUnfinishedDesign['currentEmpoweredEffectEntityName'])) or (not ValidateEntity(CraftingUnfinishedDesign['currentEmpoweredEffectEntityName'])) then
			btnLabel:SetText(Translate('crafting_add_imbuement'))
			btn:SetWidth('98s')
		else
			btnLabel:SetText(Translate('crafting_remove_imbuement'))
			btn:SetWidth('98s')
		end	
	end)	
	
	btn:RegisterWatchLua('CraftingUnfinishedDesign', function(widget, trigger)
		if (not CraftingUnfinishedDesign['currentEmpoweredEffectEntityName']) or Empty((CraftingUnfinishedDesign['currentEmpoweredEffectEntityName'])) or (not ValidateEntity(CraftingUnfinishedDesign['currentEmpoweredEffectEntityName'])) then
			btn:SetCallback('onclick', function()
				local triggerStage = LuaTrigger.GetTrigger('craftingStage')
				local canCraftInfo = LuaTrigger.GetTrigger('craftingCraftInfo') 

				if (canCraftInfo.entity) and (not Empty(canCraftInfo.entity)) then
					craftingUpdateStage(8)
				end			
			end)
		else
			btn:SetCallback('onclick', function()
				local triggerStage = LuaTrigger.GetTrigger('craftingStage')
				local canCraftInfo = LuaTrigger.GetTrigger('craftingCraftInfo') 
				Crafting.SetDesignEmpoweredEffect('')
				if (canCraftInfo.entity) and (not Empty(canCraftInfo.entity)) then
					craftingUpdateStage(8)
				end			
			end)
		end			
	end)	
	
	btn:SetCallback('onrightclick', function()
		Crafting.SetDesignEmpoweredEffect('')			
	end)	
	
	name:RegisterWatchLua('CraftingUnfinishedDesign', function(widget, trigger)
		if (not CraftingUnfinishedDesign['currentEmpoweredEffectEntityName']) or Empty((CraftingUnfinishedDesign['currentEmpoweredEffectEntityName'])) or (not ValidateEntity(CraftingUnfinishedDesign['currentEmpoweredEffectEntityName'])) then
			widget:SetText(Translate('crafting_no_imbuement'))
		else
			widget:SetText(trigger['currentEmpoweredEffectDisplayName'] or '?Name?')
		end
	end, false, nil)
	
	desc:RegisterWatchLua('CraftingUnfinishedDesign', function(widget, trigger)
		if (not CraftingUnfinishedDesign['currentEmpoweredEffectEntityName']) or Empty((CraftingUnfinishedDesign['currentEmpoweredEffectEntityName'])) or (not ValidateEntity(CraftingUnfinishedDesign['currentEmpoweredEffectEntityName'])) then
			widget:SetText(Translate('crafting_no_imbuement_desc'))	
		else
			widget:SetText(trigger['currentEmpoweredEffectDescription'] or '?Description?')
		end
	end, false, nil)	
	
	costParent:RegisterWatchLua('CraftingUnfinishedDesign', function(widget, trigger)
		if (not CraftingUnfinishedDesign['currentEmpoweredEffectEntityName']) or Empty((CraftingUnfinishedDesign['currentEmpoweredEffectEntityName'])) or (not ValidateEntity(CraftingUnfinishedDesign['currentEmpoweredEffectEntityName'])) then
			widget:FadeOut(250)	
		else	
			widget:FadeIn(250)
		end
	end, false, nil)	
	
	cost:RegisterWatchLua('CraftingUnfinishedDesign', function(widget, trigger)
		if (not CraftingUnfinishedDesign['currentEmpoweredEffectEntityName']) or Empty((CraftingUnfinishedDesign['currentEmpoweredEffectEntityName'])) or (not ValidateEntity(CraftingUnfinishedDesign['currentEmpoweredEffectEntityName'])) then
		
		else	
			widget:SetText('+' .. trigger['currentEmpoweredEffectCost'] or '?Cost?')
		end
	end, false, nil)

	GetWidget('craftingImbuement_slot_0_gold_cost'):RegisterWatchLua('CraftingUnfinishedDesign', function(widget, trigger)
		if (not CraftingUnfinishedDesign['currentEmpoweredEffectEntityName']) or Empty((CraftingUnfinishedDesign['currentEmpoweredEffectEntityName'])) or (not ValidateEntity(CraftingUnfinishedDesign['currentEmpoweredEffectEntityName'])) then
			widget:SetText('0')
		else	
			widget:SetText('+' .. trigger['currentEmpoweredEffectCost'] or '?Cost?')
		end
	end, false, nil)	

	icon:RegisterWatchLua('CraftingUnfinishedDesign', function(widget, trigger)
		if (not CraftingUnfinishedDesign['currentEmpoweredEffectEntityName']) or Empty((CraftingUnfinishedDesign['currentEmpoweredEffectEntityName'])) or (not ValidateEntity(CraftingUnfinishedDesign['currentEmpoweredEffectEntityName'])) then
			widget:SetTexture('/ui/main/crafting/textures/imbue_icon.tga')
		else	
			widget:SetTexture('/ui/main/crafting/textures/imbue_icon_selected.tga')
		end
	end, false, nil)	
	
	local function buttonOver(widget)
		-- shopItemTipShow(1, 'craftedItemInfoShop')	
		hoverFrame:FadeIn(125)
	end
	
	local function buttonOut(widget)
		shopItemTipHide()
		hoverFrame:FadeOut(125)
	end	
	
	btn:SetCallback('onclick', function(widget)
		-- sound_craftingSelectSlotForComponent
		PlaySound('/ui/sounds/crafting/sfx_component_drag.wav')

		local triggerStage = LuaTrigger.GetTrigger('craftingStage')
		local canCraftInfo = LuaTrigger.GetTrigger('craftingCraftInfo') 

		if (canCraftInfo.entity) and (not Empty(canCraftInfo.entity)) then
			craftingUpdateStage(8)
		end
	end)
	btn:RegisterWatchLua('CraftingGroupStatus', buttonDisableViaCraftActions)
	
	container:SetCallback('onclick', function(widget)
		-- sound_craftingSelectSlotForComponent
		PlaySound('/ui/sounds/crafting/sfx_component_drag.wav')

		local triggerStage = LuaTrigger.GetTrigger('craftingStage')
		local canCraftInfo = LuaTrigger.GetTrigger('craftingCraftInfo') 

		if (canCraftInfo.entity) and (not Empty(canCraftInfo.entity)) then
			craftingUpdateStage(8)
		end
	end)
	container:SetCallback('onrightclick', function(widget)
		-- sound_craftingSelectSlotForComponent
		PlaySound('/ui/sounds/crafting/sfx_component_drag.wav')
		Crafting.SetDesignEmpoweredEffect('')
	end)	
	container:RegisterWatchLua('CraftingGroupStatus', buttonDisableViaCraftActions)
	
	btn:SetCallback('onmouseover', buttonOver)
	btn:SetCallback('onmouseout', buttonOut)	
	
	container:SetCallback('onmouseover', buttonOver)
	container:SetCallback('onmouseout', buttonOut)
	
	clickDropTarget:SetCallback('onmouseover', buttonOver)
	clickDropTarget:SetCallback('onmouseout', buttonOut)	

	clickDropTarget:RegisterWatchLua('craftingClickedComponent', function(widget, trigger)
		widget:SetVisible(string.len(trigger.entity) > 0)
	end, false, nil, 'entity')

	clickDropTarget:SetCallback('onclick', function(widget)
		-- sound_craftingClickPlaceComponentInSlot
		PlaySound('/ui/sounds/crafting/sfx_component_drop.wav')
	end)

	dropTarget:RegisterWatchLua('craftingClickedImbuement', function(widget, trigger)
		widget:SetVisible(trigger.active and trigger.index and trigger.index >= 0)
	end, false, nil, 'index', 'active')

	dropTarget:SetCallback('onmouseover', function(widget)
		buttonOver(widget)
		globalDraggerReadTarget(widget, function()
			-- sound_craftingDropPlaceComponentInSlot
			PlaySound('/ui/sounds/crafting/sfx_component_drop.wav')
			local CraftingUnfinishedDesign = LuaTrigger.GetTrigger('CraftingUnfinishedDesign')
			local craftingClickedImbuement = LuaTrigger.GetTrigger('craftingClickedImbuement')
			Crafting.SetDesignEmpoweredEffect(CraftingUnfinishedDesign['empoweredEffect'..craftingClickedImbuement.index..'EntityName'])
			craftingClickedImbuement.index = -1
			craftingClickedImbuement:Trigger(false)			
		end)
	end)
	
	dropTarget:SetCallback('onmouseout', buttonOut)

end

local function craftingRegisterItemCraftedComponent(object, index)
	local container		= object:GetWidget('craftingItemCraftedComponent'..index)
	local icon			= object:GetWidget('craftingItemCraftedComponent'..index..'Icon')

	local statName		= object:GetWidget('craftingItemCraftedComponent'..index..'StatName')	
	local statValue		= object:GetWidget('craftingItemCraftedComponent'..index..'StatValue')	
	
	icon:RegisterWatchLua('CraftingUnclaimedDesign', function(widget, trigger)
		local componentName	= trigger['component'..index]
		if componentName and string.len(componentName) > 0 then
			widget:SetVisible(true)
			widget:SetTexture( GetEntityIconPath( componentName ) )
		else
			widget:SetVisible(false)
		end
	end, false, nil, 'component'..index)

	container:RegisterWatchLua('CraftingUnclaimedDesign', function(widget, trigger)
		if (trigger['component'..index]) and (not Empty(trigger['component'..index])) then
			widget:SetVisible(true)
		else
			widget:SetVisible(false)
		end
	end, false, nil, 'component'..index)

	statName:RegisterWatchLua('CraftingUnclaimedDesign', function(widget, trigger)	
		local statFieldListLCS					= { 'power', 'maxHealth', 'baseHealthRegen', 'maxMana', 'baseManaRegen', 'baseAttackSpeed' }	-- In CraftingUnclaimedDesign, these start lower case
		if (trigger['component'..index]) and (not Empty(trigger['component'..index])) then		
			for k,v in ipairs(statFieldListLCS) do
				local comTable = craftingGetComponentByName(trigger['component'..index])
				if (comTable) and (comTable[v]) and (comTable[v] > 0) and (comTable.description) then
					local valueSuffix	= ''
					if v == 'baseAttackSpeed' then
						valueSuffix = '%'
						comTable[v] = math.floor(comTable[v] * 100)
					end

					widget:SetText(Translate('shop_item_stat_name_' .. v))
					statValue:SetText(comTable[v] .. valueSuffix)
					break
				else
					widget:SetText('')
				end
			end
		end
	end, false, nil, 'description')

end

local function craftingRegisterItemCraftedImbuement(object, index)
	local craftingItemCraftedmbuementContainer		=   object:GetWidget('craftingItemCraftedmbuementContainer')
	local craftingItemCraftedImbuement_icon			=   object:GetWidget('craftingItemCraftedImbuement_icon')
	local craftingItemCraftedImbuement_label_1		=   object:GetWidget('craftingItemCraftedImbuement_label_1')
	local craftingItemCraftedImbuement_label_3		=   object:GetWidget('craftingItemCraftedImbuement_label_3')
	local craftingItemCraftedImbuement_label_2		=   object:GetWidget('craftingItemCraftedImbuement_label_2')
	
	craftingItemCraftedmbuementContainer:RegisterWatchLua('CraftingUnclaimedDesign', function(widget, trigger)
		if (trigger.currentEmpoweredEffectEntityName) and (not Empty(trigger.currentEmpoweredEffectEntityName)) then
			widget:SetVisible(1)
		else
			widget:SetVisible(0)
		end
	end, false, nil, 'currentEmpoweredEffectEntityName')
	
	craftingItemCraftedImbuement_label_1:RegisterWatchLua('CraftingUnclaimedDesign', function(widget, trigger)
		if (trigger.currentEmpoweredEffectEntityName) and (not Empty(trigger.currentEmpoweredEffectEntityName)) then
			widget:SetText(trigger.currentEmpoweredEffectDisplayName)
		else
			widget:SetText('')
		end
	end, false, nil, 'currentEmpoweredEffectEntityName', 'currentEmpoweredEffectDisplayName')	
	
	craftingItemCraftedImbuement_label_3:RegisterWatchLua('CraftingUnclaimedDesign', function(widget, trigger)
		if (trigger.currentEmpoweredEffectEntityName) and (not Empty(trigger.currentEmpoweredEffectEntityName)) then
			widget:SetText(trigger.currentEmpoweredEffectDescription)
		else
			widget:SetText('')
		end
	end, false, nil, 'currentEmpoweredEffectEntityName', 'currentEmpoweredEffectDescription')		
	
end

local function craftingRegisterEnchantItemListTab(object, index, itemType)
	itemType = itemType or ''

	local button	= object:GetWidget('mainEnchantItemListTab'..index)
	local selected	= object:GetWidget('mainEnchantItemListTab'..index..'Selected')
	local backer	= object:GetWidget('mainEnchantItemListTab'..index..'Backer')
	local glow		= object:GetWidget('mainEnchantItemListTab'..index..'Glow')

	local pulseDuration = 1000
	local glowVis		= true
	local lastGlowVis	= false
	local glowR, glowG, glowB, glowA = glow:GetColor()

	local function glowEnd()
		glow:UnregisterWatchLua('System')
		glow:FadeOut(pulseDuration)
	end

	local function glowStart()
		glowEnd()
		glow:RegisterWatchLua('System', function(widget, trigger)
			local hostTime = trigger.hostTime

			if glowVis and (lastGlowVis ~= glowVis) then
				widget:FadeIn(pulseDuration)
				lastGlowVis = glowVis
			elseif (not glowVis) and (lastGlowVis ~= glowVis) then
				widget:FadeOut(pulseDuration)
				lastGlowVis = glowVis
			end

			glowVis = ((hostTime % (pulseDuration * 2)) > pulseDuration)
		end, false, nil, 'hostTime')
	end
	
	glow:RegisterWatchLua('craftingStage', function(widget, trigger)
		local isSelected = (itemType == trigger.craftedItemsFilter)
		-- widget:SetVisible(isSelected)
		if isSelected then
			glowStart()
		else
			glowEnd()
		end
	end, false, nil, 'craftedItemsFilter')
	
	button:SetCallback('onshow', function(widget)
		if LuaTrigger.GetTrigger('craftingStage').craftedItemsFilter == itemType then
			glowStart()
		end
	end)
	
	button:SetCallback('onmouseover', function(widget)
		selected:SetVisible(true)
	end)
	
	button:SetCallback('onmouseout', function(widget)
		selected:SetVisible(false)
	end)
	
	button:SetCallback('onclick', function(widget)
		local craftingStage = LuaTrigger.GetTrigger('craftingStage')
		if craftingStage.craftedItemsFilter == itemType then
			craftingStage.craftedItemsFilter = ''
			craftingStage:Trigger(false)
		else
			craftingStage.craftedItemsFilter = itemType
			craftingStage:Trigger(false)
		end
		-- sound_enchantItemListSelectCategory
		PlaySound('/ui/sounds/crafting/sfx_category.wav')
	end)
end

local function craftingRegister(object)
	local container							= object:GetWidget('mainCrafting')	-- Just need a widget to register stuff to

	craftingRegisterEnchantItemListTab(object, 1, '')
	craftingRegisterEnchantItemListTab(object, 2, 'ability')
	craftingRegisterEnchantItemListTab(object, 3, 'attack')
	craftingRegisterEnchantItemListTab(object, 4, 'mana')
	craftingRegisterEnchantItemListTab(object, 5, 'defense')
	craftingRegisterEnchantItemListTab(object, 6, 'utility')

	local enchantStationMustTemper			= object:GetWidget('enchantItemNotTempered')
	local enchantStationTemperButton		= object:GetWidget('enchantStationTemper')

	local enchantDurationBar				= object:GetWidget('mainEnchantDurationBar')

	local enchantStationLastIndex			= -1
	local enchantStationItemName			= object:GetWidget('enchantItemQualityItemName')
	local enchantStationItemIcon			= object:GetWidget('craftingEnchantStationItemIcon')
	local craftingEnchantStationSwapButton2_frame			= object:GetWidget('craftingEnchantStationSwapButton2_frame')
	local craftingEnchantStationSwapButton2_hover_frame		= object:GetWidget('craftingEnchantStationSwapButton2_hover_frame')
	local enchantStationSwapButton			= object:GetWidget('craftingEnchantStationSwapButton')
	local enchantStationSwapButton2			= object:GetWidget('craftingEnchantStationSwapButton2')
	local enchantStationCostEssence			= object:GetWidget('enchantItemCostEssence')
	local enchantItemCostSelectItem			= object:GetWidget('enchantItemCostSelectItem')
	local enchantItemCostInfo				= object:GetWidget('enchantItemCostInfo')
	

	local enchantPullBar					= object:GetWidget('enchantItemPullBar')
	local enchantPullBarCostInfo			= object:GetWidget('enchantItemCostInfo')

	local triggerClickedComponent			= LuaTrigger.GetTrigger('craftingClickedComponent')
	local stageTrigger						= LuaTrigger.GetTrigger('craftingStage')
	local statFieldListLCS					= { 'power', 'maxHealth', 'baseHealthRegen', 'maxMana', 'baseManaRegen', 'baseAttackSpeed' }	-- In CraftingUnclaimedDesign, these start lower case

	local enchantStationBonus			= {}
	
	-- ================

	local craftSelectRecipeTarget		= object:GetWidget('mainCraftSelectRecipeTarget')
	local craftSelectRecipeTargetBody	= object:GetWidget('mainCraftSelectRecipeTargetBody')

	craftSelectRecipeTarget:RegisterWatchLua('globalDragInfo', function(widget, trigger)
		if LuaTrigger.GetTrigger('mainPanelStatus').main == 1 then
			widget:SetVisible(trigger.active and trigger.type == 4)
		end
		
	end, false, nil, 'active', 'type')

	craftSelectRecipeTarget:SetCallback('onmouseover', function(widget)
		craftSelectRecipeTargetBody:SetVisible(true)

		globalDraggerReadTarget(widget, function()
			local draggedRecipe = LuaTrigger.GetTrigger('gamePanelInfo').shopDraggedItem
			craftingSelectRecipe(draggedRecipe)
		end)

	end)

	craftSelectRecipeTarget:SetCallback('onmouseout', function(widget)
		craftSelectRecipeTargetBody:SetVisible(false)
	end)
	
	-- ================
	
	local enchantSalvageTarget			= object:GetWidget('mainEnchantSalvageTarget')
	local enchantSalvageTargetBody		= object:GetWidget('mainEnchantSalvageTargetBody')
	local enchantSalvageTargetBodyColor	= object:GetWidget('mainEnchantSalvageTargetBodyColor')

	enchantSalvageTarget:RegisterWatchLua('craftingStage', function(widget, trigger)
		libGeneral.fade(widget, (trigger.stage == 5), styles_shopTransitionTime)
	end, false, nil, 'stage')	
	
	
	enchantSalvageTargetBody:RegisterWatchLua('globalDragInfo', function(widget, trigger)
		widget:SetVisible(trigger.active and trigger.type == 5)
	end, false, nil, 'active', 'type')
	
	enchantSalvageTargetBody:SetCallback('onmouseover', function(widget)
		enchantSalvageTargetBodyColor:SetVisible(true)

		globalDraggerReadTarget(widget, function()
			-- sound_enchantingDroppedToSalvage
			-- PlaySound('/path_to_soundfile.wav')
			local stageTrigger		= LuaTrigger.GetTrigger('craftingStage')
			craftingPromptSalvageUpdate(stageTrigger.enchantLastDraggedIndex)
		end)

	end)

	enchantSalvageTargetBody:SetCallback('onmouseout', function(widget)
		enchantSalvageTargetBodyColor:SetVisible(false)
	end)
	
	-- ==============

	local itemBonusQualityParams		= {
		Analog		= {
			quality		= 'normalQuality',
			exists		= '',
			name		= '',
			icon		= '',
			description	= 'bonusDescription'
		},
		Rare		= {
			quality		= 'rareQuality',
			exists		= 'isRare',
			name		= 'rareBonusName',
			icon		= 'rareBonusIcon',
			description	= 'rareBonusDescription'
		},
		Legendary	= {
			quality		= 'legendaryQuality',
			exists		= 'isLegendary',
			name		= 'legendaryBonusName',
			icon		= 'legendaryBonusIcon',
			description	= 'legendaryBonusDescription'
		}
	}
	local itemBonusTypes				= { 'Analog', 'Rare', 'Legendary' }

	for k,v in ipairs(itemBonusTypes) do
		enchantStationBonus[v] = {
			name				= object:GetWidget('enchantItemQuality'..v..'BonusName'),
			description			= object:GetWidget('enchantItemQuality'..v..'BonusDescription'),
			icon				= object:GetWidget('enchantItemQuality'..v..'Icon'),
			iconContainer		= object:GetWidget('enchantItemQuality'..v..'IconContainer'),
			locked				= object:GetWidget('enchantItemQuality'..v..'Locked'),
			qualityBar			= object:GetWidget('enchantItemQuality'..v..'Bar'),
			qualityBarEffect	= object:GetWidget('enchantItemQuality'..v..'BarEffect'),
			backer				= object:GetWidget('enchantItemQuality'..v..'Backer'),
			pips				= object:GetWidget('enchantItemQuality'..v..'Pips'),
		}
	end

	local inventoryListbox				= object:GetWidget('craftingInventoryListbox')
	local inventoryClose				= object:GetWidget('craftingInventoryClose')

	local promptTemper					= object:GetWidget('craftingPromptTemper')
	local promptTemperClose				= object:GetWidget('craftingPromptTemperClose')
	local promptTemperCost				= object:GetWidget('craftingPromptTemperCost')
	local promptTemperCostGems			= object:GetWidget('craftingPromptTemperCostGems')

	local promptSalvage					= object:GetWidget('craftingPromptSalvage')
	local promptSalvageClose			= object:GetWidget('craftingPromptSalvageClose')
	local promptSalvageOreCost			= object:GetWidget('craftingPromptSalvageOreCost')
	local promptSalvageOreReturned		= object:GetWidget('craftingPromptSalvageOreReturned')

	local promptNewItemChooseRecipeButton	= object:GetWidget('craftPanelSelectRecipeButton')
	local promptNewItemChooseRecipeButton2	= object:GetWidget('craftPanelSelectRecipeButton2')
	local promptNewItemChooseRecipeButton3	= object:GetWidget('craftPanelSelectRecipeButton3')
	
	local promptNewItemChooseRecipeNotice	= object:GetWidget('craftPanelSelectRecipeNotice')

	local newItemEfficiencyBar			= object:GetWidget('mainCraftingEfficiencyBar')
	local craftItemButton				= object:GetWidget('craftItemButton')
	local craftOreCost					= object:GetWidget('mainCraftingOreCost')
	local craftOreCostParent			= object:GetWidget('mainCraftingOreCostParent')
	local JublieCost					= object:GetWidget('mainCraftingJublieCost')
	local JublieCost2					= object:GetWidget('mainCraftingJublieCost2')
	local JublieCostReq					= object:GetWidget('mainCraftingJublieCostReq')
	local JublieCostParent				= object:GetWidget('mainCraftingJublieCostParent')

	-- ================================================================================
	-- ================================================================================

	local itemCrafted				= object:GetWidget('craftingItemCrafted')
	local itemCraftedClose			= object:GetWidget('craftingItemCraftedClose')
	local itemCraftedName			= object:GetWidget('craftItemQualityItemName')
	local itemCraftedIcon			= object:GetWidget('craftingItemCraftedIcon')
	local itemCraftedDescription	= object:GetWidget('craftingItemCraftedDescription')
	local itemCraftedRecraft		= object:GetWidget('craftingItemCraftedRecraft')
	local itemCraftedUpgrade		= object:GetWidget('craftingItemCraftedUpgrade')
	local itemCraftedSalvage		= object:GetWidget('craftingItemCraftedSalvage')
	local itemCraftedFinish			= object:GetWidget('craftingItemCraftedFinish')

	local itemCraftedTempBonusName			= nil
	local itemCraftedTempIcon				= nil
	local itemCraftedTempBonusDescription	= nil
	local itemCraftedTempIconContainer		= nil
	local itemCraftedTempLocked				= nil
	local itemCraftedTempBar				= nil
	local itemCraftedTempBarLabel			= nil
	local itemCraftedTempPips				= nil

	local function itemCraftedClaim()
		Crafting.ClaimCraftedDesign()
		Crafting.Save()
		Crafting.ClearDesign()
		lastStage = nil
		Crafting.SetDesignEmpoweredEffect('')
		mainUI.RefreshProducts()
		craftingUpdateStage(0)
		if (mainUI) and  (mainUI.savedLocally) and  (mainUI.savedLocally.adaptiveTraining) and (mainUI.savedLocally.adaptiveTraining.featureList) and (mainUI.savedLocally.adaptiveTraining.featureList) then
			mainUI.AdaptiveTraining.RecordUtilisationInstanceByFeatureName('crafting')
		end
	end
	
	itemCrafted:RegisterWatchLua('craftingStageUnclaimed', function(widget, groupTrigger)
		local triggerStage				= groupTrigger['craftingStage']
		local triggerDesign				= groupTrigger['CraftingUnclaimedDesign']
		local triggerAnimationStatus	= groupTrigger['mainPanelAnimationStatus']
		local designID = triggerDesign.id
		
		if triggerDesign.available and designID >= 0 and designID ~= 4294967296 then
			if mainSectionAnimState(1, triggerAnimationStatus.main, triggerAnimationStatus.newMain) == 4 then
				widget:FadeIn(styles_shopTransitionTime)
				if triggerDesign.isLegendary then
					keeperPlayVO('craft_complete_legendary', true)
				elseif triggerDesign.isRare then
					keeperPlayVO('craft_complete_rare', true)
				else
					keeperPlayVO('craft_complete')
				end
			else
				itemCraftedClaim()
				widget:FadeOut(styles_shopTransitionTime)
			end
		else
			widget:FadeOut(styles_shopTransitionTime)
		end
	end)

	itemCraftedClose:SetCallback('onclick', function(widget)
		-- sound_craftingItemCraftedClose
		-- PlaySound('/path_to_soundfile.wav')
		itemCraftedClaim()
	end)
	
	itemCraftedFinish:SetCallback('onclick', function(widget)
		-- sound_craftingItemCraftedFinish
		PlaySound('/ui/sounds/sfx_button_generic.wav')
		itemCraftedClaim()
	end)

	itemCraftedFinish:SetCallback('onmouseover', function(widget)
		simpleTipGrowYUpdate(true, nil, Translate('crafting_itemcraftedreturn'), Translate('crafting_itemcraftedreturn_tip'), libGeneral.HtoP(28))
	end)
	
	itemCraftedFinish:SetCallback('onmouseout', function(widget)
		simpleTipGrowYUpdate(false)
	end)

	itemCraftedFinish:RegisterWatchLua('CraftingGroupStatus', function(widget, groupTrigger)
		widget:SetEnabled(
			(not CraftingAnimationStatus.requestPending) and
			(not CraftingAnimationStatus.enchantAnimating) and
			(not CraftingAnimationStatus.rerollAnimating) and
			(not CraftingAnimationStatus.craftAnimating)
		)
	end)

	itemCraftedUpgrade:SetCallback('onclick', function(widget)
		-- sound_craftingItemCraftedUpgrade
		PlaySound('/ui/sounds/sfx_button_generic.wav')
		local itemInfo = LuaTrigger.GetTrigger('CraftingUnclaimedDesign')

		if itemInfo.available then
			PlaySound('/ui/sounds/sfx_button_generic.wav')
			craftingPromptEnchantUpdate(itemInfo.id)
			keeperPlayVO('enchant')
			
			Crafting.ClaimCraftedDesign()
			Crafting.Save()
			mainUI.RefreshProducts()
			craftingUpdateStage(6,0, false)


			local mainPanelStatus = LuaTrigger.GetTrigger('mainPanelStatus')
			mainPanelStatus.main = 5
			mainPanelStatus:Trigger(false)
			PlaySound('/ui/sounds/sfx_transition_1.wav')
		end
	end)

	itemCraftedUpgrade:SetCallback('onmouseover', function(widget)
		simpleTipGrowYUpdate(true, nil, Translate('crafting_enchant'), Translate('crafting_enchant_tip'), libGeneral.HtoP(30))
	end)

	itemCraftedUpgrade:SetCallback('onmouseout', function(widget)
		simpleTipGrowYUpdate(false)
	end)
	
	itemCraftedUpgrade:RegisterWatchLua('CraftingGroupStatus', function(widget, groupTrigger)
		widget:SetEnabled(
			(not CraftingAnimationStatus.requestPending) and
			(not CraftingAnimationStatus.enchantAnimating) and
			(not CraftingAnimationStatus.rerollAnimating) and
			(not CraftingAnimationStatus.craftAnimating)
		)
	end)

	itemCraftedSalvage:SetCallback('onclick', function(widget)
		-- sound_craftingItemCraftedSalvage
		PlaySound('/ui/sounds/crafting/sfx_salvage.wav')
		Crafting.SalvageUnclaimedDesign()
	end)
	
	itemCraftedSalvage:SetCallback('onmouseover', function(widget)
		simpleTipGrowYUpdate(true, nil, Translate('crafting_salvage'), Translate('crafting_salvage_tip'), libGeneral.HtoP(30))
	end)

	itemCraftedSalvage:SetCallback('onmouseout', function(widget)
		simpleTipGrowYUpdate(false)
	end)

	itemCraftedSalvage:RegisterWatchLua('CraftingGroupStatus', function(widget, groupTrigger)
		widget:SetEnabled(
			(not CraftingAnimationStatus.requestPending) and
			(not CraftingAnimationStatus.enchantAnimating) and
			(not CraftingAnimationStatus.rerollAnimating) and
			(not CraftingAnimationStatus.craftAnimating)
		)
	end)
	
	object:GetWidget('craftingItemCraftedIngameCost'):RegisterWatchLua('CraftingUnfinishedDesign', function(widget, trigger)
		local componentTrigger
		local totalCost = trigger.recipeCost

		for i=1,3,1 do
			componentTrigger	= LuaTrigger.GetTrigger('craftingNewItemComponent'..i..'Info')
			if componentTrigger.exists then
				totalCost = totalCost + componentTrigger.cost
			end
		end
		if (trigger['currentEmpoweredEffectEntityName']) and (not Empty((trigger['currentEmpoweredEffectEntityName']))) and ValidateEntity((trigger['currentEmpoweredEffectEntityName'])) then
			if (trigger['currentEmpoweredEffectCost']) and tonumber((trigger['currentEmpoweredEffectCost'])) then
				totalCost = totalCost + tonumber((trigger['currentEmpoweredEffectCost']))
			end
		end		
		widget:SetText(libNumber.commaFormat(totalCost))
	end, false, nil, 'recipeCost', 'component1', 'component2', 'component3', 'currentEmpoweredEffectEntityName', 'currentEmpoweredEffectCost')

	local recraftQueued = false
	
	itemCraftedRecraft:SetCallback('onclick', function(widget)
		-- sound_craftingItemCraftedRecraft
		PlaySound('/ui/sounds/crafting/sfx_item_craft.wav')
		recraftQueued = true
		Crafting.SalvageUnclaimedDesign()
		CraftingAnimationStatus.craftAnimating = true
		CraftingAnimationStatus:Trigger(false)		
	end)
	
	itemCraftedRecraft:RegisterWatchLua('GameClientRequestsSalvageCraftedItem', function(widget, trigger)
		if trigger.status == 2 and recraftQueued then
			recraftQueued = false
			updateCraftedItemQuality(widget, 'craftItemQuality', false, { common = 0, rare = 0, legendary = 0 })	-- this is kind of just for safety.  in reality it should already be at 0
			Crafting.CraftDesign()
		end
	end, false, nil, 'status')
	
	itemCraftedRecraft:SetCallback('onmouseover', function(widget)
		simpleTipGrowYUpdate(true, nil, Translate('crafting_recraft'), Translate('crafting_recraft_tip'), libGeneral.HtoP(38))
	end)
	itemCraftedRecraft:SetCallback('onmouseout', function(widget)
		simpleTipGrowYUpdate(false)
	end)
	
	object:GetWidget('craftingItemCraftedRecraftCost'):RegisterWatchLua('CraftingUnclaimedDesign', function(widget, trigger)
		local oreCost = trigger.oreCost
		widget:SetText(oreCost - (oreCost / 4))
	end, false, nil, 'oreCost')

	itemCraftedRecraft:RegisterWatchLua('CraftingGroupStatus', function(widget, groupTrigger) 
		local triggerDesign	= groupTrigger['CraftingUnclaimedDesign']
		local triggerOre	= groupTrigger['CraftingCommodityInfo']
		
		local notBusy		= (
			(not CraftingAnimationStatus.requestPending) and
			(not CraftingAnimationStatus.enchantAnimating) and
			(not CraftingAnimationStatus.rerollAnimating) and
			(not CraftingAnimationStatus.craftAnimating)
		)		
		
		widget:SetEnabled(
			triggerOre.oreCount >= (triggerDesign.oreCost - (triggerDesign.oreCost / 4)) and
			notBusy
		)
	end)

	itemCraftedIcon:RegisterWatchLua('CraftingUnclaimedDesign', function(widget, trigger)
		local entityName	= trigger.name
		if string.len(entityName) > 0 then
			widget:SetTexture(GetEntityIconPath(trigger.name))
		end
	end, false, nil, 'name')

	itemCraftedName:RegisterWatchLua('CraftingUnclaimedDesign', function(widget, trigger)
		local entityName		= trigger.name

		if string.len(entityName) > 0 then
			local isRare		= trigger.isRare
			local isLegendary	= trigger.isLegendary
			widget:SetColor(libGeneral.craftedItemGetNameColor(isRare, isLegendary))
			
			local rareBonus			= trigger.rareBonusName
			local legendaryBonus	= trigger.legendaryBonusName

			local fullItemName = libGeneral.craftedItemFormatName(GetEntityDisplayName(entityName), isRare, rareBonus, isLegendary, legendaryBonus)
			FitFontToLabel(widget, fullItemName)
			widget:SetText(fullItemName)
		end		
	end, false, nil, 'name', 'isRare', 'isLegendary', 'rareBonusName', 'legendaryBonusName')

	itemCraftedDescription:RegisterWatchLua('CraftingUnclaimedDesign', function(widget, trigger) widget:SetText(trigger.description) end, false, nil, 'description')
	
	--[[
	for k,v in pairs(itemBonusQualityParams) do
		itemCraftedTempBonusDescription	= object:GetWidget('craftItemQuality'..k..'BonusDescription')

		itemCraftedTempLocked			= object:GetWidget('craftItemQuality'..k..'Locked')
		itemCraftedTempBonusName		= object:GetWidget('craftItemQuality'..k..'BonusName')	-- Empty/invisible for analog.  Otherwise 'Locked!' or name of bonus.

		if k ~= 'Analog' then
			itemCraftedTempBonusName:SetVisible(true)
			itemCraftedTempBonusName:RegisterWatchLua('CraftingUnclaimedDesign', function(widget, trigger)
				if trigger[v.exists] then
					widget:SetText(trigger[v.name])
				else
					widget:SetText(Translate('crafting_locked'))
				end
			end, false, nil, v.name, v.exists)
			
			object:GetWidget('craftItemQuality'..k..'Backer'):RegisterWatchLua('CraftingUnclaimedDesign', function(widget, trigger)
				if trigger[v.exists] then
					widget:SetColor(1,1,1)
					widget:SetRenderMode('normal')
				else
					widget:SetColor(0.6, 0.6, 0.6)
					widget:SetRenderMode('grayscale')
				end
			end, false, nil, v.exists)
			
			object:GetWidget('craftItemQuality'..k..'Icon'):RegisterWatchLua('CraftingUnclaimedDesign', function(widget, trigger)
				if trigger[v.exists] then
					widget:SetTexture(trigger[v.icon])
				end
			end, false, nil, v.icon, v.exists)
			
			object:GetWidget('craftItemQuality'..k..'IconContainer'):RegisterWatchLua('CraftingUnclaimedDesign', function(widget, trigger)
				if trigger[v.exists] then
					
					widget:SetVisible(true)
				else
					widget:SetVisible(false)
				end
			end, false, nil, v.icon, v.exists)

			itemCraftedTempLocked:RegisterWatchLua('CraftingUnclaimedDesign', function(widget, trigger)
				widget:SetVisible(not trigger[v.exists])
			end, false, nil, v.exists)

			itemCraftedTempBonusDescription:RegisterWatchLua('CraftingUnclaimedDesign', function(widget, trigger)
				if trigger[v.exists] then
					widget:SetText(StripColorCodes(trigger[v.description]))
				else
					widget:SetText(Translate('crafting_bonus_'..k..'_description'))
				end
				
			end, false, nil, v.description, v.exists)
		else
			-- itemCraftedTempIconContainer:SetVisible(true)
			itemCraftedTempBonusName:SetVisible(false)
			itemCraftedTempBonusDescription:RegisterWatchLua('CraftingUnclaimedDesign', function(widget, trigger) widget:SetText(trigger[v.description]) end, false, nil, v.description)
		end
	end
	--]]

	for i=1,3,1 do
		craftingRegisterItemCraftedComponent(object, i)
	end

	craftingRegisterItemCraftedImbuement(object, 0)
	
	-- ================================================================================
	-- ================================================================================

	container:RegisterWatchLua('CraftingUnfinishedDesign', function(widget, trigger)
		local componentTrigger, componentInfo, componentName

		for i=1,3,1 do
			componentTrigger	= LuaTrigger.GetTrigger('craftingNewItemComponent'..i..'Info')
			componentName = trigger['component'..i]
			if componentName and string.len(componentName) > 0 then
				componentInfo					= craftingGetComponentByName(componentName)
				if componentInfo then
					componentTrigger.exists 		= true
					componentTrigger.entity			= componentInfo.name
					componentTrigger.cost			= componentInfo.cost
					componentTrigger.craftingValue	= componentInfo.craftingValue
					componentTrigger.name			= componentInfo.displayName
					componentTrigger.description	= componentInfo.description
					componentTrigger.icon			= componentInfo.icon

					componentTrigger.power				= componentInfo.power
					componentTrigger.baseAttackSpeed	= componentInfo.baseAttackSpeed
					componentTrigger.health				= componentInfo.maxHealth
					componentTrigger.mana				= componentInfo.maxMana
					componentTrigger.healthRegen		= componentInfo.baseHealthRegen
					componentTrigger.manaRegen			= componentInfo.baseManaRegen
				end

			else
				componentTrigger.icon			= style_crafting_componentEmptyAddIcon
				componentTrigger.exists	= false

				componentTrigger.power				= 0
				componentTrigger.baseAttackSpeed	= 0
				componentTrigger.health				= 0
				componentTrigger.mana				= 0
				componentTrigger.healthRegen		= 0
				componentTrigger.manaRegen			= 0
			end
			componentTrigger:Trigger(true)
		end
	end, false, nil, 'component1', 'component2', 'component3')

	-- ================================================================================
	-- ================================================================================

	--[[

	-- rmm hook up status indicator for enchanting
	enchantStatus				= object:GetWidget('enchantStatus')
	enchantStatusLabel			= object:GetWidget('enchantStatusLabel')

	enchantStatus:RegisterWatchLua('GameClientRequestsEnchantCraftedItem', function(widget, trigger)
		local statusNum = trigger.status
		if statusNum == 2 or statusNum == 3 then
			widget:FadeIn(100)
			widget:Sleep(5000, function() widget:FadeOut(1000) end)

		end
	end, false, nil, 'status')

	enchantStatusLabel:RegisterWatchLua('GameClientRequestsEnchantCraftedItem', function(widget, trigger)
			if trigger.status == 3 then
				enchantStatusLabel:SetText(trigger.errorMessage)
			elseif trigger.status == 2 then

				widget:Sleep(1, function()
					local itemInfo = LuaTrigger.GetTrigger('CraftedItems'..stageTrigger.enchantSelectedIndex)

					if (
						enchantLastNormalQuality == itemInfo.normalQuality and
						enchantLastRareQuality == itemInfo.rareQuality and
						enchantLastLegendaryQuality == itemInfo.legendaryQuality and
						enchantLastIsRare == itemInfo.isRare and
						enchantLastIsLegendary == itemInfo.isLegendary
					) then
						enchantStatusLabel:SetText('^r'..Translate('crafting_enchant_fail'))
					else

						if itemInfo.isLegendary and not enchantLastIsLegendary then
							keeperPlayVO('enchant_complete_nowlegendary', true)
						elseif itemInfo.isRare and not enchantLastIsRare then
							keeperPlayVO('enchant_complete_nowrare', true)
						else
							keeperPlayVO('enchant_complete')
						end

						enchantStatusLabel:SetText('^g'..Translate('crafting_enchant_success'))
					end
				end)
			end
	end, false, nil, 'status', 'errorMessage')

	--]]
	
	GetWidget('craftPanelCurrentIngameCost_parent'):SetCallback('onmouseover', function(widget, trigger)
		for i=1,3,1 do
			GetWidget('craftingNewItemComponent'..i..'_gold_coverup'):FadeIn(125)
		end
		GetWidget('craftPanelSelectRecipeButton2_gold_coverup'):FadeIn(125)
		GetWidget('craftingImbuement_slot_0_gold_coverup'):FadeIn(125)
	end)
	
	GetWidget('craftPanelCurrentIngameCost_parent'):SetCallback('onmouseout', function(widget, trigger)
		for i=1,3,1 do
			GetWidget('craftingNewItemComponent'..i..'_gold_coverup'):FadeOut(125)
		end	
		GetWidget('craftPanelSelectRecipeButton2_gold_coverup'):FadeOut(125)
		GetWidget('craftingImbuement_slot_0_gold_coverup'):FadeOut(125)
	end)	
	
	lastTotalCost = 0
	GetWidget('crafting_interaction_block_3'):RegisterWatchLua('CraftingUnfinishedDesign', function(widget, trigger)
		local componentName, componentInfo
		local componentCost = 0
		local componentActualCost	= 0
		for i=1,3,1 do
			componentName = trigger['component'..i]
			if componentName and string.len(componentName) > 0 then
				componentInfo = craftingGetComponentByName(componentName)
				if componentInfo then
					componentActualCost = componentActualCost + componentInfo.cost
					componentCost = componentCost + componentInfo.craftingValue
				end
			end
		end

		local minComponentCost = trigger.componentCost
		
		local canCraftInfo = LuaTrigger.GetTrigger('craftingCraftInfo')
		canCraftInfo.minComponentCost	= minComponentCost
		canCraftInfo.oreCost			= trigger.oreCost
		canCraftInfo.gemCost			= trigger.gemCost
		canCraftInfo.componentCost		= componentCost
		canCraftInfo.entity				= trigger.name
		canCraftInfo:Trigger(false)

		local itemCostLabel				= widget:GetWidget('craftPanelCurrentIngameCost')
		local itemCostLabelPopup		= widget:GetWidget('craftPanelCurrentIngameCost_popupinsert')
		totalCost = trigger.recipeCost + componentActualCost
		
		if (trigger['currentEmpoweredEffectEntityName']) and (not Empty((trigger['currentEmpoweredEffectEntityName']))) and ValidateEntity((trigger['currentEmpoweredEffectEntityName'])) then
			if (trigger['currentEmpoweredEffectCost']) and tonumber((trigger['currentEmpoweredEffectCost'])) then
				totalCost = totalCost + tonumber((trigger['currentEmpoweredEffectCost']))
			end
		end			
		
		if string.len(trigger.name) == 0 then		
			lastTotalCost = 0
		else	
			
			local function Popup(content)
				local popupTable = itemCostLabelPopup:InstantiateAndReturn('craftPanelCurrentIngameCostPopup', 'content', content, 'icon', '/ui/elements:gold_coins')
				local popup = popupTable[1]
				popup:SetY('-28s')
				popup:SlideY('-125s', 2250)
				popup:FadeIn(125)
				popup:Sleep(2000, function()
					popup:FadeOut(250)
					popup:Sleep(250, function()
						popup:Destroy()
					end)
				end)
			end
			
			if (lastTotalCost == 0) or (totalCost == 0) or (totalCost == lastTotalCost) then
				itemCostLabel:SetText(libNumber.commaFormat(totalCost))
			elseif (totalCost > lastTotalCost) then
				AnimatedLabelIncrease(itemCostLabel, totalCost, lastTotalCost)
				Popup('^900+' .. math.floor(totalCost - lastTotalCost))
			elseif (totalCost < lastTotalCost) then
				AnimatedLabelDecrease(itemCostLabel, totalCost, lastTotalCost)	
				Popup('^090-' .. math.floor(lastTotalCost - totalCost))			
			end
			
			lastTotalCost = totalCost
		end
	end, false, nil)

	GetWidget('crafting_interaction_block_3'):RegisterWatchLua('CraftingCommodityInfo', function(widget, trigger)
		local canCraftInfo = LuaTrigger.GetTrigger('craftingCraftInfo')
		canCraftInfo.oreCount = trigger.oreCount
		canCraftInfo:Trigger(false)
	end, false, nil, 'oreCount')

	promptNewItemChooseRecipeNotice:RegisterWatchLua('CraftingUnfinishedDesign', function(widget, trigger)
		local entity = trigger.name
		widget:SetVisible(not (entity and string.len(entity) > 0))
	end, false, nil, 'name')

	local inventory						= object:GetWidget('craftingInventory')

	local promptNewItemIcon				= object:GetWidget('craftingNewItemIcon')

	local buyEnchantBoostContainer		= object:GetWidget('craftingBuyEnchantBoost')
	local buyEnchantBoostCurrent		= object:GetWidget('craftingBuyEnchantBoostBoostCurrent')	-- Current boost count
	local buyEnchantBoostClose			= object:GetWidget('craftingBuyEnchantBoostClose')
	local buyEnchantBoostGemCount		= object:GetWidget('craftingBuyEnchantBoostGemCount')
	local buyEnchantBoostBuyGemsButton	= object:GetWidget('craftingBuyEnchantBoostBuyGemsButton')
	local errorContainer				= object:GetWidget('craftingError')
	local errorClose					= object:GetWidget('craftingErrorClose')
	local errorLabel					= object:GetWidget('craftingErrorLabel')
	local buyCraftBoostContainer		= object:GetWidget('craftingBuyCraftBoost')

	local buyCraftBoostCurrent			= object:GetWidget('craftingBuyCraftBoostBoostCurrent')	-- Current boost count
	local buyCraftBoostClose			= object:GetWidget('craftingBuyCraftBoostClose')
	local buyCraftBoostGemCount			= object:GetWidget('craftingBuyCraftBoostGemCount')
	local buyCraftBoostBuyGemsButton	= object:GetWidget('craftingBuyCraftBoostBuyGemsButton')

	-- ============

	local triggerCommodity	= LuaTrigger.GetTrigger('CraftingCommodityInfo')
	local filterTrigger		= LuaTrigger.GetTrigger('craftingCraftedItemFilter')

	local recipeList					= {}
	local componentList					= {}
	local craftedItemList				= {}
	local craftedItemListType			= 'attack'
	local craftableRecipeListType		= 'attack'

	local canCraftInfo = LuaTrigger.GetTrigger('craftingCraftInfo')
	local bonusInfoTrigger				= LuaTrigger.GetTrigger('craftingItemCreatedBonusInfo')
	local currentFilterTrigger	= LuaTrigger.GetTrigger('craftingCurrentCraftedItemFilter')
	currentFilterTrigger.filter	= 'power'

	local componentEffectPerType	= {
		power			= 'power',
		baseAttackSpeed	= 'baseAttackSpeed',
		hp				= 'maxHealth',
		mp				= 'maxMana',
		hpregen			= 'baseHealthRegen',
		mpregen			= 'baseManaRegen',

		power_comp			= 'power',
		attack_speed_comp	= 'baseAttackSpeed',
		health_comp			= 'maxHealth',
		mana_comp			= 'maxMana',
		health_regen_comp	= 'baseHealthRegen',
		mana_regen_comp		= 'baseManaRegen'
	}

	local itemEffectPerType	= {
		power		= 'power',
		baseAttackSpeed	= 'baseAttackSpeed',
		hp			= 'maxHealth',
		mp			= 'maxMana',
		hpregen		= 'baseHealthRegen',
		mpregen		= 'maxBaseManaRegen'
	}

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

	local componentByType	= {}
	local recipeByType		= {}
	local craftedItemByType	= {}

	local typeList		= { 'attack', 'ability', 'mana', 'defense', 'utility'}	-- Store categories
	local statFieldList	= { 'power', 'maxHealth', 'baseHealthRegen', 'maxMana', 'baseManaRegen', 'baseAttackSpeed' }	-- As returned from code
	local statNameList	= { 'power', 'health', 'healthRegen', 'mana', 'manaRegen', 'baseAttackSpeed' }	-- As seen in custom triggers

	enchantPullBar:SetCallback('onclick', function(widget)
		-- sound_enchantingEnchantItem
		-- PlaySound('/path_to_soundfile.wav')
		local itemInfo = LuaTrigger.GetTrigger('CraftedItems'..stageTrigger.enchantSelectedIndex)
		enchantLastNormalQuality = itemInfo.normalQuality
		enchantLastRareQuality = itemInfo.rareQuality
		enchantLastLegendaryQuality = itemInfo.legendaryQuality
		enchantLastIsRare = itemInfo.isRare
		enchantLastIsLegendary = itemInfo.isLegendary

		local craftedItemsTrigger		= LuaTrigger.GetTrigger('CraftedItems' .. stageTrigger.enchantSelectedIndex)	
		
		--Crafting.EnchantItemWithEssence(craftedItemsTrigger.id)
		Crafting.Save()
		mainUI.RefreshProducts()
		
		CraftingAnimationStatus.enchantAnimating = true
		CraftingAnimationStatus:Trigger(false)			
		
	end)

	enchantItemCostInfo:SetVisible(true)
	
	local queueRerollRefresh = false
	GetWidget('enchantRareRerollRare'):RegisterWatchLua('CraftingGroupStatus', function(widget, groupTrigger)
		local itemInfoTrigger			= LuaTrigger.GetTrigger('CraftedItems' .. stageTrigger.enchantSelectedIndex)
		local triggerSalvageStatus		= groupTrigger['GameClientRequestsSalvageCraftedItem']
		local triggerRerollStatus		= groupTrigger['GameClientRequestsRerollRareEffectOnCraftedItem']
		local isRare = (itemInfoTrigger and itemInfoTrigger.isRare) or false

		local notBusy		= (
			(not CraftingAnimationStatus.requestPending) and
			(not CraftingAnimationStatus.enchantAnimating) and
			(not CraftingAnimationStatus.rerollAnimating) and
			(not CraftingAnimationStatus.craftAnimating)
		)

		widget:SetEnabled(notBusy and isRare)
		local triggerCraftInfo	= LuaTrigger.GetTrigger('craftingCraftInfo')
		triggerCraftInfo.requestStatusRerollRare	= triggerSalvageStatus.status 
		triggerCraftInfo:Trigger(false)		
		if (triggerRerollStatus.status == 1) then
			queueRerollRefresh = true
		end
		if (triggerRerollStatus.status == 2) and (queueRerollRefresh) then
			Crafting.Save()
			mainUI.RefreshProducts()
			queueRerollRefresh = false
		end		
	end, false)	
	
	GetWidget('mainEnchantReroll_purchase_btn_1'):RegisterWatchLua('CraftingCommodityInfo', function(widget, trigger)
		local CraftingAccountInfo = LuaTrigger.GetTrigger('CraftingAccountInfo')
		local rerollRareEssenceCost = CraftingAccountInfo.rerollRareEssenceCost	
		widget:SetEnabled( trigger.essenceCount >= rerollRareEssenceCost )
	end, true, nil, 'essenceCount')
	
	GetWidget('mainEnchantReroll_purchase_btn_1'):SetCallback('onclick', function(widget)
		-- reroll rare bonus
		-- PlaySound('/path_to_soundfile.wav')		
		local CraftingAccountInfo = LuaTrigger.GetTrigger('CraftingAccountInfo')
		local rerollRareEssenceCost = CraftingAccountInfo.rerollRareEssenceCost	
		craftingUpdateStage(nil, 0)
		if LuaTrigger.GetTrigger('CraftingCommodityInfo').essenceCount >= rerollRareEssenceCost then
			local craftedItemsTrigger		= LuaTrigger.GetTrigger('CraftedItems' .. stageTrigger.enchantSelectedIndex)
			--Crafting.RerollRareEffectWithEssence(craftedItemsTrigger.id) 
		end		
	end)		
	
	GetWidget('mainEnchantReroll_purchase_btn_2'):SetCallback('onclick', function(widget)
		-- reroll rare bonus
		-- PlaySound('/path_to_soundfile.wav')		
		local CraftingAccountInfo = LuaTrigger.GetTrigger('CraftingAccountInfo')
		local rerollCostGem = CraftingAccountInfo.rerollRareGemCost
		craftingUpdateStage(nil, 0)
		if LuaTrigger.GetTrigger('GemOffer').gems >= rerollCostGem then
			local craftedItemsTrigger		= LuaTrigger.GetTrigger('CraftedItems' .. stageTrigger.enchantSelectedIndex)
			--Crafting.RerollRareEffectWithGems(craftedItemsTrigger.id) 
		else
			buyGemsShow()
		end		
	end)	
	
	GetWidget('enchantRareRerollRare'):SetCallback('onmouseover', function(widget)
		simpleTipGrowYUpdate(true, nil, Translate('enchanting_reroll_rare_short'), Translate('enchanting_reroll_rare_short_desc'), libGeneral.HtoP(38), 28)
	end)
	GetWidget('enchantRareRerollRare'):SetCallback('onmouseout', function(widget)
		simpleTipGrowYUpdate(false)
	end)		
	
	GetWidget('enchantRareRerollRare'):SetCallback('onclick', function(widget)
		-- reroll rare bonus
		-- PlaySound('/path_to_soundfile.wav')		
		local mainPanelStatus = LuaTrigger.GetTrigger('mainPanelStatus')
		craftingUpdateStage(nil, 4)
	end)	
	
	GetWidget('mainEnchantReroll_close_btn_1'):SetCallback('onclick', function(widget)
		-- back to enchanting
		-- PlaySound('/path_to_soundfile.wav')		
		local mainPanelStatus = LuaTrigger.GetTrigger('mainPanelStatus')
		craftingUpdateStage(nil, 0)
	end)	
	
	
	function craftingPromptSalvageUpdate(itemID)
		local itemInfo = LuaTrigger.GetTrigger('CraftedItems'..itemID)
		promptSalvageOreCost:SetText(itemInfo.oreCost)
		promptSalvageOreReturned:SetText(math.floor(itemInfo.oreCost /2))
		if (itemInfo) and (itemInfo.id) then
			stageTrigger.enchantSelectedIndex = itemID
			craftingUpdateStage(nil, 3)
		end
	end

	promptTemperClose:SetCallback('onclick', function(widget)
		-- sound_enchantingTemperClose
		-- PlaySound('/path_to_soundfile.wav')
		craftingUpdateStage(nil, 0)
	end)

	promptSalvageClose:SetCallback('onclick', function(widget)
		-- sound_enchantingSalvageClose
		-- PlaySound('/path_to_soundfile.wav')
		craftingUpdateStage(nil, 0)
	end)

	for i=1,3,1 do
		craftingRegisterNewItemComponent(object, i, newItemInfo)
	end
	
	craftingRegisterNewItemImbuement(object, 0, newItemInfo)

	craftOreCost:RegisterWatchLua('CraftingUnfinishedDesign', function(widget, trigger)
		widget:SetText(trigger.oreCost)
	end, false, nil, 'oreCost')
	
	local jublieCostThread
	JublieCost2:RegisterWatchLua('craftingCraftInfo', function(widget, trigger)
		local jublieCost = trigger.componentCost/style_crafting_costPerComponentPip		
		local saveCost = false
		if (jublieCostThread) then
			jublieCostThread:kill()
			jublieCostThread = nil
		else
			saveCost = true
		end		
		if (trigger.componentCost > trigger.minComponentCost) or (trigger.componentCost < trigger.minComponentCost) then
			jublieCostThread = libThread.threadFunc(function()
				if (jublieCost > lastJublieCost) then
					wait(1100)
					local valueAdd = jublieCost - lastJublieCost
					local lastValue = lastJublieCost
					local valueStart = lastJublieCost
					local animType = math.max(250, math.min(750, (jublieCost * 150)))
					libAnims.customTween(
						widget, animType,
						function(posPercent)

							local newValue = math.floor(valueStart + (valueAdd * posPercent))
							if newValue > lastValue then
								-- Purchase gem sound 
								-- PlaySound('/ui/sounds/rewards/sfx_tally_oneshot.wav')
								lastValue = newValue
							end
							widget:SetText('^r' .. newValue .. '^*/' .. trigger.minComponentCost/style_crafting_costPerComponentPip)
						end
					)	
				elseif (jublieCost < lastJublieCost) then
					wait(1100)
					local valueSubtract = lastJublieCost - jublieCost
					local lastValue = lastJublieCost
					local valueStart = lastJublieCost
					local animType = math.max(250, math.min(750, (valueSubtract * 150)))
					libAnims.customTween(
						widget, animType,
						function(posPercent)
							local newValue = math.floor(valueStart - (valueSubtract * posPercent))
							if newValue < lastValue then
								lastValue = newValue
							end
							widget:SetText('^r' .. newValue .. '^*/' .. trigger.minComponentCost/style_crafting_costPerComponentPip)
						end
					)		
				else
					widget:SetText('^r' .. jublieCost .. '^*/' .. trigger.minComponentCost/style_crafting_costPerComponentPip)
				end
				lastJublieCost = jublieCost		
				jublieCostThread = nil
			end)
			JublieCost:SetText('^r' .. jublieCost .. '^*/' .. trigger.minComponentCost/style_crafting_costPerComponentPip)		
		else
			widget:SetText('^*' .. jublieCost .. '^*/' .. trigger.minComponentCost/style_crafting_costPerComponentPip)
			if (saveCost) then
				lastJublieCost = jublieCost	
			end
			JublieCost:SetText('^*' .. jublieCost .. '^*/' .. trigger.minComponentCost/style_crafting_costPerComponentPip)		
		end
		JublieCostReq:SetText(trigger.minComponentCost/style_crafting_costPerComponentPip)
	end, false, nil, 'componentCost', 'minComponentCost')

	craftItemButton:RegisterWatchLua('CraftingGroupStatus', function(widget, groupTrigger)
		local trigger 					= groupTrigger['craftingCraftInfo']
		local oreCost					= trigger.oreCost
		local oreCount					= trigger.oreCount
		local entity					= trigger.entity
		local craftedItemCount			= groupTrigger['craftingStage'].craftedItemCount

		local notBusy		= (
			(not CraftingAnimationStatus.requestPending) and
			(not CraftingAnimationStatus.enchantAnimating) and
			(not CraftingAnimationStatus.rerollAnimating) and
			(not CraftingAnimationStatus.craftAnimating)
		)	
		
		if (not notBusy) then
			craftItemButton:SetEnabled(false)
			craftOreCostParent:SetVisible(1)
			JublieCostParent:SetVisible(0)				
		else
			if entity and string.len(entity) > 0 then
				if (trigger.componentCost < trigger.minComponentCost) or (trigger.componentCost > trigger.minComponentCost) then
					craftItemButton:SetEnabled(false)
					craftOreCostParent:SetVisible(0)
					JublieCostParent:SetVisible(1)					
				else
					craftOreCostParent:SetVisible(1)
					JublieCostParent:SetVisible(0)						
					local triggerNPE = LuaTrigger.GetTrigger('newPlayerExperience')
					if triggerNPE.tutorialComplete and triggerNPE.craftingIntroProgress == 0 and triggerNPE.craftingIntroStep == 5 then
						newPlayerExperienceCraftingStep(6)
					end
					craftItemButton:SetEnabled(craftedItemCount < mainUI.crafting.craftedItemSlots)
				end
			else
				craftItemButton:SetEnabled(false)
				craftOreCostParent:SetVisible(0)
				JublieCostParent:SetVisible(0)					
			end
		end

	end)

	promptNewItemIcon:RegisterWatchLua('CraftingUnfinishedDesign', function(widget, trigger)
		local entity = trigger.name
		if entity and string.len(entity) > 0 and ValidateEntity(entity) then
			widget:SetTexture(GetEntityIconPath(entity))
			widget:SetVisible(true)
		else
			widget:SetVisible(false)
			-- widget:SetTexture('/ui/shared/textures/pack2.tga')
		end

	end, false, nil, 'name')

	GetWidget('craftPanelSelectRecipeButton2_gold_cost'):RegisterWatchLua('CraftingUnfinishedDesign', function(widget, trigger)
		local entity = trigger.name
		if entity and string.len(entity) > 0 and ValidateEntity(entity) then
			widget:SetText(trigger.recipeCost)
		else
			widget:SetText('')
		end
	end, false, nil, 'name', 'recipeCost')	
	
	promptTemper:RegisterWatchLua('craftingStage', function(widget, trigger) libGeneral.fade(widget, (trigger.popup == 1), styles_shopTransitionTime) end, false, nil, 'popup')

	local function enchantingOpenSelectItem(widget)
		-- sound_enchantingOpenItemList
		PlaySound('/ui/sounds/crafting/sfx_book_open.wav')
		-- craftingUpdateStage(5, 0)
	
		local triggerNPE = LuaTrigger.GetTrigger('newPlayerExperience')
		if triggerNPE.tutorialComplete and triggerNPE.enchantingIntroProgress == 0 and triggerNPE.enchantingIntroStep == 1 then
			newPlayerExperienceEnchantingStep(2)
		end
		local mainPanelStatus = LuaTrigger.GetTrigger('mainPanelStatus')
		mainPanelStatus.main = 6
		mainPanelStatus:Trigger(false)		
	end
	
	enchantStationSwapButton:SetCallback('onclick', enchantingOpenSelectItem)
	enchantStationSwapButton2:SetCallback('onclick', enchantingOpenSelectItem)

	enchantStationSwapButton2:SetCallback('onmouseover', function(widget)
		craftingEnchantStationSwapButton2_hover_frame:FadeIn(250)
	end)
	
	enchantStationSwapButton2:SetCallback('onmouseout', function(widget)
		craftingEnchantStationSwapButton2_hover_frame:FadeOut(250)
	end)
	
	local function openChooseNewItemRecipe(widget)
		
		local itemInfo	= LuaTrigger.GetTrigger('CraftingUnfinishedDesign')

		if stageTrigger.stage == 7 then
			-- sound_craftingCloseRecipeSelection
			PlaySound('/ui/sounds/crafting/sfx_book_close.wav')
			if (itemInfo.name) and (not Empty(itemInfo.name)) then
				craftingUpdateStage(3)
			else
				craftingUpdateStage(1)
			end
		else
			-- sound_craftingOpenRecipeselection
			PlaySound('/ui/sounds/crafting/sfx_book_open.wav')
			craftingUpdateStage(7)

		end
	end
	
	GetWidget('crafting_open_inventory_btn'):SetCallback('onclick', enchantingOpenSelectItem)	
	GetWidget('crafting_open_inventory_btn'):SetCallback('onmouseover', function(widget)
		simpleTipGrowYUpdate(true, nil, Translate('inventory_title'), Translate('inventory_open_tip'), libGeneral.HtoP(38), 28)
	end)
	GetWidget('crafting_open_inventory_btn'):SetCallback('onmouseout', function(widget)
		simpleTipGrowYUpdate(false)
	end)

	GetWidget('enchanting_open_inventory_btn'):SetCallback('onclick', function(widget)
		local mainPanelStatus = LuaTrigger.GetTrigger('mainPanelStatus')
		mainPanelStatus.main = 6
		mainPanelStatus:Trigger(false)
	end)
	GetWidget('enchanting_open_inventory_btn'):SetCallback('onmouseover', function(widget)
		simpleTipGrowYUpdate(true, nil, Translate('crafting_swap_item'), Translate('inventory_open_fromenchant_tip'), libGeneral.HtoP(30), 28)
	end)
	GetWidget('enchanting_open_inventory_btn'):SetCallback('onmouseout', function(widget)
		simpleTipGrowYUpdate(false)
	end)
	
	promptNewItemChooseRecipeButton:RegisterWatchLua('CraftingGroupStatus', buttonDisableViaCraftActions)
	promptNewItemChooseRecipeButton2:RegisterWatchLua('CraftingGroupStatus', buttonDisableViaCraftActions)
	promptNewItemChooseRecipeButton3:RegisterWatchLua('CraftingGroupStatus', buttonDisableViaCraftActions)
	
	promptNewItemChooseRecipeButton:SetCallback('onclick', openChooseNewItemRecipe)
	promptNewItemChooseRecipeButton2:SetCallback('onclick', openChooseNewItemRecipe)
	promptNewItemChooseRecipeButton3:SetCallback('onclick', openChooseNewItemRecipe)
	
	promptNewItemChooseRecipeButton:SetCallback('onmouseover', function(widget)
		simpleTipGrowYUpdate(true, nil, Translate('crafting_selectrecipe'), Translate('crafting_selectrecipe_tip'), libGeneral.HtoP(38), 28)
	end)
	
	promptNewItemChooseRecipeButton:SetCallback('onmouseout', function(widget)
		simpleTipGrowYUpdate(false)
	end)
	
	promptNewItemChooseRecipeButton3:SetCallback('onmouseover', function(widget)
		simpleTipGrowYUpdate(true, nil, Translate('crafting_selectrecipe'), Translate('crafting_selectrecipe_tip'), libGeneral.HtoP(38), 28)
	end)
	
	promptNewItemChooseRecipeButton3:SetCallback('onmouseout', function(widget)
		simpleTipGrowYUpdate(false)
	end)	

	promptNewItemChooseRecipeButton2:SetCallback('onmouseover', function(widget)
		local itemInfo	= LuaTrigger.GetTrigger('CraftingUnfinishedDesign')
		local entity = itemInfo.name
		if entity and string.len(entity) > 0 then
			craftedItemTipPopulate(entity, true, nil, true, true, true)
			shopItemTipShow(1, 'craftedItemInfoShop')		
		end
	end)
	
	promptNewItemChooseRecipeButton2:SetCallback('onmouseout', function(widget)
		shopItemTipHide()
	end)

	promptNewItemChooseRecipeButton3:SetCallback('onmouseover', function(widget)
		local itemInfo	= LuaTrigger.GetTrigger('CraftingUnfinishedDesign')
		local entity = itemInfo.name
		if entity and string.len(entity) > 0 then
			craftedItemTipPopulate(entity, true, nil, true, true, true)
			shopItemTipShow(1, 'craftedItemInfoShop')		
		end
	end)
	
	promptNewItemChooseRecipeButton3:SetCallback('onmouseout', function(widget)
		shopItemTipHide()
	end)	
	
	promptNewItemChooseRecipeButton:RegisterWatchLua('CraftingUnfinishedDesign', function(widget, trigger)
		local itemInfo	= LuaTrigger.GetTrigger('CraftingUnfinishedDesign')
		local entity = itemInfo.name
		if entity and string.len(entity) > 0 and ValidateEntity(entity) then
			widget:SetVisible(0)
		else
			widget:SetVisible(1)
		end
	end, false, nil, 'name', 'recipeCost')		
	
	promptNewItemChooseRecipeButton3:RegisterWatchLua('craftingStageMainPanelTrigger', function(widget, trigger)
		local itemInfo	= LuaTrigger.GetTrigger('CraftingUnfinishedDesign')
		local mainPanelStatus	= LuaTrigger.GetTrigger('mainPanelStatus')
		local entity = itemInfo.name
		if entity and string.len(entity) > 0 and ValidateEntity(entity) and (mainPanelStatus.main == 1) then
			widget:SetVisible(1)
		else
			widget:SetVisible(0)
		end
	end, false, nil)	
	
	local enchantStationDurationLabel			= object:GetWidget('mainEnchantDurationLabel')
	local enchantStationDuration						= object:GetWidget('enchantStationDuration')
	local enchantStationDurationButtonContainer			= object:GetWidget('enchantStationTemperButtonContainer')

	enchantStationTemperButton:SetCallback('onclick', function(widget)
		-- sound_enchantingTemperItem
		-- PlaySound('/path_to_soundfile.wav')
		
		craftingUpdateStage(nil, 1)
		local stageTrigger		= LuaTrigger.GetTrigger('craftingStage')
		craftingPromptTemperUpdate(stageTrigger.enchantSelectedIndex)
		keeperPlayVO('temper')
	end)

	local enchantButtonStatusGroupTrigger
	local temperButtonStatusGroupTrigger
	
	enchantStationItemName:RegisterWatchLua('craftingStage', function(widget, trigger)
		local enchantSelectedIndex = trigger.enchantSelectedIndex
		if enchantStationLastIndex >= 0 then
			enchantStationItemName:UnregisterWatchLuaByKey('enchantStationWatch')
			enchantStationItemIcon:UnregisterWatchLuaByKey('enchantStationWatch')
			craftingEnchantStationSwapButton2_frame:UnregisterWatchLuaByKey('enchantStationWatch')
			craftingEnchantStationSwapButton2_hover_frame:UnregisterWatchLuaByKey('enchantStationWatch')
			enchantStationDurationLabel:UnregisterWatchLuaByKey('enchantStationWatch')

			enchantStationCostEssence:UnregisterWatchLuaByKey('enchantStationWatch')

			enchantDurationBar:UnregisterWatchLuaByKey('enchantStationWatch')

			enchantStationTemperButton:UnregisterWatchLuaByKey('enchantStationWatch')
			enchantPullBar:UnregisterWatchLuaByKey('enchantStationWatch')
			
			--[[
			for k,v in pairs(enchantStationBonus) do
				v.name:UnregisterWatchLuaByKey('enchantStationWatch')
				v.description:UnregisterWatchLuaByKey('enchantStationWatch')
				v.icon:UnregisterWatchLuaByKey('enchantStationWatch')
				v.locked:UnregisterWatchLuaByKey('enchantStationWatch')
				-- v.qualityBar:UnregisterWatchLuaByKey('enchantStationWatch')
			end
			--]]

			if enchantButtonStatusGroupTrigger then
				LuaTrigger.DestroyGroupTrigger(enchantButtonStatusGroupTrigger)
			end

			if temperButtonStatusGroupTrigger then
				LuaTrigger.DestroyGroupTrigger(temperButtonStatusGroupTrigger)
			end
		end

		if enchantSelectedIndex >= 0 then
			local itemTrigger	= LuaTrigger.GetTrigger('CraftedItems'..enchantSelectedIndex)
			
			temperButtonStatusGroupTrigger = LuaTrigger.CreateGroupTrigger('temperButtonStatus', {
				'CraftingAnimationStatus',
				'GameClientRequestsEnchantCraftedItem.status',
				'GameClientRequestsSalvageCraftedItem.status',
				'GameClientRequestsTemperCraftedItemWithEssence.status',
				'GameClientRequestsTemperCraftedItemWithGems.status',
				'GameClientRequestsRerollRareEffectOnCraftedItem.status',
				'CraftedItems'..enchantSelectedIndex..'.isTempered'
			})

			enchantStationTemperButton:RegisterWatchLua('temperButtonStatus', function(widget, groupTrigger)
				local triggerEnchantStatus		= groupTrigger['GameClientRequestsEnchantCraftedItem']
				local triggerTemperStatus		= groupTrigger['GameClientRequestsTemperCraftedItemWithEssence']
				local triggerTemperStatusGems	= groupTrigger['GameClientRequestsTemperCraftedItemWithGems']
				local triggerSalvageStatus		= groupTrigger['GameClientRequestsSalvageCraftedItem']
				local triggerItem				= groupTrigger['CraftedItems'..enchantSelectedIndex]
				local triggerRerollStatus		= groupTrigger['GameClientRequestsRerollRareEffectOnCraftedItem']

				widget:SetEnabled(
					not triggerItem.isTempered and
					(
						triggerEnchantStatus.status ~= 1 and
						triggerTemperStatus.status ~= 1 and
						triggerTemperStatusGems.status ~= 1 and
						triggerRerollStatus.status ~= 1 and
						triggerSalvageStatus.status ~= 1 and
						(not CraftingAnimationStatus.enchantAnimating) and
						(not CraftingAnimationStatus.rerollAnimating) and
						(not CraftingAnimationStatus.craftAnimating)						
					)
				)
			end, false, 'enchantStationWatch')

			enchantButtonStatusGroupTrigger = LuaTrigger.CreateGroupTrigger('enchantButtonStatus', {
				'CraftingAnimationStatus',
				'GameClientRequestsEnchantCraftedItem.status',
				'GameClientRequestsSalvageCraftedItem.status',
				'GameClientRequestsTemperCraftedItemWithEssence.status',
				'GameClientRequestsTemperCraftedItemWithGems.status',
				'GameClientRequestsRerollRareEffectOnCraftedItem.status',
				'CraftedItems'..enchantSelectedIndex..'.normalQuality',
				'CraftedItems'..enchantSelectedIndex..'.rareQuality',
				'CraftedItems'..enchantSelectedIndex..'.legendaryQuality',
				'CraftedItems'..enchantSelectedIndex..'.essenceEnchantCost',
				'CraftingCommodityInfo.essenceCount',
			})
			
			
			enchantItemCostInfo:SetVisible(true)
			
			enchantPullBar:RegisterWatchLua('enchantButtonStatus', function(widget, groupTrigger)
				local triggerEnchantStatus		= groupTrigger['GameClientRequestsEnchantCraftedItem']
				local triggerTemperStatus		= groupTrigger['GameClientRequestsTemperCraftedItemWithEssence']
				local triggerTemperStatusGems	= groupTrigger['GameClientRequestsTemperCraftedItemWithGems']
				local triggerSalvageStatus		= groupTrigger['GameClientRequestsSalvageCraftedItem']
				local triggerRerollStatus		= groupTrigger['GameClientRequestsRerollRareEffectOnCraftedItem']
				local triggerItem				= groupTrigger['CraftedItems'..enchantSelectedIndex]
				local triggerCommodities		= groupTrigger['CraftingCommodityInfo']
				local canAfford		= (triggerItem.essenceEnchantCost <= triggerCommodities.essenceCount)
				local canUpgrade	= (
					triggerItem.normalQuality < 1 or
					triggerItem.rareQuality < 1 or
					triggerItem.legendaryQuality < 1
				)
				local notBusy		= (
					triggerEnchantStatus.status ~= 1 and
					triggerTemperStatus.status ~= 1 and
					triggerTemperStatusGems.status ~= 1 and
					triggerRerollStatus.status ~= 1 and
					triggerSalvageStatus.status ~= 1 and 
					(not CraftingAnimationStatus.enchantAnimating) and
					(not CraftingAnimationStatus.rerollAnimating) and
					(not CraftingAnimationStatus.craftAnimating)
					
				)
				widget:SetEnabled(canUpgrade and canAfford and notBusy)
				enchantPullBarCostInfo:SetVisible(canUpgrade)
			end, false, 'enchantStationWatch')

			enchantDurationBar:RegisterWatchLua('CraftedItems'..enchantSelectedIndex, function(widget, trigger)
				if not trigger.isTempered then
				
				
					if trigger.monthsLeft >= 1 then
						widget:ScaleWidth(ToPercent(1), 250)
					else
						local secondsLeft = (
							(86400 * trigger.daysLeft) +	-- Seconds per day
							(3600 * trigger.hoursLeft) + 	-- Seconds per hour
							(60 * trigger.minutesLeft)		-- Derps per second
						)

						widget:ScaleWidth(ToPercent(math.min(secondsLeft / 1209600, 1)), 250)	-- rmm 14 Days hardcoded expiration time
					end
				end
			end, false, 'enchantStationWatch', 'isTempered', 'monthsLeft', 'daysLeft', 'hoursLeft', 'minutesLeft')

			
			--[[
			enchantStationItemName:RegisterWatchLua('CraftedItems'..enchantSelectedIndex, function(widget, trigger)
				local entityName		= trigger.name

				if string.len(entityName) > 0 then
					local isRare		= trigger.isRare
					local isLegendary	= trigger.isLegendary
					widget:SetColor(libGeneral.craftedItemGetNameColor(isRare, isLegendary))
					
					local rareBonus			= trigger.rareBonusName
					local legendaryBonus	= trigger.legendaryBonusName

					local fullItemName = libGeneral.craftedItemFormatName(GetEntityDisplayName(entityName), isRare, rareBonus, isLegendary, legendaryBonus)
					FitFontToLabel(widget, fullItemName)
					widget:SetText(fullItemName)
				end		
			end, false, 'enchantStationWatch', 'name', 'rareBonusName', 'legendaryBonusName', 'available', 'isRare', 'isLegendary')
			--]]

			enchantStationCostEssence:RegisterWatchLua('CraftedItems'..enchantSelectedIndex, function(widget, trigger)
				widget:SetText(trigger.essenceEnchantCost)
			end, false, 'enchantStationWatch', 'essenceEnchantCost')

			enchantStationItemIcon:RegisterWatchLua('CraftedItems'..enchantSelectedIndex, function(widget, trigger)
				local entityName = trigger.name
				if entityName and string.len(entityName) > 0 then
					widget:SetTexture(GetEntityIconPath(entityName))
				end
			end, false, 'enchantStationWatch', 'isRare', 'isLegendary')

			craftingEnchantStationSwapButton2_frame:RegisterWatchLua('CraftedItems'..enchantSelectedIndex, function(widget, trigger)
				if (trigger.isLegendary) then
					widget:SetTexture('/ui/main/inventory/textures/iconframe_legendary.tga')
				elseif (trigger.isRare) then
					widget:SetTexture('/ui/main/inventory/textures/iconframe_rare.tga')
				else
					widget:SetTexture('/ui/main/inventory/textures/iconframe_common.tga')
				end
			end, false, 'enchantStationWatch', 'isRare', 'isLegendary')

			craftingEnchantStationSwapButton2_hover_frame:RegisterWatchLua('CraftedItems'..enchantSelectedIndex, function(widget, trigger)
				if (trigger.isLegendary) then
					widget:SetTexture('/ui/main/inventory/textures/iconframe_legendary_hover.tga')
				elseif (trigger.isRare) then
					widget:SetTexture('/ui/main/inventory/textures/iconframe_rare_hover.tga')
				else
					widget:SetTexture('/ui/main/inventory/textures/iconframe_common_hover.tga')
				end
			end, false, 'enchantStationWatch', 'name')			
			
			enchantStationDurationLabel:RegisterWatchLua('CraftedItems'..enchantSelectedIndex, function(widget, trigger)
				if not trigger.isTempered then
					local monthsLeft	= trigger.monthsLeft
					local daysLeft		= trigger.daysLeft
					local hoursLeft		= trigger.hoursLeft
					local minutesLeft	= trigger.minutesLeft

					if monthsLeft and monthsLeft >= 1 then
						if (monthsLeft > 1) then
							widget:SetText(Translate('general_expires_in') .. ' ' .. Translate('general_months_amount', 'amount', math.floor(monthsLeft)) .. '!')
						else
							widget:SetText(Translate('general_expires_in') .. ' ' .. Translate('general_month_amount', 'amount', math.floor(monthsLeft)) .. '!')		
						end
					elseif daysLeft and daysLeft >= 1 then
						if (daysLeft > 1) then
							widget:SetText(Translate('general_expires_in') .. ' ' ..  Translate('general_days_amount', 'amount', math.floor(daysLeft)) .. '!')
						else
							widget:SetText(Translate('general_expires_in') .. ' ' ..  Translate('general_day_amount', 'amount', math.floor(daysLeft)) .. '!')
						end
					elseif hoursLeft and hoursLeft >= 1 then
						if (hoursLeft > 1) then
							widget:SetText(Translate('general_expires_in') .. ' ' ..  Translate('general_hours_amount', 'amount', math.floor(hoursLeft)) .. '!')
						else	
							widget:SetText(Translate('general_expires_in') .. ' ' ..  Translate('general_hour_amount', 'amount', math.floor(hoursLeft)) .. '!')
						end
					elseif minutesLeft and minutesLeft >= 1 then
						if (minutesLeft > 1) then
							widget:SetText(Translate('general_expires_in') .. ' ' ..  Translate('general_minutes_amount', 'amount', math.floor(minutesLeft)) .. '!')
						else
							widget:SetText(Translate('general_expires_in') .. ' ' ..  Translate('general_minute_amount', 'amount', math.floor(minutesLeft)) .. '!')
						end
					else
						widget:SetText(Translate('general_expires_now'))
					end

					widget:SetVisible(true)
					enchantStationDuration:SetVisible(false)
					enchantStationDurationButtonContainer:SetVisible(false)
				else
					widget:SetVisible(false)
					enchantStationDuration:SetVisible(false)
					enchantStationDurationButtonContainer:SetVisible(false)
				end
			end, false, 'enchantStationWatch', 'isTempered', 'daysLeft', 'hoursLeft', 'minutesLeft', 'monthsLeft')
			
			--[[
			for k,v in pairs(enchantStationBonus) do
				if k ~= 'Analog' then
					v.name:RegisterWatchLua('CraftedItems'..enchantSelectedIndex, function(widget, trigger)
						if trigger[itemBonusQualityParams[k].quality] > 0 then
							widget:SetText(trigger[itemBonusQualityParams[k].name])
						else
							widget:SetText('')
						end
					end, false, 'enchantStationWatch', itemBonusQualityParams[k].name, itemBonusQualityParams[k].quality)
					
					v.icon:RegisterWatchLua('CraftedItems'..enchantSelectedIndex, function(widget, trigger)
						if trigger[itemBonusQualityParams[k].quality] > 0 then
							widget:SetTexture(trigger[itemBonusQualityParams[k].icon])
						else
							widget:SetTexture(style_item_emptySlot)
						end
					end, false, 'enchantStationWatch', itemBonusQualityParams[k].icon, itemBonusQualityParams[k].quality)
					v.locked:RegisterWatchLua('CraftedItems'..enchantSelectedIndex, function(widget, trigger)
						local bonusExists = trigger[itemBonusQualityParams[k].exists]
						
						if bonusExists then
							v.backer:SetColor(1,1,1)
							v.backer:SetRenderMode('normal')
						else
							v.backer:SetColor(0.6, 0.6, 0.6)
							v.backer:SetRenderMode('grayscale')
						end
						widget:SetVisible(not bonusExists)
						v.iconContainer:SetVisible(bonusExists)
						-- v.lockedLabel:SetVisible(not bonusExists)
					end, false, 'enchantStationWatch', itemBonusQualityParams[k].exists)

					v.description:RegisterWatchLua('CraftedItems'..enchantSelectedIndex, function(widget, trigger)

						if trigger[itemBonusQualityParams[k].exists] then
							widget:SetText(StripColorCodes(trigger[itemBonusQualityParams[k].description]))
						else
							widget:SetText(Translate('crafting_bonus_'..k..'_description'))
						end
					
						
					end, false, 'enchantStationWatch', itemBonusQualityParams[k].description, itemBonusQualityParams[k].quality, itemBonusQualityParams[k].exists)

				else
					v.icon:SetTexture('/ui/main/enchanting/textures/common_bonus.tga')
					v.locked:SetVisible(false)
					v.description:RegisterWatchLua('CraftedItems'..enchantSelectedIndex, function(widget, trigger)
						widget:SetText(trigger[itemBonusQualityParams[k].description])
					end, false, 'enchantStationWatch', itemBonusQualityParams[k].description, itemBonusQualityParams[k].quality)

				end

			end
			--]]

			enchantItemCostSelectItem:SetVisible(false)
			
			enchantStationLastIndex = enchantSelectedIndex
			itemTrigger:Trigger(true)
		else	-- Clear enchanting station display
			enchantStationItemName:SetText(Translate('crafting_enchant_noitem'))
			enchantStationTemperButton:SetEnabled(false)
			enchantPullBar:SetEnabled(false)
			enchantItemCostInfo:SetVisible(false)
			enchantItemCostSelectItem:SetVisible(true)
			enchantStationItemIcon:SetTexture(style_item_emptySlot)

			--[[
			for k,v in pairs(enchantStationBonus) do
					v.name:SetText('')
					v.icon:SetTexture(style_item_emptySlot)
					v.locked:SetVisible(true)					
				if k ~= 'Analog' then
					

				end
				v.description:SetText('')
			end
			--]]
			
			enchantStationLastIndex = -1
		end
	end, false, nil, 'enchantSelectedIndex')

	promptSalvage:RegisterWatchLua('craftingStage', function(widget, trigger) libGeneral.fade(widget, (trigger.popup == 3), styles_shopTransitionTime) end, false, nil, 'popup')

	-- HUDMasteries:RegisterWatchLua('craftingStage', function(widget, trigger) libGeneral.fade(widget, (trigger.stage >= 2), styles_shopTransitionTime) end, false, nil, 'stage')

	local queueOpen						= false	-- Following RegisterEntityDefinitions, will open crafting

	function craftingUpdateStage(stage, popup, setQueueOpen)
		local stageTrigger		= LuaTrigger.GetTrigger('craftingStage')

		if setQueueOpen ~= nil then
			queueOpen = true
		end
		if stage ~= nil then
			stageTrigger.stage	= stage
		end

		if popup ~= nil then
			stageTrigger.popup	= popup
		end

		stageTrigger.craftClickedComponentSlotIndex = -1

		local clickedItemTrigger = LuaTrigger.GetTrigger('craftingClickedComponent')
		clickedItemTrigger.entity = ''
		clickedItemTrigger:Trigger(false)


		stageTrigger:Trigger(false)
	end

	function saveNewCraftedItem()
		Crafting.ClaimCraftedDesign()
		Crafting.Save()
		mainUI.RefreshProducts()
		if (mainUI) and  (mainUI.savedLocally) and  (mainUI.savedLocally.adaptiveTraining) and (mainUI.savedLocally.adaptiveTraining.featureList) and (mainUI.savedLocally.adaptiveTraining.featureList) then
			mainUI.AdaptiveTraining.RecordUtilisationInstanceByFeatureName('crafting')
		end
	end

	inventoryClose:SetCallback('onclick', function(widget)
		craftingUpdateStage(6)
		local triggerNPE = LuaTrigger.GetTrigger('newPlayerExperience')
		if triggerNPE.enchantingIntroProgress == 0 and triggerNPE.enchantingIntroStep == 2 then
			newPlayerExperienceEnchantingStep(1)
		end
	end)

	inventory:RegisterWatchLua('craftingStage', function(widget, trigger)
		libGeneral.fade(widget, (trigger.stage == 5), styles_shopTransitionTime)
	end, false, nil, 'stage')

	function craftingTestItemsPerCategory()
		for k,v in pairs(craftedItemByType) do
			for j,l in ipairs(v) do
				if type(l) == 'table' then
					for i,m in pairs(l) do
						print(k..' => '..j..' -> '..i..' - '..tostring(m)..'\n')
					end
				else
					print(k..' => '..j..' - '..tostring(l)..'\n')
				end
			end
		end
	end

	for k,v in pairs(selectableComponentTypeList) do
		for i=1,3,1 do
			if i <= 2 or (v ~= 'mana_regen_comp' and v ~= 'health_regen_comp' and v ~= 'attack_speed_comp') then
				craftingRegisterDraggableComponent(object, v, i)
			end
		end
	end
	
	for i=0,7,1 do
		craftingRegisterDraggableImbuement(object, i)
	end
	
	local crafting_prompt_purchase_craft_btn_ok_elixir 		= GetWidget('crafting_prompt_purchase_craft_btn_ok_elixir')
	local crafting_prompt_purchase_craft_btn_ok_gems 		= GetWidget('crafting_prompt_purchase_craft_btn_ok_gems')
	local crafting_prompt_purchase_craft 					= GetWidget('crafting_prompt_purchase_craft')
	
	craftItemButton:SetCallback('onclick', function(widget)
		crafting_prompt_purchase_craft:FadeIn(250)
	end)
	
	crafting_prompt_purchase_craft_btn_ok_elixir:RegisterWatchLua('craftingCraftInfo', function(widget, trigger)
		local craftingCommodityInfo = LuaTrigger.GetTrigger('CraftingCommodityInfo')
		local craftingCraftInfo = LuaTrigger.GetTrigger('craftingCraftInfo')
		widget:SetEnabled(craftingCommodityInfo.oreCount >= craftingCraftInfo.oreCost)
	end)
	crafting_prompt_purchase_craft_btn_ok_elixir:RegisterWatchLua('CraftingCommodityInfo', function(widget, trigger)
		local craftingCommodityInfo = LuaTrigger.GetTrigger('CraftingCommodityInfo')
		local craftingCraftInfo = LuaTrigger.GetTrigger('craftingCraftInfo')
		widget:SetEnabled(craftingCommodityInfo.oreCount >= craftingCraftInfo.oreCost)
	end)
	crafting_prompt_purchase_craft_btn_ok_elixir:SetCallback('onclick', function(widget)
		-- sound_craftingCraftItem
		PlaySound('/ui/sounds/crafting/sfx_item_craft.wav')
		Crafting.CraftDesign(false)
		CraftingAnimationStatus.craftAnimating = true
		CraftingAnimationStatus:Trigger(false)		
		crafting_prompt_purchase_craft:FadeOut(125)
	end)

	crafting_prompt_purchase_craft_btn_ok_gems:RegisterWatchLua('GemOffer', function(widget, groupTrigger)
		local gemOffer = LuaTrigger.GetTrigger('GemOffer')
		local craftingCraftInfo = LuaTrigger.GetTrigger('craftingCraftInfo')
		widget:SetEnabled(gemOffer.gems >= craftingCraftInfo.gemCost)
	end)	
	crafting_prompt_purchase_craft_btn_ok_gems:RegisterWatchLua('CraftingCommodityInfo', function(widget, groupTrigger)
		local gemOffer = LuaTrigger.GetTrigger('GemOffer')
		local craftingCraftInfo = LuaTrigger.GetTrigger('craftingCraftInfo')	
		widget:SetEnabled(gemOffer.gems >= craftingCraftInfo.gemCost)	
	end)		
	crafting_prompt_purchase_craft_btn_ok_gems:RegisterWatchLua('craftingCraftInfo', function(widget, groupTrigger)
		local gemOffer = LuaTrigger.GetTrigger('GemOffer')
		local craftingCraftInfo = LuaTrigger.GetTrigger('craftingCraftInfo')	
		widget:SetEnabled(gemOffer.gems >= craftingCraftInfo.gemCost)	
	end)		
	crafting_prompt_purchase_craft_btn_ok_gems:SetCallback('onclick', function(widget)
		-- sound_craftingCraftItem
		PlaySound('/ui/sounds/crafting/sfx_item_craft.wav')
		Crafting.CraftDesign(true)
		CraftingAnimationStatus.craftAnimating = true
		CraftingAnimationStatus:Trigger(false)		
		crafting_prompt_purchase_craft:FadeOut(125)
	end)	

	local alertThread
	local function newComponentAlert(color, show, hide)
		color = color or '1 .2 .2 .8'
		if (alertThread) then
			alertThread:kill()
			alertThread = nil
		end
		alertThread = libThread.threadFunc(function()	
			if (show) then
				for i=1,3,1 do
					GetWidget('craftingNewItemComponent' .. i .. '_alert_glow'):SetColor(color)
					GetWidget('craftingNewItemComponent' .. i .. '_alert_glow'):SetBorderColor(color)
					GetWidget('craftingNewItemComponent' .. i .. '_alert_glow'):FadeIn(500)
					GetWidget('craftingNewItemComponent' .. i .. '_dummyglows'):FadeOut(1)
				end
				wait(750)
			end
			if (hide) then
				for i=1,3,1 do
					GetWidget('craftingNewItemComponent' .. i .. '_alert_glow'):FadeOut(1)
					GetWidget('craftingNewItemComponent' .. i .. '_dummyglows'):FadeIn(500)
				end
			end
			alertThread = nil
		end)
	end
	
	craftItemButton:SetCallback('onmouseover', function(widget)
		simpleTipGrowYUpdate(true, nil, Translate('crafting_prompt_newitem_craft_tip'), Translate('crafting_prompt_newitem_craft_tip_body'), libGeneral.HtoP(38))
	end)

	craftItemButton:SetCallback('onmouseout', function(widget)
		simpleTipGrowYUpdate(false)
		newComponentAlert(nil, false, true)
	end)	
	
	craftItemButton:SetCallback('onmouseoverdisabled', function(widget)
		local unfinishedEntity 		= LuaTrigger.GetTrigger('CraftingUnfinishedDesign').name
		local craftingCraftInfo 	= LuaTrigger.GetTrigger('craftingCraftInfo')
		local craftedItemCount		= LuaTrigger.GetTrigger('craftingStage').craftedItemCount
		
		if (craftingCraftInfo.componentCost > craftingCraftInfo.minComponentCost) then
			simpleTipGrowYUpdate(true, nil, Translate('crafting_too_many_components'), Translate('crafting_too_many_components_desc', 'value', (craftingCraftInfo.componentCost - craftingCraftInfo.minComponentCost)/style_crafting_costPerComponentPip), libGeneral.HtoP(50))
			newComponentAlert(nil, true, false)
		elseif (craftingCraftInfo.componentCost < craftingCraftInfo.minComponentCost) then
			simpleTipGrowYUpdate(true, nil, Translate('crafting_insufficient'), Translate('crafting_insufficient_desc', 'value', (craftingCraftInfo.minComponentCost - craftingCraftInfo.componentCost)/style_crafting_costPerComponentPip), libGeneral.HtoP(50))			
			newComponentAlert(nil, true, false)
		elseif craftedItemCount >= mainUI.crafting.craftedItemSlots then
			simpleTipGrowYUpdate(true, nil, Translate('crafting_outofslots'), Translate('crafting_outofslots_tip'), libGeneral.HtoP(50))
		elseif unfinishedEntity and string.len(unfinishedEntity) == 0 then
			simpleTipGrowYUpdate(true, nil, Translate('crafting_prompt_newitem_craft_tip_needrecipe'), Translate('crafting_prompt_newitem_craft_tip_needrecipe_body'), libGeneral.HtoP(50))
		else
			simpleTipGrowYUpdate(true, nil, Translate('crafting_prompt_newitem_craft_tip_unknown'), Translate('crafting_prompt_newitem_craft_tip_unknown_body'), libGeneral.HtoP(50))		
		end
	end)
	
	craftItemButton:SetCallback('onmouseoutdisabled', function(widget)
		simpleTipGrowYUpdate(false)
		newComponentAlert(nil, false, true)
	end)

	function craftingTestCurrentItemList()
		local itemList	= craftedItemList

		for k,v in ipairs(itemList) do
			for j,l in pairs(v) do
				if type(l) == 'table' then
					for i,m in ipairs(l) do
						print(k..' => '..j..' -> '..i..' - '..tostring(m)..'\n')
					end
				else
					print(k..' => '..j..' - '..tostring(l)..'\n')
				end
			end
		end
	end

	local craftingInitialized = false

	local function craftingInitialize()
		if (not craftingInitialized) then
			Crafting.ClearDesign()
			Crafting.SetDesignEmpoweredEffect('')
			lastStage = nil
			
			local upgradValidItem	= -1
			local upgradValidItemUntempered	= -1
			local tempItemInfo		= nil
			recipeList		= Crafting.GetRecipes()
			componentList	= Crafting.GetComponents()
			local selectableComponentTrigger	= nil

			local shopCategories = nil

			for k,v in ipairs(selectableComponentTypeList) do
				componentByType[v]		= {}
			end

			for k,v in ipairs(typeList) do
				recipeByType[v]			= {}
			end

			for k,v in ipairs(componentList) do
				shopCategories	= Explode(',', v.shopCategories)
				for j,l in ipairs(shopCategories) do
					if componentByType[l] and type(componentByType[l]) == 'table' then
						table.insert(componentByType[l], v)
						if table.maxn(componentByType[l]) <= 3 and libGeneral.isInTable(selectableComponentTypeList, l) then
							selectableComponentTrigger					= LuaTrigger.GetTrigger( 'craftingSelectableComponent'..l..'Info'..table.maxn(componentByType[l]) )
							selectableComponentTrigger.icon				= v.icon
							selectableComponentTrigger.cost				= v.cost
							selectableComponentTrigger.value			= v[componentEffectPerType[l]]
							selectableComponentTrigger.craftingValue	= v.craftingValue
							selectableComponentTrigger.entity			= v.name
							selectableComponentTrigger.componentType	= l
							selectableComponentTrigger:Trigger(true)
						end
					end
				end
			end

			for k,v in ipairs(recipeList) do
				shopCategories	= Explode(',', v.shopCategories)
				for j,l in ipairs(shopCategories) do
					if recipeByType[l] and type(recipeByType[l]) == 'table' then
						table.insert(recipeByType[l], v)
					end
				end
			end

			for k,v in ipairs(selectableComponentTypeList) do
				table.sort(componentByType[v], function(a,b)
					return a.cost < b.cost
				end)
			end

			for k,v in ipairs(typeList) do
				table.sort(recipeByType[v], function(a,b)
					return a.craftingRecipeCost < b.craftingRecipeCost
				end)
			end

			for i=0,99,1 do	-- 59
				inventoryListbox:AddTemplateListItem('craftedItemEntry2', i, 'id', i)
				craftingRegisterCraftedItemEntry2(object, i, inventoryListbox, statFieldListLCS)
			end
		end

		if queueOpen then
			local stageTrigger		= LuaTrigger.GetTrigger('craftingStage')
			if stageTrigger.enchantSelectedIndex <= -1 then
				local mainPanelStatus = LuaTrigger.GetTrigger('mainPanelStatus')
				local mainPanelAnimationStatus = LuaTrigger.GetTrigger('mainPanelAnimationStatus')
				if mainUI.savedRemotely.lastSelectedEnchantingItem and mainUI.savedRemotely.lastSelectedEnchantingItem >= 0 and LuaTrigger.GetTrigger('CraftedItems'..mainUI.savedRemotely.lastSelectedEnchantingItem).available then
					craftingPromptEnchantUpdate(mainUI.savedRemotely.lastSelectedEnchantingItem)			
				end
			end
			queueOpen = false
		end

		LuaTrigger.GetTrigger('CraftingUnfinishedDesign'):Trigger(true)	-- Crafting.GetComponents() seems to not populate until EntityDefinitionsLoaded despite always loading entity definitions when the client is up.
	end	-- End initialize

	function craftingGetComponent(itemType, index)
		return componentByType[itemType][index]
	end

	function craftingGetComponentByName(entity)
		return componentList[entity]
	end

	function craftingGetRecipe(entity)
		return recipeList[entity]
	end

	function craftingAddComponentByName(entityName, slotIndex)
		craftingUpdateStage(nil, 0)
		Crafting.AddDesignComponent(entityName, slotIndex - 1)	-- Parses afterward
		craftingEvaluateNPEAddComponentProgress()
	end

	function craftingAddComponent(itemType, itemIndex)
		local designInfo	= LuaTrigger.GetTrigger('craftingCraftInfo')
		local itemInfo			= craftingGetComponent(itemType, itemIndex)
		craftingUpdateStage(nil, 0)
		Crafting.AddDesignComponent(itemInfo.Name, designInfo.selectedComponentIndex - 1)	-- Parses afterward
	end

	function testComponentBreakdown()	-- Global for external access to local vars, for testing
		for k,v in pairs(componentByType) do
			for j,l in pairs(v) do
				print(k..' => '..j..' - '..tostring(l)..'\n')
			end
		end
	end

	local promptTemperOKButton			= object:GetWidget('craftingTemperOKButton')

	promptTemperOKButton:SetCallback('onclick', function(widget)
		local stageTrigger		= LuaTrigger.GetTrigger('craftingStage')
		-- sound_enchantingTemperUseElixir
		PlaySound('/ui/sounds/sfx_button_generic.wav')
		if stageTrigger.enchantSelectedIndex > -1 then
			local craftedItemsTrigger		= LuaTrigger.GetTrigger('CraftedItems' .. stageTrigger.enchantSelectedIndex)
			--Crafting.TemperItemWithEssence(craftedItemsTrigger.id)
			Crafting.Save()
			mainUI.RefreshProducts()
		end
		craftingUpdateStage(nil, 0)
	end)

	local promptTemperOKButtonGems			= object:GetWidget('craftingTemperOKButtonGems')

	promptTemperOKButtonGems:SetCallback('onclick', function(widget)
		local stageTrigger		= LuaTrigger.GetTrigger('craftingStage')
		-- sound_enchantingTemperUseGems
		PlaySound('/ui/sounds/sfx_button_generic.wav')
		if stageTrigger.enchantSelectedIndex > -1 then
			local craftedItemsTrigger		= LuaTrigger.GetTrigger('CraftedItems' .. stageTrigger.enchantSelectedIndex)
			--Crafting.TemperItemWithGems(craftedItemsTrigger.id)
			Crafting.Save()
			mainUI.RefreshProducts()
		end
		craftingUpdateStage(nil, 0)
	end)

	function craftingPromptTemperUpdate(itemID)
		local itemInfo	= LuaTrigger.GetTrigger('CraftedItems'..itemID)
		local gemInfo	= LuaTrigger.GetTrigger('GemOffer')

		promptTemperCost:SetText(itemInfo.essenceTemperCost)
		promptTemperCostGems:SetText(itemInfo.gemTemperCost)

		promptTemperOKButtonGems:SetEnabled(gemInfo.gems >= itemInfo.gemTemperCost)
		promptTemperOKButton:SetEnabled(triggerCommodity.essenceCount >= itemInfo.essenceTemperCost)
	end

	function craftingPromptEnchantUpdate(itemID)
		local stageTrigger	= LuaTrigger.GetTrigger('craftingStage')
		mainUI.savedRemotely.lastSelectedEnchantingItem	= itemID
		stageTrigger.enchantSelectedIndex	= itemID
		stageTrigger:Trigger(false)
	end

	local promptSalvageOKButton			= object:GetWidget('craftingSalvageOKButton')

	promptSalvageOKButton:SetCallback('onclick', function(widget)
		-- sound_enchantingSalvageConfirm
		PlaySound('/ui/sounds/crafting/sfx_salvage.wav')
		if stageTrigger.enchantSelectedIndex > -1 then
			local craftedItemsTrigger		= LuaTrigger.GetTrigger('CraftedItems' .. stageTrigger.enchantSelectedIndex)
			Crafting.SalvageItem(craftedItemsTrigger.id)
			Crafting.Save()
			mainUI.RefreshProducts()
			keeperPlayVO('salvage')
		end
		craftingUpdateStage(nil, 0)
	end)

	--[[
	masteriesButtonGlow:RegisterWatchLua('PlayerCraftingMastery', function(widget, trigger) widget:SetVisible(trigger.unusedSkillPoints > 0) end, false, nil, 'unusedSkillPoints')

	masteriesButton:SetCallback('onclick', function(widget)
		PlaySound('/ui/sounds/sfx_button_generic.wav')
		craftingUpdateStage(nil,6)
	end)

	masteriesButton:SetCallback('onmouseover', function(widget)
		simpleTipGrowYUpdate(true, nil, Translate('crafting_hud_masteries'), Translate('crafting_hud_masteries_tip'))
	end)

	masteriesButton:SetCallback('onmouseout', function(widget)
		simpleTipGrowYUpdate(false)
	end)
	--]]

	--[[
	local buyCraftBoostOpenButton = object:GetWidget('craftingBuyCraftBoostOpenButton')

	buyCraftBoostOpenButton:SetCallback('onclick', function(widget)
		PlaySound('/ui/sounds/sfx_button_generic.wav')
		buyCraftBoostContainer:FadeIn(250)
	end)

	buyCraftBoostOpenButton:SetCallback('onmouseover', function(widget)
		simpleTipGrowYUpdate(true, nil, Translate('crafting_boost'), Translate('crafting_boost_craft_description'))
	end)

	buyCraftBoostOpenButton:SetCallback('onmouseout', function(widget)
		simpleTipGrowYUpdate(false)
	end)

	--]]

	--buyCraftBoostCurrent:RegisterWatchLua('CraftingCraftBoost', function(widget, trigger) widget:SetText(trigger.currentBoostAmount) end, false, nil, 'currentBoostAmount')
	buyCraftBoostGemCount:RegisterWatchLua('GemOffer', function(widget, trigger) widget:SetText(trigger.gems) end, false, nil, 'gems')
	buyCraftBoostClose:SetCallback('onclick', function(widget) buyCraftBoostContainer:FadeOut(250) end)

	buyCraftBoostBuyGemsButton:SetCallback('onclick', function(widget)
		PlaySound('/ui/sounds/sfx_button_generic.wav')
		buyGemsShow()
	end)

	for i=1,4,1 do
		craftingRegisterBoostCraftPackage(object, i)
	end

	--buyEnchantBoostCurrent:RegisterWatchLua('CraftingEnchantBoost', function(widget, trigger) widget:SetText(trigger.currentBoostAmount) end, false, nil, 'currentBoostAmount')
	buyEnchantBoostGemCount:RegisterWatchLua('GemOffer', function(widget, trigger) widget:SetText(trigger.gems) end, false, nil, 'gems')
	buyEnchantBoostClose:SetCallback('onclick', function(widget) buyEnchantBoostContainer:FadeOut(250) end)

	buyEnchantBoostBuyGemsButton:SetCallback('onclick', function(widget)
		PlaySound('/ui/sounds/sfx_button_generic.wav')
		buyGemsShow()
	end)

	for i=1,4,1 do
		craftingRegisterBoostEnchantPackage(object, i)
	end

	errorContainer:RegisterWatchLua('CraftingModalDialog', function(widget, trigger) widget:SetVisible(true) end)

	errorLabel:RegisterWatchLua('CraftingModalDialog', function(widget, trigger)
		local errorCode		= trigger.errorCode
		local errorValue	= trigger.extraValue

		if errorValue > 0 then
			widget:SetText(Translate('crafting_error'..errorCode, 'errvalue', errorValue))
		else
			widget:SetText(Translate('crafting_error'..errorCode))
		end
	end)

	errorClose:SetCallback('onclick', function(widget) errorContainer:FadeOut(250) end)

	object:GetWidget('craftingErrorOKButton'):SetCallback('onclick', function(widget)
		PlaySound('/ui/sounds/sfx_button_generic.wav')
		errorContainer:FadeOut(250)
	end)

	local wasCrafting	= false
	
	local pulseDuration = 1500
	local pulseThread = {}

	local craftingCraftInfo 					= LuaTrigger.GetTrigger('craftingCraftInfo')	
	
	local function doGlow(pulseThread, staticWidget, pulseWidget)				
		pulseThread[staticWidget:GetName()] = libThread.threadFunc(function()	
			if (staticWidget) and (staticWidget:IsValid()) then
				staticWidget:FadeIn(pulseDuration)
				
				local function pulse(staticWidget, pulseWidget)
					if ((pulseWidget) and (pulseWidget:IsValid())) then
						if (pulseWidget) and (pulseWidget:IsValid()) then
							pulseWidget:FadeIn(pulseDuration)							
						end	
						wait(pulseDuration)
						if (pulseWidget) and (pulseWidget:IsValid()) then
							pulseWidget:FadeOut(pulseDuration)
						end
						wait(pulseDuration)
						pulse(staticWidget, pulseWidget)
					end
				end
				
				pulse(staticWidget, pulseWidget)
				if (staticWidget) and (staticWidget:IsValid()) then
					pulseThread[staticWidget:GetName()] = nil
				end
			end
		end)		
	end
	
	local function GlowPulseComponent(staticWidget, pulseWidget, condition1, condition2, mainCondition)
		staticWidget:RegisterWatchLua('craftingStageMainPanelTrigger', function(widget, groupTrigger)
			local stage = groupTrigger.craftingStage.stage
			local main	= groupTrigger.mainPanelStatus.main
			local currentEmpoweredEffectEntityName	= groupTrigger.CraftingUnfinishedDesign.currentEmpoweredEffectEntityName
			
			if (pulseThread[staticWidget:GetName()]) then				
				pulseThread[staticWidget:GetName()]:kill()
				pulseThread[staticWidget:GetName()] = nil
			end		

			if (((stage == condition1) or (stage == condition2)) or (currentEmpoweredEffectEntityName and (not Empty(currentEmpoweredEffectEntityName)))) and (main == mainCondition) and (craftingCraftInfo.minComponentCost ~= craftingCraftInfo.componentCost) and (staticWidget) and (pulseWidget) and (staticWidget:IsValid()) and (pulseWidget:IsValid()) then
				doGlow(pulseThread, staticWidget, pulseWidget)	
			else
				staticWidget:FadeOut(1)
				pulseWidget:FadeOut(1)				
			end
		end)
	end
	for i=1,3,1 do
		GlowPulseComponent(GetWidget('craftingNewItemComponent'..i..'_dummyglow_1'), GetWidget('craftingNewItemComponent'..i..'_dummyglow_2'), 3, 3, 1)		
	end
	
	local function GlowPulse(staticWidget, pulseWidget, condition1, condition2, mainCondition)
		staticWidget:RegisterWatchLua('craftingStageMainPanelTrigger', function(widget, groupTrigger)
			local stage = groupTrigger.craftingStage.stage
			local main	= groupTrigger.mainPanelStatus.main
			
			if (pulseThread[staticWidget:GetName()]) then				
				pulseThread[staticWidget:GetName()]:kill()
				pulseThread[staticWidget:GetName()] = nil
			end		

			if ((stage == condition1) or (stage == condition2)) and (main == mainCondition) and (staticWidget) and (pulseWidget) and (staticWidget:IsValid()) and (pulseWidget:IsValid()) then
				doGlow(pulseThread, staticWidget, pulseWidget)
			else
				staticWidget:FadeOut(1)
				pulseWidget:FadeOut(1)				
			end
		end)
	end	
	GlowPulse(GetWidget('craftPanelSelectRecipeButton2_dummyglow_1'), GetWidget('craftPanelSelectRecipeButton2_dummyglow_2'), 0, 1, 1, true)
	GlowPulse(GetWidget('gameShopContainer_dummyglow_1'), GetWidget('gameShopContainer_dummyglow_2'), 7, 7, 1, true)		
	
	local function GlowPulseImbuement(staticWidget, pulseWidget, condition1, condition2, mainCondition)
		staticWidget:RegisterWatchLua('craftingStageMainPanelTrigger', function(widget, groupTrigger)
			local stage = groupTrigger.craftingStage.stage
			local main	= groupTrigger.mainPanelStatus.main
			local currentEmpoweredEffectEntityName	= groupTrigger.CraftingUnfinishedDesign.currentEmpoweredEffectEntityName

			if (pulseThread[staticWidget:GetName()]) then				
				pulseThread[staticWidget:GetName()]:kill()
				pulseThread[staticWidget:GetName()] = nil
			end		

			if (((stage == condition1) or (stage == condition2)) or (craftingCraftInfo.minComponentCost == craftingCraftInfo.componentCost)) and (main == mainCondition) and (currentEmpoweredEffectEntityName and (Empty(currentEmpoweredEffectEntityName))) and (staticWidget) and (pulseWidget) and (staticWidget:IsValid()) and (pulseWidget:IsValid()) then
				doGlow(pulseThread, staticWidget, pulseWidget)
			else
				staticWidget:FadeOut(1)
				pulseWidget:FadeOut(1)				
			end
		end)
	end	
	GlowPulseImbuement(GetWidget('craftingImbuement_slot_0_dummyglow_1'), GetWidget('craftingImbuement_slot_0_dummyglow_2'), 8, 8, 1, true)
	
	local function GlowPulseCraftButton(staticWidget, pulseWidget, condition1, condition2, mainCondition)
		staticWidget:RegisterWatchLua('craftingStageMainPanelTrigger', function(widget, groupTrigger)
			local stage = groupTrigger.craftingStage.stage
			local main	= groupTrigger.mainPanelStatus.main
			local currentEmpoweredEffectEntityName	= groupTrigger.CraftingUnfinishedDesign.currentEmpoweredEffectEntityName

			if (pulseThread[staticWidget:GetName()]) then				
				pulseThread[staticWidget:GetName()]:kill()
				pulseThread[staticWidget:GetName()] = nil
			end		

			if (craftingCraftInfo.minComponentCost == craftingCraftInfo.componentCost) and (main == mainCondition) and (currentEmpoweredEffectEntityName and (not Empty(currentEmpoweredEffectEntityName))) and (staticWidget) and (pulseWidget) and (staticWidget:IsValid()) and (pulseWidget:IsValid()) then
				doGlow(pulseThread, staticWidget, pulseWidget)
			else
				staticWidget:FadeOut(1)
				pulseWidget:FadeOut(1)				
			end
		end)
	end	
	GlowPulseCraftButton(GetWidget('craftItemButton_dummyglow_1'), GetWidget('craftItemButton_dummyglow_2'), 8, 8, 1, true)	
	
	GetWidget('crafting_interaction_block_0'):RegisterWatchLua('craftingStage', function(widget, trigger)
		if (trigger.stage == 1) or (trigger.stage == 0) or (trigger.stage == 7) then
			widget:SlideX('320s', styles_shopTransitionTime, true)
		else
			widget:SlideX('0s', styles_shopTransitionTime, true)
		end
	end, false, nil, 'stage')	
	
	GetWidget('crafting_interaction_block_1'):RegisterWatchLua('craftingStage', function(widget, trigger)
		if (trigger.stage == 3) or (trigger.stage == 8) then
			widget:SlideX('0s', styles_shopTransitionTime, true)
			widget:FadeIn(styles_shopTransitionTime)
		else
			widget:SlideX('320s', styles_shopTransitionTime, true)
			widget:FadeOut(styles_shopTransitionTime)
		end
	end, false, nil, 'stage')
	
	GetWidget('crafting_interaction_block_2'):RegisterWatchLua('craftingStage', function(widget, trigger)
		if (trigger.stage == 3) then
			widget:FadeIn(styles_shopTransitionTime)
		else
			widget:FadeOut(styles_shopTransitionTime)
		end
	end, false, nil, 'stage')	
	
	GetWidget('crafting_interaction_block_3'):RegisterWatchLua('craftingStage', function(widget, trigger)
		if (trigger.stage == 3) or (trigger.stage == 8) then
			widget:FadeIn(styles_shopTransitionTime)
		else
			widget:FadeOut(styles_shopTransitionTime)
		end
	end, false, nil, 'stage')	
	
	GetWidget('crafting_interaction_block_5'):RegisterWatchLua('craftingStage', function(widget, trigger)
		if (trigger.stage == 3) or (trigger.stage == 8) or (trigger.stage == 1)  or (trigger.stage == 0) then
			widget:FadeIn(styles_shopTransitionTime)
		else
			widget:FadeOut(styles_shopTransitionTime)
		end
	end, false, nil, 'stage')		
	
	GetWidget('crafting_interaction_block_4'):RegisterWatchLua('craftingStage', function(widget, trigger)
		if (trigger.stage == 8) then
			widget:FadeIn(styles_shopTransitionTime)
		else
			widget:FadeOut(styles_shopTransitionTime)
		end
		if (trigger.stage > 1) then
			lastStage = trigger.stage
		end
	end, false, nil, 'stage')		
	
	GetWidget('crafting_interaction_block_6'):RegisterWatchLua('craftingStage', function(widget, trigger)
		if (trigger.stage == 3) or (trigger.stage == 8) then
			widget:FadeIn(styles_shopTransitionTime)
		else
			widget:FadeOut(styles_shopTransitionTime)
		end
	end, false, nil, 'stage')		
	
	GetWidget('crafting_interaction_block_6_label_2'):RegisterWatchLua('craftingStage', function(widget, trigger)
		if (trigger.stage == 3) then
			widget:SetColor('1 1 1 1')
		else
			widget:SetColor('.5 .5 .5 1')
		end
	end, false, nil, 'stage')

	GetWidget('crafting_interaction_block_6_label_3'):RegisterWatchLua('craftingStage', function(widget, trigger)
		if (trigger.stage == 8) then
			widget:SetColor('1 1 1 1')
		else
			widget:SetColor('.5 .5 .5 1')
		end
	end, false, nil, 'stage')	
	
	GetWidget('crafting_interaction_block_6_label_4'):RegisterWatchLua('craftingStage', function(widget, trigger)
		if (trigger.stage == 8) then
			widget:SetColor('1 1 1 1')
		else
			widget:SetColor('.5 .5 .5 1')
		end
	end, false, nil, 'stage')	
	
	container:RegisterWatchLua('mainPanelAnimationStatus', function(widget, trigger)
		local newMain	= trigger.newMain
		local main		= trigger.main
		
		local animState = mainSectionAnimState(1, trigger.main, trigger.newMain)

		if animState == 1 then
			if container:IsVisible() and wasCrafting and (newMain ~= 5) then
				keeperPlayVO('exit')
			end			
			libThread.threadFunc(function()	
				groupfcall('crafting_animation_widgets', function(_, widget)  widget:DoEventN(8) end)			
			end)
			craftingUpdateStage(0)
		elseif animState == 2 then
			widget:SetVisible(false)
			wasCrafting = false
			craftingUpdateStage(0)
		elseif animState == 3 then
			craftingUpdateStage(1, nil)	-- , true
			craftingInitialize()
			craftingInitialized = true
			wasCrafting			= true			
			libThread.threadFunc(function()	
				wait(10)
				PlaySound('/ui/sounds/sfx_transition_2.wav')
				groupfcall('crafting_animation_widgets', function(_, widget) RegisterRadialEase(widget) widget:DoEventN(7) end)			
			end)
		elseif animState == 4 then
			keeperPlayVO('enter')
			widget:SetVisible(true)		
			if (lastStage) then
				libThread.threadFunc(function()	
					wait(300)			
					craftingUpdateStage(lastStage, nil)
				end)
			end
			if (mainUI) and  (mainUI.savedLocally) and  (mainUI.savedLocally.adaptiveTraining) and (mainUI.savedLocally.adaptiveTraining.featureList) and (mainUI.savedLocally.adaptiveTraining.featureList) then
				mainUI.AdaptiveTraining.RecordViewInstanceByFeatureName('crafting')
			end
		end
	end, false, nil, 'main', 'newMain')	
	
	canCraftInfo.componentCost			= 0
	canCraftInfo.minComponentCost		= 0
	canCraftInfo.oreCount				= 0
	canCraftInfo.oreCost				= 0
	canCraftInfo.entity					= ''
	canCraftInfo.selectedComponentIndex	= 0

	stageTrigger.stage							= 0	-- Not Open
	stageTrigger.popup							= 0
	stageTrigger.enchantSelectedIndex			= -1	-- None selected
	stageTrigger.craftClickedComponentSlotIndex	= -1	-- None selected
	stageTrigger.craftedItemsFilter				= ''
	stageTrigger.craftedItemCount				= 0
	stageTrigger:Trigger(true)

	triggerClickedComponent.entity	= ''
	triggerClickedComponent:Trigger(true)

	filterTrigger.filter = 'power'
	filterTrigger:Trigger(true)


	FindChildrenClickCallbacks(container)
end	-- end craftingRegister

craftingRegister(object)