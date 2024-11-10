local _G = getfenv(0)
local ipairs, pairs, select, string, table, next, type, unpack, tinsert, tconcat, tremove, format, tostring, tonumber, tsort, ceil, floor, sub, find, gfind, len, lower, gsub = _G.ipairs, _G.pairs, _G.select, _G.string, _G.table, _G.next, _G.type, _G.unpack, _G.table.insert, _G.table.concat, _G.table.remove, _G.string.format, _G.tostring, _G.tonumber, _G.table.sort, _G.math.ceil, _G.math.floor, _G.string.sub, _G.string.find, _G.string.gfind, _G.string.len, _G.string.lower, _G.string.gsub

local interfaceName = object:GetName()
local interface = object

mainUI = mainUI or {}
mainUI.Clans = mainUI.Clans or {}
mainUI.Clans.page = 1

local function RegisterClansFinder(object)
	
	-- println('RegisterClansFinder 1/2')

	local clan_finder 							= interface:GetWidget('clan_finder')
	local frame 								= interface:GetWidget('clans_searchinput_frame')
	local buffer 								= interface:GetWidget('clans_searchinput_buffer')
	local frame_coverlabel 						= interface:GetWidget('clans_searchinput_coverlabel')
	local highlight 							= interface:GetWidget('clans_searchinput_frame_highlight')
	local clans_finder_region_combobox 			= interface:GetWidget('clans_finder_region_combobox')
	local clan_finder_results_scrollbox 		= interface:GetWidget('clan_finder_results_scrollbox')
	local clans_finder_search_btn 				= interface:GetWidget('clans_finder_search_btn')

	buffer:SetCallback('onevent', function(widget)
		buffer:SetInputLine('')
		buffer:SetFocus(false)
		buffer:SetDefaultFocus(false)
	end)
	
	buffer:SetCallback('onevent2', function(widget)
		buffer:SetFocus(false)
		buffer:SetDefaultFocus(false)
		mainUI.Clans.SearchClans()
	end)
	
	buffer:SetCallback('onfocus', function(widget)
		frame_coverlabel:SetVisible(0)
	end)

	buffer:SetCallback('onlosefocus', function(widget)
		local value = widget:GetValue()
		frame_coverlabel:SetVisible(value == '')
	end)

	buffer:SetCallback('onchange', function(widget)
		local value = widget:GetValue()
	end)


	local filters = {}
	local function registerFilter(id, filterValue, isDefault)
		local cbpanel 							= GetWidget(id .. '_cbpanel')
		local cbname 							= GetWidget(id .. '_cbname')
		-- local cb_frame_ 						= GetWidget(id .. 'cb_frame_')
		local options_checkbox_check 			= GetWidget('options_checkbox_check_' .. id)
		local options_checkbox_titlelabel 		= GetWidget('options_checkbox_titlelabel_' .. id)
		local isChecked							= false
		isDefault 								= isDefault or false
		
		filters[filterValue] = filters[filterValue] or {}
		table.insert(filters[filterValue], {active = isDefault, id = id})
		options_checkbox_check:SetVisible(isDefault)
		
		cbname:SetCallback('onclick', function(widget)
			if (not options_checkbox_check:IsVisible()) then
				local isChecked = not options_checkbox_check:IsVisible()
				
				for i,v in pairs(filters[filterValue]) do
					local check = GetWidget('options_checkbox_check_' .. v.id)
					v.active = false
					check:SetVisible(0)
				end
				
				options_checkbox_check:SetVisible(isChecked)
				
				for i,v in pairs(filters[filterValue]) do
					if (v.id == id) then
						v.active = isChecked
					end
				end
			end
		end)

	end
	
	registerFilter('clan_finder_filter_0_1', 'membership')	
	registerFilter('clan_finder_filter_0_2', 'membership')	
	registerFilter('clan_finder_filter_0_3', 'membership', true)	
	
	registerFilter('clan_finder_filter_1_1', 'focus')	
	registerFilter('clan_finder_filter_1_2', 'focus')	
	registerFilter('clan_finder_filter_1_3', 'focus', true)	
	
	registerFilter('clan_finder_filter_2_1', 'skill')	
	registerFilter('clan_finder_filter_2_2', 'skill')	
	registerFilter('clan_finder_filter_2_3', 'skill', true)		
	
	registerFilter('clan_finder_filter_3_1', 'medals', true)		
	registerFilter('clan_finder_filter_3_2', 'medals')		
	
	local regionComboboxInit = false
	local function UpdateRegionCombox()
		if (not regionComboboxInit) then
			regionComboboxInit = true
			clans_finder_region_combobox:ClearItems()
			-- local regions = Login.regionsTable
			local regions = mainUI.Clans.Regions or {}
			for i, v in ipairs(regions) do
				if (v[1]) then
					-- clans_finder_region_combobox:AddTemplateListItem('simpleDropdownItem', v[2], 'code', v[2], 'texture', '$invis', 'label', Translate(v[1]))
					clans_finder_region_combobox:AddTemplateListItem('windowframe_combobox_lang_item', v[1], 'code', v[1], 'texture', Translate('game_region_flag_' .. v[1]), 'label', Translate('game_region_' .. v[1]))
				end
			end
			clans_finder_region_combobox:SetSelectedItemByValue((mainUI.savedLocally and mainUI.savedLocally.defaultClanRegion) or 'NA')
		end
		clans_finder_region_combobox:SetEnabled(true)
	end

	clans_finder_region_combobox:SetCallback('onshow', function(widget)
		UpdateRegionCombox()
	end)	
	
	function mainUI.Clans.AttemptJoinClan(clanID)
		local chatClanInfo = LuaTrigger.GetTrigger('ChatClanInfo')
		local notInClan = (chatClanInfo.id == nil or chatClanInfo.id == '' or chatClanInfo.id == '0.000')
		if (notInClan) then
			ChatClient.RequestJoinClan(clanID)
		else
			GenericDialogAutoSize(
				'clans_leave_club', '', Translate('clans_leave_club_desc3', 'value', chatClanInfo.name), 'clans_leave_club_leave', 'general_cancel',
				function() 
					clan_finder:UnregisterWatchLua('ChatClanInfo')
					clan_finder:RegisterWatchLua('ChatClanInfo', function(widget, trigger)
						local notInClan = (chatClanInfo.id == nil or chatClanInfo.id == '' or chatClanInfo.id == '0.000')
						if (notInClan) then							
							clan_finder:UnregisterWatchLua('ChatClanInfo')
							ChatClient.RequestJoinClan(clanID)
						end
					end)						
					ChatClient.LeaveClan() 
				end,
				function() end
			)
		end	
	end
	
	function mainUI.Clans.UpdateDetailedClanInfo(inClanID)
		local clans_detailed_splash 						= interface:GetWidget('clans_detailed_splash')
		local club_finder_details_clan_name 				= interface:GetWidget('club_finder_details_clan_name')
		local club_finder_details_clan_score	 			= interface:GetWidget('club_finder_details_clan_score')
		local club_finder_details_clan_label_parent	 		= interface:GetWidget('club_finder_details_clan_label_parent')
		local ladder_row_scrollbar 							= interface:GetWidget('clanLadder_row_scrollbar_clan_detailed')
		local ladder_row_scrollbar_vscroll 					= interface:GetWidget('clanLadder_row_scrollbar_clan_detailed_vscroll')
					
		if (not inClanID) or (inClanID == '') then
			return
		end

		local oldRows = ladder_row_scrollbar:GetChildren()
		for i,v in pairs(oldRows) do
			if (v) and (v:IsValid()) then
				v:Destroy()
			end
		end		
		
		clans_detailed_splash:SetVisible(1)
		
		local getClanInfoSuccessFunction = function(request, cachedData)
			local responseData = cachedData or request:GetBody()
			if responseData == nil then
				printr('^r UpdateDetailedClanInfo getClanInfoSuccessFunction - no data')
			else
				println('^g UpdateDetailedClanInfo getClanInfoSuccessFunction SUCCESS')
				printr(responseData)
				
				if (responseData.clan_id) then
					
					local clanID 				= responseData.clan_id 				or ''
					local clanName 				= responseData.name 				or ''
					local clanDescription		= responseData.description 			or clanName or ''

					club_finder_details_clan_name:SetText(clanName)
					club_finder_details_clan_score:SetText(clanDescription)

					if (club_finder_details_clan_name) and (GetStringWidth('maindyn_48', clanName) > (club_finder_details_clan_label_parent:GetWidth() * 1.0) ) then
						club_finder_details_clan_name:SetFont('maindyn_18')
					else
						club_finder_details_clan_name:SetFont('maindyn_48')
					end	
					
					if (club_finder_details_clan_score) and (GetStringWidth('maindyn_28', clanDescription) > (club_finder_details_clan_label_parent:GetWidth() * 1.0) ) then
						club_finder_details_clan_score:SetFont('maindyn_14')
					else
						club_finder_details_clan_score:SetFont('maindyn_28')
					end						

					if (responseData.members) and (responseData.members.members) then
						local sortedTop100Data = {}
						
						for i,v in pairs(responseData.members.members) do
							if (v) and (v.nickname or v.name) then
								local playerTable = {}
								playerTable.name 			= v.nickname or v.name or ''
								playerTable.uniqueID 		= v.uniqueID or ''
								playerTable.clanSeals 		= v.clanSeals or 0
								playerTable.medalRating 	= v.pvp_rating0 or 0
								playerTable.identID 		= v.identID or v.ident_id or ''
								table.insert(sortedTop100Data, playerTable)
							end
						end

						table.sort(sortedTop100Data, function(a, b)
							if tonumber(a.medalRating) and tonumber(b.medalRating) and tonumber(a.medalRating) ~= tonumber(b.medalRating) then
								return tonumber(a.medalRating) > tonumber(b.medalRating)
							else
								return false
							end
						end)

						for i,v in ipairs(sortedTop100Data) do
							local color = '#ebebeb'
							local medalRating = tonumber(v.medalRating) or 0
							local clanSeals = tonumber(v.clanSeals) or 0
							if (IsMe(v.identID)) then
								color = '#ec6e31'
							elseif (i % 2) == 0 then 
								color = '#ebebeb'
							end
							ladder_row_scrollbar:Instantiate('clanLadderRow',
								'id', 'clan2' .. i,
								'displayname', (v.name or '?'),
								'rank', i or '?',
								'medals', math.ceil(medalRating),
								'seals', math.ceil(clanSeals),
								'color', color
							)
							local parent = GetWidget('clanLadderEntry_parent_' .. 'clan2' .. i)
							if (parent) and (v.identID) then
								parent:SetCallback('onclick', function() 
									ContextMenuTrigger.selectedUserIdentID = v.identID
									Profile.OpenProfile()	
								end)
								parent:SetCallback('onmouseover', function(widget) 
									UpdateCursor(widget, true, { canLeftClick = true, canRightClick = false, canDrag = false })
									Profile.OpenProfilePreview(v.identID)
								end)
								parent:SetCallback('onmouseout', function(widget) 
									UpdateCursor(widget, false, { canLeftClick = true, canRightClick = false, canDrag = false })
									Profile.CloseProfilePreview()
								end)					
								FindChildrenClickCallbacks(parent)
							end
						end
					end
					
					ladder_row_scrollbar:SetClipAreaToChild()
					ladder_row_scrollbar_vscroll:SetValue(0)

				end
			end
		end
		
		Strife_Web_Requests:GetClanInfo(inClanID, true, getClanInfoSuccessFunction)
	end
	
	local delayUpdateListThread
	function mainUI.Clans.DelayUpdateList(page)
		if (delayUpdateListThread) and (delayUpdateListThread:IsValid()) then
			delayUpdateListThread:kill()
			delayUpdateListThread = nil
		end	
		delayUpdateListThread = libThread.threadFunc(function()
			wait(200)
			mainUI.Clans.SearchClans(page, true)
		end)
	end
	
	local updateResultsThread
	local lastResult
	function mainUI.Clans.SearchClans(page, refilterLastResult)
	
		if (clans_finder_search_btn:GetNoClick()) then
			return
		end
	
		if (delayUpdateListThread) and (delayUpdateListThread:IsValid()) then
			delayUpdateListThread:kill()
			delayUpdateListThread = nil
		end		
	
		clans_finder_search_btn:SetNoClick(1)
		
		local clans_finder_language_combobox 	= interface:GetWidget('clans_finder_language_combobox')
		local clans_finder_region_combobox 		= interface:GetWidget('clans_finder_region_combobox')
		local clan_finder_results 				= interface:GetWidget('clan_finder_results')
		
		local search = interface:GetWidget('clans_searchinput_buffer'):GetValue()
		local recruitment = 3
		local language = 'en'
		local region = 'NA'
		local limitToMyMedals = false
		local memberFilter = 0
		
		if (page) then
			mainUI.Clans.page = page
		else
			mainUI.Clans.page = 1
		end
		
		if (clans_finder_language_combobox:GetValue() ~= '') then
			language = clans_finder_language_combobox:GetValue()
		end
		
		language = string.sub(language, 1, 2)		
		
		if (clans_finder_region_combobox:GetValue() ~= '') then
			region = clans_finder_region_combobox:GetValue()
		end
			
		if (filters['membership']) then
			for i,v in pairs(filters['membership']) do -- Open (2) Application (1) Both (3) Invite Only (0)
				if (v.active and v.id == 'clan_finder_filter_0_1') then -- Open (2)
					recruitment = 2
				elseif (v.active and v.id == 'clan_finder_filter_0_2') then -- Invite Only
					recruitment = 0
				elseif (v.active and v.id == 'clan_finder_filter_0_3') then -- Open + Application
					recruitment = 3
				end
			end
		end
			
		if (filters['medals']) then
			for i,v in pairs(filters['medals']) do
				if (v.active and v.id == 'clan_finder_filter_3_1') then -- I Can Join
					limitToMyMedals = true
				elseif (v.active and v.id == 'clan_finder_filter_3_2') then -- All
					limitToMyMedals = false
					memberFilter = -1
				end
			end
		end		

		local minRatingMax
		local minRatingMin
		if (limitToMyMedals) then
			local myChatClientInfo = (GetMyChatClientInfo and GetMyChatClientInfo())
			minRatingMax = math.floor((myChatClientInfo and myChatClientInfo.rating) or 0)
			minRatingMin = -1500
		end		
		
		local failureFunction = function(request)
			clans_finder_search_btn:SetNoClick(0)
		end
		
		local successFunction = function(request, dataOverride)
			clans_finder_search_btn:SetNoClick(0)

			println('Search Results')
			
			local responseData = dataOverride or request:GetBody()
			lastResult = responseData
			-- printr(responseData)
			
			if responseData == nil then
				return
			end
		
			local stringKey = 0
			
			local unsortedSearchResults = {}
			local searchResults = {}
			local matchingSearchResults = {}
			local notMatchingSearchResults = {}			
			
			while (responseData[tostring(stringKey)]) do
				table.insert(unsortedSearchResults, responseData[tostring(stringKey)])
				stringKey = stringKey + 1
			end
			
			-- printr(unsortedSearchResults)

			if (unsortedSearchResults) and (#unsortedSearchResults > 0) then
				for i,v in ipairs(unsortedSearchResults) do
					if (v) and (v.region == region) and (((tonumber(recruitment or 0) or 0) == 3) or ((tonumber(v.recruitStatus or 0) or 0) == (recruitment or 0))) and (v.language == language) and ((minRatingMax == nil) or ((tonumber(v.minRating or 0) or 0) <= (tonumber(minRatingMax or 0) or 0))) then
						table.insert(matchingSearchResults, v)
					else
						table.insert(notMatchingSearchResults, v)
						-- println(tostring( (v.region == region) ))
						-- println(tostring( (((tonumber(recruitment or 0) or 0) == 3) or ((tonumber(v.recruitStatus or 0) or 0) == (recruitment or 0))) ))
						-- println(tostring( (v.language == language) ))
						-- println(tostring( ((minRatingMax == nil) or ((tonumber(v.minRating or 0) or 0) <= (tonumber(minRatingMax or 0) or 0))) ))
					end
				end
			end
			
			table.sort(matchingSearchResults, function(a, b)
				if (a.recruitStatus) and (b.recruitStatus) and tonumber(a.recruitStatus) and tonumber(b.recruitStatus) and tonumber(a.recruitStatus) ~= tonumber(b.recruitStatus) then
					return tonumber(a.recruitStatus) > tonumber(b.recruitStatus)
				elseif (a.members) and (b.members) and tonumber(a.members) and tonumber(b.members) and tonumber(a.members) ~= tonumber(b.members) then
					return tonumber(a.members) > tonumber(b.members)					
				else
					return false
				end
			end)

			table.sort(notMatchingSearchResults, function(a, b)
				if (a.recruitStatus) and (b.recruitStatus) and tonumber(a.recruitStatus) and tonumber(b.recruitStatus) and tonumber(a.recruitStatus) ~= tonumber(b.recruitStatus) then
					return tonumber(a.recruitStatus) > tonumber(b.recruitStatus)
				elseif (a.members) and (b.members) and tonumber(a.members) and tonumber(b.members) and tonumber(a.members) ~= tonumber(b.members) then
					return tonumber(a.members) > tonumber(b.members)					
				else
					return false
				end
			end)			
			
			for i,v in ipairs(matchingSearchResults) do
				table.insert(searchResults, v)
			end
			
			for i,v in ipairs(notMatchingSearchResults) do
				table.insert(searchResults, v)
			end			
			
			-- println('region ' .. tostring(region))
			-- println('language ' .. tostring(language))
			-- println('recruitment ' .. tostring(recruitment))
			-- println('minRatingMax ' .. tostring(minRatingMax))
			
			-- printr(matchingSearchResults)
			-- printr(notMatchingSearchResults)

			printr(searchResults)
			
			if (updateResultsThread) and (updateResultsThread:IsValid()) then
				updateResultsThread:kill()
				updateResultsThread = nil
			end
			
			updateResultsThread = libThread.threadFunc(function()
						
				local children = clan_finder_results:GetChildren()
				for _,v in pairs(children) do
					if (v) and (v:IsValid()) then
						v:Destroy()
					end
				end

				wait(1)			
				
				local myChatClientInfo = (GetMyChatClientInfo and GetMyChatClientInfo())
				local myMedals = ((myChatClientInfo and myChatClientInfo.rating) or 0)
				
				if (searchResults) and (#searchResults > 0) then

					for i,v in ipairs(searchResults) do
						
						local clanID 				= v.clan_id 			or ''
						local clanName 				= v.name 				or ''
						local clanTag 				= v.tag 				or ''
						local clanDescription		= v.description 		or clanName or ''
						local clanRegion			= v.region 				or 'NA'
						local clanLanguage			= v.language 			or 'en'
						local clanRecruitStatus 	= tonumber(v.recruitStatus or 0) or 0
						local memberCount			= tonumber(v.members or 0) or 0
						local minRating				= tonumber(v.minRating or 0) or 0 
						local maxMembers			= 50
						
						if (clanLanguage == 'pt') then clanLanguage = 'pt_br' end
						
						local regionFlagPath 		= Translate('game_region_flag_' .. clanRegion)
						local languageFlagPath 		= Translate('lang_flag_' .. clanLanguage)
						local memberLabel			= memberCount .. '/' .. maxMembers
						
						local id 					= 'search_' .. clanID					
						
						local hasEnoughMedals		= (myMedals >= minRating)

						clan_finder_results:Instantiate('clans_finder_results_listitem',
							'id', id,
							'clanID', clanID,
							'clan_name', clanName,
							'language_flag', languageFlagPath,
							'region_flag', regionFlagPath,
							'member_label', memberLabel,
							'tag', '[' .. clanTag .. ']',
							'medals', minRating + 1500,
							'medalscolor', ((hasEnoughMedals and '#ebebeb') or '1 0 0 1')
						)		
						
						-- println(clanName)
						-- println(clanRecruitStatus)
						-- println(tostring((clanRecruitStatus == 2)))

						local nameWidget = interface:GetWidget('clans_finder_results_listitem_' .. id .. '_clan_name')
						if (nameWidget) and (GetStringWidth('maindyn_20', clanName) > nameWidget:GetWidth()) then
							nameWidget:SetFont('maindyn_18')
						end						
						
						interface:GetWidget('clans_finder_results_listitem_' .. id .. '_action'):SetVisible((hasEnoughMedals) or false)
						interface:GetWidget('clans_finder_results_listitem_' .. id .. '_action_label'):SetVisible((not hasEnoughMedals) or false)
						interface:GetWidget('clans_finder_results_listitem_' .. id .. '_action_label'):SetText(Translate('clans_not_eligible'))
						
						interface:GetWidget('clans_finder_results_listitem_' .. id .. '_action'):SetCallback('onclick', function(widget)
							
							local pendingApplication2 = false
							if (mainUI.Clans.clanApplications) then
								for i,v in pairs(mainUI.Clans.clanApplications) do
									if (v == clanID) then
										pendingApplication2 = true
										break
									end							
								end
							end	

							if (not pendingApplication2) then
								mainUI.Clans.AttemptJoinClan(clanID)
							end
							
							simpleTipGrowYUpdate(false)
							
							LuaTrigger.GetTrigger('clanFinderUpdate'):Trigger(true)
						end)	
						
						interface:GetWidget('clans_finder_results_listitem_' .. id .. '_parent_btn'):SetCallback('onclick', function(widget)	
							mainUI.Clans.UpdateDetailedClanInfo(clanID)
						end)
						interface:GetWidget('clans_finder_results_listitem_' .. id .. '_parent_btn'):SetCallback('onmouseover', function(widget)		
							simpleTipGrowYUpdate(true, nil, clanName, clanDescription, self:GetHeightFromString('320s'))
							UpdateCursor(widget, true, { canLeftClick = true, canRightClick = false, canDrag = false })
						end)
						interface:GetWidget('clans_finder_results_listitem_' .. id .. '_parent_btn'):SetCallback('onmouseout', function(widget)		
							simpleTipGrowYUpdate(false)
							UpdateCursor(widget, false, { canLeftClick = false, canRightClick = false, canDrag = false })
						end)	
						
						interface:GetWidget('clans_finder_results_listitem_' .. id .. '_moreinfo'):SetCallback('onclick', function(widget)	
							mainUI.Clans.UpdateDetailedClanInfo(clanID)
						end)
						interface:GetWidget('clans_finder_results_listitem_' .. id .. '_moreinfo'):SetCallback('onmouseover', function(widget)		
							simpleTipGrowYUpdate(true, nil, clanName, clanDescription, self:GetHeightFromString('320s'))
							UpdateCursor(widget, true, { canLeftClick = true, canRightClick = false, canDrag = false })
						end)
						interface:GetWidget('clans_finder_results_listitem_' .. id .. '_moreinfo'):SetCallback('onmouseout', function(widget)		
							simpleTipGrowYUpdate(false)
							UpdateCursor(widget, false, { canLeftClick = false, canRightClick = false, canDrag = false })
						end)
						
						local function UpdatePendingStatus()
							local pendingApplication = false
							local pendingInvite = false
							if (mainUI.Clans.clanApplications) then
								for i,v in pairs(mainUI.Clans.clanApplications) do
									if (v == clanID) then
										pendingApplication = true
										break
									end
								end
							end
							if (mainUI.Clans.clanInvites) then
								for i,v in pairs(mainUI.Clans.clanInvites) do
									if (v.clanID == clanID) then
										pendingInvite = true
										break
									end
								end							
							end
							
							if (pendingApplication) then
								
								interface:GetWidget('clans_finder_results_listitem_' .. id .. '_actionLabel'):SetText(Translate('clans_sent'))
								interface:GetWidget('clans_finder_results_listitem_' .. id .. '_action'):SetEnabled(0)
								
							
							elseif (pendingInvite) then
								
								interface:GetWidget('clans_finder_results_listitem_' .. id .. '_actionLabel'):SetText(Translate('clans_join'))
								interface:GetWidget('clans_finder_results_listitem_' .. id .. '_action'):SetEnabled(1)
								
								interface:GetWidget('clans_finder_results_listitem_' .. id .. '_action'):SetCallback('onmouseover', function(widget)
									simpleTipGrowYUpdate(true, nil, Translate('social_action_bar_apply_join_clan'), Translate('social_action_bar_apply_join_clan_desc'), self:GetHeightFromString('340s'))
								end)
								
								interface:GetWidget('clans_finder_results_listitem_' .. id .. '_action'):SetCallback('onmouseout', function(widget)
									simpleTipGrowYUpdate(false)
								end)							
								
							elseif (clanRecruitStatus == 0) then

								interface:GetWidget('clans_finder_results_listitem_' .. id .. '_action'):SetVisible(0)
								interface:GetWidget('clans_finder_results_listitem_' .. id .. '_action'):SetEnabled(0)
								interface:GetWidget('clans_finder_results_listitem_' .. id .. '_actionLabel'):SetText(Translate('clans_not_eligible'))	
								interface:GetWidget('clans_finder_results_listitem_' .. id .. '_action_label'):SetVisible(1)
								
							elseif (clanRecruitStatus == 1) then
								
								interface:GetWidget('clans_finder_results_listitem_' .. id .. '_action'):SetEnabled(1)
								interface:GetWidget('clans_finder_results_listitem_' .. id .. '_actionLabel'):SetText(Translate('clans_apply'))

								interface:GetWidget('clans_finder_results_listitem_' .. id .. '_action'):SetCallback('onmouseover', function(widget)
									simpleTipGrowYUpdate(true, nil, Translate('social_action_bar_apply_apply_clan'), Translate('social_action_bar_apply_apply_clan_desc'), self:GetHeightFromString('340s'))
								end)
								
								interface:GetWidget('clans_finder_results_listitem_' .. id .. '_action'):SetCallback('onmouseout', function(widget)
									simpleTipGrowYUpdate(false)
								end)					
							
							elseif (clanRecruitStatus == 2) then
								
								interface:GetWidget('clans_finder_results_listitem_' .. id .. '_action'):SetEnabled(1)
								interface:GetWidget('clans_finder_results_listitem_' .. id .. '_actionLabel'):SetText(Translate('clans_join'))

								interface:GetWidget('clans_finder_results_listitem_' .. id .. '_action'):SetCallback('onmouseover', function(widget)
									simpleTipGrowYUpdate(true, nil, Translate('social_action_bar_apply_join_clan'), Translate('social_action_bar_apply_join_clan_desc'), self:GetHeightFromString('340s'))
								end)
								
								interface:GetWidget('clans_finder_results_listitem_' .. id .. '_action'):SetCallback('onmouseout', function(widget)
									simpleTipGrowYUpdate(false)
								end)						
							
							end
						end
						
						UpdatePendingStatus()
						
						interface:GetWidget('clans_finder_results_listitem_' .. id .. '_parent_btn'):RegisterWatchLua('clanFinderUpdate', function(widget, trigger)
							UpdatePendingStatus()
						end)
						
					end
				else
					clan_finder_results:Instantiate('clans_finder_noresults_listitem')				
				end
				
				local showPageButtons = ((searchResults and #searchResults >= 60) or (page and page > 1)) or false
				
				interface:GetWidget('clans_finder_prev_btn'):SetVisible(showPageButtons)
				interface:GetWidget('clans_finder_next_btn'):SetVisible(showPageButtons)
				interface:GetWidget('clans_finder_prev_btn'):SetEnabled((page and page > 1) or false)				
				interface:GetWidget('clans_finder_next_btn'):SetEnabled((searchResults and #searchResults >= 60) or false)				
				
				clan_finder_results_scrollbox:DoEvent()
			end)
		end
		
		local children = clan_finder_results:GetChildren()
		for _,v in pairs(children) do
			if (v) and (v:IsValid()) then
				v:Destroy()
			end
		end
		
		println('mainUI.Clans.SearchClans search: ' .. tostring(search) .. ' | language:' .. tostring(language)  .. ' | region:' .. tostring(region)  .. ' | recruitment:' .. tostring(recruitment) )
		
		
		local isTagSearch = string.find(search, '%[') or string.find(search, '%]')
		if (isTagSearch) then
			search = string.gsub(search, '%[', '')
			search = string.gsub(search, '%]', '')
		end
		local searchLength = string.len(search)

		if (refilterLastResult) and (lastResult) then
			successFunction(nil, lastResult)
		elseif (searchLength == 0) then
			println('region search')
			Strife_Web_Requests:SearchClans(region, language, nil, nil, nil, recruitment, minRatingMax, minRatingMin, successFunction, failureFunction, page, memberFilter)
		elseif (searchLength < 3) then
			if (isTagSearch) then
				println('region + tag search')
				Strife_Web_Requests:SearchClans(region, language, search, nil, nil, recruitment, minRatingMax, minRatingMin, successFunction, failureFunction, page, memberFilter)
			else
				println('region + name search')
				Strife_Web_Requests:SearchClans(region, language, nil, search, nil, recruitment, minRatingMax, minRatingMin, successFunction, failureFunction, page, memberFilter)
			end
		else
			if (isTagSearch) then
				println('global tag search')
				Strife_Web_Requests:SearchClansByTag(search, successFunction, failureFunction)	
			else			
				println('global name search')
				Strife_Web_Requests:SearchClansByName(search, successFunction, failureFunction)
			end
		end
		
		-- Strife_Web_Requests:SearchClans(regionString, languageString, tagString, nameString, memberString, recruitStatusString, minRatingMax, minRatingMin, successFunction, failFunction
		-- Strife_Web_Requests:SearchClansByName(clanNameSearch, successFunction, failFunction)
		-- Strife_Web_Requests:SearchClansByTag(clanTagSearch, successFunction, failFunction)
		
		-- ChatClient.SearchClans(search, searchCallback)
	end
	
	local updateInvitesThread
	local updateKey = 0
	local function UpdateInvites()
		
		if (not GetCvarBool('host_islauncher')) then
			-- println('^r Clan UpdateInvites denied because host_islauncher is : ' .. tostring(host_islauncher))
			return
		end			
	
		if (LuaTrigger.GetTrigger('GamePhase').gamePhase > 0 and LuaTrigger.GetTrigger('GamePhase').gamePhase < 4) then
			-- println('^r Clan UpdateInvites denied because GamePhase is : ' .. tostring(LuaTrigger.GetTrigger('GamePhase').gamePhase))
			return
		end			
		
		local clan_finder_pending_invite_parent 		= interface:GetWidget('clan_finder_pending_invite_parent')
		local clan_finder_pending_invite 				= interface:GetWidget('clan_finder_pending_invite')
		local clan_finder_pending_application_parent 	= interface:GetWidget('clan_finder_pending_application_parent')
		local clan_finder_pending_application			= interface:GetWidget('clan_finder_application_invite')
		
		if (updateInvitesThread) and (updateInvitesThread:IsValid()) then
			updateInvitesThread:kill()
			updateInvitesThread = nil
		end
		
		updateInvitesThread = libThread.threadFunc(function()
			
			updateKey = updateKey + 1
			local myUpdateKey = updateKey
			
			local children = clan_finder_pending_invite:GetChildren()
			for _,v in pairs(children) do
				if (v) and (v:IsValid()) then
					v:Destroy()
				end
			end
					
			local children = clan_finder_pending_application:GetChildren()
			for _,v in pairs(children) do
				if (v) and (v:IsValid()) then
					v:Destroy()
				end
			end
			
			wait(1)
			
			if (mainUI.Clans.clanInvites) and (#mainUI.Clans.clanInvites > 0) then
				Notifications.ClanInvite(#mainUI.Clans.clanInvites)
				println('mainUI.Clans.clanInvites')
				printr(mainUI.Clans.clanInvites)
				for i,v in ipairs(mainUI.Clans.clanInvites) do
					if (i) and (i <= 3) and (v) and (v.clanID) then
						
						local getClanInfoSuccessFunction = function(request, cachedData)
							local responseData = cachedData or request:GetBody()
							if responseData == nil then
								printr('^r UpdateInvites getClanInfoSuccessFunction - no data')
							else
								-- println('^g UpdateInvites getClanInfoSuccessFunction SUCCESS')
								-- printr(responseData)
								
								if (responseData.clan_id) and (myUpdateKey == updateKey) then
									
									mainUI.Clans.getClanInfoCache 										= mainUI.Clans.getClanInfoCache or {}
									mainUI.Clans.getClanInfoCache[responseData.clan_id] 				= mainUI.Clans.getClanInfoCache[responseData.clan_id] or {}
									mainUI.Clans.getClanInfoCache[responseData.clan_id][true]			= responseData									
									
									local clanID 				= responseData.clan_id 				or ''
									local clanName 				= responseData.name 				or ''
									local clanDescription		= responseData.description 			or clanName or ''
									local clanRegion			= responseData.region 				or 'NA'
									local clanLanguage			= responseData.language 			or 'en'
									local clanRecruitStatus 	= responseData.recruitStatus 		or 0
									local memberCount			= 0
									local maxMembers			= 50
									if (responseData.members) and (responseData.members.members) then
										for i,v in pairs(responseData.members.members) do
											memberCount = memberCount + 1
										end
									end
									
									if (clanLanguage == 'pt') then clanLanguage = 'pt_br' end
									
									local regionFlagPath 		= Translate('game_region_flag_' .. clanRegion)
									local languageFlagPath 		= Translate('lang_flag_' .. clanLanguage)
									local memberLabel			= memberCount .. '/' .. maxMembers
									
									local id 					= 'pending_' .. clanID

									libThread.threadFunc(function()
										
										local parent = interface:GetWidget('clans_finder_results_listitem_' .. id .. '_parent_btn')
										
										if (parent) and (parent:IsValid()) then
											parent:Destroy()
											wait(1)
										end
										
										clan_finder_pending_invite:Instantiate('clans_finder_pending_invite_listitem',
											'id', id,
											'clanID', clanID,
											'clan_name', clanName,
											'language_flag', languageFlagPath,
											'region_flag', regionFlagPath,
											'member_label', memberLabel	
										)
										
										local nameWidget = interface:GetWidget('clans_finder_results_listitem_' .. id .. '_clan_name')
										if (nameWidget) and (GetStringWidth('maindyn_20', clanName) > nameWidget:GetWidth()) then
											nameWidget:SetFont('maindyn_18')
										end											
										
										interface:GetWidget('clans_finder_results_listitem_' .. id .. '_moreinfo'):SetCallback('onclick', function(widget)	
											mainUI.Clans.UpdateDetailedClanInfo(clanID)
										end)
										interface:GetWidget('clans_finder_results_listitem_' .. id .. '_moreinfo'):SetCallback('onmouseover', function(widget)		
											simpleTipGrowYUpdate(true, nil, clanName, clanDescription, self:GetHeightFromString('380s'))
											UpdateCursor(widget, true, { canLeftClick = true, canRightClick = false, canDrag = false })
										end)
										interface:GetWidget('clans_finder_results_listitem_' .. id .. '_moreinfo'):SetCallback('onmouseout', function(widget)		
											simpleTipGrowYUpdate(false)
											UpdateCursor(widget, false, { canLeftClick = false, canRightClick = false, canDrag = false })
										end)								
										
										interface:GetWidget('clans_finder_results_listitem_' .. id .. '_btn_approve'):SetCallback('onclick', function(widget)
											ChatClient.AcceptClanInvite(clanID)
											if (mainUI.Clans.clanInvites) and (#mainUI.Clans.clanInvites > 0) then
												for i,v in ipairs(mainUI.Clans.clanInvites) do	
													if (v) and (v.clanID == clanID) then
														mainUI.Clans.clanInvites[i] = nil
														break
													end
												end
												UpdateInvites()
											end
											simpleTipGrowYUpdate(false)
										end)
										
										interface:GetWidget('clans_finder_results_listitem_' .. id .. '_btn_approve'):SetCallback('onmouseover', function(widget)
											simpleTipGrowYUpdate(true, nil, Translate('social_action_bar_accept_claninvite'), Translate('social_action_bar_accept_claninvite_desc'), self:GetHeightFromString('340s'))
										end)
										
										interface:GetWidget('clans_finder_results_listitem_' .. id .. '_btn_approve'):SetCallback('onmouseout', function(widget)
											simpleTipGrowYUpdate(false)
										end)

										interface:GetWidget('clans_finder_results_listitem_' .. id .. '_btn_reject'):SetCallback('onclick', function(widget)
											ChatClient.RejectClanInvite(clanID)
											if (mainUI.Clans.clanInvites) and (#mainUI.Clans.clanInvites > 0) then
												for i,v in ipairs(mainUI.Clans.clanInvites) do	
													if (v) and (v.clanID == clanID) then
														mainUI.Clans.clanInvites[i] = nil
														break
													end
												end
												UpdateInvites()
											end
											simpleTipGrowYUpdate(false)
											LuaTrigger.GetTrigger('clanFinderUpdate'):Trigger(true)
										end)
										
										interface:GetWidget('clans_finder_results_listitem_' .. id .. '_btn_reject'):SetCallback('onmouseover', function(widget)
											simpleTipGrowYUpdate(true, nil, Translate('social_action_bar_reject_claninvite'), Translate('social_action_bar_reject_claninvite_desc'), self:GetHeightFromString('340s'))
										end)
										
										interface:GetWidget('clans_finder_results_listitem_' .. id .. '_btn_reject'):SetCallback('onmouseout', function(widget)
											simpleTipGrowYUpdate(false)
										end)								
										
										clan_finder_pending_invite_parent:SetVisible(1)
										
										wait(1)
										
										clan_finder_results_scrollbox:DoEvent()										
										
									end)
								else
									println('ignoring old request myUpdateKey ' .. tostring(myUpdateKey) .. ' updateKey ' .. tostring(updateKey))
								end
							end					
						end

						Strife_Web_Requests:GetClanInfo(v.clanID, true, getClanInfoSuccessFunction)
					end
				end
			else
				clan_finder_pending_invite_parent:SetVisible(0)		
				Notifications.ClanInvite(0)
			end

			if (mainUI.Clans.clanApplications) and (#mainUI.Clans.clanApplications > 0) then
				println('mainUI.Clans.clanApplications')
				printr(mainUI.Clans.clanApplications)				
				for i,v in pairs(mainUI.Clans.clanApplications) do
					if (i) and (i <= 20) and (v) then
						
						local getClanInfoSuccessFunction = function(request, cachedData)
							local responseData = cachedData or request:GetBody()
							if responseData == nil then
								printr('^r UpdateInvites getClanInfoSuccessFunction - no data')
							else

								if (responseData.clan_id) and (myUpdateKey == updateKey) then
									
									println('^g UpdateInvites getClanInfoSuccessFunction SUCCESS')
									-- printr(responseData)									
									
									local clanID 				= responseData.clan_id 				or ''
									local clanName 				= responseData.name 				or ''
									local clanDescription		= responseData.description 			or clanName or ''
									local clanRegion			= responseData.region 				or 'NA'
									local clanLanguage			= responseData.language 			or 'en'
									local clanRecruitStatus 	= responseData.recruitStatus 		or 0
									local memberCount			= 0
									local maxMembers			= 50
									if (responseData.members) and (responseData.members.members) then
										for i,v in pairs(responseData.members.members) do
											memberCount = memberCount + 1
										end
									end
									
									if (clanLanguage == 'pt') then clanLanguage = 'pt_br' end
									
									local regionFlagPath 		= Translate('game_region_flag_' .. clanRegion)
									local languageFlagPath 		= Translate('lang_flag_' .. clanLanguage)
									local memberLabel			= memberCount .. '/' .. maxMembers
									
									local id 					= 'application_' .. clanID
									
									libThread.threadFunc(function()
										
										local parent = interface:GetWidget('clans_finder_results_listitem_' .. id .. '_parent_btn')
										
										if (parent) and (parent:IsValid()) then
											parent:Destroy()
											wait(1)
										end									
									
										clan_finder_pending_application:Instantiate('clans_finder_pending_application_listitem',
											'id', id,
											'clanID', clanID,
											'clan_name', clanName,
											'language_flag', languageFlagPath,
											'region_flag', regionFlagPath,
											'member_label', memberLabel	
										)
										
										local nameWidget = interface:GetWidget('clans_finder_results_listitem_' .. id .. '_clan_name')
										if (nameWidget) and (GetStringWidth('maindyn_20', clanName) > nameWidget:GetWidth()) then
											nameWidget:SetFont('maindyn_18')
										end											
										
										interface:GetWidget('clans_finder_results_listitem_' .. id .. '_moreinfo'):SetCallback('onclick', function(widget)	
											mainUI.Clans.UpdateDetailedClanInfo(clanID)
										end)
										interface:GetWidget('clans_finder_results_listitem_' .. id .. '_moreinfo'):SetCallback('onmouseover', function(widget)		
											simpleTipGrowYUpdate(true, nil, clanName, clanDescription, self:GetHeightFromString('380s'))
											UpdateCursor(widget, true, { canLeftClick = true, canRightClick = false, canDrag = false })
										end)
										interface:GetWidget('clans_finder_results_listitem_' .. id .. '_moreinfo'):SetCallback('onmouseout', function(widget)		
											simpleTipGrowYUpdate(false)
											UpdateCursor(widget, false, { canLeftClick = false, canRightClick = false, canDrag = false })
										end)									
										
										interface:GetWidget('clans_finder_results_listitem_' .. id .. '_action'):SetCallback('onclick', function(widget)
											ChatClient.CancelClanApplication(clanID)
											simpleTipGrowYUpdate(false)
											LuaTrigger.GetTrigger('clanFinderUpdate'):Trigger(true)
										end)
										
										interface:GetWidget('clans_finder_results_listitem_' .. id .. '_action'):SetCallback('onmouseover', function(widget)
											simpleTipGrowYUpdate(true, nil, Translate('social_action_bar_withdraw_application'), Translate('social_action_bar_withdraw_application_desc'), self:GetHeightFromString('340s'))
										end)
										
										interface:GetWidget('clans_finder_results_listitem_' .. id .. '_action'):SetCallback('onmouseout', function(widget)
											simpleTipGrowYUpdate(false)
										end)
										
										clan_finder_pending_application_parent:SetVisible(1)
										
										wait(1)
										
										clan_finder_results_scrollbox:DoEvent()
									end)
								else
									println('ignoring old request myUpdateKey ' .. tostring(myUpdateKey) .. ' updateKey ' .. tostring(updateKey))									
								end
							end					
						end

						Strife_Web_Requests:GetClanInfo(v, true, getClanInfoSuccessFunction)
					end
				end
			else
				clan_finder_pending_application_parent:SetVisible(0)		
			end
			
			wait(1)
			LuaTrigger.GetTrigger('clanFinderUpdate'):Trigger(true)
			wait(1)
			clan_finder_results_scrollbox:DoEvent()
		end)

	end

	local canInitialSearch = true
	clan_finder:SetCallback('onshow', function(widget)
		-- println('ChatClanInvite')
		if (not mainUI.Clans.clanApplications) then
			mainUI.Clans.clanApplications = {}
			local clanApplicationsTable = ChatClient.GetClanApplications()
			for i, v in pairs(clanApplicationsTable) do
				table.insert(mainUI.Clans.clanApplications, v)
			end
		end
		if (not mainUI.Clans.clanInvites) then
			 mainUI.Clans.clanInvites = {}
			 local clanInvitesTable = ChatClient.GetClanInvitations()
			 -- printr(clanInvitesTable)
			 for i, v in pairs(clanInvitesTable) do
				local invite = {}
				invite.senderName 		= v.sendername
				invite.senderUniqueID 	= v.senderuniqueid
				invite.senderIdentID 	= v.senderid
				invite.clanID 			= v.clanid
				table.insert(mainUI.Clans.clanInvites, invite)
			 end
		end
		-- printr(mainUI.Clans.clanInvites)
		UpdateInvites()
		if (canInitialSearch) and (IsFullyLoggedIn(GetIdentID())) then
			canInitialSearch = false
			mainUI.Clans.SearchClans()
		end
	end, false, nil, 'clanID', 'senderIdentID', 'senderName', 'senderUniqueID')	
	
	clan_finder:RegisterWatchLua('ChatClanInvite', function(widget, trigger)
		-- println('ChatClanInvite')
		if (not mainUI.Clans.clanInvites) then
			 mainUI.Clans.clanInvites = {}
			 local clanInvitesTable = ChatClient.GetClanInvitations()
			 -- printr(clanInvitesTable)
			 for i, v in pairs(clanInvitesTable) do
				local invite = {}
				invite.senderName 		= v.sendername
				invite.senderUniqueID 	= v.senderuniqueid
				invite.senderIdentID 	= v.senderid
				invite.clanID 			= v.clanid
				table.insert(mainUI.Clans.clanInvites, invite)
			 end
		elseif (mainUI.Clans.clanInvites) then
			local foundMatch = false
			for i,v in pairs(mainUI.Clans.clanInvites) do
				if ((v.clanID) and (v.clanID == trigger.clanID)) then
					foundMatch = true
					break
				end
			end
			if (not foundMatch) then
				local invite = {}
				invite.clanID 			= trigger.clanID
				invite.senderIdentID 	= trigger.senderIdentID
				invite.senderName 		= trigger.senderName
				invite.senderUniqueID 	= trigger.senderUniqueID
				tinsert(mainUI.Clans.clanInvites, invite)
			end
		end
		-- printr(mainUI.Clans.clanInvites)
		UpdateInvites()
	end, false, nil, 'clanID', 'senderIdentID', 'senderName', 'senderUniqueID')
			
	clan_finder:RegisterWatchLua('ChatClanApplication', function(widget, trigger)
		-- println('ChatClanApplication')
		if (not mainUI.Clans.clanApplications) then
			mainUI.Clans.clanApplications = {}
			local clanApplicationsTable = ChatClient.GetClanApplications()
			for i, v in pairs(clanApplicationsTable) do
				table.insert(mainUI.Clans.clanApplications, v)
			end
		elseif (mainUI.Clans.clanApplications) then
			if (trigger.added) then
				local foundMatch = false
				for i,v in pairs(mainUI.Clans.clanApplications) do
					if (v == trigger.clanID) then
						foundMatch = true
						break
					end
				end
				if (not foundMatch) then
					tinsert(mainUI.Clans.clanApplications, trigger.clanID)
				end
			else
				for i,v in pairs(mainUI.Clans.clanApplications) do
					if (v == trigger.clanID) then
						mainUI.Clans.clanApplications[i] = nil
						break
					end
				end			
			end
		end
		-- printr(mainUI.Clans.clanApplications)
		UpdateInvites()
	end, false, nil, 'added', 'clanID')

	function mainUI.Clans.ClearAllInvitations()
		mainUI.Clans.clanInvites = nil
		mainUI.Clans.clanApplications = nil	
		UpdateInvites()
	end
	
	-- println('RegisterClansFinder 2/2')
	
end

RegisterClansFinder(object)