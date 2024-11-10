-- AltInfoGeneric (creep)

function altInfoGenericRegister(object)
	local healthBar				= object:GetWidget('AltInfoGenericHealthBar')
	local healthBarBacker		= object:GetWidget('AltInfoGenericHealthBarBacker')
	local healthBarMaxWidth		= healthBar:GetWidth()
	
	local shieldPipContainer	= object:GetWidget('AltInfoGenericShieldPipContainer')
	local shieldBar				= object:GetWidget('AltInfoGenericShieldBar')
	local shieldBarMaxWidth		= shieldBar:GetWidth()
	local shieldPerPip			= 300
	
	local shieldShadow			= object:GetWidget('AltInfoGenericShieldShadow')
	local shieldGlow			= object:GetWidget('AltInfoGenericShieldGlow')
	local shieldGlowContainer	= object:GetWidget('AltInfoGenericShieldGlowContainer')	-- Grouptriggers don't work in altinfo
	local shieldBacker			= object:GetWidget('AltInfoGenericShieldBacker')
	local shieldInset			= object:GetWidget('AltInfoGenericShieldInset')
	
	local expIndicator			= object:GetWidget('AltInfoGenericExp')
	local expIndicatorShadow	= object:GetWidget('AltInfoGenericExpShadow')
	
	local healthGlow			= object:GetWidget('AltInfoGenericHealthGlow')
	
	healthBar:RegisterWatchLua('AltInfoGeneric', function(widget, trigger) widget:SetWidthF(healthBarMaxWidth * trigger.healthPercent) end, true, nil, 'healthPercent')
	
	local lastRelation = nil
	healthBar:RegisterWatchLua('updateHealthColors', function(widget)
		if relation == 1 then
			widget:SetColor(styles_healthBarAllyColor2)
		elseif isMyTap then
			widget:SetColor(styles_healthBarEnemyColor2)
		elseif relation == 2 then
			widget:SetColor(styles_healthBarEnemyColor2)
		elseif isHeroTapped then
			widget:SetColor(styles_healthOtherTapColorR, styles_healthOtherTapColorG, styles_healthOtherTapColorB)
		else
			widget:SetColor(styles_healthBarNeutralColor)
		end
	end)
	
	healthBar:RegisterWatchLua('AltInfoGeneric', function(widget, trigger)
		local relation = trigger.relation
		lastRelation = relation
		local isHeroTapped = trigger.isHeroTapped
		local isMyTap = trigger.isMyTap
		if relation == 1 then
			widget:SetColor(styles_healthBarAllyColor2)
		elseif isMyTap then
			widget:SetColor(styles_healthBarMyTapColor)
		elseif relation == 2 then
			widget:SetColor(styles_healthBarEnemyColor2)
		elseif isHeroTapped then
			widget:SetColor(styles_healthOtherTapColorR, styles_healthOtherTapColorG, styles_healthOtherTapColorB)
		else
			widget:SetColor(styles_healthBarNeutralColor)
		end
	end, true, nil, 'relation', 'isHeroTapped', 'isMyTap')
	
	local lastRelation = nil
	healthBarBacker:RegisterWatchLua('updateHealthColors', function(widget)
		if lastRelation == 1 then
			widget:SetColor(styles_healthBarAllyColorBack)
		elseif relation == 2 then
			widget:SetColor(styles_healthBarEnemyColorBack)
		else
			widget:SetColor(styles_healthBarNeutralColorBack)
		end
	end)
	
	healthBarBacker:RegisterWatchLua('AltInfoGeneric', function(widget, trigger)	-- Would ideally be the frame itself
		local relation		= trigger.relation
		lastRelation = relation
		local isHeroTapped = trigger.isHeroTapped
		local isMyTap = trigger.isMyTap	
		local colorR		= nil
		local colorG		= nil
		local colorB		= nil	
		
		if relation == 1 then
			widget:SetColor(styles_healthBarAllyColorBack)
		elseif isMyTap then
			colorR = styles_healthBackerColorEnemyR	-- temp
			colorG = styles_healthBackerColorEnemyG	-- temp
			colorB = styles_healthBackerColorEnemyB	-- temp
		elseif relation == 2 then
			widget:SetColor(styles_healthBarEnemyColorBack)
		elseif isHeroTapped then
			colorR = styles_healthBackerColorOtherTapR
			colorG = styles_healthBackerColorOtherTapG
			colorB = styles_healthBackerColorOtherTapB
		else
			widget:SetColor(styles_healthBarNeutralColorBack)
		end
		if colorR then 
			widget:SetColor(colorR, colorG, colorB)
		end
		
	end, true, nil, 'relation', 'isHeroTapped', 'isMyTap')
	
	shieldGlow:RegisterWatchLua('AltInfoGeneric', function(widget, trigger)	-- Would ideally be the frame itself
		local relation		= trigger.relation
		local isHeroTapped = trigger.isHeroTapped
		local isMyTap = trigger.isMyTap
		local colorR		= styles_glowNeutralR
		local colorG		= styles_glowNeutralG
		local colorB		= styles_glowNeutralB
		if relation == 1 then
			colorR = styles_glowAllyR
			colorG = styles_glowAllyG
			colorB = styles_glowAllyB
		elseif isMyTap then
			colorR = styles_healthMyTapColorR
			colorG = styles_healthMyTapColorG
			colorB = styles_healthMyTapColorB
		elseif relation == 2 then
			colorR = styles_glowEnemyR
			colorG = styles_glowEnemyG
			colorB = styles_glowEnemyB
		elseif isHeroTapped then
			colorR = styles_healthOtherTapColorR
			colorG = styles_healthOtherTapColorG
			colorB = styles_healthOtherTapColorB
		end
		
		widget:SetColor(colorR, colorG, colorB)
		widget:SetBorderColor(colorR, colorG, colorB)
	end, true, nil, 'relation', 'isHeroTapped', 'isMyTap')

	healthGlow:RegisterWatchLua('AltInfoGeneric', function(widget, trigger)	-- Would ideally be the frame itself
		local relation		= trigger.relation
		local isHeroTapped = trigger.isHeroTapped
		local isMyTap = trigger.isMyTap
		local colorR		= styles_glowNeutralR
		local colorG		= styles_glowNeutralG
		local colorB		= styles_glowNeutralB
		if relation == 1 then
			colorR = styles_glowAllyR
			colorG = styles_glowAllyG
			colorB = styles_glowAllyB
		elseif isMyTap then
			colorR = styles_healthMyTapColorR
			colorG = styles_healthMyTapColorG
			colorB = styles_healthMyTapColorB
		elseif relation == 2 then
			colorR = styles_glowEnemyR
			colorG = styles_glowEnemyG
			colorB = styles_glowEnemyB
		elseif isHeroTapped then
			colorR = styles_healthOtherTapColorR
			colorG = styles_healthOtherTapColorG
			colorB = styles_healthOtherTapColorB
		end
		
		widget:SetColor(colorR, colorG, colorB)
		widget:SetBorderColor(colorR, colorG, colorB)	
	end, true, nil, 'relation', 'isHeroTapped', 'isMyTap')
	
	shieldBar:RegisterWatchLua('AltInfoGeneric', function(widget, trigger) widget:SetWidthF(trigger.shieldPercent * shieldBarMaxWidth) end, true, nil, 'shieldPercent')
	shieldBar:RegisterWatchLua('AltInfoGeneric', function(widget, trigger)
		local showWidget = (trigger.maxShield > 0)
		widget:SetVisible(showWidget)
		shieldPipContainer:SetVisible(showWidget)
		shieldShadow:SetVisible(showWidget)
		shieldBacker:SetVisible(showWidget)
		shieldInset:SetVisible(showWidget)
	end, true, nil, 'maxShield')
	
	expIndicator:RegisterWatchLua('AltInfoGeneric', function(widget, trigger) widget:SetVisible(trigger.isInExpRange) end, true, nil, 'relation')
	expIndicatorShadow:RegisterWatchLua('AltInfoGeneric', function(widget, trigger) widget:SetVisible(trigger.isInExpRange) end, true, nil, 'relation')
	
	healthGlow:RegisterWatchLua('AltInfoGeneric', function(widget, trigger)
		widget:SetVisible( trigger.isHovering )
	end, true, nil, 'isHovering')
	
	shieldPipContainer:RegisterWatchLua('AltInfoGeneric', function(widget, trigger)
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
	
	shieldGlow:RegisterWatchLua('AltInfoGeneric', function(widget, trigger) widget:SetVisible(trigger.maxShield > 0) end, true, nil, 'maxShield')
	
	shieldGlowContainer:RegisterWatchLua('AltInfoGeneric', function(widget, trigger) widget:SetVisible(trigger.isHovering) end, true, nil, 'isHovering')
end

altInfoGenericRegister(object)