local _G = getfenv(0)
local ipairs, pairs, select, string, table, next, type, unpack, tinsert, tconcat, tremove, format, tostring, tonumber, tsort, ceil, floor, sub, find, gfind = _G.ipairs, _G.pairs, _G.select, _G.string, _G.table, _G.next, _G.type, _G.unpack, _G.table.insert, _G.table.concat, _G.table.remove, _G.string.format, _G.tostring, _G.tonumber, _G.table.sort, _G.math.ceil, _G.math.floor, _G.string.sub, _G.string.find, _G.string.gfind
local interface, interfaceName = object, object:GetName()

mainUI = mainUI or {}
mainUI.savedLocally 	= mainUI.savedLocally 		or {}
mainUI.savedRemotely 	= mainUI.savedRemotely 		or {}
mainUI.savedAnonymously	= mainUI.savedAnonymously 	or {}
mainUI.savedLocally.downVoteList 	= mainUI.savedLocally.downVoteList 	or {}
mainUI.pauseDuration1 = 150
mainUI.pauseDuration2 = 250
mainUI.pauseDuration3 = 500
mainUI.reconnecting = false
ClientInfo = ClientInfo or {}
ClientInfo.duplicateUsernameTable = {}

local clientInfoDrag = LuaTrigger.CreateCustomTrigger('clientInfoDrag',
	{

		{ name	= 'clientDraggingIndex',				type	= 'number' },
		{ name	= 'clientDraggingIdentID',				type	= 'string' },
		{ name	= 'clientDraggingUniqueID',				type	= 'string' },
		{ name	= 'clientDraggingName',					type	= 'string' },
		{ name	= 'clientDraggingAcceptStatus',			type	= 'string' },
		{ name	= 'clientDraggingGameAddress',			type	= 'string' },
		{ name	= 'clientDraggingLabel',				type	= 'string' },
		{ name	= 'clientDraggingWidgetIndex',			type	= 'number' },
		{ name	= 'clientDraggingIsFriend',				type	= 'boolean' },
		{ name	= 'clientDraggingIsPending',			type	= 'boolean' },
		{ name	= 'clientDraggingIsInParty',			type	= 'boolean' },
		{ name	= 'clientDraggingCanSpectate',			type	= 'boolean' },
		{ name	= 'clientDraggingIsHoveringMenu',		type	= 'boolean' },
		{ name 	= 'clientDraggingIsOnline',				type	= 'boolean' },
		{ name	= 'dragActive',							type	= 'boolean' },
		
	}
)

local mainPanelStatusDragInfo = LuaTrigger.CreateGroupTrigger('mainPanelStatusDragInfo', {'mainPanelStatus', 'globalDragInfo', 'clientInfoDrag'} )

local function InitializeLoading(object, triggerPanelStatus)

	interface:RegisterWatchLua('EntityDefinitionsProgress', function(widget, trigger) 
		triggerPanelStatus.entityDefinitionsState = 1
		triggerPanelStatus:Trigger(false)
	end)	
	
	interface:RegisterWatchLua('EntityDefinitionsLoaded', function(widget, trigger)
		triggerPanelStatus.entityDefinitionsState = 2
		triggerPanelStatus:Trigger(false)
	end)	
		
end

local urlOpenThrottle	= 3000
local urlOpenLastTime

function mainUI.OpenURL(targetURL)
	local thisTime = GetTime()
	if (not urlOpenLastTime) or (thisTime > urlOpenLastTime + urlOpenThrottle) then
		println('Open URL in external browser: ' .. tostring(targetURL))
		System.OpenURL(targetURL)
		urlOpenLastTime = thisTime
	end
end

local function InitializeMusic(object, triggerPanelStatus)

	LuaTrigger.CreateGroupTrigger('gameMusicControlInfo', {'GamePhase.gamePhase', 'LoginStatus.isLoggedIn', 'LoginStatus.hasIdent'} )

	local currentMusic	= ''
	
	local function playMusicUnique(musicFile)
		if musicFile and string.len(musicFile) > 0 and musicFile ~= currentMusic then
			object:UICmd("PlayMusic('"..musicFile.."', false)")
			currentMusic = musicFile
		end
	end
	
	object:GetWidget('mainMusicController'):RegisterWatchLua('gameMusicControlInfo', function(widget, groupTrigger)
		local triggerGamePhase		= groupTrigger['GamePhase']
		local triggerLoginStatus	= groupTrigger['LoginStatus']
		
		local gamePhase	= triggerGamePhase.gamePhase
		
		if gamePhase == 0 then
			-- playMusicUnique('/music/music_mainmenu_temp.wav')
			--[[
			if triggerLoginStatus.isLoggedIn and triggerLoginStatus.hasIdent then
				widget:UICmd("PlayMusic('/music/ingame/music_normal.wav', true)")
			else
				widget:UICmd("PlayMusic('/music/ingame/music_pregame.wav', true)")
			end	
			--]]			
		-- elseif gamePhase < 5 then
		-- 	if gamePhase == 1 then
		-- 		widget:UICmd("PlayMusic('/music/ingame/music_tencitement.wav', true)")
		-- 	else
		-- 		widget:UICmd("StopMusic()")
		-- 	end
		else
			-- widget:UICmd("StopMusic()")
		end
	end)
