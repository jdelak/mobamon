mainUI = mainUI or {}
local interface = object

libGeneral.createGroupTrigger('PlayerCardProfileAnimationStatus', { 'playerProfileAnimStatus.section', 'mainPanelAnimationStatus.main', 'mainPanelAnimationStatus.newMain' })

local playerCardIntroThread
GetWidget('main_header_player_card'):RegisterWatchLua('mainPanelStatus', function(widget, trigger)
	if (trigger.isLoggedIn) and (trigger.hasIdent) and (trigger.main ~= 10) and (not trigger.hideSecondaryElements) then
		playerCardIntroThread = libThread.threadFunc(function()	
			wait(styles_mainSwapAnimationDuration * 3)
			widget:FadeIn(250)
			playerCardIntroThread = nil
		end)
	else
		if (playerCardIntroThread) then
			playerCardIntroThread:kill()
			playerCardIntroThread = nil
		end				
		widget:FadeOut(250)
	end
end, false, nil, 'isLoggedIn', 'hasIdent', 'main', 'hideSecondaryElements')

local playerCardNoClickThread = nil
GetWidget('main_header_player_card'):RegisterWatchLua('mainPanelAnimationStatus', function(widget, trigger)
	if (playerCardNoClickThread) then
		playerCardNoClickThread:kill()
		playerCardNoClickThread = nil
	end			
	if (trigger.newMain ~= -1) then
		widget:SetPassiveChildren(1)
		widget:SetNoClick(1)
	else
		playerCardNoClickThread = libThread.threadFunc(function()
			wait(styles_mainSwapAnimationDuration)
			widget:SetPassiveChildren(0)
			widget:SetNoClick(1)
			playerCardNoClickThread = nil
		end)
	end
end, false, nil, 'newMain')

GetWidget('main_header_player_card_level_ring_pie'):RegisterWatchLua('AccountProgression', function(widget, trigger)
	widget:SetValue(trigger.percentToNextLevel)
end, false, nil, 'percentToNextLevel')

GetWidget('playerCard_extra_label_1'):RegisterWatchLua('AccountProgression', function(widget, trigger)
	if (mainUI) and (mainUI.progression) and (mainUI.progression.stats) and (mainUI.progression.stats.account) and (mainUI.progression.stats.account.wins) then
		if (mainUI.progression.stats.account.wins > 1) then
			widget:SetText(Translate('stat_name_total_wins_x', 'value', mainUI.progression.stats.account.wins))
		elseif (mainUI.progression.stats.account.wins == 1) then
			widget:SetText(Translate('stat_name_total_win_x', 'value', mainUI.progression.stats.account.wins))
		else
			widget:SetText(Translate('friends_default_group'))
		end
	end
end, false, nil, 'update')

GetWidget('playerCard_extra_label_2'):RegisterWatchLua('AccountProgression', function(widget, trigger)
	if (mainUI) and (mainUI.progression) and (mainUI.progression.stats) and (mainUI.progression.stats.account) and (mainUI.progression.stats.account.pvpRating0) then
		widget:SetText(Translate('stat_name_pvp_rating_x_short', 'value', mainUI.progression.stats.account.pvpRating0))
	end
end, false, nil, 'update')

GetWidget('playerCard_extra_label_5'):RegisterWatchLua('AccountProgression', function(widget, trigger)
	if (mainUI) and (mainUI.progression) and (mainUI.progression.stats) and (mainUI.progression.stats.account) and (mainUI.progression.stats.account.ladderPoints) then
		local ladderPoints = mainUI.progression.stats.account.ladderPoints or 0
		local ladderRank = mainUI.progression.stats.account.ladderRank or 0
		if (ladderPoints) and (ladderRank) then
			if (tonumber(ladderRank)) and (tonumber(ladderRank) >= 1) and (tonumber(ladderRank) <= 100) then
				widget:SetText(Translate('stat_name_ladder_rank_x', 'value', ladderRank, 'value2', ladderPoints))
			else
				widget:SetText(Translate('stat_name_ladder_points_x', 'value', ladderPoints, 'value2', ladderRank))
			end
		end
	end
end, false, nil, 'update')

