
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
		local selectionStatus = LuaTrigger.GetTrigger('selection_Status') 

		mainPanelStatus.main				= 102
		mainPanelStatus:Trigger(false)		
		
	end	
	
	select_mode:RegisterWatchLua('mainPanelStatus', function(widget, trigger)
		if (trigger.main == mainUI.MainValues.selectMode) then
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
	
	local function selectModeBigArtButtonRegister(object, index, buttonTable)
		
		local FADE_TIME = 250
		
		local Parent							= object:GetWidget('playScreenOption'..index..'Parent')
		local BackGlow							= object:GetWidget('playScreenOption'..index..'BackGlow')
		local Highlight							= object:GetWidget('playScreenOption'..index..'Highlight')
		local ButtonContainer					= object:GetWidget('playScreenOption'..index..'ButtonContainer')
		local Buttons							= object:GetWidget('playScreenOption'..index..'Buttons')
		local Clipper							= object:GetWidget('playScreenOption'..index..'Clipper')
		local Art								= object:GetWidget('playScreenOption'..index..'Art')
		local TitleContainer					= object:GetWidget('playScreenOption'..index..'TitleContainer')
		

		local function onMouseOver(widget)
			Art:FadeOut(FADE_TIME)
			BackGlow:FadeIn(FADE_TIME)
			ButtonContainer:FadeIn(FADE_TIME * 1.2)
			Clipper:ScaleHeight('0%', FADE_TIME)
			TitleContainer:SlideY('12s', FADE_TIME)
			libThread.threadFunc(function()
				wait(FADE_TIME * 1.4)
			end)
		end

		local function onMouseOut(widget, isLoop, force)		
			libThread.threadFunc(function()
				if (not libGeneral.mouseInWidgetArea(Parent)) or (force) then		
					Art:FadeIn(FADE_TIME)
					BackGlow:FadeOut(FADE_TIME)
					ButtonContainer:FadeOut(FADE_TIME * 0.8)
					Clipper:ScaleHeight('104%', FADE_TIME)
					TitleContainer:SlideY('402s', FADE_TIME)
					wait(FADE_TIME * 1.4)			
				elseif (not isLoop) then
					wait(200)
					onMouseOut(widget, true)		
				end
			end)
		end

		local mouseThread = nil
		local function onMouseOverParent(widget)

			if (mouseThread) then
				Parent:SetPassiveChildren(0)
				Parent:SetNoClick(0)
				mouseThread:kill()
				mouseThread = nil
			end			
			
			Parent:SetPassiveChildren(1)
			Art:FadeOut(FADE_TIME)
			BackGlow:FadeIn(FADE_TIME)
			ButtonContainer:FadeIn(FADE_TIME * 1.2)
			Clipper:ScaleHeight('0%', FADE_TIME)
			TitleContainer:SlideY('12s', FADE_TIME)
			if (not libGeneral.mouseInWidgetArea(Parent)) then
				mouseThread = libThread.threadFunc(function()
					wait(FADE_TIME * 1.4)
					Parent:SetPassiveChildren(0)
					mouseThread = nil
				end)
			else
				mouseThread = libThread.threadFunc(function()
					wait(FADE_TIME * 1.0)
					Parent:SetPassiveChildren(0)
					mouseThread = nil
				end)			
			end
		end
		
		local function onMouseOutParent(widget, isLoop)		
			if (mouseThread) then
				Parent:SetNoClick(0)
				Parent:SetPassiveChildren(0)
				mouseThread:kill()
				mouseThread = nil
			end			

			mouseThread = libThread.threadFunc(function()
				if (not libGeneral.mouseInWidgetArea(Parent)) then		
					Parent:SetNoClick(1)	
					Art:FadeIn(FADE_TIME)
					BackGlow:FadeOut(FADE_TIME)
					ButtonContainer:FadeOut(FADE_TIME * 0.8)
					Clipper:ScaleHeight('104%', FADE_TIME)
					TitleContainer:SlideY('402s', FADE_TIME)
					wait(FADE_TIME * 1.4)
					Parent:SetNoClick(0)
				elseif (not isLoop) then
					wait(200)
					Parent:SetNoClick(0)
					onMouseOutParent(widget, true)
				else
					Parent:SetNoClick(0)
				end		
				mouseThread = nil				
			end)
		end		
		
		Parent:SetCallback('onmouseover', function(Parent) onMouseOverParent(Parent, true) end)
		Parent:SetCallback('onmouseout', function(Parent) onMouseOutParent(Parent, true) end)
		
		for i,v in ipairs(buttonTable) do
			local subButton		= object:GetWidget('playScreenOptionBtn'..index..'_'..i)
			local parent		= object:GetWidget('playScreenOptionBtn'..index..'_'..i..'_parent')
			local lock			= object:GetWidget('playScreenOptionBtn'..index..'_'..i..'_lock')
			local comingsoon	= object:GetWidget('playScreenOptionBtn'..index..'_'..i..'_comingsoon')
			local moreinfo		= object:GetWidget('playScreenOptionBtn'..index..'_'..i..'_moreinfo')

			subButton:SetCallback('onmouseover', function(subButton) onMouseOver(subButton) end)
			subButton:SetCallback('onmouseout', function(subButton) onMouseOut(subButton) end)			
			if v[1] ~= nil then
				subButton:SetCallback('onclick', 
					function()
						onMouseOut(subButton, false, true)
						v[1]()
					end
				)		
			end

			if v[2] ~= nil then
				subButton:RegisterWatchLua('featureMaintenanceTrigger', function(widget, trigger)
					if (mainUI) and (mainUI.featureMaintenance) and (mainUI.featureMaintenance[v[2]]) and (mainUI.featureMaintenance[v[2]] == 'disabled') then
						parent:SetVisible(1)
						comingsoon:SetVisible(1)
						subButton:SetCallback('onmouseoverdisabled', function(subButton) 
							onMouseOver(subButton) 
							simpleTipGrowYUpdate(true, nil, Translate('party_finder_maint_feature_locked'), Translate('party_finder_maint_feature_locked_desc'), 350, -250)
						end)
						subButton:SetCallback('onmouseoutdisabled', function(subButton) 
							simpleTipGrowYUpdate(false)
							onMouseOut(subButton) 
						end)					
					elseif (mainUI) and (mainUI.featureMaintenance) and (mainUI.featureMaintenance[v[2]]) and (mainUI.featureMaintenance[v[2]] == 'comingsoon') then
						parent:SetVisible(1)
						comingsoon:SetVisible(1)
						subButton:SetCallback('onmouseoverdisabled', function(subButton) 
							onMouseOver(subButton) 
							simpleTipGrowYUpdate(true, nil, Translate('party_finder_comingsoon_feature_locked'), Translate('party_finder_comingsoon_feature_locked_desc'), 350, -250)
						end)
						subButton:SetCallback('onmouseoutdisabled', function(subButton) 
							simpleTipGrowYUpdate(false)
							onMouseOut(subButton) 
						end)						
					elseif (mainUI) and (mainUI.featureMaintenance) and (mainUI.featureMaintenance[v[2]]) then
						parent:SetVisible(0)	
						comingsoon:SetVisible(0)
						subButton:SetCallback('onmouseoverdisabled', function(subButton) 
							onMouseOver(subButton) 
							simpleTipGrowYUpdate(true, nil, Translate('party_finder_disabled_feature_locked'), Translate('party_finder_disabled_feature_locked_desc'), 350, -250)
						end)
						subButton:SetCallback('onmouseoutdisabled', function(subButton) 
							simpleTipGrowYUpdate(false)
							onMouseOut(subButton) 
						end)						
					else
						parent:SetVisible(1)
						comingsoon:SetVisible(0)
						subButton:SetCallback('onmouseoverdisabled', function(subButton) 
							onMouseOver(subButton) 
							simpleTipGrowYUpdate(true, nil, Translate('party_finder_disabled_feature_locked'), Translate('party_finder_disabled_feature_locked_desc'), 350, -250)
						end)
						subButton:SetCallback('onmouseoutdisabled', function(subButton) 
							simpleTipGrowYUpdate(false)
							onMouseOut(subButton) 
						end)						
					end
				end)	
			else
				parent:SetVisible(1)
				comingsoon:SetVisible(0)
				subButton:SetCallback('onmouseoverdisabled', function(subButton) 
					onMouseOver(subButton) 
					simpleTipGrowYUpdate(true, nil, Translate('party_finder_disabled_feature_locked'), Translate('party_finder_disabled_feature_locked_desc'), 350, -250)
				end)
				subButton:SetCallback('onmouseoutdisabled', function(subButton) 
					simpleTipGrowYUpdate(false)
					onMouseOut(subButton) 
				end)				
			end
			
			if v[3] ~= nil then
				subButton:SetEnabled(v[3]() and ((v[2] == nil) or (v[2] and (not ((mainUI.featureMaintenance) and (mainUI.featureMaintenance[v[2]]))))))
				lock:SetVisible(not v[3]())
				subButton:RegisterWatchLua('AccountProgression', function(widget, trigger)
					subButton:SetEnabled(v[3]() and ((v[2] == nil) or (v[2] and (not ((mainUI.featureMaintenance) and (mainUI.featureMaintenance[v[2]]))))))
					lock:SetVisible(not v[3]())
				end)
				subButton:SetCallback('onmouseoverdisabled', function(subButton) 
					onMouseOver(subButton) 
					simpleTipGrowYUpdate(true, nil, Translate('party_finder_disabled_feature_locked'), Translate('party_finder_disabled_feature_locked_desc'), 350, -250)
				end)
				subButton:SetCallback('onmouseoutdisabled', function(subButton) 
					simpleTipGrowYUpdate(false)
					onMouseOut(subButton) 
				end)				
			else
				lock:SetVisible(0)
				subButton:SetEnabled(((v[2] == nil) or (v[2] and (not ((mainUI.featureMaintenance) and (mainUI.featureMaintenance[v[2]]))))))
				subButton:RegisterWatchLua('AccountProgression', function(widget, trigger)
					subButton:SetEnabled(((v[2] == nil) or (v[2] and (not ((mainUI.featureMaintenance) and (mainUI.featureMaintenance[v[2]]))))))
				end)				
			end				
			
			if v[4] ~= nil then
				moreinfo:SetVisible(1)
				moreinfo:SetCallback('onclick', 
					function()
						onMouseOut(moreinfo, false, true)
						v[4]()
					end
				)		
			end			
			moreinfo:SetCallback('onmouseover', function(subButton) onMouseOver(moreinfo) end)
			moreinfo:SetCallback('onmouseout', function(subButton) onMouseOut(moreinfo) end)				

		end
		
	end

	local singlePlayerButtons = {
		{function() 
			object:GetWidget('select_mode_spe_splash'):FadeIn(500)	
		end, 
		'play_spe_1'},	
		{function() 
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
		end, 
		'play_tut_1'},
		{function()
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
		end, 
		'play_tut_2'},
		{function()
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
							StartGame('practice', Translate('game_name_default_practice'), 'map:tutorial_3')
						end)
					end,
					function()
						PlaySound('/ui/sounds/sfx_ui_back.wav')
					end
			)		
		end, 
		'play_tut_3'},		
	}

	local multiPlayerButtons = {
		{function() 
			-- if (not mainUI.savedRemotely.splashScreensViewed) or (not mainUI.savedRemotely.splashScreensViewed['splash_screen_unranked']) then
				-- mainUI.savedRemotely = mainUI.savedRemotely or {}
				-- mainUI.savedRemotely.splashScreensViewed = mainUI.savedRemotely.splashScreensViewed or {}
				-- mainUI.savedRemotely.splashScreensViewed['splash_screen_unranked'] = true
				-- SaveState()
				-- mainUI.ShowSplashScreen('splash_screen_unranked')
			-- else
				queueMatchMode('pvp')
			-- end			
		end,
		'pvp',
		nil,
		function() 
			mainUI.ShowSplashScreen('splash_screen_unranked')
		end,		
		},
		{function() 
			if (not mainUI.savedRemotely.splashScreensViewed) or (not mainUI.savedRemotely.splashScreensViewed['splash_screen_ranked']) then
				mainUI.savedRemotely = mainUI.savedRemotely or {}
				mainUI.savedRemotely.splashScreensViewed = mainUI.savedRemotely.splashScreensViewed or {}
				mainUI.savedRemotely.splashScreensViewed['splash_screen_ranked'] = true
				SaveState()
				mainUI.ShowSplashScreen('splash_screen_ranked')
			else
				queueMatchMode('ranked')
			end
		end,
		'ranked',
		libGeneral.canIAccessRankedPlay,
		function() 
			mainUI.ShowSplashScreen('splash_screen_ranked')
		end,		
		},
		{function() 
			queueMatchMode('pve')
		end,
		'pve'
		},
		{function()
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
				end
				
			end			
		end, 
		'scrim',
		libGeneral.canIAccessChallenges,
		},			
	}	
	
	local customButtons = {
		{function() 
			Party.LeaveParty()	
			local triggerPanelStatus = LuaTrigger.GetTrigger('mainPanelStatus')
			triggerPanelStatus.main = 24
			triggerPanelStatus:Trigger(false)		
		end,
		'lobby'
		},
		{function()
			PlaySound('/ui/sounds/sfx_ui_creategame_2.wav')
			Strife_Options.LeaveOptionsScreen()
			libThread.threadFunc(function()
				LeaveGameLobby()
				Party.LeaveParty()		
				wait(styles_mainSwapAnimationDuration)
				StartGame('practice', Translate('game_name_default_practice'), 'map:strife nolobby:true fillbots:false finalheroesonly:false')
			end)	
		end, 
		'play_tut_4'},		
		{function() 
			queueMatchMode('khanquest')
		end,
		'khanquest',
		libGeneral.canIAccessKhanquest,
		function() 
			mainUI.ShowSplashScreen('splash_screen_khanquest')
		end		
		},		
	}		
	
	selectModeBigArtButtonRegister(object, 1, singlePlayerButtons)
	selectModeBigArtButtonRegister(object, 2, multiPlayerButtons)
	selectModeBigArtButtonRegister(object, 3, customButtons)

	selectModeInfo.queuedMode = ''
	selectModeInfo:Trigger(true)
	
end	
	
register(object)


