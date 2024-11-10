-- Reconnect Dialog

function reconnectDialogRegister(object)
	-- local container			= object:GetWidget('reconnectDialog')
	-- local timeLabel			= object:GetWidget('reconnectDialogTimeLabel')
	-- local closeButton		= object:GetWidget('reconnectDialogClose')
	
	-- LuaTrigger.CreateCustomTrigger('ReconnectInfoTest',
	-- {
		-- { name	= 'address',	type	= 'string' },
		-- { name	= 'type',		type	= 'string' },
		-- { name	= 'show',		type	= 'boolean' },
	-- }
	-- )	
	
	libGeneral.createGroupTrigger('reconnectDialogVis', { 'GamePhase', 'ReconnectInfo' })
	
	object:RegisterWatchLua('reconnectDialogVis', function(widget, groupTrigger)

		local triggerPhase	= groupTrigger[1]
		local triggerShow	= groupTrigger[2]
		local reconnectAddress = triggerShow.address
		local reconnectType = triggerShow.type
		if (triggerPhase.gamePhase < 1 and triggerShow.show) then
			if (reconnectAddress) and (not Empty(reconnectAddress)) then
				local text = 'main_reconnect_text'
				-- allow them to abandon the game
				if (LuaTrigger.GetTrigger('ReconnectInfo').isRewarding and not LuaTrigger.GetTrigger('ReconnectInfo').hasLeaver) then
					text = 'main_abandon_text'
				end	
				GenericDialog(
					'main_reconnect_header', '', text, 'general_reconnect', 'main_abandon',
						function()
							-- soundEvent
							if reconnectType == 'game' then
								Connect(reconnectAddress)
							elseif reconnectType == 'lobby' then
								ChatClient.JoinGame(reconnectAddress)
							end
						end,
						function()
							ChatClient.AbandonGame(triggerShow.gameUID)
						end)
			else 
				SevereError('main_reconnect_text_fail', 'main_reconnect_thatsucks', '', nil, nil, false)			
			end
		end
	end, true)

	object:RegisterWatchLua('ChatMissedGame', function(widget, trigger)
		if (trigger.address) and (not Empty(trigger.address)) then
			local text = 'main_missedgame_text'
			-- allow them to reconnect or abandon the game
			if (LuaTrigger.GetTrigger('ReconnectInfo').isRewarding and not LuaTrigger.GetTrigger('ReconnectInfo').hasLeaver) then
				text = 'main_abandon_text'
			end	
			GenericDialog(
				'main_missedgame_header', '', text, 'main_missedgame_ok', 'main_abandon',
					function()
						-- soundEvent
						Connect(trigger.address)
					end,
					function()
						ChatClient.AbandonGame(LuaTrigger.GetTrigger('ReconnectInfo').gameUID)
					end)
		end
	end, true)	
	
end

reconnectDialogRegister(object)