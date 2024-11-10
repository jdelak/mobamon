
-- local itemInfoDrag = LuaTrigger.CreateCustomTrigger('itemInfoDrag',
	-- {
		-- { name	= 'triggerName',						type	= 'string' },
		-- { name	= 'triggerIndex',						type	= 'string' },
		-- { name	= 'type',								type	= 'string' },
		-- { name	= 'entityName',							type	= 'string' },
	-- }
-- )

Links = {}
Links.lastActiveChatInputBuffer = nil

-- function Links.SpawnShiftLink()

	-- local mainPanelStatus 	 = LuaTrigger.GetTrigger('mainPanelStatus')
	-- local globalDragInfo  	 = LuaTrigger.GetTrigger('globalDragInfo')
	-- local clientInfoDrag  	 = LuaTrigger.GetTrigger('clientInfoDrag')
	-- local itemInfoDrag 		 = LuaTrigger.GetTrigger('itemInfoDrag')
	-- local craftingStage		 = LuaTrigger.GetTrigger('craftingStage')

	-- if (globalDragInfo.type == 4) or (globalDragInfo.type == 5) then

		-- local itemInfo = LuaTrigger.GetTrigger(itemInfoDrag.triggerName .. itemInfoDrag.triggerIndex)
		
		-- if (itemInfo) then

			-- if (channelType) and (channelType == 'pm') then

				-- mainUI.chatManager.InitPrivateMessage(channelID, nil, channelName)
				
				-- GetWidget('main_chat_sleeper'):Sleep(1, function()
					-- GetWidget('main_chat_sleeper'):Sleep(1, function()
						-- if GetWidget('overlay_chat_' .. channelID .. '_input') then
							-- GetWidget('overlay_chat_' .. channelID .. '_input'):InputChatLink('i', '1', GetEntityDisplayName(itemInfoDrag.entityName))
						-- end
					-- end)
				-- end)
			
			-- elseif (channelType) and (channelType == 'channel') then
			
				-- if GetWidget('overlay_chat_' .. channelID .. '_input') then
					-- GetWidget('overlay_chat_' .. channelID .. '_input'):InputChatLink('i', '1', GetEntityDisplayName(itemInfoDrag.entityName))
				-- end			
			
			-- end
			
		-- end
	
	-- end
	
-- end

function Links.GetBuildData(buildNum)
	local buildName, buildHero, buildTable
	buildTable = {linkType = 'build'}

	if (buildNum > 0) then
		buildTable.itemData 	= (mainUI.Selection.itemsBuildTables[tonumber(buildNum)])
		buildTable.abilityData 	= (mainUI.Selection.abilitiesBuildTables[tonumber(buildNum)])
		buildTable.buildInfo 	= (mainUI.Selection.buildInfoTables[tonumber(buildNum)])
		buildHero = mainUI.Selection.buildInfoTables[tonumber(buildNum)].heroEntity
		buildName = mainUI.Selection.buildInfoTables[tonumber(buildNum)].name
	end
	
	local encoded = JSON:encode(buildTable)
	if (encoded) and (buildHero) and (buildName) then
		return {'i', encoded, '[' .. GetEntityDisplayName(buildHero) .. ': ' .. buildName ..']'}
	end
	return nil

end

