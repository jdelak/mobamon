-- Custom Triggers that need to be accessed globally

local defaultTriggerValues = {}

-- Resets a trigger to it's default
function resetTrigger(trigger)
	newParams = table.copy(defaultTriggerValues[trigger]) -- get defaults
	local trigger = LuaTrigger.GetTrigger(trigger)
	for k,v in pairs(newParams) do -- apply args to trigger
		trigger[tostring(k)] = v
	end
end

-- Triggers a LuaTrigger given a an array of (name and an array of values), as an alternative to the default.
--[[e.g
setMainTriggers({
	mainBackground = {wheelX='-250s', logoSlide=false, navBackingVisible=false},
	mainNavigation = {visible=false }
})
]]
function setMainTriggers(triggerTable, notFromDefault)
	for triggerName, defaults in pairs(defaultTriggerValues) do
		local newParams = {}
		newParams = table.copy(defaults) -- get defaults
		local params = triggerTable[triggerName] or {}
		for k,v in pairs(params) do -- parse overriding args
			newParams[tostring(k)] = v
		end
		local trigger = LuaTrigger.GetTrigger(triggerName)
		for k,v in pairs(newParams) do -- apply args to trigger
			trigger[tostring(k)] = v
		end
		trigger:Trigger() -- fire trigger
	end
end

-- Background
if LuaTrigger.GetTrigger('mainBackground') then
	LuaTrigger.DestroyCustomTrigger('mainBackground')
end
LuaTrigger.CreateCustomTrigger('mainBackground',
	{
		{ name	= 'visible',							type	= 'boolean' },
		{ name	= 'blackTop',							type	= 'boolean' },
		{ name	= 'navBackingVisible',					type	= 'boolean' },
		{ name	= 'logoVisible',						type	= 'boolean' },
		{ name	= 'logoX',								type	= 'string' },
		{ name	= 'logoY',								type	= 'string' },
		{ name	= 'logoWidth',							type	= 'string' },
		{ name	= 'logoHeight',							type	= 'string' },
		{ name	= 'logoSlide',							type	= 'boolean' },
		{ name	= 'shadowVisible',						type	= 'boolean' },
		{ name	= 'wheelX',								type	= 'string' },
		{ name	= 'wheelWidth',							type	= 'string' },
		{ name	= 'wheelHeight',						type	= 'string' },
		{ name	= 'wheelAngleX',						type	= 'string' },
		{ name	= 'wheelAngleY',						type	= 'string' },
		{ name	= 'wheelAngleZ',						type	= 'string' },
	}
)
defaultTriggerValues['mainBackground'] = {
	visible			= true, 
	blackTop		 = false,
	navBackingVisible = true,
	logoVisible		= true, 
	logoX			= '1063s',
	logoY			= '8s',
	logoWidth		= '170s',
	logoHeight		= '85s',
	logoSlide		= true,
	shadowVisible	= true,
	wheelX			= '600s',
	wheelWidth		= '900s',
	wheelHeight		= '900s',
	wheelAngleX		= '0',
	wheelAngleY		= '0',
	wheelAngleZ		= '0',
}

-- Navigation
if LuaTrigger.GetTrigger('mainNavigation') then
	LuaTrigger.DestroyCustomTrigger('mainNavigation')
end
LuaTrigger.CreateCustomTrigger('mainNavigation',
	{
		{ name	= 'visible',							type	= 'boolean' },
		{ name	= 'enabled',							type	= 'boolean' },
		{ name	= 'breadCrumbsVisible',					type	= 'boolean' },
	}
)
defaultTriggerValues['mainNavigation'] = {
	visible				= true,
	enabled				= true,
	breadCrumbsVisible 	= false,
}

-- Navigation Overlay Statuses
trigger_clanFinderUpdate =  trigger_clanFinderUpdate or LuaTrigger.CreateCustomTrigger('clanFinderUpdate',
	{
		{ name	= 'update',						type	= 'bool' },
	}
)
trigger_clanFinderUpdate.update = false

-- Navigation Overlay Statuses
trigger_mainOverlayStatus =  trigger_mainOverlayStatus or LuaTrigger.CreateCustomTrigger('mainOverlayStatus',
	{
		{ name	= 'currentOverlay',						type	= 'string' },
	}
)
trigger_mainOverlayStatus.currentOverlay = 'none'

trigger_mainOverlayAnimationStatus = trigger_mainOverlayAnimationStatus or LuaTrigger.CreateCustomTrigger('mainOverlayAnimationStatus',
	{
		{ name	= 'overlay',							type	= 'string' },
		{ name	= 'lastOverlay',						type	= 'string' },
		{ name	= 'newOverlay',							type	= 'string' },
		{ name	= 'timeOfMainChange',					type	= 'number' },
		{ name	= 'timeSinceMainChange',				type	= 'number' },
	}
)
trigger_mainOverlayAnimationStatus.overlay = 'none'
trigger_mainOverlayAnimationStatus.lastOverlay = 'none'
trigger_mainOverlayAnimationStatus.newOverlay = ''

-- Shop
if LuaTrigger.GetTrigger('mainShop') then
	LuaTrigger.DestroyCustomTrigger('mainShop')
end
LuaTrigger.CreateCustomTrigger('mainShop',
	{
		{ name	= 'visible',							type	= 'boolean' },
		{ name	= 'bookmarksVisible',					type	= 'boolean' },
		{ name	= 'exclusions',							type	= 'string' },
		{ name	= 'title',								type	= 'string' },
		{ name	= 'y',									type	= 'string' },
		{ name	= 'valign',								type	= 'string' },
		{ name	= 'mode',								type	= 'number' }, -- 0 normal, 1, builds, 2, crafting
	}
)
defaultTriggerValues['mainShop'] = {
	visible				= false,
	bookmarksVisible	= false,
	exclusions			= "",
	title				= "",
	y					= "-36s",
	valign				= "bottom",
	mode				= "2", -- should be 0 when crafting adopts this trigger
}

-- Build Editor
if LuaTrigger.GetTrigger('mainBuildEditor') then
	LuaTrigger.DestroyCustomTrigger('mainBuildEditor')
end
LuaTrigger.CreateCustomTrigger('mainBuildEditor',
	{
		{ name	= 'visible',							type	= 'boolean' },
		{ name	= 'buildHero',							type	= 'number' },
		{ name	= 'buildHeroEntity',					type	= 'string' },
		{ name	= 'buildNumber',						type	= 'number' },
	}
)
defaultTriggerValues['mainBuildEditor'] = {
	visible				= false,
	--buildHero			= -1,		-- Don't reset this
	--buildHeroEntity		= '',	-- Don't reset this
	--buildNumber		= -1,		-- Don't reset this
}

-- Non-defaulting triggers
LuaTrigger.CreateCustomTrigger('regionSelectClosed',{})
LuaTrigger.CreateCustomTrigger('regionSelectLoaded',{})

LuaTrigger.CreateCustomTrigger('loadComplete',{})


-- Build Browser
LuaTrigger.CreateCustomTrigger('mainBuildBrowser',
	{
		{ name	= 'visible',							type	= 'boolean' },
		{ name	= 'hero',								type	= 'number' },
	}
)

DatabaseLoadStateTrigger = DatabaseLoadStateTrigger or LuaTrigger.CreateCustomTrigger(
	'DatabaseLoadStateTrigger',
	{
		{ name	= 'stateLoaded',	type	= 'boolean' }
	}
)	
DatabaseLoadStateTrigger.stateLoaded = false

LuaTrigger.CreateGroupTrigger('DatabaseLoadStateGroupTrigger', {
	'DatabaseLoadStateTrigger',
	'mainPanelStatus',
})

LuaTrigger.CreateCustomTrigger('globalDragInfo',	-- Part of a centralized draggable object concept
	{
		{ name	= 'overDraggable',	type	= 'boolean' },
		{ name	= 'active',			type	= 'boolean' },
		{ name	= 'type',			type	= 'number' }
	}
)

MultiWindowDragInfo = LuaTrigger.CreateCustomTrigger('MultiWindowDragInfo',	-- Part of a centralized draggable object concept
	{
		{ name	= 'active',			type	= 'boolean' },
		{ name	= 'type',			type	= 'string' }
	}
)

LuaTrigger.CreateCustomTrigger('featureMaintenanceTrigger',
	{
		{ name	= 'update',						type	= 'boolean' },
	}
)

local wheelTrigger = LuaTrigger.GetTrigger('wheelTrigger') or LuaTrigger.CreateCustomTrigger('wheelTrigger',
	{
		{ name	= 'wheelSpinAvailable',				type	= 'bool' },
		{ name	= 'wheelSpinAvailableFree',			type	= 'bool' },
		{ name	= 'hasWheelData',					type	= 'bool' },
		{ name	= 'wheelClosed',					type	= 'bool' },
		{ name	= 'lastWheel',						type	= 'number' },
	}
)

local accountBoostInfoTrigger = LuaTrigger.GetTrigger('AccountBoostInfoTrigger') or LuaTrigger.CreateCustomTrigger('AccountBoostInfoTrigger',
	{
		{ name	= 'hasPermanentXPBoost',					type	= 'boolean' },
		{ name	= 'hasTemporaryXPBoost',					type	= 'boolean' },
		{ name	= 'hasTemporaryCommodityBoost',				type	= 'boolean' },
		{ name	= 'hasTemporaryPetBoost',					type	= 'boolean' },
	}
)

accountBoostInfoTrigger.hasPermanentXPBoost 			= false
accountBoostInfoTrigger.hasTemporaryXPBoost 			= false
accountBoostInfoTrigger.hasTemporaryCommodityBoost 		= false
accountBoostInfoTrigger.hasTemporaryPetBoost 			= false
accountBoostInfoTrigger:Trigger(false)

