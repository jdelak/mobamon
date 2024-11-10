local interface = object
TDM = TDM or {}

function TDM.Init(object)
	
	local function Start()
		TDM.totalLives = GetCvarNumber('tdm_totalLives', true) or  40
		
		local teamTrigger = LuaTrigger.GetTrigger('Team')
		local team = teamTrigger.team
		
		object:GetWidget('tdm_lives_team_1'):RegisterWatchLua('Team', function(widget, trigger)
			widget:SetVisible(1)
			if (trigger.team == 1) then
				widget:SetColor('0 1 0 1')
				widget:SetText(Translate('general_your_lives') .. ' ' .. math.ceil(TDM.totalLives))
			else
				widget:SetColor('red')
				widget:SetText(Translate('general_enemy_lives') .. ' ' .. math.ceil(TDM.totalLives))
			end
		end, false, nil, 'team')	
		
		object:GetWidget('tdm_lives_team_2'):RegisterWatchLua('Team', function(widget, trigger)
			widget:SetVisible(1)
			if (trigger.team == 2) then
				widget:SetColor('0 1 0 1')
				widget:SetText(Translate('general_your_lives') .. ' ' .. math.ceil(TDM.totalLives))
			else
				widget:SetColor('red')
				widget:SetText(Translate('general_enemy_lives') .. ' ' .. math.ceil(TDM.totalLives))
			end
		end, false, nil, 'team')	
		
		object:GetWidget('tdm_lives_team_1'):RegisterWatchLua('BaseHealth0', function(widget, trigger)
			if (team == 1) then
				widget:SetColor('0 1 0 1')
				widget:SetText(Translate('general_your_lives') .. ' ' .. math.ceil(TDM.totalLives * trigger.healthPercent))
			else
				widget:SetColor('red')
				widget:SetText(Translate('general_enemy_lives') .. ' ' .. math.ceil(TDM.totalLives * trigger.healthPercent))
			end		
		end, false, nil, 'healthPercent')

		object:GetWidget('tdm_lives_team_2'):RegisterWatchLua('BaseHealth1', function(widget, trigger)
			if (team == 2) then
				widget:SetColor('0 1 0 1')
				widget:SetText(Translate('general_your_lives') .. ' ' .. math.ceil(TDM.totalLives * trigger.healthPercent))
			else
				widget:SetColor('red')
				widget:SetText(Translate('general_enemy_lives') .. ' ' .. math.ceil(TDM.totalLives * trigger.healthPercent))
			end		
		end, false, nil, 'healthPercent')	
		
		LuaTrigger.GetTrigger('Team'):Trigger(true)
		LuaTrigger.GetTrigger('BaseHealth0'):Trigger(true)
		LuaTrigger.GetTrigger('BaseHealth1'):Trigger(true)		
		
	end
	
	object:GetWidget('tdm_helper'):RegisterWatch('mapWidgetVis_tdm_show', function(widget)
		trigger_gamePanelInfo.mapWidgetVis_tdm = true
		trigger_gamePanelInfo:Trigger(false)
		TDM.mapWidgetVis_tdm = trigger_gamePanelInfo.mapWidgetVis_tdm
		Start()
	end)
	
	object:GetWidget('tdm_helper'):RegisterWatch('mapWidgetVis_canToggleShop_disable', function(widget)
		trigger_gamePanelInfo.mapWidgetVis_canToggleShop = false
		trigger_gamePanelInfo:Trigger(false)
		TDM.mapWidgetVis_canToggleShop = trigger_gamePanelInfo.mapWidgetVis_canToggleShop
	end)	
	
	object:GetWidget('tdm_helper'):RegisterWatch('mapWidgetVis_pushBar_hide', function(widget)
		trigger_gamePanelInfo.mapWidgetVis_pushBar = false
		trigger_gamePanelInfo:Trigger(false)
		TDM.mapWidgetVis_pushBar = trigger_gamePanelInfo.mapWidgetVis_pushBar
	end)

	object:GetWidget('tdm_helper'):RegisterWatch('mapWidgetVis_kills_show', function(widget)
		trigger_gamePanelInfo.mapWidgetVis_kills = true
		trigger_gamePanelInfo:Trigger(false)
		TDM.mapWidgetVis_kills = trigger_gamePanelInfo.mapWidgetVis_kills
	end)	
	
	object:GetWidget('tdm_helper'):RegisterWatch('mapWidgetVis_inventory_hide', function(widget)
		trigger_gamePanelInfo.mapWidgetVis_inventory = false
		trigger_gamePanelInfo.backpackVis = false
		trigger_gamePanelInfo:Trigger(false)
		TDM.mapWidgetVis_inventory = trigger_gamePanelInfo.mapWidgetVis_inventory
	end)		
	
	if (TDM.mapWidgetVis_tdm) then
		libThread.threadFunc(function()
			wait(1)
			trigger_gamePanelInfo.mapWidgetVis_canToggleShop 		= 		TDM.mapWidgetVis_canToggleShop or false
			trigger_gamePanelInfo.mapWidgetVis_pushBar 				= 		TDM.mapWidgetVis_pushBar or false
			trigger_gamePanelInfo.mapWidgetVis_kills 				= 		TDM.mapWidgetVis_kills or false
			trigger_gamePanelInfo.mapWidgetVis_tdm 					= 		TDM.mapWidgetVis_tdm or true
			trigger_gamePanelInfo.mapWidgetVis_inventory 			= 		TDM.mapWidgetVis_inventory or false
			trigger_gamePanelInfo.backpackVis 						= 		TDM.mapWidgetVis_inventory or false
			trigger_gamePanelInfo:Trigger(false)
			Start()
		end)
	end
	
		-- Cmd('Trigger mapWidgetVis_canToggleShop_disable')
		-- Cmd('Trigger mapWidgetVis_pushBar_hide')
		-- Cmd('Trigger mapWidgetVis_kills_show')
		-- Cmd('Trigger mapWidgetVis_tdm_show')
		-- Cmd('Trigger mapWidgetVis_inventory_hide');
	
end

TDM.Init(object)



