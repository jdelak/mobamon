-- Game Menu

function GameMenuToggle()
	if GetWidget('game_menu_parent', 'game', true) then
		GetWidget('game_menu_parent', 'game', true):SetVisible(not GetWidget('game_menu_parent', 'game', true):IsVisible())
	end
end

local function GameMenuRegister(object)

	object:GetWidget('game_menu_pause'):RegisterWatchLua('PauseTimeInfo', function(widget, trigger)
		if (trigger.canGeneralPause) or ((trigger.remainingPlayerPause == trigger.maxPlayerPause) and (trigger.remainingPlayerPause > 0)) then
			widget:SetEnabled(1)
		else
			widget:SetEnabled(0)
		end
	end, false, nil)		
	
	object:GetWidget('game_menu_unpause'):RegisterWatchLua('PauseTimeInfo', function(widget, trigger)
		if (trigger.canUnpause) then
			widget:SetEnabled(1)
		else
			widget:SetEnabled(0)
		end
	end, false, nil)	
	
	object:GetWidget('game_menu_pause'):RegisterWatchLua('GameIsPaused', function(widget, trigger)
		widget:SetVisible(not trigger.paused)
	end)
	
	object:GetWidget('game_menu_unpause'):RegisterWatchLua('GameIsPaused', function(widget, trigger)
		widget:SetVisible(trigger.paused)
	end)
	
	object:GetWidget('game_menu_parent'):SetCallback('onshow', function()
		LuaTrigger.GetTrigger('gamePanelInfo').gameMenuExpanded = true
		LuaTrigger.GetTrigger('gamePanelInfo'):Trigger(false)
		LuaTrigger.GetTrigger('game_specPanelInfo').gameMenuExpanded = true
		LuaTrigger.GetTrigger('game_specPanelInfo'):Trigger(false)		
	end)
	
	object:GetWidget('game_menu_parent'):SetCallback('onhide', function()
		LuaTrigger.GetTrigger('gamePanelInfo').gameMenuExpanded = false
		LuaTrigger.GetTrigger('gamePanelInfo'):Trigger(false)
		LuaTrigger.GetTrigger('game_specPanelInfo').gameMenuExpanded = false
		LuaTrigger.GetTrigger('game_specPanelInfo'):Trigger(false)		
	end)
	
end

GameMenuRegister(object)