PostGame = PostGame or {}
local mainPanelStatus				= LuaTrigger.GetTrigger('mainPanelStatus')
local PostGameLoopStatus			= LuaTrigger.GetTrigger('PostGameLoopStatus')
local AccountProgression 			= LuaTrigger.GetTrigger('AccountProgression')
local PostGameGroupTrigger 			= LuaTrigger.GetTrigger('PostGameGroupTrigger')

function TestPostGame(up)
	local testThread

	local function testPostGame()
		mainUI.savedLocally.lastMatchID = GetCvarString('ui_testPostGame_matchid', true) or '322.000'
		EndMatch.Show(true)
	end

	function testPostGame2()
		local rewardData = {}
		rewardData.reward = {}
		rewardData.reward.progress = 1
		rewardData.reward.match_id = '2.000'
		rewardData.reward.openChestCost = {}
		rewardData.reward.openChestCost.gems = 0
		PostGame.Rewards.openAnotherChestCost = 0
		trigger_postGameLoopStatus.showPostGameLoop = true

		PostGame.Rewards.ProcessData(rewardData, matchid, true)
	end

	if (testThread) then
		mainUI.savedLocally.lastMatchID = nil
		testThread:kill()
		testThread = nil
	end
	testThread = libThread.threadFunc(function()
		mainUI.savedLocally.lastMatchID = nil
		wait(3500)
		PostGame.Splash.heroEntityName = 'Hero_Hale'
		
		PostGame.Splash.modules.rankedPlayProgression = PostGame.Splash.modules.rankedPlayProgression or {}
		PostGame.Splash.modules.standardPlayProgression = PostGame.Splash.modules.standardPlayProgression or {}
		
		if (not up) then
			PostGame.Splash.modules.rankedPlayProgression['Hero_Hale'] = {}
			PostGame.Splash.modules.standardPlayProgression['Hero_Hale'] = {}
			PostGame.Splash.modules.rankedPlayProgression['Hero_Hale'].lastDivision = 'bronze'
			PostGame.Splash.modules.rankedPlayProgression['Hero_Hale'].lastRank = 1000
			PostGame.Splash.modules.standardPlayProgression['Hero_Hale'].pvpRating0 = 1800
			PostGame.Splash.modules.standardPlayProgression['Hero_Hale'].lastpvpRating0 = 1750			
			PostGame.Splash.modules.rankedPlayProgression['Hero_Moxie'] = {}
			PostGame.Splash.modules.standardPlayProgression['Hero_Moxie'] = {}
			PostGame.Splash.modules.rankedPlayProgression['Hero_Moxie'].lastDivision = 'bronze'
			PostGame.Splash.modules.rankedPlayProgression['Hero_Moxie'].lastRank = 1000				
			PostGame.Splash.modules.standardPlayProgression['Hero_Moxie'].pvpRating0 = 1800
			PostGame.Splash.modules.standardPlayProgression['Hero_Moxie'].lastpvpRating0 = 1750		
			PostGame.Splash.modules.standardPlayProgression['Hero_Moxie'].lastpvpRating0 = 1750	
			mainUI.progression.stats.account = mainUI.progression.stats.account or {}
			mainUI.progression.stats.account.lastpvpRating0 = 1750
		else
			PostGame.Splash.modules.rankedPlayProgression['Hero_Hale'] = {}
			PostGame.Splash.modules.standardPlayProgression['Hero_Hale'] = {}
			PostGame.Splash.modules.rankedPlayProgression['Hero_Hale'].lastDivision = 'bronze'
			PostGame.Splash.modules.rankedPlayProgression['Hero_Hale'].lastRank = 1000
			PostGame.Splash.modules.standardPlayProgression['Hero_Hale'].pvpRating0 = 1200
			PostGame.Splash.modules.standardPlayProgression['Hero_Hale'].lastpvpRating0 = 1250			
			PostGame.Splash.modules.rankedPlayProgression['Hero_Moxie'] = {}
			PostGame.Splash.modules.standardPlayProgression['Hero_Moxie'] = {}
			PostGame.Splash.modules.rankedPlayProgression['Hero_Moxie'].lastDivision = 'bronze'
			PostGame.Splash.modules.rankedPlayProgression['Hero_Moxie'].lastRank = 1000				
			PostGame.Splash.modules.standardPlayProgression['Hero_Moxie'].pvpRating0 = 1200
			PostGame.Splash.modules.standardPlayProgression['Hero_Moxie'].lastpvpRating0 = 1250		
			PostGame.Splash.modules.standardPlayProgression['Hero_Moxie'].lastpvpRating0 = 1250	
			mainUI.progression.stats.account = mainUI.progression.stats.account or {}
			mainUI.progression.stats.account.lastpvpRating0 = 1250	
		end
		
		testPostGame()
		wait(8500)
		-- testPostGame2()
		
		PostGame.Rewards.TestRewards()
		testThread = nil
	end)
end

