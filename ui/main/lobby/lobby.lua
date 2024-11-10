-- Lobby Manager
mainUI = mainUI or {}
Lobby = Lobby or {}
Lobby.isFilledWithBots = false
local tinsert, tremove, tsort = table.insert, table.remove, table.sort
ClientInfo = ClientInfo or {}
ClientInfo.duplicateUsernameTable = ClientInfo.duplicateUsernameTable or {}
local interface = object

local lobbyTrigger = LuaTrigger.CreateCustomTrigger('lobbyTrigger',
	{
		{ name	= 'isLobbyLeader',				type	= 'boolean' },
		{ name	= 'inLobby',					type	= 'boolean' },
		{ name	= 'lobbyOpen',					type	= 'boolean' },
		{ name	= 'draggingSlot',				type	= 'number' },
		{ name	= 'draggingSlotTeam',			type	= 'number' },
		{ name	= 'draggingSlotClient',			type	= 'number' },
		
	}
)
local clientInfoDrag	= LuaTrigger.GetTrigger('clientInfoDrag')

local function isPlayerInLobby(playerName, playerUniqueID, identID)
	local isInLobby = false
	for index = 0,9, 1 do
		local infoTrigger = LuaTrigger.GetTrigger('LobbyPlayerInfo'..index)
		if ( (infoTrigger.playerName == playerName) and (infoTrigger.playerUniqueID == playerUniqueID) ) or (infoTrigger.identID == identID) then
			isInLobby = true
			break
		end
		infoTrigger = LuaTrigger.GetTrigger('LobbySpectators'..index)
		if ( (infoTrigger.playerName == playerName) and (infoTrigger.playerUniqueID == playerUniqueID) ) or (infoTrigger.identID == identID) then
			isInLobby = true
			break
		end		
	end
	return isInLobby
end

