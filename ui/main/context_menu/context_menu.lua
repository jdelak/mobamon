local interface = object
mainUI = mainUI or {}
mainUI.contextMenu = mainUI.contextMenu or {}
gameUI = gameUI or {}
gameUI.contextMenu = gameUI.contextMenu or {}

--[[
	ContextMenuTrigger = LuaTrigger.CreateCustomTrigger('ContextMenuTrigger',
		{
			{ name	= 'contextMenuArea',				type	= 'number' },
			{ name	= 'selectedUserIsLocalClient',		type	= 'boolean' },
			{ name	= 'selectedUserIsFriend',			type	= 'boolean' },
			{ name	= 'selectedUserOnlineStatus',		type	= 'boolean' },
			{ name	= 'localClientIsSpectating',		type	= 'boolean' },
			{ name	= 'needToApprove',					type	= 'boolean' },
			{ name	= 'selectedUserIdentID',			type	= 'string' },
			{ name	= 'selectedUserUniqueID',			type	= 'string' },
			{ name	= 'selectedUserUsername',			type	= 'string' },
			{ name	= 'channelID',						type	= 'string' },
			{ name	= 'endMatchSection',				type	= 'number' },
			{ name	= 'selectedUserIsIgnored',			type	= 'boolean' },
		}
	)

	contextMenuArea
		1:	Generic Player (Outside Game)
		2:	Generic Player (Inside Game)
		3:	Local Player (Outside Game: Quit Menu, Account Item Options, Profile Edit etc)
		4:	Chat Tab
		5:	Party Chat Tab
		6:	Friends Options
--]]

