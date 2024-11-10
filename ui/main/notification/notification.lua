local interface = object
local tinsert, tremove, tsort = table.insert, table.remove, table.sort
Notifications						= {}
Notifications.popupQueue			= {}
Notifications.popupActive			= false
Notifications.pendingKeeperQueue	= {}
Notifications.notificationsTable	= {}
Notifications.keeperActive			= false
Notifications.lastKeeper			= ''
Notifications.lastKeeperModel		= ''
Notifications.useKeeperModels		= true

local keeperModelSettings = {
	khan	= {
		model			= '/maps/tutorial_2/resources/heroes/lexikhan/model.mdf',
		cameraPos		= '-10 355 70',
		cameraAngles	= '0 0 180',
		modelAngles		= '0 0 0'
	},
	auros	= {
		model			= '/maps/tutorial_2/resources/buildings/cage/model.mdf',
		cameraPos		= '-10 355 70',
		cameraAngles	= '0 0 180',
		modelAngles		= '0 0 0'
	},
	rhao	= {
		model			= '/maps/tutorial/resources/heroes/merchant/model.mdf',
		cameraPos		= '-10 355 70',
		cameraAngles	= '0 0 180',
		modelAngles		= '0 0 0'
	},
	draknia	= {
		model			= '/maps/tutorial_2/resources/heroes/draknia/model.mdf',
		cameraPos		= '-10 355 70',
		cameraAngles	= '0 0 180',
		modelAngles		= '0 0 0'
	}
}

local notificationsTrigger = LuaTrigger.GetTrigger('notificationsTrigger')

local mainPanelStatus = LuaTrigger.GetTrigger('mainPanelStatus')

GetWidget('main_notification_footer_overlay'):RegisterWatchLua('mainPanelStatus', function(widget, trigger)
	if (trigger.chatConnectionState >= 1) and (trigger.hasIdent) and (trigger.isLoggedIn) and (trigger.main ~= 11) and (not trigger.hideSecondaryElements) then
		widget:FadeIn(500)
	else
		widget:FadeOut(250)	
	end
end, false, nil, 'chatConnectionState', 'hasIdent', 'isLoggedIn', 'main', 'hideSecondaryElements')

