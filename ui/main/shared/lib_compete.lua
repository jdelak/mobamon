mainUI = mainUI or {}
mainUI.savedLocally = mainUI.savedLocally or {}
mainUI.savedLocally.lib_compete = mainUI.savedLocally.lib_compete or {}

-- Sit and Go, Ranked Play Lib

-- ===============================================================
-- ============ Move to some centralized location later ==========
-- ===============================================================

local function webRequestSuccessPreprocessRequest(request, requestName)
	requestName = requestName or 'Undefined Request'
	if request then	-- Later on I'd like to distill this to knowing at least what type this will be
		local responseData = request:GetBody()
		if responseData ~= nil then
			return responseData
		else
			SevereError(requestName..' - no response data', 'main_reconnect_thatsucks', '', nil, nil, false)
		end
	else
		SevereError('preprocessWebRequestSuccess ('..requestName..') - not a valid request', 'main_reconnect_thatsucks', '', nil, nil, false)
	end

	return false
end

local function webRequestFailPreprocessRequest(request, requestName)
	println('^r webRequestFailPreprocessRequest ' .. tostring(requestName))
end

local WEB_STATUS_NONE		= 0
local WEB_STATUS_SUCCESS	= 1
local WEB_STATUS_FAILURE	= 2
local WEB_STATUS_NOSTART	= 3

-- ===============================================================

local getActiveTeamsAndCompletedTournamentsStatus = LuaTrigger.GetTrigger('getActiveTeamsAndCompletedTournamentsStatus') or LuaTrigger.CreateCustomTrigger('getActiveTeamsAndCompletedTournamentsStatus', {
	{ name	= 'busy',		type	= 'boolean' },
	{ name	= 'lastStatus', type	= 'number' },
})

getActiveTeamsAndCompletedTournamentsStatus.busy			= false
getActiveTeamsAndCompletedTournamentsStatus:Trigger(true)
getActiveTeamsAndCompletedTournamentsStatus.lastStatus		= WEB_STATUS_NONE		-- None, Success, Failure, Could not Initiate Request

-- ===============================================================

local getRankedRatingStatus = LuaTrigger.GetTrigger('getRankedRatingStatus') or LuaTrigger.CreateCustomTrigger('getRankedRatingStatus', {
	{ name	= 'busy',		type	= 'boolean' },
	{ name	= 'lastStatus', type	= 'number' },
})

getRankedRatingStatus.busy			= false
getRankedRatingStatus:Trigger(true)
getRankedRatingStatus.lastStatus		= WEB_STATUS_NONE		-- None, Success, Failure, Could not Initiate Request

-- ===============================================================

local getTeamByMembersStatus = LuaTrigger.GetTrigger('getTeamByMembersStatus') or LuaTrigger.CreateCustomTrigger('getTeamByMembersStatus', {
	{ name	= 'busy',		type	= 'boolean' },
	{ name	= 'lastStatus', type	= 'number' },
})

getTeamByMembersStatus.busy			= false
getTeamByMembersStatus:Trigger(true)
getTeamByMembersStatus.lastStatus		= WEB_STATUS_NONE		-- None, Success, Failure, Could not Initiate Request

-- ===============================================================

local getHeroRatingsStatus = LuaTrigger.GetTrigger('getHeroRatingsStatus') or LuaTrigger.CreateCustomTrigger('getHeroRatingsStatus', {
	{ name	= 'busy',		type	= 'boolean' },
	{ name	= 'lastStatus', type	= 'number' },
})

getHeroRatingsStatus.busy			= false
getHeroRatingsStatus:Trigger(true)
getHeroRatingsStatus.lastStatus		= WEB_STATUS_NONE		-- None, Success, Failure, Could not Initiate Request

-- ===============================================================

libCompete = libCompete or {}

libCompete.divisions	= {
	{
		key		= 'provisional',
		icon	= '/ui/main/shared/textures/elo_rank_0.tga',
	},
	{
		key		= 'slate',
		icon	= '/ui/main/shared/textures/elo_rank_1.tga',
	},	
	{
		key		= 'bronze',
		icon	= '/ui/main/shared/textures/elo_rank_2.tga',
	},
	{
		key		= 'silver',
		icon	= '/ui/main/shared/textures/elo_rank_3.tga',
	},
	{
		key		= 'gold',
		icon	= '/ui/main/shared/textures/elo_rank_4.tga',
	},
	{
		key		= 'diamond',
		icon	= '/ui/main/shared/textures/elo_rank_5.tga',
	}
}

libCompete.divisionNumberByName = {}

