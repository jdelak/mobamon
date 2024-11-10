-- Custom triggers for game ui only


local interface = object

function gameGetInterface()
	return interface
end

function gameGetWidget(widgetName)
	return interface:GetWidget(widgetName)
end

LuaTrigger.CreateCustomTrigger('gameRefreshKeyLabels', {
	{ name	= 'time',	type	= 'number' }
})

LuaTrigger.CreateCustomTrigger('mutePlayerInfo', {
	{ name	= 'IdentID',	type	= 'string' },
	{ name	= 'muted',		type	= 'boolean' },
})

trigger_gamePlayerGPMCompare = LuaTrigger.CreateCustomTrigger('game_specPlayerGPMCompare', {
	{ name	= 'player0GPM',								type		= 'number' },
	{ name	= 'player1GPM',								type		= 'number' },
	{ name	= 'player2GPM',								type		= 'number' },
	{ name	= 'player3GPM',								type		= 'number' },
	{ name	= 'player4GPM',								type		= 'number' },
	{ name	= 'player5GPM',								type		= 'number' },
	{ name	= 'player6GPM',								type		= 'number' },
	{ name	= 'player7GPM',								type		= 'number' },
	{ name	= 'player8GPM',								type		= 'number' },
	{ name	= 'player9GPM',								type		= 'number' },
})
trigger_game_specPlayerKillAssistsCompare = LuaTrigger.CreateCustomTrigger('game_specPlayerKillAssistsCompare', {
	{ name	= 'player0KillAssists',								type		= 'number' },
	{ name	= 'player1KillAssists',								type		= 'number' },
	{ name	= 'player2KillAssists',								type		= 'number' },
	{ name	= 'player3KillAssists',								type		= 'number' },
	{ name	= 'player4KillAssists',								type		= 'number' },
	{ name	= 'player5KillAssists',								type		= 'number' },
	{ name	= 'player6KillAssists',								type		= 'number' },
	{ name	= 'player7KillAssists',								type		= 'number' },
	{ name	= 'player8KillAssists',								type		= 'number' },
	{ name	= 'player9KillAssists',								type		= 'number' },
})
trigger_game_specPanelInfo = LuaTrigger.CreateCustomTrigger('game_specPanelInfo', {
	{ name	= 'team',								type		= 'number' },
	{ name	= 'shopOpen',							type		= 'boolean' },
	{ name	= 'shopView',							type		= 'number' },
	{ name	= 'shopIsFiltered',						type		= 'boolean' },
	{ name	= 'shopHasFiltersToDisplay',			type		= 'boolean' },
	{ name	= 'shopShowFilters',					type		= 'boolean' },
	{ name	= 'shopCategory',						type		= 'string' },
	{ name	= 'shopItemView',						type		= 'number' },
	{ name	= 'shopDraggedItem',					type		= 'string' },
	{ name	= 'shopLastBuyQueueDragged',			type		= 'number' },
	{ name	= 'shopLastQuickSlotDragged',			type		= 'number' },
	{ name	= 'shopTooltipMoreInfo',				type		= 'boolean' },
	{ name	= 'abilityPanel',						type		= 'boolean' },
	{ name	= 'abilityPanelView',					type		= 'number' },
	{ name	= 'moreInfoKey',						type		= 'boolean' },
	{ name	= 'selectedShopItem',					type		= 'number' },
	{ name	= 'selectedShopItemType',				type		= 'string' },
	{ name	= 'unitFramesVis',						type		= 'boolean' },
	{ name	= 'statsVis',							type		= 'boolean' },
	{ name	= 'pushBarVis',							type		= 'boolean' },
	{ name	= 'selectedUnitVis',					type		= 'boolean' },
	{ name	= 'replayControlsVis',					type		= 'boolean' },
	{ name	= 'heroInfoVis',						type		= 'boolean' },
	{ name	= 'player0Exists',						type		= 'boolean' },
	{ name	= 'player1Exists',						type		= 'boolean' },
	{ name	= 'player2Exists',						type		= 'boolean' },
	{ name	= 'player3Exists',						type		= 'boolean' },
	{ name	= 'player4Exists',						type		= 'boolean' },
	{ name	= 'player5Exists',						type		= 'boolean' },
	{ name	= 'player6Exists',						type		= 'boolean' },
	{ name	= 'player7Exists',						type		= 'boolean' },
	{ name	= 'player8Exists',						type		= 'boolean' },
	{ name	= 'player9Exists',						type		= 'boolean' },
	{ name	= 'player0MVP',							type		= 'boolean' },
	{ name	= 'player1MVP',							type		= 'boolean' },
	{ name	= 'player2MVP',							type		= 'boolean' },
	{ name	= 'player3MVP',							type		= 'boolean' },
	{ name	= 'player4MVP',							type		= 'boolean' },
	{ name	= 'player5MVP',							type		= 'boolean' },
	{ name	= 'player6MVP',							type		= 'boolean' },
	{ name	= 'player7MVP',							type		= 'boolean' },
	{ name	= 'player8MVP',							type		= 'boolean' },
	{ name	= 'player9MVP',							type		= 'boolean' },
	{ name	= 'unitFramesPinned',					type		= 'boolean' },	
	{ name	= 'aspect',								type		= 'number' },
	{ name	= 'gameMenuExpanded',					type		= 'boolean' }
})
trigger_gameAllyGPMCompare = LuaTrigger.CreateCustomTrigger('gameAllyGPMCompare', {
	{ name	= 'ally0GPM',								type		= 'number' },
	{ name	= 'ally1GPM',								type		= 'number' },
	{ name	= 'ally2GPM',								type		= 'number' },
	{ name	= 'ally3GPM',								type		= 'number' },
	{ name	= 'ally4GPM',								type		= 'number' }	-- Self, for convenience sake
})

