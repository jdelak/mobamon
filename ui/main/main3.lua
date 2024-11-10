-- Newer Main Lua (15/10/2014)
local _G = getfenv(0)
local ipairs, pairs, select, string, table, next, type, unpack, tinsert, tconcat, tremove, format, tostring, tonumber, tsort, ceil, floor, sub, find, gfind = _G.ipairs, _G.pairs, _G.select, _G.string, _G.table, _G.next, _G.type, _G.unpack, _G.table.insert, _G.table.concat, _G.table.remove, _G.string.format, _G.tostring, _G.tonumber, _G.table.sort, _G.math.ceil, _G.math.floor, _G.string.sub, _G.string.find, _G.string.gfind
local interface, interfaceName = object, object:GetName()

mainUI = mainUI or {}
mainUI.savedLocally 	= mainUI.savedLocally 		or {}
mainUI.savedRemotely 	= mainUI.savedRemotely 		or {}
mainUI.savedAnonymously	= mainUI.savedAnonymously 	or {}
mainUI.resourceContextTable	= mainUI.resourceContextTable or {}
ClientInfo = ClientInfo or {}
ClientInfo.duplicateUsernameTable = {}
CURRENT_TOS_VERSION = 1.0

local clientInfoDrag = LuaTrigger.GetTrigger('clientInfoDrag')
local mainPanelStatusDragInfo = LuaTrigger.GetTrigger('mainPanelStatusDragInfo')

mainUI.pauseDuration2 = 250

local currentlyShownScreen = -1
function mainSectionAnimState(targMain, main, newMain)
	if targMain and main and newMain and type(targMain) == 'number' and type(main) == 'number' and type(newMain) == 'number' then
		if (newMain ~= main and newMain ~= -1) then
			currentlyShownScreen = -1
		end
		if (newMain ~= targMain) and (newMain ~= -1) and (main == targMain) then			-- do outro
			return 1
		elseif (main ~= targMain) and (newMain ~= targMain) then	-- fully hidden
			return 2
		elseif (newMain == targMain) and (newMain ~= -1 and currentlyShownScreen ~= targMain) then		-- do intro
			return 3
		elseif (main == targMain) then								-- fully displayed
			currentlyShownScreen = targMain
			return 4
		end
		return 0
	end
	return -1
end

local finishMatchThread
function FinishMatch()
	println('^r FinishMatch')
	SaveState()
	SetSave('cg_cloudSynced', 'false', 'bool')
	if (finishMatchThread) then
		finishMatchThread:kill()
		finishMatchThread = nil
	end
	finishMatchThread = libThread.threadFunc(function()	
		wait(1500)		
		Client.FinishGame()
		finishMatchThread = nil
	end)
end

local function InitialisePlayerCard(object)
	local playerCardUsername		= object:GetWidget('mainPlayerCardUsername')
	
	local function UpdatePlayerName()
		local myInfo = GetMyChatClientInfo()
		local text = ''
		if (myInfo) and (myInfo.clanTag) and (not Empty(myInfo.clanTag)) then
			text = (('[' .. (myInfo.clanTag or '') ..']') .. (myInfo.name or ''))
		elseif (myInfo) then
			text = (myInfo.name or '')
		end
		playerCardUsername:SetText(text)
		if (string.len(text) > 18) then
			playerCardUsername:SetFont('maindyn_15')
		elseif (string.len(text) > 16) then
			playerCardUsername:SetFont('maindyn_18')
		elseif (string.len(text) > 14) then
			playerCardUsername:SetFont('maindyn_22')
		elseif (string.len(text) > 12) then
			playerCardUsername:SetFont('maindyn_24')
		else
			playerCardUsername:SetFont('maindyn_26')
		end
	end
	
	playerCardUsername:RegisterWatchLua('AccountInfo', function(widget, trigger) UpdatePlayerName() end, false, nil, 'nickname')
end

local function InitializeLoading(object, triggerPanelStatus)
	interface:RegisterWatchLua('EntityDefinitionsProgress', function(widget, trigger) 
		triggerPanelStatus.entityDefinitionsState = 1
		triggerPanelStatus:Trigger(false)
	end)	
	
	interface:RegisterWatchLua('EntityDefinitionsLoaded', function(widget, trigger)
		triggerPanelStatus.entityDefinitionsState = 2
		triggerPanelStatus:Trigger(false)
	end)	
	
	interface:GetWidget('main_bg_loading_bar'):RegisterWatchLua('EntityDefinitionsProgress', function(widget, trigger) widget:SetWidth(ToPercent(trigger.load / trigger.loadMax)) end)		
end