for k,v in ipairs(libCompete.divisions) do
	libCompete.divisionNumberByName[v.key] = k
end

libCompete.divisions.provisional 	= libCompete.divisions[1]
libCompete.divisions.slate 			= libCompete.divisions[2]
libCompete.divisions.bronze 		= libCompete.divisions[3]
libCompete.divisions.silver 		= libCompete.divisions[4]
libCompete.divisions.gold 			= libCompete.divisions[5]
libCompete.divisions.diamond 		= libCompete.divisions[6]

libCompete.khanquest = libCompete.khanquest or {
	activeTeams			= {},
	tournamentHistory	= {},
	maxLosses			= 2,	-- Reach this and the tournament is closed
	seatCostTokens		= 1,
	seatCostGems		= 20
}
libCompete.ranked	= {}	-- This may not be used

function libCompete.isValidPercentile(percentile)
	return (percentile and type(percentile) == 'number')
end

function libCompete.isValidDivision(division)
	return (division and (type(division) == 'number' or (type(division) == 'string' and string.len(division) > 0)) and libCompete.divisions[division])
end

function libCompete.khanquest.validForPostgame()
	return false
end

function libCompete.ranked.populateHeroRank(hero, division, rank, wins, gamesAboveBracket, gamesBelowBracket, seasonWins, seasonLosses)
	-- local rank = tonumber(rank)

	-- local divisionInfo = libCompete.getDivisionInfo(division)
	
	-- if divisionInfo then
		-- if libCompete.isValidPercentile(rank) then
			
			-- local wins 			= wins or 0
			-- local seasonWins 	= seasonWins or 0
			-- local winsReq 		= GetCvarNumber('ui_rankedMatchesRequired', true) or 5
			
			-- mainUI 													= mainUI or {}
			-- mainUI.savedLocally 									= mainUI.savedLocally or {}
			-- mainUI.savedLocally.lib_compete 						= mainUI.savedLocally.lib_compete or {}								
			-- mainUI.savedLocally.lib_compete.heroRankings			= mainUI.savedLocally.lib_compete.heroRankings or {}								
			-- mainUI.savedLocally.lib_compete.heroRankings[hero]		= mainUI.savedLocally.lib_compete.heroRankings[hero] or {}								
						
			-- PostGame 																	= PostGame or {}
			-- PostGame.Splash 															= PostGame.Splash or {}		
			-- PostGame.Splash.modules 													= PostGame.Splash.modules or {}	
			-- PostGame.Splash.modules.rankedPlayProgression 								= PostGame.Splash.modules.rankedPlayProgression or {}
			-- PostGame.Splash.modules.rankedPlayProgression[hero] 						= PostGame.Splash.modules.rankedPlayProgression[hero] or {}
			
			-- if ((PostGame.Splash.modules.rankedPlayProgression[hero].lastRank) and (PostGame.Splash.modules.rankedPlayProgression[hero].lastRank ~= rank)) or ((PostGame.Splash.modules.rankedPlayProgression[hero].lastDivision) and (PostGame.Splash.modules.rankedPlayProgression[hero].lastDivision ~= division)) then
				-- trigger_postGameLoopStatus.rankedProgressAvailable	 	= true
				-- trigger_postGameLoopStatus:Trigger(false)
			-- end

			-- mainUI.progression.stats.heroes[hero] 								= mainUI.progression.stats.heroes[hero] or {}			
			-- mainUI.progression.stats.heroes[hero]['ranked_provMatchesRem'] 		= winsReq - seasonWins				
			-- mainUI.progression.stats.heroes[hero].gamesAboveBracket 			= gamesAboveBracket		
			-- mainUI.progression.stats.heroes[hero].gamesBelowBracket 			= gamesBelowBracket		
			
			-- if (mainUI.progression.stats.heroes[hero]['ranked_provMatchesRem']) and (mainUI.progression.stats.heroes[hero]['ranked_provMatchesRem'] > 0) then
				-- PostGame.Splash.modules.rankedPlayProgression[hero].lastRank 		= mainUI.savedLocally.lib_compete.heroRankings[hero].lastRank 		or 1000
				-- PostGame.Splash.modules.rankedPlayProgression[hero].lastDivision 	= mainUI.savedLocally.lib_compete.heroRankings[hero].lastDivision 	or 'provisional'
		
				-- mainUI.savedLocally.lib_compete.heroRankings[hero].lastRank 		= 1000 
				-- mainUI.savedLocally.lib_compete.heroRankings[hero].lastDivision 	= 'provisional'				
				
				-- mainUI.progression.stats.heroes[hero]['ranked_division'] 			= 'provisional'					
				-- mainUI.progression.stats.heroes[hero]['ranked_rank'] 				= 1000	
			-- else
				-- PostGame.Splash.modules.rankedPlayProgression[hero].lastRank 		= mainUI.savedLocally.lib_compete.heroRankings[hero].lastRank 		or rank
				-- PostGame.Splash.modules.rankedPlayProgression[hero].lastDivision 	= mainUI.savedLocally.lib_compete.heroRankings[hero].lastDivision 	or division
		
				-- mainUI.savedLocally.lib_compete.heroRankings[hero].lastRank 		= rank 
				-- mainUI.savedLocally.lib_compete.heroRankings[hero].lastDivision 	= division 	
				
				-- mainUI.progression.stats.heroes[hero]['ranked_division'] 			= division					
				-- mainUI.progression.stats.heroes[hero]['ranked_rank'] 				= rank				
			-- end

		-- else
			-- printdb(debug.getinfo(value[2])..' - Invalid rank.')
		-- end
	-- else
		-- printdb(debug.getinfo(value[2])..' - No division info.')
	-- end
