-- Chat UI
Game = Game or {}
Game.Chat = Game.Chat or {}
mainUI = mainUI or {}
mainUI.savedLocally 	= mainUI.savedLocally 	or {}
mainUI.savedRemotely 	= mainUI.savedRemotely 	or {}

local function chatRegister(object)

	local inputTeam			= object:GetWidget('game_chat_team_input')
	local inputAll			= object:GetWidget('game_chat_all_input')
	local inputMentor		= object:GetWidget('game_chat_mentor_input')
	local specInputTeam		= object:GetWidget('game_spectator_chat_team_input')
	local specInputAll		= object:GetWidget('game_spectator_chat_all_input')
	local specInputMentor	= object:GetWidget('game_spectator_chat_mentor_input')

	local scrollBar			= object:GetWidget('gameChatScrollBar')
	local scrollPanel		= object:GetWidget('gameChatScrollPanel')
	
	local containers		= object:GetGroup('gameChatContainers')
	local chatType			= 'team'
	local endgameChatMode	= 'all'
	
	-- local typeLabel				= object:GetWidget('gameChatTypeLabel')
	local inputBox					= object:GetWidget('gameChatInputBox')
	local inputBoxEndgame			= object:GetWidget('gameChatInputBoxEndgame')
	local inputContainers			= object:GetGroup('gameChatInputContainers')
	local inputContainersEndgame	= object:GetGroup('gameChatInputContainersEndgame')
	local inputContainersEndgameLim	= object:GetGroup('gameChatInputContainersEndgameLimited')
	local typeLabelEndgame			= object:GetWidget('gameChatTypeLabelEndgame')
	
	
	local displaySlotMax	= 30
	local displaySlots		= {}
	local displaySlotPopulated	= {}
	local displayOrder			= {}
	local fadeTimes				= {}
	
	for i=1,displaySlotMax,1 do
		displaySlots[i] = {
		containers		= object:GetGroup('gameChatEntry'..i),
		PlayerName		= object:GetWidget('gameChatEntry'..i..'PlayerName'),
		IconParent		= object:GetWidget('gameChatEntry'..i..'_icon'),
		Icon			= object:GetWidget('gameChatEntry'..i..'Icon'),
		Mute			= object:GetWidget('gameChatEntry'..i..'Mute'),
		MuteBtn			= object:GetWidget('gameChatEntry'..i..'MuteBtn'),
		-- TypeLabel	= object:GetWidget('gameChatEntry'..i..'TypeLabel'),
		Message			= object:GetGroup('gameChatEntry'..i..'Message'),	-- Multiple so they all constrain height accordingly
		MessageLabel	= object:GetWidget('gameChatEntry'..i..'Message')	-- Set color on this one
		}
		displayOrder[displaySlotMax - i + 1] = i
	end
	
	
	local viewArea			= object:GetGroup('gameChatViewArea')
	local contentBody		= object:GetGroup('gameChatBody')
	local viewHeight		= viewArea[1]:GetHeight()
	local itemPadding		= libGeneral.HtoP(0.35)
	local scrollStep		= displaySlots[1].containers[1]:GetHeight() + styles_chatItemPadding
	local scrollPosition	= 0
	local scrollPositionMax	= 0
	local viewHistory		= false
	local typeStrings		= {	-- Localize later on
		team	= 'TEAM',
		all		= 'ALL',
		mentor	= 'MENT',
		server	= 'SVR',
		pm		= 'PM'
	}


	local function updateScrolling()
		local totalItems = 0
		local totalHeight = 0
		local scrollVisible = false
		for i=1,displaySlotMax,1 do
			if displaySlots[i].containers[1]:IsVisibleSelf() then
				if totalItems > 0 then
					totalHeight = totalHeight + styles_chatItemPadding
				end
				totalHeight = totalHeight + displaySlots[i].containers[1]:GetHeight()
				totalItems = totalItems + 1
			end
		end
		
		scrollPositionMax = math.ceil((totalHeight - viewHeight) / scrollStep)
		scrollVisible = (scrollPositionMax > 0 and viewHistory)
		scrollBar:SetVisible(scrollVisible)
		scrollPanel:SetVisible(scrollVisible)
		
		scrollBar:SetMaxValue(scrollPositionMax)
		if scrollPosition > scrollPositionMax then
			scrollPosition = scrollPositionMax
			scrollBar:SetValue(scrollPosition)
		end
		scrollPosition = scrollPositionMax
		scrollBar:SetValue(scrollPosition)
		
	end
	
	local function fadeAction(widget, trigger)
		hostTime = trigger.hostTime
		
		for k,v in pairs(fadeTimes) do
			if v < hostTime then
				for j,l in pairs(displaySlots[k].containers) do
					l:FadeOut(
						math.max(
							styles_chatFadeTime,
							styles_chatFadeTime - (v + hostTime)
						)
					)
				end
				fadeTimes[k] = nil
			end
		end

		if table.maxn(fadeTimes) <= 0 then
			viewArea[1]:UnregisterWatchLua('System')
		end
	end

	 local function fadeInit()
		if not viewHistory and table.maxn(fadeTimes) > 0 then
			if (not viewArea[1]:IsWatchRegisteredLua('System')) then
				viewArea[1]:RegisterWatchLua('System', fadeAction, false, nil, 'hostTime')
			end
		else
			viewArea[1]:UnregisterWatchLua('System')
		end
	end
	
	local function arrangeSlots()
		local displaySlotID = nil
		local displaySlot = nil
		local yPosition = 0
		local prevDisplaySlotID = 0
		local prevDisplaySlot =  nil
		for i=1,displaySlotMax,1 do
			displaySlotID = displayOrder[displaySlotMax - i + 1]
			displaySlot = displaySlots[displaySlotID]

			if i > 1 then
				prevDisplaySlotID = displayOrder[displaySlotMax - i + 2]
				prevDisplaySlot = displaySlots[prevDisplaySlotID]
				yPosition = (yPosition - prevDisplaySlot.containers[1]:GetHeight()) + 3
			else
				yPosition = 0
			end
			
			for k,v in pairs(displaySlot.containers) do
				v:SetY(yPosition)
			end
			
		end
	end
	
	local function cycleSlots()	-- Move the last slot up front before populating
		local newDisplayOrder = {}
		
		for i=2,displaySlotMax,1 do
			newDisplayOrder[i - 1] = displayOrder[i]
		end
		table.insert(newDisplayOrder, displayOrder[1])
		displayOrder = newDisplayOrder
	end

	-- Get my IdentId for use later
	local myIdentId = tonumber((string.gsub(tostring(LuaTrigger.GetTrigger('AccountInfo').identID), "%.", ""))) -- Extra braces are necessary here, gsub returns 2 values.
	IsMeTable = {}
	local function addEntry(message, messageColorR, messageColorG, messageColorB, senderName, playerNameColorR, playerNameColorG, playerNameColorB, entityIcon, chatType, identID, playerIndex)
	
		local lastOrderID	= nil
		local displaySlot	= nil
		
		cycleSlots()
		
		lastOrderID		= displayOrder[displaySlotMax]
		displaySlot		= displaySlots[lastOrderID]
		if displaySlot then
			
			displaySlot.Icon:SetTexture(entityIcon)
			-- displaySlot.TypeLabel:SetText(chatType)
			displaySlot.PlayerName:SetText(senderName)
			displaySlot.PlayerName:SetColor(playerNameColorR, playerNameColorG, playerNameColorB)
			for k,v in pairs(displaySlot.Message) do
				v:SetText(message)
			end

			displaySlot.MessageLabel:SetColor(messageColorR, messageColorG, messageColorB)
			for k,v in pairs(displaySlot.containers) do
				v:SetVisible(true)
			end
			displaySlotPopulated[lastOrderID] = true
			if fadeTimes[lastOrderID] == nil then
				fadeTimes[lastOrderID] = GetTime() + styles_chatMaxDisplayTime
			end
			
			if (identID) then
				if  (ChatClient.IsIgnored(identID)) then
					displaySlot.Mute:SetTexture('/ui/_textures/icons/chat_muted.tga')
				else
					displaySlot.Mute:SetTexture('/ui/game/unit_frames/textures/chat.tga')
				end
			end
			
			displaySlot.IconParent:SetCallback('onmouseover', function(widget, showChatHistory)
				--displaySlot.Mute:SetVisible(1)
				displaySlot.Mute:SetColor('1 1 1 1')
			end)
			displaySlot.IconParent:SetCallback('onmouseout', function(widget, showChatHistory)
				--displaySlot.Mute:SetVisible(0)
				displaySlot.Mute:SetColor('1 1 1 0.1')
			end)	
			
			displaySlot.Mute:SetCallback('onmouseover', function(widget, showChatHistory)
				--displaySlot.Mute:SetVisible(1)
				displaySlot.Mute:SetColor('1 1 1 1')
			end)
			displaySlot.Mute:SetCallback('onmouseout', function(widget, showChatHistory)
				--displaySlot.Mute:SetVisible(0)
				displaySlot.Mute:SetColor('1 1 1 0.1')
			end)		

			if (identID) and identID ~= myIdentId and (playerIndex) then
				local function setMuted(muted)
					if  (muted) then
						displaySlot.Mute:SetTexture('/ui/_textures/icons/chat_muted.tga')
					else
						displaySlot.Mute:SetTexture('/ui/game/unit_frames/textures/chat.tga')
					end
				end
			
				local triggerPrefix = "AllyUnit"
				local index = playerIndex
				if index > 4 then
					triggerPrefix = "EnemyUnit"
				end
				for i = 0, 4 do
					if tonumber((string.gsub(tostring(LuaTrigger.GetTrigger(triggerPrefix..i).identID), "%.", ""))) == identID then
						index = i
						break
					end
				end
				local ident = LuaTrigger.GetTrigger(triggerPrefix..index).identID
				
				displaySlot.Mute:SetCallback('onclick', function(widget, showChatHistory)
					UIMute(playerIndex, ident, playerIndex, senderName, '0') -- RMM I think this index is the wrong one for mute
				end)
				setMuted(ChatClient.IsIgnored(ident))
				displaySlot.Mute:UnregisterWatchLua('mutePlayerInfo')
				displaySlot.Mute:RegisterWatchLua('mutePlayerInfo', function(widget, trigger)
					if (trigger.IdentID == ident) then
						setMuted(trigger.muted)
					end
				end)
			end
			IsMeTable[displaySlot] = (identID == myIdentId)
		end
		
		arrangeSlots()
		updateScrolling()
		fadeInit()
	end
	
	object:RegisterWatch('chatHistoryVisible', function(widget, showChatHistory)
		viewHistory = AtoB(showChatHistory)
		if viewHistory then
			fadeInit()
			for i=1,displaySlotMax,1 do
				if displaySlotPopulated[i] then
					for k,v in pairs(displaySlots[i].containers) do
						v:FadeIn(0)
						v:SetVisible(true)	
						v:SetNoClick(1)						
					end
					displaySlots[i].IconParent:SetNoClick(0)
					if (not IsMeTable[displaySlots[i]]) then
						displaySlots[i].Mute:SetVisible(true)
					end
					displaySlots[i].Mute:SetColor('1 1 1 0.1')
				end
			end
			updateScrolling()
		else
			for i=1,displaySlotMax,1 do
				if fadeTimes[i] then
					for k,v in pairs(displaySlots[i].containers) do
						v:FadeIn(0)
						v:SetVisible(true)
						v:SetNoClick(1)	
					end
					displaySlots[i].IconParent:SetNoClick(1)
				else
					for k,v in pairs(displaySlots[i].containers) do
						v:FadeOut(0)
						v:SetVisible(false)
						v:SetNoClick(1)	
					end
					displaySlots[i].IconParent:SetNoClick(1)
				end
				displaySlots[i].Mute:SetVisible(false)
			end
			updateScrolling()
			fadeInit()
		end
	end)
	
	
	--[==[
	local function showChatHistory()
		viewHistory = true
		fadeInit()
		for i=1,displaySlotMax,1 do
			if displaySlotPopulated[i] then
				for k,v in pairs(displaySlots[i].containers) do
					v:FadeIn(0)
					v:SetVisible(true)				
				end
			end
		end
		updateScrolling()
		
		-- ===== Game Events =====
		
		--[[
		gameUI.events.viewHistory = true
		gameUI.events.fadeInit()
		for i=1,gameUI.events.displaySlotMax,1 do
			if gameUI.events.displaySlotPopulated[i] then
				gameUI.events.displaySlots[i].root:FadeIn(0)
				gameUI.events.displaySlots[i].root:SetVisible(true)
			end
		end
		gameUI.events.updateScrolling()
		--]]
	end

	local function hideChatHistory()
		viewHistory = false
		for i=1,displaySlotMax,1 do
			if fadeTimes[i] then
				for k,v in pairs(displaySlots[i].containers) do
					v:FadeIn(0)
					v:SetVisible(true)
				end
			else
				for k,v in pairs(displaySlots[i].containers) do
					v:FadeOut(0)
					v:SetVisible(false)
				end

			end
		end
		updateScrolling()
		fadeInit()
		
		-- ===== Game Events =====
		
		--[[
		gameUI.events.viewHistory = false
		for i=1,gameUI.events.displaySlotMax,1 do
			if gameUI.events.fadeTimes[i] then
				gameUI.events.displaySlots[i].root:FadeIn(0)
				gameUI.events.displaySlots[i].root:SetVisible(true)
			else
				gameUI.events.displaySlots[i].root:FadeOut(0)
				gameUI.events.displaySlots[i].root:SetVisible(false)
			end
		end
		gameUI.events.updateScrolling()
		gameUI.events.fadeInit()
		--]]
	end
	
	--]==]
	
	-- ==========================================================================================

	local allowedEndGameMessages = {
		'end_game_message_string_1',
		'end_game_message_string_2',
		'end_game_message_string_3',
		'end_game_message_string_4',
		'end_game_message_string_5',
	}
	
	function AllStrifeChatMessages(widget, trigger)
		local senderRelation	= trigger.senderRelation
		local messageType		= trigger.type
		local typeString		= ''
		local identID 			= trigger.identID
		local playerIndex 		= trigger.playerIndex
		local allChatEnabled = LuaTrigger.GetTrigger('GameInfo').allChatEnabled
		
		-- trigger.channel = 
		-- trigger.playerIndex = 0.0000
		-- trigger.timestamp = 

		if senderRelation == 1 or senderRelation == 4 or messageType == 2 or senderRelation == 5 then
			--[[
			local showTime			= math.max(
				styles_chatMinDisplayTime,
				math.min(
					styles_chatMaxDisplayTime,
					string.len(message) * (styles_chatMaxDisplayTime / styles_chatMaxCharsExpected)
				)
			)
			--]]
			
			local entity			= trigger.entityName
			local senderName		= trigger.senderName
			local message			= trigger.message	
			local playerNameColorR	= 1
			local playerNameColorG	= 1
			local playerNameColorB	= 1
			local messageColorR		= 1
			local messageColorG		= 1
			local messageColorB		= 1
			
			if (identID) and (ChatClient.IsIgnored(identID)) then
				return
			end
			
			if senderRelation == 1 or senderRelation == 4 then	-- ally or self
				if senderRelation == 1 then	-- Self
					playerNameColorR = styles_chatNameColorSelfR
					playerNameColorG = styles_chatNameColorSelfG
					playerNameColorB = styles_chatNameColorSelfB
				else	-- Ally
					playerNameColorR = styles_chatNameColorAllyR
					playerNameColorG = styles_chatNameColorAllyG
					playerNameColorB = styles_chatNameColorAllyB
				end
			else	-- Enemy
				playerNameColorR = styles_chatNameColorEnemyR
				playerNameColorG = styles_chatNameColorEnemyG
				playerNameColorB = styles_chatNameColorEnemyB
			end
			
			if messageType == 2 and string.len(senderName) == 0 then
				senderName = 'Server'
				if string.find(string.lower(message), string.lower(Translate('general_pause')), 1, true) then
					-- RMM Allow pause server messages or handle another way
				else
					return -- RMM Disabled all server messages
				end
			end
			
			if messageType == 3 then	-- Team
				typeString = typeStrings.team
				messageColorR = styles_chatMessageColorTeamR
				messageColorG = styles_chatMessageColorTeamG
				messageColorB = styles_chatMessageColorTeamB
			else	-- All
				typeString = typeStrings.all
				messageColorR = styles_chatMessageColorAllR
				messageColorG = styles_chatMessageColorAllG
				messageColorB = styles_chatMessageColorAllB
			end
			
			local entityIcon = nil
			if string.len(entity) > 0 then
				entityIcon = GetEntityIconPath(entity)
			else
				playerNameColorR = styles_chatNameColorSpectatorR
				playerNameColorG = styles_chatNameColorSpectatorG
				playerNameColorB = styles_chatNameColorSpectatorB
				entityIcon = styles_chatIconSpectator
			end

			if IsInTable(allowedEndGameMessages, message) then
				message = Translate(message)
				addEntry(
					message,
					messageColorR,
					messageColorG,
					messageColorB,
					senderName,
					playerNameColorR,
					playerNameColorG,
					playerNameColorB,
					entityIcon,
					typeString,
					identID,
					playerIndex
				)	
			elseif (allChatEnabled) or (messageType == 2 or messageType == 3 or senderRelation == 1 or senderRelation == 4) then		
				addEntry(
					message,
					messageColorR,
					messageColorG,
					messageColorB,
					senderName,
					playerNameColorR,
					playerNameColorG,
					playerNameColorB,
					entityIcon,
					typeString,
					identID,
					playerIndex
				)				
			end	
			
		end
	end
	
	object:RegisterWatchLua('AllStrifeChatMessages', AllStrifeChatMessages)


	local function inputVisEndgame(showInput)
		for k,v in pairs(inputContainersEndgame) do
			v:SetVisible(showInput)
		end
		Trigger('chatHistoryVisible', tostring(showInput))
	end	
	
	local function inputVisEndgameLim(showInput)
		for k,v in pairs(inputContainersEndgameLim) do
			v:SetVisible(showInput)
		end
		Trigger('chatHistoryVisible', tostring(showInput))
	end
	
	local function inputVis(showInput)
		for k,v in pairs(inputContainers) do
			v:SetVisible(showInput)
		end
		Trigger('chatHistoryVisible', tostring(showInput))
	end

	local function setInputType(useChatType, widget)
		widget:SetFocus(false)
		local gamePhase	= LuaTrigger.GetTrigger('GamePhase').gamePhase
		local allChatEnabled = LuaTrigger.GetTrigger('GameInfo').allChatEnabled
		if	(allChatEnabled and LuaTrigger.GetTrigger('ModifierKeyStatus').shift) then		
			chatType = 'all'
			inputBoxEndgame:SetFocus(true)
			inputVisEndgame(true)	
		elseif	(gamePhase >= 7) then		
			chatType = 'team'
			inputBox:SetFocus(true)
			inputVis(true)				
			inputVisEndgameLim(true)				
		else
			chatType = 'team'
			inputBox:SetFocus(true)
			inputVis(true)	
		end
		--println('chatType ' .. chatType)
	end
	
	-- Hide channel label if all chat isn't enabled.
	object:GetWidget('gameChatInputChannelContainer'):RegisterWatchLua('GameInfo', function(widget, trigger)
		if (not trigger.allChatEnabled) then
			inputBox:SetWidth("-1h")
			widget:SetVisible(false)
		end
	end, false, nil, 'allChatEnabled')
	
	
	inputTeam:SetCallback( 'onfocus', function(widget) setInputType('team', widget) end )
	inputAll:SetCallback( 'onfocus', function(widget) setInputType('all', widget) end )
	inputMentor:SetCallback( 'onfocus', function(widget) setInputType('mentor', widget) end )

	specInputTeam:SetCallback( 'onfocus', function(widget) setInputType('team', widget) end )
	specInputAll:SetCallback( 'onfocus', function(widget) setInputType('all', widget) end )
	specInputMentor:SetCallback( 'onfocus', function(widget) setInputType('mentor', widget) end )
	
	scrollPanel:SetCallback(
		'onmousewheeldown', function(widget)
			if scrollPosition < scrollPositionMax then
				scrollPosition = math.min(scrollPosition + 1, scrollPositionMax)
				scrollBar:SetValue(scrollPosition)
			end
		end
	)

	scrollPanel:SetCallback(
		'onmousewheelup', function(widget)
			if scrollPosition > 0 then
				scrollPosition = math.max(scrollPosition - 1, 0)
				scrollBar:SetValue(scrollPosition)
			end
		end
	)

	scrollBar:SetCallback(
		'onslide', function(widget)
			scrollPosition = AtoN(widget:GetValue())
			for k,v in pairs(contentBody) do
				v:SetY( (scrollPositionMax - scrollPosition) * scrollStep )
			end
		end
	)
	
	LocalPlayer.SetTyping(false)
	
	inputBox:SetCallback('onfocus', function(widget)
		LocalPlayer.SetTyping(true)
	end)

	inputBox:SetCallback('onlosefocus', function(widget)
		LocalPlayer.SetTyping(false)
		mainUI.SlashCommands.UpdateTargetElement(false)
	end)

	inputBox:SetCallback('onhide', function(widget)
		LocalPlayer.SetTyping(false)
		mainUI.SlashCommands.UpdateTargetElement(false)
	end)
	
	inputBoxEndgame:SetCallback('onfocus', function(widget)
		LocalPlayer.SetTyping(true)
	end)

	inputBoxEndgame:SetCallback('onlosefocus', function(widget)
		LocalPlayer.SetTyping(false)
		mainUI.SlashCommands.UpdateTargetElement(false)
	end)
	
	inputBoxEndgame:SetCallback('onhide', function(widget)
		LocalPlayer.SetTyping(false)
		mainUI.SlashCommands.UpdateTargetElement(false)
	end)	
	
	inputBox:RegisterWatch(
		'GameChatBoxEnter', function(widget)
			if chatType == 'team' then
				ChatWindow.TeamChat(widget:GetValue())
			elseif chatType == 'all' then
				ChatWindow.AllChat(widget:GetValue())
			end
			widget:EraseInputLine()
			widget:SetFocus(false)
			inputVis(false)
			inputVisEndgameLim(false)
			LocalPlayer.SetTyping(false)
			mainUI.SlashCommands.UpdateTargetElement(false)
		end
	)

	inputBoxEndgame:RegisterWatch(
		'GameChatBoxEnterEndgame', function(widget)
			if endgameChatMode == 'team' then
				ChatWindow.TeamChat(widget:GetValue())
			elseif endgameChatMode == 'all' then
				ChatWindow.AllChat(widget:GetValue())
			end
			widget:EraseInputLine()
			widget:SetFocus(false)
			inputVisEndgame(false)
			inputVisEndgameLim(false)
			LocalPlayer.SetTyping(false)
			mainUI.SlashCommands.UpdateTargetElement(false)
		end
	)
	
	inputBoxEndgame:RegisterWatch(
		'GameChatBoxEscEndgame', function(widget)
			widget:EraseInputLine()
			widget:SetFocus(false)
			inputVisEndgame(false)
			inputVisEndgameLim(false)
			LocalPlayer.SetTyping(false)
			mainUI.SlashCommands.UpdateTargetElement(false)
		end
	)
	
	
	inputBox:RegisterWatch(
		'GameChatBoxEsc', function(widget)
			widget:EraseInputLine()
			widget:SetFocus(false)
			inputVis(false)
			inputVisEndgameLim(false)
			LocalPlayer.SetTyping(false)
			mainUI.SlashCommands.UpdateTargetElement(false)
		end
	)
	
	scrollPosition = scrollPositionMax
	scrollBar:SetValue(scrollPosition)
	
	-- libGeneral.createGroupTrigger('gameChatPosition', { 'ShopActive', 'backpackVertVis', 'ModifierKeyStatus' })
	object:GetWidget('gameChatContainer'):RegisterWatchLua('GamePhase', function(widget, gamePhaseTrigger)
		if (gamePhaseTrigger.gamePhase == 7) then
			for k,v in pairs(containers) do
				
				local allChatEnabled = LuaTrigger.GetTrigger('GameInfo').allChatEnabled
				
				if (allChatEnabled) then

					v:RegisterWatchLua('gamePanelInfo', function(widget, trigger)

						local targX			= libGeneral.HtoP(55)
						local targY			= -1 * libGeneral.HtoP(0.2)

						v:SlideX(targX, styles_uiSpaceShiftTime)
						v:SlideY(targY, styles_uiSpaceShiftTime)
						
					end, false, nil, 'moreInfoKey', 'heroVitalsVis', 'lanePusherVis', 'channelBarVis', 'respawnBarVis')

					local targX			= libGeneral.HtoP(55)
					local targY			= -1 * libGeneral.HtoP(0.2)				
				
					v:SlideX(targX, styles_uiSpaceShiftTime)
					v:SlideY(targY, styles_uiSpaceShiftTime)
				
				else
				
					v:RegisterWatchLua('gamePanelInfo', function(widget, trigger)

						local targX			= libGeneral.HtoP(55)
						local targY			= -1 * libGeneral.HtoP(3.7)

						v:SlideX(targX, styles_uiSpaceShiftTime)
						v:SlideY(targY, styles_uiSpaceShiftTime)
						
					end, false, nil, 'moreInfoKey', 'heroVitalsVis', 'lanePusherVis', 'channelBarVis', 'respawnBarVis')

					local targX			= libGeneral.HtoP(55)
					local targY			= -1 * libGeneral.HtoP(3.7)				
				
					v:SlideX(targX, styles_uiSpaceShiftTime)
					v:SlideY(targY, styles_uiSpaceShiftTime)
					
				end
			end

			-- addEntry(
				-- Translate('game_chat_endgame_announcement'),
				-- 1,
				-- 1,
				-- 1,
				-- '',
				-- 1,
				-- 1,
				-- 1,
				-- '/ui/main/shared/textures/acct_type_igames.tga',
				-- 'ALL',
				-- nil,
				-- nil
			-- )			
			
		else
			for k,v in pairs(containers) do
				
				v:RegisterWatchLua('gamePanelInfo', function(widget, trigger)

					local targX			= styles_gameChatContainerX
					local targY			= -16.5

					if (trigger.moreInfoKey or trigger_gamePanelInfo.heroVitalsVis) then
						targY = targY - 3.8
					end

					if (trigger.lanePusherVis) then
						targY = targY - 3.8
					end			

					if (trigger.channelBarVis) or (trigger.respawnBarVis) then
						targY = targY - 3.8
					end			
					
					v:SlideX(targX, styles_uiSpaceShiftTime)
					v:SlideY(libGeneral.HtoP(targY), styles_uiSpaceShiftTime)
				end, false, nil, 'moreInfoKey', 'heroVitalsVis', 'lanePusherVis', 'channelBarVis', 'respawnBarVis')
				
				local targX			= styles_gameChatContainerX
				local targY			= -16.5

				if (trigger_gamePanelInfo.heroVitalsVis) then
					targY = targY - 3.8
				end

				v:SlideX(targX, styles_uiSpaceShiftTime)
				v:SlideY(libGeneral.HtoP(targY), styles_uiSpaceShiftTime)			
				
			end		
		end
	end)
			
	local chatPMLastTime	= {}
	local chatPMThrottle	= 5000		
		
	object:RegisterWatchLua('ChatPrivateMessage', function(widget, trigger) 
		local channelID					 = tostring(trigger.senderIdentID)
			
		if (not channelID) then
			return
		end
		
		mainUI 								= mainUI or {}
		mainUI.chatManager 					= mainUI.chatManager or {}
		mainUI.chatManager.activeChannels 	= mainUI.chatManager.activeChannels or {}
		mainUI.chatManager.pinnedChannels 	= mainUI.chatManager.pinnedChannels or {}
		
		if IsMe(trigger.senderIdentID) then
			addEntry(
				trigger.message or '',
				'1',
				'0.7',
				'1',
				'->' .. trigger.receiverName,
				'0.7',
				'0',
				'0.7',
				'/ui/main/friends/textures/social.tga',
				'PM',
				trigger.senderIdentID,
				nil
			)	
		elseif IsOpponent(trigger.senderIdentID) then
			-- don't show this message
		elseif (not GetCvarBool('ui_whisperRequiresFriendship') or ChatClient.IsFriend(trigger.senderIdentID)) then
			if (not mainUI.chatManager.activeChannels[channelID]) then
				mainUI.chatManager.activeChannels[channelID] = {trigger.senderName, channelID, false, 'pm'}	
				mainUI.chatManager.pinnedChannels[channelID] = false
			end
				
			addEntry(
				trigger.message or '',
				'1',
				'0.5',
				'1',
				trigger.senderName .. '->',
				'0.5',
				'0',
				'0.5',
				'/ui/main/friends/textures/social.tga',
				'PM',
				trigger.senderIdentID,
				nil
			)
			
			local thisTime = GetTime()
			if (not chatPMLastTime['pm'..channelID]) or (thisTime > chatPMLastTime['pm'..channelID] + chatPMThrottle) then
				chatPMLastTime['pm'..channelID] = thisTime
				PlaySound('/ui/sounds/social/sfx_chat_new.wav')
			end
		else
			-- don't show this message
		end
	end)
	
	mainUI.SlashCommands.RegisterInput(inputBox)
	mainUI.SlashCommands.RegisterInput(inputBoxEndgame)

end


chatRegister(object)