--[[
	.main:
		0	Not logged in
		1	Crafting
		2	Pets/Corral
		3	Heroes
		4	Match Finder
		5	Enchanting (10/7/2013)
		6	Crafted Item Inventory
		7	Crafted Item Reroll Bonus
		8	Create Game
		9	Heroes -Loading-
		10	End Match Stats/Quests  - section 1
		11	End Match Rewards       - section 2
		12  Lobby (GamePhase 1)
		13  End Match       		- section 0
		21	Group Profile
		22	Group Finder
		23	Player Profile
		24	Match Finder (Game List)
		25  Options
		26  Options New
		27  Twitch Stream List
		28  Watch Strife
		29	Select Game Mode (big play thing)

		31	Quests
		32	NewsFeed
		33	Replay Finder / Stats
		34	Wheel of Strife
		35  Scrim Finder

		40  Pre match hero selection

		50 Create Account

		60 NPE

		100	Loading Transition
		101	Logged In
		103 Logged in but tos not signed
		1001 Demo UI

	.mainMoreVisible
		true/false, whether you're expanding out main options to view ("draggables, vertical, horizontal"?)
	.aspect
		actual ratio between screen width/height - stuff will just look for a number they're comfortable with so we have fine control over this
			16:9		1.777777777777778
			16:10		1.6
			4:3			1.333333333333333
			5:4			1.25
	.socialUserListToggled
		true/false, whether the friends list/social panel (right side) is toggled on
	.socialUserListVisible
		true/false, whether the friends list/social panel (right side) would be forced to be visible because there's plenty of extra space at the res
--]]


trigger_mainPanelStatus = LuaTrigger.CreateCustomTrigger('mainPanelStatus',
	{
		{ name	= 'main',							type	= 'number' },
		{ name	= 'mainMoreVisible',				type	= 'boolean' },
		{ name	= 'aspect',							type	= 'number' },
		{ name	= 'socialUserListToggled',			type	= 'boolean' },
		{ name	= 'socialUserListVisible',			type	= 'boolean' },
		{ name	= 'selectedUserIdentID',			type	= 'string' },
		{ name	= 'activityFeedVisible',			type	= 'boolean' },
		{ name	= 'myGroupsVisible',				type	= 'boolean' },
		{ name	= 'useCompetitiveHeroSelect',		type	= 'boolean' },
		{ name	= 'sliderAdSelected',				type	= 'number' },
		{ name	= 'sliderAdLastTime',				type	= 'number' },
		{ name	= 'sliderAdLastSelected',			type	= 'number' },
		{ name	= 'isLoggedIn',						type	= 'boolean' },		-- LoginStatus
		{ name	= 'externalLogin',					type	= 'boolean' },		-- LoginStatus
		{ name	= 'hasIdent',						type	= 'boolean' },		-- LoginStatus
		{ name	= 'isAutoLogin',					type	= 'boolean' },		-- LoginStatus
		{ name	= 'loginChange',					type	= 'boolean' },		-- LoginStatus
		{ name	= 'gamePhase',						type	= 'number' },		-- GamePhase
		{ name	= 'chatConnected',					type	= 'boolean' },		-- ChatConnected, ChatDisconnect
		{ name	= 'isReady',						type	= 'boolean' },		-- HeroSelectLocalPlayerInfo
		{ name	= 'initialPetPicked',				type	= 'boolean' },		-- Corral
		{ name	= 'animationState',					type	= 'number' },
		{ name	= 'getPetDataState',				type	= 'number' },
		{ name	= 'getEnchantItemsState',			type	= 'number' },
		{ name	= 'chatConnectionState',			type	= 'number' },
		{ name	= 'updaterState',					type	= 'number' },
		{ name	= 'getAllIdentGameDataStatus',		type	= 'number' },
		{ name	= 'inQueue',						type	= 'boolean' },
		{ name	= 'inParty',						type	= 'boolean' },
		{ name 	= 'numPlayersInParty',				type	= 'number' },
		{ name	= 'entityDefinitionsState',			type	= 'number' },
		{ name 	= 'reconnectAddress',				type	= 'string' },
		{ name 	= 'reconnectType',					type	= 'string' },
		{ name 	= 'reconnectShow',					type	= 'boolean' },
		{ name 	= 'missedGameAddress',				type	= 'string' },
		{ name 	= 'launcherMusicEnabled',			type	= 'boolean' },
		{ name 	= 'isRewarding',					type	= 'boolean' },
		{ name 	= 'leftLastGame',					type	= 'boolean' },
		{ name 	= 'hideSecondaryElements',			type	= 'boolean' },
	}
)

ProgressionLoadStateTrigger = ProgressionLoadStateTrigger or LuaTrigger.CreateCustomTrigger(
	'ProgressionLoadStateTrigger',
	{
		{ name	= 'stateLoaded',	type	= 'boolean' }
	}
)	
ProgressionLoadStateTrigger.stateLoaded = false

trigger_postGameLoopStatus = LuaTrigger.CreateCustomTrigger('PostGameLoopStatus',
	{
		{ name	= 'showPostGameLoop',				type	= 'boolean' },
		{ name	= 'viaUnclaimed',					type	= 'boolean' },
		{ name	= 'screen',							type	= 'string' },
		{ name	= 'rewardsAvailable',				type	= 'boolean' },
		{ name	= 'rewardsClaimed',					type	= 'boolean' },
		{ name	= 'scoreboardAvailable',			type	= 'boolean' },
		{ name	= 'unlocksAvailable',				type	= 'boolean' },
		{ name	= 'summaryAvailable',				type	= 'boolean' },
		{ name	= 'awardsAvailable',				type	= 'boolean' },
		{ name	= 'progressAvailable',				type	= 'boolean' },
		{ name	= 'questsAvailable',				type	= 'boolean' },
		{ name	= 'isClaimingChest',				type	= 'boolean' },
		{ name	= 'statsAvailable',					type	= 'boolean' },
		{ name	= 'requestingClaimReward',			type	= 'boolean' },
		{ name	= 'requestingClaimQuestReward',		type	= 'boolean' },
		{ name	= 'requestingMatchStats',			type	= 'boolean' },
		{ name	= 'requestingRewardChests',			type	= 'boolean' },
		{ name	= 'requestingQuests',				type	= 'boolean' },
		{ name	= 'requestingAccountProgress',		type	= 'boolean' },
		{ name	= 'summaryAnimationActive',			type	= 'boolean' },
		{ name	= 'khanquestAnimationActive',		type	= 'boolean' },
		{ name	= 'fastForwarding',					type	= 'boolean' },
		{ name	= 'isKhanquestMatch',				type	= 'boolean' },
		{ name	= 'rankedProgressAvailable',		type	= 'boolean' },
		{ name	= 'standardProgressAvailable',		type	= 'boolean' },
		{ name	= 'fastForward',					type	= 'boolean' },	-- Will be using this at some point

		{ name	= 'matchID',						type	= 'string' },
	}
)
trigger_postGameLoopStatus.screen							= ''
trigger_postGameLoopStatus.matchID							= -1
trigger_postGameLoopStatus.summaryAvailable 				= false
trigger_postGameLoopStatus.unlocksAvailable 				= false
trigger_postGameLoopStatus.awardsAvailable 					= false
trigger_postGameLoopStatus.rewardsAvailable 				= false
trigger_postGameLoopStatus.statsAvailable 					= false
trigger_postGameLoopStatus.scoreboardAvailable 				= false
trigger_postGameLoopStatus.progressAvailable 				= false
trigger_postGameLoopStatus.questsAvailable 					= false
trigger_postGameLoopStatus.showPostGameLoop 				= false
trigger_postGameLoopStatus.viaUnclaimed 					= false
trigger_postGameLoopStatus.rewardsClaimed 					= false
trigger_postGameLoopStatus.requestingClaimReward			= false
trigger_postGameLoopStatus.requestingClaimQuestReward		= false
trigger_postGameLoopStatus.requestingMatchStats				= false
trigger_postGameLoopStatus.requestingRewardChests			= false
trigger_postGameLoopStatus.requestingQuests					= false
trigger_postGameLoopStatus.requestingAccountProgress		= false
trigger_postGameLoopStatus.summaryAnimationActive			= false
trigger_postGameLoopStatus.isKhanquestMatch					= false
trigger_postGameLoopStatus.fastForward						= false

trigger_postGameLoopBusyStatus = LuaTrigger.CreateCustomTrigger('PostGameLoopBusyStatus',
	{
		{ name	= 'busy',							type	= 'boolean' },
	}
)
trigger_postGameLoopBusyStatus.busy 							= false

local PostGameGroupTrigger = LuaTrigger.GetTrigger('PostGameGroupTrigger') or libGeneral.createGroupTrigger('PostGameGroupTrigger', {
	'mainPanelStatus.main',
	'PostGameLoopStatus.screen',
})

local FriendStatusTriggerUI = LuaTrigger.GetTrigger('FriendStatusTriggerUI') or LuaTrigger.CreateCustomTrigger('FriendStatusTriggerUI', {
		{ name	=   'friendMultiWindowOpen',						type	= 'boolean'},	
		{ name	=   'friendLauncherWindowOpen',						type	= 'boolean'},	
		{ name	=   'friendLastUsedMethod',							type	= 'string'},	
	}
)

trigger_corralSelectedPet = LuaTrigger.CreateCustomTrigger('CorralSelectedPet',
	{
		{ name	= 'petFruitCost',							type	= 'number' },
		{ name	= 'petGemCost',								type	= 'number' },
		{ name	= 'fruit',									type	= 'number' },
		{ name	= 'initialPetPicked',						type	= 'boolean' },
		{ name	= 'canPurchasePet',							type	= 'boolean' },
	}
)
trigger_corralSelectedPet.petFruitCost 	= -1
trigger_corralSelectedPet.petGemCost 	= -1
trigger_corralSelectedPet.fruit 		= -1
trigger_corralSelectedPet.initialPetPicked 	= false
trigger_corralSelectedPet.canPurchasePet 	= false

