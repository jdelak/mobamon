-- new_game_herotargetstats.lua (12/2014)
-- functionality for the hero / target stats windows

-- Updates the position of the hero stats and target stats
function updateStatPosition()
	local swapSides = 1
	
	if GetCvarBool('ui_swapMinimap') then
		swapSides = -1
	end
	
	local object = gameGetInterface()
	
	local statsParent			= object:GetWidget('gameLeftCornerAnimation')
	local statsContainers		= object:GetWidget('gameLeftCornerContainer')
	
	local targetStatsTopLeft	= object:GetWidget('gameTargetStatTopLeft')
	local targetStatsTopRight	= object:GetWidget('gameTargetStatTopRight')
	
	local neutralStatsTopLeft	= object:GetWidget('gameNeutralStatTopLeft')
	local neutralStatsTopRight	= object:GetWidget('gameNeutralStatTopRight')
	
	local heroStatsBottomLeft	= object:GetWidget('gameHeroStatBottomLeft')
	local heroStatsBottomRight	= object:GetWidget('gameHeroStatBottomRight')
	local heroStatsTopLeft		= object:GetWidget('gameHeroStatTopLeft')
	local heroStatsTopRight		= object:GetWidget('gameHeroStatTopRight')
	
	local targetStatOffset		= object:GetGroup('targetStatOffset')
	
	for k,v in ipairs(targetStatOffset) do
		if (swapSides == 1) then
			v:SetX('-0.3')
		else
			v:SetX('0.3')
		end
	end
	
	if (swapSides == 1) then
		statsParent:SetAlign('left')
		statsParent:SetX('-0.9h')
		statsContainers:SetAlign('left')
		
		targetStatsTopLeft:SetVisible(true)
		targetStatsTopRight:SetVisible(false)
		
		neutralStatsTopLeft:SetVisible(true)
		neutralStatsTopRight:SetVisible(false)
		
		heroStatsBottomLeft:SetVisible(true)
		heroStatsBottomRight:SetVisible(false)
		heroStatsTopLeft:SetVisible(true)
		heroStatsTopRight:SetVisible(false)
	else
		statsParent:SetAlign('right')
		statsParent:SetX('0.9h')
		statsContainers:SetAlign('right')
		
		targetStatsTopLeft:SetVisible(false)
		targetStatsTopRight:SetVisible(true)
		
		neutralStatsTopLeft:SetVisible(false)
		neutralStatsTopRight:SetVisible(true)
		
		heroStatsBottomLeft:SetVisible(false)
		heroStatsBottomRight:SetVisible(true)
		heroStatsTopLeft:SetVisible(false)
		heroStatsTopRight:SetVisible(true)
	end
end
updateStatPosition()

-- Register both the player's hero stats and target hero stats containers
local interface = object

