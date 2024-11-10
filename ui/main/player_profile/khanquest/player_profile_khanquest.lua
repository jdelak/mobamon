-- Khanquest section for Player Profile

playerProfile_khanquest = playerProfile_khanquest or {
	profileLoaded		= false,
	countPerWins		= {},
	totalWins			= 0,
	totalGames			= 0,
	livesStart			= 2,
}

trigger_playerProfileKhanquestInfo = LuaTrigger.CreateCustomTrigger('playerProfileKhanquestInfo', {
	{ name	= 'section',		type	= 'number'},
	{ name	= 'searchFilter',	type	= 'string'},
	{ name	= 'isFiltered',		type	= 'boolean'},
	{ name	= 'hoverIndex',		type	= 'number'},
	{ name	= 'hoverType',		type	= 'number'},	-- 0 for none, 1 for team, 2 for tournament
})

-- ========================================================================================

local socialPanelInfoHovering = LuaTrigger.GetTrigger('socialPanelInfoHovering')

local function getNonSelfPlayerList(infoTable)
	local playerInfos = {}
	for i=1,5,1 do
		if infoTable['seat'..i] ~= GetIdentID() then
			table.insert(playerInfos, {
				identID		= infoTable['seat'..i],
				playerName	= infoTable['seat'..i..'PlayerName']
			})
		end
	end

	return playerInfos
end