local trigger_UILeaverBan = LuaTrigger.CreateCustomTrigger('UILeaverBan',
	{
		{ name	= 'bannedUntil',							type	= 'number' },
		{ name	= 'now',									type	= 'number' },
		{ name	= 'remainingBanSeconds',					type	= 'number' },
	}
)
trigger_UILeaverBan.bannedUntil 			= 0
trigger_UILeaverBan.now 					= 0
trigger_UILeaverBan.remainingBanSeconds 	= 0

function TestUILeaverBan()

	local system = LuaTrigger.GetTrigger('System')
	local now = tonumber(system.unixTimestamp)

	trigger_UILeaverBan.bannedUntil 				= (now + (60 * 2))
	trigger_UILeaverBan.now 						= (now)
	trigger_UILeaverBan.remainingBanSeconds 		= trigger_UILeaverBan.bannedUntil - trigger_UILeaverBan.now
	trigger_UILeaverBan:Trigger(false)

	UnwatchLuaTriggerByKey('CountDownSeconds', 'UILeaverBanCountdownKey')
	WatchLuaTrigger('CountDownSeconds', function(countDownTrigger)
		trigger_UILeaverBan.remainingBanSeconds = trigger_UILeaverBan.remainingBanSeconds - 1
		trigger_UILeaverBan:Trigger(false)
	end, 'UILeaverBanCountdownKey', 'timeSeconds')

end

UnwatchLuaTriggerByKey('LeaverBan', 'UILeaverBanKey')
WatchLuaTrigger('LeaverBan', function(trigger)
	if (trigger.bannedUntil) and (trigger.now) and (trigger.now > 0) and (trigger.bannedUntil > 0) and (trigger.bannedUntil > trigger.now) then
		trigger_UILeaverBan.bannedUntil 				= trigger.bannedUntil
		trigger_UILeaverBan.now 						= trigger.now
		trigger_UILeaverBan.remainingBanSeconds 		= trigger.bannedUntil - trigger.now
		trigger_UILeaverBan:Trigger(false)

		UnwatchLuaTriggerByKey('CountDownSeconds', 'UILeaverBanCountdownKey')
		WatchLuaTrigger('CountDownSeconds', function(countDownTrigger)
			trigger_UILeaverBan.remainingBanSeconds = trigger_UILeaverBan.remainingBanSeconds - 1
			trigger_UILeaverBan:Trigger(false)
		end, 'UILeaverBanCountdownKey', 'timeSeconds')
	else
		UnwatchLuaTriggerByKey('CountDownSeconds', 'UILeaverBanCountdownKey')
	end
end, 'UILeaverBanKey', 'bannedUntil', 'now')

local mainBGMouseEvent = LuaTrigger.GetTrigger('MainBGMouseEvent') or LuaTrigger.CreateCustomTrigger('MainBGMouseEvent',
	{
		{ name	= 'onmouseover',	type	= 'boolean' },
		{ name	= 'onmouseout',		type	= 'boolean' },
	}
)

trigger_mainPanelAnimationStatus = LuaTrigger.CreateCustomTrigger('mainPanelAnimationStatus',
	{
		{ name	= 'main',							type	= 'number' },
		{ name	= 'lastMain',						type	= 'number' },
		{ name	= 'newMain',						type	= 'number' },
		{ name	= 'timeSinceMainChange',			type	= 'number' },
		{ name	= 'timeOfMainChange',				type	= 'number' },
		{ name	= 'gamePhase',						type	= 'number' },
		{ name	= 'newGamePhase',					type	= 'number' },
		{ name	= 'inQueue',						type	= 'boolean' },
		{ name	= 'inParty',						type	= 'boolean' },
		{ name	= 'isLoggedIn',						type	= 'boolean' },		-- LoginStatus
		{ name	= 'hasIdent',						type	= 'boolean' },		-- LoginStatus
		{ name	= 'loginChange',					type	= 'boolean' },		-- LoginStatus
	}
)

trigger_mainPanelAnimationStatus.newMain = -1
trigger_mainPanelAnimationStatus.newGamePhase = -1

-- ======

local triggerStatus = LuaTrigger.CreateCustomTrigger('selection_Status',
	{
		{ name	= 'selectedBuild',			type	= 'number' },
		{ name	= 'enableAutoBuild',		type	= 'boolean' },
		{ name	= 'enableAutoAbilities',	type	= 'boolean' },
		{ name	= 'blockGearHover',			type	= 'boolean' },
		{ name	= 'selectionStatus',		type	= 'number' },
		{ name	= 'selectedPet',			type	= 'number' },
		{ name	= 'selectedHero',			type	= 'number' },
		{ name	= 'purchasingGear',			type	= 'number' },
		{ name	= 'hoveringPet',			type	= 'number' },
		{ name	= 'stickyHoveringPet',		type	= 'number' },
		{ name	= 'hoveringHero',			type	= 'number' },
		{ name	= 'stickyHoveringHero',		type	= 'number' },
		{ name	= 'recommendedHero',		type	= 'number' },
		{ name	= 'recommendedRole',		type	= 'string' },
		{ name	= 'selectedGear',			type	= 'number' },
		{ name	= 'selectedGearOwned',		type	= 'number' },
		{ name	= 'hoveringPetSkinIndex',	type	= 'number' },
		{ name	= 'selectedPetSkin',		type	= 'string' },
		{ name	= 'selectedPetSkinIndex',	type	= 'number' },
		{ name	= 'selectedPetSkinOwned',	type	= 'string' },
		{ name	= 'selectedPetSkinCost',	type	= 'number' },
		{ name	= 'hoveringGear',			type	= 'number' },
		{ name	= 'selectedSkin',			type	= 'number' },
		{ name	= 'selectedSkinOwned',		type	= 'number' },
		{ name	= 'purchasingSkin',			type	= 'number' },
		{ name	= 'hoveringSkin',			type	= 'number' },
		{ name	= 'selectionSection',		type	= 'number' },	-- 0 selection main, 1 skill builds, 2 Awards and Quest Status, 3 scoreboard, 4 pre-play mode selection screen
		{ name	= 'selectionLeftContent',	type	= 'number' },	-- 0 breadcrumbs and gear, 1 hero pick, 2 hero pick full size, 3 pet pick, 4 pet pick full size, 5 dye pick expanded, 6 crafted items expanded, 7 postgame quests, 8 player finder
		{ name	= 'selectionRightContent',	type	= 'number' },	-- 0 team info, 1 hero, 2 pet, 3 region map, 4 language list, 5 server list
		{ name	= 'selectionRightHero',		type	= 'number' },	-- 1 hero abilities, 2 hero lore, 3 hero replays, 4 hero videos
		{ name	= 'heroSelectInfoType',		type	= 'string' },
		{ name	= 'lobbyGameInfoServerType',	type	= 'string' },
		{ name	= 'inQueue',					type	= 'boolean' },
		{ name	= 'inParty',					type	= 'boolean' },
		{ name 	= 'isLocalPlayerReady',			type	= 'boolean' },
		{ name 	= 'isPartyReady',				type	= 'boolean' },
		{ name 	= 'isPartyLeader',				type	= 'boolean' },
		{ name 	= 'npebusySpeaking',			type	= 'boolean' },
		{ name 	= 'userRequestedParty',			type	= 'boolean' },
		{ name 	= 'numPlayersInParty',			type	= 'number' },
		{ name 	= 'tutorialProgress',			type	= 'number' },
		{ name 	= 'reconnectAddress',			type	= 'string' },
		{ name 	= 'reconnectType',				type	= 'string' },
		{ name 	= 'reconnectShow',				type	= 'boolean' },
		{ name 	= 'missedGameAddress',			type	= 'string' },
		{ name 	= 'teamListQueueUpdate',		type	= 'boolean' },
		{ name 	= 'teamListReOrderLock',		type	= 'boolean' },
		{ name 	= 'teamListSingleUpdate',		type	= 'boolean' },
		{ name 	= 'isRewarding',				type	= 'boolean' },
		{ name 	= 'leftLastGame',				type	= 'boolean' },
		{ name 	= 'selectionComplete',			type	= 'boolean' },
		{ name 	= 'queue',						type	= 'string' },
		{ name 	= 'region',						type	= 'string' },
	}
)

mainUI.Selection = mainUI.Selection or {}
mainUI.Selection.selectionSections = mainUI.Selection.selectionSections or {}
mainUI.Selection.selectionSections.HERO_PICK 					= 0
mainUI.Selection.selectionSections.SKILL_BUILDS 				= 1
mainUI.Selection.selectionSections.AWARDS_AND_QUEST_STATUS		= 2
mainUI.Selection.selectionSections.SCOREBOARD 					= 3
mainUI.Selection.selectionSections.GAME_TYPE_PICK 				= 4
mainUI.Selection.selectionSections.CAPTAINS_MODE 				= 5

triggerStatus.teamListReOrderLock = false
triggerStatus.teamListQueueUpdate = false
triggerStatus.teamListSingleUpdate = false