local function CheckForQueuedKeeperNotifications()	-- keeper
	-- local keeper = keeper or ''
	if ((not Notifications.keeperActive)) and (#Notifications.pendingKeeperQueue > 0) then	--  or (string.len(keeper) > 0 and Notifications.lastKeeper == keeper)
		DisplayKeeperPopupNotification(
			unpack( Notifications.pendingKeeperQueue[1], 1, table.maxn(Notifications.pendingKeeperQueue[1]) )
		)
		tremove(Notifications.pendingKeeperQueue, 1)
	end
end

local function CloseNotification(durationExpired, durationExpiredCallback, hasSound)
	local durationExpired = durationExpired or false
	local hasSound = hasSound or false	-- Has sound to cancel upon dismissal

	local function onFinishClose()
		Notifications.keeperActive = false
		if durationExpired and durationExpiredCallback then
			if type(durationExpiredCallback) == 'function' then
				durationExpiredCallback()
			end
		end
		
		if hasSound then
			interface:UICmd("StopSound(9)")
		end
		
		CheckForQueuedKeeperNotifications()
	end
	
	local sameKeeperImage			= (Notifications.lastKeeper and string.len(Notifications.lastKeeper) > 0) and Notifications.pendingKeeperQueue[1] and Notifications.pendingKeeperQueue[1][5] and Notifications.pendingKeeperQueue[1][5] == Notifications.lastKeeper
	local sameKeeperModel			= (Notifications.lastKeeperModel and string.len(Notifications.lastKeeperModel) > 0) and Notifications.pendingKeeperQueue[1] and Notifications.pendingKeeperQueue[1][12] and Notifications.pendingKeeperQueue[1][12] == Notifications.lastKeeperModel
	
	if sameKeeperModel or sameKeeperImage then
		onFinishClose()
	else
		GetWidget('notification_keeper'):FadeOut(mainUI.pauseDuration2, onFinishClose)
		GetWidget('notification_keeper_darken'):FadeOut(mainUI.pauseDuration2)
	end
	
	if not sameKeeperModel then
		GetWidget('notification_keeper_model'):SlideY('200%', mainUI.pauseDuration2)
	end
	
	if not sameKeeperImage then
		GetWidget('notification_keeper_texture'):SlideY('200%', mainUI.pauseDuration2)
	end
end

local function OpenNotification(withKeeper, noDarken, withKeeperModel)
	Notifications.keeperActive = true
	noDarken = noDarken or false
	GetWidget('notification_keeper'):FadeIn(mainUI.pauseDuration2)
	if (withKeeper or withKeeperModel) then
		if not noDarken then
			GetWidget('notification_keeper_darken'):FadeIn(mainUI.pauseDuration2)
		end
		
		if withKeeper then
			GetWidget('notification_keeper_texture'):SetVisible(1)
			GetWidget('notification_keeper_texture'):SlideY('-40%', mainUI.pauseDuration2)
		else
			GetWidget('notification_keeper_texture'):SetVisible(0)
		end
		
		
		GetWidget('notification_keeper_speechbubble'):Sleep(mainUI.pauseDuration2, function(widget)
			widget:FadeIn(mainUI.pauseDuration2)
			GetWidget('notification_keeper_speechbubble_label_0'):Sleep(mainUI.pauseDuration2, function(widget)
				widget:FadeIn(mainUI.pauseDuration2)
			end)
		end)
		
		if withKeeperModel then
			GetWidget('notification_keeper_model'):SetVisible(1)
			GetWidget('notification_keeper_model'):SlideY('-125%', mainUI.pauseDuration2)
		else
			GetWidget('notification_keeper_model'):SetVisible(0)
		end
		
		GetWidget('notification_keeper_speechbubble'):SlideY('-345s', mainUI.pauseDuration2)	
	else
		
		GetWidget('notification_keeper_texture'):SetVisible(0)
		GetWidget('notification_keeper_model'):SetVisible(0)
		GetWidget('notification_keeper_speechbubble'):Sleep(mainUI.pauseDuration2, function(widget)
			widget:FadeIn(mainUI.pauseDuration2)
			GetWidget('notification_keeper_speechbubble_label_0'):Sleep(mainUI.pauseDuration2, function(widget)
				widget:FadeIn(mainUI.pauseDuration2)
			end)
		end)
		GetWidget('notification_keeper_speechbubble'):SlideY('-80s', mainUI.pauseDuration2)	
	end
end	

Notifications.listNotificationsActionsTable = {}
Notifications.listNotificationsActionsTable2 = {}
function Notifications.CloseCurrentKeeper()
	CloseNotification(nil, nil, nil, nil)
	groupfcall('friends_mini_bubble_templates', function(_, groupWidget) groupWidget:SetVisible(0) end)
end

local lastDisplayedKeeperPopupNotification

function DisplayKeeperPopupNotification(duration, messageString, clickActionFunction, cancelFunction, keeper, durationExpireFunction, sound, onShow, isFromNPE, noDarken, listTable, keeperModel, keeperAnim, okbuttonstring)
	-- println('DisplayKeeperPopupNotification')
	
	lastDisplayedKeeperPopupNotification = { duration, messageString, clickActionFunction, cancelFunction, keeper, durationExpireFunction, sound, onShow, isFromNPE, noDarken, listTable, keeperModel, keeperAnim, okbuttonstring }
	
	local duration		= duration or 9000
	local hasExpired	= false
	local isFromNPE		= isFromNPE or false
	
	local useKeeperModel	= (keeperModel and string.len(keeperModel) > 0 and keeperModelSettings[keeperModel] and keeperAnim and string.len(keeperAnim) > 0)

	noDarken			= noDarken or false

	function Notifications.CloseCurrentKeeper()
		CloseNotification(nil, nil, nil, keeper)
	end
	
	if (listTable) then
		GetWidget('notification_keeper_speechbubble'):SetWidth('460s')
		GetWidget('notification_speech_bubble_listbox'):ClearItems()
		GetWidget('notification_speech_bubble_listbox'):SetVisible(1)			
		for i, v in pairs(listTable) do
			if v[3] or (true) then
				GetWidget('notification_speech_bubble_listbox'):AddTemplateListItem('notification_listbox_item_2_button_template', i, 'i', i, 'label', v[1])	
				Notifications.listNotificationsActionsTable[i] = {v[2], v[3]}
			elseif v[2] then
				GetWidget('notification_speech_bubble_listbox'):AddTemplateListItem('notification_listbox_item_1_button_template', i, 'i', i, 'label', v[1])	
				Notifications.listNotificationsActionsTable[i] = {v[2]}
			else
				println('^r Error: List notification with no action ')
				Notifications.listNotificationsActionsTable[i] = {}
			end
		end
	else
		GetWidget('notification_keeper_speechbubble'):SetWidth('360s')
		GetWidget('notification_speech_bubble_listbox'):SetVisible(0)
		GetWidget('notification_speech_bubble_listbox'):ClearItems()
		local party_list_invites_listbox = GetWidget('party_list_invites_listbox', nil, true)
		if party_list_invites_listbox then
			GetWidget('party_list_invites_listbox'):ClearItems()	
		end
	end
	
	--[[
		keeper:
			/ui/main/keepers/textures/draknia.png
			/ui/main/keepers/textures/lexikhan.png
			/ui/main/keepers/textures/rhao.png
			/ui/main/keepers/textures/auros.png
	--]]
	
	Notifications.keeperActive = true
	GetWidget('notification_keeper_sleepWidget'):Sleep(1, function()	-- Allows all notifications to be entered into queue from this frame
		
		if keeper ~= nil then	-- allow false
			keeper = keeper
		else
			keeper = '/ui/main/keepers/textures/lexikhan.png'
		end

		-- local keeper = keeper or '/ui/_textures/elements/designimages/endmatch_keeper.tga'
		
		local hasSound = false
		if sound then
			hasSound = true
			interface:UICmd("StopSound(9)")
			PlayStream(sound, nil, 9, 0)
		end
		
		if onShow then
			onShow()
		end
		
		OpenNotification(keeper, noDarken, useKeeperModel)
		Notifications.lastKeeper = keeper
		Notifications.lastKeeperModel = keeperModel
		
		GetWidget('notification_keeper_speechbubble_label_0'):SetText(FormatStringNewline(Translate(messageString)))
		if keeper then
			GetWidget('notification_keeper_texture'):SetVisible(1)
			GetWidget('notification_keeper_texture'):SetImage(keeper)	
		end
		
		if useKeeperModel then
			GetWidget('notification_keeper_model'):SetVisible(1)
			GetWidget('notification_keeper_model'):SetModel(keeperModelSettings[keeperModel].model)
			GetWidget('notification_keeper_model'):SetAnim(keeperAnim)
		end
		
		if (okbuttonstring) and (TranslateOrNil(okbuttonstring)) then
			GetWidget('notification_keeper_speechbubble_action_btnLabel'):SetText(Translate(okbuttonstring))
		elseif (isFromNPE) then
			GetWidget('notification_keeper_speechbubble_action_btnLabel'):SetText(Translate('general_go'))
		else
			GetWidget('notification_keeper_speechbubble_action_btnLabel'):SetText(Translate('general_ok'))
		end
		
		GetWidget('notification_keeper_speechbubble_action_btn'):SetVisible(clickActionFunction ~= nil)
		GetWidget('notification_keeper_speechbubble_action_btn'):SetCallback('onclick', function(widget)
			CloseNotification(nil, nil, nil)	-- , keeper
			if clickActionFunction then
				clickActionFunction()
			end
		end)
		
		GetWidget('notification_keeper_speechbubble_cancel_btn'):SetVisible(cancelFunction ~= nil)
		GetWidget('notification_keeper_speechbubble_cancel_btn'):SetCallback('onclick', function(widget)
			CloseNotification(nil, nil, nil)	-- , keeper
			if cancelFunction then
				cancelFunction()
			end
		end)	
		

		local closeTexture = '/ui/main/shared/textures/close.tga'
		
		local closeButtonVisible = false
		local nextButtonVisible = false
		
		if isFromNPE then
			if (#Notifications.pendingKeeperQueue > 0) then
				nextButtonVisible = true

				GetWidget('notification_keeper_speechbubble_next_btn'):SetCallback('onclick', function(widget)
					hasExpired = true
					CloseNotification(true, durationExpireFunction, hasSound)
				end)
			else
				closeButtonVisible = true
				
				GetWidget('notification_keeper_speechbubble_close_btn2'):SetCallback('onclick', function(widget)
					hasExpired = true
					CloseNotification(true, durationExpireFunction, hasSound)
				end)
			end
		end
		
		GetWidget('notification_keeper_speechbubble_close_btn2'):SetVisible(closeButtonVisible)
		GetWidget('notification_keeper_speechbubble_next_btn'):SetVisible(nextButtonVisible)
		
		GetWidget('notification_keeper_speechbubble_close_btn'):SetVisible(not (closeButtonVisible or nextButtonVisible))
		
		GetWidget('notification_keeper_speechbubble_close_btn'):SetCallback('onclick', function(widget)
			hasExpired = true
			CloseNotification(true, durationExpireFunction, hasSound)
			if cancelFunction then
				if type(cancelFunction) == 'function' then
					cancelFunction()
				end
			end			
		end)

		if (duration ~= -1) then
			GetWidget('notification_keeper'):Sleep(duration, function()
				if not hasExpired then
					CloseNotification(true, durationExpireFunction, hasSound, keeper)
				end
			end)
		end

	end)
end

function Notifications.QueueKeeperPopupNotification(duration, messageString, clickActionFunction, cancelFunction, keeper, durationExpireFunction, sound, onShow, isFromNPE, noDarken, listTable, keeperModel, keeperAnim, okbuttonstring)
	noDarken = noDarken or false
	-- println('QueueKeeperPopupNotification')
	
	if not Notifications.useKeeperModels then
		keeperModel		= nil
		keeperAnim		= nil
	elseif keeperModel and keeperAnim then
		keeper			= false
	end
	
	if (not Notifications.keeperActive) then
		DisplayKeeperPopupNotification(duration, messageString, clickActionFunction, cancelFunction, keeper, durationExpireFunction, sound, onShow, isFromNPE, noDarken, listTable, keeperModel, keeperAnim, okbuttonstring)
	else
		tinsert(Notifications.pendingKeeperQueue, {duration, messageString, clickActionFunction, cancelFunction, keeper, durationExpireFunction, sound, onShow, isFromNPE, noDarken, listTable, keeperModel, keeperAnim, okbuttonstring})
	end
end

local function NotificationsRegister(object)
	notificationsTrigger.popupActive		 			= false
	notificationsTrigger.questRewards 	 				= 0
	notificationsTrigger.partyInvites 	 				= 0
	notificationsTrigger.lobbyInvites 	 				= 0
	notificationsTrigger.clanInvites 	 				= 0
	notificationsTrigger.miscNotifications 				= 0
	notificationsTrigger.spinNotifications 				= 0
	notificationsTrigger.incomingChallenges 			= 0

	notificationsTrigger:Trigger(true)
end

function CloseCurrentKeeperNotification()
	GetWidget('notification_keeper'):Sleep(1, function() end)	-- Clears sleep so durationExpireFunction doesn't occur
	CloseNotification(nil, nil, true)
end

function ClearAllKeeperNotifications(onlyFromNPE)	-- Clear active notification and flush queue
	onlyFromNPE = onlyFromNPE or false
	
	if onlyFromNPE then
		local newKeeperQueue = {}
		
		for k,v in ipairs(Notifications.pendingKeeperQueue) do
			if not v[9] then
				table.insert(newKeeperQueue, v)
			end
		end

		Notifications.pendingKeeperQueue = newKeeperQueue
		
		if lastDisplayedKeeperPopupNotification and type(lastDisplayedKeeperPopupNotification) == 'table' and lastDisplayedKeeperPopupNotification[9] then
			CloseCurrentKeeperNotification()
		end		
	else
		Notifications.pendingKeeperQueue = {}
		CloseCurrentKeeperNotification()
	end
end

NotificationsRegister(object)

------------------------------------------------------------------------------
--	Incoming Data
------------------------------------------------------------------------------
-- type 0: addiction, 1: quest, 2: unclaimed reward, 4: no type - splash, 5: no type - no splash
-- ChatClient.AddNotification(	message )
-- ChatClient.RemoveNotification(	notificationID )

local function MiniFooterNotification(notificationType, message)
	local bubble = GetWidget('notification_' .. notificationType .. '_bubble')
	local bubbleLabel = GetWidget('notification_' .. notificationType .. '_bubble_label')
	
	bubbleLabel:SetText(message)
	bubble:FadeIn(250)
	bubble:Sleep(7500, function(widget)
		widget:FadeOut(500)
	end)

end

local function FlashFooterIcon(notificationType)
	local footerButton = GetWidget('notification_'..notificationType)

	if (footerButton) then
		local visibilityToggle = true
		local cycles = 6

		local flash = nil
		flash = function()
			if (visibilityToggle) then
				footerButton:DoEventN(1)
			else
				footerButton:DoEventN(0)
			end

			visibilityToggle = not visibilityToggle
			cycles = cycles - 1

			if (cycles > 0) then
				footerButton:Sleep(250, flash)
			end
		end

		flash()
	end
end



function ProcessNotifications()
	
	notificationsTrigger.questRewards 	 				= 0
	notificationsTrigger.partyInvites 	 				= 0
	notificationsTrigger.lobbyInvites 	 				= 0
	notificationsTrigger.clanInvites 	 				= 0
	notificationsTrigger.miscNotifications 				= 0
	notificationsTrigger.spinNotifications 				= 0
	-- notificationsTrigger.incomingChallenges 			= 0 -- this is done in the scrim finder
	
	GetWidget('notification_keeper_speechbubble'):SetWidth('360s')
	GetWidget('notification_speech_bubble_listbox'):SetVisible(0)
	GetWidget('notification_speech_bubble_listbox'):ClearItems()
	if (not GetCvarBool('ui_multiWindowFriends')) then
		local party_list_invites_listbox = GetWidget('party_list_invites_listbox', nil, true)
		if party_list_invites_listbox then
			GetWidget('party_list_invites_listbox'):ClearItems()	
		end
	end
	
	printr(Notifications.notificationsTable)
	
	if (mainUI.Clans and mainUI.Clans.UpdatePartyInvites) then
		mainUI.Clans.UpdatePartyInvites()
	end

	for notificationType, typeTable in pairs(Notifications.notificationsTable) do
		for i, notificationTable in pairs(typeTable) do

			if (notificationTable.message == 'fix_that') then -- error display immediately -- remove notification, no history
				Notifications.QueueKeeperPopupNotification(10000, 
					"Fix That!", 
						function()  end,
						nil,
						'/ui/main/keepers/textures/lexikhan.png'
				)	
				Notifications.notificationsTable[notificationType][i] = nil
			elseif (notificationTable.message == 'disconnect_afk_kicked') or (notificationTable.message == 'disconnect_afk_kicked_desc') then -- error display immediately -- remove notification, no history
				Notifications.QueueKeeperPopupNotification(900000, 
					Translate2(notificationTable.message, notificationTable.tokens), 
						function()  end,
						nil,
						'/ui/main/keepers/textures/lexikhan.png'
				)
				Notifications.notificationsTable[notificationType][i] = nil				
			elseif (type(notificationTable.notificationType) == 'table') and (libGeneral.isInTable(notificationTable.notificationType, 'update')) then -- display immediately -- remove notification, no history
				Cmd("CheckForUpdate")	
				Notifications.notificationsTable[notificationType][i] = nil			
			elseif (type(notificationTable.notificationType) == 'table') and (libGeneral.isInTable(notificationTable.notificationType, 'motd')) then -- display immediately -- remove notification, no history
				MOTD() -- go get the MOTD
				Notifications.notificationsTable[notificationType][i] = nil						
			elseif (type(notificationTable.notificationType) == 'table') and (libGeneral.isInTable(notificationTable.notificationType, 'ok')) then -- display immediately -- remove notification, no history
				Notifications.QueueKeeperPopupNotification(10000, 
					Translate2(notificationTable.message, notificationTable.tokens), 
						function()  end,
						nil,
						'/ui/main/keepers/textures/lexikhan.png'
				)	
				if string.find(string.lower(notificationTable.message), string.lower('create_party_error'), 1, true) then
					mainUI.ReturnHome()			
				elseif string.find(string.lower(notificationTable.message), string.lower('create_lobby_error'), 1, true) then
					mainUI.ReturnHome()			
				elseif string.find(string.lower(notificationTable.message), string.lower('join_lobby_error'), 1, true) then
					mainUI.ReturnHome()				
				elseif string.find(string.lower(notificationTable.message), string.lower('join_party_error'), 1, true) then
					mainUI.ReturnHome()
				elseif string.find(string.lower(notificationTable.message), string.lower('left_party_kicked'), 1, true) or string.find(string.lower(notificationTable.message), string.lower('left_party_matchmaking_disabled'), 1, true) or string.find(string.lower(notificationTable.message), string.lower('left_party_new_version'), 1, true) then
					mainUI.ReturnHome()			
				end
				Notifications.notificationsTable[notificationType][i] = nil
			elseif (type(notificationTable.notificationType) == 'table') and (libGeneral.isInTable(notificationTable.notificationType, 'ok_forever')) then -- display immediately -- remove notification, no history
				Notifications.QueueKeeperPopupNotification(-1, 
					Translate2(notificationTable.message, notificationTable.tokens), 
						function()  end,
						nil,
						'/ui/main/keepers/textures/lexikhan.png'
				)	
				Notifications.notificationsTable[notificationType][i] = nil						
			elseif (type(notificationTable.notificationType) == 'table') and (libGeneral.isInTable(notificationTable.notificationType, 'clan_error')) then -- display immediately as dialog -- remove notification, no history
				if (notificationTable.message) and (not Empty(notificationTable.message)) and (notificationTable.message ~= 'error_not_found') then
					local errorTable = explode('|', notificationTable.message)
					local errorTable2 = {}
					for i,v in ipairs(errorTable) do
						table.insert(errorTable2, Translate(v))
					end
					local errorString = implode2(errorTable2, ' \n')
					GenericDialogAutoSize(
						'error_web_general_clan', '', tostring(Translate(errorString)), 'general_ok', '',
							nil,
							nil
					)
				end			
				if (mainUI.Clans) and (mainUI.Clans.ClearCreatingClan) then
					mainUI.Clans.ClearCreatingClan()
				end
				Notifications.notificationsTable[notificationType][i] = nil			
			elseif (type(notificationTable.notificationType) == 'table') and (libGeneral.isInTable(notificationTable.notificationType, 'game_invite')) then -- display small popup, queue click event in footer, requires action so keep history
				if ((mainUI.featureMaintenance) and (mainUI.featureMaintenance['lobby'])) then
					return
				end				
				notificationsTrigger.lobbyInvites = notificationsTrigger.lobbyInvites  + 1
				GetWidget('notification_lobby_invite'):SetCallback('onclick', function()
					if (notificationsTrigger.lobbyInvites <= 1) then
						Notifications.QueueKeeperPopupNotification(-1, 
							Translate2(notificationTable.message, notificationTable.tokens), 
								function() 
									libThread.threadFunc(function()
										LeaveGameLobby()
										Party.LeaveParty()		
										wait(styles_mainSwapAnimationDuration)
										ChatClient.NotificationAction(notificationTable.id, notificationTable.actions[1])
										Notifications.notificationsTable[notificationType][i] = nil
									end)
								end,
								function() 
									ChatClient.NotificationAction(notificationTable.id, notificationTable.actions[2]) 
									Notifications.notificationsTable[notificationType][i] = nil
								end,
								'/ui/main/keepers/textures/lexikhan.png'
						)
					else
						local invitesTable = {}
						for i, v in pairs(Notifications.notificationsTable[notificationType]) do
							table.insert(invitesTable, {Translate2('notification_sender_name', notificationTable.tokens), 
								function() 
									libThread.threadFunc(function()
										LeaveGameLobby()
										Party.LeaveParty()		
										wait(styles_mainSwapAnimationDuration)
										ChatClient.NotificationAction(v.id, v.actions[1])
										Notifications.notificationsTable[notificationType][i] = nil
									end)
								end, 
								function() 
									ChatClient.NotificationAction(v.id, v.actions[2])
									Notifications.notificationsTable[notificationType][i] = nil 
								end}
							)
						end

						Notifications.QueueKeeperPopupNotification(-1, 
							Translate2(notificationTable.message .. '_multi', notificationTable.tokens), 
								nil,
								nil,
								'/ui/main/keepers/textures/lexikhan.png',
								nil, nil, nil, nil, true, invitesTable
						)
					end
				end)	
				FlashFooterIcon('lobby_invite')
				MiniFooterNotification('lobby_invite', Translate2(notificationTable.message, notificationTable.tokens))
				GetWidget('notification_lobby_invite'):RefreshCallbacks()				
			elseif (type(notificationTable.notificationType) == 'table') and (libGeneral.isInTable(notificationTable.notificationType, 'party_invite')) then  -- display small popup, move data to party area, queue click event in footer, requires action so keep history
				if ((mainUI.featureMaintenance) and (mainUI.featureMaintenance['party'])) then
					return
				end
				-- sound_receivePartyInvite
				PlaySound('/ui/sounds/parties/sfx_invite_receive.wav')
				notificationsTrigger.partyInvites = notificationsTrigger.partyInvites  + 1
				
				-- if (notificationsTrigger.partyInvites <= 1) then
					-- MiniFooterNotification('friends_footer_button', Translate2(notificationTable.message, notificationTable.tokens))	
					-- FlashFooterIcon('party_invite')
				-- else
					FlashFooterIcon('party_invite')
					MiniFooterNotification('party_invite', Translate2(notificationTable.message, notificationTable.tokens))
				-- end
				
				GetWidget('notification_party_invite'):SetCallback('onclick', function()
					if (notificationsTrigger.partyInvites <= 1) then
						Notifications.QueueKeeperPopupNotification(-1, 
							Translate2(notificationTable.message, notificationTable.tokens), 
								function() 
									libThread.threadFunc(function()
										LeaveGameLobby()
										Party.LeaveParty()		
										wait(styles_mainSwapAnimationDuration)
										ChatClient.NotificationAction(notificationTable.id, notificationTable.actions[1])
										wait(styles_mainSwapAnimationDuration)
										InitSelectionTriggers(interface, false)										
									end)
								end,
								function() 
									ChatClient.NotificationAction(notificationTable.id, notificationTable.actions[2])
								end,
								'/ui/main/keepers/textures/lexikhan.png'
						)
					else
						local invitesTable = {}
						for i, v in pairs(Notifications.notificationsTable[notificationType]) do
							table.insert(invitesTable, {Translate2('notification_sender_name', v.tokens), function() 
								libThread.threadFunc(function()
									LeaveGameLobby()
									Party.LeaveParty()		
									wait(styles_mainSwapAnimationDuration)
									ChatClient.NotificationAction(v.id, v.actions[1]) 
									wait(styles_mainSwapAnimationDuration)
									InitSelectionTriggers(interface, false)									
								end)
							end, function() 
								ChatClient.NotificationAction(v.id, v.actions[2]) 
							end})
						end
						Notifications.QueueKeeperPopupNotification(-1, 
							Translate2(notificationTable.message .. '_multi', notificationTable.tokens), 
								nil,
								nil,
								'/ui/main/keepers/textures/lexikhan.png',
								nil, nil, nil, nil, true, invitesTable
						)
					end
				end)			
				GetWidget('notification_party_invite'):RefreshCallbacks()	
	
				-- sound_notficiationPartyInvite
				PlaySound('/ui/sounds/rewards/sfx_reward_flash.wav')	-- temp
								
				-- in party area list
				local invitesTable2 = {}
				for i, v in pairs(Notifications.notificationsTable[notificationType]) do
					table.insert(invitesTable2, {Translate2('notification_sender_name', v.tokens), 
					function() 
						local function acceptAction()
							libThread.threadFunc(function()
								LeaveGameLobby()
								Party.LeaveParty()		
								wait(styles_mainSwapAnimationDuration)
								ChatClient.NotificationAction(v.id, v.actions[1]) 
								wait(styles_mainSwapAnimationDuration)
								InitSelectionTriggers(interface, false)
							end)
						end
						
						if LuaTrigger.GetTrigger('GamePhase').gamePhase >= 1 or LuaTrigger.GetTrigger('PartyStatus').numPlayersInParty > 1 then
							GenericDialog(
								Translate('party_invite_inlobby'), Translate('party_invite_inlobby_body'), '', Translate('general_ok'), Translate('general_cancel'), 
								function()
									acceptAction()
								end,
								nil,
								nil,
								nil,
								true
							)
						else
							acceptAction()
						end
					end, function() 
						ChatClient.NotificationAction(v.id, v.actions[2]) 
					end})
				end	

				
				local party_list_invites_listbox = GetWidget('party_list_invites_listbox', nil, true)
				if party_list_invites_listbox then
					if (not GetCvarBool('ui_multiWindowFriends')) then
						party_list_invites_listbox:ClearItems()
					end
				
					Notifications.listNotificationsActionsTable2 = {}
					for i, v in pairs(invitesTable2) do
						if (not GetCvarBool('ui_multiWindowFriends')) then
							GetWidget('party_list_invites_listbox'):AddTemplateListItem('notification_listbox_item_2_button_template_2', i, 'i', i, 'label', v[1])	
						end
						Notifications.listNotificationsActionsTable2[i] = {v[2], v[3]}
					end
				end
			elseif (type(notificationTable.notificationType) == 'table') and (libGeneral.isInTable(notificationTable.notificationType, 'party_challenge')) then
				if ((mainUI.featureMaintenance) and (mainUI.featureMaintenance['party'])) then
					return
				end
				-- sound_receivePartyInvite
				PlaySound('/ui/sounds/parties/sfx_invite_receive.wav')
				
				GetWidget('notification_party_challenge'):SetCallback('onclick', function()
					ScrimFinder.OpenScrimFinder()
				end)	
				FlashFooterIcon('party_challenge')
				MiniFooterNotification('party_challenge', Translate2(notificationTable.message, notificationTable.tokens))
				GetWidget('notification_party_challenge'):RefreshCallbacks()
			elseif (type(notificationTable.notificationType) == 'table') and (libGeneral.isInTable(notificationTable.notificationType, 'party_challenge_declined')) then
				if ((mainUI.featureMaintenance) and (mainUI.featureMaintenance['party'])) then
					return
				end
				-- Notifications.QueueKeeperPopupNotification(10000, 
					-- Translate2(notificationTable.message, notificationTable.tokens), 
						-- function()  end,
						-- nil,
						-- '/ui/main/keepers/textures/lexikhan.png'
				-- )	
				MiniFooterNotification('party_challenge', Translate2(notificationTable.message, notificationTable.tokens))
				Notifications.notificationsTable[notificationType][i] = nil
			elseif (type(notificationTable.notificationType) == 'table') and (libGeneral.isInTable(notificationTable.notificationType, 'party_challenge_accepted')) then
				if ((mainUI.featureMaintenance) and (mainUI.featureMaintenance['party'])) then
					return
				end
				-- Notifications.QueueKeeperPopupNotification(10000, 
					-- Translate2(notificationTable.message, notificationTable.tokens), 
						-- function()  end,
						-- nil,
						-- '/ui/main/keepers/textures/lexikhan.png'
				-- )	
				MiniFooterNotification('party_challenge', Translate2(notificationTable.message, notificationTable.tokens))
				Notifications.notificationsTable[notificationType][i] = nil				
			elseif (notificationTable.notificationType == -1) then		-- put into footer
				notificationsTrigger.miscNotifications = notificationsTrigger.miscNotifications  + 1
				widget:SetCallback('onclick', function()
					-- we got a notification we don't know what to do with
				end)	
				widget:RefreshCallbacks()				
			end
		end
	end
	notificationsTrigger:Trigger(true)
end	

local processNotificationThread = nil

local function createNotificationProcesThread()
	if processNotificationThread == nil then
		processNotificationThread = libThread.threadFunc(function()
			yield()
			ProcessNotifications()
			processNotificationThread = nil
		end)
	end
end
	
GetWidget('main_notification_footer_overlay'):RegisterWatchLua('ChatNewNotification', function(widget, trigger)  -- id message
	local notificationType = -1
	local notificationGroupType = -1
	if (trigger.type) and (not Empty(trigger.type)) then
		notificationType = explode(',', trigger.type)
		notificationGroupType = notificationType[1]
	end

	Notifications.notificationsTable[notificationGroupType] = Notifications.notificationsTable[notificationGroupType] or {}
	Notifications.notificationsTable[notificationGroupType][trigger.id] = {
		id = trigger.id,
		message = trigger.message,
		tokens = trigger.tokens,
		actions = trigger.actions,
		notificationType = notificationType
	}

	if trigger.message == 'left_lobby_no_server' or trigger.message == 'left_game_no_server' then
		LuaTrigger.GetTrigger('mainPanelStatus'):Trigger(true)	-- rmm this is another hack pending modification to how mainPanelAnimationStatus is used
	end
	
	createNotificationProcesThread()
end)

GetWidget('main_notification_footer_overlay'):RegisterWatchLua('ChatDeleteNotification', function(widget, trigger)  -- id
	println(' ChatDeleteNotification ' .. trigger.id)
	for i, v in pairs(Notifications.notificationsTable) do
		if (v) and (v[trigger.id]) then
			Notifications.notificationsTable[i][trigger.id] = nil
		end
	end

	createNotificationProcesThread()
end)

UnwatchLuaTriggerByKey('ChatAddictionWarning', 'ChatAddictionWarningKey')
WatchLuaTrigger('ChatAddictionWarning', function(trigger)
	Notifications.QueueKeeperPopupNotification(-1, trigger.message, function()  end, nil, nil)
end, 'ChatAddictionWarningKey')

-- Unclaimed Quest Rewards
-- GetWidget('notification_unclaimed_quest'):RegisterWatchLua('questsTrigger', function(widget, trigger)
	-- GetWidget('notification_unclaimed_quest_count'):SetText(trigger.unclaimedQuestRewards)
	
	-- if (trigger.unclaimedQuestRewards > 0) then
		-- widget:SetVisible(1)
	-- else
		-- widget:SetVisible(0)
	-- end
	
	-- notificationsTrigger.questRewards = trigger.unclaimedQuestRewards
	
	-- widget:SetCallback('onclick', function()
		-- Notifications.QueueKeeperPopupNotification(nil, 
			-- Translate('notification_quest_completion'), 
			-- function() 
				-- if (Quests) and (Quests.questsWithUnclaimedRewards) and (#Quests.questsWithUnclaimedRewards > 0) then
					-- Quests.Splash(Quests.questsWithUnclaimedRewards)
				-- end			
			-- end,
			-- nil,
			-- '/ui/main/keepers/textures/rhao.png'
		-- )
	-- end)	
	-- FlashFooterIcon('unclaimed_quest')
	-- MiniFooterNotification('unclaimed_quest', Translate('notification_quest_completion'))
	-- widget:RefreshCallbacks()
	-- createNotificationProcesThread()
-- end, false, nil, 'unclaimedQuestRewards')

-- Unclaimed gameplay chest reward from UnclaimedRewardsUpdated UnclaimedRewards
-- GetWidget('notification_unclaimed_loot'):RegisterWatchLua('UnclaimedRewards', function(widget, trigger)
	-- GetWidget('notification_unclaimed_loot_count'):SetText(trigger.numUnclaimed)
	
	-- if (trigger.numUnclaimed > 0) then
		-- widget:SetVisible(1)
	-- else
		-- widget:SetVisible(0)
	-- end
	
	-- widget:SetCallback('onclick', function()
		-- Notifications.QueueKeeperPopupNotification(nil, 
			-- Translate('notification_unclaimed_reward'), 
			-- function() 
				-- local PostGameLoopStatus		= LuaTrigger.GetTrigger('PostGameLoopStatus')
				-- Rewards.ClaimFirstReward()
				-- PostGameLoopStatus.viaUnclaimed = true
				-- PostGameLoopStatus.matchID = tostring(trigger.firstMatchID)
				-- PostGameLoopStatus:Trigger(true)
				-- EndMatch.Show(true)		
			-- end,
			-- nil,
			-- '/ui/main/keepers/textures/rhao.png'
		-- )
	-- end)	
	-- FlashFooterIcon('unclaimed_loot')
	-- if (not mainUI.savedLocally.lastNumUnclaimedRewards) or (mainUI.savedLocally.lastNumUnclaimedRewards ~= trigger.numUnclaimed) then
		-- MiniFooterNotification('unclaimed_loot', Translate('notification_unclaimed_reward'))
		-- mainUI.savedLocally.lastNumUnclaimedRewards = trigger.numUnclaimed
		-- SaveState()
	-- end	
	-- widget:RefreshCallbacks()
	-- createNotificationProcesThread()
-- end)

GetWidget('notification_unclaimed_spin'):RegisterWatchLua('wheelTrigger', function(widget, trigger)
	local AccountProgression = LuaTrigger.GetTrigger('AccountProgression')
	if (AccountProgression.level >= mainUI.progression.PRIZE_SPIN_UNLOCK_LEVEL) then
		mainUI.savedLocally = mainUI.savedLocally or {}
		GetWidget('notification_unclaimed_spin_count'):SetText(1)
		
		if (trigger.wheelSpinAvailable) then
			widget:SetVisible(1)
		else
			widget:SetVisible(0)
		end
		
		widget:SetCallback('onclick', function()
			LuaTrigger.GetTrigger('mainPanelStatus').main=42
			LuaTrigger.GetTrigger('mainPanelStatus'):Trigger(false)
		end)	
		FlashFooterIcon('unclaimed_spin')
		if (trigger.wheelSpinAvailable) and (not mainUI.savedLocally.lastwheelSpinAvailable) then
			MiniFooterNotification('unclaimed_spin', Translate('notification_unclaimed_spin'))
		end	
		widget:RefreshCallbacks()
		createNotificationProcesThread()
		mainUI.savedLocally.lastwheelSpinAvailable = trigger.wheelSpinAvailable
	end
end, false, nil, 'wheelSpinAvailable')

-- Pending incoming challenge
local lastChallengesPending = 0
GetWidget('notification_pending_challenge'):RegisterWatchLua('notificationsTrigger', function(widget, trigger)
	local partyStatus = LuaTrigger.GetTrigger('PartyStatus')
	
	GetWidget('notification_pending_challenge_count'):SetText(trigger.incomingChallenges)
	
	if (trigger.incomingChallenges > 0) and (partyStatus.inParty) then
		widget:SetVisible(1)
	else
		widget:SetVisible(0)
	end

	widget:SetCallback('onclick', function()
		ScrimFinder.OpenScrimFinder()
	end)

	if (trigger.incomingChallenges > 0) and (partyStatus.inParty) and (trigger.incomingChallenges ~= lastChallengesPending) then
		FlashFooterIcon('pending_challenge')
		MiniFooterNotification('pending_challenge', Translate('party_challenge_new_noname'))
	end	
	
	widget:RefreshCallbacks()
	
	lastChallengesPending = trigger.incomingChallenges
end, false, nil, 'incomingChallenges')

-- Party Invites
GetWidget('notification_party_invite'):RegisterWatchLua('notificationsTrigger', function(widget, trigger)
	local partyStatus = LuaTrigger.GetTrigger('PartyStatus')
	GetWidget('notification_party_invite_count'):SetText(trigger.partyInvites)
	if (trigger.partyInvites > 0) then
		widget:SetVisible(1)
	else
		widget:SetVisible(0)
	end
end, false, nil, 'partyInvites')

-- Clan Invites
GetWidget('notification_clan_invite'):RegisterWatchLua('notificationsTrigger', function(widget, trigger)
	GetWidget('notification_clan_invite_count'):SetText(Translate('clan_notification_clan_invite_mouseo', 'value', trigger.clanInvites))
	if (trigger.clanInvites > 0) then
		widget:SetVisible(1)
	else
		widget:SetVisible(0)
	end
end, false, nil, 'clanInvites')

-- Lobby Invites
GetWidget('notification_lobby_invite'):RegisterWatchLua('notificationsTrigger', function(widget, trigger)
	GetWidget('notification_lobby_invite_count'):SetText(trigger.lobbyInvites)
	if (trigger.lobbyInvites > 0) then
		widget:SetVisible(1)
	else
		widget:SetVisible(0)
	end
end, false, nil, 'lobbyInvites')

-- Leaver
GetWidget('notification_leaver'):RegisterWatchLua('LeaverBan', function(widget, trigger)
	local strikes = trigger.strikes
	if (strikes <= 0) then
		widget:SetVisible(0)
	elseif (strikes == 1) then
		GetWidget('notification_leaver_count'):SetText(Translate('notification_leaver_desc', 'value', strikes))
		FlashFooterIcon('leaver')
		widget:SetVisible(1)
		if (not mainUI.savedLocally.lastStrikesWarn) or (mainUI.savedLocally.lastStrikesWarn ~= strikes) then
			MiniFooterNotification('leaver', Translate('notification_leaver', 'value', strikes))
			mainUI.savedLocally.lastStrikesWarn = strikes
			SaveState()
		end
	elseif (strikes >= 2) then
		GetWidget('notification_leaver_count'):SetText(Translate('notification_leavers_desc', 'value', strikes))
		FlashFooterIcon('leaver')
		widget:SetVisible(1)
		if (not mainUI.savedLocally.lastStrikesWarn) or (mainUI.savedLocally.lastStrikesWarn ~= strikes) then
			MiniFooterNotification('leaver', Translate('notification_leavers', 'value', strikes))
			mainUI.savedLocally.lastStrikesWarn = strikes
			SaveState()
		end
	end
	GetWidget('main_chat_footer_overlay_parent_1'):Sleep(50, function(overlayWidget)
		overlayWidget:SetX(GetWidget('main_notification_footer_overlay'):GetWidth() + 6)
		overlayWidget:SetWidth(widget:GetWidthFromString('840s') - GetWidget('main_notification_footer_overlay'):GetWidth())
	end)
end, false, nil, 'strikes', 'nextBanDuration')

-- Catch All
GetWidget('notification_catchall'):RegisterWatchLua('notificationsTrigger', function(widget, trigger)
	GetWidget('notification_catchall_count'):SetText(trigger.miscNotifications)
	if (trigger.miscNotifications > 0) then
		widget:SetVisible(1)
	else
		widget:SetVisible(0)
	end
end, false, nil, 'miscNotifications')

local matchmakingWasEnabled = false
GetWidget('notification_catchall'):RegisterWatchLua('ChatAvailability', function(sourceWidget, trigger)
	local triggerPanelStatus 				= LuaTrigger.GetTrigger('mainPanelStatus')
	if (trigger.matchmaking) and (trigger.matchmaking.visible) and (trigger.matchmaking.enabled == false) then
		if (matchmakingWasEnabled) then
			if (trigger.matchmaking.timestamp) and tonumber(trigger.matchmaking.timestamp) and (tonumber(trigger.matchmaking.timestamp) > 0) then
				Notifications.QueueKeeperPopupNotification(45000, 
					Translate('matchmaking_disabled_notification_2', 'time', FormatDateTime(trigger.timeStamp, '%#I:%M %p %b%d', true)), 
						function()  end,
						nil,
						'/ui/main/keepers/textures/lexikhan.png'
				)
			else
				Notifications.QueueKeeperPopupNotification(-1, 
					Translate('matchmaking_disabled_notification'), 
						function()  end,
						nil,
						'/ui/main/keepers/textures/lexikhan.png'
				)			
			end
		end
		matchmakingWasEnabled = false
	elseif (trigger.matchmaking) and (trigger.matchmaking.visible) and (trigger.matchmaking.enabled) then
		matchmakingWasEnabled = true
	end
end, false, nil, 'matchmaking')

local lastClanInvites = 0
function Notifications.ClanInvite(invites)
	notificationsTrigger.clanInvites = invites
	
	if (invites) and (invites > 0) then
		if (lastClanInvites) and (invites > lastClanInvites) then
			PlaySound('/ui/sounds/parties/sfx_invite_receive.wav')
			MiniFooterNotification('clan_invite', Translate('clan_notification_clan_invite_popup'))
		end
		FlashFooterIcon('clan_invite')
	end
	
	GetWidget('notification_clan_invite'):SetCallback('onclick', function()
		HideMiniFooterNotification('clan_invite')
		mainUI.Clans.Toggle(true)
	end)			
	GetWidget('notification_clan_invite'):RefreshCallbacks()		
	
	lastClanInvites = invites
	
	notificationsTrigger:Trigger(true)
end

function NotificationDebug()
	ChatClient.AddNotification('party_invite', 'party_invite')
	ChatClient.AddNotification('party_invite', 'party_invite')
	ChatClient.AddNotification('party_invite', 'party_invite')
	ChatClient.AddNotification('party_invite', 'party_invite')
	ChatClient.AddNotification('party_invite', 'party_invite')
end
if (GetCvarBool('ui_debug_notification')) then
	GetWidget('main_notification_footer_overlay'):Sleep(500, function()
		NotificationDebug() -- RMM
	end)
end