local function playerProfileKhanquestRegisterPlayerEntry(object, prefix, index, playerInfo, hoverType, hoverSubtype)
	playerInfo = playerInfo or {}

	hoverType = hoverType or 3
	hoverSubtype = hoverSubtype or 0
	prefix = prefix or ''
	
	local widgets		= socialEntry.getEntryWidgets(object, prefix)
	if ChatClient.IsSpectating(playerInfo.identID) then 
		widgets.userStatus:SetColor('#e82000') -- red
		widgets.userGroup:SetText(Translate('friend_online_status_spectating'))
		widgets.userGroup:SetColor('.6 .6 .6 1')				 
	elseif ChatClient.IsInLocalGame(playerInfo.identID) then 
		widgets.userStatus:SetColor('#e82000') -- red
		widgets.userGroup:SetText(Translate('friend_online_status_practice'))
		widgets.userGroup:SetColor('.6 .6 .6 1')
	elseif ChatClient.IsInGame(playerInfo.identID) then 
		widgets.userStatus:SetColor('#e82000') -- red
		widgets.userGroup:SetText(Translate('friend_online_status_ingame'))
		widgets.userGroup:SetColor('.6 .6 .6 1')					
	--[[
	elseif (data.isInParty) and (data.acceptStatus == 'approved') then
		widgets.userStatus:SetColor('#FF9100') -- orange	
		widgets.userGroup:SetText(Translate('friend_online_status_inparty'))
		widgets.userGroup:SetColor('.6 .6 .6 1')
	elseif (data.isInLobby) and (data.acceptStatus == 'approved') then
		widgets.userStatus:SetColor('#FF9100') -- orange		
		widgets.userGroup:SetText(Translate('friend_online_status_inlobby'))	
		widgets.userGroup:SetColor('.6 .6 .6 1')
	-- elseif (false) then -- is ready to play RMM
		-- widgets.userStatus:SetColor('#138dff') -- blue
	--]]
	elseif ChatClient.IsOnline(playerInfo.identID) then
		widgets.userStatus:SetColor('#b7ff00') -- green
		widgets.userGroup:SetText(Translate('friend_online_status_online'))
		widgets.userGroup:SetColor('.8 .8 .8 1')
	else
		widgets.userStatus:SetColor('.3 .2 .2 .7') -- faded gray red
		widgets.userGroup:SetText(Translate('friend_online_status_offline'))
		widgets.userGroup:SetColor('.4 .4 .4 1')
	end
	
	widgets.userIcon:SetTexture('/ui/shared/textures/account_icons/default.tga')
	widgets.userName:SetText(playerInfo.playerName or '')

	local function userButtonOver(widget)
		UpdateCursor(widget, true, { canLeftClick = true, canRightClick = true, canDrag = true })
		if ((playerInfo.playerName) and (not Empty(playerInfo.playerName))) or true then
			socialPanelInfoHovering.friendHoveringIndex 		= index
			socialPanelInfoHovering.friendHoveringWidgetIndex 	= index
			socialPanelInfoHovering.friendHoveringIdentID		= playerInfo.identID or -1
			socialPanelInfoHovering.friendHoveringUniqueID		= playerInfo.uniqueID or -1
			socialPanelInfoHovering.friendHoveringName			= playerInfo.playerName or ''
			socialPanelInfoHovering.friendHoveringAcceptStatus	= playerInfo.acceptStatus or ''
			socialPanelInfoHovering.friendHoveringLabel			= playerInfo.buddyLabel or 'Default'
			socialPanelInfoHovering.friendHoveringIsFriend		= ChatClient.IsFriend(playerInfo.identID) or false
			socialPanelInfoHovering.friendHoveringCanSpectate	= ChatClient.IsInGame(playerInfo.identID) or false
			socialPanelInfoHovering.friendHoveringIsInLobby		= playerInfo.isInLobby or false
			socialPanelInfoHovering.friendHoveringIsOnline		= ChatClient.IsOnline(playerInfo.identID) or false
			socialPanelInfoHovering.friendHoveringIsInGame		= ChatClient.IsInGame(playerInfo.identID) or false
			socialPanelInfoHovering.friendHoveringType			= hoverType
			socialPanelInfoHovering.friendHoveringSubType		= hoverSubtype
			socialPanelInfoHovering:Trigger(false)
		end
		-- TeamInfo.TeamListCheckLock()
	end
	
	widgets.userButton:SetCallback('onmouseover', userButtonOver)
	
	widgets.userButton:SetCallback('onmouseout', function(widget)
		UpdateCursor(widget, false, { canLeftClick = true, canRightClick = true, canDrag = true })
		if (widget:IsVisible()) then
			socialPanelInfoHovering.friendHoveringWidgetIndex 	=	-1
			socialPanelInfoHovering.friendHoveringIdentID 		=	playerInfo.identID or -1
			socialPanelInfoHovering:Trigger(false)
		end
		-- TeamInfo.TeamListCheckLock()
	end)
	
	-- =============================
	-- =============================
	
	local barOffset = 55
	local lastItemCountShown	= nil
	
	local function clearActionBar()
		local barItemGroup = object:GetGroup(prefix..'ActionItemVisGroup')
		for k,v in ipairs(barItemGroup) do
			v:SlideX(0, socialEntry.actionItemSlideTime)
			v:FadeOut(socialEntry.actionItemSlideTime)
		end
		widgets.actionBacker:ScaleWidth(widgets.actionBacker:GetWidthFromString(55 + barOffset..'@'), socialEntry.actionItemSlideTime)
		lastItemCountShown		= nil
		lastItemCountVisible	= 0
	end

	widgets.actionBarButtons:SetPassiveChildren(false)
	local lastHovering = false
	local lastIdentID
	local lastItemCountVisible	= 0

	widgets.actionBacker:FadeIn(socialEntry.actionItemSlideTime)
	widgets.actionBacker:ScaleWidth(widgets.actionBacker:GetWidthFromString(55 + barOffset..'@'), socialEntry.actionItemSlideTime)
	
	local function afterOnclick()
		-- triggerStatus.teamListSingleUpdate = true
		-- PopulateTeamList(UIManager.GetActiveInterface())
	end				
	
	local function ProcessHover(widget, trigger)
		barData = socialEntry.createActionBarData((barOffset * -1))

		local isHovering		= (trigger.friendHoveringWidgetIndex == index and trigger.friendHoveringType == hoverType and trigger.friendHoveringSubType == hoverSubtype)
		
		if isHovering then
			if trigger.friendHoveringIdentID ~= lastIdentID then	-- Slot data changes
				lastHovering = false
			end
			lastIdentID = trigger.friendHoveringIdentID
			if (not lastHovering) then	-- lastFriendHoveringWidgetIndex ~= index
				
				socialEntry.actionItemRegisterSendIM(socialEntry.getActionItemWidgets(object, prefix, 1), 0, index, 1, trigger, barData)
				socialEntry.actionItemRegisterLeaveParty(socialEntry.getActionItemWidgets(object, prefix, 2), 0, index, 2, trigger, barData)
				socialEntry.actionItemRegisterLeavePlay(socialEntry.getActionItemWidgets(object, prefix, 3), 0, index, 3, trigger, barData, false)
				-- socialEntry.actionItemRegisterViewProfile(socialEntry.getActionItemWidgets(object, prefix, 4), 0, index, 4, trigger, barData)
				socialEntry.actionItemRegisterFriendAdd(socialEntry.getActionItemWidgets(object, prefix, 5), 0, index, 5, trigger, barData)
				socialEntry.actionItemRegisterFriendAccept(socialEntry.getActionItemWidgets(object, prefix, 6), 0, index, 6, trigger, barData)
				socialEntry.actionItemRegisterFriendReject(socialEntry.getActionItemWidgets(object, prefix, 7), 0, index, 7, trigger, barData)
				socialEntry.actionItemRegisterChangeGroup(socialEntry.getActionItemWidgets(object, prefix, 8), 0, index, 8, trigger, barData)
				socialEntry.actionItemRegisterFriendRemove(socialEntry.getActionItemWidgets(object, prefix, 9), 0, index, 9, trigger, barData)
				socialEntry.actionItemRegisterKickPlayer(socialEntry.getActionItemWidgets(object, prefix, 10), 0, index, 10, trigger, barData, false, afterOnclick)
				
				-- socialEntry.actionItemRegisterInviteToParty(socialEntry.getActionItemWidgets(object, prefix, 2), 0, index, 2, trigger, barData)
				-- socialEntry.actionItemRegisterLobbyInvite(socialEntry.getActionItemWidgets(object, prefix, 10), 0, index, 10, trigger, barData)
				-- socialEntry.actionItemRegisterSpectate(socialEntry.getActionItemWidgets(object, prefix, 4), 0, index, 4, trigger, barData)
				-- socialEntry.actionItemRegisterLobbyJoin(socialEntry.getActionItemWidgets(object, prefix, 11), 0, index, 11, trigger, barData)
				
				lastItemCountVisible = barData.actionItemCountVisible
			end
			lastHovering = true
		else
			if lastHovering then
				socialEntry.actionItemSetVis(socialEntry.getActionItemWidgets(object, prefix, 1), false, barData)
				socialEntry.actionItemSetVis(socialEntry.getActionItemWidgets(object, prefix, 2), false, barData)
				socialEntry.actionItemSetVis(socialEntry.getActionItemWidgets(object, prefix, 3), false, barData)
				socialEntry.actionItemSetVis(socialEntry.getActionItemWidgets(object, prefix, 4), false, barData)
				socialEntry.actionItemSetVis(socialEntry.getActionItemWidgets(object, prefix, 5), false, barData)
				socialEntry.actionItemSetVis(socialEntry.getActionItemWidgets(object, prefix, 6), false, barData)
				socialEntry.actionItemSetVis(socialEntry.getActionItemWidgets(object, prefix, 7), false, barData)
				socialEntry.actionItemSetVis(socialEntry.getActionItemWidgets(object, prefix, 8), false, barData)
				socialEntry.actionItemSetVis(socialEntry.getActionItemWidgets(object, prefix, 9), false, barData)
				socialEntry.actionItemSetVis(socialEntry.getActionItemWidgets(object, prefix, 10), false, barData)

				lastItemCountVisible = barData.actionItemCountVisible
			end
			lastHovering = false
		end
		
		if barData.haveButtonsToShow then
			widgets.actionBarButtons:SetPassiveChildren(false)
		
			if lastItemCountShown ~= lastItemCountVisible then
				widgets.actionBacker:ScaleWidth(widgets.actionBacker:GetWidthFromString(35 + barOffset + (lastItemCountVisible * 95)..'@'), socialEntry.actionItemSlideTime)
				lastItemCountShown = lastItemCountVisible
			end
		else
			widgets.actionBarButtons:SetPassiveChildren(true)
			clearActionBar()	-- Everything
		end
	end
	widgets.parent:UnregisterWatchLua('socialPanelInfoHovering')
	widgets.parent:RegisterWatchLua('socialPanelInfoHovering', function(widget, trigger)
		ProcessHover(widget, trigger)
	end)
	
	ProcessHover(widgets.parent, socialPanelInfoHovering)
	
	-- =============================
	-- =============================
