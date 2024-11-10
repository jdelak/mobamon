local _G = getfenv(0)
local ipairs, pairs, select, string, table, next, type, unpack, tinsert, tconcat, tremove, format, tostring, tonumber, tsort, ceil, floor, sub, find, gfind = _G.ipairs, _G.pairs, _G.select, _G.string, _G.table, _G.next, _G.type, _G.unpack, _G.table.insert, _G.table.concat, _G.table.remove, _G.string.format, _G.tostring, _G.tonumber, _G.table.sort, _G.math.ceil, _G.math.floor, _G.string.sub, _G.string.find, _G.string.gfind
mainUI = mainUI or {}
mainUI.crafting = mainUI.crafting or {}
mainUI.crafting.maxCraftedItemSlots					= 99
mainUI.crafting.maxCraftedItemSlotWidgets			= 18
mainUI.crafting.craftedItemSlotsPerRow				= 6
mainUI.crafting.maxCraftedItemRowsVisible			= math.ceil(mainUI.crafting.maxCraftedItemSlotWidgets / mainUI.crafting.craftedItemSlotsPerRow) - 1
mainUI.crafting.maxCraftedItemNavSlotWidgets		= 48
mainUI.crafting.maxCraftedItemNavSlotItemsPerGroup	= 18

mainUI.crafting.craftedItemSlots					= mainUI.crafting.maxCraftedItemSlots + 1
-- mainUI.crafting.maxCraftedItemNavSlotGroupsVisible	= math.ceil(mainUI.crafting.maxCraftedItemNavSlotWidgets / mainUI.crafting.maxCraftedItemNavSlotItemsPerGroup)

-- inventorySlotEmptyBtn
-- maxCraftedItemSlotWidgets spareSlots

