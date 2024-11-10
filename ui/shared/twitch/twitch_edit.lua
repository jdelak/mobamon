TwitchEdit = TwitchEdit or {}
mainUI 										= mainUI 									or {}
mainUI.savedLocally 						= mainUI.savedLocally 						or {}
mainUI.savedLocally.TwitchEdit				= mainUI.savedLocally.TwitchEdit 			or {}
mainUI.savedLocally.TwitchEdit.settings		= mainUI.savedLocally.TwitchEdit.settings 	or {}
mainUI.savedLocally.TwitchEdit.widgets		= mainUI.savedLocally.TwitchEdit.widgets 	or {}

local object = object

TwitchEdit.stateTrigger = LuaTrigger.GetTrigger('TwitchStateTrigger') or LuaTrigger.CreateCustomTrigger('TwitchStateTrigger', {
	{ name	=   'panelOpen',			type	= 'boolean'},
	{ name	=   'overlayVisible',		type	= 'boolean'},
	{ name	=   'unsavedChanges',		type	= 'boolean'},
	{ name	=   'panelState',			type	= 'string'},
})
TwitchEdit.statusTrigger 				= LuaTrigger.GetTrigger('TwitchStatus')
TwitchEdit.webCamDevicesTrigger 		= LuaTrigger.GetTrigger('TwitchWebCamDevices')
TwitchEdit.ingestServersTrigger 		= LuaTrigger.GetTrigger('TwitchIngestServers')

