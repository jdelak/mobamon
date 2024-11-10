local deathRecapContainer
local killerData	= { }
local damageEvent	= { }
local ccEvent		= { }
local pies = {
	DamageTypePie	= {
		Labels		= { }, 
		Pies		= { },
		Percents	= { }
	},
	DamageHeroPie = {
		Labels			= { }, 
		Pies			= { },
		Percents		= { },
		Icons			= { },
		IconsContainers = { }
	},
}	

local heroContribution = { }
local damageDetail = { } 

local timeRangeCombobox = object:GetWidget('deathRecapTimeRangeCombobox')

timeRangeCombobox:AddTemplateListItem('simpleDropdownItem', 0, 'label', 'deathrecap_range_25sec')
timeRangeCombobox:AddTemplateListItem('simpleDropdownItem', 1, 'label', 'deathrecap_range_thislife')
timeRangeCombobox:AddTemplateListItem('simpleDropdownItem', 2, 'label', 'deathrecap_range_thismatch')
timeRangeCombobox:SetSelectedItemByValue(0)
timeRangeCombobox:SetCallback('onselect', function(widget)
	local val = widget:GetValue()
	
	if val == "0" then
		RequestDeathRecap(25000) 	-- in milliseconds
	elseif val == "1" then
		RequestDeathRecap(0)	 	-- Special Case 0: This life
	elseif val == "2" then
		RequestDeathRecap(-1)		-- Special Case 1: This match
	end
end)


local function RegisterKillerWatchers()
	--[[
	killerData.killerPlayerName:RegisterWatchLua('DeathRecap', function(widget, trigger)
		widget:SetTexture(trigger.killerPlayerName)
	end, true, nil, 'killerPlayerName')
	--]]
	killerData.killerHeroName:RegisterWatchLua('DeathRecap', function(widget, trigger)
		if (trigger.killerHeroName ~= "") then
			widget:SetText(trigger.killerHeroName)
		else
			widget:SetText(Translate("deathrecap_environment"))
		end
	end, true, nil, 'killerHeroName')
	killerData.killerIcon:RegisterWatchLua('DeathRecap', function(widget, trigger)
		if (trigger.killerIcon ~= "") then
			widget:SetTexture(trigger.killerIcon)
		else
			widget:SetTexture("/ui/_textures/icons/icon_tower.tga")
		end
	end, true, nil, 'killerIcon')
	
	killerData.killerAbilityIcon:RegisterWatchLua('DeathRecap', function(widget, trigger)
		local killerAbilityIcon	= trigger.killerAbilityIcon
		local killerIcon		= trigger.killerIcon

		if killerAbilityIcon ~= killerIcon then
			widget:SetTexture(killerAbilityIcon)
		else
			widget:SetTexture('/ui/elements:auto_attack')
		end
	end, true, nil, 'killerAbilityIcon', 'killerIcon')
	killerData.killerAbilityName:RegisterWatchLua('DeathRecap', function(widget, trigger)
		local killerHeroName	= trigger.killerHeroName
		local killerAbilityName	= trigger.killerAbilityName
		if trigger.killerHeroName ~= killerAbilityName then
			widget:SetText(killerAbilityName)
		else
			widget:SetText(Translate('deathrecap_autoattack'))
		end
	end, true, nil, 'killerAbilityName', 'killerHeroName')
	killerData.killerDamage:RegisterWatchLua('DeathRecap', function(widget, trigger)
		widget:SetText(math.ceil(trigger.killerDamage))
	end, true, nil, 'killerDamage')
end

