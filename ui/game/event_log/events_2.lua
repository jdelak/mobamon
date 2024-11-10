-- Game Events (kills, deaths, towers, bosses)
gameEvents = gameEvents or {}
local interface = object
local GetTrigger = LuaTrigger.GetTrigger

local trigger_EventKillDriver = LuaTrigger.GetTrigger('EventKillTest') or LuaTrigger.CreateCustomTrigger('EventKillTest',
	{
		{ name	= 'assists',					type	= 'string' },
		{ name	= 'firstBlood',					type	= 'boolean' },
		{ name	= 'goldIncome',					type	= 'number' },
		{ name	= 'killStreak',					type	= 'number' },
		{ name	= 'killType',					type	= 'number' },
		{ name	= 'killerIcon',					type	= 'string' },
		{ name	= 'killerIsAlly',				type	= 'boolean' },
		{ name	= 'killerIsSelf',				type	= 'boolean' },
		{ name	= 'killerName',					type	= 'string' },
		{ name	= 'killerPlayerColor',			type	= 'string' },
		{ name	= 'killerTeam',					type	= 'number' },
		{ name	= 'killerTypeName',				type	= 'string' },
		{ name	= 'multiKill',					type	= 'number' },
		{ name	= 'multiKillHeroes',			type	= 'string' },
		{ name	= 'playerGoldIncome',			type	= 'number' },
		{ name	= 'victimIcon',					type	= 'string' },
		{ name	= 'victimIsAlly',				type	= 'boolean' },
		{ name	= 'victimName',					type	= 'string' },
		{ name	= 'playerGoldIncome',			type	= 'number' },
		{ name	= 'victimPlayerColor',			type	= 'string' },
		{ name	= 'victimTypeName',				type	= 'string' },
	}
)	

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

