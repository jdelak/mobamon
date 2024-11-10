local interface = object

mainUI = mainUI or {}
mainUI.Clans = mainUI.Clans or {}
mainUI.Clans.stream = 'member'

local function RegisterClansChat(object)
	
	-- println('RegisterClansChat 1/2')
	
	local slashInit = false
	
	local outputBuffer 			= object:GetWidget('clans_window_output')
	local inputBuffer 			= object:GetWidget('clans_window_input')	
	
	local function RegisterBuffers(object)

		interface:GetWidget('clans_window_buffer'):RegisterWatchLua(
			'ChatClanInfo', function(sourceWidget, trigger)
				if (trigger.id) and (trigger.id ~= '') and (trigger.id ~= '0.000') then
					outputBuffer:SetClan()
					inputBuffer:SetClan()
					if (not slashInit) then
						slashInit = true
						mainUI.SlashCommands.RegisterInput(inputBuffer, 'clan', 'clan', 'channel')
					end
				end
			end
		)		

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

		mainUI.Clans.stream = 'member'
		inputBuffer:SetStream('member')
		inputBuffer:SetInputLine('')

		local function UpdateTopic()
			mainUI.savedLocally = mainUI.savedLocally or {}
			local ChatClanInfo = LuaTrigger.GetTrigger('ChatClanInfo')
			-- println('UpdateTopic ' .. tostring(ChatClanInfo.topic) )
			if (ChatClanInfo.topic ~= '') and ((mainUI.savedLocally.lastTopic == nil) or (mainUI.savedLocally.lastTopic and mainUI.savedLocally.lastTopic ~= ChatClanInfo.topic)) then
				ChatClient.DispatchMessageToLocalClientWindow(6, 6, '^*^393' .. ChatClanInfo.topic, Translate('chat_motd_msg'))
				mainUI.savedLocally.lastTopic = ChatClanInfo.topic
			end		
		end
		
		interface:GetWidget('clans_chat_parent'):RegisterWatchLua('ChatClanInfo', function(widget, trigger)
			UpdateTopic()
		end, false, nil, 'topic')			
		
		UpdateTopic()
		
	end
	
	RegisterBuffers(object)

	outputBuffer:SetCallback('onfocus', function(widget)
		inputBuffer:SetFocus(true)
	end)
	
	local clans_parent 	= interface:GetWidget('clans_parent')
	clans_parent:SetCallback('onclick', function(widget)
		inputBuffer:SetFocus(false)
	end)
	
	function mainUI.Clans.SendOfficerMessage(message)
		inputBuffer:SetStream('officer')
		inputBuffer:SetInputLine(message)
		inputBuffer:ProcessInputLine()
		inputBuffer:SetStream(mainUI.Clans.stream)
		local combo = interface:GetWidget('clans_window_input_combobox')
		if (combo) and (combo:IsValid()) then
			combo:SetSelectedItemByValue(mainUI.Clans.stream, true)
		end
	end
	
	function mainUI.Clans.SendMemberMessage(message)
		inputBuffer:SetStream('member')
		inputBuffer:SetInputLine(message)
		inputBuffer:ProcessInputLine()
		inputBuffer:SetStream(mainUI.Clans.stream)
		local combo = interface:GetWidget('clans_window_input_combobox')
		if (combo) and (combo:IsValid()) then
			combo:SetSelectedItemByValue(mainUI.Clans.stream, true)
		end
	end
	
	function mainUI.Clans.ChangeTopic(message)
		if (mainUI.Clans.CanEditTopic()) then
			ChatClient.SetClanTopic(message)
		end
	end
	
	-- println('RegisterClansChat 2/2')
	
end

RegisterClansChat(object)