local function InitializeMusic(object, triggerPanelStatus)
	libGeneral.createGroupTrigger('gameMusicControlInfo', {'mainPanelAnimationStatus.main', 'GamePhase.gamePhase', 'newPlayerExperience.tutorialProgress', 'newPlayerExperience.tutorialComplete', 'mainPanelStatus.launcherMusicEnabled', 'System.hasFocus', 'PartyStatus.inQueue'} )

	local currentMusic	= ''
	local musicFadeTime	= 3000
	local lastMusictime = 0
	local launcherMusic
	local musicChannel	= nil	-- not required at thie time
	local musicLastAudible = false
	
	local function playMusicUnique(musicFile, loopMusic, fadeOverride)
		local thisFadeTime = fadeOverride or musicFadeTime
		if loopMusic == nil then loopMusic = true end
		if musicFile and string.len(musicFile) > 0 then
			local musicTime = 0
		
			if musicFile == currentMusic then
				musicTime = GetTime() - lastMusicTime
			else
				musicLastAudible = false
				if launcherMusic then
					FadeOutHandle(launcherMusic, thisFadeTime)
					launcherMusic = nil
				end
				
				lastMusicTime = GetTime()
			end
			-- object:UICmd("PlayMusic('"..musicFile.."', "..tostring(loopMusic)..")")
			if not musicLastAudible then
				-- print('play with thisfadetime of '..thisFadeTime..'\n')
				launcherMusic = PlayStreamMusic(musicFile, 1, loopMusic, thisFadeTime, musicChannel, musicTime)
				musicLastAudible = true
			end
			
			currentMusic = musicFile
		end
	end
	
	local lastInQueue = false
	
	object:GetWidget('mainMusicController'):RegisterWatchLua('gameMusicControlInfo', function(widget, groupTrigger)
		local gamePhase				= groupTrigger['GamePhase'].gamePhase
		local main					= groupTrigger['mainPanelAnimationStatus'].main
		local launcherMusicEnabled	= groupTrigger['mainPanelStatus'].launcherMusicEnabled
		local triggerNPE			= groupTrigger['newPlayerExperience']
		local hasFocus				= groupTrigger['System'].hasFocus
		local inQueue				= groupTrigger['PartyStatus'].inQueue
		local tutorialProgress		= triggerNPE.tutorialProgress
		local tutorialComplete		= triggerNPE.tutorialComplete
		
		if launcherMusicEnabled and hasFocus then
			if gamePhase < 4 then
				if inQueue then
					playMusicUnique('/music/music_heroselect.wav', nil, 250)
					if not lastInQueue then
						-- sound_partyEnterQueue
						PlaySound('/ui/sounds/parties/sfx_queue_enter.wav')
					end
					lastInQueue = true
					return
				else
					lastInQueue = false
					if tutorialComplete or tutorialProgress >= NPE_PROGRESS_ACCOUNTCREATED then
						if (main == 10) then
							playMusicUnique('/music/music_postgame.wav') -- RMM Change me to the postgame music
						else
							playMusicUnique('/music/music_mainmenu.wav')
						end
						return
					end
				end
			end
		end

		if launcherMusic then
			FadeOutHandle(launcherMusic, musicFadeTime)
			launcherMusic = nil
		end
		
		musicLastAudible = false
	end)
end

