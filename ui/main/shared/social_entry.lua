socialEntry = {	-- socialEntry or
	getUserWidgets = function(object, prefix)
		return {
			userBody			= object:GetWidget(prefix..'UserBody'),
			userButton			= object:GetWidget(prefix..'UserButton'),
			userIcon			= object:GetWidget(prefix..'UserIcon'),
			userName			= object:GetWidget(prefix..'UserName'),
			userGroup			= object:GetWidget(prefix..'UserGroup'),
			userDarken			= object:GetWidget(prefix..'UserDarken'),
			userStatus			= object:GetWidget(prefix..'UserStatus'),
			actionBacker		= object:GetWidget(prefix..'ActionBacker'),
			actionBarButtons	= object:GetWidget(prefix..'ActionBarButtons'),
			actionBarVis		= object:GetWidget(prefix..'ActionBarVis'),
			dropTarget			= object:GetWidget(prefix..'DropTarget'),
			VOIP				= object:GetWidget(prefix..'VOIP'),
			VOIPIcon1			= object:GetWidget(prefix..'VOIPIcon1'),
			VOIPIcon2			= object:GetWidget(prefix..'VOIPIcon2'),
		}
	end,
	getHeaderWidgets = function(object, prefix)
		return {
			headerBody			= object:GetWidget(prefix..'HeaderBody'),
			headerName			= object:GetWidget(prefix..'HeaderName'),
			headerExpandArrow	= object:GetWidget(prefix..'HeaderExpandArrow'),
			headerExpandButton	= object:GetWidget(prefix..'HeaderExpandButton')
		}
	end,
	getEntryWidgets = function(object, prefix)
		local widgetList = {
			parent = object:GetWidget(prefix)
		}

		for k,v in pairs(socialEntry.getUserWidgets(object, prefix)) do
			widgetList[k] = v
		end

		for k,v in pairs(socialEntry.getHeaderWidgets(object, prefix)) do
			widgetList[k] = v
		end

		return widgetList
	end,
	getActionItemWidgets = function(object, prefix, index)
		return {
			body		= object:GetWidget(prefix..'ActionItem'..index..'Body'),			-- All visible elements here
			button		= object:GetWidget(prefix..'ActionItem'..index),
			icon		= object:GetWidget(prefix..'ActionItem'..index..'Icon'),
			buttonPanel	= object:GetWidget(prefix..'ActionItem'..index..'ButtonPanel'),	-- Button cannot slide
			tip			= object:GetWidget(prefix..'ActionItem'..index..'Tip'),
			tipLabel	= object:GetWidget(prefix..'ActionItem'..index..'TipLabel')
		}
	end,
	actionItemWidth		= 95,	-- '@'
	actionItemSlideTime	= 150,
	actionItemReposition = function(widgets, visible, barData)
		visible		= visible or false
		local xPos	= barData.actionItemOffset	-- maybe just 0 always?
		if visible then
			xPos = (xPos - (95 * barData.actionItemCountVisible))
		end

		xPos = widgets.body:GetXFromString((xPos..'@'))

		widgets.buttonPanel:SlideX(xPos, socialEntry.actionItemSlideTime)
		widgets.body:SlideX(xPos, socialEntry.actionItemSlideTime)
	end,
	createActionBarData = function(actionItemOffset, startCountVisible)
		startCountVisible = startCountVisible or 0
		return {
			actionItemOffset		= (actionItemOffset or 0),	-- '@'
			actionItemCountVisible	= startCountVisible,
			haveButtonsToShow		= false
		}
	end,
	actionItemReadyLabelUpdate = function(widget, trigger)
		if (trigger.selectedHero < 0)  then
			widget:SetText(Translate('social_action_bar_toheropick'))
		elseif (trigger.isLocalPlayerReady) then
			widget:SetText(Translate('social_action_bar_unready_up'))
		else
			widget:SetText(Translate('social_action_bar_ready_up'))
		end
	end,
	actionItemReadyIconUpdate = function(widget, trigger)
		if (trigger.isLocalPlayerReady) then
			widget:SetTexture('/ui/main/party/textures/icon_ready.tga')
		else
			widget:SetTexture('/ui/main/party/textures/icon_waiting.tga')
		end
	end,
	actionItemSetHover = function(isHovering, tipWidget, userID, hoverData)
		userID = userID or -1
		local socialPanelInfoHovering = LuaTrigger.GetTrigger('socialPanelInfoHovering')
		if (hoverData) and (socialPanelInfoHovering.friendHoveringIdentID == hoverData.friendHoveringIdentID) then
			socialPanelInfoHovering.friendHoveringIsHoveringMenu 	= isHovering
			socialPanelInfoHovering.friendHoveringWidgetIndex 		= userID
			socialPanelInfoHovering:Trigger(false)

			libGeneral.fade(tipWidget, isHovering, 150)
		else
			libGeneral.fade(tipWidget, false, 150)
		end
	end,
	-- rmm remove hoverdata
	actionItemSetVis = function(widgets, isVisible, barData)
		isVisible = isVisible or false

		widgets.buttonPanel:SetVisible(isVisible)
		libGeneral.fade(widgets.body, isVisible, socialEntry.actionItemSlideTime)
		socialEntry.actionItemReposition(widgets, isVisible, barData)
	end,
	actionItemPaySetStatusColor = function(widgets, selfPaid, otherPaid)
		if widgets and widgets.buttonInfo then
			selfPaid = selfPaid or false
			otherPaid = otherPaid or false
			localPaid = localPaid or false
			local payIcon = widgets.icon
			payIcon:SetRenderMode('grayscale')

			if localPaid then
				payIcon:SetColor(0.2,0.42,0.87)
				widgets.buttonInfo.baseColorR = 0.2
				widgets.buttonInfo.baseColorG = 0.42
				widgets.buttonInfo.baseColorB = 0.87
			elseif selfPaid then
				payIcon:SetColor(0,1,0)
				widgets.buttonInfo.baseColorR = 0
				widgets.buttonInfo.baseColorG = 1
				widgets.buttonInfo.baseColorB = 0

			elseif otherPaid then
				payIcon:SetColor(1, 0.65, 0)
				widgets.buttonInfo.baseColorR = 1
				widgets.buttonInfo.baseColorG = 0.65
				widgets.buttonInfo.baseColorB = 0
			else	-- no paid!
				payIcon:SetColor(0.75, 0.75, 0.75)
				widgets.buttonInfo.baseColorR = 0.75
				widgets.buttonInfo.baseColorG = 0.75
				widgets.buttonInfo.baseColorB = 0.75
			end
		end
	end,
	actionItemRegister = function(widgets, entryType, userID, itemID, hoverData, barData, onclick, isVisible, iconBase, iconHover, tipText, afterOnclick)
		isVisible = isVisible or false


		socialEntry.actionItemSetVis(widgets, isVisible, barData)

		if isVisible then
			barData.actionItemCountVisible = barData.actionItemCountVisible + 1
			local textureSwap = (iconHover ~= nil)

			if iconBase then
				widgets.icon:SetTexture(iconBase)
			end

			if tipText then
				widgets.tipLabel:SetText(tipText)
			end

			widgets.buttonInfo = libButton2.register(
				{
					widgets		= {
						button		= widgets.button,
						Icon		= widgets.icon
					},
					overTexture	= iconHover,
					textureSwap = textureSwap,
				}, 'socialEntryUserActionItem'
			)

			if (afterOnclick) then
				widgets.button:SetCallback('onclick', function(...) onclick(...) afterOnclick(...) end )
			else
				widgets.button:SetCallback('onclick', onclick)
			end

			widgets.button:SetCallback('onmouseover', function(widget)
				socialEntry.actionItemSetHover(true, widgets.tip, userID, hoverData)
			end)

			widgets.button:SetCallback('onmouseout', function(widget)
				socialEntry.actionItemSetHover(false, widgets.tip, -1, hoverData)
			end)

			barData.haveButtonsToShow = true
		end

		return isVisible
	end,
	actionItemRegisterSendIM = function(widgets, entryType, userID, itemID, hoverData, barData, afterOnclick)
		return socialEntry.actionItemRegister(widgets, entryType, userID, itemID, hoverData, barData, function(widget)
			mainUI.chatManager.InitPrivateMessage(hoverData.friendHoveringIdentID, nil, hoverData.friendHoveringName or '')
		end, ChatClient.IsOnline(hoverData.friendHoveringIdentID) and not IsMe(hoverData.friendHoveringIdentID),'/ui/main/friends/textures/icon_message.tga', nil, Translate('social_action_bar_send_im'), afterOnclick)
	end,
	actionItemRegisterInviteToParty = function(widgets, entryType, userID, itemID, hoverData, barData, afterOnclick)
		local triggerHeroSelectInfo		= LuaTrigger.GetTrigger('HeroSelectInfo')
		return socialEntry.actionItemRegister(widgets, entryType, userID, itemID, hoverData, barData, function(widget)
			local partyCustomTrigger = LuaTrigger.GetTrigger('PartyTrigger')

			ChatClient.PartyInvite(hoverData.friendHoveringIdentID)
			partyCustomTrigger.userRequestedParty = true
			partyCustomTrigger:Trigger(false)

			-- sound_socialInviteToParty
			PlaySound('/ui/sounds/parties/sfx_invite_send.wav')
		end, (
			(not IsMe(hoverData.friendHoveringIdentID)) and
			( (triggerHeroSelectInfo.type == 'party') or ( (LuaTrigger.GetTrigger('HeroSelectMode').mode == 'captains') and (LuaTrigger.GetTrigger('PartyStatus').isPartyLeader) ) ) and
			(not LuaTrigger.GetTrigger('HeroSelectMode').isCustomLobby) and
			(not hoverData.friendHoveringIsInGame) and
			(not hoverData.friendHoveringIsInLobby) and
			-- (not hoverData.friendHoveringIsInParty) and
			ChatClient.IsOnline(hoverData.friendHoveringIdentID) and
			-- (not IsInParty(hoverData.friendHoveringIdentID)) and
			((mainUI.featureMaintenance) and (not mainUI.featureMaintenance['party']))
		), '/ui/main/friends/textures/icon_party.tga', nil, Translate('social_action_bar_invite_to_party'), afterOnclick)
	end,
	actionItemRegisterSpectate = function(widgets, entryType, userID, itemID, hoverData, barData, afterOnclick)
		return socialEntry.actionItemRegister(widgets, entryType, userID, itemID, hoverData, barData, function(widget)
			mainUI.SpectateGame(hoverData.friendHoveringIdentID)
		end, (((mainUI.featureMaintenance) and (not mainUI.featureMaintenance['spectate'])) and (hoverData.friendHoveringIdentID) and ChatClient.IsFriend(hoverData.friendHoveringIdentID) and ChatClient.IsOnline(hoverData.friendHoveringIdentID) and hoverData.spectatableGame ), '/ui/main/friends/textures/icon_spectate.tga', nil, Translate('social_action_bar_spectate'), afterOnclick)
	end,
	actionItemRegisterFriendAdd = function(widgets, entryType, userID, itemID, hoverData, barData, afterOnclick)
		local friendHoveringIdentID = hoverData.friendHoveringIdentID
		return socialEntry.actionItemRegister(widgets, entryType, userID, itemID, hoverData, barData, function(widget)
			ChatClient.AddFriend(hoverData.friendHoveringIdentID)
			if ChatClient.IsIgnored(hoverData.friendHoveringIdentID) then
				ChatClient.RemoveIgnore(hoverData.friendHoveringIdentID)
			end
			-- sound_socialAddFriend
			PlaySound('ui/sounds/sfx_button_generic.wav')
		end, ((not ChatClient.IsFriend(hoverData.friendHoveringIdentID)) and (not IsMe(hoverData.friendHoveringIdentID)) and (hoverData.friendHoveringAcceptStatus ~= 'pending') and (hoverData.friendHoveringAcceptStatus ~= 'sent')),
			'/ui/main/friends/textures/icon_friend_add.tga', nil, Translate('social_action_bar_add_friend'), afterOnclick
		)
	end,
	actionItemRegisterFriendAccept = function(widgets, entryType, userID, itemID, hoverData, barData, afterOnclick)
		return socialEntry.actionItemRegister(widgets, entryType, userID, itemID, hoverData, barData, function(widget)
			ChatClient.SetFriendStatus(hoverData.friendHoveringIdentID, 'approved')
			if ChatClient.IsIgnored(hoverData.friendHoveringIdentID) then
				ChatClient.RemoveIgnore(hoverData.friendHoveringIdentID)
			end
			-- sound_socialAcceptFriend
			PlaySound('ui/sounds/sfx_button_generic.wav')
		end, (hoverData.friendHoveringAcceptStatus == 'pending'), '/ui/main/friends/textures/icon_friend_add.tga', nil, Translate('social_action_bar_accept_friend'), afterOnclick)
	end,
	actionItemRegisterFriendReject = function(widgets, entryType, userID, itemID, hoverData, barData, afterOnclick)
		return socialEntry.actionItemRegister(widgets, entryType, userID, itemID, hoverData, barData, function(widget)
			ChatClient.SetFriendStatus(hoverData.friendHoveringIdentID, 'rejected')
			-- sound_socialRejectFriend
			PlaySound('ui/sounds/sfx_button_generic.wav')
		end, (hoverData.friendHoveringAcceptStatus == 'pending'), '/ui/main/friends/textures/icon_friend_remove.tga', nil, Translate('social_action_bar_decline_friend'), afterOnclick)
	end,
	actionItemRegisterRemoveIgnore = function(widgets, entryType, userID, itemID, hoverData, barData, afterOnclick)
		return socialEntry.actionItemRegister(widgets, entryType, userID, itemID, hoverData, barData, function(widget)
			ChatClient.RemoveIgnore(hoverData.friendHoveringIdentID)
			-- sound_socialRejectFriend
			PlaySound('ui/sounds/sfx_button_generic.wav')
		end, ChatClient.IsIgnored(hoverData.friendHoveringIdentID), '/ui/main/friends/textures/icon_friend_remove.tga', nil, Translate('social_action_bar_removeignore'), afterOnclick)
	end,
	actionItemRegisterIgnore = function(widgets, entryType, userID, itemID, hoverData, barData, afterOnclick)
		return socialEntry.actionItemRegister(widgets, entryType, userID, itemID, hoverData, barData, function(widget)
			ChatClient.Ignore(hoverData.friendHoveringIdentID)
			-- sound_socialRejectFriend
			PlaySound('ui/sounds/sfx_button_generic.wav')
		end, (false) and (not ChatClient.IsIgnored(hoverData.friendHoveringIdentID)) and (hoverData.friendHoveringAcceptStatus == 'unknown'), '/ui/main/friends/textures/icon_friend_remove.tga', nil, Translate('social_action_bar_removeignore'), afterOnclick)
	end,
	actionItemRegisterFriendRemove = function(widgets, entryType, userID, itemID, hoverData, barData, afterOnclick)
		return socialEntry.actionItemRegister(widgets, entryType, userID, itemID, hoverData, barData, function(widget)
			GenericDialog(
				'social_action_bar_remove_friend', 'social_action_bar_remove_friend_desc', '', 'general_ok', 'general_cancel',
				function()
					ChatClient.RemoveFriend(hoverData.friendHoveringIdentID)
					-- sound_socialRemoveFriend
					PlaySound('ui/sounds/sfx_button_generic.wav')
				end,
				function()
					PlaySound('/ui/sounds/sfx_ui_back.wav')
				end
			)
		end, (ChatClient.IsFriend(hoverData.friendHoveringIdentID) or hoverData.friendHoveringAcceptStatus ~= '') and (hoverData.friendHoveringAcceptStatus ~= 'pending') and not IsMe(hoverData.friendHoveringIdentID), '/ui/main/friends/textures/icon_friend_remove.tga', nil, Translate('social_action_bar_remove_friend'), afterOnclick)
	end,
	actionItemRegisterChangeGroup = function(widgets, entryType, userID, itemID, hoverData, barData, afterOnclick)
		return socialEntry.actionItemRegister(widgets, entryType, userID, itemID, hoverData, barData, function(widget)
			Friends.EditFriendInfo(hoverData.friendHoveringIdentID, hoverData.friendHoveringLabel)	-- Friends.UpdateAndDisplayLabelListbox
			-- sound_socialChangeGroup
			PlaySound('/ui/sounds/parties/sfx_change.wav')
		end, (ChatClient.IsFriend(hoverData.friendHoveringIdentID) and (hoverData.friendHoveringAcceptStatus == 'approved')), '/ui/main/friends/textures/icon_change_group.tga', nil, Translate('social_action_bar_edit_group'), afterOnclick)
	end,
	actionItemRegisterViewProfile = function(widgets, entryType, userID, itemID, hoverData, barData, afterOnclick)
		return socialEntry.actionItemRegister(widgets, entryType, userID, itemID, hoverData, barData, function(widget)
			local triggerPanelStatus = LuaTrigger.GetTrigger('mainPanelStatus')
			triggerPanelStatus.selectedUserIdentID = hoverData.friendHoveringIdentID
			triggerPanelStatus.main = 23
			triggerPanelStatus:Trigger(false)
			-- sound_socialViewProfile
			PlaySound('ui/sounds/sfx_button_generic.wav')
		end, ChatClient.IsOnline(hoverData.friendHoveringIdentID), '/ui/main/friends/textures/icon_profile.tga', nil, Translate('social_action_bar_view_profile'), afterOnclick)
	end,
	actionItemRegisterChallenge = function(widgets, entryType, userID, itemID, hoverData, barData, afterOnclick)
		return socialEntry.actionItemRegister(widgets, entryType, userID, itemID, hoverData, barData, function(widget)
			-- sound_socialChallenge
			ScrimFinder.ChallengePlayerByIdentID(hoverData.friendHoveringIdentID)
			PlaySound('ui/sounds/sfx_button_generic.wav')
		end, (((mainUI.featureMaintenance) and ((not LuaTrigger.GetTrigger('PartyStatus').inParty) or (LuaTrigger.GetTrigger('PartyStatus').isPartyLeader)) and (not mainUI.featureMaintenance['scrim'])) and ChatClient.IsOnline(hoverData.friendHoveringIdentID) and libGeneral.canIAccessChallenges() and (not IsMe(hoverData.friendHoveringIdentID))), '/ui/main/friends/textures/icon_challenge.tga', nil, Translate('social_action_bar_challenge_issue'), afterOnclick)
	end,	
	actionItemRegisterLobbyInvite = function(widgets, entryType, userID, itemID, hoverData, barData, afterOnclick)
		return socialEntry.actionItemRegister(widgets, entryType, userID, itemID, hoverData, barData, function(widget)
			ChatClient.GameInvite(hoverData.friendHoveringIdentID)
			PlaySound('/ui/sounds/parties/sfx_invite_send.wav')
			-- Disable the button first, which causes the icon to wobble
			widget:SetEnabled(false)
			widget:SetVisible(false)
			local colors = {'#f68f52', '#64e0ff'}
			libThread.threadFunc(function()
				for n = 1, 4 do
					widgets.icon:SetColor(colors[(n%2)+1])
					wait(125)
				end
				widgets.tipLabel:SetText(Translate('social_action_bar_invited_to_lobby'))
				widget:SetEnabled(true)
				widget:SetVisible(true)
				
				wait(3000)
				if (widgets and widgets.tipLabel and widgets.tipLabel:IsValid()) then
					widgets.tipLabel:SetText(Translate('social_action_bar_invite_to_lobby'))
				end
			end)
			
		end, (
			(not IsMe(hoverData.friendHoveringIdentID)) and
			(LuaTrigger.GetTrigger('HeroSelectInfo').type == 'lobby') and
			(LuaTrigger.GetTrigger('LobbyStatus').isHost) and
			(not hoverData.friendHoveringIsInGame) and
			(not hoverData.friendHoveringIsInLobby) and
			ChatClient.IsOnline(hoverData.friendHoveringIdentID) and
			-- (not IsInParty(hoverData.friendHoveringIdentID)) and
			((mainUI.featureMaintenance) and (not mainUI.featureMaintenance['party']))
		), '/ui/main/friends/textures/icon_party.tga', nil, Translate('social_action_bar_invite_to_lobby'), afterOnclick)
	end,
	actionItemRegisterLobbyJoin = function(widgets, entryType, userID, itemID, hoverData, barData, afterOnclick)
		return socialEntry.actionItemRegister(widgets, entryType, userID, itemID, hoverData, barData, function(widget)
			ChatClient.JoinFriendGame(hoverData.friendHoveringIdentID)
		end, ((false) and ChatClient.IsOnline(hoverData.friendHoveringIdentID) and hoverData.joinableGame and (not hoverData.joinableParty)), '/ui/main/friends/textures/icon_group_invite.tga', nil, Translate('social_action_bar_join_lobby'), afterOnclick)
	end,
	actionItemRegisterPartyJoin = function(widgets, entryType, userID, itemID, hoverData, barData, afterOnclick)
		return socialEntry.actionItemRegister(widgets, entryType, userID, itemID, hoverData, barData, function(widget)
			ChatClient.JoinFriendParty(hoverData.friendHoveringIdentID)
		end, ((false) and ChatClient.IsOnline(hoverData.friendHoveringIdentID) and hoverData.joinableParty), '/ui/main/friends/textures/icon_group_invite.tga', nil, Translate('social_action_bar_join_party'), afterOnclick)
	end,
	actionItemRegisterKickPlayer = function(widgets, entryType, userID, itemID, hoverData, barData, playScreen, afterOnclick)
		playScreen = playScreen or false
		local partyStatus			= LuaTrigger.GetTrigger('PartyStatus')
		return socialEntry.actionItemRegister(widgets, entryType, userID, itemID, hoverData, barData, function(widget)
			ChatClient.PartyKick(hoverData.friendHoveringIdentID)
			println('^y Request kick from party: ' .. tostring(hoverData.friendHoveringIdentID))
			-- sound_socialRemoveFromParty
			PlaySound('/ui/sounds/parties/sfx_remove.wav')
		end, ( partyStatus.isPartyLeader and (not IsMe(hoverData.friendHoveringIdentID)) and ((not playScreen) or LuaTrigger.GetTrigger('HeroSelectInfo').type == 'party')),
		'/ui/main/party/textures/icon_boot.tga', nil, Translate('social_action_bar_kick_player'), afterOnclick)
	end,
	actionItemRegisterLeaveParty = function(widgets, entryType, userID, itemID, hoverData, barData, playScreen, afterOnclick, forceVisible)
		playScreen = playScreen or false
		local showItem = true
		forceVisible = forceVisible or false


		if hoverData ~= nil then
			local tutorialComplete 		= LuaTrigger.GetTrigger('newPlayerExperience').tutorialComplete
			local partyStatus			= LuaTrigger.GetTrigger('PartyStatus')
			local partyCustomTrigger	= LuaTrigger.GetTrigger('PartyTrigger')
			showItem = forceVisible or (partyStatus.inParty and tutorialComplete and (IsMe(hoverData.friendHoveringIdentID) and ((not partyStatus.isPartyLeader) or partyCustomTrigger.userRequestedParty) ) and ((not playScreen) or LuaTrigger.GetTrigger('HeroSelectInfo').type == 'party'))
		else
			local tutorialComplete 		= LuaTrigger.GetTrigger('newPlayerExperience').tutorialComplete
			showItem = tutorialComplete
		end

		return socialEntry.actionItemRegister(widgets, entryType, userID, itemID, hoverData, barData, function(widget)
			Party.LeaveParty()
			LeaveGameLobby()
			-- sound_socialLeaveParty
			PlaySound('/ui/sounds/parties/sfx_leave.wav')
		end, showItem, '/ui/main/party/textures/icon_door.tga', nil, Translate('social_action_bar_leave_party'), afterOnclick)
	end,
	actionItemRegisterLeavePlay = function(widgets, entryType, userID, itemID, hoverData, barData, playScreen, afterOnclick)
		playScreen = playScreen or false
		local partyStatus			= LuaTrigger.GetTrigger('PartyStatus')
		local partyCustomTrigger	= LuaTrigger.GetTrigger('PartyTrigger')

		return socialEntry.actionItemRegister(widgets, entryType, userID, itemID, hoverData, barData, function(widget)
			LeaveGameLobby()
		end, ( partyStatus.inParty and ChatClient.IsOnline(hoverData.friendHoveringIdentID) and IsMe(hoverData.friendHoveringIdentID) and (not ((not partyStatus.isPartyLeader) or partyCustomTrigger.userRequestedParty)) and ((not playScreen) or LuaTrigger.GetTrigger('HeroSelectInfo').type == 'party') ),
		'/ui/main/friends/party/icon_door.tga', nil, Translate('social_action_bar_leave'), afterOnclick)
	end,
	actionItemRegisterReady = function(widgets, entryType, userID, itemID, hoverData, barData, afterOnclick)	-- 14pt2, the 15ening
		local selection_Status	= LuaTrigger.GetTrigger('selection_Status')

		widgets.buttonPanel:SetVisible(true)
		widgets.body:SetVisible(true)

		widgets.tipLabel:UnregisterWatchLua('selection_Status')
		widgets.tipLabel:RegisterWatchLua('selection_Status', socialEntry.actionItemReadyLabelUpdate, false, nil, 'isLocalPlayerReady', 'selectedHero')
		socialEntry.actionItemReadyLabelUpdate(widgets.tipLabel, selection_Status)
		widgets.icon:UnregisterWatchLua('PartyStatus')
		widgets.icon:RegisterWatchLua('PartyStatus', socialEntry.actionItemReadyIconUpdate, false, nil, 'isLocalPlayerReady')
		socialEntry.actionItemReadyIconUpdate(widgets.icon, LuaTrigger.GetTrigger('PartyStatus'))

		return socialEntry.actionItemRegister(widgets, entryType, userID, itemID, hoverData, barData, function(widget)
			local partyStatus			= LuaTrigger.GetTrigger('PartyStatus')
			if (partyStatus.isLocalPlayerReady) then
				Cmd('UnReady')
			else
				if (LuaTrigger.GetTrigger('selection_Status').selectedHero >= 0) then
					Cmd('Ready')
				else
					local trigger_mainPanelStatus 				= 	LuaTrigger.GetTrigger('mainPanelStatus')
					if (trigger_mainPanelStatus.main ~= 40) then
						trigger_mainPanelStatus.main = 40
						trigger_mainPanelStatus:Trigger(false)
					end
				end
			end
		end, true, nil, nil, nil, afterOnclick)
	end,
	actionItemRegisterPayForSeat = function(widgets, entryType, userID, itemID, hoverData, barData, showCondition, selfPaid, otherPaid, localPaid)
		selfPaid = selfPaid or false
		otherPaid = otherPaid or false
		return socialEntry.actionItemRegister(widgets, entryType, userID, itemID, hoverData, barData, function(widget)
			-- rmm create popup later on
			-- SendPayForGame(hoverData.friendHoveringIdentID, 1)
			selectionPayForSeatShow(hoverData.friendHoveringIdentID, hoverData.friendHoveringName, (hoverData.friendHoveringIdentID == GetIdentID()), selfPaid, otherPaid, localPaid)

			-- 0 none
			-- 1 gems
			-- 2 tokens
		end, showCondition,
		'/ui/shared/textures/gold_coins.tga', nil, Translate('social_action_bar_pay_for_seat'), afterOnclick)
	end
}