-- Post Game Main Parent

	local function postgameRequestPending()
		return (trigger_postGameLoopStatus.requestingClaimQuestReward) or (trigger_postGameLoopStatus.requestingClaimReward) or (trigger_postGameLoopStatus.requestingMatchStats) or (trigger_postGameLoopStatus.requestingRewardChests) or (trigger_postGameLoopStatus.requestingQuests) or (trigger_postGameLoopStatus.requestingAccountProgress) or false
	end	

	local postGameUpdateDelayThread	-- This thread allows processing to complete before triggering the post game loop
	GetWidget('post_game_loop_parent'):RegisterWatchLua('PostGameLoopStatus', function(widget, trigger)
		if (postGameUpdateDelayThread) then
			postGameUpdateDelayThread:kill()
			postGameUpdateDelayThread = nil
		end 
		postGameUpdateDelayThread = libThread.threadFunc(function()
			if (trigger_postGameLoopBusyStatus.busy) or (postgameRequestPending()) or (not (mainUI and mainUI.progression and mainUI.progression.progressionLoaded)) then
				wait(3500)
			else
				wait(100)
			end
			PostGame.Update()
			postGameUpdateDelayThread = nil
		end)
	end, false, nil)

	GetWidget('post_game_loop_parent'):RegisterWatchLua('mainPanelStatus', function(widget, trigger)
		libGeneral.fade(widget, (trigger.main == 10) or (trigger.main == 11) or (trigger.main == 13) or (trigger.main == 14), 250)
	end, false, nil, 'main')

-- Content Inside Parent

	-- GetWidget('postgame_khanquest'):RegisterWatchLua('PostGameGroupTrigger', function(widget, _)
		-- libGeneral.fade(widget, (PostGameLoopStatus.screen == 'KHANQUEST'), 250)
	-- end, false, nil)
	
	GetWidget('postgame_rewards'):RegisterWatchLua('PostGameGroupTrigger', function(widget, _)
		libGeneral.fade(widget, (PostGameLoopStatus.screen == 'REWARDS'), 250)
	end, false, nil)

	GetWidget('postgame_summary_freeform_parent'):RegisterWatchLua('PostGameGroupTrigger', function(widget, _)
		libGeneral.fade(widget, (PostGameLoopStatus.screen == 'SUMMARY'), 250)
	end, false, nil)

	GetWidget('postgame_notice_parent'):RegisterWatchLua('PostGameGroupTrigger', function(widget, _)
		libGeneral.fade(widget, (PostGameLoopStatus.screen == 'SUMMARY' or PostGameLoopStatus.screen == 'REWARDS'), 250)
	end, false, nil)

	GetWidget('postgame_progress'):RegisterWatchLua('PostGameGroupTrigger', function(widget, _)
		libGeneral.fade(widget, (PostGameLoopStatus.screen == 'PROGRESS'), 250)
	end, false, nil)

	GetWidget('postgame_scoreboard'):RegisterWatchLua('PostGameGroupTrigger', function(widget, _)
		libGeneral.fade(widget, (PostGameLoopStatus.screen == 'SCOREBOARD'), 250)
	end, false, nil)

	GetWidget('postgame_summary_insert_match_awards'):RegisterWatchLua('PostGameGroupTrigger', function(widget, _)
		libGeneral.fade(widget, (PostGameLoopStatus.screen == 'SCOREBOARD'), 250)
	end, false, nil)	
	
