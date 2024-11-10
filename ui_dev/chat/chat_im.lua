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

	local channelID = Windows.data.chat.im.creatingChannelID
	local channelName = Windows.data.chat.im.creatingChannelName

	local lastTitle	
	local function UpdateUnreadCount()	
		if (interface) and (interface:IsValid()) then
			if (interface:GetWindow()) and (interface:GetWindow():IsValid()) then
				if (mainUI.chatManager) and (mainUI.chatManager.unreadMessages) and (mainUI.chatManager.unreadMessages[tostring(channelID)]) and (mainUI.chatManager.unreadMessages[tostring(channelID)] > 0) then
					if (mainUI.chatManager.unreadMessages[tostring(channelID)] >= 9) then
						mainUI.chatManager.unreadMessages[tostring(channelID)] = 9
					end					
					if (lastTitle == nil) or (lastTitle ~= '[+' .. mainUI.chatManager.unreadMessages[tostring(channelID)] .. '] ' .. channelName) then
						interface:GetWindow():SetWindowTitle('[+' .. mainUI.chatManager.unreadMessages[tostring(channelID)] .. '] ' .. channelName)
					end
					lastTitle = '[+' .. mainUI.chatManager.unreadMessages[tostring(channelID)] .. '] ' .. channelName
				else
					if (lastTitle == nil) or (lastTitle ~= channelName) then
						interface:GetWindow():SetWindowTitle(channelName)
					end
					lastTitle = channelName
				end
			end
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

		self:SetIdentID(tostring(channelID))

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

		self:SetIdentID(tostring(channelID))
		
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
		
		self:SetIdentID(tostring(channelID))
		
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
		mainUI.chatManager.SaveChatWindowPositionAndSize(widget, 'channel', channelID)
		DockToLauncherIfPossible()
		FocusChatWindow(widget)
	end)	
	
	interface:GetWidget('overlay_chat_channel_window_minimise_button'):SetCallback('onclick', function(widget)
		mainUI.chatManager.ClickedPinnedChatTab(widget, channelName, channelID, true, true, 'pm')
	end)
	
	interface:GetWidget('overlay_chat_channel_window_close_button'):SetCallback('onclick', function(widget)
		mainUI.LeavePinnedChannel(widget, channelID)
	end)
	
	interface:GetWidget('overlay_chat_channel_window_parent'):SetCallback('onmouselup', function(widget)
		mainUI.chatManager.SaveChatWindowPositionAndSize(widget, 'im', channelID)
		DockToLauncherIfPossible()
		FocusChatWindow(widget)
	end)
	
	interface:GetWidget('overlay_chat_channel_window_parent'):SetCallback('onenddrag', function(widget)
		mainUI.chatManager.SaveChatWindowPositionAndSize(widget, 'im', channelID)
		DockToLauncherIfPossible()
		FocusChatWindow(widget)
	end)	
	
	ChatChannelFocusRegister(interface:GetWidget('overlay_chat_channel_window_parent'), channelID, channelName, 'channel')
	OutputBufferRegister(interface:GetWidget('overlay_chat_channel_window_output'), channelID, channelName, 'channel')	
	InputBufferRegister(interface:GetWidget('overlay_chat_channel_window_input'), channelID, channelName, 'channel')		
	
	local function UserActionsRegister()
		
		local function UpdateUserActions(trigger)
			if (interface) and (interface:IsValid()) then
			
				local ignoreBtn = interface:GetWidget('overlay_chat_channel_window_ignore_button')
				if (ignoreBtn) and (ignoreBtn:IsValid()) then	
					
					local friendData = Friends.main.GetFriendDataFromIdentID(channelID)
					
					if (friendData) then
					
						if ChatClient.IsIgnored(channelID) then
							ignoreBtn:SetColor("1 0 0 1") 
						else
							ignoreBtn:SetColor("#a9d6e4")
						end		
						ignoreBtn:SetCallback('onmouseover', function(widget)
							if ChatClient.IsIgnored(channelID) then
								simpleMultiWindowTipGrowYUpdate(true, nil, Translate('social_action_bar_removeignore'), Translate('general_remove_ignore'), libGeneral.HtoP(80))
							else
								simpleMultiWindowTipGrowYUpdate(true, nil, Translate('social_action_bar_ignore'), Translate('general_add_ignore'), libGeneral.HtoP(80))
							end
						end)	
						ignoreBtn:SetCallback('onmouseout', function(widget)
							simpleMultiWindowTipGrowYUpdate(false)
						end)	
						ignoreBtn:SetCallback('onclick', function(widget)
							if ChatClient.IsIgnored(channelID) then
								ChatClient.RemoveIgnore(channelID)
							else
								ChatClient.AddIgnore(channelID)
							end
						end)
						ignoreBtn:SetVisible(ChatClient.IsOnline(channelID))			
						
						local overlay_chat_channel_window_header_label = interface:GetWidget('overlay_chat_channel_window_header_label')
						local overlay_chat_channel_window_status_light = interface:GetWidget('overlay_chat_channel_window_status_light')
						local overlay_chat_channel_window_status_label = interface:GetWidget('overlay_chat_channel_window_status_label')
				
						local statusColor = '.3 .2 .2 .7'
						local statusText = Translate('friend_online_status_offline')	
						
						if (friendData) and (friendData.isInMyParty) and (friendData.isPending) then
							statusColor = '#FF9100' -- orange	
							statusText = Translate('friend_online_status_partypending')
						elseif (trigger) and (trigger.userStatus == 7) and ((friendData == nil) or (friendData.acceptStatus == nil) or (friendData.acceptStatus == 'approved')) then 
							statusColor = '0.7 0.7 0.7 0.3' -- faded gray
							statusText = Translate('friend_online_status_offline')		
							isOnline = false
						elseif (trigger) and (trigger.userStatus == 3) and ((friendData == nil) or (friendData.acceptStatus == nil) or (friendData.acceptStatus == 'approved')) then 
							statusColor = '#e82000' -- red
							statusText = Translate('friend_online_status_streaming')										
						elseif (trigger) and (trigger.userStatus == 5) and ((friendData == nil) or (friendData.acceptStatus == nil) or (friendData.acceptStatus == 'approved')) then 
							statusColor = '#e82000' -- red
							statusText = Translate('friend_online_status_dnd')			
						elseif (trigger) and ((trigger.userStatus == 1)) and (trigger.status == 1) and ((friendData == nil) or (friendData.acceptStatus == nil) or (friendData.acceptStatus == 'approved')) then
							statusColor = '#138dff' -- blue
							statusText = Translate('friend_online_status_lfg')
						elseif (trigger) and ((trigger.userStatus == 2)) and (trigger.status == 1) and ((friendData == nil) or (friendData.acceptStatus == nil) or (friendData.acceptStatus == 'approved')) then
							statusColor = '#138dff' -- blue
							statusText = Translate('friend_online_status_lfm')
						elseif (trigger) and ((trigger.userStatus == 4)) and ((friendData == nil) or (friendData.acceptStatus == nil) or (friendData.acceptStatus == 'approved')) then
							statusColor = '#FFFF00' -- yellow
							statusText = Translate('friend_online_status_afk')	
						elseif (trigger) and ((trigger.status == 2)) and ((friendData == nil) or (friendData.acceptStatus == nil) or (friendData.acceptStatus == 'approved')) then
							statusColor = '#FFFF00' -- yellow
							statusText = Translate('friend_online_status_idle')										
						elseif (trigger) and (trigger.status == 6) and ((friendData == nil) or (friendData.acceptStatus == nil) or (friendData.acceptStatus == 'approved')) then 
							statusColor = '#e82000' -- red
							statusText = Translate('friend_online_status_spectating')		 
						elseif (trigger) and (trigger.status == 5) and ((friendData == nil) or (friendData.acceptStatus == nil) or (friendData.acceptStatus == 'approved')) then 
							statusColor = '#e82000' -- red
							statusText = Translate('friend_online_status_practice')
						elseif (trigger) and (trigger.status == 4) and ((friendData == nil) or (friendData.acceptStatus == nil) or (friendData.acceptStatus == 'approved')) then 
							statusColor = '#e82000' -- red
							statusText = Translate('friend_online_status_ingame')			
						elseif (trigger) and ((trigger.status == 3) or (friendData.isInParty)) and ((friendData == nil) or (friendData.acceptStatus == nil) or ((friendData == nil) or (friendData.acceptStatus == nil) or (friendData.acceptStatus == 'approved'))) then
							statusColor = '#FF9100' -- orange	
							statusText = Translate('friend_online_status_inparty')
						elseif (friendData) and (friendData.isInLobby) and ((friendData.acceptStatus == nil) or (friendData.acceptStatus == 'approved')) then
							statusColor = '#FF9100' -- orange		
							statusText = Translate('friend_online_status_inlobby')						
						elseif (trigger) and (trigger.status == 1) and ((friendData == nil) or (friendData.acceptStatus == nil) or (friendData.acceptStatus == 'approved')) then
							statusColor = '#b7ff00' -- green
							statusText = Translate('friend_online_status_online')
						elseif (trigger) and (trigger.status == 0) then
							statusColor = '.7 .7 .7 1' -- faded gray red
							statusText = Translate('friend_online_status_offline')
						else
							statusColor = '.7 .7 .7 1'
							statusText = Translate('friend_online_status_unknown')
						end
						
						local userName = ''
						if (not friendData) or ((not friendData.isDuplicate) and (friendData.acceptStatus ~= 'pending')) then
							userName = friendData.name or '?NONAME1?'
						else
							userName = (friendData.name  or '?NONAME2?') .. '.' .. (friendData.uniqueID  or '?NOUNIQUEID2?')
						end
						
						local userNameColor = '1 1 1 1'
						if (trigger) and (trigger.isStaff) then
							userNameColor = '#e82000'
						else
							userNameColor = '1 1 1 1'
						end				
						
						overlay_chat_channel_window_status_label:SetText(statusText)
						overlay_chat_channel_window_status_label:SetColor(statusColor)
						overlay_chat_channel_window_status_light:SetColor(statusColor)
						overlay_chat_channel_window_header_label:SetText(userName)	
						overlay_chat_channel_window_header_label:SetColor(userNameColor)	
						
						local friendBtn = interface:GetWidget('overlay_chat_channel_window_friend_button')
						if (friendData and friendData.acceptStatus == "pending") then
							friendBtn:SetTexture("/ui/main/friends/textures/icon_friend_add.tga")
						elseif ChatClient.IsFriend(channelID) and ((friendData == nil) or (friendData.acceptStatus ~= 'rejected')) then
							friendBtn:SetTexture("/ui/main/friends/textures/icon_friend_remove.tga")
						else
							friendBtn:SetTexture("/ui/main/friends/textures/icon_friend_add.tga")
						end
						
						friendBtn:SetCallback('onmouseover', function(widget)
							local friendData = Friends.main.GetFriendDataFromIdentID(channelID)
							if (friendData and friendData.acceptStatus == "pending") then
								simpleMultiWindowTipGrowYUpdate(true, nil, Translate('general_accept_friend'), Translate('general_accept_friend'), libGeneral.HtoP(80))
							elseif ChatClient.IsFriend(channelID) then
								simpleMultiWindowTipGrowYUpdate(true, nil, Translate('general_remove_friend'), Translate('general_remove_friend'), libGeneral.HtoP(80))
							else
								simpleMultiWindowTipGrowYUpdate(true, nil, Translate('general_add_friend'), Translate('general_add_friend'), libGeneral.HtoP(80))
							end						
						end)	
						friendBtn:SetCallback('onmouseout', function(widget)
							simpleMultiWindowTipGrowYUpdate(false)
						end)						
						
						friendBtn:SetCallback('onclick', function(widget)
							local friendData = Friends.main.GetFriendDataFromIdentID(channelID)
							if (friendData and friendData.acceptStatus == "pending") then
								ChatClient.SetFriendStatus(channelID, 'approved')
							elseif ChatClient.IsFriend(channelID) then
								ChatClient.RemoveFriend(channelID)
							else
								ChatClient.AddFriend(channelID)
								friendBtn:SetVisible(false)
							end
						end)
						friendBtn:SetVisible(ChatClient.IsOnline(channelID) and not (friendData and friendData.acceptStatus == "sent"))	
					
						local inviteBtn = interface:GetWidget('overlay_chat_channel_window_invite_button')
						inviteBtn:SetVisible(ChatClient.IsOnline(channelID))
						inviteBtn:SetCallback('onclick', function(widget)
							if (LuaTrigger.GetTrigger('HeroSelectInfo').type == 'lobby') and (LuaTrigger.GetTrigger('HeroSelectMode').isCustomLobby) then
								ChatClient.GameInvite(channelID)
							elseif (not LuaTrigger.GetTrigger('HeroSelectMode').isCustomLobby) then 
								ChatClient.PartyInvite(channelID)
								local partyCustomTrigger 		= LuaTrigger.GetTrigger('PartyTrigger')
								partyCustomTrigger.userRequestedParty = true
								partyCustomTrigger:Trigger(false)
							end
						end)
						
						inviteBtn:SetCallback('onmouseover', function(widget)
							simpleMultiWindowTipGrowYUpdate(true, nil, Translate('heroselect_inviteplayer'), Translate('ui_items_cc_right_click_invite_to_game'), libGeneral.HtoP(80))					
						end)	
						inviteBtn:SetCallback('onmouseout', function(widget)
							simpleMultiWindowTipGrowYUpdate(false)
						end)											
						
					end
				end
			end
		end
		
		if (channelID) then
			local friendsClientInfoTrigger = LuaTrigger.GetTrigger('ChatClientInfo' .. string.gsub(channelID, '%.', ''))
			if (friendsClientInfoTrigger) then	
				UnwatchLuaTriggerByKey('ChatClientInfo' .. string.gsub(channelID, '%.', ''), 'IMKey'..'ChatClientInfo' .. string.gsub(channelID, '%.', ''))
				WatchLuaTrigger('ChatClientInfo' .. string.gsub(channelID, '%.', ''), function(trigger)
					libThread.threadFunc(function()
						wait(10)						 
						UpdateUserActions(trigger)
					end)
				end, 'IMKey'..'ChatClientInfo' .. string.gsub(channelID, '%.', ''))
				UpdateUserActions(friendsClientInfoTrigger)
			end
		end

	end

	UserActionsRegister()

	UnwatchLuaTriggerByKey('ChatUnreadMessageTrigger', 'IMUnreadKey'..'ChatClientInfo' .. string.gsub(channelID, '%.', ''))
	WatchLuaTrigger('ChatUnreadMessageTrigger', function(trigger)
		UpdateUnreadCount()
	end, 'IMUnreadKey'..'ChatClientInfo' .. string.gsub(channelID, '%.', ''))	
	
end
register(object)
	
	