--[[
function RegisterDamageWatchers()
	damageEvent[0].container:RegisterWatchLua('DeathRecap', function(widget, trigger)
		if trigger.recentDmgCount == 0 then
			widget:SetVisible(false)
		else
			widget:SetVisible(true)
		end
	end, true, nil, 'recentDmgCount')
	damageEvent[0].abilityName:RegisterWatchLua('DeathRecap', function(widget, trigger)
		widget:SetText(math.ceil(trigger.recentDmgAmount1))
	end, true, nil, 'recentDmgAmount1')
	damageEvent[0].entityIcon:RegisterWatchLua('DeathRecap', function(widget, trigger)
		widget:SetTexture(trigger.recentDmgHeroIcon1)
	end, true, nil, 'recentDmgHeroIcon1')
	damageEvent[0].abilityIcon:RegisterWatchLua('DeathRecap', function(widget, trigger)
		widget:SetTexture(trigger.recentDmgAbilityIcon1)
	end, true, nil, 'recentDmgAbilityIcon1')
	damageEvent[0].dmgDesc:RegisterWatchLua('DeathRecap', function(widget, trigger)
		widget:SetText(trigger.recentDmgAbilityName1)
	end, true, nil, 'recentDmgAbilityName1' )

	damageEvent[1].container:RegisterWatchLua('DeathRecap', function(widget, trigger)
		if trigger.recentDmgCount > 1 then
			widget:SetVisible(true)
		else
			widget:SetVisible(false)
		end
		-- widget:SetText(trigger.killerHeroName)
	end, true, nil, 'recentDmgCount')
	damageEvent[1].abilityName:RegisterWatchLua('DeathRecap', function(widget, trigger)
		widget:SetText(math.ceil(trigger.recentDmgAmount2))
	end, true, nil, 'recentDmgAmount2')
	damageEvent[1].entityIcon:RegisterWatchLua('DeathRecap', function(widget, trigger)
		widget:SetTexture(trigger.recentDmgHeroIcon2)
	end, true, nil, 'recentDmgHeroIcon2')
	damageEvent[1].abilityIcon:RegisterWatchLua('DeathRecap', function(widget, trigger)
		widget:SetTexture(trigger.recentDmgAbilityIcon2)
	end, true, nil, 'recentDmgAbilityIcon2')
	damageEvent[1].dmgDesc:RegisterWatchLua('DeathRecap', function(widget, trigger)
		widget:SetText(trigger.recentDmgAbilityName2)
	end, true, nil, 'recentDmgAbilityName2' )

	damageEvent[2].container:RegisterWatchLua('DeathRecap', function(widget, trigger)
		if trigger.recentDmgCount > 2 then
			widget:SetVisible(true)
		else
			widget:SetVisible(false)
		end
	end, true, nil, 'recentDmgCount')
	damageEvent[2].abilityName:RegisterWatchLua('DeathRecap', function(widget, trigger)
			widget:SetText(math.ceil(trigger.recentDmgAmount3))
		end, true, nil, 'recentDmgAmount3')
	damageEvent[2].entityIcon:RegisterWatchLua('DeathRecap', function(widget, trigger)
			widget:SetTexture(trigger.recentDmgHeroIcon3)
		end, true, nil, 'recentDmgHeroIcon3')
	damageEvent[2].abilityIcon:RegisterWatchLua('DeathRecap', function(widget, trigger)
			widget:SetTexture(trigger.recentDmgAbilityIcon3)
		end, true, nil, 'recentDmgAbilityIcon3')
	damageEvent[2].dmgDesc:RegisterWatchLua('DeathRecap', function(widget, trigger)
			widget:SetText(trigger.recentDmgAbilityName3)
		end, true, nil, 'recentDmgAbilityName3' )
end
--]]