local function mainRegister(object)
	local triggerPanelStatus		= LuaTrigger.GetTrigger('mainPanelStatus')

	InitializeLoading(object, triggerPanelStatus)
	InitialisePlayerCard(object, triggerPanelStatus)
	
	function mainUI.ShowSplashScreen(whichSplashScreen)
		local generic_splash_screen_target = GetWidget('generic_splash_screen_target')
		if (whichSplashScreen) and (generic_splash_screen_target) then

			mainUI.savedRemotely = mainUI.savedRemotely or {}
			mainUI.savedRemotely.splashScreensViewed = mainUI.savedRemotely.splashScreensViewed or {}
			mainUI.savedRemotely.splashScreensViewed[whichSplashScreen] = true
			SaveState()
		
			local temp = generic_splash_screen_target:InstantiateAndReturn(whichSplashScreen)
			generic_splash_screen_target:FadeIn(250)
			FindChildrenClickCallbacks(temp[1])
		else
			if (generic_splash_screen_target) then
				generic_splash_screen_target:SetVisible(0)
			end
			groupfcall('splash_screens', function(_, groupWidget) groupWidget:Destroy() end)
		end
	end

	local mainPanelRefreshThread
	local function mainPanelRefreshThreadKill()
		if (mainPanelRefreshThread) then
			mainPanelRefreshThread:kill()
			mainPanelRefreshThread = nil
		end
	end	
	
	function mainUI.RefreshProducts(postRefreshCallback)
		-- println('^y RefreshProducts ' .. tostring(postRefreshCallback))
		postRefreshCallback = postRefreshCallback or function() end
		ChatClient.RefreshProducts('pets,heroes,crafts', postRefreshCallback) -- , 'titles', 'colors', 'icons'
	end
	
	local mainPanelOverrideThread
	local function mainPanelOverrideThreadKill()
		if (mainPanelOverrideThread) then
			mainPanelOverrideThread:kill()
			mainPanelOverrideThread = nil
		end
	end
	
	function mainUI.ReturnHome()
		mainPanelOverrideThreadKill()
		mainPanelOverrideThread = libThread.threadFunc(function()	
			wait(styles_mainSwapAnimationDuration)
			Party.LeaveParty(nil, 1)
			local triggerPanelStatus = LuaTrigger.GetTrigger('mainPanelStatus') 
			triggerPanelStatus.main	= 101
			triggerPanelStatus:Trigger(false)
			PlaySound('/ui/sounds/sfx_transition_3.wav')	
			mainPanelOverrideThread = nil				
		end)	
	end
	
	-- Modes: 0: normal, display all vars
	-- 1: print stack trace
	-- 2: 0 and 1
	local function debugTrigger(triggerName, mode, ...)
		local mode = mode or 0
		UnwatchLuaTriggerByKey(triggerName, 'debug'..triggerName)
		WatchLuaTrigger(triggerName, function(trigger)
			println('^g==================================')
			if (mode == 0 or mode == 2) then Cmd('luatriggershowparams '..triggerName) end
			if (mode == 1 or mode == 2) then println(debug.traceback()) end
		end, 'debug'..triggerName, unpack(arg))
	end
	
	-- debug
	local debuggingMain = false
	function debugMain()
		debuggingMain = true
		debugTrigger('mainPanelStatus', 1, 'main')
	end
	
	--debugTrigger('FriendListOnline')
	--debugTrigger('FriendListOffline')
	--debugTrigger('ChatClientInfo')
	--debugTrigger('FriendListEvent')

	--debugTrigger('FriendListGame')
	--debugTrigger('FriendStatusTriggerUI')
	
	
	UnwatchLuaTriggerByKey('LoginStatus', 'LoginStatusCloseAllWindows')
	WatchLuaTrigger('LoginStatus', function(trigger)
		if (not trigger.isLoggedIn) and (WindowManager) and (WindowManager.CloseAllWindowsExceptMainWindow) then
			WindowManager.CloseAllWindowsExceptMainWindow()
		end
	end, 'LoginStatusCloseAllWindows', 'isLoggedIn')	

	-- Automatic screen changes via trigger changes
	local lastPregameState = ''
	local currentPregameState = ''
	function mainUI.getPregameState()
		local gamePhase = LuaTrigger.GetTrigger('GamePhase').gamePhase
		local inLobby = LuaTrigger.GetTrigger('LobbyStatus').inLobby
		local heroSelectMode = LuaTrigger.GetTrigger('HeroSelectMode').mode
		local state = ''
		if (gamePhase > 2 and heroSelectMode == 'captains') then 
			state = 'captainsHeroSelect'
		elseif (heroSelectMode == 'captains') then 
			state = 'captains'
		elseif (gamePhase > 2 and inLobby) then 
			state = 'lobbyHeroSelect'
		elseif (inLobby and gamePhase ~= 0) then 
			state = 'lobby'
		elseif (LuaTrigger.GetTrigger('selectModeInfo').queuedMode == 'scrim') then 
			state = 'scrim'
		elseif (LuaTrigger.GetTrigger('PartyStatus').inParty) then 
			state = 'pregame'
		end
		
		if debuggingMain then println("^gState: "..state) end
		
		lastPregameState = currentPregameState
		currentPregameState = state
		return state
	end
	
	local function checkForAutoSwitch()
		local mainPanelStatus = LuaTrigger.GetTrigger('mainPanelStatus')
		mainUI.getPregameState()
		local curMain = mainPanelStatus.main
		if currentPregameState == 'pregame' and curMain ~= mainUI.MainValues.preGame then
			InitSelectionTriggers()
			mainPanelStatus.main = mainUI.MainValues.preGame
			mainPanelStatus:Trigger(false)
		elseif currentPregameState == 'lobby' then
			mainPanelStatus.main = mainUI.MainValues.lobby
			mainPanelStatus:Trigger(false)
		elseif currentPregameState == 'lobbyHeroSelect' then
			InitSelectionTriggers()
			mainPanelStatus.main = mainUI.MainValues.preGame
			mainPanelStatus:Trigger(false)
		elseif currentPregameState == 'captains' then
			mainPanelStatus.main	= mainUI.MainValues.captainsMode
			mainPanelStatus:Trigger(false)
		elseif (currentPregameState ~= 'captains' and currentPregameState ~= 'captainsHeroSelect') and (lastPregameState == 'captains' or lastPregameState == 'captainsHeroSelect') then
			mainPanelStatus.main	= mainUI.MainValues.news
			mainPanelStatus:Trigger(false)
		elseif currentPregameState == 'captainsHeroSelect' then
			-- Do nothing on this change
		end
	end
	
	-- Party
	UnwatchLuaTriggerByKey('PartyStatus', 'PartyAutoChange')
	WatchLuaTrigger('PartyStatus', function(trigger)
		checkForAutoSwitch()
	end, 'PartyAutoChange', 'inParty')
	
	-- Lobby
	UnwatchLuaTriggerByKey('GamePhase', 'LobbyAutoChange')
	WatchLuaTrigger('GamePhase', function(trigger)
		if LuaTrigger.GetTrigger('LobbyStatus').inLobby then
			checkForAutoSwitch() -- only check changes to gamephase, if we are in a lobby
		end
	end, 'LobbyAutoChange', 'gamePhase')

	-- captains
	UnwatchLuaTriggerByKey('HeroSelectMode', 'HeroSelectModeKey')
	WatchLuaTrigger('HeroSelectMode', function(trigger)
		checkForAutoSwitch()
	end, 'HeroSelectModeKey', 'mode')
	
	-- Return from lobby
	UnwatchLuaTriggerByKey('mainPanelStatus', 'returnFromLobbyKey')
	WatchLuaTrigger('mainPanelStatus', function(trigger)	
		mainPanelOverrideThreadKill()
		local trigger_GamePhase = LuaTrigger.GetTrigger('GamePhase')
		if (trigger_GamePhase.gamePhase == 0) and (trigger.main == 12) then
			mainPanelOverrideThreadKill()
			mainPanelOverrideThread = libThread.threadFunc(function()	
				wait(1)
				local triggerPanelStatus = LuaTrigger.GetTrigger('mainPanelStatus') 
				triggerPanelStatus.main	= 101
				triggerPanelStatus:Trigger(false)
				mainPanelOverrideThread = nil				
			end)	
		end
	end, 'returnFromLobbyKey', 'main')		
	
	LuaTrigger.CreateGroupTrigger('GamePhaseAndAccountLevel', {'GamePhase.gamePhase', 'AccountInfo.accountLevel', 'AccountProgression.level'})
	
	UnwatchLuaTriggerByKey('GamePhaseAndAccountLevel', 'GamePhaseAndAccountLevelKey')
	WatchLuaTrigger('GamePhaseAndAccountLevel', function(groupTrigger)		
		local gamePhase = groupTrigger['GamePhase'].gamePhase
		local accountLevel = groupTrigger['AccountProgression'].level
		if (gamePhase) then
			if ( accountLevel >= 5 ) and (not GetCvarBool('ui_PAXDemo')) then
				ManagedSetLoadingInterface('loading')
			else
				ManagedSetLoadingInterface('loading2')
			end
		end		
	end, 'GamePhaseAndAccountLevelKey')	
	
	local currentLoadingInterface = nil
	function ManagedSetLoadingInterface(targetInterface)
		if (currentLoadingInterface ~= targetInterface)  then
			if (targetInterface ~= 'loading') then
				SetLoadingInterface('/ui/loading/' .. targetInterface .. '.interface', targetInterface)	
			else
				SetLoadingInterface('/ui/' .. targetInterface .. '.interface', targetInterface)
			end
			currentLoadingInterface = targetInterface
		end
	end

	local loginAnimController = LuaTrigger.GetTrigger('loginAnimController') or LuaTrigger.CreateGroupTrigger('loginAnimController', {'GameClientRequestsGetAllLoginData.status', 'GameClientRequestsGetAllGearSets.status', 'GameClientRequestsGetPet.status', 'GameClientRequestsGetCraftedItems.status', 'GameClientRequestsIdentCommodities.status', 'GameClientRequestsGetAllIdentGameData.status', 'LoginStatus.isLoggedIn', 'LoginStatus.hasIdent', 'LoginStatus.isIdentPopulated', 'mainPanelStatus.chatConnectionState', 'LoginStatus.statusTitle', 'PostGameLoopBusyStatus.busy', 'ChatConnectionStatus'} )

	
	local function getInitialPage()
		local pregameState = mainUI.getPregameState()
		if (pregameState == '' or pregameState == "scrim") then
			return mainUI.MainValues.news
		end
		if (pregameState == "captains" or pregameState == "captainsHeroSelect") then
			return mainUI.MainValues.captainsMode
		end
		return -1
	end
	
	
	UnwatchLuaTriggerByKey('loginAnimController', 'loginAnimControllerKey')
	WatchLuaTrigger('loginAnimController', function(groupTrigger)
		local loginStatus 								= groupTrigger['LoginStatus']
		local ChatConnectionStatus 						= groupTrigger['ChatConnectionStatus']
		local gameClientRequestsGetAllIdentGameData 	= groupTrigger['GameClientRequestsGetAllIdentGameData']
		local gameClientRequestsIdentCommodities 		= groupTrigger['GameClientRequestsIdentCommodities']
		local gameClientRequestsGetCraftedItems 		= groupTrigger['GameClientRequestsGetCraftedItems']
		local gameClientRequestsGetPet 					= groupTrigger['GameClientRequestsGetPet']
		local gameClientRequestsGetAllGearSets 			= groupTrigger['GameClientRequestsGetAllGearSets']
		local gameClientRequestsGetAllLoginData 		= groupTrigger['GameClientRequestsGetAllLoginData']
		local triggerPanelStatus 						= groupTrigger['mainPanelStatus']
		local postGameLoopBusy							= groupTrigger['PostGameLoopBusyStatus'].busy
		
		mainUI.unparsedLoginData = mainUI.unparsedLoginData or {}
		
		if (not loginStatus.isLoggedIn) or (not loginStatus.hasIdent) or (not loginStatus.isIdentPopulated) then
			mainUI.unparsedLoginData = {}
			triggerPanelStatus.main			= 0
			triggerPanelStatus:Trigger(false)
		elseif (loginStatus.isLoggedIn) and (loginStatus.hasIdent) and (not postGameLoopBusy) then
			if (gameClientRequestsGetAllLoginData.status ~= 1) and (gameClientRequestsIdentCommodities.status ~= 1) and (gameClientRequestsGetAllIdentGameData.status ~= 1) and (gameClientRequestsGetAllGearSets.status ~= 1)  and (gameClientRequestsGetPet.status ~= 1)  and (gameClientRequestsGetCraftedItems.status ~= 1) then
				if (triggerPanelStatus.main == 0) or (triggerPanelStatus.main == 103) then
					if GetCvarBool('ui_PAXDemo') then
						triggerPanelStatus.main			= 1001
						triggerPanelStatus:Trigger(false)					
					else
						
						MOTD(true, GetCvarBool('ui_alwaysShowMOTD'))
						local page = getInitialPage()
						if (page ~= -1) then
							triggerPanelStatus.main			= page
							triggerPanelStatus:Trigger(false)
						end
						
						if (isReload) then
							LuaTrigger.GetTrigger('loadComplete'):Trigger() -- If this is a reload, we are now loaded.
						else
							UnwatchLuaTriggerByKey('DatabaseLoadStateTrigger', 'isLoadedChecker')
							WatchLuaTrigger('DatabaseLoadStateTrigger', function(trigger)
								if trigger.stateLoaded then
									LuaTrigger.GetTrigger('loadComplete'):Trigger() -- If this is not a reload, we are now loaded.
								end
							end, 'isLoadedChecker', 'stateLoaded')
						end
						
						isReload = true -- Keep track of what is a reload, and what is returning from an update/game

						-- Sync only if we need to.
						if not LuaTrigger.GetTrigger('optionsTrigger').isSynced then
							SaveDBToWeb()
						end				
					end
				end
			end
		end
	end, 'loginAnimControllerKey')
	
	local loginAnimThread
	local function killLoginAnimThread(animActivate)		
		if (animActivate) then
			if (loginAnimThread) then
				-- it already exists
			else
				-- animate in after delay
				loginAnimThread = libThread.threadFunc(function()	
					wait(1200)
					GetWidget('main_chat_no_connection_overlay'):FadeIn(500)
					wait(500)
					GetWidget('main_chat_no_connection_overlay_label'):FadeIn(500)
					GetWidget('main_chat_no_connection_overlay_dimmer'):FadeIn(2500)
					loginAnimThread = nil
				end)	
			end
		else
			if (loginAnimThread) then
				loginAnimThread:kill()
				loginAnimThread = nil
			end		
			GetWidget('main_chat_no_connection_overlay'):FadeOut(125)		
			GetWidget('main_chat_no_connection_overlay_dimmer'):FadeOut(125)
			GetWidget('main_chat_no_connection_overlay_label'):FadeOut(125)			
		end
	end

	GetWidget('main_chat_no_connection_overlay'):RegisterWatchLua('loginAnimController', function(widget, groupTrigger)
		local loginStatus 								= groupTrigger['LoginStatus']
		local ChatConnectionStatus 						= groupTrigger['ChatConnectionStatus']		
		local gameClientRequestsGetAllIdentGameData 	= groupTrigger['GameClientRequestsGetAllIdentGameData']
		local gameClientRequestsGetAllLoginData 		= groupTrigger['GameClientRequestsGetAllLoginData']
		local gameClientRequestsIdentCommodities 		= groupTrigger['GameClientRequestsIdentCommodities']
		local gameClientRequestsGetCraftedItems 		= groupTrigger['GameClientRequestsGetCraftedItems']
		local gameClientRequestsGetPet 					= groupTrigger['GameClientRequestsGetPet']
		local gameClientRequestsGetAllGearSets 			= groupTrigger['GameClientRequestsGetAllGearSets']
		local triggerPanelStatus 						= groupTrigger['mainPanelStatus']
		local postGameLoopBusy							= groupTrigger['PostGameLoopBusyStatus'].busy

		if (loginStatus.statusTitle ~= 'offline' and loginStatus.statusTitle ~= 'failure' and (not loginStatus.isLoggedIn)) then
			-- login attempt in progress
			GetWidget('main_chat_no_connection_overlay_label'):SetText(Translate('main_chat_logging_in'))
			killLoginAnimThread(true)			
		elseif ((not loginStatus.isLoggedIn) or (not loginStatus.hasIdent)) then
			-- do nothing, we are at login screen
			GetWidget('main_chat_no_connection_overlay_label'):SetText(Translate('main_chat_log_in'))
			killLoginAnimThread(false)				
		elseif (not loginStatus.isIdentPopulated) then
			-- we have ident but are waiting for data
			GetWidget('main_chat_no_connection_overlay_label'):SetText(Translate('main_chat_processing_ident'))
			killLoginAnimThread(true)						
		elseif (loginStatus.isLoggedIn) and (loginStatus.hasIdent) then			
			if (not ChatConnectionStatus.connected) and (not GetCvarBool('ui_dont_require_chat_server')) then
				-- connecting to chat
				GetWidget('main_chat_no_connection_overlay_label'):SetText(Translate('main_chat_connecting'))
				killLoginAnimThread(true)
			elseif (not ChatConnectionStatus.authenticated) and (not GetCvarBool('ui_dont_require_chat_server')) then
				GetWidget('main_chat_no_connection_overlay_label'):SetText(Translate('main_chat_chat_authenticating'))
				killLoginAnimThread(true)				
			elseif (gameClientRequestsGetAllLoginData.status == 1) or (gameClientRequestsIdentCommodities.status == 1) or (gameClientRequestsGetAllIdentGameData.status == 1) or (gameClientRequestsGetAllGearSets.status == 1)  or (gameClientRequestsGetPet.status == 1)  or (gameClientRequestsGetCraftedItems.status == 1) then
				-- processing ident data
				GetWidget('main_chat_no_connection_overlay_label'):SetText(Translate('main_chat_processing_data'))
				killLoginAnimThread(true)			
			elseif (postGameLoopBusy) then
				GetWidget('main_chat_no_connection_overlay_label'):SetText(Translate('main_chat_processing_postgame_data'))
				killLoginAnimThread(true)				
			else
				-- fully logged in and ready to show menu
				GetWidget('main_chat_no_connection_overlay_label'):SetText(Translate('main_chat_processing_success'))			
				killLoginAnimThread(false)
			end
		else
			-- logged in but no ident chosen
			GetWidget('main_chat_no_connection_overlay_label'):SetText(Translate('main_chat_processing_choose_ident'))
			killLoginAnimThread(false)
		end
	end)	
	
	interface:RegisterWatchLua(
		'ChatMasterQueueStatus', function(sourceWidget, trigger)
			println(trigger.estimatedMillisecondsRemaining)
			println(trigger.queuePosition)
			println(trigger.reason)
		end
	)	
	
	interface:RegisterWatchLua(
		'ChatConnectionStatus', function(sourceWidget, trigger)
			if (trigger.authenticated) then
				triggerPanelStatus.chatConnectionState		= 1
				triggerPanelStatus:Trigger(false)
			elseif (trigger.connected) then
				-- TODO - show 'Authenticating...'
				triggerPanelStatus.chatConnectionState		= 0
				triggerPanelStatus:Trigger(false)
			else	-- disconnected
				triggerPanelStatus.chatConnectionState		= 0
				triggerPanelStatus:Trigger(false)
				
				if (NewPlayerExperience) and (NewPlayerExperience.trigger) then 
					NewPlayerExperience.trigger.npeStarted			= false
					NewPlayerExperience.trigger:Trigger(false)			
				end
				
				local triggerPanelStatus 						= LuaTrigger.GetTrigger('mainPanelStatus')
				if (triggerPanelStatus.main == 40) then
					triggerPanelStatus.main			= 101
					triggerPanelStatus:Trigger(false)		
				end	
				
				local selection_Status = LuaTrigger.GetTrigger('selection_Status')
				selection_Status.selectionSection = mainUI.Selection.selectionSections.GAME_TYPE_PICK
				selection_Status.selectionLeftContent	= 1
				selection_Status.selectionRightContent	= 1					
			end
		end
	)			
	
	interface:RegisterWatchLua('ChatAvailability', function(sourceWidget, trigger)
		local triggerPanelStatus 				= LuaTrigger.GetTrigger('mainPanelStatus')
		if (triggerPanelStatus.main == 40) and (trigger.matchmaking) and (trigger.matchmaking.enabled == false) then
			triggerPanelStatus.main			= 101
			triggerPanelStatus:Trigger(false)
		elseif (triggerPanelStatus.main == 24) and (trigger.lobby) and (trigger.lobby.enabled == false) then
			LeaveGameLobby(false)
		end	
	end, false, nil, 'matchmaking', 'lobby')
	
	interface:RegisterWatchLua(
		'UpdateInfo', function(sourceWidget, trigger) -- bool updateAvailable, string newVersion
			if (trigger.updateAvailable) then
				Party.LeaveParty(nil, 5)
				triggerPanelStatus.updaterState		= 1
				if (trigger.externalPatchMode) then
					GenericDialog(
						Translate('main_label_update'), Translate('main_label_steam_update_avail'), '', Translate('general_quit'), Translate('general_cancel'), 
						function()
							-- soundEvent - Confirm
							if (trigger.updateAvailable) then
								Cmd('Quit')
							end
						end,
						function()
							-- soundEvent - Cancel
							if (GetCvarBool('ui_newUISounds')) then PlaySound('/ui/sounds/sfx_ui_back.wav') end
							triggerPanelStatus.main = 101
						end,
						nil,
						nil,
						true
					)
				else
					GenericDialog(
						Translate('main_label_update'), Translate('main_label_update_avail'), '', Translate('general_update'), Translate('general_cancel'), 
						function()
							-- soundEvent - Confirm
							if (trigger.updateAvailable) then
								Client.Update()
							end
						end,
						function()
							-- soundEvent - Cancel
							if (GetCvarBool('ui_newUISounds')) then PlaySound('/ui/sounds/sfx_ui_back.wav') end
							triggerPanelStatus.main = 101
						end,
						nil,
						nil,
						true
					)
				end
			else
				triggerPanelStatus.updaterState		= 0
			end
			triggerPanelStatus:Trigger(false)
		end
	)		

	function RegisterEntityDefinitions()
		if (triggerPanelStatus.entityDefinitionsState == 0) then
			triggerPanelStatus.entityDefinitionsState = 2
			triggerPanelStatus:Trigger(false)
			return true
		else
			return true
		end
	end
	
	local animatorWaitThread
	local queuedAnimationFunction
	local function animatorWaitThreadKill()
		if (animatorWaitThread) then
			animatorWaitThread:kill()
			animatorWaitThread = nil
		end
	end	

	interface:GetWidget('main_animator'):RegisterWatchLua('mainPanelStatus', function(widget, trigger)

		widget:UnregisterWatchLua('System')
	
		local mainPanelAnimationStatus = LuaTrigger.GetTrigger('mainPanelAnimationStatus')
		
		if GetCvarBool('ui_animation_debug') then println('Request animation to ^c' .. tostring(trigger.main) .. '^* from ^y' .. mainPanelAnimationStatus.lastMain) end
	
		queuedAnimationFunction = function()
			mainPanelAnimationStatus.newMain 				= 	trigger.main
			mainPanelAnimationStatus.newGamePhase 			= 	trigger.gamePhase
			mainPanelAnimationStatus.timeOfMainChange 		=	GetTime()
			mainPanelAnimationStatus.timeSinceMainChange 	=	0
			
			ClearDrag()
			
			if GetCvarBool('ui_animation_debug') then println('Queueing animation to ^c' .. tostring(mainPanelAnimationStatus.newMain) .. '^* from ^y' .. mainPanelAnimationStatus.lastMain) end
			
			widget:UnregisterWatchLua('System')
			widget:RegisterWatchLua('System', function(_, systemTrigger)
				mainPanelAnimationStatus.timeSinceMainChange = systemTrigger.hostTime - mainPanelAnimationStatus.timeOfMainChange
				mainPanelAnimationStatus:Trigger(false)
				if ((systemTrigger.hostTime - mainPanelAnimationStatus.timeOfMainChange) > (styles_mainSwapAnimationDuration)) then
					if GetCvarBool('ui_animation_debug') then println('Executing animation to ^g' .. tostring(mainPanelAnimationStatus.newMain) .. '^* from ^y' .. mainPanelAnimationStatus.lastMain) end
					mainPanelAnimationStatus.main 			= 	trigger.main
					mainPanelAnimationStatus.gamePhase		= 	trigger.gamePhase
					mainPanelAnimationStatus.lastMain 		= 	trigger.main
					mainPanelAnimationStatus.newMain 		=   -1
					mainPanelAnimationStatus.newGamePhase 	=   -1
					mainPanelAnimationStatus:Trigger(false)
					widget:UnregisterWatchLua('System')
				end
			end, false, nil, 'hostTime')
			
			mainPanelAnimationStatus:Trigger(false)
		end	
	
		animatorWaitThreadKill()
		animatorWaitThread = libThread.threadFunc(function()	
			wait(1)
			if (mainPanelOverrideThread) then
				wait(500)
			end
			
			if (queuedAnimationFunction) then
				queuedAnimationFunction()
			end
			animatorWaitThread = nil
		end)

	end, false, nil, 'main')
		
	if GetCvarBool('ui_animation_debug2') then

		interface:GetWidget('main_animator'):RegisterWatchLua('mainPanelAnimationStatus', function(widget, trigger)
			println(' ')
			println('^g mainPanelAnimationStatus.main ' 				.. 		tostring(trigger.main)					)
			println('^g mainPanelAnimationStatus.newMain ' 				.. 		tostring(trigger.newMain)				)
		end, false, nil, 'main', 'newMain') -- , 'lastMain', 'timeOfMainChange', 'timeSinceMainChange'		
		
		interface:GetWidget('main_animator'):RegisterWatchLua('featureMaintenanceTrigger', function(widget, trigger)
			println('^c featureMaintenanceTrigger ')
		end)
		
	end
	
	local urlOpenThrottle	= 3000
	local urlOpenLastTime
	
	function mainUI.AreYouSureYouWantToCreateASteamAccountDialog()
		GenericDialogAutoSize(
			Translate('dialog_holdon_newsteamaccount'), Translate('dialog_holdon_newsteamaccount_moreinfo'), Translate('dialog_holdon_newsteamaccount_really'), 'dialog_holdon_newsteamaccount_doit', 'general_go_back',
			function()
				mainUI.ShowSplashScreen(); Login.AttemptCreateSteamAccount()
			end,
			nil
		)	
		GetWidget('generic_dialog_button_1'):SetEnabled(0)
		libThread.threadFunc(function()	
			wait(4500)		
			GetWidget('generic_dialog_button_1'):SetEnabled(1)
		end)
	end
	
	function mainUI.OpenSupportDialog()
		if (Client.GetAccountID() ~= '4294967.295') then
			GenericDialogAutoSize(
				Translate('general_go_to_website'), Translate('general_go_to_cs'), Translate('general_go_to_cs_moreinfo') .. '\n\n' .. Translate('general_go_to_cs_accountid', 'value', Client.GetAccountID()) .. '\n', 'general_ok', 'general_cancel',
				function()
					mainUI.OpenURL((Strife_Region.regionTable[Strife_Region.activeRegion].strifeSupportURL or 'http://www.strife.com'))
				end,
				nil
			)
		else
			GenericDialogAutoSize(
				Translate('general_go_to_website'), Translate('general_go_to_cs'), Translate('general_go_to_cs_login') .. '\n', 'general_ok', 'general_cancel',
				function()
					mainUI.OpenURL((Strife_Region.regionTable[Strife_Region.activeRegion].strifeSupportURL or 'http://www.strife.com'))
				end,
				nil
			)
		end
	end	
	
	function mainUI.OpenURL(targetURL, pushToFront, useSteamOverlay)
		local pushToFront = pushToFront
		if (pushToFront == nil) then
			pushToFront = true
		end
		local useSteamOverlay = useSteamOverlay or false
		local thisTime = GetTime()
		if (not urlOpenLastTime) or (thisTime > urlOpenLastTime + urlOpenThrottle) then
			println('Open URL in external browser: ' .. tostring(targetURL))
			System.OpenURL(targetURL, pushToFront, useSteamOverlay)
			urlOpenLastTime = thisTime
		end
	end
	
	function mainUI.OpenURLInLauncher(targetURL)
		local thisTime = GetTime()
		if (not urlOpenLastTime) or (thisTime > urlOpenLastTime + urlOpenThrottle) then
			println('Open URL in launcher: ' .. tostring(targetURL))
			UIManager.GetActiveInterface():GetWidget('browser_browser'):WebBrowserLoadURL(targetURL)
			UIManager.GetActiveInterface():GetWidget('browser_panel'):FadeIn(750)
			urlOpenLastTime = thisTime
		end
	end	
	
	function mainUI.CloseBrowser()
		UIManager.GetActiveInterface():GetWidget('browser_browser'):WebBrowserStop()
		UIManager.GetActiveInterface():GetWidget('browser_browser'):WebBrowserClose()
		UIManager.GetActiveInterface():GetWidget('browser_panel'):FadeOut(250)
	end		
	
	function mainUI.SpectateGame(identID)
		local partyStatusTrigger = LuaTrigger.GetTrigger('PartyStatus')
		if (not partyStatusTrigger.inQueue) then
			ChatClient.SpectateGame(identID)
		else
			GenericDialog(
				Translate('main_prompt_spectate_will_leave_queue'), Translate('main_prompt_spectate_will_leave_queue_desc'), '', Translate('general_ok'), Translate('general_quit'), 
				function()
					-- soundEvent - Confirm
					Party.LeaveParty(nil, 2)
					ChatClient.SpectateGame(identID)
				end,
				function()
					-- soundEvent - Cancel
				end
			)		
		end
	end
	
	mainUI.savedLocally = mainUI.savedLocally or {}
	triggerPanelStatus.selectedUserIdentID		= mainUI.savedLocally.selectedUserIdentID or ''
	triggerPanelStatus.updaterState				= 0
	triggerPanelStatus.main						= 0
	triggerPanelStatus.mainMoreVisible			= false
	triggerPanelStatus.aspect					= (GetScreenWidth() / GetScreenHeight())
	triggerPanelStatus.socialUserListToggled	= false
	triggerPanelStatus.activityFeedVisible		= true
	triggerPanelStatus.myGroupsVisible			= true
	triggerPanelStatus.isLoggedIn				= false
	triggerPanelStatus.externalLogin			= false
	triggerPanelStatus.hasIdent					= false
	triggerPanelStatus.gamePhase				= 0
	triggerPanelStatus.animationState 			= 0
	triggerPanelStatus.entityDefinitionsState	= 0
	triggerPanelStatus.getPetDataState			= 0
	triggerPanelStatus.getEnchantItemsState		= 0
	triggerPanelStatus.chatConnectionState		= 0
	triggerPanelStatus.chatConnected			= false
	triggerPanelStatus.useCompetitiveHeroSelect	= false
	triggerPanelStatus.missedGameAddress = ''
	triggerPanelStatus.reconnectAddress = ''
	triggerPanelStatus.reconnectType = ''
	triggerPanelStatus.reconnectShow = false	
	
	local mainPanelAnimationStatus = LuaTrigger.GetTrigger('mainPanelAnimationStatus')
	mainPanelAnimationStatus.newMain 	=   -1	
	
	function hackLogin()
		triggerPanelStatus.hasIdent		= true
		triggerPanelStatus.isLoggedIn	= true
		triggerPanelStatus:Trigger()
	end
	
	InitializeMusic(object, triggerPanelStatus)

	function blockInput(doBlock)
		doBlock = doBlock or false

		object:GetWidget('inputBlocker'):SetVisible(doBlock)
	end

	local function InitializeTwitchTV(object)
		if (Twitch) and (Twitch.SetOverlayInterface) then
			Twitch.SetOverlayInterface('/ui/shared/twitch/twitch.interface')
		end
	end
	InitializeTwitchTV(object)		
	
end	

mainRegister(object)


function GameMenuToggle()
	-- Overlay here, eventually
end

object:RegisterWatchLua('LobbyStatus', function(widget, trigger)
	if trigger.state == 'finding_server' then
		-- sound_lobbyFoundMatch (finding server)
		-- PlaySound('/ui/sounds/ui_startmatch.wav')
		-- print('status is finding_server!!!\n')
		widget:UICmd("StopMusic()")
	end
end, false, nil, 'state')
