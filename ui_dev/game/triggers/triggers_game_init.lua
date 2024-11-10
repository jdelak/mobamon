-- Initialize trigger default values, etc.

for k,v in pairs(preTrigger_shopFilterList) do
	trigger_shopFilter[k] = false
end

local triggerKeyRefresh = LuaTrigger.GetTrigger('gameRefreshKeyLabels')
triggerKeyRefresh.time = 0
triggerKeyRefresh:Trigger(true)


trigger_shopFilter.shopCategory = 'crafted+itembuild'
trigger_shopFilter.forceCategory = ''
trigger_shopFilter.shopView  = Cvar.GetCvar('_shopView'):GetNumber()
trigger_shopFilter:Trigger(true)

trigger_gameAllyGPMCompare.ally0GPM	= 0
trigger_gameAllyGPMCompare.ally1GPM	= 0
trigger_gameAllyGPMCompare.ally2GPM	= 0
trigger_gameAllyGPMCompare.ally3GPM	= 0
trigger_gameAllyGPMCompare.ally4GPM	= 0
trigger_gameAllyGPMCompare:Trigger(true)

trigger_gameEnemyGPMCompare.enemy0GPM	= 0
trigger_gameEnemyGPMCompare.enemy1GPM	= 0
trigger_gameEnemyGPMCompare.enemy2GPM	= 0
trigger_gameEnemyGPMCompare.enemy3GPM	= 0
trigger_gameEnemyGPMCompare.enemy4GPM	= 0
trigger_gameEnemyGPMCompare:Trigger(true)

trigger_gameAllyKillAssistsCompare.ally0KillAssists	= 0
trigger_gameAllyKillAssistsCompare.ally1KillAssists	= 0
trigger_gameAllyKillAssistsCompare.ally2KillAssists	= 0
trigger_gameAllyKillAssistsCompare.ally3KillAssists	= 0
trigger_gameAllyKillAssistsCompare.ally4KillAssists	= 0
trigger_gameAllyKillAssistsCompare:Trigger(true)

trigger_gameEnemyKillAssistsCompare.enemy0KillAssists	= 0
trigger_gameEnemyKillAssistsCompare.enemy1KillAssists	= 0
trigger_gameEnemyKillAssistsCompare.enemy2KillAssists	= 0
trigger_gameEnemyKillAssistsCompare.enemy3KillAssists	= 0
trigger_gameEnemyKillAssistsCompare.enemy4KillAssists	= 0
trigger_gameEnemyKillAssistsCompare:Trigger(true)