function registerHeroStats()
	
	local statTypes = { 
		"Power", 			"AttackSpeed",
		"AbilityDamage",	"AttackDamage",
		"Mitigation",		"MovementSpeed",
		"Resistance",		"GPM",
		"Kills",			"Kills",
		"Assists",			"",
		"Deaths",			"Deaths",
	}

	local statIcons = {
		'/ui/game/shared/textures/herostat_power.tga', 		'/ui/game/shared/textures/herostat_dps.tga',
		'/ui/game/shared/textures/herostat_dps.tga',   		'/ui/game/shared/textures/herostat_power.tga',
		'/ui/game/shared/textures/herostat_armor.tga', 		'/ui/shared/textures/itemtype_boots.tga',
		'/ui/game/shared/textures/herostat_magicarmor.tga', '/ui/shared/textures/gold_coins.tga',
		'',													'',
		'',													'',	
		'',													'',	
	}
	
	local statName = { 
		"stattip_power",			"stattip_attackSpeed",
		"stattip_abilityDamage",	"stattip_attackDamage",
		"stattip_mitigation",		"stattip_movementSpeed",
		"stattip_resistance",		"stattip_GPM",
		"stattip_kills",			"stattip_kills",
		"stattip_assists",			"",
		"stattip_deaths",			"stattip_deaths"
	}
	
	local triggerParamNames = {
		"power",			"attackSpeed",
		"",					"damage",
		"mitigation",		"moveSpeed",
		"resistance",		"gpm",
		"heroKills",		"kills",
		"assists",			"",
		"deaths",			"death"
	}
	
	local targetStatTrigger = nil
	local targetStatRegistrations = { }

	local targetStats 	= nil
	local heroStats 	= nil

	local statTipWidget 	= object:GetWidget('stats_tooltip')
	local statTipIconParent	= object:GetWidget('stats_tipIcon'):GetParent()
	local statTipIcon 		= object:GetWidget('stats_tipIcon')
	local statTipName 		= object:GetWidget('stats_tipName')
	local statTipVal 		= object:GetWidget('stats_tipValue')
	local statTipDesc 		= object:GetWidget('stats_tipDescription')
	
	local statTipLevel 		= object:GetWidget('gameTargetHero_level')
	local statTipHealthBar 	= object:GetWidget('gameTargetStatBarHealth')
	local statTipHealthText	= object:GetWidget('gameTargetStatBarHealthText')
	local statTipManaBar 	= object:GetWidget('gameTargetStatBarMana')
	local statTipManaText 	= object:GetWidget('gameTargetStatBarManaText')
	
	-- local statCourierButton	= object:GetWidget('gameMinimapButtonCourier2')

	local statTipTrigger = nil
	local statTipRegistrations = { }
	
	-- local function registerCourierButton()
		-- statCourierButton:RegisterWatchLua('gamePanelInfo', function(widget, trigger)
			-- widget:SetVisible(trigger.mapWidgetVis_courierButton)
		-- end, false, nil, 'mapWidgetVis_courierButton')
		
		-- statCourierButton:SetCallback('onclick', function()
			-- ActivateTool(11)
		-- end)
		
		-- statCourierButton:SetCallback('onmouseover', function(widget)
			-- UpdateCursor(widget, true, { canLeftClick = true})
		-- end)
		
		-- statCourierButton:SetCallback('onmouseout', function(widget)
			-- UpdateCursor(widget, false, { canLeftClick = true})
		-- end)
		
		-- gameHelper.registerMiniButton('gameMinimapButtonCourier2', 'ActiveInventory11', 'icon')
	-- end
	
	-- registerCourierButton()

	local statTipShowCount = 0
	local function statTipHide()
		statTipShowCount = statTipShowCount - 1
		if statTipShowCount <= 0 then
			statTipWidget:SetVisible(false)
			statTipShowCount = 0
		end
	end

	local function statTipShow()
		statTipShowCount = statTipShowCount + 1
		statTipWidget:SetVisible(true)
	end

	local function registerStatTip(index, unitTrigger, target)
		if statTipTrigger then
			for k,v in ipairs(statTipRegistrations) do
				v:UnregisterWatchLua(statTipTrigger)
			end
			statTipRegistrations = { }
		end

		statTipTrigger = unitTrigger
		if statTipTrigger == nil then
			return
		end

		
		if statIcons[index] and statIcons[index] ~= '' then
			statTipIcon:SetTexture(statIcons[index])
			statTipIconParent:SetVisible(true)
			statTipName:SetX('3.5h')
		else
			statTipIconParent:SetVisible(false)
			statTipName:SetX('0.6h')
		end
		
		statTipName:SetText(Translate(statName[index]))

		statTipDesc:SetText(Translate(statName[index]..'_desc'))

		if target and statTypes[index] == 'AttackSpeed' then
			gameHelper.registerWatchText(statTipVal, unitTrigger, triggerParamNames[index], nil, function(val) return libNumber.round(val * 100) end)
		else
			gameHelper.registerWatchTextFloor(statTipVal, unitTrigger, triggerParamNames[index])
		end 

		statTipRegistrations[1] = statTipIcon
		statTipRegistrations[2] = statTipName
		statTipRegistrations[3] = statTipDesc
		statTipRegistrations[4] = statTipVal
	end

	local function registerStats(widgetPrefix, trigger, target)
		local statsContainer = gameGetWidget(widgetPrefix .. 'sContainers')
		local widgetIndex = 1

		for k,v in ipairs(statTypes) do
			if triggerParamNames[k] ~= nil and triggerParamNames[k] ~= "" then
				local statWidget = statsContainer:GetWidget(widgetPrefix .. v .. '_text')
				if statWidget ~= nil then
					if target and v == 'AttackSpeed' then
						gameHelper.registerWatchText(statWidget, trigger, triggerParamNames[k], nil, function(val) return libNumber.round(val * 100) end)
					else
						gameHelper.registerWatchTextFloor(statWidget, trigger, triggerParamNames[k])
					end 

					local statRow = gameGetWidget(widgetPrefix .. v)
					statRow:SetCallback('onmouseover', function(widget)
						statTipShow()
						registerStatTip(k, trigger, target)
						LuaTrigger.GetTrigger(trigger):Trigger(true)
					end)
					statRow:SetCallback('onmouseout', function(widget)
						statTipHide()
					end)
					
					if target then
						local differenceWidget = gameGetWidget('gameStat' .. v .. '_difference')
					
						differenceWidget:RegisterWatchLua(trigger, function(widget, trigger)
							local statVal = trigger[triggerParamNames[k] ]
							local heroTrigger = LuaTrigger.GetTrigger('HeroUnit')
							local heroStatVal = heroTrigger[triggerParamNames[k] ]

							widget:SetVisible(statVal ~= heroStatVal)
							if (statVal > heroStatVal) then
								widget:SetTexture('/ui/shared/textures/plus_icon_green.tga')
							elseif statVal < heroStatVal then
								widget:SetTexture('/ui/shared/textures/minus_icon_red.tga')
							end
						end, true, nil, triggerParamNames[k])

						differenceWidget:RegisterWatchLua('HeroUnit', function(widget, t)
							local statValTrigger = LuaTrigger.GetTrigger(trigger)
							local statVal 		 = statValTrigger[triggerParamNames[k] ]
							local heroStatVal 	 = t[triggerParamNames[k] ]

							widget:SetVisible(statVal ~= heroStatVal)
							if (statVal > heroStatVal) then
								widget:SetTexture('/ui/shared/textures/plus_icon_green.tga')
							elseif statVal < heroStatVal then
								widget:SetTexture('/ui/shared/textures/minus_icon_red.tga')
							end
						end, true, nil, triggerParamNames[k])
					
						targetStatRegistrations[widgetIndex] = statWidget
						targetStatRegistrations[widgetIndex + 1] = differenceWidget
						widgetIndex = widgetIndex + 2
					end
				end
			end
		end
	end


	-- register the target stat area
	local function registerTargetStats()
		local targetStatContainer 	= object:GetWidget('gameTargetStatsContainers')
		local targetIcon 			= targetStatContainer:GetWidget('gameTargetHero_icon')
		local targetEffect 			= targetStatContainer:GetWidget('gameTargetHero_effect')

		local unitTrigger 			= trigger
		local prevTriggerName		= nil
		
		-- we want to know if the selection is a hero or if the hero selected changed
		libGeneral.createGroupTrigger('targetStatVisible', {
			'SelectedUnits0.index',
			'SelectedUnit.isHero',
		})
		
		gameHelper.registerWatchTexture(targetIcon, 'SelectedUnit', 'entity', nil, function(val)
			if val ~= nil and val ~= "" and ValidateEntity(val) and GetEntityCutOutIconPath(val) ~= '' then
				return GetEntityCutOutIconPath(val)
			else
				return LuaTrigger.GetTrigger('SelectedUnits0').iconPath
			end
		end)

		targetStatContainer:RegisterWatchLua('targetStatVisible', function(widget, trigger)
			local unitTriggerName
			local unitTrigger
			
			-- only care if its a hero
			local isHero 			= trigger['SelectedUnit'].isHero
			local heroIndex 		= trigger['SelectedUnits0'].index
			local selfIndex 		= LuaTrigger.GetTrigger('HeroUnit').index

			local killsLabel		= gameGetWidget('gameTargetStat_kills_text')
			local assistsLabel		= gameGetWidget('gameTargetStat_assists_text')
			local deathsLabel 		= gameGetWidget('gameTargetStat_deaths_text')
			local nameLabel 		= gameGetWidget('gameTargetStat_name')
			
			if (targetAnimationThread) then
				targetAnimationThread:kill()
				targetAnimationThread = nil
			end
				
			if (isHero and heroIndex ~= selfIndex) then				
				local isAlly = false

				-- find which hero trigger corresponds to this guy
				for i=0,4 do
					if i ~= 4 then
						local allyUnit = LuaTrigger.GetTrigger('AllyUnit' .. i)
						if allyUnit.index == heroIndex then
							unitTriggerName = 'AllyUnit' .. i
							unitTrigger = allyUnit
							isAlly = true
							break
						end
					end
					local enemyUnit = LuaTrigger.GetTrigger('EnemyUnit' .. i)
					if enemyUnit.index == heroIndex then
						unitTriggerName = 'EnemyUnit' .. i
						unitTrigger = enemyUnit
						break
					end
				end

				-- clean up the old data
				if targetStatTrigger ~= nil then					
					for k,v in ipairs(targetStatRegistrations) do
						v:UnregisterWatchLua(targetStatTrigger)
					end
				end
				
				if (prevTriggerName) then
					statTipLevel:UnregisterWatchLua(prevTriggerName)
					statTipHealthBar:UnregisterWatchLua(prevTriggerName)
					statTipManaBar:UnregisterWatchLua(prevTriggerName)
					killsLabel:UnregisterWatchLua(prevTriggerName)
					assistsLabel:UnregisterWatchLua(prevTriggerName)
					deathsLabel:UnregisterWatchLua(prevTriggerName)
					nameLabel:UnregisterWatchLua(prevTriggerName)
				end
				
				if (unitTrigger) then				
					targetStatTrigger = unitTriggerName
					targetStatRegistrations = { }
					
					-- register the stats to labels
					targetStatContainer:FadeIn(200)

					if isAlly then
						targetEffect:SetColor(0,1,0,0.2)
						statTipHealthBar:SetColor('#01d600')
						statTipHealthBar:SetBorderColor('#01d600')
						nameLabel:SetColor(0,1,0)
					else
						targetEffect:SetColor(1,0,0,0.2)
						statTipHealthBar:SetColor('#d60000')
						statTipHealthBar:SetBorderColor('#d60000')
						nameLabel:SetColor(1,0,0)
					end
					
					statTipLevel:RegisterWatchLua(unitTriggerName, function(widget, trigger)
						widget:SetText(trigger.level)
					end, true, nil, 'level')
					
					
					statTipHealthBar:RegisterWatchLua(unitTriggerName, function(widget, trigger)
						widget:ScaleWidth((trigger.healthPercent * 100) .. '%', 400)
						statTipHealthText:SetText(libNumber.commaFormat(math.floor(trigger.health)))
					end, true, nil, 'healthPercent', 'health')
					

					statTipManaBar:RegisterWatchLua(unitTriggerName, function(widget, trigger)
						widget:ScaleWidth((trigger.manaPercent * 100) .. '%', 400)
						statTipManaText:SetText(libNumber.commaFormat(math.floor(trigger.mana)))
					end, true, nil, 'manaPercent', 'mana')

					registerStats('gameTargetStat', unitTriggerName, true)
					
					assistsLabel:SetCallback('onmouseover', function(widget)
						statTipShow()
						registerStatTip(11, unitTriggerName, target)
						LuaTrigger.GetTrigger(unitTriggerName):Trigger(true)
					end)
					
					assistsLabel:SetCallback('onmouseout', function(widget)
						statTipHide()
					end)
					
					killsLabel:SetCallback('onmouseover', function(widget)
						statTipShow()
						registerStatTip(10, unitTriggerName, target)
						LuaTrigger.GetTrigger(unitTriggerName):Trigger(true)
					end)
					
					killsLabel:SetCallback('onmouseout', function(widget)
						statTipHide()
					end)
					
					deathsLabel:SetCallback('onmouseover', function(widget)
						statTipShow()
						registerStatTip(14, unitTriggerName, target)
						LuaTrigger.GetTrigger(unitTriggerName):Trigger(true)
					end)
					
					deathsLabel:SetCallback('onmouseout', function(widget)
						statTipHide()
					end)
					
					gameHelper.registerWatchText(killsLabel, unitTriggerName, 'kills')
					gameHelper.registerWatchText(assistsLabel, unitTriggerName, 'assists')
					gameHelper.registerWatchText(deathsLabel, unitTriggerName, 'death')
					gameHelper.registerWatchText(nameLabel, unitTriggerName, 'playerName')

					prevTriggerName = unitTriggerName

					-- force update the stat area
					unitTrigger:Trigger(true)
					return
				end
			end
			
			-- not a hero, hide it and unregister the watches
			targetStatContainer:FadeOut(150)
			
			if targetStatTrigger ~= nil then
				for k,v in ipairs(targetStatRegistrations) do
					v:UnregisterWatchLua(targetStatTrigger)
					v:UnregisterWatchLua('HeroUnit')
				end
			end
			
			if (prevTriggerName) then
				statTipLevel:UnregisterWatchLua(prevTriggerName)
				statTipHealthBar:UnregisterWatchLua(prevTriggerName)
				statTipManaBar:UnregisterWatchLua(prevTriggerName)
				killsLabel:UnregisterWatchLua(prevTriggerName)
				deathsLabel:UnregisterWatchLua(prevTriggerName)
				nameLabel:UnregisterWatchLua(prevTriggerName)
			end

			targetStatTrigger = nil
			targetStatRegistrations = nil
		end, true, nil)


		for n = 1, 9 do
			local widget = interface:GetWidget('gameTargetStatRow_item'..n)
			widget:RegisterWatchLua('SelectedInventory' .. (n + 95), function(widget, trigger)
				if (trigger.icon == "") then
					widget:SetVisible(false)
				else
					widget:SetVisible(true)
					widget:SetTexture(trigger.icon)
				end
			end)

			widget:SetCallback('onmouseover', function(widget)
				shopItemTipShow((n + 95), 'SelectedInventory')
			end)

			widget:SetCallback('onmouseout', function(widget)
				shopItemTipHide()
			end)
		end
	end

	
	local function registerPlayerStats()
		local goldLabel 	= object:GetWidget('gamePlayerStat_gold')
		local killsLabel 	= object:GetWidget('gamePlayerStat_kills_text')
		local assistLabel 	= object:GetWidget('gamePlayerStat_assists_text')
		local deathsLabel 	= object:GetWidget('gamePlayerStat_deaths_text')
		
		killsLabel:SetCallback('onmouseover', function(widget)
			statTipShow()
			registerStatTip(9, 'PlayerScore', target)
			LuaTrigger.GetTrigger('PlayerScore'):Trigger(true)
		end)
		
		killsLabel:SetCallback('onmouseout', function(widget)
			statTipHide()
		end)
		
		assistLabel:SetCallback('onmouseover', function(widget)
			statTipShow()
			registerStatTip(11, 'PlayerScore', target)
			LuaTrigger.GetTrigger('PlayerScore'):Trigger(true)
		end)
		
		assistLabel:SetCallback('onmouseout', function(widget)
			statTipHide()
		end)
		
		deathsLabel:SetCallback('onmouseover', function(widget)
			statTipShow()
			registerStatTip(13, 'PlayerScore', target)
			LuaTrigger.GetTrigger('PlayerScore'):Trigger(true)
		end)
		
		deathsLabel:SetCallback('onmouseout', function(widget)
			statTipHide()
		end)

		gameHelper.registerWatchText(goldLabel, 'HeroUnit', 'gold')
		gameHelper.registerWatchText(killsLabel, 'PlayerScore', 'heroKills')
		gameHelper.registerWatchText(assistLabel, 'PlayerScore', 'assists')
		gameHelper.registerWatchText(deathsLabel, 'PlayerScore', 'deaths')

		registerStats('gamePlayerStat', 'HeroUnit')
	end

	registerPlayerStats()
	registerTargetStats()
end