local triggerStatusAnim = LuaTrigger.CreateCustomTrigger('selection_StatusAnimation',
	{
		{ name	= 'animState',						type	= 'string' },
		{ name	= 'selectionSection',				type	= 'number' },
		{ name	= 'newSelectionSection',			type	= 'number' },
		{ name	= 'selectionLeftContent',			type	= 'number' },
		{ name	= 'newSelectionLeftContent',		type	= 'number' },
		{ name	= 'selectionRightContent',			type	= 'number' },
		{ name	= 'newSelectionRightContent',		type	= 'number' },
		{ name	= 'timeOfLeftContentChange',		type	= 'number' },
		{ name	= 'timeSinceLeftContentChange',		type	= 'number' },
		{ name	= 'timeOfRightContentChange',		type	= 'number' },
		{ name	= 'timeSinceRightContentChange',	type	= 'number' },
		{ name	= 'timeOfSectionChange',			type	= 'number' },
		{ name	= 'timeSinceSectionChange',			type	= 'number' },
	}
)

triggerStatusAnim.animState = 0
triggerStatusAnim.newSelectionSection = -1
triggerStatusAnim.newSelectionRightContent = -1
triggerStatusAnim.newSelectionLeftContent = -1

UnwatchLuaTriggerByKey('mainPanelAnimationStatus', 'mainPanelAnimationStatusKeySelection')
WatchLuaTrigger('mainPanelAnimationStatus', function(trigger)
	if (mainSectionAnimState) then
		local animState = mainSectionAnimState(40, trigger.main, trigger.newMain)
		triggerStatusAnim.animState = animState
		triggerStatusAnim:Trigger(false)
	end
end, 'mainPanelAnimationStatusKeySelection', 'main', 'newMain')

object:RegisterWatchLua('selection_Status', function(widget, trigger)
	local triggerStatusAnim = LuaTrigger.GetTrigger('selection_StatusAnimation')
	if (triggerStatusAnim.newSelectionSection ~= trigger.selectionSection) and (triggerStatusAnim.selectionSection ~= trigger.selectionSection) then
		triggerStatusAnim.newSelectionSection 					= 	trigger.selectionSection
		triggerStatusAnim.timeOfSectionChange 					=	GetTime()
		triggerStatusAnim.timeSinceSectionChange 				=	0

		UnwatchLuaTriggerByKey('System', 'SelectionAnim1')
		WatchLuaTrigger('System', function(systemTrigger)
			triggerStatusAnim.timeSinceSectionChange = systemTrigger.hostTime - triggerStatusAnim.timeOfSectionChange
			triggerStatusAnim:Trigger(false)
			if ((systemTrigger.hostTime - triggerStatusAnim.timeOfSectionChange) > (styles_mainSwapAnimationDuration)) then
				triggerStatusAnim.selectionSection 				= 	trigger.selectionSection
				triggerStatusAnim.newSelectionSection 			=   -1
				triggerStatusAnim:Trigger(false)
				UnwatchLuaTriggerByKey('System', 'SelectionAnim1')
			end
		end, 'SelectionAnim1', 'hostTime')

		triggerStatusAnim:Trigger(false)
	end
end, true, nil, 'selectionSection')

object:RegisterWatchLua('selection_Status', function(widget, trigger)
	local triggerStatusAnim = LuaTrigger.GetTrigger('selection_StatusAnimation')
	if (triggerStatusAnim.newSelectionLeftContent ~= trigger.selectionLeftContent) and (triggerStatusAnim.selectionLeftContent ~= trigger.selectionLeftContent) then
		triggerStatusAnim.newSelectionLeftContent 				= 	trigger.selectionLeftContent
		triggerStatusAnim.timeOfLeftContentChange 				=	GetTime()
		triggerStatusAnim.timeSinceLeftContentChange 			=	0

		UnwatchLuaTriggerByKey('System', 'SelectionAnim2')
		WatchLuaTrigger('System', function(systemTrigger)
			triggerStatusAnim.timeSinceLeftContentChange = systemTrigger.hostTime - triggerStatusAnim.timeOfLeftContentChange
			triggerStatusAnim:Trigger(false)
			if ((systemTrigger.hostTime - triggerStatusAnim.timeOfLeftContentChange) > (styles_mainSwapAnimationDuration)) then
				triggerStatusAnim.selectionLeftContent 			= 	trigger.selectionLeftContent
				triggerStatusAnim.newSelectionLeftContent 		=   -1
				triggerStatusAnim:Trigger(false)
				UnwatchLuaTriggerByKey('System', 'SelectionAnim2')
			end
		end, 'SelectionAnim2', 'hostTime')

		triggerStatusAnim:Trigger(false)
	end
end, true, nil, 'selectionLeftContent')

object:RegisterWatchLua('selection_Status', function(widget, trigger)
	local triggerStatusAnim = LuaTrigger.GetTrigger('selection_StatusAnimation')
	if (triggerStatusAnim.newSelectionRightContent ~= trigger.selectionRightContent) and (triggerStatusAnim.selectionRightContent ~= trigger.selectionRightContent) then
		triggerStatusAnim.newSelectionRightContent 				= 	trigger.selectionRightContent
		triggerStatusAnim.timeOfRightContentChange 				=	GetTime()
		triggerStatusAnim.timeSinceRightContentChange 			=	0

		UnwatchLuaTriggerByKey('System', 'SelectionAnim3')
		WatchLuaTrigger('System', function(systemTrigger)
			triggerStatusAnim.timeSinceRightContentChange = systemTrigger.hostTime - triggerStatusAnim.timeOfRightContentChange
			triggerStatusAnim:Trigger(false)
			if ((systemTrigger.hostTime - triggerStatusAnim.timeOfRightContentChange) > (styles_mainSwapAnimationDuration)) then
				triggerStatusAnim.selectionRightContent 		= 	trigger.selectionRightContent
				triggerStatusAnim.newSelectionRightContent 		=   -1
				triggerStatusAnim:Trigger(false)
				UnwatchLuaTriggerByKey('System', 'SelectionAnim3')
			end
		end, 'SelectionAnim3', 'hostTime')

		triggerStatusAnim:Trigger(false)
	end
end, true, nil, 'selectionRightContent')

local craftedItemTipInfo = LuaTrigger.CreateCustomTrigger('craftedItemTipInfo',
	{
		{ name	= 'visible',					type	= 'boolean'},
		{ name	= 'icon',						type	= 'string'},
		{ name	= 'title',						type	= 'string'},
		{ name	= 'description',				type	= 'string'},
		{ name	= 'cost',						type	= 'number'},
		{ name	= 'power',						type	= 'number'},
		{ name	= 'baseAttackSpeed',			type	= 'number'},
		{ name	= 'hp',							type	= 'number'},
		{ name	= 'mp',							type	= 'number'},
		{ name	= 'hpregen',					type	= 'number'},
		{ name	= 'mpregen',					type	= 'number'},
		{ name	= 'component1Icon',				type	= 'string'},
		{ name	= 'component2Icon',				type	= 'string'},
		{ name	= 'component3Icon',				type	= 'string'},
		{ name	= 'component1Exists',			type	= 'boolean'},
		{ name	= 'component2Exists',			type	= 'boolean'},
		{ name	= 'component3Exists',			type	= 'boolean'},
		{ name	= 'analogBonusDescription',		type	= 'string'},
		{ name	= 'analogTierString',			type	= 'string'},
		{ name	= 'rareBonusExists',			type	= 'boolean'},
		{ name	= 'rareBonusIcon',				type	= 'string'},
		{ name	= 'rareBonusTitle',				type	= 'string'},
		{ name	= 'rareBonusDescription',		type	= 'string'},
		{ name	= 'legendaryBonusExists',		type	= 'boolean'},
		{ name	= 'legendaryBonusIcon',			type	= 'string'},
		{ name	= 'legendaryBonusTitle',		type	= 'string'},
		{ name	= 'legendaryBonusDescription',	type	= 'string'},
		{ name	= 'currentEmpoweredEffectEntityName',		type	= 'string' },
		{ name	= 'currentEmpoweredEffectCost',				type	= 'number' },
		{ name	= 'currentEmpoweredEffectDisplayName',		type	= 'string' },
		{ name	= 'currentEmpoweredEffectDescription',		type	= 'string' },
		{ name	= 'empoweredEffect0EntityName',						type		= 'string' },
		{ name	= 'empoweredEffect1EntityName',						type		= 'string' },
		{ name	= 'empoweredEffect2EntityName',						type		= 'string' },
		{ name	= 'empoweredEffect3EntityName',						type		= 'string' },
		{ name	= 'empoweredEffect4EntityName',						type		= 'string' },
		{ name	= 'empoweredEffect5EntityName',						type		= 'string' },
		{ name	= 'empoweredEffect6EntityName',						type		= 'string' },
		{ name	= 'empoweredEffect7EntityName',						type		= 'string' },

	}
)

craftedItemTipInfo.currentEmpoweredEffectEntityName = ''
craftedItemTipInfo.currentEmpoweredEffectCost = 0
craftedItemTipInfo.currentEmpoweredEffectDisplayName = ''
craftedItemTipInfo.currentEmpoweredEffectDescription = ''
craftedItemTipInfo.empoweredEffect0EntityName = ''
craftedItemTipInfo.empoweredEffect1EntityName = ''
craftedItemTipInfo.empoweredEffect2EntityName = ''
craftedItemTipInfo.empoweredEffect3EntityName = ''
craftedItemTipInfo.empoweredEffect4EntityName = ''
craftedItemTipInfo.empoweredEffect5EntityName = ''
craftedItemTipInfo.empoweredEffect6EntityName = ''
craftedItemTipInfo.empoweredEffect7EntityName = ''

-- =================== From Old =====================

LuaTrigger.CreateCustomTrigger('spectatorMouseSettings',	-- For the virtual cursor representing the player being spectated
	{
		{ name	= 'opacity', type	= 'number' }
	}
)

LuaTrigger.CreateCustomTrigger('gameShopLastView',
	{
		{ name		= 'search',		type	= 'string' },
		{ name		= 'filter',		type	= 'string' },
		{ name		= 'category',	type	= 'string' }
	}
)