trigger_gamePanelInfo.team							= LuaTrigger.GetTrigger('Team').team
trigger_gamePanelInfo.shopOpen						= LuaTrigger.GetTrigger('ShopActive').isActive
trigger_gamePanelInfo.shopView						= Cvar.GetCvar('_shopView'):GetNumber()			-- [0], My Builds [1] Items
trigger_gamePanelInfo.shopIsFiltered				= false
trigger_gamePanelInfo.shopHasFiltersToDisplay		= false
trigger_gamePanelInfo.shopShowFilters				= false
trigger_gamePanelInfo.shopItemView					= Cvar.GetCvar('_shopItemView'):GetNumber()		-- [0] Simple, [1] Detailed
trigger_gamePanelInfo.shopDraggedItem				= ''
trigger_gamePanelInfo.shopDraggedItemScroll			= false
trigger_gamePanelInfo.shopDraggedItemOwnedRecipe	= false
trigger_gamePanelInfo.draggedInventoryIndex			= -1
trigger_gamePanelInfo.shopLastBuyQueueDragged		= -1
trigger_gamePanelInfo.shopLastQuickSlotDragged		= -1
trigger_gamePanelInfo.shopTooltipMoreInfo			= false
trigger_gamePanelInfo.abilityPanel					= false
trigger_gamePanelInfo.abilityPanelView				= Cvar.GetCvar('_abilityPanelView'):GetNumber()	-- [0] Simple, [1] Detailed
trigger_gamePanelInfo.moreInfoKey					= false
trigger_gamePanelInfo.selectedShopItem				= -1
trigger_gamePanelInfo.selectedShopItemType			= ''
trigger_gamePanelInfo.mapWidgetVis_inventory		= true
trigger_gamePanelInfo.backpackVis					= Cvar.GetCvar('_backpackVis'):GetBoolean() and trigger_gamePanelInfo.mapWidgetVis_inventory
trigger_gamePanelInfo.heroVitalsVis					= Cvar.GetCvar('_heroVitalsVis'):GetBoolean()
trigger_gamePanelInfo.lanePusherVis					= false
trigger_gamePanelInfo.channelBarVis					= false
trigger_gamePanelInfo.respawnBarVis					= false
trigger_gamePanelInfo.pushOrbVis					= Cvar.GetCvar('_pushOrbVis'):GetBoolean()
trigger_gamePanelInfo.heroInfoVis					= Cvar.GetCvar('_heroInfoVis'):GetBoolean()
trigger_gamePanelInfo.ally0Exists					= false
trigger_gamePanelInfo.ally1Exists					= false
trigger_gamePanelInfo.ally2Exists					= false
trigger_gamePanelInfo.ally3Exists					= false
trigger_gamePanelInfo.enemy0Exists					= false
trigger_gamePanelInfo.enemy1Exists					= false
trigger_gamePanelInfo.enemy2Exists					= false
trigger_gamePanelInfo.enemy3Exists					= false
trigger_gamePanelInfo.enemy4Exists					= false
trigger_gamePanelInfo.enemy0Exists					= false
trigger_gamePanelInfo.ally0MVP						= false
trigger_gamePanelInfo.ally1MVP						= false
trigger_gamePanelInfo.ally2MVP						= false
trigger_gamePanelInfo.ally3MVP						= false
trigger_gamePanelInfo.ally4MVP						= false
trigger_gamePanelInfo.enemy0MVP						= false
trigger_gamePanelInfo.enemy1MVP						= false
trigger_gamePanelInfo.enemy2MVP						= false
trigger_gamePanelInfo.enemy3MVP						= false
trigger_gamePanelInfo.enemy4MVP						= false
trigger_gamePanelInfo.unitFramesPinned				= false
trigger_gamePanelInfo.orbExpanded					= false
trigger_gamePanelInfo.orbExpandedPinned				= false
trigger_gamePanelInfo.boss1Expanded					= false
trigger_gamePanelInfo.boss1ExpandedPinned			= Cvar.GetCvar('_bossTimerVis'):GetBoolean()
trigger_gamePanelInfo.boss2Expanded					= false
trigger_gamePanelInfo.boss2ExpandedPinned			= Cvar.GetCvar('_bossTimerVis'):GetBoolean()
trigger_gamePanelInfo.clockExpanded					= false
trigger_gamePanelInfo.clockExpandedPinned			= Cvar.GetCvar('_pushOrbVis'):GetBoolean()
trigger_gamePanelInfo.mapWidgetVis_tabbing			= true
trigger_gamePanelInfo.mapWidgetVis_respawnTimer		= true
trigger_gamePanelInfo.mapWidgetVis_minimap			= true
trigger_gamePanelInfo.mapWidgetVis_items			= true
trigger_gamePanelInfo.mapWidgetVis_abilityBarPet	= true
trigger_gamePanelInfo.mapWidgetVis_pushBar			= true
trigger_gamePanelInfo.mapWidgetVis_heroInfos		= true
trigger_gamePanelInfo.mapWidgetVis_shopItemList		= true
trigger_gamePanelInfo.mapWidgetVis_courierButton	= true
trigger_gamePanelInfo.mapWidgetVis_portHomeButton	= true
trigger_gamePanelInfo.mapWidgetVis_abilityPanel		= true
trigger_gamePanelInfo.mapWidgetVis_shopQuickSlots	= true
trigger_gamePanelInfo.mapWidgetVis_shopClickable	= true
trigger_gamePanelInfo.mapWidgetVis_shopRightClick	= true
trigger_gamePanelInfo.mapWidgetVis_canToggleShop	= true
trigger_gamePanelInfo.mapWidgetVis_shopBootsGlow	= true
trigger_gamePanelInfo.mapWidgetVis_arcadeText		= true
trigger_gamePanelInfo.mapWidgetVis_buildControls	= true
trigger_gamePanelInfo.mapWidgetVis_kills			= false
trigger_gamePanelInfo.mapWidgetVis_tdm				= false
trigger_gamePanelInfo.gameMenuExpanded				= false
trigger_gamePanelInfo.goldSplashVisible				= false
trigger_gamePanelInfo.itemGuidanceVisible			= false

trigger_gamePanelInfo.aspect						= (GetScreenWidth() / GetScreenHeight())
trigger_gamePanelInfo:Trigger(true)