--[[
function RegisterCCWatchers()
	ccEvent[0].container:RegisterWatchLua('DeathRecap', function(widget, trigger)
		if trigger.recentCCCount == 0 then
			widget:SetVisible(false)
		else
			widget:SetVisible(true)
		end
	end, true, nil, 'recentCCCount')
	ccEvent[0].abilityName:RegisterWatchLua('DeathRecap', function(widget, trigger)
		widget:SetText(trigger.recentCCName1)
	end, true, nil, 'recentCCName1')
	ccEvent[0].entityIcon:RegisterWatchLua('DeathRecap', function(widget, trigger)
		widget:SetTexture(trigger.recentCCHeroIcon1)
	end, true, nil, 'recentCCHeroIcon1')
	ccEvent[0].abilityIcon:RegisterWatchLua('DeathRecap', function(widget, trigger)
		widget:SetTexture(trigger.recentCCAbilityIcon1)
	end, true, nil, 'recentCCAbilityIcon1')
	ccEvent[0].ccDesc:RegisterWatchLua('DeathRecap', function(widget, trigger)
		widget:SetText(trigger.recentCCAbilityName1)
	end, true, nil, 'recentCCAbilityName1' )

	ccEvent[1].container:RegisterWatchLua('DeathRecap', function(widget, trigger)
		if trigger.recentCCCount > 1 then
			widget:SetVisible(true)
		else
			widget:SetVisible(false)
		end
	end, true, nil, 'recentCCCount')
	ccEvent[1].abilityName:RegisterWatchLua('DeathRecap', function(widget, trigger)
		widget:SetText(trigger.recentCCName2)
	end, true, nil, 'recentCCName2')
	ccEvent[1].entityIcon:RegisterWatchLua('DeathRecap', function(widget, trigger)
		widget:SetTexture(trigger.recentCCHeroIcon2)
	end, true, nil, 'recentCCHeroIcon2')
	ccEvent[1].abilityIcon:RegisterWatchLua('DeathRecap', function(widget, trigger)
		widget:SetTexture(trigger.recentCCAbilityIcon2)
	end, true, nil, 'recentCCAbilityIcon2')
	ccEvent[1].ccDesc:RegisterWatchLua('DeathRecap', function(widget, trigger)
		widget:SetText(trigger.recentCCAbilityName2)
	end, true, nil, 'recentCCAbilityName2' )

	ccEvent[2].container:RegisterWatchLua('DeathRecap', function(widget, trigger)
		if trigger.recentCCCount > 2 then
			widget:SetVisible(true)
		else
			widget:SetVisible(false)
		end
	end, true, nil, 'recentCCCount')
	ccEvent[2].abilityName:RegisterWatchLua('DeathRecap', function(widget, trigger)
		widget:SetText(trigger.recentCCName3)
	end, true, nil, 'recentCCName3')
	ccEvent[2].entityIcon:RegisterWatchLua('DeathRecap', function(widget, trigger)
		widget:SetTexture(trigger.recentCCHeroIcon3)
	end, true, nil, 'recentCCHeroIcon3')
	ccEvent[2].abilityIcon:RegisterWatchLua('DeathRecap', function(widget, trigger)
		widget:SetTexture(trigger.recentCCAbilityIcon3)
	end, true, nil, 'recentCCAbilityIcon3')
	ccEvent[2].ccDesc:RegisterWatchLua('DeathRecap', function(widget, trigger)
		widget:SetText(trigger.recentCCAbilityName3)
	end, true, nil, 'recentCCAbilityName3' )
end
--]]

local function RegisterPieWatchers() 
	pies.DamageTypePie.container:RegisterWatchLua('DeathRecap', function(widget, trigger)
		local phys = trigger.dmgPhysical
		local abil = trigger.dmgAbility
		local other = trigger.dmgOther
		
		local total = phys + abil --  + other

		if phys ~= 0 then
			pies.DamageTypePie.Pies[1]:SetValue(1)
			pies.DamageTypePie.Pies[2]:SetValue(abil / total)
			-- pies.DamageTypePie.Pies[3]:SetValue(other / total)
			pies.DamageTypePie.Pies[3]:SetValue(0)
		elseif abil ~= 0 then
			pies.DamageTypePie.Pies[2]:SetValue(1)
			-- pies.DamageTypePie.Pies[3]:SetValue(other / total)
			pies.DamageTypePie.Pies[3]:SetValue(0)
		else
			pies.DamageTypePie.Pies[3]:SetValue(1)
		end
	
		pies.DamageTypePie.Percents[1]:SetText(math.floor(phys / total * 100 + .5)..'%')
		pies.DamageTypePie.Percents[2]:SetText(math.floor(abil / total * 100 + .5)..'%')
	end, true, nil, "dmgPhysical", "dmgAbility", "dmgOther")
	
	pies.DamageHeroPie.container:RegisterWatchLua('DeathRecap', function(widget, trigger)
		local damage = {
			[1] = trigger.teamDamageAmount1,
			[2] = trigger.teamDamageAmount2,
			[3] = trigger.teamDamageAmount3,
			[4] = trigger.teamDamageAmount4,
			[5] = trigger.teamDamageAmount5,
			[6] = trigger.teamDamageEnvironment
		}

		local total = 0
		for i=1,6 do
			total = total + damage[i]
		end
		pies.DamageHeroPie.Pies[1]:SetValue(1)

		local shownPercent = 1
		for i=1,6 do
			pies.DamageHeroPie.Pies[i]:SetValue(shownPercent)
			shownPercent = shownPercent - (damage[i] / total)
		end
		
		local totalDamage = 0
		for i=1,5 do
			totalDamage = totalDamage + math.floor(damage[i] / total * 100 + .5)
			pies.DamageHeroPie.Percents[i]:SetText(math.floor(damage[i] / total * 100 + .5)..'%')
		end
		pies.DamageHeroPie.Percents[6]:SetText((100 - totalDamage)..'%') -- Environmental absorbs up the rest of the damage, in-case things don't add up.
		
	end, true, nil, "teamDamageAmount1", "teamDamageAmount2", "teamDamageAmount3", "teamDamageAmount4", "teamDamageAmount5", "teamDamageEnvironment")
	

	pies.DamageHeroPie.IconsContainers[6]:RegisterWatchLua('DeathRecap', function(widget, trigger)
		if (trigger.teamDamageEnvironment == 0) then
			widget:SetVisible(false)
		else
			widget:SetVisible(true)
			-- widget:SetTexture(trigger['teamDamageIcon'..i])
		end
	end, true, nil, "teamDamageEnvironment")
	
	for i=1,5,1 do
		pies.DamageHeroPie.IconsContainers[i]:RegisterWatchLua('DeathRecap', function(widget, trigger)
			if (trigger['teamDamageAmount'..i] == 0) then
				widget:SetVisible(false)
			else
				widget:SetVisible(true)
				-- widget:SetTexture(trigger['teamDamageIcon'..i])
			end
		end, true, nil, "teamDamageIcon"..i, "teamDamageAmount"..i)
	
		-- Pie Icons
		pies.DamageHeroPie.Icons[i]:RegisterWatchLua('DeathRecap', function(widget, trigger)
			if (trigger['teamDamageAmount'..i] == 0) then
				widget:SetVisible(false)
			else
				widget:SetVisible(true)
				widget:SetTexture(trigger['teamDamageIcon'..i])
			end
		end, true, nil, "teamDamageIcon"..i, "teamDamageAmount"..i)

		-- Hero Names
		pies.DamageHeroPie.Labels[i]:RegisterWatchLua('DeathRecap', function(widget, trigger)
			if (trigger['teamDamageAmount'..i] == 0) then
				widget:SetVisible(false)
			else
				widget:SetVisible(true)
				widget:SetText(trigger['teamDamageHero'..i])
			end
		end, true, nil, "teamDamageHero"..i, "teamDamageAmount"..i)
	end
	
