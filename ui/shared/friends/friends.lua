mainUI = mainUI or {}
Friends = Friends or {}
SocialClient = SocialClient or {}

local function FriendsRegister(object)
	
	local clientInfoDrag	= LuaTrigger.GetTrigger('clientInfoDrag')
	local globalDragInfo	= LuaTrigger.GetTrigger('globalDragInfo')	
	
	local socialclient_im_friendlist 					= UIManager.GetInterface('main'):GetWidget('socialclient_im_friendlist')
	local socialclient_im_friendlist_scrollbar 			= GetWidget('socialclient_im_friendlist_scrollbar')	
	local social_client_sizingframe 					= GetWidget('social_client_sizingframe')	
	
	local rowIndex = 0
	local headerIndex = 0	
	
	function Friends.Clicked(self, identID)
	
	end
	
	function Friends.DoubleClicked(self, identID)
	
	end	
	
	function Friends.RightClicked(self, identID)
		println('identID ' .. tostring(identID))
		local ContextMenuTrigger = LuaTrigger.GetTrigger('ContextMenuTrigger')
		if (identID) then
			local friendsClientInfoTrigger = LuaTrigger.GetTrigger('ChatClientInfo' .. identID)
			if (friendsClientInfoTrigger) then
				ContextMenuTrigger.selectedUserIdentID 			= friendsClientInfoTrigger.identID
				ContextMenuTrigger.selectedUserUsername 		= friendsClientInfoTrigger.name
				-- ContextMenuTrigger.selectedUserIsInGame			= {inGame}
				-- ContextMenuTrigger.selectedUserIsInParty		= {inParty}
				-- ContextMenuTrigger.selectedUserIsInLobby		= {inLobby}
				-- ContextMenuTrigger.spectatableGame			= {spectatableGame}
				ContextMenuTrigger.contextMenuArea = 1
				ContextMenuTrigger:Trigger(true)
			else
				ContextMenuTrigger.selectedUserIdentID 			= identID
				ContextMenuTrigger.contextMenuArea = 1
				ContextMenuTrigger:Trigger(true)			
			end
		end
	end		
	
	function Friends.StartDrag(self, identID)
	
	end			
	
	function Friends.EndDrag(self, identID)
	
	end		

	function Friends.OnMouseOver(self, identID)
	
	end	

	function Friends.GetFriendDataFromIdentID(identID)
		for i,v in pairs(Friends.friendData) do
			if (v.identID == identID) then
				return v
			end		
		end
		return nil
	end
	
	function Friends.OnStartDrag(self, identID)
		local data = Friends.GetFriendDataFromIdentID(identID)
		if (data) then
			clientInfoDrag.clientDraggingName			= data.name
			clientInfoDrag.clientDraggingUniqueID		= data.uniqueID
			clientInfoDrag.clientDraggingIdentID		= data.identID
			clientInfoDrag.clientDraggingCanSpectate	= data.isInGame or false
			clientInfoDrag.clientDraggingIsFriend		= data.isFriend or false
			clientInfoDrag.clientDraggingIsOnline		= data.isOnline or false
			clientInfoDrag.clientDraggingIsInGame		= data.isInGame or false
			clientInfoDrag.clientDraggingIsInParty		= data.isInParty or false
			clientInfoDrag.joinableGame					= (data.joinableGame or false)
			clientInfoDrag.joinableParty				= (data.joinableParty or false)					
			clientInfoDrag.spectatableGame				= (data.spectatableGame or false)
			clientInfoDrag.dragActive					= true
			clientInfoDrag:Trigger(false)	
		end
	end
	
	function Friends.OnEndDrag(self, identID)
		clientInfoDrag.dragActive			= false
		clientInfoDrag:Trigger(false)	
	end
	
	function Friends.RegisterFriend(self, identID)

		self:SetCallback('onclick', function(widget, trigger)
			println('onclick ' .. tostring(identID))
			Friends.Clicked(widget, identID)
		end)	
		self:SetCallback('ondoubleclick', function(widget, trigger)
			println('ondoubleclick ' .. tostring(identID))
			Friends.DoubleClicked(widget, identID)
		end)
		self:SetCallback('onrightclick', function(widget, trigger)
			println('onrightclick ' .. tostring(identID))
			Friends.RightClicked(widget, identID)
		end)		
		self:SetCallback('onmouseover', function(widget, trigger)
			println('onmouseover ' .. tostring(identID))
			Friends.OnMouseOver(widget, identID)
			UpdateCursor(widget, true, { canLeftClick = true, canRightClick = true, spendGems = false })
		end)	
		self:SetCallback('onmouseout', function(widget, trigger)
			println('onmouseout ' .. tostring(identID))
			Friends.OnMouseOut(widget, identID)
			UpdateCursor(widget, false, { canLeftClick = true, canRightClick = true, spendGems = false })
		end)
		self:SetCallback('onstartdrag', function(widget, trigger)
			println('onstartdrag ' .. tostring(identID))
			Friends.OnStartDrag(widget, identID)
		end)	
		self:SetCallback('onenddrag', function(widget, trigger)
			println('onenddrag ' .. tostring(identID))
			Friends.OnEndDrag(widget, identID)
		end)		
		
		globalDraggerReadTarget(self, function()
			println('globalDraggerReadTarget ' .. tostring(identID))
		end)
		globalDraggerRegisterSource(self, 11)
		
	end	

	local function FriendsUpdateRegister(object)
		
		function SocialClient.UpdateFriendsList()
			socialclient_im_friendlist:ClearChildren()
			
			local sortableTable = {}
			
			for i,friendInfo in pairs(Friends.friendData) do
				local displayGroup = 'online'
				if (friendInfo.buddyLabel == 'offline') or (friendInfo.buddyLabel == 'online') or (friendInfo.buddyLabel == 'search') or (friendInfo.buddyLabel == 'autocomplete')  or (friendInfo.buddyLabel == 'sent') or (friendInfo.buddyLabel == 'pending') or (friendInfo.buddyLabel == 'ignored') or (friendInfo.buddyLabel == 'rejected') then
					displayGroup = friendInfo.buddyLabel
				elseif (not friendInfo.isOnline) then
					displayGroup = 'offline'
				elseif (friendInfo.buddyLabel == "Friends") or (friendInfo.buddyLabel == "Default") then
					displayGroup = 'online'
				else
					displayGroup = friendInfo.buddyLabel
				end			
				sortableTable[displayGroup] = sortableTable[displayGroup] or {}
				table.insert(sortableTable[displayGroup], friendInfo)
			end
			
			for _, groupTable in pairs(sortableTable) do
				table.sort(groupTable, function(a,b) return string.lower(a.name) < string.lower(b.name) end)
			end
			
			groupfcall('socialclient_im_friendlist_row_group', function(_, widget) widget:Destroy() end)
			
			local FRIEND_ITEM_WIDTH = socialclient_im_friendlist:GetWidthFromString('98s')
			rowIndex = 0
			headerIndex = 0
			local spawnedHeaders = {}
			local spawnedRows = {}
			
			local function SpawnFriendsUsingGroupTable(groupTable, displayGroup)
				for i,friendInfo in pairs(groupTable) do	
					
					if (spawnedHeaders[displayGroup] == nil) then
						headerIndex = headerIndex + 1
						spawnedHeaders[displayGroup] = {}
						table.insert(spawnedHeaders[displayGroup], headerIndex)					
						socialclient_im_friendlist:Instantiate('socialclient_im_header_row_template', 'index', headerIndex, 'label', displayGroup)
						println('Creating new header ^y' .. tostring(displayGroup) .. ' ^g' .. headerIndex)
					end
					
					if (not spawnedRows[displayGroup]) then
						rowIndex = rowIndex + 1
						socialclient_im_friendlist:Instantiate('socialclient_im_friendlist_row_template', 'index', rowIndex, 'label', displayGroup)
						GetWidget('socialclient_im_friendlist_row_' .. rowIndex):Instantiate('socialclient_friend_iconmode_template', 'index', friendInfo.identID, 'userName', friendInfo.name, 'accountIcon', friendInfo.icon, 'identID', friendInfo.identID)
						spawnedRows[displayGroup] = {}
						table.insert(spawnedRows[displayGroup], {index = rowIndex, count = 1})
						println('Creating new row cus the header is new ^y' .. tostring(displayGroup) .. ' ^g' .. tostring(rowIndex))
					else
						local spawnedFriendItem = false
						for _,rowTable in ipairs(spawnedRows[displayGroup]) do
							local spawnedRowIndex = rowTable.index
							local rowWidget = GetWidget('socialclient_im_friendlist_row_' .. spawnedRowIndex)
							if (rowWidget) then
								local numItems = rowTable.count
								local rowWidth = FRIEND_ITEM_WIDTH * numItems
								if ((rowWidth) <= (socialclient_im_friendlist:GetWidth() - (FRIEND_ITEM_WIDTH * 0.82))) then
									spawnedFriendItem = true
									rowWidget:Instantiate('socialclient_friend_iconmode_template', 'index', friendInfo.identID, 'userName', friendInfo.name, 'accountIcon', friendInfo.icon, 'identID', friendInfo.identID)
									rowTable.count = rowTable.count + 1
									println('Inserting into existing row ^y' .. rowTable.count .. ' ' .. tostring(displayGroup) .. ' ^g' .. tostring(rowIndex))
								end
							end
						end
						if (not spawnedFriendItem) then
							rowIndex = rowIndex + 1
							socialclient_im_friendlist:Instantiate('socialclient_im_friendlist_row_template', 'index', rowIndex, 'label', displayGroup)
							GetWidget('socialclient_im_friendlist_row_' .. rowIndex):Instantiate('socialclient_friend_iconmode_template', 'index', friendInfo.identID, 'userName', friendInfo.name, 'accountIcon', friendInfo.icon, 'identID', friendInfo.identID)
							table.insert(spawnedRows[displayGroup], {index = rowIndex, count = 1})	
							println('Creating new row cus the other rows are full ^y' .. tostring(displayGroup) .. ' ^g' .. tostring(rowIndex))
						end
					end
				end
			end
			
			if (sortableTable) then
				if (sortableTable['search']) then
					SpawnFriendsUsingGroupTable(sortableTable['search'], 'search')
					sortableTable['search'] = nil
				end			
				if (sortableTable['autocomplete']) then
					SpawnFriendsUsingGroupTable(sortableTable['autocomplete'], 'autocomplete')
					sortableTable['autocomplete'] = nil
				end					
				for i,v in pairs(sortableTable) do
					if (i ~= 'offline') and (i ~= 'online')  and(i ~= 'Default') and (i ~= 'search')  and (i ~= 'autocomplete')  and (i ~= 'sent') and (i ~= 'pending') and (i ~= 'ignored') and (i ~= 'rejected') then
						SpawnFriendsUsingGroupTable(v, i)
						v = nil
					end
				end
				if (sortableTable['online']) then
					SpawnFriendsUsingGroupTable(sortableTable['online'], 'online')
					sortableTable['online'] = nil
				end
				if (sortableTable['pending']) then
					SpawnFriendsUsingGroupTable(sortableTable['pending'], 'pending')
					sortableTable['pending'] = nil
				end						
				if (sortableTable['offline']) then
					SpawnFriendsUsingGroupTable(sortableTable['offline'], 'offline')
					sortableTable['offline'] = nil
				end	
				if (sortableTable['sent']) then
					SpawnFriendsUsingGroupTable(sortableTable['sent'], 'sent')
					sortableTable['sent'] = nil
				end		
				if (sortableTable['ignored']) then
					SpawnFriendsUsingGroupTable(sortableTable['ignored'], 'ignored')
					sortableTable['ignored'] = nil
				end		
				if (sortableTable['rejected']) then
					SpawnFriendsUsingGroupTable(sortableTable['rejected'], 'rejected')
					sortableTable['rejected'] = nil
				end					
			end
			
			socialclient_im_friendlist_scrollbar:SetMaxValue(headerIndex + rowIndex)
			
		end
		
	end
	
	local function WatchFriend(identID, nameCatUniqueID, infoTable)
		local friendsClientInfoTrigger = LuaTrigger.GetTrigger('ChatClientInfo' .. identID)
		if (friendsClientInfoTrigger) then
			UnwatchLuaTriggerByKey('ChatClientInfo' .. identID, 'FriendChatClientInfo'..identID)
			WatchLuaTrigger('ChatClientInfo' .. identID, function(trigger)
				local accountIcon = trigger.accountIconPath
				if (not accountIcon) or Empty(accountIcon) then
					accountIcon = '/ui/shared/textures/account_icons/default.tga'
				end			
				Friends.friendData 										= Friends.friendData or {}
				Friends.friendData[nameCatUniqueID] 					= Friends.friendData[nameCatUniqueID] or {}
				Friends.friendData[nameCatUniqueID].trueName			= trigger.name
				Friends.friendData[nameCatUniqueID].icon				= accountIcon
				Friends.friendData[nameCatUniqueID].accountTitle		= trigger.accountTitle
				Friends.friendData[nameCatUniqueID].uniqueID			= trigger.uniqueID 
				Friends.friendData[nameCatUniqueID].status				= trigger.status
				Friends.friendData[nameCatUniqueID].identID				= trigger.identID
				Friends.friendData[nameCatUniqueID].isDND				= trigger.isDND			
				Friends.friendData[nameCatUniqueID].isStaff				= trigger.isStaff			
				Friends.friendData[nameCatUniqueID].ready				= trigger.ready			
			end, 'FriendChatClientInfo'..identID)	
		end
	end
	
	local function FriendsDataRegister(object)
		Friends.friendData = {}
		
		local function addUserData(widget, trigger, isOnline, isInGame, isIgnoreList)
			local buddyGroup	= trigger.buddyGroup

			if (isIgnoreList) then
				buddyGroup = 'ignored'
				isOnline = false
				isInGame = false		
			elseif trigger.acceptStatus == 'unknown' then
				buddyGroup = 'ignored'
			elseif trigger.ignored == true then
				buddyGroup = 'ignored'					
			elseif trigger.acceptStatus == 'pending' then
				buddyGroup = 'pending' 
				isOnline = false
			elseif trigger.acceptStatus == 'rejected' then
				buddyGroup = 'rejected'
				return				
			elseif (isOnline) then
				if buddyGroup == 'Friends' or buddyGroup == 'Default' or buddyGroup == 'Friend' or buddyGroup == '' then
					if trigger.acceptStatus == 'sent' then
						buddyGroup = 'sent' 
						isOnline = false
						isInGame = false
					elseif isInGame then
						-- buddyGroup = 'ingame' 
						buddyGroup = 'online'
						isOnline = true
					elseif isOnline then
						buddyGroup = 'online'
					else
						buddyGroup = 'offline'
						isOnline = false
						isInGame = false					
					end
				end
			else
				buddyGroup = 'offline'
				isOnline = false
				isInGame = false				
			end

			local accountIcon = trigger.accountIconPath
			if (not accountIcon) or Empty(accountIcon) then
				accountIcon = '/ui/shared/textures/account_icons/default.tga'
			end
			
			local  name 		= trigger.buddyName
			local  uniqueID 	= trigger.buddyUniqueID
			
			Friends.friendData									= Friends.friendData or {}
			Friends.friendData[name .. uniqueID]				= Friends.friendData[name .. uniqueID] or {}
			Friends.friendData[name .. uniqueID].name			= trigger.buddyName
			Friends.friendData[name .. uniqueID].trueName		= trigger.buddyName
			Friends.friendData[name .. uniqueID].buddyGroup		= Translate('friends_default_group')	-- rmm
			Friends.friendData[name .. uniqueID].buddyLabel		= trigger.buddyGroup
			Friends.friendData[name .. uniqueID].icon			= accountIcon
			Friends.friendData[name .. uniqueID].uniqueID		= trigger.buddyUniqueID
			Friends.friendData[name .. uniqueID].acceptStatus	= trigger.acceptStatus
			Friends.friendData[name .. uniqueID].isOnline		= isOnline
			Friends.friendData[name .. uniqueID].isInGame		= isInGame
			Friends.friendData[name .. uniqueID].isInLobby		= trigger.inLobby
			Friends.friendData[name .. uniqueID].isInParty		= trigger.inParty
			Friends.friendData[name .. uniqueID].isFriend		= true
			Friends.friendData[name .. uniqueID].identID		= trigger.buddyIdentID
			Friends.friendData[name .. uniqueID].joinableGame	= trigger.joinableGame
			Friends.friendData[name .. uniqueID].joinableParty	= trigger.joinableParty
			Friends.friendData[name .. uniqueID].ignored		= trigger.ignored
			Friends.friendData[name .. uniqueID].spectatableGame = trigger.spectatableGame

			WatchFriend(trigger.buddyIdentID, name .. uniqueID, playerInfo)
			
		end
		
		object:RegisterWatchLua('FriendListGame', function(widget, trigger) addUserData(widget, trigger, true, true, false) end)
		object:RegisterWatchLua('FriendListOffline', function(widget, trigger) addUserData(widget, trigger, false, false, false) end)
		object:RegisterWatchLua('FriendListOnline', function(widget, trigger) addUserData(widget, trigger, true, false, false) end)
		object:RegisterWatchLua('IgnoredList', function(widget, trigger) addUserData(widget, trigger, false, false, true) end)
		
		object:RegisterWatchLua('FriendListEvent', function(widget, trigger)
			local event = trigger.eventType
			if event == 'ClearItems' then

			elseif event == 'SortListboxSortIndex' then
				SocialClient.UpdateFriendsList()
			end
		end)	
	
	end

	FriendsDataRegister(object)	
	FriendsUpdateRegister(object)
	SocialClient.UpdateFriendsList()

	socialclient_im_friendlist_scrollbar:SetCallback('onslide', function(widget)
		local SCROLL_Y_AMOUNT_ROW = socialclient_im_friendlist:GetHeightFromString('98s')
		local SCROLL_Y_AMOUNT_HEADER = socialclient_im_friendlist:GetHeightFromString('28s')
		local scrollValue = widget:GetValue()
		local maxScrollAmount = ((SCROLL_Y_AMOUNT_ROW * rowIndex) + (SCROLL_Y_AMOUNT_HEADER * headerIndex)) - (GetWidget('socialclient_im_friendlist_parent'):GetHeight() - socialclient_im_friendlist:GetHeightFromString('4s'))
		local scrollAmount = (scrollValue / socialclient_im_friendlist_scrollbar:GetMaxValue()) * maxScrollAmount
		socialclient_im_friendlist:SlideY(scrollAmount * -1, 125)
	end)	
	function Friends.WheelUp()
		socialclient_im_friendlist_scrollbar:SetValue( math.max(0, socialclient_im_friendlist_scrollbar:GetValue() - 1) )
	end
	function  Friends.WheelDown()
		socialclient_im_friendlist_scrollbar:SetValue( math.min(socialclient_im_friendlist_scrollbar:GetMaxValue(), socialclient_im_friendlist_scrollbar:GetValue() + 1) )
	end	
	
	local social_client_scroll_catchers = object:GetGroup('social_client_scroll_catchers')
	for _, social_client_scroll_catcher in pairs(social_client_scroll_catchers) do
		social_client_scroll_catcher:SetCallback('onmousewheelup', function(widget)
			 Friends.WheelUp()
		end)
		social_client_scroll_catcher:SetCallback('onmousewheeldown', function(widget)
			Friends.WheelDown()
		end)	
	end
	
	social_client_sizingframe:SetCallback('onstartdrag', function(widget)
		widget:ClearCallback('onframe')
		widget:SetCallback('onframe', function(widget)
			SocialClient.UpdateFriendsList()
		end)
	end)
	
	social_client_sizingframe:SetCallback('onenddrag', function(widget)
		widget:ClearCallback('onframe')
	end)
	
end

FriendsRegister(object)