function mainUI.contextMenu.InitialiseMainPlayerContextMenu(sourceWidget)

	GetWidget('general_context_menu_player_listbox'):SetCallback('onhide', function(widget)
		ContextMenuTrigger.contextMenuArea = -1
		ContextMenuTrigger:Trigger(true)
	end)

	interface:RegisterWatchLua('ContextMenuTrigger', function(widget, trigger)
		if (trigger.contextMenuArea >= 0) then
			GetWidget('general_context_menu_player'):OpenMenu(false)
			GetWidget('general_context_menu_player'):MoveToCursor()
			GetWidget('general_context_menu_player'):SetVisible(1)
			GetWidget('general_context_menu_player'):SortByValue()
		end
	end, true)
	
	-- message
	GetWidget('context_menu_listitem_0'):RegisterWatchLua('ContextMenuTrigger', function(widget, trigger)
		if ((trigger.contextMenuArea == 1 or trigger.contextMenuArea == 2) and (not IsMe(trigger.selectedUserIdentID))) and (ChatClient.IsOnline(trigger.selectedUserIdentID)) then
			GetWidget('general_context_menu_player'):ShowItemByValue(0)
		else
			GetWidget('general_context_menu_player'):HideItemByValue(0)
		end			
	end, false, nil, 'contextMenuArea')
	GetWidget('context_menu_listitem_0'):SetCallback('onselect', function(widget)
		mainUI.chatManager.InitPrivateMessage(ContextMenuTrigger.selectedUserIdentID, ContextMenuTrigger.contextMenuArea, ContextMenuTrigger.selectedUserUsername or '')
	end)
	
	-- profile
	GetWidget('context_menu_listitem_1'):RegisterWatchLua('ContextMenuTrigger', function(widget, trigger)
		if (trigger.contextMenuArea == 3) and trigger.endMatchSection ~= 2 then -- other players disabled: trigger.contextMenuArea == 1 or trigger.contextMenuArea == 2 or 
			GetWidget('general_context_menu_player'):ShowItemByValue(1)
		else
			GetWidget('general_context_menu_player'):HideItemByValue(1)
		end			
	end, false, nil, 'contextMenuArea')
	GetWidget('context_menu_listitem_1'):SetCallback('onselect', function()
		local contextMenuTrigger = LuaTrigger.GetTrigger('ContextMenuTrigger')
		local triggerPanelStatus = LuaTrigger.GetTrigger('mainPanelStatus')
		triggerPanelStatus.selectedUserIdentID = contextMenuTrigger.selectedUserIdentID
		triggerPanelStatus.main = 23
		triggerPanelStatus:Trigger(false)			
	end)	
	
	-- party
	GetWidget('context_menu_listitem_2'):RegisterWatchLua('ContextMenuTrigger', function(widget, trigger)
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
			
			GetWidget('general_context_menu_player'):ShowItemByValue(2)
		else
			GetWidget('general_context_menu_player'):HideItemByValue(2)
		end			
	end, false, nil, 'contextMenuArea')
	GetWidget('context_menu_listitem_2'):SetCallback('onselect', function()
		local partyStatusTrigger 		= LuaTrigger.GetTrigger('PartyStatus')
		ChatClient.PartyInvite(ContextMenuTrigger.selectedUserIdentID)
	end)		
	
	-- add friend
	GetWidget('context_menu_listitem_3'):RegisterWatchLua('ContextMenuTrigger', function(widget, trigger)
		local friendInfo
		if Friends and Friends['main'] and Friends['main'].GetFriendDataFromIdentID then
			friendInfo = Friends['main'].GetFriendDataFromIdentID(ContextMenuTrigger.selectedUserIdentID)
		end
		
		if ((trigger.contextMenuArea == 1 or trigger.contextMenuArea == 2) and (not IsMe(trigger.selectedUserIdentID)) and (not ChatClient.IsFriend(trigger.selectedUserIdentID))) and (not ((friendInfo) and (friendInfo.acceptStatus) and (friendInfo.acceptStatus == 'pending' or friendInfo.acceptStatus == 'sent'))) then
			interface:GetWidget('general_context_menu_player'):ShowItemByValue(3)
		else
			interface:GetWidget('general_context_menu_player'):HideItemByValue(3)
		end				
	end, false, nil, 'contextMenuArea', 'selectedUserIsFriend')
	GetWidget('context_menu_listitem_3'):SetCallback('onselect', function()
		ChatClient.AddFriend(ContextMenuTrigger.selectedUserIdentID)
	end)	
	
	-- remove friend
	GetWidget('context_menu_listitem_4'):RegisterWatchLua('ContextMenuTrigger', function(widget, trigger)
		local friendInfo
		if Friends and Friends['main'] and Friends['main'].GetFriendDataFromIdentID then
			friendInfo = Friends['main'].GetFriendDataFromIdentID(ContextMenuTrigger.selectedUserIdentID)
		end
		
		if ((trigger.contextMenuArea == 1 or trigger.contextMenuArea == 2) and (not IsMe(trigger.selectedUserIdentID)) and (ChatClient.IsFriend(trigger.selectedUserIdentID) or (friendInfo and friendInfo.acceptStatus and (friendInfo.acceptStatus == 'pending' or friendInfo.acceptStatus == 'sent')))) then
			interface:GetWidget('general_context_menu_player'):ShowItemByValue(4)
		else
			interface:GetWidget('general_context_menu_player'):HideItemByValue(4)
		end		
	end, false, nil, 'contextMenuArea', 'selectedUserIsFriend')
	GetWidget('context_menu_listitem_4'):SetCallback('onselect', function()
		ChatClient.RemoveFriend(ContextMenuTrigger.selectedUserIdentID)
	end)		
	
	-- customise account
	GetWidget('context_menu_listitem_5'):RegisterWatchLua('ContextMenuTrigger', function(widget, trigger)
		if (trigger.contextMenuArea == 3) then
			-- GetWidget('general_context_menu_player'):ShowItemByValue(5)
			GetWidget('general_context_menu_player'):HideItemByValue(5) -- RMM
		else
			GetWidget('general_context_menu_player'):HideItemByValue(5)
		end
	end, false, nil, 'contextMenuArea')
	GetWidget('context_menu_listitem_5'):SetCallback('onselect', function()

	end)
	
	-- view options
	GetWidget('context_menu_listitem_6'):RegisterWatchLua('ContextMenuTrigger', function(widget, trigger)
		if (trigger.contextMenuArea == 3) then
			-- GetWidget('general_context_menu_player'):ShowItemByValue(6)
			GetWidget('general_context_menu_player'):HideItemByValue(6)
		else
			GetWidget('general_context_menu_player'):HideItemByValue(6)
		end
	end, false, nil, 'contextMenuArea')
	GetWidget('context_menu_listitem_6'):SetCallback('onselect', function()
		local optionsWindow	= GetWidget('gameOptionsMenu')
		mainOptions.open()
		PlaySound('/ui/sounds/ui_options_open.wav')		
	end)	
	
	-- log out
	GetWidget('context_menu_listitem_7'):RegisterWatchLua('ContextMenuTrigger', function(widget, trigger)
		if (trigger.contextMenuArea == 3) and (false) then
			GetWidget('general_context_menu_player'):ShowItemByValue(7)
		else
			GetWidget('general_context_menu_player'):HideItemByValue(7)
		end		
	end, false, nil, 'contextMenuArea')
	GetWidget('context_menu_listitem_7'):SetCallback('onselect', function()
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
	GetWidget('context_menu_listitem_8'):RegisterWatchLua('ContextMenuTrigger', function(widget, trigger)
		if (trigger.contextMenuArea == 3) then
			GetWidget('general_context_menu_player'):ShowItemByValue(8)
		else
			GetWidget('general_context_menu_player'):HideItemByValue(8)
		end
	end, false, nil, 'contextMenuArea')
	GetWidget('context_menu_listitem_8'):SetCallback('onselect', function()
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
	GetWidget('context_menu_listitem_9'):RegisterWatchLua('ContextMenuTrigger', function(widget, trigger)
		if Friends and Friends['main'] and Friends['main'].GetFriendDataFromIdentID then
			local friendInfo = Friends['main'].GetFriendDataFromIdentID(ContextMenuTrigger.selectedUserIdentID)
			if ((trigger.contextMenuArea == 1 or trigger.contextMenuArea == 2) and (friendInfo) and (friendInfo.acceptStatus) and (friendInfo.acceptStatus == 'pending')) then
				interface:GetWidget('general_context_menu_player'):ShowItemByValue(9)
			else
				interface:GetWidget('general_context_menu_player'):HideItemByValue(9)
			end
		end			
	end, false, nil, 'contextMenuArea', 'selectedUserIsFriend')
	GetWidget('context_menu_listitem_9'):SetCallback('onselect', function()
		ChatClient.SetFriendStatus(ContextMenuTrigger.selectedUserIdentID, 'approved')
	end)		
	
	-- approve friend
	GetWidget('context_menu_listitem_10'):RegisterWatchLua('ContextMenuTrigger', function(widget, trigger)
		if Friends and Friends['main'] and Friends['main'].GetFriendDataFromIdentID then
			local friendInfo = Friends['main'].GetFriendDataFromIdentID(ContextMenuTrigger.selectedUserIdentID)
			if ((trigger.contextMenuArea == 1 or trigger.contextMenuArea == 2) and (friendInfo) and (friendInfo.acceptStatus) and (friendInfo.acceptStatus == 'pending')) then
				interface:GetWidget('general_context_menu_player'):ShowItemByValue(10)
			else
				interface:GetWidget('general_context_menu_player'):HideItemByValue(10)
			end
		end			
	end, false, nil, 'contextMenuArea', 'selectedUserIsFriend')
	GetWidget('context_menu_listitem_10'):SetCallback('onselect', function()
		ChatClient.SetFriendStatus(ContextMenuTrigger.selectedUserIdentID, 'rejected')
	end)	
	
	-- close chat tab
	GetWidget('context_menu_listitem_11'):RegisterWatchLua('ContextMenuTrigger', function(widget, trigger)
		if (trigger.contextMenuArea == 4) and (trigger.channelID ~= 'Clan') and (trigger.channelID ~= 'Party') and (trigger.channelID ~= 'Lobby') and  (trigger.channelID ~= 'Game')  then
			GetWidget('general_context_menu_player'):ShowItemByValue(11)
		else
			GetWidget('general_context_menu_player'):HideItemByValue(11)
		end
	end, false, nil, 'contextMenuArea')
	GetWidget('context_menu_listitem_11'):SetCallback('onselect', function()
		mainUI.LeavePinnedChannel(nil, ContextMenuTrigger.channelID)		
	end)	
	
	-- quests UNUSED
	GetWidget('context_menu_listitem_12'):RegisterWatchLua('ContextMenuTrigger', function(widget, trigger)
		GetWidget('general_context_menu_player'):HideItemByValue(12)		
	end, false, nil, 'contextMenuArea')
	GetWidget('context_menu_listitem_12'):SetCallback('onselect', function()
		local contextMenuTrigger = LuaTrigger.GetTrigger('ContextMenuTrigger')
		local triggerPanelStatus = LuaTrigger.GetTrigger('mainPanelStatus')
		triggerPanelStatus.selectedUserIdentID = contextMenuTrigger.selectedUserIdentID
		triggerPanelStatus.main = 23
		triggerPanelStatus:Trigger(false)			
	end)		
	
	GetWidget('context_menu_listitem_13'):RegisterWatchLua('ContextMenuTrigger', function(widget, trigger)
		if (trigger.contextMenuArea == 1 or trigger.contextMenuArea == 2) and (not IsMe(trigger.selectedUserIdentID)) and (ChatClient.IsOnline(trigger.selectedUserIdentID)) and (LuaTrigger.GetTrigger('LobbyStatus').inLobby) and (LuaTrigger.GetTrigger('LobbyStatus').isHost) then
			GetWidget('general_context_menu_player'):ShowItemByValue(13)
		else
			GetWidget('general_context_menu_player'):HideItemByValue(13)
		end			
	end, false, nil, 'contextMenuArea')
	GetWidget('context_menu_listitem_13'):SetCallback('onselect', function()
		ChatClient.GameInvite(ContextMenuTrigger.selectedUserIdentID)
	end)	
	
	-- leave party (also via chat tab)
	GetWidget('context_menu_listitem_14'):RegisterWatchLua('ContextMenuTrigger', function(widget, trigger)
		local partyStatus = LuaTrigger.GetTrigger('PartyStatus')
		if ((trigger.contextMenuArea == 5) or ((trigger.contextMenuArea == 1) and (IsMe(trigger.selectedUserIdentID)))) and (partyStatus.inParty)  then
			GetWidget('general_context_menu_player'):ShowItemByValue(14)
		else
			GetWidget('general_context_menu_player'):HideItemByValue(14)
		end
	end, false, nil, 'contextMenuArea')
	GetWidget('context_menu_listitem_14'):SetCallback('onselect', function()
		Party.LeaveParty()
		mainUI.LeavePinnedChannel(nil, '-4')
	end)	
	
	-- add ignore
	GetWidget('context_menu_listitem_15'):RegisterWatchLua('ContextMenuTrigger', function(widget, trigger)
		if ((trigger.contextMenuArea == 1 or trigger.contextMenuArea == 2) and (not IsMe(trigger.selectedUserIdentID)) and (not ChatClient.IsIgnored(trigger.selectedUserIdentID))) then
			GetWidget('general_context_menu_player'):ShowItemByValue(15)
		else
			GetWidget('general_context_menu_player'):HideItemByValue(15)
		end				
	end, false, nil, 'contextMenuArea', 'selectedUserIsIgnored')
	GetWidget('context_menu_listitem_15'):SetCallback('onselect', function()
		ChatClient.AddIgnore(ContextMenuTrigger.selectedUserIdentID)
	end)	
	
	-- remove ignore
	GetWidget('context_menu_listitem_16'):RegisterWatchLua('ContextMenuTrigger', function(widget, trigger)
		if ((trigger.contextMenuArea == 1 or trigger.contextMenuArea == 2) and (not IsMe(trigger.selectedUserIdentID)) and (ChatClient.IsIgnored(trigger.selectedUserIdentID))) then
			GetWidget('general_context_menu_player'):ShowItemByValue(16)
		else
			GetWidget('general_context_menu_player'):HideItemByValue(16)
		end		
	end, false, nil, 'contextMenuArea', 'selectedUserIsIgnored')
	GetWidget('context_menu_listitem_16'):SetCallback('onselect', function()
		ChatClient.RemoveIgnore(ContextMenuTrigger.selectedUserIdentID)
	end)
	
	-- spectate
	GetWidget('context_menu_listitem_17'):RegisterWatchLua('ContextMenuTrigger', function(widget, trigger)
		if Friends and Friends['main'] and Friends['main'].GetFriendDataFromIdentID then
			local friendInfo = Friends['main'].GetFriendDataFromIdentID(trigger.selectedUserIdentID)		
			if ((mainUI.featureMaintenance) and (not mainUI.featureMaintenance['spectate'])) and ((trigger.contextMenuArea == 1 or trigger.contextMenuArea == 2) and (not IsMe(trigger.selectedUserIdentID)) and (friendInfo) and (friendInfo.spectatableGame) and ChatClient.IsFriend(trigger.selectedUserIdentID)) then
				GetWidget('general_context_menu_player'):ShowItemByValue(17)
			else
				GetWidget('general_context_menu_player'):HideItemByValue(17)
			end
		end
	end, false, nil, 'contextMenuArea', 'spectatableGame')
	GetWidget('context_menu_listitem_17'):SetCallback('onselect', function()
		mainUI.SpectateGame(ContextMenuTrigger.selectedUserIdentID)
	end)	
	
	-- join lobby
	GetWidget('context_menu_listitem_18'):RegisterWatchLua('ContextMenuTrigger', function(widget, trigger)
		if ((trigger.contextMenuArea == 1 or trigger.contextMenuArea == 2) and (not IsMe(trigger.selectedUserIdentID)) and (trigger.joinableGame)) then
			GetWidget('general_context_menu_player'):ShowItemByValue(18)
		else
			GetWidget('general_context_menu_player'):HideItemByValue(18)
		end		
	end, false, nil, 'contextMenuArea', 'joinableGame')
	GetWidget('context_menu_listitem_18'):SetCallback('onselect', function()
		ChatClient.JoinFriendGame(ContextMenuTrigger.selectedUserIdentID)
	end)		
	
	-- join party
	GetWidget('context_menu_listitem_19'):RegisterWatchLua('ContextMenuTrigger', function(widget, trigger)
		if ((trigger.contextMenuArea == 1 or trigger.contextMenuArea == 2) and (not IsMe(trigger.selectedUserIdentID)) and (trigger.joinableParty)) then
			GetWidget('general_context_menu_player'):ShowItemByValue(19)
		else
			GetWidget('general_context_menu_player'):HideItemByValue(19)
		end		
	end, false, nil, 'contextMenuArea', 'joinableParty')
	GetWidget('context_menu_listitem_19'):SetCallback('onselect', function()
		ChatClient.JoinFriendParty(ContextMenuTrigger.selectedUserIdentID)
	end)		
	
	-- challenge
	GetWidget('context_menu_listitem_20'):RegisterWatchLua('ContextMenuTrigger', function(widget, trigger)
		local partyStatus = LuaTrigger.GetTrigger('PartyStatus')
		if libGeneral.canIAccessChallenges() and ((mainUI.featureMaintenance) and (not mainUI.featureMaintenance['scrim'])) and ( (not partyStatus.inParty) or ((partyStatus.isPartyLeader) and (not partyStatus.inQueue)) ) and (trigger.contextMenuArea == 1 or trigger.contextMenuArea == 2) and (trigger.endMatchSection ~= 2) and (not IsMe(trigger.selectedUserIdentID)) then
			GetWidget('general_context_menu_player'):ShowItemByValue(20)
		else
			GetWidget('general_context_menu_player'):HideItemByValue(20)
		end			
	end, false, nil, 'contextMenuArea')
	GetWidget('context_menu_listitem_20'):SetCallback('onselect', function()
		local contextMenuTrigger = LuaTrigger.GetTrigger('ContextMenuTrigger')
		ScrimFinder.ChallengePlayerByIdentID(contextMenuTrigger.selectedUserIdentID)
		PlaySound('ui/sounds/sfx_button_generic.wav')		
	end)	
	
	-- edit friend info
	GetWidget('context_menu_listitem_21'):RegisterWatchLua('ContextMenuTrigger', function(widget, trigger)
		if ((trigger.contextMenuArea == 1 or trigger.contextMenuArea == 2) and (not IsMe(trigger.selectedUserIdentID))) then
			GetWidget('general_context_menu_player'):ShowItemByValue(21)
		else
			GetWidget('general_context_menu_player'):HideItemByValue(21)
		end				
	end, false, nil, 'contextMenuArea')
	GetWidget('context_menu_listitem_21'):SetCallback('onselect', function()
		local contextMenuTrigger = LuaTrigger.GetTrigger('ContextMenuTrigger')
		Friends.EditFriendInfo(contextMenuTrigger.selectedUserIdentID, '')
		Friends.ToggleFriendsList(true)
		PlaySound('/ui/sounds/parties/sfx_change.wav')	
	end)		
		
	-- Start Party
	GetWidget('context_menu_listitem_22'):RegisterWatchLua('ContextMenuTrigger', function(widget, trigger)
		local partyStatus = LuaTrigger.GetTrigger('PartyStatus')
		local partyCustomTrigger = LuaTrigger.GetTrigger('PartyTrigger')
		if (trigger.contextMenuArea == 1) and (IsMe(trigger.selectedUserIdentID)) and ((not partyCustomTrigger.userRequestedParty) and ((not partyStatus.inParty) or (partyStatus.numPlayersInParty <= 1))) then
			GetWidget('general_context_menu_player'):ShowItemByValue(22)
		else
			GetWidget('general_context_menu_player'):HideItemByValue(22)
		end				
	end, false, nil, 'contextMenuArea')
	GetWidget('context_menu_listitem_22'):SetCallback('onselect', function()
		Party.SoftCreateParty()
		PlaySound('/ui/sounds/parties/sfx_change.wav')	
	end)		
	
	-- remove from party
	interface:GetWidget('context_menu_listitem_23'):RegisterWatchLua('ContextMenuTrigger', function(widget, trigger)
		if Friends and Friends['main'] and Friends['main'].GetFriendDataFromIdentID then
			local friendInfo = Friends['main'].GetFriendDataFromIdentID(ContextMenuTrigger.selectedUserIdentID)
			local partyStatus = LuaTrigger.GetTrigger('PartyStatus')
			if (trigger.contextMenuArea == 1 or trigger.contextMenuArea == 2) and (friendInfo) and (friendInfo.isInMyParty) and (partyStatus.isPartyLeader) and (not IsMe(trigger.selectedUserIdentID)) then
				interface:GetWidget('general_context_menu_player'):ShowItemByValue(23)
			else
				interface:GetWidget('general_context_menu_player'):HideItemByValue(23)
			end
		end				
	end, false, nil, 'contextMenuArea', 'selectedUserIsFriend')
	interface:GetWidget('context_menu_listitem_23'):SetCallback('onselect', function()
		ChatClient.PartyKick(ContextMenuTrigger.selectedUserIdentID)
		println('^y Request kick from party: ' .. tostring(ContextMenuTrigger.selectedUserIdentID))
		PlaySound('/ui/sounds/parties/sfx_remove.wav')
	end)	
	
	local function RegisterClanContextItem(index, conditionFunction, actionFunction, allowMe)	
		GetWidget('context_menu_listitem_' .. index):RegisterWatchLua('ContextMenuTrigger', function(widget, trigger)
			local mainPanelStatus = LuaTrigger.GetTrigger('mainPanelStatus')
			local chatClientInfo = GetClientInfoTrigger(trigger.selectedUserIdentID)
			if (IsValidIdent(trigger.selectedUserIdentID)) and (chatClientInfo) and (trigger.contextMenuArea == 1 or trigger.contextMenuArea == 2) and ((allowMe) or (not IsMe(trigger.selectedUserIdentID))) and (conditionFunction and conditionFunction(trigger.selectedUserIdentID)) then
				GetWidget('general_context_menu_player'):ShowItemByValue(index)
			else
				GetWidget('general_context_menu_player'):HideItemByValue(index)
			end			
		end, false, nil, 'contextMenuArea')
		GetWidget('context_menu_listitem_' .. index):SetCallback('onselect', function()
			local contextMenuTrigger = LuaTrigger.GetTrigger('ContextMenuTrigger')
			if (actionFunction) then
				actionFunction(contextMenuTrigger.selectedUserIdentID)
			end
			PlaySound('ui/sounds/sfx_button_generic.wav')		
		end)		
	end

	RegisterClanContextItem('25', function(identID) return mainUI.Clans.CanPromote(identID) end, function(identID) mainUI.Clans.PromptPromote(identID) end) -- social_action_bar_promote
	RegisterClanContextItem('26', function(identID) return mainUI.Clans.CanDemote(identID) end, function(identID) mainUI.Clans.PromptDemote(identID) end) -- social_action_bar_demote
	RegisterClanContextItem('27', function(identID) return mainUI.Clans.CanKick(identID) end, function(identID) mainUI.Clans.PromptKick(identID) end) -- social_action_bar_clankick
	RegisterClanContextItem('28', function(identID) return mainUI.Clans.CanInvite(identID) end, function(identID) mainUI.Clans.ClanInvite(identID) end) -- social_action_bar_claninvite
	RegisterClanContextItem('29', function(identID) return mainUI.Clans.IsPendingInvite(identID) and mainUI.Clans.CanApprovePendingInvites(identID) end, function(identID) mainUI.Clans.ApprovePendingInvite(identID) end) -- social_action_bar_claninvite_accept
	RegisterClanContextItem('30', function(identID) return mainUI.Clans.IsPendingInvite(identID) and mainUI.Clans.CanRejectPendingInvites(identID) end, function(identID) mainUI.Clans.RejectPendingInvite(identID) end) -- social_action_bar_claninvite_reject
	RegisterClanContextItem('31', function(identID) return mainUI.Clans.CanSetOwner(identID) end, function(identID) mainUI.Clans.PromptSetOwner(identID) end) -- social_action_bar_promotetoowner
	RegisterClanContextItem('32', function(identID) return mainUI.Clans.IAmInClan() and IsMe(identID) end, function(identID) mainUI.Clans.PromptLeaveClan() end, true) -- social_action_bar_leaveclan	
	
end

