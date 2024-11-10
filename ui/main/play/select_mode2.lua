local lastSelected = 2

local function swapToTutorials()
	mainUI.setBreadcrumbsSelected(1)
	lastSelected = 1
	GetWidget('playScreenModesTutorials'):SlideX('0%', 300)
	GetWidget('playScreenModesArena'):SlideX('100%', 300)
	GetWidget('playScreenModesCustom'):SlideX('100%', 300)
	if (GetCvarBool('ui_newUISounds')) then PlaySound('/ui/sounds/launcher/sfx_play_tutorials.wav') end
end
local function swapToArena()
	mainUI.setBreadcrumbsSelected(2)
	lastSelected = 2
	GetWidget('playScreenModesTutorials'):SlideX('-100%', 300)
	GetWidget('playScreenModesArena'):SlideX('0%', 300)
	GetWidget('playScreenModesCustom'):SlideX('100%', 300)
	if (GetCvarBool('ui_newUISounds')) then PlaySound('/ui/sounds/launcher/sfx_play_arenamodes.wav') end
end
local function swapToCustom()
	mainUI.setBreadcrumbsSelected(3)
	lastSelected = 3
	GetWidget('playScreenModesTutorials'):SlideX('-100%', 300)
	GetWidget('playScreenModesArena'):SlideX('-100%', 300)
	GetWidget('playScreenModesCustom'):SlideX('0%', 300)
	if (GetCvarBool('ui_newUISounds')) then PlaySound('/ui/sounds/launcher/sfx_play_customgames.wav') end
end
local function swapToAdventure()
	GetWidget('select_mode_spe_splash'):FadeIn(500)
	if (GetCvarBool('ui_newUISounds')) then PlaySound('/ui/sounds/launcher/sfx_play_adventure.wav') end
end

local breadCrumbsTable = {
	{text='pre_play_tutorials', onclick=swapToTutorials},
	{text='pre_play_arena_modes', 	onclick=swapToArena},
	{text='pre_play_custom_games', 	onclick=swapToCustom},
	{text='pre_play_adventure', 	onclick=swapToAdventure}
}

