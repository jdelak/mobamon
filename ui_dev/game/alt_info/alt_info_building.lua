-- AltInfoBuilding

function altInfoBuildingRegister(object)
	local healthBar				= object:GetWidget('AltInfoBuildingHealthBar')
	local healthBarBacker		= object:GetWidget('AltInfoBuildingHealthBarBacker')
	local healthBarMaxWidth		= healthBar:GetWidth()
	
	local healthPips		= object:GetWidget('AltInfoBuildingHealthPips')
	local healthPerPip		= 1500
	
	---[[
	local shieldPipContainer	= object:GetWidget('AltInfoBuildingShieldPipContainer')
	local shieldBar				= object:GetWidget('AltInfoBuildingShieldBar')
	local shieldBarMaxWidth		= shieldBar:GetWidth()
	local shieldPerPip			= 250
	
	local shieldShadow			= object:GetWidget('AltInfoBuildingShieldShadow')
	local shieldGlow			= object:GetWidget('AltInfoBuildingShieldGlow')
	local shieldGlowContainer	= object:GetWidget('AltInfoBuildingShieldGlowContainer')
	local shieldBacker			= object:GetWidget('AltInfoBuildingShieldBacker')
	local shieldInset			= object:GetWidget('AltInfoBuildingShieldInset')
	local shieldCorners			= object:GetWidget('AltInfoBuildingShieldCorners')
	
	-- local expIndicator		= object:GetWidget('AltInfoBuildingExp')
	-- local expIndicatorShadow	= object:GetWidget('AltInfoBuildingExpShadow')
	
	--]]
	
	local healthGlow			= object:GetWidget('AltInfoBuildingHealthGlow')
	
	local levelShadow			= object:GetWidget('AltInfoBuildingLevelShadow')
	local levelBacker			= object:GetWidget('AltInfoBuildingLevelBacker')
	local levelInset			= object:GetWidget('AltInfoBuildingLevelInset')
	local levelBar				= object:GetWidget('AltInfoBuildingLevelBar')
	local levelMaxWidth			= levelBar:GetWidth()
	local levelCorners			= object:GetWidget('AltInfoBuildingLevelCorners')
	local levelGlow				= object:GetWidget('AltInfoBuildingLevelGlow')
	local levelGlowContainer	= object:GetWidget('AltInfoBuildingLevelGlowContainer')
	
	
	healthBar:RegisterWatchLua('AltInfoBuilding', function(widget, trigger) widget:SetWidthF(healthBarMaxWidth * trigger.healthPercent) end, true, nil, 'healthPercent')
	
	healthPips:RegisterWatchLua('AltInfoBuilding', function(widget, trigger)
		local healthMax = trigger.maxHealth

		if healthMax > 16875 then
			widget:SetTexture('/ui/game/alt_info/bar_segment_big_8.tga')
		elseif healthMax >= 13125 then
			widget:SetTexture('/ui/game/alt_info/bar_segment_big_16.tga')
		elseif healthMax > 4500 then
			widget:SetTexture('/ui/game/alt_info/bar_segment_big_32.tga')
		else
			widget:SetTexture('/ui/game/alt_info/bar_segment_big_128.tga')
		end
		widget:SetUScale(healthPerPip / healthMax)
	end, true, nil, 'maxHealth')
	
	local lastRelation = nil
	healthBar:RegisterWatchLua('updateHealthColors', function(widget)
		if lastRelation == 1 then
			widget:SetColor(styles_healthBarAllyColor)
		elseif lastRelation == 2 then
			widget:SetColor(styles_healthBarEnemyColor)
		else
			widget:SetColor(styles_healthBarNeutralColor)
		end
	end)
	
	healthBar:RegisterWatchLua('AltInfoBuilding', function(widget, trigger)
		local relation = trigger.relation
		lastRelation = relation
		if relation == 1 then
			widget:SetColor(styles_healthBarAllyColor)
		elseif relation == 2 then
			widget:SetColor(styles_healthBarEnemyColor)
		else
			widget:SetColor(styles_healthBarNeutralColor)
		end
	end, true, nil, 'relation')
	
	healthBarBacker:RegisterWatchLua('AltInfoBuilding', function(widget, trigger)	-- Would ideally be the frame itself
		local relation		= trigger.relation
		local colorR		= styles_healthBackerColorNeutralR
		local colorG		= styles_healthBackerColorNeutralG
		local colorB		= styles_healthBackerColorNeutralB
		if relation == 1 then
			colorR = styles_healthBackerColorR
			colorG = styles_healthBackerColorG
			colorB = styles_healthBackerColorB
		elseif relation == 2 then
			colorR = styles_healthBackerColorEnemyR
			colorG = styles_healthBackerColorEnemyG
			colorB = styles_healthBackerColorEnemyB
		end
		
		widget:SetColor(colorR, colorG, colorB)
	end, true, nil, 'relation')
	
	---[[
	
	shieldGlow:RegisterWatchLua('AltInfoBuilding', function(widget, trigger)	-- Would ideally be the frame itself
		local relation		= trigger.relation
		local colorR		= styles_glowNeutralR
		local colorG		= styles_glowNeutralG
		local colorB		= styles_glowNeutralB
		if relation == 1 then
			colorR = styles_glowAllyR
			colorG = styles_glowAllyG
			colorB = styles_glowAllyB
		elseif relation == 2 then
			colorR = styles_glowEnemyR
			colorG = styles_glowEnemyG
			colorB = styles_glowEnemyB
		end
		
		widget:SetColor(colorR, colorG, colorB)
		widget:SetBorderColor(colorR, colorG, colorB)
	end, true, nil, 'relation')
	
	healthGlow:RegisterWatchLua('AltInfoBuilding', function(widget, trigger)	-- Would ideally be the frame itself
		local relation		= trigger.relation
		local colorR		= styles_glowNeutralR
		local colorG		= styles_glowNeutralG
		local colorB		= styles_glowNeutralB
		if relation == 1 then
			colorR = styles_glowAllyR
			colorG = styles_glowAllyG
			colorB = styles_glowAllyB
		elseif relation == 2 then
			colorR = styles_glowEnemyR
			colorG = styles_glowEnemyG
			colorB = styles_glowEnemyB
		end
		
		widget:SetColor(colorR, colorG, colorB)
		widget:SetBorderColor(colorR, colorG, colorB)
	end, true, nil, 'relation')
	
	levelGlow:RegisterWatchLua('AltInfoBuilding', function(widget, trigger)	-- Would ideally be the frame itself
		local relation		= trigger.relation
		local colorR		= styles_glowNeutralR
		local colorG		= styles_glowNeutralG
		local colorB		= styles_glowNeutralB
		if relation == 1 then
			colorR = styles_glowAllyR
			colorG = styles_glowAllyG
			colorB = styles_glowAllyB
		elseif relation == 2 then
			colorR = styles_glowEnemyR
			colorG = styles_glowEnemyG
			colorB = styles_glowEnemyB
		end
	
		widget:SetColor(colorR, colorG, colorB)
		widget:SetBorderColor(colorR, colorG, colorB)
	end, true, nil, 'relation')
	
	object:RegisterWatchLua('AltInfoBuilding', function(widget, trigger)
		local shieldVis = (trigger.maxShield > 0)
		
		shieldBar:SetVisible(shieldVis)
		shieldPipContainer:SetVisible(shieldVis)
		shieldShadow:SetVisible(shieldVis)
		shieldBacker:SetVisible(shieldVis)
		shieldInset:SetVisible(shieldVis)
		shieldCorners:SetVisible(shieldVis)
	end, true, nil, 'maxShield')
	
	shieldBar:RegisterWatchLua('AltInfoBuilding', function(widget, trigger) widget:SetWidthF(trigger.shieldPercent * shieldBarMaxWidth) end, true, nil, 'shieldPercent')

	shieldPipContainer:RegisterWatchLua('AltInfoBuilding', function(widget, trigger)
		local maxShield = trigger.maxShield
		
		if maxShield > 4500 then
			widget:SetTexture('/ui/game/alt_info/bar_segment_big_8.tga')
		elseif maxShield >= 3500 then
			widget:SetTexture('/ui/game/alt_info/bar_segment_big_16.tga')
		elseif maxShield > 1500 then
			widget:SetTexture('/ui/game/alt_info/bar_segment_big_32.tga')
		else
			widget:SetTexture('/ui/game/alt_info/bar_segment_big_128.tga')
		end
		widget:SetUScale(shieldPerPip / maxShield)
	end, true, nil, 'maxShield')
	
	shieldGlow:RegisterWatchLua('AltInfoBuilding', function(widget, trigger) widget:SetVisible(trigger.maxShield > 0) end, true, nil, 'maxShield')
	shieldGlowContainer:RegisterWatchLua('AltInfoBuilding', function(widget, trigger) widget:SetVisible(trigger.isHovering) end, true, nil, 'isHovering')

	-- expIndicator:RegisterWatchLua('AltInfoBuilding', function(widget, trigger) widget:SetVisible(trigger.isInExpRange) end, true, nil, 'isInExpRange)
	-- expIndicatorShadow:RegisterWatchLua('AltInfoBuilding', function(widget, trigger) widget:SetVisible(trigger.isInExpRange) end, true, nil, 'isInExpRange)
	
	--]]

	object:RegisterWatchLua('AltInfoBuilding', function(widget, trigger)
		local levelVis = (trigger.level > 0)
		levelShadow:SetVisible(levelVis)
		levelBacker:SetVisible(levelVis)
		levelInset:SetVisible(levelVis)
		levelGlow:SetVisible(levelVis)
		levelCorners:SetVisible(levelVis)
		levelBar:SetVisible(levelVis)
	end, true, nil, 'level')
	
	levelBar:RegisterWatchLua('AltInfoBuilding', function(widget, trigger) widget:SetWidthF(trigger.level * levelMaxWidth) end, true, nil, 'level')
	
	levelGlowContainer:RegisterWatchLua('AltInfoBuilding', function(widget, trigger) widget:SetVisible(trigger.isHovering) end, true, nil, 'isHovering')
	
	healthGlow:RegisterWatchLua('AltInfoBuilding', function(widget, trigger)
		widget:SetVisible( trigger.isHovering )
	end, true, nil, 'isHovering')
end

altInfoBuildingRegister(object)