end

-- ========================================================================================

local function playerProfileKhanquestRegisterActiveTeam(object, listbox, index, teamInfo)

	listbox:AddTemplateListItem('khanquest_entry', index, 'id', index, 'prefix', 'ActiveTeam')

	local container		= object:GetWidget('playerProfile_khanquestActiveTeam'..index)
	local backer		= object:GetWidget('playerProfile_khanquestActiveTeam'..index..'Backer')
	local wins			= object:GetWidget('playerProfile_khanquestActiveTeam'..index..'Wins')
	local lives			= object:GetWidget('playerProfile_khanquestActiveTeam'..index..'Lives')
	
	local title			= object:GetWidget('playerProfile_khanquestActiveTeam'..index..'Title')
	local forfeit		= object:GetWidget('playerProfile_khanquestActiveTeam'..index..'Forfeit')
	local continue		= object:GetWidget('playerProfile_khanquestActiveTeam'..index..'Continue')
	local create		= object:GetWidget('playerProfile_khanquestActiveTeam'..index..'Create')
	
	local progressContainer	= object:GetWidget('playerProfile_khanquestActiveTeam'..index..'ProgressContainer')
	local hoverActions	= object:GetWidget('playerProfile_khanquestActiveTeam'..index..'HoverActions')
	
	
	if teamInfo then
		progressContainer:SetVisible(true)
	
		if tonumber(teamInfo.active) == 1 then
			forfeit:SetEnabled(true)
			forfeit:SetCallback('onclick', function(Widget)
				local teamIDs = {}
				for i=1,5,1 do
					if teamInfo['seat'..i] ~= GetIdentID() then
						table.insert(teamIDs, teamInfo['seat'..i])
					end
				end

				if #teamIDs == 4 then
					GenericDialogAutoSize(
						'player_profile_khanquest_forfeit', 'player_profile_khanquest_forfeit_desc', '', 'general_ok', 'general_cancel', 
							function()											
								SendTournamentForfeit(unpack(teamIDs))
							end,
							function()
								PlaySound('/ui/sounds/sfx_ui_back.wav')
							end
					)
				end

			end)
		else
			forfeit:SetEnabled(false)
		end
	
		local function setOver()
			trigger_playerProfileKhanquestInfo.hoverIndex = index
			trigger_playerProfileKhanquestInfo.hoverType = 1
			trigger_playerProfileKhanquestInfo:Trigger(false)
		end
		
		local function setOut()
			trigger_playerProfileKhanquestInfo.hoverIndex = -1
			trigger_playerProfileKhanquestInfo:Trigger(false)
		end
		
		container:SetCallback('onmouseover', setOver)
		container:SetCallback('onmouseout', setOut)
		
		local playerInfos = getNonSelfPlayerList(teamInfo)
		
		continue:SetCallback('onmouseover', setOver)
		continue:SetCallback('onmouseout', setOut)
		
		local playerOffline = false
		
		for k,v in ipairs(playerInfos) do
			if not ChatClient.IsOnline(v.identID) then
				playerOffline = true
			end
		end
		
		if playerOffline then
			title:SetText(Translate('player_profile_khanquest_team_notready'))
			title:SetColor('#00deff')
		else
			title:SetText(Translate('player_profile_khanquest_team_ready'))
			title:SetColor('#00ff1d')
		end

		continue:SetVisible(not playerOffline)
		
		local function continueSession()
			ChatClient.CreateParty()
			for k,v in ipairs(playerInfos) do
				ChatClient.PartyInvite(v.identID)
			end
		end
		
		continue:SetCallback('onclick', function(widget)
			if LuaTrigger.GetTrigger('PartyStatus').inParty then
				GenericDialogAutoSize(
					'player_profile_khanquest_continue_inparty', 'player_profile_khanquest_continue_inparty_desc', '', 'general_ok', 'general_cancel', 
						function()
							ChatClient.LeaveParty()
							continueSession()
						end,
						function()
							PlaySound('/ui/sounds/sfx_ui_back.wav')
						end
				)
			else
				continueSession()
			end

		end)
		
		forfeit:SetCallback('onmouseover', setOver)
		forfeit:SetCallback('onmouseout', setOut)
		
		hoverActions:RegisterWatchLua('playerProfileKhanquestInfo', function(widget, trigger)
			libGeneral.fade(widget, (trigger.hoverIndex == index and trigger.hoverType == 1), 250)
		end, false, nil, 'hoverIndex', 'hoverType')
		
		wins:SetText(teamInfo.wins)
		-- lives:SetText(math.max(0, playerProfile_khanquest.livesStart - teamInfo.losses))
		for i=1,4,1 do
			playerProfileKhanquestRegisterPlayerEntry(object, 'playerProfile_khanquestActiveTeam'..index..'Player'..i, i, playerInfos[i], 3, index)
		end
	else	-- Empty entry, generally to fill a row, etc.
		progressContainer:SetVisible(false)
		create:SetVisible(true)
	end