local function Register(object)

	local twitchPanelWasOpen		= false
	local twitchMessageCount		= 0
	local twitchPanel 				= object:GetWidget('Twitch_Panel')
	local twitchPanelLogin 			= object:GetWidget('Twitch_Login_Holder')
	local twitchPanelLogged 		= object:GetWidget('Twitch_Logged_Holder')	

	local Twitch_Logout_Send_Button 			= object:GetWidget('Twitch_Logout_Send_Button')
	local Twitch_Login_Send_Button 				= object:GetWidget('Twitch_Login_Send_Button')
	local Twitch_Login_Form_Username 			= object:GetWidget('Twitch_Login_Form_Username')
	local Twitch_Login_Form_Password 			= object:GetWidget('Twitch_Login_Form_Password')
	local Twitch_Login_Form_Password_coverup 	= object:GetWidget('Twitch_Login_Form_Password_coverup')
	local Twitch_Login_Form_Username_Coverup 	= object:GetWidget('Twitch_Login_Form_Username_Coverup')
	local Twitch_Broadcast_Btn					= object:GetWidget('Twitch_Logged_Broadcast')
	local Twitch_Broadcast_Btn_Label			= object:GetWidget('Twitch_Logged_Broadcast_label')
	local twitch_edit_center_screen_announce	= object:GetWidget('twitch_edit_center_screen_announce')
	local Twitch_Logged_Username				= object:GetWidget('Twitch_Logged_Username')
	local Twitch_Logged_ViewCount				= object:GetWidget('Twitch_Logged_ViewCount')
	local Twitch_Logged_ViewCount2				= object:GetWidget('Twitch_Logged_ViewCount2')
	local Twitch_Logged_FollowerCount			= object:GetWidget('Twitch_Logged_FollowerCount')
	local Twitch_Logged_FollowerCount2			= object:GetWidget('Twitch_Logged_FollowerCount2')
	local Twitch_Logged_Title					= object:GetWidget('Twitch_Logged_Title')
	local Twitch_Logged_Settings				= object:GetWidget('Twitch_Logged_Settings')
	local Twitch_Toggle_Webcam					= object:GetWidget('Twitch_Toggle_Webcam')	
	local Twitch_Toggle_Webcam_Label			= object:GetWidget('Twitch_Toggle_Webcam_label')		
	local Twitch_Toggle_Chat					= object:GetWidget('Twitch_Toggle_Chat')	
	local Twitch_Toggle_Chat_Label				= object:GetWidget('Twitch_Toggle_Chat_label')	
	local twitch_settings_webcam_combobox		= object:GetWidget('twitch_settings_webcam_combobox')	
	local twitch_settings_capabilities_combobox	= object:GetWidget('twitch_settings_capabilities_combobox')	
	local twitch_settings_ingest_server_combobox = object:GetWidget('twitch_settings_ingest_server_combobox')	
	local Twitch_Logged_Status 					= object:GetWidget('Twitch_Logged_Status')	
	local Twitch_Logged_StatusType 				= object:GetWidget('Twitch_Logged_StatusType')	
	local Twitch_InGame_Stream_Notification 	= object:GetWidget('Twitch_InGame_Stream_Notification')	
	local Twitch_Overlays_Auto 					= object:GetWidget('Twitch_Overlays_Auto')	
	local Twitch_Overlays_Close 				= object:GetWidget('Twitch_Overlays_Close')	
	local twitch_settings_output_volume_slider  = object:GetWidget('twitch_settings_output_volume_slider')	
	local twitch_settings_output_volume_value_label  		= object:GetWidget('twitch_settings_output_volume_value_label')		
	local twitch_settings_output_bitrate_slider  			= object:GetWidget('twitch_settings_output_bitrate_slider')	
	local twitch_settings_output_bitrate_value_label  		= object:GetWidget('twitch_settings_output_bitrate_value_label')	
	local Twitch_InGame_Chat_Window_minimise_button  		= object:GetWidget('Twitch_InGame_Chat_Window_minimise_button')	
	local Twitch_InGame_Chat_Window_parent  				= object:GetWidget('Twitch_InGame_Chat_Window_parent')	
	local Twitch_InGame_Chat_Notification  					= object:GetWidget('Twitch_InGame_Chat_Notification')	
	local Twitch_InGame_Chat_Notification_label  			= object:GetWidget('Twitch_InGame_Chat_Notification_label')	
	local Twitch_InGame_Chat_Notification_icon  			= object:GetWidget('Twitch_InGame_Chat_Notification_icon')	

	local Twitch_Stream_Title 						= object:GetWidget('Twitch_Stream_Title')
	local Twitch_Stream_Title_input 				= object:GetWidget('Twitch_Stream_Title_input')
	local Twitch_Stream_Title_input_btn 			= object:GetWidget('Twitch_Stream_Title_input_btn')
	
	function TwitchEdit.ToggleLoginPanel()
		TwitchEdit.stateTrigger.panelOpen = not TwitchEdit.stateTrigger.panelOpen
		TwitchEdit.stateTrigger:Trigger(true)	
	end	
	
	function TwitchEdit.CoerceHeightToPercent(targetWidget, incValue)
		local value = targetWidget:GetHeightFromString(incValue)
		value = ((value / GetScreenHeight()) * 100) .. '%'
		return value
	end
	
	function TwitchEdit.CoerceWidthToPercent(targetWidget, incValue)
		local value = targetWidget:GetWidthFromString(incValue)
		value = ((value / GetScreenWidth()) * 100) .. '%'
		return value
	end	
	
	function TwitchEdit.ConvertHeightPercentToPixels(incValue)
		local value = object:GetHeightFromString(incValue)
		return value
	end
	
	function TwitchEdit.ConvertWidthPercentToPixels(incValue)
		local value = object:GetWidthFromString(incValue)
		return value
	end		

	Twitch_Stream_Title_input_btn:SetCallback('onclick', function(widget)
		Twitch.SetStreamTitle(Twitch_Stream_Title_input:GetInputText())
		Twitch_Stream_Title:FadeOut(250)
	end)	
	
	local function updateTwitchMessageInGameIcon()
		if (twitchMessageCount == 0) then
			Twitch_InGame_Chat_Notification_label:SetText('')
			Twitch_InGame_Chat_Notification_icon:SetColor('white')
		else
			Twitch_InGame_Chat_Notification_label:SetText(twitchMessageCount)
			Twitch_InGame_Chat_Notification_icon:SetColor('1 .5 0 1')		
		end
	end	
	
	Twitch_InGame_Chat_Window_minimise_button:SetCallback('onclick', function(widget)
		Twitch_InGame_Chat_Window_parent:SetVisible(not Twitch_InGame_Chat_Window_parent:IsVisible())
	end)
	
	Twitch_InGame_Chat_Notification:SetCallback('onclick', function(widget)
		if (not Twitch_InGame_Chat_Window_parent:IsVisible()) then
			twitchMessageCount = 0
			Twitch_InGame_Chat_Window_parent:SetVisible(1)
		else
			Twitch_InGame_Chat_Window_parent:SetVisible(0)
		end
		updateTwitchMessageInGameIcon()		
	end)	
	
	Twitch_InGame_Chat_Notification:RegisterWatchLua('TwitchStatus', function(widget, trigger)
		local gamePhaseTrigger = LuaTrigger.GetTrigger('GamePhase')
		widget:SetVisible(trigger.chatConnected and (gamePhaseTrigger.gamePhase >= 4))
	end)	
	
	Twitch_InGame_Chat_Notification:RegisterWatchLua('GamePhase', function(widget, trigger)
		widget:SetVisible(TwitchEdit.statusTrigger.chatConnected and (trigger.gamePhase >= 4))
	end)	

	object:RegisterWatchLua('ChatReceivedChannelMessage', function(sourceWidget, trigger)
		if (trigger.channelID == 'Twitch') then
			if (Twitch_InGame_Chat_Window_parent:IsVisible()) then
				twitchMessageCount = 0
			else
				twitchMessageCount = twitchMessageCount + 1
			end
		end
		updateTwitchMessageInGameIcon()
	end)		
	
	-- twitch_settings_ingest_server_combobox:RegisterWatchLua('TwitchStatus', function(widget, trigger)
		-- if (trigger.ingestServer) and (trigger.ingestServer >= 0) and (trigger.ingestServer <= 1000000) then
			-- widget:SetSelectedItemByIndex(trigger.ingestServer, false)
		-- end
	-- end, false, nil, 'ingestServer')
	
	local function UpdateMemberlist(channelID)
		local channelID = tostring(channelID)
		
		if (not object:GetWidget('Twitch_InGame_Chat_Window_memberlist_listbox')) then
			return
		end
		
		local lastScrollValue = object:GetWidget('Twitch_InGame_Chat_Window_memberlist_listbox_vscroll'):GetValue()

		if (not TwitchEdit.memberlist) then
			return
		end

		local count = 0
		for identID, accountTable in pairs(TwitchEdit.memberlist) do
			
			if (object:GetWidget('Twitch_InGame_Chat_Window_memberlist_listbox'):HasListItem(accountTable.identID)) then
				-- they already exist
			else
				local chatNameColorPath = accountTable.chatNameColorPath
				if Empty(chatNameColorPath) then
					chatNameColorPath = 'white'
				end

				local accountIconPath = accountTable.accountIconPath
				if Empty(accountIconPath) then 
					accountIconPath = '/ui/shared/textures/user_icon.tga'
				end

				local playerName = accountTable.playerName

				object:GetWidget('Twitch_InGame_Chat_Window_memberlist_listbox'):AddTemplateListItemWithSort('twitch_memberlist_entry_template', 
					accountTable.playerName..accountTable.uniqueID,
					string.lower(playerName) .. string.lower(accountTable.uniqueID), -- sort index is broken, use name sort instead
					'playerName', playerName,
					'labelColor', chatNameColorPath,
					'accountIcon', accountIconPath,
					'identID', accountTable.identID,
					'inGame', accountTable.inGame,
					'inParty', accountTable.inParty,
					'inLobby', accountTable.inLobby,
					'uniqueID', accountTable.uniqueID,
					'isFriend', tostring(ChatClient.IsFriend(accountTable.identID)),
					'joinableParty', tostring(accountTable.joinableParty),
					'joinableGame', tostring(accountTable.joinableGame),
					'gameAddress', tostring(accountTable.gameAddress),
					'channelID', accountTable.channelID,
					'spectatableGame', tostring(accountTable.spectatableGame)
				)	
				
				object:GetWidget('Twitch_InGame_Chat_Window_memberlist_listbox'):SortListboxSortIndex(0)
			end
			
			count = count + 1
		end

		object:GetWidget('Twitch_InGame_Chat_Window_memberlist_listbox_vscroll'):SetValue(lastScrollValue)
		
		object:GetWidget('Twitch_InGame_Chat_Window_member_label'):SetText(count)
	end	
	
	local function ChatChannelMember(sourceWidget, trigger)
		local channelID = tostring(trigger.channelID)
		if (channelID == 'Twitch') then
			TwitchEdit.memberlist = TwitchEdit.memberlist or {}
			if (trigger.leave) then
				TwitchEdit.memberlist[trigger.identID] = nil
				UpdateMemberlist(channelID)	
			else
				TwitchEdit.memberlist[trigger.identID] = {
					channelID = channelID,
					playerName = trigger.playerName,
					adminLevel = trigger.adminLevel,
					inGame = tostring(trigger.inGame),
					inParty = 'false', -- tostring(trigger.inParty),
					inLobby = 'false', --  tostring(trigger.inLobby),
					isPremium = trigger.isPremium,
					identID = tostring(trigger.identID),
					uniqueID = tostring(trigger.playerUniqueID),
					chatNameColorString = trigger.accountColor,
					accountIconPath = trigger.accountIconPath,
					accountTitle = trigger.accountTitle,
					joinableParty = trigger.joinableParty,
					joinableGame  = trigger.joinableGame,
					spectatableGame = trigger.spectatableGame,
					leave = trigger.leave,
				}
				
				UpdateMemberlist(channelID)
			end
		end
	end
	object:RegisterWatchLua(
		'ChatChannelMember', function(sourceWidget, trigger)
				ChatChannelMember(sourceWidget, trigger)
			end, --callback
			false --duplicates_allowed
			--key
			--param_indices_to_watch
	)	
	
	twitch_settings_ingest_server_combobox:RegisterWatchLua('TwitchIngestServers', function(widget, trigger)
		if (trigger) and (#trigger > 0) then
			widget:Clear()
			local selectedIngestServer = false
			for index = 1,#trigger do
				widget:AddTemplateListItem('simpleDropdownItem', index , 'label', '['..index..']' .. ' ' .. trigger[index])
				if (mainUI.savedLocally.TwitchEdit) and (mainUI.savedLocally.TwitchEdit.savedSettings) and (mainUI.savedLocally.TwitchEdit.savedSettings.ingestServer) and (mainUI.savedLocally.TwitchEdit.savedSettings.ingestServer == index) then
					widget:SetSelectedItemByValue(index, true)
					selectedIngestServer = true				
				end
			end	
			if (not selectedIngestServer) then
				widget:SetSelectedItemByIndex(1, true)
			end
		end
	end)	
	
	twitch_settings_ingest_server_combobox:SetCallback('onselect', function(widget)
		local index = tonumber(widget:GetValue())
		if (index) and (index >= 0) and (index <= 1000000) then
			Twitch.SetIngestServer(index)
		
			mainUI.savedLocally.TwitchEdit = mainUI.savedLocally.TwitchEdit or {}
			mainUI.savedLocally.TwitchEdit.savedSettings = mainUI.savedLocally.TwitchEdit.savedSettings or {}
			mainUI.savedLocally.TwitchEdit.savedSettings.ingestServer = index
			SaveState()
		end
	end)	
	
	local function UpdateCapabilitiesDropdown(index)

		local widget = twitch_settings_capabilities_combobox
		local trigger = TwitchEdit.webCamDevicesTrigger

		widget:Clear() 
		
		if (not trigger.webCamInfo) then
			widget:AddTemplateListItem('simpleDropdownItem', 1, 'label', 'twitch_no_select_a_device')
			widget:SetSelectedItemByIndex(1, false)
			widget:SetEnabled(0)
			return
		else
			widget:SetEnabled(1)
		end		
		
		if (trigger.webCamInfo) and (trigger.webCamInfo[index]) and (trigger.webCamInfo[index].capabilities) and (#trigger.webCamInfo[index].capabilities > 0) then
			local selectedCapability = false
			for i, v in pairs(trigger.webCamInfo[index].capabilities) do
				widget:AddTemplateListItem('simpleDropdownItem', v.index, 'label', v.width .. ' x ' .. v.height .. ' @ ' .. v.frameRate)
				if (mainUI.savedLocally.TwitchEdit) and (mainUI.savedLocally.TwitchEdit.savedSettings) and (mainUI.savedLocally.TwitchEdit.savedSettings.capabilityIndex) and (mainUI.savedLocally.TwitchEdit.savedSettings.capabilityIndex == v.index) then
					widget:SetSelectedItemByValue(v.index, true)
					selectedCapability = true				
				end			
			end
			if (not selectedCapability) then
				widget:SetSelectedItemByIndex(1, true)
			end		
		end
		
		if (mainUI.savedLocally.TwitchEdit.savedSettings) and (mainUI.savedLocally.TwitchEdit.savedSettings.webcamEnabled) and (mainUI.savedLocally.TwitchEdit.savedSettings.webcam) and (mainUI.savedLocally.TwitchEdit.savedSettings.capabilityIndex) then
			if (trigger.webCamInfo) and (trigger.webCamInfo[1]) then
				for i, v in pairs(trigger.webCamInfo) do
					if (mainUI.savedLocally.TwitchEdit) and (mainUI.savedLocally.TwitchEdit.savedSettings) and (mainUI.savedLocally.TwitchEdit.savedSettings.webcam) and (mainUI.savedLocally.TwitchEdit.savedSettings.webcam == v.name) then
						Twitch.SelectWebCam(i, mainUI.savedLocally.TwitchEdit.savedSettings.capabilityIndex)
					end
				end
			end			
		end	
	end		
	
	twitch_settings_capabilities_combobox:SetCallback('onselect', function(widget)
		local index = tonumber(widget:GetValue())
		
		mainUI.savedLocally.TwitchEdit = mainUI.savedLocally.TwitchEdit or {}
		mainUI.savedLocally.TwitchEdit.savedSettings = mainUI.savedLocally.TwitchEdit.savedSettings or {}
		mainUI.savedLocally.TwitchEdit.savedSettings.capabilityIndex = index
		SaveState()
	end)	
	
	twitch_settings_webcam_combobox:RegisterWatchLua('TwitchWebCamDevices', function(widget, trigger)
		widget:Clear() 
		if (not trigger.webCamInfo) then
			widget:AddTemplateListItem('simpleDropdownItem', 1, 'label', 'twitch_no_devices')
			widget:SetSelectedItemByIndex(1, false)
			return
		end		
		
		if (trigger.webCamInfo) and (trigger.webCamInfo[1]) then
			local selectedWebCam = false
			for i, v in pairs(trigger.webCamInfo) do
				widget:AddTemplateListItem('simpleDropdownItem', i, 'label', v.name)
				if (mainUI.savedLocally.TwitchEdit) and (mainUI.savedLocally.TwitchEdit.savedSettings) and (mainUI.savedLocally.TwitchEdit.savedSettings.webcam) and (mainUI.savedLocally.TwitchEdit.savedSettings.webcam == v.name) then
					widget:SetSelectedItemByValue(i, true)
					selectedWebCam = true
				end
			end
			if (not selectedWebCam) then
				widget:SetSelectedItemByIndex(1, true)
			end
		end
	end)	
	
	twitch_settings_webcam_combobox:SetCallback('onselect', function(widget)

		local index = tonumber(widget:GetValue())
		UpdateCapabilitiesDropdown(index)
		
		mainUI.savedLocally.TwitchEdit = mainUI.savedLocally.TwitchEdit or {}
		mainUI.savedLocally.TwitchEdit.savedSettings = mainUI.savedLocally.TwitchEdit.savedSettings or {}
		mainUI.savedLocally.TwitchEdit.savedSettings.webcam = TwitchEdit.webCamDevicesTrigger.webCamInfo[index].name
		SaveState()
	end)
	
	-- volume
	mainUI.savedLocally 									= mainUI.savedLocally or {}
	mainUI.savedLocally.TwitchEdit 							= mainUI.savedLocally.TwitchEdit or {}
	mainUI.savedLocally.TwitchEdit.savedSettings 			= mainUI.savedLocally.TwitchEdit.savedSettings or {}
	mainUI.savedLocally.TwitchEdit.savedSettings.volume 	= mainUI.savedLocally.TwitchEdit.savedSettings.volume or 1	
	
	twitch_settings_output_volume_slider:RegisterWatchLua('TwitchStatus', function(widget, trigger)
		if (trigger.streamingActive) then
			twitch_settings_output_volume_slider:SetValue(mainUI.savedLocally.TwitchEdit.savedSettings.volume)
			twitch_settings_output_volume_value_label:SetText(math.floor(tonumber(mainUI.savedLocally.TwitchEdit.savedSettings.volume) * 100) .. '%')
			Twitch.SetVolume(mainUI.savedLocally.TwitchEdit.savedSettings.volume)
		end
	end, 'streamingActive')
	
	twitch_settings_output_volume_slider:SetCallback('onchange', function(widget, trigger)
		local value = widget:GetValue()
		if (twitch_settings_output_volume_slider:IsVisible()) then
			if (value) and tonumber(value) then
				value = math.max(0.0001, value)
				Twitch.SetVolume(value)
				twitch_settings_output_volume_value_label:SetText(math.floor(tonumber(value) * 100) .. '%')
				mainUI.savedLocally.TwitchEdit = mainUI.savedLocally.TwitchEdit or {}
				mainUI.savedLocally.TwitchEdit.savedSettings = mainUI.savedLocally.TwitchEdit.savedSettings or {}
				mainUI.savedLocally.TwitchEdit.savedSettings.volume = value
				SaveState()
			end
		else
			value = 0
			Twitch.SetVolume(value)
			twitch_settings_output_volume_value_label:SetText(math.floor(tonumber(value) * 100) .. '%')
			mainUI.savedLocally.TwitchEdit = mainUI.savedLocally.TwitchEdit or {}
			mainUI.savedLocally.TwitchEdit.savedSettings = mainUI.savedLocally.TwitchEdit.savedSettings or {}
			mainUI.savedLocally.TwitchEdit.savedSettings.volume = value
			SaveState()	
		end
	end)	 
	
	if (mainUI.savedLocally.TwitchEdit.savedSettings) and (mainUI.savedLocally.TwitchEdit.savedSettings.volume) then
		twitch_settings_output_volume_slider:SetValue(mainUI.savedLocally.TwitchEdit.savedSettings.volume)
		twitch_settings_output_volume_value_label:SetText(math.floor(tonumber(mainUI.savedLocally.TwitchEdit.savedSettings.volume) * 100) .. '%')	
	end
	
	-- bitrate -- dont try to use twitch version rmm
	-- twitch_settings_output_bitrate_slider:RegisterWatchLua('TwitchStatus', function(widget, trigger)
		-- widget:SetValue(trigger.bitrate)	
		-- twitch_settings_output_bitrate_value_label:SetText(math.floor(tonumber(trigger.bitrate)))	
	-- end)	
	
	twitch_settings_output_bitrate_slider:SetCallback('onchange', function(widget, trigger)
		local value = widget:GetValue()
		SetSave('twitch_bitrate', tostring(value), 'int')
		mainUI.savedLocally.TwitchEdit = mainUI.savedLocally.TwitchEdit or {}
		mainUI.savedLocally.TwitchEdit.savedSettings = mainUI.savedLocally.TwitchEdit.savedSettings or {}
		mainUI.savedLocally.TwitchEdit.savedSettings.bitrate = value
		SaveState()		
		twitch_settings_output_bitrate_value_label:SetText(math.floor(tonumber(value)))	
	end)	
	
	if (mainUI.savedLocally.TwitchEdit.savedSettings) and (mainUI.savedLocally.TwitchEdit.savedSettings.bitrate) then
		twitch_settings_output_bitrate_slider:SetValue(mainUI.savedLocally.TwitchEdit.savedSettings.bitrate)
		SetSave('twitch_bitrate', tostring(mainUI.savedLocally.TwitchEdit.savedSettings.bitrate), 'int')
		twitch_settings_output_bitrate_value_label:SetText(math.floor(tonumber(mainUI.savedLocally.TwitchEdit.savedSettings.bitrate)))	
	else
		mainUI.savedLocally										= mainUI.savedLocally							or {}
		mainUI.savedLocally.TwitchEdit 							= mainUI.savedLocally.TwitchEdit 				or {}
		mainUI.savedLocally.TwitchEdit.savedSettings 			= mainUI.savedLocally.TwitchEdit.savedSettings 	or {}
		mainUI.savedLocally.TwitchEdit.savedSettings.bitrate 	= 1500		
		twitch_settings_output_bitrate_slider:SetValue(1500)
		SetSave('twitch_bitrate', tostring(1500), 'int')
		twitch_settings_output_bitrate_value_label:SetText(math.floor(tonumber(1500)))
	end	
	
	--
	
	function Twitch.AutoDetect()
		Twitch_Overlays_Close:SetEnabled(0)
		Twitch_Overlays_Auto:SetEnabled(0)
		Twitch_Overlays_Auto:RegisterWatchLua('TwitchStatus', function(widget, trigger)
			if (trigger.bandwidthTestInProgress) then
				Twitch_Overlays_Close:SetEnabled(0)
				Twitch_Overlays_Auto:SetEnabled(0)
			else
				local result = trigger.bandwidthTestResultBitrate
				result = math.max(230, result)
				result = math.min(3500, result)
				Twitch_Overlays_Close:SetEnabled(1)
				Twitch_Overlays_Auto:SetEnabled(1)
				SetSave('twitch_bitrate', tostring(trigger.bandwidthTestResultBitrate), 'int')
				twitch_settings_output_bitrate_slider:SetValue(trigger.bandwidthTestResultBitrate)	
				twitch_settings_output_bitrate_value_label:SetText(math.floor(tonumber(trigger.bandwidthTestResultBitrate)))	
				Twitch_Overlays_Auto:UnregisterWatchLua('TwitchStatus')
			end
		end)
		if (mainUI.savedLocally.TwitchEdit) and ((mainUI.savedLocally.TwitchEdit.savedSettings) and (mainUI.savedLocally.TwitchEdit.savedSettings.ingestServer)) then
			Twitch.TestBandwidth(mainUI.savedLocally.TwitchEdit.savedSettings.ingestServer)
		else
			Twitch.TestBandwidth()
		end
		libThread.threadFunc(function()
			wait(5000)
			TwitchEdit.statusTrigger:Trigger(true)
		end)
	end
	
	--
	twitchPanel:RegisterWatchLua('TwitchStatus', function(widget, trigger)
		if (trigger.initialized) and (trigger.loggedIn) then
			TwitchEdit.stateTrigger.panelState = 'main'
			TwitchEdit.stateTrigger:Trigger(false)			
		else
			TwitchEdit.stateTrigger.panelState = 'login'
			TwitchEdit.stateTrigger:Trigger(false)	
		end
	end)
	
	twitchPanel:RegisterWatchLua('TwitchStateTrigger', function(widget, trigger)
		if (trigger.panelOpen) then
			widget:FadeIn(250)
			widget:SlideY('0', 250)
			-- widget:SlideX('0', 250)
		else
			widget:FadeOut(250)
			widget:SlideY('90h', 250)
			-- widget:SlideX('38.7h', 250)
		end
	end)
	
	twitchPanelLogin:RegisterWatchLua('TwitchStateTrigger', function(widget, trigger)
		if (trigger.panelState == 'login') then
			widget:FadeIn(250)
		else
			widget:FadeOut(250)
		end
	end)	
	
	twitchPanelLogged:RegisterWatchLua('TwitchStateTrigger', function(widget, trigger)
		if (trigger.panelState == 'main') then
			widget:FadeIn(250)
		else
			widget:FadeOut(250)
		end
	end)	
	
	object:GetWidget('Twitch_Login_Links_Signup'):SetCallback('onclick', function(widget)
		mainUI.OpenURL('http://www.twitch.tv/user/signup')
		PlaySound('/ui/sounds/sfx_button_generic.wav')
	end)	
	
	object:GetWidget('Twitch_Login_Trouble'):SetCallback('onclick', function(widget)
		mainUI.OpenURL('http://www.twitch.tv/user/reset_password')
		PlaySound('/ui/sounds/sfx_button_generic.wav')
	end)	
	
	object:GetWidget('Twitch_Login_Form_RememberMe'):SetCallback('onclick', function(widget)
		object:GetWidget('Twitch_Login_Form_RememberMe_check'):SetVisible(not object:GetWidget('Twitch_Login_Form_RememberMe_check'):IsVisibleSelf())
	end)	

	Twitch_Toggle_Chat:RegisterWatchLua('TwitchStatus', function(widget, trigger)
		if (trigger.chatConnected) then
			Twitch_Toggle_Chat_Label:SetText(Translate('twitch_chat_off'))
			Twitch_Toggle_Chat:SetCallback('onclick', function(widget)
				Twitch.DisconnectChat()
			end)			
		else
			Twitch_Toggle_Chat_Label:SetText(Translate('twitch_chat_on'))
			Twitch_Toggle_Chat:SetCallback('onclick', function(widget)
				Twitch.ConnectChat()
			end)
		end
	end)	
	
	Twitch_InGame_Stream_Notification:RegisterWatchLua('TwitchStatus', function(widget, trigger)
		local gamePhaseTrigger = LuaTrigger.GetTrigger('GamePhase')
		widget:SetVisible(trigger.streamingActive and (gamePhaseTrigger.gamePhase >= 4))
	end)	
	
	Twitch_InGame_Stream_Notification:RegisterWatchLua('GamePhase', function(widget, trigger)
		widget:SetVisible(TwitchEdit.statusTrigger.streamingActive and (trigger.gamePhase >= 4))
	end)	
	
	Twitch_Logged_StatusType:RegisterWatchLua('TwitchStatus', function(widget, trigger)
		if (trigger.streamingActive) then
			Twitch_Logged_StatusType:SetText(Translate('twitch_status_steaming'))		
		elseif (trigger.loggedIn) then
			Twitch_Logged_StatusType:SetText(Translate('twitch_status_online'))
		else
			Twitch_Logged_StatusType:SetText(Translate('twitch_status_offline'))
		end
	end)
	
	Twitch_Logged_Status:RegisterWatchLua('TwitchStatus', function(widget, trigger)
		if (trigger.streamingActive) then
			Twitch_Logged_Status:SetColor('1 0 0 1')	
		elseif (trigger.loggedIn) then
			Twitch_Logged_Status:SetColor('0 1 0 1')
		else
			Twitch_Logged_Status:SetColor('0.3 .3 .3 1')
		end
	end)	
	
	local function CheckWebCam()
		if (TwitchEdit.statusTrigger.webCamActive) then
			Twitch_Toggle_Webcam_Label:SetText(Translate('twitch_webcam_off'))
			Twitch_Toggle_Webcam:SetCallback('onclick', function(widget)
				Twitch.StopWebCam()
				mainUI.savedLocally.TwitchEdit = mainUI.savedLocally.TwitchEdit or {}
				mainUI.savedLocally.TwitchEdit.savedSettings = mainUI.savedLocally.TwitchEdit.savedSettings or {}
				mainUI.savedLocally.TwitchEdit.savedSettings.webcamEnabled = false
				SaveState()
			end)			
		elseif (mainUI.savedLocally.TwitchEdit.savedSettings) and (mainUI.savedLocally.TwitchEdit.savedSettings.webcam) and (mainUI.savedLocally.TwitchEdit.savedSettings.capabilityIndex) then
			local webCamValid = false
			if (TwitchEdit.webCamDevicesTrigger.webCamInfo) and (TwitchEdit.webCamDevicesTrigger.webCamInfo[1]) then
				for i, v in pairs(TwitchEdit.webCamDevicesTrigger.webCamInfo) do
					if (mainUI.savedLocally.TwitchEdit) and (mainUI.savedLocally.TwitchEdit.savedSettings) and (mainUI.savedLocally.TwitchEdit.savedSettings.webcam) and (mainUI.savedLocally.TwitchEdit.savedSettings.webcam == v.name) then
						webCamValid = tue
						Twitch_Toggle_Webcam_Label:SetText(Translate('twitch_webcam_on'))
					end
				end
			end
			if (not webCamValid) then
				-- Twitch_Toggle_Webcam_Label:SetText('^900' .. Translate('twitch_cant_use_webcam')) -- this isn't working
				Twitch_Toggle_Webcam_Label:SetText(Translate('twitch_webcam_on'))
			end
			Twitch_Toggle_Webcam:SetCallback('onclick', function(widget)
				local foundWebCam = false
				if (TwitchEdit.webCamDevicesTrigger.webCamInfo) and (TwitchEdit.webCamDevicesTrigger.webCamInfo[1]) then
					for i, v in pairs(TwitchEdit.webCamDevicesTrigger.webCamInfo) do
						if (mainUI.savedLocally.TwitchEdit) and (mainUI.savedLocally.TwitchEdit.savedSettings) and (mainUI.savedLocally.TwitchEdit.savedSettings.webcam) and (mainUI.savedLocally.TwitchEdit.savedSettings.webcam == v.name) then
							Twitch.SelectWebCam(i, mainUI.savedLocally.TwitchEdit.savedSettings.capabilityIndex)
							mainUI.savedLocally.TwitchEdit.savedSettings.webcamEnabled = true
							SaveState()
							foundWebCam = true
						end
					end
				end
				if (not foundWebCam) then
					widget:GetWidget('Twitch_Settings'):FadeIn(250)
				end
			end)			
		else
			Twitch_Toggle_Webcam_Label:SetText(Translate('twitch_cant_use_webcam'))
			Twitch_Toggle_Webcam:SetCallback('onclick', function(widget)
				widget:GetWidget('Twitch_Settings'):FadeIn(250)
			end)
		end	
	end
	
	Twitch_Toggle_Webcam:RegisterWatchLua('TwitchStatus', function(widget, trigger)
		CheckWebCam()
	end)	

	Twitch_Toggle_Webcam:RegisterWatchLua('TwitchWebCamDevices', function(widget, trigger)
		CheckWebCam()
	end)	
	
	Twitch_Logged_Username:RegisterWatchLua('TwitchStatus', function(widget, trigger)
		widget:SetText(trigger.channelName)
	end)		
	
	-- Twitch_Logged_ViewCount2:RegisterWatchLua('TwitchStatus', function(widget, trigger)
		-- local viewCount = trigger.viewCount or 0
		-- widget:SetVisible(viewCount > 0)
	-- end)	
	
	-- Twitch_Logged_ViewCount:RegisterWatchLua('TwitchStatus', function(widget, trigger)
		-- local viewCount = trigger.viewCount or 0
		-- widget:SetText(viewCount)
		-- widget:SetVisible(viewCount > 0)
	-- end)		
	
	-- Twitch_Logged_FollowerCount2:RegisterWatchLua('TwitchStatus', function(widget, trigger)
		-- local followerCount = trigger.followerCount or 0
		-- widget:SetVisible(followerCount > 0)
	-- end)	
	
	-- Twitch_Logged_FollowerCount:RegisterWatchLua('TwitchStatus', function(widget, trigger)
		-- local followerCount = trigger.followerCount or 0
		-- widget:SetText(followerCount)
		-- widget:SetVisible(followerCount > 0)
	-- end)
	
	Twitch_Logged_Title:RegisterWatchLua('TwitchStatus', function(widget, trigger)
		if (trigger.streamTitle) and (string.len(trigger.streamTitle) > 0) then
			widget:SetText(trigger.streamTitle)
		end
	end, false, nil, 'streamTitle')		
	
	local twitchStartBroadcastCountdownThread

	local function UpdateBroadcastButton(trigger, countingDown)
		if (trigger.streamingActive) or (countingDown) or (twitchStartBroadcastCountdownThread) then
			Twitch_Broadcast_Btn:SetCallback('onclick', function(widget)
				if (twitchStartBroadcastCountdownThread) then
					twitchStartBroadcastCountdownThread:kill()
					twitchStartBroadcastCountdownThread = nil
				end		
				twitch_edit_center_screen_announce:SetVisible(0)
				Twitch.StopStreaming()
				UpdateBroadcastButton(TwitchEdit.statusTrigger, false)
			end)
			Twitch_Broadcast_Btn_Label:SetText(Translate('twitch_broadcasting_live'))
			Twitch_Broadcast_Btn:SetEnabled(1)
		else
			if (trigger.initialized) and (trigger.loggedIn) and ((mainUI.savedLocally.TwitchEdit.savedSettings) and (GetCvarNumber('twitch_bitrate') >= 230) and (GetCvarNumber('twitch_bitrate') <= 10000) and (mainUI.savedLocally.TwitchEdit.savedSettings.ingestServer)) then
				Twitch_Broadcast_Btn:SetCallback('onclick', function(widget)
					if (twitchStartBroadcastCountdownThread) then
						twitchStartBroadcastCountdownThread:kill()
						twitchStartBroadcastCountdownThread = nil
					end
					twitchStartBroadcastCountdownThread = libThread.threadFunc(function()
						UpdateBroadcastButton(TwitchEdit.statusTrigger, true)
						for i = 5,1,-1 do
							twitch_edit_center_screen_announce:FadeIn(250)
							twitch_edit_center_screen_announce:SetText(i)
							wait(1000)
						end
						twitch_edit_center_screen_announce:SetVisible(0)
						Twitch.StartStreaming(mainUI.savedLocally.TwitchEdit.savedSettings.ingestServer)
						twitchStartBroadcastCountdownThread = nil
					end)
				end)
				Twitch_Broadcast_Btn_Label:SetText(Translate('twitch_broadcast_live'))
				Twitch_Broadcast_Btn:SetEnabled(1)
			else
				Twitch_Broadcast_Btn_Label:SetText(Translate('twitch_cant_broadcast_live'))
				Twitch_Broadcast_Btn:SetEnabled(1)
				Twitch_Broadcast_Btn:SetCallback('onclick', function(widget)
					widget:GetWidget('Twitch_Settings'):FadeIn(250)
				end)
			end
		end
	end

	object:GetWidget('Twitch_Settings'):SetCallback('onhide', function(widget)
		UpdateBroadcastButton(TwitchEdit.statusTrigger, false)
		CheckWebCam()
	end)
	
	Twitch_Broadcast_Btn:RegisterWatchLua('TwitchStatus', function(widget, trigger)
		UpdateBroadcastButton(trigger, false)
	end)	
	UpdateBroadcastButton(TwitchEdit.statusTrigger, false)
	
	Twitch_Logout_Send_Button:SetCallback('onclick', function(widget)
		Twitch.Logout()
	end)	

	local function checkForTwitchLogin()
		local username = Twitch_Login_Form_Username:GetValue()
		local password = Twitch_Login_Form_Password:GetValue()
		if (username) and (not Empty(username)) and (password) and (not Empty(password)) then
			Twitch_Login_Send_Button:SetEnabled(1)
			return true
		else
			Twitch_Login_Send_Button:SetEnabled(0)
			return false
		end
	end	
	
	local function attemptLogin()
		if (checkForTwitchLogin()) then
			PlaySound('/ui/sounds/sfx_button_generic.wav')
			local username = Twitch_Login_Form_Username:GetValue()
			local password = Twitch_Login_Form_Password:GetValue()		
			Twitch.Login(username, password, object:GetWidget('Twitch_Login_Form_RememberMe_check'):IsVisibleSelf())
		end
	end		
	
	Twitch_Login_Send_Button:SetCallback('onclick', function(widget)
		attemptLogin()
	end)

	-- Username
	function TwitchEdit.LoginInputOnEnter()
		Twitch_Login_Form_Username:SetFocus(false)
		Twitch_Login_Form_Password:SetFocus(true)
	end
	
	function TwitchEdit.LoginInputOnEsc()
		Twitch_Login_Form_Username:EraseInputLine()
		Twitch_Login_Form_Username_Coverup:SetFocus(false)	
		Twitch_Login_Form_Username_Coverup:SetVisible(true)	
	end

	Twitch_Login_Form_Username:SetCallback('onfocus', function(widget)
		Twitch_Login_Form_Username_Coverup:SetVisible(false)
	end)
	
	Twitch_Login_Form_Username:SetCallback('onlosefocus', function(widget)
		if string.len(widget:GetValue()) == 0 then
			Twitch_Login_Form_Username_Coverup:SetVisible(true)
		end
	end)	
	
	Twitch_Login_Form_Username:SetCallback('onhide', function(widget)
		 TwitchEdit.LoginInputOnEsc()
	end)	
	
	Twitch_Login_Form_Username:SetCallback('onchange', function(widget)
		checkForTwitchLogin()
	end)
	
	-- Password
	function TwitchEdit.LoginPWInputOnEnter()
		Twitch_Login_Form_Username:SetFocus(false)
		Twitch_Login_Form_Password:SetFocus(false) 
		attemptLogin()
	end
	
	function TwitchEdit.LoginPWInputOnEsc()
		Twitch_Login_Form_Password:EraseInputLine()
		Twitch_Login_Form_Password_coverup:SetFocus(false)	
		Twitch_Login_Form_Password_coverup:SetVisible(true)	
	end

	Twitch_Login_Form_Password:SetCallback('onfocus', function(widget)
		Twitch_Login_Form_Password_coverup:SetVisible(false)
	end)
	
	Twitch_Login_Form_Password:SetCallback('onlosefocus', function(widget)
		if string.len(widget:GetValue()) == 0 then
			Twitch_Login_Form_Password_coverup:SetVisible(true)
		end
	end)	
	
	Twitch_Login_Form_Password:SetCallback('onhide', function(widget)
		 TwitchEdit.LoginPWInputOnEsc()
	end)	
	
	Twitch_Login_Form_Password:SetCallback('onchange', function(widget)
		checkForTwitchLogin()
	end)	
	
	local twitch_instantiate_layer 	= object:GetWidget('twitch_instantiate_layer')
	local twitch_helper_layer 		= object:GetWidget('twitch_helper_layer')
	
	function Twitch.ResizeFont(widget)
		widget:SetFont(GetFontThatFits(widget:GetWidth(), widget:GetText(), nil))
	end
	
	function TwitchEdit.InstantiateAndRegisterWidgets(twitch_instantiate_layer, callback)
		local widgets = mainUI.savedLocally.TwitchEdit.widgets
		for i, v in pairs(widgets) do	
			local widget = object:GetWidget('twitchinstantiate_template_' .. v.widgetName)
			if (not widget) or (not widget:IsValid()) then
				if (widget) then
					widget:Destroy()
				end
				local width = (v.overrideWidth or v.originalWidth or v[3])
				local height = (v.overrideHeight or v.originalHeight or v[4])		
				local x = (v.overrideX or v.originalX or v[5])		
				local y = (v.overrideY or v.originalY or v[6])		
				
				if (v[1] == 'image') then				
					widgets[i].pointer = twitch_instantiate_layer:InstantiateAndReturn('twitch_instantiate_template_image',
						'index',	v.widgetName,
						'texture', 	v[2],
						'width', 	width,
						'height', 	height,
						'x', 		x,
						'y', 		y
					)[1]
					widgets[i].pointer:Sleep(100, function(widget2)
						if (callback) then
							callback(widget2)
						end
					end)					
				elseif (v[1] == 'label') then
					widgets[i].pointer = twitch_instantiate_layer:InstantiateAndReturn('twitch_instantiate_template_label',
						'index',	v.widgetName,
						'label', 	v[2],
						'font', 	GetFontThatFits(width, v[2], nil),
						'width', 	width,
						'height', 	height,
						'x', 		x,
						'y', 		y
					)[1]	
					widgets[i].pointer:Sleep(100, function(widget2)
						if (callback) then
							callback(widget2)
						end
					end)					
				elseif (v[1] == 'webcam') then
					widgets[i].pointer = twitch_instantiate_layer:InstantiateAndReturn('twitch_instantiate_template_webcam',
						'index',	v.widgetName,
						'width', 	width,
						'height', 	height,
						'x', 		x,
						'y', 		y
					)[1]				
					widgets[i].pointer:Sleep(100, function(widget2)
						if (callback) then
							callback(widget2)
						end
					end)
				end
			end
		end
	end
	
	function TwitchEdit.Reset()
	
		local groupWidgets = object:GetGroup('twitch_helpers') or {}
		for groupWidgetIndex, groupWidget in pairs(groupWidgets) do	
			groupWidget:Destroy()
		end

		for index, targetGroupTable in pairs(mainUI.savedLocally.TwitchEdit.widgets) do

			local targetWidget
			if ((targetGroupTable.pointer) and (targetGroupTable.pointer:IsValid())) then 
				targetWidget = targetGroupTable.pointer
			elseif ((object:GetWidget('twitchinstantiate_template_'..targetGroupTable.widgetName)) and (object:GetWidget('twitchinstantiate_template_'..targetGroupTable.widgetName):IsValid())) then
				targetWidget = object:GetWidget('twitchinstantiate_template_'..targetGroupTable.widgetName)
			end			
		
			if (targetWidget) then
				targetWidget:SetVisible(0)
				targetWidget:Destroy()
			end
		end

		mainUI.savedLocally.Twitch = mainUI.savedLocally.Twitch or {}
		mainUI.savedLocally.TwitchEdit = mainUI.savedLocally.TwitchEdit or {}
		mainUI.savedLocally.TwitchEdit.savedSettings = mainUI.savedLocally.TwitchEdit.savedSettings or {}		
		mainUI.savedLocally.TwitchEdit.widgetCount = 1
		mainUI.savedLocally.TwitchEdit.widgets = {}	
		
		SaveState()
		
		TwitchEdit.PopulateWidgetList() -- doesn't rely on them existing

		TwitchEdit.InstantiateAndRegisterWidgets(twitch_instantiate_layer, function()
			TwitchEdit.Load(true, true)	-- Get the position and size info
			TwitchEdit.UpdateEditorWidgets() -- Set position and spawn helpers		
		end) -- Create the widget and pointer at [7]	
		
		TwitchEdit.stateTrigger.unsavedChanges = false
		TwitchEdit.stateTrigger:Trigger(false)		
		
	end

	function TwitchEdit.Load(loadOriginal, dontReload)		
		local widgets = mainUI.savedLocally.TwitchEdit.widgets
		
		if (loadOriginal) then
			for index, targetGroupTable in pairs(widgets) do
				local targetWidget
				if ((not targetGroupTable.hasBeenLoaded)) then
					if ((targetGroupTable.pointer) and (targetGroupTable.pointer:IsValid())) then 
						targetWidget = targetGroupTable.pointer
					elseif ((object:GetWidget('twitchinstantiate_template_'..targetGroupTable.widgetName)) and (object:GetWidget('twitchinstantiate_template_'..targetGroupTable.widgetName):IsValid())) then
						targetWidget = object:GetWidget('twitchinstantiate_template_'..targetGroupTable.widgetName)
					end
					if (targetWidget) then
						targetGroupTable.originalHeight 	= TwitchEdit.CoerceHeightToPercent(targetWidget, targetWidget:GetHeight())
						targetGroupTable.originalWidth 		= TwitchEdit.CoerceWidthToPercent(targetWidget, targetWidget:GetWidth())
						targetGroupTable.originalX 			= TwitchEdit.CoerceWidthToPercent(targetWidget, targetWidget:GetAbsoluteX())
						targetGroupTable.originalY 			= TwitchEdit.CoerceHeightToPercent(targetWidget, targetWidget:GetAbsoluteY())
						targetGroupTable.originalAlign 		= targetWidget:GetAlign()		
						targetGroupTable.originalVAlign 	= targetWidget:GetVAlign()
						targetGroupTable.hasBeenLoaded = true	 
					end
				end
			end
		end

		for index, targetGroupTable in pairs(widgets) do
			local targetWidget
			if ((targetGroupTable.pointer) and (targetGroupTable.pointer:IsValid())) then 
				targetWidget = targetGroupTable.pointer
			elseif ((object:GetWidget('twitchinstantiate_template_'..targetGroupTable.widgetName)) and (object:GetWidget('twitchinstantiate_template_'..targetGroupTable.widgetName):IsValid())) then
				targetWidget = object:GetWidget('twitchinstantiate_template_'..targetGroupTable.widgetName)
			end		
		
			if (targetWidget) and ((not targetGroupTable.hasBeenLoaded) or (not dontReload)) then			
				if (targetGroupTable.overrideHeight) and (targetGroupTable.overrideWidth) and (targetGroupTable.overrideX) and (targetGroupTable.overrideY) then
					targetWidget:SetHeight(targetGroupTable.overrideHeight or targetGroupTable.originalHeight)
					targetWidget:SetWidth(targetGroupTable.overrideWidth or targetGroupTable.originalWidth)
					targetWidget:SetAbsoluteX(TwitchEdit.ConvertWidthPercentToPixels(targetGroupTable.overrideX or targetGroupTable.originalX))
					targetWidget:SetAbsoluteY(TwitchEdit.ConvertHeightPercentToPixels(targetGroupTable.overrideY or targetGroupTable.originalY))
				end
			end
		end		

	end

	function TwitchEdit.Save()

		for index, targetGroupTable in pairs(mainUI.savedLocally.TwitchEdit.widgets) do
			local targetWidget
			if ((targetGroupTable.pointer) and (targetGroupTable.pointer:IsValid())) then 
				targetWidget = targetGroupTable.pointer
			elseif ((object:GetWidget('twitchinstantiate_template_'..targetGroupTable.widgetName)) and (object:GetWidget('twitchinstantiate_template_'..targetGroupTable.widgetName):IsValid())) then
				targetWidget = object:GetWidget('twitchinstantiate_template_'..targetGroupTable.widgetName)
			end			
		
			mainUI.savedLocally.TwitchEdit.widgets[index] = mainUI.savedLocally.TwitchEdit.widgets[index] or {}
			if (targetWidget) then
				mainUI.savedLocally.TwitchEdit.widgets[index] = mainUI.savedLocally.TwitchEdit.widgets[index] or {}
				mainUI.savedLocally.TwitchEdit.widgets[index].overrideHeight 		= TwitchEdit.CoerceHeightToPercent(targetWidget, targetWidget:GetHeight())
				mainUI.savedLocally.TwitchEdit.widgets[index].overrideWidth 		= TwitchEdit.CoerceWidthToPercent(targetWidget, targetWidget:GetWidth())
				mainUI.savedLocally.TwitchEdit.widgets[index].overrideX 			= TwitchEdit.CoerceWidthToPercent(targetWidget, targetWidget:GetAbsoluteX())
				mainUI.savedLocally.TwitchEdit.widgets[index].overrideY 			= TwitchEdit.CoerceHeightToPercent(targetWidget, targetWidget:GetAbsoluteY())
				mainUI.savedLocally.TwitchEdit.widgets[index].overrideAlign 		= targetWidget:GetAlign()		
				mainUI.savedLocally.TwitchEdit.widgets[index].overrideVAlign 		= targetWidget:GetVAlign()
				mainUI.savedLocally.TwitchEdit.widgets[index].originalHeight 		= TwitchEdit.CoerceHeightToPercent(targetWidget, targetWidget:GetHeight())
				mainUI.savedLocally.TwitchEdit.widgets[index].originalWidth 		= TwitchEdit.CoerceWidthToPercent(targetWidget, targetWidget:GetWidth())
				mainUI.savedLocally.TwitchEdit.widgets[index].originalX 			= TwitchEdit.CoerceWidthToPercent(targetWidget, targetWidget:GetAbsoluteX())
				mainUI.savedLocally.TwitchEdit.widgets[index].originalY 			= TwitchEdit.CoerceHeightToPercent(targetWidget, targetWidget:GetAbsoluteY())
				mainUI.savedLocally.TwitchEdit.widgets[index].originalAlign 		= targetWidget:GetAlign()		
				mainUI.savedLocally.TwitchEdit.widgets[index].originalVAlign 		= targetWidget:GetVAlign()				
				mainUI.savedLocally.TwitchEdit.widgets[index].temp 					= false
			end
		end	
		SaveState()		
		
		TwitchEdit.Load(false, false)
		TwitchEdit.stateTrigger.unsavedChanges = false
		TwitchEdit.stateTrigger:Trigger(false)		
		
		TwitchEdit.PopulateWidgetList()
		libThread.threadFunc(function() -- This must occur after the list has been populated as it gives function to those buttons
			wait(10)		
			TwitchEdit.UpdateEditorWidgets()
		end)
		
	end

	function TwitchEdit.Revert()	
		for index, targetGroupTable in pairs(mainUI.savedLocally.TwitchEdit.widgets) do
			local targetWidget
			if ((targetGroupTable.pointer) and (targetGroupTable.pointer:IsValid())) then 
				targetWidget = targetGroupTable.pointer
			elseif ((object:GetWidget('twitchinstantiate_template_'..targetGroupTable.widgetName)) and (object:GetWidget('twitchinstantiate_template_'..targetGroupTable.widgetName):IsValid())) then
				targetWidget = object:GetWidget('twitchinstantiate_template_'..targetGroupTable.widgetName)
			end			
		
			local Twitch_index 						=  targetGroupTable.widgetName	
			if (targetGroupTable[3]) or (targetGroupTable[4]) then
				twitch_helper_group 			= object:GetWidget('twitch_helper_'..Twitch_index) or object:GetWidget('twitch_helper_layer'):InstantiateAndReturn('twitch_helper_template', 'index', Twitch_index, 'canMove', tostring(true), 'canResizeConstrained', tostring(true), 'canResize', tostring(true))
			else	
				twitch_helper_group 			= object:GetWidget('twitch_helper_'..Twitch_index) or object:GetWidget('twitch_helper_layer'):InstantiateAndReturn('twitch_helper_template_nosize', 'index', Twitch_index, 'canMove', tostring(true), 'canResizeConstrained', tostring(true), 'canResize', tostring(true))
			end		
			local twitch_helper 				= twitch_helper_group[1] or twitch_helper_group		
		
			if (targetWidget) then			
				if (targetGroupTable.temp) then
					targetWidget:SetVisible(0)
					targetWidget:Destroy()
					object:GetWidget('twitch_helper_'..targetGroupTable.widgetName):SetVisible(0)

					-- TwitchEdit.PopulateWidgetList()	-- This causes a crash for some reason, do this other derpy thing instead
					local Twitch_Overlays_List_Listbox 				= object:GetWidget('Twitch_Overlays_List_Listbox')		
					Twitch_Overlays_List_Listbox:HideItemByValue(targetGroupTable.widgetName)					
					
					mainUI.savedLocally.TwitchEdit.widgets[index] = nil		
					targetGroupTable = nil
				else
					targetWidget:SetHeight(targetGroupTable.overrideHeight or targetGroupTable.originalHeight)
					targetWidget:SetWidth(targetGroupTable.overrideWidth or targetGroupTable.originalWidth)
					targetWidget:SetAbsoluteX(TwitchEdit.ConvertWidthPercentToPixels(targetGroupTable.overrideX or targetGroupTable.originalX))
					targetWidget:SetAbsoluteY(TwitchEdit.ConvertHeightPercentToPixels(targetGroupTable.overrideY or targetGroupTable.originalY))	
					
					twitch_helper:ClearCallback('onframe')
					twitch_helper:SetHeight(targetGroupTable.originalHeight)
					twitch_helper:SetWidth(targetGroupTable.originalWidth)
					twitch_helper:SetAbsoluteX(TwitchEdit.ConvertWidthPercentToPixels(targetGroupTable.originalX))
					twitch_helper:SetAbsoluteY(TwitchEdit.ConvertHeightPercentToPixels(targetGroupTable.originalY))				
				end
			end
		end		
		TwitchEdit.stateTrigger.unsavedChanges = false
		TwitchEdit.stateTrigger:Trigger(false)		
	end

	function TwitchEdit.DisableEditor()	
		object:GetWidget('twitch_helper_layer'):SetVisible(0)
		object:GetWidget('twitch_command_layer'):SetVisible(0)		
		object:GetWidget('twitch_instantiate_layer'):SetVisible(0)		
		
		TwitchEdit.stateTrigger.unsavedChanges = false
		TwitchEdit.stateTrigger:Trigger(false)	
			
		TwitchOverlay.SpawnOverlay()
		
		if (twitchPanelWasOpen) then
			twitchPanelWasOpen = false
			TwitchEdit.stateTrigger.panelOpen = true
			TwitchEdit.stateTrigger:Trigger(false)	
		end
		
		SaveState()
		
	end	

	function TwitchEdit.PopulateWidgetList()

		local Twitch_Overlays_List_Listbox 				= object:GetWidget('Twitch_Overlays_List_Listbox')	
		
		Twitch_Overlays_List_Listbox:Clear()
		
		local count = 0
		
		for _, targetGroupTable in pairs(mainUI.savedLocally.TwitchEdit.widgets) do
			count = count + 1
			if (not targetGroupTable.temp) then
				Twitch_Overlays_List_Listbox:AddTemplateListItem('twitch_widget_listitem_template', targetGroupTable.widgetName, 'label', Translate('twitch_widget_type_'..targetGroupTable[1], 'value', count), 'texture', Translate('twitch_widget_type_'..targetGroupTable[1]..'_texture', 'value', count), 'index', targetGroupTable.widgetName)
			else
				Twitch_Overlays_List_Listbox:AddTemplateListItem('twitch_widget_listitem_template', targetGroupTable.widgetName, 'label', '^980'..Translate('twitch_widget_type_'..targetGroupTable[1], 'value', count), 'texture', Translate('twitch_widget_type_'..targetGroupTable[1]..'_texture', 'value', count), 'index', targetGroupTable.widgetName)
			end 
		end
		
	end			
			
	function TwitchEdit.AddWebcam()
		mainUI.savedLocally.TwitchEdit.widgetCount = mainUI.savedLocally.TwitchEdit.widgetCount + 1
		
		local newWebcamTable 		= {'webcam', '', 						    '20h', '20h', '0h', '80h'}
		newWebcamTable.temp 		= true
		newWebcamTable.widgetName 	= mainUI.savedLocally.TwitchEdit.widgetCount
		
		table.insert(mainUI.savedLocally.TwitchEdit.widgets, newWebcamTable)
		
		TwitchEdit.PopulateWidgetList() -- doesn't rely on them existing

		TwitchEdit.InstantiateAndRegisterWidgets(twitch_instantiate_layer, function()
			TwitchEdit.Load(true, true)	-- Get the position and size info
			TwitchEdit.UpdateEditorWidgets() -- Set position and spawn helpers		
		end) -- Create the widget and pointer at [7]

		TwitchEdit.stateTrigger.unsavedChanges = true
		TwitchEdit.stateTrigger:Trigger(false)		
		
		SaveState()
	end
	
	function TwitchEdit.AddImage()
		
		local Twitch_Image_Content 				= object:GetWidget('Twitch_Image_Content')
		local Twitch_Image_Content_Listbox 		= object:GetWidget('Twitch_Image_Content_Listbox')
		local Twitch_Image_Content_input_btn 	= object:GetWidget('Twitch_Image_Content_input_btn')
		
		Twitch_Image_Content_input_btn:SetEnabled(0)
		
		local imageTable = Twitch.GetOverlayImages()
		
		Twitch_Image_Content_Listbox:Clear()
		if (imageTable) and (#imageTable > 0) then
			for index, value in pairs(imageTable) do
				local widthScale = value.width / value.height
				Twitch_Image_Content_Listbox:AddTemplateListItem('twitch_image_dropdown_item_template', index , 'label', string.gsub(value.name, '~/twitch/', ''), 'texture', value.name, 'width', (92 * widthScale))
			end
		end

		Twitch_Image_Content_Listbox:SetCallback('onselect', function(widget)
			Twitch_Image_Content_input_btn:SetEnabled(string.len(Twitch_Image_Content_Listbox:GetValue())>0)
		end)
		
		Twitch_Image_Content:FadeIn(250)
		
		Twitch_Image_Content_input_btn:SetCallback('onclick', function(widget)
			local index = Twitch_Image_Content_Listbox:GetValue()
			local image_path 		= imageTable[tonumber(index)].name
			local width 			= imageTable[tonumber(index)].width
			local height 			= imageTable[tonumber(index)].height
			
			mainUI.savedLocally.TwitchEdit.widgetCount = mainUI.savedLocally.TwitchEdit.widgetCount + 1
			
			local newImageTable 		= {'image', image_path,  (width), (height), '10h', '50h'}
			newImageTable.temp 			= true
			newImageTable.widgetName 	= mainUI.savedLocally.TwitchEdit.widgetCount
			
			table.insert(mainUI.savedLocally.TwitchEdit.widgets, newImageTable)
			
			TwitchEdit.PopulateWidgetList() -- doesn't rely on them existing

			TwitchEdit.InstantiateAndRegisterWidgets(twitch_instantiate_layer, function()
				TwitchEdit.Load(true, true)	-- Get the position and size info
				TwitchEdit.UpdateEditorWidgets() -- Set position and spawn helpers		
			end) -- Create the widget and pointer at [7]

			TwitchEdit.stateTrigger.unsavedChanges = true
			TwitchEdit.stateTrigger:Trigger(false)		
			
			SaveState()				
			
			Twitch_Image_Content:FadeOut(125)
			
		end)	
	end

	function TwitchEdit.AddText()
		
		local Twitch_Label_Content 				= object:GetWidget('Twitch_Label_Content')
		local Twitch_Label_Content_input 		= object:GetWidget('Twitch_Label_Content_input')
		local Twitch_Label_Content_input_btn 	= object:GetWidget('Twitch_Label_Content_input_btn')
		
		Twitch_Label_Content:FadeIn(250)

		Twitch_Label_Content_input_btn:SetCallback('onclick', function(widget)
			local text = Twitch_Label_Content_input:GetInputText()
			
			mainUI.savedLocally.TwitchEdit.widgetCount = mainUI.savedLocally.TwitchEdit.widgetCount + 1
			
			local newTextTable 		= {'label', tostring(text), 		'40h', '10h', '20h', '80h'}
			newTextTable.temp 		= true
			newTextTable.widgetName 	= mainUI.savedLocally.TwitchEdit.widgetCount
			
			table.insert(mainUI.savedLocally.TwitchEdit.widgets, newTextTable)
			
			TwitchEdit.PopulateWidgetList() -- doesn't rely on them existing

			TwitchEdit.InstantiateAndRegisterWidgets(twitch_instantiate_layer, function()
				TwitchEdit.Load(true, true)	-- Get the position and size info
				TwitchEdit.UpdateEditorWidgets() -- Set position and spawn helpers		
			end) -- Create the widget and pointer at [7]

			TwitchEdit.stateTrigger.unsavedChanges = true
			TwitchEdit.stateTrigger:Trigger(false)		
			
			SaveState()				
			
			Twitch_Label_Content:FadeOut(125)
			
		end)
		
	end	
	
	function TwitchEdit.UpdateEditorWidgets()

		local widgetTable = mainUI.savedLocally.TwitchEdit.widgets
		for index, targetGroupTable in pairs(widgetTable) do

			local twitch_helper_group		

			local targetWidget
			if ((targetGroupTable.pointer) and (targetGroupTable.pointer:IsValid())) then 
				targetWidget = targetGroupTable.pointer
			elseif ((object:GetWidget('twitchinstantiate_template_'..targetGroupTable.widgetName)) and (object:GetWidget('twitchinstantiate_template_'..targetGroupTable.widgetName):IsValid())) then
				targetWidget = object:GetWidget('twitchinstantiate_template_'..targetGroupTable.widgetName)
			end					
			
			if (targetWidget) then			

				local Twitch_index 						=  targetGroupTable.widgetName	
				local editorListButtonValue				=  targetGroupTable.widgetName					
				local editorListButtonUndo				=  object:GetWidget('twitch_widget_listitem_' .. Twitch_index .. '_undo')
				local editorListButtonDelete			=  object:GetWidget('twitch_widget_listitem_' .. Twitch_index .. '_closex')				
				
				if (targetGroupTable[3]) or (targetGroupTable[4]) then
					twitch_helper_group 			= object:GetWidget('twitch_helper_'..Twitch_index) or object:GetWidget('twitch_helper_layer'):InstantiateAndReturn('twitch_helper_template', 'index', Twitch_index, 'canMove', tostring(true), 'canResizeConstrained', tostring(true), 'canResize', tostring(true))
				else	
					twitch_helper_group 			= object:GetWidget('twitch_helper_'..Twitch_index) or object:GetWidget('twitch_helper_layer'):InstantiateAndReturn('twitch_helper_template_nosize', 'index', Twitch_index, 'canMove', tostring(true), 'canResizeConstrained', tostring(true), 'canResize', tostring(true))
				end		
				local twitch_helper 				= twitch_helper_group[1] or twitch_helper_group

				local cancelButton 					= object:GetWidget('twitch_helper_' .. Twitch_index .. '_btn_cancel')
				local keepButton 					= object:GetWidget('twitch_helper_' .. Twitch_index .. '_btn_keep')
				
				twitch_helper:SetVisible(1)
				targetWidget:SetVisible(1)
				
				targetWidget:SetHeight(targetGroupTable.overrideHeight or targetGroupTable.originalHeight)
				targetWidget:SetWidth(targetGroupTable.overrideWidth or targetGroupTable.originalWidth)
				targetWidget:SetAbsoluteX(TwitchEdit.ConvertWidthPercentToPixels(targetGroupTable.overrideX or targetGroupTable.originalX))
				targetWidget:SetAbsoluteY(TwitchEdit.ConvertHeightPercentToPixels(targetGroupTable.overrideY or targetGroupTable.originalY)	)
			
				twitch_helper:SetHeight(targetWidget:GetHeight())
				twitch_helper:SetWidth(targetWidget:GetWidth())

				twitch_helper:SetAbsoluteX(TwitchEdit.ConvertWidthPercentToPixels(targetWidget:GetAbsoluteX()))
				twitch_helper:SetAbsoluteY(TwitchEdit.ConvertHeightPercentToPixels(targetWidget:GetAbsoluteY()))
				
				twitch_helper:SetCallback('onstartdrag', function(widget)
					twitch_helper:SetAbsoluteX(TwitchEdit.ConvertWidthPercentToPixels(twitch_helper:GetAbsoluteX()))
					twitch_helper:SetAbsoluteY(TwitchEdit.ConvertHeightPercentToPixels(twitch_helper:GetAbsoluteY()))
					twitch_helper:SetCallback('onframe', function(widget)
						targetWidget:SetHeight(twitch_helper:GetHeight())
						targetWidget:SetWidth(twitch_helper:GetWidth())

						targetWidget:SetAbsoluteX(TwitchEdit.ConvertWidthPercentToPixels(twitch_helper:GetAbsoluteX()))
						targetWidget:SetAbsoluteY(TwitchEdit.ConvertHeightPercentToPixels(twitch_helper:GetAbsoluteY()))
					end)
					TwitchEdit.stateTrigger.unsavedChanges = true
					TwitchEdit.stateTrigger:Trigger(false)
				end)
				
				twitch_helper:SetCallback('onenddrag', function(widget)
					twitch_helper:ClearCallback('onframe')
					twitch_helper:SetAbsoluteX(TwitchEdit.ConvertWidthPercentToPixels(twitch_helper:GetAbsoluteX()))
					twitch_helper:SetAbsoluteY(TwitchEdit.ConvertHeightPercentToPixels(twitch_helper:GetAbsoluteY()))			
					
					targetWidget:SetHeight(twitch_helper:GetHeight())
					targetWidget:SetWidth(twitch_helper:GetWidth())

					targetWidget:SetAbsoluteX(TwitchEdit.ConvertWidthPercentToPixels(twitch_helper:GetAbsoluteX()))
					targetWidget:SetAbsoluteY(TwitchEdit.ConvertHeightPercentToPixels(twitch_helper:GetAbsoluteY()))
					
					if (targetGroupTable.temp) then
						mainUI.savedLocally.TwitchEdit.widgets[index] = mainUI.savedLocally.TwitchEdit.widgets[index] or {}
						mainUI.savedLocally.TwitchEdit.widgets[index].overrideHeight 		= TwitchEdit.CoerceHeightToPercent(targetWidget, targetWidget:GetHeight())
						mainUI.savedLocally.TwitchEdit.widgets[index].overrideWidth 		= TwitchEdit.CoerceWidthToPercent(targetWidget, targetWidget:GetWidth())
						mainUI.savedLocally.TwitchEdit.widgets[index].overrideX 			= TwitchEdit.CoerceWidthToPercent(targetWidget, targetWidget:GetAbsoluteX())
						mainUI.savedLocally.TwitchEdit.widgets[index].overrideY 			= TwitchEdit.CoerceHeightToPercent(targetWidget, targetWidget:GetAbsoluteY())
						mainUI.savedLocally.TwitchEdit.widgets[index].overrideAlign 		= targetWidget:GetAlign()		
						mainUI.savedLocally.TwitchEdit.widgets[index].overrideVAlign 		= targetWidget:GetVAlign()	
					end
					
					local labelWidget = object:GetWidget('twitchinstantiate_template_'..targetGroupTable.widgetName..'_label')
					
					if (labelWidget and labelWidget:IsValid()) then
						Twitch.ResizeFont(labelWidget)
					end
					
					local imageWidget = object:GetWidget('twitchinstantiate_template_'..targetGroupTable.widgetName..'_image')
					
					if (imageWidget and imageWidget:IsValid()) then
						targetWidget:SetHeight(twitch_helper:GetHeight())
						targetWidget:SetWidth(twitch_helper:GetWidth())		
						targetWidget:SetAbsoluteX(TwitchEdit.ConvertWidthPercentToPixels(twitch_helper:GetAbsoluteX()))
						targetWidget:SetAbsoluteY(TwitchEdit.ConvertHeightPercentToPixels(twitch_helper:GetAbsoluteY())	)					
					end
				
				end)

				editorListButtonUndo:SetCallback('onclick', function(widget)
					twitch_helper:ClearCallback('onframe')
					twitch_helper:SetHeight(targetGroupTable.originalHeight)
					twitch_helper:SetWidth(targetGroupTable.originalWidth)
					twitch_helper:SetAbsoluteX(TwitchEdit.ConvertWidthPercentToPixels(targetGroupTable.originalX))
					twitch_helper:SetAbsoluteY(TwitchEdit.ConvertHeightPercentToPixels(targetGroupTable.originalY))
				
					targetWidget:SetHeight(twitch_helper:GetHeight())
					targetWidget:SetWidth(twitch_helper:GetWidth())

					targetWidget:SetAbsoluteX(TwitchEdit.ConvertWidthPercentToPixels(twitch_helper:GetAbsoluteX()))
					targetWidget:SetAbsoluteY(TwitchEdit.ConvertHeightPercentToPixels(twitch_helper:GetAbsoluteY()))
				
				end)
				
				editorListButtonDelete:SetCallback('onclick', function(widget)
					twitch_helper:ClearCallback('onframe')
					twitch_helper:SetVisible(0)	
					targetWidget:SetVisible(0)
					targetWidget:Destroy()
					widgetTable[index] = nil
					for index2, targetGroupTable2 in pairs(mainUI.savedLocally.TwitchEdit.widgets) do
						if (targetGroupTable2.widgetName == targetGroupTable.widgetName) then
							mainUI.savedLocally.TwitchEdit.widgets[index2] = nil
						end
					end				
					-- TwitchEdit.PopulateWidgetList()	-- This causes a crash for some reason, do this other derpy thing instead
					local Twitch_Overlays_List_Listbox 				= object:GetWidget('Twitch_Overlays_List_Listbox')		
					Twitch_Overlays_List_Listbox:HideItemByValue(editorListButtonValue)
				end)				
				
				targetGroupTable.helpersExist = true
			end
		end		
	end
	
	function TwitchEdit.EnableEditor()

		TwitchEdit.stateTrigger.panelOpen = false
		TwitchEdit.stateTrigger:Trigger(false)	
		twitchPanelWasOpen = true	
	
		object:GetWidget('twitch_helper_layer'):SetVisible(1)
		object:GetWidget('twitch_command_layer'):SetVisible(1)
		object:GetWidget('twitch_instantiate_layer'):SetVisible(1)

		local Twitch_Overlay_Remove 					= object:GetWidget('Twitch_Overlay_Remove')
		local Twitch_Overlay_Revert 					= object:GetWidget('Twitch_Overlay_Revert')
		local Twitch_Overlay_Save 						= object:GetWidget('Twitch_Overlay_Save')	
		local Twitch_Overlays_Header 					= object:GetWidget('Twitch_Overlays_Header')	
		local Twitch_Overlays_Header_closex 			= object:GetWidget('Twitch_Overlays_Header_closex')	
		local Twitch_Overlays_List_Listbox 				= object:GetWidget('Twitch_Overlays_List_Listbox')	
		local Twitch_Overlay_Webcam 					= object:GetWidget('Twitch_Overlay_Webcam')	
		local Twitch_Overlay_Image 						= object:GetWidget('Twitch_Overlay_Image')	
		local Twitch_Overlay_Text 						= object:GetWidget('Twitch_Overlay_Text')	
		local Twitch_Overlay_Cancel 					= object:GetWidget('Twitch_Overlay_Cancel')	
		
		Twitch_Overlay_Remove:SetCallback('onclick', function(widget)
			GenericDialog(
				'twitch_remove_all', '', 'twitch_remove_all_confirm', 'general_ok', 'general_cancel', 
					function()  TwitchEdit.Reset() end,
					function()  end
			)			 
		end)		
		
		Twitch_Overlay_Webcam:SetCallback('onclick', function(widget)
			 TwitchEdit.AddWebcam()
		end)
		
		Twitch_Overlay_Image:SetCallback('onclick', function(widget)
			 TwitchEdit.AddImage()
		end)	

		Twitch_Overlay_Text:SetCallback('onclick', function(widget)
			 TwitchEdit.AddText()
		end)		
		
		Twitch_Overlay_Save:SetCallback('onclick', function(widget)
			TwitchEdit.Save()
			TwitchEdit.DisableEditor()	
		end)
		
		Twitch_Overlay_Revert:SetCallback('onclick', function(widget)
			if (TwitchEdit.stateTrigger.unsavedChanges) then
				GenericDialog(
					'twitch_undo_changes', '', 'twitch_undo_changes_confirm', 'general_ok', 'general_cancel', 
						function()  
							TwitchEdit.Revert()				
						end,
						function()  end
				)
			else
				TwitchEdit.Revert()
			end				
		end)	
		
		Twitch_Overlay_Cancel:SetCallback('onclick', function(widget)
			if (TwitchEdit.stateTrigger.unsavedChanges) then
				GenericDialog(
					'twitch_undo_changes2', '', 'twitch_undo_changes_confirm2', 'general_ok', 'general_cancel', 
						function()  
							TwitchEdit.Revert()	
							TwitchEdit.DisableEditor()					
						end,
						function()  end
				)
			else
				TwitchEdit.Revert()	
				TwitchEdit.DisableEditor()
			end
		end)		
		
		Twitch_Overlays_Header_closex:SetCallback('onclick', function(widget)
			if (TwitchEdit.stateTrigger.unsavedChanges) then
				GenericDialog(
					'twitch_undo_changes2', '', 'twitch_undo_changes_confirm2', 'general_ok', 'general_cancel', 
						function()  
							TwitchEdit.Revert()	
							TwitchEdit.DisableEditor()					
						end,
						function()  end
				)
			else
				TwitchEdit.Revert()	
				TwitchEdit.DisableEditor()
			end
		end)		
		
		TwitchEdit.PopulateWidgetList()
		
		TwitchEdit.UpdateEditorWidgets()
		
	end
		
	function TwitchEdit.ToggleEditor()
		if object:GetWidget('twitch_command_layer') then
			if object:GetWidget('twitch_command_layer'):IsVisible() then
				TwitchEdit.DisableEditor()
			else
				TwitchEdit.EnableEditor()
			end
		end
	end

	local isLoaded = false
	function TwitchEdit.Init(force)
		local loginStatusTrigger = LuaTrigger.GetTrigger('LoginStatus')
		local mainPanelStatusTrigger = LuaTrigger.GetTrigger('mainPanelStatus')
		local TwitchStatus = LuaTrigger.GetTrigger('TwitchStatus')
		local GamePhase = LuaTrigger.GetTrigger('GamePhase')
		
		if (TwitchStatus.initialized) and (loginStatusTrigger.isLoggedIn) and (loginStatusTrigger.hasIdent) and (loginStatusTrigger.isIdentPopulated) and ((mainPanelStatusTrigger.main == 101) or (GamePhase.gamePhase > 0)) then
			if (force) or (not isLoaded) then
				
				mainUI.savedLocally.TwitchEdit = mainUI.savedLocally.TwitchEdit or {}
				mainUI.savedLocally.TwitchEdit.savedSettings = mainUI.savedLocally.TwitchEdit.savedSettings or {}				
				mainUI.savedLocally.TwitchEdit.widgetCount = mainUI.savedLocally.TwitchEdit.widgetCount or 1
				mainUI.savedLocally.TwitchEdit.widgets = mainUI.savedLocally.TwitchEdit.widgets or {}				
				
				isLoaded = true
				TwitchEdit.InstantiateAndRegisterWidgets(twitch_instantiate_layer, nil)			
				TwitchEdit.Load(true, false)

				TwitchEdit.stateTrigger.panelOpen = false
				TwitchEdit.stateTrigger.overlayVisible = false
				TwitchEdit.stateTrigger.unsavedChanges = false
				if (TwitchEdit.statusTrigger.loggedIn) then
					TwitchEdit.stateTrigger.panelState = 'main'	
				else
					TwitchEdit.stateTrigger.panelState = 'login'
				end
				TwitchEdit.stateTrigger:Trigger(false)		

				TwitchEdit.ingestServersTrigger:Trigger(true)			
				TwitchEdit.webCamDevicesTrigger:Trigger(true)			
				TwitchEdit.statusTrigger:Trigger(true)
				
			end
		end
	end

	local Twitch_Logged_Overlay 						= object:GetWidget('Twitch_Logged_Overlay')	
	
	Twitch_Logged_Overlay:SetCallback('onclick', function(widget)
		TwitchEdit.ToggleEditor()
	end)		
	
	object:GetWidget('twitch_command_layer'):RegisterWatchLua('GamePhase', function() TwitchEdit.Init(false) end)
	object:GetWidget('twitch_command_layer'):RegisterWatchLua('GameReinitialize', function() TwitchEdit.Init(false) end)
	object:GetWidget('twitch_command_layer'):RegisterWatchLua('LoginStatus', function() TwitchEdit.Init(false) end, false, nil, 'isIdentPopulated', 'hasIdent', 'isLoggedIn')
	object:GetWidget('twitch_command_layer'):RegisterWatchLua('mainPanelStatus', function() TwitchEdit.Init(false) end, false, nil, 'main')
	object:GetWidget('twitch_command_layer'):RegisterWatchLua('TwitchStatus', function() TwitchEdit.Init(false) end, false, nil, 'initialized')
	
	object:GetWidget('twitch_command_layer'):RegisterWatchLua('TwitchStatusMessage', function(widget, trigger)
		local text = trigger.text
		println('TwitchStatusMessage: ' .. tostring(text))
		if (text == 'TTV_EC_INVALID_AUTHTOKEN') or (text == 'TTV_EC_WEBAPI_RESULT_NO_AUTHTOKEN') then
			Twitch.Logout()
			GenericDialog(
				'twitch_error_title', '', TranslateOrNil(trigger.text) or Translate('twitch_error_generic'), 'general_ok', '',
					function()
					end,
					nil,
					true
			)
		elseif (trigger.isFatal) then
			Twitch.Logout()
			GenericDialog(
				'twitch_error_title', '', TranslateOrNil(trigger.text) or Translate('twitch_error_generic'), 'general_ok', '',
					function()
					end,
					nil,
					true
			)			
		end
	end, false)

end

if ((GetCvarString('host_videoDriver') == 'vid_d9')) and (Twitch) then
	Register(object)
end