local function gameLobbySpectatorSeatRegister(object, index)
	local container		= object:GetWidget('lobby_entryspec_'..index)
	local icon			= object:GetWidget('lobby_entryspec_'..index..'UserIcon')
	local button		= object:GetWidget('lobby_entryspec_'..index..'UserButton')
	local playerName	= object:GetWidget('lobby_entryspec_'..index..'UserName')
	local darken		= object:GetWidget('lobby_entryspec_'..index..'UserDarken')
	local dropTarget	= object:GetWidget('lobby_entryspec_'..index..'DropTarget')

	local hasPlayer		= false
	
	button:SetCallback('onclick', function(widget)
		-- lobbyJoinSpectatorSlot
		-- PlaySound('/path_to/filename.wav')
	
		interface:UICmd("Team(0)")
		ClearDrag()	
	end)
	
	button:RegisterWatchLua('LobbyStatus', function(widget, trigger)
		widget:SetCallback('onrightclick', function()
			local infoTrigger = LuaTrigger.GetTrigger('LobbySpectators'..index)
			if trigger.isHost and infoTrigger.clientNum >= 0 then
				-- lobbyRightclickSpectatorOpenMenu
				-- PlaySound('/path_to/filename.wav')
				lobbyRightClickOpen(infoTrigger.clientNum, index, 0, infoTrigger.identID)
			end
		end)	
	end)
	
	icon:RegisterWatchLua('LobbySpectators'..index, function(widget, trigger)
		if (not Empty(trigger.playerName)) then
			widget:SetTexture('/ui/shared/textures/user_icon.tga')
		else
			widget:SetTexture('$invis')
		end
	end)	
	icon:SetTexture('$invis')
	
	container:RegisterWatchLua('LobbyTeamInfo0', function(widget, trigger)
		if (index <= (trigger.maxPlayers - 1)) then
			widget:SetVisible(1)
		else
			widget:SetVisible(0)
		end
	end, false, nil, 'maxPlayers')
	
	playerName:RegisterWatchLua('LobbySpectators'..index, function(widget, trigger)
		if (not Empty(trigger.playerName)) then
		
			if not hasPlayer then
				-- mainLobbyPlayerEnteredSpecSlot
				-- PlaySound('/path_to/filename.wav')
			end
			hasPlayer = true
		
			widget:SetText(trigger.playerName)
			widget:SetColor('1 1 1 1')
		else
		
			if hasPlayer then
				-- mainLobbyPlayerLeftSpecSlot
				-- PlaySound('/path_to/filename.wav')
			end
			hasPlayer = false
		
			widget:SetText(Translate('temp_gamelobby_team3_slot', 'value', index))
			widget:SetColor('.4 .4 .4 1')
		end
		
	end)
	
	playerName:SetText(Translate('temp_gamelobby_team3_slot', 'value', index))
	playerName:SetColor('.4 .4 .4 1')
	
	button:SetCallback('onmouseover', function(widget)
		UpdateCursor(widget, true, { canLeftClick = true, canRightClick = true, canDrag = true })
	end)

	button:SetCallback('onmouseout', function(widget)
		UpdateCursor(widget, false, { canLeftClick = true, canRightClick = true, canDrag = true })
	end)		
	
	button:RegisterWatchLua('LobbySpectators'..index, function(widget, trigger)
		
		widget:SetEnabled(1)
		
		darken:UnregisterWatchLua('clientInfoDrag')
		darken:RegisterWatchLua('clientInfoDrag', function(widget, trigger2)
			widget:SetVisible(trigger2.dragActive and trigger2.clientDraggingName == trigger.playerName and trigger2.clientDraggingUniqueID == trigger.playerUniqueID)
		end, false, nil, 'clientDraggingName', 'clientDraggingUniqueID', 'dragActive')	
	
		widget:SetCallback('onstartdrag', function(widget)
			-- lobbyStartDraggingSpectatorSlot
			-- PlaySound('/path_to/filename.wav')

			lobbyTrigger.draggingSlot					= index
			lobbyTrigger.draggingSlotClient				= trigger.clientNum
			lobbyTrigger.draggingSlotTeam				= 0
			lobbyTrigger:Trigger(false)		
			clientInfoDrag.clientDraggingName			= trigger.playerName
			clientInfoDrag.clientDraggingUniqueID		= trigger.playerUniqueID
			clientInfoDrag.clientDraggingIdentID		= trigger.identID
			clientInfoDrag.clientDraggingCanSpectate	= false
			clientInfoDrag.clientDraggingIsFriend		= ChatClient.IsFriend(trigger.identID)
			clientInfoDrag.clientDraggingIsOnline		= true
			clientInfoDrag.dragActive					= true
			clientInfoDrag:Trigger(false)
		end)
		
		widget:SetCallback('onenddrag', function(widget)
	
			clientInfoDrag.dragActive			= false
			clientInfoDrag:Trigger(false)
		end)	
		 
		if (ChatClient.IsFriend(trigger.identID)) then
			globalDraggerRegisterSource(widget, 12)
		else
			globalDraggerRegisterSource(widget, 11)
		end
	
	end)		
	
end

