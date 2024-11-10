
local GetTrigger = LuaTrigger.GetTrigger

ShopUI = ShopUI or {}
ShopUI.itemGuidance = {}
ShopUI.itemGuidance.guideFullItemTable = nil
ShopUI.itemGuidance.targetItemTable = nil

local itemGuidanceTrigger = LuaTrigger.GetTrigger('itemGuidanceTrigger')

local function ItemGuidanceRegister(object)

	local parent 		= object:GetWidget('game_item_guidance_parent')
	local bump 			= object:GetWidget('game_item_guidance_parent_bump')
	local icon 			= object:GetWidget('game_item_guidance_item_icon_0')
	local label			= object:GetWidget('game_item_guidance_item_label_0')
	local label1		= object:GetWidget('game_item_guidance_item_label_1')
	local item 			= object:GetWidget('game_item_guidance_item_0')

	local itemTrigger 	= LuaTrigger.GetTrigger('BookmarkQueue0')

	local min = math.min
	local max = math.max

	local System = GetTrigger('System')
	local nextGoldUpdate, nextPromptAvailable, delay = 0, 0, 0
	local heroGoldContainer_effect  = object:GetWidget('gameHeroGoldContainer_effect')
	
	local itemGuidanceSlideThread
	item:RegisterWatchLua('itemGuidanceTrigger', function(widget, trigger)
		if (itemGuidanceSlideThread) then
			itemGuidanceSlideThread:kill()
			itemGuidanceSlideThread = nil
		end
		local swapSides = 1
	
		if mainUI.minimapFlipped or GetCvarBool('ui_swapMinimap') then
			swapSides = -1
		end
		
		if trigger.visible then
			item:SetNoClick(0)
			item:SetVisible(1)
			item:SlideX(-0.5*swapSides ..'h', 250, false)
			itemGuidanceSlideThread = libThread.threadFunc(function()
				wait(250)
				item:SetX(-0.5*swapSides .. 'h')
				itemGuidanceSlideThread = nil
			end)			
		else
			item:SetNoClick(1)
			item:SlideX(100*swapSides .. '%', 250, false, function() item:SetVisible(0) end)
			itemGuidanceSlideThread = libThread.threadFunc(function()
				wait(250)
				item:SetX(100*swapSides .. '%')
				item:SetVisible(0) 
				itemGuidanceSlideThread = nil
			end)				
		end
	end, false, nil, 'visible')
	
	local function Close()
		itemGuidanceTrigger.visible = false
		itemGuidanceTrigger:Trigger(false)
	end
	Close()
	local function Open(delayClose)
		-- vis stuff
		itemGuidanceTrigger.visible = true
		itemGuidanceTrigger:Trigger(false)
		if (delayClose) then
			item:Sleep(5500, function()
				Close()
			end)
			item:SetCallback('onhide', function()
				item:Sleep(1, function() end)
			end)
		end
	end
	
	local function updateSide()
		if parent and parent:IsValid() then
			if GetCvarBool('ui_swapMinimap') then
				parent:SetAlign('left')
				item:SetAlign('left')
			else
				parent:SetAlign('right')
				item:SetAlign('right')
			end
			Close()
		end
	end
	updateSide()
	UnwatchLuaTriggerByKey('optionsTrigger', 'optionsTriggerSwapMinimapGuidance')
	WatchLuaTrigger('optionsTrigger', function()
		updateSide()
	end, 'optionsTriggerSwapMinimapGuidance')

	local gamePanelInfoFunction = function(widget, trigger)
		if (trigger.moreInfoKey) then
			Open()
		else
			Close()
		end
	end

	local function ActivatePrompt()
		if ((System.hostTime - nextPromptAvailable) > 0) then
			if (not item:IsVisible()) then
				Open(true)
				nextPromptAvailable = (System.hostTime + 40000) -- rmm
			else
				nextPromptAvailable = (System.hostTime + 6000)
			end
		end
	end

	local function DisablePrompt()
		nextPromptAvailable = (System.hostTime + 600)
	end

	parent:RegisterWatchLua('gamePanelInfo', function(widget, trigger)
		widget:SetVisible(not trigger.gameMenuExpanded and not trigger.goldSplashVisible)
	end, false, nil, 'gameMenuExpanded', 'goldSplashVisible')
	parent:SetVisible(1)

	bump:RegisterWatchLua('HeroUnit', function(widget, trigger)
		if (trigger.availablePoints > 0) then
			widget:SlideY('-7h', 125)
		else
			widget:SlideY('0', 125)
		end
	end, false, nil, 'availablePoints')

	parent:RegisterWatchLua('PlayerGold', function(widget, trigger)
		if ((System.hostTime - nextGoldUpdate) > 0) then
			if (trigger.gold > itemGuidanceTrigger.cost) then
				delay = min(60000, max(5000, (60000 - ((trigger.gold - itemGuidanceTrigger.cost) * 13.75) )))
				nextGoldUpdate = (System.hostTime + delay)
				heroGoldContainer_effect:SetVisible(1)
				heroGoldContainer_effect:FadeOut(4800)
			else
				nextGoldUpdate = (System.hostTime + 5000)
			end
		end
	end, false, nil, 'gold')

	heroGoldContainer_effect:RegisterWatchLua('ItemPurchased', function(widget, trigger)
		DisablePrompt()
		delay = 60000
		nextGoldUpdate = (System.hostTime + delay)
		nextPromptAvailable = (System.hostTime + 600)
		Close()
	end, false, nil, 'entity')

	heroGoldContainer_effect:RegisterWatchLua('ItemSold', function(widget, trigger)
		DisablePrompt()
		nextPromptAvailable = (System.hostTime + 600)
		Close()
	end, false, nil, 'entity')

	local function isValidComponentID(componentID)	-- This can be used elsewhere
		return (componentID and type(componentID) == 'number' and componentID >= 0 and componentID <= 3)
	end
	
	local function getPurchasableComponentInfo(itemInfo, componentID)	-- ShopItem style
		if itemInfo then
			if itemInfo.isRecipe then
				local itemPrefix = ''
				local costParam	= 'cost'
				if componentID then
					if isValidComponentID(componentID) then
						itemPrefix = 'recipeComponentDetail'..componentID
					else
						return false
					end
				else	-- Recipe scroll/item itself
					costParam = 'recipeScrollCost'
				end
				return {
					exists	= itemInfo[itemPrefix..'exists'],
					cost	= itemInfo[itemPrefix..costParam],
					isOwned	= itemInfo[itemPrefix..'isOwned']
				}
			else	-- return just item info
				return {
					exists	= itemInfo.exists,
					cost	= itemInfo.cost,
					isOwned	= itemInfo.isOwned
				}
			end
		else
			return false
		end
	end
	
	
	local function getNextPurchasableComponent(itemInfo)	-- ShopItem style
		if itemInfo.exists then
			local componentInfo	-- can be nil or recipe scroll
			if itemInfo.isRecipe then
				for i=0,3,1 do
					componentInfo = getPurchasableComponentInfo(itemInfo, i)
					if componentInfo and componentInfo.exists and (not componentInfo.isOwned) then
						return componentInfo
					end
				end
			end
			
			componentInfo = getPurchasableComponentInfo(itemInfo)
			if componentInfo and componentInfo.exists and (not componentInfo.isOwned) then
				return componentInfo
			end
		end

		return nil
	end
	
	object:GetWidget('game_item_guidance_item_0'):RegisterWatch('gamePurchaseCurrentValidBookmark', function(widget, keyDown)
		if AtoB(keyDown) then
			local playerGold		= LuaTrigger.GetTrigger('PlayerGold')
			local itemInfo			= LuaTrigger.GetTrigger('BookmarkQueue0')
			local nextPurchasableItem = getNextPurchasableComponent(itemInfo)
			
			if nextPurchasableItem and playerGold.gold >= nextPurchasableItem.cost then
				gameShopSetLastPurchaseSourceWidget(widget)

				Close()
				if itemInfo.isRecipe then
					Shop.PurchaseRemainingComponents(itemInfo.entity)
				else
					Shop.PurchaseByName(itemInfo.entity)
				end
			end
		end
	end)

	local function RegisterItem(itemEntity, isRecipe, searchEntity)
		icon:SetTexture(GetEntityIconPath(itemEntity))
		label:SetText(GetEntityDisplayName(itemEntity))
		item:UnregisterWatchLua('gamePanelInfo')
		item:RegisterWatchLua('gamePanelInfo', gamePanelInfoFunction, false, nil, 'moreInfoKey')

		item:SetCallback('onclick', function(widget)

			Close()

			if itemEntity and searchEntity then

				trigger_gamePanelInfo.selectedShopItemType = ''
				trigger_gamePanelInfo:Trigger(false)

				ShopUI.ClearFilters()

				if isRecipe then

					if trigger_gamePanelInfo.selectedShopItem == 0 then
						widget:Sleep(1, function()
							gameShopUpdateRowDataSelectedID(object)
						end)
					else
						trigger_gamePanelInfo.selectedShopItem = 0
					end

					object:GetWidget('game_shop_search_input'):SetInputLine(GetEntityDisplayName(searchEntity))
					trigger_shopFilter.shopCategory	= ''
				else

					trigger_gamePanelInfo.selectedShopItem = -1

					if compNameToFilterName[itemEntity][1] then
						object:GetWidget('game_shop_search_input'):EraseInputLine()
						trigger_shopFilter.shopCategory	= 'components'
						trigger_shopFilter[compNameToFilterName[itemEntity][1]] = true
					else
						trigger_shopFilter.shopCategory	= ''
						object:GetWidget('game_shop_search_input'):SetInputLine(GetEntityDisplayName(searchEntity))
					end

				end

				trigger_gamePanelInfo:Trigger(false)
				trigger_shopFilter:Trigger(false)

				if (not trigger_gamePanelInfo.shopOpen) then
					widget:UICmd("ToggleShop()")
				end
			end
		end)

		item:SetCallback('onrightclick', function(widget)
			Close()

			if (itemEntity) then

				gameShopSetLastPurchaseSourceWidget(widget)

				if isRecipe then
					Shop.PurchaseRemainingComponents(itemEntity)
				else
					Shop.PurchaseByName(itemEntity)
				end

			end
		end)

		item:RefreshCallbacks()
	end

	local itemGuidanceInfoTrigger = LuaTrigger.GetTrigger('itemGuidanceInfoTrigger') or LuaTrigger.CreateGroupTrigger('itemGuidanceInfoTrigger', { 'BookmarkQueue0', 'PlayerGold'})

	local lastEntity = nil
	parent:RegisterWatchLua('itemGuidanceInfoTrigger', function(widget, groupTrigger)

		local trigger		 = 	groupTrigger['BookmarkQueue0']
		local PlayerGold 	 = 	groupTrigger['PlayerGold']

		if (trigger.exists) then

			if (trigger.entity ~= lastEntity) then
				nextPromptAvailable = (System.hostTime + 600)
			end
			lastEntity = trigger.entity

			local cost = 0	-- cost of first unowned item component
			itemGuidanceTrigger.cost = 99999

			if (trigger.exists) then

				if (not trigger.isRecipe) then	-- non Recipes are just their base price
					cost = trigger.cost
				else 							-- take cost of first unowned
					for i=0,3 do
						if trigger['recipeComponentDetail'..i..'exists'] and (not trigger['recipeComponentDetail'..i..'isOwned']) then
							cost = cost + trigger['recipeComponentDetail'..i..'cost']
							break
						end
					end
					if (cost == 0) then
						cost = cost + trigger.recipeScrollCost
					end
				end

				itemGuidanceTrigger.cost = min(itemGuidanceTrigger.cost, cost)

				if trigger.exists and (not trigger.isOwned) and trigger.cost <= PlayerGold.gold then
					RegisterItem(trigger.entity, trigger.isRecipe, trigger.entity)
					ActivatePrompt()
				elseif trigger.exists and (not trigger.isOwned) and trigger.isRecipe and trigger.recipeScrollCost <= PlayerGold.gold and ((not trigger.recipeComponentDetail0exists) or trigger.recipeComponentDetail0isOwned) and ((not trigger.recipeComponentDetail1exists) or trigger.recipeComponentDetail1isOwned) and ((not trigger.recipeComponentDetail2exists) or trigger.recipeComponentDetail2isOwned) and ((not trigger.recipeComponentDetail3exists) or trigger.recipeComponentDetail3isOwned)  then
					RegisterItem(trigger.entity, trigger.isRecipe, trigger.entity)
					ActivatePrompt()
				elseif (trigger.exists) and (not trigger.isOwned) and (trigger.recipeComponentDetail0exists) and (not trigger.recipeComponentDetail0isOwned) and (trigger.recipeComponentDetail0cost <= PlayerGold.gold) then
					RegisterItem(trigger.recipeComponentDetail0entity, trigger.isRecipe, trigger.entity)
					ActivatePrompt()
				elseif (trigger.exists) and (not trigger.isOwned) and (trigger.recipeComponentDetail1exists) and (not trigger.recipeComponentDetail1isOwned) and (trigger.recipeComponentDetail1cost <= PlayerGold.gold) and ((not trigger.recipeComponentDetail0exists) or (trigger.recipeComponentDetail0isOwned)) then
					RegisterItem(trigger.recipeComponentDetail1entity, trigger.isRecipe, trigger.entity)
					ActivatePrompt()
				elseif (trigger.exists) and (not trigger.isOwned) and (trigger.recipeComponentDetail2exists) and (not trigger.recipeComponentDetail2isOwned) and (trigger.recipeComponentDetail2cost <= PlayerGold.gold) and ((not trigger.recipeComponentDetail0exists) or (trigger.recipeComponentDetail0isOwned)) and ((not trigger.recipeComponentDetail1exists) or (trigger.recipeComponentDetail1isOwned)) then
					RegisterItem(trigger.recipeComponentDetail2entity, trigger.isRecipe, trigger.entity)
					ActivatePrompt()
				elseif (trigger.exists) and (not trigger.isOwned) and (trigger.recipeComponentDetail3exists) and (not trigger.recipeComponentDetail3isOwned) and (trigger.recipeComponentDetail3cost <= PlayerGold.gold) and ((not trigger.recipeComponentDetail0exists) or (trigger.recipeComponentDetail0isOwned)) and ((not trigger.recipeComponentDetail1exists) or (trigger.recipeComponentDetail1isOwned)) and ((not trigger.recipeComponentDetail2exists) or (trigger.recipeComponentDetail2isOwned)) then
					RegisterItem(trigger.recipeComponentDetail3entity, trigger.isRecipe, trigger.entity)
					ActivatePrompt()
				elseif (trigger.exists) and (trigger.isRecipe) and (not trigger.isOwned) and (trigger.recipeScrollCost > PlayerGold.gold) and ((not trigger.recipeComponentDetail3exists) or (trigger.recipeComponentDetail3isOwned)) and ((not trigger.recipeComponentDetail0exists) or (trigger.recipeComponentDetail0isOwned))  and ((not trigger.recipeComponentDetail1exists) or (trigger.recipeComponentDetail1isOwned)) and ((not trigger.recipeComponentDetail2exists) or (trigger.recipeComponentDetail2isOwned)) then
					-- waiting on recipe, do nothing
					itemGuidanceTrigger.cost = trigger.recipeScrollCost
					itemGuidanceTrigger:Trigger(false)
					Close()
					item:UnregisterWatchLua('gamePanelInfo')
					DisablePrompt()
				else
					itemGuidanceTrigger.cost = 1215
					itemGuidanceTrigger:Trigger(false)
					Close()
					item:UnregisterWatchLua('gamePanelInfo')
					DisablePrompt()
				end

			end

			if (itemGuidanceTrigger.cost == 99999) then
				itemGuidanceTrigger.cost = 1215
			end

			itemGuidanceTrigger:Trigger(false)

		else
			itemGuidanceTrigger.cost = 1215
			itemGuidanceTrigger:Trigger(false)
			Close()
			item:UnregisterWatchLua('gamePanelInfo')
			DisablePrompt()
		end

	end)

end

ItemGuidanceRegister(object)