GetWidget('playerCard_extra_label_5'):SetCallback('onshow', function(widget)
	if (mainUI) and (mainUI.progression) and (mainUI.progression.stats) and (mainUI.progression.stats.account) and (mainUI.progression.stats.account.ladderPoints) then
		local ladderPoints = mainUI.progression.stats.account.ladderPoints or 0
		local ladderRank = mainUI.progression.stats.account.ladderRank or 0
		if (ladderPoints) and (ladderRank) then
			if (tonumber(ladderRank)) and (tonumber(ladderRank) >= 1) and (tonumber(ladderRank) <= 100) then
				widget:SetText(Translate('stat_name_ladder_rank_x', 'value', ladderRank, 'value2', ladderPoints))
			else
				widget:SetText(Translate('stat_name_ladder_points_x', 'value', ladderPoints, 'value2', ladderRank))
			end
		end
	end
end)

GetWidget('playerCard_extra_label_3'):RegisterWatchLua('AccountInfo', function(widget, trigger)
	widget:SetText(Translate('game_level', 'level', trigger.accountLevel))
end, false, nil, 'accountLevel')

GetWidget('playerCard_extra_label_3'):RegisterWatchLua('AccountProgression', function(widget, trigger)
	widget:SetText(Translate('game_level', 'level', trigger.level))
	if LuaTrigger.GetTrigger('AccountInfo').accountLevel ~= trigger.level then
		widget:SetColor('red')
	else
		widget:SetColor('white')
	end
end, false, nil, 'level')

GetWidget('playerCard_extra_label_4'):RegisterWatchLua('AccountProgression', function(widget, trigger)
	if (mainUI) and (mainUI.progression) and (mainUI.progression.stats) and (mainUI.progression.stats.account) and (mainUI.progression.stats.account.division) then 
		widget:SetText(Translate('ranked_division_' .. mainUI.progression.stats.account.division))
	end
end, false)

GetWidget('playerCard_extra_label_4_image_2'):RegisterWatchLua('AccountProgression', function(widget, trigger)
	if (mainUI) and (mainUI.progression) and (mainUI.progression.stats) and (mainUI.progression.stats.account) and (mainUI.progression.stats.account.division) then 
		if (mainUI.progression.stats.account.division == 'provisional') then
			widget:SetTexture(libCompete.divisions[libCompete.divisionNumberByName['provisional']].icon)
		else
			widget:SetTexture(libCompete.divisions[libCompete.divisionNumberByName[mainUI.progression.stats.account.division]].icon)
		end
	end
end, false)

local toggle = 1
GetWidget('playerCard_extra_label_4_parent'):RegisterWatchLua('AccountProgression', function(widget, trigger)
	widget:UnregisterWatchLua('AccountProgression')
	local widgets = {
		GetWidget('playerCard_extra_label_1'),
		GetWidget('playerCard_extra_label_3'),
		GetWidget('playerCard_extra_label_4_parent'),
		GetWidget('playerCard_extra_label_2'),
		GetWidget('playerCard_extra_label_5')
	}

	local loaded = false

	libThread.threadFunc(function()
		while (true) do

			if (loaded) then

				if (toggle == 4) and (mainUI.progression.stats.account.pvpRating0) and (mainUI.progression.stats.account.pvpRating0 < 1530) then
					toggle = 5
				end
				if (toggle == 1) and not (mainUI.progression.stats.account.wins) then
					toggle = toggle + 1
				end
				if (toggle == 3) and not (mainUI.progression.stats.account.pvpRating0) then
					toggle = toggle + 1
				end
				if (toggle == 4) and (not mainUI.progression.stats.account.pvpRating0 or (mainUI.progression.stats.account.pvpRating0 and mainUI.progression.stats.account.pvpRating0 < 1530)) then
					toggle = toggle + 1
				end
				if (toggle == 5) and ((not (mainUI.progression.stats.account.ladderPoints)) or (mainUI.featureMaintenance and mainUI.featureMaintenance['ladder'])) then
					toggle = 2
				end

				for n = 1, 5 do
					if (toggle == n) then
						fadeWidget(widgets[n], true, 500)
					else
						fadeWidget(widgets[n], false, 250)
					end
				end

				toggle = toggle + 1
				if (toggle > 5) then
					toggle = 1
				end
				wait(5500)
			else
				loaded = (mainUI) and (mainUI.progression) and (mainUI.progression.stats) and (mainUI.progression.stats.account)
				wait(500)
			end
		end
	end)
end, false, nil, 'update')

