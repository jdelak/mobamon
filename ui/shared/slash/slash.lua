local _G = getfenv(0)
local ipairs, pairs, select, string, table, next, type, unpack, tinsert, tconcat, tremove, format, tostring, tonumber, tsort, ceil, floor, sub, find, gfind = _G.ipairs, _G.pairs, _G.select, _G.string, _G.table, _G.next, _G.type, _G.unpack, _G.table.insert, _G.table.concat, _G.table.remove, _G.string.format, _G.tostring, _G.tonumber, _G.table.sort, _G.math.ceil, _G.math.floor, _G.string.sub, _G.string.find, _G.string.gfind

mainUI = mainUI or {}
mainUI.SlashCommands = {}
mainUI.SlashCommands.tabOffset = 0
mainUI.SlashCommands.matchingClients = {}
mainUI.SlashCommands.slashCommandTarget = {}
mainUI.SlashCommands.maxUserListSize = 10

ClientInfo = ClientInfo or {}
ClientInfo.duplicateUsernameTable = ClientInfo.duplicateUsernameTable or {}

local function showError(self, errorMessage)
	
	-- println('UpdateTargetElement ' .. tostring(visible) .. ' ' .. tostring(self) .. ' ' .. tostring(clientTable) .. ' ' .. tostring(currentTargetIndex) .. ' ' .. tostring(commandName) .. ' ' .. tostring(arg) )
	
	local slash_tab_error_parent = GetWidget('slash_tab_error_parent', 'slash')
	
	if (self) then
		
		slash_tab_error_parent:FadeIn(250)

		-- update contents
		local parent 		= GetWidget('slash_tab_target_error', 'slash')
		local username 		= GetWidget('slash_tab_target_error_username', 'slash')
		local button 		= GetWidget('slash_tab_target_error_button', 'slash')
		local frame3 		= GetWidget('slash_tab_target_error_frame_3', 'slash')
		username:SetText(Translate(errorMessage))
		frame3:SetVisible(1)
		
		-- update position
		slash_tab_error_parent:UICmd("SetAbsoluteX(".. (self:GetAbsoluteX()) .. ")")
		slash_tab_error_parent:UICmd("SetAbsoluteY(".. (self:GetAbsoluteY() - slash_tab_error_parent:GetHeight()) - 6 .. ")")
		
		slash_tab_error_parent:Sleep(3000, function(widget)
			widget:FadeOut(250)
		end)
		
	else
		slash_tab_error_parent:FadeOut(250)	
	end
end

local function SlashCommandError(widget, errorMessage, showAsPopup, showInWindow, channelID)
	if (widget) then
		println('^r SlashCommandError ' .. widget:GetName() .. ' ' .. tostring(errorMessage))
		if (true) or (showAsPopup) then
			showError(widget, errorMessage)
		elseif (showInWindow) and ((channelID) or (mainUI.chatManager.channelAtFrontId)) then
			ChatClient.DispatchMessageToLocalClientWindow(1, ((channelID) or (mainUI.chatManager.channelAtFrontId)), Translate(errorMessage))
		end
	else
		println('^r SlashCommandError !NO WIDGET! ' .. tostring(errorMessage))
	end
end

