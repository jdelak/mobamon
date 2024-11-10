PostGame = PostGame or {}
PostGame.Splash = PostGame.Splash or {}
PostGame.Splash.modules = PostGame.Splash.modules or {}
local object = object
local mainPanelStatus				= LuaTrigger.GetTrigger('mainPanelStatus')
local PostGameLoopStatus			= LuaTrigger.GetTrigger('PostGameLoopStatus')
local AccountProgression 			= LuaTrigger.GetTrigger('AccountProgression')
local tinsert = table.insert
PostGame.Splash.animationDelayUnit 			= 1000
PostGame.Splash.animationDelayMultiplier 	= 0.0
PostGame.Splash.animateSplashScreenThread   = nil
PostGame.selfInfo = nil
local MAX_LEVEL = 70
local MIN_LEVEL = 1
local rewardsClaimed 		= 0
MAX_REWARDS_CLAIMABLE		= 8
QUESTS_CAN_BULK_CLAIM		= true

function RankUpAnim(object, lastDivisionIndex, divisionIndex)
	
	local ui_dev_rankup 		= object:GetWidget('ui_dev_rankup')
	local ui_dev_rankup_label 		= object:GetWidget('ui_dev_rankup_label')
	local indexToName 			= {'diamond',  'gold', 'silver', 'bronze', 'slate'}
	
	if (lastDivisionIndex > 5) then -- we don't have effects for this
		lastDivisionIndex = 5
	end
	
	if (divisionIndex > 5) then  -- we don't have effects for this
		divisionIndex = 5
	end	
	
	local function UpdateRank(index, currentRank)
		local parent 		= object:GetWidget('rankUP_item_'..index)
		local model 		= object:GetWidget('rankUP_item_'..index..'_model_1')
		local image1 		= object:GetWidget('rankUP_item_'..index..'_image_1')
		local image2 		= object:GetWidget('rankUP_item_'..index..'_image_2')
		
		if (parent) then
			if (index == currentRank) then
				parent:Scale('100@', '100%', 500)
				model:SetEffect('/ui/main/shared/effects/'..indexToName[index]..'/passive_highlighted.effect')
				image1:SetColor('1 1 1 1')
				image2:SetColor('1 1 1 1')
			else
				parent:Scale('70@', '70%', 500)
				model:SetEffect('/ui/main/shared/effects/'..indexToName[index]..'/passive.effect')
				image1:SetColor('.4 .4 .4 1')
				image2:SetColor('.4 .4 .4 1')			
			end
		end
		
	end
	
	local function UpdateRanks(currentRank)
		for index=1,5,1 do
			UpdateRank(index, currentRank)
		end
	end
	
	libThread.threadFunc(function()
		UpdateRanks(lastDivisionIndex)
		wait(500)
		ui_dev_rankup:FadeIn(250)
		wait(1500)
		UpdateRanks(divisionIndex)
		wait(4500)
		ui_dev_rankup:FadeOut(250)
	end)
	
end

function ShowGiftedCraftedItemSplashScreen(itemEntity, itemComponentEntity1, itemComponentEntity2, itemComponentEntity3, itemImbuement)
	local generic_splash_screen_target = GetWidget('generic_splash_screen_target')
	if (generic_splash_screen_target) then
		
		groupfcall('splash_screens', function(_, groupWidget) groupWidget:Destroy() end)
		
		local headerLabel, contentLabel, itemIcon, itemName, itemDescription, imbuementIcon, imbuementName, imbuementDescription, goldCost, componentName1, componentName2, componentName3, componentIcon1, componentIcon2, componentIcon3, componentStat1, componentStat2, componentStat3, componentValue1, componentValue2, componentValue3

		if (itemEntity) and (not Empty(itemEntity)) and ValidateEntity(itemEntity) then
			itemName = GetEntityDisplayName(itemEntity)
			itemIcon = GetEntityIconPath(itemEntity)						
			Crafting.ClearDesign()
			Crafting.SetDesignRecipe(itemEntity)		
			local itemInfoTable = ShopItem(itemEntity)
			if (itemInfoTable) then
				goldCost = itemInfoTable.cost or ((itemInfoTable.craftingRecipeCost or 0) + (itemInfoTable.craftingComponentCost or 0)) or 0
				itemDescription = itemInfoTable.description
			end
		
			if (itemComponentEntity1) and (not Empty(itemComponentEntity1)) and ValidateEntity(itemComponentEntity1) then
				Crafting.AddDesignComponent(itemComponentEntity1, 0)
				local componentInfo = craftingGetComponentByName(itemComponentEntity1) or Crafting.GetComponents()[itemComponentEntity1]
				componentName1 = GetEntityDisplayName(itemComponentEntity1)
				componentIcon1 = GetEntityIconPath(itemComponentEntity1)					
				if (componentInfo) then
					componentStat1 = componentInfo.displayName
					componentValue1 = math.max(componentInfo.power or 0, math.max(componentInfo.baseAttackSpeed or 0, math.max(componentInfo.maxHealth or 0, math.max(componentInfo.maxMana or 0, math.max(componentInfo.baseHealthRegen or 0, componentInfo.baseManaRegen or 0)))))
				end
			end
			
			if (itemComponentEntity2) and (not Empty(itemComponentEntity2)) and ValidateEntity(itemComponentEntity2) then
				Crafting.AddDesignComponent(itemComponentEntity2, 1)
				local componentInfo = craftingGetComponentByName(itemComponentEntity2) or Crafting.GetComponents()[itemComponentEntity2]
				componentName2 = GetEntityDisplayName(itemComponentEntity2)
				componentIcon2 = GetEntityIconPath(itemComponentEntity2)					
				if (componentInfo) then
					componentStat2 = componentInfo.displayName
					componentValue2 = math.max(componentInfo.power or 0, math.max(componentInfo.baseAttackSpeed or 0, math.max(componentInfo.maxHealth or 0, math.max(componentInfo.maxMana or 0, math.max(componentInfo.baseHealthRegen or 0, componentInfo.baseManaRegen or 0)))))
				end
			end

			if (itemComponentEntity3) and (not Empty(itemComponentEntity3)) and ValidateEntity(itemComponentEntity3) then
				Crafting.AddDesignComponent(itemComponentEntity3, 2)
				local componentInfo = craftingGetComponentByName(itemComponentEntity3) or Crafting.GetComponents()[itemComponentEntity3]
				componentName3 = GetEntityDisplayName(itemComponentEntity3)
				componentIcon3 = GetEntityIconPath(itemComponentEntity3)					
				if (componentInfo) then
					componentStat3 = componentInfo.displayName
					componentValue3 = math.max(componentInfo.power or 0, math.max(componentInfo.baseAttackSpeed or 0, math.max(componentInfo.maxHealth or 0, math.max(componentInfo.maxMana or 0, math.max(componentInfo.baseHealthRegen or 0, componentInfo.baseManaRegen or 0)))))
				end
			end				
			
			if (itemImbuement) and (not Empty(itemImbuement)) and ValidateEntity(itemImbuement) then
				Crafting.SetDesignEmpoweredEffect(itemImbuement)
				Crafting.Save()
				imbuementName = GetEntityDisplayName(itemImbuement)
				imbuementIcon = '/ui/main/crafting/textures/imbue_icon_selected_1.tga'
				imbuementDescription = LuaTrigger.GetTrigger('CraftingUnfinishedDesign').currentEmpoweredEffectDescription
			else
				Crafting.Save()
			end
			
			local temp = generic_splash_screen_target:InstantiateAndReturn('splash_screen_gifted_crafted_item_template',
				'headerLabel', 			headerLabel or '',
				'contentLabel', 		contentLabel or '',
				'itemIcon', 			itemIcon or '$checker',
				'itemName', 			itemName or '',
				'itemDescription', 		itemDescription or '',
				'imbuementIcon', 		imbuementIcon or '$checker',
				'imbuementName', 		imbuementName or '',
				'imbuementDescription', imbuementDescription or '',
				'goldCost', 			goldCost or 0,
				'componentIcon1', 		componentIcon1 or '$checker',
				'componentIcon2', 		componentIcon2 or '$checker',
				'componentIcon3', 		componentIcon3 or '$checker',
				'componentStat1', 		componentStat1 or 0,
				'componentStat2', 		componentStat2 or 0,
				'componentStat3', 		componentStat3 or 0,
				'componentValue1', 		componentValue1 or 0,
				'componentValue2', 		componentValue2 or 0,
				'componentValue3', 		componentValue3 or 0	
			)
			generic_splash_screen_target:FadeIn(250)
			FindChildrenClickCallbacks(temp[1])
		end
	end
end

function TestShowGiftedCraftedItemSplashScreen()
	ShowGiftedCraftedItemSplashScreen('Item_FellBlade', 'Item_Healthstone', 'Item_Healthstone', 'Item_Healthstone', 'Item_FellBlade_Empower_3')
end

local function PostGameInit(object)

	local playRewards_accountboost_icon_parent 	= GetWidget('playRewards_accountboost_icon_parent')
	local playRewards_accountboost_parent 		= GetWidget('playRewards_accountboost_parent')
	local maxMovement = 6	
	local startTime = 0
	
	playRewards_accountboost_icon_parent:SetCallback('onshow', function(widget)
		startTime = LuaTrigger.GetTrigger('System').hostTime
		playRewards_accountboost_icon_parent:RegisterWatchLua('System', function(widget, trigger)
			local scaler = ((((trigger.hostTime - startTime) % 2000)/2000) * 2 * math.pi) +125
			playRewards_accountboost_icon_parent:SetY((-45 + ((-1 * maxMovement / 2) - (maxMovement * math.sin(scaler)))) .. 's')
			playRewards_accountboost_icon_parent:SetX(20 + ((maxMovement * math.cos(1- scaler))) .. 's')
		end, false, nil, 'hostTime')
	end)

	playRewards_accountboost_icon_parent:SetCallback('onhide', function(widget)
		playRewards_accountboost_icon_parent:UnregisterWatchLua('System')
		playRewards_accountboost_icon_parent:SlideX('20s',125)
		playRewards_accountboost_icon_parent:SlideY('-45s',125)
	end)	
	
	playRewards_accountboost_icon_parent:SetCallback('onmouseover', function(widget)
		UpdateCursor(widget, true, { canLeftClick = true, canRightClick = false })
		simpleTipGrowYUpdate(true, nil, Translate('player_card_boost_perma_title'), Translate('player_card_boost_perma_desc'), 250, -250)
	end)
	
	playRewards_accountboost_icon_parent:SetCallback('onmouseout', function(widget)
		UpdateCursor(widget, false, { canLeftClick = true, canRightClick = false })
		simpleTipGrowYUpdate(false, nil, Translate('player_card_boost_perma_title'), Translate('player_card_boost_perma_desc'), 250, -250)
	end)	
	
	playRewards_accountboost_icon_parent:RefreshCallbacks()	
	
	playRewards_accountboost_parent:SetCallback('onmouseover', function(widget)
		UpdateCursor(widget, true, { canLeftClick = true, canRightClick = false })
		simpleTipGrowYUpdate(true, nil, Translate('player_card_boost_perma_title'), Translate('player_card_boost_perma_desc'), 250, -250)
	end)
	
	playRewards_accountboost_parent:SetCallback('onmouseout', function(widget)
		UpdateCursor(widget, false, { canLeftClick = true, canRightClick = false })
		simpleTipGrowYUpdate(false, nil, Translate('player_card_boost_perma_title'), Translate('player_card_boost_perma_desc'), 250, -250)
	end)	
	
	playRewards_accountboost_parent:RefreshCallbacks()		
	
	if (PostGame) and (PostGame.Splash) and (PostGame.Splash.animateSplashScreenThread) then
		trigger_postGameLoopStatus.summaryAnimationActive = false
		trigger_postGameLoopStatus.fastForwarding = false
		trigger_postGameLoopStatus:Trigger(false)	
		PostGame.Splash.animateSplashScreenThread:kill()
		PostGame.Splash.animateSplashScreenThread = nil
	end	
	
end
PostGameInit(object)