end					

--[[
function RegisterContrbutionWatchers()
	heroContribution.container:SetCallback('onmouseover', function(widget)
		damageDetail.container:SetVisible(true)
	end)
	heroContribution.container:SetCallback('onmouseout', function(widget)
		damageDetail.container:SetVisible(false)
	end)
	
	heroContribution.Values.lifeTime:RegisterWatchLua('DeathRecap', function(widget, trigger)
		widget:SetText(
			Translate(
				'general_seconds_amount', 'amount', math.ceil((trigger.heroLifetime) / 1000)
			)
		)
	end, true, nil, "heroLifetime")
	
	heroContribution.Values.damage:RegisterWatchLua('DeathRecap', function(widget, trigger)
		widget:SetText(math.ceil(trigger.heroDmgDealt))
	end, true, nil, "heroDmgDealt")
	
	heroContribution.Values.healed:RegisterWatchLua('DeathRecap', function(widget, trigger)
		widget:SetText(math.ceil(trigger.heroHealDealt))
	end, true, nil, "heroHealDealt")
	
end
--]]

--[[
function RegisterDetailsWatchers()
	damageDetail.Labels.ability[1]:RegisterWatchLua('DeathRecap', function(widget, trigger)
		widget:SetText(trigger.detailDmgAbility1Name)
	end, true, nil, "detailDmgAbility1Name")
	damageDetail.Labels.ability[2]:RegisterWatchLua('DeathRecap', function(widget, trigger)
		widget:SetText(trigger.detailDmgAbility2Name)
	end, true, nil, "detailDmgAbility2Name")
	damageDetail.Labels.ability[3]:RegisterWatchLua('DeathRecap', function(widget, trigger)
		widget:SetText(trigger.detailDmgAbility3Name)
	end, true, nil, "detailDmgAbility3Name")
	damageDetail.Labels.ability[4]:RegisterWatchLua('DeathRecap', function(widget, trigger)
		widget:SetText(trigger.detailDmgAbility4Name)
	end, true, nil, "detailDmgAbility4Name")

	
	damageDetail.Values.attack:RegisterWatchLua('DeathRecap', function(widget, trigger)
		widget:SetText(math.ceil(trigger.detailDmgAttack))
	end, true, nil, "detailDmgAttack")
	damageDetail.Values.ability[1]:RegisterWatchLua('DeathRecap', function(widget, trigger)
		widget:SetText(math.ceil(trigger.detailDmgAbility1))
	end, true, nil, "detailDmgAbility1")
	damageDetail.Values.ability[2]:RegisterWatchLua('DeathRecap', function(widget, trigger)
		widget:SetText(math.ceil(trigger.detailDmgAbility2))
	end, true, nil, "detailDmgAbility2")
	damageDetail.Values.ability[3]:RegisterWatchLua('DeathRecap', function(widget, trigger)
		widget:SetText(math.ceil(trigger.detailDmgAbility3))
	end, true, nil, "detailDmgAbility3")
	damageDetail.Values.ability[4]:RegisterWatchLua('DeathRecap', function(widget, trigger)
		widget:SetText(math.ceil(trigger.detailDmgAbility4))
	end, true, nil, "detailDmgAbility4")
	damageDetail.Values.familiar:RegisterWatchLua('DeathRecap', function(widget, trigger)
		widget:SetText(math.ceil(trigger.detailDmgFamiliar))
	end, true, nil, "detailDmgFamiliar")
	damageDetail.Values.item:RegisterWatchLua('DeathRecap', function(widget, trigger)
		widget:SetText(math.ceil(trigger.detailDmgItem))
	end, true, nil, "detailDmgItem")
end
--]]

