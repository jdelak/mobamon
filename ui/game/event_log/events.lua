-- Game Events (kills, deaths, towers, bosses)
gameEvents = {}
local interface = object
local GetTrigger = LuaTrigger.GetTrigger

local fullLaneNames = {	-- May not always just be a case change
	bottom	= Translate('lane_bot'),
	middle	= Translate('lane_mid'),
	top		= Translate('lane_top')
}

local barracksEntities = {
	'Building_LegionMeleeBarracks',
	'Building_HellbourneMeleeBarracks'
}
local function isBarracksEntity(input)
	return libGeneral.isInTable(barracksEntities, input)
end

local towerEntities = {
	'Building_LegionTower',
	'Building_HellbourneTower',
	'Building_Tutorial_Tower'
}

local function isTowerEntity(input)
	return libGeneral.isInTable(towerEntities, input)
end

local captureEntities = {
	'Building_LegionStatic_Home1',
	'Building_LegionStatic_Home2',
	'Building_HellbourneStatic_Home1',
	'Building_HellbourneStatic_Home2'
}

local function isCaptureEntity(input)
	return libGeneral.isInTable(captureEntities, input)
end

local recaptureEntities = {
	'Building_LegionStatic_Away1',
	'Building_LegionStatic_Away2',
	'Building_HellbourneStatic_Away1',
	'Building_HellbourneStatic_Away2'
}

local function isRecaptureEntity(input)
	return libGeneral.isInTable(recaptureEntities, input)
end

local function PlayGoldSound(goldReward, sourceTrigger)
	println('^y^: PlayGoldSound ' .. tostring(goldReward) .. ' | ' .. tostring(sourceTrigger) )
	if (goldReward) then
		if (goldReward > 1000) then
			PlaySound('/shared/sounds/ui/sfx_gold_3.wav')
		elseif (goldReward > 200) then
			PlaySound('/shared/sounds/ui/sfx_gold_2.wav')
		elseif (goldReward >= 10) then
			PlaySound('/shared/sounds/ui/sfx_gold_1.wav')
		end
	end
end

if (LuaTrigger.GetTrigger('EventHeroGold')) then
	interface:RegisterWatchLua('EventBossGold',  function(widget, trigger) PlayGoldSound(trigger.gold, 'EventBossGold') end)
	interface:RegisterWatchLua('EventGeneratorGold',  function(widget, trigger) PlayGoldSound(trigger.gold, 'EventGeneratorGold') end)
	interface:RegisterWatchLua('EventTowerGold',  function(widget, trigger) PlayGoldSound(trigger.gold, 'EventTowerGold') end)
	interface:RegisterWatchLua('EventHeroGold',  function(widget, trigger) PlayGoldSound(trigger.gold, 'EventHeroGold') end)
	-- interface:RegisterWatchLua('EventPlayerGold',  function(widget, trigger) PlayGoldSound(trigger.gold, 'EventPlayerGold') end)
end

