function heroInventoryRegisterStash(object, abilID)
	local icon					= object:GetWidget('gameInventory'..abilID..'Icon')
	local iconContainer			= object:GetWidget('gameInventory'..abilID..'IconContainer')
	local cooldownPie			= object:GetWidget('gameInventory'..abilID..'CooldownPie')
	local cooldown				= object:GetWidget('gameInventory'..abilID..'Cooldown')
	local button				= object:GetWidget('gameInventory'..abilID..'Button')
	local drop					= object:GetWidget('gameInventory'..abilID..'Drop')
	local chargeShadow			= object:GetWidget('gameInventory'..abilID..'ChargeShadow')
	local chargeBacker			= object:GetWidget('gameInventory'..abilID..'ChargeBacker')
	local charges				= object:GetWidget('gameInventory'..abilID..'Charges')
	local scrollOverlay			= object:GetWidget('gameInventory'..abilID..'ScrollOverlay')
	local purchasedRecently		= object:GetWidget('gameInventory'..abilID..'PurchasedRecently')
	local onCourier				= object:GetWidget('gameInventory'..abilID..'OnCourier')
	local crafted				= object:GetWidget('gameInventory'..abilID..'Crafted')
	local dragTarget			= object:GetWidget('gameInventory'..abilID..'DragTarget')

	iconContainer:RegisterWatchLua('StashInventory'..abilID, function(widget, trigger)
		if trigger.isRecipeScroll then
			widget:SetWidth('65%')
			widget:SetHeight('65%')
		else
			widget:SetWidth('100%')
			widget:SetHeight('100%')
		end
	end, false, nil, 'isRecipeScroll')	-- Probably incorrect

	-- Hack as StashInventory#.purchasedRecently does not ever appear to be true
	purchasedRecently:RegisterWatchLua('ActiveInventory'..abilID, function(widget, trigger) widget:SetVisible(trigger.exists and trigger.purchasedRecently) end, false, nil, 'exists', 'purchasedRecently')
	
	onCourier:RegisterWatchLua('StashInventory'..abilID, function(widget, trigger) widget:SetVisible(trigger.exists and trigger.isOnCourier) end, false, nil, 'exists', 'isOnCourier')
	
	crafted:RegisterWatchLua('StashInventory'..abilID, function(widget, trigger) widget:SetVisible(trigger.exists and trigger.isPlayerCrafted) end, false, nil, 'exists', 'isPlayerCrafted')

	scrollOverlay:RegisterWatchLua('StashInventory'..abilID, function(widget, trigger)
		widget:SetVisible(trigger.exists and trigger.isRecipeScroll)
	end, false, nil, 'isRecipeScroll', 'exists')	-- Probably incorrect

	chargeBacker:RegisterWatchLua('StashInventory'..abilID, function(widget, trigger)
		local showWidget = (trigger.charges > 0 and trigger.exists)
		widget:SetVisible(showWidget)
		chargeShadow:SetVisible(showWidget)
		charges:SetVisible(showWidget)
	end, false, nil, 'charges', 'exists')
	
	charges:RegisterWatchLua('StashInventory'..abilID, function(widget, trigger) widget:SetText(math.floor(trigger.charges)) end, false, nil, 'charges')

	icon:RegisterWatchLua('StashInventory'..abilID, function(widget, trigger) widget:SetTexture(trigger.icon) end, false, nil, 'icon')
	
	-- icon:RegisterWatchLua('StashInventory'..abilID, function(widget, trigger)
		-- if trigger.canAccess then
			-- widget:SetRenderMode('normal')
			-- widget:SetColor(1,1,1)
		-- else
			-- widget:SetRenderMode('grayscale')
			-- widget:SetColor(0.8,0.8,0.8)
		-- end
	-- end, true, nil, 'canAccess')
	
	cooldownPie:RegisterWatchLua('StashInventory'..abilID, function(widget, trigger) widget:SetValue(trigger.remainingCooldownPercent) end, false, nil, 'remainingCooldownPercent')
	
	cooldown:RegisterWatchLua('StashInventory'..abilID, function(widget, trigger) if trigger.remainingCooldownPercent > 0 then widget:SetText(math.ceil(trigger.remainingCooldownTime * 0.001)) else widget:ClearText() end end, false, nil, 'remainingCooldownPercent', 'remainingCooldownTime')

	button:SetCallback('onclick', function(widget)
		PrimaryActionStash(abilID)
		PlaySound('/ui/sounds/sfx_button_generic.wav')
	end)
	
	button:SetCallback('onrightclick', function(widget)
		SecondaryActionStash(abilID)
		PlaySound('/ui/sounds/sfx_button_generic.wav')
	end)
	
	button:SetCallback('onmouseover', function(widget)
		shopItemTipShow(abilID, 'StashInventory')
		UpdateCursor(button, true, { canLeftClick = true, canRightClick = true })
		if object:GetWidget('gameShop_sell_area') then
			object:GetWidget('gameShop_sell_area'):SetVisible(1)
		end		
	end)
	
	button:SetCallback('onmouseout', function(widget)
		shopItemTipHide()
		if object:GetWidget('gameShop_sell_area') then
			local dragTrigger = LuaTrigger.GetTrigger('globalDragInfo')
			local itemCursorTrigger = LuaTrigger.GetTrigger('ItemCursorVisible')
	
			if (itemCursorTrigger.cursorVisible and itemCursorTrigger.hasItem) then
			
			elseif (dragTrigger.active and (dragTrigger.type == 5 or dragTrigger.type == 6)) then
			
			else
				object:GetWidget('gameShop_sell_area'):SetVisible(0)
			end
		end
		UpdateCursor(button, false, { canLeftClick = true, canRightClick = true })
	end)
	
	libButton2.register(
		{
			widgets		= {
				button		= button,
				icon		= icon,
			}
		}, 'abilityButtonStash'
	)
	
	button:RegisterWatchLua('StashInventory'..abilID, function(widget, trigger)
		local exists = trigger.exists
		widget:SetVisible(exists)
		cooldown:SetVisible(exists)
		-- icon:SetVisible(exists)
		libGeneral.fade(icon, exists, 175)
		cooldownPie:SetVisible(exists)
	end, false, nil, 'exists')	
	
	--[[
	button:RegisterWatchLua('StashInventory'..abilID, function(widget, trigger)
		buttonInfoTable.useAnims = trigger.canAccess
	end, true, nil, 'canAccess')
	--]]
	
	drop:RegisterWatchLua('ItemCursorVisible', function(widget, trigger)
		widget:SetVisible(trigger.cursorVisible and trigger.hasItem)
	end)
	
	drop:SetCallback('onclick', function(widget)
		-- sound_itemPlaceStash
		-- PlaySound('/path_to/filename.wav')
		ItemPlaceStash(abilID)
	end)
	
	button:SetCallback('onstartdrag', function(widget)
		local inventoryInfo = LuaTrigger.GetTrigger('StashInventory'..abilID)
		trigger_gamePanelInfo.shopLastBuyQueueDragged = -1
		trigger_gamePanelInfo.shopLastQuickSlotDragged = -1
		trigger_gamePanelInfo.shopDraggedItem = inventoryInfo.entity
		trigger_gamePanelInfo.shopDraggedItemScroll	= inventoryInfo.isRecipeScroll
		trigger_gamePanelInfo.shopDraggedItemOwnedRecipe = inventoryInfo.isRecipeCompleted
		trigger_gamePanelInfo.draggedInventoryIndex = abilID
	end)

	globalDraggerRegisterSource(button, 6, 'gameDragLayer')
	
	dragTarget:SetCallback('onmouseover', function(widget)
		globalDraggerReadTarget(widget, function()
			local dragInfo	= LuaTrigger.GetTrigger('globalDragInfo')
			local dragType	= dragInfo.type
			
			if dragType == 3 then		-- From Bookmarks
				Shop.PurchaseRemainingComponents(
					GetTrigger('BookmarkQueue'..trigger_gamePanelInfo.shopLastBuyQueueDragged).entity
				)
			elseif dragType == 4 then	-- From Shop Items
				Shop.PurchaseRemainingComponents(trigger_gamePanelInfo.shopDraggedItem)
			elseif dragType == 5 then	-- From Items
				local sourceIndex = trigger_gamePanelInfo.draggedInventoryIndex
				SecondaryAction(sourceIndex)
				ItemPlaceStash(abilID)
			end
		end)
	end)

	libGeneral.createGroupTrigger('stashDragInfo', { 'globalDragInfo.active', 'globalDragInfo.type', 'PlayerCanShop.playerCanShop'})
	
	dragTarget:RegisterWatchLua('stashDragInfo', function(widget, groupTrigger)
		local dropType	= groupTrigger['globalDragInfo'].type
		local active 	= groupTrigger['globalDragInfo'].active
		local canShop 	= groupTrigger['PlayerCanShop'].playerCanShop

		widget:SetVisible(canShop and active and (((dropType == 3 or dropType == 4) and not trigger_gamePanelInfo.shopDraggedItemOwnedRecipe) or dropType == 5))
	end)
	
end	-- end heroInventoryRegisterStash

function heroInventoryStashContainerRegister(object)
	local stashContainers	= object:GetGroup('heroInventoryStashContainers')
	
	for k,v in pairs(stashContainers) do
		v:RegisterWatchLua('gamePanelInfo', function(widget, trigger)
			if trigger.shopOpen and not trigger.abilityPanel then
				widget:FadeIn(styles_shopTransitionTime)
			else
				widget:FadeOut(styles_shopTransitionTime)
			end
		end, false, nil, 'shopOpen', 'abilityPanel', 'selectedShopItem')
	end
end

heroInventoryStashContainerRegister(object)

for i=128,133,1 do
	heroInventoryRegisterStash(object, i)
end