LuaTrigger.CreateCustomTrigger('showBuyGems',
	{
		{ name	= 'dummyParam', type	= 'boolean' }	-- Isn't used
	}
)

LuaTrigger.CreateCustomTrigger('petCorralSelectPurchasePet',	-- To populate the "select pet" confirmation screen.
	{
		{ name	= 'petName',			type	= 'string' },
		{ name	= 'petID',				type	= 'number' }
	}
)

LuaTrigger.CreateCustomTrigger('petCorralOpen',	-- 0 Closed, 1 loading, 2 open
	{
		{ name	= 'stage',				type	= 'number'}
	}
)

local craftingStage = LuaTrigger.CreateCustomTrigger('craftingStage',	-- To quickly and simply toggle between crafting prompts
	{
		{ name	= 'stage',							type	= 'number'},
		{ name	= 'popup',							type	= 'number'},
		{ name	= 'enchantSelectedIndex',			type	= 'number'},
		{ name	= 'craftClickedComponentSlotIndex',	type	= 'number'},
		{ name	= 'craftedItemsFilter',				type	= 'string'},
		{ name	= 'enchantLastDraggedIndex',		type	= 'number'},
		{ name	= 'craftedItemCount',				type	= 'number'},
		{ name	= 'choseValidComponents',			type	= 'boolean'},
		{ name	= 'choseValidImbuement',			type	= 'boolean'},
		{ name	= 'confirmedImbuement',				type	= 'boolean'},
	}
)
craftingStage.choseValidComponents = false
craftingStage.choseValidImbuement = false
craftingStage.confirmedImbuement = false
craftingStage:Trigger(false)

LuaTrigger.CreateCustomTrigger('buttonBinderData',
	{
		{ name	= 'show',				type	= 'boolean' },
		{ name	= 'allowMoreInfoKey',	type	= 'boolean' },
		{ name	= 'table',				type	= 'string' },
		{ name	= 'action',				type	= 'string' },
		{ name	= 'param',				type	= 'string' },
		{ name	= 'oldButton',			type	= 'string' },
		{ name	= 'keyNum',				type	= 'number' },
		{ name	= 'impulse',			type	= 'boolean' },
		{ name	= 'useCtrl',			type	= 'boolean' },
		{ name	= 'useAlt',				type	= 'boolean' },
		{ name	= 'useShift',			type	= 'boolean' },
	}
)

LuaTrigger.CreateCustomTrigger('simpleMultiWindowTipGrowYData',
	{
		{ name	= 'show',		type	= 'boolean' },
		{ name	= 'title',		type	= 'string' },
		{ name	= 'body',		type	= 'string' },
		{ name	= 'icon',		type	= 'string' },
		{ name	= 'hasIcon',	type	= 'boolean' },
		{ name	= 'hasTitle',	type	= 'boolean' },
		{ name	= 'hasBody',	type	= 'boolean' },
		{ name	= 'width',		type	= 'number' },
		{ name	= 'xOffset',	type	= 'number' },
		{ name	= 'yOffset',	type	= 'number' },

	}
)

LuaTrigger.CreateCustomTrigger('simpleTipGrowYData',
	{
		{ name	= 'show',		type	= 'boolean' },
		{ name	= 'title',		type	= 'string' },
		{ name	= 'body',		type	= 'string' },
		{ name	= 'icon',		type	= 'string' },
		{ name	= 'hasIcon',	type	= 'boolean' },
		{ name	= 'hasTitle',	type	= 'boolean' },
		{ name	= 'hasBody',	type	= 'boolean' },
		{ name	= 'width',		type	= 'number' },
		{ name	= 'xOffset',	type	= 'number' },
		{ name	= 'yOffset',	type	= 'number' },

	}
)

LuaTrigger.CreateCustomTrigger('simpleTipNoFloatData',
	{
		{ name	= 'show',		type	= 'boolean' },
		{ name	= 'title',		type	= 'string' },
		{ name	= 'body',		type	= 'string' },
		{ name	= 'icon',		type	= 'string' },
		{ name	= 'hasIcon',	type	= 'boolean' },
		{ name	= 'hasTitle',	type	= 'boolean' },
		{ name	= 'hasBody',	type	= 'boolean' },
		{ name	= 'x',			type	= 'string' },
		{ name	= 'y',			type	= 'string' },
		{ name	= 'align',		type	= 'string' },
		{ name	= 'valign',		type	= 'string' },
		{ name	= 'width',		type	= 'number' }
	}
)


-- Context Menu

ContextMenuTrigger = LuaTrigger.CreateCustomTrigger('ContextMenuTrigger',
	{
		{ name	= 'contextMenuArea',				type	= 'number' },
		{ name	= 'selectedUserIsLocalClient',		type	= 'boolean' },
		{ name	= 'selectedUserIsFriend',			type	= 'boolean' },
		{ name	= 'selectedUserOnlineStatus',		type	= 'boolean' },
		{ name	= 'selectedUserIsInGame',			type	= 'boolean' },
		{ name	= 'selectedUserIsInParty',			type	= 'boolean' },
		{ name	= 'selectedUserIsInLobby',			type	= 'boolean' },
		{ name	= 'localClientIsSpectating',		type	= 'boolean' },
		{ name	= 'needToApprove',					type	= 'boolean' },
		{ name	= 'selectedUserIdentID',			type	= 'string' },
		{ name	= 'selectedUserUniqueID',			type	= 'string' },
		{ name	= 'selectedUserUsername',			type	= 'string' },
		{ name	= 'channelID',						type	= 'string' },
		{ name	= 'endMatchSection',				type	= 'number' },
		{ name	= 'gameAddress',					type	= 'string' },
		{ name	= 'selectedUserIsIgnored',			type	= 'boolean' },
		{ name	= 'joinableGame',					type	= 'boolean' },
		{ name	= 'joinableParty',					type	= 'boolean' },
		{ name	= 'spectatableGame',				type	= 'boolean' },
	}
)
ContextMenuTrigger.contextMenuArea = -1

ContextMenuMultiWindowTrigger = LuaTrigger.CreateCustomTrigger('ContextMenuMultiWindowTrigger',
	{
		{ name	= 'contextMenuArea',				type	= 'number' },
		{ name	= 'selectedUserIsLocalClient',		type	= 'boolean' },
		{ name	= 'selectedUserIsFriend',			type	= 'boolean' },
		{ name	= 'selectedUserOnlineStatus',		type	= 'boolean' },
		{ name	= 'selectedUserIsInGame',			type	= 'boolean' },
		{ name	= 'selectedUserIsInParty',			type	= 'boolean' },
		{ name	= 'selectedUserIsInLobby',			type	= 'boolean' },
		{ name	= 'localClientIsSpectating',		type	= 'boolean' },
		{ name	= 'needToApprove',					type	= 'boolean' },
		{ name	= 'activeMultiWindowWindow',		type	= 'string' },
		{ name	= 'selectedUserIdentID',			type	= 'string' },
		{ name	= 'selectedUserUniqueID',			type	= 'string' },
		{ name	= 'selectedUserUsername',			type	= 'string' },
		{ name	= 'channelID',						type	= 'string' },
		{ name	= 'endMatchSection',				type	= 'number' },
		{ name	= 'gameAddress',					type	= 'string' },
		{ name	= 'selectedUserIsIgnored',			type	= 'boolean' },
		{ name	= 'joinableGame',					type	= 'boolean' },
		{ name	= 'joinableParty',					type	= 'boolean' },
		{ name	= 'spectatableGame',				type	= 'boolean' },
	}
)
ContextMenuMultiWindowTrigger.contextMenuArea = -1

local partyCustomTrigger 		= LuaTrigger.GetTrigger('PartyTrigger') or LuaTrigger.CreateCustomTrigger('PartyTrigger',
	{
		{ name	= 'isOpen',	type				= 'boolean' },
		{ name	= 'userRequestedParty',	type	= 'boolean' },
		{ name	= 'unrankedIsPvE',		type	= 'boolean' },
		{ name	= 'gameMode',			type	= 'string' },	-- unranked, ranked, khanquest
		{ name	= 'isPublic',			type	= 'boolean' },
	}
)

--

object:RegisterWatchLua('HeroSelectInfo', function(widget, trigger)
	triggerStatus.heroSelectInfoType = trigger.type
	triggerStatus:Trigger(false)
end, true, nil, 'type')

object:RegisterWatchLua('LobbyGameInfo', function(widget, trigger)
	triggerStatus.lobbyGameInfoServerType = trigger.serverType
	triggerStatus:Trigger(false)
end, true, nil, 'serverType')

object:RegisterWatchLua('PartyTrigger', function(widget, trigger)
	triggerStatus.userRequestedParty = trigger.userRequestedParty
	triggerStatus:Trigger(false)
end, false, nil, 'userRequestedParty')

object:RegisterWatchLua('PartyStatus', function(widget, trigger)
	triggerStatus.region = trigger.region
	triggerStatus.inQueue = trigger.inQueue
	triggerStatus.inParty = trigger.inParty
	triggerStatus.isLocalPlayerReady = trigger.isLocalPlayerReady
	triggerStatus.isPartyLeader = trigger.isPartyLeader
	triggerStatus.isPartyReady = trigger.isPartyReady
	triggerStatus.numPlayersInParty = trigger.numPlayersInParty
	triggerStatus.queue = trigger.queue
	triggerStatus:Trigger(false)
	trigger_mainPanelStatus.inQueue = trigger.inQueue
	trigger_mainPanelStatus.inParty = trigger.inParty
	trigger_mainPanelStatus.numPlayersInParty = trigger.numPlayersInParty
	trigger_mainPanelStatus:Trigger(false)
	trigger_mainPanelAnimationStatus.inQueue = trigger.inQueue
	trigger_mainPanelAnimationStatus.inParty = trigger.inParty
	trigger_mainPanelAnimationStatus:Trigger(false)
end, true, nil, 'inQueue', 'inParty', 'isLocalPlayerReady', 'numPlayersInParty', 'queue', 'region')