end

function libCompete.ranked.populateRank(division, rank)
	local funcName = 'libCompete.ranked.populateRank'
	local divisionInfo = libCompete.getDivisionInfo(division)
	
	if divisionInfo then
		if libCompete.isValidPercentile(rank) then
			local playerRankInfo = LuaTrigger.GetTrigger('playerRankInfo')
			playerRankInfo.division			= division
			playerRankInfo.rank				= rank
			playerRankInfo.rankedUnlocked	= true
			playerRankInfo:Trigger(false)
			
			SaveState()

		else
			printdb(funcName..' - Invalid rank.')
		end
	else
		printdb(funcName..' - No division info.')
	end
end

-- 0, 1, 2 = safe, warning, loss
-- Later on if we expand how many losses we may require additional states or push warning/loss out

function libCompete.khanquest.getTournamentIDFromTournamentIndex(tournamentIndex)	-- Later on we'll strip ident from it
	return tournamentIndex
end

function libCompete.khanquest.displaySelectedTournament(tournamentInfo)
	local funcName = 'libCompete.khanquest.displaySelectedTournament'

	if tournamentInfo and type(tournamentInfo) == 'table' then
		
	else
		printdb(funcName..' - No tournament info.')
	end
end

function libCompete.khanquest.processTeamInfo(teamInfo)
	local funcName = 'libCompete.khanquest.displaySelectedTournament'

	if teamInfo and type(teamInfo) == 'table' then
		
	else
		printdb(funcName..' - No team info.')
	end
end

function libCompete.khanquest.processTournamentInfo(tournamentInfo)

end

function libCompete.khanquest.processTournamentHistory(tournamentHistory)
	local tournamentList = tournamentList or {}
	for k,tournamentInfo in ipairs(tournamentList) do
		libCompete.khanquest.processTournamentInfo(tournamentInfo)
	end
end

function libCompete.khanquest.processActiveTeams(activeTeams)
	local teamList = teamList or {}
	for k,teamInfo in ipairs(teamList) do
		libCompete.khanquest.processTeamInfo(teamInfo)
	end
end

function libCompete.ranked.getTeamByMembers(successCallback, identID1, identID2, identID3, identID4, identID5)
	local requestName = 'libCompete.ranked.getTeamByMembers'
	
	local function successFunction(request)
		local responseData = webRequestSuccessPreprocessRequest(request, requestName)
		if responseData == false then
			getTeamByMembersStatus.lastStatus = WEB_STATUS_FAILURE
		else
			getTeamByMembersStatus.lastStatus = WEB_STATUS_SUCCESS

			if successCallback and type(successCallback) == 'function' then
				successCallback(responseData)
			end
		end
		
		getTeamByMembersStatus.busy = false
		getTeamByMembersStatus:Trigger(false)
	end
	
	local function failFunction(request)
		getTeamByMembersStatus.busy = false
		getTeamByMembersStatus.lastStatus = WEB_STATUS_FAILURE
		getTeamByMembersStatus:Trigger(false)

		return webRequestFailPreprocessRequest(request, requestName)
	end
	
	getTeamByMembersStatus.busy = true
	getTeamByMembersStatus:Trigger(false)
	
	local webRequestOccurred = Strife_Web_Requests:GetTeamByMembers(successFunction, failFunction, identID1, identID2, identID3, identID4, identID5)
	
	if webRequestOccurred then
		return true
	else
		printdb(requestName..' - Unable to initiate web request.')

		getTeamByMembersStatus.busy = false
		getTeamByMembersStatus.lastStatus = WEB_STATUS_NOSTART
		getTeamByMembersStatus:Trigger(false)
	end
	
	return false