function PostGame.Close()
	if (mainPanelStatus.main == 10) and (not postgameRequestPending()) then
		println('^gPostGame.Close')
		local partyStatusTrigger 		= LuaTrigger.GetTrigger('PartyStatus')

		local newMain			= mainUI.MainValues.news
		local openedPlayScreen	= false

		local LeaverBan	= LuaTrigger.GetTrigger('LeaverBan')

		if (LeaverBan) and (LeaverBan.bannedUntil) and (LeaverBan.bannedUntil > 0) and (LeaverBan.now) and (LeaverBan.bannedUntil > LeaverBan.now) then
			-- Banned, don't go anywhere special.
			newMain				= mainUI.MainValues.news
		elseif partyStatusTrigger.inParty then
			if (partyStatusTrigger.queue == 'scrim') then
				newMain				= 35	
				ScrimFinder.OpenScrimFinder()
			else
				newMain				= mainUI.MainValues.preGame
				forceTrigger		= true
				openedPlayScreen	= true
			end
		end

		mainPanelStatus.main = newMain
		mainPanelStatus:Trigger(true)

		local selection_Status = LuaTrigger.GetTrigger('selection_Status')
		selection_Status.selectionSection = mainUI.Selection.selectionSections.HERO_PICK
		selection_Status.selectionLeftContent = 1
		selection_Status.selectionRightContent = 1
		selection_Status:Trigger(forceTrigger)
		EndMatch.Show(false)

		if (forceTrigger) then
			InitSelectionTriggers(interface, false)
		end

		if (mainUI) and (mainUI.savedLocally.downVoteList) and (downVoteMatchID) then
			for identID,reason in pairs((mainUI.savedLocally.downVoteList)) do
				if (type(reason) == 'number') then
					EndMatch.PlayerFeedbackWithEncode(identID, downVoteMatchID, true, reason)
				else
					EndMatch.PlayerFeedbackWithEncode(identID, downVoteMatchID, true, 0)
				end
			end
			downVoteMatchID = nil
			mainUI.savedLocally.downVoteList = {}
		end

		if (mainUI) and (mainUI.savedLocally.upVoteList) and (upVoteMatchID) then
			for identID,_ in pairs((mainUI.savedLocally.upVoteList)) do
				EndMatch.PlayerFeedbackWithEncode(identID, upVoteMatchID, false, 0)
			end
			upVoteMatchID = nil
			mainUI.savedLocally.upVoteList = {}
		end

		if openedPlayScreen then
			Party.OpenedPlayScreen()
		end

		if PostGameLoopStatus.viaUnclaimed and (PostGame.Rewards.lastGetRewardChestsMatchID) and (tonumber(PostGame.Rewards.lastGetRewardChestsMatchID) > 0) then
			FinishReward(PostGame.Rewards.lastGetRewardChestsMatchID)
		elseif (PostGameLoopStatus.rewardsAvailable) and (PostGame.Rewards.lastGetRewardChestsMatchID) and (tonumber(PostGame.Rewards.lastGetRewardChestsMatchID) > 0) then
			PostGameLoopStatus.rewardsAvailable = false
			if (PostGameLoopStatus.rewardsClaimed) then
				FinishReward(PostGame.Rewards.lastGetRewardChestsMatchID)
			end
		end
		PlaySound('/ui/sounds/rewards/sfx_done.wav')

		PostGame.Splash.modules = PostGame.Splash.modules or {}
		trigger_postGameLoopStatus.screen							= ''
		trigger_postGameLoopStatus.summaryAvailable 				= false
		trigger_postGameLoopStatus.unlocksAvailable 				= false
		trigger_postGameLoopStatus.awardsAvailable 					= false
		trigger_postGameLoopStatus.statsAvailable 					= false
		trigger_postGameLoopStatus.rewardsAvailable 				= false
		trigger_postGameLoopStatus.scoreboardAvailable 				= false
		trigger_postGameLoopStatus.progressAvailable 				= false
		trigger_postGameLoopStatus.rankedProgressAvailable 			= false
		trigger_postGameLoopStatus.standardProgressAvailable 		= false
		trigger_postGameLoopStatus.questsAvailable 					= false
		trigger_postGameLoopStatus.showPostGameLoop 				= false
		trigger_postGameLoopStatus.viaUnclaimed 					= false
		trigger_postGameLoopStatus.rewardsClaimed 					= false
		trigger_postGameLoopStatus.requestingClaimReward			= false
		trigger_postGameLoopStatus.requestingClaimQuestReward		= false
		trigger_postGameLoopStatus.isClaimingChest					= false
		trigger_postGameLoopStatus.requestingMatchStats				= false
		trigger_postGameLoopStatus.requestingRewardChests			= false
		trigger_postGameLoopStatus.requestingQuests					= false
		trigger_postGameLoopStatus.requestingAccountProgress		= false
		trigger_postGameLoopStatus.summaryAnimationActive			= false
		trigger_postGameLoopStatus.fastForwarding					= false
		trigger_postGameLoopStatus.khanquestAnimationActive			= false

		if (PostGame.Splash.animateSplashScreenThread) then
			PostGame.Splash.animateSplashScreenThread:kill()
			PostGame.Splash.animateSplashScreenThread = nil
		end

		if (PostGame.Rewards) and (PostGame.Rewards.lastGetRewardChestsMatchID) and (PostGame.Rewards.lastGetRewardChestsMatchID == '0.000') then
			newPlayerExperienceCompleted()
		elseif (mainUI.savedLocally) and (mainUI.savedLocally.lastMatchID) and (mainUI.savedLocally.lastMatchID == '0.000') then
			newPlayerExperienceCompleted()
		elseif (trigger_postGameLoopStatus) and (trigger_postGameLoopStatus.matchID == '0.000') then
			newPlayerExperienceCompleted()
		end

		if (GetProfileData) then
			GetProfileData(nil, true)
		end
		if (mainUI) and (mainUI.progression) and (mainUI.progression.UpdateProgression) then
			mainUI.progression.UpdateProgression()
		end

		mainUI.savedLocally.lastMatchID = nil
		PostGame.Rewards.claimRewardResponseData = nil

		SaveState()
	else
		-- println('^rPostGame.Close')
	end
end

function PostGame.Open()
	if (mainPanelStatus.main ~= 10) then
		println('^gPostGame.Open')
		mainPanelStatus.main = 10
		mainPanelStatus:Trigger(false)
		trigger_postGameLoopStatus:Trigger(true)
	else
		-- println('^rPostGame.Open')
	end
end

function PostGame.RequestClose()
	println('^gPostGame.RequestClose')
	if (PostGame.Splash) and (PostGame.Splash.animateSplashScreenThread) then
		PostGame.Splash.animateSplashScreenThread:kill()
		PostGame.Splash.animateSplashScreenThread = nil
	end
	if (PostGame.Khanquest) and (PostGame.Khanquest.animateSplashScreenThread) then
		PostGame.Khanquest.animateSplashScreenThread:kill()
		PostGame.Khanquest.animateSplashScreenThread = nil
	end	
	if (PostGame.Splash.splashUpdateDelayThread) then
		PostGame.Splash.splashUpdateDelayThread:kill()
		PostGame.Splash.splashUpdateDelayThread = nil
	end	
	local PostGameLoopStatus = LuaTrigger.GetTrigger('PostGameLoopStatus')
	PostGameLoopStatus.screen = ''
	PostGameLoopStatus.summaryAnimationActive = false
	PostGameLoopStatus.fastForwarding = false
	PostGameLoopStatus.khanquestAnimationActive = false
	PostGameLoopStatus.showPostGameLoop = false
	PostGameLoopStatus:Trigger(false)
	PostGame.Splash.animationDelayMultiplier = 0
	PostGame.Close()