function PostGame.Splash.AnimateSpashScreen()
	
	local queuedSplashScreens = {}
	local queuedCraftedItemSplashScreens = {}
	
	println('^y PostGame.Splash.PrepareSpashScreen() C 2')
	
	GetWidget('post_game_loop_nav_continue_button_throb'):FadeOut(125)
	GetWidget('post_game_loop_nav_continue_button_parent'):FadeIn(250)
	
	PostGame.Splash.animationDelayMultiplier 	= 1.0
	
	if (PostGame.Splash.animateSplashScreenThread) then
		trigger_postGameLoopStatus.summaryAnimationActive = false
		trigger_postGameLoopStatus.fastForwarding = false
		trigger_postGameLoopStatus:Trigger(false)	
		PostGame.Splash.animateSplashScreenThread:kill()
		PostGame.Splash.animateSplashScreenThread = nil
	end

	PostGame.Splash.animateSplashScreenThread = libThread.threadFunc(function()	
		
		trigger_postGameLoopStatus.summaryAnimationActive = true
		trigger_postGameLoopStatus.fastForwarding = false
		trigger_postGameLoopStatus:Trigger(false)
		

		local postgame_summary_insert_match_awards_5more 			= 	GetWidget('postgame_summary_insert_match_awards_5more')
		local postgame_summary_insert_match_awards_4less 			= 	GetWidget('postgame_summary_insert_match_awards_4less')
		
		local postgame_summary_insert_account_progression 			= 	GetWidget('postgame_summary_insert_account_progression')
		local postgame_summary_insert_account_progression_insert 	= 	GetWidget('postgame_summary_insert_account_progression_insert')
		local postgame_summary_insert_upcoming_unlocks 				= 	GetWidget('postgame_summary_insert_upcoming_unlocks')
		local postgame_summary_insert_match_awards 					= 	GetWidget('postgame_summary_insert_match_awards')
		local postgame_summary_insert_match_awards_insert 			= 	GetWidget('postgame_summary_insert_match_awards_insert')
		local postgame_summary_insert_match_awards_insert_label 	= 	GetWidget('postgame_summary_insert_match_awards_insert_label')
		
		local postgame_summary_freeform_parent 						= 	GetWidget('postgame_summary_freeform_parent')
		
		groupfcall('postgame_quest_prize_template', function(_, widget) widget:Destroy() end)
		groupfcall('postgame_splash_quest_items', function(_, widget) widget:Destroy() end)
		groupfcall('postgame_quest_accountlevels', function(_, widget) widget:Destroy() end)
		postgame_summary_insert_match_awards_5more:ClearChildren()
		postgame_summary_insert_match_awards_5more:SetVisible(0)
		postgame_summary_insert_match_awards_4less:ClearChildren()
		postgame_summary_insert_match_awards_4less:SetVisible(0)
		postgame_summary_insert_match_awards_insert:ClearChildren()
		postgame_summary_insert_match_awards_insert:SetVisible(0)
		postgame_summary_insert_match_awards_insert_label:SetVisible(0)
		postgame_summary_insert_match_awards:SetVisible(0)
		GetWidget('postgame_summary_insert_account_progression'):SetVisible(0)
		GetWidget('postgame_summary_insert_upcoming_unlocks'):SetVisible(0)
		GetWidget('postgame_summary_insert_game_results_header'):SetVisible(0)
		GetWidget('postgame_summary_insert_game_results_header_flare'):SetVisible(0)
		local rewardIndex = 0
		
		local function animateUnlockPrize(effect, shimmer, shimmer2, shimmer3, shine, shine2, lock, prizeIcon2)		
			libThread.threadFunc(function()
				wait(200)
				shine:Rotate(math.random() * 360, 10)
				
				prizeIcon2:FadeOut(130)
				lock:FadeOut(130)
				effect:FadeIn(100)
				effect:Scale('100%', '100%', 130)
				
				wait(130)
				effect:FadeOut(400)
				
				wait(100)
				shine:Rotate(math.random() * 360, 200)
				shine:Scale('100%', '100%', 200)
				shimmer:SlideX('110s', 300)
				shimmer:SlideY('110s', 300)
				
				wait(190)
				shimmer2:SlideX('110s', 300)
				shimmer2:SlideY('110s', 300)
				
				wait(10)
				shine:Scale('0%', '0%', 100)
				
				wait(90)
				shine2:Scale('40%', '40%', 200)
				shimmer3:SlideX('110s', 300)
				shimmer3:SlideY('110s', 300)
				
				wait(200)
				shine2:Scale('0%', '0%', 100)
			end)
		end		
		
		local displayRewardThread
		local function DisplayReward(rewardTables, destination, template, playDelay)
			
			local destination = destination or postgame_summary_insert_match_awards_5more
			
				if (destination) and (destination:IsValid()) then
				
				destination:FadeIn(250)
				
				local template = template or 'postgame_summary_game_reward_template'
				for index, rewardTable in ipairs(rewardTables) do

					rewardIndex = rewardIndex + 1
					
					destination:RecalculateSize()
					destination:RecalculatePosition()

					local prizeWidgets = destination:InstantiateAndReturn(template,
						'index', rewardIndex,
						'prizeIcon', rewardTable[2] or '$checker',
						'prizeLabel', rewardTable[1] or 'Missing',
						'title', (rewardTable[3]) or '',
						'desc', (rewardTable[4]) or '',
						'group', 'postgame_quest_prize_template',
						'visible', 'false',
						'color', (rewardTable[6]) or '',
						'labelColor', (rewardTable[7]) or ''
					)
					local prizeParent = prizeWidgets[1]
					
					-- Is there something specific we want to bounce? Else, we'll bounce in the entire widget
					if (prizeParent:GetWidget('postgame_summary_game_reward_'..rewardIndex..'_bounce')) then
						prizeParent:FadeIn(250) --Fades in all elements, since we're about to change prizeParent to something more specific
						prizeParent = GetWidget('postgame_summary_game_reward_'..rewardIndex..'_bounce')
					end
					
					local function flairEffect(widget, width, height, duration)
						if (displayRewardThread) then
							displayRewardThread:kill()
							displayRewardThread = nil
						end
						displayRewardThread = libThread.threadFunc(function()	
							widget:SetVisible(0)
							libAnims.bounceIn(widget, width * 1.0, height * 1.0, true, duration, 0.2, 200, 0.8, 0.2)
							displayRewardThread = nil
						end)
					end
					
					flairEffect(prizeParent, prizeParent:GetWidth(), prizeParent:GetHeight(), PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier)
					
					if (playDelay) then
						wait(PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier)
					end
					
					if (rewardTable[5]) then -- animation function
						rewardTable[5](rewardIndex)
					end
					
				end	
			end
		end

		-- Start Animation
		wait(PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 0.1)
		
		if (PostGame.selfInfo) then
			println('Found self info')
			println('PostGame.selfInfo.matchType ' .. tostring(PostGame.selfInfo.matchType))
		else
			println('No self info')
		end
		
		-- rmm
		if GetCvarBool('ui_matchTypeIsTotesKhanquest') then
			PostGame.Splash.heroEntityName = 'Hero_Hale'
			PostGame.selfInfo = PostGame.selfInfo or {}
			PostGame.selfInfo.matchType = 'khanquest'		
		elseif GetCvarBool('ui_testPostgame2') or (GetCvarNumber('ui_testRankedProgression') > 0) then
			PostGame.Splash.heroEntityName = 'Hero_Hale'
			PostGame.selfInfo = PostGame.selfInfo or {}
			PostGame.selfInfo.matchType = 'pvp'
		end
		
		-- Awards module. This exists outside of timing so can be done first.
		if (PostGame.Splash.modules) and (PostGame.Splash.modules.matchAwards) and (#PostGame.Splash.modules.matchAwards > 0) then
			if (postgame_summary_insert_match_awards_insert) and (postgame_summary_insert_match_awards_insert:IsValid()) then
				postgame_summary_insert_match_awards_insert:FadeIn(250)
				postgame_summary_insert_match_awards_insert_label:FadeIn(250)
				DisplayReward(PostGame.Splash.modules.matchAwards, postgame_summary_insert_match_awards_insert, 'postgame_summary_game_award_template')
			end
		else
			println('No match awards module')
		end				
		
		if (((PostGame.selfInfo) and (PostGame.selfInfo.matchType) and (PostGame.selfInfo.matchType == 'khanquest')) or (GetCvarBool('ui_matchTypeIsTotesKhanquest'))) and (postGame_khanquest) and (postGame_khanquest.cachedProgress) then

			local function KhanquestAnimation()
			
				local function postGame_khanquestRegisterChestUpgradeProjectile(object, index)
					local container		= object:GetWidget('postGame_khanquestChestUpgradeProjectile'..index)
					local body			= object:GetWidget('postGame_khanquestChestUpgradeProjectile'..index..'Body')
					
					local function appear(sourceWidget)
						container:SetX(libGeneral.getXToCenterOnTarget(container, sourceWidget))
						container:SetY(libGeneral.getYToCenterOnTarget(container, sourceWidget))
						-- container:FadeIn(125)
						libAnims.bounceIn(body, container:GetWidth(), container:GetHeight(), true, 1000)
					end
					
					local function moveToTarget(targWidget)
						container:SlideX(libGeneral.getXToCenterOnTarget(container, targWidget), 500)
						container:SlideY(libGeneral.getYToCenterOnTarget(container, targWidget), 500)
					end
					
					local function disappear()
						body:FadeOut(250)
					end
					
					local function initVis()
						body:SetVisible(false)
					end
					
					return {
						appear			= appear,
						moveToTarget	= moveToTarget,
						disappear		= disappear,
						initVis			= initVis,
					}
				end

				local function postGame_khanquestRegisterMatch(object, index)
					local container		= object:GetWidget('postGame_khanquestMatch'..index)
					local bodyPos		= object:GetWidget('postGame_khanquestMatch'..index..'BodyPos')
					local body			= object:GetWidget('postGame_khanquestMatch'..index..'Body')
					local glow			= object:GetWidget('postGame_khanquestMatch'..index..'Glow')
					local image			= object:GetWidget('postGame_khanquestMatch'..index..'Image')
					local backer		= object:GetWidget('postGame_khanquestMatch'..index..'Backer')
					
					local function glowStartRotation()
						libAnims.wobbleStop2(glow)
						libAnims.wobbleStart2(glow, 2500, 6, -3, (index * 150))
					end
					
					glow:SetCallback('onshow', function(widget)
						glowStartRotation()
					end)
					
					glow:SetCallback('onhide', function(widget)
						libAnims.wobbleStop2(widget)
					end)

					local function setCompletion(isComplete)	-- Instant
						isComplete = isComplete or false
						
						image:SetVisible(isComplete)
						glow:SetVisible(isComplete)
					end
					
					local function appear()
						container:FadeIn(500)
						glowStartRotation()
						bodyPos:SlideY(0, 500)
					end
					
					local function disappear()
						container:FadeOut(250)
					end

					
					local function markCompleted()	-- Animated
						libThread.threadFunc(function()
							image:FadeIn(125)
							libAnims.bounceIn(body, container:GetWidth(), container:GetHeight(), true, 600)
							
							glowStartRotation()
							glow:FadeIn(250)

						end)
					end
					
					local function initVis(isComplete)
						isComplete = isComplete or false
						setCompletion(isComplete)

						container:SetVisible(false)
						-- glow:SetVisible(false)
						-- image:SetVisible(false)
						backer:SetVisible(true)
						body:SetWidth('100@')
						body:SetHeight('100%')
						bodyPos:SetY('200%')
					end
					
					return {
						appear			= appear,
						disappear		= disappear,
						setCompletion	= setCompletion,
						markCompleted	= markCompleted,
						initVis			= initVis,
						container		= container,
					}
				end

				local function postGame_khanquestRegisterChest(object, index)
					local container		= object:GetWidget('postGame_khanquestChest'..index)
					local body			= object:GetWidget('postGame_khanquestChest'..index..'Body')
					local chestImage	= object:GetWidget('postGame_khanquestChest'..index..'Image')
					local glow			= object:GetWidget('postGame_khanquestChest'..index..'Glow')
					
					local transformThread = nil
					
					
					local function appear(bounce)
						bounce = bounce or false
						if bounce then
							libAnims.bounceIn(container, container:GetWidth(), container:GetHeight(), true, 750)
						else
							container:FadeIn(250)
						end
					end
					
					local function disappear()
						
					end
					
					
					local function setImage(texture)
						chestImage:SetTexture(texture)
					end
					
					local function transform(texture)
						transformThread = libThread.threadFunc(function()
							libAnims.bounceIn(container, container:GetWidth(), container:GetHeight(), true, 750)
							setImage(texture)
							transformThread = nil
						end)
					end
					
					local function initVis()
						if transformThread then
							transformThread:kill()
						end
						container:SetVisible(false)
						body:SetWidth('100@')
						body:SetHeight('100%')
						glow:SetVisible(false)
					end
					
					return {
						disappear	= disappear,
						setImage	= setImage,
						initVis		= initVis,
						transform	= transform,
						container	= container,
						appear		= appear,
					}
				end

				local function postGame_khanquestRegisterInfoLabel(object, index)
					local label = object:GetWidget('postGame_khanquestInfoLabel'..index)
					
					local function appear()
						label:SetX('-92s')
						label:FadeIn(250)
						label:SlideX(0, 250)
					end
					
					local function disappear()
						label:FadeOut(250)
						label:SlideX('92s', 250)
					end
					
					local function setText(content)	-- This allows the content to be animated later on
						label:SetText(content)
					end
					
					local function initVis()
						label:SetVisible(false)
						label:SetX('-92s')
					end
					
					local function animatedText(content, duration, doDisappear)
						duration = duration or 1000
						doDisappear = doDisappear or false
						libThread.threadFunc(function()
							setText(content)
							appear()
							wait(duration)
							if doDisappear then
								disappear()
							end
						end)
					end
					
					return {
						appear			= appear,
						disappear		= disappear,
						setText			= setText,
						initVis			= initVis,
						animatedText	= animatedText,
					}
				end			
			
				local container					= object:GetWidget('postgame_khanquest')

				local spotlight					= object:GetWidget('postGame_khanquestChest1Spotlight')
				local sparkle					= object:GetWidget('postGame_khanquestChest1Sparkle')
				local chestImage				= object:GetWidget('postGame_khanquestChest1Image')
				
				local infoDivider				= object:GetWidget('postGame_khanquestInfoDivider')
				local infoLabel1				= postGame_khanquestRegisterInfoLabel(object, 1)
				local infoLabel2				= postGame_khanquestRegisterInfoLabel(object, 2)
				
				local chestUpgradeProjectile	= postGame_khanquestRegisterChestUpgradeProjectile(object, 1)

				local chest						= postGame_khanquestRegisterChest(object, 1)
				local matchMax					= 7
				local matches					= {}
				local lifeMax					= 1
				local lives						= {}

				for i=1,matchMax,1 do
					table.insert(matches, postGame_khanquestRegisterMatch(object, i))
				end
				
				local revealSpeedMult	= 1
				local revealThread

				local function initVis(winsStart)
					winsStart = winsStart or 0
					
					if (winsStart > 0) and (winsStart <= 7) then
						chest.setImage('/ui/main/postgame/khanquest/textures/prize_chest' .. winsStart .. '.tga')
					else
						chest.setImage('/ui/main/postgame/khanquest/textures/prize_chest1.tga')
					end

					chest.initVis()
					for i=1,matchMax,1 do
						matches[i].initVis(i <= winsStart)
					end
					
					infoLabel1.initVis()
					infoLabel2.initVis()
					
					spotlight:SetVisible(false)
					sparkle:SetVisible(false)
					
					chestUpgradeProjectile.initVis()
					
					infoDivider:SetVisible(false)
				
				end			
			
				if postGame_khanquest.cachedProgress then

					local winsStart		= postGame_khanquest.cachedProgress.wins or 0
					
					if (winsStart > 0) then
						
						GetWidget('postgame_khanquest'):FadeIn(250)
						
						if postGame_khanquest.cachedProgress.isWin then
							winsStart = winsStart - 1
						end

						initVis(winsStart)

						sparkle:FadeIn(500)
						spotlight:FadeIn(1000)
						
						wait(PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 1.25)

						chest.appear(true)

						infoDivider:FadeIn(250)
						wait(PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 0.25)
						
						infoLabel1.animatedText(Translate('postgame_khanquest_wins', 'amount', postGame_khanquest.cachedProgress.wins), wait(PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 0.25), false)
						
						wait(PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 0.25)

						for i=1,matchMax,1 do
							matches[i].appear()
							wait(PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 0.25)
						end

						wait(PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 0.5)
						
						if postGame_khanquest.cachedProgress.isWin then
							wait(PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 0.25)
							
							infoLabel2.animatedText(Translate('postgame_khanquest_streak_extended', 'value', winsStart), (PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 2.5), true)
							
							if (matches[postGame_khanquest.cachedProgress.wins]) then
								matches[postGame_khanquest.cachedProgress.wins].markCompleted()
							end
							
							wait(PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 0.5)
							
							if (winsStart >= 1) then
								infoLabel1.disappear()
								if (matches[postGame_khanquest.cachedProgress.wins]) then
									chestUpgradeProjectile.appear(matches[postGame_khanquest.cachedProgress.wins].container)
								end
								wait(PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 0.25)
								chestUpgradeProjectile.moveToTarget(chest.container)
								wait(PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 0.5)
								chestUpgradeProjectile.disappear()
								chest.transform('/ui/main/postgame/khanquest/textures/prize_chest' .. (winsStart + 1) .. '.tga')
								
								infoLabel1.animatedText(Translate('postgame_khanquest_chestupgraded'), (PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 2.5), false)
								wait(PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 1)
							elseif (winsStart >= 0) then
								-- First win
							end
							
							wait(PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 2)
							
							if (winsStart <= 5) then
								infoLabel2.animatedText(Translate('postgame_khanquest_winanother'), (PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 2.5), false)
							else
								infoLabel1.disappear()
								wait(PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 0.25)
								infoLabel1.animatedText(Translate('postgame_khanquest_maximum_streak_end'), (PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 2.5), false)
							end
							
							wait(PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 2.5)
							
						elseif not postGame_khanquest.cachedProgress.isWin then
							wait(PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 0.25)
							infoLabel2.animatedText(Translate('postgame_khanquest_streak_ended', 'value', winsStart), (PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 2.5), true)	
							wait(PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 2.5)
						end
						
						if postGame_khanquest.cachedProgress.complete then
							wait(PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 0.25)
							infoLabel2.animatedText(Translate('postgame_khanquest_payoutstreak', 'value', winsStart), (PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 2.5), false)
							
							if (postGame_khanquest.cachedProgress.rewards) then

								local rewardData = postGame_khanquest.cachedProgress.rewards.reward or postGame_khanquest.cachedProgress.rewards
								local boostModifier = 0
								
								if (rewardData) then

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
									local khanpoints 			= tonumber(rewardData.khanpoints) or 0
									local khanpointsBonus		= tonumber(math.ceil(boostModifier * khanpoints)) or 0	
									local rankpoints 			= tonumber(rewardData.rankpoints) or 0
									local rankpointsBonus		= tonumber(math.ceil(boostModifier * rankpoints)) or 0									

									local commodityAmounts	= {
										{name = 'ore', value = ore, bonus = oreBonus},
										{name = 'essence', value = essence, bonus = essenceBonus},
										{name = 'food', value = food, bonus = foodBonus}, 
										{name = 'shards', value = shards, bonus = shardsBonus}, 
										{name = 'gems', value = gems, bonus = gemsBonus},
										{name = 'khanpoints', value = khanpoints, bonus = khanpointsBonus},
										{name = 'rankpoints', value = rankpoints, bonus = rankpointsBonus},
									}				
									
									local rewardTables = {}
									for index, commodityTable in pairs(commodityAmounts) do
										local commodity 	= commodityTable.name
										local bonus 		= commodityTable.bonus
										local value 		= commodityTable.value + bonus
										
										local glowColor = '0 0.94 1 0.4' --Default
										local labelColor = '0 0.94 1 1' --Default
										
										if (commodity == 'essence') then
											glowColor = '1 0.92 0.64 0.4'
											labelColor = '#fffea8'
										elseif (commodity == 'food') then
											glowColor = '0.89 0.66 1 0.4'
											labelColor = '#e3a8ff'
										end
										
										if (value) and (tonumber(value) > 0) then
											if (bonus) and (tonumber(bonus) > 0) then
												if (tonumber(value) > 1) then
													table.insert(rewardTables, {Translate('general_commodity_' .. commodity .. '_x', 'value', value) .. '\n' ..Translate('general_commodity_bonus_x', 'bonus', bonus), Translate('general_commodity_texture_' .. commodity), Translate('general_commodity_' .. commodity), Translate('general_commodity_' .. commodity .. '_x', 'value', value) .. '\n' ..Translate('general_commodity_bonus_x', 'bonus', bonus), nil, glowColor, labelColor})
												else
													table.insert(rewardTables, {Translate('general_commodity_' .. commodity .. '_x_single', 'value', value) .. '\n' ..Translate('general_commodity_bonus_x', 'bonus', bonus), Translate('general_commodity_texture_' .. commodity), Translate('general_commodity_' .. commodity), Translate('general_commodity_' .. commodity .. '_x_single', 'value', value) .. '\n' ..Translate('general_commodity_bonus_x', 'bonus', bonus), nil, glowColor, labelColor})
												end
											else
												if (tonumber(value) > 1) then
													table.insert(rewardTables, {Translate('general_commodity_' .. commodity .. '_x', 'value', value), Translate('general_commodity_texture_' .. commodity), Translate('general_commodity_' .. commodity), Translate('general_commodity_' .. commodity .. '_x', 'value', value), nil, glowColor, labelColor})
												else	
													table.insert(rewardTables, {Translate('general_commodity_' .. commodity .. '_x_single', 'value', value), Translate('general_commodity_texture_' .. commodity), Translate('general_commodity_' .. commodity), Translate('general_commodity_' .. commodity .. '_x_single', 'value', value), nil, glowColor, labelColor})
												end
											end
										end
									end			

									if (rewardTables) and (#rewardTables > 0) then
										for i,v in pairs(rewardTables) do
											local rewardTable = {v}
											DisplayReward(rewardTable)
											wait(1 * PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier)
										end
									end				

								end		
							else
								println('No rewards module')
							end							
							
							wait(PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 2.5)
							
						end
					
						GetWidget('postgame_khanquest'):FadeOut(250)
						wait(PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 0.5)
					end
				end
			end
			
			if (GetCvarBool('ui_matchTypeIsTotesKhanquest')) then
				postGame_khanquestRandomCache(GetCvarBool('ui_matchTypeIsTotesKhanquestWinner'))
			end
			
			KhanquestAnimation()
			
		else
			println('No khanquest module')
		end		
		
		if (PostGame.Splash.modules) and (PostGame.Splash.modules.matchOutcome) and (#PostGame.Splash.modules.matchOutcome > 0) then
			-- GetWidget('postgame_summary_insert_game_results_header'):SetY('300s')
			GetWidget('postgame_summary_insert_game_results_header'):SetText(PostGame.Splash.modules.matchOutcome[1][1])
			GetWidget('postgame_summary_insert_game_results_header'):FadeIn(PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 0.5)
			GetWidget('postgame_summary_insert_game_results_header_flare'):FadeIn(PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 0.5)
			-- GetWidget('postgame_summary_insert_game_results_header'):SlideY('30s', PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 0.5)
			wait(PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 0.75)
		else
			println('No matchOutcome module')
		end
		
		if (PostGame.Splash.modules) and (PostGame.Splash.modules.allAccountProgression) then
			
			local animationInProgress = true
			local accountQuestIndexesWithProgress, levelOfFirstAccountLevelQuest, levelOfActualAccountLevel = {}, 1000, 0
			
			if (GetCvarNumber('ui_testPostgame9', true)) and (GetCvarNumber('ui_testPostgame9') > 0) then
				-- PostGame.Splash.animationDelayMultiplier = 2.5
				local LEVELS_TO_LEVEL = GetCvarNumber('ui_testPostgame9')
				LuaTrigger.GetTrigger('AccountProgression').level = 1 -- LuaTrigger.GetTrigger('AccountProgression').level - LEVELS_TO_LEVEL
				levelOfFirstAccountLevelQuest = LuaTrigger.GetTrigger('AccountProgression').level
				levelOfActualAccountLevel = levelOfFirstAccountLevelQuest + LEVELS_TO_LEVEL
			end

			for i,questTable in pairs(PostGame.Splash.modules.allAccountProgression) do
				if (GetCvarNumber('ui_testPostgame9', true)) and (GetCvarNumber('ui_testPostgame9') > 0) and (i <= levelOfActualAccountLevel) and (i >= levelOfFirstAccountLevelQuest) then
					questTable.percentProgress = 1
					questTable.percentLatestProgress = 0.5
					table.insert(accountQuestIndexesWithProgress, i)
					levelOfFirstAccountLevelQuest = math.min(levelOfFirstAccountLevelQuest, i)
					if (questTable) and (questTable.percentProgress >= 1) and (questTable.craftedItemReward) then
						table.insert(queuedCraftedItemSplashScreens, questTable.craftedItemReward)
					elseif (questTable) and (questTable.percentProgress >= 1) and (questTable.splashTemplate) then
						table.insert(queuedSplashScreens, questTable.splashTemplate)
					end				
				elseif (GetCvarNumber('ui_testPostgame9', true)) and (GetCvarNumber('ui_testPostgame9') > 0) and (not ((i <= levelOfActualAccountLevel) and (i >= levelOfFirstAccountLevelQuest))) then
					questTable.percentProgress = 0
					questTable.percentLatestProgress = 0				
				elseif (GetCvarNumber('ui_testPostgame9') == 0) and (questTable.percentProgress) and (questTable.percentLatestProgress) and (questTable.percentLatestProgress > 0) then
					table.insert(accountQuestIndexesWithProgress, i)
					levelOfFirstAccountLevelQuest = math.min(levelOfFirstAccountLevelQuest, i)
					if (questTable) and (questTable.percentProgress >= 1) and (questTable.craftedItemReward) then
						table.insert(queuedCraftedItemSplashScreens, questTable.craftedItemReward)
					elseif (questTable) and (questTable.percentProgress >= 1) and (questTable.splashTemplate) then
						table.insert(queuedSplashScreens, questTable.splashTemplate)
					end				
				end
			end
			
			if (levelOfFirstAccountLevelQuest == 1000) then
				levelOfFirstAccountLevelQuest = math.max(LuaTrigger.GetTrigger('AccountProgression').level, 2)
			end
			
			table.sort(accountQuestIndexesWithProgress, function(a,b)
				return tonumber(a) < tonumber(b)
			end)			
			
			-- println('accountQuestIndexesWithProgress')
			-- printr(accountQuestIndexesWithProgress)
			
			local currentLevel 						= LuaTrigger.GetTrigger('AccountProgression').level
			local LEVELS_PER_SEGMENT 				= 5
			local currentAnimationLevel				= levelOfFirstAccountLevelQuest
			local currentAnimationSegment			= math.ceil((currentAnimationLevel) / LEVELS_PER_SEGMENT)
			local clickedLevel, hoverLevel 			= nil,nil

			local levelBar							= GetWidget('postgame_summary_insert_account_progression_bar_level_bar')
			local levelBarNew						= GetWidget('postgame_summary_insert_account_progression_bar_level_bar_new')
			local levelBarBoosted					= GetWidget('postgame_summary_insert_account_progression_bar_level_bar_boosted')
			
			local levelBarGlow						= GetWidget('postgame_summary_insert_account_progression_bar_level_bar_glow')
			local levelBarNewGlow					= GetWidget('postgame_summary_insert_account_progression_bar_level_bar_new_glow')
			local levelBarBoostedGlow				= GetWidget('postgame_summary_insert_account_progression_bar_level_bar_boosted_glow')
			local levelBarNewGlowWidth				= GetWidget('postgame_summary_insert_account_progression_bar_level_bar_new_glow_width')
			local levelBarBoostedGlowWidth			= GetWidget('postgame_summary_insert_account_progression_bar_level_bar_boosted_glow_width')
			local levelBarTransitionGlowNew			= GetWidget('postgame_summary_insert_account_progression_bar_level_bar_transition_glow_new')
			local levelBarTransitionGlowBoosted		= GetWidget('postgame_summary_insert_account_progression_bar_level_bar_transition_glow_boosted')
			
			local levelBarLeader					= GetWidget('postgame_summary_insert_account_progression_bar_level_bar_leader')
			local levelBarNewLeader					= GetWidget('postgame_summary_insert_account_progression_bar_level_bar_new_leader')
			local levelBarBoostedLeader				= GetWidget('postgame_summary_insert_account_progression_bar_level_bar_boosted_leader')		
			
			local function UnlockPrizeDisplayCountdown(displayLevel, questTable, unlocked, dontAnimate)
				
				println('UnlockPrizeDisplayCountdown | displayLevel: ' .. tostring(displayLevel) .. ' | unlocked: ' .. tostring(unlocked))
				
				-- Update the label that counts down to the prize.
				local label = GetWidget('postgame_summary_insert_upcoming_unlocks_label')
				local label2 = GetWidget('postgame_summary_insert_upcoming_unlocks_label_2')				
				
				if (questTable) then
					
					label:FadeIn(125)
					label2:FadeIn(125)
					
					local remainingExperience = -1
					local remainingGames = -1
					
					if (questTable) and (questTable.required) and (questTable.required.experience) and (questTable.required.experience.experience) and (questTable.currentProgress) then
						remainingExperience = questTable.required.experience.experience - questTable.currentProgress
						if libGeneral.DoIHaveAnAccountExperienceBoost() then
							remainingGames = math.ceil(remainingExperience / 75)
						else
							remainingGames = math.ceil(remainingExperience / 50)
						end
					end
					
					label:SetText(Translate('postgame_upcoming_unlocks_header', 'value', displayLevel))
					
					if (unlocked) then
						label2:SetText(Translate('postgame_upcoming_unlocks_unlocked', 'value', displayLevel))
					elseif (remainingGames <= 10) then
						-- Find # Games
						if (remainingGames) and (remainingGames > 1) then
							label2:SetText(Translate('postgame_upcoming_unlocks_remaining_games', 'value', displayLevel))
						elseif (remainingGames >= 1) then
							label2:SetText(Translate('postgame_upcoming_unlocks_remaining_game', 'value', displayLevel))
						else
							label2:SetText(Translate('postgame_upcoming_unlocks_header', 'value', displayLevel))
						end
					else
						-- Show Level
						label2:SetText(Translate('postgame_upcoming_unlocks_header', 'value', displayLevel))
					end
				else
					label:FadeOut(125)
					label2:FadeOut(125)				
				end
			end

			local function UpdatePrizeDisplay(incomingLevel, unlocked, dontAnimate)

				local displayLevel = incomingLevel or hoverLevel or clickedLevel or currentAnimationLevel
				local questTable = PostGame.Splash.modules.allAccountProgression[displayLevel]

				println('UpdatePrizeDisplay | incomingLevel: ' .. tostring(incomingLevel) .. ' | displayLevel: ' .. displayLevel .. ' | unlocked: ' .. tostring(unlocked))
				-- printr(questTable)
				
				if (questTable) and (questTable.percentProgress >= 1) and (not animationInProgress) then
					unlocked = true
				end
				
				-- println('^y unlocked ' .. tostring(unlocked))
				
				local widgetIndex = 11
				for prizeIndex = 1,10,1 do
					widgetIndex = widgetIndex - 1
					local prizeIcon 		= GetWidget('postgame_summary_insert_account_progression_prize_icon_' .. widgetIndex)
					local prizeIcon2 		= GetWidget('postgame_summary_insert_account_progression_prize_icon2_' .. widgetIndex)
					local prizeParent		= GetWidget('postgame_summary_insert_account_progression_prize_parent_' .. widgetIndex)
					local effect			= GetWidget('postgame_summary_insert_account_progression_unlock_effect_' .. widgetIndex)
					local shimmer			= GetWidget('postgame_summary_insert_account_progression_unlock_shimmer_'.. widgetIndex)
					local shimmer2			= GetWidget('postgame_summary_insert_account_progression_unlock_shimmer2_'.. widgetIndex)
					local shimmer3			= GetWidget('postgame_summary_insert_account_progression_unlock_shimmer3_'.. widgetIndex)
					local shine				= GetWidget('postgame_summary_insert_account_progression_prize_shine_'.. widgetIndex)
					local shine2			= GetWidget('postgame_summary_insert_account_progression_prize_shine2_'.. widgetIndex)
					local lock				= GetWidget('postgame_summary_insert_account_progression_prize_lock_' .. widgetIndex)	
					local count				= GetWidget('postgame_summary_insert_account_progression_prize_count_' .. widgetIndex)	
					local countGlow			= GetWidget('postgame_summary_insert_account_progression_prize_count_glow_' .. widgetIndex)	
					local countParent		= GetWidget('postgame_summary_insert_account_progression_prize_count_parent_' .. widgetIndex)	
					
					if (questTable) and (questTable['rewardIcon'..prizeIndex]) and (questTable['rewardText'..prizeIndex]) then
						
						if (prizeParent) then
							prizeParent:SetVisible(1)
						end
						
						if (prizeIcon) then
							prizeIcon:SetTexture(questTable['rewardIcon'..prizeIndex])
						end		
						
						if (count) then
							if (questTable['rewardCount'..prizeIndex]) then
								countParent:SetVisible(1)
								count:SetText(questTable['rewardCount'..prizeIndex])								
							else
								countParent:SetVisible(0)
								count:SetText('')								
							end
							if (unlocked) then
								countGlow:SetColor('#ffd480')
								count:SetColor('#f9e8a3')
							else
								countGlow:SetColor('#e6ddcc')
								count:SetColor('#d8d3bf')
							end
						end							
						
						if (prizeIcon2) then
							prizeIcon2:SetTexture(questTable['rewardIcon'..prizeIndex])
							if (unlocked) then
								if (dontAnimate) then
									prizeIcon2:SetVisible(0)
								else
									PlaySound('/ui/sounds/rewards/sfx_tally_oneshot.wav')
									animateUnlockPrize(effect, shimmer, shimmer2, shimmer3, shine, shine2, lock, prizeIcon2)
									wait(350)
								end
							else
								prizeIcon2:SetVisible(1)
								lock:SetVisible(1)
								effect:SetVisible(0)
								effect:SetWidth('60%')
								effect:SetHeight('60%')
								shimmer:SetX('-110s')
								shimmer:SetY('-110s')
								shimmer2:SetX('-110s')
								shimmer2:SetY('-110s')
								shimmer3:SetX('-110s')
								shimmer3:SetY('-110s')
								shine:SetWidth('0%')
								shine:SetHeight('0%')
								shine2:SetWidth('0%')
								shine2:SetHeight('0%')
							end
						end
						
						if (prizeParent) then
							prizeParent:SetCallback('onmouseover', function(widget)
								local prizeString = TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_reward_label_'..prizeIndex) or questTable['rewardText'..prizeIndex] or ''
								simpleTipGrowYUpdate(true, nil, Translate('postgame_upcoming_unlocks_header', 'value', displayLevel), prizeString, 250, -250)
							end)						
							prizeParent:SetCallback('onmouseout', function(widget)
								simpleTipGrowYUpdate(false)
							end)
						end
					else
						if (prizeParent) then
							prizeParent:SetVisible(0)
						end						
					end
				end
				
				UnlockPrizeDisplayCountdown(displayLevel, questTable, unlocked, dontAnimate)
				
			end
		
			local function UpdateLevelPips(currentAnimationSegment, currentAnimationLevel)
				
				-- println('UpdateLevelPips | currentAnimationSegment: ' .. currentAnimationSegment .. ' | currentAnimationLevel: ' .. currentAnimationLevel)
				
				local widgetIndex = 0
				for i = ((currentAnimationSegment - 1) * LEVELS_PER_SEGMENT) + 1, ((currentAnimationSegment) * LEVELS_PER_SEGMENT) + 1, 1 do
					if (i <= MAX_LEVEL) then
						widgetIndex = widgetIndex + 1
						local levelLabel 		= GetWidget('postgame_summary_insert_account_progression_bar_level_label_' .. widgetIndex, nil, true)
						local levelButton		= GetWidget('postgame_summary_insert_account_progression_bar_level_button_' .. widgetIndex, nil, true)
						local levelHover		= GetWidget('postgame_summary_insert_account_progression_bar_level_hover_' .. widgetIndex, nil, true)
						local levelGlow			= GetWidget('postgame_summary_insert_account_progression_bar_level_glow_' .. widgetIndex, nil, true)
						
						if (levelLabel) then
							levelLabel:SetText(i)
							if (i <= currentAnimationLevel) then
								if (levelGlow) then
									levelGlow:FadeIn(100)
								end
								levelLabel:SetColor(1, 1, 1, 1)
								levelLabel:SetOutline(1)
							else							
								if (levelGlow) then
									levelGlow:SetVisible(0)
								end
								levelLabel:SetColor(0.24, 0.26, 0.3, 1)
								levelLabel:SetOutline(0)
							end							
						end
						
						if (levelButton) then
							levelButton:SetCallback('onclick', function(widget)
								if (not animationInProgress) then
									if (clickedLevel) and (clickedLevel == i) then
										clickedLevel = nil
									else
										clickedLevel = i
									end
									UpdatePrizeDisplay(clickedLevel, nil, true)
								end
							end)
							levelButton:SetCallback('onmouseover', function(widget)
								if (not animationInProgress) then
									clickedLevel = nil
									hoverLevel = i
									UpdatePrizeDisplay(hoverLevel, nil, true)
								end
								levelHover:FadeIn(125)
							end)						
							levelButton:SetCallback('onmouseout', function(widget)
								if (not animationInProgress) then
									hoverLevel = nil
									UpdatePrizeDisplay(currentAnimationLevel + 1, nil, true)
								end
								levelHover:FadeOut(125)
							end)	
							levelButton:RefreshCallbacks()
						end
					else
						widgetIndex = widgetIndex + 1
						local levelLabel 		= GetWidget('postgame_summary_insert_account_progression_bar_level_label_' .. widgetIndex, nil, true)
						local levelButton		= GetWidget('postgame_summary_insert_account_progression_bar_level_button_' .. widgetIndex, nil, true)
						
						if (levelLabel) then
							levelLabel:SetText('?')
							levelLabel:SetColor(0.24, 0.26, 0.3, 1)
							levelLabel:SetOutline(0)							
						end
						
						if (levelButton) then
							levelButton:SetCallback('onclick', function(widget) end)
							levelButton:SetCallback('onmouseover', function(widget) end)						
							levelButton:SetCallback('onmouseout', function(widget) end)	
						end					
					end
				end				
			end
			
			local function ResetWithoutQuestData()				
				
				clickedLevel = nil
				
				local animationLevelOverride = 0
				local baseLevel = LuaTrigger.GetTrigger('AccountProgression').level

				println('^c ResetWithoutQuestData | baseLevel: ' .. baseLevel)

				local percentProgress 		= LuaTrigger.GetTrigger('AccountProgression').percentToNextLevel
				local percentLatestProgress = 0
				
				currentAnimationLevel					= baseLevel
				currentAnimationSegment					= math.ceil((currentAnimationLevel + animationLevelOverride) / LEVELS_PER_SEGMENT)	
				local levelOnCurrentBar					= (currentAnimationLevel - ((currentAnimationSegment-1) * LEVELS_PER_SEGMENT)) - 1
				local currentLevelProgressPercent 		= math.min(1, ((percentProgress - percentLatestProgress)))

				local levelBarWidth 					= (4 * 5 * levelOnCurrentBar) + ( 4 * 5 * currentLevelProgressPercent)

				if (resetBar) or (levelOnCurrentBar < 0) or (levelOnCurrentBar > 5) then
					levelBarWidth = 0
				end

				if (levelBar) then
					levelBar:SetWidth(levelBarWidth .. '%')
					levelBarLeader:SetX(levelBarWidth .. '%')
					levelBarLeader:FadeOut(50)
					levelBarGlow:FadeOut(200)
					levelBarGlow:SetWidth(levelBarWidth .. '%')
				end
				if (levelBarNew) then
					levelBarNew:SetWidth(levelBarWidth .. '%')
					levelBarNewLeader:FadeOut(50)
					levelBarNewLeader:SetX(levelBarWidth .. '%')
					levelBarNewGlow:FadeOut(200)
					levelBarNewGlow:SetX(levelBarWidth .. '%')
					levelBarNewGlowWidth:SetWidth('0%')
				end
				if (levelBarBoosted) then
					levelBarBoosted:SetWidth(levelBarWidth .. '%')	
					levelBarBoostedLeader:FadeOut(50)
					levelBarBoostedLeader:SetX(levelBarWidth .. '%')		
					levelBarBoostedGlow:FadeOut(200)
					levelBarBoostedGlow:SetX(levelBarWidth .. '%')
					levelBarBoostedGlowWidth:SetWidth('0%')
				end
				
				UpdateLevelPips(currentAnimationSegment, (currentAnimationLevel))
				
				UpdatePrizeDisplay((baseLevel + animationLevelOverride) + 1, nil, true)
			end			
			
			local function ResetToPrevious(baseLevel, resetBar, animationLevelOverride, dontAnimate)				
				
				clickedLevel = nil
				
				local animationLevelOverride = animationLevelOverride or 0
				local baseLevel = baseLevel or levelOfFirstAccountLevelQuest 
				
				println('^c ResetToPrevious | levelOfFirstAccountLevelQuest: ' .. baseLevel)
				
				local firstQuestTable = PostGame.Splash.modules.allAccountProgression[baseLevel + 1] or {}
				
				if (firstQuestTable) then
				
					local percentProgress 		= firstQuestTable.percentProgress or 0
					local percentLatestProgress = firstQuestTable.percentLatestProgress or 0
					
					currentAnimationLevel					= baseLevel
					currentAnimationSegment					= math.ceil((currentAnimationLevel + animationLevelOverride) / LEVELS_PER_SEGMENT)	
					local levelOnCurrentBar					= (currentAnimationLevel - ((currentAnimationSegment-1) * LEVELS_PER_SEGMENT)) - 1
					local currentLevelProgressPercent 		= math.min(1, ((percentProgress - percentLatestProgress)))

					local levelBarWidth 					= (4 * 5 * levelOnCurrentBar) + ( 4 * 5 * currentLevelProgressPercent)
					
					-- println('^g animationLevelOverride ' .. tostring(animationLevelOverride))
					-- println('^g currentAnimationSegment ' .. tostring(currentAnimationSegment))
					-- println('^g levelOnCurrentBar ' .. tostring(levelOnCurrentBar) )
					
					if (resetBar) or (levelOnCurrentBar < 0) or (levelOnCurrentBar > 5) then
						levelBarWidth = 0
					end
					
					-- println('currentLevelProgressPercent ' .. tostring(currentLevelProgressPercent))
					-- println('levelOnCurrentBar ' .. tostring(levelOnCurrentBar))
					-- println('levelBarWidth ' .. tostring(levelBarWidth))					
					
					if (levelBar) then
						levelBar:SetWidth(levelBarWidth .. '%')
						levelBarLeader:SetX(levelBarWidth .. '%')
						levelBarLeader:FadeOut(50)
						levelBarGlow:FadeOut(200)
						levelBarGlow:SetWidth(levelBarWidth .. '%')
					end
					if (levelBarNew) then
						levelBarNew:SetWidth(levelBarWidth .. '%')
						levelBarNewLeader:FadeOut(50)
						levelBarNewLeader:SetX(levelBarWidth .. '%')
						levelBarNewGlow:FadeOut(200)
						levelBarNewGlow:SetX(levelBarWidth .. '%')
						levelBarNewGlowWidth:SetWidth('0%')
					end
					if (levelBarBoosted) then
						levelBarBoosted:SetWidth(levelBarWidth .. '%')	
						levelBarBoostedLeader:FadeOut(50)
						levelBarBoostedLeader:SetX(levelBarWidth .. '%')		
						levelBarBoostedGlow:FadeOut(200)
						levelBarBoostedGlow:SetX(levelBarWidth .. '%')
						levelBarBoostedGlowWidth:SetWidth('0%')
					end
					
					UpdateLevelPips(currentAnimationSegment, (currentAnimationLevel))
					
					UpdatePrizeDisplay((baseLevel + animationLevelOverride) + 1, nil, true)
				else
					ResetWithoutQuestData()
				end
			end
			
			local function AnimateToNextExperience(questTable, currentAnimationLevel, currentAnimationSegment, newAnimationSegment, lastLevel, lastSegment, dontAnimate)
				-- println('^c AnimateToNextExperience | currentAnimationLevel: ' .. currentAnimationLevel .. ' | newAnimationSegment: ' .. newAnimationSegment)

				local questTable = PostGame.Splash.modules.allAccountProgression[currentAnimationLevel]
				
				if (questTable) then
				
					local currentLevelProgressPercent 			= math.min(1, ((questTable.percentProgress - questTable.percentLatestProgress)))
					local levelOnCurrentBar						= (currentAnimationLevel - ((currentAnimationSegment-1) * LEVELS_PER_SEGMENT)) - 2
					local levelBarWidth 						= math.max(0, math.min(100, (4 * 5 * levelOnCurrentBar) + ( 4 * 5 * currentLevelProgressPercent)))
					
					if (levelOnCurrentBar >= 0) and (levelOnCurrentBar <= 5) then
					
						-- println('questTable.percentProgress ' .. tostring(questTable.percentProgress))
						-- println('questTable.percentLatestProgress ' .. tostring(questTable.percentLatestProgress))
						-- println('currentLevelProgressPercent ' .. tostring(currentLevelProgressPercent))
						-- println('levelOnCurrentBar ' .. tostring(levelOnCurrentBar))
						-- println('levelBarWidth ' .. tostring(levelBarWidth))
						
						if (dontAnimate) then
							if (levelBar) then
								levelBar:SetWidth(levelBarWidth .. '%')
								levelBarLeader:SetX(levelBarWidth .. '%')
								levelBarGlow:SetVisible(0)
								levelBarLeader:FadeOut(50)
							end
							if (levelBarNew) then
								levelBarNew:SetWidth(levelBarWidth .. '%')
								levelBarNewLeader:SetX(levelBarWidth .. '%')
								levelBarNewGlow:SetVisible(0)
								levelBarNewLeader:FadeOut(50)
							end
							if (levelBarBoosted) then
								levelBarBoosted:SetWidth(levelBarWidth .. '%')		
								levelBarBoostedLeader:SetX(levelBarWidth .. '%')
								levelBarBoostedGlow:SetVisible(0)
								levelBarBoostedLeader:FadeOut(50)
							end				

							local percentProgress, progressPercentBoosted = false, 0, 0

							if (libGeneral.DoIHaveAnAccountExperienceBoost()) then
								progressPercentBoosted = math.min(1, (questTable.percentProgress))
								percentProgress = progressPercentBoosted - (questTable.percentLatestProgress / 3)
							else
								percentProgress = math.min(1, (questTable.percentProgress))
								progressPercentBoosted = 0
							end					

							if (percentProgress > 0) and (levelBarNew) then
								levelBarNew:SetWidth(math.max(0, math.min(100, (4 * 5 * levelOnCurrentBar) + ( 4 * 5 * percentProgress))) .. '%')
								levelBarNewLeader:SetX(math.max(0, math.min(100, (4 * 5 * levelOnCurrentBar) + ( 4 * 5 * percentProgress))) .. '%')
							end

							if (progressPercentBoosted > 0) and (levelBarBoosted) then
								levelBarBoosted:SetWidth(math.max(0, math.min(100, (4 * 5 * levelOnCurrentBar) + ( 4 * 5 * progressPercentBoosted))) .. '%')
								levelBarBoostedLeader:SetX(math.max(0, math.min(100, (4 * 5 * levelOnCurrentBar) + ( 4 * 5 * progressPercentBoosted))) .. '%')
							end							
						else			

							if (levelBar) then
								levelBar:ScaleWidth(levelBarWidth .. '%', PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 0.5)
								levelBarLeader:SlideX(levelBarWidth .. '%', PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 0.5)
								levelBarLeader:FadeIn(50)
								levelBarGlow:FadeIn(200)
								levelBarGlow:ScaleWidth(levelBarWidth.. '%', PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 0.5)
							end
							if (levelBarNew) then
								levelBarNew:ScaleWidth(levelBarWidth .. '%', PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 0.5 * 2)
								levelBarNewLeader:FadeOut(50)
								levelBarNewLeader:SlideX(levelBarWidth .. '%', PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 0.5 * 2)
								levelBarNewGlow:FadeIn(200)
								levelBarNewGlow:SlideX(levelBarWidth + 1.27 .. '%', PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 0.5)
								levelBarNewGlowWidth:ScaleWidth('0%', PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 0.5 * 2)
								levelBarNewGlow:FadeOut(100)
							end
							if (levelBarBoosted) then
								levelBarBoosted:ScaleWidth(levelBarWidth .. '%', PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 0.5 * 2)	
								levelBarBoostedLeader:FadeOut(50)								
								levelBarBoostedLeader:SlideX(levelBarWidth .. '%', PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 0.5 * 2)
								levelBarBoostedGlow:FadeIn(200)
								levelBarBoostedGlow:SlideX(levelBarWidth + 1.27 .. '%', PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 0.5 * 2)
								levelBarBoostedGlowWidth:ScaleWidth('0%', PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 0.5 * 2)
								levelBarBoostedGlow:FadeOut(100)
							end				
							
							wait(PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 0.5 * 2)
							
							local percentProgress, progressPercentBoosted = false, 0, 0
							
							-- println('libGeneral.DoIHaveAnAccountExperienceBoost() ' .. tostring(libGeneral.DoIHaveAnAccountExperienceBoost()))
							-- println('questTable.percentProgress ' .. tostring(questTable.percentProgress))
							-- println('questTable.percentLatestProgress ' .. tostring(questTable.percentLatestProgress))
							
							if (libGeneral.DoIHaveAnAccountExperienceBoost()) then
								progressPercentBoosted = math.min(1, (questTable.percentProgress))
								percentProgress = progressPercentBoosted - (questTable.percentLatestProgress / 3)
							else
								percentProgress = math.min(1, (questTable.percentProgress))
								progressPercentBoosted = 0
							end					

							if (percentProgress > 0) and (levelBarNew) then
								PlaySound('/ui/sounds/crafting/sfx_barfill_start.wav')
								PlaySound('/ui/sounds/crafting/sfx_barfill.wav', 1, 14)								
								levelBarNewGlow:SetX(math.max(0, math.min(100, (4 * 5 * levelOnCurrentBar) + ( 4 * 5 * currentLevelProgressPercent))) + 1.27 .. '%')
								levelBarLeader:FadeOut(100)
								-- levelBarGlow:FadeOut(100)
								wait(PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 0.1 * 2)	
								levelBarNewGlow:FadeIn(100)
								levelBarNewLeader:FadeIn(50)
								levelBarNew:ScaleWidth(math.max(0, math.min(100, (4 * 5 * levelOnCurrentBar) + ( 4 * 5 * percentProgress))) .. '%', PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 0.5)
								levelBarNewLeader:SlideX(math.max(0, math.min(100, (4 * 5 * levelOnCurrentBar) + ( 4 * 5 * percentProgress))) .. '%', PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 0.5)
								levelBarNewGlowWidth:ScaleWidth(math.max(0, math.min(100, (4 * 5 * levelOnCurrentBar) + ( 4 * 5 * (percentProgress - currentLevelProgressPercent) - 1.27 ))) .. '%', PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 0.5)
								wait(PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 0.5)	
							end

							if (progressPercentBoosted > 0) and (levelBarBoosted) then
								levelBarBoosted:SetWidth(math.max(0, math.min(100, (4 * 5 * levelOnCurrentBar) + ( 4 * 5 * percentProgress))) .. '%')
								levelBarBoostedLeader:SetX(math.max(0, math.min(100, (4 * 5 * levelOnCurrentBar) + ( 4 * 5 * percentProgress))) .. '%')
								levelBarBoostedGlow:SetX(math.max(0, math.min(100, (4 * 5 * levelOnCurrentBar) + ( 4 * 5 * percentProgress))) + 1.27 .. '%')
								PlaySound('/ui/sounds/crafting/sfx_barfill.wav', 1, 14)
								levelBarLeader:FadeOut(100)
								levelBarNewLeader:FadeOut(100)
								-- levelBarGlow:FadeOut(100)
								-- levelBarNewGlow:FadeOut(100)
								wait(PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 0.1 * 2)
								levelBarBoostedGlow:FadeIn(100)
								levelBarBoostedLeader:FadeIn(50)
								levelBarBoosted:ScaleWidth(math.max(0, math.min(100, (4 * 5 * levelOnCurrentBar) + ( 4 * 5 * progressPercentBoosted))) .. '%', PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 0.5)
								levelBarBoostedLeader:SlideX(math.max(0, math.min(100, (4 * 5 * levelOnCurrentBar) + ( 4 * 5 * progressPercentBoosted))) .. '%', PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 0.5)
								levelBarBoostedGlowWidth:ScaleWidth(math.max(0, math.min(100, (4 * 5 * levelOnCurrentBar) + ( 4 * 5 * (progressPercentBoosted - percentProgress)) - 1.27 )) .. '%', PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 0.5)
								wait(PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 0.5)	
							end				
						end
						
						return (questTable.percentProgress >= 1)
					else
						return false
					end						
				else
					return false
				end
			end					
			
			local function CompleteLevelAnimation(questTable, completedLevel, dontAnimate)
				
				-- println('^c CompleteLevelAnimation | completedLevel: ' .. completedLevel)
				
				-- Level pip animations
				UpdateLevelPips(currentAnimationSegment, completedLevel, dontAnimate)
				
				-- Unlock your prizes animations
				
				UpdatePrizeDisplay(completedLevel, true, dontAnimate)
				if (dontAnimate) then
				
				else
					PlaySound('/ui/sounds/rewards/sfx_chest_open_3.wav')
					wait(PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 5.5)	
				end
				
			end					
			
			local function AnimateToNextLevel(questTable, currentAnimationLevel, currentAnimationSegment, newAnimationSegment, lastLevel, lastSegment)
				
				-- println('^c AnimateToNextLevel | currentAnimationLevel: ' .. currentAnimationLevel .. ' | newAnimationSegment: ' .. newAnimationSegment)
				
				-- Level pip animations

				wait(PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 1.5)	
				
				UpdatePrizeDisplay(currentAnimationLevel)
				
			end			
			
			local function AnimateToNextSegment(questTable, currentAnimationLevel, currentAnimationSegment, newAnimationSegment, lastLevel, lastSegment)
				
				clickedLevel = nil
				
				-- println('^c AnimateToNextSegment | currentAnimationSegment: ' .. currentAnimationSegment .. ' | newAnimationSegment: ' .. newAnimationSegment)
				
				-- Yay victory animation
				wait(PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 3.5)	
				
				-- Move bar over 
				ResetToPrevious(currentAnimationLevel, true)
				
				wait(PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 1.5)	

			end				
			
			-- Show account boost
			local function ShowAccountBoost()
				GetWidget('playRewards_accountboost_parent'):FadeIn(250)
				if libGeneral.DoIHaveAnAccountExperienceBoost() then
					GetWidget('player_card_purchase_bonus_label'):SetText(Translate('postgame_boost_active_label'))
					GetWidget('playRewards_accountboost_parent'):SetCallback('onclick', function(widget)
						libBoost.ShowAccountBoostPurchaseSplash()					
					end)	
					GetWidget('playRewards_accountboost_icon_parent'):SetCallback('onclick', function(widget)
						libBoost.ShowAccountBoostPurchaseSplash()
					end)					
				else
					GetWidget('player_card_purchase_bonus_label'):SetText(Translate('player_card_boost_inactive_header'))
					GetWidget('playRewards_accountboost_parent'):SetCallback('onclick', function(widget)
						libBoost.ShowAccountBoostPurchaseSplash()					
					end)					
					GetWidget('playRewards_accountboost_icon_parent'):SetCallback('onclick', function(widget)
						libBoost.ShowAccountBoostPurchaseSplash()
					end)
				end				
			end			
			
			local function RegisterNavigation()
				local postgame_progress_bar_forward 		= GetWidget('postgame_progress_bar_forward')
				local postgame_progress_bar_back 			= GetWidget('postgame_progress_bar_back')
				local animationLevelOverride					= 0
				
				postgame_progress_bar_forward:SetCallback('onclick', function(widget)
					if (not animationInProgress) then
						animationLevelOverride = math.min(MAX_LEVEL, math.max((-1*MAX_LEVEL), animationLevelOverride + 5))
						animationLevelOverride = math.min((MAX_LEVEL-currentAnimationLevel)-1, math.max((-1*currentAnimationLevel)+5, animationLevelOverride))
						animationInProgress = true
						ResetToPrevious(currentAnimationLevel, false, animationLevelOverride)
						if AnimateToNextExperience(questTable, currentAnimationLevel, currentAnimationSegment, newAnimationSegment, lastLevel, lastSegment, true) then
							CompleteLevelAnimation(questTable, currentAnimationLevel, true)
						end	
						animationInProgress = false
					end
				end)
				postgame_progress_bar_forward:SetCallback('onmouseover', function(widget)
					widget:SetColor('1 1 1 1')
				end)
				postgame_progress_bar_forward:SetCallback('onmouseout', function(widget)
					widget:SetColor('.6 .6 .6 .6')
				end)				
				
				postgame_progress_bar_back:SetCallback('onclick', function(widget)
					if (not animationInProgress) then
						animationLevelOverride = math.min(MAX_LEVEL, math.max((-1*MAX_LEVEL), animationLevelOverride - 5))
						animationLevelOverride = math.min((MAX_LEVEL-currentAnimationLevel)-1, math.max((-1*currentAnimationLevel)+5, animationLevelOverride))
						animationInProgress = true
						ResetToPrevious(currentAnimationLevel, false, animationLevelOverride)
						if AnimateToNextExperience(questTable, currentAnimationLevel, currentAnimationSegment, newAnimationSegment, lastLevel, lastSegment, true) then
							CompleteLevelAnimation(questTable, currentAnimationLevel, true)
						end
						animationInProgress = false
					end
				end)				
				postgame_progress_bar_back:SetCallback('onmouseover', function(widget)
					widget:SetColor('1 1 1 1')
				end)
				postgame_progress_bar_back:SetCallback('onmouseout', function(widget)
					widget:SetColor('.6 .6 .6 .6')
				end)	
				
			end
			
			local function PlayProgressAnimation()
				
				animationInProgress = true
				
				ResetToPrevious()
				ShowAccountBoost()
				RegisterNavigation()
				 
				GetWidget('postgame_summary_insert_upcoming_unlocks'):FadeIn(PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 0.5)
				GetWidget('postgame_summary_insert_account_progression'):FadeIn(PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 0.5)
				
				wait(PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 0.5)
				
				local lastLevel, lastSegment, lastCompletedLevel
				if ((accountQuestIndexesWithProgress) and (#accountQuestIndexesWithProgress > 0)) then
					for index, accountQuestIndexes in ipairs(accountQuestIndexesWithProgress) do
						currentAnimationLevel			= accountQuestIndexes
						local newAnimationSegment		= math.ceil((currentAnimationLevel) / LEVELS_PER_SEGMENT)
						local questTable = PostGame.Splash.modules.allAccountProgression[currentAnimationLevel]
						if (lastLevel) and (currentAnimationLevel ~= lastLevel) and ((not lastCompletedLevel) or (lastCompletedLevel ~= lastLevel)) then
							CompleteLevelAnimation(questTable, lastLevel)
							lastCompletedLevel = lastLevel
						end
						if (lastLevel) and (currentAnimationLevel ~= lastLevel) then
							AnimateToNextLevel(questTable, currentAnimationLevel, currentAnimationSegment, newAnimationSegment, lastLevel, lastSegment)
						end							

						if AnimateToNextExperience(questTable, currentAnimationLevel, currentAnimationSegment, newAnimationSegment, lastLevel, lastSegment) then
							CompleteLevelAnimation(questTable, currentAnimationLevel)
							lastCompletedLevel = currentAnimationLevel
						end

						if (lastSegment) and (newAnimationSegment ~= lastSegment) then
							AnimateToNextSegment(questTable, currentAnimationLevel, currentAnimationSegment, newAnimationSegment, lastLevel, lastSegment)
						end							
						currentAnimationSegment			= newAnimationSegment
						lastLevel						= currentAnimationLevel
						lastSegment						= currentAnimationSegment
						wait(PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 1)	
					end
					animationInProgress = false	
				else
					animationInProgress = false	
					ResetWithoutQuestData()
				end
			end
		
			PlayProgressAnimation()
			
			wait(PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier * 1)	
			
		else
			println('No account progression module')
		end

		if (PostGame.selfInfo) and (PostGame.selfInfo.matchType) and (PostGame.selfInfo.matchType == 'pvp') and (PostGame.Splash.modules) and (PostGame.Splash.modules.rankedPlayProgression) and (PostGame.Splash.modules.rankedPlayProgression.status) and (PostGame.Splash.modules.rankedPlayProgression.status ~= '') then
			if (PostGame.Splash.modules.rankedPlayProgression.status == 'provisional') then
				-- Still in provisional division
				println('pvp standard division provisional')
				
				local winsNeeded  = PostGame.Splash.modules.rankedPlayProgression.winsReq - PostGame.Splash.modules.rankedPlayProgression.wins
				local text = Translate('ranked_division_provisional', 'remaining', winsNeeded)
				local tip = Translate('ranked_division_provisional', 'remaining', winsNeeded)
				local desc = Translate('ranked_newdivision_provisional_desc', 'remaining', winsNeeded)
				
				local rankUpTable = {{
					text,
					'/ui/main/shared/textures/elo_rank_0.tga',
					tip,
					desc,
				}}
				
				DisplayReward(rankUpTable, nil, 'postgame_summary_game_ranked_rating_template')						
				
				wait(PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier)
				
			elseif (PostGame.Splash.modules.rankedPlayProgression.status == 'promoted') then
				-- Promoted Division
				println('pvp standard division promoted')
				wait(PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier)
				
				local text = Translate('ranked_promoted') .. '\n ' .. Translate('ranked_division_' .. PostGame.Splash.modules.rankedPlayProgression.division)
				local tip = Translate('ranked_division_' .. PostGame.Splash.modules.rankedPlayProgression.division .. '_num')
				local desc = Translate('ranked_newrating_explaination', 'division', Translate('ranked_division_'..PostGame.Splash.modules.rankedPlayProgression.division))
				
				local rankUpTable = {{
					text,
					(libCompete.divisions[libCompete.divisionNumberByName[PostGame.Splash.modules.rankedPlayProgression.division]].icon),
					tip,
					desc,
				}}
				
				DisplayReward(rankUpTable, nil, 'postgame_summary_game_ranked_rating_template')				
				
				local ui_dev_rankup_label 		= object:GetWidget('ui_dev_rankup_label')
				if (ui_dev_rankup_label) then
					ui_dev_rankup_label:SetText(Translate('ranked_promoted') .. ' ' .. Translate('ranked_division_' .. PostGame.Splash.modules.rankedPlayProgression.division))
				end
				
				RankUpAnim(object, PostGame.Splash.modules.rankedPlayProgression.lastDivisionIndex, PostGame.Splash.modules.rankedPlayProgression.divisionIndex)
				
				wait(7 * PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier)
				
			elseif (PostGame.Splash.modules.rankedPlayProgression.status == 'demoted') then
				-- Demoted Division
				println('pvp standard division demoted')
				wait(PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier)
				
				local text = Translate('ranked_division_' .. PostGame.Splash.modules.rankedPlayProgression.division)
				local tip = Translate('ranked_division_' .. PostGame.Splash.modules.rankedPlayProgression.division .. '_num')
				local desc = Translate('ranked_newrating_explaination', 'division', Translate('ranked_division_'..PostGame.Splash.modules.rankedPlayProgression.division))
				
				local rankUpTable = {{
					text,
					(libCompete.divisions[libCompete.divisionNumberByName[PostGame.Splash.modules.rankedPlayProgression.division]].icon),
					tip,
					desc,
				}}
				
				DisplayReward(rankUpTable, nil, 'postgame_summary_game_ranked_rating_template')					
				
				local ui_dev_rankup_label 		= object:GetWidget('ui_dev_rankup_label')
				if (ui_dev_rankup_label) then
					ui_dev_rankup_label:SetText(Translate('ranked_demoted') .. ' ' .. Translate('ranked_division_' .. PostGame.Splash.modules.rankedPlayProgression.division))
				end				
				
				RankUpAnim(object, PostGame.Splash.modules.rankedPlayProgression.lastDivisionIndex, PostGame.Splash.modules.rankedPlayProgression.divisionIndex)
				
				wait(7 * PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier)
			else
				-- No division change
				println('No pvp standard division change')
			end
		else
			println('No pvp standard division module')
		end		
			
		if (GetCvarBool('ui_testPostgame')) then	
			PostGame.Splash.modules.claimRewardResponseData = PostGame.Splash.modules.claimRewardResponseData or {
				reward = {
					currentTier = 10,
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
			}
		end

		if (PostGame.Splash.modules) and (PostGame.Splash.modules.claimRewardResponseData) then

			local responseData = PostGame.Splash.modules.claimRewardResponseData
			local rewardData = responseData.reward	
			local boostModifier = responseData.boostRewards or 1
			boostModifier = boostModifier -	1 -- remove base 100%
			
			if (rewardData) then

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
					
					local glowColor = '0 0.94 1 0.4' --Default
					local labelColor = '0 0.94 1 1' --Default
					
					if (commodity == 'essence') then
						glowColor = '1 0.92 0.64 0.4'
						labelColor = '#fffea8'
					elseif (commodity == 'food') then
						glowColor = '0.89 0.66 1 0.4'
						labelColor = '#e3a8ff'
					end
					
					if (value) and (tonumber(value) > 0) then
						if (bonus) and (tonumber(bonus) > 0) then
							if (tonumber(value) > 1) then
								table.insert(rewardTables, {Translate('general_commodity_' .. commodity .. '_x', 'value', value) .. '\n' ..Translate('general_commodity_bonus_x', 'bonus', bonus), Translate('general_commodity_texture_' .. commodity), Translate('general_commodity_' .. commodity), Translate('general_commodity_' .. commodity .. '_x', 'value', value) .. '\n' ..Translate('general_commodity_bonus_x', 'bonus', bonus), nil, glowColor, labelColor})
							else	
								table.insert(rewardTables, {Translate('general_commodity_' .. commodity .. '_x_single', 'value', value) .. '\n' ..Translate('general_commodity_bonus_x', 'bonus', bonus), Translate('general_commodity_texture_' .. commodity), Translate('general_commodity_' .. commodity), Translate('general_commodity_' .. commodity .. '_x_single', 'value', value) .. '\n' ..Translate('general_commodity_bonus_x', 'bonus', bonus), nil, glowColor, labelColor})
							end
						else
							if (tonumber(value) > 1) then
								table.insert(rewardTables, {Translate('general_commodity_' .. commodity .. '_x', 'value', value), Translate('general_commodity_texture_' .. commodity), Translate('general_commodity_' .. commodity), Translate('general_commodity_' .. commodity .. '_x', 'value', value), nil, glowColor, labelColor})
							else	
								table.insert(rewardTables, {Translate('general_commodity_' .. commodity .. '_x_single', 'value', value), Translate('general_commodity_texture_' .. commodity), Translate('general_commodity_' .. commodity), Translate('general_commodity_' .. commodity .. '_x_single', 'value', value), nil, glowColor, labelColor})
							end
						end
					end
				end			

				if (rewardTables) and (#rewardTables > 0) then
					for i,v in pairs(rewardTables) do
						local rewardTable = {v}
						DisplayReward(rewardTable)
						wait(1 * PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier)
					end
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
		else
			println('No rewards module')
		end
		
		if (PostGame.Splash.modules) and (PostGame.Splash.modules.questProgression) and (#PostGame.Splash.modules.questProgression > 0) then
			local questsShown = 0
			for i, questTable in pairs(PostGame.Splash.modules.questProgression) do
				-- Block all quests that aren't complete for now
				if (not questTable) and (((not questTable.percentProgress) or (questTable.percentProgress < 1) and (not ((questTable.rewardsAvailable) and (questTable.rewardsAvailable.used) and (questTable.rewardsAvailable.used == '0') and (questTable.rewardsAvailable.questRewardIncrement))))) then
					
				else
					if (questTable.quest) and (questTable.quest.required) and (questTable.quest.required.experience) and (questTable.quest.required.experience.experience) and (not (GetCvarBool('ui_testPostgame5'))) then -- dont show account xp quests here
						
					elseif (questsShown <= 3) then
						
						questsShown = questsShown + 1
						
						local showCount = (not Empty(TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_reward_label_1') or questTable.rewardText1 or '')) or false
						
						local rewardCount = TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_reward_count') or questTable.rewardCount or '0'

						local hasReward1 = tonumber( rewardCount ) >= 1
						local hasReward2 = tonumber( rewardCount ) >= 2
						local hasReward3 = tonumber( rewardCount ) >= 3	
						
						local rewardText1 = TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_reward_label_1') or questTable.rewardCount1 or questTable.rewardText1 or ''
						local rewardText2 = TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_reward_label_2') or questTable.rewardCount2 or questTable.rewardText2 or ''
						local rewardText3 = TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_reward_label_3') or questTable.rewardCount3 or questTable.rewardText3 or ''
						
						local rewardIcon1 = TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_reward_texture_1') or questTable.rewardIcon1 or '/ui/main/shared/textures/scroll.tga'
						local rewardIcon2 = TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_reward_texture_2') or questTable.rewardIcon2 or '/ui/main/shared/textures/scroll.tga'
						local rewardIcon3 = TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_reward_texture_3') or questTable.rewardIcon3 or '/ui/main/shared/textures/scroll.tga'
						
						local isComplete, progressLabel1 = false, ''
						if (questTable.percentProgress >= 1) then
							isComplete = true
							progressLabel1 = Translate('general_complete')
						elseif (questTable.percentProgress <= 0) then
							isComplete = false
							progressLabel1 = tostring(questTable.currentProgress) .. ' / ' .. tostring(questTable.requirementTotal)
						else
							isComplete = false
							progressLabel1 = tostring(questTable.currentProgress) .. ' / ' .. tostring(questTable.requirementTotal)
						end					
						
						postgame_summary_insert_match_awards_5more:RecalculateSize()
						postgame_summary_insert_match_awards_5more:RecalculatePosition()				
					
						local template = 'postgame_summary_game_quest_1_prizes_template'
					
						if (hasReward3) then
							template = 'postgame_summary_game_quest_3_prizes_template'
						elseif (hasReward2) then
							template = 'postgame_summary_game_quest_2_prizes_template'
						end
						
						local prizeWidgets = postgame_summary_insert_match_awards_5more:InstantiateAndReturn(template,
							'index', questsShown,
							'questName1', TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_name') or questTable.labelText or '',
							'progressLabel1', tostring(progressLabel1),
							'isComplete', tostring(isComplete),
							'backgroundTexture1', TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_texture') or '/ui/main/quests/textures/quest_item_card_lexikhan.tga',
							'rewardIcon1', rewardIcon1,
							'rewardIcon2', rewardIcon2,
							'rewardIcon3', rewardIcon3,
							'rewardText1', rewardText1,
							'rewardText2', rewardText2,
							'rewardText3', rewardText3,
							'progressPercent', math.min(100, (questTable.percentProgress * 100)),
							'oldProgressPercent', math.min(100, ((questTable.percentProgress - questTable.percentLatestProgress) * 100)),
							'questTypeIcon', TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_type_icon') or questTable.questTypeIcon or '$invis',
							'group', 'postgame_splash_quest_items',
							'visible', 'false',
							'showCount', tostring(showCount)
						)
						local prizeParent = prizeWidgets[1]
				
						-- Is there something specific we want to bounce? Else, we'll bounce in the entire widget
						if (prizeParent:GetWidget('postgame_summary_quests_reward_'..questsShown..'_bounce')) then
							prizeParent:FadeIn(250) --Fades in all elements, since we're about to change prizeParent to something more specific
							prizeParent = GetWidget('postgame_summary_quests_reward_'..questsShown..'_bounce')
						end
						
						local function flairEffect(widget, width, height, duration)
							widget:SetVisible(0)
							libAnims.bounceIn(widget, width * 1.0, height * 1.0, true, duration, 0.2, 200, 0.8, 0.2)
						end
						
						flairEffect(prizeParent, prizeParent:GetWidth(), prizeParent:GetHeight(), PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier)

						if ((questTable.rewardsAvailable) and (questTable.rewardsAvailable.used) and (questTable.rewardsAvailable.used == '0') and (questTable.rewardsAvailable.questRewardIncrement)) then
							if (questTable.craftedItemReward) then
								table.insert(queuedCraftedItemSplashScreens, questTable.craftedItemReward)
							elseif (questTable.splashTemplate) then
								table.insert(queuedSplashScreens, questTable.splashTemplate)
							end		

							if (questTable.rewardsAvailable and (type(questTable.rewardsAvailable) == 'table') and (#questTable.rewardsAvailable > 0)) then
								
								for rewardIndex, rewardRawTable in pairs(questTable.rewardsAvailable) do
									
									if (rewardRawTable.used == '0') and (rewardRawTable.questRewardIncrement) and (questTable.questIncrement) then

										rewardsClaimed = rewardsClaimed + 1
										
										if (rewardsClaimed <= MAX_REWARDS_CLAIMABLE) then
									
											local successFunction =  function (request)	-- response handler
												local responseData = request:GetBody()
												if responseData == nil then
													SevereError('ClaimQuestReward - no response data. quest: ' .. (questTable.questIncrement) .. ' - reward: ' .. rewardRawTable.questRewardIncrement, 'main_reconnect_thatsucks', '', nil, nil, false)
												else
													println('Claimed reward for quest: ' .. questTable.questIncrement .. ' - reward: ' .. rewardRawTable.questRewardIncrement)
													Quests																								= Quests or {}
													Quests.questDataConsolidationTable 																	= Quests.questDataConsolidationTable or {}
													Quests.questDataConsolidationTable[questTable.questIncrement] 										= Quests.questDataConsolidationTable[questTable.questIncrement] or {}
													Quests.questDataConsolidationTable[questTable.questIncrement].rewardsAvailable 						= Quests.questDataConsolidationTable[questTable.questIncrement].rewardsAvailable or {}
													Quests.questDataConsolidationTable[questTable.questIncrement].rewardsAvailable[rewardIndex]			= Quests.questDataConsolidationTable[questTable.questIncrement].rewardsAvailable[rewardIndex] or {}
													Quests.questDataConsolidationTable[questTable.questIncrement].rewardsAvailable[rewardIndex].used	= '1'		
													rewardRawTable.used																					= '1'
												end
												trigger_postGameLoopStatus.requestingClaimQuestReward = false
												trigger_postGameLoopStatus:Trigger(false)														
											end

											local failFunction =  function (request)	-- error handler
												SevereError('ClaimQuestReward Request Error: ' .. Translate(request:GetError()) .. '.  Quest: ' .. (questTable.questIncrement)  .. '.  Reward: ' .. (rewardRawTable.questRewardIncrement), 'main_reconnect_thatsucks', '', nil, nil, false)
												trigger_postGameLoopStatus.requestingClaimQuestReward = false
												trigger_postGameLoopStatus:Trigger(false)							
											end				
									
											trigger_postGameLoopStatus.requestingClaimQuestReward = true
											trigger_postGameLoopStatus:Trigger(false)				
											
											Strife_Web_Requests:ClaimQuestReward(
												successFunction,
												failFunction,
												rewardRawTable.questRewardIncrement
											)
											
										else
											
											if (QUESTS_CAN_BULK_CLAIM) then
												QUESTS_CAN_BULK_CLAIM = false
											
												local successFunction =  function (request)	-- response handler
													local responseData = request:GetBody()
													if responseData == nil then
														SevereError('ClaimAllQuestRewards - no response data', 'main_reconnect_thatsucks', '', nil, nil, false)
													else
														println('ClaimAllQuestRewards Success')
													end
													trigger_postGameLoopStatus.requestingClaimQuestReward = false
													trigger_postGameLoopStatus:Trigger(false)														
												end

												local failFunction =  function (request)	-- error handler
													SevereError('ClaimAllQuestRewards Request Error: ' .. Translate(request:GetError()), 'main_reconnect_thatsucks', '', nil, nil, false)
													trigger_postGameLoopStatus.requestingClaimQuestReward = false
													trigger_postGameLoopStatus:Trigger(false)							
												end						
											
												trigger_postGameLoopStatus.requestingClaimQuestReward = true
												trigger_postGameLoopStatus:Trigger(false)						
											
												Strife_Web_Requests:ClaimAllQuestRewards(
													successFunction,
													failFunction
												)					
											
											end
											
										end
										
									end
								end
							end	
							
						elseif ((questTable.percentProgress) and (questTable.percentProgress >= 1) and (questTable.percentLatestProgress) and (questTable.percentLatestProgress > 0)) then
							if (questTable.craftedItemReward) then
								table.insert(queuedCraftedItemSplashScreens, questTable.craftedItemReward)
							elseif (questTable.splashTemplate) then
								table.insert(queuedSplashScreens, questTable.splashTemplate)
							end						
						end		

						wait(1 * PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier)	
							
					end
				end
			end
		else
			println('No quest progress module')
		end		

		if (PostGame.Splash.modules) and (PostGame.Splash.modules.ladder) and (PostGame.Splash.modules.ladder.newLadderPoints) and (PostGame.Splash.modules.ladder.newLadderPoints > 0) then

			local commodityAmounts	= {
				{name = 'rankpoints', value = PostGame.Splash.modules.ladder.newLadderPoints, bonus = 0},
			}				
			
			local rewardTables = {}
			for index, commodityTable in pairs(commodityAmounts) do
				local commodity 	= commodityTable.name
				local bonus 		= commodityTable.bonus
				local value 		= commodityTable.value + bonus
				
				local glowColor = '0 0.94 1 0.4' --Default
				local labelColor = '0 0.94 1 1' --Default
				
				if (commodity == 'essence') then
					glowColor = '1 0.92 0.64 0.4'
					labelColor = '#fffea8'
				elseif (commodity == 'food') then
					glowColor = '0.89 0.66 1 0.4'
					labelColor = '#e3a8ff'
				end
				
				if (value) and (tonumber(value) > 0) then
					if (bonus) and (tonumber(bonus) > 0) then
						if (tonumber(value) > 1) then
							table.insert(rewardTables, {Translate('general_commodity_' .. commodity .. '_x', 'value', value) .. '\n' ..Translate('general_commodity_bonus_x', 'bonus', bonus), Translate('general_commodity_texture_' .. commodity), Translate('general_commodity_' .. commodity), Translate('general_commodity_' .. commodity .. '_x', 'value', value) .. '\n' ..Translate('general_commodity_bonus_x', 'bonus', bonus), nil, glowColor, labelColor})
						else	
							table.insert(rewardTables, {Translate('general_commodity_' .. commodity .. '_x_single', 'value', value) .. '\n' ..Translate('general_commodity_bonus_x', 'bonus', bonus), Translate('general_commodity_texture_' .. commodity), Translate('general_commodity_' .. commodity), Translate('general_commodity_' .. commodity .. '_x_single', 'value', value) .. '\n' ..Translate('general_commodity_bonus_x', 'bonus', bonus), nil, glowColor, labelColor})
						end
					else
						if (tonumber(value) > 1) then
							table.insert(rewardTables, {Translate('general_commodity_' .. commodity .. '_x', 'value', value), Translate('general_commodity_texture_' .. commodity), Translate('general_commodity_' .. commodity), Translate('general_commodity_' .. commodity .. '_x', 'value', value), nil, glowColor, labelColor})
						else	
							table.insert(rewardTables, {Translate('general_commodity_' .. commodity .. '_x_single', 'value', value), Translate('general_commodity_texture_' .. commodity), Translate('general_commodity_' .. commodity), Translate('general_commodity_' .. commodity .. '_x_single', 'value', value), nil, glowColor, labelColor})
						end
					end
				end
			end			

			if (rewardTables) and (#rewardTables > 0) then
				for i,v in pairs(rewardTables) do
					local rewardTable = {v}
					DisplayReward(rewardTable, nil, 'postgame_summary_game_ladder_reward_template')
					wait(1 * PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier)
				end
			end				
	
		else
			println('No ladder module')
		end		
		
		for i,v in ipairs(queuedCraftedItemSplashScreens) do
			wait(1 * PostGame.Splash.animationDelayUnit * PostGame.Splash.animationDelayMultiplier)	
			local itemEntity 				= v.entityName
			local itemComponentEntity1 		= v.component1
			local itemComponentEntity2 		= v.component2
			local itemComponentEntity3 		= v.component3
			local itemImbuement 			= v.imbueEffect
			ShowGiftedCraftedItemSplashScreen(itemEntity, itemComponentEntity1, itemComponentEntity2, itemComponentEntity3, itemImbuement)
		end
		
		for i,v in ipairs(queuedSplashScreens) do
			if (mainUI) and (mainUI.savedRemotely) and ((not mainUI.savedRemotely.splashScreensViewed) or (not mainUI.savedRemotely.splashScreensViewed[v])) then
				mainUI.savedRemotely = mainUI.savedRemotely or {}
				mainUI.savedRemotely.splashScreensViewed = mainUI.savedRemotely.splashScreensViewed or {}
				mainUI.savedRemotely.splashScreensViewed[v] = true
				SaveState()		
				println('show splash screen' .. tostring(v))
				mainUI.ShowSplashScreen(v)		
			else
				println('dont show splash screen as it has been seen before ' .. tostring(v))
			end
		end		
		
		trigger_postGameLoopStatus.summaryAnimationActive = false
		trigger_postGameLoopStatus.fastForwarding = false
		trigger_postGameLoopStatus:Trigger(false)		
		
		println('Postgame splash complete')
		
		PostGame.Splash.animateSplashScreenThread = nil
	end)
end

PostGame.Splash.splashUpdateDelayThread = nil
function PostGame.Splash.PrepareSpashScreen()
	println('PostGame.Splash.PrepareSpashScreen()')
	
	local postgame_summary_insert_match_awards_5more 			= 	GetWidget('postgame_summary_insert_match_awards_5more')
	local postgame_summary_insert_match_awards_4less 			= 	GetWidget('postgame_summary_insert_match_awards_4less')
	
	local postgame_summary_insert_account_progression 			= 	GetWidget('postgame_summary_insert_account_progression')
	local postgame_summary_insert_account_progression_insert 	= 	GetWidget('postgame_summary_insert_account_progression_insert')
	local postgame_summary_insert_upcoming_unlocks 				= 	GetWidget('postgame_summary_insert_upcoming_unlocks')
	local postgame_summary_insert_match_awards 					= 	GetWidget('postgame_summary_insert_match_awards')
	local postgame_summary_insert_match_awards_insert 			= 	GetWidget('postgame_summary_insert_match_awards_insert')
	local postgame_summary_insert_match_awards_insert_label 	= 	GetWidget('postgame_summary_insert_match_awards_insert_label')
	
	GetWidget('post_game_loop_nav_continue_button_parent'):SetVisible(0)
	GetWidget('post_game_loop_nav_continue_button_throb'):SetVisible(1)
	groupfcall('postgame_quest_prize_template', function(_, widget) widget:Destroy() end)
	groupfcall('postgame_splash_quest_items', function(_, widget) widget:Destroy() end)
	groupfcall('postgame_quest_accountlevels', function(_, widget) widget:Destroy() end)
	postgame_summary_insert_match_awards_5more:ClearChildren()
	postgame_summary_insert_match_awards_5more:SetVisible(0)
	postgame_summary_insert_match_awards_4less:ClearChildren()
	postgame_summary_insert_match_awards_4less:SetVisible(0)
	postgame_summary_insert_match_awards_insert:ClearChildren()
	postgame_summary_insert_match_awards_insert:SetVisible(0)
	postgame_summary_insert_match_awards_insert_label:SetVisible(0)
	postgame_summary_insert_match_awards:SetVisible(0)
	GetWidget('postgame_summary_insert_account_progression'):SetVisible(0)
	GetWidget('postgame_summary_insert_upcoming_unlocks'):SetVisible(0)
	GetWidget('postgame_summary_insert_game_results_header'):SetVisible(0)	
	GetWidget('postgame_summary_insert_game_results_header_flare'):SetVisible(0)	
	
	trigger_postGameLoopStatus.summaryAnimationActive = true
	trigger_postGameLoopStatus.fastForwarding = false
	trigger_postGameLoopStatus:Trigger(false)	
	
	if (PostGame.Splash.splashUpdateDelayThread) then
		PostGame.Splash.splashUpdateDelayThread:kill()
		PostGame.Splash.splashUpdateDelayThread = nil
	end
	PostGame.Splash.splashUpdateDelayThread = libThread.threadFunc(function()
		wait(500)
		PostGame.Splash.AnimateSpashScreen()
		PostGame.Splash.splashUpdateDelayThread = nil
	end)	
	
end

GetWidget('postgame_summary'):RegisterWatchLua('PostGameGroupTrigger', function(widget, _)
	libGeneral.fade(widget, (PostGameLoopStatus.screen == 'SUMMARY'), 250)
end, false, nil)


PostGame.Splash.awardsInfo = {}
PostGame.Splash.awardsInfoTeam = {}
PostGame.Splash.awardsInfoSelf = {}
function PostGame.Splash.AssignAwards(matchStatsTable)
	
	PostGame.Splash.modules.matchAwards = {}
	
	local matchStats		= {
		tAwardsGroup		= {},
		tAwardsGroupTeam	= {},
		tAwardsPlayer		= {},
		tAwardsPlayerAv		= {},
		tAwardsPlayerTeam	= {},
		tAwardsPlayerTeamAv	= {},
		tPersonalBest		= {},
	}
	
	PostGame.selfInfo = nil
	local usePlayerIndex
	
	if (not matchStatsTable.matchStats.stats) then
		SevereError('AssignAwards called with no matchStats.stats table '.. tostring(matchStatsTable), 'main_reconnect_thatsucks', '', nil, nil, false)
		return
	end
			
	local function getPlayerFromIdentID(playerStats, identID)
		for k,v in pairs(playerStats) do
			if v.identID == identId then
				return v
			end
		end
	end		
		
	local function CalcAward(matchStats, awardName, awardVar, position, showMin, showMax, nonZero, showAverage, awardGroup)

		if (awardName) and (awardVar) and (showMin or showMax) then
			local awardVar = tonumber(awardVar) or 0

			if (awardGroup) then
				matchStats.tAwardsGroup[awardGroup] = matchStats.tAwardsGroup[awardGroup] or {}
			end

			PostGame.Splash.awardsInfo[awardName] = PostGame.Splash.awardsInfo[awardName] or {}

			if (not nonZero) or (awardVar and (awardVar > 0)) then

				if (matchStats.tAwardsGroup[awardGroup]) then
					local canGetAward = true
					for i, v in ipairs(matchStats.tAwardsGroup[awardGroup]) do
						if (v == position) then
							canGetAward = false
							break
						end
					end
					if (canGetAward) then
						PostGame.Splash.awardsInfo[awardName][awardVar] = position
						table.insert(matchStats.tAwardsGroup[awardGroup], position)
					end
				else
					PostGame.Splash.awardsInfo[awardName][awardVar] = position
				end
			end

			local tPositions = {}
			for val, pos in pairsByKeys(PostGame.Splash.awardsInfo[awardName]) do
			  table.insert(tPositions, pos)
			end

			if (#tPositions > 0) then
				if (showMin) and (#tPositions > 1) then
					matchStats.tAwardsPlayer[tPositions[1]] = matchStats.tAwardsPlayer[tPositions[1]] or {}
					table.insert(matchStats.tAwardsPlayer[tPositions[1]],  awardName..'_l')
				end
				if (showMax) then
					matchStats.tAwardsPlayer[tPositions[#tPositions]] = matchStats.tAwardsPlayer[tPositions[#tPositions]] or {}
					table.insert(matchStats.tAwardsPlayer[tPositions[#tPositions]], awardName..'_m')
				end
				if (showAverage) then
					for i, v in ipairs(tPositions) do 
						if (#tPositions >= 2) and (i < (#tPositions/2)) and (i > 1) then
							matchStats.tAwardsPlayerAv[tPositions[i]] = matchStats.tAwardsPlayer[tPositions[i]] or {}
							table.insert(matchStats.tAwardsPlayerAv[tPositions[i]], awardName..'_av')
						end
					end
				end			
			end
		end
	end	
	
	local function CalcAwardTeam(matchStats, awardName, awardVar, position, showMin, showMax, nonZero, showAverage, awardGroup)

		if (awardName) and (awardVar) and (showMin or showMax) then
			local awardVar = tonumber(awardVar) or 0

			if (awardGroup) then
				matchStats.tAwardsGroup[awardGroup] = matchStats.tAwardsGroup[awardGroup] or {}
			end

			PostGame.Splash.awardsInfoTeam[awardName] = PostGame.Splash.awardsInfoTeam[awardName] or {}

			if (not nonZero) or (awardVar and (awardVar > 0)) then

				if (matchStats.tAwardsGroup[awardGroup]) then
					local canGetAward = true
					for i, v in ipairs(matchStats.tAwardsGroup[awardGroup]) do
						if (v == position) then
							canGetAward = false
							break
						end
					end
					if (canGetAward) then
						PostGame.Splash.awardsInfoTeam[awardName][awardVar] = position
						table.insert(matchStats.tAwardsGroup[awardGroup], position)
					end
				else
					PostGame.Splash.awardsInfoTeam[awardName][awardVar] = position
				end
			end

			local tPositions = {}
			for val, pos in pairsByKeys(PostGame.Splash.awardsInfoTeam[awardName]) do
			  table.insert(tPositions, pos)
			end

			if (#tPositions > 0) then
				if (showMin) and (#tPositions > 1) then
					matchStats.tAwardsPlayerTeam[tPositions[1]] = matchStats.tAwardsPlayerTeam[tPositions[1]] or {}
					table.insert(matchStats.tAwardsPlayerTeam[tPositions[1]],  awardName..'_tl')
				end
				if (showMax) then
					matchStats.tAwardsPlayerTeam[tPositions[#tPositions]] = matchStats.tAwardsPlayerTeam[tPositions[#tPositions]] or {}
					table.insert(matchStats.tAwardsPlayerTeam[tPositions[#tPositions]], awardName..'_tm')
				end
				if (showAverage) then
					for i, v in ipairs(tPositions) do 
						if (#tPositions >= 2) and (i < (#tPositions/2)) and (i > 1) then
							matchStats.tAwardsPlayerTeamAv[tPositions[i]] = matchStats.tAwardsPlayerTeam[tPositions[i]] or {}
							table.insert(matchStats.tAwardsPlayerTeamAv[tPositions[i]], awardName..'_tav')
						end
					end
				end				
			end
		end
	end		
	
	local myTeam
	local mySlot
	
	local function isAlly(slot)		
		slot = tonumber(slot)
		myTeam = tonumber(myTeam)
		if (not myTeam) or ((myTeam ~= 1) and (myTeam ~= 2)) then
			return false
		elseif (myTeam == 1) and ((slot) and ((slot) <= 4) and ((slot) >= 0)) then
			return true
		elseif (myTeam == 2) and ((slot) and ((slot) <= 9) and ((slot) >= 5)) then
			return true
		else
			return false
		end
	end
		
	for playerIndex, playerInfo in pairs(matchStatsTable.matchStats.stats) do
		if playerInfo.ident_id == GetIdentID() then
			PostGame.selfInfo = playerInfo
			mySlot = tonumber(playerInfo.slot)
			if (mySlot <= 4) then
				myTeam = 1
			else
				myTeam = 2
			end
			break
		end
	end
	
	for playerIndex, playerInfo in pairs(matchStatsTable.matchStats.stats) do
		if (playerInfo) then
			if (not playerInfo.slot) then
				SevereError('playerInfo Player Slot Missing #0: '.. tostring(playerInfo.slot), 'main_reconnect_thatsucks', '', nil, nil, false)
				return
			end

			if playerInfo.ident_id then
				if playerInfo.ident_id == '0.000' then
					usePlayerIndex = playerInfo.slot
					for i=1,math.max(0, (2 - string.len(playerInfo.slot))),1 do
						usePlayerIndex = '0'..usePlayerIndex
					end
					usePlayerIndex = '0.0'..usePlayerIndex
				else
					usePlayerIndex = playerInfo.ident_id
				end
			else
				print('no valid or even empty ident_id for '..playerIndex..'\n')
				usePlayerIndex = playerIndex
			end
			
			local isMe = false
			if playerInfo.ident_id == GetIdentID() then
				isMe = true
			end
			
			matchStats.tAwardsPlayer = {}
			matchStats.tAwardsPlayerAv = {}
			matchStats.tAwardsGroup = {}			
			
			playerInfo.gpm 				= tonumber(playerInfo.gpm) or 0
			playerInfo.kills 			= tonumber(playerInfo.kills) or 0
			playerInfo.assists 			= tonumber(playerInfo.assists) or 0
			playerInfo.heroLevel 		= tonumber(playerInfo.heroLevel) or 0
			playerInfo.creepKills 		= tonumber(playerInfo.creepKills) or 0
			playerInfo.deaths 			= tonumber(playerInfo.deaths) or 0
			playerInfo.heroDamage 		= tonumber(playerInfo.heroDamage) or 0
			playerInfo.buildingDamage 	= tonumber(playerInfo.buildingDamage) or 0
			playerInfo.creepDamage 		= tonumber(playerInfo.creepDamage) or 0
			playerInfo.apm 				= tonumber(playerInfo.apm) or 0
			playerInfo.buildingKills 	= tonumber(playerInfo.buildingKills) or 0
			playerInfo.cindaraKills 	= tonumber(playerInfo.cindaraKills) or 0
			playerInfo.balidirKills 	= tonumber(playerInfo.balidirKills) or 0
			playerInfo.atm 				= tonumber(playerInfo.atm) or 0
			playerInfo.purchaseditems 	= playerInfo.purchaseditems or {}
			
			local kad = (tonumber(playerInfo.kills) + tonumber(playerInfo.assists) / math.min(0.5, tonumber(playerInfo.deaths)))
			local purchaseditems = 0
			if (playerInfo.purchasedItems) then
				purchaseditems = #playerInfo.purchasedItems
			end
			
			-- RMM hack to fix broken cindara kills
			if (playerInfo.cindaraKills > 50) then
				playerInfo.cindaraKills = 0
			end
			
			--                     string           field                       index               lowest  highest nonzero  group
			-- MATCH BEST
			CalcAward(matchStats, 'gpm', 			playerInfo.gpm, 											usePlayerIndex, 	false, 	true,	true, 	true, 'gpm')
			CalcAward(matchStats, 'killassist', 	playerInfo.kills + playerInfo.assists, 						usePlayerIndex, 	false, 	true,	true, 	false, 'killassist')
			-- Killstreak
			CalcAward(matchStats, 'kad', 			kad, 														usePlayerIndex, 	false, 	true,	true, 	true, 'kad')
			CalcAward(matchStats, 'level', 			playerInfo.heroLevel, 										usePlayerIndex, 	false, 	true,	true, 	false, 'level')	
			CalcAward(matchStats, 'teamcreepkills', playerInfo.creepKills, 										usePlayerIndex, 	false, 	true, 	true, 	true, 'teamcreepkills')				
			CalcAward(matchStats, 'deaths', 		playerInfo.deaths, 											usePlayerIndex, 	true, 	false,	false, 	false, 'deaths')
			CalcAward(matchStats, 'herodmg', 		playerInfo.heroDamage, 										usePlayerIndex, 	false, 	true,	true, 	true, 'herodmg')
			CalcAward(matchStats, 'bdmg', 			playerInfo.buildingDamage, 									usePlayerIndex, 	false, 	true,	true, 	false, 'bdmg')
			CalcAward(matchStats, 'cdmg', 			playerInfo.creepDamage, 									usePlayerIndex, 	false, 	true,	true, 	true, 'cdmg')
			CalcAward(matchStats, 'actions', 		playerInfo.apm, 											usePlayerIndex, 	false, 	true,	true, 	false, 'actions')
			CalcAward(matchStats, 'razed', 			playerInfo.buildingKills, 									usePlayerIndex, 	false, 	true,	true, 	true, 'razed')
			CalcAward(matchStats, 'bosskills',		playerInfo.cindaraKills + playerInfo.balidirKills, 			usePlayerIndex, 	false, 	true,	true, 	false,'bosskills')
			CalcAward(matchStats, 'purchaseditems',	purchaseditems, 											usePlayerIndex, 	false, 	true,	true, 	false, 'purchaseditems')

			-- TEAM BEST
			if isAlly(usePlayerIndex) then
				matchStats.tAwardsPlayerTeam = {}
				matchStats.tAwardsPlayerTeamAv = {}
				matchStats.tAwardsGroupTeam = {}				
				
				CalcAwardTeam(matchStats, 'gpm', 			playerInfo.gpm, 									usePlayerIndex, 	false, 	true,	true, 	true, 'gpm')
				CalcAwardTeam(matchStats, 'killassist', 	playerInfo.kills + playerInfo.assists, 				usePlayerIndex, 	false, 	true,	true, 	true, 'killassist')
				-- Killstreak
				CalcAwardTeam(matchStats, 'kad', 			kad, 												usePlayerIndex, 	false, 	true,	true, 	true, 'kad')
				CalcAwardTeam(matchStats, 'level', 			playerInfo.heroLevel, 								usePlayerIndex, 	false, 	true,	true, 	false, 'level')	
				CalcAwardTeam(matchStats, 'teamcreepkills', playerInfo.creepKills, 								usePlayerIndex, 	false, 	true, 	true, 	true, 'teamcreepkills')				
				CalcAwardTeam(matchStats, 'deaths', 		playerInfo.deaths, 									usePlayerIndex, 	true, 	false,	false, 	false, 'deaths')
				CalcAwardTeam(matchStats, 'herodmg', 		playerInfo.heroDamage, 								usePlayerIndex, 	false, 	true,	true, 	true, 'herodmg')
				CalcAwardTeam(matchStats, 'bdmg', 			playerInfo.buildingDamage, 							usePlayerIndex, 	false, 	true,	true, 	false, 'bdmg')
				CalcAwardTeam(matchStats, 'cdmg', 			playerInfo.creepDamage, 							usePlayerIndex, 	false, 	true,	true, 	true, 'cdmg')
				CalcAwardTeam(matchStats, 'actions', 		playerInfo.apm, 									usePlayerIndex, 	false, 	true,	true, 	false, 'actions')
				CalcAwardTeam(matchStats, 'razed', 			playerInfo.buildingKills, 							usePlayerIndex, 	false, 	true,	true, 	true, 'razed')
				CalcAwardTeam(matchStats, 'bosskills',		playerInfo.cindaraKills + playerInfo.balidirKills, 	usePlayerIndex, 	false, 	true,	true, 	false, 'bosskills')
				CalcAwardTeam(matchStats, 'purchaseditems',	purchaseditems, 									usePlayerIndex, 	false, 	true,	true, 	false, 'purchaseditems')
			end
			
			-- SELF BEST
			if (isMe) then
				
				matchStats.tPersonalBest = {}
				
				if (mainUI.progression.stats) then
					if (tonumber(mainUI.progression.stats.averageKillsAssists)) and ( (tonumber(playerInfo.kills) + tonumber(playerInfo.assists)) > (tonumber(mainUI.progression.stats.averageKillsAssists) * 1.2) ) then
						table.insert(matchStats.tPersonalBest,  'killassist'..'_pb')
					end
					if (tonumber(mainUI.progression.stats.averageKillsAssists) and tonumber(mainUI.progression.stats.averageDeaths)) and ( (kad) > (1.2 * (tonumber(mainUI.progression.stats.averageKillsAssists) / math.min(0.5, tonumber(mainUI.progression.stats.averageDeaths)))) ) then
						table.insert(matchStats.tPersonalBest,  'kad'..'_pb')
					end				
					if (tonumber(mainUI.progression.stats.averageGPM)) and ( tonumber(playerInfo.gpm) > (1.2 * tonumber(mainUI.progression.stats.averageGPM)) ) then
						table.insert(matchStats.tPersonalBest,  'gpm'..'_pb')
					end	
					if (tonumber(mainUI.progression.stats.averageCreepKills)) and ( tonumber(playerInfo.creepKills) > (1.2 * tonumber(mainUI.progression.stats.averageCreepKills)) ) then
						table.insert(matchStats.tPersonalBest,  'teamcreepkills'..'_pb')
					end					
					if (tonumber(mainUI.progression.stats.averageBossKills)) and ( (tonumber(playerInfo.cindaraKills) + tonumber(playerInfo.balidirKills)) > (1.2 * tonumber(mainUI.progression.stats.averageBossKills)) ) then
						table.insert(matchStats.tPersonalBest,  'bosskills'..'_pb')
					end		
					if (tonumber(mainUI.progression.stats.averageBuildingKills)) and (  tonumber(playerInfo.buildingKills) > (1.2 * tonumber(mainUI.progression.stats.averageBuildingKills)) ) then
						table.insert(matchStats.tPersonalBest,  'razed'..'_pb')
					end	
					if (tonumber(mainUI.progression.stats.averageHeroDamage)) and ( tonumber(playerInfo.heroDamage) > (1.2 * tonumber(mainUI.progression.stats.averageHeroDamage)) ) then
						table.insert(matchStats.tPersonalBest,  'herodmg'..'_pb')
					end
				else		
					println('self account progression stats are not available, no personal awards')		
				end
				
				if (PostGame.selfInfo) and ((PostGame.selfInfo.winner == 1) or (PostGame.selfInfo.winner == '1') or (PostGame.selfInfo.winner == PostGame.selfInfo.team)) then
					table.insert(matchStats.tPersonalBest,  'wongame_self')
				end
				
				if (PostGame.selfInfo) and (PostGame.selfInfo.numBadWordsSaid) and (tonumber(PostGame.selfInfo.numBadWordsSaid)) and (tonumber(PostGame.selfInfo.numBadWordsSaid) == 0) and (math.random(1,2) == 1) then
					table.insert(matchStats.tPersonalBest,  'noswearing_self')
				end				
			end
			
		else
			println('no stats for index ' .. playerIndex)		
		end
	end

	local postgame_summary_detailed_self_stats_show 	= GetWidget('postgame_summary_detailed_self_stats_show')	
	
	if PostGame.selfInfo then
		
		local postgame_summary_detailed_self_stats_listbox 	= GetWidget('postgame_summary_detailed_self_stats_listbox')
		
		local selfStatsTable = {}
		for i,v in pairs(PostGame.selfInfo) do
			local statString =  TranslateOrNil('scoreboard_detailed_stats_' .. tostring(i))
			if (statString) and (v) then
				table.insert(selfStatsTable, {stat = statString, value = v})
			end
		end
		
		table.sort(selfStatsTable, function(a,b)
			return (a.stat) < (b.stat)
		end)
		
		for i,v in pairs(selfStatsTable) do
			if (v.stat) and (v.value) and (postgame_summary_detailed_self_stats_listbox) then
				postgame_summary_detailed_self_stats_listbox:AddTemplateListItem('simpleDropdownItem2Labels', i, 'label1', tostring(v.stat) .. ':', 'label2', tostring(v.value))
			end
		end		

		if (selfStatsTable) and (#selfStatsTable > 0) then
			postgame_summary_detailed_self_stats_show:FadeIn(125)
		else
			postgame_summary_detailed_self_stats_show:FadeOut(125)
		end
		
		local awardsGiven		= {}
		local awardsPerPlayer	= {}
		local awardPlayerSlot

		if (PostGame.selfInfo.matchmakingHeroStats) and (PostGame.selfInfo.matchmakingHeroStats.entityName) then
			PostGame.Splash.heroEntityName = PostGame.selfInfo.matchmakingHeroStats.entityName
		else
			PostGame.Splash.heroEntityName = nil
		end
		
		for playerIndex,playerAwardInfo in pairs(matchStats.tAwardsPlayer) do
			awardPlayerSlot = playerIndex

			if not awardsPerPlayer[awardPlayerSlot] then
				awardsPerPlayer[awardPlayerSlot] = {}
			end
			for awardIndex, awardName in ipairs(playerAwardInfo) do
				if not awardsGiven[awardName] and #awardsPerPlayer[awardPlayerSlot] < 2 then
					table.insert(awardsPerPlayer[awardPlayerSlot], awardName)
					awardsGiven[awardName] = awardPlayerSlot
				end
			end
		end
		
		for playerIndex,playerAwardInfo in pairs(matchStats.tAwardsPlayerTeam) do
			awardPlayerSlot = playerIndex

			if not awardsPerPlayer[awardPlayerSlot] then
				awardsPerPlayer[awardPlayerSlot] = {}
			end
			for awardIndex, awardName in ipairs(playerAwardInfo) do
				if not awardsGiven[awardName] and #awardsPerPlayer[awardPlayerSlot] < 2 then
					table.insert(awardsPerPlayer[awardPlayerSlot], awardName)
					awardsGiven[awardName] = awardPlayerSlot
				end
			end
		end	
		
		for playerIndex,playerAwardInfo in pairs(matchStats.tAwardsPlayerAv) do
			awardPlayerSlot = playerIndex

			if not awardsPerPlayer[awardPlayerSlot] then
				awardsPerPlayer[awardPlayerSlot] = {}
			end
			for awardIndex, awardName in ipairs(playerAwardInfo) do
				if not awardsGiven[awardName] and #awardsPerPlayer[awardPlayerSlot] < 2 then
					table.insert(awardsPerPlayer[awardPlayerSlot], awardName)
					awardsGiven[awardName] = awardPlayerSlot
				end
			end
		end	
		
		for awardIndex,awardName in pairs(matchStats.tPersonalBest) do
			awardPlayerSlot = GetIdentID()

			if not awardsPerPlayer[awardPlayerSlot] then
				awardsPerPlayer[awardPlayerSlot] = {}
			end
			if not awardsGiven[awardName] and #awardsPerPlayer[awardPlayerSlot] < 2 then
				table.insert(awardsPerPlayer[awardPlayerSlot], awardName)
				awardsGiven[awardName] = awardPlayerSlot
			end
		end			
		
		for playerIndex,playerAwardInfo in pairs(matchStats.tAwardsPlayerTeamAv) do
			awardPlayerSlot = playerIndex

			if not awardsPerPlayer[awardPlayerSlot] then
				awardsPerPlayer[awardPlayerSlot] = {}
			end
			for awardIndex, awardName in ipairs(playerAwardInfo) do
				if not awardsGiven[awardName] and #awardsPerPlayer[awardPlayerSlot] < 2 then
					table.insert(awardsPerPlayer[awardPlayerSlot], awardName)
					awardsGiven[awardName] = awardPlayerSlot
				end
			end
		end		
		
		awardsPerPlayer[GetIdentID()] = awardsPerPlayer[GetIdentID()] or {} -- create local player entry if missing
		
		local awardsSpecialAvail	= {}

		for i=1,7,1 do
			table.insert(awardsSpecialAvail, i)
		end

		if #awardsPerPlayer[GetIdentID()] == 1 then
			table.insert(awardsPerPlayer[GetIdentID()], ('special_'..math.random(1, #awardsSpecialAvail)))
		elseif #awardsPerPlayer[GetIdentID()] == 0 then
			local numberTable = RandomUniqueNumbers(1, #awardsSpecialAvail, 2)
			table.insert(awardsPerPlayer[GetIdentID()], ('special_'..numberTable[1]))
			table.insert(awardsPerPlayer[GetIdentID()], ('special_'..numberTable[2]))
		end

		local function weightedTotal(choices)
			local total = 0
			for choice, weight in pairs(choices) do
				total = total + weight
			end
			return total
		end		
		
		local function weightedRandomChoice(choices)
			local threshold = math.random(0, weightedTotal(choices))
			local last_choice
			for choice, weight in pairs(choices) do
				threshold = threshold - weight
				if threshold <= 0 then 
					return choice
				end
				last_choice = choice
			end
			return last_choice
		end

		local function generateWeightedTable(playerAwards)
			local choices = {}
			for position,award in ipairs(playerAwards) do
				choices[award] = ((#playerAwards + 1) - tonumber(position))
			end
			return choices
		end
		
		local weightedRandomAwardsPerPlayer = {}
		for playerIndex,playerAwards in pairs(awardsPerPlayer) do
			weightedRandomAwardsPerPlayer[playerIndex] = {}
			local choice1 = weightedRandomChoice(generateWeightedTable(playerAwards))
			local choice2
			local count = 0
			while ((choice2 == nil) or (choice2 == choice1)) and (#playerAwards >= 2) do
				choice2 = weightedRandomChoice(generateWeightedTable(playerAwards))
				count = count + 1
				if (count > 1000) then
					break
				end
			end
			tinsert(weightedRandomAwardsPerPlayer[playerIndex], choice1)
			tinsert(weightedRandomAwardsPerPlayer[playerIndex], choice2)
		end
		
		for i=1,2,1 do
			if (weightedRandomAwardsPerPlayer[GetIdentID()]) and (weightedRandomAwardsPerPlayer[GetIdentID()][i]) then
				PostGame.Splash.modules.matchAwards = PostGame.Splash.modules.matchAwards or {}
				tinsert(PostGame.Splash.modules.matchAwards, {
						Translate('match_awards_'..weightedRandomAwardsPerPlayer[GetIdentID()][i]),
						'/ui/main/postgame/textures/awards/match_awards_'..weightedRandomAwardsPerPlayer[GetIdentID()][i]..'.tga',
						Translate('match_awards_'..weightedRandomAwardsPerPlayer[GetIdentID()][i]),
						Translate('match_awards_'..weightedRandomAwardsPerPlayer[GetIdentID()][i]..'_desc'),
					}
				)
			end
		end
		trigger_postGameLoopStatus.awardsAvailable = true
		trigger_postGameLoopStatus:Trigger(false)
	else
		println('No self info in match stats - skipping awards')
		postgame_summary_detailed_self_stats_show:FadeOut(125)
	end	
	
	PostGame.Splash.modules.matchOutcome = PostGame.Splash.modules.matchOutcome or {}
	if (PostGame.selfInfo) and ((PostGame.selfInfo.winner == 1) or (PostGame.selfInfo.winner == '1') or (PostGame.selfInfo.winner == PostGame.selfInfo.team)) then
		tinsert(PostGame.Splash.modules.matchOutcome, {Translate('endmatch_victory')})
	elseif (PostGame.selfInfo) and ((PostGame.selfInfo.winner == 0) or (PostGame.selfInfo.winner == '0') or (PostGame.selfInfo.winner ~= PostGame.selfInfo.team)) then
		tinsert(PostGame.Splash.modules.matchOutcome, {Translate('endmatch_defeat')})
	else
		tinsert(PostGame.Splash.modules.matchOutcome, {Translate('endmatch_results')})
	end	
	
end