function gameEventsRegister(object)
	local scrollPanel			= object:GetWidget('gameEventScrollPanel')
	local scrollBar				= object:GetWidget('gameEventScrollBar')
	local eventsContainer		= object:GetWidget('gameEventsContainer')
	local contentBody			= object:GetGroup('gameEventsBody')
	local viewArea				= object:GetWidget('gameEventsViewArea')
	local viewHeight			= viewArea:GetHeight()
	local scrollPosition		= 0
	local scrollPositionMax		= 0
	local displaySlots			= {}
	local displaySlotPopulated	= {}
	local displayOrder			= {}	-- Current order of display slots, top-down
	local maxDisplaySlots		= 30
	local fadeTimes				= {}
	local fadeTime				= 1000
	local displayLength			= 7500
	local viewHistory			= false
	local labelFontTable		= {
		'maindyn_12',
		'maindyn_11',
		'maindyn_10',
		'maindyn_9',
		'maindyn_8'
	}
	
	function gameEventHighlightLabel(index)
		spotlightWidget(displaySlots[index].label1)
	end
	
	local captureEntities = {
		'Building_LegionStatic_Home1',
		'Building_LegionStatic_Home2',
		'Building_HellbourneStatic_Home1',
		'Building_HellbourneStatic_Home2'
	}
	
	local function isCaptureEntity(input)
		return libGeneral.isInTable(captureEntities, input)
	end

	-- ============= Building Destruction ===========

	local teamIcons = {
		'/ui/elements:crest_legion',
		'/ui/elements:crest_hellbourne'
	}

	local function cycleSlots()	-- Move the last slot up front before populating
		local newDisplayOrder = {}
		
		for i=2,maxDisplaySlots,1 do
			newDisplayOrder[i - 1] = displayOrder[i]
		end
		table.insert(newDisplayOrder, displayOrder[1])
		displayOrder = newDisplayOrder
	end
	
	local function arrangeSlots()
		local displaySlotID = nil
		local displaySlot = nil
		local yPosition = 0
		local prevDisplaySlotID = 0
		local prevDisplaySlot =  nil
		for i=1,maxDisplaySlots,1 do
			displaySlotID = displayOrder[maxDisplaySlots - i + 1]
			displaySlot = displaySlots[displaySlotID]

			if i > 1 then
				prevDisplaySlotID = displayOrder[maxDisplaySlots - i + 2]
				prevDisplaySlot = displaySlots[prevDisplaySlotID]
				yPosition = yPosition - itemPadding - prevDisplaySlot.root[1]:GetHeight()
			else
				yPosition = 0
			end
			
			for k,v in pairs(displaySlot.root) do
				v:SetY(yPosition)
			end
			
		end
	end
	
	local function updateScrolling()
		local totalItems = 0
		local totalHeight = 0
		local scrollVisible = false
		for i=1,maxDisplaySlots,1 do
			if displaySlots[i].root[1]:IsVisibleSelf() then
				if totalItems > 0 then
					totalHeight = totalHeight + itemPadding
				end
				totalHeight = totalHeight + displaySlots[i].root[1]:GetHeight()
				totalItems = totalItems + 1
			end
		end
		
		scrollPositionMax = math.ceil((totalHeight - viewHeight) / scrollStep)
		scrollVisible = (scrollPositionMax > 0 and viewHistory)
		scrollBar:SetVisible(scrollVisible)
		scrollPanel:SetVisible(scrollVisible)
		
		scrollBar:SetMaxValue(scrollPositionMax)
		if scrollPosition > scrollPositionMax then
			scrollPosition = scrollPositionMax
			scrollBar:SetValue(scrollPosition)
		end
		scrollPosition = scrollPositionMax
		scrollBar:SetValue(scrollPosition)
		
	end
	
	local function fadeAction(widget, trigger)
		hostTime = trigger.hostTime
		
		for k,v in pairs(fadeTimes) do
			if v < hostTime then
			
				for j,l in pairs(displaySlots[k].root) do
					l:FadeOut(
						math.max(
							fadeTime,
							fadeTime - (v + hostTime)
						)
					)
				end
				fadeTimes[k] = nil
			end
		end

		if table.maxn(fadeTimes) <= 0 then
			eventsContainer:UnregisterWatchLua('System')
		end
	end

	local function fadeInit()
		if not viewHistory and table.maxn(fadeTimes) > 0 then
			eventsContainer:RegisterWatchLua('System', fadeAction, false, nil, 'hostTime')
		else
			eventsContainer:UnregisterWatchLua('System')
		end
	end
	
	local function tallyNewEntry()
		local lastOrderID	= nil
		local displaySlot	= nil
		
		cycleSlots()
		
		lastOrderID	= displayOrder[maxDisplaySlots]
		displaySlot	= displaySlots[lastOrderID]
		
		if displaySlot then
			displaySlotPopulated[lastOrderID] = true
			if fadeTimes[lastOrderID] == nil then
				fadeTimes[lastOrderID] = GetTime() + displayLength
			end
			
		end
		
		arrangeSlots()
		updateScrolling()
		fadeInit()
		
		return displaySlot
	end
	
	-- =============  General ===========
	
	local function populateDisplaySlotLaneChoice(displaySlot, eventData)
		for k,v in pairs(displaySlot.root) do
			v:SetVisible(true)
		end
	
		displaySlot.label3:SetVisible(false)
	
		displaySlot.backer2:SetVisible(false)
		displaySlot.arrow:SetVisible(false)
		displaySlot.icon2:SetVisible(false)
		displaySlot.icon3:SetVisible(false)
		displaySlot.icon1:SetTexture(eventData.pusherIcon)
		displaySlot.icon1:SetColor(1,1,1,1)
		displaySlot.label1:SetColor(1,1,1,1)
		displaySlot.label1:SetText(eventData.pushMessage)
		displaySlot.label2:SetVisible(false)
		displaySlot.glow:SetVisible(true)
		displaySlot.glow:SetBorderColor(eventData.notifyColorR, eventData.notifyColorG, eventData.notifyColorB)
		displaySlot.glow:SetColor(eventData.notifyColorR, eventData.notifyColorG, eventData.notifyColorB)
		
		
		displaySlot.iconBorder2:SetVisible(true)
		displaySlot.iconBorder3:SetVisible(false)
		displaySlot.iconBorder2:SetBorderColor(eventData.backerColor)
		
		displaySlot.backer:SetColor(eventData.backerColor)
		displaySlot.backer:SetBorderColor(eventData.backerColor)
		
		-- Format accordingly
		

		displaySlot.icon1:SetWidth('3h')
		displaySlot.icon1:SetHeight('3h')
		
		displaySlot.icon1:SetAlign('left')
		displaySlot.icon1:SetX('0.5h')
		
		displaySlot.label1:SetWidth('-4.5h')
		displaySlot.label1:SetX('-1h')
		displaySlot.label1:SetAlign('right')

		displaySlot.label1:SetTextAlign('center')

	end
	
	local function populateDisplaySlotBuildingKill(displaySlot, eventData)
		for k,v in pairs(displaySlot.root) do
			v:SetVisible(true)
		end		

		
		displaySlot.backer:SetColor(eventData.backerColor)
		displaySlot.backer:SetBorderColor(eventData.backerColor)
		
		displaySlot.iconBorder2:SetVisible(true)
		displaySlot.iconBorder3:SetVisible(false)
		displaySlot.iconBorder2:SetBorderColor(eventData.backerColor)
		
		displaySlot.label3:SetVisible(false)
		displaySlot.label2:SetVisible(false)
		displaySlot.label1:SetText(eventData.message)
		displaySlot.label1:SetColor(1,1,1,1)
		displaySlot.backer2:SetVisible(false)
		displaySlot.arrow:SetVisible(false)
		displaySlot.icon1:SetTexture(eventData.teamIcon)
		displaySlot.icon1:SetColor(1,1,1,1)
		displaySlot.icon2:SetVisible(false)
		displaySlot.icon3:SetVisible(false)
		displaySlot.glow:SetVisible(true)
		displaySlot.glow:SetBorderColor(eventData.notifyColorR, eventData.notifyColorG, eventData.notifyColorB)
		displaySlot.glow:SetColor(eventData.notifyColorR, eventData.notifyColorG, eventData.notifyColorB)
		
		-- Format accordingly
		
		displaySlot.icon1:SetWidth('3h')
		displaySlot.icon1:SetHeight('3h')
		
		displaySlot.icon1:SetAlign('left')
		displaySlot.icon1:SetX('0.5h')
		
		displaySlot.label1:SetWidth('-4.5h')
		displaySlot.label1:SetX('-1h')
		displaySlot.label1:SetAlign('right')
		displaySlot.label1:SetTextAlign('center')
	end
	
	local function populateDisplaySlotKill(displaySlot, eventData)
		for k,v in pairs(displaySlot.root) do
			v:SetVisible(true)
		end

		if eventData.goldIncome > 0 then
			displaySlot.label3:SetVisible(true)
			displaySlot.label3:SetText(libNumber.commaFormat(eventData.goldIncome))
		else
			displaySlot.label3:SetVisible(false)
		end
		
	
		displaySlot.icon1:SetTexture('/ui/game/unit_frames/textures/dead.tga')
		
		displaySlot.backer:SetColor(0.1, 0.1, 0.1, 1)
		displaySlot.backer:SetBorderColor(0.1, 0.1, 0.1, 1)
		
		displaySlot.icon2:SetVisible(true)
		displaySlot.icon3:SetVisible(true)
		displaySlot.icon2:SetTexture(eventData.killerIcon)
		displaySlot.icon3:SetTexture(eventData.victimIcon)
		displaySlot.iconBorder2:SetVisible(true)
		displaySlot.iconBorder3:SetVisible(true)
		
		displaySlot.iconBorder2:SetBorderColor(0,0,0)
		displaySlot.iconBorder3:SetBorderColor(0,0,0)
		
		displaySlot.iconBorder2:SetX(libGeneral.HtoP(0.5))
		displaySlot.iconBorder3:SetX(libGeneral.HtoP(-0.5))
		displaySlot.iconBorder3:SetAlign('right')
		
		displaySlot.icon3:SetAlign('right')
		displaySlot.icon3:SetX(libGeneral.HtoP(-0.5))
		
		displaySlot.icon2:SetX(libGeneral.HtoP(0.5))
		
		displaySlot.backer2:SetVisible(true)
		displaySlot.arrow:SetVisible(true)
		
		displaySlot.glow:SetVisible(true)
		displaySlot.glow:SetColor(1, 1, 1, 0.6)
		displaySlot.glow:SetBorderColor(1, 1, 1, 0.6)
		displaySlot.icon1:SetColor(eventData.killerColorR, eventData.killerColorG, eventData.killerColorB)
		displaySlot.label1:SetColor(eventData.killerColorR, eventData.killerColorG, eventData.killerColorB)
		displaySlot.label2:SetColor(eventData.victimColorR, eventData.victimColorG, eventData.victimColorB)

		
		displaySlot.label2:SetVisible(true)
		
		-- Format accordingly
		displaySlot.icon1:SetAlign('center')
		displaySlot.icon1:SetX(0)
		displaySlot.icon1:SetWidth('74@')
		displaySlot.icon1:SetHeight('74%')

		
		displaySlot.label2:SetWidth('12h')
		displaySlot.label2:SetX('-110@')
		displaySlot.label2:SetAlign('right')
		displaySlot.label2:SetTextAlign('right')
		
		displaySlot.label1:SetWidth('12h')
		displaySlot.label1:SetX('110@')
		displaySlot.label1:SetAlign('left')
		displaySlot.label1:SetTextAlign('left')
		
		displaySlot.label1:SetText(eventData.killerName)
		displaySlot.label2:SetText(eventData.victimName)
		
		-- displaySlot.label1:SetText('a a a a a a a a a a a a')
		-- displaySlot.label2:SetText('b b b b b b b b b b b b')
		
		FitFontToLabel(displaySlot.label1, nil, labelFontTable)
		FitFontToLabel(displaySlot.label2, nil, labelFontTable)
		
	end
	
	for i=1,maxDisplaySlots,1 do
		displaySlots[i] 	= {
			root			= object:GetGroup('gameEventEntry'..i),
			-- Body			= object:GetWidget('gameEventEntry'..i..'Body'),
			backer			= object:GetWidget('gameEventEntry'..i..'Backer'),
			backer2			= object:GetWidget('gameEventEntry'..i..'Backer2'),
			arrow			= object:GetWidget('gameEventEntry'..i..'Arrow'),
			icon1			= object:GetWidget('gameEventEntry'..i..'Icon1'),
			icon2			= object:GetWidget('gameEventEntry'..i..'Icon2'),
			icon3			= object:GetWidget('gameEventEntry'..i..'Icon3'),
			iconBorder1		= object:GetWidget('gameEventEntry'..i..'IconBorder1'),
			iconBorder2		= object:GetWidget('gameEventEntry'..i..'IconBorder2'),
			iconBorder3		= object:GetWidget('gameEventEntry'..i..'IconBorder3'),
			label1			= object:GetWidget('gameEventEntry'..i..'Label1'),
			label2			= object:GetWidget('gameEventEntry'..i..'Label2'),
			label3			= object:GetWidget('gameEventEntry'..i..'Label3'),
			glow			= object:GetWidget('gameEventEntry'..i..'Glow')
		}
		
		displayOrder[maxDisplaySlots - i + 1] = i
	end

	itemPadding	= libGeneral.HtoP(0.75)
	scrollStep	= libGeneral.HtoP(3.5) + itemPadding

	scrollPanel:SetCallback(
		'onmousewheeldown', function(widget)
			if scrollPosition < scrollPositionMax then
				scrollPosition = math.min(scrollPosition + 1, scrollPositionMax)
				scrollBar:SetValue(scrollPosition)
			end
		end
	)

	scrollPanel:SetCallback(
		'onmousewheelup', function(widget)
			if scrollPosition > 0 then
				scrollPosition = math.max(scrollPosition - 1, 0)
				scrollBar:SetValue(scrollPosition)
			end
		end
	)

	scrollBar:SetCallback(
		'onslide', function(widget)
			scrollPosition = AtoN(widget:GetValue())
			for k,v in pairs(contentBody) do
				v:SetY(
					(
						 (scrollPositionMax - scrollPosition) * scrollStep
					)
				)
			end

		end
	)

	eventsContainer:RegisterWatchLua('EventKill', function(widget, trigger)
		local displaySlot	= nil
		local killType		= trigger.killType -- ?

		--[[
		
			0 - HERO_KILL_NONE,
			1 - HERO_KILL_NORMAL,
			2 - HERO_KILL_END_STREAK,
			3 - HERO_KILL_HERO_DENY,
			4 - HERO_KILL_SUICIDE,
			5 - HERO_KILL_TEAM_KILL,
			6 - HERO_KILL_KONGOR_KILL,
			7 - HERO_KILL_NEUTRAL_KILL,
			8 - HERO_KILL_UNKNOWN_KILL,
		--]]
		
		if (killType ~= 1 and killType ~= 2) or not trigger_gamePanelInfo.mapWidgetVis_arcadeText then
			return
		end

		
		
		local killerName	= trigger.killerName 
		local victimName	= trigger.victimName
		local killerIsAlly	= trigger.killerIsAlly
		local victimIsAlly	= trigger.victimIsAlly
		local goldIncome	= trigger.playerGoldIncome
		
		-- local killerPlayerColor = trigger.killerPlayerColor
		local killerIcon = trigger.killerIcon
		local victimIcon = trigger.victimIcon
		-- local assists = trigger.assists

		local killerColorR = styles_eventEnemyColorR
		local killerColorG = styles_eventEnemyColorG
		local killerColorB = styles_eventEnemyColorB
		local victimColorR = styles_eventEnemyColorR
		local victimColorG = styles_eventEnemyColorG
		local victimColorB = styles_eventEnemyColorB
		if killerIsAlly then
			killerColorR = styles_eventAllyColorR
			killerColorG = styles_eventAllyColorG
			killerColorB = styles_eventAllyColorB
		end
		if victimIsAlly then
			victimColorR = styles_eventAllyColorR
			victimColorG = styles_eventAllyColorG
			victimColorB = styles_eventAllyColorB
		end
		
		displaySlot = tallyNewEntry()
		
		if displaySlot then
			populateDisplaySlotKill(
				displaySlot,
				{
					killerColorR		= killerColorR,
					killerColorG		= killerColorG,
					killerColorB		= killerColorB,
					victimColorR		= victimColorR,
					victimColorG		= victimColorG,
					victimColorB		= victimColorB,
					killerName			= killerName,
					killerIcon			= killerIcon,
					victimName			= victimName,
					victimIcon			= victimIcon,
					goldIncome			= goldIncome,
					enemyKill			= (not killerIsAlly)
				}
			)
		end
		

		--[[
		addEntry(
			function(slotID)
				displaySlots[slotID].Body:UICmd("ClearChildren()")
				displaySlots[slotID].Body:Instantiate(
					'gameEventEntryPlayerKill',
					'killerColor', killerColor,
					'victimColor', victimColor,
					'killerName', killerName,
					'victimName', victimName
				)
			end
		)
		--]]

	end)
	
	eventsContainer:RegisterWatchLua('EventBuildingKill', function(widget, trigger)
		if not trigger_gamePanelInfo.mapWidgetVis_arcadeText then
			return
		end
	
		local displaySlot		= nil
		
		local entityName		= trigger.entityName
		local ownerTeam			= trigger.ownerTeam
		--local attackerIndex	= trigger.attackerIndex
		--local attackerTeam	= trigger.attackerTeam 
		--local goldReward		= trigger.goldReward 
		local wasDenied			= trigger.wasDenied

		local teamIcon			= teamIcons[ownerTeam]
		local message			= ''
		local teamTrigger		= LuaTrigger.GetTrigger('Team')
		local userTeam			= teamTrigger.team
		local notifyColorR		= 1
		local notifyColorG		= 0
		local notifyColorB		= 0
		local backerColor				= '#4b2020'
		
		if ownerTeam ~= userTeam or (wasDenied and not isCaptureEntity(entityName)) then
			notifyColorR = 0
			notifyColorG = 1
			notifyColorB = 0
			backerColor					= '#204b2c'
		end
		
		if isTowerEntity(entityName) then
			if wasDenied then
				message = Translate('events_towerdenied')
			else
				message = Translate('events_towerdestroyed')
			end
		elseif isCaptureEntity(entityName) then
			message = Translate('events_outpostcaptured')
		elseif isBarracksEntity(entityName) then
			message = Translate('events_barracksdestroyed')
		elseif isRecaptureEntity(entityName) then
			message = Translate('events_outpostreclaimed')
		end
		
		displaySlot = tallyNewEntry()
		
		if displaySlot then
			populateDisplaySlotBuildingKill(
				displaySlot,
				{
					teamIcon	= teamIcon,
					message		= message,
					notifyColorR	= notifyColorR,
					notifyColorG	= notifyColorG,
					notifyColorB	= notifyColorB,
					backerColor		= backerColor
				}
			)
		end
		
		
		--[[
		addEntry(
			function(slotID)
				displaySlots[slotID].Body:UICmd("ClearChildren()")
				displaySlots[slotID].Body:Instantiate(
					'gameEventEntryBuildingKill',
					'teamIcon', teamIcon,
					'message', message,
					'notifyColor', notifyColor
				)
			end
		)
		--]]
	end)
	
	eventsContainer:RegisterWatchLua('EventBossKill', function(widget, trigger)
	
		if not trigger_gamePanelInfo.mapWidgetVis_arcadeText then
			return
		end
	
		local displaySlot		= nil
		
		local entityName		= trigger.entityName
		local ownerTeam			= trigger.ownerTeam
		--local attackerIndex	= trigger.attackerIndex
		local attackerTeam		= trigger.attackerTeam 
		--local goldReward		= trigger.goldReward 
		local wasDenied			= trigger.wasDenied

		local teamIcon			= teamIcons[attackerTeam]
		local message			= ''
		local teamTrigger		= LuaTrigger.GetTrigger('Team')
		local userTeam			= teamTrigger.team
		local notifyColorR		= 1
		local notifyColorG		= 0
		local notifyColorB		= 0
		local backerColor				= '#4b2020'
		
		if attackerTeam == userTeam then
			notifyColorR = 0
			notifyColorG = 1
			notifyColorB = 0
			backerColor					= '#204b2c'
		end
		
		message = Translate('events_defeated', 'entity', GetEntityDisplayName(entityName))
		
		displaySlot = tallyNewEntry()
		
		if displaySlot then
			populateDisplaySlotBuildingKill(
				displaySlot,
				{
					teamIcon	= teamIcon,
					message		= message,
					notifyColorR	= notifyColorR,
					notifyColorG	= notifyColorG,
					notifyColorB	= notifyColorB,
					backerColor		= backerColor
					
				}
			)
		end

	end)	
	
	eventsContainer:RegisterWatchLua('LanePushSet', function(widget, trigger)
		local displaySlot	= nil
		local entityName	= trigger.entityName
		local laneName		= trigger.laneName

		
		displaySlot = tallyNewEntry()
		
		local notifyColorR				= 1
		local notifyColorG				= 0
		local notifyColorB				= 0
		local backerColor				= '#4b2020'
		
		if trigger.friendly then
			notifyColorR				= 0
			notifyColorG				= 1
			notifyColorB				= 0		
			backerColor					= '#204b2c'
		end
		
		if displaySlot then
			populateDisplaySlotLaneChoice(
				displaySlot,
				{
					pusherIcon		= GetEntityIconPath(entityName),
					pushMessage		= Translate('game_lane_push'),
					notifyColorR		= notifyColorR,
					notifyColorG		= notifyColorG,
					notifyColorB		= notifyColorB,
					backerColor			= backerColor
				}
			)
		end

	end)
	
	-- eventsContainer:RegisterWatchLua('ItemPurchased', function(widget, trigger)

		-- displaySlot = tallyNewEntry()
		
		-- if displaySlot and ValidateEntity(trigger.entity) then
			-- populateDisplaySlotLaneChoice(
				-- displaySlot,
				-- {
					-- pusherIcon		= GetEntityIconPath(trigger.entity),
					-- pushMessage		= GetEntityDisplayName(trigger.entity)..'^w purchased',
					-- notifyColorR		= 1,
					-- notifyColorG		= 0.847,
					-- notifyColorB		= 0.239,
					-- backerColor			= '#47422c'
				-- }
			-- )
		-- else
			-- println('^r eventsContainer ItemPurchased error')
		-- end

	-- end)	
	
	-- eventsContainer:RegisterWatchLua('ItemSold', function(widget, trigger)

		-- displaySlot = tallyNewEntry()
		
		-- if displaySlot and ValidateEntity(trigger.entity) then
			-- populateDisplaySlotLaneChoice(
				-- displaySlot,
				-- {
					-- pusherIcon		= GetEntityIconPath(trigger.entity),
					-- pushMessage		= GetEntityDisplayName(trigger.entity)..'^w sold',
					-- notifyColorR		= 1,
					-- notifyColorG		= 0.847,
					-- notifyColorB		= 0.239,
					-- backerColor			= '#47422c'
				-- }
			-- )
		-- else
			-- println('^r eventsContainer ItemSold error')
		-- end

	-- end)		

	eventsContainer:RegisterWatchLua('gamePanelInfo', function(widget, trigger)
		widget:SetVisible(not trigger.gameMenuExpanded)
	end, false, nil, 'gameMenuExpanded')
	
	eventsContainer:RegisterWatch('chatHistoryVisible', function(widget, showChatHistory)
		viewHistory = AtoB(showChatHistory)
		if viewHistory then
			fadeInit()
			for i=1,maxDisplaySlots,1 do
				if displaySlotPopulated[i] then
					for k,v in pairs(displaySlots[i].root) do
						v:FadeIn(0)
						v:SetVisible(true)
					end

				end
			end
			updateScrolling()
		else
			for i=1,maxDisplaySlots,1 do
				if fadeTimes[i] then
					for k,v in pairs(displaySlots[i].root) do
						v:FadeIn(0)
						v:SetVisible(true)
					end
				else
					for k,v in pairs(displaySlots[i].root) do
						v:FadeOut(0)
						v:SetVisible(false)
					end
				end
			end
			updateScrolling()
			fadeInit()
		end
	end)
	
	scrollPosition = scrollPositionMax
	scrollBar:SetValue(scrollPosition)
	
	gameEventsRegister = nil