local function register(object)
	
	local select_mode 			= object:GetWidget('select_mode')	
	local queuedMatchingMode	= nil

	local selectModeInfo = LuaTrigger.GetTrigger('selectModeInfo') or LuaTrigger.CreateCustomTrigger('selectModeInfo', {
		{ name	= 'queuedMode',		type		= 'string' }
	})

	select_mode:SetCallback('onhide', function()
		GetWidget('select_mode_spe_splash'):FadeOut(250)
	end)
	
	local selectModePartyStatus = LuaTrigger.GetTrigger('selectModePartyStatus') or libGeneral.createGroupTrigger('selectModePartyStatus', {
		'PartyStatus.queue',
		'PartyStatus.inParty',
		'PartyStatus.isPartyLeader',
		'PartyStatus.numPlayersInParty',
		'selectModeInfo.queuedMode'
	})

	local selectModeMainPanelStatus = LuaTrigger.GetTrigger('selectModeMainPanelStatus') or libGeneral.createGroupTrigger('selectModeMainPanelStatus', {
		'mainPanelAnimationStatus.main',
		'mainPanelAnimationStatus.newMain',
		'selection_Status.selectionSection',
	})	
	
	local function queueMatchMode(mode)
		Party.OpenedPlayScreen()		
		
		selectModeInfo.queuedMode = mode
		selectModeInfo:Trigger(false)
		
		local mainPanelStatus = LuaTrigger.GetTrigger('mainPanelStatus') 

		mainPanelStatus.main				= 102
		mainPanelStatus:Trigger(false)		
		
	end		
	
	GetWidget('playScreenTypeSwitcher' .. '0' .. 'Parent'):SetCallback('onclick', function()
		swapToTutorials()
	end)	
	GetWidget('playScreenTypeSwitcher' .. '1' .. 'Parent'):SetCallback('onclick', function()
		swapToArena()
	end)	
	GetWidget('playScreenTypeSwitcher' .. '2' .. 'Parent'):SetCallback('onclick', function()
		swapToCustom()
	end)	
	GetWidget('playScreenTypeSwitcher' .. '3' .. 'Parent'):SetCallback('onclick', function()
		swapToAdventure()
	end)
	
	select_mode:RegisterWatchLua('mainPanelStatus', function(widget, trigger)
		if (trigger.main == mainUI.MainValues.selectMode) then
			--setMainTriggers({}) -- default triggers
			
			mainUI.initBreadcrumbs(breadCrumbsTable, nil, '42s')
			mainUI.setBreadcrumbsSelected(lastSelected)
			setMainTriggers({
				mainBackground = {blackTop=true}, -- Cover under the navigation
				mainNavigation = {breadCrumbsVisible=true}, -- navigation with breadcrumbs
			})
			
			widget:FadeIn(250)
		else
			widget:FadeOut(250)
		end
	end)	
	
	select_mode:RegisterWatchLua('selectModePartyStatus', function(widget, groupTrigger)
		local triggerParty = groupTrigger['PartyStatus']
		local queuedMatchingMode = groupTrigger['selectModeInfo'].queuedMode
		if triggerParty.inParty  and triggerParty.isPartyLeader then
			local partyTrigger = LuaTrigger.GetTrigger('PartyTrigger')
			if (mainUI) and (mainUI.featureMaintenance) and (not mainUI.featureMaintenance['khanquest']) and (triggerParty.numPlayersInParty == 5) and (triggerParty.queue == 'pvp')  then
				queuedMatchingMode = ''				
				partyTrigger.gameMode = 'khanquest'
				partyTrigger.unrankedIsPvE = false
				partyTrigger:Trigger(false)
				println('^y 5 players in pvp - sending to khanquest')
			elseif (mainUI) and (mainUI.featureMaintenance) and (not mainUI.featureMaintenance['khanquest']) and (triggerParty.numPlayersInParty < 5) and (triggerParty.queue == 'khanquest')  then
				queuedMatchingMode = ''
				partyTrigger.gameMode = 'unranked'
				partyTrigger.unrankedIsPvE = false
				partyTrigger:Trigger(false)
				println('^y <5 players in khanquest - sending to pvp')
			elseif (queuedMatchingMode) and (not Empty(queuedMatchingMode)) then
				if queuedMatchingMode == 'khanquest' then
					if (mainUI) and (mainUI.featureMaintenance) and (not mainUI.featureMaintenance['khanquest']) and (triggerParty.numPlayersInParty == 5) then
						partyTrigger.gameMode = queuedMatchingMode
						partyTrigger.unrankedIsPvE = false
					else
						partyTrigger.gameMode = 'unranked'
						partyTrigger.unrankedIsPvE = false
					end
				elseif queuedMatchingMode == 'pvp' or queuedMatchingMode == 'pve' then
					partyTrigger.gameMode = 'unranked'
					if queuedMatchingMode == 'pvp' then
						partyTrigger.unrankedIsPvE = false
					else
						partyTrigger.unrankedIsPvE = true
					end
				else
					partyTrigger.gameMode = queuedMatchingMode
				end
				queuedMatchingMode = ''
				partyTrigger:Trigger(false)
			end
		elseif (triggerParty.inParty) and (not triggerParty.isPartyLeader) then
			local selectionStatus = LuaTrigger.GetTrigger('selection_Status') 
			if (selectionStatus.selectionSection == mainUI.Selection.selectionSections.GAME_TYPE_PICK) then
				selectionStatus.selectionSection = mainUI.Selection.selectionSections.HERO_PICK 
				selectionStatus:Trigger(false)
			end
		end
	end)	
	
	GetWidget('playScreenOption' .. 1 .. 'Parent'):SetCallback('onclick', function(widget)
		
		if (not GetCvarBool('ui_promptToPVE')) and (mainUI) and (mainUI.progression) and (mainUI.progression.stats) and (mainUI.progression.stats.account) and (mainUI.progression.stats.account.wins) and (mainUI.progression.stats.account.wins < 2) and (mainUI.progression.stats.account.pveWins) and (mainUI.progression.stats.account.pveWins < 2) then
			SetSave('ui_promptToPVE', 'true', 'bool')
			GenericDialog(
				Translate('newplay_pve_prompt'), Translate('newplay_pve_prompt_desc'), '', Translate('newplay_pve_prompt_pvp'), Translate('general_cancel'), 
				function()
					-- soundEvent - Confirm
					if (GetCvarBool('ui_newUISounds')) then PlaySound('/ui/sounds/launcher/sfx_mode_standard.wav') end
					queueMatchMode('pvp')
				end,
				function()
					-- soundEvent - Cancel
					-- if (GetCvarBool('ui_newUISounds')) then PlaySound('/ui/sounds/launcher/sfx_mode_bots.wav') end
					-- queueMatchMode('pve')
				end,
				nil,
				nil,
				true
			)		
		else
			if (GetCvarBool('ui_newUISounds')) then PlaySound('/ui/sounds/launcher/sfx_mode_standard.wav') end
			queueMatchMode('pvp')		
		end
		
	end)

	GetWidget('playScreenOption' .. 1 .. 'Parent'):RegisterWatchLua('featureMaintenanceTrigger', function(widget, trigger)
		if (mainUI) and (mainUI.featureMaintenance) and (mainUI.featureMaintenance['pvp']) then	
			widget:SetVisible(0)
		else
			widget:SetVisible(1)
		end
	end)	
	
	GetWidget('playScreenOption' .. 1 .. '_moreinfo'):SetCallback('onclick', function(widget)
		mainUI.ShowSplashScreen('splash_screen_unranked')
	end)	
	
	GetWidget('playScreenOption' .. 2 .. 'Parent'):SetCallback('onclick', function(widget)
		if (GetCvarBool('ui_newUISounds')) then PlaySound('/ui/sounds/launcher/sfx_mode_bots.wav') end
		queueMatchMode('pve')
	end)
	
	GetWidget('playScreenOption' .. 2 .. 'Parent'):RegisterWatchLua('featureMaintenanceTrigger', function(widget, trigger)
		if (mainUI) and (mainUI.featureMaintenance) and (mainUI.featureMaintenance['pve']) then	
			widget:SetVisible(0)
		else
			widget:SetVisible(1)
		end
	end)	
	
	GetWidget('playScreenOption' .. 3 .. 'Parent'):SetCallback('onclick', function(widget)
		if (not mainUI.savedRemotely.splashScreensViewed) or (not mainUI.savedRemotely.splashScreensViewed['splash_screen_ranked']) then
			mainUI.savedRemotely = mainUI.savedRemotely or {}
			mainUI.savedRemotely.splashScreensViewed = mainUI.savedRemotely.splashScreensViewed or {}
			mainUI.savedRemotely.splashScreensViewed['splash_screen_ranked'] = true
			SaveState()
			mainUI.ShowSplashScreen('splash_screen_ranked')
		else
			queueMatchMode('ranked')
		end
	end)
	
	GetWidget('playScreenOption' .. 3 .. '_moreinfo'):SetCallback('onclick', function(widget)
		mainUI.ShowSplashScreen('splash_screen_ranked')
	end)	
	
	GetWidget('playScreenOption' .. 3 .. 'Parent'):RegisterWatchLua('featureMaintenanceTrigger', function(widget, trigger)
		if (mainUI) and (mainUI.featureMaintenance) and (mainUI.featureMaintenance['ranked']) then	
			widget:SetVisible(0)
		else
			widget:SetVisible(1)
		end
	end)	

	GetWidget('playScreenOption' .. 4 .. 'Parent'):SetCallback('onclick', function(widget)
		if (GetCvarBool('ui_newUISounds')) then PlaySound('/ui/sounds/launcher/sfx_mode_scrim.wav') end
		if ((mainUI.featureMaintenance) and (not mainUI.featureMaintenance['party'])) then
			
			PlaySound('/ui/sounds/sfx_ui_creategame_2.wav')
			
			local partyStatusTrigger 		= LuaTrigger.GetTrigger('PartyStatus')
			local partyCustomTrigger 		= LuaTrigger.GetTrigger('PartyTrigger')				
			
			if (not partyStatusTrigger.inParty) and (LuaTrigger.GetTrigger('GamePhase').gamePhase ~= 1) then
				ChatClient.CreateParty()
				InitSelectionTriggers(object, false)
			end
			
			selectModeInfo.queuedMode = 'scrim'
			selectModeInfo:Trigger(false)

			local triggerPanelStatus = LuaTrigger.GetTrigger('mainPanelStatus')
			triggerPanelStatus.main = 35 
			triggerPanelStatus:Trigger(false)	
			
			if (Friends) and (Friends.ToggleFriends) then
				Friends.ToggleFriends(true)			
			elseif (Friends) and (Friends.ToggleFriendsList) then
				Friends.ToggleFriendsList(true)
			end
			
		end	
	end)	
	
	GetWidget('playScreenOption' .. 4 .. 'Parent'):RegisterWatchLua('featureMaintenanceTrigger', function(widget, trigger)
		if (mainUI) and (mainUI.featureMaintenance) and (mainUI.featureMaintenance['scrim']) then	
			widget:SetVisible(0)
		else
			widget:SetVisible(1)
		end
	end)	
	
	GetWidget('playScreenOption' .. 5 .. 'Parent'):SetCallback('onclick', function(widget)
		queueMatchMode('khanquest')
	end)	
	
	GetWidget('playScreenOption' .. 5 .. 'Parent'):RegisterWatchLua('featureMaintenanceTrigger', function(widget, trigger)
		if (mainUI) and (mainUI.featureMaintenance) and (mainUI.featureMaintenance['khanquest']) then	
			widget:SetVisible(0)
		else
			widget:SetVisible(1)
		end
	end)
	
	GetWidget('playScreenOption' .. 5 .. '_moreinfo'):SetCallback('onclick', function(widget)
		mainUI.ShowSplashScreen('splash_screen_khanquest')
	end)	
	
	GetWidget('playScreenOption' .. 7 .. 'Parent'):SetCallback('onclick', function(widget)
		if (GetCvarBool('ui_newUISounds')) then PlaySound('/ui/sounds/launcher/sfx_tutorial_1.wav') end
		GenericDialogAutoSize(
			'main_simple_play_tutorial', 'main_simple_play_tutorial_desc', '', 'general_play', 'general_cancel', 
				function()
					PlaySound('/ui/sounds/sfx_ui_creategame_2.wav')
					libThread.threadFunc(function()
						RMM_DONT_AUTO_BUILD_TEMP_HAX = true
						LeaveGameLobby()
						Party.LeaveParty()		
						wait(styles_mainSwapAnimationDuration)
						ManagedSetLoadingInterface('loading_npe_1')
						StartGame('tutorial', Translate('game_name_default_tutorial'), 'map:tutorial nolobby:true')
					end)												
				end,
				function()
					PlaySound('/ui/sounds/sfx_ui_back.wav')
				end
		)	
	end)
	
	GetWidget('playScreenOption' .. 7 .. 'Parent'):RegisterWatchLua('featureMaintenanceTrigger', function(widget, trigger)
		if (mainUI) and (mainUI.featureMaintenance) and (mainUI.featureMaintenance['tut1']) then	
			widget:SetVisible(0)
		else
			widget:SetVisible(1)
		end
	end)		
	
	GetWidget('playScreenOption' .. 8 .. 'Parent'):SetCallback('onclick', function(widget)
		if (GetCvarBool('ui_newUISounds')) then PlaySound('/ui/sounds/launcher/sfx_tutorial_2.wav') end
		GenericDialogAutoSize(
			'main_simple_play_tutorial2', 'main_simple_play_tutorial2_desc', '', 'general_play', 'general_cancel', 
				function()
					PlaySound('/ui/sounds/sfx_ui_creategame_2.wav')
					libThread.threadFunc(function()
						RMM_DONT_AUTO_BUILD_TEMP_HAX = true
						LeaveGameLobby()
						Party.LeaveParty()		
						wait(styles_mainSwapAnimationDuration)
						ManagedSetLoadingInterface('loading_npe_2')
						StartGame('tutorial', Translate('game_name_default_tutorial'), 'map:tutorial_2 nolobby:true')
					end)												
				end,
				function()
					PlaySound('/ui/sounds/sfx_ui_back.wav')
				end
		)
	end)
	
	GetWidget('playScreenOption' .. 8 .. 'Parent'):RegisterWatchLua('featureMaintenanceTrigger', function(widget, trigger)
		if (mainUI) and (mainUI.featureMaintenance) and (mainUI.featureMaintenance['tut2']) then	
			widget:SetVisible(0)
		else
			widget:SetVisible(1)
		end
	end)		
	
	GetWidget('playScreenOption' .. 9 .. 'Parent'):SetCallback('onclick', function(widget)
		if (GetCvarBool('ui_newUISounds')) then PlaySound('/ui/sounds/launcher/sfx_tutorial_3.wav') end
		GenericDialogAutoSize(
			'main_simple_play_tutorial3', 'main_simple_play_tutorial3_desc', '', 'general_play', 'general_cancel', 
				function()
					PlaySound('/ui/sounds/sfx_ui_creategame_2.wav')
					libThread.threadFunc(function()
						RMM_DONT_AUTO_BUILD_TEMP_HAX = true
						queuedTut3SkipLobby = true
						LeaveGameLobby()
						Party.LeaveParty()		
						wait(styles_mainSwapAnimationDuration)
						SetSave('ui_hideDevMenu', 'true', 'bool')
						StartGame('practice', Translate('game_name_default_practice'), 'map:tutorial_3')
					end)
				end,
				function()
					PlaySound('/ui/sounds/sfx_ui_back.wav')
				end
		)	
	end)	
	
	GetWidget('playScreenOption' .. 9 .. 'Parent'):RegisterWatchLua('featureMaintenanceTrigger', function(widget, trigger)
		if (mainUI) and (mainUI.featureMaintenance) and (mainUI.featureMaintenance['tut3']) then	
			widget:SetVisible(0)
		else
			widget:SetVisible(1)
		end
	end)	
	
	GetWidget('playScreenOption' .. 10 .. 'Parent'):SetCallback('onclick', function(widget)
		Party.LeaveParty()
		PlaySound('/ui/sounds/launcher/sfx_play_openbrowser.wav')
		local triggerPanelStatus = LuaTrigger.GetTrigger('mainPanelStatus')
		triggerPanelStatus.main = 24
		triggerPanelStatus:Trigger(false)	
	end)	

	GetWidget('playScreenOption' .. 10 .. 'Parent'):RegisterWatchLua('featureMaintenanceTrigger', function(widget, trigger)
		if (mainUI) and (mainUI.featureMaintenance) and (mainUI.featureMaintenance['lobby']) then	
			widget:SetVisible(0)
		else
			widget:SetVisible(1)
		end
	end)	
	
	GetWidget('playScreenOption' .. 11 .. 'Parent'):SetCallback('onclick', function(widget)
		PlaySound('/ui/sounds/launcher/sfx_play_practicematch.wav')
		local triggerPanelStatus = LuaTrigger.GetTrigger('mainPanelStatus')
		triggerPanelStatus.main = mainUI.MainValues.blank
		triggerPanelStatus:Trigger(false)
		LeaveGameLobby()
		Party.LeaveParty()
		SetSave('ui_hideDevMenu', 'false', 'bool')
		StartGame('practice', Translate('game_name_default_practice'), 'map:strife nolobby:true fillbots:false finalheroesonly:false')
	end)	
	
	GetWidget('playScreenOption' .. 11 .. 'Parent'):RegisterWatchLua('featureMaintenanceTrigger', function(widget, trigger)
		if (mainUI) and (mainUI.featureMaintenance) and (mainUI.featureMaintenance['practice']) then	
			widget:SetVisible(0)
		else
			widget:SetVisible(1)
		end
	end)	
	
	
end	
	
register(object)


