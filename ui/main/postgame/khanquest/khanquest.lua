-- Khanquest Mode (formerly Sit and Go "Tournament" System)
postGame_khanquest = postGame_khanquest or {}

local function postGame_khanquestRegister(object)

	function postGame_khanquestProcessPlayers(playerInfo)
		local selfTeam = {}
		
		-- print('test A =========================\n')
		-- printr(playerInfo)
		
		if playerInfo and type(playerInfo) == 'table' then
		
			-- print('test B =========================\n')
		
			if playerInfo[GetIdentID()] then
			
				-- print('test C =========================\n')
			
				local selfTeamIndex = tonumber(playerInfo[GetIdentID()].team)
				for k,v in pairs(playerInfo) do
					-- print('test D =========================\n')
					if tonumber(v.team) == selfTeamIndex then
						-- print('test E =========================\n')
						table.insert(selfTeam, v.ident_id)
					end
				end
				
				if #selfTeam == 5 then
					-- print('test F =========================\n')
					libCompete.ranked.getTeamByMembers(function(responseData)
						-- printr(responseData)
						if responseData and responseData.team and responseData.team.currentTournament and type(responseData.team.currentTournament) == 'table' then
							println('setting cached progress ================================\n')
							postGame_khanquest.cachedProgress = {
								wins		= tonumber(responseData.team.currentTournament.wins),
								losses		= tonumber(responseData.team.currentTournament.losses),
								complete	= AtoB(responseData.team.currentTournament.complete),
								rewards		= responseData.team.currentTournament.rewards,
								isWin		= AtoB(playerInfo[GetIdentID()].winner)
							}
							PostGame = PostGame or {}
							PostGame.Splash = PostGame.Splash or {}
							PostGame.Splash.modules = PostGame.Splash.modules or {}
							PostGame.Splash.modules.khanquest = true
							printr(postGame_khanquest.cachedProgress)
						end
					end, unpack(selfTeam))
				end
			end
		end
	end
	
	function postGame_khanquestSetCache(wins, losses, complete, rewards, isWin)
		wins		= wins or 3
		losses		= losses or 1
		complete	= false
		if isWin == nil then isWin = true end
		
		postGame_khanquest.cachedProgress = {
			wins		= wins,
			losses		= losses,
			complete	= complete,
			rewards		= rewards,
			isWin		= isWin
		}
	end
	
	function postGame_khanquestRandomCache(winner)
		local didIwin = AtoB(math.random(0,1))
		if (winner ~= nil) then
			didIwin = winner
		end
		local complete = false
		local wins
		if (didIwin) then
			losses = 0
			wins = math.random(1,7)
			if (wins >= 7) then
				complete = true
			else
				complete = false
			end			
		else
			losses = 1
			complete = true
			wins = math.random(0,6)
		end

		postGame_khanquest.cachedProgress = {
			wins		= wins,
			losses		= losses,
			complete	= complete,
			rewards		= {
				reward = {
					currentTier = wins,
					currentOre = 0,
					currentOreBonus = 0,
					currentFood = 10,
					currentFoodBonus = 5,
					currentEssence = 10,
					currentEssenceBonus = 0,
					currentGems = 0,
					currentGemsBonus = 0,
				},
				commodities = {
					ore = 0,
					food = 0,
					gems = 0,
					essence = 0,
				}
			},
			isWin		= didIwin
		}
	end	

	libGeneral.createGroupTrigger('khanquestPostVis', {
		'mainPanelStatus.main',
		'PostGameLoopStatus.screen',
		'PostGameLoopStatus.isKhanquestMatch',
		
	})

end

postGame_khanquestRegister(object)