-- GetWidget('main_header_player_card_mastery_parent'):RegisterWatchLua('AccountProgression', function(widget, trigger)
	-- if (mainUI) and (mainUI.progression) and (mainUI.progression.stats) and (mainUI.progression.stats.account) and (mainUI.progression.stats.account.rank) and (mainUI.progression.stats.account.winsToNextRank) and (mainUI.progression.stats.account.rank >= 1) then
		-- widget:FadeIn(500)
		-- GetWidget('main_header_player_card_mastery_icon'):SetTexture('/ui/shared/textures/account_icons/star_' .. (math.floor(mainUI.progression.stats.account.rank)) .. '.tga')
	-- else
		-- widget:SetVisible(0)
	-- end
-- end, false, nil, 'update')

-- GetWidget('main_header_player_card'):RegisterWatchLua('CraftingCommodityInfo', function(widget, trigger)
	-- widget:GetWidget('player_card_commodity_breakdown_ore_label'):SetText(trigger.oreCount)
	-- widget:GetWidget('player_card_commodity_breakdown_essence_label'):SetText(trigger.essenceCount)
-- end, false, nil, 'oreCount', 'essenceCount')


-- GetWidget('main_header_player_card'):RegisterWatchLua('Corral', function(widget, trigger)
	-- widget:GetWidget('player_card_commodity_breakdown_fruit_label'):SetText(trigger.fruit)
-- end, false, nil, 'shards', 'fruit')

-- GetWidget('main_header_player_card'):RegisterWatchLua('GemOffer', function(widget, trigger)
	-- widget:GetWidget('player_card_commodity_breakdown_gems_label'):SetText(trigger.gems)
-- end, false, nil, 'gems')

-- ==============================================================================================================

-- Seals
local player_card_seal_label 			= GetWidget('player_card_seal_label')
local function updatePetsSubText(seals)
	seals = seals or LuaTrigger.GetTrigger('Corral').fruit
	player_card_seal_label:SetText(seals)
	player_card_seal_label:SetWidth(GetStringWidth(player_card_seal_label:GetFont(),tostring(libNumber.commaFormat(seals))))
end
updatePetsSubText()
player_card_seal_label:RegisterWatchLua('Corral', function(widget, trigger)
	updatePetsSubText(trigger.fruit)
end, false, nil, 'fruit')

-- Essence
local player_card_essence_label = object:GetWidget('player_card_essence_label')
local function updateCraftingSubText(ore)
	ore = ore or math.floor(LuaTrigger.GetTrigger('CraftingCommodityInfo').oreCount)
	player_card_essence_label:SetText(ore)
	player_card_essence_label:SetWidth(GetStringWidth(player_card_essence_label:GetFont(),tostring(libNumber.commaFormat(ore))))
end
updateCraftingSubText()
player_card_essence_label:RegisterWatchLua('CraftingCommodityInfo', function(widget, trigger)
	updateCraftingSubText(math.floor(trigger.oreCount))
end, false, nil, 'oreCount')





local player_card_gems_effect 			= GetWidget('player_card_gems_effect')
local player_card_gems_effect_behind 	= GetWidget('player_card_gems_effect_behind')
local player_card_gems_label 			= GetWidget('player_card_gems_label')

