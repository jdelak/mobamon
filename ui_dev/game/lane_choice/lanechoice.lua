-- Boss lane choice

local interface = object

gameLaneChoice = {
	root	= object:GetWidget('bossLaneChoice'),
	botLaneChoiceName	= 'bottom',
	midLaneChoiceName	= 'middle',
	topLaneChoiceName	= 'top',
	timerLabel			= object:GetWidget('bossLaneChoiceTimerLabel'),
	pusherIcon			= object:GetWidget('bossLaneChoiceIcon'),
	iconContainer		= object:GetWidget('bossLaneChoiceIconContainer'),
	iconContainerWidth	= object:GetWidget('bossLaneChoiceIconContainer'):GetWidth(),
	iconContainerHeight	= object:GetWidget('bossLaneChoiceIconContainer'):GetHeight(),
	lastPusherEntity	= '',
	buttonRegistry		= {},
	object				= object,
	laneChoiceButton	= object:GetWidget('gameSpawnLanePusher'),
	laneChoiceTimerContainer	= object:GetWidget('laneChoiceTimerContainer'),
	laneChoiceTimerBar			= object:GetWidget('laneChoiceTimerBar'),
	existsTrigger		= LuaTrigger.GetTrigger('HeroInventory64')
}

gameLaneChoice.laneChoiceButton:SetCallback('onclick', function(widget)
	if gameLaneChoice.existsTrigger.exists and not gameLaneChoice.root:IsVisible() then
		gameLaneChoice.root:SetVisible(true)
	end	
end)

gameLaneChoice.laneChoiceTimerBar:RegisterWatchLua('HeroInventory64', function(widget, trigger) widget:SetWidth(ToPercent(trigger.timer / trigger.timerDuration)) end, false, nil, 'timer', 'timerDuration')
gameLaneChoice.laneChoiceTimerContainer:RegisterWatchLua('HeroInventory64', function(widget, trigger) widget:SetVisible(trigger.exists) end, false, nil, 'exists')
gameLaneChoice.laneChoiceButton:RegisterWatchLua('HeroInventory64', function(widget, trigger) 
	if (trigger.exists) then
		widget:SetVisible(1) 
		trigger_gamePanelInfo.lanePusherVis = true
		trigger_gamePanelInfo:Trigger(false)		
	else
		widget:SetVisible(0) 
		trigger_gamePanelInfo.lanePusherVis = false
		trigger_gamePanelInfo:Trigger(false)			
	end
end, false, nil, 'exists')

-- gameLaneChoice.laneChoiceTimerContainer:RegisterWatchLua('gamePanelInfo', function(widget, trigger)		
	-- if (trigger.moreInfoKey) or (trigger.heroVitalsVis) then
		-- widget:SlideY('-26.0h', 125)			
	-- else
		-- widget:SlideY('-21.2h', 125)
	-- end
-- end, false, nil, 'moreInfoKey', 'heroVitalsVis')

-- gameLaneChoice.laneChoiceButton:RegisterWatchLua('gamePanelInfo', function(widget, trigger)		
	-- if (trigger.moreInfoKey) or (trigger.heroVitalsVis) then
		-- widget:SlideY('-23.0h', 125)			
	-- else
		-- widget:SlideY('-18.2h', 125)
	-- end
-- end, false, nil, 'moreInfoKey', 'heroVitalsVis')	

gameLaneChoice.root:RegisterWatchLua('HeroInventory64', function(widget, trigger)
	if not trigger.exists then
		widget:SetVisible(false)
	end
end, false, nil, 'exists')

object:GetWidget('bossLaneChoiceTopIcon'):RegisterWatchLua('HeroInventory64', function(widget, trigger)
	if trigger.charges > 0 then
		widget:SetTexture('/ui/game/shared/textures/lane_top_selected.tga')
	else
		widget:SetTexture('/ui/game/shared/textures/lane_top.tga')
	end
end, false, nil, 'charges')