end

local function isPostgameTest()
	return GetCvarBool('ui_testPostgame3')
end

local function allowTestSection(allowTest)
	if allowTest == nil then
		allowTest = false
	end

	return allowTest
end

--[[
	name			trigger_postGameLoopStatus.screen gets set to this when entering this section.
--]]


local postgameSections = {
	{
		name			= 'PENDING',
		isAvailable		= function()
			return (postgameRequestPending() or trigger_postGameLoopStatus.screen == '')
		end,
		availableForUpdate = function()
			return trigger_postGameLoopStatus.summaryAnimationActive
		end,		
		continueString	= Translate('general_wait'),
		actionOverride	= function()

		end
	},
	-- {
		-- name			= 'KHANQUEST',
		-- isAvailable		= function()
			-- return (trigger_postGameLoopStatus.isKhanquestMatch) and (not postgameRequestPending())
		-- end,
		-- availableForUpdate		= function()
			-- return (trigger_postGameLoopStatus.isKhanquestMatch)
		-- end,
		-- continueString	= Translate('postgame_to_khanquest')
	-- },	
	{
		name			= 'SUMMARY',
		isAvailable		= function()
			return (not trigger_postGameLoopStatus.summaryAnimationActive) and (not postgameRequestPending())
		end,
		availableForUpdate = function()
			return trigger_postGameLoopStatus.showPostGameLoop
		end,
		continueString	= Translate('postgame_to_progress')
	},
	{
		name			= 'SUMMARY_SKIP',	-- You never actually get to this "screen", but it can be available as the "next" screen.
		isAvailable		= function()
			return trigger_postGameLoopStatus.screen == 'SUMMARY' and trigger_postGameLoopStatus.summaryAnimationActive and (not trigger_postGameLoopStatus.fastForwarding)
		end,
		availableForUpdate		= function()
			return trigger_postGameLoopStatus.screen == 'SUMMARY' and trigger_postGameLoopStatus.summaryAnimationActive
		end,		
		continueString	= Translate('postgame_to_skip'),
		actionOverride	= function()
			trigger_postGameLoopStatus.fastForwarding = true
			trigger_postGameLoopStatus:Trigger(false)
			PostGame.Splash.animationDelayMultiplier = 0.08
			PostGame.UpdateContinueButton()
		end
	},
	-- {
		-- name			= 'REWARDS',
		-- isAvailable		= function()
			-- return false	-- (isPostgameTest() or (trigger_postGameLoopStatus.rewardsAvailable and trigger_postGameLoopStatus.rewardsClaimed)  and (not trigger_postGameLoopStatus.summaryAnimationActive))
		-- end,
		-- continueString	= Translate('postgame_to_rewards')
	-- },
	{
		name			= 'SCOREBOARD',
		isAvailable		= function()
			return ((isPostgameTest() or trigger_postGameLoopStatus.scoreboardAvailable) and (not trigger_postGameLoopStatus.summaryAnimationActive))
		end,
		availableForUpdate		= function()
			return ((isPostgameTest() or trigger_postGameLoopStatus.scoreboardAvailable))
		end,
		continueString	= Translate('postgame_to_scoreboard')
	},
	-- {
		-- name			= 'PROGRESS',
		-- isAvailable		= function()
			-- return false -- ((isPostgameTest() or (trigger_postGameLoopStatus.progressAvailable or trigger_postGameLoopStatus.unlocksAvailable))  and (not trigger_postGameLoopStatus.summaryAnimationActive))
		-- end,
		-- continueString	= Translate('postgame_to_progress')
	-- },
	{
		name			= 'CLOSE',	-- You'll never actually reach this screen - but it's a step you'll reach
		isAvailable		= function() return (not trigger_postGameLoopStatus.summaryAnimationActive) end,
		availableForUpdate		= function() return true end,
		continueString	= Translate('postgame_to_close'),
		actionOverride	= function()
			PostGame.Splash.animationDelayMultiplier = 0
			PostGame.RequestClose()
		end,
	},	
}

postgameSectionByName = {}

for k,v in ipairs(postgameSections) do
	postgameSectionByName[v.name] = v
end


function PostGame.GetFirstValidSection()
	local currentSection = trigger_postGameLoopStatus.screen

	for k,v in ipairs(postgameSections) do
		if v.isAvailable() or (v.availableForUpdate and type(v.availableForUpdate) == 'function' and v.availableForUpdate()) then
			return v
		end
	end
end

function PostGame.GetNextSection()
	local currentSection = trigger_postGameLoopStatus.screen

	if currentSection == '' then
		-- return postgameSections[1]
	else
		for k,v in ipairs(postgameSections) do
			if (currentSection == v.name) then
				for i=(k+1),#postgameSections,1 do
					if postgameSections[i].isAvailable() or (postgameSections[i].availableForUpdate and type(postgameSections[i].availableForUpdate) == 'function' and postgameSections[i].availableForUpdate()) then
						return postgameSections[i]
					end
				end
			end
		end
	end