function AnimatedGemIncrease(currentGems, lastGems)
	local gemAnimatedIncreaseThread
	if (gemAnimatedIncreaseThread) then
		gemAnimatedIncreaseThread:kill()
		player_card_gems_effect_behind:SetEffect('/ui/main/player_card/effects/red_energy_behind_subtle.effect')
		gemAnimatedIncreaseThread = nil
	end	
	player_card_gems_effect_behind:SetEffect('/ui/main/player_card/effects/red_energy_behind.effect')
	player_card_gems_effect_behind:FadeIn(250)
	player_card_gems_effect:FadeIn(250)
	
	local valueAdd = currentGems - lastGems
	local lastValue = lastGems
	local valueStart = lastGems
	
	local animType = math.max(1500, math.min(10000, (currentGems * 5)))

	libAnims.customTween(
		player_card_gems_label, animType,
		function(posPercent)

			local newValue = math.floor(valueStart + (valueAdd * posPercent))
			if newValue > lastValue then
				-- Purchase gem sound 
				-- PlaySound('/ui/sounds/rewards/sfx_tally_oneshot.wav')
				lastValue = newValue
			end
			player_card_gems_label:SetText(newValue)
			player_card_gems_label:SetWidth(GetStringWidth(player_card_gems_label:GetFont(),tostring(libNumber.commaFormat(currentGems))))
		end
	)	
	
	gemAnimatedIncreaseThread = libThread.threadFunc(function()	
		wait(animType)	
		if (player_card_gems_effect_behind) and (player_card_gems_effect_behind:IsValid()) then
			player_card_gems_effect_behind:SetEffect('/ui/main/player_card/effects/red_energy_behind_subtle.effect')
			if (currentGems > 100) then
				player_card_gems_effect_behind:FadeIn(250)		
			else
				player_card_gems_effect_behind:FadeOut(250)	
			end
		end
	end)
	
end

function AnimatedGemDecrease(currentGems, lastGems)
	println('AnimatedGemDecrease')

	local gemAnimatedDecreaseThread
	if (gemAnimatedDecreaseThread) then
		gemAnimatedIncreaseThread:kill()
		player_card_gems_effect_behind:SetEffect('/ui/main/player_card/effects/red_energy_behind_subtle.effect')
		gemAnimatedDecreaseThread = nil
	end	
	player_card_gems_effect_behind:SetEffect('/ui/main/player_card/effects/red_energy_behind.effect')
	player_card_gems_effect_behind:FadeIn(250)
	player_card_gems_effect:FadeIn(250)
	
	local valueSubtract = lastGems - currentGems
	local lastValue = lastGems
	local valueStart = lastGems

	libAnims.customTween(
		player_card_gems_label, 1500,
		function(posPercent)

			local newValue = math.floor(valueStart - (valueSubtract * posPercent))
			if newValue < lastValue then
				-- PlaySound('/ui/sounds/rewards/sfx_tally_oneshot.wav')
				lastValue = newValue
			end
			player_card_gems_label:SetText(newValue)
			player_card_gems_label:SetWidth(GetStringWidth(player_card_gems_label:GetFont(),tostring(libNumber.commaFormat(lastGems))))
		end
	)	
	
	gemAnimatedDecreaseThread = libThread.threadFunc(function()	
		wait(1500)	
		if (player_card_gems_effect_behind) and (player_card_gems_effect_behind:IsValid()) then
			player_card_gems_effect_behind:SetEffect('/ui/main/player_card/effects/red_energy_behind_subtle.effect')
		end
	end)
	
end

GetWidget('main_header_player_card_icon_anim'):RegisterWatchLua('AccountInfo', function(widget, trigger)
	if (trigger.accountIconPath) and (not Empty(trigger.accountIconPath)) then
		widget:SetTexture(trigger.accountIconPath)
	end
end, false, nil, 'accountIconPath')

GetWidget('main_header_player_card_icon'):RegisterWatchLua('AccountInfo', function(widget, trigger)
	widget:FadeIn(250)
	if (trigger.accountIconPath) and (not Empty(trigger.accountIconPath)) then
		widget:SetTexture(trigger.accountIconPath)
	end
end, false, nil, 'accountIconPath')

