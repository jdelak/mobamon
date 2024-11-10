-- Ability tips

local function abilityTipRegister(object)
	local container					= object:GetWidget('abilityLevelUpTip')
	local channelOffset				= object:GetWidget('abilityTipChannelOffset')
	local name						= object:GetWidget('abilityTipName')
	local icon						= object:GetWidget('abilityTipIcon')
	local cost						= object:GetWidget('abilityTipManaCost')
	local binding					= object:GetWidget('abilityTipBinding')
	local description				= object:GetWidget('abilityTipDescription')
	local darkFrame					= object:GetWidget('abilityTipDarkFrame')

	local cooldown					= object:GetWidget('abilityTipCooldown')
	local cooldownContainer	= object:GetWidget('abilityTipCooldownContainer')	
	
	local function watchRegister(triggerName, heroIndex, abilityID)

		local triggerDescription = triggerName .. heroIndex
		
		if (not triggerDescription) then
			return
		end
		
		container:UnregisterAllWatchLuaByKey('main_ability_tooltip')
		container:UnregisterAllWatchLuaByKey('main_ability_tooltip_pet')
		
		binding:SetVisible(1)
		cost:SetVisible(1)
		
		name:RegisterWatchLua(triggerDescription, function(widget, trigger) widget:SetText(trigger['ability' .. abilityID ..  'DisplayName']) end, true, 'main_ability_tooltip', 'ability' .. abilityID ..  'DisplayName')
		icon:RegisterWatchLua(triggerDescription, function(widget, trigger) widget:SetTexture(trigger['ability' .. abilityID ..  'IconPath']) end, true, 'main_ability_tooltip', 'ability' .. abilityID ..  'IconPath')
		cost:RegisterWatchLua(triggerDescription, function(widget, trigger) widget:SetText(trigger['ability' .. abilityID ..  'ManaCost']) end, true, 'main_ability_tooltip', 'ability' .. abilityID ..  'ManaCost')
		binding:RegisterWatchLua(triggerDescription, function(widget, trigger) widget:SetText('') end, true, 'main_ability_tooltip', 'ability' .. abilityID ..  'ManaCost')
		description:RegisterWatchLua(triggerDescription, function(widget, trigger) widget:SetText(trigger['ability' .. abilityID ..  'Description']) end, true, 'main_ability_tooltip', 'ability' .. abilityID ..  'Description')
		
		cooldownContainer:RegisterWatchLua(triggerDescription, function(widget, trigger)
			widget:SetVisible(trigger['ability' .. abilityID ..  'Cooldown'] > 0)
		end, true, 'main_ability_tooltip', 'ability' .. abilityID ..  'Cooldown')
		
		cooldown:RegisterWatchLua(triggerDescription, function(widget, trigger)
			widget:SetText(Translate('general_seconds_amount', 'amount', math.ceil(trigger['ability' .. abilityID ..  'Cooldown'] / 1000)))
		end, true, 'main_ability_tooltip', 'ability' .. abilityID ..  'Cooldown')
		
		LuaTrigger.GetTrigger(triggerDescription):Trigger(true)
	end

	container:RegisterWatch('abilityTipShow', function(widget, triggerName, heroIndex, abilityID, showFrame)
		darkFrame:SetVisible((showFrame and true) or false)
		watchRegister(triggerName, heroIndex, abilityID)
		widget:SetVisible(true)
	end)
	
	container:RegisterWatch('abilityTipHide', function(widget)
		widget:SetVisible(false)
	end)
end

abilityTipRegister(object)


local function petTipRegister(object)
	local container					= object:GetWidget('abilityLevelUpTip')
	local channelOffset				= object:GetWidget('abilityTipChannelOffset')
	local name						= object:GetWidget('abilityTipName')
	local icon						= object:GetWidget('abilityTipIcon')
	local cost						= object:GetWidget('abilityTipManaCost')
	local binding					= object:GetWidget('abilityTipBinding')
	local description				= object:GetWidget('abilityTipDescription')

	local cooldown					= object:GetWidget('abilityTipCooldown')
	local cooldownContainer			= object:GetWidget('abilityTipCooldownContainer')	
	
	local function watchRegister(triggerName, heroIndex, abilityID)
		
		local triggerDescription 	= triggerName .. heroIndex
		local trigger 				= LuaTrigger.GetTrigger(triggerDescription)
		
		if (not triggerDescription) then
			return
		end
		
		local fieldPrefix = 'Active'
		if (abilityID == 1) then
			fieldPrefix = 'triggered'
		elseif (abilityID == 2) then
			fieldPrefix = 'passiveA'
		elseif (abilityID == 3) then
			fieldPrefix = 'passiveB'
		end	

		container:UnregisterAllWatchLuaByKey('main_ability_tooltip')
		container:UnregisterAllWatchLuaByKey('main_ability_tooltip_pet')
		
		cooldownContainer:SetVisible(0)
		binding:SetVisible(0)
		cost:SetVisible(0)
		
		name:RegisterWatchLua(triggerDescription, function(widget, trigger) widget:SetText(trigger[fieldPrefix .. 'Name']) end, true, 'main_ability_tooltip_pet', fieldPrefix ..  'Name')
		icon:RegisterWatchLua(triggerDescription, function(widget, trigger) widget:SetTexture(trigger[fieldPrefix ..  'Icon']) end, true, 'main_ability_tooltip_pet', fieldPrefix ..  'Icon')
		description:RegisterWatchLua(triggerDescription, function(widget, trigger) widget:SetText(trigger[fieldPrefix ..  'Description']) end, true, 'main_ability_tooltip_pet', fieldPrefix ..  'Description')

		LuaTrigger.GetTrigger(triggerDescription):Trigger(true)
	end

	container:RegisterWatch('petTipShow', function(widget, triggerName, heroIndex, abilityID)
		watchRegister(triggerName, heroIndex, tonumber(abilityID))
		widget:SetVisible(true)
	end)
	
	container:RegisterWatch('petTipHide', function(widget)
		widget:SetVisible(false)
	end)
end

petTipRegister(object)