local function GoldSplashRegister()

	local parent	= interface:GetWidget('gameEventsGold_parent')
	local texture	= interface:GetWidget('gameEventsGold_texture')
	local glow		= interface:GetWidget('gameEventsGold_glow')
	local label		= interface:GetWidget('gameEventsGold_label')
	local goldAnim	= gameGetWidget('gameHeroGoldContainer_anim')
	local animChest	= interface:GetWidget('gameEventsGold_anichest')
	local staticChest	= interface:GetWidget('gameEventsGold_staticchest')
	
	local trigger_gamePanelInfo = LuaTrigger.GetTrigger('gamePanelInfo')
	
	local goldThread
	local accumulatedGold = 0
	
	if (not parent) then
		return
	end
	
	--[[
	-- This needs to always be placed in an exact spot above the minimap
	parent:RegisterWatchLua('HeroUnit', function(widget, trigger)
		if (trigger.availablePoints > 0) then
			widget:SlideY('-36.2h', 125)
		else
			widget:SlideY('-30.2h', 125)
		end
	end, false, nil, 'availablePoints')
	--]]
		
	local function UpdateAccumulatedGold()
		label:SetText('+' .. accumulatedGold)
	end		
		
	local function CheckDisplaySplash()
		if (goldThread) then
			goldThread:kill()
			goldThread = nil
		end
		goldThread = libThread.threadFunc(function()	
			UpdateAccumulatedGold()
			trigger_gamePanelInfo.goldSplashVisible = true
			trigger_gamePanelInfo:Trigger(false)
			
			animChest:SetVisible(0)
			glow:SetVisible(0)
			parent:FadeIn(500)
			wait(250)
			
			staticChest:FadeIn(250)
			wait(3500)
			
			animChest:FadeIn(250)
			glow:FadeIn(250)
			animChest:UICmd("StartAnim(1);")
			wait(125)
			staticChest:SetVisible(0)
			wait(375)
			
			glow:FadeOut(900)
			goldAnim:FadeIn(250)
			wait(750)
			
			goldAnim:FadeOut(250)			
			parent:FadeOut(500)
			accumulatedGold = 0
			
			wait(500)
			
			trigger_gamePanelInfo.goldSplashVisible = false
			trigger_gamePanelInfo:Trigger(false)	
			goldThread = nil
		end)
	end		
	
	local oldSwap = false
	local function checkMinimapSide(force)
		local newSwap = GetCvarBool('ui_swapMinimap')
		if (newSwap ~= oldSwap or (force and newSwap)) then
			FlipWidgets(parent, true, 300, true, true)
		end
		oldSwap = newSwap
	end
	checkMinimapSide(true)
	parent:RegisterWatchLua('optionsTrigger',  function(widget, trigger)
		checkMinimapSide()
	end, false)	
	
	local function PlayGoldEvent(goldReward, sourceTrigger)
		println('^y^: PlayGoldEvent ' .. tostring(goldReward) .. ' | ' .. tostring(sourceTrigger) )
		if (goldReward) then
			if (goldReward > 1000) then
				PlaySound('/shared/sounds/ui/sfx_gold_3.wav')
				if (goldAnim) then
					goldAnim:UICmd("StartAnim(1)")
				end			
				CheckDisplaySplash()
			elseif (goldReward > 200) then
				PlaySound('/shared/sounds/ui/sfx_gold_2.wav')
				if (goldAnim) then
					goldAnim:UICmd("StartAnim(1)")
				end			
				CheckDisplaySplash()
			elseif (goldReward >= 10) then
				PlaySound('/shared/sounds/ui/sfx_gold_1.wav')
				if (goldAnim) then
					goldAnim:UICmd("StartAnim(1)")
				end
			end
			if (goldThread) then
				accumulatedGold = accumulatedGold + goldReward
				UpdateAccumulatedGold(accumulatedGold)
			else
				accumulatedGold = 0
				trigger_gamePanelInfo.goldSplashVisible = false
				trigger_gamePanelInfo:Trigger(false)				
			end			
		end
	end

	if (LuaTrigger.GetTrigger('EventHeroGold')) then
		interface:RegisterWatchLua('EventBossGold',  function(widget, trigger) PlayGoldEvent(trigger.gold, 'EventBossGold') end)
		interface:RegisterWatchLua('EventGeneratorGold',  function(widget, trigger) PlayGoldEvent(trigger.gold, 'EventGeneratorGold') end)
		interface:RegisterWatchLua('EventTowerGold',  function(widget, trigger) PlayGoldEvent(trigger.gold, 'EventTowerGold') end)
		interface:RegisterWatchLua('EventHeroGold',  function(widget, trigger) PlayGoldEvent(trigger.gold, 'EventHeroGold') end)
		-- interface:RegisterWatchLua('EventPlayerGold',  function(widget, trigger) PlayGoldEvent(trigger.gold, 'EventPlayerGold') end)
	end	
	
