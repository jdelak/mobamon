-- AltInfoLargeUnit

function altInfoLargeUnitRegister(object)
	local healthBar				= object:GetWidget('AltInfoLargeUnitHealthBar')
	local healthBarBacker		= object:GetWidget('AltInfoLargeUnitHealthBarBacker')
	local healthBarMaxWidth		= healthBar:GetWidth()
	
	local healthPips		= object:GetWidget('AltInfoLargeUnitHealthPips')
	local healthPerPip		= 1500
	
	---[[
	local shieldPipContainer	= object:GetWidget('AltInfoLargeUnitShieldPipContainer')
	local shieldBar				= object:GetWidget('AltInfoLargeUnitShieldBar')
	local shieldBarMaxWidth		= shieldBar:GetWidth()
	local shieldPerPip			= 250
	
	local shieldShadow			= object:GetWidget('AltInfoLargeUnitShieldShadow')
	local shieldGlow			= object:GetWidget('AltInfoLargeUnitShieldGlow')
	local shieldGlowContainer	= object:GetWidget('AltInfoLargeUnitShieldGlowContainer')
	local shieldBacker			= object:GetWidget('AltInfoLargeUnitShieldBacker')
	local shieldInset			= object:GetWidget('AltInfoLargeUnitShieldInset')
	local shieldCorners			= object:GetWidget('AltInfoLargeUnitShieldCorners')
	
	-- local expIndicator		= object:GetWidget('AltInfoLargeUnitExp')
	-- local expIndicatorShadow	= object:GetWidget('AltInfoLargeUnitExpShadow')
	
	--]]
	
	local healthGlow			= object:GetWidget('AltInfoLargeUnitHealthGlow')
	
	local levelShadow			= object:GetWidget('AltInfoLargeUnitLevelShadow')
	local levelBacker			= object:GetWidget('AltInfoLargeUnitLevelBacker')
	local levelInset			= object:GetWidget('AltInfoLargeUnitLevelInset')
	local levelBar				= object:GetWidget('AltInfoLargeUnitLevelBar')
	local lifetimeMaxWidth		= levelBar:GetWidth()
	local levelCorners			= object:GetWidget('AltInfoLargeUnitLevelCorners')
	local levelGlow				= object:GetWidget('AltInfoLargeUnitLevelGlow')
	local levelGlowContainer	= object:GetWidget('AltInfoLargeUnitLevelGlowContainer')
	
	
	healthBar:RegisterWatchLua('AltInfoLargeUnit', function(widget, trigger) widget:SetWidthF(healthBarMaxWidth * trigger.healthPercent) end, true, nil, 'healthPercent')
	
	healthPips:RegisterWatchLua('AltInfoLargeUnit', function(widget, trigger)
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
		if not styles_healthBarAllyColor2 then return end --throws error occasionally otherwise
		if lastRelation == 1 then
			widget:SetColor(styles_healthBarAllyColor2)
		elseif lastRelation == 2 then
			widget:SetColor(styles_healthBarEnemyColor2)
		else
			widget:SetColor(styles_healthBarNeutralColor)
		end
	end)
	
	healthBar:RegisterWatchLua('AltInfoLargeUnit', function(widget, trigger)
		local relation = trigger.relation
		lastRelation = relation
		local isTeamTapped = trigger.isTeamTapped
		local isOurTeamTap = trigger.isOurTeamTap
		if relation == 1 then
			widget:SetColor(styles_healthBarAllyColor2)
		elseif isOurTeamTap then
			widget:SetColor(styles_healthBarEnemyColor)
		elseif relation == 2 then
			widget:SetColor(styles_healthBarEnemyColor2)
		elseif isTeamTapped then
			widget:SetColor(styles_healthOtherTapColorR, styles_healthOtherTapColorG, styles_healthOtherTapColorB)
		else
			widget:SetColor(styles_healthBarNeutralColor)
		end
		--local relation = trigger.relation
		--if relation == 1 then
		--	widget:SetColor(styles_healthBarColorR, styles_healthBarColorG, styles_healthBarColorB)
		--elseif relation == 2 then
		--	widget:SetColor(styles_healthBarColorEnemyR, styles_healthBarColorEnemyG, styles_healthBarColorEnemyB)
		--else
		--	widget:SetColor(styles_healthBarColorNeutralR, styles_healthBarColorNeutralG, styles_healthBarColorNeutralB)
		--end
	end, true, nil, 'relation', 'isTeamTapped', 'isOurTeamTap' )
	
	healthBarBacker:RegisterWatchLua('AltInfoLargeUnit', function(widget, trigger)	-- Would ideally be the frame itself
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
	
	shieldGlow:RegisterWatchLua('AltInfoLargeUnit', function(widget, trigger)	-- Would ideally be the frame itself
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
	
	healthGlow:RegisterWatchLua('AltInfoLargeUnit', function(widget, trigger)	-- Would ideally be the frame itself
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
	
	levelGlow:RegisterWatchLua('AltInfoLargeUnit', function(widget, trigger)	-- Would ideally be the frame itself
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
	
	object:RegisterWatchLua('AltInfoLargeUnit', function(widget, trigger)
		local shieldVis = (trigger.maxShield > 0)
		
		shieldBar:SetVisible(shieldVis)
		shieldPipContainer:SetVisible(shieldVis)
		shieldShadow:SetVisible(shieldVis)
		shieldBacker:SetVisible(shieldVis)
		shieldInset:SetVisible(shieldVis)
		shieldCorners:SetVisible(shieldVis)
	end, true, nil, 'maxShield')
	
	shieldBar:RegisterWatchLua('AltInfoLargeUnit', function(widget, trigger) widget:SetWidthF(trigger.shieldPercent * shieldBarMaxWidth) end, true, nil, 'shieldPercent')

	shieldPipContainer:RegisterWatchLua('AltInfoLargeUnit', function(widget, trigger)
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
	
	shieldGlow:RegisterWatchLua('AltInfoLargeUnit', function(widget, trigger) widget:SetVisible(trigger.maxShield > 0) end, true, nil, 'maxShield')
	shieldGlowContainer:RegisterWatchLua('AltInfoLargeUnit', function(widget, trigger) widget:SetVisible(trigger.isHovering) end, true, nil, 'isHovering')

	-- expIndicator:RegisterWatchLua('AltInfoLargeUnit', function(widget, trigger) widget:SetVisible(trigger.isInExpRange) end, true, nil, 'isInExpRange')
	-- expIndicatorShadow:RegisterWatchLua('AltInfoLargeUnit', function(widget, trigger) widget:SetVisible(trigger.isInExpRange) end, true, nil, 'isInExpRange')
	
	--]]

	object:RegisterWatchLua('AltInfoLargeUnit', function(widget, trigger)
		local showLifetime = (trigger.lifetimepercent > 0)
		levelShadow:SetVisible(showLifetime)
		levelBacker:SetVisible(showLifetime)
		levelInset:SetVisible(showLifetime)
		levelGlow:SetVisible(showLifetime)
		levelCorners:SetVisible(showLifetime)
		levelBar:SetVisible(showLifetime)
	end, true, nil, 'lifetimepercent')
	
	levelBar:RegisterWatchLua('AltInfoLargeUnit', function(widget, trigger) widget:SetWidthF(math.min(trigger.lifetimepercent * lifetimeMaxWidth, lifetimeMaxWidth)) end, true, nil, 'lifetimepercent')
	
	levelGlowContainer:RegisterWatchLua('AltInfoLargeUnit', function(widget, trigger) widget:SetVisible(trigger.isHovering) end, true, nil, 'isHovering')
	
	healthGlow:RegisterWatchLua('AltInfoLargeUnit', function(widget, trigger)
		widget:SetVisible( trigger.isHovering )
	end, true, nil, 'isHovering')
end

altInfoLargeUnitRegister(object)