trigger_SPEAbilityUpdate.ShowActiveAbility0			= true
trigger_SPEAbilityUpdate.ShowActiveAbility1			= true
trigger_SPEAbilityUpdate.ShowActiveAbility2			= true
trigger_SPEAbilityUpdate.ShowActiveAbility3			= true
trigger_SPEAbilityUpdate.ShowActiveAbility4			= true
trigger_SPEAbilityUpdate.ShowActiveAbility5			= true
trigger_SPEAbilityUpdate.ShowActiveAbility6			= true
trigger_SPEAbilityUpdate.ShowActiveAbility64		= true
trigger_SPEAbilityUpdate.ShowActiveAbility65		= true
trigger_SPEAbilityUpdate.ShowActiveAbility66		= true
trigger_SPEAbilityUpdate:Trigger(true)

trigger_game_specPanelInfo.statsVis					= Cvar.GetCvar('_spec_statsVis'):GetBoolean()
trigger_game_specPanelInfo.pushBarVis				= Cvar.GetCvar('_spec_pushBarVis'):GetBoolean()
trigger_game_specPanelInfo.team						= LuaTrigger.GetTrigger('Team').team
trigger_game_specPanelInfo.shopOpen					= LuaTrigger.GetTrigger('ShopActive').isActive
trigger_game_specPanelInfo.shopView					= Cvar.GetCvar('_shopView'):GetNumber()			-- [0], My Builds [1] Items
trigger_game_specPanelInfo.shopIsFiltered			= false
trigger_game_specPanelInfo.shopHasFiltersToDisplay	= false
trigger_game_specPanelInfo.shopShowFilters			= false
trigger_game_specPanelInfo.shopItemView				= Cvar.GetCvar('_shopItemView'):GetNumber()		-- [0] Simple, [1] Detailed
trigger_game_specPanelInfo.shopDraggedItem			= ''
trigger_game_specPanelInfo.shopLastBuyQueueDragged	= -1
trigger_game_specPanelInfo.shopLastQuickSlotDragged	= -1
trigger_game_specPanelInfo.shopTooltipMoreInfo		= false
trigger_game_specPanelInfo.abilityPanel				= false
trigger_game_specPanelInfo.abilityPanelView			= Cvar.GetCvar('_abilityPanelView'):GetNumber()	-- [0] Simple, [1] Detailed
trigger_game_specPanelInfo.moreInfoKey				= false
trigger_game_specPanelInfo.selectedShopItem			= -1
trigger_game_specPanelInfo.selectedShopItemType		= ''
trigger_game_specPanelInfo.backpackVis				= Cvar.GetCvar('_spec_unitFramesVis'):GetBoolean()
trigger_game_specPanelInfo.heroVitalsVis			= Cvar.GetCvar('_spec_selectedUnitVis'):GetBoolean()
trigger_game_specPanelInfo.selectedUnitVis			= Cvar.GetCvar('_spec_selectedUnitVis'):GetBoolean()
trigger_game_specPanelInfo.lanePusherVis			= false
trigger_game_specPanelInfo.channelBarVis			= false
trigger_game_specPanelInfo.respawnBarVis			= false
trigger_game_specPanelInfo.pushOrbVis				= Cvar.GetCvar('_spec_replayControlsVis'):GetBoolean()
trigger_game_specPanelInfo.heroInfoVis				= Cvar.GetCvar('_heroInfoVis'):GetBoolean()
trigger_game_specPanelInfo.player0Exists			= false
trigger_game_specPanelInfo.player1Exists			= false
trigger_game_specPanelInfo.player2Exists			= false
trigger_game_specPanelInfo.player3Exists			= false
trigger_game_specPanelInfo.player4Exists			= false
trigger_game_specPanelInfo.player5Exists			= false
trigger_game_specPanelInfo.player6Exists			= false
trigger_game_specPanelInfo.player7Exists			= false
trigger_game_specPanelInfo.player8Exists			= false
trigger_game_specPanelInfo.player9Exists			= false
trigger_game_specPanelInfo.player0MVP				= false
trigger_game_specPanelInfo.player1MVP				= false
trigger_game_specPanelInfo.player2MVP				= false
trigger_game_specPanelInfo.player3MVP				= false
trigger_game_specPanelInfo.player4MVP				= false
trigger_game_specPanelInfo.player5MVP				= false
trigger_game_specPanelInfo.player6MVP				= false
trigger_game_specPanelInfo.player7MVP				= false
trigger_game_specPanelInfo.player8MVP				= false
trigger_game_specPanelInfo.player9MVP				= false
trigger_game_specPanelInfo.aspect					= (GetScreenWidth() / GetScreenHeight())
trigger_game_specPanelInfo.gameMenuExpanded			= false
trigger_game_specPanelInfo:Trigger(true)