trigger_gameEnemyGPMCompare = LuaTrigger.CreateCustomTrigger('gameEnemyGPMCompare', {
	{ name	= 'enemy0GPM',								type		= 'number' },
	{ name	= 'enemy1GPM',								type		= 'number' },
	{ name	= 'enemy2GPM',								type		= 'number' },
	{ name	= 'enemy3GPM',								type		= 'number' },
	{ name	= 'enemy4GPM',								type		= 'number' }
})

trigger_gameAllyKillAssistsCompare = LuaTrigger.CreateCustomTrigger('gameAllyKillAssistsCompare', {
	{ name	= 'ally0KillAssists',								type		= 'number' },
	{ name	= 'ally1KillAssists',								type		= 'number' },
	{ name	= 'ally2KillAssists',								type		= 'number' },
	{ name	= 'ally3KillAssists',								type		= 'number' },
	{ name	= 'ally4KillAssists',								type		= 'number' }	-- Self, for convenience sake
})

trigger_gameEnemyKillAssistsCompare = LuaTrigger.CreateCustomTrigger('gameEnemyKillAssistsCompare', {
	{ name	= 'enemy0KillAssists',								type		= 'number' },
	{ name	= 'enemy1KillAssists',								type		= 'number' },
	{ name	= 'enemy2KillAssists',								type		= 'number' },
	{ name	= 'enemy3KillAssists',								type		= 'number' },
	{ name	= 'enemy4KillAssists',								type		= 'number' }
})

object:RegisterWatchLua('ShopActive', function(widget, trigger)
	if trigger_gamePanelInfo.mapWidgetVis_canToggleShop then
		local active = trigger.isActive

		if active then
			if trigger_gamePanelInfo.shopOpen == false then
				trigger_gamePanelInfo.abilityPanel = false
			end
		else
			if trigger_gamePanelInfo.shopOpen and trigger_gamePanelInfo.abilityPanel then
				widget:UICmd("OpenShop()")	-- Keep open and instead 
				trigger_gamePanelInfo.abilityPanel = false
			end
		end

		trigger_gamePanelInfo.shopOpen = active
		trigger_gamePanelInfo:Trigger(false)
	else
		if trigger_gamePanelInfo.shopOpen then
			widget:UICmd("OpenShop()")
		else
			widget:UICmd("CloseShop()")
		end
	end
end)

LuaTrigger.CreateCustomTrigger('channelBarVis',
	{
		{ name	= 'isChanneling', type	= 'boolean' }
	}
)

LuaTrigger.CreateCustomTrigger('respawnBarVis',
	{
		{ name	= 'isChanneling', type	= 'boolean' }
	}
)

-- ===================================

object:RegisterWatchLua('gamePanelInfo', function(widget, trigger)
	trigger_shopFilter.shopView = trigger.shopView
	trigger_shopFilter:Trigger(false)
end, false, nil, 'shopView')

object:RegisterWatchLua('game_specPanelInfo', function(widget, trigger)
	trigger_shopFilter.shopView = trigger.shopView
	trigger_shopFilter:Trigger(false)	
end, false, nil, 'shopView')
object:RegisterWatchLua('gameShopFilterInfo', function(widget, trigger)
	trigger_gamePanelInfo.shopCategory = trigger.shopCategory
	trigger_gamePanelInfo:Trigger(false)
	trigger_game_specPanelInfo.shopCategory = trigger.shopCategory
	trigger_game_specPanelInfo:Trigger(false)
end, false, nil, 'shopCategory')

LuaTrigger.CreateCustomTrigger('itemGuidanceTrigger', {
	{ name	= 'cost',			type	= 'number' 	},
	{ name	= 'visible',		type	= 'boolean' 	},
})