local function InventoryRegister(object)
	local scrollbar			= object:GetWidget('inventoryScrollbar')
	local scrollPanel		= object:GetWidget('inventoryScrollPanel')
	local scrollMin			= 0		-- should always be 0!
	local scrollPos			= 0
	local scrollMax			= 0
	local validSlotList		= {}
	
	local navScrollPanel	= object:GetWidget('inventoryNavScrollPanel')
	local navScrollFrame	= object:GetWidget('inventoryNavScrollFrame')
	
	local navExtraCount		= object:GetWidget('inventoryNavExtraCount')
	local navExtraCountTop	= object:GetWidget('inventoryNavExtraCountTop')

	local function inventoryNavItemRegister(object, slotIndex, triggerIndex)
		local triggerName		= 'CraftedItems' .. triggerIndex
		local itemTrigger 		= LuaTrigger.GetTrigger('CraftedItems' .. triggerIndex)

		local isLocked			= false
		
		if (slotIndex > mainUI.crafting.maxCraftedItemNavSlotWidgets) then return end
		
		local parent 			= GetWidget('inventory_nav_slot_' .. slotIndex)
		local icon 				= GetWidget('inventory_nav_slot_' .. slotIndex..'Icon')
		
		if (not parent) then return end
		
		parent:UnregisterWatchLuaByKey('inventorySlotWatch'..slotIndex)
		icon:UnregisterWatchLuaByKey('inventorySlotWatch'..slotIndex)
		
		
		local function OpenSlotPurchase()
			-- Crafting.UnlockSlotWithGems()
			-- Crafting.UnlockSlotWithEssence()
		end

		local function OpenCraftingToItem()
			local mainPanelStatus = LuaTrigger.GetTrigger('mainPanelStatus')
			mainPanelStatus.main = 1
			mainPanelStatus:Trigger(false)
		end

		local function OpenEnchantingToItem()
			-- local stageTrigger = LuaTrigger.GetTrigger('craftingStage')
			-- stageTrigger.enchantSelectedIndex = triggerIndex
			-- stageTrigger:Trigger(false)
			-- local mainPanelStatus = LuaTrigger.GetTrigger('mainPanelStatus')
			-- mainPanelStatus.main = 5
			-- mainPanelStatus:Trigger(false)

			-- craftingUpdateStage(6,0)
			-- craftingPromptEnchantUpdate(triggerIndex)
			-- keeperPlayVO('enchant')

			-- local triggerNPE = LuaTrigger.GetTrigger('newPlayerExperience')
			-- if triggerNPE.tutorialComplete and triggerNPE.enchantingIntroProgress == 0 and triggerNPE.enchantingIntroStep <= 2 then
				-- local selectedID	= LuaTrigger.GetTrigger('craftingStage').enchantSelectedIndex
				-- local itemInfo		= LuaTrigger.GetTrigger('CraftedItems'..selectedID)
				-- if (not itemInfo.isLegendary) or itemInfo.legendaryQuality < 1 then
					-- newPlayerExperienceEnchantingStep(3)
				-- else
					-- newPlayerExperienceEnchantingStep(1)
				-- end
			-- end
		end

		local function OpenSalvageToItem()
			local stageTrigger = LuaTrigger.GetTrigger('craftingStage')
			craftingPromptSalvageUpdate(triggerIndex)
		end
		
		local function parentUpdate(widget, itemTrigger)
	
			parent:SetVisible((not locked) and (not Empty(itemTrigger.name)))
			
			parent:SetCallback('onmouseover', function(widget)
				if (not Empty(itemTrigger.name)) then
					local canCraftInfo = LuaTrigger.GetTrigger('craftingCraftInfo')
					canCraftInfo.id = itemTrigger.id		
					canCraftInfo:Trigger(false)
					craftedItemTipPopulate(triggerIndex, true)
					shopItemTipShow(triggerIndex, 'craftedItemInfoShop')
				else
					if LuaTrigger.GetTrigger('craftingStage').craftedItemCount >= mainUI.crafting.craftedItemSlots then
						simpleTipGrowYUpdate(true, nil, Translate('crafting_outofslots'), Translate('crafting_outofslots_tip'), libGeneral.HtoP(34))
					end
				end
			end)

			parent:SetCallback('onmouseout', function(widget)
				shopItemTipHide()
				simpleTipGrowYUpdate(false)
			end)

			parent:SetCallback('onclick', function(widget)
				if (isLocked) and Empty(itemTrigger.name) then
					-- OpenSlotPurchase()
				elseif (not Empty(itemTrigger.name)) then
					-- OpenEnchantingToItem()
					-- OpenCraftingToItem()
				else
					OpenCraftingToItem()
				end
			end)
		end
		
		parent:RegisterWatchLua(triggerName, parentUpdate, true, 'inventorySlotWatch'..slotIndex, 'name')
		parentUpdate(parent, itemTrigger)
		
		local function iconUpdate(widget, itemTrigger)
			if (isLocked) or Empty(itemTrigger.name) then
				icon:SetTexture('/ui/main/inventory/textures/inventory_empty_slot.tga')
				icon:SetRenderMode('grayscale')
			else
				icon:SetTexture(GetEntityIconPath(itemTrigger.name))
				icon:SetRenderMode('normal')
			end
		end
		
		iconUpdate(icon, itemTrigger)
		icon:RegisterWatchLua(triggerName, iconUpdate, true, 'inventorySlotWatch'..slotIndex, 'name')
	end
	
	local function RegisterInventoryItem(object, slotIndex, triggerIndex)
		local triggerName		= 'CraftedItems' .. triggerIndex
		local itemTrigger 		= LuaTrigger.GetTrigger('CraftedItems' .. triggerIndex)

		local hasItem
		
		if triggerIndex > mainUI.crafting.maxCraftedItemSlots or not itemTrigger then
			hasItem = false
		else
			hasItem = (not Empty(itemTrigger.name))
		end
		
		local isLocked			= false

		local parent 				= GetWidget('inventory_slot_' .. slotIndex)
		local hoverGlow				= GetWidget('inventory_slot_' .. slotIndex .. '_hover')
		local icon 					= GetWidget('inventory_slot_' .. slotIndex .. '_icon')
		local frame 				= GetWidget('inventory_slot_' .. slotIndex .. '_frame')
		local hover_frame 			= GetWidget('inventory_slot_' .. slotIndex .. '_hover_frame')
		local hover_action_bg		= GetWidget('inventory_slot_' .. slotIndex .. '_action_bg')
		local lock 					= GetWidget('inventory_slot_' .. slotIndex .. '_lock')
		local salvage 				= GetWidget('inventory_slot_' .. slotIndex .. '_salvage')
		local repurchase 			= GetWidget('inventory_slot_' .. slotIndex .. '_repurchase')
		local rareBonus 			= GetWidget('inventory_slot_' .. slotIndex .. '_rareBonus')
		local rareIcon 				= GetWidget('inventory_slot_' .. slotIndex .. '_rareIcon')
		local hover_action_button 	= GetWidget('inventory_slot_' .. slotIndex .. '_hover_action_button')
		local hover_action_buttonL 	= GetWidget('inventory_slot_' .. slotIndex .. '_hover_action_buttonLabel')
		local hover_actions 		= GetWidget('inventory_slot_' .. slotIndex .. '_hover_actions')
		local lifetime_bar_parent 	= GetWidget('inventory_slot_' .. slotIndex .. '_lifetime_bar_parent')
		local lifetime_bar 			= GetWidget('inventory_slot_' .. slotIndex .. '_lifetime_bar')
		local expired 				= GetWidget('inventory_slot_' .. slotIndex .. '_expired')
		local disabled 				= GetWidget('inventory_slot_' .. slotIndex .. '_disabled')

		if (not parent) then return end
		
		-- unregister step
		
		parent:UnregisterWatchLuaByKey('inventorySlotWatch'..slotIndex)
		salvage:UnregisterWatchLuaByKey('inventorySlotWatch'..slotIndex)
		repurchase:UnregisterWatchLuaByKey('inventorySlotWatch'..slotIndex)
		expired:UnregisterWatchLuaByKey('inventorySlotWatch'..slotIndex)
		disabled:UnregisterWatchLuaByKey('inventorySlotWatch'..slotIndex)
		lifetime_bar_parent:UnregisterWatchLuaByKey('inventorySlotWatch'..slotIndex)
		hover_action_button:UnregisterWatchLuaByKey('inventorySlotWatch'..slotIndex)
		icon:UnregisterWatchLuaByKey('inventorySlotWatch'..slotIndex)
		frame:UnregisterWatchLuaByKey('inventorySlotWatch'..slotIndex)
		hover_frame:UnregisterWatchLuaByKey('inventorySlotWatch'..slotIndex)
		rareBonus:UnregisterWatchLuaByKey('inventorySlotWatch'..slotIndex)
		hoverGlow:UnregisterWatchLuaByKey('inventorySlotWatch'..slotIndex)
		lock:UnregisterWatchLuaByKey('inventorySlotWatch'..slotIndex)



		local function OpenCraftingToItem()
			local mainPanelStatus = LuaTrigger.GetTrigger('mainPanelStatus')
			mainPanelStatus.main = 1
			mainPanelStatus:Trigger(false)
		end


		if (not hasItem) then
			lifetime_bar_parent:SetVisible(0)
			hoverGlow:SetVisible(0)
			hover_action_bg:SetVisible(0)
			salvage:SetVisible(0)
			repurchase:SetVisible(0)
			expired:SetVisible(0)
			lifetime_bar_parent:SetVisible(0)
			lock:SetVisible(0)

			icon:SetTexture('/ui/main/inventory/textures/inventory_empty_slot.tga')
			icon:SetRenderMode('grayscale')
			icon:SetColor('1 1 1 .3')
			icon:SetWidth('48@')
			icon:SetHeight('48@')
			for i=1,3,1 do
				GetWidget('inventory_slot_'..slotIndex..'_component'..i..'Icon'):SetTexture('/ui/main/crafting/textures/component_blank.tga')
			end

			parent:SetCallback('onmouseover', function(widget)


				if LuaTrigger.GetTrigger('craftingStage').craftedItemCount + 1 >= mainUI.crafting.craftedItemSlots then
					simpleTipGrowYUpdate(true, nil, Translate('crafting_outofslots'), Translate('crafting_outofslots_tip'), libGeneral.HtoP(34))
					hover_action_button:SetEnabled(false)
					hover_action_button:SetCallback('onclick', function(widget)
						
					end)
				else
					hover_action_button:SetEnabled(true)
					hover_action_button:SetCallback('onclick', function(widget)
						OpenCraftingToItem()
					end)
				end
				hover_action_buttonL:SetText(Translate('crafting_begin_button_label'))
				hover_action_button:SetVisible(1)

				

				hover_frame:FadeIn(250)
				hover_actions:FadeIn(250)
			end)


			parent:SetCallback('onclick', function(widget)
				OpenCraftingToItem()
			end)


			return

		end

		--[[
		if triggerIndex > mainUI.crafting.maxCraftedItemSlots then
			parent:SetVisible(false)
			return
		else
			parent:SetVisible(true)
		end
		--]]

		local function OpenSlotPurchase()

			-- Crafting.UnlockSlotWithGems()
			-- Crafting.UnlockSlotWithEssence()
		end

		local function OpenEnchantingToItem()
			-- local stageTrigger = LuaTrigger.GetTrigger('craftingStage')
			-- stageTrigger.enchantSelectedIndex = triggerIndex
			-- stageTrigger:Trigger(false)
			-- local mainPanelStatus = LuaTrigger.GetTrigger('mainPanelStatus')
			-- mainPanelStatus.main = 5
			-- mainPanelStatus:Trigger(false)

			-- craftingUpdateStage(6,0)
			-- craftingPromptEnchantUpdate(triggerIndex)
			-- keeperPlayVO('enchant')

			-- local triggerNPE = LuaTrigger.GetTrigger('newPlayerExperience')
			-- if triggerNPE.tutorialComplete and triggerNPE.enchantingIntroProgress == 0 and triggerNPE.enchantingIntroStep <= 2 then
				-- local selectedID	= LuaTrigger.GetTrigger('craftingStage').enchantSelectedIndex
				-- local itemInfo		= LuaTrigger.GetTrigger('CraftedItems'..selectedID)
				-- if (not itemInfo.isLegendary) or itemInfo.legendaryQuality < 1 then
					-- newPlayerExperienceEnchantingStep(3)
				-- else
					-- newPlayerExperienceEnchantingStep(1)
				-- end
			-- end
		end

		local function OpenSalvageToItem()
			local stageTrigger = LuaTrigger.GetTrigger('craftingStage')
			craftingPromptSalvageUpdate(triggerIndex)
		end

		local function ExtendLifePrompt(itemTrigger)
			local canCraftInfo = LuaTrigger.GetTrigger('craftingCraftInfo')
			canCraftInfo.id = itemTrigger.id
			canCraftInfo:Trigger(false)		
			local baseName = string.match(itemTrigger.name, '|(.+)')
			craftingSelectRecipe(baseName)				
			Crafting.SetDesignEmpoweredEffect(itemTrigger.currentEmpoweredEffectEntityName)
			craftingAddComponentByName(itemTrigger.component1, 1)
			craftingAddComponentByName(itemTrigger.component2, 2)
			craftingAddComponentByName(itemTrigger.component3, 3)
			GetWidget('crafting_prompt_purchase_craft'):FadeIn(250)		
		end
		
		local function parentUpdate(widget, itemTrigger)

			parent:SetCallback('onmouseover', function(widget)
				hover_frame:FadeIn(250)
				hover_actions:FadeIn(250)
				if (not isLocked and (not Empty(itemTrigger.name))) then
					hoverGlow:FadeIn(250)
				end
				
				if (not Empty(itemTrigger.name)) then
					local canCraftInfo = LuaTrigger.GetTrigger('craftingCraftInfo')
					canCraftInfo.id = itemTrigger.id
					canCraftInfo:Trigger(false)
					craftedItemTipPopulate(triggerIndex, true)
					shopItemTipShow(triggerIndex, 'craftedItemInfoShop')
				end
			end)

			parent:SetCallback('onmouseout', function(widget)
				hover_frame:FadeOut(250)
				hover_actions:FadeOut(125)
				hoverGlow:FadeOut(250)

				simpleTipGrowYUpdate(false)
				shopItemTipHide()
			end)

			parent:SetCallback('onclick', function(widget)
				if (isLocked) and Empty(itemTrigger.name) then
					-- OpenSlotPurchase()
				elseif (not Empty(itemTrigger.name)) then
					-- OpenEnchantingToItem()
					-- OpenCraftingToItem()
				else
					OpenCraftingToItem()
				end
			end)
			
			parent:SetCallback('onstartdrag', function(widget)
				local stageTrigger = LuaTrigger.GetTrigger('craftingStage')
				stageTrigger.enchantLastDraggedIndex = triggerIndex
				stageTrigger:Trigger(false)
				
				local itemInfo = LuaTrigger.GetTrigger('CraftedItems' .. triggerIndex)
				local itemInfoDrag = LuaTrigger.GetTrigger('itemInfoDrag')
				itemInfoDrag.triggerName = 'CraftedItems'
				itemInfoDrag.triggerIndex = triggerIndex
				itemInfoDrag.type = 1
				itemInfoDrag.entityName = itemInfo.name
				itemInfoDrag:Trigger(false)
			end)

			globalDraggerRegisterSource(parent, 5)	
			
		end
		
		parent:RegisterWatchLua(triggerName, parentUpdate, true, 'inventorySlotWatch'..slotIndex, 'name')
		parentUpdate(parent, itemTrigger)

		local function lifetimeUpdate(widget, itemTrigger)
			if (not itemTrigger.isPermanent) and ((itemTrigger.days > 0) or (itemTrigger.monthsLeft > 0) or (itemTrigger.daysLeft > 0) or (itemTrigger.hoursLeft > 0) or (itemTrigger.minutesLeft > 0)) then
				widget:SetVisible(1)
				local days = (itemTrigger.monthsLeft * 30) + (itemTrigger.daysLeft) + (itemTrigger.hoursLeft / 24)
				local percentRemaining = math.max(0, math.min(100, (days / 7) * 100))
				lifetime_bar:SetWidth(percentRemaining .. '%')
			else
				widget:SetVisible(0)
			end
		end
		
		lifetimeUpdate(lifetime_bar_parent, itemTrigger)
		lifetime_bar_parent:RegisterWatchLua(triggerName, lifetimeUpdate, true, 'inventorySlotWatch'..slotIndex, 'name', 'days', 'monthsLeft', 'daysLeft', 'hoursLeft', 'minutesLeft', 'isExpired', 'available', 'isPermanent')		
		
		local function availableUpdate(widget, itemTrigger)
			widget:SetVisible(not itemTrigger.available)
		end
		
		availableUpdate(disabled, itemTrigger)
		disabled:RegisterWatchLua(triggerName, availableUpdate, true, 'inventorySlotWatch'..slotIndex, 'name', 'days', 'monthsLeft', 'daysLeft', 'hoursLeft', 'minutesLeft', 'isExpired', 'available', 'isPermanent')			
		
		local function expiredUpdate(widget, itemTrigger)
			widget:SetVisible((not itemTrigger.isPermanent) and itemTrigger.isExpired)
		end
		
		expiredUpdate(expired, itemTrigger)
		expired:RegisterWatchLua(triggerName, expiredUpdate, true, 'inventorySlotWatch'..slotIndex, 'name', 'days', 'monthsLeft', 'daysLeft', 'hoursLeft', 'minutesLeft', 'isExpired', 'available', 'isPermanent')			
		
		repurchase:SetCallback('onmouseover', function(widget)
			hover_frame:FadeIn(250)
			hover_actions:FadeIn(250)
			if (not Empty(itemTrigger.name)) then
				hoverGlow:FadeIn(250)
			end
			UpdateCursor(repurchase, true, { canLeftClick = true, canRightClick = false })
		end)
		repurchase:SetCallback('onmouseout', function(widget)
			hover_frame:FadeOut(250)
			hover_actions:FadeOut(125)
			hoverGlow:FadeOut(250)
			UpdateCursor(repurchase, false, { canLeftClick = true, canRightClick = false })
		end)
		repurchase:SetCallback('onclick', function(widget)
			if (isLocked) or Empty(itemTrigger.name) then

			else
				ExtendLifePrompt(itemTrigger)
			end
		end)	
		
		local function repurchaseUpdate(widget, itemTrigger)
			repurchase:SetCallback('onmouseover', function(widget)
				if (itemTrigger.isExpired) then
					simpleTipGrowYUpdate(true, nil, Translate('crafting_repurchase'), Translate('crafting_repurchase_tip'), libGeneral.HtoP(34))
				else
					simpleTipGrowYUpdate(true, nil, Translate('crafting_repurchase2'), Translate('crafting_repurchase2_tip'), libGeneral.HtoP(34))
				end
				hover_frame:FadeIn(250)
				hover_actions:FadeIn(250)
				if (not Empty(itemTrigger.name)) then
					hoverGlow:FadeIn(250)
				end
			end)
			repurchase:SetCallback('onmouseout', function(widget)
				simpleTipGrowYUpdate(false)
				hover_frame:FadeOut(250)
				hover_actions:FadeOut(125)
				hoverGlow:FadeOut(250)
			end)
			repurchase:SetCallback('onclick', function(widget)
				if (isLocked) or Empty(itemTrigger.name) then

				else
					ExtendLifePrompt(itemTrigger)
				end
			end)
			repurchase:SetVisible(not itemTrigger.isPermanent and (((itemTrigger.isExpired) or (itemTrigger.days > 0) or (itemTrigger.monthsLeft > 0) or (itemTrigger.daysLeft > 0) or (itemTrigger.hoursLeft > 0) or (itemTrigger.minutesLeft > 0)) and (not Empty(itemTrigger.name))))
			hover_action_bg:SetVisible((not itemTrigger.isPermanent) and (((itemTrigger.isExpired) or (itemTrigger.days > 0) or (itemTrigger.monthsLeft > 0) or (itemTrigger.daysLeft > 0) or (itemTrigger.hoursLeft > 0) or (itemTrigger.minutesLeft > 0)) and (not Empty(itemTrigger.name))))
		end

		repurchaseUpdate(repurchase, itemTrigger)
		repurchase:RegisterWatchLua(triggerName, repurchaseUpdate, true, 'inventorySlotWatch'..slotIndex, 'name')		
		
		salvage:SetCallback('onmouseover', function(widget)
			hover_frame:FadeIn(250)
			hover_actions:FadeIn(250)
			if (not Empty(itemTrigger.name)) then
				hoverGlow:FadeIn(250)
			end
			UpdateCursor(salvage, true, { canLeftClick = true, canRightClick = false })
		end)
		salvage:SetCallback('onmouseout', function(widget)
			hover_frame:FadeOut(250)
			hover_actions:FadeOut(125)
			hoverGlow:FadeOut(250)
			UpdateCursor(salvage, false, { canLeftClick = true, canRightClick = false })
		end)
		salvage:SetCallback('onclick', function(widget)
			if (isLocked) or Empty(itemTrigger.name) then

			else
				-- salvage prompt
				OpenSalvageToItem()
			end
		end)
		
		local function rareUpdate(widget, itemTrigger)
			local isRare = itemTrigger.isRare
			if isRare then
				rareBonus:SetVisible(true)
				rareIcon:SetTexture(itemTrigger.rareBonusIcon)
			else
				rareBonus:SetVisible(false)
			end
		end
		
		rareUpdate(rareBonus, itemTrigger)
		rareBonus:RegisterWatchLua(triggerName, rareUpdate, true, 'inventorySlotWatch'..slotIndex, 'isRare', 'rareBonusIcon')
		
		local function salvageUpdate(widget, itemTrigger)
			salvage:SetCallback('onmouseover', function(widget)
				simpleTipGrowYUpdate(true, nil, Translate('crafting_salvage_item'), Translate('crafting_salvage_tip'), libGeneral.HtoP(34))
				hover_frame:FadeIn(250)
				hover_actions:FadeIn(250)
				if (not Empty(itemTrigger.name)) then
					hoverGlow:FadeIn(250)
				end
			end)
			salvage:SetCallback('onmouseout', function(widget)
				simpleTipGrowYUpdate(false)
				hover_frame:FadeOut(250)
				hover_actions:FadeOut(125)
				hoverGlow:FadeOut(250)
			end)
			salvage:SetCallback('onclick', function(widget)
				if (isLocked) or Empty(itemTrigger.name) then

				else
					-- salvage prompt
					OpenSalvageToItem()
				end
			end)
			salvage:SetVisible((not isLocked) and (not Empty(itemTrigger.name)))
		end

		salvageUpdate(salvage, itemTrigger)
		salvage:RegisterWatchLua(triggerName, salvageUpdate, true, 'inventorySlotWatch'..slotIndex, 'name')
		
		local function hoverActionButtonUpdate(widget, itemTrigger)
			hover_action_button:SetCallback('onmouseover', function(widget)
				hover_frame:FadeIn(250)
				hover_actions:FadeIn(250)
				if (not Empty(itemTrigger.name)) then
					hoverGlow:FadeIn(250)
				end
				
				if (not isLocked) and Empty(itemTrigger.name) then
					if LuaTrigger.GetTrigger('craftingStage').craftedItemCount + 1 >= mainUI.crafting.craftedItemSlots then
						simpleTipGrowYUpdate(true, nil, Translate('crafting_outofslots'), Translate('crafting_outofslots_tip'), libGeneral.HtoP(34))
					end
				end
				
			end)

			hover_action_button:SetCallback('onmouseout', function(widget)
				hover_frame:FadeOut(250)
				hover_actions:FadeOut(125)
				hoverGlow:FadeOut(250)
				
				simpleTipGrowYUpdate(false)
			end)
			hover_action_button:SetCallback('onclick', function(widget)
				if (isLocked) and Empty(itemTrigger.name) then
					-- OpenSlotPurchase()
				elseif (not Empty(itemTrigger.name)) then
					-- OpenEnchantingToItem()
					-- OpenCraftingToItem()
				else
					OpenCraftingToItem()
				end
			end)
			if (isLocked) and Empty(itemTrigger.name) then
				-- hover_action_buttonL:SetText(Translate('unlockslot_begin_button_label'))
				hover_action_button:SetVisible(0)				
			elseif (not Empty(itemTrigger.name)) then
				hover_action_buttonL:SetText(Translate('crafting_begin_button_label'))
				hover_action_button:SetVisible(0)				
			else
				hover_action_buttonL:SetText(Translate('crafting_begin_button_label'))
				hover_action_button:SetVisible(1)
				hover_action_button:SetEnabled(true)
			end
		end

		hoverActionButtonUpdate(hover_action_button, itemTrigger)
		hover_action_button:RegisterWatchLua(triggerName, hoverActionButtonUpdate, true, 'inventorySlotWatch'..slotIndex, 'name')

		local function iconUpdate(widget, itemTrigger)
			if (isLocked) or Empty(itemTrigger.name) then
				icon:SetTexture('/ui/main/inventory/textures/inventory_empty_slot.tga')
				icon:SetRenderMode('grayscale')
				icon:SetColor('1 1 1 .3')
				icon:SetWidth('48@')
				icon:SetHeight('48@')
				for i=1,3,1 do
					GetWidget('inventory_slot_'..slotIndex..'_component'..i..'Icon'):SetTexture('/ui/main/crafting/textures/component_blank.tga')
				end
			else
				icon:SetTexture(GetEntityIconPath(itemTrigger.name))
				icon:SetRenderMode('normal')
				icon:SetColor('1 1 1 1')
				icon:SetWidth('64@')
				icon:SetHeight('64@')				
				for i=1,3,1 do
					if itemTrigger['component'..i] and string.len(itemTrigger['component'..i]) > 0 then
						GetWidget('inventory_slot_'..slotIndex..'_component'..i..'Icon'):SetTexture(GetEntityIconPath(itemTrigger['component'..i]))
					else
						GetWidget('inventory_slot_'..slotIndex..'_component'..i..'Icon'):SetTexture('/ui/main/crafting/textures/component_blank.tga')
					end
				end
			end
		end
		
		iconUpdate(icon, itemTrigger)
		icon:RegisterWatchLua(triggerName, iconUpdate, true, 'inventorySlotWatch'..slotIndex, 'name', 'component1', 'component2', 'component3')

		local function frameUpdate(widget, itemTrigger)
			if (Empty(itemTrigger.name)) then
				frame:SetTexture('/ui/main/inventory/textures/slot_frame.tga')
			elseif (isLocked) and Empty(itemTrigger.name) then
				frame:SetTexture('/ui/main/inventory/textures/slot_frame.tga')
			elseif (itemTrigger.isLegendary) then
				frame:SetTexture('/ui/main/inventory/textures/slot_frame.tga')
			elseif (itemTrigger.isRare) then
				frame:SetTexture('/ui/main/inventory/textures/slot_frame.tga')
			else
				frame:SetTexture('/ui/main/inventory/textures/slot_frame.tga')
			end
		end
		
		frameUpdate(frame, itemTrigger)
		frame:RegisterWatchLua(triggerName, frameUpdate, true, 'inventorySlotWatch'..slotIndex, 'name', 'isRare', 'isLegendary')

		local function hoverFrameUpdate(widget, itemTrigger)
			if (Empty(itemTrigger.name)) then
				hover_frame:SetTexture('/ui/main/inventory/textures/slot_frame_hover.tga')
			elseif (isLocked) and Empty(itemTrigger.name) then
				hover_frame:SetTexture('/ui/main/inventory/textures/slot_frame_hover.tga')
			elseif (itemTrigger.isLegendary) then
				hover_frame:SetTexture('/ui/main/inventory/textures/slot_frame_hover.tga')
			elseif (itemTrigger.isRare) then
				hover_frame:SetTexture('/ui/main/inventory/textures/slot_frame_hover.tga')
			else
				hover_frame:SetTexture('/ui/main/inventory/textures/slot_frame_hover.tga')
			end
		end
		
		hoverFrameUpdate(hover_frame, itemTrigger)
		hover_frame:RegisterWatchLua(triggerName, hoverFrameUpdate, true, 'inventorySlotWatch'..slotIndex, 'name', 'isRare', 'isLegendary')

		local function hoverGlowUpdate(widget, itemTrigger)
			if (Empty(itemTrigger.name)) then
				hoverGlow:SetColor('.4 .9 1 .5')
			elseif (isLocked) and Empty(itemTrigger.name) then
				hoverGlow:SetColor('.4 .9 1 .5')
			elseif (itemTrigger.isLegendary) then
				hoverGlow:SetColor('.4 .9 1 .5')
			elseif (itemTrigger.isRare) then
				hoverGlow:SetColor('.4 .9 1 .5')
			else
				hoverGlow:SetColor('.4 .9 1 .5')
			end
		end
		
		hoverGlowUpdate(hoverGlow, itemTrigger)
		hoverGlow:RegisterWatchLua(triggerName, hoverGlowUpdate, true, 'inventorySlotWatch'..slotIndex, 'name')

		local function lockUpdate(widget, itemTrigger)
			lock:SetVisible(isLocked and (not Empty(itemTrigger.name)))
		end

		lockUpdate(lock, itemTrigger)
		lock:RegisterWatchLua(triggerName, lockUpdate, true, 'inventorySlotWatch'..slotIndex, 'name')
		
		FindChildrenClickCallbacks(parent)
	end
	
	local lastItemCount	= 0
	
	local navScrollArea	= 10
	
	local function updateScrolledList(itemCount)
		itemCount = itemCount or lastItemCount
		lastItemCount = itemCount

		local scrollOffset	= (scrollPos * mainUI.crafting.craftedItemSlotsPerRow)
		local slotIndex
		
		for i=scrollOffset, (scrollOffset + mainUI.crafting.maxCraftedItemSlotWidgets - 1),1 do
			slotIndex = (i - scrollOffset + 1)
			RegisterInventoryItem(object, slotIndex, i)
		end
		
		local navScrollOffset = (math.max(scrollPos - navScrollArea, 0) * mainUI.crafting.craftedItemSlotsPerRow)
		
		for i=navScrollOffset,(navScrollOffset + mainUI.crafting.maxCraftedItemNavSlotWidgets - 1),1 do
			slotIndex = (i - navScrollOffset + 1)
			inventoryNavItemRegister(object, slotIndex, i)
		end
		
		local navScrollPos		= math.min(scrollPos, navScrollArea)
		local itemFullHeight	= GetWidget('inventory_nav_slot_1'):GetHeight() + GetWidget('inventory_nav_slot_1'):GetHeightFromString('4s')
		navScrollFrame:SetY((navScrollPos * mainUI.crafting.craftedItemSlotsPerRow / 4) * itemFullHeight)
		navScrollFrame:SetHeight(mainUI.crafting.maxCraftedItemNavSlotItemsPerGroup / 4 * itemFullHeight)

		local navItemCountExtra	= itemCount - mainUI.crafting.maxCraftedItemNavSlotWidgets
		
		local navItemCountExtraTop	= math.max(scrollPos - navScrollArea, 0) * mainUI.crafting.craftedItemSlotsPerRow
		local navItemCountExtraBot	= navItemCountExtra - navItemCountExtraTop
		
		if navItemCountExtraBot > 0 then
			navExtraCount:SetVisible(true)
			navExtraCount:SetText('+'..navItemCountExtraBot)
		else
			navExtraCount:SetVisible(false)
		end
		
		if navItemCountExtraTop > 0 then
			navExtraCountTop:SetVisible(true)
			navExtraCountTop:SetText('+'..navItemCountExtraTop)
		else
			navExtraCountTop:SetVisible(false)
		end
	end
	
	local function recalculateScrolling()
		local itemCount	= 0
		local rowCount	= 0
		for i=0,mainUI.crafting.maxCraftedItemSlots,1 do
			if validSlotList[i] then
				itemCount = i
			end
		end
		
		rowCount = math.max(math.ceil(itemCount / mainUI.crafting.craftedItemSlotsPerRow), 2)
		local itemPad = itemCount % mainUI.crafting.craftedItemSlotsPerRow
		if itemPad == 0 then
			rowCount = rowCount + 1
		end
		
		scrollMax = math.max(0, rowCount - mainUI.crafting.maxCraftedItemRowsVisible)
		
		local canScroll = scrollMax > 0
		scrollbar:SetVisible(canScroll)
		scrollPanel:SetVisible(canScroll)
		navScrollFrame:SetVisible(canScroll)
		
		scrollbar:SetMaxValue(scrollMax)
		
		if AtoN(scrollbar:GetValue()) > scrollMax then
			scrollbar:SetValue(scrollMax)
		end
		
		local triggerStage	= LuaTrigger.GetTrigger('craftingStage')
		triggerStage.craftedItemCount = itemCount
		triggerStage:Trigger(false)
		
		return itemCount
	end
	
	local function panelWheelUp()
		scrollbar:SetValue(math.max(
			scrollMin,
			scrollPos - 1
		))
	end
	
	local function panelWheelDown()
		scrollbar:SetValue(math.min(
			scrollPos + 1,
			scrollMax
		))
	end
	
	scrollbar:SetCallback('onslide', function(widget)
		scrollPos = widget:GetValue()
		updateScrolledList()
	end)

	navScrollPanel:SetCallback('onmousewheelup', panelWheelUp)
	navScrollPanel:SetCallback('onmousewheeldown', panelWheelDown)
	
	scrollPanel:SetCallback('onmousewheelup', panelWheelUp)
	scrollPanel:SetCallback('onmousewheeldown', panelWheelDown)

	-- ===================================
	
	local navScrollDragger		= navScrollPanel	-- object:GetWidget('inventoryNavScrollDragger')
	
	local navScrollOverThrottle		= 125	-- When you're past the scroll area in either direction, this is how long between scroll attempts (up or down)
	local navScrollOverLastTime		= 0		-- Time since last past-scroll-area scroll (used w/throttling)
	local navScrollDraggerYMin		= navScrollDragger:GetAbsoluteY()
	local navScrollDraggerHeight	= navScrollDragger:GetHeight()
	local navScrollDraggerYMax		= navScrollDraggerYMin + navScrollDraggerHeight
	local navScrollDraggerActive	= false
	local navScrollItemHeight		= GetWidget('inventory_nav_slot_1'):GetHeight() + GetWidget('inventory_nav_slot_1'):GetHeightFromString('4s')
	
	-- ===================================
	
	local function navScrollThrottleExpired(hostTime)	-- rmm variable throttle time based on distance modifier
		local hasExpired = hostTime > (navScrollOverLastTime + navScrollOverThrottle)
		if hasExpired then
			navScrollOverLastTime = hostTime
		end
		
		return hasExpired
	end
	
	local function navScrollDragWithin(cursorY)
		local cursorYWithinDragger	= (cursorY - navScrollDraggerYMin)
		local dragScrollPos = math.floor(cursorYWithinDragger / navScrollItemHeight)
	
		local navScrollPos		= math.min(scrollPos, navScrollArea)
		local newScrollPos		= scrollPos
		
		if navScrollPos > dragScrollPos then
			newScrollPos = scrollPos - (navScrollPos - dragScrollPos)
		elseif navScrollPos < dragScrollPos then
			newScrollPos = scrollPos + (dragScrollPos - navScrollPos)
		end
		
		
		if newScrollPos ~= scrollPos then
			scrollbar:SetValue(math.max(
				scrollMin,
				math.min(newScrollPos, scrollMax)
			))
		end
	end
	
	local function navScrollDragPastBefore(cursorY, hostTime)
		if navScrollThrottleExpired(hostTime) then
			panelWheelUp()
		end
	end
	
	local function navScrollDragPastAfter(cursorY, hostTime)
		if navScrollThrottleExpired(hostTime) then
			panelWheelDown()
		end
	end
	
	local function navScrollDragStart()
		navScrollDraggerActive = true
		navScrollDragger:UnregisterWatchLua('System')
		navScrollDragger:RegisterWatchLua('System', function(widget, trigger)
			local cursorY	= Input.GetCursorPosY()
			
			if cursorY < navScrollDraggerYMin then
				navScrollDragPastBefore(cursorY, trigger.hostTime)
			elseif cursorY > navScrollDraggerYMax then
				navScrollDragPastAfter(cursorY, trigger.hostTime)
			else
				navScrollDragWithin(cursorY)
			end
		end, false, nil, 'hostTime')
	end
	
	local function navScrollDragEnd()
		if navScrollDraggerActive then
			navScrollDraggerActive = false
			navScrollDragger:UnregisterWatchLua('System')
		end
	end
	
	navScrollDragger:SetCallback('onmouseldown', function(widget)
		navScrollDragStart()
	end)
	
	navScrollDragger:SetCallback('onmouselup', function(widget)
		navScrollDragEnd()
	end)
	
	navScrollDragger:SetCallback('onhide', function(widget)
		navScrollDragEnd()
	end)
	
	-- ===================================

	local validSlotParams	= {}

	for i=0,mainUI.crafting.maxCraftedItemSlots,1 do
		table.insert(validSlotParams, 'CraftedItems'..i..'.available')

	end
	
	libGeneral.createGroupTrigger('inventoryValidSlots', validSlotParams)

	local inventory 	= GetWidget('inventory')
	
	inventory:RegisterWatchLua('inventoryValidSlots', function(widget, groupTrigger)
		for i=0,mainUI.crafting.maxCraftedItemSlots,1 do
			validSlotList[i] = groupTrigger['CraftedItems'..i].available
		end
		
		updateScrolledList(recalculateScrolling())
	end)
	
	local function OpenCraftingToItem()
		local mainPanelStatus = LuaTrigger.GetTrigger('mainPanelStatus')
		mainPanelStatus.main = 1
		mainPanelStatus:Trigger(false)
	end	
	
	GetWidget('crafting_open_crafting_btn'):SetCallback('onclick', OpenCraftingToItem)
	
	inventory:RegisterWatchLua('mainPanelAnimationStatus', function(widget, trigger)
		local newMain	= trigger.newMain
		local main		= trigger.main

		local animState = mainSectionAnimState(6, trigger.main, trigger.newMain)

		if animState == 1 then
			libThread.threadFunc(function()
				groupfcall('inventory_animation_widgets', function(_, widget)  widget:DoEventN(8) end)
			end)
		elseif animState == 2 then
			widget:SetVisible(false)
		elseif animState == 3 then
			libThread.threadFunc(function()
				wait(10)
				PlaySound('/ui/sounds/sfx_transition_2.wav')
				widget:SetVisible(true)
				groupfcall('inventory_animation_widgets', function(_, widget) RegisterRadialEase(widget) widget:DoEventN(7) end)
			end)
		elseif animState == 4 then
			widget:SetVisible(true)
			updateScrolledList()
		end
	end, false, nil, 'main', 'newMain')

end

InventoryRegister(object)