object:RegisterWatchLua('optionsTrigger', function(widget, trigger)
	trigger_gamePanelInfo.backpackVis					= Cvar.GetCvar('_backpackVis'):GetBoolean() and trigger_gamePanelInfo.mapWidgetVis_inventory
	trigger_gamePanelInfo.heroVitalsVis					= Cvar.GetCvar('_heroVitalsVis'):GetBoolean()
	trigger_gamePanelInfo.pushOrbVis					= Cvar.GetCvar('_pushOrbVis'):GetBoolean()
	trigger_gamePanelInfo.heroInfoVis					= Cvar.GetCvar('_heroInfoVis'):GetBoolean()
	trigger_gamePanelInfo.boss1ExpandedPinned			= Cvar.GetCvar('_bossTimerVis'):GetBoolean()
	trigger_gamePanelInfo.boss2Expanded					= false
	trigger_gamePanelInfo.boss2ExpandedPinned			= Cvar.GetCvar('_bossTimerVis'):GetBoolean()
	trigger_gamePanelInfo.clockExpanded					= false
	trigger_gamePanelInfo.clockExpandedPinned			= Cvar.GetCvar('_pushOrbVis'):GetBoolean()	
	trigger_gamePanelInfo:Trigger(false)
		
	trigger_game_specPanelInfo.statsVis					= Cvar.GetCvar('_spec_statsVis'):GetBoolean()
	trigger_game_specPanelInfo.pushBarVis				= Cvar.GetCvar('_spec_pushBarVis'):GetBoolean()
	trigger_game_specPanelInfo.shopView					= Cvar.GetCvar('_shopView'):GetNumber()			-- [0], My Builds [1] Items
	trigger_game_specPanelInfo.shopItemView				= Cvar.GetCvar('_shopItemView'):GetNumber()		-- [0] Simple, [1] Detailed
	trigger_game_specPanelInfo.abilityPanelView			= Cvar.GetCvar('_abilityPanelView'):GetNumber()	-- [0] Simple, [1] Detailed
	trigger_game_specPanelInfo.backpackVis				= Cvar.GetCvar('_spec_unitFramesVis'):GetBoolean()
	trigger_game_specPanelInfo.heroVitalsVis			= Cvar.GetCvar('_spec_selectedUnitVis'):GetBoolean()
	trigger_game_specPanelInfo.pushOrbVis				= Cvar.GetCvar('_spec_replayControlsVis'):GetBoolean()
	trigger_game_specPanelInfo.heroInfoVis				= Cvar.GetCvar('_heroInfoVis'):GetBoolean()	
	trigger_game_specPanelInfo:Trigger(false)
	
end)

object:RegisterWatchLua('ModifierKeyStatus', function(widget, trigger)
	trigger_gamePanelInfo.moreInfoKey	= trigger.moreInfoKey
	trigger_gamePanelInfo:Trigger(false)
end, false, nil, 'moreInfoKey')

for i=0,3,1 do
	object:RegisterWatchLua('AllyUnit'..i, function(widget, trigger)
		trigger_gamePanelInfo['ally'..i..'Exists']	= trigger.exists
		trigger_gamePanelInfo:Trigger(false)
	end, false, nil, 'exists')
end

for i=0,4,1 do
	object:RegisterWatchLua('EnemyUnit'..i, function(widget, trigger)
		trigger_gamePanelInfo['enemy'..i..'Exists']	= trigger.exists
		trigger_gamePanelInfo:Trigger(false)
	end, false, nil, 'exists')
end

for i=0,9,1 do
	object:RegisterWatchLua('SpectatorUnit'..i, function(widget, trigger)
		trigger_game_specPanelInfo['player'..i..'Exists']	= trigger.exists
		trigger_game_specPanelInfo:Trigger(false)
	end, false, nil, 'exists')
end
object:RegisterWatchLua('Team', function(widget, trigger)
	trigger_gamePanelInfo.team = trigger.team
	trigger_gamePanelInfo:Trigger(false)
	trigger_game_specPanelInfo.team = trigger.team
	trigger_game_specPanelInfo:Trigger(false)
end) -- , false, nil, 'team'