end
gameEventsRegister(object)

function ArcadeEventsRegister(object)

	if GetCvarBool('ui_hideArcadeText') then return end

	local arcadeEventsQueue = {{},{},{}}
	local nemesisStreakTable = {}
	
	-- EventKill EventmultiKill EventKillStreak EventFirstKill EventBuildingKill
	-- X out player name, show consecutive kills / domination
	
	gameEvents.selfAnnouncerFadeOutDelay = 4500
	gameEvents.announcerFadeOutDelay = 3200
	gameEvents.shortFade = 250
	gameEvents.longFade = 500
	
	local function ClearEventsQueue()
		arcadeEventsQueue = {{},{},{}}
	end
	interface:GetWidget('self_center_announcements_0'):RegisterWatchLua('GameReinitialize', ClearEventsQueue)
	
	function SelfArcadeEventKill(trigger, isDelayed)
		
		if ((trigger.killType ~= 1) and (trigger.killType ~= 2)) or (not trigger_gamePanelInfo.mapWidgetVis_arcadeText) then
			return
		end
		
		-- local didSelfAssist = false
		-- local assistsTable1 = explode('|', trigger.assists)
		-- local assistsTable2 = {}
		-- for i, v in ipairs(assistsTable1) do
			-- assistsTable2[i] = explode(':', v)
			-- if IsMe(assistsTable2[i][1]) then
				-- didSelfAssist = true
			-- end
		-- end
		
		if (trigger.killerIsSelf) then
			
			local selfAnnouncerFadeOutDelay = gameEvents.selfAnnouncerFadeOutDelay

			if (isDelayed) then
				selfAnnouncerFadeOutDelay = gameEvents.selfAnnouncerFadeOutDelay - 1000 -- delayed events play faster
			else
				if  (Shop.GetVisible()) then
					return
				elseif (#arcadeEventsQueue[1] ~= 0) then
					table.insert(arcadeEventsQueue[1], {1, trigger})
					return
				else
					table.insert(arcadeEventsQueue[1], {1, trigger})
				end
			end
			
			if (nemesisStreakTable[trigger.victimName..trigger.victimTypeName]) then
				nemesisStreakTable[trigger.victimName..trigger.victimTypeName] = nemesisStreakTable[trigger.victimName..trigger.victimTypeName] + 1 
			else
				nemesisStreakTable[trigger.victimName..trigger.victimTypeName] = 1
			end
			
			interface:GetWidget('self_center_announcements_0'):SetVisible(1)
			
			-- killer and killed
			interface:GetWidget('self_center_announcements_0_line_1'):FadeIn(gameEvents.shortFade)
			interface:GetWidget('self_center_announcements_0_line_1_icon_1'):SetTexture(trigger.killerIcon)
			interface:GetWidget('self_center_announcements_0_line_1_icon_2'):SetTexture(trigger.victimIcon)
			interface:GetWidget('self_center_announcements_0_line_1_parent_1'):SetColor('0 1 0 0.7')
			interface:GetWidget('self_center_announcements_0_line_1_parent_2'):SetColor('1 0 0 0.7')
			interface:GetWidget('self_center_announcements_0_line_1_label_1'):SetText(Translate('events_hasslain', 'entity', trigger.killerName))
			
			-- X out and ( RMM domination animation here)
			interface:GetWidget('self_center_announcements_0_line_1_icon_2_x_1'):Sleep(250, function()
				interface:GetWidget('self_center_announcements_0_line_1_icon_2_x_1'):SetVisible(1)
				interface:GetWidget('self_center_announcements_0_line_1_icon_2_x_1'):SetHeight(0)
				interface:GetWidget('self_center_announcements_0_line_1_icon_2_x_1'):SetWidth(0)
				interface:GetWidget('self_center_announcements_0_line_1_icon_2_x_1'):Scale('100%', '100%', 250, true)
				interface:GetWidget('self_center_announcements_0_line_1_icon_2_x_1'):Sleep(selfAnnouncerFadeOutDelay - 500, function()
					interface:GetWidget('self_center_announcements_0_line_1_icon_2_x_1'):FadeOut(500)
				end)				
			end)
			
			interface:GetWidget('self_center_announcements_0_line_1_icon_2_x_2'):Sleep(250, function()
				interface:GetWidget('self_center_announcements_0_line_1_icon_2_x_2'):SetVisible(1)
				interface:GetWidget('self_center_announcements_0_line_1_icon_2_x_2'):SetHeight(0)
				interface:GetWidget('self_center_announcements_0_line_1_icon_2_x_2'):SetWidth(0)
				interface:GetWidget('self_center_announcements_0_line_1_icon_2_x_2'):Sleep(250, function()
					if (nemesisStreakTable[trigger.victimName..trigger.victimTypeName]) and (nemesisStreakTable[trigger.victimName..trigger.victimTypeName] > 1) then
						interface:GetWidget('self_center_announcements_0_line_1_label_2'):FadeIn(500)
						interface:GetWidget('self_center_announcements_0_line_1_label_2'):SetText('x' .. nemesisStreakTable[trigger.victimName..trigger.victimTypeName] )
					end
					interface:GetWidget('self_center_announcements_0_line_1_icon_2_x_2'):Scale('100%', '100%', 250, true)	
					interface:GetWidget('self_center_announcements_0_line_1_icon_2_x_2'):Sleep(selfAnnouncerFadeOutDelay - 750, function()
						interface:GetWidget('self_center_announcements_0_line_1_icon_2_x_2'):FadeOut(500)
						interface:GetWidget('self_center_announcements_0_line_1_label_2'):FadeOut(500)
					end)
				end)
			end)
			
			-- multiKill icons
			if (trigger.multiKill) and (trigger.multiKill >= 2) and (not Empty(trigger.multiKillHeroes)) and (false) then	
				
				local victimTable = explode('|', trigger.multiKillHeroes)
				-- local victimTable = {}
				-- for i=#victimTable2, 1, -1 do
					-- table.insert(victimTable, victimTable2[i])
				-- end
				
				
				if (victimTable[1]) and (GetEntityIconPath(victimTable[1])) then
				
					interface:GetWidget('self_center_announcements_0_line_2'):FadeIn(gameEvents.longFade)
					
					if (trigger.multiKill >= 2) and (GetEntityIconPath(victimTable[1])) then
						interface:GetWidget('self_center_announcements_0_line_2_icon_parent_1'):SetVisible(1)
						interface:GetWidget('self_center_announcements_0_line_2_icon_1'):SetTexture(GetEntityIconPath(victimTable[1]))
					else
						interface:GetWidget('self_center_announcements_0_line_2_icon_parent_1'):SetVisible(0)
					end
					
					if (trigger.multiKill >= 3) and (GetEntityIconPath(victimTable[2])) then
						interface:GetWidget('self_center_announcements_0_line_2_icon_parent_2'):SetVisible(1)
						interface:GetWidget('self_center_announcements_0_line_2_icon_2'):SetTexture(GetEntityIconPath(victimTable[2]))
						interface:GetWidget('self_center_announcements_0_line_2_spacer_1'):SetVisible(1)
					else
						interface:GetWidget('self_center_announcements_0_line_2_icon_parent_2'):SetVisible(0)
						interface:GetWidget('self_center_announcements_0_line_2_spacer_1'):SetVisible(0)
					end				
					
					if (trigger.multiKill >= 4) and (GetEntityIconPath(victimTable[3])) then
						interface:GetWidget('self_center_announcements_0_line_2_icon_parent_3'):SetVisible(1)
						interface:GetWidget('self_center_announcements_0_line_2_icon_3'):SetTexture(GetEntityIconPath(victimTable[3]))
						interface:GetWidget('self_center_announcements_0_line_2_spacer_2'):SetVisible(1)
					else
						interface:GetWidget('self_center_announcements_0_line_2_icon_parent_3'):SetVisible(0)
						interface:GetWidget('self_center_announcements_0_line_2_spacer_2'):SetVisible(0)
					end					
				
					if (trigger.multiKill >= 5) and (GetEntityIconPath(victimTable[4])) then
						interface:GetWidget('self_center_announcements_0_line_2_icon_parent_4'):SetVisible(1)
						interface:GetWidget('self_center_announcements_0_line_2_icon_4'):SetTexture(GetEntityIconPath(victimTable[4]))
						interface:GetWidget('self_center_announcements_0_line_2_spacer_3'):SetVisible(1)
					else
						interface:GetWidget('self_center_announcements_0_line_2_icon_parent_4'):SetVisible(0)
						interface:GetWidget('self_center_announcements_0_line_2_spacer_3'):SetVisible(0)
					end	
				else
					interface:GetWidget('self_center_announcements_0_line_2'):SetVisible(0)
				end
			else
				interface:GetWidget('self_center_announcements_0_line_2'):SetVisible(0)
			end
			
			interface:GetWidget('self_center_announcements_0_sleeper'):Sleep(selfAnnouncerFadeOutDelay * 0.30, function()
				
				-- streak and gold
				interface:GetWidget('self_center_announcements_0_line_3'):FadeIn(gameEvents.longFade)
				
				-- streak
				if (trigger.firstBlood) and ((trigger.killerIsAlly) or (trigger.killerIsSelf)) then	
					interface:GetWidget('self_center_announcements_0_line_3_a'):SetVisible(1)
					interface:GetWidget('self_center_announcements_0_line_3_label_1'):SetAlign('center')
					interface:GetWidget('self_center_announcements_0_line_3_label_1'):SetText(Translate('game_firstblood'))					
				elseif (trigger.multiKill >= 2) and ((trigger.killerIsAlly) or (trigger.killerIsSelf)) then	
					interface:GetWidget('self_center_announcements_0_line_3_a'):SetVisible(1)
					interface:GetWidget('self_center_announcements_0_line_3_label_1'):SetAlign('center')
					interface:GetWidget('self_center_announcements_0_line_3_label_1'):SetText(Translate('game_multikill_announcer_' .. trigger.multiKill))			
				elseif (trigger.killStreak >= 3) and (trigger.killerIsSelf) then	
					interface:GetWidget('self_center_announcements_0_line_3_a'):SetVisible(1)
					interface:GetWidget('self_center_announcements_0_line_3_label_1'):SetAlign('center')
					interface:GetWidget('self_center_announcements_0_line_3_label_1'):SetText(Translate('game_streak_announcer_x', 'value', trigger.killStreak))					
				else
					interface:GetWidget('self_center_announcements_0_line_3_a'):SetVisible(0)
					interface:GetWidget('self_center_announcements_0_line_3_label_1'):SetAlign('left')
					interface:GetWidget('self_center_announcements_0_line_3_label_1'):SetText('')				
				end
				
				interface:GetWidget('self_center_announcements_0_line_3_label_2'):UnregisterWatchLua('EventGeneratorGold')
				interface:GetWidget('self_center_announcements_0_line_3_label_2'):UnregisterWatchLua('EventTowerGold')
				interface:GetWidget('self_center_announcements_0_line_3_label_2'):UnregisterWatchLua('EventBossGold')
				interface:GetWidget('self_center_announcements_0_line_3_label_2'):UnregisterWatchLua('EventHeroGold')					
			
				-- gold
				if (trigger.playerGoldIncome) and (trigger.playerGoldIncome > 0) then
					interface:GetWidget('self_center_announcements_0_line_3_b'):SetVisible(1)
					-- interface:GetWidget('self_center_announcements_0_line_3_label_2'):RegisterWatchLua('EventHeroGold', function(widget, trigger2) widget:SetText('+' .. trigger2.gold) end)
					-- interface:GetWidget('self_center_announcements_0_line_3_label_2'):SetText('+' .. LuaTrigger.GetTrigger('EventHeroGold').gold)						
					interface:GetWidget('self_center_announcements_0_line_3_label_2'):SetText('+' .. trigger.playerGoldIncome)						
				else
					interface:GetWidget('self_center_announcements_0_line_3_b'):SetVisible(0)
				end
				
				interface:GetWidget('self_center_announcements_0_sleeper'):Sleep(selfAnnouncerFadeOutDelay * 0.70, function()
					interface:GetWidget('self_center_announcements_0'):FadeOut(gameEvents.longFade)
					interface:GetWidget('self_center_announcements_0_line_1'):FadeOut(gameEvents.longFade)
					interface:GetWidget('self_center_announcements_0_line_2'):FadeOut(gameEvents.longFade)
					interface:GetWidget('self_center_announcements_0_line_3'):FadeOut(gameEvents.shortFade)
					interface:GetWidget('self_center_announcements_0_line_3_a'):FadeOut(gameEvents.shortFade)
					interface:GetWidget('self_center_announcements_0_line_1_label_2'):FadeOut(gameEvents.shortFade)
					interface:GetWidget('self_center_announcements_0_sleeper'):Sleep(gameEvents.longFade + 500, function()
						table.remove(arcadeEventsQueue[1], 1)
						if (#arcadeEventsQueue[1] ~= 0) then
							if (arcadeEventsQueue[1][1][1] == 4) then
								SelfArcadeEventRespawn(arcadeEventsQueue[1][1][2], true)						
							elseif (arcadeEventsQueue[1][1][1] == 3) then
								SelfArcadeEventPusher(arcadeEventsQueue[1][1][2], true)
							else
								SelfArcadeEventKill(arcadeEventsQueue[1][1][2], true)
							end
							return
						end					
					end)
					
				end)
			end)
		end

	end
	
	interface:GetWidget('self_center_announcements_0'):RegisterWatchLua('HeroUnit', function(widget, trigger)	
		if (not trigger.isActive) then
			nemesisStreakTable = {}
		end
	end, false, nil, 'isActive')	

	interface:GetWidget('self_center_announcements_0'):RegisterWatchLua('EventKill', function(widget, trigger)
		SelfArcadeEventKill(trigger, false)
	end)	
	
	function SelfArcadeEventPusher(trigger, isDelayed)
	
		if (not trigger.name) or Empty(trigger.name) or (not GetEntityIconPath(trigger.name)) or (not (trigger.status == 1)) then
			return
		end
		
		local selfAnnouncerFadeOutDelay = gameEvents.selfAnnouncerFadeOutDelay

		if (isDelayed) then
			selfAnnouncerFadeOutDelay = gameEvents.selfAnnouncerFadeOutDelay - 1000 -- delayed events play faster
		else
			if  (Shop.GetVisible()) then
				return
			elseif (#arcadeEventsQueue[1] ~= 0) then
				table.insert(arcadeEventsQueue[1], {3, trigger})
				return
			else
				table.insert(arcadeEventsQueue[1], {3, trigger})
			end
		end
		
		interface:GetWidget('self_center_announcements_0'):SetVisible(1)
		
		interface:GetWidget('self_center_announcements_0_line_1'):FadeIn(gameEvents.shortFade)
		interface:GetWidget('self_center_announcements_0_line_1_icon_1'):SetTexture(GetEntityIconPath(trigger.name))
		interface:GetWidget('self_center_announcements_0_line_1_icon_2'):SetTexture('$invis')
		interface:GetWidget('self_center_announcements_0_line_1_parent_1'):SetColor('0 1 0 0')
		interface:GetWidget('self_center_announcements_0_line_1_parent_2'):SetColor('1 0 0 0')		
		
		local LanePushSet = LuaTrigger.GetTrigger('LanePushSet')
		local laneName	  = LanePushSet.laneName
		
		if (GetEntityDisplayName(trigger.name)) then
			interface:GetWidget('self_center_announcements_0_line_1_label_1'):SetText(
				Translate('events_pusherispushing', 'pusher', GetEntityDisplayName(trigger.name), 'lane', (fullLaneNames[laneName] or laneName or '?lane?'))
			)
		end
		
		interface:GetWidget('self_center_announcements_0_sleeper'):Sleep(selfAnnouncerFadeOutDelay, function()
			
			interface:GetWidget('self_center_announcements_0'):FadeOut(gameEvents.longFade)
			interface:GetWidget('self_center_announcements_0_line_1'):FadeOut(gameEvents.longFade)
			interface:GetWidget('self_center_announcements_0_line_2'):FadeOut(gameEvents.longFade)
			interface:GetWidget('self_center_announcements_0_line_3'):FadeOut(gameEvents.shortFade)
			
			interface:GetWidget('self_center_announcements_0_sleeper'):Sleep(gameEvents.longFade + 500, function()
				table.remove(arcadeEventsQueue[1], 1)
				if (#arcadeEventsQueue[1] ~= 0) then
					if (arcadeEventsQueue[1][1][1] == 4) then
						SelfArcadeEventRespawn(arcadeEventsQueue[1][1][2], true)				
					elseif (arcadeEventsQueue[1][1][1] == 3) then
						SelfArcadeEventPusher(arcadeEventsQueue[1][1][2], true)
					else
						SelfArcadeEventKill(arcadeEventsQueue[1][1][2], true)
					end
					return
				end					
			end)	

		end)
	
	end
	
	interface:GetWidget('self_center_announcements_0'):RegisterWatchLua('LanePushers0', function(widget, trigger)
		SelfArcadeEventPusher(trigger, false)
	end)
	
	function SelfArcadeEventRespawn(trigger, isDelayed)
	
		local selfAnnouncerFadeOutDelay = gameEvents.selfAnnouncerFadeOutDelay / 1.6

		if (isDelayed) then
			selfAnnouncerFadeOutDelay = gameEvents.selfAnnouncerFadeOutDelay - 1000 -- delayed events play faster
		else
			if  (Shop.GetVisible()) then
				return
			elseif (#arcadeEventsQueue[1] ~= 0) then
				table.insert(arcadeEventsQueue[1], {4, trigger})
				return
			else
				table.insert(arcadeEventsQueue[1], {4, trigger})
			end
		end
		
		interface:GetWidget('self_center_announcements_0'):SetVisible(1)
		
		interface:GetWidget('self_center_announcements_0_line_1'):FadeIn(gameEvents.shortFade)
		interface:GetWidget('self_center_announcements_0_line_1_icon_1'):SetTexture(trigger.iconPath)
		interface:GetWidget('self_center_announcements_0_line_1_icon_2'):SetTexture('$invis')
		interface:GetWidget('self_center_announcements_0_line_1_parent_1'):SetColor('0 1 0 1')
		interface:GetWidget('self_center_announcements_0_line_1_parent_2'):SetColor('1 0 0 0')		
		
		if (trigger.isActive) then
			interface:GetWidget('self_center_announcements_0_line_1_label_1'):SetText(Translate('events_respawned'))
		else
			interface:GetWidget('self_center_announcements_0_line_1_label_1'):SetText(Translate('events_died'))
		end
		
		interface:GetWidget('self_center_announcements_0_sleeper'):Sleep(selfAnnouncerFadeOutDelay, function()
			
			interface:GetWidget('self_center_announcements_0'):FadeOut(gameEvents.longFade)
			interface:GetWidget('self_center_announcements_0_line_1'):FadeOut(gameEvents.longFade)
			interface:GetWidget('self_center_announcements_0_line_2'):FadeOut(gameEvents.longFade)
			interface:GetWidget('self_center_announcements_0_line_3'):FadeOut(gameEvents.shortFade)
			
			interface:GetWidget('self_center_announcements_0_sleeper'):Sleep(gameEvents.longFade + 500, function()
				table.remove(arcadeEventsQueue[1], 1)
				if (#arcadeEventsQueue[1] ~= 0) then
					if (arcadeEventsQueue[1][1][1] == 4) then
						SelfArcadeEventRespawn(arcadeEventsQueue[1][1][2], true)
					elseif (arcadeEventsQueue[1][1][1] == 3) then
						SelfArcadeEventPusher(arcadeEventsQueue[1][1][2], true)
					else
						SelfArcadeEventKill(arcadeEventsQueue[1][1][2], true)
					end
					return
				end					
			end)	

		end)
	
	end	
	
	local playerWasDead = false
	interface:GetWidget('self_center_announcements_0'):RegisterWatchLua('HeroUnit', function(widget, trigger)	-- Death and Respawn
		if (trigger.isActive) then	
			if (not trigger.isOnScreen) and (playerWasDead) then
				SelfArcadeEventRespawn(trigger, false)
			end
			playerWasDead = false
		else
			-- if (not playerWasDead) then
				-- SelfArcadeEventRespawn(trigger, false)
			-- end		
			playerWasDead = true
		end
	end, true, nil, 'isActive')
	
	interface:GetWidget('self_center_announcements_0'):RegisterWatchLua('gamePanelInfo', function(widget, trigger)		
		if (trigger.moreInfoKey) or (trigger.orbExpanded) or (trigger.orbExpandedPinned) then
			widget:SlideY('20.1h', 125)
			widget:Sleep(125, function()
				widget:SetY('20.1h')
			end)			
		else
			widget:SlideY('15.5h', 125)
			widget:Sleep(125, function()
				widget:SetY('15.5h')
			end)
		end
	end, false, nil, 'moreInfoKey', 'orbExpanded', 'orbExpandedPinned')
	
	function Side1ArcadeEventKill(trigger, isDelayed)
		if ((trigger.killType ~= 1) and (trigger.killType ~= 2)) or not trigger_gamePanelInfo.mapWidgetVis_arcadeText then
			return
		end
		
		if (not trigger.killerIsAlly) or (trigger.killerIsSelf) then
			return
		end	
		
		local team = LuaTrigger.GetTrigger('Team').team

		if (trigger.killerTeam == team or team == 0) and (not trigger.killerIsSelf) then
			
			local announcerFadeOutDelay = gameEvents.announcerFadeOutDelay

			if (isDelayed) then
				announcerFadeOutDelay = gameEvents.announcerFadeOutDelay - 1000 -- delayed events play faster
			else
				if  (Shop.GetVisible()) then
					return
				elseif (#arcadeEventsQueue[2] ~= 0) then
					table.insert(arcadeEventsQueue[2], {1, trigger})
					return
				else
					table.insert(arcadeEventsQueue[2], {1, trigger})
				end
			end			
			
			interface:GetWidget('game_team_announcements_1'):SetVisible(1)
			
			interface:GetWidget('game_team_announcements_1_line_1'):FadeIn(gameEvents.shortFade)
			interface:GetWidget('game_team_announcements_1_line_1_icon_1'):SetTexture(trigger.killerIcon)
			interface:GetWidget('game_team_announcements_1_line_1_icon_2'):SetTexture(trigger.victimIcon)
			if (trigger.killerIsAlly) then
				interface:GetWidget('game_team_announcements_1_line_1_icon_parent_1'):SetColor('0 1 0 0.7')
				interface:GetWidget('game_team_announcements_1_line_1_icon_parent_2'):SetColor('1 0 0 0.7')
			else
				interface:GetWidget('game_team_announcements_1_line_1_icon_parent_2'):SetColor('0 1 0 0.7')
				interface:GetWidget('game_team_announcements_1_line_1_icon_parent_1'):SetColor('1 0 0 0.7')			
			end	
			interface:GetWidget('game_team_announcements_1_line_1_label_1'):SetText(Translate('events_hasslain', 'entity', trigger.killerName))

			interface:GetWidget('game_team_announcements_1_sleeper'):Sleep(announcerFadeOutDelay * 0.30, function()
			
				interface:GetWidget('game_team_announcements_1_line_3'):FadeIn(gameEvents.longFade)
		
				-- streak
				if (trigger.multiKill >= 2) and ((trigger.killerIsAlly) or (trigger.killerIsSelf)) then	
					interface:GetWidget('game_team_announcements_1_line_3_a'):SetVisible(1)
					interface:GetWidget('game_team_announcements_1_line_3_label_1'):SetAlign('center')
					interface:GetWidget('game_team_announcements_1_line_3_label_1'):SetText(Translate('game_multikill_announcer_' .. trigger.multiKill))			
				elseif (trigger.killStreak >= 3) and (trigger.killerIsSelf) then	
					interface:GetWidget('game_team_announcements_1_line_3_a'):SetVisible(1)
					interface:GetWidget('game_team_announcements_1_line_3_label_1'):SetAlign('center')
					interface:GetWidget('game_team_announcements_1_line_3_label_1'):SetText(Translate('game_streak_announcer_x', 'value', trigger.killStreak))					
				else
					interface:GetWidget('game_team_announcements_1_line_3_a'):SetVisible(0)
					interface:GetWidget('game_team_announcements_1_line_3_label_1'):SetAlign('left')
					interface:GetWidget('game_team_announcements_1_line_3_label_1'):SetText('')				
				end
				

				interface:GetWidget('game_team_announcements_1_line_3_label_2'):UnregisterWatchLua('EventGeneratorGold')
				interface:GetWidget('game_team_announcements_1_line_3_label_2'):UnregisterWatchLua('EventTowerGold')
				interface:GetWidget('game_team_announcements_1_line_3_label_2'):UnregisterWatchLua('EventBossGold')
				interface:GetWidget('game_team_announcements_1_line_3_label_2'):UnregisterWatchLua('EventHeroGold')				
				
				if (team == trigger.killerTeam) and (trigger.playerGoldIncome > 0) then
					interface:GetWidget('game_team_announcements_1_line_3'):FadeIn(gameEvents.longFade)
					-- gold
					interface:GetWidget('game_team_announcements_1_line_3_b'):SetVisible(1)
					
					-- interface:GetWidget('game_team_announcements_1_line_3_label_2'):RegisterWatchLua('EventHeroGold', function(widget, trigger2) widget:SetText('+' .. trigger2.gold) end)
					-- interface:GetWidget('game_team_announcements_1_line_3_label_2'):SetText('+' .. LuaTrigger.GetTrigger('EventHeroGold').gold)						
					interface:GetWidget('game_team_announcements_1_line_3_label_2'):SetText('Assist +' .. trigger.playerGoldIncome)						
				else
					interface:GetWidget('game_team_announcements_1_line_3_b'):SetVisible(0)
				end				

				
				interface:GetWidget('game_team_announcements_1_sleeper'):Sleep(announcerFadeOutDelay * 0.70, function()
					interface:GetWidget('game_team_announcements_1'):FadeOut(gameEvents.longFade)
					interface:GetWidget('game_team_announcements_1_line_1'):FadeOut(gameEvents.longFade)
					interface:GetWidget('game_team_announcements_1_line_3'):FadeOut(gameEvents.shortFade)
					interface:GetWidget('game_team_announcements_1_line_3_a'):FadeOut(gameEvents.shortFade)
					
					interface:GetWidget('game_team_announcements_1'):Sleep(gameEvents.longFade + 500, function()
						table.remove(arcadeEventsQueue[2], 1)
						if (#arcadeEventsQueue[2] ~= 0) then
							if (arcadeEventsQueue[2][1][1] == 2) then
								Side1ArcadeEventBuildingKill(arcadeEventsQueue[2][1][2], true)
							else
								Side1ArcadeEventKill(arcadeEventsQueue[2][1][2], true)
							end
							return
						end					
					end)					
					
				end)
			end)
		end

	end	
	
	interface:GetWidget('game_team_announcements_1'):RegisterWatchLua('EventKill', function(widget, trigger)	
		Side1ArcadeEventKill(trigger, false)
	end)	
	
	function Side1ArcadeEventBuildingKill(trigger, isDelayed, isBoss)
		
		local team = LuaTrigger.GetTrigger('Team').team
		
		if (not trigger_gamePanelInfo.mapWidgetVis_arcadeText) or ((not isBoss) and (not isTowerEntity(trigger.entityName)) and (not isBarracksEntity(trigger.entityName))) then
			return
		end
		
		if (not trigger.killerIsAlly) and (not trigger.killerIsSelf) then
			return
		end
		
		local announcerFadeOutDelay = gameEvents.announcerFadeOutDelay

		if (isDelayed) then
			announcerFadeOutDelay = gameEvents.announcerFadeOutDelay - 1000 -- delayed events play faster
		else
			if  (Shop.GetVisible()) then
				return
			elseif (#arcadeEventsQueue[2] ~= 0) then
				table.insert(arcadeEventsQueue[2], {2, trigger})
				return
			else
				table.insert(arcadeEventsQueue[2], {2, trigger})
			end
		end		

		interface:GetWidget('game_team_announcements_1'):SetVisible(1)
		
		interface:GetWidget('game_team_announcements_1_line_1'):FadeIn(gameEvents.shortFade)
		interface:GetWidget('game_team_announcements_1_line_1_icon_1'):SetTexture('$invis')
		interface:GetWidget('game_team_announcements_1_line_1_icon_2'):SetTexture(GetEntityIconPath(trigger.entityName))
		if (team == trigger.attackerTeam) then
			interface:GetWidget('game_team_announcements_1_line_1_icon_parent_1'):SetColor('0 1 0 0.0')
			interface:GetWidget('game_team_announcements_1_line_1_icon_parent_2'):SetColor('1 0 0 0.7')
		else
			interface:GetWidget('game_team_announcements_1_line_1_icon_parent_2'):SetColor('0 1 0 0.7')
			interface:GetWidget('game_team_announcements_1_line_1_icon_parent_1'):SetColor('1 0 0 0.0')			
		end	
		
		local displayName = GetEntityDisplayName(trigger.entityName) or trigger.entityName
		if (isBoss) then
			interface:GetWidget('game_team_announcements_1_line_1_label_1'):SetText(Translate('events_defeated', 'entity', displayName))
		else
			interface:GetWidget('game_team_announcements_1_line_1_label_1'):SetText(Translate('events_destroyed', 'entity', displayName))
		end
		
		interface:GetWidget('game_team_announcements_1_sleeper'):Sleep(announcerFadeOutDelay * 0.30, function()
			
			if (LuaTrigger.GetTrigger('EventHeroGold')) then
				interface:GetWidget('game_team_announcements_1_line_3_label_2'):UnregisterWatchLua('EventGeneratorGold')
				interface:GetWidget('game_team_announcements_1_line_3_label_2'):UnregisterWatchLua('EventBossGold')
				interface:GetWidget('game_team_announcements_1_line_3_label_2'):UnregisterWatchLua('EventTowerGold')
				interface:GetWidget('game_team_announcements_1_line_3_label_2'):UnregisterWatchLua('EventHeroGold')
				
				if (team == trigger.attackerTeam or team == 0) then
					interface:GetWidget('game_team_announcements_1_line_3'):FadeIn(gameEvents.longFade)
					-- gold
					interface:GetWidget('game_team_announcements_1_line_3_b'):SetVisible(1)
					
					if (isBoss) then
						interface:GetWidget('game_team_announcements_1_line_3_label_2'):RegisterWatchLua('EventBossGold', function(widget, trigger2) widget:SetText('+' .. trigger2.gold) end)
						interface:GetWidget('game_team_announcements_1_line_3_label_2'):SetText('+' .. LuaTrigger.GetTrigger('EventBossGold').gold)					
					elseif isTowerEntity(trigger.entityName) then
						interface:GetWidget('game_team_announcements_1_line_3_label_2'):RegisterWatchLua('EventTowerGold', function(widget, trigger2) widget:SetText('+' .. trigger2.gold) end)
						interface:GetWidget('game_team_announcements_1_line_3_label_2'):SetText('+' .. LuaTrigger.GetTrigger('EventTowerGold').gold)
					else
						interface:GetWidget('game_team_announcements_1_line_3_label_2'):RegisterWatchLua('EventGeneratorGold', function(widget, trigger2) widget:SetText('+' .. trigger2.gold) end)
						interface:GetWidget('game_team_announcements_1_line_3_label_2'):SetText('+' .. LuaTrigger.GetTrigger('EventGeneratorGold').gold)
					end
				else
					interface:GetWidget('game_team_announcements_1_line_3_b'):SetVisible(0)
				end
			end
			
			interface:GetWidget('game_team_announcements_1_sleeper'):Sleep(announcerFadeOutDelay * 0.70, function()
				interface:GetWidget('game_team_announcements_1'):FadeOut(gameEvents.longFade)
				interface:GetWidget('game_team_announcements_1_line_1'):FadeOut(gameEvents.longFade)
				interface:GetWidget('game_team_announcements_1_line_3'):FadeOut(gameEvents.shortFade)
				interface:GetWidget('game_team_announcements_1_line_3_b'):FadeOut(gameEvents.shortFade)
				
				interface:GetWidget('game_team_announcements_1'):Sleep(gameEvents.longFade + 500, function()
					table.remove(arcadeEventsQueue[2], 1)
					if (#arcadeEventsQueue[2] ~= 0) then
						if (arcadeEventsQueue[2][1][1] == 2) then
							Side1ArcadeEventBuildingKill(arcadeEventsQueue[2][1][2], true)
						else
							Side1ArcadeEventKill(arcadeEventsQueue[2][1][2], true)
						end
						return
					end					
				end)					
				
			end)
		end)
	end		

	interface:GetWidget('game_team_announcements_1'):RegisterWatchLua('EventBuildingKill', function(widget, trigger)	
		Side1ArcadeEventBuildingKill(trigger, false, false)
	end)	

	interface:GetWidget('game_team_announcements_1'):RegisterWatchLua('EventBossKill', function(widget, trigger)	
		Side1ArcadeEventBuildingKill(trigger, false, true)
	end)	

	interface:GetWidget('game_team_announcements_1'):RegisterWatchLua('gamePanelInfo', function(widget, trigger)
		if (trigger.moreInfoKey) or (trigger.unitFramesPinned) then
			widget:SlideY('12.6h', 125)
			widget:Sleep(125, function()
				widget:SetY('12.6h')
			end)			
		else
			widget:SlideY('8.6h', 125)
			widget:Sleep(125, function()
				widget:SetY('8.6h')
			end)
		end
	end, false, nil, 'moreInfoKey', 'unitFramesPinned')
	
	function Side2ArcadeEventKill(trigger, isDelayed)

		if ((trigger.killType ~= 1) and (trigger.killType ~= 2)) or not trigger_gamePanelInfo.mapWidgetVis_arcadeText then
			return
		end

		if (trigger.killerIsAlly) or (trigger.killerIsSelf) then
			return
		end
		
		local team = LuaTrigger.GetTrigger('Team').team
		
		if (trigger.killerTeam ~= team) and (not trigger.killerIsSelf) then
			
			local announcerFadeOutDelay = gameEvents.announcerFadeOutDelay

			if (isDelayed) then
				announcerFadeOutDelay = gameEvents.announcerFadeOutDelay - 1000 -- delayed events play faster
			else
				if  (Shop.GetVisible()) then
					return
				elseif (#arcadeEventsQueue[3] ~= 0) then
					table.insert(arcadeEventsQueue[3], {1, trigger})
					return
				else
					table.insert(arcadeEventsQueue[3], {1, trigger})
				end
			end				
			
			interface:GetWidget('game_team_announcements_2'):SetVisible(1)
			
			interface:GetWidget('game_team_announcements_2_line_1'):FadeIn(gameEvents.shortFade)
			interface:GetWidget('game_team_announcements_2_line_1_icon_1'):SetTexture(trigger.killerIcon)
			interface:GetWidget('game_team_announcements_2_line_1_icon_2'):SetTexture(trigger.victimIcon)
			if (trigger.killerIsAlly) then
				interface:GetWidget('game_team_announcements_2_line_1_icon_parent_1'):SetColor('0 1 0 0.7')
				interface:GetWidget('game_team_announcements_2_line_1_icon_parent_2'):SetColor('1 0 0 0.7')
			else
				interface:GetWidget('game_team_announcements_2_line_1_icon_parent_2'):SetColor('0 1 0 0.7')
				interface:GetWidget('game_team_announcements_2_line_1_icon_parent_1'):SetColor('1 0 0 0.7')			
			end
			interface:GetWidget('game_team_announcements_2_line_1_label_1'):SetText(Translate('events_hasslain', 'entity', trigger.killerName))
			
			
			interface:GetWidget('game_team_announcements_2_sleeper'):Sleep(announcerFadeOutDelay * 0.30, function()
			
				interface:GetWidget('game_team_announcements_2_line_3'):FadeIn(gameEvents.longFade)
		
				-- streak
				if (trigger.multiKill >= 2) and ((trigger.killerIsAlly) or (trigger.killerIsSelf)) then	
					interface:GetWidget('game_team_announcements_2_line_3_a'):SetVisible(1)
					interface:GetWidget('game_team_announcements_2_line_3_label_1'):SetAlign('center')
					interface:GetWidget('game_team_announcements_2_line_3_label_1'):SetText(Translate('game_multikill_announcer_' .. trigger.multiKill))			
				elseif (trigger.killStreak >= 3) and (trigger.killerIsSelf) then	
					interface:GetWidget('game_team_announcements_2_line_3_a'):SetVisible(1)
					interface:GetWidget('game_team_announcements_2_line_3_label_1'):SetAlign('center')
					interface:GetWidget('game_team_announcements_2_line_3_label_1'):SetText(Translate('game_streak_announcer_x', 'value', trigger.killStreak))					
				else
					interface:GetWidget('game_team_announcements_2_line_3_a'):SetVisible(0)
					interface:GetWidget('game_team_announcements_2_line_3_label_1'):SetAlign('left')
					interface:GetWidget('game_team_announcements_2_line_3_label_1'):SetText('')				
				end
			

				interface:GetWidget('game_team_announcements_2_line_3_label_2'):UnregisterWatchLua('EventGeneratorGold')
				interface:GetWidget('game_team_announcements_2_line_3_label_2'):UnregisterWatchLua('EventTowerGold')
				interface:GetWidget('game_team_announcements_2_line_3_label_2'):UnregisterWatchLua('EventBossGold')
				interface:GetWidget('game_team_announcements_2_line_3_label_2'):UnregisterWatchLua('EventHeroGold')
				
				interface:GetWidget('game_team_announcements_2_line_3_b'):SetVisible(0)
						

				interface:GetWidget('game_team_announcements_2_sleeper'):Sleep(announcerFadeOutDelay * 0.70, function()
					interface:GetWidget('game_team_announcements_2'):FadeOut(gameEvents.longFade)
					interface:GetWidget('game_team_announcements_2_line_1'):FadeOut(gameEvents.longFade)
					interface:GetWidget('game_team_announcements_2_line_3'):FadeOut(gameEvents.shortFade)
					interface:GetWidget('game_team_announcements_2_line_3_a'):FadeOut(gameEvents.shortFade)
					
					interface:GetWidget('game_team_announcements_2'):Sleep(gameEvents.longFade + 500, function()
						table.remove(arcadeEventsQueue[3], 1)
						if (#arcadeEventsQueue[3] ~= 0) then
							if (arcadeEventsQueue[3][1][1] == 2) then
								Side2ArcadeEventBuildingKill(arcadeEventsQueue[3][1][2], true)
							else
								Side2ArcadeEventKill(arcadeEventsQueue[3][1][2], true)
							end
							return
						end					
					end)					
					
				end)
			end)
		end

	end	
	
	interface:GetWidget('game_team_announcements_2'):RegisterWatchLua('EventKill', function(widget, trigger)	
		Side2ArcadeEventKill(trigger, false)
	end)	
	
	function Side2ArcadeEventBuildingKill(trigger, isDelayed, isBoss)
		
		local team = LuaTrigger.GetTrigger('Team').team
		
		if (not trigger_gamePanelInfo.mapWidgetVis_arcadeText) or ((not isBoss) and (not isTowerEntity(trigger.entityName)) and (not isBarracksEntity(trigger.entityName))) then
			return
		end
		
		if (trigger.killerIsAlly) or (trigger.killerIsSelf) then
			return
		end

		local announcerFadeOutDelay = gameEvents.announcerFadeOutDelay

		if (isDelayed) then
			announcerFadeOutDelay = gameEvents.announcerFadeOutDelay - 1000 -- delayed events play faster
		else
			if  (Shop.GetVisible()) then
				return
			elseif (#arcadeEventsQueue[3] ~= 0) then
				table.insert(arcadeEventsQueue[3], {2, trigger})
				return
			else
				table.insert(arcadeEventsQueue[3], {2, trigger})
			end
		end		

		interface:GetWidget('game_team_announcements_2'):SetVisible(1)
		
		interface:GetWidget('game_team_announcements_2_line_1'):FadeIn(gameEvents.shortFade)
		interface:GetWidget('game_team_announcements_2_line_1_icon_1'):SetTexture('$invis')
		interface:GetWidget('game_team_announcements_2_line_1_icon_2'):SetTexture(GetEntityIconPath(trigger.entityName))
		if (team == trigger.attackerTeam) then
			interface:GetWidget('game_team_announcements_2_line_1_icon_parent_1'):SetColor('0 1 0 0.0')
			interface:GetWidget('game_team_announcements_2_line_1_icon_parent_2'):SetColor('1 0 0 0.7')
		else
			interface:GetWidget('game_team_announcements_2_line_1_icon_parent_2'):SetColor('0 1 0 0.7')
			interface:GetWidget('game_team_announcements_2_line_1_icon_parent_1'):SetColor('1 0 0 0.0')			
		end		
			
		local displayName = GetEntityDisplayName(trigger.entityName) or trigger.entityName
		if (isBoss) then
			interface:GetWidget('game_team_announcements_2_line_1_label_1'):SetText(Translate('events_defeated', 'entity', displayName))
		else
			interface:GetWidget('game_team_announcements_2_line_1_label_1'):SetText(Translate('events_destroyed', 'entity', displayName))
		end

		interface:GetWidget('game_team_announcements_2_sleeper'):Sleep(announcerFadeOutDelay * 0.30, function()
			
			if (LuaTrigger.GetTrigger('EventHeroGold')) then
				interface:GetWidget('game_team_announcements_2_line_3_label_2'):UnregisterWatchLua('EventGeneratorGold')
				interface:GetWidget('game_team_announcements_2_line_3_label_2'):UnregisterWatchLua('EventTowerGold')
				interface:GetWidget('game_team_announcements_2_line_3_label_2'):UnregisterWatchLua('EventBossGold')
				interface:GetWidget('game_team_announcements_2_line_3_label_2'):UnregisterWatchLua('EventHeroGold')
				
				interface:GetWidget('game_team_announcements_2_line_3'):SetVisible(0)
				interface:GetWidget('game_team_announcements_2_line_3_b'):SetVisible(0)
	
			end
			
			interface:GetWidget('game_team_announcements_2_sleeper'):Sleep(announcerFadeOutDelay * 0.70, function()
				interface:GetWidget('game_team_announcements_2'):FadeOut(gameEvents.longFade)
				interface:GetWidget('game_team_announcements_2_line_1'):FadeOut(gameEvents.longFade)
				interface:GetWidget('game_team_announcements_2_line_3'):FadeOut(gameEvents.shortFade)
				interface:GetWidget('game_team_announcements_2_line_3_b'):FadeOut(gameEvents.shortFade)
				
				interface:GetWidget('game_team_announcements_2'):Sleep(gameEvents.longFade + 500, function()
					table.remove(arcadeEventsQueue[3], 1)
					if (#arcadeEventsQueue[3] ~= 0) then
						if (arcadeEventsQueue[3][1][1] == 2) then
							Side2ArcadeEventBuildingKill(arcadeEventsQueue[3][1][2], true)
						else
							Side2ArcadeEventKill(arcadeEventsQueue[3][1][2], true)
						end
						return
					end				
				end)					
				
			end)
		end)
	end		

	interface:GetWidget('game_team_announcements_2'):RegisterWatchLua('EventBuildingKill', function(widget, trigger)	
		Side2ArcadeEventBuildingKill(trigger, false)
	end)	
	
	interface:GetWidget('game_team_announcements_2'):RegisterWatchLua('EventBossKill', function(widget, trigger)	
		Side2ArcadeEventBuildingKill(trigger, false, true)
	end)	

	interface:GetWidget('game_team_announcements_2'):RegisterWatchLua('gamePanelInfo', function(widget, trigger)
		
		if (trigger.moreInfoKey) or (trigger.unitFramesPinned) then
			widget:SlideY('12.6h', 125)
			widget:Sleep(125, function()
				widget:SetY('12.6h')
			end)			
		else
			widget:SlideY('8.6h', 125)
			widget:Sleep(125, function()
				widget:SetY('8.6h')
			end)
		end
	end, false, nil, 'moreInfoKey', 'unitFramesPinned')
	
	ArcadeEventsRegister = nil
end
ArcadeEventsRegister(object)

local function TipEventsRegister(object)
	
	local self_bottom_announcements_0 			= 	object:GetWidget('self_bottom_announcements_0')
	local self_bottom_announcements_label_0 	= 	object:GetWidget('self_bottom_announcements_label_0')
	local self_bottom_announcements_0_wrapper 	= 	object:GetWidget('self_bottom_announcements_0_wrapper')
	local gamePanelInfo 						= 	GetTrigger('gamePanelInfo')
	local shownTips 							=	{}
	local canPromptShopTip						=	false	-- fix for the buy items tip appearing on game start
	
	-- 96-104 -- inventory ActiveInventory
	-- 128-133 -- stash StashInventory
	
	function ShowTip(stringKey, duration)
		
		if (not shownTips[stringKey]) and (not self_bottom_announcements_0:IsVisible()) then
			
			shownTips[stringKey] = true
			
			self_bottom_announcements_0:SetVisible(0)
			
			self_bottom_announcements_label_0:SetText(Translate(stringKey))
			
			self_bottom_announcements_0_wrapper:SetHeight(0)
			self_bottom_announcements_0_wrapper:SetWidth(0)
			self_bottom_announcements_0_wrapper:SetVisible(1)
			
			if (gamePanelInfo.moreInfoKey) or (gamePanelInfo.heroVitalsVis) then
				self_bottom_announcements_0_wrapper:SetY('-23.0h')			
			else
				self_bottom_announcements_0_wrapper:SetY('-18.2h')
			end		
			
			self_bottom_announcements_0_wrapper:Scale('45h', '5.5h', 125)		
			
			self_bottom_announcements_0:FadeIn(250)
			
			self_bottom_announcements_0:Sleep(duration, function(widget)
				widget:FadeOut(250)
			end)
			
			self_bottom_announcements_0_wrapper:Sleep(duration, function(widget)
				widget:FadeOut(250)
			end)

		end
	end
	
	self_bottom_announcements_0:SetCallback('onclick', function()
		self_bottom_announcements_0:FadeOut(250)
		self_bottom_announcements_0_wrapper:FadeOut(250)	
	end)
	
	self_bottom_announcements_0:SetCallback('onrightclick', function()
		self_bottom_announcements_0:FadeOut(250)
		self_bottom_announcements_0_wrapper:FadeOut(250)	
	end)	
	
	self_bottom_announcements_0:RegisterWatchLua('GameReinitialize', function(widget, trigger)
		shownTips =	{}
		canPromptShopTip = false
	end)
	
	local wasAFK = false
	self_bottom_announcements_0:RegisterWatchLua('ClientAFKWarning', function(widget, trigger)
		local npeTrigger = LuaTrigger.GetTrigger('newPlayerExperience')
		if (npeTrigger) and (npeTrigger.tutorialProgress >= NPE_PROGRESS_TUTORIALCOMPLETE) then
			shownTips['game_context_tip_2'] = false
			ShowTip('game_context_tip_2', 60000)
			wasAFK = true
		end
	end, true, nil)	
	
	self_bottom_announcements_0:RegisterWatchLua('ClientAFK', function(widget, trigger)
		local npeTrigger = LuaTrigger.GetTrigger('newPlayerExperience')
		if (npeTrigger) and (npeTrigger.tutorialProgress >= NPE_PROGRESS_TUTORIALCOMPLETE) then
			shownTips['game_context_tip_3'] = false
			ShowTip('game_context_tip_3', 60000)
			wasAFK = true
		end
	end, true, nil)		
	
	self_bottom_announcements_0:RegisterWatchLua('EventPlayerGoldFromOtherPlayer', function(widget, trigger)
		local npeTrigger = LuaTrigger.GetTrigger('newPlayerExperience')
		if (trigger.gold > 0) and (npeTrigger) and (npeTrigger.tutorialProgress >= NPE_PROGRESS_TUTORIALCOMPLETE) then
			ShowTip('game_context_tip_4', 8000)
		end
	end, true, nil, 'gold')
	
	self_bottom_announcements_0:RegisterWatchLua('HeroUnit', function(widget, trigger)
		if (trigger.availablePoints > 0) and (trigger.inCombat) and (trigger.level == 1) then
			ShowTip('game_context_tip_1', 5500)
		end
		if (not trigger.isAFK) and (wasAFK) then
			self_bottom_announcements_0:FadeOut(250)
			self_bottom_announcements_0_wrapper:FadeOut(250)
		end
	end, true, nil, 'availablePoints', 'inCombat', 'isAFK')
	
	self_bottom_announcements_0:RegisterWatchLua('PlayerCanShop', function(widget, trigger)
		if trigger.playerCanShop then
			canPromptShopTip = true -- since they have been allowed to shop once, allow the tip to display
		elseif (canPromptShopTip) then
			local hasAnItem  = false
			local trigger2
			for index = 96, 104, 1 do
				trigger2 = GetTrigger('ActiveInventory' .. index)
				if (trigger2) and (trigger2.exists) then
					hasAnItem = true
					break
				end
				
			end
			if (not hasAnItem) then
				ShowTip('game_context_tip_0', 6500)
			end
		end
	end, true, nil, 'playerCanShop')
		
	self_bottom_announcements_0:RegisterWatchLua('gamePanelInfo', function(widget, trigger)		
		if (trigger.moreInfoKey) or (trigger.heroVitalsVis) then
			widget:SlideY('-23.0h', 125)			
		else
			widget:SlideY('-18.2h', 125)
		end
	end, false, nil, 'moreInfoKey', 'heroVitalsVis')		
	
	self_bottom_announcements_0_wrapper:RegisterWatchLua('gamePanelInfo', function(widget, trigger)		
		if (trigger.moreInfoKey) or (trigger.heroVitalsVis) then
			widget:SlideY('-23.0h', 125)			
		else
			widget:SlideY('-18.2h', 125)
		end
	end, false, nil, 'moreInfoKey', 'heroVitalsVis')		
	
	TipEventsRegister = nil
end
TipEventsRegister(object)