end

local finishMatchThread
function FinishMatch()
	println('^r FinishMatch')
	local LeavingInfo = LuaTrigger.GetTrigger('LeavingInfo')
	if (LeavingInfo) and (mainUI.savedLocally) then
		mainUI.savedLocally.leftLastGameSafely = LeavingInfo.safeToLeave
	end
	SaveState()
	SetSave('cg_cloudSynced', 'false', 'bool')
	if (finishMatchThread) then
		finishMatchThread:kill()
		finishMatchThread = nil
	end
	finishMatchThread = libThread.threadFunc(function()	
		wait(500)		
		if (not mainUI.reconnecting) then
			Client.FinishGame()
		end
		finishMatchThread = nil
	end)
end


local function mainRegister(object)
	
	local triggerPanelStatus		= LuaTrigger.GetTrigger('mainPanelStatus')

	InitializeLoading(object, triggerPanelStatus)
		
	interface:RegisterWatchLua('GameReinitialize', function(widget, trigger)
		mainUI = mainUI or {}
		mainUI.savedLocally = mainUI.savedLocally or {}
		local LeavingInfo = LuaTrigger.GetTrigger('LeavingInfo')
		if (LeavingInfo) and (mainUI.savedLocally) then
			mainUI.savedLocally.leftLastGameSafely = LeavingInfo.safeToLeave
		end
		SaveState()
	end)		
		
	interface:RegisterWatch('HostErrorMessage', function(sourceWidget, param0, param1, param2)
		println('^r HostErrorMessage ' .. tostring(param0) .. ' ' .. tostring(param1))
		if (param0 == 'disconnect_afk_kicked') or (param1 == 'disconnect_afk_kicked') then
			mainUI.savedLocally = mainUI.savedLocally or {}
			mainUI.savedLocally.notifications = mainUI.savedLocally.notifications or {}
			table.insert(mainUI.savedLocally.notifications, {'disconnect_afk_kicked', 'disconnect_afk_kicked_desc'})
			FinishMatch()			
		end		
		sourceWidget:GetWidget('main_parted_no_connection_overlay_label'):SetText(Translate(param0) .. '\n' .. Translate(param1))
		sourceWidget:GetWidget('main_parted_no_connection_overlay_label'):SetVisible(1)		
	end)	

	interface:GetWidget('main_parted_blocker'):RegisterWatchLua('GamePhase', function(sourceWidget, trigger)
		sourceWidget:SetVisible(trigger.gamePhase <= 5)
	end)
	interface:GetWidget('main_parted_blocker'):SetVisible(1)
	
	interface:GetWidget('main_parted_blocker'):RegisterWatchLua('ConnectionStatus', function(sourceWidget, trigger)
		if (trigger.isConnected) then
			interface:GetWidget('main_parted_blocker'):UnregisterWatchLua('GamePhase')
			interface:GetWidget('main_parted_blocker'):RegisterWatchLua('GamePhase', function(sourceWidget, trigger)
				sourceWidget:SetVisible(trigger.gamePhase <= 5)
			end)
			sourceWidget:SetVisible(1)
		else
			interface:GetWidget('main_parted_blocker'):UnregisterWatchLua('GamePhase')
			sourceWidget:SetVisible(0)
		end
	end)	
	
	interface:RegisterWatch('Disconnected', function(sourceWidget)
		println('^r Disconnected')
		libThread.threadFunc(function()	
			wait(15000)		
			FinishMatch()
		end)
	end)
	
	local delayThread = nil
	interface:SetCallback('onshow', function(sourceWidget)
		println('^r onshow')
		if (delayThread) then
			delayThread:kill()
			delayThread = nil
		end		
		sourceWidget:GetWidget('main_parted_no_connection_overlay'):SetVisible(0)
		delayThread = libThread.threadFunc(function()	
			wait(1500)		
			sourceWidget:GetWidget('main_parted_no_connection_overlay'):FadeIn(250)
			delayThread = nil
		end)
	end)	
	
	interface:SetCallback('onhide', function(sourceWidget)
		println('^r onhide')
		sourceWidget:GetWidget('main_parted_no_connection_overlay'):SetVisible(0)
		if (delayThread) then
			delayThread:kill()
			delayThread = nil
		end
	end)		
	
	local lastGamePhase = -1		
	interface:RegisterWatchLua('GamePhase', function(widget, trigger)
		local gamePhase = trigger.gamePhase
		if gamePhase == 0 then
			if lastGamePhase >= 5 then
				libThread.threadFunc(function()	
					wait(1500)	
					FinishMatch()
				end)
			end
		end
		lastGamePhase = gamePhase
		mainUI.reconnecting = false
	end, true)	
	
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
			end
		end
	)		
	
	interface:RegisterWatchLua(
		'UpdateInfo', function(sourceWidget, trigger) -- bool updateAvailable, string newVersion
			if (trigger.updateAvailable) then
				triggerPanelStatus.updaterState		= 1
			else
				triggerPanelStatus.updaterState		= 0
			end
			triggerPanelStatus:Trigger(false)
		end
	)		

	function RegisterEntityDefinitions()
		if (triggerPanelStatus.entityDefinitionsState == 0) then
			Cmd('RegisterEntityDefinitions')
			return false
		else
			return true
		end
	end

	interface:RegisterWatchLua('GamePhase', function(widget, trigger)
		if trigger.gamePhase == 1 or trigger.gamePhase >= 5 then
			RemoveLoadScreen()
		end
	end, false, nil, 'gamePhase')
	
	local currentLoadingInterface = nil
	function ManagedSetLoadingInterface(targetInterface)
		-- if (currentLoadingInterface ~= targetInterface)  then
			-- if (targetInterface ~= 'loading') then
				-- SetLoadingInterface('/ui/loading/' .. targetInterface .. '.interface', targetInterface)	
			-- else
				-- SetLoadingInterface('/ui/' .. targetInterface .. '.interface', targetInterface)
			-- end
			-- currentLoadingInterface = targetInterface
		-- end
	end
	
	-- UnwatchLuaTriggerByKey('GamePhase', 'GamePhaseKey')
	-- WatchLuaTrigger('GamePhase', function(trigger)
		-- if (trigger.gamePhase == 0) then
			-- ManagedSetLoadingInterface('loading')
		-- end
	-- end, 'GamePhaseKey', 'gamePhase')

	
	UnwatchLuaTriggerByKey('mainPanelStatus', 'main_state')
	WatchLuaTrigger('mainPanelStatus', function(trigger)
		mainUI = mainUI or {}
		mainUI.savedLocally = mainUI.savedLocally or {}
		mainUI.savedLocally.updaterState 					=	0
		mainUI.savedLocally.main 							=	trigger.main
		mainUI.savedLocally.mainMoreVisible 				=	false
		mainUI.savedLocally.aspect 							=	trigger.aspect
		mainUI.savedLocally.socialUserListToggled 			=	false
		mainUI.savedLocally.activityFeedVisible 			=	false
		mainUI.savedLocally.myGroupsVisible 				=	false
		mainUI.savedLocally.isLoggedIn 						=	false
		mainUI.savedLocally.hasIdent 						=	false
		mainUI.savedLocally.gamePhase 						=	trigger.gamePhase
		mainUI.savedLocally.animationState 					=	0
		mainUI.savedLocally.entityDefinitionsState 			=	0
		mainUI.savedLocally.getPetDataState 				=	0
		mainUI.savedLocally.getEnchantItemsState 			=	0
		mainUI.savedLocally.chatConnectionState 			=	0
		mainUI.savedLocally.chatConnected 					=	false
		mainUI.savedLocally.useCompetitiveHeroSelect 		=	false
		SaveState()
	end, 'main_state')		
	
	triggerPanelStatus.updaterState				= mainUI.savedLocally.updaterState or 0
	triggerPanelStatus.main						= mainUI.savedLocally.main or GetCvarNumber('ui_defaultMain') or 0
	triggerPanelStatus.mainMoreVisible			= mainUI.savedLocally.mainMoreVisible or false
	triggerPanelStatus.aspect					= mainUI.savedLocally.aspect or (GetScreenWidth() / GetScreenHeight())
	triggerPanelStatus.socialUserListToggled	= mainUI.savedLocally.socialUserListToggled or false
	triggerPanelStatus.activityFeedVisible		= mainUI.savedLocally.activityFeedVisible or true
	triggerPanelStatus.myGroupsVisible			= mainUI.savedLocally.myGroupsVisible or true
	triggerPanelStatus.isLoggedIn				= mainUI.savedLocally.isLoggedIn or false
	triggerPanelStatus.hasIdent					= mainUI.savedLocally.hasIdent or false
	triggerPanelStatus.gamePhase				= mainUI.savedLocally.gamePhase or 0
	triggerPanelStatus.animationState 			= mainUI.savedLocally.animationState or 0
	triggerPanelStatus.entityDefinitionsState	= mainUI.savedLocally.entityDefinitionsState or 0
	triggerPanelStatus.getPetDataState			= mainUI.savedLocally.getPetDataState or 0
	triggerPanelStatus.getEnchantItemsState		= mainUI.savedLocally.getEnchantItemsState or 0
	triggerPanelStatus.chatConnectionState		= mainUI.savedLocally.chatConnectionState or 0
	triggerPanelStatus.chatConnected			= mainUI.savedLocally.chatConnected or false
	triggerPanelStatus.useCompetitiveHeroSelect	= mainUI.savedLocally.useCompetitiveHeroSelect or false
	if mainUI.launcherMusicEnabled == nil then
		mainUI.launcherMusicEnabled = true
	end

	triggerPanelStatus.launcherMusicEnabled = mainUI.launcherMusicEnabled
	
	triggerPanelStatus:Trigger(true)

	InitializeMusic(object, triggerPanelStatus)
	
end	

mainRegister(object)