local lastGemCount = nil
interface:GetWidget('player_card_gems'):RegisterWatchLua('GemOffer', function(widget, trigger)
	widget:FadeIn(250)
	player_card_gems_label:SetText(trigger.gems)
	player_card_gems_label:SetWidth(GetStringWidth(player_card_gems_label:GetFont(),tostring(libNumber.commaFormat(trigger.gems))))
	if (trigger.gems) and (trigger.gems > 100) then
		interface:GetWidget('player_card_gems_icon'):SetTexture('/ui/main/shared/textures/gem.tga')
		player_card_gems_effect_behind:SetEffect('/ui/main/player_card/effects/red_energy_behind_subtle.effect')
		player_card_gems_effect_behind:FadeIn(250)
		player_card_gems_effect:FadeIn(250)
	elseif (trigger.gems) and (trigger.gems > 0) then
		interface:GetWidget('player_card_gems_icon'):SetTexture('/ui/main/shared/textures/gem.tga')
		player_card_gems_effect_behind:SetEffect('/ui/main/player_card/effects/red_energy_behind_subtle.effect')
		player_card_gems_effect_behind:FadeOut(250)
		player_card_gems_effect:FadeIn(250)
	else
		interface:GetWidget('player_card_gems_icon'):SetTexture('/ui/main/shared/textures/gem.tga')
		player_card_gems_effect_behind:SetEffect('/ui/main/player_card/effects/red_energy_behind_subtle.effect')
		player_card_gems_effect_behind:FadeOut(250)
		player_card_gems_effect:FadeIn(250)
	end
	if (trigger.gems) and (lastGemCount) and (trigger.gems > lastGemCount) then
		AnimatedGemIncrease(trigger.gems, lastGemCount)
	elseif (trigger.gems) and (lastGemCount) and (trigger.gems < lastGemCount) then
		AnimatedGemDecrease(trigger.gems, lastGemCount)		
	end
	lastGemCount = trigger.gems
end, false, nil, 'gems')

interface:GetWidget('player_card_gems'):SetCallback('onmouseover', function(widget)
	player_card_gems_effect_behind:SetEffect('/ui/main/player_card/effects/red_energy_behind.effect')
end)

interface:GetWidget('player_card_gems'):SetCallback('onmouseout', function(widget)
	player_card_gems_effect_behind:SetEffect('/ui/main/player_card/effects/red_energy_behind_subtle.effect')
end)

interface:GetWidget('player_card_gems'):SetCallback('onclick', function(widget)
	widget:SetEnabled(0)
	buyGemsShow()	
	libThread.threadFunc(function()	
		wait(2500)	
		widget:SetEnabled(1)
	end)
end)	

interface:GetWidget('player_card_gems'):SetCallback('onrightclick', function(widget)
	if LuaTrigger.GetTrigger('KeyDown').ctrl then
		GenericColorPicker(widget, Translate('options_choose_new_color'), Translate('general_ok'), Translate('general_cancel'), function(red, green, blue) BG.SetBGColor2(red, green, blue) end)
	else
		widget:SetEnabled(0)
		buyGemsShow()	
		libThread.threadFunc(function()	
			wait(2500)	
			widget:SetEnabled(1)
		end)	
	end
end)	