end

function PostGame.UpdateContinueButton()
	-- println('^o PostGame.UpdateContinueButton()')

	local label				= GetWidget('post_game_loop_nav_continue_button_label_2')
	local nextSection		= PostGame.GetNextSection()

	if nextSection then
		label:SetText(nextSection.continueString or '')
		if nextSection.isAvailable() and (not postgameRequestPending()) then
			-- GetWidget('post_game_loop_nav_continue_button'):SetEnabled(1)
			GetWidget('post_game_loop_nav_continue_button'):SetNoClick(0)
		else
			-- GetWidget('post_game_loop_nav_continue_button'):SetEnabled(0)
			GetWidget('post_game_loop_nav_continue_button'):SetNoClick(1)
		end
	end
end

function PostGame.RequestContinue()
	-- println('^o PostGame.RequestContinue()')
	local nextSection = PostGame.GetNextSection()
	if nextSection and nextSection.isAvailable() then
		if nextSection.actionOverride and type(nextSection.actionOverride) == 'function' then
			nextSection.actionOverride()
		else
			PostGame.Splash.animationDelayMultiplier = 0
			PostGameLoopStatus.screen = nextSection.name
			PostGameLoopStatus:Trigger(false)
		end
	end

	return true
end

function PostGame.Update()
	local newSection = ""
	if trigger_postGameLoopStatus.screen == '' or trigger_postGameLoopStatus.screen == 'PENDING' then
		local showSection = PostGame.GetFirstValidSection()			
		
		GetWidget('postgame_summary'):SetCallback('onshow', function(widget)
			-- println('^y postgame_summary onshow')
			widget:ClearCallback('onshow')
			PostGame.Splash.PrepareSpashScreen()
		end)		
		
		if showSection then
			newSection = showSection.name
			trigger_postGameLoopStatus.screen = showSection.name
			trigger_postGameLoopStatus:Trigger(false)
		end
	end

	if (trigger_postGameLoopStatus.unlocksAvailable) or (trigger_postGameLoopStatus.awardsAvailable) or (trigger_postGameLoopStatus.progressAvailable) or (trigger_postGameLoopStatus.standardProgressAvailable) or (trigger_postGameLoopStatus.rankedProgressAvailable) or ((trigger_postGameLoopStatus.rewardsAvailable) and (trigger_postGameLoopStatus.rewardsClaimed))  then
		trigger_postGameLoopStatus.summaryAvailable = true
	end
	
	local function EnableButton(widgetName, condition, visible)
		if (visible) then
			GetWidget(widgetName):SetVisible(1)
			if condition then
				GetWidget(widgetName):SetEnabled(1)
				-- GetWidget(widgetName):SetVisible(1)
				GetWidget(widgetName .. '_texture'):SetRenderMode('normal')
				GetWidget(widgetName .. 'Label'):SetColor('white')
			else
				GetWidget(widgetName):SetEnabled(0)
				-- GetWidget(widgetName):SetVisible(0)
				GetWidget(widgetName .. '_texture'):SetRenderMode('grayscale')
				GetWidget(widgetName .. 'Label'):SetColor('.6 .6 .6 1')
			end
		else
			GetWidget(widgetName):SetVisible(0)
		end
	end

	local navTabs = { 'SUMMARY', 'SCOREBOARD'}
	local requestPending = postgameRequestPending()

	for k,v in ipairs(navTabs) do
		EnableButton(
			'post_game_loop_nav_tab_'..k, (
				(not requestPending) and postgameSectionByName[v].isAvailable()
			),
			postgameSectionByName[v].isAvailable() or (postgameSectionByName[v].availableForUpdate and type(postgameSectionByName[v].availableForUpdate) == 'function' and postgameSectionByName[v].availableForUpdate())
		)
	end

	if (requestPending) then
		GetWidget('post_game_loop_nav_continue_button_throb'):SetVisible(1)
	end
	
	if (trigger_postGameLoopStatus.showPostGameLoop) and (not Empty(trigger_postGameLoopStatus.screen)) then
		PostGame.Open()
	elseif (not requestPending) and (newSection == "") then
		PostGame.Close()
	else
		
	end

	trigger_postGameLoopBusyStatus.busy = false
	trigger_postGameLoopBusyStatus:Trigger(false)

	PostGame.UpdateContinueButton()
end

