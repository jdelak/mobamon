-- Chat Manager
mainUI 					= mainUI 					or {}
mainUI.savedLocally 	= mainUI.savedLocally 		or {}
mainUI.savedRemotely 	= mainUI.savedRemotely 		or {}
mainUI.savedAnonymously	= mainUI.savedAnonymously 	or {}
local interface = object
local tinsert, tremove, tsort = table.insert, table.remove, table.sort

local chatUnreadMessageTrigger = LuaTrigger.GetTrigger('ChatUnreadMessageTrigger') or LuaTrigger.CreateCustomTrigger('ChatUnreadMessageTrigger', {
		{ name	=   'updatedChannel',		type	= 'string'},	
	}
)

local function register(object)

	local channelID = Windows.data.chat.channel.creatingChannelID
	local channelName = Windows.data.chat.channel.creatingChannelName
	
	local lastTitle
	local function UpdateUnreadCount()
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
	
	local function FocusChatWindow(self)
		if interface:GetWidget('overlay_chat_' .. 'channel_window'.. '_parent'):IsVisible() then
			interface:GetWidget('overlay_chat_' .. 'channel_window'.. '_parent'):BringToFront()
			interface:GetWidget('overlay_chat_channel_window_input'):SetFocus(true)
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

	local function ChatChannelFocusRegister(self, channelID, channelName, chatType)

		interface:GetWidget('overlay_chat_channel_window_input'):SetCallback('onmouseldown', function(widget) FocusChatWindow(self) end )
		interface:GetWidget('overlay_chat_channel_window_input'):SetCallback('onmouselup', function(widget) FocusChatWindow(self) end)
		interface:GetWidget('overlay_chat_channel_window_input'):SetCallback('onfocus', function(widget) 
			FocusChatWindow(widget) 
			Links.lastActiveChatInputBuffer = widget
			mainUI.chatManager.lastActiveChannelID = channelID		
		end)
		interface:GetWidget('overlay_chat_channel_window_input'):SetCallback('onclick', function(widget) FocusChatWindow(self) end)
		interface:GetWidget('overlay_chat_channel_window_input'):RefreshCallbacks()
		
		self:SetCallback('onmouseldown', function(self) FocusChatWindow(self) end)
		self:SetCallback('onmouselup', function(self) FocusChatWindow(self) end)
		self:SetCallback('onclick', function(self) FocusChatWindow(self) end)	
		self:SetCallback('onfocus', function(self) FocusChatWindow(self) end)	
		self:SetCallback('onstartdrag', function(self) FocusChatWindow(self) end)	
		self:SetCallback('onenddrag', function(self) FocusChatWindow(self) end)
		self:RefreshCallbacks()
		
		interface:GetWidget('overlay_chat_channel_window_input_btn'):SetCallback('onmouseldown', function(self) FocusChatWindow(self) end)
		interface:GetWidget('overlay_chat_channel_window_input_btn'):SetCallback('onmouselup', function(self) FocusChatWindow(self) end)
		interface:GetWidget('overlay_chat_channel_window_input_btn'):SetCallback('onfocus', function(self) FocusChatWindow(self) end)
		interface:GetWidget('overlay_chat_channel_window_input_btn'):SetCallback('onclick', function(self)
			interface:GetWidget('overlay_chat_channel_window_input'):ProcessInputLine()
			FocusChatWindow(self)
		end)		
		interface:GetWidget('overlay_chat_channel_window_input_btn'):RefreshCallbacks()	
		
		interface:GetWidget('overlay_chat_channel_window_frame'):SetCallback('onmouseldown', function(self) FocusChatWindow(self) end)
		interface:GetWidget('overlay_chat_channel_window_frame'):SetCallback('onmouselup', function(self) FocusChatWindow(self) end)
		interface:GetWidget('overlay_chat_channel_window_frame'):SetCallback('onclick', function(self) FocusChatWindow(self) end)	
		interface:GetWidget('overlay_chat_channel_window_frame'):RefreshCallbacks()
			
		interface:GetWidget('overlay_chat_channel_window_buffer'):SetCallback('onmouseldown', function(self) FocusChatWindow(self) end)
		interface:GetWidget('overlay_chat_channel_window_buffer'):SetCallback('onmouselup', function(self) FocusChatWindow(self) end)
		interface:GetWidget('overlay_chat_channel_window_buffer'):SetCallback('onfocus', function(self) FocusChatWindow(self) end)	
		interface:GetWidget('overlay_chat_channel_window_buffer'):SetCallback('onclick', function(self) FocusChatWindow(self) end)	
		interface:GetWidget('overlay_chat_channel_window_buffer'):RefreshCallbacks()

	end
		
	local function TeamInputBufferRegister(self, channelID, channelName, chatType)		

		self:SetOutputWidget(interface:GetWidget('overlay_chat_channel_window_output'))

		self:GetParent():RegisterWatchLua('KeyDown', function(widget, trigger) 	
			if (trigger.enter) then 
				local triggerPanelStatus		= LuaTrigger.GetTrigger('mainPanelStatus')
				if (self:IsVisible()) and (self:HasFocus()) then

				elseif (triggerPanelStatus.main == 40) and (mainUI.chatManager.channelAtFrontId == channelID) then
					if (not self:HasFocus()) then
						self:SetFocus(true)
					end	
				else

				end
			end
		end, true, nil, 'enter')
		
		self:GetParent():RegisterWatchLua('KeyDown', function(widget, trigger) 	
			if (trigger.esc) then
				if (self:HasFocus()) then
					self:SetFocus(false)
				end
			end
		end, true, nil, 'esc')

		self:SetChannelID(tostring(channelID))

	end

	local function InputBufferRegister(self, channelID, channelName, chatType)		
		
		self:SetOutputWidget(interface:GetWidget('overlay_chat_channel_window_output'))

		self:GetParent():RegisterWatchLua('KeyDown', function(widget, trigger) 	
			if (trigger.enter) then
				if (self:IsVisible()) and (self:HasFocus()) then

				elseif (mainUI.chatManager.lastActiveChannelID == channelID) then
					if (self:IsVisible()) and (not self:HasFocus()) then
						-- println('^g EnterPressedTrigger ')
						self:SetFocus(true)
					else
						-- println('^c EnterPressedTrigger 1')
					end		
				else
					-- println('^c EnterPressedTrigger 2')
				end
			end
		end, true, nil, 'enter')
		
		self:GetParent():RegisterWatchLua('KeyDown', function(widget, trigger) 	
			if (trigger.esc) then
				if (self:IsVisible()) and (self:HasFocus()) then
					self:SetFocus(false)
				end
			end
		end, true, nil, 'esc')

		self:SetChannelID(tostring(channelID)) 
		
		if (channelID == 'Game') then

			self:SetStream('all')
			self:SetInputLine('')
			self:RegisterWatchLua('mainPanelStatus', function(widget, trigger) 
				if (trigger.gamePhase <= 1) then
					widget:SetStream('all')
				else
					widget:SetStream('team')
				end
			end, false, nil, 'gamePhase')	
		
		else
			-- self:SetStream('public')
		end

		mainUI.SlashCommands.RegisterInput(self, channelID, channelName, chatType)

	end

	local function OutputBufferRegister(self, channelID, channelName, chatType)				
		
		self:SetInputWidget(interface:GetWidget('overlay_chat_channel_window_input'))

		-- println('^y OutputBufferRegister ' .. chatType)
		
		self:SetChannelID(tostring(channelID)) 
		
		if (channelID == 'Game') then
		
			self:SetBaseOverselfCursor('/core/cursors/k_text_select.cursor')
			self:SetBaseSenderOverselfCursor('/core/cursors/arrow.cursor')

			self:SetBaseFormat('{timestamp}{tag}{sender}: {message}')
			self:SetBaseTextColor('#ffffff')
			self:SetBaseSenderTextColor('#88FFff')
			self:SetBaseMessageTextColor('#ffffff')	
		
			self:SetStreamFormat('all', '{timestamp}{tag}{sender}: {message}')
			self:SetStreamTextColor('all', '#ffffff')
			self:SetStreamSenderTextColor('all', '#FFff88')
			self:SetStreamMessageTextColor('all', '#ffffff')
			
			self:SetStreamFormat('team', '{timestamp}{tag}{sender}: {message}')
			self:SetStreamTextColor('team', '#ffffff')
			self:SetStreamSenderTextColor('team', '#88FFff')
			self:SetStreamMessageTextColor('team', '#ffffff')
			
		elseif (channelID == 'Party') then
			
			self:SetBaseOverselfCursor('/core/cursors/k_text_select.cursor')
			self:SetBaseSenderOverselfCursor('/core/cursors/arrow.cursor')

			self:SetBaseFormat('{timestamp}{tag}{sender}: {message}')
			self:SetBaseTextColor('#ffffff')
			self:SetBaseSenderTextColor('#88FFff')
			self:SetBaseMessageTextColor('#ffffff')		
			
			self:SetStreamFormat('all', '{timestamp}{tag}{sender}: {message}')
			self:SetStreamTextColor('all', '#ffffff')
			self:SetStreamSenderTextColor('all', '#FFff88')
			self:SetStreamMessageTextColor('all', '#ffffff')
			
			self:SetStreamFormat('team', '{timestamp}{tag}{sender}: {message}')
			self:SetStreamTextColor('team', '#ffffff')
			self:SetStreamSenderTextColor('team', '#88FFff')
			self:SetStreamMessageTextColor('team', '#ffffff')	
		
			-- self:RegisterWatchLua('HeroSelectInfo', function(widget, trigger)
				-- if (trigger.type == 'party') then
					-- self:SetStream('all')
					-- self:SetInputLine('')
				-- else
					-- self:SetStream('team')
					-- self:SetInputLine('')		
				-- end
			-- end, false, nil, 'type')		
			
		else
			
			self:SetBaseOverselfCursor('/core/cursors/k_text_select.cursor')
			self:SetBaseSenderOverselfCursor('/core/cursors/arrow.cursor')

			self:SetBaseFormat('{timestamp}{tag}{sender}: {message}')
			self:SetBaseTextColor('#ffffff')
			self:SetBaseSenderTextColor('#88FFff')
			self:SetBaseMessageTextColor('#ffffff')
			
			self:SetStreamFormat('public', '{timestamp}{tag}{sender}: {message}')
			self:SetStreamTextColor('public', '#ffffff')
			self:SetStreamSenderTextColor('public', '#88FFff')
			self:SetStreamMessageTextColor('public', '#ffffff')
			-- self:SetStreamOverselfOutline('public', true)
			-- self:SetStreamSenderOverselfOutlineColor('public', 'lime')
			-- self:SetStreamSenderOverselfTextColor('public', '#0000ff')
			-- self:SetStreamSenderOverselfUnderline('public', true)
			-- self:SetStreamMessageOverselfOutlineColor('public', 'blue')
			-- self:SetStreamMessageOverselfUnderline('public', true)
			-- self:SetStreamOverselfColorCodeFactor('public', 0.5)
			-- self:SetStreamOversiblingOutline('public', true)
			-- self:SetStreamOversiblingOutlineColor('public', '#ff0000')
			-- self:SetStreamOversiblingColorCodeFactor('public', 0.5)	
			-- self:SetStreamOversiblingTextColor('public', '#70ff70')
			-- self:SetStreamOversiblingShadowColor('public', '#ffffff')
			-- self:SetStreamSenderOversiblingUnderline('public', true)
			-- self:SetStreamMessageOversiblingOutlineColor('public', 'blue')
			
			self:SetStreamFormat('member', '{timestamp}{member_chat} {sender}: {message}')
			self:SetStreamTextColor('member', '#88FF88')
			self:SetStreamSenderTextColor('member', '#88FF88')
			self:SetStreamMessageTextColor('member', '#88FF88')
			
			self:SetStreamFormat('officer', '{timestamp}{officer_chat} {sender}: {message}')
			self:SetStreamTextColor('officer', '#ffaa00')
			self:SetStreamSenderTextColor('officer', '#ffaa00')
			self:SetStreamMessageTextColor('officer', '#ffaa00')
			
			self:SetBaseSenderOverselfTextColor('#ffff88')
			self:SetBaseMessageOversiblingTextColor('#00bbff')
			self:SetBaseMessageOverselfTextColor('#00bbff')
		end
	end

	local function isWindowInLauncherBounds(window)
		
		local launcherMainInterfaceWidget = UIManager.GetInterface('main')
		
		if (window) and (window:IsValid()) and (launcherMainInterfaceWidget) and (launcherMainInterfaceWidget:IsValid()) then

			local launcherLeftBound, launcherTopBound 		= System.WindowClientToScreen(0, 0)
			local launcherRightBound, launcherBottomBound 	= System.WindowClientToScreen(launcherMainInterfaceWidget:GetWidth(), launcherMainInterfaceWidget:GetHeight()) -- GetScreenWidth(), GetScreenHeight() seem to be using the window they are called from
			
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
		if window and isWindowInLauncherBounds(window) then
			window:SetOwnerMainWindow()
		else
			window:SetOwner(nil)
		end
	end	
	
	interface:GetWidget('overlay_chat_channel_window_header_label'):SetText(Translate(channelName))
	
	interface:GetWidget('overlay_chat_channel_window_header_dragger'):SetCallback('onmouselup', function(widget)
		mainUI.chatManager.SaveChatWindowPositionAndSize(self, 'channel', channelID)
		DockToLauncherIfPossible()
		FocusChatWindow(widget)		
	end)
	
	interface:GetWidget('overlay_chat_channel_window_parent'):SetCallback('onmouselup', function(widget)
		mainUI.chatManager.SaveChatWindowPositionAndSize(widget, 'channel', channelID)
		DockToLauncherIfPossible()
		FocusChatWindow(widget)
	end)
	
	interface:GetWidget('overlay_chat_channel_window_parent'):SetCallback('onenddrag', function(widget)
		mainUI.chatManager.SaveChatWindowPositionAndSize(widget, 'channel', channelID)
		DockToLauncherIfPossible()
		FocusChatWindow(widget)
	end)	
	
	interface:GetWidget('overlay_chat_channel_window_memberlist_button'):SetCallback('onclick', function(widget)
		if widget:GetWidget('overlay_chat_channel_window_parent_right_container'):IsVisible() then
			widget:GetWidget('overlay_chat_channel_window_parent_right_container'):FadeOut(100)
			widget:GetWidget('overlay_chat_channel_window_parent_left_container'):ScaleWidth('100%', 250, false)
			mainUI.savedLocally.openMemberlists[channelID] = nil
		else
			widget:GetWidget('overlay_chat_channel_window_parent_right_container'):FadeIn(250)
			widget:GetWidget('overlay_chat_channel_window_parent_left_container'):ScaleWidth('-180s', 100, false)
			mainUI.savedLocally.openMemberlists[channelID] = true
		end
		FocusChatWindow(widget)
	end)
	
	interface:GetWidget('overlay_chat_channel_window_memberlist_button'):SetCallback('oninstantiate', function(widget)
		if (mainUI.savedLocally.openMemberlists) and (mainUI.savedLocally.openMemberlists[channelID]) then
			widget:GetWidget('overlay_chat_channel_window_parent_right_container'):FadeIn(250)
			widget:GetWidget('overlay_chat_channel_window_parent_left_container'):ScaleWidth('-180s', 100, false)								
		end
	end)	
	
	interface:GetWidget('overlay_chat_channel_window_minimise_button'):SetCallback('onclick', function(widget)
		mainUI.chatManager.ClickedPinnedChatTab(widget, channelName, channelID, false, true, 'channel')
	end)
	
	if (channelID ~= 'Party') and  (channelID ~= 'Lobby') and  (channelID ~= 'Game') then
		interface:GetWidget('overlay_chat_channel_window_close_button'):SetCallback('onclick', function(widget)
			mainUI.LeavePinnedChannel(widget, channelID)
		end)
	else
		interface:GetWidget('overlay_chat_channel_window_close_button'):SetVisible(0)
	end
	
	local function UpdateMemberlist(channelID, removeIdentID)
		local channelID = tostring(channelID)
		
		if (not interface:GetWidget('overlay_chat_channel_window_memberlist_listbox')) then
			return
		end
		
		local lastScrollValue = interface:GetWidget('overlay_chat_channel_window_memberlist_listbox_vscroll'):GetValue()
		
		-- interface:GetWidget('overlay_chat_channel_window_memberlist_listbox'):ClearItems() 

		if (not mainUI.chatManager.memberlist[channelID]) then
			return
		end

		-- local indexTable = {}
		-- for i,v in pairs(mainUI.chatManager.memberlist[channelID]) do
			-- tinsert(indexTable, v)
		-- end

		-- table.sort(indexTable, function(a,b) return ( (a.playerName) and (b.playerName) and (string.lower(a.playerName) < string.lower(b.playerName)) ) end) -- using listbox to sort until swap to reuse widget method

		if (removeIdentID) and (interface:GetWidget('overlay_chat_channel_window_memberlist_listbox'):HasListItem(removeIdentID)) then
			interface:GetWidget('overlay_chat_channel_window_memberlist_listbox'):EraseListItemByValue(removeIdentID)
		end
		
		local count = 0
		for identID, accountTable in pairs(mainUI.chatManager.memberlist[channelID]) do
			
			if (interface:GetWidget('overlay_chat_channel_window_memberlist_listbox'):HasListItem(accountTable.identID)) then
				-- they already exist
			else
				local chatNameColorPath = accountTable.chatNameColorPath

				if (not chatNameColorPath) or Empty(chatNameColorPath) then
					if (accountTable.isStaff) then
						chatNameColorPath = '#e82000'
					else
						chatNameColorPath = 'white'
					end
				end
				
				local accountIconPath = accountTable.accountIconPath

				if (not accountIconPath) or Empty(accountIconPath) then 
					accountIconPath = '/ui/shared/textures/user_icon.tga'
				elseif (accountTable.isStaff) and (accountIconPath) and (accountIconPath == '/ui/shared/textures/account_icons/default.tga') then
					accountIconPath = '/ui/shared/textures/account_icons/s2staff.tga'	
				end

				local playerName = accountTable.playerName
				
				if (accountTable) and (accountTable.clanTag) and (not Empty(accountTable.clanTag)) then
					playerName = (('[' .. (accountTable.clanTag or '') ..']') .. (playerName or ''))
				end					
				
				mainUI.savedRemotely.friendDatabase = mainUI.savedRemotely.friendDatabase or {}
				if (mainUI.savedRemotely.friendDatabase) and (mainUI.savedRemotely.friendDatabase[accountTable.identID]) and (mainUI.savedRemotely.friendDatabase[accountTable.identID].nicknameOverride) then
					playerName = mainUI.savedRemotely.friendDatabase[accountTable.identID].nicknameOverride
				end				
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

				interface:GetWidget('overlay_chat_channel_window_memberlist_listbox'):AddTemplateListItemWithSort('memberlist_entry_multiwindow_template', 
					accountTable.identID,
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
					'channelID', '_window',
					'spectatableGame', tostring(accountTable.spectatableGame)
				)	
				
				interface:GetWidget('overlay_chat_channel_window_memberlist_listbox'):SortListboxSortIndex(0)
			end
			
			count = count + 1
		end

		interface:GetWidget('overlay_chat_channel_window_memberlist_listbox_vscroll'):SetValue(lastScrollValue)
		
		if interface:GetWidget('overlay_chat_channel_window_member_label') then
			interface:GetWidget('overlay_chat_channel_window_member_label'):SetText(count)
		end
	end

	local function ChatChannelMember(sourceWidget, trigger)
		local incomingChannelID = tostring(trigger.channelID)
		
		mainUI.chatManager.memberlist[incomingChannelID] = mainUI.chatManager.memberlist[incomingChannelID] or {}
		if (trigger.leave) then
			mainUI.chatManager.memberlist[incomingChannelID][trigger.identID] = nil
			if (incomingChannelID == channelID) then
				UpdateMemberlist(channelID, trigger.identID)	
			end
		else
			local identID = string.gsub(trigger.identID, '%.', '')
			local chatClientInfoTrigger = LuaTrigger.GetTrigger('ChatClientInfo' .. identID)
			
			local isStaff = (chatClientInfoTrigger and chatClientInfoTrigger.isStaff) or false

			mainUI.chatManager.memberlist[incomingChannelID][trigger.identID] = {
				channelID = incomingChannelID,
				playerName = trigger.playerName,
				clanTag = trigger.clanTag,
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
				isStaff = isStaff,
			}
			if (incomingChannelID == channelID) then
				UpdateMemberlist(channelID)
			end
		end
	end
	interface:GetWidget('overlay_chat_channel_window_parent'):RegisterWatchLua(
		'ChatChannelMember', function(sourceWidget, trigger)
				ChatChannelMember(sourceWidget, trigger)
			end, --callback
			false --duplicates_allowed
			--key
			--param_indices_to_watch
	)	
	UpdateMemberlist(channelID)
	
	ChatChannelFocusRegister(interface:GetWidget('overlay_chat_channel_window_parent'), channelID, channelName, 'channel')
	OutputBufferRegister(interface:GetWidget('overlay_chat_channel_window_output'), channelID, channelName, 'channel')	
	InputBufferRegister(interface:GetWidget('overlay_chat_channel_window_input'), channelID, channelName, 'channel')		

	interface:GetWidget('overlay_chat_channel_window_parent'):RegisterWatchLua('ChatUnreadMessageTrigger', function(sourceWidget, trigger)
		UpdateUnreadCount()
	end)		

end
register(object)
	
	