end
GoldSplashRegister()

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
	
	libGeneral.createGroupTrigger('eventsContainerPos', {
		'gamePanelInfo.goldSplashVisible',
		'HeroUnit.availablePoints',
		'itemGuidanceTrigger.visible'
	})
	
	eventsContainer:RegisterWatchLua('eventsContainerPos', function(widget, groupTrigger)
		local goldSplashVisible = groupTrigger['gamePanelInfo'].goldSplashVisible
		local canLevelUp		= (groupTrigger['HeroUnit'].availablePoints > 0)
		local showItemGuidance	= groupTrigger['itemGuidanceTrigger'].visible
		
		local yPos = -32
		
		if canLevelUp then
			yPos = yPos - 6
		end
		
		if goldSplashVisible then
			yPos = yPos - 6
		end
		
		if showItemGuidance then
			yPos = yPos - 9
		end

		widget:SlideY(libGeneral.HtoP(yPos), styles_uiSpaceShiftTime)

	end)
	
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
				yPosition = yPosition - itemPadding - prevDisplaySlot.parent:GetHeight()
			else
				yPosition = 0
			end
			

			displaySlot.parent:SetY(yPosition)

		end
		
	end
	
	local function updateScrolling()
		local totalItems = 0
		local totalHeight = 0
		local scrollVisible = false
		for i=1,maxDisplaySlots,1 do
			if displaySlots[i].parent:IsVisibleSelf() then
				if totalItems > 0 then
					totalHeight = totalHeight + itemPadding
				end
				totalHeight = totalHeight + displaySlots[i].parent:GetHeight()
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
			
				displaySlots[k].parent:FadeOut(
					math.max(
						fadeTime,
						fadeTime - (v + hostTime)
					)
				)

				fadeTimes[k] = nil
			end
		end

		if table.maxn(fadeTimes) <= 0 then
			eventsContainer:UnregisterWatchLua('System')
		end
	end

	local function fadeInit()
		if not viewHistory and table.maxn(fadeTimes) > 0 then
			eventsContainer:UnregisterWatchLua('System')
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
	

	
	local function populateDisplaySlotBuildingKill(displaySlot, trigger, isBoss, lanePusher)
		isBoss		= isBoss or false
		lanePusher	= lanePusher or false

		local entityName		= trigger.entityName
		displaySlot.right_icon:SetVisible(false)

		displaySlot.parent:SetVisible(true)

		displaySlot.right_bg_texture:SetVisible(false)
		displaySlot.center_bg_texture:SetVisible(true)

		displaySlot.bg:SetTexture('ui/game/arcade_text/textures/kill_bg.tga')
		displaySlot.bg:SetVisible(1)

		displaySlot.right_portrait:SetVisible(false)

		if (trigger.killerIsAlly) or (trigger.killerIsSelf) then
			displaySlot.glow:SetBorderColor(0, 1, 0, 0.6)
			displaySlot.center_bg_texture:SetColor('#54ff00')
			displaySlot.slider_cap:SetColor('#54ff00')
			displaySlot.slider_label_1:SetColor('#cfff00')
		else
			displaySlot.glow:SetBorderColor(1, 0, 0, 0.6)
			displaySlot.center_bg_texture:SetColor('#ff0000')
			displaySlot.slider_cap:SetColor('#ff0000')
			displaySlot.slider_label_1:SetColor('#ffbaa5')
		end

		local message = ''

		if lanePusher then
			message	= Translate('events_pusherispushing', 'pusher', GetEntityDisplayName(entityName), 'lane', trigger.laneName)
		elseif isBoss then
			message = Translate('events_defeated', 'entity', GetEntityDisplayName(entityName))
		elseif isTowerEntity(entityName) then
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
		

		displaySlot.slider_label_1:SetText(message)
		displaySlot.slider_label_2:SetVisible(false)
		FitFontToLabel(displaySlot.slider_label_1, nil, labelFontTable)
		displaySlot.slider_cap:SetVisible(true)
		displaySlot.slider:SetVisible(false)


		displaySlot.multiplier_parent:SetVisible(false)
		displaySlot.multiplier_label:SetText('')

		local entityName = trigger.entityName
		if entityName and string.len(entityName) > 0 then
			displaySlot.left_portrait:SetTexture(libGeneral.getCutoutOrRegularIcon(entityName))
		else
			displaySlot.left_portrait:SetTexture('')
		end

	end
	
	local function populateDisplaySlotLaneChoice(displaySlot, trigger)
		displaySlot = displaySlot or tallyNewEntry()
		
		if displaySlot then
			populateDisplaySlotBuildingKill(displaySlot, {
				entityName		= trigger.entityName,
				killerIsAlly	= trigger.friendly,
				laneName		= fullLaneNames[trigger.laneName]
			}, nil, true)
		end
	end
	
	local function populateDisplaySlotKill(displaySlot, trigger)

		-- println("displaySlot.parent " .. tostring(displaySlot.parent) .. ' | ' .. tostring(displaySlot.parent:GetName()) )
		
		displaySlot.parent:SetVisible(1)

		displaySlot.center_bg_texture:SetVisible(false)

		-- if trigger.goldIncome > 0 then
			-- displaySlot.label3:SetVisible(true)
			-- displaySlot.label3:SetText(libNumber.commaFormat(trigger.goldIncome))
		-- else
			-- displaySlot.label3:SetVisible(false)
		-- end
		
		displaySlot.right_icon:SetVisible(1)
		displaySlot.slider_label_1:SetVisible(1)
		displaySlot.slider:SetVisible(1)
		displaySlot.right_icon:SetTexture('/ui/game/unit_frames/textures/dead.tga')
		
		displaySlot.bg:SetTexture('ui/game/arcade_text/textures/kill_bg.tga')
		displaySlot.bg:SetVisible(1)
		
		displaySlot.right_bg_texture:SetVisible(1)
		displaySlot.right_bg_texture:SetTexture('/ui/game/arcade_text/textures/kill_rightbar.tga')
		if (trigger.killerIsAlly) or (trigger.killerIsSelf) then
			displaySlot.right_bg_texture:SetColor('#999999')
		else
			displaySlot.right_bg_texture:SetColor('#999999')
		end
		
		displaySlot.right_portrait:SetVisible(1)
		displaySlot.right_portrait:SetTexture(libGeneral.getCutoutOrRegularIcon(trigger.victimTypeName))
		
		displaySlot.right_portrait_grayscale:SetVisible(1)
		displaySlot.right_portrait_grayscale:SetTexture(libGeneral.getCutoutOrRegularIcon(trigger.victimTypeName))

		displaySlot.left_portrait:SetVisible(1)
		displaySlot.left_portrait:SetTexture(libGeneral.getCutoutOrRegularIcon(trigger.killerTypeName))
		
		if (trigger.killerIsAlly) or (trigger.killerIsSelf) then
			displaySlot.glow:SetBorderColor(0, 1, 0, 0.6)
		else
			displaySlot.glow:SetBorderColor(1, 0, 0, 0.6)
		end
		
		displaySlot.slider_label_2:SetText(trigger.victimName)
		displaySlot.slider_label_2:SetVisible(true)
		if (trigger.killerIsAlly) or (trigger.killerIsSelf) then
			displaySlot.slider_label_2:SetColor('#ffbaa5')
		else
			displaySlot.slider_label_2:SetColor('#cfff00')
		end		
		
		displaySlot.slider_label_1:SetText(trigger.killerName)
		if (trigger.killerIsAlly) or (trigger.killerIsSelf) then
			displaySlot.slider_label_1:SetColor('#cfff00')
		else
			displaySlot.slider_label_1:SetColor('#ffbaa5')
		end
		
		FitFontToLabel(displaySlot.slider_label_2, nil, labelFontTable)
		FitFontToLabel(displaySlot.slider_label_1, nil, labelFontTable)
		
		displaySlot.slider_cap:SetVisible(1)
		if (trigger.killerIsAlly) or (trigger.killerIsSelf) then
			displaySlot.slider_cap:SetColor('#54ff00')
		else
			displaySlot.slider_cap:SetColor('#ff0000')
		end
		
		if (trigger.killerIsAlly) or (trigger.killerIsSelf) then
			displaySlot.slider:SetColor('#54ff00')
		else
			displaySlot.slider:SetColor('#ff0000')
		end
		
		displaySlot.multiplier_parent:SetVisible(0)
		displaySlot.multiplier_label:SetText('')
		
		-- Animate In
		displaySlot.slider:SetX('-190@')
		displaySlot.right_portrait_grayscale:SetVisible(0)
		displaySlot.right_icon:SetVisible(0)
		libThread.threadFunc(function()	
			wait(150)			
			displaySlot.slider:SlideX('0', 250)
			wait(250)
			displaySlot.right_portrait_grayscale:FadeIn(250)
			displaySlot.right_icon:FadeIn(250)

			wait(500)		
		
			-- Animate Out
			displaySlot.slider:SlideX('-190@', 150)
		end)
		
	end
	
	for i=1,maxDisplaySlots,1 do
		displaySlots[i] 	= {
			parent						= object:GetWidget('game_events_log_'..i),
			glow						= object:GetWidget('game_events_log_'..i..'_glow'),
			bg							= object:GetWidget('game_events_log_'..i..'_bg'),
			center_bg_texture			= object:GetWidget('game_events_log_'..i..'_center_bg_texture'),
			right_bg_texture			= object:GetWidget('game_events_log_'..i..'_right_bg_texture'),
			right_portrait				= object:GetWidget('game_events_log_'..i..'_right_portrait'),
			right_portrait_grayscale	= object:GetWidget('game_events_log_'..i..'_right_portrait_grayscale'),
			right_icon					= object:GetWidget('game_events_log_'..i..'_right_icon'),
			slider_parent				= object:GetWidget('game_events_log_'..i..'_slider_parent'),
			slider						= object:GetWidget('game_events_log_'..i..'_slider'),
			slider_label_2				= object:GetWidget('game_events_log_'..i..'_slider_label_2'),
			slider_label_1				= object:GetWidget('game_events_log_'..i..'_slider_label_1'),
			slider_cap					= object:GetWidget('game_events_log_'..i..'_slider_cap'),
			left_portrait				= object:GetWidget('game_events_log_'..i..'_left_portrait'),
			multiplier_parent			= object:GetWidget('game_events_log_'..i..'_multiplier_parent'),
			multiplier_label			= object:GetWidget('game_events_log_'..i..'_multiplier_label')
		}
		
		displayOrder[maxDisplaySlots - i + 1] = i
	end

	itemPadding	= libGeneral.HtoP(0.75)
	scrollStep	= libGeneral.HtoP(4.5) + itemPadding

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

		if (killType ~= 1 and killType ~= 2) or not trigger_gamePanelInfo.mapWidgetVis_arcadeText then
			return
		end
		
		displaySlot = tallyNewEntry()
		
		if displaySlot then
			populateDisplaySlotKill(
				displaySlot,
				trigger
			)
		end

	end)
	
	eventsContainer:RegisterWatchLua('EventKillTest', function(widget, trigger)
		
		println('^c EventKillTest')
		
		local displaySlot	= nil
		local killType		= trigger.killType -- ?
		
		if (killType ~= 1 and killType ~= 2) or not trigger_gamePanelInfo.mapWidgetVis_arcadeText then
			return
		end
		
		displaySlot = tallyNewEntry()
		
		if displaySlot then
			populateDisplaySlotKill(
				displaySlot,
				trigger
			)
		end

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

		-- local teamIcon			= teamIcons[ownerTeam]
		local message			= ''
		local userTeam			= LuaTrigger.GetTrigger('Team').team
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
			populateDisplaySlotBuildingKill(displaySlot, trigger)
		end

		-- if displaySlot then
			-- populateDisplaySlotBuildingKill(
				-- displaySlot,
				-- {
					-- teamIcon	= teamIcon,
					-- message		= message,
					-- notifyColorR	= notifyColorR,
					-- notifyColorG	= notifyColorG,
					-- notifyColorB	= notifyColorB,
					-- backerColor		= backerColor
				-- }
			-- )
		-- end
		
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
		
		displaySlot = tallyNewEntry()

		if displaySlot then
			populateDisplaySlotBuildingKill(displaySlot, trigger, true)
		end

	end)	
	
	eventsContainer:RegisterWatchLua('LanePushers0', function(widget, triggerPushers)
		local pusherEntity = triggerPushers.name
		if triggerPushers.status == 1 and pusherEntity and string.len(pusherEntity) > 0 then
			local trigger = LuaTrigger.GetTrigger('LanePushSet')

			local displaySlot = displaySlot or tallyNewEntry()

			if displaySlot then
				populateDisplaySlotLaneChoice(displaySlot, trigger)
			end
		end
	end)

	eventsContainer:RegisterWatchLua('gamePanelInfo', function(widget, trigger)
		widget:SetVisible(not trigger.gameMenuExpanded)
	end, false, nil, 'gameMenuExpanded')
	
	eventsContainer:RegisterWatch('chatHistoryVisible', function(widget, showChatHistory)
		viewHistory = AtoB(showChatHistory)
		if viewHistory then
			fadeInit()
			for i=1,maxDisplaySlots,1 do
				if displaySlotPopulated[i] then
					-- for k,v in pairs(displaySlots[i].root) do
						displaySlots[i].parent:FadeIn(0)
						displaySlots[i].parent:SetVisible(true)
					-- end

				end
			end
			updateScrolling()
		else
			for i=1,maxDisplaySlots,1 do
				if fadeTimes[i] then
					-- for k,v in pairs(displaySlots[i].root) do
						displaySlots[i].parent:FadeIn(0)
						displaySlots[i].parent:SetVisible(true)
					-- end
				else
					-- for k,v in pairs(displaySlots[i].root) do
						displaySlots[i].parent:FadeOut(0)
						displaySlots[i].parent:SetVisible(false)
					-- end
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

local function TipEventsRegister(object)
	
	local self_bottom_announcements_0 			= 	object:GetWidget('self_bottom_announcements_0')
	local self_bottom_announcements_label_0 	= 	object:GetWidget('self_bottom_announcements_label_0')
	local self_bottom_announcements_0_wrapper 	= 	object:GetWidget('self_bottom_announcements_0_wrapper')
	local gamePanelInfo 						= 	GetTrigger('gamePanelInfo')
	local shownTips 							=	{}
	local canPromptShopTip						=	false	-- fix for the buy items tip appearing on game start
	
	-- 96-104 -- inventory ActiveInventory
	-- 128-133 -- stash StashInventory
	
	local function ShowTip(stringKey, duration, extraText, extraTextValue)
		
		if (not shownTips[stringKey]) and (not self_bottom_announcements_0:IsVisible()) then
			
			shownTips[stringKey] = true
			
			self_bottom_announcements_0:SetVisible(0)
			
			if extraText then
				self_bottom_announcements_label_0:SetText(Translate(stringKey, extraText, extraTextValue))
			else
				self_bottom_announcements_label_0:SetText(Translate(stringKey))
			end
			
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

			self_bottom_announcements_0:SetCallback('onclick', function()
				self_bottom_announcements_0:FadeOut(250)
				self_bottom_announcements_0_wrapper:FadeOut(250)
			end)
			self_bottom_announcements_0:RefreshCallbacks()
			self_bottom_announcements_0:SetNoClick(0)
			
		end
	end
	
	self_bottom_announcements_0:RegisterWatchLua('GameReinitialize', function(widget, trigger)
		shownTips =	{}
		canPromptShopTip = false
	end)

	local wasAFK = false
	self_bottom_announcements_0:RegisterWatchLua('ClientAFKWarning', function(widget, trigger)
		local npeTrigger = LuaTrigger.GetTrigger('newPlayerExperience')
		if (npeTrigger) and (npeTrigger.tutorialProgress >= NPE_PROGRESS_TUTORIALCOMPLETE) and (not GetCvarBool('ui_PAXDemo')) then
			shownTips['game_context_tip_2'] = false
			ShowTip('game_context_tip_2', 60000)
			wasAFK = true
		end
	end, true, nil)	
	
	self_bottom_announcements_0:RegisterWatchLua('ClientAFK', function(widget, trigger)
		local npeTrigger = LuaTrigger.GetTrigger('newPlayerExperience')
		if (npeTrigger) and (npeTrigger.tutorialProgress >= NPE_PROGRESS_TUTORIALCOMPLETE) and (not GetCvarBool('ui_PAXDemo')) then
			shownTips['game_context_tip_3'] = false
			ShowTip('game_context_tip_3', 60000)
			wasAFK = true
		end
	end, true, nil)		
	
	self_bottom_announcements_0:RegisterWatchLua('EventPlayerGoldFromOtherPlayer', function(widget, trigger)
		local npeTrigger = LuaTrigger.GetTrigger('newPlayerExperience')
		if (trigger.gold > 0) and (npeTrigger) and (npeTrigger.tutorialProgress >= NPE_PROGRESS_TUTORIALCOMPLETE) and (not GetCvarBool('ui_PAXDemo')) then
			ShowTip('game_context_tip_4', 8000)
		end
	end, true, nil, 'gold')	
	
	self_bottom_announcements_0:RegisterWatchLua('HeroUnit', function(widget, trigger)
		if (trigger.availablePoints > 0) and (trigger.inCombat) and (trigger.level == 1) then
			ShowTip('game_context_tip_1', 4000)
		end
	end, true, nil, 'availablePoints', 'inCombat')
	
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
				local shopHotkey = GetKeybindButton('game', 'ToggleShop', '', 0)
				if shopHotkey then
					ShowTip('game_context_tip_0', 6500, 'hotkey1', shopHotkey)
				else
					ShowTip('game_context_tip_0', 6500)
				end
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