end

function libCompete.khanquest.getActiveTeamsAndCompletedTournaments(successCallback)
	local requestName = 'libCompete.khanquest.getActiveTeamsAndCompletedTournaments'

	local function successFunction(request)
		local responseData = webRequestSuccessPreprocessRequest(request, requestName)
		if responseData == false then
			getActiveTeamsAndCompletedTournamentsStatus.lastStatus = WEB_STATUS_FAILURE
		else
			getActiveTeamsAndCompletedTournamentsStatus.lastStatus = WEB_STATUS_SUCCESS
			
			if successCallback and type(successCallback) == 'function' then
				successCallback(responseData)
			end
		end

		getActiveTeamsAndCompletedTournamentsStatus.busy = false
		getActiveTeamsAndCompletedTournamentsStatus:Trigger(false)
	end
	
	local function failFunction(request)
		getActiveTeamsAndCompletedTournamentsStatus.busy = false
		getActiveTeamsAndCompletedTournamentsStatus.lastStatus = WEB_STATUS_FAILURE
		getActiveTeamsAndCompletedTournamentsStatus:Trigger(false)

		return webRequestFailPreprocessRequest(request, requestName)
	end
	
	getActiveTeamsAndCompletedTournamentsStatus.busy = true
	getActiveTeamsAndCompletedTournamentsStatus:Trigger(false)
	
	local webRequestOccurred = Strife_Web_Requests:GetActiveTeamsAndCompletedTournaments(successFunction, failFunction)
	
	if webRequestOccurred then
		
	else
		printdb(requestName..' - Unable to initiate web request.')

		getActiveTeamsAndCompletedTournamentsStatus.busy = false
		getActiveTeamsAndCompletedTournamentsStatus.lastStatus = WEB_STATUS_NOSTART
		getActiveTeamsAndCompletedTournamentsStatus:Trigger(false)
	end
	
	return false
end

--[[
function libCompete.khanquest.getTeamInfo(teamID)
	local requestName = 'libCompete.khanquest.getTeamInfo'

	if teamID and type(teamID) == 'number' then
	
		local function successFunction(request)
			
			local responseData = webRequestSuccessPreprocessRequest(request, requestName)
			if responseData ~= false then
				printr(responseData)
			end
		end
		
		local function failFunction(request)
			return webRequestFailPreprocessRequest(request, requestName)
		end
		
		local webRequestOccurred = Strife_Web_Requests:khanquest_GetTeamInfo(successFunction, failFunction, teamID)
	
		if webRequestOccurred then
		else
			printdb(requestName..' - Unable to initiate web request.')
		end
	else
		printdb(requestName..' - invalid teamID.')
	end
	
	return false
end


function libCompete.khanquest.getTournamentInfo(tournamentID)
	local requestName = 'libCompete.khanquest.getTournamentInfo'

	if tournamentID and type(tournamentID) == 'number' then
		local function successFunction(request)
			if webRequestSuccessPreprocessRequest(request, requestName) ~= false then
			end
		end
		
		local function failFunction(request)
			return webRequestFailPreprocessRequest(request, requestName)
		end
		
		local webRequestOccurred = Strife_Web_Requests:khanquest_GetTournamentInfo(successFunction, failFunction, tournamentID)
	
		if webRequestOccurred then
		else
			printdb(requestName..' - Unable to initiate web request.')
		end
	else
		printdb(requestName..' - invalid tournamentID.')
	end
	
	return false
end

--]]

function libCompete.khanquest.getLossStatus(losses)
	if losses and type(losses) == 'number' then
		return math.max(0, math.min(libCompete.khanquest.maxLosses, losses))
	else
		printdb('libComplete.khanquest.getLossStatus - invalid losses')
	end
end

function libCompete.khanquest.getRewardFromProgress(progress, matchInfo)
	if progress and type(progress) == 'number' then
		if matchInfo then
			-- ?
		else
			printdb('libCompete.khanquest.getRewardsFromProgress - invalid matchInfo.')
		end
	else
		printdb('libCompete.khanquest.getRewardsFromProgress - invalid progress.')
	end
end

function libCompete.getDivisionInfo(division)
	if libCompete.isValidDivision(division) then
		return libCompete.divisions[division]
	else
		printdb('libCompete.getDivisionInfo - invalid Division ID')
	end
	return false
end