object:RegisterWatchLua('LoginStatus', function(widget, trigger)	-- This is a bit of a hacky workaround for being unable to watch specific params in grouptriggers
	trigger_mainPanelStatus.isAutoLogin = trigger.isAutoLogin
	trigger_mainPanelStatus.isLoggedIn = trigger.isLoggedIn
	trigger_mainPanelStatus.hasIdent = trigger.hasIdent
	trigger_mainPanelStatus.loginChange = trigger.loginChange
	trigger_mainPanelStatus.externalLogin = trigger.externalLogin
	trigger_mainPanelStatus:Trigger(false)
	trigger_mainPanelAnimationStatus.isLoggedIn = trigger.isLoggedIn
	trigger_mainPanelAnimationStatus.hasIdent = trigger.hasIdent
	trigger_mainPanelAnimationStatus.loginChange = trigger.loginChange
	trigger_mainPanelAnimationStatus:Trigger(false)
end, true, nil, 'isLoggedIn', 'hasIdent', 'isAutoLogin', 'loginChange', 'externalLogin')

object:RegisterWatchLua('GamePhase', function(widget, trigger)
	trigger_mainPanelStatus.gamePhase = trigger.gamePhase
	trigger_mainPanelStatus:Trigger(false)
end)

object:RegisterWatchLua('GameClientRequestsGetAllIdentGameData', function(widget, trigger)
	trigger_mainPanelStatus.getAllIdentGameDataStatus = trigger.status
	trigger_mainPanelStatus:Trigger(false)
end, true, nil)

object:RegisterWatchLua('Corral', function(widget, trigger)
	trigger_mainPanelStatus.initialPetPicked = trigger.initialPetPicked
	trigger_mainPanelStatus:Trigger(false)
end)

--

object:RegisterWatchLua('HeroSelectLocalPlayerInfo', function(widget, trigger)
	trigger_mainPanelStatus.isReady = trigger.isReady
	trigger_mainPanelStatus:Trigger(false)
end, true, nil, 'isReady')

-- ================ Temp until Lua replacements arrive =========================

-- ============ temp::: --

LuaTrigger.CreateCustomTrigger('socialEntryDataDragged',	-- For the visual clone that you're dragging
	{
		{ name		= 'exists',		type	= 'boolean' },
		{ name		= 'type',		type	= 'number' },
		{ name		= 'title',		type	= 'string' },
		{ name		= 'subtitle',	type	= 'string' },
		{ name		= 'status',		type	= 'number' },
		{ name		= 'icon',		type	= 'string' }
	}
)

