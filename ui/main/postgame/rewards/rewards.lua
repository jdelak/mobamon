local interface = object
PostGame = PostGame or {}
PostGame.Rewards = PostGame.Rewards or {}
local mainPanelStatus							= LuaTrigger.GetTrigger('mainPanelStatus')
local PostGameLoopStatus						= LuaTrigger.GetTrigger('PostGameLoopStatus')
local AccountProgression 			= LuaTrigger.GetTrigger('AccountProgression')
local tinsert = table.insert
PostGame.Rewards.rewardData						= nil
PostGame.Rewards.lastGetRewardChestsMatchID 	= -1
PostGame.Rewards.openAnotherChestCost 			= 15
PostGame.Rewards.chestCount						= 1

local function playRewardsRegister(object)

	if Strife_Region.regionTable and Strife_Region.regionTable[Strife_Region.activeRegion] and Strife_Region.regionTable[Strife_Region.activeRegion].useAntiAbuse then
		object:GetWidget('playRewards_addiction_parent_label_1'):SetText(Translate('rewards_abuse_status_0'))
		object:GetWidget('playRewards_addiction_parent_label_2'):SetText(Translate('rewards_abuse_stauts_0_desc'))
	end

	local postgame_rewards_insert_game_rewards 					= 	GetWidget('postgame_rewards_insert_game_rewards')
	local postgame_rewards_insert_game_rewards_insert 			= 	GetWidget('postgame_rewards_insert_game_rewards_insert')

	local rewardIndex = 0
	local centeredRewards = {}
	local centeredQuests = {}
	
	local function ClearCenterSpaceIfNeeded(alwaysNeeded)

		if (alwaysNeeded) or (centeredRewards and centeredQuests and ((#centeredRewards + #centeredQuests) >= 4)) then
			

		end
		
		if (centeredQuests and (#centeredQuests >= 4)) then

		end		
		
	end			
	
	local displayRewardThread
	local function DisplayReward(rewardTables, destination)
		for index, rewardTable in ipairs(rewardTables) do
			
			rewardIndex = rewardIndex + 1
			local prizeWidgets = postgame_rewards_insert_game_rewards_insert:InstantiateAndReturn('postgame_summary_game_award_template',
				'index', rewardIndex,
				'prizeIcon', rewardTable[2] or '$checker',
				'prizeLabel', rewardTable[1] or 'Missing',
				'title', (rewardTable[3]) or '',
				'desc', (rewardTable[4]) or '',
				'group', 'postgame_reward_prize_template',
				'visible', '1'
			)
			local prizeParent = prizeWidgets[1]
			tinsert(centeredRewards, {prizeParent, destination})
			
			local function flairEffect(widget, width, height, duration)
				if (displayRewardThread) then
					displayRewardThread:kill()
					displayRewardThread = nil
				end
				displayRewardThread = libThread.threadFunc(function()	
					widget:SetVisible(0)
					libAnims.bounceIn(widget, width * 1.0, height * 1.0, true, duration, 0.05, 200, 0.8, 0.2)
					displayRewardThread = nil
				end)
			end				
			
			flairEffect(prizeParent, prizeParent:GetWidth(), prizeParent:GetHeight(), PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier)

		end			
	end	
	
	local function SpawnRewards(responseData)
		local rewardData = responseData.reward			
		local boostModifier = responseData.boostRewards or 1
		boostModifier = boostModifier -	1 -- remove base 100%		
		
		if (rewardData) then

			postgame_rewards_insert_game_rewards:SetVisible(1)
			
			-- Commodity Rewards
			local tier 					= tonumber(rewardData.currentTier) or 0
			local ore 					= tonumber(rewardData.currentOre) or 0
			local oreBonus 				= tonumber(math.ceil(boostModifier * ore)) or 0
			local essence 				= tonumber(rewardData.currentEssence) or 0
			local essenceBonus 			= tonumber(math.ceil(boostModifier * essence)) or 0
			local food 					= tonumber(rewardData.currentFood) or 0
			local foodBonus 			= tonumber(math.ceil(boostModifier * food)) or 0
			local shards 				= tonumber(rewardData.currentShards) or 0
			local shardsBonus 			= tonumber(math.ceil(boostModifier * shards)) or 0
			local gems 					= tonumber(rewardData.currentGems) or 0
			local gemsBonus				= tonumber(math.ceil(boostModifier * gems)) or 0

			local commodityAmounts	= {
				{name = 'ore', value = ore, bonus = oreBonus},
				{name = 'essence', value = essence, bonus = essenceBonus},
				{name = 'food', value = food, bonus = foodBonus}, 
				{name = 'shards', value = shards, bonus = shardsBonus}, 
				{name = 'gems', value = gems, bonus = gemsBonus},
			}					
			
			local rewardTables = {}
			for index, commodityTable in pairs(commodityAmounts) do
				local commodity 	= commodityTable.name
				local bonus 		= commodityTable.bonus
				local value 		= commodityTable.value + bonus
				if (value) and (tonumber(value) > 0) then
					if (bonus) and (tonumber(bonus) > 0) then
						if (tonumber(value) > 1) then
							table.insert(rewardTables, {Translate('general_commodity_' .. commodity .. '_x', 'value', value).. '\n' ..Translate('general_commodity_bonus_x', 'bonus', bonus), Translate('general_commodity_texture_' .. commodity)})
						else
							table.insert(rewardTables, {Translate('general_commodity_' .. commodity .. '_x_single', 'value', value).. '\n' ..Translate('general_commodity_bonus_x', 'bonus', bonus), Translate('general_commodity_texture_' .. commodity)})
						end
					else
						if (tonumber(value) > 1) then
							table.insert(rewardTables, {Translate('general_commodity_' .. commodity .. '_x', 'value', value), Translate('general_commodity_texture_' .. commodity)})
						else
							table.insert(rewardTables, {Translate('general_commodity_' .. commodity .. '_x_single', 'value', value), Translate('general_commodity_texture_' .. commodity)})
						end
					end
				end
			end			

			if (rewardTables) and (#rewardTables > 0) then
				DisplayReward(rewardTables, 'rewards')
			end
			
			-- Commodity Rewards Addiction
			local addictedLevel = tonumber(rewardData.addictedLevel) or 0

			if (addictedLevel) and (addictedLevel > 1) then
				GetWidget('playRewards_addiction_parent'):FadeIn(250)
				GetWidget('playRewards_addiction_parent_label_1'):SetText(Translate('addiction_status_' .. addictedLevel))
				GetWidget('playRewards_addiction_parent_label_2'):SetText(Translate('addiction_status_' .. addictedLevel .. '_desc'))
			else
				GetWidget('playRewards_addiction_parent'):FadeOut(250)
			end

		end			
	end
	
	function PostGame.Rewards.ClaimReward(index)

		local function successFunction(request)	-- response handler
			local responseData = request:GetBody()
			if responseData == nil then
				trigger_postGameLoopStatus.isClaimingChest = false
				trigger_postGameLoopStatus.requestingClaimReward = false
				trigger_postGameLoopStatus:Trigger(false)				
				SevereError('No ClaimReward Data', 'main_reconnect_thatsucks', '', nil, nil, false)
				return nil
			else
				trigger_postGameLoopStatus.isClaimingChest = false
				trigger_postGameLoopStatus.rewardsClaimed = true
				trigger_postGameLoopStatus.requestingClaimReward = false
				trigger_postGameLoopStatus:Trigger(false)
				PostGame.Rewards.claimRewardResponseData = responseData
				PostGame.Splash.modules.claimRewardResponseData = responseData
				
				SpawnRewards(responseData)
			end
		end

		local function failFunction(request)	-- error handler
			local PostGameLoopStatus	= LuaTrigger.GetTrigger('PostGameLoopStatus')
			PostGameLoopStatus.isClaimingChest = false
			PostGameLoopStatus.requestingClaimReward = false
			PostGameLoopStatus:Trigger(false)
			return nil
		end

		local PostGameLoopStatus	= LuaTrigger.GetTrigger('PostGameLoopStatus')
		PostGameLoopStatus.requestingClaimReward = true
		PostGameLoopStatus.isClaimingChest = true
		PostGameLoopStatus:Trigger(false)
	
		Strife_Web_Requests:ClaimReward(successFunction, failFunction, PostGame.Rewards.lastGetRewardChestsMatchID, index)
	end

	function PostGame.Rewards.ProcessData(rewardData, matchid, recievedRewards)
		if (recievedRewards) and (rewardData.reward) and (rewardData.reward.match_id) then
			if (PostGame.Rewards.openAnotherChestCost == 0) then
				trigger_postGameLoopStatus.rewardsAvailable = true
				trigger_postGameLoopStatus.rewardsClaimed = false
				trigger_postGameLoopStatus:Trigger(false)

				PostGame.Rewards.lastGetRewardChestsMatchID = rewardData.reward.match_id
				
				PostGame.Rewards.ClaimReward(1)
			else
				println('^r Reward skipped because cost was above 0')
				trigger_postGameLoopStatus.rewardsAvailable  = false
				trigger_postGameLoopStatus:Trigger(false)
				-- Kill this reward if able, it should not exist
				if (PostGame.Rewards.lastGetRewardChestsMatchID) and (tonumber(PostGame.Rewards.lastGetRewardChestsMatchID) > 0) then
					FinishReward(PostGame.Rewards.lastGetRewardChestsMatchID)
				end				
			end
		else
			trigger_postGameLoopStatus.rewardsAvailable  = false
			trigger_postGameLoopStatus:Trigger(false)
		end	
	end	
			
	function PostGame.Rewards.PopulateRewards(object, rewardData)
		local hasReward = false
		
		GetWidget('postgame_rewards_insert_game_rewards'):SetVisible(0)
		groupfcall('postgame_reward_prize_template', function(_, widget) widget:Destroy() end)
		
		if (rewardData) and (rewardData.reward) and  (rewardData.reward.openChestCost) and (rewardData.reward.openChestCost.gems) then
			PostGame.Rewards.openAnotherChestCost = rewardData.reward.openChestCost.gems
		else
			PostGame.Rewards.openAnotherChestCost = 0
		end	
		
		for i=1,PostGame.Rewards.chestCount,1 do
			if (rewardData.reward['displayBox'..i]) and (tonumber(rewardData.reward['displayBox'..i]) >= 1) then
				hasReward = true
				break
			end
		end 
		
		if (hasReward) then
			PostGame.Rewards.ProcessData(rewardData, matchid, true) -- endMatchRewardDataTemp
		else
			PostGame.Rewards.ProcessData(rewardData, matchid, false)
			println(Translate('endmatch_norewards', 'matchid', tostring(rewardData.reward.match_id)))
			-- SevereError(Translate('endmatch_norewards', 'matchid', tostring(rewardData.reward.match_id)), 'main_reconnect_thatsucks', '', nil, nil, false)
		end
	end		
		
	function PostGame.Rewards.TestRewards()
		SpawnRewards({
			reward = {
				currentTier = 10,
				currentOre = 10,
				currentFood = 10,
			},
			commodities = {
				ore = 0,
				food = 0,
				gems = 0,
				essence = 0,
			}
		})
	end	

end

playRewardsRegister(object)