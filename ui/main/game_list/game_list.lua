-- Game List
local interface = object


local selectedServer = ''
local function SelectServer()

	local triggerPanelStatus = LuaTrigger.GetTrigger('mainPanelStatus')
	triggerPanelStatus.mainMoreVisible			= false
	triggerPanelStatus.main						= 101
	triggerPanelStatus.socialUserListVisible	= false
	triggerPanelStatus:Trigger(false)

	ChatClient.JoinGame(selectedServer or -1, true, 'loading', false, false)
	--CancelServerList()

end

interface:GetWidget('main_game_list_listbox'):SetCallback('onselect', function(widget)
	-- gameListSelectGame
	-- PlaySound('/path_to/filename.wav')
	selectedServer = widget:GetValue()
	interface:GetWidget('main_game_list_join_button'):SetEnabled(1)
end)
interface:GetWidget('main_game_list_listbox'):SetCallback('ondoubleclick', function(widget)
	-- gameListSelectDoubleClick
	-- PlaySound('/path_to/filename.wav')
	selectedServer = widget:GetValue()
	SelectServer()
end)	
interface:GetWidget('main_game_list_listbox'):RegisterWatchLua('LobbyListStatus',  function(widget, trigger)
	if (not trigger.isWorking) then
		if (widget:GetNumListItems() == 0) then
			GetWidget('game_list_message'):SetText(Translate('main_lobby_no_games_found'))
		end
	end
end)

interface:GetWidget('main_game_list_join_button'):SetCallback('onclick', function(widget)
	-- gameListJoin
	-- PlaySound('/path_to/filename.wav')
	SelectServer()
end)

interface:GetWidget('main_game_list_parent'):RegisterWatchLua('mainPanelAnimationStatus', function(widget, trigger)
	if (trigger.newMain ~= 24) and (trigger.newMain ~= -1) then			-- outro
		widget:FadeOut(250)
	elseif (trigger.main ~= 24) and (trigger.newMain ~= 24) then			-- fully hidden
		widget:SetVisible(false)	
	elseif (trigger.newMain == 24) and (trigger.newMain ~= -1) then		-- intro
		libThread.threadFunc(function()	
			wait(1)
			-- groupfcall('creategame_animation_widgets', function(_, widget) RegisterRadialEase(widget,  508, 555, true) widget:DoEventN(7) end)			
			groupfcall('game_list_animation_widgets', function(_, widget) RegisterRadialEase(widget,  508, 555, true) widget:DoEventN(7) end)			
		end)
	elseif (trigger.main == 24) then										-- fully displayed
		widget:SetVisible(true)	
		Client.GetLobbyList()
		
		-- RMM Disabled rewards dialog
		GenericDialog(
			Translate('general_norewards'), Translate('general_norewards_desc'), Translate('general_play_anyway'), Translate('general_proceed'), Translate('general_cancel'), 
			function() end,
			function()
				local mainPanelStatus = LuaTrigger.GetTrigger('mainPanelStatus')
				mainPanelStatus.main = 101
				mainPanelStatus:Trigger(false)
			end,
			nil,
			nil,
			nil,
			true
		)		
	end
end, false, nil, 'main', 'newMain', 'lastMain')	

-- interface:GetWidget('main_game_list_parent'):RegisterWatchLua('GameListStatus',  function(widget, trigger)
	
	-- interface:GetWidget('main_game_list_retrieving_label_2'):SetVisible(trigger.isList)
	-- interface:GetWidget('main_game_list_retrieving_label_3'):SetVisible(not trigger.isList)
	
	-- if (trigger.isWorking) then
		-- interface:GetWidget('main_game_list_refresh_button'):SetVisible(0)
		-- interface:GetWidget('main_game_list_retrieving'):SetVisible(1)
		-- interface:GetWidget('main_game_list_retrieving_panel_1'):SetWidth(ToPercent(trigger.processed .. ' / ' .. trigger.total))
		-- interface:GetWidget('main_game_list_retrieving_label_3'):SetText(trigger.processed .. ' / ' .. trigger.total)	
		-- interface:GetWidget('main_game_list_status_throb_1'):SetVisible(1)
		-- interface:GetWidget('main_game_list_status_parent_1'):SetVisible(1)
		-- interface:GetWidget('main_game_list_status_label_1'):SetText(Translate('main_lobby_responses', 'visible', trigger.visible, 'count', trigger.total))
		-- GetWidget('game_list_message'):SetVisible(true)
		-- GetWidget('game_list_message'):SetText(Translate('mainlobby_label_custom_searching'))
	-- else
		-- interface:GetWidget('main_game_list_retrieving'):SetVisible(0)
		-- interface:GetWidget('main_game_list_retrieving_label_2'):SetVisible(0)	
		-- interface:GetWidget('main_game_list_status_throb_1'):SetVisible(0)		
		-- interface:GetWidget('main_game_list_status_parent_1'):SetVisible(0)
		-- if (trigger.visible > 0) then
			-- interface:GetWidget('main_game_list_refresh_button'):SetVisible(1)
			-- GetWidget('game_list_message'):SetVisible(false)		
		-- else
			-- interface:GetWidget('main_game_list_refresh_button'):SetVisible(1)
			-- GetWidget('game_list_message'):SetVisible(true)
			-- GetWidget('game_list_message'):SetText(Translate('main_lobby_no_servers_found'))			
		-- end
	-- end
-- end)