local function PostGameRegister(object)

	local post_game_loop_parent = GetWidget('post_game_loop_parent')

	trigger_postGameLoopStatus.screen							= ''
	trigger_postGameLoopStatus.matchID							= -1
	trigger_postGameLoopStatus.summaryAvailable 				= false
	trigger_postGameLoopStatus.unlocksAvailable 				= false
	trigger_postGameLoopStatus.awardsAvailable 					= false
	trigger_postGameLoopStatus.statsAvailable 					= false
	trigger_postGameLoopStatus.rewardsAvailable 				= false
	trigger_postGameLoopStatus.scoreboardAvailable 				= false
	trigger_postGameLoopStatus.progressAvailable 				= false
	trigger_postGameLoopStatus.rankedProgressAvailable 			= false
	trigger_postGameLoopStatus.standardProgressAvailable 		= false
	trigger_postGameLoopStatus.questsAvailable 					= false
	trigger_postGameLoopStatus.showPostGameLoop 				= false
	trigger_postGameLoopStatus.viaUnclaimed 					= false
	trigger_postGameLoopStatus.rewardsClaimed 					= false
	trigger_postGameLoopStatus.requestingClaimReward			= false
	trigger_postGameLoopStatus.requestingClaimQuestReward		= false
	trigger_postGameLoopStatus.isClaimingChest					= false
	trigger_postGameLoopStatus.requestingMatchStats				= false
	trigger_postGameLoopStatus.requestingRewardChests			= false
	trigger_postGameLoopStatus.requestingQuests					= false
	trigger_postGameLoopStatus.requestingAccountProgress		= false
	trigger_postGameLoopStatus.summaryAnimationActive			= false
	trigger_postGameLoopStatus.fastForwarding					= false
	trigger_postGameLoopStatus.khanquestAnimationActive			= false
	trigger_postGameLoopStatus.isKhanquestMatch					= false
	trigger_postGameLoopStatus.isFastForward					= false


	PostGame.Splash.modules = PostGame.Splash.modules or {}

	libGeneral.createGroupTrigger('endMatchDisplay', {
		'EndMatch.display',
		'LoginStatus.isLoggedIn',
		'LoginStatus.hasIdent',
		'LoginStatus.isIdentPopulated',
		'GameClientRequestsGetAllIdentGameData.status',
		'GameClientRequestsGetAllLoginData.status',
	})

	post_game_loop_parent:RegisterWatchLua('endMatchDisplay', function(widget, groupTrigger)
		local triggerEndMatch							= groupTrigger['EndMatch']
		local triggerLogin								= groupTrigger['LoginStatus']
		local gameClientRequestsGetAllIdentGameData 	= groupTrigger['GameClientRequestsGetAllIdentGameData']
		local gameClientRequestsGetAllLoginData 		= groupTrigger['GameClientRequestsGetAllLoginData']
		PostGame.Splash.modules = PostGame.Splash.modules or {}

		trigger_postGameLoopStatus.screen							= ''
		trigger_postGameLoopStatus.summaryAvailable 				= false
		trigger_postGameLoopStatus.unlocksAvailable 				= false
		trigger_postGameLoopStatus.awardsAvailable 					= false
		trigger_postGameLoopStatus.statsAvailable 					= false
		trigger_postGameLoopStatus.rewardsAvailable 				= false
		trigger_postGameLoopStatus.scoreboardAvailable 				= false
		trigger_postGameLoopStatus.progressAvailable 				= false
		-- trigger_postGameLoopStatus.rankedProgressAvailable 		= false	 -- These are requested asynchronously, do not override
		-- trigger_postGameLoopStatus.standardProgressAvailable 	= false	 -- These are requested asynchronously, do not override
		-- trigger_postGameLoopStatus.questsAvailable 				= false	 -- These are requested asynchronously, do not override
		trigger_postGameLoopStatus.showPostGameLoop 				= false
		trigger_postGameLoopStatus.rewardsClaimed 					= false
		trigger_postGameLoopStatus.isClaimingChest 					= false
		trigger_postGameLoopStatus.requestingClaimReward			= false
		trigger_postGameLoopStatus.requestingClaimQuestReward		= false
		trigger_postGameLoopStatus.requestingMatchStats				= false
		trigger_postGameLoopStatus.requestingRewardChests			= false
		trigger_postGameLoopStatus.requestingQuests					= false
		trigger_postGameLoopStatus.requestingAccountProgress		= false
		trigger_postGameLoopStatus.summaryAnimationActive			= false
		trigger_postGameLoopStatus.fastForwarding					= false
		trigger_postGameLoopStatus.khanquestAnimationActive			= false
		trigger_postGameLoopStatus.isKhanquestMatch					= false	-- will likely not be set here
		trigger_postGameLoopStatus.isFastForward					= false

		if (PostGame.Splash.animateSplashScreenThread) then
			PostGame.Splash.animateSplashScreenThread:kill()
			PostGame.Splash.animateSplashScreenThread = nil
		end

		local display		= triggerEndMatch.display
		-- println('^y endMatchDisplay ' .. tostring(display))

		local mainPanelStatus = LuaTrigger.GetTrigger('mainPanelStatus')
		local LeaverBan	= LuaTrigger.GetTrigger('LeaverBan')
		
		-- println("display " .. tostring(display) )
		-- if (mainUI) and (mainUI.savedLocally) and (mainUI.savedLocally.lastMatchID) then
			-- println("mainUI.savedLocally.lastMatchID " .. tostring(mainUI.savedLocally.lastMatchID) )
		-- end
		-- println("triggerLogin.isLoggedIn " .. tostring(triggerLogin.isLoggedIn) )
		-- println("triggerLogin.hasIdent " .. tostring(triggerLogin.hasIdent) )
		-- println("triggerLogin.isIdentPopulated " .. tostring(triggerLogin.isIdentPopulated) )
		-- println("gameClientRequestsGetAllLoginData.status " .. tostring(gameClientRequestsGetAllLoginData.status) )
		-- println("gameClientRequestsGetAllIdentGameData.status " .. tostring(gameClientRequestsGetAllIdentGameData.status) )
		
		if (mainPanelStatus.missedGameAddress and (not Empty(mainPanelStatus.missedGameAddress))) and (LuaTrigger.GetTrigger('ChatMissedGame').isRewarding) and (not LuaTrigger.GetTrigger('mainPanelStatus').leftLastGame) then	-- game started without you
			println('^y endMatchDisplay ignored because missed game')
			trigger_postGameLoopStatus.showPostGameLoop = false
		elseif (mainPanelStatus.reconnectShow and mainPanelStatus.reconnectAddress and (not Empty(mainPanelStatus.reconnectAddress)) and mainPanelStatus.reconnectType and (not Empty(mainPanelStatus.reconnectType)) ) and  (LuaTrigger.GetTrigger('ReconnectInfo').isRewarding) and (not LuaTrigger.GetTrigger('mainPanelStatus').leftLastGame) then	-- you left a game, it's still going
			println('^y endMatchDisplay ignored because reconnect available')
			trigger_postGameLoopStatus.showPostGameLoop = false
		elseif (mainPanelStatus.updaterState == 1) and (triggerLogin.isLoggedIn) and (triggerLogin.hasIdent) then
			println('^y endMatchDisplay ignored because update available')
			trigger_postGameLoopStatus.showPostGameLoop = false
		elseif (LeaverBan) and (LeaverBan.bannedUntil) and (LeaverBan.bannedUntil > 0) and (LeaverBan.now) and (LeaverBan.bannedUntil > LeaverBan.now) then
			println('^y endMatchDisplay ignored because leaver banned')
			trigger_postGameLoopStatus.showPostGameLoop = false
		elseif ((display or ((mainUI) and (mainUI.savedLocally) and (mainUI.savedLocally.lastMatchID) and (tonumber(mainUI.savedLocally.lastMatchID) >= 0))) and triggerLogin.isLoggedIn and triggerLogin.hasIdent and triggerLogin.isIdentPopulated and (gameClientRequestsGetAllLoginData.status ~= 1) and (gameClientRequestsGetAllIdentGameData.status ~= 1)) then
			
			println('^g endMatchDisplay Fired - Unregistering endMatchDisplay')
			
			post_game_loop_parent:UnregisterWatchLua('endMatchDisplay')
			trigger_postGameLoopStatus.showPostGameLoop = true

			trigger_postGameLoopBusyStatus.busy = true
			trigger_postGameLoopBusyStatus:Trigger(false)

			local matchStatsTable, rewardsChestsTable
			local showSomething = false

			local incMatchID
			if (mainUI.savedLocally) and (mainUI.savedLocally.lastMatchID) and (tonumber(mainUI.savedLocally.lastMatchID) >= 0) then
				incMatchID = mainUI.savedLocally.lastMatchID
				mainUI.savedLocally.lastMatchID = nil
				SaveState()
				println('EndMatch MatchID LuaDB: ' .. tostring(incMatchID))
			elseif (trigger_postGameLoopStatus.matchID) and (tonumber(trigger_postGameLoopStatus.matchID) >= 0) then
				incMatchID = trigger_postGameLoopStatus.matchID
				trigger_postGameLoopStatus.matchID = -1
				println('EndMatch MatchID UI: ' .. tostring(incMatchID))
			else
				incMatchID = GetMatchID()
				println('EndMatch MatchID Server: ' .. tostring(incMatchID))
			end

			trigger_postGameLoopStatus.matchID = incMatchID

			if (tonumber(incMatchID) and (tonumber(incMatchID) >= 0) and (tonumber(incMatchID) <= 4000000)) then -- (not trigger.isPractice) or
				println('Was A Real Game: ' .. tostring(incMatchID))

				PostGame.GetMatchStats(incMatchID)
			else
				println('Was A Practice Game')

				downVoteMatchID = nil

				matchStatsTable = {}
				matchStatsTable.matchStats = {}
				matchStatsTable.matchStats.stats = {}

				local localMatchStatsTable = EndMatch.GetLocalStats()

				if (localMatchStatsTable) then
					for index,statTable in pairs(localMatchStatsTable) do
						matchStatsTable.matchStats.stats[index]										= statTable
						matchStatsTable.matchStats.stats[index].matchmakingHeroStats				= {}
						matchStatsTable.matchStats.stats[index].matchmakingHeroStats.entityName		= statTable.hero
						matchStatsTable.matchStats.stats[index].matchmakingFamiliarStats			= {}
						matchStatsTable.matchStats.stats[index].matchmakingFamiliarStats.entityName = statTable.familiar
						matchStatsTable.matchStats.stats[index].nickname							= statTable.name
					end

					rewardsChestsTable = nil

					if (matchStatsTable) then
						showSomething = true
						PostGame.Scoreboard.PopulateScoreboard(object, matchStatsTable)
					else
						SevereError('End Match triggered without any data', 'main_reconnect_thatsucks', '', nil, nil, false)
					end
				else
					SevereError('End Match triggered without any local data', 'main_reconnect_thatsucks', '', nil, nil, false)
				end
			end

			PostGame.Rewards.CheckAccountRewards()

		else
			println('^y endMatchDisplay no valid event')
			trigger_postGameLoopStatus.showPostGameLoop = false
		end
		trigger_postGameLoopStatus:Trigger(false)
	end)

	function PostGame.Rewards.CheckAccountRewards()
		if (AccountProgression.newExperience > 0) or (GetCvarBool('ui_testPostgame7')) then
			if (AccountProgression.newLevelUp) then
				if (GOT_REWARDS_AT_THIS_LEVEL or true) then
					trigger_postGameLoopStatus.unlocksAvailable 	= true
					trigger_postGameLoopStatus.progressAvailable	 	= true
					trigger_postGameLoopStatus:Trigger(false)
				end
			end
		end
	end

	function PostGame.GetMatchStats(incMatchID)
		println('^yPostGame.GetMatchStats')

		downVoteMatchID 	= 	incMatchID
		upVoteMatchID 		= 	incMatchID

		if incMatchID ~= '0.000' then	-- from finishing tutorial3, you get an unclaimed reward entry
			-- =========== MATCH STATS
			local function successFunction(request)	-- response handler
				local responseData = request:GetBody()
				if responseData == nil or responseData.matchStats == nil or responseData.matchStats.stats == nil then
					SevereError('GetMatchStatsLite No Match Stats in EndMatch data', 'main_reconnect_thatsucks', '', nil, nil, false)
					trigger_postGameLoopStatus.statsAvailable  = false
					trigger_postGameLoopStatus.requestingMatchStats = false
					trigger_postGameLoopStatus:Trigger(false)
					return nil
				else
					if (responseData.matchStats) and (responseData.matchStats.stats) and (responseData.matchStats.stats[GetIdentID()]) and GetCvarBool('ui_matchTypeIsTotesKhanquest') then
						responseData.matchStats.stats[GetIdentID()].matchType = 'khanquest'
						postGame_khanquestRandomCache()						
					end
					
					PostGame.Scoreboard.PopulateScoreboard(object, responseData)
					if (Rewards.RemoveReward) then
						Rewards.RemoveReward(incMatchID) -- Code function
					end
					trigger_postGameLoopStatus.statsAvailable  = true
					trigger_postGameLoopStatus.requestingMatchStats = false

					if responseData.matchStats.stats[GetIdentID()] and responseData.matchStats.stats[GetIdentID()].matchType then
						trigger_postGameLoopStatus.isKhanquestMatch = (responseData.matchStats.stats[GetIdentID()].matchType == 'khanquest')
					else
						trigger_postGameLoopStatus.isKhanquestMatch = false
					end

					postGame_khanquestProcessPlayers(responseData.matchStats.stats)
					trigger_postGameLoopStatus:Trigger(false)
					
					println('^gPostGame.GetMatchStats')
					
					return true
				end
			end

			local function failureFunction(request)	-- error handler
				SevereError('GetMatchStatsLite Request Error: ' .. Translate(request:GetError() or ''), 'main_reconnect_thatsucks', '', nil, nil, false)
				trigger_postGameLoopStatus.statsAvailable  = false
				trigger_postGameLoopStatus.requestingMatchStats = false
				trigger_postGameLoopStatus:Trigger(false)
				return nil
			end

			trigger_postGameLoopStatus.requestingMatchStats = true
			trigger_postGameLoopStatus:Trigger(false)
			matchStatsTable 	= Strife_Web_Requests:GetMatchStatsLite(incMatchID, successFunction, failureFunction)
		end

		if ((mainUI.featureMaintenance) and (mainUI.featureMaintenance['rewards'])) then
			return
		end

		-- =========== REWARDS AND QUESTS
		local function successFunction2(request)	-- response handler
			local responseData = request:GetBody()
			if responseData == nil then
				SevereError('GetRewardChests no data ', 'main_reconnect_thatsucks', '', nil, nil, false)
				trigger_postGameLoopStatus.rewardsAvailable  = false
				trigger_postGameLoopStatus.requestingRewardChests = false
				trigger_postGameLoopStatus.requestingQuests = false
				trigger_postGameLoopStatus:Trigger(false)
				return nil
			else
				PostGame.Rewards.PopulateRewards(interface, responseData)
				
				trigger_postGameLoopStatus.requestingRewardChests = false
				trigger_postGameLoopStatus.requestingQuests = false
				trigger_postGameLoopStatus:Trigger(false)
				return true
			end
		end

		local function failureFunction2(request)	-- error handler
			SevereError('GetRewardChests Request Error: ' .. Translate(request:GetError() or ''), 'main_reconnect_thatsucks', '', nil, nil, false)
			trigger_postGameLoopStatus.rewardsAvailable  = false
			trigger_postGameLoopStatus.requestingRewardChests = false
			trigger_postGameLoopStatus.requestingQuests = false
			trigger_postGameLoopStatus:Trigger(false)
			return nil
		end

		PostGame.Rewards.lastGetRewardChestsMatchID = incMatchID
		trigger_postGameLoopStatus.requestingRewardChests = true
		trigger_postGameLoopStatus.requestingQuests = true
		trigger_postGameLoopStatus:Trigger(false)
		rewardsChestsTable  = Strife_Web_Requests:GetRewardChests(incMatchID,successFunction2, failureFunction2)
	end

end

PostGameRegister(object)
