-- Auto-Level Path Panel (6/2013 update)

function autoLevelPathRegisterSkill(object, index)

	local container		= object:GetWidget('autoLevelSkill'..index)
	local icon			= object:GetWidget('autoLevelSkill'..index..'Icon')
	local level			= object:GetWidget('autoLevelSkill'..index..'Level')
	-- local hotkey		= object:GetWidget('autoLevelSkill'..index..'Hotkey')
	local canLevel		= object:GetWidget('autoLevelSkill'..index..'CanLevel')
	
	local button			= object:GetWidget('autoLevelSkill'..index..'Button')
	local buttonBody		= object:GetWidget('autoLevelSkill'..index..'ButtonBody')
	
	local lastSkillID		= nil
	local statusLevelGroup	= LuaTrigger.GetTrigger('autoSkillStatusLevel'..index)
	local triggerIcon		= nil
	
	container:RegisterWatchLua('AutoLevelBuild', function(widget, trigger)
		local skillID		= trigger['level'..index]  - 1
		
		if triggerInventory ~= nil then
			icon:UnregisterWatchLua('HeroInventory'..skillID)
			-- hotkey:UnregisterWatchLua('HeroInventory'..skillID)
		end
		

		if statusLevelGroup	~= nil then
			LuaTrigger.DestroyGroupTrigger(statusLevelGroup)
		end
		
		statusLevelGroup	= libGeneral.createGroupTrigger('autoSkillStatusLevel'..index, { 'HeroUnit', 'HeroInventory'..skillID })
		triggerInventory			= LuaTrigger.GetTrigger('HeroInventory'..skillID)
		
		button:RegisterWatchLua('autoSkillStatusLevel'..index, function(widget, groupTrigger)
			local triggerLevel	= groupTrigger[1]
			local triggerStatus	= groupTrigger[2]

			widget:SetEnabled(triggerStatus.canLevelUp and triggerLevel.level == index)
		end)
		
		canLevel:RegisterWatchLua('autoSkillStatusLevel'..index, function(widget, groupTrigger)
			local triggerLevel	= groupTrigger[1]
			local triggerStatus	= groupTrigger[2]

			widget:SetVisible(triggerStatus.canLevelUp and triggerLevel.level == index)
		end)
		
		icon:RegisterWatchLua('HeroInventory'..skillID, function(widget, trigger) widget:SetTexture(trigger.icon) end, false, nil, 'icon')
		-- hotkey:RegisterWatchLua('HeroInventory'..skillID, function(widget, trigger) widget:SetText(trigger.binding1) end, false, nil, 'binding1')
		
		
		button:SetCallback('onclick', function(widget)
			PlaySound('/ui/sounds/sfx_button_generic.wav')
			widget:UICmd("LevelUpAbility("..skillID..")")
		end)
		
		button:SetCallback('onmouseover', function(widget)
			Trigger('abilityTipShow', 2, skillID)
		end)
		
		
		button:SetCallback('onmouseout', function(widget)
			Trigger('abilityTipHide')
		end)
		
		lastSkillID = skillID
		
		triggerInventory:Trigger(true)
		statusLevelGroup:Trigger(true)
	end, false, nil, 'level'..index)

	level:RegisterWatchLua('HeroUnit', function(widget, trigger)
		if trigger.level >= index then
			widget:SetColor(styles_colors_greenText)
		else
			widget:SetColor(styles_colors_whiteText)
		end
	end, false, nil, 'level')
	
	icon:RegisterWatchLua('HeroUnit', function(widget, trigger)
		if trigger.level >= index then
			widget:SetRenderMode('normal')
		else
			widget:SetRenderMode('grayscale')
		end
	end, false, nil, 'level')

end

function autoLevelPathRegister(object)

	for i=1,15,1 do
		autoLevelPathRegisterSkill(object, i)
	end

end

autoLevelPathRegister(object)