local function deathRecapRegister(object)

	deathRecapContainer					= object:GetWidget('deathRecapContainer')
	-- deathRecapContainer:RegisterWatchLua('DeathRecap', function(widget, trigger)
		-- widget:SetVisible(trigger.visible)
	-- end, true, nil, 'visible')

	-- killerData.killerPlayerName 			= object:GetWidget('killerPlayerName')
	killerData.killerHeroName				= object:GetWidget('killerHeroName')
	killerData.killerIcon					= object:GetWidget('killerIcon')
	killerData.killerAbilityIcon			= object:GetWidget('killerAbilityIcon')
	killerData.killerAbilityName			= object:GetWidget('killerAbilityName')
	killerData.killerDamage 				= object:GetWidget('killerDmg')
	
	for i=0, 2 do
		damageEvent[i] = { }
		damageEvent[i].container = object:GetWidget('deathRecapDmgCCContainer' .. i)
		damageEvent[i].abilityName = object:GetWidget('deathRecapDmgCCSrcName' .. i)
		damageEvent[i].entityIcon = object:GetWidget('deathRecapDmgCCEntity' .. i)
		damageEvent[i].abilityIcon = object:GetWidget('deathRecapDmgCCAbility' .. i)
		damageEvent[i].dmgDesc = object:GetWidget('deathRecapDmgCCDescription' .. i)
	
		ccEvent[i] = { }
		ccEvent[i].container = object:GetWidget('deathRecapDmgCCContainer' .. i + 3)
		ccEvent[i].entityIcon = object:GetWidget('deathRecapDmgCCEntity' .. i + 3)
		ccEvent[i].abilityIcon = object:GetWidget('deathRecapDmgCCAbility' .. i + 3)
		ccEvent[i].abilityName = object:GetWidget('deathRecapDmgCCSrcName' .. i + 3)
		ccEvent[i].ccDesc = object:GetWidget('deathRecapDmgCCDescription' .. i + 3)
	end
	
	pies.DamageTypePie.container = object:GetWidget("deathRecapDamagePieContainer")
	for i=1, 3 do		-- Label1 = Phys, Label2 = Ability, Label3 = Other
		pies.DamageTypePie.Labels[i] = object:GetWidget("deathRecapDamagePieLabel" .. i)
	end
	pies.DamageTypePie.Pies[1] = object:GetWidget("deathRecapDamagePiePhysical")
	pies.DamageTypePie.Pies[2] = object:GetWidget("deathRecapDamagePieAbility")
	pies.DamageTypePie.Pies[3] = object:GetWidget("deathRecapDamagePieOther")
	pies.DamageTypePie.Percents[1] = object:GetWidget("deathRecapDamagePercentPhysical")
	pies.DamageTypePie.Percents[2] = object:GetWidget("deathRecapDamagePercentAbility")
	pies.DamageTypePie.Percents[3] = object:GetWidget("deathRecapDamagePercentOther")
	
	pies.DamageHeroPie.container = object:GetWidget("deathRecapTeamDamagePieContainer")
	for i=1,6 do
		pies.DamageHeroPie.Labels[i] = object:GetWidget("deathRecapTeamDamageLabel" .. i)
		pies.DamageHeroPie.Icons[i] = object:GetWidget("deathRecapTeamDamageIcon" .. i)
		pies.DamageHeroPie.Percents[i] = object:GetWidget("deathRecapTeamDamagePercent" .. i)
		pies.DamageHeroPie.IconsContainers[i] = object:GetWidget("deathRecapTeamDamageIcon" .. i..'Container')
		pies.DamageHeroPie.Pies[i] = object:GetWidget("deathRecapTeamDamagePieHero" .. i)
	end

	-- heroContribution.container = object:GetWidget("deathRecapHeroContributionContainer")
	heroContribution.Labels = {
		lifeTime = object:GetWidget("deathRecapHeroLifeTime"),
		damage = object:GetWidget("deathRecapHeroDamage"),
		healed = object:GetWidget("deathRecapHeroHealed"),
	}
	heroContribution.Values = {
		lifeTime = object:GetWidget("deathRecapHeroLifetimeValue"), 
		damage   = object:GetWidget("deathRecapHeroDamageValue"),
		healed   = object:GetWidget("deathRecapHeroHealedValue")
	}
	
	damageDetail.Labels = { 
		attack = object:GetWidget("deathRecapDetailAttack"),
		ability = {
			[1] = object:GetWidget("deathRecapDetailAbility1"),
			[2] = object:GetWidget("deathRecapDetailAbility2"),
			[3] = object:GetWidget("deathRecapDetailAbility3"),
			[4] = object:GetWidget("deathRecapDetailAbility4"),
		},
		familiar = object:GetWidget("deathRecapDetailFamiliar"), 
		item = object:GetWidget("deathRecapDetailItem")
	}
	
	damageDetail.Values = { 
		attack = object:GetWidget("deathRecapDetailAttackValue"),
		ability = {
			[1] = object:GetWidget("deathRecapDetailAbility1Value"),
			[2] = object:GetWidget("deathRecapDetailAbility2Value"),
			[3] = object:GetWidget("deathRecapDetailAbility3Value"),
			[4] = object:GetWidget("deathRecapDetailAbility4Value"),
		},
		familiar = object:GetWidget("deathRecapDetailFamiliarValue"), 
		item = object:GetWidget("deathRecapDetailItemValue")
	}
	
	RegisterKillerWatchers()
	-- RegisterDamageWatchers()
	-- RegisterCCWatchers()
	RegisterPieWatchers()
	-- RegisterContrbutionWatchers()
	-- RegisterDetailsWatchers()
	
	
	local showButton = object:GetWidget('showDeathRecapButton')
	
	libGeneral.createGroupTrigger('deathRecapShowButtonVis', { 'PlayerScore', 'DeathRecap', 'HeroUnit'})
	
	local showing = false
	showButton:RegisterWatchLua('deathRecapShowButtonVis', function(widget, groupTrigger)
		local triggerScore	= groupTrigger[1]
		--local triggerRecap	= groupTrigger[2]
		local triggerHero	= groupTrigger[3]

		local shouldShow = (not triggerHero.isActive) and (triggerScore.deaths > 0)
		if (showing ~= shouldShow) then
			fadeWidget(widget, shouldShow, 350)
			widget:SetX(shouldShow and '-30h' or '.5h')
			widget:SlideX(shouldShow and '.5h' or '-30h', 350)
		end
		showing = shouldShow

		-- Don't show button for too long
	end)
	
	
	showButton:SetCallback('onclick', function(widget)
		fadeWidget(deathRecapContainer, not deathRecapContainer:IsVisible(), 250) -- Toggle visibility
	end)
	
	
	-- Commented out because moving the button closer to center-screen makes it much more intrusive.
	-- showButton:RegisterWatchLua('ShopActive', function(widget, trigger)
	-- 	if trigger.isActive then
	-- 		widget:SlideX(libGeneral.HtoP(60), styles_uiSpaceShiftTime)
	-- 	else
	-- 		widget:SlideX(libGeneral.HtoP(0.5), styles_uiSpaceShiftTime)
	-- 	end
	-- end)	
end

deathRecapRegister(object)