-- player_card_purchase_bonus player_card_bonus_xp player_card_bonus_commodity player_card_bonus_pets player_card_bonus_summary_label player_card_bonuses
local function BoostsRegister(object)
	
	local accountBoostInfoTrigger = LuaTrigger.GetTrigger('AccountBoostInfoTrigger')
	
	local player_card_purchase_bonus 					= GetWidget('player_card_purchase_bonus')
	local player_card_purchase_bonus_boost 				= GetWidget('player_card_purchase_bonus_boost')
	local player_card_purchase_bonus_boost_icon 		= GetWidget('player_card_purchase_bonus_boost_icon')
	local player_card_purchase_bonus_boost_fx 			= GetWidget('player_card_purchase_bonus_boost_fx')
	local maxMovement = 6	
	local startTime = 0
	
	function mainUI.OpenBuyBoostURL()
		local URL = Strife_Region.regionTable[Strife_Region.activeRegion].purchaseBoostURL

		URL = string.gsub(URL, "{accountId}", Client.GetAccountID())
		URL = string.gsub(URL, "{identId}", GetIdentID())
		URL = string.gsub(URL, "{sessionKey}", Client.GetSessionKey())
		
		println('OpenBuyBoostURL ' .. tostring(URL) )
		
		mainUI.OpenURL(URL)
	end	
	
	local profileBoostPositionY = '205s'
	local profileBoostPositionX = '173s'
	local profileBoostSize = '48s'	
	
	local onProfile = false
	local boostToProfileThread
	local function BoostToProfile()
		player_card_purchase_bonus_boost_fx:SetVisible(1)
		player_card_purchase_bonus_boost_icon:SetTexture('/ui/main/shared/textures/acct_boost_on.tga')	
		boostToProfileThread = libThread.threadFunc(function()	
			player_card_purchase_bonus:SetNoClick(1)
			player_card_purchase_bonus_boost:SetNoClick(1)
			player_card_purchase_bonus_boost_icon:RotateAdd(65, 125)
			-- player_card_purchase_bonus_boost_fx:ModelRotateAdd(65, 0, 0, 500)
			player_card_purchase_bonus_boost_fx:SetVisible(0)
			wait(125)
			player_card_purchase_bonus_boost:SlideY(profileBoostPositionY, 500)
			player_card_purchase_bonus_boost:SlideX(profileBoostPositionX, 500)
			player_card_purchase_bonus_boost:Scale(profileBoostSize, profileBoostSize, 500, true)
			wait(400)
			player_card_purchase_bonus_boost_icon:RotateAdd(-65, 125)
			player_card_purchase_bonus_boost:SetY(profileBoostPositionY)
			player_card_purchase_bonus_boost:SetX(profileBoostPositionX)	
			wait(125)
			player_card_purchase_bonus_boost_fx:SetVisible(1)
			player_card_purchase_bonus_boost:SetNoClick(0)
			
			startTime = LuaTrigger.GetTrigger('System').hostTime
			player_card_purchase_bonus_boost:RegisterWatchLua('System', function(widget, trigger)
				local scaler = ((((trigger.hostTime - startTime) % 1000)/1000) * 2 * math.pi) +125
				player_card_purchase_bonus_boost:SetY(interface:GetYFromString(profileBoostPositionY)+ (-3 + ((-1 * maxMovement / 2) - (maxMovement * math.sin(scaler)))) .. 's')
				player_card_purchase_bonus_boost:SetX(interface:GetXFromString(profileBoostPositionX)+ ((maxMovement * math.cos(1- scaler))) .. 's')
			end, false, nil, 'hostTime')			
			
			player_card_purchase_bonus_boost:SetRotation(0)
			
			boostToProfileThread = nil
		end)
	end
	
	local playerCardBoostPositionY = '29s'
	local playerCardBoostPositionX = '182s'
	local playerCardBoostSize = '24s'
	function mainUI.BoostToPlayerCard()
		player_card_purchase_bonus_boost_fx:SetVisible(1)
		player_card_purchase_bonus_boost_icon:SetTexture('/ui/main/shared/textures/acct_boost_on.tga')	
		boostToProfileThread = libThread.threadFunc(function()	
			player_card_purchase_bonus_boost:UnregisterWatchLua('System')
			player_card_purchase_bonus_boost:SetNoClick(1)
			player_card_purchase_bonus_boost_icon:RotateAdd(-65, 125)
			-- player_card_purchase_bonus_boost_fx:ModelRotateAdd(65, 0, 0, 500)
			player_card_purchase_bonus_boost_fx:SetVisible(0)
			wait(125)
			player_card_purchase_bonus_boost:SlideY(playerCardBoostPositionY, 500)
			player_card_purchase_bonus_boost:SlideX(playerCardBoostPositionX, 500)
			player_card_purchase_bonus_boost:Scale(playerCardBoostSize, playerCardBoostSize, 500, true)
			wait(400)
			player_card_purchase_bonus_boost_icon:RotateAdd(65, 125)
			player_card_purchase_bonus_boost:SetY(playerCardBoostPositionY)
			player_card_purchase_bonus_boost:SetX(playerCardBoostPositionX)	
			wait(125)
			if (not accountBoostInfoTrigger.hasPermanentXPBoost) and (not accountBoostInfoTrigger.hasTemporaryXPBoost) then
				player_card_purchase_bonus_boost_fx:SetVisible(0)
				player_card_purchase_bonus_boost_icon:SetTexture('/ui/main/shared/textures/acct_boost_off.tga')			
			end
			player_card_purchase_bonus_boost:SetNoClick(0)
			player_card_purchase_bonus_boost:SetRotation(0)
			boostToProfileThread = nil
		end)
	end	
	
	player_card_purchase_bonus_boost:SetRotation(0)
	player_card_purchase_bonus_boost:SetHeight(playerCardBoostSize)
	player_card_purchase_bonus_boost:SetWidth(playerCardBoostSize)
	player_card_purchase_bonus_boost:SetY(playerCardBoostPositionY)
	player_card_purchase_bonus_boost:SetX(playerCardBoostPositionX)	
	player_card_purchase_bonus_boost:SetNoClick(0)
	
	local function UpdateRocketBase()
		local mainPlayerCardUsername = GetWidget('mainPlayerCardUsername')
		player_card_purchase_bonus:SetY('-25s')
		player_card_purchase_bonus:SetX(mainPlayerCardUsername:GetWidth() - interface:GetWidthFromString('100s'))
	end
	player_card_purchase_bonus:RegisterWatchLua('AccountInfo', function(widget, trigger) UpdateRocketBase() end, false, nil)
	
	GetWidget('player_card_purchase_bonus'):RegisterWatchLua('AccountBoostInfoTrigger', function(widget, trigger)
		widget:FadeIn(125)
		if (accountBoostInfoTrigger.hasPermanentXPBoost) or (accountBoostInfoTrigger.hasTemporaryXPBoost) then
			player_card_purchase_bonus_boost_fx:SetVisible(1)
			player_card_purchase_bonus_boost_icon:SetTexture('/ui/main/shared/textures/acct_boost_on.tga')		
		else
			player_card_purchase_bonus_boost_fx:SetVisible(0)
			player_card_purchase_bonus_boost_icon:SetTexture('/ui/main/shared/textures/acct_boost_off.tga')
		end
	end)

	GetWidget('player_card_purchase_bonus'):RegisterWatchLua('PlayerCardProfileAnimationStatus', function(widget, groupTrigger)	
		local playerProfileAnimStatus = groupTrigger['playerProfileAnimStatus']
		local mainPanelAnimationStatus = groupTrigger['mainPanelAnimationStatus']
		if (((mainPanelAnimationStatus.main == 23) and (mainPanelAnimationStatus.newMain == -1)) or (mainPanelAnimationStatus.newMain == 23)) and (playerProfileAnimStatus.section == 'achievements') then
			if (not onProfile) then
				BoostToProfile()
			end
			onProfile = true
		else
			if (onProfile) then
				mainUI.BoostToPlayerCard()
			end		
			onProfile= false
		end
		UpdateRocketBase()
	end, false, nil)	
	accountBoostInfoTrigger:Trigger(true)
			
	player_card_purchase_bonus:SetCallback('onclick', function(widget)
		libBoost.ShowAccountBoostPurchaseSplash()
	end)

	player_card_purchase_bonus:SetCallback('onmouseover', function(widget)
		player_card_purchase_bonus_boost_fx:SetVisible(1)
		player_card_purchase_bonus_boost_icon:SetTexture('/ui/main/shared/textures/acct_boost_on.tga')
		UpdateCursor(widget, true, { canLeftClick = true, canRightClick = false })
	end)
	
	player_card_purchase_bonus:SetCallback('onmouseout', function(widget)
		if (not accountBoostInfoTrigger.hasPermanentXPBoost) and (not accountBoostInfoTrigger.hasTemporaryXPBoost) then
			player_card_purchase_bonus_boost_fx:SetVisible(0)
			player_card_purchase_bonus_boost_icon:SetTexture('/ui/main/shared/textures/acct_boost_off.tga')
		end
		UpdateCursor(widget, false, { canLeftClick = true, canRightClick = false })
	end)	
	
	player_card_purchase_bonus_boost:SetCallback('onclick', function(widget)
		libBoost.ShowAccountBoostPurchaseSplash()
	end)

	player_card_purchase_bonus_boost:SetCallback('onmouseover', function(widget)
		UpdateCursor(widget, true, { canLeftClick = true, canRightClick = false })
		simpleTipGrowYUpdate(true, nil, Translate('player_card_boost_perma_title'), Translate('player_card_boost_perma_desc'), 250, -250)
	end)
	
	player_card_purchase_bonus_boost:SetCallback('onmouseout', function(widget)
		UpdateCursor(widget, false, { canLeftClick = true, canRightClick = false })
		simpleTipGrowYUpdate(false, nil, Translate('player_card_boost_perma_title'), Translate('player_card_boost_perma_desc'), 250, -250)
	end)	
	
	local player_card_bonus_xp 						= GetWidget('player_card_bonus_xp')	
	local player_card_bonus_commodity 				= GetWidget('player_card_bonus_commodity')	
	local player_card_bonus_pets 					= GetWidget('player_card_bonus_pets')	
	
	player_card_bonus_xp:RegisterWatchLua('AccountBoostInfoTrigger', function(widget, trigger)
		widget:SetVisible(trigger.hasTemporaryXPBoost or trigger.hasPermanentXPBoost)
	end, false, nil, 'hasTemporaryXPBoost', 'hasPermanentXPBoost')

	player_card_bonus_xp:SetCallback('onmouseover', function(widget)
		UpdateCursor(widget, true, { canLeftClick = true, canRightClick = false })
		simpleTipGrowYUpdate(true, nil, Translate('player_card_boost_temp_xp_title'), Translate('player_card_boost_purchased_xp_desc'), 250, -250)
	end)
	
	player_card_bonus_xp:SetCallback('onmouseout', function(widget)
		UpdateCursor(widget, false, { canLeftClick = true, canRightClick = false })
		simpleTipGrowYUpdate(false)
	end)	
	
	player_card_bonus_commodity:RegisterWatchLua('AccountBoostInfoTrigger', function(widget, trigger)
		widget:SetVisible(trigger.hasTemporaryCommodityBoost or trigger.hasPermanentCommodityBoost)
	end, false, nil, 'hasTemporaryCommodityBoost', 'hasPermanentCommodityBoost')
	
	player_card_bonus_commodity:SetCallback('onmouseover', function(widget)
		UpdateCursor(widget, true, { canLeftClick = true, canRightClick = false })
		simpleTipGrowYUpdate(true, nil, Translate('player_card_boost_temp_commodity_title'), Translate('player_card_boost_temp_commodity_desc'), 250, -250)
	end)
	
	player_card_bonus_commodity:SetCallback('onmouseout', function(widget)
		UpdateCursor(widget, false, { canLeftClick = true, canRightClick = false })
		simpleTipGrowYUpdate(false)
	end)	
	
	player_card_bonus_pets:RegisterWatchLua('AccountBoostInfoTrigger', function(widget, trigger)
		widget:SetVisible(trigger.hasTemporaryPetBoost)
	end, false, nil, 'hasTemporaryPetBoost')
	
	player_card_bonus_pets:SetCallback('onmouseover', function(widget)
		UpdateCursor(widget, true, { canLeftClick = true, canRightClick = false })
		simpleTipGrowYUpdate(true, nil, Translate('player_card_boost_temp_pets_title'), Translate('player_card_boost_temp_pets_desc'), 250, -250)
	end)
	
	player_card_bonus_pets:SetCallback('onmouseout', function(widget)
		UpdateCursor(widget, false, { canLeftClick = true, canRightClick = false })
		simpleTipGrowYUpdate(false)
	end)	
	
end

BoostsRegister(object)