-- ================================ (shop stuff (up from game)

preTrigger_shopFilterList	= {
	activatable			= false,
	attack_speed		= false,
	attack_mod			= false,
	defense_armor		= false,
	buff_team			= false,
	attack_crit			= false,
	cd_reduction		= false,
	debuff_enemy		= false,
	defense_health		= false,
	attack_lifesteal	= false,
	defense_magic_armor	= false,
	ability_mana		= false,
	mobility			= false,
	ability_power		= false,
	stealth				= false,
	health_comp 		= false,
	health_regen_comp 	= false,
	mana_comp 			= false,
	mana_regen_comp 	= false,
	power_comp 			= false,
	attack_speed_comp 	= false,
	mana_comp1 			= false,
	mana_comp2 			= false,
	mana_comp3 			= false,
	mana_regen_comp1 	= false,
	mana_regen_comp2 	= false,
	health_comp1 		= false,
	health_comp2 		= false,
	health_comp3 		= false,
	health_regen_comp1 	= false,
	health_regen_comp2 	= false,
	power_comp1 		= false,
	power_comp2 		= false,
	power_comp3 		= false,
	attack_speed_comp1	= false,
	attack_speed_comp2	= false,
	attack_damage		= false,
	defense_mitigation	= false,
	defense_resistance	= false,
}

shopFilterParamList = {}

for k,v in pairs(preTrigger_shopFilterList) do
	table.insert(shopFilterParamList, { name = k, type = 'boolean'})
end

table.insert(shopFilterParamList, { name = 'shopCategory', type = 'string' })
table.insert(shopFilterParamList, { name = 'shopView', type = 'number' })
table.insert(shopFilterParamList, { name = 'forceCategory', type = 'string' })

trigger_shopFilter = LuaTrigger.CreateCustomTrigger('gameShopFilterInfo', shopFilterParamList)

-- =============

trigger_gamePanelInfo = LuaTrigger.CreateCustomTrigger('gamePanelInfo', {
	{ name	= 'team',								type		= 'number' },
	{ name	= 'shopOpen',							type		= 'boolean' },
	{ name	= 'shopView',							type		= 'number' },
	{ name	= 'shopIsFiltered',						type		= 'boolean' },
	{ name	= 'shopHasFiltersToDisplay',			type		= 'boolean' },
	{ name	= 'shopShowFilters',					type		= 'boolean' },
	{ name	= 'shopCategory',						type		= 'string' },
	{ name	= 'shopItemView',						type		= 'number' },
	{ name	= 'shopDraggedItem',					type		= 'string' },
	{ name	= 'shopDraggedItemScroll',				type		= 'boolean' },
	{ name	= 'shopDraggedItemOwnedRecipe',			type		= 'boolean' },
	{ name	= 'draggedInventoryIndex',				type		= 'number' },
	{ name	= 'shopLastBuyQueueDragged',			type		= 'number' },
	{ name	= 'shopLastQuickSlotDragged',			type		= 'number' },
	{ name	= 'shopTooltipMoreInfo',				type		= 'boolean' },
	{ name	= 'abilityPanel',						type		= 'boolean' },
	{ name	= 'abilityPanelView',					type		= 'number' },
	{ name	= 'moreInfoKey',						type		= 'boolean' },
	{ name	= 'selectedShopItem',					type		= 'number' },
	{ name	= 'selectedShopItemType',				type		= 'string' },
	{ name	= 'backpackVis',						type		= 'boolean' },
	{ name	= 'channelBarVis',						type		= 'boolean' },
	{ name	= 'respawnBarVis',						type		= 'boolean' },
	{ name	= 'heroVitalsVis',						type		= 'boolean' },
	{ name	= 'lanePusherVis',						type		= 'boolean' },
	{ name	= 'pushOrbVis',							type		= 'boolean' },
	{ name	= 'heroInfoVis',						type		= 'boolean' },
	{ name	= 'ally0Exists',						type		= 'boolean' },
	{ name	= 'ally1Exists',						type		= 'boolean' },
	{ name	= 'ally2Exists',						type		= 'boolean' },
	{ name	= 'ally3Exists',						type		= 'boolean' },
	{ name	= 'enemy0Exists',						type		= 'boolean' },
	{ name	= 'enemy1Exists',						type		= 'boolean' },
	{ name	= 'enemy2Exists',						type		= 'boolean' },
	{ name	= 'enemy3Exists',						type		= 'boolean' },
	{ name	= 'enemy4Exists',						type		= 'boolean' },
	{ name	= 'ally0MVP',							type		= 'boolean' },
	{ name	= 'ally1MVP',							type		= 'boolean' },
	{ name	= 'ally2MVP',							type		= 'boolean' },
	{ name	= 'ally3MVP',							type		= 'boolean' },
	{ name	= 'ally4MVP',							type		= 'boolean' },
	{ name	= 'enemy0MVP',							type		= 'boolean' },
	{ name	= 'enemy1MVP',							type		= 'boolean' },
	{ name	= 'enemy2MVP',							type		= 'boolean' },
	{ name	= 'enemy3MVP',							type		= 'boolean' },
	{ name	= 'enemy4MVP',							type		= 'boolean' },
	{ name	= 'unitFramesPinned',					type		= 'boolean' },
	{ name	= 'orbExpanded',						type		= 'boolean' },
	{ name	= 'orbExpandedPinned',					type		= 'boolean' },
	{ name	= 'boss1Expanded',						type		= 'boolean' },
	{ name	= 'boss1ExpandedPinned',				type		= 'boolean' },
	{ name	= 'boss2Expanded',						type		= 'boolean' },
	{ name	= 'boss2ExpandedPinned',				type		= 'boolean' },
	{ name	= 'clockExpanded',						type		= 'boolean' },
	{ name	= 'clockExpandedPinned',				type		= 'boolean' },
	{ name	= 'aspect',								type		= 'number'	},
	{ name	= 'ShowActiveAbility0',					type		= 'boolean' },
	{ name	= 'ShowActiveAbility1',					type		= 'boolean' },
	{ name	= 'ShowActiveAbility2',					type		= 'boolean' },
	{ name	= 'ShowActiveAbility3',					type		= 'boolean' },
	{ name	= 'mapWidgetVis_tabbing',				type		= 'boolean' },
	{ name	= 'mapWidgetVis_respawnTimer',			type		= 'boolean' },
	{ name	= 'mapWidgetVis_minimap',				type		= 'boolean' },
	{ name	= 'mapWidgetVis_items',					type		= 'boolean' },
	{ name	= 'mapWidgetVis_abilityBarPet',			type		= 'boolean' },
	{ name	= 'mapWidgetVis_pushBar',				type		= 'boolean' },	-- This is whatever the game momentum / push orb thing ends up being, contains time, etc.
	{ name	= 'mapWidgetVis_heroInfos',				type		= 'boolean' },	-- All top-of-screen hero info (unitframes)
	{ name	= 'mapWidgetVis_shopItemList',			type		= 'boolean' },	-- Entire "items" portion of the shop
	{ name	= 'mapWidgetVis_courierButton',			type		= 'boolean' },
	{ name	= 'mapWidgetVis_portHomeButton',		type		= 'boolean' },
	{ name	= 'mapWidgetVis_shopQuickSlots',		type		= 'boolean' },
	{ name	= 'mapWidgetVis_abilityPanel',			type		= 'boolean' },
	{ name	= 'mapWidgetVis_shopClickable',			type		= 'boolean' },
	{ name	= 'mapWidgetVis_shopRightClick',		type		= 'boolean' },
	{ name	= 'mapWidgetVis_canToggleShop',			type		= 'boolean' },
	{ name	= 'mapWidgetVis_shopBootsGlow',			type		= 'boolean' },
	{ name	= 'mapWidgetVis_buildControls',			type		= 'boolean' },
	{ name	= 'mapWidgetVis_arcadeText',			type		= 'boolean' },
	{ name	= 'mapWidgetVis_kills',					type		= 'boolean' },
	{ name	= 'mapWidgetVis_tdm',					type		= 'boolean' },
	{ name	= 'mapWidgetVis_inventory',				type		= 'boolean' },
	{ name	= 'gameMenuExpanded',					type		= 'boolean' },
	{ name	= 'goldSplashVisible',					type		= 'boolean' },
	{ name	= 'itemGuidanceVisible',				type		= 'boolean' },
})

trigger_SPEAbilityUpdate = LuaTrigger.CreateCustomTrigger('SPEAbilityUpdate', {
	{ name	= 'ShowActiveAbility0',					type		= 'boolean' },
	{ name	= 'ShowActiveAbility1',					type		= 'boolean' },
	{ name	= 'ShowActiveAbility2',					type		= 'boolean' },
	{ name	= 'ShowActiveAbility3',					type		= 'boolean' },
	{ name	= 'ShowActiveAbility4',					type		= 'boolean' },
	{ name	= 'ShowActiveAbility5',					type		= 'boolean' },
	{ name	= 'ShowActiveAbility6',					type		= 'boolean' },
})

-- Needs to exist due to how often things keep getting rearranged/expanded out while the basic steps remain the same.
NPE_PROGRESS_START				= 0
NPE_PROGRESS_ENTEREDNAME		= 1
NPE_PROGRESS_FINISHTUT1			= 2
NPE_PROGRESS_FINISHTUT2			= 3
NPE_PROGRESS_ACCOUNTCREATED		= 4
NPE_PROGRESS_SELECTEDPET		= 5
NPE_PROGRESS_FINISHTUT3			= 6
NPE_PROGRESS_TUTORIALCOMPLETE	= 7

LuaTrigger.CreateCustomTrigger('newPlayerExperience', {
	{ name		= 'tutorialProgress',			type		= 'number', },		-- Progress through tutorial campaign and in-between sections for account creation, intro to social, etc.
	{ name		= 'tutorialComplete',			type		= 'boolean', },		-- Has the user completed the tutorial campaign?
	{ name		= 'craftingIntroProgress',		type		= 'number', },      -- Progress through first time crafting.
	{ name		= 'craftingIntroStep',			type		= 'number', },      -- While progress is saved, step is the un-saved point within the progress checkpoint where the user currently is.
	{ name		= 'enchantingIntroProgress',	type		= 'number', },      -- Progress through first time enchanting.
	{ name		= 'enchantingIntroStep',		type		= 'number', },      -- While progress is saved, step is the un-saved point within the progress checkpoint where the user currently is.
	{ name		= 'corralIntroProgress',		type		= 'number', },		-- Progress through first time interacting with pets.
	{ name		= 'corralIntroStep',			type		= 'number', },		-- While progress is saved, step is the un-saved point within the progress checkpoint where the user currently is.
	{ name		= 'rewardsIntroProgress',		type		= 'number', },		-- Progress through first time interacting with end match rewards.
	{ name		= 'rewardsIntroStep',			type		= 'number', },		-- While progress is saved, step is the un-saved point within the progress checkpoint where the user currently is.
	{ name		= 'tutorial1Revisit',			type		= 'number', },		-- Has this map been revisited post tutorial? (especially if skipping).
	{ name		= 'tutorial2Revisit',			type		= 'number', },		-- Has this map been revisited post tutorial? (especially if skipping).
	{ name		= 'tutorial3Revisit',			type		= 'number', },		-- Has this map been revisited post tutorial? (especially if skipping).
	{ name		= 'tutorialProgressBeforeSkip',	type		= 'number', },		-- Only set if skipping.
	{ name		= 'npeStarted',					type		= 'boolean', },		-- If they've already clicked "Begin"/etc. in the "start tutorial/skip to log in" prompt.
	{ name		= 'showLogin',					type		= 'boolean', },		-- Primarily for tutorialProgress 2 - need something that shows login if skipping account creation without actually being tutorialProgress 3 (which doesn't save)
	{ name		= 'busySpeaking',				type		= 'boolean', },
})

local loginNPEStatus		= libGeneral.createGroupTrigger('loginNPEStatus', {
	'newPlayerExperience.tutorialProgress',
	'newPlayerExperience.tutorialComplete',
	'newPlayerExperience.npeStarted',
	'newPlayerExperience.showLogin',
	'GamePhase.gamePhase',
	'mainPanelStatus.main',
	'AccountInfo.tutorialProgress'
})

local loginNPEStatusAnims		= libGeneral.createGroupTrigger('loginNPEStatusAnims', {
	'newPlayerExperience.tutorialProgress',
	'newPlayerExperience.tutorialComplete',
	'newPlayerExperience.npeStarted',
	'newPlayerExperience.showLogin',
	'GamePhase.gamePhase',
	'mainPanelAnimationStatus.main',
	'mainPanelAnimationStatus.newMain',
	'UpdateInfo.updateAvailable',
	'ChatConnected',
	'LoginStatus.isLoggedIn'
})

object:RegisterWatchLua('newPlayerExperience', function(widget, trigger)
	triggerStatus.npebusySpeaking = trigger.busySpeaking
	triggerStatus.tutorialProgress  = trigger.tutorialProgress
	triggerStatus:Trigger(false)
end, true, nil, 'busySpeaking', 'tutorialProgress')

object:RegisterWatchLua('ReconnectInfo', function(widget, trigger)
	triggerStatus.reconnectAddress 				 = trigger.address
	triggerStatus.reconnectType  				 = trigger.type
	triggerStatus.reconnectShow  				 = trigger.show
	triggerStatus.isRewarding					 = trigger.isRewarding
	triggerStatus.leftLastGame					 = trigger.hasLeaver
	triggerStatus:Trigger(false)
	trigger_mainPanelStatus.reconnectAddress 	 = trigger.address
	trigger_mainPanelStatus.reconnectType  		 = trigger.type
	trigger_mainPanelStatus.reconnectShow  		 = trigger.show
	trigger_mainPanelStatus.isRewarding			 = trigger.isRewarding
	trigger_mainPanelStatus.leftLastGame		 = trigger.hasLeaver
	trigger_mainPanelStatus:Trigger(false)
end, true, nil, 'address', 'type', 'show', 'isRewarding', 'hasLeaver')

object:RegisterWatchLua('ChatMissedGame', function(widget, trigger)
	triggerStatus.missedGameAddress 			 = trigger.address
	triggerStatus.isRewarding					 = trigger.isRewarding
	triggerStatus.leftLastGame					 = trigger.hasLeaver
	triggerStatus:Trigger(false)
	trigger_mainPanelStatus.missedGameAddress  	 = trigger.address
	trigger_mainPanelStatus.isRewarding			 = trigger.isRewarding
	trigger_mainPanelStatus.leftLastGame		 = trigger.hasLeaver
	trigger_mainPanelStatus:Trigger(false)
end, true, nil, 'address', 'isRewarding', 'hasLeaver')

LuaTrigger.CreateCustomTrigger('craftingCraftInfo',
	{
		{ name	= 'componentCost',				type	= 'number'},
		{ name	= 'minComponentCost',			type	= 'number'},
		{ name	= 'oreCount',					type	= 'number'},
		{ name	= 'oreCost',					type	= 'number'},
		{ name	= 'gemCost',					type	= 'number'},
		{ name	= 'entity',						type	= 'string'},
		{ name	= 'id',							type	= 'string'},
		{ name	= 'selectedComponentIndex',		type	= 'number'},
		{ name	= 'requestStatusCraftItem',		type	= 'number'},
		{ name	= 'requestStatusSalvageItem',	type	= 'number'},
		{ name	= 'selectedDurationDays',		type	= 'number'},
		{ name	= 'isExistingItem',				type	= 'boolean'},
	}
)

local mainPetsMode = LuaTrigger.CreateCustomTrigger(
	'mainPetsMode',
	{
		{ name	= 'selectedPetID',					type = 'number' 	},
		{ name	= 'selectedPassiveIndex',			type = 'number'		},
		{ name	= 'selectedPassiveID',				type = 'string'		},
		{ name	= 'selectedPetSkin',				type = 'string'		},
		{ name	= 'selectedPetSkinIndex',			type = 'number'		},
		{ name	= 'petSkinHovering',				type = 'string'		},
		{ name	= 'petSkinHoveringIndex',			type = 'number'		},
		{ name	= 'selectedPetSkinOwned',			type = 'string'		},
		{ name	= 'selectedPetSkinCost',			type = 'number'		},
		{ name	= 'hoverAbilityID',					type = 'number'		}
	}
)

mainPetsMode.selectedPetSkinIndex = 2
mainPetsMode.petSkinHoveringIndex = -1
mainPetsMode.selectedPetSkin = ''
mainPetsMode.petSkinHovering = ''
mainPetsMode.selectedPetSkinOwned = ''
mainPetsMode.selectedPetSkinCost = -1

local itemInfoDrag = LuaTrigger.CreateCustomTrigger('itemInfoDrag',
	{
		{ name	= 'triggerName',						type	= 'string' },
		{ name	= 'triggerIndex',						type	= 'string' },
		{ name	= 'type',								type	= 'string' },
		{ name	= 'entityName',							type	= 'string' },
	}
)

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
		{ name	= 'clientDraggingIsInGame',				type	= 'boolean' },
		{ name	= 'clientDraggingIsInLobby',			type	= 'boolean' },
		{ name	= 'clientDraggingCanSpectate',			type	= 'boolean' },
		{ name	= 'clientDraggingIsHoveringMenu',		type	= 'boolean' },
		{ name 	= 'clientDraggingIsOnline',				type	= 'boolean' },
		{ name	= 'dragActive',							type	= 'boolean' },
		{ name	= 'joinableGame',						type	= 'boolean' },
		{ name	= 'joinableParty',						type	= 'boolean' },
		{ name	= 'spectatableGame',					type	= 'boolean' },

	}
)

