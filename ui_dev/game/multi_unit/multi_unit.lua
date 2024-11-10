local interface = object

local function InitMultiUnit()
	-- Health
	local function SelectedHealth(targetWidget, sourceWidget, health, maxHealth, healthPercent, healthShadow)
		local health, maxHealth, tempHealthPercent, tempHealthShadow = AtoN(health), AtoN(maxHealth), AtoN(healthPercent), ToPercent(AtoN(healthPercent))
		if (maxHealth > 0) then
			interface:GetWidget('game_botright_health_bar_bg_'..targetWidget):SetVisible(true)
			interface:GetWidget('game_botright_health_bar_backer_'..targetWidget):SetColor(GetHealthBarColor(healthPercent))
			interface:GetWidget('game_botright_health_bar_'..targetWidget):SetWidth(ToPercent(tempHealthPercent))
			interface:GetWidget('game_botright_health_bar_'..targetWidget):SetColor(GetHealthBarColor(healthPercent))	
			if (tempHealthPercent < 0) then
				interface:GetWidget('game_botright_health_label_'..targetWidget):SetText(Translate('game_invulnerable'))
			else
				interface:GetWidget('game_botright_health_label_'..targetWidget):SetText(ceil(health) .. '/' .. ceil(maxHealth))
			end		
		else
			interface:GetWidget('game_botright_health_bar_bg_'..targetWidget):SetVisible(false)
		end
	end
	interface:RegisterWatch('SelectedHealth0', function(...) SelectedHealth('0', ...) SelectedHealth('1', ...) end)

	-- Mana
	local function SelectedMana(targetWidget, sourceWidget, mana, maxMana, manaPercent, manaShadow)
		local mana, maxMana, tempManaPercent, tempManaShadow = AtoN(mana), AtoN(maxMana), ToPercent(AtoN(manaPercent)), ToPercent(AtoN(manaPercent))
		if (maxMana > 0) then		
			interface:GetWidget('game_botright_mana_bar_bg_'..targetWidget):SetVisible(true)
			interface:GetWidget('game_botright_mana_bar_'..targetWidget):SetWidth(tempManaPercent)
			interface:GetWidget('game_botright_mana_label_'..targetWidget):SetText(ceil(mana) .. '/' .. ceil(maxMana))		
		else
			interface:GetWidget('game_botright_mana_bar_bg_'..targetWidget):SetVisible(false)
		end
	end
	interface:RegisterWatch('SelectedMana0', function(...) SelectedMana('0', ...) end)

	local function SelectedLevel(targetWidget, sourceWidget, currentLevel, hasLevel)
		if (hasLevel) then
			local hasLevel = AtoB(hasLevel)
			interface:GetWidget('game_botright_level_bg_'..targetWidget):SetVisible(hasLevel)
			interface:GetWidget('game_botright_level_label_'..targetWidget):SetText(currentLevel)
		end
	end
	interface:RegisterWatch('SelectedLevel0', function(...) SelectedLevel('0', ...) SelectedLevel('1', ...) end)

	--Portrait
	local function SelectedIcon(targetWidget, sourceWidget, icon)
		if (icon) and NotEmpty(icon) then
			interface:GetWidget('game_botright_portrait_icon_'..targetWidget):SetTexture(icon)
			interface:GetWidget('game_botright_portrait_icon_'..targetWidget):SetVisible(true)
		else
			interface:GetWidget('game_botright_portrait_icon_'..targetWidget):SetVisible(false)
		end
	end
	interface:RegisterWatch('SelectedIcon0', function(...) SelectedIcon('0', ...) SelectedIcon('1', ...) end)

	local function UpdateGameCenterPortrait(targetWidget)
		if (Game.SelectedIllusion) then
			interface:GetWidget('game_botright_portrait_icon_'..targetWidget):SetColor('0.35 1.3 0.35')
			interface:GetWidget('game_botright_portrait_icon_'..targetWidget):UICmd("SetRenderMode('grayscale')")
		else
			interface:GetWidget('game_botright_portrait_icon_'..targetWidget):SetColor('white')
			interface:GetWidget('game_botright_portrait_icon_'..targetWidget):UICmd("SetRenderMode('normal')")
		end
	end

	local function SelectedIllusion(targetWidget, sourceWidget, isIllusion)
		local isIllusion = AtoB(isIllusion)
		Game.SelectedIllusion = isIllusion
		UpdateGameCenterPortrait(targetWidget)
	end
	interface:RegisterWatch('SelectedIllusion0', function(...) SelectedIllusion('0', ...) SelectedIllusion('1', ...) end)

	local function SelectedModel(sourceWidget, model)
		interface:GetWidget('game_botright_portrait_model'):UICmd("SetModel('"..model.."')")
	end
	interface:RegisterWatch('SelectedModel', SelectedModel)

	local function SelectedPlayerInfo(sourceWidget, playerName, playerColor)
		interface:GetWidget('game_botright_portrait_model'):UICmd("SetTeamColor('"..playerColor.."')")
	end
	interface:RegisterWatch('SelectedPlayerInfo', SelectedPlayerInfo)

	local function SelectedEffect(sourceWidget, SelectedEffect)
		if (SelectedEffect) then
			interface:GetWidget('game_botright_portrait_model'):UICmd("SetEffect('"..SelectedEffect.."')")
		end
	end
	interface:RegisterWatch('SelectedEffect', SelectedEffect)

	local function SelectedLifetime(sourceWidget, remainingLifetime, actualLifetime, remainingPercent)
		local remainingLifetime, actualLifetime, remainingPercent = AtoN(remainingLifetime), AtoN(actualLifetime), AtoN(remainingPercent)
		if (actualLifetime <= 0) then
			interface:GetWidget('game_botright_life_bar_backer'):SetVisible(false)
		else
			interface:GetWidget('game_botright_life_bar_backer'):SetVisible(true)
			interface:GetWidget('game_botright_life_bar_ring'):SetValue(remainingPercent)
			interface:GetWidget('game_botright_life_bar_label'):SetText(ceil(remainingLifetime / 1000) .. ' s')
		end
	end
	interface:RegisterWatch('SelectedLifetime', SelectedLifetime)

	local function SelectedName(targetWidget, sourceWidget, name)
		local label = interface:GetWidget('game_botright_name_label_'..targetWidget)
		local labelB = interface:GetWidget('game_botright_name_label_'..targetWidget..'B')
		if (label) and (name) then
			label:SetText(name)
		end
		if (labelB) and (name) then
			labelB:SetText(name)
		end
	end
	interface:RegisterWatch('SelectedName0', function(...) SelectedName('0', ...) SelectedName('1', ...) end)
	

	interface:GetWidget('selection_info_right'):SetAlign('left')

	interface:GetWidget('game_selected_info_unit'):SetAlign('left')
	interface:GetWidget('game_selected_info_unit_bg'):SetAlign('left')
	interface:GetWidget('game_selected_info_unit_icon'):SetAlign('left')
	interface:GetWidget('game_selected_info_unit_icon'):SetX('17.1h')
	interface:GetWidget('game_botright_health_bar_bg_0'):SetAlign('left')
	interface:GetWidget('game_botright_health_bar_bg_0'):SetX('1.2h')
	interface:GetWidget('game_botright_mana_bar_bg_0'):SetX('1.2h')		
	interface:GetWidget('game_botright_mana_bar_bg_0'):SetAlign('left')	
	interface:GetWidget('game_botright_level_bg_0'):SetAlign('left')
	interface:GetWidget('game_botright_level_bg_0'):SetX('0.7h')	
	interface:GetWidget('game_botright_name_label_0'):SetVisible(false)
	interface:GetWidget('game_botright_name_label_0B'):SetAlign('left')
	interface:GetWidget('game_botright_name_label_0B'):SetX('0')
	interface:GetWidget('game_botright_name_label_0B'):SetVisible(true)
	interface:GetWidget('game_selected_info_unit_stats'):SetAlign('left')
	interface:GetWidget('game_selected_info_unit_stats'):SetX('15.0h')
	
	interface:GetWidget('game_selected_info_building'):SetAlign('left')
	interface:GetWidget('game_selected_info_building_bg'):SetAlign('left')
	interface:GetWidget('game_selected_info_building_icon'):SetAlign('left')
	interface:GetWidget('game_selected_info_building_icon'):SetX('17.1h')
	interface:GetWidget('game_botright_health_bar_bg_1'):SetAlign('left')
	interface:GetWidget('game_botright_health_bar_bg_1'):SetX('1.2h')
	interface:GetWidget('game_selected_info_building_shared_abilities'):SetAlign('left')
	interface:GetWidget('game_selected_info_building_shared_abilities'):SetX('1.7h')
	interface:GetWidget('game_selected_info_building_shared_abilities_pos'):SetAlign('left')
	interface:GetWidget('game_selected_info_building_shared_abilities_pos'):SetX('-0.4h')
	interface:GetWidget('game_botright_level_bg_1'):SetAlign('left')
	interface:GetWidget('game_botright_level_bg_1'):SetX('0.7h')
	interface:GetWidget('game_botright_name_label_1B'):SetAlign('left')
	interface:GetWidget('game_botright_name_label_1B'):SetX('0')
	interface:GetWidget('game_botright_name_label_1B'):SetVisible(true)
	interface:GetWidget('game_botright_name_label_1'):SetVisible(false)
	interface:GetWidget('game_selected_info_building_stats'):SetAlign('left')
	interface:GetWidget('game_selected_info_building_stats'):SetX('16.6h')		
	interface:GetWidget('game_selected_info_mult_backer'):SetAlign('left')
	interface:GetWidget('game_selected_info_mult_units'):SetAlign('left')
	interface:GetWidget('game_selected_info_mult_units'):SetX('2.5h')
	
	
	
end

InitMultiUnit()

