-- Push / Orb Thing
local interface = object
local gameUI = {}
gameUI.veryShortFade = 125
gameUI.shortFade = 250
gameUI.longFade = 500
gameUI.buildingAlertSleep = 7500

local GetTrigger = LuaTrigger.GetTrigger

function RegisterGameStateInfo(object)

	trigger_gamePanelInfo.orbExpanded = false
	trigger_gamePanelInfo.boss1Expanded = false
	trigger_gamePanelInfo.boss2Expanded = false
	trigger_gamePanelInfo.clockExpanded = false
	trigger_gamePanelInfo:Trigger(false)	
	
	local team_trigger 		=		GetTrigger('Team')
	
	-- Clock
	interface:GetWidget('game_push_clock'):RegisterWatchLua('gamePanelInfo', function(widget, trigger)
		
		local moreInfoKey	= trigger.moreInfoKey
		
		if trigger.mapWidgetVis_pushBar and (moreInfoKey or trigger.clockExpanded or trigger.clockExpandedPinned) then
			widget:FadeIn(gameUI.veryShortFade)
		else
			widget:FadeOut(gameUI.veryShortFade)
		end
	
	end, false, nil, 'moreInfoKey', 'clockExpanded', 'clockExpandedPinned', 'mapWidgetVis_pushBar')
	
	interface:GetWidget('game_push_clock_label'):RegisterWatchLua('MatchTime', function(widget, trigger) 
		if ((trigger.matchTime % 600000) <= 500) then
			trigger_gamePanelInfo.clockExpanded = true
			trigger_gamePanelInfo:Trigger(false)

			widget:Sleep(9500, function()
				trigger_gamePanelInfo.clockExpanded = false
				trigger_gamePanelInfo:Trigger(false)			
			end)			
		end
		if (trigger.matchTime >= 0) and (trigger.matchTime <= 4000000000) then
			widget:SetText(libNumber.timeFormat(trigger.matchTime))
		else
			widget:SetText('')
		end
	end)

	-- Boss 1 -- LanePushers0 SpawnerInfo0
	interface:GetWidget('game_push_boss_1'):RegisterWatchLua('gamePanelInfo', function(widget, trigger)	-- Krytos
		local moreInfoKey	= trigger.moreInfoKey
		
		if trigger.mapWidgetVis_pushBar and (trigger.mapWidgetVis_tabbing) and (moreInfoKey or trigger.boss1Expanded or trigger.boss1ExpandedPinned) then
			widget:FadeIn(gameUI.veryShortFade)
		else
			widget:FadeOut(gameUI.veryShortFade)
		end
		
	end, false, nil, 'moreInfoKey', 'boss1Expanded', 'boss1ExpandedPinned', 'mapWidgetVis_pushBar', 'mapWidgetVis_tabbing')
	
	local boss1wasalive = false
	interface:GetWidget('game_push_boss_1'):RegisterWatchLua('SpawnerInfo0', function(widget, trigger)	-- Krytos
		
		if (trigger.status == 1) or (boss1wasalive) then
			trigger_gamePanelInfo.boss1Expanded = true
			trigger_gamePanelInfo:Trigger(false)
			boss1wasalive = true
		end
		
		interface:GetWidget('game_push_boss_1_icon'):Sleep(4500, function()
			trigger_gamePanelInfo.boss1Expanded = false
			trigger_gamePanelInfo:Trigger(false)			
		end)		
		
		if (trigger.status == 0) then
			interface:GetWidget('game_push_boss_1_label'):SetText(libNumber.timeFormat(trigger.respawnCountDown))
			interface:GetWidget('game_push_boss_1_icon'):SetRenderMode('grayscale')
		else
			interface:GetWidget('game_push_boss_1_label'):SetText(Translate('game_boss_ready'))
			interface:GetWidget('game_push_boss_1_icon'):SetRenderMode('normal')
		end
	end, false, nil, 'status')
	
	interface:GetWidget('game_push_boss_1_label'):RegisterWatchLua('SpawnerInfo0', function(widget, trigger)	-- Krytos
		if (trigger.status == 0) then
			interface:GetWidget('game_push_boss_1_label'):SetText(libNumber.timeFormat(trigger.respawnCountDown))
		end
	end, false, nil, 'respawnCountDown')	
	
	-- boss 2
	interface:GetWidget('game_push_boss_2'):RegisterWatchLua('gamePanelInfo', function(widget, trigger)	-- Baldir
		local pushOrbVis	= trigger.pushOrbVis
		local moreInfoKey	= trigger.moreInfoKey
	
		if trigger.mapWidgetVis_pushBar and (trigger.mapWidgetVis_tabbing) and (moreInfoKey or trigger.boss2Expanded or trigger.boss1ExpandedPinned) then
			widget:FadeIn(gameUI.veryShortFade)
		else
			widget:FadeOut(gameUI.veryShortFade)
		end
	
	end, false, nil, 'moreInfoKey', 'boss2Expanded', 'boss1ExpandedPinned', 'mapWidgetVis_pushBar', 'mapWidgetVis_tabbing')
	
	local boss2wasalive = false
	interface:GetWidget('game_push_boss_2'):RegisterWatchLua('SpawnerInfo1', function(widget, trigger)	-- Baldir
		
		if (trigger.status == 1) or (boss2wasalive) then
			trigger_gamePanelInfo.boss2Expanded = true
			trigger_gamePanelInfo:Trigger(false)
			boss2wasalive = true
		end
		
		interface:GetWidget('game_push_boss_2_icon'):Sleep(4500, function()
			trigger_gamePanelInfo.boss2Expanded = false
			trigger_gamePanelInfo:Trigger(false)			
		end)			
		
		if (trigger.status == 0) then
			interface:GetWidget('game_push_boss_2_label'):SetText(libNumber.timeFormat(trigger.respawnCountDown))
			interface:GetWidget('game_push_boss_2_icon'):SetRenderMode('grayscale')
		else
			interface:GetWidget('game_push_boss_2_label'):SetText(Translate('game_boss_ready'))
			interface:GetWidget('game_push_boss_2_icon'):SetRenderMode('normal')
		end	
	end, false, nil, 'status')	
	
	interface:GetWidget('game_push_boss_2_label'):RegisterWatchLua('SpawnerInfo1', function(widget, trigger)	-- Baldir
		if (trigger.status == 0) then
			interface:GetWidget('game_push_boss_2_label'):SetText(libNumber.timeFormat(trigger.respawnCountDown))
		end
	end, false, nil, 'respawnCountDown')
	
	RegisterGameStateInfo = nil
end
RegisterGameStateInfo(object)