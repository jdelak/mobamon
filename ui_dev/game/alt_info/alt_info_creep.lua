-- AltInfoCreep (not actually creeps)

function altInfoCreepRegister(object)
	local healthBar				= object:GetWidget('AltInfoCreepHealthBar')
	local healthBarBacker		= object:GetWidget('AltInfoCreepHealthBarBacker')
	local healthBarMaxWidth		= healthBar:GetWidth()
	
	---[[
	local shieldPipContainer	= object:GetWidget('AltInfoCreepShieldPipContainer')
	local shieldBar				= object:GetWidget('AltInfoCreepShieldBar')
	local shieldBarMaxWidth		= shieldBar:GetWidth()
	local shieldPerPip			= 300
	
	local shieldShadow			= object:GetWidget('AltInfoCreepShieldShadow')
	local shieldGlow			= object:GetWidget('AltInfoCreepShieldGlow')
	local shieldGlowContainer	= object:GetWidget('AltInfoCreepShieldGlowContainer')	-- Grouptriggers don't work in altinfo
	local shieldBacker			= object:GetWidget('AltInfoCreepShieldBacker')
	local shieldInset			= object:GetWidget('AltInfoCreepShieldInset')
	local shieldCorners			= object:GetWidget('AltInfoCreepShieldCorners')
	
	local expIndicator			= object:GetWidget('AltInfoCreepExp')
	local expIndicatorShadow	= object:GetWidget('AltInfoCreepExpShadow')
	
	--]]
	
	local healthGlow			= object:GetWidget('AltInfoCreepHealthGlow')
	
	local levelShadow			= object:GetWidget('AltInfoCreepLevelShadow')
	local levelBacker			= object:GetWidget('AltInfoCreepLevelBacker')
	local levelInset			= object:GetWidget('AltInfoCreepLevelInset')
	local levelBar				= object:GetWidget('AltInfoCreepLevelBar')
	local levelMaxWidth			= levelBar:GetWidth()
	local levelCorners			= object:GetWidget('AltInfoCreepLevelCorners')
	local levelGlow				= object:GetWidget('AltInfoCreepLevelGlow')
	local levelGlowContainer	= object:GetWidget('AltInfoCreepLevelGlowContainer')
	
	healthBar:RegisterWatchLua('AltInfoCreep', function(widget, trigger) widget:SetWidthF(healthBarMaxWidth * trigger.healthPercent) end, true, nil, 'healthPercent')
	
	healthBar:RegisterWatchLua('AltInfoCreep', function(widget, trigger)
		local relation = trigger.relation
		if relation == 1 then
			widget:SetColor(styles_healthBarAllyColor2)
		elseif relation == 2 then
			widget:SetColor(styles_healthBarEnemyColor2)
		else
			widget:SetColor(styles_healthBarNeutralColor)
		end
	end, true, nil, 'relation')
	
	healthBarBacker:RegisterWatchLua('AltInfoCreep', function(widget, trigger)	-- Would ideally be the frame itself
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
	
	shieldGlow:RegisterWatchLua('AltInfoCreep', function(widget, trigger)	-- Would ideally be the frame itself
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
	
	healthGlow:RegisterWatchLua('AltInfoCreep', function(widget, trigger)	-- Would ideally be the frame itself
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
	
	
	
	levelGlow:RegisterWatchLua('AltInfoCreep', function(widget, trigger)	-- Would ideally be the frame itself
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
	
	shieldBar:RegisterWatchLua('AltInfoCreep', function(widget, trigger) widget:SetWidthF(trigger.shieldPercent * shieldBarMaxWidth) end)

	object:RegisterWatchLua('AltInfoCreep', function(widget, trigger)
		local shieldVis = (trigger.maxShield > 0)
		
		shieldBar:SetVisible(shieldVis)
		shieldPipContainer:SetVisible(shieldVis)
		shieldShadow:SetVisible(shieldVis)
		shieldBacker:SetVisible(shieldVis)
		shieldInset:SetVisible(shieldVis)
		shieldCorners:SetVisible(shieldVis)
	end, true, nil, 'maxShield')
	
	shieldPipContainer:RegisterWatchLua('AltInfoCreep', function(widget, trigger)
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
	
	shieldGlow:RegisterWatchLua('AltInfoCreep', function(widget, trigger) widget:SetVisible(trigger.maxShield > 0) end, true, nil, 'maxShield')
	shieldGlowContainer:RegisterWatchLua('AltInfoCreep', function(widget, trigger) widget:SetVisible(trigger.isHovering) end, true, nil, 'isHovering')
	expIndicator:RegisterWatchLua('AltInfoCreep', function(widget, trigger) widget:SetVisible(trigger.isInExpRange) end, true, nil, 'isInExpRange')
	expIndicatorShadow:RegisterWatchLua('AltInfoCreep', function(widget, trigger) widget:SetVisible(trigger.isInExpRange) end, true, nil, 'isInExpRange')
	
	--]]
	
	object:RegisterWatchLua('AltInfoCreep', function(widget, trigger)
		local levelVis = (trigger.level > 0)
		levelShadow:SetVisible(levelVis)
		levelBacker:SetVisible(levelVis)
		levelInset:SetVisible(levelVis)
		levelGlow:SetVisible(levelVis)
		levelCorners:SetVisible(levelVis)
		levelBar:SetVisible(levelVis)
	end, true, nil, 'level')
	
	levelBar:RegisterWatchLua('AltInfoCreep', function(widget, trigger) widget:SetWidthF(trigger.level * levelMaxWidth) end, true, nil, 'level')
	levelGlowContainer:RegisterWatchLua('AltInfoCreep', function(widget, trigger) widget:SetVisible(trigger.isHovering) end, true, nil, 'isHovering')

	healthGlow:RegisterWatchLua('AltInfoCreep', function(widget, trigger)
		widget:SetVisible( trigger.isHovering )
	end, true, nil, 'isHovering')
	

end

altInfoCreepRegister(object)