local mainPanelStatusDragInfo = LuaTrigger.GetTrigger('mainPanelStatusDragInfo') or LuaTrigger.CreateGroupTrigger('mainPanelStatusDragInfo', {'mainPanelStatus', 'globalDragInfo', 'clientInfoDrag', 'itemInfoDrag'} )

local endMatchRewardsStatus	= LuaTrigger.CreateCustomTrigger('endMatchRewardsStatus', {
	{ name	= 'chestsOpened',				type	= 'number' },	-- This session
	{ name	= 'chestGameInitiated',			type	= 'number' },
	{ name	= 'closed',						type	= 'number' },
	{ name	= 'chestThreadActive',			type	= 'boolean' },
})

local notificationsTrigger = LuaTrigger.GetTrigger('notificationsTrigger') or LuaTrigger.CreateCustomTrigger('notificationsTrigger',
	{
		{ name	= 'popupActive',				type	= 'bool' },
		{ name	= 'questRewards',				type	= 'number' },
		{ name	= 'spinNotifications',			type	= 'number' },
		{ name	= 'partyInvites',				type	= 'number' },
		{ name	= 'clanInvites',				type	= 'number' },
		{ name	= 'lobbyInvites',				type	= 'number' },
		{ name	= 'miscNotifications',			type	= 'number' },
		{ name	= 'incomingChallenges',			type	= 'number' },
	}
)

local partyComboTrigger 		= LuaTrigger.GetTrigger('PartyComboStatus') or libGeneral.createGroupTrigger('PartyComboStatus', {'PartyStatus', 'PartyTrigger', 'clientInfoDrag', 'mainPanelAnimationStatus.main', 'mainPanelStatus.main', 'selection_Status.selectionSection', 'notificationsTrigger.partyInvites'} )

-- Don't care that this initializes before widgets are watching.
endMatchRewardsStatus.chestsOpened			= 0
endMatchRewardsStatus.chestGameInitiated	= 0
endMatchRewardsStatus.closed				= 0
endMatchRewardsStatus.chestThreadActive				= false
endMatchRewardsStatus:Trigger(true)

LuaTrigger.CreateCustomTrigger('socialPanelInfoHovering',
	{
		{ name	= 'friendHoveringIndex',				type	= 'number' },
		{ name	= 'friendHoveringIdentID',				type	= 'string' },
		{ name	= 'friendHoveringUniqueID',				type	= 'string' },
		{ name	= 'friendHoveringName',					type	= 'string' },
		{ name	= 'friendHoveringAcceptStatus',			type	= 'string' },
		{ name	= 'friendHoveringGameAddress',			type	= 'string' },
		{ name	= 'friendHoveringLabel',				type	= 'string' },
		{ name	= 'friendHoveringWidgetIndex',			type	= 'number' },
		{ name	= 'friendHoveringIsPending',			type	= 'boolean' },
		{ name	= 'friendHoveringIsInParty',			type	= 'boolean' },
		{ name	= 'friendHoveringIsInLobby',			type	= 'boolean' },
		{ name	= 'friendHoveringIsInGame',				type	= 'boolean' },
		{ name	= 'friendHoveringCanSpectate',			type	= 'boolean' },
		{ name	= 'friendHoveringIsHoveringMenu',		type	= 'boolean' },
		{ name 	= 'friendHoveringIsOnline',				type	= 'boolean' },
		{ name 	= 'friendHoveringType',					type	= 'number' },
		{ name 	= 'friendHoveringSubType',				type	= 'string' },
		{ name	= 'joinableGame',						type	= 'boolean' },
		{ name	= 'joinableParty',						type	= 'boolean' },
		{ name	= 'spectatableGame',					type	= 'boolean' },
	}
)

LuaTrigger.CreateCustomTrigger('socialPanelInfo',
	{
		{ name	= 'friendsListUserOpen',		type	= 'boolean' },
		{ name	= 'friendsListOpen',			type	= 'boolean' },
		{ name	= 'friendsListReOrderLock',		type	= 'boolean' },
		{ name	= 'friendsListSingleUpdate',	type	= 'boolean' },
		{ name	= 'friendsListQueueUpdate',		type	= 'boolean' },
		{ name	= 'friendHoveringIndex',		type	= 'number' },
		{ name	= 'friendHoveringWidgetIndex',	type	= 'number' },
		{ name	= 'partyListReOrderLock',		type	= 'boolean' },
		{ name	= 'partyListQueueUpdate',		type	= 'boolean' },
		{ name	= 'partyListSingleUpdate',		type	= 'boolean' },
	}
)

local AccountProgression = LuaTrigger.GetTrigger('AccountProgression') or LuaTrigger.CreateCustomTrigger('AccountProgression',
	{
		{ name	= 'update',						type	= 'boolean' },
		{ name	= 'newLevelUp',					type	= 'boolean' },
		{ name	= 'experience',					type	= 'number' },
		{ name	= 'newExperience',				type	= 'number' },
		{ name	= 'lastExperience',				type	= 'number' },
		{ name	= 'level',						type	= 'number' },
		{ name	= 'lastLevel',					type	= 'number' },
		{ name	= 'percentToNextLevel',			type	= 'number' },
		{ name	= 'experienceToNextLevel',		type	= 'number' },
		{ name	= 'petLevel',					type	= 'number' },
		{ name	= 'percentToNextPetLevel',		type	= 'number' },
		{ name	= 'accountLevelForNextPetLevel',		type	= 'number' },
		{ name	= 'petAbilityLevel1',			type	= 'number' },
		{ name	= 'petAbilityLevel2',			type	= 'number' },
		{ name	= 'petAbilityLevel3',			type	= 'number' },
	}
)
AccountProgression.update 					= false
AccountProgression.newLevelUp 				= false
AccountProgression.experience 				= 0
AccountProgression.newExperience 			= 0
AccountProgression.lastExperience 			= 0
AccountProgression.level 					= 0
AccountProgression.lastLevel 				= 0
AccountProgression.percentToNextLevel 		= 0
AccountProgression.experienceToNextLevel 	= 0
AccountProgression.petLevel 				= 0
AccountProgression.percentToNextPetLevel	= 0
AccountProgression.accountLevelForNextPetLevel	= 0
AccountProgression.petAbilityLevel1			= 0
AccountProgression.petAbilityLevel2			= 0
AccountProgression.petAbilityLevel3			= 0

local updateHealthColors = LuaTrigger.CreateCustomTrigger('updateHealthColors',{})

local optionsTrigger = LuaTrigger.CreateCustomTrigger('optionsTrigger',
	{
		{ name	= 'updateVisuals',				type	= 'bool' },
		{ name	= 'hasChanges',					type	= 'bool' },
		{ name	= 'isSynced',					type	= 'bool' },
	}
)

LuaTrigger.CreateCustomTrigger('questsTrigger',
	{
		{ name	= 'hasQuestData',				type	= 'bool' },
		{ name	= 'selectedDisplayType',		type	= 'string' },
		{ name	= 'searchString',				type	= 'string' },
		{ name	= 'unclaimedQuestRewards',		type	= 'number' },
		{ name	= 'count0',						type	= 'number' },
		{ name	= 'count1',						type	= 'number' },
		{ name	= 'count2',						type	= 'number' },
		{ name	= 'count3',						type	= 'number' },
		{ name	= 'count4',						type	= 'number' },
	}
)

LuaTrigger.CreateCustomTrigger('playerProfileInfo',
	{
		{ name	= 'currentDragIndex',	type	= 'number'},
		{ name	= 'currentDragType',	type	= 'number'},
		{ name	= 'column1Count',		type	= 'number'},
		{ name	= 'column2Count',		type	= 'number'},
		{ name	= 'globalDragActive',	type	= 'boolean'},
		{ name	= 'globalDragType',		type	= 'number'},
		{ name	= 'viewingSelf',		type	= 'boolean' },
		{ name	= 'section',			type	= 'number'},
		{ name	= 'questCount',			type	= 'number'},
	}
)

LuaTrigger.CreateCustomTrigger('playerProfileAnimStatus',
	{
		{ name	= 'section',			type	= 'string'},
		{ name	= 'viewingSelf',		type	= 'boolean' },
	}
)

LuaTrigger.CreateCustomTrigger('playerRankInfo', {
		{ name	= 'division',			type	= 'string'},
		{ name	= 'rank',				type	= 'number' },
		{ name	= 'rankedUnlocked',		type	= 'boolean' },
})