end

local function playerProfileKhanquestRegisterCompletedTournament(object, listbox, index, fullTournamentInfo)

	local tournamentInfo	= fullTournamentInfo.tournament
	local teamInfo			= fullTournamentInfo.team

	listbox:AddTemplateListItem('khanquest_entry', index, 'id', index, 'prefix', 'CompletedTournament')

	local container	= object:GetWidget('playerProfile_khanquestCompletedTournament'..index)
	local backer	= object:GetWidget('playerProfile_khanquestCompletedTournament'..index..'Backer')
	local wins		= object:GetWidget('playerProfile_khanquestCompletedTournament'..index..'Wins')
	local lives		= object:GetWidget('playerProfile_khanquestCompletedTournament'..index..'Lives')
	
	local title		= object:GetWidget('playerProfile_khanquestCompletedTournament'..index..'Title')
	local progressContainer	= object:GetWidget('playerProfile_khanquestCompletedTournament'..index..'ProgressContainer')
	
	local lastVis	= true

	local function setItemVis(showItem)
		if true then return end
		showItem = showItem or false
	
		if showItem then
			if not lastVis then
				listbox:ShowItemByValue(index)
				lastVis = true
			end
		else
			if lastVis then
				listbox:HideItemByValue(index)	
				lastVis = false
			end
		end
	end
	
	if tournamentInfo and teamInfo then
		--[[
		local function setOver()
			trigger_playerProfileKhanquestInfo.hoverIndex = index
			trigger_playerProfileKhanquestInfo.hoverType = 2
			trigger_playerProfileKhanquestInfo:Trigger(false)
		end
		
		local function setOut()
			trigger_playerProfileKhanquestInfo.hoverIndex = -1
			trigger_playerProfileKhanquestInfo:Trigger(false)
		end
		
		container:SetCallback('onmouseover', setOver)
		container:SetCallback('onmouseout', setOut)
	
		hoverActions:RegisterWatchLua('playerProfileKhanquestInfo', function(widget, trigger)
			libGeneral.fade(widget, (trigger.hoverIndex == index and trigger.hoverType == 1), 250)
		end, false, nil, 'hoverIndex', 'hoverType')
		--]]
	
		progressContainer:SetVisible(true)
		wins:SetText(tournamentInfo.wins)
		lives:SetText(math.max(0, playerProfile_khanquest.livesStart - tonumber(tournamentInfo.losses)))

		container:RegisterWatchLua('playerProfileKhanquestInfo', function(widget, trigger)
			local searchFilter = trigger.searchFilter
			if string.len(searchFilter) > 0 then
				if isInTable(tournamentInfo, searchFilter) then
					setItemVis(true)
				else
					setItemVis(false)
				end
			else
				setItemVis(true)
			end
		end, false, nil, 'searchFilter')

		local playerInfos = getNonSelfPlayerList(teamInfo)
		
		local playerOffline = false
		
		for k,v in ipairs(playerInfos) do
			if not ChatClient.IsOnline(v.identID) then
				playerOffline = true
			end
		end
		
		if playerOffline then
			title:SetText(Translate('player_profile_khanquest_team_notready'))
			title:SetColor('#00deff')
		else
			title:SetText(Translate('player_profile_khanquest_team_ready'))
			title:SetColor('#00ff1d')
		end
		
		for i=1,4,1 do
			playerProfileKhanquestRegisterPlayerEntry(object, 'playerProfile_khanquestCompletedTournament'..index..'Player'..i, i, playerInfos[i], 4, index)	-- rmm need player info per tournament
		end
		
	else
		progressContainer:SetVisible(false)
		container:RegisterWatchLua('playerProfileKhanquestInfo', function(widget, trigger)
			local searchFilter = trigger.searchFilter
			if string.len(searchFilter) > 0 then
				setItemVis(false)
			else
				setItemVis(true)
			end
		end, false, nil, 'searchFilter')

	
	end