function Links.SpawnLink(channelID, channelType, channelName, extraData)

	local mainPanelStatus 	 = LuaTrigger.GetTrigger('mainPanelStatus')
	local globalDragInfo  	 = LuaTrigger.GetTrigger('globalDragInfo')
	local clientInfoDrag  	 = LuaTrigger.GetTrigger('clientInfoDrag')
	local itemInfoDrag 		 = LuaTrigger.GetTrigger('itemInfoDrag')
	local craftingStage		 = LuaTrigger.GetTrigger('craftingStage')

	if (globalDragInfo.type == 4) or (globalDragInfo.type == 5) then

		local itemInfo = LuaTrigger.GetTrigger(itemInfoDrag.triggerName .. itemInfoDrag.triggerIndex)

		if (itemInfo) then
			local tipTrigger 					= {}
			tipTrigger.linkType 				= 'item'
			tipTrigger.isPlayerCrafted	= true
			tipTrigger.description = itemInfo.description
			tipTrigger.currentEmpoweredEffectEntityName = itemInfo.currentEmpoweredEffectEntityName
			tipTrigger.currentEmpoweredEffectCost = itemInfo.currentEmpoweredEffectCost
			tipTrigger.currentEmpoweredEffectDisplayName = itemInfo.currentEmpoweredEffectDisplayName
			tipTrigger.currentEmpoweredEffectDescription = itemInfo.currentEmpoweredEffectDescription
			tipTrigger.isRare			= string.len(itemInfo.currentEmpoweredEffectDisplayName) > 0
			
			if  (itemInfoDrag.triggerName == 'ShopItem') then
				tipTrigger.name = itemInfo.entity
				tipTrigger.recipeCost = itemInfo.recipeScrollCost
				-- Components
				for i=1,3,1 do
					if itemInfo['recipeComponentDetail'.. i-1 ..'exists'] == true then
						tipTrigger['component'..i] = itemInfo['recipeComponentDetail'.. i-1 ..'entity']
					else
						tipTrigger['component'..i] = nil
					end
				end
			else
				local name = itemInfo.name
				tipTrigger.name = string.sub(name, string.find(name, "|") + 1)
				tipTrigger.recipeCost = itemInfo.recipeCost
				-- Components
				for i=1,3,1 do
					tipTrigger['component'..i] = itemInfo['component'..i]
				end
			end
			local tipTriggerImplode = JSON:encode(tipTrigger)

			if (channelType) and (channelType == 'pm') then
				if not mainUI.chatManager.pinnedChannels[channelID] then
					mainUI.chatManager.InitPrivateMessage(channelID, nil, channelName) -- Don't Create it if it exists..
				end
				
				GetWidget('main_chat_sleeper'):Sleep(1, function()
					GetWidget('main_chat_sleeper'):Sleep(1, function()
						if GetWidget('overlay_chat_pm' .. channelID .. '_input') then
							GetWidget('overlay_chat_pm' .. channelID .. '_input'):InputChatLink('i', tipTriggerImplode, '[' .. GetEntityDisplayName(itemInfoDrag.entityName) ..']'  )
						end
					end)
				end)
			
			elseif (channelType) and (channelType == 'channel') then
			
				if GetWidget('overlay_chat_channel' .. channelID .. '_input') then
					GetWidget('overlay_chat_channel' .. channelID .. '_input'):InputChatLink('i', tipTriggerImplode, '[' .. GetEntityDisplayName(itemInfoDrag.entityName) ..']'  )
				end		
			
			end
			
		end
		
	elseif (globalDragInfo.type == 20) then		-- match id / replay
	
	
	elseif (globalDragInfo.type == 21) then		-- hero build
			
		println("Spawn Hero Build Link, to " .. channelID)	
		
		local buildNum = extraData.buildNum

		local buildData = Links.GetBuildData(buildNum)
		if (buildData) then
			if (channelType) and (channelType == 'pm') then
				if not mainUI.chatManager.pinnedChannels[channelID] then
					mainUI.chatManager.InitPrivateMessage(channelID, nil, channelName) -- Don't Create it if it exists..
				end
				
				libThread.threadFunc(function()
					wait(1)
					if Windows.Chat.IM[channelID] then
						Windows.Chat.IM[channelID]:GetActiveInterface():GetWidget('overlay_chat_channel_window_input'):InputChatLink(unpack(buildData))
						Windows.Chat.IM[channelID]:GetActiveInterface():GetWidget('overlay_chat_channel_window_input'):ProcessInputLine()
					end
				end)
			elseif (channelType) and (channelType == 'channel') then
				if Windows.Chat.Channel[channelID] then
					Windows.Chat.Channel[channelID]:GetActiveInterface():GetWidget('overlay_chat_channel_window_input'):InputChatLink(buildData[1], buildData[2], buildData[3])
					Windows.Chat.Channel[channelID]:GetActiveInterface():GetWidget('overlay_chat_channel_window_input'):ProcessInputLine()
				end
			end
		end
		
	end

end