object:GetWidget('bossLaneChoiceMidIcon'):RegisterWatchLua('HeroInventory65', function(widget, trigger)
	if trigger.charges > 0 then
		widget:SetTexture('/ui/game/shared/textures/lane_mid_selected.tga')
	else
		widget:SetTexture('/ui/game/shared/textures/lane_mid.tga')
	end
end, false, nil, 'charges')

object:GetWidget('bossLaneChoiceBotIcon'):RegisterWatchLua('HeroInventory66', function(widget, trigger)
	if trigger.charges > 0 then
		widget:SetTexture('/ui/game/shared/textures/lane_bot_selected.tga')
	else
		widget:SetTexture('/ui/game/shared/textures/lane_bot.tga')
	end
end, false, nil, 'charges')

object:RegisterWatchLua(
	'SelectLanePusher', function(widget, trigger)
		local pusherEntity = trigger.lanePusher
	
		if pusherEntity and string.len(pusherEntity) > 0 then
			gameLaneChoice.timerLabel:SetVisible(false)
			gameLaneChoice.root:SetVisible(true)
			
			if pusherEntity ~= gameLaneChoice.lastPusherEntity then
				libAnims.bounceIn(
					gameLaneChoice.iconContainer,
					gameLaneChoice.iconContainerWidth,
					gameLaneChoice.iconContainerHeight,
					nil, 400, nil, nil, 0.7, 0.3
				)
			end
				
			gameLaneChoice.lastPusherEntity = pusherEntity
			if pusherEntity == 'Creep_Kongor' then
				gameLaneChoice.pusherIcon:SetTexture('/npcs/Kongor/icon_circle.tga')
			elseif pusherEntity == 'Creep_Kongor2' then
				gameLaneChoice.pusherIcon:SetTexture('/npcs/Kongor/kongor2/icon_circle.tga')
			end
				
			-- Will set up something better later on using arg[]
			gameLaneChoice.botLaneChoiceName = "bottom"
			gameLaneChoice.midLaneChoiceName = "middle"
			gameLaneChoice.topLaneChoiceName = "top"
		else
			gameLaneChoice.root:SetVisible(false)
		end
	end
)

object:GetWidget('bossLaneChoiceTop'):SetCallback('onclick', function(widget)
	ActivateTool(64)
	gameLaneChoice.root:SetVisible(false)
end)

object:GetWidget('bossLaneChoiceTop'):SetCallback('onmouseover', function(widget)
	interface:GetWidget('bossLaneChoiceTopLabel'):SetColor('#b0def9')
end)

object:GetWidget('bossLaneChoiceTop'):SetCallback('onmouseout', function(widget)
	interface:GetWidget('bossLaneChoiceTopLabel'):SetColor('white')
end)

object:GetWidget('bossLaneChoiceMid'):SetCallback('onclick', function(widget)
	ActivateTool(65)
	gameLaneChoice.root:SetVisible(false)
end)

object:GetWidget('bossLaneChoiceMid'):SetCallback('onmouseover', function(widget)
	interface:GetWidget('bossLaneChoiceMidLabel'):SetColor('#b0def9')
end)

object:GetWidget('bossLaneChoiceMid'):SetCallback('onmouseout', function(widget)
	interface:GetWidget('bossLaneChoiceMidLabel'):SetColor('white')
end)

object:GetWidget('bossLaneChoiceBot'):SetCallback('onclick', function(widget)
	ActivateTool(66)
	gameLaneChoice.root:SetVisible(false)
end)

object:GetWidget('bossLaneChoiceBot'):SetCallback('onmouseover', function(widget)
	interface:GetWidget('bossLaneChoiceBotLabel'):SetColor('#b0def9')
end)

object:GetWidget('bossLaneChoiceBot'):SetCallback('onmouseout', function(widget)
	interface:GetWidget('bossLaneChoiceBotLabel'):SetColor('white')
end)