end

local function playerProfileKhanquestRegister(object)

	local function notInMaintenance()
		if not (mainUI.featureMaintenance and mainUI.featureMaintenance['khanquest']) then
			return true
		end
		return false
	end

	local container						= object:GetWidget('playerProfile_khanquest')
	local menu							= object:GetWidget('playerProfile_khanquestMenu')
	local title							= object:GetWidget('playerProfile_khanquestTitle')

	local sectionActiveButtonCount		= object:GetWidget('khanquest_menu_category_item_'..'general_active'..'Label')
	local sectionCompleteButtonCount	= object:GetWidget('khanquest_menu_category_item_'..'general_complete'..'Label')

	local sectionStatsWins5Count		= object:GetWidget('playerProfile_khanquestStatsWins5Count')
	local sectionStatsWins7Count		= object:GetWidget('playerProfile_khanquestStatsWins7Count')
	local sectionStatsTotalComplete		= object:GetWidget('playerProfile_khanquestStatsTotalCompete')
	local sectionStatsGamesPlayed		= object:GetWidget('playerProfile_khanquestStatsGamesPlayed')
	local sectionStatsWinPercent		= object:GetWidget('playerProfile_khanquestStatsWinPercent')
	
	local sectionTabStats				= object:GetWidget('khanquest_menu_category_item_'..'general_general')
	local sectionTabActive				= object:GetWidget('khanquest_menu_category_item_'..'general_active')
	local sectionTabComplete			= object:GetWidget('khanquest_menu_category_item_'..'general_complete')

	local sectionStats					= object:GetWidget('playerProfile_khanquestStatsBody')
	local sectionActive					= object:GetWidget('playerProfile_khanquestActiveBody')
	local sectionHistory				= object:GetWidget('playerProfile_khanquestHistoryBody')

	local sectionActiveList				= object:GetWidget('playerProfile_khanquestActiveList')
	local sectionHistoryList			= object:GetWidget('playerProfile_khanquestHistoryList')

	local searchContainer				= object:GetWidget('playerProfile_khanquestSearch')
	local searchGoButton				= object:GetWidget('playerProfile_khanquestSearchGo')
	local searchTextbox					= object:GetWidget('playerProfile_khanquestSearchTextbox')
	local searchCoverup					= object:GetWidget('playerProfile_khanquestSearchCoverup')
	local searchCloseButton				= object:GetWidget('playerProfile_khanquestSearchClose')

	
	container:RegisterWatchLua('ChatTournamentForfeit', function(widget, trigger)
		local validForfeit	= true
		local identID		= nil
		for i=0,4,1 do
			identID = trigger['identID'..i]
			if not (identID and tonumber(identID) > 0) then
				validForfeit = false
			end
		end

		if validForfeit then
			-- valid notification of forfeit
		end
		
	end, false, nil)
	
	container:RegisterWatchLua('playerProfileAnimStatus', function(widget, trigger)
		if (trigger.section == 'khanquest') then
			widget:SetVisible(1)
			groupfcall('profile_animation_khanquest_widgets', function(_, widget) RegisterRadialEase(widget) widget:DoEventN(7) end)
			groupfcall('profile_menu_group', function(_, widget) widget:SetNoClick(1) end)
		else
			groupfcall('profile_animation_khanquest_widgets', function(_, widget) widget:DoEventN(8) end)
			libThread.threadFunc(function()	
				wait(styles_mainSwapAnimationDuration)		
				widget:SetVisible(0)
				groupfcall('profile_menu_group', function(_, widget) widget:SetNoClick(0) end)
			end)			
		end		
	end, false, nil, 'section')	

	sectionTabStats:SetCallback('onclick', function(widget)
		trigger_playerProfileKhanquestInfo.section = 0
		trigger_playerProfileKhanquestInfo:Trigger(false)
	end)

	sectionTabActive:SetCallback('onclick', function(widget)
		trigger_playerProfileKhanquestInfo.section = 1
		trigger_playerProfileKhanquestInfo:Trigger(false)
	end)

	sectionTabComplete:SetCallback('onclick', function(widget)
		trigger_playerProfileKhanquestInfo.section = 2
		trigger_playerProfileKhanquestInfo:Trigger(false)
	end)
	
	sectionTabStats:RegisterWatchLua('playerProfileKhanquestInfo', function(widget, trigger)
		widget:SetEnabled(trigger.section ~= 0)
	end, false, nil, 'section')
	
	sectionTabActive:RegisterWatchLua('playerProfileKhanquestInfo', function(widget, trigger)
		widget:SetEnabled(trigger.section ~= 1)
	end, false, nil, 'section')
	
	sectionTabComplete:RegisterWatchLua('playerProfileKhanquestInfo', function(widget, trigger)
		widget:SetEnabled(trigger.section ~= 2)
	end, false, nil, 'section')
	
	local function updateSearchFilter(filter)
		filter = filter or ''
		
		if string.len(filter) > 0 then
			
		else
			-- Show all
		end
	end
	
	local function searchCoverUpdate(hasFocus)
		hasFocus = hasFocus or false
		searchCoverup:SetVisible(hasFocus and string.len(searchTextbox:GetValue()) == 0)
	end

	function playerProfileKhanquestSearchEsc()
		searchTextbox:EraseInputLine()
		searchTextbox:SetFocus(false)
	end
	
	searchCloseButton:SetCallback('onclick', function(widget)
		playerProfileKhanquestSearchEsc()
	end)
	
	searchTextbox:SetCallback('onchange', function(widget)
		searchCoverUpdate(widget:HasFocus())
		updateSearchFilter(widget:GetValue())
	end)
	
	searchTextbox:SetCallback('onfocus', function(widget)
		searchCoverUpdate(true)
	end)
	
	searchTextbox:SetCallback('onlosefocus', function(widget)
		searchCoverUpdate(false)
	end)

	sectionStats:RegisterWatchLua('playerProfileKhanquestInfo', function(widget, trigger)
		libGeneral.fade(widget, trigger.section == 0, 250)
	end, false, nil, 'section')
	
	sectionActive:RegisterWatchLua('playerProfileKhanquestInfo', function(widget, trigger)
		libGeneral.fade(widget, trigger.section == 1, 250)
	end, false, nil, 'section')
	
	sectionHistory:RegisterWatchLua('playerProfileKhanquestInfo', function(widget, trigger)
		libGeneral.fade(widget, trigger.section == 2, 250)
	end, false, nil, 'section')
	
	local profileInitialPopulate = false

	function playerProfile_khanquest.loadProfileSuccess(responseData)
		
		-- println('loadProfileSuccess')
		-- printr(responseData)
		
		playerProfile_khanquest.profileLoaded = true
		
		if not profileInitialPopulate then
		
			for i=1,5,1 do
				playerProfile_khanquest.countPerWins[i] = 0
			end

			playerProfile_khanquest.completedTournaments	= 0
			playerProfile_khanquest.activeTeams				= 0
			playerProfile_khanquest.totalWins				= 0
			playerProfile_khanquest.totalGames				= 0
			
			local haveTeams			= false
			local haveTournaments	= false
			
			local responseData 									= responseData or {}
			responseData.teams 						= responseData.teams or {}
			responseData.teams.completedTournaments 	= responseData.teams.completedTournaments or {}
			responseData.teams.activeTeams			= responseData.teams.activeTeams or {}
			
			for k,v in pairs(responseData.teams.activeTeams) do
				haveTeams = true
			end
			
			for k,v in pairs(responseData.teams.completedTournaments) do
				haveTournaments = true
			end
			
			if not haveTeams and GetCvarBool('ui_dev_khanquest') then
				local function insertFakeTeam(i)
					table.insert(responseData.teams.activeTeams, {	-- rmm test
						['active'] = 1,
						['teamType'] = 'sitAndGo',
						['losses'] = 0,
						['wins'] = math.random(0,6),
						['forfeits'] = 0,
						['rating'] = 0.00,
						['uniqueTeamId'] = i,
						['lastCompletedMatchTimestamp'] = '2014-04-15 09:03:15',
						['won1'] = 0,
						['won2'] = 0,
						['won3'] = 0,
						['won4'] = 0,
						['won5'] = 0,
						['won6'] = 0,
						['won7'] = 0,
						['seat1'] = '1.001',
						['seat2'] = '1.002',
						['seat3'] = '1.003',
						['seat4'] = '1.004',
						['seat5'] = '1.005',
						['seat1PlayerName']	= 'Player Name 1',
						['seat2PlayerName']	= 'Player Name 2',
						['seat3PlayerName']	= 'Player Name 3',
						['seat4PlayerName']	= 'Player Name 4',
						['seat5PlayerName']	= 'Player Name 5'
					})
				end
				for i=1,10 do
					insertFakeTeam(i)
				end
			end

			if not haveTournaments and GetCvarBool('ui_dev_khanquest') then
				local function insertFakeCompletedTournament(i)
					table.insert(responseData.teams.completedTournaments, {	-- rmm test
						tournament = {
							['wins'] = math.random(0,7),
							['losses'] = math.random(0,1),
							['complete'] = 1,
							['matchType'] = 'sitAndGo',
							['uniqueTeamId'] = i,
							['uniqueTournamentId'] = i,
							['rating'] = 0.00,
							['lastCompletedMatchTimestamp'] = '2014-04-15 09:04:06',
							['forfeits'] = 0,
							['seat1'] = '1.001',
							['seat2'] = '1.002',
							['seat3'] = '1.003',
							['seat4'] = '1.004',
							['seat5'] = '1.005',
							['seat1PlayerName']	= 'Player Name 1',
							['seat2PlayerName']	= 'Player Name 2',
							['seat3PlayerName']	= 'Player Name 3',
							['seat4PlayerName']	= 'Player Name 4',
							['seat5PlayerName']	= 'Player Name 5'							
						}
					})
				end
				for i=1,10 do
					insertFakeCompletedTournament(i)
				end					
			end
			
			-- printr(responseData.teams)
			
			for k,v in pairs(responseData.teams.activeTeams) do
				playerProfileKhanquestRegisterActiveTeam(object, sectionActiveList, tonumber(v.uniqueTeamId), v)
				for i=1,5,1 do
					playerProfile_khanquest.countPerWins[i] = playerProfile_khanquest.countPerWins[i] + tonumber(v['won'..i])
				end
				
				playerProfile_khanquest.activeTeams = playerProfile_khanquest.activeTeams + 1
				
				playerProfile_khanquest.totalWins	= playerProfile_khanquest.totalWins + tonumber(v.wins)
				playerProfile_khanquest.totalGames	= playerProfile_khanquest.totalGames + tonumber(v.wins) + tonumber(v.losses)
			end
			
			local championships, grandChampionships = 0,0
			
			for k,v in pairs(responseData.teams.completedTournaments) do
				playerProfileKhanquestRegisterCompletedTournament(object, sectionHistoryList, libCompete.khanquest.getTournamentIDFromTournamentIndex(k), v)
				playerProfile_khanquest.completedTournaments = playerProfile_khanquest.completedTournaments + 1
				
				playerProfile_khanquest.totalWins	= playerProfile_khanquest.totalWins + tonumber(v.tournament.wins)
				playerProfile_khanquest.totalGames	= playerProfile_khanquest.totalGames + tonumber(v.tournament.wins + v.tournament.losses)
				
				if tonumber(v.tournament.wins) and (tonumber(v.tournament.wins) >= 7) then
					grandChampionships = grandChampionships + 1
				elseif tonumber(v.tournament.wins) and (tonumber(v.tournament.wins) >= 5) then
					championships = championships + 1
				end
				
			end

			-- will need to update these when the proper values exist
			sectionStatsWins5Count:SetText(championships)
			sectionStatsWins7Count:SetText(grandChampionships)
			
			sectionStatsTotalComplete:SetText(libNumber.commaFormat(playerProfile_khanquest.completedTournaments))
			sectionStatsGamesPlayed:SetText(libNumber.commaFormat(playerProfile_khanquest.totalGames))
			
			sectionActiveButtonCount:SetText(libNumber.commaFormat(playerProfile_khanquest.activeTeams))
			sectionCompleteButtonCount:SetText(libNumber.commaFormat(playerProfile_khanquest.completedTournaments))
			
			if playerProfile_khanquest.totalGames > 0 then
			sectionStatsWinPercent:SetText(
				FtoA2(100 * (playerProfile_khanquest.totalWins / playerProfile_khanquest.totalGames), 0, 1)..'%'
			)
			else
				sectionStatsWinPercent:SetText(0)
			end
			
			profileInitialPopulate = true
		end
	end
	
	local function checkLoadProfile()
		-- println('checkLoadProfile')
		if (GetCvarBool('ui_dev_khanquest')) then
			playerProfile_khanquest.loadProfileSuccess()
		end
	end
	
	
	-- if playerProfile_khanquest.profileLoaded and notInMaintenance() then	-- This is generally only after a UI reload
		-- Populate profile widgets
		-- profileInitialPopulate = true
	-- end
	
	libGeneral.createGroupTrigger('loadPlayerProfileKhanquest', { 'playerProfileAnimStatus.section', 'LoginStatus.isLoggedIn', 'LoginStatus.hasIdent' })
	
	--[[
	container:RegisterWatchLua('playerProfileInfo', function(widget, trigger)
		libGeneral.fade(widget, (notInMaintenance() and trigger.section == 3), 250)
	end, false, nil, 'section')
	--]]
	
	container:RegisterWatchLua('loadPlayerProfileKhanquest', function(widget, groupTrigger)
		local triggerLogin		= groupTrigger['LoginStatus']
		local profileSection = groupTrigger['playerProfileAnimStatus'].section
		
		if profileSection == 'khanquest' and triggerLogin.isLoggedIn and triggerLogin.hasIdent then
			checkLoadProfile()
		end
	end)

end

playerProfileKhanquestRegister(object)

trigger_playerProfileKhanquestInfo.section		= 0
trigger_playerProfileKhanquestInfo.searchFilter	= ''
trigger_playerProfileKhanquestInfo.isFiltered	= false
trigger_playerProfileKhanquestInfo.hoverIndex	= -1
trigger_playerProfileKhanquestInfo.hoverType	= 0
trigger_playerProfileKhanquestInfo:Trigger(true)