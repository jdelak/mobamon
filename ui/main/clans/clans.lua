local interface = object

Windows = Windows or {}
Windows.state 			= Windows.state  		or {}
Windows.data 			= Windows.data  		or {}
Windows.data.drag 		= Windows.data.drag  	or {}
Windows.Clans = nil

mainUI = mainUI or {}
mainUI.Clans = {}
mainUI.Clans.init = false
mainUI.Clans.initInClan = false
mainUI.Clans.windowExists = false
-- mainUI.Clans.mode = 'launcher'
mainUI.Clans.rankEnum = {NONE = -1, MEMBER = 0, OFFICER = 1, COOWNER = 2, OWNER = 3}

mainUI.Clans.Regions = {
	{'NA'},  -- NO REGIONS SEARCH THIS PHRASE
	-- {'SA'},
	-- {'EU'},
	-- {'AFR'},
	-- {'CIS'},
	-- {'ME'},
	-- {'SEA'},
	-- {'OCE'},
	-- {'ASIA'},
}

local function RegisterClans(object)
	
	-- println('RegisterClans 1/2')
	
	local chatUnreadMessageTrigger = LuaTrigger.GetTrigger('ChatUnreadMessageTrigger') or LuaTrigger.CreateCustomTrigger('ChatUnreadMessageTrigger', {
			{ name	=   'updatedChannel',		type	= 'string'},	
		}
	)	
	
	local clans_parent 							= interface:GetWidget('clans_parent')
	local clans_window_title 					= interface:GetWidget('clans_window_title')
	local clans_window_topic 					= interface:GetWidget('clans_window_topic')
	local clans_window_window_button 			= interface:GetWidget('clans_window_window_button')
	local clans_view_clan_btn2 					= interface:GetWidget('clans_view_clan_btn2')
	local clans_prizes_club_seals_parent 		= interface:GetWidget('clans_prizes_club_seals_parent')
	local clans_topleft_prizes 					= interface:GetWidget('clans_topleft_prizes')
	local clans_topleft_clubhouse 				= interface:GetWidget('clans_topleft_clubhouse')
	
	local clansWindowWidth = '800s'
	local clansWindowHeight = '500s'
	local clansWindowX = ((0 + interface:GetXFromString('20s')) + (1 * interface:GetXFromString('20s'))) .. 's'
	local clansWindowY = (((0 + interface:GetHeight()) - interface:GetHeightFromString(clansWindowHeight)) - interface:GetYFromString('40s')) .. 's'
	
	local channelID = 'Clan'
	local channelName = 'Clan'
	local chatType = 'channel'
	local lastTitle	
	
	function mainUI.Clans.SpawnWindow()
		
		mainUI.Clans.windowExists = true
		
		local width 							= interface:GetWidthFromString(clansWindowWidth)
		local height 							= interface:GetHeightFromString(clansWindowHeight)
		local x 								= interface:GetXFromString(clansWindowX)
		local y 								= interface:GetYFromString(clansWindowY)
		
		local settingsChannelID = 'Clan'
		
		if (mainUI.savedLocally) and (mainUI.savedLocally.chatSettings) and (mainUI.savedLocally.chatSettings.channel) and (not mainUI.savedLocally.chatSettings.channel[settingsChannelID]) then
			for i,v in pairs(mainUI.savedLocally.chatSettings) do
				for i2,v2 in pairs(v) do
					if (v2) and (v2.channelName) and (v2.channelName == channelName) then
						settingsChannelID = i2
						break
					end
				end
			end
		end
		
		if (mainUI.savedLocally) and (mainUI.savedLocally.chatSettings) and (mainUI.savedLocally.chatSettings.channel) and (mainUI.savedLocally.chatSettings.channel[settingsChannelID]) and (mainUI.savedLocally.chatSettings.channel[settingsChannelID].windowHeight) then
			height = mainUI.savedLocally.chatSettings.channel[settingsChannelID].windowHeight
		end	
		if (mainUI.savedLocally) and (mainUI.savedLocally.chatSettings) and (mainUI.savedLocally.chatSettings.channel) and (mainUI.savedLocally.chatSettings.channel[settingsChannelID]) and (mainUI.savedLocally.chatSettings.channel[settingsChannelID].windowWidth) then
			width = mainUI.savedLocally.chatSettings.channel[settingsChannelID].windowWidth
		end		
		if (mainUI.savedLocally) and (mainUI.savedLocally.chatSettings) and (mainUI.savedLocally.chatSettings.channel) and (mainUI.savedLocally.chatSettings.channel[settingsChannelID]) and (mainUI.savedLocally.chatSettings.channel[settingsChannelID].windowX) then
			x = mainUI.savedLocally.chatSettings.channel[settingsChannelID].windowX
		end		
		if (mainUI.savedLocally) and (mainUI.savedLocally.chatSettings) and (mainUI.savedLocally.chatSettings.channel) and (mainUI.savedLocally.chatSettings.channel[settingsChannelID]) and (mainUI.savedLocally.chatSettings.channel[settingsChannelID].windowY) then
			y = mainUI.savedLocally.chatSettings.channel[settingsChannelID].windowY
		end		

		local isPositionIsValid = false
		for _, v in pairs(System.GetAllMonitorRects()) do
			if (((interface:GetXFromString(x)) + interface:GetWidthFromString(width)) <= (v.left + v.right)) 
			and (((interface:GetXFromString(x))) >= (v.left)) 
			and (((interface:GetYFromString(y))) >= (v.top))
			and (((interface:GetYFromString(y)) + interface:GetHeightFromString(height)) <= (v.top + v.bottom)) then
				isPositionIsValid = true
			end
		end		

		if (not isPositionIsValid) then
			width 							= interface:GetWidthFromString(clansWindowWidth)
			height 							= interface:GetHeightFromString(clansWindowHeight)
			x 								= interface:GetXFromString(clansWindowX)
			y 								= interface:GetYFromString(clansWindowY)		
		end			
		
		Windows.Clans = Window.New(
			interface:GetXFromString(x),
			interface:GetYFromString(y),
			interface:GetWidthFromString(width),
			interface:GetHeightFromString(height),
			{
				Window.BORDERLESS,
				Window.THREADED,
				Window.COMPOSITE,
				Window.RESIZABLE,
				-- Window.CENTER,
				-- Window.HIDDEN,
				Window.POSITION,
			},
			"/ui/main/clans/clans_window.interface",
			Translate('window_name_brawl_club')
		)
		
		Windows.Chat = Windows.Chat or {}
		Windows.Chat.Channel = Windows.Chat.Channel or {}
		Windows.Chat.Channel['Clan'] = Windows.Clans
		
		Windows.Clans:SetCloseCallback(function()
			ChatClient.ForceInterfaceUpdate()
			RecalculateFooterWidgets()	
			if (mainUI and mainUI.chatManager and mainUI.chatManager.channelAtFrontId and mainUI.chatManager.channelAtFrontId == 'Clan') then
				mainUI.chatManager.channelAtFrontId = '-1'
			end				
		end)		

		Windows.Clans:SetSizingBounds((interface:GetWidthFromString(clansWindowWidth) * 0.5), (interface:GetHeightFromString(clansWindowHeight) * 0.5), (interface:GetWidthFromString(clansWindowWidth) * 2.5), (interface:GetHeightFromString(clansWindowHeight) * 2.5))

	end
	
	function mainUI.Clans.ShowWindow()
		if (Windows.Clans) then
			Windows.Clans:Restore()	
			Windows.Clans:MakeFrontActiveWindow()
			if (interface) and (interface:IsValid()) and (interface:GetWidget('main_footer_chat_tab_' .. chatType .. channelID .. '_4')) and (interface:GetWidget('main_footer_chat_tab_' .. chatType .. channelID .. '_4'):IsValid()) then
				interface:GetWidget('main_footer_chat_tab_' .. chatType .. channelID .. '_4'):SetTexture('/ui/main/footer/textures/message_bubble_focus.tga')
			end
			mainUI.chatManager.channelAtFrontId = channelID
		end
	end
	
	function mainUI.Clans.HideWindow()
		if (Windows.Clans) then
			Windows.Clans:Hide(true)	
		end
	end
	
	function mainUI.Clans.ToggleMode()
		
		if (not GetCvarBool('host_islauncher')) then
			-- println('^r Clan UpdateClanMemberlist denied because host_islauncher is : ' .. tostring(host_islauncher))
			return
		end			

		mainUI.savedLocally = mainUI.savedLocally or {}
		mainUI.Clans.mode = mainUI.Clans.mode or mainUI.savedLocally.clansMode or 'launcher'
		
		if (mainUI.Clans.mode == 'launcher') then
			mainUI.Clans.mode = 'window'
		else
			mainUI.Clans.mode = 'launcher'
		end
		
		local clans_parent = interface:GetWidget('clans_parent')
		
		local trigger = LuaTrigger.GetTrigger('ChatClanInfo')
		if ((trigger) and (trigger.id == '' or trigger.id == '0.000')) then
			mainUI.Clans.mode = 'launcher'
		end
		
		if (mainUI.Clans.mode == 'launcher') then
			mainUI.Clans.HideWindow()
			clans_parent:SetVisible(1)
		elseif (mainUI.Clans.mode == 'window') then
			if (not mainUI.Clans.windowExists) then
				mainUI.Clans.SpawnWindow()
			end
			mainUI.Clans.ShowWindow()
			clans_parent:SetVisible(0)
		end	
		
		 mainUI.savedLocally.clansMode = mainUI.Clans.mode
		 SaveState()
		 
		local channelID = 'Clan'
		local chatUnreadMessageTrigger = LuaTrigger.GetTrigger('ChatUnreadMessageTrigger')
		mainUI.chatManager = mainUI.chatManager or {}
		mainUI.chatManager.unreadMessages = mainUI.chatManager.unreadMessages or {}
		mainUI.chatManager.unreadMessages[tostring(channelID)] = 0
		mainUI.chatManager.channelAtFrontId = channelID
		chatUnreadMessageTrigger.updatedChannel = '-1'
		mainUI.chatManager.lastActiveChannelID = channelID
		chatUnreadMessageTrigger:Trigger(true)		 
		 
	end
	
	interface:GetWidget('clans_window_window_button'):SetCallback('onclick', function(widget)
		mainUI.Clans.ToggleMode()
	end)
	
	local function UpdateUnreadCount()
		local windowInterface = Windows.Clans:GetActiveInterface()
		if (windowInterface) then
			if (mainUI.chatManager) and (mainUI.chatManager.unreadMessages) and (mainUI.chatManager.unreadMessages[tostring(channelID)]) and (mainUI.chatManager.unreadMessages[tostring(channelID)] > 0) then
				if (mainUI.chatManager.unreadMessages[tostring(channelID)] >= 9) then
					mainUI.chatManager.unreadMessages[tostring(channelID)] = 9
				end
				if (lastTitle == nil) or (lastTitle ~= '[+' .. mainUI.chatManager.unreadMessages[tostring(channelID)] .. '] ' .. Translate(channelName)) then
					windowInterface:GetWindow():SetWindowTitle('[+' .. mainUI.chatManager.unreadMessages[tostring(channelID)] .. '] ' .. Translate(channelName))
				end
				lastTitle = '[+' .. mainUI.chatManager.unreadMessages[tostring(channelID)] .. '] ' .. Translate(channelName)
			else
				if (lastTitle == nil) or (lastTitle ~= Translate(channelName)) then
					windowInterface:GetWindow():SetWindowTitle(Translate(channelName))
				end
				lastTitle = Translate(channelName)
			end	
		end
	end
	
	local function FocusChatWindow(self)
		local windowInterface = Windows.Clans:GetActiveInterface()
		if windowInterface and windowInterface:GetWidget('clans_window_parent') and windowInterface:GetWidget('clans_window_parent'):IsVisible() then
			windowInterface:GetWidget('clans_window_parent'):BringToFront()
			windowInterface:GetWidget('clans_window_input'):SetFocus(true)
			mainUI.chatManager = mainUI.chatManager or {}
			mainUI.chatManager.unreadMessages = mainUI.chatManager.unreadMessages or {}
			mainUI.chatManager.unreadMessages[tostring(channelID)] = 0
			mainUI.chatManager.channelAtFrontId = channelID
			mainUI.chatManager.lastActiveChannelID = channelID	
			chatUnreadMessageTrigger.updatedChannel = '-1'
			chatUnreadMessageTrigger:Trigger(false)		
			UpdateUnreadCount()
		end
	end		

	function mainUI.Clans.Toggle(alwaysOpen, alwaysClose)
		
		if (not GetCvarBool('host_islauncher')) then
			-- println('^r Clan UpdateClanMemberlist denied because host_islauncher is : ' .. tostring(host_islauncher))
			return
		end			
		
		if (mainUI) and  (mainUI.savedLocally) and  (mainUI.savedLocally.adaptiveTraining) and (mainUI.savedLocally.adaptiveTraining.featureList) and (mainUI.savedLocally.adaptiveTraining.featureList) then
			mainUI.AdaptiveTraining.RecordViewInstanceByFeatureName('clans')
			mainUI.AdaptiveTraining.RecordUtilisationInstanceByFeatureName('clans')
		end		
		
		mainUI.savedLocally = mainUI.savedLocally or {}
		mainUI.Clans.mode = mainUI.Clans.mode or mainUI.savedLocally.clansMode or 'launcher'	
	
		local lastOpenState = mainUI.savedLocally.clansOpen
	
		local clans_parent = interface:GetWidget('clans_parent')
		
		local trigger = LuaTrigger.GetTrigger('ChatClanInfo')
		if ((trigger) and (trigger.id == '' or trigger.id == '0.000')) then
			mainUI.Clans.mode = 'launcher'
		end		
		
		if (mainUI.Clans.mode == 'launcher') then
			local isVisible = not clans_parent:IsVisible()
			if (alwaysOpen) then
				isVisible = true
			elseif (alwaysClose) then
				isVisible = false
			end
			if (interface) and (interface:IsValid()) and (interface:GetWidget('main_footer_chat_tab_' .. chatType .. channelID .. '_4')) and (interface:GetWidget('main_footer_chat_tab_' .. chatType .. channelID .. '_4'):IsValid()) then
				if (isVisible) then
					interface:GetWidget('main_footer_chat_tab_' .. chatType .. channelID .. '_4'):SetTexture('/ui/main/footer/textures/message_bubble_focus.tga')
				else
					interface:GetWidget('main_footer_chat_tab_' .. chatType .. channelID .. '_4'):SetTexture('/ui/main/footer/textures/message_bubble.tga')
				end
			end
			clans_parent:SetVisible(isVisible)			
			if (Windows.Clans) then
				Windows.Clans:Hide()
			end
			mainUI.savedLocally.clansOpen = isVisible
			if (isVisible) then
				local channelID = 'Clan'
				local chatUnreadMessageTrigger = LuaTrigger.GetTrigger('ChatUnreadMessageTrigger')
				mainUI.chatManager = mainUI.chatManager or {}
				mainUI.chatManager.unreadMessages = mainUI.chatManager.unreadMessages or {}
				mainUI.chatManager.unreadMessages[tostring(channelID)] = 0
				mainUI.chatManager.channelAtFrontId = channelID
				chatUnreadMessageTrigger.updatedChannel = '-1'
				mainUI.chatManager.lastActiveChannelID = channelID
				chatUnreadMessageTrigger:Trigger(true)	
				mainUI.Clans.GetDefaultClanRegion()
				hideSpinnableWheel()
			else
				mainUI.chatManager = mainUI.chatManager or {}
				if (mainUI.chatManager.channelAtFrontId == 'Clan') then
					mainUI.chatManager.channelAtFrontId = '-1'
				end	
				local chatUnreadMessageTrigger = LuaTrigger.GetTrigger('ChatUnreadMessageTrigger')
				chatUnreadMessageTrigger.updatedChannel = '-1'
				chatUnreadMessageTrigger:Trigger(true)					
			end
		elseif (mainUI.Clans.mode == 'window') then
			clans_parent:SetVisible(0)
			
			if (Windows.Clans) then
				if (not Windows.Clans:IsVisible()) or (Windows.Clans:IsMinimized()) or (alwaysOpen) then		
					Windows.Clans:Restore()
					Windows.Clans:Show()
					if (Windows.Clans:IsBehindMainWindow() and (isWindowInLauncherBounds(Windows.Clans))) then
						Windows.Clans:MakeFrontActiveWindow()
					end
					FocusChatWindow(Windows.Clans)
					
					mainUI.chatManager.pinnedChannels[channelID] = true
					if (interface) and (interface:IsValid()) and (interface:GetWidget('main_footer_chat_tab_' .. chatType .. channelID .. '_4')) and (interface:GetWidget('main_footer_chat_tab_' .. chatType .. channelID .. '_4'):IsValid()) then
						interface:GetWidget('main_footer_chat_tab_' .. chatType .. channelID .. '_4'):SetTexture('/ui/main/footer/textures/message_bubble_focus.tga')
					end
	
					ChatClient.SetChannelPinned(channelID,true)
	
					-- sound_showChatChannel
					PlaySound('ui/sounds/social/sfx_chat_open.wav')
					
					mainUI.savedLocally.clansOpen = true
					mainUI.Clans.GetDefaultClanRegion()
					
					local channelID = 'Clan'
					local chatUnreadMessageTrigger = LuaTrigger.GetTrigger('ChatUnreadMessageTrigger')
					mainUI.chatManager = mainUI.chatManager or {}
					mainUI.chatManager.unreadMessages = mainUI.chatManager.unreadMessages or {}
					mainUI.chatManager.unreadMessages[tostring(channelID)] = 0
					mainUI.chatManager.channelAtFrontId = channelID
					mainUI.chatManager.lastActiveChannelID  = channelID
					chatUnreadMessageTrigger.updatedChannel = '-1'
					chatUnreadMessageTrigger:Trigger(true)						
					
				else
					if (Windows.Clans:HasFocus()) or (mainUI.chatManager.channelAtFrontId == channelID) or (isMinimise) then

						if Windows.Clans:HasOwner() then
							Windows.Clans:Hide() 
						else
							Windows.Clans:Minimize() 
						end					
						
						mainUI.chatManager.pinnedChannels[channelID] = false
						ChatClient.SetChannelPinned(channelID,false)
						if (interface) and (interface:IsValid()) and (interface:GetWidget('main_footer_chat_tab_' .. chatType .. channelID .. '_4')) and (interface:GetWidget('main_footer_chat_tab_' .. chatType .. channelID .. '_4'):IsValid()) then
							interface:GetWidget('main_footer_chat_tab_' .. chatType .. channelID .. '_4'):SetTexture('/ui/main/footer/textures/message_bubble.tga')
						end
						PlaySound('ui/sounds/social/sfx_chat_close.wav')			
						
						mainUI.savedLocally.clansOpen = false
						
						if (mainUI.chatManager.channelAtFrontId == 'Clan') then
							mainUI.chatManager.channelAtFrontId = '-1'
						end							
					else
						FocusChatWindow(Windows.Clans)
						
						mainUI.chatManager.pinnedChannels[channelID] = true
						if (interface) and (interface:IsValid()) and (interface:GetWidget('main_footer_chat_tab_' .. chatType .. channelID .. '_4')) and (interface:GetWidget('main_footer_chat_tab_' .. chatType .. channelID .. '_4'):IsValid()) then
							interface:GetWidget('main_footer_chat_tab_' .. chatType .. channelID .. '_4'):SetTexture('/ui/main/footer/textures/message_bubble_focus.tga')
						end
						mainUI.chatManager.channelAtFrontId = channelID		
						ChatClient.SetChannelPinned(channelID,true)
						local chatUnreadMessageTrigger = LuaTrigger.GetTrigger('ChatUnreadMessageTrigger')
						chatUnreadMessageTrigger.updatedChannel = '-1'
						chatUnreadMessageTrigger:Trigger(true)		
						PlaySound('ui/sounds/social/sfx_chat_open.wav')
						mainUI.chatManager.lastActiveChannelID  = channelID
						
						mainUI.savedLocally.clansOpen = true
						mainUI.Clans.GetDefaultClanRegion()
					end
				end		
			else
				if (not mainUI.Clans.windowExists) then
					mainUI.Clans.SpawnWindow()
					mainUI.Clans.ShowWindow()
					mainUI.savedLocally.clansOpen = true
					mainUI.Clans.GetDefaultClanRegion()
				end			
			end
		end
		if (lastOpenState ~= mainUI.savedLocally.clansOpen) then
			SaveState()
		end
	end

	local canAutoToggle = true
	function mainUI.Clans.CheckAutoToggle()
		local trigger = LuaTrigger.GetTrigger('ChatClanInfo')
		local chatTrigger = LuaTrigger.GetTrigger('ChatConnectionStatus')
		if (canAutoToggle) and (chatTrigger.authenticated and chatTrigger.connected) and (trigger) and (trigger.id) and (trigger.id ~= '') and (mainUI) and (mainUI.savedLocally) and (mainUI.savedLocally.clansOpen) and (mainUI.Clans) and (mainUI.Clans.Toggle) and (mainUI.savedLocally.clansMode == 'launcher') then
			canAutoToggle = false
			libThread.threadFunc(function()
				wait(1)
				mainUI.Clans.Toggle(true)
			end)
		end		
	end	
	
	local lastTab = ''
	function mainUI.Clans.SetTab(inTab)
		simpleTipGrowYUpdate(false)
		interface:GetWidget('clans_window_switcher'):SetVisible(0)
		interface:GetWidget('clans_view_clan_btndeckTabOn'):SetVisible(1)
		interface:GetWidget('clans_view_clan_btndeckTabOff'):SetVisible(0)
		interface:GetWidget('clans_view_clan_prizes_btndeckTabOn'):SetVisible(0)
		interface:GetWidget('clans_view_clan_prizes_btndeckTabOff'):SetVisible(1)
		if (inTab == 'clan_clubhouse') or (inTab == 'clan_management' and lastTab == 'clan_management') or (inTab == 'clan_ladder' and lastTab == 'clan_ladder') then
			inTab = 'clan_clubhouse'
			interface:GetWidget('clan_parent'):SetVisible(1)
			interface:GetWidget('clan_create'):SetVisible(0)
			interface:GetWidget('clans_topleft_clubhouse'):SetVisible(1)
			interface:GetWidget('clans_topleft_prizes'):SetVisible(0)
			interface:GetWidget('clan_finder'):SetVisible(0)
			interface:GetWidget('clans_right_container_memberlist'):SetVisible(1)
			interface:GetWidget('clans_right_container_management'):SlideX('100%', 200)	
			interface:GetWidget('clans_right_container_management'):FadeOut(500)	
			interface:GetWidget('clans_right_container_ladder'):SlideX('100%', 200)
			interface:GetWidget('clans_right_container_ladder'):FadeOut(500)
		elseif (inTab == 'clan_ladder') then
			interface:GetWidget('clan_parent'):SetVisible(1)
			interface:GetWidget('clan_create'):SetVisible(0)
			interface:GetWidget('clans_topleft_clubhouse'):SetVisible(1)
			interface:GetWidget('clans_topleft_prizes'):SetVisible(0)
			interface:GetWidget('clan_finder'):SetVisible(0)
			interface:GetWidget('clans_right_container_memberlist'):SetVisible(1)
			interface:GetWidget('clans_right_container_management'):SlideX('100%', 200)				
			interface:GetWidget('clans_right_container_management'):FadeOut(500)			
			interface:GetWidget('clans_right_container_ladder'):SlideX('0%', 200)
			interface:GetWidget('clans_right_container_ladder'):SetVisible(1)
		elseif (inTab == 'clan_prizes') then
			interface:GetWidget('clan_parent'):SetVisible(1)
			interface:GetWidget('clan_create'):SetVisible(0)
			interface:GetWidget('clans_topleft_clubhouse'):SetVisible(0)
			interface:GetWidget('clans_topleft_prizes'):SetVisible(1)
			interface:GetWidget('clan_finder'):SetVisible(0)
			interface:GetWidget('clans_right_container_memberlist'):SetVisible(1)
			interface:GetWidget('clans_right_container_management'):SlideX('100%', 200)
			interface:GetWidget('clans_right_container_management'):FadeOut(500)	
			interface:GetWidget('clans_right_container_ladder'):SlideX('100%', 200)		
			interface:GetWidget('clans_right_container_ladder'):FadeOut(500)	
			interface:GetWidget('clans_view_clan_btndeckTabOn'):SetVisible(0)
			interface:GetWidget('clans_view_clan_btndeckTabOff'):SetVisible(1)
			interface:GetWidget('clans_view_clan_prizes_btndeckTabOn'):SetVisible(1)
			interface:GetWidget('clans_view_clan_prizes_btndeckTabOff'):SetVisible(0)			
		elseif (inTab == 'clan_finder') then
			interface:GetWidget('clan_parent'):SetVisible(0)
			interface:GetWidget('clan_create'):SetVisible(0)
			interface:GetWidget('clans_topleft_clubhouse'):SetVisible(0)
			interface:GetWidget('clans_topleft_prizes'):SetVisible(0)			
			interface:GetWidget('clan_finder'):SetVisible(1)
			interface:GetWidget('clans_right_container_memberlist'):SetVisible(1)
			interface:GetWidget('clans_right_container_management'):SlideX('100%', 200)
			interface:GetWidget('clans_right_container_management'):FadeOut(500)	
			interface:GetWidget('clans_right_container_ladder'):SlideX('100%', 200)			
			interface:GetWidget('clans_right_container_ladder'):FadeOut(500)	
		elseif (inTab == 'clan_management') then
			interface:GetWidget('clan_parent'):SetVisible(1)
			interface:GetWidget('clan_create'):SetVisible(0)
			interface:GetWidget('clans_topleft_clubhouse'):SetVisible(1)
			interface:GetWidget('clans_topleft_prizes'):SetVisible(0)
			interface:GetWidget('clan_finder'):SetVisible(0)
			interface:GetWidget('clans_right_container_memberlist'):SetVisible(1)
			interface:GetWidget('clans_right_container_management'):SlideX('0%', 200)	
			interface:GetWidget('clans_right_container_management'):SetVisible(1)
			interface:GetWidget('clans_right_container_ladder'):SlideX('100%', 200)			
			interface:GetWidget('clans_right_container_ladder'):FadeOut(500)	
		elseif (inTab == 'clan_create') then
			interface:GetWidget('clan_parent'):SetVisible(0)
			interface:GetWidget('clan_create'):SetVisible(1)
			interface:GetWidget('clans_topleft_clubhouse'):SetVisible(0)
			interface:GetWidget('clans_topleft_prizes'):SetVisible(0)
			interface:GetWidget('clan_finder'):SetVisible(0)
			interface:GetWidget('clans_right_container_memberlist'):SetVisible(1)
			interface:GetWidget('clans_right_container_management'):SlideX('100%', 200)
			interface:GetWidget('clans_right_container_management'):FadeOut(500)	
			interface:GetWidget('clans_right_container_ladder'):SlideX('100%', 200)
			interface:GetWidget('clans_right_container_ladder'):FadeOut(500)	
		end
		lastTab = inTab
	end
	
	interface:GetWidget('clans_parent_minimise_button'):SetCallback('onclick', function(widget)
		mainUI.Clans.Toggle()
	end)

	function mainUI.Clans.PromptLeaveClan()
		local trigger = LuaTrigger.GetTrigger('ChatClanInfo')
		local myChatClientInfo = (GetMyChatClientInfo and GetMyChatClientInfo())
		
		local extraString = ''
		if (myChatClientInfo) and (myChatClientInfo.clanRank) and (myChatClientInfo.clanRank == mainUI.Clans.rankEnum.OWNER) then
			extraString = '\n' .. Translate('clans_leave_club_extra_owner')
		end
		
		GenericDialogAutoSize(
			'clans_leave_club', '', Translate('clans_leave_club_desc', 'value', trigger.name) .. extraString, 'clans_leave_club_leave', 'general_cancel',
				function() ChatClient.LeaveClan() end,
				function() end
		)		
	end
	
	local function Init(object, clanID)
		if (clanID and clanID ~= '' and clanID ~= '0.000') then
			mainUI.Clans.SetTab('clan_clubhouse')
		else
			mainUI.Clans.SetTab('clan_finder')
		end
	end

	local defaultRegionInit = false
	function mainUI.Clans.GetDefaultClanRegion(force)
		if (not defaultRegionInit) or (force) then
			defaultRegionInit = true
			
			local function UpdateDefaultClanRegions(region, isCache)
				-- println('UpdateDefaultClanRegions ' .. tostring(region) .. ' ' .. tostring(isCache))
				local clan_create_region_combobox = interface:GetWidget('clan_create_region_combobox')
				local clans_finder_region_combobox = interface:GetWidget('clans_finder_region_combobox')
				clan_create_region_combobox:SetSelectedItemByValue(region)
				clans_finder_region_combobox:SetSelectedItemByValue(region)
				clan_create_region_combobox:SetVisible(0) -- NO REGIONS SEARCH THIS PHRASE
				clans_finder_region_combobox:SetVisible(0) -- NO REGIONS SEARCH THIS PHRASE
			end

			UpdateDefaultClanRegions('NA', true)  -- NO REGIONS SEARCH THIS PHRASE
			
			-- local defaultRegion  -- NO REGIONS SEARCH THIS PHRASE
			-- if (mainUI.savedLocally) and (mainUI.savedLocally.defaultClanRegion) then
				-- UpdateDefaultClanRegions(mainUI.savedLocally.defaultClanRegion, true)
			-- else
				-- local successFunction = function (request)
					-- local responseData = request:GetBody()
					-- if responseData == nil then
						-- SevereError('GetDefaultClanRegion - no data', 'general_ok', '', nil, nil, false)
						-- return false
					-- else
						-- if (responseData) and (responseData.body) then
							-- UpdateDefaultClanRegions(responseData.body, false)
							-- mainUI.savedLocally = mainUI.savedLocally or {}
							-- mainUI.savedLocally.defaultClanRegion = responseData.body
							-- SaveState()
						-- end
					-- end
				-- end
				-- Strife_Web_Requests:GetDefaultClanRegion(successFunction)
			-- end
		end
	end	
	
	clans_parent:RegisterWatchLua('ChatConnectionStatus', function(widget, trigger)
		mainUI.Clans.CheckAutoToggle()
	end)
	
	clans_parent:RegisterWatchLua('ChatClanInfo', function(widget, trigger)
		mainUI.Clans.CheckAutoToggle()
		if (trigger.id == '' or trigger.id == '0.000') and (not mainUI.Clans.init) then
			mainUI.Clans.init = true
			mainUI.Clans.initInClan = false
			Init(widget, trigger.id)
			if (mainUI.Clans.mode == 'window') then
				mainUI.Clans.ToggleMode()
			end			
		elseif (trigger.id ~= '' and trigger.id ~= '0.000') and (not mainUI.Clans.initInClan) then
			mainUI.Clans.ClearAllInvitations()
			mainUI.Clans.initInClan = true
			mainUI.Clans.init = false
			Init(widget, trigger.id)
			local memberTriggerName = GetClientInfoTriggerName(GetIdentID())
			if (memberTriggerName) then
				local function UpdateVoiceJoinButton()
					local PartyStatus = LuaTrigger.GetTrigger('PartyStatus')
					local memberTrigger = GetClientInfoTrigger(GetIdentID())
					if (PartyStatus.numPlayersInParty > 1) then
						interface:GetWidget('clans_window_voip_join_button'):SetCallback('onclick', function(widget)

						end)
						interface:GetWidget('clans_window_voip_join_button'):SetEnabled(0)
						interface:GetWidget('clans_window_voip_join_button_parent'):SetVisible(1)
						interface:GetWidget('clans_window_voip_leave_button_parent'):SetVisible(0)				
					elseif (memberTrigger.clanVoiceChannel < 0) then
						interface:GetWidget('clans_window_voip_join_button'):SetCallback('onclick', function(widget)
							ChatClient.JoinClanVoiceChannel(0)
						end)
						interface:GetWidget('clans_window_voip_join_button'):SetEnabled(1)
						interface:GetWidget('clans_window_voip_join_button_parent'):SetVisible(1)
						interface:GetWidget('clans_window_voip_leave_button_parent'):SetVisible(0)
					else
						interface:GetWidget('clans_window_voip_leave_button'):SetCallback('onclick', function(widget)
							ChatClient.LeaveClanVoiceChannel()
						end)		
						interface:GetWidget('clans_window_voip_join_button'):SetEnabled(1)
						interface:GetWidget('clans_window_voip_join_button_parent'):SetVisible(0)
						interface:GetWidget('clans_window_voip_leave_button_parent'):SetVisible(1)
					end
					if (mainUI.Clans) and (mainUI.Clans.Window) and (mainUI.Clans.Window.UpdateVoice) then
						mainUI.Clans.Window.UpdateVoice(GetMyChatClientInfo and GetMyChatClientInfo())		
					end
				end
				
				interface:GetWidget('clans_window_voip_join_button_parent'):UnregisterWatchLua('PartyStatus')
				interface:GetWidget('clans_window_voip_join_button_parent'):RegisterWatchLua('PartyStatus', function(widget, trigger)
					UpdateVoiceJoinButton()
				end, false, nil, 'numPlayersInParty')
				
				interface:GetWidget('clans_window_voip_join_button_parent'):UnregisterWatchLua(memberTriggerName)
				interface:GetWidget('clans_window_voip_join_button_parent'):RegisterWatchLua(memberTriggerName, function(widget, trigger)
					UpdateVoiceJoinButton()
				end, false, nil, 'clanVoiceChannel')
				
				UpdateVoiceJoinButton()

				local function UpdateChatInputCombobox()
					local memberTrigger = GetClientInfoTrigger(GetIdentID())
					if (memberTrigger) then
						interface:GetWidget('clans_window_input_combobox'):SetVisible(memberTrigger.clanRank >= mainUI.Clans.rankEnum.OFFICER)
						interface:GetWidget('clans_window_input'):SetWidth(((memberTrigger.clanRank >= mainUI.Clans.rankEnum.OFFICER) and '-190s') or '-85s')
					else
						interface:GetWidget('clans_window_input'):SetWidth('-85s')
						interface:GetWidget('clans_window_input_combobox'):SetVisible(0)
					end
				end
				interface:GetWidget('clans_window_input_combobox'):UnregisterWatchLua(memberTriggerName)
				interface:GetWidget('clans_window_input_combobox'):RegisterWatchLua(memberTriggerName, function(widget, trigger)
					UpdateChatInputCombobox()
				end, false, nil, 'clanRank')
				UpdateChatInputCombobox()
			end
		end
	end, false, nil, 'id') -- id, name, tag, description, language, region, tags, autoAcceptMembers, minRating, title

	clans_window_title:RegisterWatchLua('ChatClanInfo', function(widget, trigger)
		local name = trigger.name
		if (name ~= '') then
			if (GetCvarBool('ui_devClans')) then
				widget:SetText(trigger.id .. ' ' .. name)
			else
				widget:SetText(name)
			end
			if (string.len(name) <= 25) then
				widget:SetFont('maindyn_36')
			elseif (string.len(name) <= 30) then
				widget:SetFont('maindyn_28')
			else
				widget:SetFont('maindyn_26')
			end			
		else
			widget:SetText(Translate('clans_view_my_club'))
			widget:SetFont('maindyn_36')
		end
	end, false, nil, 'name', 'id')
	
	clans_view_clan_btn2:RegisterWatchLua('ChatClanInfo', function(widget, trigger)
		widget:SetEnabled(trigger.id ~= '' and trigger.id ~= '0.000')
	end, false, nil, 'id')
	
	-- clans_window_window_button:RegisterWatchLua('ChatClanInfo', function(widget, trigger)
		-- widget:SetVisible(trigger.id ~= '' and trigger.id ~= '0.000')
	-- end, false, nil, 'id')
	clans_window_window_button:SetVisible(0)
	
	interface:GetWidget('clans_window_voip_join_button_parent'):SetVisible(1)
	interface:GetWidget('clans_window_voip_leave_button_parent'):SetVisible(0)
	interface:GetWidget('clans_window_voip_join_button'):SetCallback('onclick', function(widget)
		ChatClient.JoinClanVoiceChannel(0)
	end)	

	clans_window_topic:RegisterWatchLua('ChatClanInfo', function(widget, trigger)
		clans_window_topic:SetText(trigger.topic)
		if (string.len(trigger.topic) <= 60) then
			clans_window_topic:SetFont('maindyn_22')
		elseif (string.len(trigger.topic) <= 80) then
			clans_window_topic:SetFont('maindyn_18')
		else
			clans_window_topic:SetFont('maindyn_14')
		end
		clans_window_title:SetY((trigger.topic ~= '' and '-10s') or ('0s'))
	end, false, nil, 'topic')	

	local function UpdateClanPrizes()
		local trigger = LuaTrigger.GetTrigger('ChatClanInfo')
	
		if (trigger and trigger.id and trigger.id ~= '') then
	
			local clanWeeklySealRequirements = {} -- BoardDatabase.GetClanWeeklySealRequirements()
			local clanWeeklySealRequirementsSorted = {}

			local clanSeals							= 0 -- tonumber(trigger.minRating or -1) or -1
			
			for i,v in pairs(clanWeeklySealRequirements) do
				table.insert(clanWeeklySealRequirementsSorted, v)
			end
			
			table.sort(clanWeeklySealRequirementsSorted, function(a,b) 
				if (a.seals) and (b.seals) and tonumber(a.seals) and tonumber(b.seals) then
					return tonumber(a.seals) < tonumber(b.seals)
				else
					return false
				end
			end)
			
			local clanSealsForSilverSpin 	= tonumber((clanWeeklySealRequirementsSorted[1] and clanWeeklySealRequirementsSorted[1].seals) or -1)
			local silverSpins				= tonumber((clanWeeklySealRequirementsSorted[1] and clanWeeklySealRequirementsSorted[1].coins) or -1)
			local clanSealsForGoldSpin 		= tonumber((clanWeeklySealRequirementsSorted[2] and clanWeeklySealRequirementsSorted[2].seals) or -1)
			local goldSpins					= tonumber((clanWeeklySealRequirementsSorted[2] and clanWeeklySealRequirementsSorted[2].coins) or -1)
			local clanSealsForDiamondSpin 	= tonumber((clanWeeklySealRequirementsSorted[3] and clanWeeklySealRequirementsSorted[3].seals) or -1)
			local diamondSpins				= tonumber((clanWeeklySealRequirementsSorted[3] and clanWeeklySealRequirementsSorted[3].coins) or -1)
			
			local highestPrizeValue = 0
			highestPrizeValue = math.max(highestPrizeValue, clanSealsForDiamondSpin)
			highestPrizeValue = math.max(highestPrizeValue, clanSealsForGoldSpin)
			highestPrizeValue = math.max(highestPrizeValue, clanSealsForSilverSpin)
			
			if (clanSealsForDiamondSpin <= 0) or (clanSealsForGoldSpin <= 0) or (clanSealsForSilverSpin <= 0) or (highestPrizeValue <= 0) or (clanSeals < 0) then
				-- println('^r Clan Prizes Error')
				-- println('highestPrizeValue ' .. tostring(highestPrizeValue))
				-- println('clanSeals ' .. tostring(clanSeals))
				-- println('clanSealsForSilverSpin ' .. tostring(clanSealsForSilverSpin))
				-- println('clanSealsForGoldSpin ' .. tostring(clanSealsForGoldSpin))
				-- println('clanSealsForDiamondSpin ' .. tostring(clanSealsForDiamondSpin))
				interface:GetWidget('clans_view_clan_prizes_btndeckTabButton'):SetVisible(0)
			else
				interface:GetWidget('clans_view_clan_prizes_btndeckTabButton'):SetVisible(1)
				
				clanSeals 			 					= math.min(math.max(0, clanSeals), highestPrizeValue)
				highestPrizeValue 						= math.max(1, highestPrizeValue)
			
				local clans_prizes_club_seals_parent 			= interface:GetWidget('clans_prizes_club_seals_parent')
				local clans_prizes_club_seals_progress 			= interface:GetWidget('clans_prizes_club_seals_progress')
				local prize1 									= interface:GetWidget('clans_prizes_tier_marker_1')
				local prize2									= interface:GetWidget('clans_prizes_tier_marker_2')
				local prize3 									= interface:GetWidget('clans_prizes_tier_marker_3')
				local seals_needed3								= interface:GetWidget('3_clans_prizes_seals_needed')
				local seals_needed2 							= interface:GetWidget('2_clans_prizes_seals_needed')
				local seals_needed1 							= interface:GetWidget('1_clans_prizes_seals_needed')
				local spin_texture1 							= interface:GetWidget('1_clans_prizes_spin_texture')
				local spin_texture2 							= interface:GetWidget('2_clans_prizes_spin_texture')
				local spin_texture3 							= interface:GetWidget('3_clans_prizes_spin_texture')
				local spin_count1 								= interface:GetWidget('1_clans_prizes_spin_count')
				local spin_count2 								= interface:GetWidget('2_clans_prizes_spin_count')
				local spin_count3 								= interface:GetWidget('3_clans_prizes_spin_count')
				local clans_prizes_club_seals_current_lbl		= interface:GetWidget('clans_prizes_club_seals_current_lbl')
				
				local clans_prizes_seals_title_1				= interface:GetWidget('clans_prizes_seals_title_1')
				local clans_prizes_seals_title_2				= interface:GetWidget('clans_prizes_seals_title_2')
				local clans_prizes_seals_texture_1				= interface:GetWidget('clans_prizes_seals_texture_1')
				
				prize1:SetVisible(clanSeals < clanSealsForSilverSpin)
				prize2:SetVisible(clanSeals < clanSealsForGoldSpin)
				prize3:SetVisible(clanSeals < clanSealsForDiamondSpin)
				
				spin_texture1:SetTexture('/ui/main/clans/textures/prize_marker_bronze_spin.tga')
				spin_texture2:SetTexture('/ui/main/clans/textures/prize_marker_silver_spin.tga')
				spin_texture3:SetTexture('/ui/main/clans/textures/prize_marker_gold_spin.tga')
				
				spin_count1:SetText(silverSpins .. ' ' .. Translate('play_standardmode_boardspin'))
				spin_count2:SetText(goldSpins .. ' ' .. Translate('play_standardmode_boardspins'))
				spin_count3:SetText(diamondSpins .. ' ' .. Translate('play_standardmode_boardspins'))
				
				seals_needed1:SetText(clanSealsForSilverSpin)
				seals_needed2:SetText(clanSealsForGoldSpin)
				seals_needed3:SetText(clanSealsForDiamondSpin)
				
				clans_prizes_club_seals_current_lbl:SetText(clanSeals)
				clans_prizes_club_seals_progress:SetWidth( ((clanSeals / clanSealsForDiamondSpin) * 100) .. '%')
				
				local prize1Position = (clans_prizes_club_seals_parent:GetWidth() * (clanSealsForSilverSpin / highestPrizeValue) ) - 32
				prize1:SetX(prize1Position .. 's')

				local prize2Position = (clans_prizes_club_seals_parent:GetWidth() * (clanSealsForGoldSpin / highestPrizeValue) ) - 32
				prize2:SetX(prize2Position .. 's')
				
				if (clanSeals < clanSealsForSilverSpin) then
					clans_prizes_seals_title_1:SetText(Translate('clans_earning_silver_spins'))
					clans_prizes_seals_texture_1:SetTexture('/ui/main/shared/textures/spin/spin_ani0000.tga')
					clans_prizes_seals_title_2:SetText(Translate('clans_earning_spin_more_seals_x', 'value', (clanSealsForSilverSpin - clanSeals)))
				elseif (clanSeals < clanSealsForGoldSpin) then
					clans_prizes_seals_title_1:SetText(Translate('clans_earning_gold_spins'))
					clans_prizes_seals_texture_1:SetTexture('/ui/main/shared/textures/spin/spin_ani_silver0000.tga')
					clans_prizes_seals_title_2:SetText(Translate('clans_earning_spin_more_seals_x', 'value', (clanSealsForGoldSpin - clanSeals)))
				elseif (clanSeals < clanSealsForDiamondSpin) then
					clans_prizes_seals_title_1:SetText(Translate('clans_earning_diamond_spins'))
					clans_prizes_seals_texture_1:SetTexture('/ui/main/shared/textures/spin/spin_ani_gold0000.tga')
					clans_prizes_seals_title_2:SetText(Translate('clans_earning_spin_more_seals_x', 'value', (clanSealsForDiamondSpin - clanSeals)))
				else
					clans_prizes_seals_title_1:SetText(Translate('clans_earning_diamond_spin_earned'))
					clans_prizes_seals_texture_1:SetTexture('$invis')
					clans_prizes_seals_title_2:SetText(Translate('clans_earning_spin_nextweek'))
				end
			end	
		end
	end
	
	clans_topleft_clubhouse:RegisterWatchLua('ChatClanInfo', function(widget, trigger)
		UpdateClanPrizes()
	end, false, nil, 'id') -- , 'minRating'
	
	clans_topleft_clubhouse:SetCallback('onshow', function(widget)
		UpdateClanPrizes()
	end)
	
	clans_parent:RegisterWatchLua('newPlayerExperience', function(widget, trigger)
		local npeComplete = (NewPlayerExperience.trigger.tutorialProgress >= NPE_PROGRESS_TUTORIALCOMPLETE) or (NewPlayerExperience.trigger.tutorialComplete) or (not NewPlayerExperience.enabled)
		interface:GetWidget('clans_parent_npe_blocker'):SetVisible(not npeComplete)
		local channelID = 'Clan'
		if (interface) and (interface:IsValid()) and (interface:GetWidget('main_footer_chat_tab_' .. 'channel' .. channelID)) and (interface:GetWidget('main_footer_chat_tab_' .. 'channel' .. channelID):IsValid()) then
			if (npeComplete) then
				interface:GetWidget('main_footer_chat_tab_' .. 'channel' .. channelID):SetVisible(1)
			else
				interface:GetWidget('main_footer_chat_tab_' .. 'channel' .. channelID):SetVisible(0)
			end
		end
		
	end)

	
	libThread.threadFunc(function()
		wait(1)		
		local trigger = LuaTrigger.GetTrigger('ChatClanInfo')
		trigger:Trigger(true)
		if (GetCvarBool('ui_devClans2')) then
			wait(1000)
			mainUI.Clans.Toggle() -- RMM
		end
	end)
	
	-- println('RegisterClans 2/2')
	
end

RegisterClans(object)