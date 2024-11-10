local interface = object

mainUI = mainUI or {}
mainUI.Clans = mainUI.Clans or {}
mainUI.Clans.Window = mainUI.Clans.Window or {}

local function RegisterClansWindow(object)
		
	local chatUnreadMessageTrigger = LuaTrigger.GetTrigger('ChatUnreadMessageTrigger') or LuaTrigger.CreateCustomTrigger('ChatUnreadMessageTrigger', {
			{ name	=   'updatedChannel',		type	= 'string'},	
		}
	)	
	
	local channelID = 'Clan'
	
	-- println('RegisterClansWindow 1/2')
	
	local slashInit = false
	
	local function RegisterBuffers(object)
	
		local outputBuffer 			= object:GetWidget('clans_window_output')
		local inputBuffer 			= object:GetWidget('clans_window_input')
	
		outputBuffer:SetClan()
		inputBuffer:SetClan()
		mainUI.SlashCommands.RegisterInput(inputBuffer, 'clan', 'clan', 'channel')

		outputBuffer:SetBaseOverselfCursor('/core/cursors/k_text_select.cursor')
		outputBuffer:SetBaseSenderOverselfCursor('/core/cursors/arrow.cursor')

		outputBuffer:SetBaseFormat('{timestamp}{sender}: {message}')
		outputBuffer:SetBaseTextColor('#ffffff')
		outputBuffer:SetBaseSenderTextColor('#88FFff')
		outputBuffer:SetBaseMessageTextColor('#ffffff')

		outputBuffer:SetStreamFormat('member', '{timestamp}{sender}: {message}')
		outputBuffer:SetStreamTextColor('member', '#ffffff')
		outputBuffer:SetStreamSenderTextColor('member', '#88FFff')
		outputBuffer:SetStreamMessageTextColor('member', '#ffffff')
		
		outputBuffer:SetStreamFormat('officer', '{timestamp}{officer_chat}{sender}: {message}')
		outputBuffer:SetStreamTextColor('officer', '#b7ff00')
		outputBuffer:SetStreamSenderTextColor('officer', '#b7ff00')
		outputBuffer:SetStreamMessageTextColor('officer', '#b7ff00')
		
		outputBuffer:SetStreamFormat('owner', '{timestamp}{owner_chat}{sender}: {message}')
		outputBuffer:SetStreamTextColor('owner', '#ff2200')
		outputBuffer:SetStreamSenderTextColor('owner', '#ff2200')
		outputBuffer:SetStreamMessageTextColor('owner', '#ff2200')

		outputBuffer:SetStreamFormat('chat_command', '{timestamp}{sender}: {message}')
		outputBuffer:SetStreamTextColor('chat_command', '#ffffff')
		outputBuffer:SetStreamSenderTextColor('chat_command', '#88FFff')
		outputBuffer:SetStreamMessageTextColor('chat_command', '#ffffff')		
		
		outputBuffer:SetBaseSenderOverselfTextColor('#ffff88')
		outputBuffer:SetBaseMessageOversiblingTextColor('#00bbff')
		outputBuffer:SetBaseMessageOverselfTextColor('#00bbff')	
		
		inputBuffer:SetOutputWidget(outputBuffer)
		
		inputBuffer:GetParent():RegisterWatchLua('KeyDown', function(widget, trigger) 	
			if (trigger.enter) then
				if (inputBuffer:IsVisible()) and (inputBuffer:HasFocus()) then

				else
					if (inputBuffer:IsVisible()) and (not inputBuffer:HasFocus()) then
						inputBuffer:SetFocus(true)
					end
				end
			end
		end, true, nil, 'enter')
		
		inputBuffer:GetParent():RegisterWatchLua('KeyDown', function(widget, trigger) 	
			if (trigger.esc) then
				if (inputBuffer:IsVisible()) and (inputBuffer:HasFocus()) then
					inputBuffer:SetFocus(false)
				end
			end
		end, true, nil, 'esc')

		inputBuffer:SetStream('team')
		inputBuffer:SetInputLine('')

		
	end
	
	RegisterBuffers(object)

	local channelID = 'Clan'
	local channelName = 'Clan'
	
	local lastTitle
	local function UpdateUnreadCount()
		println('UpdateUnreadCount')
		if (mainUI.chatManager) and (mainUI.chatManager.unreadMessages) and (mainUI.chatManager.unreadMessages[tostring(channelID)]) and (mainUI.chatManager.unreadMessages[tostring(channelID)] > 0) then
			if (mainUI.chatManager.unreadMessages[tostring(channelID)] >= 9) then
				mainUI.chatManager.unreadMessages[tostring(channelID)] = 9
			end
			if (lastTitle == nil) or (lastTitle ~= '[+' .. mainUI.chatManager.unreadMessages[tostring(channelID)] .. '] ' .. Translate(channelName)) then
				interface:GetWindow():SetWindowTitle('[+' .. mainUI.chatManager.unreadMessages[tostring(channelID)] .. '] ' .. Translate(channelName))
			end
			lastTitle = '[+' .. mainUI.chatManager.unreadMessages[tostring(channelID)] .. '] ' .. Translate(channelName)
		else
			if (lastTitle == nil) or (lastTitle ~= Translate(channelName)) then
				interface:GetWindow():SetWindowTitle(Translate(channelName))
			end
			lastTitle = Translate(channelName)
		end	
	end		
	
	local function FocusChatWindow(inWidget)
		println('FocusChatWindow')
		local windowRef = inWidget:GetWindow()
		if windowRef:GetActiveInterface():GetWidget('clans_window_parent'):IsVisible() then
			local chatUnreadMessageTrigger = LuaTrigger.GetTrigger('ChatUnreadMessageTrigger')
			windowRef:GetActiveInterface():GetWidget('clans_window_parent'):BringToFront()
			windowRef:GetActiveInterface():GetWidget('clans_window_input'):SetFocus(true)
			mainUI.chatManager = mainUI.chatManager or {}
			mainUI.chatManager.channelAtFrontId = channelID
			mainUI.chatManager.unreadMessages = mainUI.chatManager.unreadMessages or {}
			mainUI.chatManager.unreadMessages[tostring(channelID)] = 0			
			mainUI.chatManager.lastActiveChannelID = channelID	
			chatUnreadMessageTrigger.updatedChannel = '-1'
			chatUnreadMessageTrigger:Trigger(true)
			UpdateUnreadCount()
		end
	end	
	
	local function isWindowInLauncherBounds(window)
		
		local launcherMainInterfaceWidget = UIManager.GetInterface('main')
		
		if (window) and (window:IsValid()) and (launcherMainInterfaceWidget) and (launcherMainInterfaceWidget:IsValid()) then

			local launcherLeftBound, launcherTopBound 		= Host.GetMainWindow():ClientToScreen(0, 0)
			local launcherRightBound, launcherBottomBound 	= Host.GetMainWindow():ClientToScreen(launcherMainInterfaceWidget:GetWidth(), launcherMainInterfaceWidget:GetHeight()) -- GetScreenWidth(), GetScreenHeight() seem to be using the window they are called from
			
			local friendsWindowLeftBound, friendsWindowTopBound = window:GetX(), window:GetY()
			local friendsWindowRightBound, friendsWindowBottomBound = friendsWindowLeftBound + window:GetWidth(), friendsWindowTopBound + window:GetHeight()
			
			
			if  (friendsWindowLeftBound >= launcherLeftBound) and
				(friendsWindowRightBound <= launcherRightBound) and
				(friendsWindowTopBound >= launcherTopBound) and
				(friendsWindowBottomBound <= launcherBottomBound) then
				return true
			end	
		end
		return false
	end	
	
	local function DockToLauncherIfPossible()
		local window = interface:GetWindow()
		-- if window and isWindowInLauncherBounds(window) then
			-- window:SetOwnerMainWindow()
		-- else
			if (window) then
				window:SetOwner(nil)
			end
		-- end
	end	
	
	interface:GetWidget('clans_window_header_label'):SetText(Translate('window_name_brawl_club'))
	
	interface:GetWidget('clans_window_header_dragger'):SetCallback('onmouselup', function(widget)
		mainUI.chatManager.SaveChatWindowPositionAndSize(self, 'channel', channelID)
		DockToLauncherIfPossible()
		FocusChatWindow(widget)		
	end)
	
	interface:GetWidget('clans_window_parent'):SetCallback('onmouselup', function(widget)
		mainUI.chatManager.SaveChatWindowPositionAndSize(widget, 'channel', channelID)
		DockToLauncherIfPossible()
		FocusChatWindow(widget)
	end)
	
	interface:GetWidget('clans_window_parent'):SetCallback('onenddrag', function(widget)
		mainUI.chatManager.SaveChatWindowPositionAndSize(widget, 'channel', channelID)
		DockToLauncherIfPossible()
		FocusChatWindow(widget)
	end)	
	
	interface:GetWidget('clans_window_memberlist_button'):SetCallback('onclick', function(widget)
		if widget:GetWidget('clans_window_parent_right_container'):IsVisible() then
			widget:GetWidget('clans_window_parent_right_container'):FadeOut(100)
			widget:GetWidget('clans_window_parent_left_container'):ScaleWidth('100%', 250, false)
			mainUI.savedLocally = mainUI.savedLocally or {}
			mainUI.savedLocally.openMemberlists = mainUI.savedLocally.openMemberlists or {}
			mainUI.savedLocally.openMemberlists[channelID] = nil
		else
			widget:GetWidget('clans_window_parent_right_container'):FadeIn(250)
			widget:GetWidget('clans_window_parent_left_container'):ScaleWidth('-180s', 100, false)
			mainUI.savedLocally = mainUI.savedLocally or {}
			mainUI.savedLocally.openMemberlists = mainUI.savedLocally.openMemberlists or {}			
			mainUI.savedLocally.openMemberlists[channelID] = true
		end
		FocusChatWindow(widget)
	end)
	
	interface:GetWidget('clans_window_memberlist_button'):SetCallback('oninstantiate', function(widget)
		if (mainUI.savedLocally.openMemberlists) and (mainUI.savedLocally.openMemberlists[channelID]) then
			widget:GetWidget('clans_window_parent_right_container'):FadeIn(250)
			widget:GetWidget('clans_window_parent_left_container'):ScaleWidth('-180s', 100, false)								
		end
	end)	
	
	interface:GetWidget('clans_window_minimise_button'):SetCallback('onclick', function(widget)
		mainUI.chatManager.ClickedPinnedChatTab(widget, channelName, channelID, false, true, 'channel')
	end)

	function mainUI.Clans.Window.UpdateMemberlist(inDetailedMemberlist)
		-- println('UpdateMemberlist')
		-- printr(inDetailedMemberlist)
		
		local channelID = tostring(channelID)
		
		if (not interface:GetWidget('clans_window_memberlist_listbox')) then
			println('^r missing clans_window_memberlist_listbox')
			return
		end
		
		local lastScrollValue = interface:GetWidget('clans_window_memberlist_listbox_vscroll'):GetValue()
		
		interface:GetWidget('clans_window_memberlist_listbox'):ClearItems()
		
		local count = 0
		local function IntantiateMemberByTable(inTable)
		
			-- println('IntantiateMemberByTable')
			-- printr(inTable)		
		
			if (inTable == nil) then return end
			
			for identID, accountTable in ipairs(inTable) do

				local chatNameColorPath = 'white'

				if (accountTable) and (accountTable.clanRank >= mainUI.Clans.rankEnum.COOWNER) then
					chatNameColorPath = '#e82000'
				elseif (accountTable) and (accountTable.clanRank >= mainUI.Clans.rankEnum.OFFICER) then
					chatNameColorPath = '#b7ff00'
				else
					chatNameColorPath = '1 1 1 1'
				end				

				local accountIconPath = accountTable.icon

				if (not accountIconPath) or Empty(accountIconPath) then 
					accountIconPath = '/ui/shared/textures/account_icons/default.tga'
				end

				local playerName = accountTable.name
				if (ClientInfo.duplicateUsernameTable[playerName]) then
					if (not IsInTable(ClientInfo.duplicateUsernameTable[playerName], accountTable.uniqueID)) then
						tinsert(ClientInfo.duplicateUsernameTable[playerName], accountTable.uniqueID)
					end
				else
					ClientInfo.duplicateUsernameTable[playerName] = {accountTable.uniqueID}
				end		

				if (#ClientInfo.duplicateUsernameTable[playerName] > 1) then
					playerName = playerName .. '.' .. accountTable.uniqueID
				end

				interface:GetWidget('clans_window_memberlist_listbox'):AddTemplateListItemWithSort('memberlist_entry_multiwindow_template', 
					accountTable.identID,
					string.lower(playerName) .. string.lower(accountTable.uniqueID), -- sort index is broken, use name sort instead
					'playerName', playerName,
					'clanName', '',
					'nameYPosition', '0.3h',
					'channelID', tostring(channelID),
					'labelColor', chatNameColorPath,
					'accountIcon', accountIconPath,
					'identID', accountTable.identID,
					'inGame', tostring(accountTable.isInGame),
					'inParty', tostring(false),
					'inLobby', tostring(false),
					'uniqueID', accountTable.uniqueID,
					'isFriend', tostring(ChatClient.IsFriend(accountTable.identID)),
					'joinableParty', tostring(false),
					'joinableGame', tostring(false),
					'gameAddress', '',
					'spectatableGame', tostring(accountTable.spectatableGame)
				)	
					
				interface:GetWidget('clans_window_memberlist_listbox'):SortListboxSortIndex(0)

				count = count + 1
			end
		end
		
		IntantiateMemberByTable(inDetailedMemberlist['voice'])
		IntantiateMemberByTable(inDetailedMemberlist['ingame'])
		IntantiateMemberByTable(inDetailedMemberlist['online'])
		
		interface:GetWidget('clans_window_memberlist_listbox_vscroll'):SetValue(lastScrollValue)
		
		if interface:GetWidget('clans_window_member_label') then
			interface:GetWidget('clans_window_member_label'):SetText(count)
		end
	end

	local function ChatChannelFocusRegister(self, channelID, channelName, chatType)

		interface:GetWidget('clans_window_input'):SetCallback('onmouseldown', function(widget) FocusChatWindow(self) end )
		interface:GetWidget('clans_window_input'):SetCallback('onmouselup', function(widget) FocusChatWindow(self) end)
		interface:GetWidget('clans_window_input'):SetCallback('onfocus', function(widget) 
			FocusChatWindow(widget) 
			Links.lastActiveChatInputBuffer = widget
			mainUI.chatManager.lastActiveChannelID = channelID		
		end)
		interface:GetWidget('clans_window_input'):SetCallback('onclick', function(widget) FocusChatWindow(self) end)
		interface:GetWidget('clans_window_input'):RefreshCallbacks()
		
		self:SetCallback('onmouseldown', function(self) FocusChatWindow(self) end)
		self:SetCallback('onmouselup', function(self) FocusChatWindow(self) end)
		self:SetCallback('onclick', function(self) FocusChatWindow(self) end)	
		self:SetCallback('onfocus', function(self) FocusChatWindow(self) end)	
		self:SetCallback('onstartdrag', function(self) FocusChatWindow(self) end)	
		self:SetCallback('onenddrag', function(self) FocusChatWindow(self) end)
		self:RefreshCallbacks()
		
		interface:GetWidget('clans_window_input_btn'):SetCallback('onmouseldown', function(self) FocusChatWindow(self) end)
		interface:GetWidget('clans_window_input_btn'):SetCallback('onmouselup', function(self) FocusChatWindow(self) end)
		interface:GetWidget('clans_window_input_btn'):SetCallback('onfocus', function(self) FocusChatWindow(self) end)
		interface:GetWidget('clans_window_input_btn'):SetCallback('onclick', function(self)
			interface:GetWidget('clans_window_input'):ProcessInputLine()
			FocusChatWindow(self)
		end)		
		interface:GetWidget('clans_window_input_btn'):RefreshCallbacks()
		
		interface:GetWidget('clans_window_frame'):SetCallback('onmouseldown', function(self) FocusChatWindow(self) end)
		interface:GetWidget('clans_window_frame'):SetCallback('onmouselup', function(self) FocusChatWindow(self) end)
		interface:GetWidget('clans_window_frame'):SetCallback('onclick', function(self) FocusChatWindow(self) end)	
		interface:GetWidget('clans_window_frame'):RefreshCallbacks()
			
		interface:GetWidget('clans_window_buffer'):SetCallback('onmouseldown', function(self) FocusChatWindow(self) end)
		interface:GetWidget('clans_window_buffer'):SetCallback('onmouselup', function(self) FocusChatWindow(self) end)
		interface:GetWidget('clans_window_buffer'):SetCallback('onfocus', function(self) FocusChatWindow(self) end)	
		interface:GetWidget('clans_window_buffer'):SetCallback('onclick', function(self) FocusChatWindow(self) end)	
		interface:GetWidget('clans_window_buffer'):RefreshCallbacks()

	end	
	
	ChatChannelFocusRegister(interface:GetWidget('clans_window_parent'), channelID, channelName, 'channel')

	interface:GetWidget('clans_window_parent'):RegisterWatchLua('ChatUnreadMessageTrigger', function(sourceWidget, trigger)
		UpdateUnreadCount()
	end)	

	interface:GetWidget('clans_window_togglemode_button'):SetCallback('onclick', function(widget)
		mainUI.Clans.ToggleMode()
	end)
	
	if (mainUI.Clans) and (mainUI.Clans.detailedClanList) then
		mainUI.Clans.Window.UpdateMemberlist(mainUI.Clans.detailedClanList)
	end
	
	function mainUI.Clans.Window.UpdateVoice(trigger)
		trigger = trigger or (GetMyChatClientInfo and GetMyChatClientInfo())
		
		local function UpdateVoiceJoinButton(trigger)
			if (trigger) then
				println('trigger.clanVoiceChannel ' .. trigger.clanVoiceChannel)
				if (trigger.clanVoiceChannel < 0) then
					interface:GetWidget('clans_window_voip_join_button_parent2'):SetVisible(1)
					interface:GetWidget('clans_window_voip_leave_button_parent2'):SetVisible(0)
				else		
					interface:GetWidget('clans_window_voip_join_button_parent2'):SetVisible(0)
					interface:GetWidget('clans_window_voip_leave_button_parent2'):SetVisible(1)
				end
				interface:GetWidget('clans_window_voip_join_button2'):SetCallback('onclick', function(widget)
					ChatClient.JoinClanVoiceChannel(0)
					interface:GetWidget('clans_window_voip_join_button_parent2'):SetVisible(0)
					interface:GetWidget('clans_window_voip_leave_button_parent2'):SetVisible(1)						
				end)	
				interface:GetWidget('clans_window_voip_leave_button2'):SetCallback('onclick', function(widget)
					ChatClient.LeaveClanVoiceChannel()
					interface:GetWidget('clans_window_voip_join_button_parent2'):SetVisible(1)
					interface:GetWidget('clans_window_voip_leave_button_parent2'):SetVisible(0)						
				end)
			end
		end
		
		UpdateVoiceJoinButton(trigger)
	end
	
	interface:GetWidget('clans_window_parent'):SetCallback('onshow', function(widget)
		mainUI.Clans.Window.UpdateVoice()
		interface:GetWindow():SetWindowTitle(Translate(channelName))
		UpdateUnreadCount()
	end)
	
	-- println('RegisterClansWindow 2/2')
	
end

RegisterClansWindow(object)