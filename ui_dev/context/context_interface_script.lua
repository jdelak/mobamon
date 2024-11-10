local interface = object
mainUI = mainUI or {}
mainUI.contextMenu = mainUI.contextMenu or {}
gameUI = gameUI or {}
gameUI.contextMenu = gameUI.contextMenu or {}
Windows = Windows or {}
Windows.state = Windows.state or {}

local function register()

	local function printdebug(...)
		if GetCvarBool('ui_debugContextMenu') then
			println(...)
		end
	end
	
	printdebug('Registering new context menu')
	
	function mainUI.contextMenu.RegisterMultiWindowContextMenu(self)
		
		printdebug('mainUI.contextMenu.RegisterMultiWindowContextMenu()')
		
		interface:GetWidget('general_context_menu_player'):SetCallback('onhide', function(widget)
			printdebug('general_context_menu_player onhide event - ^y setting contextMenuArea to -1 ')
			ContextMenuMultiWindowTrigger.contextMenuArea = -1
			ContextMenuMultiWindowTrigger:Trigger(false)
		end)		

		interface:GetWidget('general_context_menu_player'):SetCallback('onshow', function(widget)
			printdebug('general_context_menu_player onshow event')
			if (ContextMenuMultiWindowTrigger.contextMenuArea < 0) then
				printdebug('general_context_menu_player onshow event when area is <0 - ^y calling mainUI.contextMenu.HideContextMenu()')
				mainUI.contextMenu.HideContextMenu()			
			end
		end)		
		
		interface:GetWidget('general_context_menu_player_listbox'):SetCallback('onhide', function(widget)
			printdebug('general_context_menu_player_listbox onhide event - ^y setting contextMenuArea to -1 and CloseMenu and setting Windows.state.ContextVisible')
			interface:GetWidget('general_context_menu_player'):CloseMenu()
			ContextMenuMultiWindowTrigger.contextMenuArea = -1
			ContextMenuMultiWindowTrigger:Trigger(true)
			Windows.state.ContextVisible = false
		end)		
		
		interface:GetWidget('general_context_menu_player_listbox'):SetCallback('onshow', function(widget)
			printdebug('general_context_menu_player_listbox onshow event')
			if (ContextMenuMultiWindowTrigger.contextMenuArea < 0) then
				printdebug('general_context_menu_player_listbox onshow event when area is <0 - ^y calling mainUI.contextMenu.HideContextMenu()')
				mainUI.contextMenu.HideContextMenu()
			else
				printdebug('general_context_menu_player_listbox onshow event when area is >=0 - ^y calling OpenMenu and SortByValue and setting Windows.state.ContextVisible')
				Windows.state.ContextVisible = true
				interface:GetWidget('general_context_menu_player'):OpenMenu(false)
				interface:GetWidget('general_context_menu_player'):SortByValue()				
			end
		end)	
		
		-- message
		interface:GetWidget('context_menu_listitem_0'):RegisterWatchLua('ContextMenuMultiWindowTrigger', function(widget, trigger)
			if ((trigger.contextMenuArea == 1 or trigger.contextMenuArea == 2) and (not IsMe(trigger.selectedUserIdentID))) and (ChatClient.IsOnline(trigger.selectedUserIdentID)) then
				interface:GetWidget('general_context_menu_player'):ShowItemByValue(0)
			else
				interface:GetWidget('general_context_menu_player'):HideItemByValue(0)
			end			
		end, false, nil, 'contextMenuArea')
		interface:GetWidget('context_menu_listitem_0'):SetCallback('onselect', function(widget)
			mainUI.chatManager.InitPrivateMessage(ContextMenuMultiWindowTrigger.selectedUserIdentID, ContextMenuMultiWindowTrigger.contextMenuArea, ContextMenuMultiWindowTrigger.selectedUserUsername or '')
		end)
		
		-- profile
		interface:GetWidget('context_menu_listitem_1'):RegisterWatchLua('ContextMenuMultiWindowTrigger', function(widget, trigger)
			if (trigger.contextMenuArea == 3) and trigger.endMatchSection ~= 2 then -- other players disabled: trigger.contextMenuArea == 1 or trigger.contextMenuArea == 2 or 
				interface:GetWidget('general_context_menu_player'):ShowItemByValue(1)
			else
				interface:GetWidget('general_context_menu_player'):HideItemByValue(1)
			end			
		end, false, nil, 'contextMenuArea')
		interface:GetWidget('context_menu_listitem_1'):SetCallback('onselect', function()
			local ContextMenuMultiWindowTrigger = LuaTrigger.GetTrigger('ContextMenuMultiWindowTrigger')
			local triggerPanelStatus = LuaTrigger.GetTrigger('mainPanelStatus')
			triggerPanelStatus.selectedUserIdentID = ContextMenuMultiWindowTrigger.selectedUserIdentID
			triggerPanelStatus.main = 23
			triggerPanelStatus:Trigger(false)			
		end)	
		
		-- party
		interface:GetWidget('context_menu_listitem_2'):RegisterWatchLua('ContextMenuMultiWindowTrigger', function(widget, trigger)
			
			local friendInfo
			if Friends and Friends['main'] and Friends['main'].GetFriendDataFromIdentID then
				friendInfo = Friends['main'].GetFriendDataFromIdentID(ContextMenuMultiWindowTrigger.selectedUserIdentID)
			end					
			
			if (trigger.contextMenuArea == 1 or trigger.contextMenuArea == 2) and 
			   (not IsMe(trigger.selectedUserIdentID)) and 
			   (not (friendInfo and friendInfo.isInMyParty)) and
			   (ChatClient.IsOnline(trigger.selectedUserIdentID)) and 
			   (LuaTrigger.GetTrigger('PartyStatus').inParty) and 
			   ((not trigger.selectedUserIsInLobby) and (not trigger.selectedUserIsInGame)) and
			   (LuaTrigger.GetTrigger('HeroSelectMode').isCustomLobby == false) then
				
				interface:GetWidget('general_context_menu_player'):ShowItemByValue(2)
			else
				interface:GetWidget('general_context_menu_player'):HideItemByValue(2)
			end			
		end, false, nil, 'contextMenuArea')
		interface:GetWidget('context_menu_listitem_2'):SetCallback('onselect', function()
			local partyStatusTrigger 		= LuaTrigger.GetTrigger('PartyStatus')
			ChatClient.PartyInvite(ContextMenuMultiWindowTrigger.selectedUserIdentID)
		end)		
		
		-- add friend
		interface:GetWidget('context_menu_listitem_3'):RegisterWatchLua('ContextMenuMultiWindowTrigger', function(widget, trigger)
			local friendInfo
			if Friends and Friends['main'] and Friends['main'].GetFriendDataFromIdentID then
				friendInfo = Friends['main'].GetFriendDataFromIdentID(ContextMenuMultiWindowTrigger.selectedUserIdentID)
			end
			
			if ((trigger.contextMenuArea == 1 or trigger.contextMenuArea == 2) and (not IsMe(trigger.selectedUserIdentID)) and (not ChatClient.IsFriend(trigger.selectedUserIdentID))) and (not ((friendInfo) and (friendInfo.acceptStatus) and (friendInfo.acceptStatus == 'pending'))) then
				interface:GetWidget('general_context_menu_player'):ShowItemByValue(3)
			else
				interface:GetWidget('general_context_menu_player'):HideItemByValue(3)
			end				
		end, false, nil, 'contextMenuArea', 'selectedUserIsFriend')
		interface:GetWidget('context_menu_listitem_3'):SetCallback('onselect', function()
			ChatClient.AddFriend(ContextMenuMultiWindowTrigger.selectedUserIdentID)
		end)	
		
		-- remove friend
		interface:GetWidget('context_menu_listitem_4'):RegisterWatchLua('ContextMenuMultiWindowTrigger', function(widget, trigger)
			local friendInfo
			if Friends and Friends['main'] and Friends['main'].GetFriendDataFromIdentID then
				friendInfo = Friends['main'].GetFriendDataFromIdentID(ContextMenuMultiWindowTrigger.selectedUserIdentID)
			end
			
			if ((trigger.contextMenuArea == 1 or trigger.contextMenuArea == 2) and (not IsMe(trigger.selectedUserIdentID)) and (ChatClient.IsFriend(trigger.selectedUserIdentID))) and (not ((friendInfo) and (friendInfo.acceptStatus) and (friendInfo.acceptStatus == 'pending'))) then
				interface:GetWidget('general_context_menu_player'):ShowItemByValue(4)
			else
				interface:GetWidget('general_context_menu_player'):HideItemByValue(4)
			end		
		end, false, nil, 'contextMenuArea', 'selectedUserIsFriend')
		interface:GetWidget('context_menu_listitem_4'):SetCallback('onselect', function()
			ChatClient.RemoveFriend(ContextMenuMultiWindowTrigger.selectedUserIdentID)
		end)		
		
		-- customise account
		interface:GetWidget('context_menu_listitem_5'):RegisterWatchLua('ContextMenuMultiWindowTrigger', function(widget, trigger)
			if (trigger.contextMenuArea == 3) then
				-- interface:GetWidget('general_context_menu_player'):ShowItemByValue(5)
				interface:GetWidget('general_context_menu_player'):HideItemByValue(5) -- RMM
			else
				interface:GetWidget('general_context_menu_player'):HideItemByValue(5)
			end
		end, false, nil, 'contextMenuArea')
		interface:GetWidget('context_menu_listitem_5'):SetCallback('onselect', function()

		end)
		
		-- view options
		interface:GetWidget('context_menu_listitem_6'):RegisterWatchLua('ContextMenuMultiWindowTrigger', function(widget, trigger)
			if (trigger.contextMenuArea == 3) then
				-- interface:GetWidget('general_context_menu_player'):ShowItemByValue(6)
				interface:GetWidget('general_context_menu_player'):HideItemByValue(6)
			else
				interface:GetWidget('general_context_menu_player'):HideItemByValue(6)
			end
		end, false, nil, 'contextMenuArea')
		interface:GetWidget('context_menu_listitem_6'):SetCallback('onselect', function()
			local optionsWindow	= interface:GetWidget('gameOptionsMenu')
			mainOptions.open()
			PlaySound('/ui/sounds/ui_options_open.wav')		
		end)	
		
		-- log out
		interface:GetWidget('context_menu_listitem_7'):RegisterWatchLua('ContextMenuMultiWindowTrigger', function(widget, trigger)
			if (trigger.contextMenuArea == 3) and (false) then
				interface:GetWidget('general_context_menu_player'):ShowItemByValue(7)
			else
				interface:GetWidget('general_context_menu_player'):HideItemByValue(7)
			end		
		end, false, nil, 'contextMenuArea')
		interface:GetWidget('context_menu_listitem_7'):SetCallback('onselect', function()
			PlaySound('/ui/sounds/sfx_ui_back.wav')
			GenericDialogAutoSize(
				'main_logout_confirm', 'main_logout_confirm2', '', 'general_ok', 'general_cancel', 
					function()
						-- soundEvent - Confirm Log out
						--PlaySound('/ui/sounds/ui_quit.wav')
						Logout()
					end,
					function()
						-- soundEvent - Cancel Log out
						PlaySound('/ui/sounds/sfx_ui_back.wav')
					end
			)	
		end)
		
		-- quit
		interface:GetWidget('context_menu_listitem_8'):RegisterWatchLua('ContextMenuMultiWindowTrigger', function(widget, trigger)
			if (trigger.contextMenuArea == 3) then
				interface:GetWidget('general_context_menu_player'):ShowItemByValue(8)
			else
				interface:GetWidget('general_context_menu_player'):HideItemByValue(8)
			end
		end, false, nil, 'contextMenuArea')
		interface:GetWidget('context_menu_listitem_8'):SetCallback('onselect', function()
			PlaySound('/ui/sounds/sfx_ui_back.wav')
			GenericDialogAutoSize(
				'main_quit_confirm', 'main_quit_confirm2', '', 'general_ok', 'general_cancel', 
					function()
						-- soundEvent - Confirm Quit
						--PlaySound('/ui/sounds/ui_quit.wav')
						Cmd('Quit')
					end,
					function()
						-- soundEvent - Cancel Quit
						PlaySound('/ui/sounds/sfx_ui_back.wav')
					end
			)		
		end)	
		
		-- approve friend
		interface:GetWidget('context_menu_listitem_9'):RegisterWatchLua('ContextMenuMultiWindowTrigger', function(widget, trigger)
			if Friends and Friends['main'] and Friends['main'].GetFriendDataFromIdentID then
				local friendInfo = Friends['main'].GetFriendDataFromIdentID(ContextMenuMultiWindowTrigger.selectedUserIdentID)
				if ((trigger.contextMenuArea == 1 or trigger.contextMenuArea == 2) and (friendInfo) and (friendInfo.acceptStatus) and (friendInfo.acceptStatus == 'pending')) then
					interface:GetWidget('general_context_menu_player'):ShowItemByValue(9)
				else
					interface:GetWidget('general_context_menu_player'):HideItemByValue(9)
				end
			end				
		end, false, nil, 'contextMenuArea', 'selectedUserIsFriend')
		interface:GetWidget('context_menu_listitem_9'):SetCallback('onselect', function()
			ChatClient.SetFriendStatus(ContextMenuMultiWindowTrigger.selectedUserIdentID, 'approved')
		end)		
		
		-- reject friend
		interface:GetWidget('context_menu_listitem_10'):RegisterWatchLua('ContextMenuMultiWindowTrigger', function(widget, trigger)
			if Friends and Friends['main'] and Friends['main'].GetFriendDataFromIdentID then
				local friendInfo = Friends['main'].GetFriendDataFromIdentID(ContextMenuMultiWindowTrigger.selectedUserIdentID)
				if ((trigger.contextMenuArea == 1 or trigger.contextMenuArea == 2) and (friendInfo) and (friendInfo.acceptStatus) and (friendInfo.acceptStatus == 'pending')) then
					interface:GetWidget('general_context_menu_player'):ShowItemByValue(10)
				else
					interface:GetWidget('general_context_menu_player'):HideItemByValue(10)
				end
			end
		end, false, nil, 'contextMenuArea', 'selectedUserIsFriend')
		interface:GetWidget('context_menu_listitem_10'):SetCallback('onselect', function()
			ChatClient.SetFriendStatus(ContextMenuMultiWindowTrigger.selectedUserIdentID, 'rejected')
			-- Remove friend entry
			-- Although back-end should do this, it's easy enough to do here.
			for k,v in pairs(Friends.friendData) do
				if (v.identID == ContextMenuMultiWindowTrigger.selectedUserIdentID) then
					Friends.friendData[k].buddyGroup = 'autocomplete'
					Friends.friendData[k].buddyLabel = 'autocomplete'
					Friends.friendData[k].acceptStatus = 'rejected'
					break
				end
			end
		end)
		
		-- close chat tab
		interface:GetWidget('context_menu_listitem_11'):RegisterWatchLua('ContextMenuMultiWindowTrigger', function(widget, trigger)
			if (trigger.contextMenuArea == 4) and (trigger.channelID ~= 'Clan') and (trigger.channelID ~= 'Party') and (trigger.channelID ~= 'Lobby') and  (trigger.channelID ~= 'Game')  then
				interface:GetWidget('general_context_menu_player'):ShowItemByValue(11)
			else
				interface:GetWidget('general_context_menu_player'):HideItemByValue(11)
			end
		end, false, nil, 'contextMenuArea')
		interface:GetWidget('context_menu_listitem_11'):SetCallback('onselect', function()
			mainUI.LeavePinnedChannel(nil, ContextMenuMultiWindowTrigger.channelID)		
		end)	
		
		-- quests
		interface:GetWidget('context_menu_listitem_12'):RegisterWatchLua('ContextMenuMultiWindowTrigger', function(widget, trigger)
			if (trigger.contextMenuArea == 1 or trigger.contextMenuArea == 2 or trigger.contextMenuArea == 3) and trigger.endMatchSection ~= 2 and (IsMe(trigger.selectedUserIdentID)) then
				interface:GetWidget('general_context_menu_player'):ShowItemByValue(12)
			else
				interface:GetWidget('general_context_menu_player'):HideItemByValue(12)
			end			
		end, false, nil, 'contextMenuArea')
		interface:GetWidget('context_menu_listitem_12'):SetCallback('onselect', function()
			local ContextMenuMultiWindowTrigger = LuaTrigger.GetTrigger('ContextMenuMultiWindowTrigger')
			local triggerPanelStatus = LuaTrigger.GetTrigger('mainPanelStatus')
			triggerPanelStatus.selectedUserIdentID = ContextMenuMultiWindowTrigger.selectedUserIdentID
			triggerPanelStatus.main = 23
			triggerPanelStatus:Trigger(false)			
		end)		
		
		interface:GetWidget('context_menu_listitem_13'):RegisterWatchLua('ContextMenuMultiWindowTrigger', function(widget, trigger)
			if (trigger.contextMenuArea == 1 or trigger.contextMenuArea == 2) and (not IsMe(trigger.selectedUserIdentID)) and (ChatClient.IsOnline(trigger.selectedUserIdentID)) and (LuaTrigger.GetTrigger('LobbyStatus').inLobby) and (LuaTrigger.GetTrigger('LobbyStatus').isHost) and (LuaTrigger.GetTrigger('GamePhase').gamePhase > 0) then
				interface:GetWidget('general_context_menu_player'):ShowItemByValue(13)
			else
				interface:GetWidget('general_context_menu_player'):HideItemByValue(13)
			end			
		end, false, nil, 'contextMenuArea')
		interface:GetWidget('context_menu_listitem_13'):SetCallback('onselect', function()
			ChatClient.GameInvite(ContextMenuMultiWindowTrigger.selectedUserIdentID)
		end)	
		
		-- leave party (also via chat tab)
		interface:GetWidget('context_menu_listitem_14'):RegisterWatchLua('ContextMenuMultiWindowTrigger', function(widget, trigger)
			local partyStatus = LuaTrigger.GetTrigger('PartyStatus')
			if ((trigger.contextMenuArea == 5) or ((trigger.contextMenuArea == 1) and (IsMe(trigger.selectedUserIdentID)))) and (partyStatus.inParty)  then
				interface:GetWidget('general_context_menu_player'):ShowItemByValue(14)
			else
				interface:GetWidget('general_context_menu_player'):HideItemByValue(14)
			end
		end, false, nil, 'contextMenuArea')
		interface:GetWidget('context_menu_listitem_14'):SetCallback('onselect', function()
			Party.LeaveParty()
			mainUI.LeavePinnedChannel(nil, '-4')
		end)	
		
		-- add ignore
		interface:GetWidget('context_menu_listitem_15'):RegisterWatchLua('ContextMenuMultiWindowTrigger', function(widget, trigger)
			if ((trigger.contextMenuArea == 1 or trigger.contextMenuArea == 2) and (not IsMe(trigger.selectedUserIdentID)) and (not ChatClient.IsIgnored(trigger.selectedUserIdentID))) then
				interface:GetWidget('general_context_menu_player'):ShowItemByValue(15)
			else
				interface:GetWidget('general_context_menu_player'):HideItemByValue(15)
			end				
		end, false, nil, 'contextMenuArea', 'selectedUserIsIgnored')
		interface:GetWidget('context_menu_listitem_15'):SetCallback('onselect', function()
			ChatClient.AddIgnore(ContextMenuMultiWindowTrigger.selectedUserIdentID)
		end)	
		
		-- remove ignore
		interface:GetWidget('context_menu_listitem_16'):RegisterWatchLua('ContextMenuMultiWindowTrigger', function(widget, trigger)
			if ((trigger.contextMenuArea == 1 or trigger.contextMenuArea == 2) and (not IsMe(trigger.selectedUserIdentID)) and (ChatClient.IsIgnored(trigger.selectedUserIdentID))) then
				interface:GetWidget('general_context_menu_player'):ShowItemByValue(16)
			else
				interface:GetWidget('general_context_menu_player'):HideItemByValue(16)
			end		
		end, false, nil, 'contextMenuArea', 'selectedUserIsIgnored')
		interface:GetWidget('context_menu_listitem_16'):SetCallback('onselect', function()
			ChatClient.RemoveIgnore(ContextMenuMultiWindowTrigger.selectedUserIdentID)
		end)
		
		-- spectate
		interface:GetWidget('context_menu_listitem_17'):RegisterWatchLua('ContextMenuMultiWindowTrigger', function(widget, trigger)
			if Friends and Friends['main'] and Friends['main'].GetFriendDataFromIdentID then
				local friendInfo = Friends['main'].GetFriendDataFromIdentID(trigger.selectedUserIdentID)			
				if ((mainUI.featureMaintenance) and (not mainUI.featureMaintenance['spectate'])) and ((trigger.contextMenuArea == 1 or trigger.contextMenuArea == 2) and (not IsMe(trigger.selectedUserIdentID)) and (friendInfo) and (friendInfo.spectatableGame) and ChatClient.IsFriend(trigger.selectedUserIdentID)) then
					interface:GetWidget('general_context_menu_player'):ShowItemByValue(17)
				else
					interface:GetWidget('general_context_menu_player'):HideItemByValue(17)
				end		
			end
		end, false, nil, 'contextMenuArea', 'spectatableGame')
		interface:GetWidget('context_menu_listitem_17'):SetCallback('onselect', function()
			mainUI.SpectateGame(ContextMenuMultiWindowTrigger.selectedUserIdentID)
		end)	
		
		-- join lobby
		interface:GetWidget('context_menu_listitem_18'):RegisterWatchLua('ContextMenuMultiWindowTrigger', function(widget, trigger)
			if ((trigger.contextMenuArea == 1 or trigger.contextMenuArea == 2) and (not IsMe(trigger.selectedUserIdentID)) and (trigger.joinableGame)) then
				interface:GetWidget('general_context_menu_player'):ShowItemByValue(18)
			else
				interface:GetWidget('general_context_menu_player'):HideItemByValue(18)
			end		
		end, false, nil, 'contextMenuArea', 'joinableGame')
		interface:GetWidget('context_menu_listitem_18'):SetCallback('onselect', function()
			ChatClient.JoinFriendGame(ContextMenuMultiWindowTrigger.selectedUserIdentID)
		end)		
		
		-- join party
		interface:GetWidget('context_menu_listitem_19'):RegisterWatchLua('ContextMenuMultiWindowTrigger', function(widget, trigger)
			if ((trigger.contextMenuArea == 1 or trigger.contextMenuArea == 2) and (not IsMe(trigger.selectedUserIdentID)) and (trigger.joinableParty)) then
				interface:GetWidget('general_context_menu_player'):ShowItemByValue(19)
			else
				interface:GetWidget('general_context_menu_player'):HideItemByValue(19)
			end		
		end, false, nil, 'contextMenuArea', 'joinableParty')
		interface:GetWidget('context_menu_listitem_19'):SetCallback('onselect', function()
			ChatClient.JoinFriendParty(ContextMenuMultiWindowTrigger.selectedUserIdentID)
		end)		
		
		-- challenge
		interface:GetWidget('context_menu_listitem_20'):RegisterWatchLua('ContextMenuMultiWindowTrigger', function(widget, trigger)
			local partyStatus = LuaTrigger.GetTrigger('PartyStatus')
			if libGeneral.canIAccessChallenges() and ((mainUI.featureMaintenance) and (not mainUI.featureMaintenance['scrim'])) and ( (not partyStatus.inParty) or ((partyStatus.isPartyLeader) and (not partyStatus.inQueue)) ) and (trigger.contextMenuArea == 1 or trigger.contextMenuArea == 2) and (trigger.endMatchSection ~= 2) and (not IsMe(trigger.selectedUserIdentID)) and ChatClient.IsOnline(trigger.selectedUserIdentID) then
				interface:GetWidget('general_context_menu_player'):ShowItemByValue(20)
			else
				interface:GetWidget('general_context_menu_player'):HideItemByValue(20)
			end			
		end, false, nil, 'contextMenuArea')
		interface:GetWidget('context_menu_listitem_20'):SetCallback('onselect', function()
			local ContextMenuMultiWindowTrigger = LuaTrigger.GetTrigger('ContextMenuMultiWindowTrigger')
			ScrimFinder.ChallengePlayerByIdentID(ContextMenuMultiWindowTrigger.selectedUserIdentID)
			PlaySound('ui/sounds/sfx_button_generic.wav')		
		end)	
		
		-- edit friend info
		interface:GetWidget('context_menu_listitem_21'):RegisterWatchLua('ContextMenuMultiWindowTrigger', function(widget, trigger)
			if ((trigger.contextMenuArea == 1 or trigger.contextMenuArea == 2) and (not IsMe(trigger.selectedUserIdentID))) then
				interface:GetWidget('general_context_menu_player'):ShowItemByValue(21)
			else
				interface:GetWidget('general_context_menu_player'):HideItemByValue(21)
			end				
		end, false, nil, 'contextMenuArea')
		interface:GetWidget('context_menu_listitem_21'):SetCallback('onselect', function()
			local ContextMenuMultiWindowTrigger = LuaTrigger.GetTrigger('ContextMenuMultiWindowTrigger')
			Friends.EditFriendInfo(ContextMenuMultiWindowTrigger.selectedUserIdentID, '')
			PlaySound('/ui/sounds/parties/sfx_change.wav')	
		end)		
			
		-- Start Party
		interface:GetWidget('context_menu_listitem_22'):RegisterWatchLua('ContextMenuMultiWindowTrigger', function(widget, trigger)
			local partyStatus = LuaTrigger.GetTrigger('PartyStatus')
			local partyCustomTrigger = LuaTrigger.GetTrigger('PartyTrigger')
			if (trigger.contextMenuArea == 1) and (IsMe(trigger.selectedUserIdentID)) and ((not partyCustomTrigger.userRequestedParty) and ((not partyStatus.inParty) or (partyStatus.numPlayersInParty <= 1))) then
				interface:GetWidget('general_context_menu_player'):ShowItemByValue(22)
			else
				interface:GetWidget('general_context_menu_player'):HideItemByValue(22)
			end				
		end, false, nil, 'contextMenuArea')
		interface:GetWidget('context_menu_listitem_22'):SetCallback('onselect', function()
			Party.SoftCreateParty()
			PlaySound('/ui/sounds/parties/sfx_change.wav')	
		end)		

		-- remove from party
		interface:GetWidget('context_menu_listitem_23'):RegisterWatchLua('ContextMenuMultiWindowTrigger', function(widget, trigger)
			if Friends and Friends['main'] and Friends['main'].GetFriendDataFromIdentID then
				local friendInfo = Friends['main'].GetFriendDataFromIdentID(ContextMenuMultiWindowTrigger.selectedUserIdentID)
				local partyStatus = LuaTrigger.GetTrigger('PartyStatus')
				if (trigger.contextMenuArea == 1 or trigger.contextMenuArea == 2) and (friendInfo) and (friendInfo.isInMyParty) and (partyStatus.isPartyLeader) and (not IsMe(trigger.selectedUserIdentID)) then 
					interface:GetWidget('general_context_menu_player'):ShowItemByValue(23)
				else
					interface:GetWidget('general_context_menu_player'):HideItemByValue(23)
				end
			end				
		end, false, nil, 'contextMenuArea', 'selectedUserIsFriend')
		interface:GetWidget('context_menu_listitem_23'):SetCallback('onselect', function()
			ChatClient.PartyKick(ContextMenuMultiWindowTrigger.selectedUserIdentID)
			println('^y Request kick from party: ' .. tostring(ContextMenuMultiWindowTrigger.selectedUserIdentID))
			PlaySound('/ui/sounds/parties/sfx_remove.wav')
		end)		
		
		local function RegisterClanContextItem(index, conditionFunction, actionFunction, allowMe)	
			if interface and interface:IsValid() and interface:GetWidget('context_menu_listitem_' .. index) then
				interface:GetWidget('context_menu_listitem_' .. index):RegisterWatchLua('ContextMenuMultiWindowTrigger', function(widget, trigger)
					local mainPanelStatus = LuaTrigger.GetTrigger('mainPanelStatus')
					local chatClientInfo = GetClientInfoTrigger(trigger.selectedUserIdentID)
					if (IsValidIdent(trigger.selectedUserIdentID)) and (chatClientInfo) and (trigger.contextMenuArea == 1 or trigger.contextMenuArea == 2) and ((allowMe) or (not IsMe(trigger.selectedUserIdentID))) and (conditionFunction and conditionFunction(trigger.selectedUserIdentID)) then
						interface:GetWidget('general_context_menu_player'):ShowItemByValue(index)
					else
						interface:GetWidget('general_context_menu_player'):HideItemByValue(index)
					end			
				end, false, nil, 'contextMenuArea')
				interface:GetWidget('context_menu_listitem_' .. index):SetCallback('onselect', function()
					if (actionFunction) then
						actionFunction(ContextMenuMultiWindowTrigger.selectedUserIdentID)
					end
					PlaySound('ui/sounds/sfx_button_generic.wav')		
				end)
			end
		end

		RegisterClanContextItem('25', function(identID) return mainUI.Clans.CanPromote(identID) end, function(identID) mainUI.Clans.PromptPromote(identID) end) -- social_action_bar_promote
		RegisterClanContextItem('26', function(identID) return mainUI.Clans.CanDemote(identID) end, function(identID) mainUI.Clans.PromptDemote(identID) end) -- social_action_bar_demote
		RegisterClanContextItem('27', function(identID) return mainUI.Clans.CanKick(identID) end, function(identID) mainUI.Clans.PromptKick(identID) end) -- social_action_bar_clankick
		RegisterClanContextItem('28', function(identID) return mainUI.Clans.CanInvite(identID) end, function(identID) mainUI.Clans.ClanInvite(identID) end) -- social_action_bar_claninvite
		RegisterClanContextItem('29', function(identID) return mainUI.Clans.IsPendingInvite(identID) and mainUI.Clans.CanApprovePendingInvites(identID) end, function(identID) mainUI.Clans.ApprovePendingInvite(identID) end) -- social_action_bar_claninvite_accept
		RegisterClanContextItem('30', function(identID) return mainUI.Clans.IsPendingInvite(identID) and mainUI.Clans.CanRejectPendingInvites(identID) end, function(identID) mainUI.Clans.RejectPendingInvite(identID) end) -- social_action_bar_claninvite_reject
		RegisterClanContextItem('31', function(identID) return mainUI.Clans.CanSetOwner(identID) end, function(identID) mainUI.Clans.PromptSetOwner(identID) end) -- social_action_bar_promotetoowner	
		RegisterClanContextItem('32', function(identID) return mainUI.Clans.IAmInClan() and IsMe(identID) end, function(identID) mainUI.Clans.PromptLeaveClan() end, true) -- social_action_bar_leaveclan		
		
		
		printdebug('mainUI.contextMenu.RegisterMultiWindowContextMenu() /end')
		
	end

	mainUI.contextMenu.RegisterMultiWindowContextMenu()
	
	libThread.threadFunc(function()			
		printdebug('Wating one frame then calling ContextMenuMultiWindowTrigger')
		wait(1)
		printdebug('calling ContextMenuMultiWindowTrigger')
		LuaTrigger.GetTrigger('ContextMenuMultiWindowTrigger'):Trigger(true)
	end)
	
	printdebug('Registering new context menu /end')
	
end

register()