local function gameLobbyPlayerSeatRegister(object, index, teamID, triggerLobbyStatus)
	local container		= object:GetWidget('lobby_entry'..index)
	local button		= object:GetWidget('lobby_entry'..index..'UserButton')
	local icon			= object:GetWidget('lobby_entry'..index..'UserIcon')
	local name			= object:GetWidget('lobby_entry'..index..'UserName')
	local darken		= object:GetWidget('lobby_entry'..index..'UserDarken')
	local dropTarget	= object:GetWidget('lobby_entry'..index..'DropTarget')
	-- local group		= object:GetWidget('lobby_entry'..index..'UserGroup')
	
	local lobbyStatus	= LuaTrigger.GetTrigger('LobbyStatus')
	local infoTrigger	= LuaTrigger.GetTrigger('LobbyPlayerInfo'..index)
	
	icon:RegisterWatchLua('LobbyPlayerInfo'..index, function(widget, trigger)
		if (trigger.isBot) then	-- bot icon
			widget:SetTexture('/ui/shared/textures/bot.tga')
			widget:SetColor('1 1 1 1')
		elseif (not Empty(trigger.playerName)) then -- player icon or default
			if (trigger.isHost) then
				widget:SetTexture('/ui/shared/shop/filters/all_3.tga')
				widget:SetColor('1 1 1 1')					
			elseif Empty(trigger.accountIconPath) then
				widget:SetTexture('/ui/shared/textures/user_icon.tga')
				widget:SetColor('1 1 1 1')
			else
				widget:SetTexture(trigger.accountIconPath)
				widget:SetColor('1 1 1 1')
			end
		else	-- no one in slot icon
			widget:SetTexture('/ui/shared/textures/drag_target.tga')
			widget:SetColor('1 1 1 .3')
		end
	end, false, nil, 'accountIconPath', 'isBot', 'playerName', 'isHost')
	
	local hasPlayer = false
	
	name:RegisterWatchLua('LobbyPlayerInfo'..index, function(widget, trigger)
		
		local playerName = trigger.playerName
		
		if (playerName) and (not Empty(playerName)) then
		
			if not hasPlayer then
				-- mainLobbyPlayerEnteredSlot
				-- PlaySound('/path_to/filename.wav')
			end
			hasPlayer = true

			if (mainUI.savedRemotely.friendDatabase) and (mainUI.savedRemotely.friendDatabase[trigger.identID]) and (mainUI.savedRemotely.friendDatabase[trigger.identID].nicknameOverride) then
				playerName = mainUI.savedRemotely.friendDatabase[trigger.identID].nicknameOverride
			end			
		
			if (ClientInfo.duplicateUsernameTable[playerName]) then
				if (not IsInTable(ClientInfo.duplicateUsernameTable[playerName], trigger.playerUniqueID)) then
					tinsert(ClientInfo.duplicateUsernameTable[playerName], trigger.playerUniqueID)
				end
			else
				ClientInfo.duplicateUsernameTable[playerName] = {trigger.playerUniqueID}
			end			
			
			if (#ClientInfo.duplicateUsernameTable[playerName] > 1) then
				playerName = playerName .. '.' .. trigger.playerUniqueID
			end

			if (trigger) and (trigger.clanTag) and (not Empty(trigger.clanTag)) then
				playerName = (('[' .. (trigger.clanTag or '') ..']') .. (trigger.playerName or ''))
			end				
			
		else
			if hasPlayer then
				-- mainLobbyPlayerLeftSlot
				-- PlaySound('/path_to/filename.wav')
			end
			hasPlayer = false
			
			
		end
		
		if (not trigger.isBot) then
			if (not Empty(playerName)) then
				if (trigger.isHost) then
					widget:SetText(playerName)
					widget:SetColor('1 1 0.4 1')
					widget:SetY('1s')		
				else
					widget:SetText(playerName)
					widget:SetColor('1 1 1 1')
					widget:SetY('1s')				
				end
			else
				widget:SetText(Translate('temp_gamelobby_team' .. teamID .. '_slot', 'value', index))
				widget:SetColor('.4 .4 .4 1')
				widget:SetY('7s')
			end
		else
			widget:SetText(Translate('general_bot'))
			widget:SetColor('.7 .7 .7 1')
		end
	end, false, nil, 'playerName', 'isBot', 'isHost')
	
	container:RegisterWatchLua('LobbyTeamInfo'..teamID, function(widget, trigger)
		local playerMod = 0
		if teamID == 2 then playerMod = 5 end
		widget:SetVisible((index - playerMod + 1) <= trigger.maxPlayers)
	end, false, nil, 'maxPlayers')

	button:SetCallback('onclick', function(widget)
		local slot = index
		if teamID == 2 then slot = slot - 5 end
		
		if infoTrigger.clientNum < 0 then
			-- lobbyPlayerTakesSeat
			PlaySound('/ui/sounds/ui_joinmatch_%.wav')
			interface:UICmd("Team("..teamID..", "..slot..")")
			ClearDrag()		
		end
	end)
	
	button:SetCallback('onrightclick', function(widget)
		if lobbyStatus.isHost and infoTrigger.clientNum >= 0 then
			-- lobbyRightclickPlayerOpenMenu
			-- PlaySound('/path_to/filename.wav')
			lobbyRightClickOpen(infoTrigger.clientNum, index, teamID, infoTrigger.identID)
		end
	end)
	
	button:SetCallback('onmouseover', function(widget)
		UpdateCursor(widget, true, { canLeftClick = true, canRightClick = true, canDrag = true })
	end)

	button:SetCallback('onmouseout', function(widget)
		UpdateCursor(widget, false, { canLeftClick = true, canRightClick = true, canDrag = true })
	end)		
	
	button:RegisterWatchLua('LobbyPlayerInfo'..index, function(widget, trigger)
	
		darken:UnregisterWatchLua('clientInfoDrag')
		darken:RegisterWatchLua('clientInfoDrag', function(widget, trigger2)
			widget:SetVisible(trigger2.dragActive and trigger2.clientDraggingName == trigger.playerName and trigger2.clientDraggingUniqueID == trigger.playerUniqueID)
		end, false, nil, 'clientDraggingName', 'clientDraggingUniqueID', 'dragActive')	
	
		widget:SetCallback('onstartdrag', function(widget)
		
			-- lobbyStartDraggingPlayerSlot
			-- PlaySound('/path_to/filename.wav')
		
			lobbyTrigger.draggingSlot					= index
			lobbyTrigger.draggingSlotClient				= trigger.clientNum
			lobbyTrigger.draggingSlotTeam				= teamID
			lobbyTrigger:Trigger(false)
			clientInfoDrag.clientDraggingName			= trigger.playerName
			clientInfoDrag.clientDraggingUniqueID		= trigger.playerUniqueID
			clientInfoDrag.clientDraggingIdentID		= trigger.identID
			clientInfoDrag.clientDraggingCanSpectate	= false
			clientInfoDrag.clientDraggingIsFriend		= ChatClient.IsFriend(trigger.identID)
			clientInfoDrag.clientDraggingIsOnline		= true
			clientInfoDrag.dragActive					= true
			clientInfoDrag:Trigger(false)
		end)
		
		widget:SetCallback('onenddrag', function(widget)
			clientInfoDrag.dragActive			= false
			clientInfoDrag:Trigger(false)
		end)	
		 
		if (not Empty(trigger.identID)) and (ChatClient.IsFriend(trigger.identID)) then
			globalDraggerRegisterSource(widget, 12)
		else
			globalDraggerRegisterSource(widget, 11)
		end
		
		dropTarget:UnregisterWatchLua('globalDragInfo')
		dropTarget:RegisterWatchLua('globalDragInfo', function(widget, trigger)
			widget:SetVisible(trigger.active and (trigger.type == 11 or trigger.type == 12))
		end, false, nil, 'active', 'type')
		dropTarget:SetCallback('onmouseover', function(widget)
			globalDraggerReadTarget(widget, function()
				if isPlayerInLobby(clientInfoDrag.clientDraggingName, clientInfoDrag.clientDraggingUniqueID, clientInfoDrag.clientDraggingIdentID) then
					local slotTeam = libGeneral.getSlotTeam(index)
					local slotIndex = libGeneral.getTeamSlotIndex(teamID, index)
					local playerIndex = libGeneral.getTeamSlotIndex(lobbyTrigger.draggingSlotTeam, lobbyTrigger.draggingSlot)

					
					-- lobbySwapPlayerViaDrop (dropped a dragged player into this slot)
					-- PlaySound('/path_to/filename.wav')
					
					RequestSwapPlayerSlots(lobbyTrigger.draggingSlotTeam, playerIndex, slotTeam, slotIndex)
				else
					ChatClient.GameInvite(clientInfoDrag.clientDraggingIdentID)
				end
			end)
		end)	
	
	end)
end

local function LobbyRegister(object)

	local container		= object:GetWidget('lobby')
	
	local lobby_header_label	= object:GetWidget('lobby_header_label')
	local lobby_header_label_2	= object:GetWidget('lobby_header_label_2')

	local lobbyStatus	= LuaTrigger.GetTrigger('LobbyStatus')
	
	local lobby_fill_with_bots_button		= object:GetWidget('lobby_fill_with_bots_button')
	local gameLobby_bot_difficulty_combobox	= object:GetWidget('gameLobby_bot_difficulty_combobox')
	local startMatchButton			= object:GetWidget('gameLobbyStartMatchButton')
	local startMatchButtonLabel2	= object:GetWidget('gameLobbyStartMatchButtonLabel2')
	local cancelButton		= object:GetWidget('gameLobbyCancelButton')
	local disbandButton		= object:GetWidget('gameLobbyDisbandButton')
	local disconnectButton	= object:GetWidget('gameLobbyDisconnectButton')

	startMatchButton:RegisterWatchLua('LobbyStatus', function(widget, trigger)
		widget:SetEnabled(trigger.isHost and trigger.canStart)
		widget:SetVisible(true)
	end, false, nil, 'isHost', 'canStart') -- trigger.allPlayersVerified
	
	startMatchButtonLabel2:RegisterWatchLua('LobbyCountDown', function(widget, trigger) widget:SetVisible((trigger.timeRemaining > 0) and (trigger.timeRemaining <= 10000)) widget:SetText( math.ceil( trigger.timeRemaining / 1000 ) .. 's' ) end, false, nil, 'timeRemaining')
	cancelButton:RegisterWatchLua('LobbyCountDown', function(widget, trigger) widget:SetVisible((trigger.timeRemaining > 0) and (trigger.timeRemaining <= 10000)) end, false, nil, 'timeRemaining')
	
	disbandButton:RegisterWatchLua('LobbyCountDown', function(widget, trigger) widget:SetEnabled((trigger.timeRemaining <= 0) or (trigger.timeRemaining > 10000)) end, false, nil, 'timeRemaining')
	disconnectButton:RegisterWatchLua('LobbyCountDown', function(widget, trigger) widget:SetEnabled((trigger.timeRemaining <= 0) or (trigger.timeRemaining > 10000)) end, false, nil, 'timeRemaining')
	
	disbandButton:RegisterWatchLua('LobbyStatus', function(widget, trigger) widget:SetVisible(trigger.isHost) end, false, nil, 'isHost')
	disconnectButton:RegisterWatchLua('LobbyStatus', function(widget, trigger) widget:SetVisible(not trigger.isHost) end, false, nil, 'isHost')
	
	gameLobby_bot_difficulty_combobox:AddTemplateListItem(style_main_dropdownItem, 'easy', 'label', Translate('bot_difficulty_beginner'))
	gameLobby_bot_difficulty_combobox:AddTemplateListItem(style_main_dropdownItem, 'medium', 'label', Translate('bot_difficulty_medium'))
	gameLobby_bot_difficulty_combobox:AddTemplateListItem(style_main_dropdownItem, 'hard', 'label', Translate('bot_difficulty_hard'))
	gameLobby_bot_difficulty_combobox:AddTemplateListItem(style_main_dropdownItem, 'unfair', 'label', Translate('bot_difficulty_unfair'))
	gameLobby_bot_difficulty_combobox:SetSelectedItemByIndex(0)
	
	gameLobby_bot_difficulty_combobox:SetCallback('onselect', function(widget)
		-- lobbySelectBotDifficulty
		PlaySound('/ui/sounds/launcher/sfx_difficulty.wav')
		RequestBotDifficulty(gameLobby_bot_difficulty_combobox:GetValue())
	end)
	
	gameLobby_bot_difficulty_combobox:SetCallback('onfocus', function(widget)
		PlaySound('/ui/sounds/launcher/sfx_dropdown.wav')
	end)
	
	gameLobby_bot_difficulty_combobox:RegisterWatchLua('LobbyStatus', function(widget, trigger)
		widget:SetEnabled((trigger.isHost))
	end)	
	
	lobby_fill_with_bots_button:RegisterWatchLua('LobbyStatus', function(widget, trigger)
		widget:SetEnabled((trigger.isHost))
	end)
	
	lobby_fill_with_bots_button:SetCallback('onclick', function(widget)
		-- lobbyFillWithBots
		PlaySound('/ui/sounds/launcher/sfx_togglebots.wav')
		if (Lobby.isFilledWithBots) then
			RequestBotFill(0)
			Lobby.isFilledWithBots = false
		else
			RequestBotFill()
			Lobby.isFilledWithBots = true
		end
		RequestBotDifficulty(gameLobby_bot_difficulty_combobox:GetValue())
	end)	
	
	startMatchButton:SetCallback('onclick', function(widget)
		-- lobbyStartMatch
		PlaySound('/ui/sounds/launcher/sfx_startmatch.wav')
		RequestMatchStart() 
	end)

	cancelButton:RegisterWatchLua('LobbyStatus', function(widget, trigger)
		if (trigger.isHost) then
			cancelButton:SetCallback('onclick', function(widget)
				PlaySound('/ui/sounds/sfx_ui_back.wav')
				RequestMatchCancel()
			end)
		else
			cancelButton:SetCallback('onclick', function(widget)
				LeaveGameLobby()
			end)
		end
	end, false, nil, 'isHost')
	
	disbandButton:SetCallback('onclick', function(widget)
		-- lobbyDisbandMatch
		PlaySound('/ui/sounds/launcher/sfx_disband.wav')
		LeaveGameLobby()	
		-- RMM Leave server finder
	end)
	disconnectButton:SetCallback('onclick', function(widget)
		-- lobbyDisconnectFromMatch
		-- PlaySound('/soundpath/file.wav')
		LeaveGameLobby()
		-- RMM Leave server finder
	end)
	
	lobby_header_label:RegisterWatchLua('LobbyGameInfo', function(widget, trigger) widget:SetText(trigger.gameName) end, false, nil, 'gameName', 'serverName', 'mapName')
	lobby_header_label_2:RegisterWatchLua('LobbyGameInfo', function(widget, trigger) widget:SetText(trigger.serverName) end, false, nil, 'gameName', 'serverName', 'mapName')

	local teamID = 1
	
	for i=0,9,1 do
		if i >= 5 then teamID = 2 end
		gameLobbyPlayerSeatRegister(object, i, teamID, lobbyStatus)
	end
	
	for i=0,9,1 do
		gameLobbySpectatorSeatRegister(object, i)
	end
	
	GetWidget('lobby_team_0'):RegisterWatchLua('LobbyTeamInfo0', function(widget, trigger)
		widget:SetVisible(trigger.maxPlayers ~= 0)
	end, false, nil, 'maxPlayers')
	
	container:RegisterWatchLua('mainPanelAnimationStatus', function(widget, trigger)
		if (trigger.newMain ~= 12) and (trigger.newMain ~= -1) then			-- outro
			widget:FadeOut(250)
		elseif ((trigger.main ~= 12) and (trigger.newMain ~= 12)) then			-- fully hidden
			widget:SetVisible(0)	
		elseif (trigger.newMain == 12) and (trigger.newMain ~= -1) then		-- intro
			setMainTriggers({}) -- Default background
			widget:FadeIn(250)
		elseif (trigger.main == 12) then										-- fully displayed
			widget:SetVisible(1)
		end
	end, false, nil, 'main', 'newMain', 'lastMain', 'inParty')	
	
	local function LobbyDragRegister()
		GetWidget('lobby_overlay_listarea_droptarget_3'):RegisterWatchLua('globalDragInfo', function(widget, trigger)
			widget:SetVisible(trigger.active and (trigger.type == 11 or trigger.type == 12))
		end, false, nil, 'active', 'type')
		GetWidget('lobby_overlay_listarea_droptarget_3'):SetCallback('onmouseover', function(widget)
			globalDraggerReadTarget(widget, function()
				
				if isPlayerInLobby(clientInfoDrag.clientDraggingName, clientInfoDrag.clientDraggingUniqueID, clientInfoDrag.clientDraggingIdentID) then
					local playerIndex = libGeneral.getTeamSlotIndex(lobbyTrigger.draggingSlotTeam, lobbyTrigger.draggingSlot)
					RequestSwapPlayerSlots(lobbyTrigger.draggingSlotTeam, playerIndex, 0, 0)		
					
					-- lobbySwapPlayerToSpectateViaDrop (dropped a dragged player into this slot)
					-- PlaySound('/path_to/filename.wav')
					
					-- RequestAssignSpectator(clientInfoDrag.clientDraggingIdentID)
				else
					ChatClient.GameInvite(clientInfoDrag.clientDraggingIdentID)
				end
			end)
		end)		
	end
	
	LobbyDragRegister()	

	lobbyTrigger.draggingSlot = -1
	lobbyTrigger.draggingSlotTeam = -1
	lobbyTrigger.draggingSlotClient = -1
	lobbyTrigger.isLobbyLeader = false
	lobbyTrigger.inLobby = false
	lobbyTrigger.lobbyOpen = false
	lobbyTrigger:Trigger(true)
	
end

LobbyRegister(object)