local function GetMatchingClients(searchString, includeAllKnownClients, conditionFunction)
	-- println('^g GetMatchingClients ')
	
	mainUI.SlashCommands.tabOffset = 0
	mainUI.SlashCommands.matchingClients = {}
	
	local recentMessagersTable = ChatClient.GetRecentMessagers() or {}
	local tempClientTable = {}
			
	if (includeAllKnownClients) then
		tempClientTable = ChatClient.FindClientsBySubstring(searchString, true) or {}
	end
	
	for i,v in pairs(tempClientTable) do
		if (i) and (v) and (v.nickname) and (not Empty(v.nickname)) and (v.identid) and IsValidIdent(v.identid) and ChatClient.IsOnline(v.identid) and (not IsMe(v.identid)) then
			if (ClientInfo.duplicateUsernameTable[v.nickname]) then
				if (not IsInTable(ClientInfo.duplicateUsernameTable[v.nickname], v.uniqueID)) then
					tinsert(ClientInfo.duplicateUsernameTable[v.nickname], v.uniqueID)
				end
			else
				ClientInfo.duplicateUsernameTable[v.nickname] = {v.uniqueID}
			end
		else
			tempClientTable[i] = nil
		end
	end
	
	for i, v in pairs(recentMessagersTable) do
		if (#mainUI.SlashCommands.matchingClients >= mainUI.SlashCommands.maxUserListSize) then
			break
		end	
		if (i) and (v) and (v.nickname) and (not Empty(v.nickname)) and (v.identid) and IsValidIdent(v.identid) and ChatClient.IsOnline(v.identid) and (not IsMe(v.identid)) and ((searchString == '') or (searchString == nil) or (string.find(string.lower(v.nickname), string.lower(searchString), 1, true))) then
			if (not conditionFunction) or (conditionFunction(v.identid)) then
				tinsert(mainUI.SlashCommands.matchingClients, v)
			end
		end
	end
	
	if (includeAllKnownClients) then
		local indexTempTable = {}
		for i, v in pairs(tempClientTable) do
			if (v.identid) and (not IsInTable(recentMessagersTable, v.identid)) then
				tinsert(indexTempTable, v)
			end
		end
		
		tsort(indexTempTable, function(a,b) 
			if (a) and (b) then
				if (a.identid) and ChatClient.IsFriend(a.identid) and (b.identid) and (not ChatClient.IsFriend(b.identid)) then
					return true
				elseif string.lower(a.nickname) < string.lower(b.nickname) then
					return true
				else
					return false
				end
			else
				return false
			end
		end)

		for i, v in ipairs(indexTempTable) do
			if (#mainUI.SlashCommands.matchingClients >= mainUI.SlashCommands.maxUserListSize) then
				break
			end		
			if (i) and (v) and (v.nickname) and (not Empty(v.nickname)) then
				if (not conditionFunction) or (conditionFunction(v.identid)) then
					tinsert(mainUI.SlashCommands.matchingClients, v)
				end
			end
		end
	end
	
	return mainUI.SlashCommands.matchingClients
end

function mainUI.SlashCommands.OnTyping(self, arg, commandName, showTargetElement, commandOverride)
	if (not self:HasFocus()) then return end
	
	local commandName = commandOverride or commandName
	
	if GetCvarBool('host_islauncher') then
		if (not mainUI.SlashCommands.matchingClients) or (not mainUI.SlashCommands.matchingClients[1]) then
			-- there are no matching clients, how sad
			-- SlashCommandError(self, 'slash_command_error_no_targets')
		else
			mainUI.SlashCommands.tabOffset = 0
			
			if (showTargetElement) then
				mainUI.SlashCommands.UpdateTargetElement(true, self, mainUI.SlashCommands.matchingClients, mainUI.SlashCommands.tabOffset, commandName, arg)
			end

		end
	end
end

function mainUI.SlashCommands.UpdateInputLine(self, arg, commandName, showTargetElement, arg1, arg2, commandOverride)
	if (commandName == "reply") then -- special case where reply turns into whisper on name click
		commandName = "whisper"
	end

	-- printr(arg)
	
	-- printr(mainUI.SlashCommands.matchingClients)
	
	local commandName = commandOverride or commandName
	
	if (not mainUI.SlashCommands.matchingClients) or (not mainUI.SlashCommands.matchingClients[1]) then
		-- there are no matching clients, how sad
		-- SlashCommandError(self, 'slash_command_error_no_targets')
	else
		if (not mainUI.SlashCommands.matchingClients[mainUI.SlashCommands.tabOffset]) then
			mainUI.SlashCommands.tabOffset = 1
		end
		
		if (showTargetElement) then
			mainUI.SlashCommands.UpdateTargetElement(true, self, mainUI.SlashCommands.matchingClients, mainUI.SlashCommands.tabOffset, commandName, arg)
		end
		
		if (mainUI.SlashCommands.matchingClients) and (mainUI.SlashCommands.matchingClients[mainUI.SlashCommands.tabOffset]) and (mainUI.SlashCommands.matchingClients[mainUI.SlashCommands.tabOffset].nickname) and (mainUI.SlashCommands.matchingClients[mainUI.SlashCommands.tabOffset].uniqid) then
			local nickname = mainUI.SlashCommands.matchingClients[mainUI.SlashCommands.tabOffset].nickname
			if (string.find(nickname, ' ', 1, true)) then
				nickname = '"' .. nickname .. '"'
			end
			if (ClientInfo.duplicateUsernameTable[mainUI.SlashCommands.matchingClients[mainUI.SlashCommands.tabOffset].nickname]) and (#ClientInfo.duplicateUsernameTable[mainUI.SlashCommands.matchingClients[mainUI.SlashCommands.tabOffset].nickname] > 1) then
				self:SetInputLine('/' .. commandName .. ' ' .. nickname .. '.' .. mainUI.SlashCommands.matchingClients[mainUI.SlashCommands.tabOffset].uniqid .. ' ' .. (arg2 or ''))
			else
				self:SetInputLine('/' .. commandName .. ' ' .. nickname .. ' ' .. (arg2 or ''))
			end
			mainUI.SlashCommands.slashCommandTarget.identid = mainUI.SlashCommands.matchingClients[mainUI.SlashCommands.tabOffset].identid
			mainUI.SlashCommands.slashCommandTarget.nickname = mainUI.SlashCommands.matchingClients[mainUI.SlashCommands.tabOffset].nickname
			mainUI.SlashCommands.slashCommandTarget.uniqid = mainUI.SlashCommands.matchingClients[mainUI.SlashCommands.tabOffset].uniqid
			mainUI.SlashCommands.slashCommandTarget.widget = self
		else
			self:SetInputLine('/' .. commandName .. ' ' .. (arg1 or '') .. ' ' .. (arg2 or ''))
		end
	end
end

function mainUI.SlashCommands.UpdateTargetElement(visible, self, clientTable, currentTargetIndex, commandName, arg)
	
	-- println('UpdateTargetElement ' .. tostring(visible) .. ' ' .. tostring(self) .. ' ' .. tostring(clientTable) .. ' ' .. tostring(currentTargetIndex) .. ' ' .. tostring(commandName) .. ' ' .. tostring(arg) )
	
	local slash_tab_target_parent = GetWidget('slash_tab_target_parent', 'slash')
	
	if (visible) and (self) and (clientTable) and (#clientTable >= 1) and (currentTargetIndex) then
		
		slash_tab_target_parent:FadeIn(250)
		
		-- hide previous contents
		for index = 1,mainUI.SlashCommands.maxUserListSize,1 do
			local parent 	= GetWidget('slash_tab_target_user_' .. index, 'slash')
			parent:SetVisible(0)
		end
		
		-- update contents
		for index, v in pairs(clientTable) do
			if (index <= mainUI.SlashCommands.maxUserListSize) then
				local parent 		= GetWidget('slash_tab_target_user_' .. index, 'slash')
				local username 		= GetWidget('slash_tab_target_user_' .. index .. '_username', 'slash')
				local usergroup 	= GetWidget('slash_tab_target_user_' .. index .. '_usergroup', 'slash')
				local button 		= GetWidget('slash_tab_target_user_' .. index .. '_button', 'slash')
				local icon		 	= GetWidget('slash_tab_target_user_' .. index .. '_icon', 'slash')
				local frame1 		= GetWidget('slash_tab_target_user_' .. index .. '_frame_1', 'slash')
				local frame2 		= GetWidget('slash_tab_target_user_' .. index .. '_frame_2', 'slash')
				local frame3 		= GetWidget('slash_tab_target_user_' .. index .. '_frame_3', 'slash')
				username:SetText(v.nickname)
				usergroup:SetText(v.uniqid)
				icon:SetTexture('/ui/shared/textures/user_icon.tga')
				
				if (index == currentTargetIndex) then
					frame3:SetVisible(1)
				else
					frame3:SetVisible(0)
				end
				
				button:SetCallback('onclick', function(widget)
					mainUI.SlashCommands.tabOffset = index
					mainUI.SlashCommands.UpdateInputLine(self, {}, commandName, false)
					self:SetFocus(true)
				end)			
				button:SetCallback('onmouseover', function(widget)
					frame2:SetBorderColor('0.8 0.8 0.8 1')
				end)
				button:SetCallback('onmouseout', function(widget)
					frame2:SetBorderColor('0 0 0 1')
				end)			
				button:RefreshCallbacks()
				
				parent:SetVisible(1)
				FindChildrenClickCallbacks(parent)
			else
				break
			end
		end
		
		-- update position
		slash_tab_target_parent:UICmd("SetAbsoluteX(".. (self:GetAbsoluteX()) .. ")")
		slash_tab_target_parent:UICmd("SetAbsoluteY(".. (self:GetAbsoluteY() - slash_tab_target_parent:GetHeight()) - 6 .. ")")
	else
		slash_tab_target_parent:FadeOut(250)	
	end
end

function mainUI.SlashCommands.RegisterInput(self, channelID, channelName, chatType, inputEnv)
	
	if (not inputEnv) then
		if GetCvarBool('host_islauncher') then
			inputEnv = 'launcher'
		else
			inputEnv = 'game'
		end
	end

	self:ClearCallback('ontab')	
	self:RefreshCallbacks()

	self:SetCallback('onlosefocus', function(widget) 
		if (mainUI.SlashCommands.slashCommandTarget.widget == widget) then
			mainUI.SlashCommands.UpdateTargetElement(false)
		end	
	end)
	self:SetCallback('onhide', function(widget) 
		if (mainUI.SlashCommands.slashCommandTarget.widget == widget) then
			mainUI.SlashCommands.UpdateTargetElement(false)
		end
	end)	
	self:SetCallback('onkeydown', function(widget, this) 
		if (self:IsVisible()) and (self:HasFocus()) then
			mainUI.SlashCommands.UpdateTargetElement(false)
		end
	end)		
	
	self:RegisterWatchLua('InvalidChatCommandAttempted', function(widget, trigger) 
		if (trigger.commandAttempted) then
			mainUI.SlashCommands.UpdateTargetElement(false)
			widget:ClearCallback('ontab')	
			widget:RefreshCallbacks()			
		end
	end)	
	
	if (inputEnv == 'launcher') then
	
		self:RegisterClientChatCommandWatcher('spectate', function (widget, commandName, ...)
			if (not self:HasFocus()) then return end
			
			local arg = arg
			mainUI.SlashCommands.slashCommandTarget.widget = widget
			
			-- Tabbing
			widget:ClearCallback('ontab')	
			widget:SetCallback('ontab', function(widget)
	
				if (not arg[1]) or (Empty(arg[1])) then
					widget:SetInputLine('/' .. commandName .. ' ')
				end
				
				mainUI.SlashCommands.tabOffset = mainUI.SlashCommands.tabOffset + 1

				mainUI.SlashCommands.UpdateInputLine(self, arg, commandName, true, arg[1], arg[2])
			end)
			self:RefreshCallbacks()
			
			local function conditionFunction(identID)
				return (ChatClient.IsInGame(identID) and ChatClient.IsFriend(identID))
			end			
			
			-- Typing
			-- printr(widget:GetName()..' '..commandName..' typing... '); 
			-- printr(arg) 
			mainUI.SlashCommands.UpdateTargetElement(false)
			if (not mainUI.SlashCommands.slashCommandTarget.nickname) or (not mainUI.SlashCommands.slashCommandTarget.uniqid) or (not arg[1]) or ((mainUI.SlashCommands.slashCommandTarget.nickname ~= arg[1]) and ((mainUI.SlashCommands.slashCommandTarget.nickname .. '.' .. mainUI.SlashCommands.slashCommandTarget.uniqid) ~= arg[1])) then
				mainUI.SlashCommands.slashCommandTarget.identid = nil
			end
			if (arg[1]) and (not Empty(arg[1])) then
				GetMatchingClients(arg[1], true, conditionFunction)
			else
				GetMatchingClients('', true, conditionFunction)
			end
			
			mainUI.SlashCommands.OnTyping(self, arg, commandName, true)
			
		end)	
	
		self:RegisterClientChatCommandWatcher('invite', function (widget, commandName, ...)
			if (not self:HasFocus()) then return end
			
			local arg = arg
			mainUI.SlashCommands.slashCommandTarget.widget = widget
			
			-- Tabbing
			widget:ClearCallback('ontab')	
			widget:SetCallback('ontab', function(widget)
				if (not arg[1]) or (Empty(arg[1])) then
					widget:SetInputLine('/' .. commandName .. ' ')
				end
				
				mainUI.SlashCommands.tabOffset = mainUI.SlashCommands.tabOffset + 1

				mainUI.SlashCommands.UpdateInputLine(self, arg, commandName, true, arg[1], arg[2])
			end)
			self:RefreshCallbacks()
			
			-- Typing
			-- printr(widget:GetName()..' '..commandName..' typing... '); 
			-- printr(arg) 
			mainUI.SlashCommands.UpdateTargetElement(false)
			if (not mainUI.SlashCommands.slashCommandTarget.nickname) or (not mainUI.SlashCommands.slashCommandTarget.uniqid) or (not arg[1]) or ((mainUI.SlashCommands.slashCommandTarget.nickname ~= arg[1]) and ((mainUI.SlashCommands.slashCommandTarget.nickname .. '.' .. mainUI.SlashCommands.slashCommandTarget.uniqid) ~= arg[1])) then
				mainUI.SlashCommands.slashCommandTarget.identid = nil
			end
			if (arg[1]) and (not Empty(arg[1])) then
				GetMatchingClients(arg[1], true, nil)
			else
				GetMatchingClients('', true, nil)
			end
			
			mainUI.SlashCommands.OnTyping(self, arg, commandName, true)
			
		end)	
	
		self:RegisterClientChatCommandWatcher('kick', function (widget, commandName, ...)
			if (not self:HasFocus()) then return end
			
			local arg = arg
			mainUI.SlashCommands.slashCommandTarget.widget = widget
			
			-- Tabbing
			widget:ClearCallback('ontab')	
			widget:SetCallback('ontab', function(widget)				
				if (not arg[1]) or (Empty(arg[1])) then
					widget:SetInputLine('/' .. commandName .. ' ')
				end
				
				mainUI.SlashCommands.tabOffset = mainUI.SlashCommands.tabOffset + 1

				mainUI.SlashCommands.UpdateInputLine(self, arg, commandName, true, arg[1], arg[2])
			end)
			self:RefreshCallbacks()
			
			-- Typing
			-- printr(widget:GetName()..' '..commandName..' typing... '); 
			-- printr(arg) 
			
			local function conditionFunction(identID)
				return IsInParty(identID)
			end
			
			mainUI.SlashCommands.UpdateTargetElement(false)
			if (not mainUI.SlashCommands.slashCommandTarget.nickname) or (not mainUI.SlashCommands.slashCommandTarget.uniqid) or (not arg[1]) or ((mainUI.SlashCommands.slashCommandTarget.nickname ~= arg[1]) and ((mainUI.SlashCommands.slashCommandTarget.nickname .. '.' .. mainUI.SlashCommands.slashCommandTarget.uniqid) ~= arg[1])) then
				mainUI.SlashCommands.slashCommandTarget.identid = nil
			end
			if (arg[1]) and (not Empty(arg[1])) then
				GetMatchingClients(arg[1], true, conditionFunction)
			else
				GetMatchingClients('', true, conditionFunction)
			end
			
			mainUI.SlashCommands.OnTyping(self, arg, commandName, true)
			
		end)	
	
	end
	
	if (inputEnv == 'launcher') or (inputEnv == 'game') then
	
		self:RegisterClientChatCommandWatcher('reply', function (widget, commandName, ...)
			if (not self:HasFocus()) then return end
			
			local arg = arg
			mainUI.SlashCommands.slashCommandTarget.widget = widget
			
			-- Tabbing
			widget:ClearCallback('ontab')	
			widget:SetCallback('ontab', function(widget)
				if (not arg[1]) or (Empty(arg[1])) then
					widget:SetInputLine('/' .. commandName .. ' ')
				end
				
				mainUI.SlashCommands.tabOffset = mainUI.SlashCommands.tabOffset + 1

				mainUI.SlashCommands.UpdateInputLine(self, arg, commandName, true, arg[1], arg[2], 'whisper')
			end)
			self:RefreshCallbacks()
			
			-- Typing
			-- printr(widget:GetName()..' '..commandName..' typing... '); 
			-- printr(arg) 
			mainUI.SlashCommands.UpdateTargetElement(false)
			if (not mainUI.SlashCommands.slashCommandTarget.nickname) or (not mainUI.SlashCommands.slashCommandTarget.uniqid) or (not arg[1]) or ((mainUI.SlashCommands.slashCommandTarget.nickname ~= arg[1]) and ((mainUI.SlashCommands.slashCommandTarget.nickname .. '.' .. mainUI.SlashCommands.slashCommandTarget.uniqid) ~= arg[1])) then
				mainUI.SlashCommands.slashCommandTarget.identid = nil
			end
			if (arg[1]) and (not Empty(arg[1])) then
				GetMatchingClients(arg[1], false, nil)
			else
				GetMatchingClients('', false, nil)
			end
			
			mainUI.SlashCommands.OnTyping(self, arg, commandName, true, 'whisper')
			
			mainUI.SlashCommands.UpdateInputLine(self, arg, commandName, true, arg[1], arg[2], 'whisper')
			
		end)	
		
		self:RegisterClientChatCommandWatcher('whisper', function (widget, commandName, ...)
			if (not self:HasFocus()) then return end
			local arg = arg
			mainUI.SlashCommands.slashCommandTarget.widget = widget
			
			-- Tabbing
			widget:ClearCallback('ontab')	
			widget:SetCallback('ontab', function(widget)
	
				if (not arg[1]) or (Empty(arg[1])) then
					widget:SetInputLine('/' .. commandName .. ' ')
				end
				
				mainUI.SlashCommands.tabOffset = mainUI.SlashCommands.tabOffset + 1

				mainUI.SlashCommands.UpdateInputLine(self, arg, commandName, true, arg[1], arg[2])
			end)
			self:RefreshCallbacks()
			
			-- Typing
			-- printr(widget:GetName()..' '..commandName..' typing... '); 
			-- printr(arg) 
			mainUI.SlashCommands.UpdateTargetElement(false)
			if (not mainUI.SlashCommands.slashCommandTarget.nickname) or (not mainUI.SlashCommands.slashCommandTarget.uniqid) or (not arg[1]) or ((mainUI.SlashCommands.slashCommandTarget.nickname ~= arg[1]) and ((mainUI.SlashCommands.slashCommandTarget.nickname .. '.' .. mainUI.SlashCommands.slashCommandTarget.uniqid) ~= arg[1])) then
				mainUI.SlashCommands.slashCommandTarget.identid = nil
			end				

			if (arg[1]) and (not Empty(arg[1])) then
				GetMatchingClients(arg[1], true, nil)
			else
				GetMatchingClients('', true, nil)
			end
			
			mainUI.SlashCommands.OnTyping(self, arg, commandName, true)
			
		end)		
		
		self:RegisterClientChatCommandWatcher('mute', function (widget, commandName, ...)
			if (not self:HasFocus()) then return end
			
			local arg = arg
			mainUI.SlashCommands.slashCommandTarget.widget = widget
			
			-- Tabbing
			widget:ClearCallback('ontab')	
			widget:SetCallback('ontab', function(widget)
	
				if (not arg[1]) or (Empty(arg[1])) then
					widget:SetInputLine('/' .. commandName .. ' ')
				end
				
				mainUI.SlashCommands.tabOffset = mainUI.SlashCommands.tabOffset + 1

				mainUI.SlashCommands.UpdateInputLine(self, arg, commandName, true, arg[1], arg[2])
			end)
			self:RefreshCallbacks()
			
			-- Typing
			-- printr(widget:GetName()..' '..commandName..' typing... '); 
			-- printr(arg) 
			mainUI.SlashCommands.UpdateTargetElement(false)
			if (not mainUI.SlashCommands.slashCommandTarget.nickname) or (not mainUI.SlashCommands.slashCommandTarget.uniqid) or (not arg[1]) or ((mainUI.SlashCommands.slashCommandTarget.nickname ~= arg[1]) and ((mainUI.SlashCommands.slashCommandTarget.nickname .. '.' .. mainUI.SlashCommands.slashCommandTarget.uniqid) ~= arg[1])) then
				mainUI.SlashCommands.slashCommandTarget.identid = nil
			end
			if (arg[1]) and (not Empty(arg[1])) then
				GetMatchingClients(arg[1], true, nil)
			else
				GetMatchingClients('', true, nil)
			end
			
			mainUI.SlashCommands.OnTyping(self, arg, commandName, true)
			
		end)		
		
		self:RegisterClientChatCommandWatcher('unmute', function (widget, commandName, ...)
			if (not self:HasFocus()) then return end
			
			local arg = arg
			mainUI.SlashCommands.slashCommandTarget.widget = widget
			
			-- Tabbing
			widget:ClearCallback('ontab')	
			widget:SetCallback('ontab', function(widget)
	
				if (not arg[1]) or (Empty(arg[1])) then
					widget:SetInputLine('/' .. commandName .. ' ')
				end
				
				mainUI.SlashCommands.tabOffset = mainUI.SlashCommands.tabOffset + 1

				mainUI.SlashCommands.UpdateInputLine(self, arg, commandName, true, arg[1], arg[2])
			end)
			self:RefreshCallbacks()
			
			-- Typing
			-- printr(widget:GetName()..' '..commandName..' typing... '); 
			-- printr(arg) 
			mainUI.SlashCommands.UpdateTargetElement(false)
			if (not mainUI.SlashCommands.slashCommandTarget.nickname) or (not mainUI.SlashCommands.slashCommandTarget.uniqid) or (not arg[1]) or ((mainUI.SlashCommands.slashCommandTarget.nickname ~= arg[1]) and ((mainUI.SlashCommands.slashCommandTarget.nickname .. '.' .. mainUI.SlashCommands.slashCommandTarget.uniqid) ~= arg[1])) then
				mainUI.SlashCommands.slashCommandTarget.identid = nil
			end
			if (arg[1]) and (not Empty(arg[1])) then
				GetMatchingClients(arg[1], true, nil)
			else
				GetMatchingClients('', true, nil)
			end
			
			mainUI.SlashCommands.OnTyping(self, arg, commandName, true)
			
		end)		
		
	end
	
end

local function SlashCommandsRegister(object, inputEnv)
	
	local hasCompletedNPE = true
	if ((LuaTrigger.GetTrigger('newPlayerExperience').tutorialProgress < NPE_PROGRESS_TUTORIALCOMPLETE) and (not LuaTrigger.GetTrigger('newPlayerExperience').tutorialComplete)) then
		hasCompletedNPE = false
	end
	
	if (not inputEnv) then
		if GetCvarBool('host_islauncher') then
			inputEnv = 'launcher'
		else
			inputEnv = 'game'
		end
	end
	
	if (inputEnv == 'game') then
		
		local function SpectateCallback(commandType, commandIdentifier, ...)
			println('^c SpectateCallback ' .. tostring(commandType) .. '|' .. tostring(commandIdentifier) .. ' : ' .. tostring(arg[1]) .. ' | ' .. tostring(arg[2]).. ' | mainUI.SlashCommands.slashCommandTarget.identid): ' .. tostring(mainUI.SlashCommands.slashCommandTarget.identid) .. '\n')
			SlashCommandError(self, 'slash_command_error_invalid_permissions')
		end
		GameClient.RegisterChatCommand('spectate', SpectateCallback, 1, false, true, true)
	
		local function InviteCallback(commandType, commandIdentifier, ...)
			println('^c InviteCallback ' .. tostring(commandType) .. '|' .. tostring(commandIdentifier) .. ' : ' .. tostring(arg[1]) .. ' | ' .. tostring(arg[2]).. ' | mainUI.SlashCommands.slashCommandTarget.identid): ' .. tostring(mainUI.SlashCommands.slashCommandTarget.identid) .. '\n')
			SlashCommandError(self, 'slash_command_error_invalid_permissions')
		end
		GameClient.RegisterChatCommand('invite', InviteCallback, 1, false, true, true)	
	
	elseif (inputEnv == 'launcher') then

		local function SpectateCallback(commandType, commandIdentifier, ...)
			println('^c SpectateCallback ' .. tostring(commandType) .. '|' .. tostring(commandIdentifier) .. ' : ' .. tostring(arg[1]) .. ' | ' .. tostring(arg[2]).. ' | mainUI.SlashCommands.slashCommandTarget.identid): ' .. tostring(mainUI.SlashCommands.slashCommandTarget.identid) .. '\n')
			if (arg[1]) and (not Empty(arg[1])) then	
				if mainUI.SlashCommands.slashCommandTarget.identid then
					mainUI.SpectateGame(mainUI.SlashCommands.slashCommandTarget.identid)
				elseif (arg[1]) and (not Empty(arg[1])) then
					local identID = ChatClient.LookupClientIdentID(arg[1])
					if IsValidIdent(identID) and ChatClient.IsOnline(identID) then 
						mainUI.SpectateGame(identID)
					else
						SlashCommandError(mainUI.SlashCommands.slashCommandTarget.widget, 'slash_command_error_invalid_target')
					end
				else
					SlashCommandError(mainUI.SlashCommands.slashCommandTarget.widget, 'slash_command_error_invalid_target')
				end
			else
				SlashCommandError(mainUI.SlashCommands.slashCommandTarget.widget, 'slash_command_error_missing_argument')	
			end
		end
		ChatClient.RegisterChatCommand('spectate', SpectateCallback, 1, false, true, true)
	
		local function InviteCallback(commandType, commandIdentifier, ...)
			println('^c InviteCallback ' .. tostring(commandType) .. '|' .. tostring(commandIdentifier) .. ' : ' .. tostring(arg[1]) .. ' | ' .. tostring(arg[2]).. ' | mainUI.SlashCommands.slashCommandTarget.identid): ' .. tostring(mainUI.SlashCommands.slashCommandTarget.identid) .. '\n')
			if (hasCompletedNPE) then
				if (arg[1]) and (not Empty(arg[1])) then	
					if mainUI.SlashCommands.slashCommandTarget.identid then
						if (LuaTrigger.GetTrigger('LobbyStatus').inLobby) and (LuaTrigger.GetTrigger('LobbyStatus').isHost) then
							-- println('A GameInvite ' .. tostring(mainUI.SlashCommands.slashCommandTarget.identid) )
							ChatClient.GameInvite(mainUI.SlashCommands.slashCommandTarget.identid)
						elseif (not LuaTrigger.GetTrigger('HeroSelectMode').isCustomLobby) then
							-- println('A PartyInvite ' .. tostring(mainUI.SlashCommands.slashCommandTarget.identid) )
							ChatClient.PartyInvite(mainUI.SlashCommands.slashCommandTarget.identid)
							local partyCustomTrigger = LuaTrigger.GetTrigger('PartyTrigger')
							partyCustomTrigger.userRequestedParty = true
							partyCustomTrigger:Trigger(false)				
						end
					elseif (arg[1]) and (not Empty(arg[1])) then
						local identID = ChatClient.LookupClientIdentID(arg[1])
						if IsValidIdent(identID) and ChatClient.IsOnline(identID) then 
							if (LuaTrigger.GetTrigger('LobbyStatus').inLobby) and (LuaTrigger.GetTrigger('LobbyStatus').isHost) then
								-- println('B GameInvite ' .. tostring(identID) )
								ChatClient.GameInvite(identID)
							elseif (not LuaTrigger.GetTrigger('HeroSelectMode').isCustomLobby) then
								-- println('B PartyInvite ' .. tostring(identID) )
								ChatClient.PartyInvite(identID)
								local partyCustomTrigger = LuaTrigger.GetTrigger('PartyTrigger')
								partyCustomTrigger.userRequestedParty = true
								partyCustomTrigger:Trigger(false)
							end					
						else
							SlashCommandError(mainUI.SlashCommands.slashCommandTarget.widget, 'slash_command_error_invalid_target')
						end
					else
						SlashCommandError(mainUI.SlashCommands.slashCommandTarget.widget, 'slash_command_error_invalid_target')
					end
				else
					SlashCommandError(mainUI.SlashCommands.slashCommandTarget.widget, 'slash_command_error_missing_argument')	
				end
			else
				SlashCommandError(mainUI.SlashCommands.slashCommandTarget.widget, 'slash_command_error_invalid_permissions')	
			end				
		end
		ChatClient.RegisterChatCommand('invite', InviteCallback, 1, false, true, true)	
	
		local function KickCallback(commandType, commandIdentifier, ...)
			println('^c KickCallback ' .. tostring(commandType) .. '|' .. tostring(commandIdentifier) .. ' : ' .. tostring(arg[1]) .. ' | ' .. tostring(arg[2]).. ' | mainUI.SlashCommands.slashCommandTarget.identid): ' .. tostring(mainUI.SlashCommands.slashCommandTarget.identid) .. '\n')
			if (arg[1]) and (not Empty(arg[1])) then	
				if mainUI.SlashCommands.slashCommandTarget.identid then
					if (LuaTrigger.GetTrigger('LobbyStatus').inLobby) and (LuaTrigger.GetTrigger('LobbyStatus').isHost) then
						Kick(mainUI.SlashCommands.slashCommandTarget.identid)
					elseif (LuaTrigger.GetTrigger('PartyStatus').inParty) and (LuaTrigger.GetTrigger('PartyStatus').isPartyLeader) then
						ChatClient.PartyKick(mainUI.SlashCommands.slashCommandTarget.identid)
					else
						SlashCommandError(mainUI.SlashCommands.slashCommandTarget.widget, 'slash_command_error_invalid_permissions')
					end
				elseif (arg[1]) and (not Empty(arg[1])) then
					local identID = ChatClient.LookupClientIdentID(arg[1])
					if IsValidIdent(identID) and ChatClient.IsOnline(identID) then 
						if (LuaTrigger.GetTrigger('LobbyStatus').inLobby) and (LuaTrigger.GetTrigger('LobbyStatus').isHost) then
							Kick(identID)						
						elseif (LuaTrigger.GetTrigger('PartyStatus').inParty) and (LuaTrigger.GetTrigger('PartyStatus').isPartyLeader) then
							ChatClient.PartyKick(identID)
						else
							SlashCommandError(mainUI.SlashCommands.slashCommandTarget.widget, 'slash_command_error_invalid_permissions')
						end
					else
						SlashCommandError(mainUI.SlashCommands.slashCommandTarget.widget, 'slash_command_error_invalid_target')
					end
				else
					SlashCommandError(mainUI.SlashCommands.slashCommandTarget.widget, 'slash_command_error_invalid_target')
				end
			else
				SlashCommandError(mainUI.SlashCommands.slashCommandTarget.widget, 'slash_command_error_missing_argument')	
			end
		end
		ChatClient.RegisterChatCommand('kick', KickCallback, 1, false, true, true)		
	
	end
	
	if (inputEnv == 'launcher') or (inputEnv == 'game') then
	
		local function ReplyCallback(commandType, commandIdentifier, ...)
			println('^c ReplyCallback ' .. tostring(commandType) .. '|' .. tostring(commandIdentifier) .. ' : ' .. tostring(arg[1]) .. ' | ' .. tostring(arg[2]).. ' | mainUI.SlashCommands.slashCommandTarget.identid): ' .. tostring(mainUI.SlashCommands.slashCommandTarget.identid) .. '\n')
			if (arg[1]) and (not Empty(arg[1])) then	
				local recentMessagers = ChatClient.GetRecentMessagers()
				if (recentMessagers) and (recentMessagers[1]) and (recentMessagers[1].identid) and (recentMessagers[1].nickname) then
					local identID = recentMessagers[1].identid
					if IsValidIdent(identID) and ChatClient.IsOnline(identID) then 
						ChatClient.SendPrivateMessageToIdentID(identID, arg[1])
						if (mainUI) and (mainUI.chatManager) and (mainUI.chatManager.InitPrivateMessage) then
							mainUI.chatManager.InitPrivateMessage(identID, 5, recentMessagers[1].nickname, true) -- pretty up arg 1 with a lookup rmm
						end
					else
						SlashCommandError(mainUI.SlashCommands.slashCommandTarget.widget, 'slash_command_error_invalid_target')
					end
				else
					SlashCommandError(mainUI.SlashCommands.slashCommandTarget.widget, 'slash_command_error_invalid_target')
				end				
			else
				SlashCommandError(mainUI.SlashCommands.slashCommandTarget.widget, 'slash_command_error_missing_argument')	
			end
		end
		ChatClient.RegisterChatCommand('reply', ReplyCallback, 1, false, true, true)
		
		local function WhisperCallback(commandType, commandIdentifier, ...)
			println('^c WhisperCallback ' .. tostring(commandType) .. '|' .. tostring(commandIdentifier) .. ' : ' .. tostring(arg[1]) .. ' | ' .. tostring(arg[2]).. ' | mainUI.SlashCommands.slashCommandTarget.identid): ' .. tostring(mainUI.SlashCommands.slashCommandTarget.identid) .. '\n')
			if (arg[2]) and (not Empty(arg[2])) then	
				if mainUI.SlashCommands.slashCommandTarget.identid then
					if (mainUI) and (mainUI.chatManager) and (mainUI.chatManager.InitPrivateMessage) then
						mainUI.chatManager.InitPrivateMessage(mainUI.SlashCommands.slashCommandTarget.identid, 5, mainUI.SlashCommands.slashCommandTarget.nickname, true)
					end
					ChatClient.SendPrivateMessageToIdentID(mainUI.SlashCommands.slashCommandTarget.identid, arg[2])
				elseif (arg[1]) and (not Empty(arg[1])) then
					local identID = ChatClient.LookupClientIdentID(arg[1])
					if IsValidIdent(identID) and ChatClient.IsOnline(identID) then
						if (mainUI) and (mainUI.chatManager) and (mainUI.chatManager.InitPrivateMessage) then
							mainUI.chatManager.InitPrivateMessage(identID, 5, arg[1], true) -- pretty up arg 1 with a lookup rmm
						end						
						ChatClient.SendPrivateMessageToIdentID(identID, arg[2])
					else
						SlashCommandError(mainUI.SlashCommands.slashCommandTarget.widget, 'slash_command_error_invalid_target')
					end
				else
					SlashCommandError(mainUI.SlashCommands.slashCommandTarget.widget, 'slash_command_error_invalid_target')
				end
			else
				SlashCommandError(mainUI.SlashCommands.slashCommandTarget.widget, 'slash_command_error_missing_argument')	
			end
		end
		ChatClient.RegisterChatCommand('whisper', WhisperCallback, 2, false, true, true)
		SetSave('chat_rememberedWhisperersSize', 10, 'int')
	
		local function IgnoreCallback(commandType, commandIdentifier, ...)
			println('^c IgnoreCallback ' .. tostring(commandType) .. '|' .. tostring(commandIdentifier) .. ' : ' .. tostring(arg[1]) .. ' | ' .. tostring(arg[2]).. ' | mainUI.SlashCommands.slashCommandTarget.identid): ' .. tostring(mainUI.SlashCommands.slashCommandTarget.identid) .. '\n')
			if mainUI.SlashCommands.slashCommandTarget.identid then
				ChatClient.AddIgnore(mainUI.SlashCommands.slashCommandTarget.identid)
			elseif (arg[1]) and (not Empty(arg[1])) then
				local identID = ChatClient.LookupClientIdentID(arg[1])
				if IsValidIdent(identID) then 
					ChatClient.AddIgnore(identID)
				else
					SlashCommandError(mainUI.SlashCommands.slashCommandTarget.widget, 'slash_command_error_invalid_target')
				end
			else
				SlashCommandError(mainUI.SlashCommands.slashCommandTarget.widget, 'slash_command_error_invalid_target')
			end
		end
		ChatClient.RegisterChatCommand('mute', IgnoreCallback, 1, false, true, true)	
	
		local function UnIgnoreCallback(commandType, commandIdentifier, ...)
			println('^c UnIgnoreCallback ' .. tostring(commandType) .. '|' .. tostring(commandIdentifier) .. ' : ' .. tostring(arg[1]) .. ' | ' .. tostring(arg[2]).. ' | mainUI.SlashCommands.slashCommandTarget.identid): ' .. tostring(mainUI.SlashCommands.slashCommandTarget.identid) .. '\n')
			if mainUI.SlashCommands.slashCommandTarget.identid then
				ChatClient.RemoveIgnore(mainUI.SlashCommands.slashCommandTarget.identid)
			elseif (arg[1]) and (not Empty(arg[1])) then
				local identID = ChatClient.LookupClientIdentID(arg[1])
				if IsValidIdent(identID) then 
					ChatClient.RemoveIgnore(identID)
				else
					SlashCommandError(mainUI.SlashCommands.slashCommandTarget.widget, 'slash_command_error_invalid_target')
				end
			else
				SlashCommandError(mainUI.SlashCommands.slashCommandTarget.widget, 'slash_command_error_invalid_target')
			end
		end
		ChatClient.RegisterChatCommand('unmute', UnIgnoreCallback, 1, false, true, true)	
	
	end
	
end
	
SlashCommandsRegister(object)

-- Strife_Web_Requests:SearchNickname(searchString, successFunction, failFunction) -- web known clients - limited results but shows offline
-- Client.GetClientList(searchString, chatServerCallbackFunction) 					-- chatserver known clients -- must be online
-- Client.SearchKnownClients(searchString, true) 									-- client known clients -  (nickname, partial=true)

-- string ChatClient.LookupClientIdentID(string sName)								-- looks for Name.Unique first if it exists then Name if it's unique in your known clients, then if you passed the exact ident it looks that up and verifies it, then returns the ident as a string
-- table ChatClient.FindClientsByName(string sName) 								-- the middle step from above, returns all idents of the name as strings in a table
-- table ChatClient.FindClientsBySubstring(string sName) 							-- looks from the beginning of the string the passed argument, So if you looked up "Ba" you would get Bane, and Bangerz, I see using this with conjunction of pressing tab while typing a chat command

-- void ChatClient.RegisterChatCommand(string sCmdName, script lua, number iMinArgs, bool bNoHelp = false, bool bNoHelp = true (more help), bool bConcatToMin = false)
-- function callback(type, identifier, [argTable])

-- table ChatClient.GetRecentMessagers()
-- idents of last X people that messaged you where X is chat_rememberedWhisperersSize

-- using stream name chat_command if you want to customize how it looks name comes from chat_command_name
-- using stream name pm when sending to a conversation

