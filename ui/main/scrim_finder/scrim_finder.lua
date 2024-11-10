-- Game List
local interface = object

ScrimFinder = ScrimFinder or {}
ScrimFinder.searchTerm = ''
ScrimFinder.selectedScrim = ''
ScrimFinder.data = {}
ScrimFinder.data.parties = {}
ScrimFinder.searchOptions = {
	bOnlyFullParties 					= false,
	bOnlyPartiesWithSpace 				= false,
	bOnlyPartiesLookingForPlayers 		= false,
	bRequireLeaderReady 				= false,
	bRequireAllReady					= false,
	bOnlyIdleParties 					= false,
}

local triggerAvailability = LuaTrigger.GetTrigger('ChatAvailability')

local println = function(...)
	if GetCvarBool('ui_devScrimFinder') then
		println(...)
	end
end
local printr = function(...)
	if GetCvarBool('ui_devScrimFinder') then
		printr(...)
	end
end

local function ScrimFinderInit(object)
	
	if ((mainUI.featureMaintenance) and (mainUI.featureMaintenance['scrim'])) then
		return
	end
	
	local scrim_finder 									= object:GetWidget('scrim_finder')
	local scrim_finder_results_parent 					= object:GetWidget('scrim_finder_results_parent')
	local main_game_list_close_button 					= object:GetWidget('main_game_list_close_button')
	local main_game_list_join_button_scrim_finder 		= object:GetWidget('main_game_list_join_button_scrim_finder')
	local scrim_finder_results_listbox 					= object:GetWidget('scrim_finder_results_listbox')
	local scrim_finder_input_textbox 					= object:GetWidget('scrim_finder_input_textbox')
	local scrim_finder_regionlist_parent 				= object:GetWidget('scrim_finder_regionlist_parent')
	local scrim_finder_regionlist 						= object:GetWidget('scrim_finder_regionlist')
		
	function ScrimFinder.ToggleRegionSelection()
		if not scrim_finder_regionlist_parent:IsVisibleSelf() then
			scrim_finder_regionlist_parent:SetVisible(true)
		else
			scrim_finder_regionlist_parent:SetVisible(false)
		end
	end

	scrim_finder_regionlist_parent:SetCallback('onshow', function()
		GetWidget('selection_region_info_listbox'):SetParent(scrim_finder_regionlist)
	end)
	
	scrim_finder_regionlist_parent:SetCallback('onhide', function()
		GetWidget('selection_region_info_listbox'):SetParent(GetWidget('selection_region_info_parent'))
	end)
	
	local function UpdateScrimFinderFilters()
		local scrim_finder_input_textbox 		= object:GetWidget('scrim_finder_input_textbox')
		ScrimFinder.searchTerm 					= scrim_finder_input_textbox:GetValue()

		if (ScrimFinder.data.parties) then	
			for UID, partyTable in pairs(ScrimFinder.data.parties) do
				
				if (partyTable.UID) and (not Empty(partyTable.UID)) then

					local partyName
					
					if (partyTable.name) and (not Empty(partyTable.name)) then
						partyName = partyTable.name
					else
						local leaderIdentID = string.gsub(partyTable.leaderIdentID, '%.', '')
						local leaderTrigger = LuaTrigger.GetTrigger('ChatClientInfo' .. leaderIdentID)					
						if (leaderTrigger) and (leaderTrigger.name) and (not Empty(leaderTrigger.name)) then
							partyName = leaderTrigger.name
						end
					end

					if (not ScrimFinder.searchTerm) or (ScrimFinder.searchTerm == '') or (not partyName) or (string.find(string.lower(partyName), string.lower(ScrimFinder.searchTerm))) then
						-- scrim_finder_results_listbox:ShowItemByValue(partyTable.UID)
						partyTable.visible = true
					else
						-- scrim_finder_results_listbox:HideItemByValue(partyTable.UID)		
						partyTable.visible = false
					end
				
				end
				
			end
		end
		
	end	

	function UpdateScrimFinderList()

		UpdateScrimFinderFilters()
		
		println('^y^: ScrimFinder.data.parties')
		printr(ScrimFinder.data.parties)
		
		if (ScrimFinder.data.parties) then	
			
			local requires5, requires3, requiresNotInGame = false, true, true
			
			local partyCount = 0
			for UID, partyTable in pairs(ScrimFinder.data.parties) do
				if (partyTable.visible) and (not partyTable.inGame) and (#partyTable.memberIdentIDs >= 3) then
					partyCount = partyCount + 1
				end
			end

			if (partyCount >= 15) then
				requires5 = true			
			end			
			
			scrim_finder_results_listbox:ClearChildren()
			
			for UID, partyTable in pairs(ScrimFinder.data.parties) do
				if (partyTable.visible) then
				
					local isMyParty = false
					local memberCount = 0
					if (partyTable.memberIdentIDs) then
						for i,v in pairs(partyTable.memberIdentIDs) do
							if IsMe(v) then
								isMyParty = true
								memberCount = memberCount + 1
							elseif (v) and (not Empty(v)) then
								memberCount = memberCount + 1
							end
						end
					end
					
					local sortPrefix
					local frame1color
					local frame2color
					local nameColor
					
					if (isMyParty) then						
						frame1color = '#1f1f1f90'
						frame2color = '#44444490'
						nameColor = '.6 .6 .6 .8'
						sortPrefix = '3'
					elseif (partyTable.inGame) then
						frame1color = '#1f1f1f90'
						frame2color = '#44444490'
						nameColor = '.6 .6 .6 .8'
						sortPrefix = '9'
					elseif (partyTable.incomingChallenge) then
						frame1color = '#053948'
						frame2color = '#0d708c'
						nameColor = '#b5eeff'
						sortPrefix = '2'
					elseif (partyTable.outgoingChallenge) then
						frame1color = '#054831'
						frame2color = '#0d8c61'
						nameColor = '#b5fff2'
						sortPrefix = '1'
					elseif (partyTable.isReady) and (memberCount == 5) then
						frame1color = '#1f1f1f'
						frame2color = '#444444'
						nameColor = '0 1 0 1'
						sortPrefix = '4'
					elseif (memberCount == 5) then
						frame1color = '#1f1f1f'
						frame2color = '#444444'
						nameColor = '1 1 1 1'
						sortPrefix = '5'
					elseif (memberCount >= 4) then
						frame1color = '#1f1f1f'
						frame2color = '#444444'
						nameColor = '1 1 1 1'	
						sortPrefix = '6'						
					elseif (memberCount >= 3) then
						frame1color = '#1f1f1f'
						frame2color = '#444444'
						nameColor = '1 1 1 1'	
						sortPrefix = '7'
					else
						frame1color = '#1f1f1f'
						frame2color = '#444444'
						nameColor = '.7 .7 .7 1'	
						sortPrefix = '8'
					end		

					if (not isMyParty) and ( (((not requiresNotInGame) or (not partyTable.inGame)) and ((not requires3) or (memberCount >= 3)) and ((not requires5) or (memberCount >= 5))) or (partyTable.incomingChallenge) or (partyTable.outgoingChallenge) ) then

						if (not scrim_finder_results_listbox:HasListItem(partyTable.UID)) then
							
							println('^g scrim_finder_results_listbox | added: UID: ' .. tostring(partyTable.UID))
							
							scrim_finder_results_listbox:AddTemplateListItemWithSort(
								'scrim_finder_scrim_listitem_template',
								partyTable.UID or '-1',					
								sortPrefix .. GetTime(),
								'index', partyTable.UID or '-1',
								'nameColor', nameColor,
								'frame1color', frame1color,
								'frame2color', frame2color
							)
							
							partyTable.creationTimestamp = GetTime()
							
						else
							println('^y scrim_finder_results_listbox | updated:  UID: ' .. tostring(partyTable.UID))
							if GetWidget('scrim_finder_' .. partyTable.UID .. '_scrimName', nil, true) then
								GetWidget('scrim_finder_' .. partyTable.UID .. '_scrimName'):SetColor(nameColor)
								
								GetWidget('scrim_finder_' .. partyTable.UID .. '_frame1'):SetColor(frame1color)
								GetWidget('scrim_finder_' .. partyTable.UID .. '_frame1'):SetBorderColor(frame1color)
								
								GetWidget('scrim_finder_' .. partyTable.UID .. '_frame2'):SetBorderColor(frame2color)
								
								GetWidget('scrim_finder_' .. partyTable.UID .. '_parent'):GetParent():SetSortIndex(sortPrefix.. (partyTable.creationTimestamp or GetTime()))
							end
						end
													
						local PartyStatus = LuaTrigger.GetTrigger('PartyStatus')
													
						GetWidget('scrim_finder_' .. partyTable.UID .. '_button_1'):UnregisterWatchLua('PartyStatus')
						GetWidget('scrim_finder_' .. partyTable.UID .. '_button_1'):RegisterWatchLua('PartyStatus', function(widget, trigger)
							widget:SetEnabled(trigger.isPartyLeader)
						end)
						GetWidget('scrim_finder_' .. partyTable.UID .. '_button_1'):SetEnabled(PartyStatus.isPartyLeader)
						
						GetWidget('scrim_finder_' .. partyTable.UID .. '_button_2'):UnregisterWatchLua('PartyStatus')
						GetWidget('scrim_finder_' .. partyTable.UID .. '_button_2'):RegisterWatchLua('PartyStatus', function(widget, trigger)
							widget:SetEnabled(trigger.isPartyLeader)
						end)					
						GetWidget('scrim_finder_' .. partyTable.UID .. '_button_2'):SetEnabled(PartyStatus.isPartyLeader)
						
						GetWidget('scrim_finder_' .. partyTable.UID .. '_parent'):SetCallback('onmouseover', function()
							UpdateCursor(widget, true, { canLeftClick = false, canRightClick = true })
						end)			
						GetWidget('scrim_finder_' .. partyTable.UID .. '_parent'):SetCallback('onmouseout', function()
							UpdateCursor(widget, false, { canLeftClick = false, canRightClick = true })
						end)						
						GetWidget('scrim_finder_' .. partyTable.UID .. '_parent'):SetCallback('onrightclick', function()
							local leaderIdentID = string.gsub(partyTable.leaderIdentID, '%.', '')
							local leaderTrigger = LuaTrigger.GetTrigger('ChatClientInfo' .. leaderIdentID)
								
							ContextMenuTrigger.selectedUserIdentID 			= partyTable.leaderIdentID
							ContextMenuTrigger.selectedUserUsername 		= leaderTrigger.name
							ContextMenuTrigger.selectedUserIsInGame			= partyTable.inGame
							ContextMenuTrigger.selectedUserIsInParty		= true
							ContextMenuTrigger.selectedUserIsInLobby		= false
							ContextMenuTrigger.spectatableGame				= false
							ContextMenuTrigger.contextMenuArea = 1
							ContextMenuTrigger:Trigger(true)					
						end)
						GetWidget('scrim_finder_' .. partyTable.UID .. '_parent'):RefreshCallbacks()
						
						if (isMyParty) then
							GetWidget('scrim_finder_' .. partyTable.UID .. '_button_1'):SetVisible(0)
							GetWidget('scrim_finder_' .. partyTable.UID .. '_button_2'):SetVisible(0)		

							GetWidget('scrim_finder_' .. partyTable.UID .. '_challenge_icon'):SetVisible(0)	
							
						elseif (partyTable.incomingChallenge) then
							GetWidget('scrim_finder_' .. partyTable.UID .. '_button_1'):SetVisible(1)
							GetWidget('scrim_finder_' .. partyTable.UID .. '_button_2'):SetVisible(1)
							
							GetWidget('scrim_finder_' .. partyTable.UID .. '_button_1Label'):SetText(Translate('general_accept_ex'))
							GetWidget('scrim_finder_' .. partyTable.UID .. '_button_1'):SetCallback('onclick', function(widget)
								ScrimFinder.AcceptChallengeByPartyID(partyTable.UID)
							end)
							
							GetWidget('scrim_finder_' .. partyTable.UID .. '_button_2Label'):SetText(Translate('general_decline'))	
							GetWidget('scrim_finder_' .. partyTable.UID .. '_button_2'):SetCallback('onclick', function(widget)
								ScrimFinder.DeclineChallengeByPartyID(partyTable.UID)
							end)
							
							GetWidget('scrim_finder_' .. partyTable.UID .. '_challenge_icon'):SetVisible(1)

						elseif (partyTable.outgoingChallenge) then
							GetWidget('scrim_finder_' .. partyTable.UID .. '_button_1'):SetVisible(1)
							GetWidget('scrim_finder_' .. partyTable.UID .. '_button_2'):SetVisible(1)					
							
							GetWidget('scrim_finder_' .. partyTable.UID .. '_button_1Label'):SetText(Translate('general_rescind'))	
							GetWidget('scrim_finder_' .. partyTable.UID .. '_button_1'):SetCallback('onclick', function(widget)
								ScrimFinder.DeclineChallengeByPartyID(partyTable.UID) -- Revoke
							end)
							
							GetWidget('scrim_finder_' .. partyTable.UID .. '_button_2Label'):SetText(Translate('scrim_btn_message'))	
							GetWidget('scrim_finder_' .. partyTable.UID .. '_button_2'):SetCallback('onclick', function(widget)
								ScrimFinder.MessagePlayerByIdentID(partyTable.leaderIdentID)
							end)

							GetWidget('scrim_finder_' .. partyTable.UID .. '_challenge_icon'):SetVisible(1)						
							
						else
							GetWidget('scrim_finder_' .. partyTable.UID .. '_button_1'):SetVisible(1)
							GetWidget('scrim_finder_' .. partyTable.UID .. '_button_2'):SetVisible(1)					
							
							GetWidget('scrim_finder_' .. partyTable.UID .. '_button_1Label'):SetText(Translate('general_challenge'))	
							GetWidget('scrim_finder_' .. partyTable.UID .. '_button_1'):SetCallback('onclick', function(widget)
								ScrimFinder.ChallengePlayerByPartyID(partyTable.UID)
							end)
							
							GetWidget('scrim_finder_' .. partyTable.UID .. '_button_2Label'):SetText(Translate('scrim_btn_message'))	
							GetWidget('scrim_finder_' .. partyTable.UID .. '_button_2'):SetCallback('onclick', function(widget)
								ScrimFinder.MessagePlayerByIdentID(partyTable.leaderIdentID)
							end)	

							GetWidget('scrim_finder_' .. partyTable.UID .. '_challenge_icon'):SetVisible(0)	
							
						end	
					else
						if (partyTable.UID) and (not Empty(partyTable.UID)) and (scrim_finder_results_listbox:HasListItem(partyTable.UID)) then
							println('^o scrim_finder_results_listbox | removed via filtering: |  UID: ' .. tostring(partyTable.UID))
							scrim_finder_results_listbox:EraseListItemByValue(partyTable.UID)
						end
					end
				else
					if (partyTable.UID) and (not Empty(partyTable.UID)) and (scrim_finder_results_listbox:HasListItem(partyTable.UID)) then
						println('^o scrim_finder_results_listbox | removed: |  UID: ' .. tostring(partyTable.UID))
						scrim_finder_results_listbox:EraseListItemByValue(partyTable.UID)
					else
						-- println('^o scrim_finder_results_listbox | failed to remove: |  UID: ' .. tostring(partyTable.UID))
					end
				end
			end
		end		
		
		scrim_finder_results_listbox:SortListboxSortIndex(0)

	end

	scrim_finder_results_listbox:SetCallback('onselect', function(widget)
		ScrimFinder.selectedScrim = widget:GetValue()
	end)
	
	function ScrimFinder.UpdatePartyData(trigger)
		if (trigger) and (trigger.UID) then
			ScrimFinder.data.parties[trigger.UID].UID					= trigger.UID
			ScrimFinder.data.parties[trigger.UID].leaderIdentID			= trigger.leaderIdentID
			ScrimFinder.data.parties[trigger.UID].memberIdentIDs		= trigger.memberIdentIDs
			ScrimFinder.data.parties[trigger.UID].name					= trigger.name
			ScrimFinder.data.parties[trigger.UID].rating				= trigger.rating
			ScrimFinder.data.parties[trigger.UID].inGame				= trigger.inGame
			ScrimFinder.data.parties[trigger.UID].isReady				= false -- trigger.isReady
		end
	end	
	
	function ScrimFinder.WatchAParty(UID)
		if (scrim_finder_results_listbox) and (scrim_finder_results_listbox:IsValid()) then
			println('^g ChatPartySummary now watching ' .. UID)
			if LuaTrigger.GetTrigger('ChatPartySummary'..UID) then
				scrim_finder_results_listbox:UnregisterWatchLua('ChatPartySummary'..UID)
			end
			ScrimFinder.data.parties[UID] = ScrimFinder.data.parties[UID] or {}
			if LuaTrigger.GetTrigger('ChatPartySummary'..UID) then
				scrim_finder_results_listbox:RegisterWatchLua('ChatPartySummary'..UID, function(widget, trigger)
					ScrimFinder.UpdatePartyData(trigger)
				end)
				ScrimFinder.UpdatePartyData(LuaTrigger.GetTrigger('ChatPartySummary'..UID))
			end
		end
	end	
	
	scrim_finder_results_listbox:RegisterWatchLua('ChatPartySummary', function(widget, trigger)
		if (trigger.added) and (not Empty(trigger.UID)) then	
			ScrimFinder.WatchAParty(trigger.UID)
		elseif (not Empty(trigger.UID)) then
			println('^o ChatPartySummary stopped watching ' .. trigger.UID)
			if LuaTrigger.GetTrigger('ChatPartySummary'..trigger.UID) then
				scrim_finder_results_listbox:UnregisterWatchLua('ChatPartySummary'..trigger.UID)
			end
			ScrimFinder.data.parties[trigger.UID] = nil
			if (scrim_finder_results_listbox:HasListItem(trigger.UID)) then
				println('^o ChatPartySummary | removed and unwatched: |  UID: ' .. tostring(trigger.UID))
				scrim_finder_results_listbox:EraseListItemByValue(trigger.UID)
			end	
		else
			println('^r ChatPartySummary got empty UID ' .. trigger.UID)
		end
		UpdateScrimFinderList()
	end, true, nil, 'UID', 'added')
	
	local function ShowChallengeSplash(incomingChallengeTable)
	
		if (incomingChallengeTable) and (incomingChallengeTable.UID) and (not Empty(incomingChallengeTable.UID)) then
	
			local summaryTrigger = LuaTrigger.GetTrigger('ChatPartySummary'..incomingChallengeTable.UID)
			local numPlayersInParty = LuaTrigger.GetTrigger('PartyStatus').numPlayersInParty
			
			if (summaryTrigger) and (incomingChallengeTable.players >= 5) then
		
				local function ThrowDownTheGauntlet()
				
					libThread.threadFunc(function()
								
						mainUI.ShowSplashScreen('splash_screen_party_challenge')
						
						wait(10)
						
						local splash_screen_party_challenge_parent 				= GetWidget('splash_screen_party_challenge_parent')
						local splash_screen_party_challenge_team 				= GetWidget('splash_screen_party_challenge_team')
						local splash_screen_party_challenge_meter 				= GetWidget('splash_screen_party_challenge_meter')
						local splash_screen_party_challenge_meter_label 		= GetWidget('splash_screen_party_challenge_meter_label')
						local splash_screen_party_challenge_button_1 			= GetWidget('splash_screen_party_challenge_button_1')
						local splash_screen_party_challenge_button_2 			= GetWidget('splash_screen_party_challenge_button_2')
						
						local partyName = ''
						if (summaryTrigger.name) and (not Empty(summaryTrigger.name)) then
							partyName = summaryTrigger.name
						else
							local leaderIdentID = string.gsub(summaryTrigger.leaderIdentID, '%.', '')
							local leaderTrigger = LuaTrigger.GetTrigger('ChatClientInfo' .. leaderIdentID)					
							if (leaderTrigger) and (leaderTrigger.name) and (not Empty(leaderTrigger.name)) then
								partyName = leaderTrigger.name
							end
						end					
						
						if (incomingChallengeTable.players) and (incomingChallengeTable.players > 1) then
							partyName = partyName .. ' ' ..Translate('scrim_challenge_and_friends', 'value', (incomingChallengeTable.players-1))
						end
						
						splash_screen_party_challenge_team:SetText(partyName)
						
						splash_screen_party_challenge_meter_label:SetText(Translate('scrim_finder_relative_rating_' .. summaryTrigger.rating))
						
						if (summaryTrigger.rating) and (summaryTrigger.rating == -4) then
							splash_screen_party_challenge_meter:SetTexture('/ui/main/scrim_finder/textures/team_comp_neg4.tga')
							splash_screen_party_challenge_meter_label:SetColor('#1eb400')
						elseif (summaryTrigger.rating) and (summaryTrigger.rating == -3) then
							splash_screen_party_challenge_meter:SetTexture('/ui/main/scrim_finder/textures/team_comp_neg3.tga')
							splash_screen_party_challenge_meter_label:SetColor('#1eb400')
						elseif (summaryTrigger.rating) and (summaryTrigger.rating == -2) then
							splash_screen_party_challenge_meter:SetTexture('/ui/main/scrim_finder/textures/team_comp_neg2.tga')
							splash_screen_party_challenge_meter_label:SetColor('#1eb400')
						elseif (summaryTrigger.rating) and (summaryTrigger.rating == -1) then
							splash_screen_party_challenge_meter:SetTexture('/ui/main/scrim_finder/textures/team_comp_neg1.tga')
							splash_screen_party_challenge_meter_label:SetColor('#1eb400')
						elseif (summaryTrigger.rating) and (summaryTrigger.rating == 0) then
							splash_screen_party_challenge_meter:SetTexture('/ui/main/scrim_finder/textures/team_comp_even.tga')
							splash_screen_party_challenge_meter_label:SetColor('#cccccc')
						elseif (summaryTrigger.rating) and (summaryTrigger.rating == 1) then
							splash_screen_party_challenge_meter:SetTexture('/ui/main/scrim_finder/textures/team_comp_pos1.tga')
							splash_screen_party_challenge_meter_label:SetColor('#e92525')
						elseif (summaryTrigger.rating) and (summaryTrigger.rating == 2) then
							splash_screen_party_challenge_meter:SetTexture('/ui/main/scrim_finder/textures/team_comp_pos2.tga')
							splash_screen_party_challenge_meter_label:SetColor('#e92525')
						elseif (summaryTrigger.rating) and (summaryTrigger.rating == 3) then
							splash_screen_party_challenge_meter:SetTexture('/ui/main/scrim_finder/textures/team_comp_pos3.tga')
							splash_screen_party_challenge_meter_label:SetColor('#e92525')
						elseif (summaryTrigger.rating) and (summaryTrigger.rating == 4) then
							splash_screen_party_challenge_meter:SetTexture('/ui/main/scrim_finder/textures/team_comp_pos4.tga')
							splash_screen_party_challenge_meter_label:SetColor('#e92525')
						else
							splash_screen_party_challenge_meter:SetTexture('/ui/main/scrim_finder/textures/team_comp_even.tga')
							splash_screen_party_challenge_meter_label:SetColor('#cccccc')
						end						

						if (incomingChallengeTable.players == 5) and (numPlayersInParty) and (numPlayersInParty >= 5) then
							splash_screen_party_challenge_meter:SetColor('1 1 1 1')
						else
							splash_screen_party_challenge_meter:SetColor('.3 .3 .3 1')
							splash_screen_party_challenge_meter_label:SetText(Translate('scrim_finder_relative_rating_unknown'))
						end						
						
						splash_screen_party_challenge_button_1:SetCallback('onclick', function(widget)
							ScrimFinder.AcceptChallengeByPartyID(summaryTrigger.UID)
							mainUI.ShowSplashScreen()
						end)
						
						splash_screen_party_challenge_button_2:SetCallback('onclick', function(widget)
							ScrimFinder.DeclineChallengeByPartyID(summaryTrigger.UID)
							mainUI.ShowSplashScreen()
						end)						
						
					end)
				
				end

				ThrowDownTheGauntlet()
			
			end
			
		end
		
	end
	
	local lastIncomingChallengeCount = 0
	local function ScanForChallenges()
		local incomingChallengeCount = 0
		
		if (ScrimFinder.data.parties) then	
			for UID, partyTable in pairs(ScrimFinder.data.parties) do
				partyTable.outgoingChallenge = false
				partyTable.incomingChallenge = false
			end
		end
		
		for index=0,4,1 do
			local trigger = LuaTrigger.GetTrigger('PartyOutgoingChallengeInfo'..index)
			if (trigger.UID) and (not Empty(trigger.UID)) then
				ScrimFinder.data.parties[trigger.UID] 								= ScrimFinder.data.parties[trigger.UID] or {}
				ScrimFinder.data.parties[trigger.UID].outgoingChallenge 			= true
				ScrimFinder.data.parties[trigger.UID].outgoingChallengeTimestamp 	= trigger.timestamp
				ScrimFinder.WatchAParty(trigger.UID)
			end
		end
		
		local incomingChallengeTable = {}
		
		for index=0,4,1 do
			local trigger = LuaTrigger.GetTrigger('PartyIncomingChallengeInfo'..index)
			if (trigger.UID) and (not Empty(trigger.UID)) then
				local summaryTrigger = LuaTrigger.GetTrigger('ChatPartySummary'..trigger.UID)
				if (not GetCvarBool('ui_challengeRequiresFriendship')) or (summaryTrigger and ChatClient.IsFriend(summaryTrigger.leaderIdentID)) then
					incomingChallengeCount = incomingChallengeCount + 1
					ScrimFinder.data.parties[trigger.UID] 								= ScrimFinder.data.parties[trigger.UID] or {}
					ScrimFinder.data.parties[trigger.UID].incomingChallenge 			= true
					ScrimFinder.data.parties[trigger.UID].incomingChallengeTimestamp 	= trigger.timestamp
					local players = 1
					if (ScrimFinder.data.parties[trigger.UID]) and (ScrimFinder.data.parties[trigger.UID].memberIdentIDs) then
						players = #ScrimFinder.data.parties[trigger.UID].memberIdentIDs
					end
					table.insert(incomingChallengeTable, {timestamp = trigger.timestamp, UID = trigger.UID, players = players})
				else
					ScrimFinder.DeclineChallengeByPartyID(trigger.UID)
				end
				ScrimFinder.WatchAParty(trigger.UID)
			end
		end		
		
		if (incomingChallengeTable) then
			table.sort(incomingChallengeTable, 
				function(a,b)
					if (a.timestamp) and (b.timestamp) then
						return a.timestamp > b.timestamp 
					elseif (a.timestamp) then
						return true
					else
						return false
					end
				end
			)
		end
		
		UpdateScrimFinderList()
		
		local notificationsTrigger = LuaTrigger.GetTrigger('notificationsTrigger')
		notificationsTrigger.incomingChallenges = incomingChallengeCount
		notificationsTrigger:Trigger(false)
		
		local partyStatusTrigger 		= LuaTrigger.GetTrigger('PartyStatus')
		
		local mainPanelStatus = LuaTrigger.GetTrigger('mainPanelStatus') 
		if (partyStatusTrigger.isPartyLeader) then
			if (mainPanelStatus.main == 35) and (incomingChallengeCount > lastIncomingChallengeCount) and (incomingChallengeTable) and (incomingChallengeTable[1]) then
				-- printr(incomingChallengeTable[1])
				ShowChallengeSplash(incomingChallengeTable[1])
			elseif (incomingChallengeCount ~= lastIncomingChallengeCount) then
				mainUI.ShowSplashScreen()
			end
			lastIncomingChallengeCount = incomingChallengeCount
		end

	end
	
	for index=0,4,1 do
		scrim_finder_results_listbox:RegisterWatchLua('PartyOutgoingChallengeInfo'..index, function(widget, trigger)
			ScanForChallenges()
		end)
		scrim_finder_results_listbox:RegisterWatchLua('PartyIncomingChallengeInfo'..index, function(widget, trigger)
			ScanForChallenges()
		end)
	end
	
	scrim_finder:RegisterWatchLua('mainPanelAnimationStatus', function(widget, trigger)
		local animState = mainSectionAnimState(35, trigger.main, trigger.newMain)
		if animState == 1 then
			if (widget:IsVisible()) then
				if (Friends) and (Friends.ToggleFriends) then
					Friends.ToggleFriends(false, true)
				end
			end			
			libThread.threadFunc(function()	
				groupfcall('scrim_finder_animation_widgets', function(_, widget) widget:DoEventN(8) end)	
				wait(styles_mainSwapAnimationDuration)
				widget:SetVisible(0)
			end)				
			widget:GetWidget('scrim_finder_no_connection_overlay'):FadeOut(styles_mainSwapAnimationDuration)
		elseif animState == 2 then
			widget:SetVisible(0)
			if (ScrimFinder.scrimChannelID) then
				LeaveChannel(ScrimFinder.scrimChannelID)
				ScrimFinder.scrimChannelID = nil
			end			
			widget:GetWidget('scrim_finder_no_connection_overlay'):FadeOut(styles_mainSwapAnimationDuration)
		elseif animState == 3 then
			widget:SetVisible(1)
			libThread.threadFunc(function()	
				groupfcall('scrim_finder_animation_widgets', function(_, widget) RegisterRadialEase(widget) widget:DoEventN(7) end)	
			end)		
			widget:GetWidget('scrim_finder_no_connection_overlay'):SetVisible(0)
		elseif animState == 4 then
			widget:GetWidget('scrim_finder_no_connection_overlay'):SetVisible(0)
			widget:SetVisible(1)
			local channelName = 'Scrim_' .. GetCvarString('host_language')
			JoinChannel(nil, channelName)	
			ScanForChallenges()
		end
	end, false, nil, 'main', 'newMain')
	
	scrim_finder:RegisterWatchLua('PartyStatus', function(widget, trigger)
		if (trigger.inParty) and (trigger.queue == 'scrim') then
			Client.GetPartyList(ScrimFinder.searchOptions[1], ScrimFinder.searchOptions[2], ScrimFinder.searchOptions[3], ScrimFinder.searchOptions[4], ScrimFinder.searchOptions[5], ScrimFinder.searchOptions[6])
			local startTime = GetTime()
			widget:UnregisterWatchLua('System')
			widget:RegisterWatchLua('System', function(widget, trigger)
				local delayBeforeRefresh = math.random(5000,60000)
				if ((startTime + delayBeforeRefresh) < trigger.hostTime) then
					startTime = trigger.hostTime
					Client.GetPartyList(ScrimFinder.searchOptions[1], ScrimFinder.searchOptions[2], ScrimFinder.searchOptions[3], ScrimFinder.searchOptions[4], ScrimFinder.searchOptions[5], ScrimFinder.searchOptions[6])
				end
			end, false, nil, 'hostTime')		
			local partyCustomTrigger 		= LuaTrigger.GetTrigger('PartyTrigger')	
			partyCustomTrigger.userRequestedParty = true
			partyCustomTrigger:Trigger(false)			
		else
			widget:UnregisterWatchLua('System')
		end
	end, false, nil, 'inParty', 'queue')	
	
	local reconnectThread
	GetWidget('scrim_finder_no_connection_overlay'):RegisterWatchLua('PartyStatus', function(widget, trigger)
		if (reconnectThread) then
			reconnectThread:kill()
			reconnectThread = nil
		end
		if (trigger.inParty) and (trigger.queue == 'scrim') then
			widget:FadeOut(250)
		else
			widget:FadeIn(250)
			reconnectThread = libThread.threadFunc(function()
				wait(5000)
				if GetWidget('scrim_finder_no_connection_overlay') and GetWidget('scrim_finder_no_connection_overlay'):IsValid() and GetWidget('scrim_finder_no_connection_overlay'):IsVisible() then
					local partyStatusTrigger 		= LuaTrigger.GetTrigger('PartyStatus')
					local partyCustomTrigger 		= LuaTrigger.GetTrigger('PartyTrigger')				
					
					if (not partyStatusTrigger.inParty) and (LuaTrigger.GetTrigger('GamePhase').gamePhase ~= 1) then
						ChatClient.CreateParty()
						InitSelectionTriggers(object, false)
					end
					
					partyCustomTrigger.userRequestedParty = true
					partyCustomTrigger:Trigger(false)
					
					local selectModeInfo = LuaTrigger.GetTrigger('selectModeInfo') or LuaTrigger.CreateCustomTrigger('selectModeInfo', {
						{ name	= 'queuedMode',		type		= 'string' }
					})		
					
					selectModeInfo.queuedMode = 'scrim'
					selectModeInfo:Trigger(false)

					ScanForChallenges()		
				end
				reconnectThread = nil
			end)
		end
	end)	
	
	GetWidget('scrim_finder_no_region_overlay'):RegisterWatchLua('PartyStatus', function(widget, trigger)
		widget:SetVisible(Empty(trigger.region))
	end)
	
	local function InputRegister(object)

		local scrim_finder_input_textbox 						= object:GetWidget('scrim_finder_input_textbox')
		local scrim_finder_input_close_button 					= object:GetWidget('scrim_finder_input_close_button')
		local scrim_finder_input_coverup 						= object:GetWidget('scrim_finder_input_coverup')
		local  scrim_finder_input_button 						= object:GetWidget('scrim_finder_input_button')
		local scrollPanel 										= object:GetWidget('scrim_finder_input_scrollpanel')
		local scrollBar 										= object:GetWidget('scrim_finder_results_listbox_vscroll')

		function ScrimFinder.WheelUp()
			scrollBar:SetValue( math.max(0, scrollValue - 1) )
		end

		function  ScrimFinder.WheelDown()
			scrollBar:SetValue( math.min(scrollMax, scrollValue + 1) )
		end

		scrollPanel:SetCallback('onmousewheelup', function(widget)
			 ScrimFinder.WheelUp()
		end)

		scrollPanel:SetCallback('onmousewheeldown', function(widget)
			ScrimFinder.WheelDown()
		end)

		function ScrimFinder.InputOnEnter()
			scrim_finder_input_textbox:SetFocus(false)
		end

		function ScrimFinder.InputOnEsc()
			scrim_finder_input_textbox:EraseInputLine()
			scrim_finder_input_textbox:SetFocus(false)
			scrim_finder_input_textbox:SetVisible(true)
			scrim_finder_input_close_button:SetVisible(0)
			scrim_finder_input_coverup:SetVisible(true)
		end

		scrim_finder_input_button:SetCallback('onclick', function(widget)
			scrim_finder_input_textbox:SetFocus(true)
		end)

		scrim_finder_input_close_button:SetCallback('onclick', function(widget)
			ScrimFinder.InputOnEsc()
		end)

		scrim_finder_input_textbox:SetCallback('onfocus', function(widget)
			scrim_finder_input_coverup:SetVisible(false)
			scrim_finder_input_close_button:SetVisible(1)
		end)

		scrim_finder_input_textbox:SetCallback('onlosefocus', function(widget)
			if string.len(widget:GetValue()) == 0 then
				scrim_finder_input_coverup:SetVisible(true)
				scrim_finder_input_close_button:SetVisible(0)
			end
		end)

		scrim_finder_input_textbox:SetCallback('onhide', function(widget)
			 ScrimFinder.InputOnEsc()
		end)

		scrim_finder_input_textbox:SetCallback('onchange', function(widget)
			UpdateScrimFinderList()
		end)
	end

	InputRegister(object)
	
	local scrim_finder_region_label = GetWidget('scrim_finder_region_label')
	
	scrim_finder_region_label:RegisterWatchLua('PartyStatus', function(widget, trigger)
		widget:SetEnabled(trigger.isPartyLeader and (not trigger.inQueue))
	end, false, nil, 'isPartyLeader', 'inQueue')

	scrim_finder_region_label:SetCallback('onclick', function(widget, trigger)
		if (ChatAvailability) and (ChatAvailability.matchmaking) and (ChatAvailability.matchmaking.queues) then
			
			local function encodeData()
				return JSON:encode(ChatAvailability.matchmaking.queues)
			end
			local encodeSuccess, encodeData = pcall(encodeData)			
			
			if (encodeSuccess) then
				mainUI.savedLocally.hasSeenMMRegions = encodeData
				SaveState()
			end
		end
		PlaySound('ui/sounds/parties/sfx_map_open.wav')
	end)
	scrim_finder_region_label:RefreshCallbacks()	
	
	function ScrimFinder.MessagePlayerByIdentID(identID)
		println('^y  ScrimFinder.MessagePlayerByIdentID ' .. tostring(identID) )	
		local playerIdentIDNoDot 			= string.gsub(identID, '%.', '')
		local playerTrigger 				= LuaTrigger.GetTrigger('ChatClientInfo' .. playerIdentIDNoDot)					
		if (playerTrigger) and (playerTrigger.name) and (not Empty(playerTrigger.name)) then	
			mainUI.chatManager.InitPrivateMessage(identID, 1, playerTrigger.name)
		end
	end	
	
	function ScrimFinder.ChallengePlayerByIdentID(identID)
		println('^y  ScrimFinder.ChallengePlayerByIdentID ' .. tostring(identID) )
		ChatClient.PartyChallenge('', identID)
	end
	
	function ScrimFinder.ChallengePlayerByPartyID(partyID)
		println('^y  ScrimFinder.ChallengePlayerByPartyID ' .. tostring(partyID) )
		ChatClient.PartyChallenge(partyID)
	end
	
	function ScrimFinder.AcceptChallengeByPartyID(partyID)
		println('^y  ScrimFinder.AcceptChallengeByPartyID ' .. tostring(partyID) )
		ChatClient.PartyAcceptChallenge(partyID)
	end	
	
	function ScrimFinder.DeclineChallengeByPartyID(partyID)
		println('^y  ScrimFinder.DeclineChallengeByPartyID ' .. tostring(partyID) )
		ChatClient.PartyDeclineChallenge(partyID)
	end	
	
	function ScrimFinder.OpenScrimFinder()
		PlaySound('/ui/sounds/sfx_ui_creategame_2.wav')
		
		local partyStatusTrigger 		= LuaTrigger.GetTrigger('PartyStatus')
		local partyCustomTrigger 		= LuaTrigger.GetTrigger('PartyTrigger')				
		
		if (not partyStatusTrigger.inParty) and (LuaTrigger.GetTrigger('GamePhase').gamePhase ~= 1) then
			ChatClient.CreateParty()
			InitSelectionTriggers(object, false)
		end
		
		partyCustomTrigger.userRequestedParty = true
		partyCustomTrigger:Trigger(false)
		
		local selectModeInfo = LuaTrigger.GetTrigger('selectModeInfo') or LuaTrigger.CreateCustomTrigger('selectModeInfo', {
			{ name	= 'queuedMode',		type		= 'string' }
		})		
		
		selectModeInfo.queuedMode = 'scrim'
		selectModeInfo:Trigger(false)

		local triggerPanelStatus = LuaTrigger.GetTrigger('mainPanelStatus')
		triggerPanelStatus.main = 35 
		triggerPanelStatus:Trigger(false)	
		
		Friends.ToggleFriends(true)
		
		ScanForChallenges()
	end

	if (GetCvarBool('ui_devScrimFinder')) and IsFullyLoggedIn(GetIdentID()) then
		
		libThread.threadFunc(function()
			wait(8000)	
			-- Cmd('Clear')
			ScrimFinder.OpenScrimFinder()
			-- wait(3000)	
			-- if (GetCvarBool('ui_devScrimFinder2')) and IsFullyLoggedIn(GetIdentID()) then
				-- mainUI.ShowSplashScreen('splash_screen_party_challenge')
			-- end
		end)
		
		-- Cmd('WatchLuaTrigger PartyIncomingChallengeInfo0')
		-- Cmd('WatchLuaTrigger PartyIncomingChallengeInfo1')
		-- Cmd('WatchLuaTrigger PartyIncomingChallengeInfo2')
		-- Cmd('WatchLuaTrigger PartyIncomingChallengeInfo3')
		-- Cmd('WatchLuaTrigger PartyIncomingChallengeInfo4')
	
		-- Cmd('WatchLuaTrigger PartyOutgoingChallengeInfo0')
		-- Cmd('WatchLuaTrigger PartyOutgoingChallengeInfo1')
		-- Cmd('WatchLuaTrigger PartyOutgoingChallengeInfo2')
		-- Cmd('WatchLuaTrigger PartyOutgoingChallengeInfo3')
		-- Cmd('WatchLuaTrigger PartyOutgoingChallengeInfo4')
		
		-- Cmd('WatchLuaTrigger ChatPartySummary')
	
	end	
	
	
	
end

ScrimFinderInit(object)