local function LinksRegister(object)
	
	-- object:RegisterWatchLua('ModifierKeyStatus', function(widget, trigger)
	-- end)
	
	object:RegisterWatchLua('ChatLinkClick', function(widget, trigger)

		local function decodeData()
			if trigger.data then
				return JSON:decode(trigger.data)
			else
				return false, nil
			end
		end			
		
		local decodeSuccess, decodedData = pcall(decodeData)

		if (decodeSuccess) and (decodedData) then
			if (decodedData.linkType == 'item') then
				if (LuaTrigger.GetTrigger('newPlayerExperience').craftingIntroProgress == 0) then
					GenericDialog(
						'crafting_link_tutorial_not_done', '', Translate('crafting_link_tutorial_not_done_desc'), 'general_ok', '',
							function()
							end,
							nil,
							true
					)
				else
					for i = 1, 3 do
						LuaTrigger.GetTrigger('mainPanelStatus').main = 1 -- crafting
						LuaTrigger.GetTrigger('mainPanelStatus'):Trigger(false)
						craftingSelectRecipe(decodedData.name)
						libThread.threadFunc(function()
							wait(1)
							Crafting.RemoveDesignComponent(i-1)
							if (decodedData['component'..i] ~= nil and not Empty(decodedData['component'..i]) ) then
								craftingAddComponentByName(decodedData['component'..i], i)
							end
							Crafting.SetDesignEmpoweredEffect(decodedData.currentEmpoweredEffectEntityName)
							craftingUpdateStage(9)
							LuaTrigger.GetTrigger('craftingStage').confirmedImbuement = true
							LuaTrigger.GetTrigger('craftingStage'):Trigger(false)
						end)
					end
				end
			elseif (decodedData.linkType == 'build') then
				local partyStatusTrigger 		= LuaTrigger.GetTrigger('PartyStatus')
				-- If not in a party, then get into a solo queue
				if not partyStatusTrigger.inParty then
					Party.OpenedPlayScreen()
					local mainPanelStatus = LuaTrigger.GetTrigger('mainPanelStatus')
					local selectionStatus = LuaTrigger.GetTrigger('selection_Status')
					mainPanelStatus.main				= 40
					mainPanelStatus:Trigger(false)
					selectionStatus.selectionSection = mainUI.Selection.selectionSections.HERO_PICK
					selectionStatus:Trigger(true)

					UnwatchLuaTriggerByKey('PartyStatus', 'partyOpen')
					WatchLuaTrigger('PartyStatus', function(trigger)
						if (partyStatusTrigger.inParty) then
							LoadBuildFromLink(decodedData.buildInfo.name, decodedData.buildInfo.heroEntity, decodedData.buildInfo, decodedData.abilityData, decodedData.itemData)
							UnwatchLuaTriggerByKey('PartyStatus', 'partyOpen')
						end
					end, 'partyOpen', 'inParty')
				else
					LoadBuildFromLink(decodedData.buildInfo.name, decodedData.buildInfo.heroEntity, decodedData.buildInfo, decodedData.abilityData, decodedData.itemData)
				end
			end
		end
	end)
	
	object:RegisterWatchLua('ChatLinkCreated', function(widget, trigger)
		
		local function decodeData()
			if trigger.data then
				return JSON:decode(trigger.data)
			else
				return false, nil
			end
		end			
		
		local decodeSuccess, decodedData = pcall(decodeData)
		
		if (decodeSuccess) and (decodedData) then	
			if (decodedData.linkType == 'item') then
				if (decodedData.isRare) then
					SetChatLinkColor(trigger.index, '#b712d6')
					SetChatLinkClickColor(trigger.index, '#b712d6')
				else
					SetChatLinkColor(trigger.index, '#3fd149')
					SetChatLinkClickColor(trigger.index, '#3fd149')
				end
			elseif (decodedData.linkType == 'build') then
				-- printr(decodedData)
				SetChatLinkColor(trigger.index, '#FF8833')
				SetChatLinkClickColor(trigger.index, '#FF8833')
			end
		end
	end)

	local isHovering = false
	object:RegisterWatchLua('ChatLinkMouseOut', function(widget, trigger)
		shopItemTipHide()
		isHovering = false
	end)

	object:RegisterWatchLua('ChatLinkMouseOver', function(widget, trigger)
		if isHovering then return end
		
		local function decodeData()
			if trigger.data then
				return JSON:decode(trigger.data)
			else
				return false, nil
			end
		end			
		
		local decodeSuccess, decodedData = pcall(decodeData)
		
		if (decodeSuccess) and (decodedData) then
			isHovering = true
			if (decodedData.linkType == 'item') then
				craftedItemTipPopulate(nil, true, nil, nil, true, true, decodedData)
				local trigger = LuaTrigger.GetTrigger('shopItemTipInfo')
				trigger.index = 1
				trigger.itemType = 'craftedItemInfoShop'
				trigger.isComponent = false
				trigger:Trigger(false)
			elseif (decodedData.linkType == 'build') then
			
			end
			
		end
		
	end)	
	
end

LinksRegister(object)
