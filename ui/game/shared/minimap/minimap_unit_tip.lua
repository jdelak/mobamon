-- Minimap Unit Tip

function minimapUnitTipRegister(object)
	local container			= object:GetWidget('minimapUnitTip')
	local name				= object:GetWidget('minimapUnitTipName')
	local icon				= object:GetWidget('minimapUnitTipIcon')
	local healthContainer	= object:GetWidget('minimapUnitTipHealthContainer')
	local healthBar			= object:GetWidget('minimapUnitTipHealthBar')
	local manaContainer		= object:GetWidget('minimapUnitTipManaContainer')
	local manaBar			= object:GetWidget('minimapUnitTipManaBar')
	local itemContainer		= object:GetWidget('minimapUnitTipItemContainer')
	local items				= {}
	
	for i=1,7,1 do
		items[i] = object:GetWidget('minimapUnitTipItem'..i)
	end
	
	container:RegisterWatchLua('MinimapHover', function(widget, trigger) widget:SetVisible(trigger.show) end, true, nil, 'show')
	itemContainer:RegisterWatchLua('MinimapHover', function(widget, trigger) widget:SetVisible(trigger.isHero) end, true, nil, 'isHero')
	name:RegisterWatchLua('MinimapHover', function(widget, trigger) widget:SetText(trigger.name) end, true, nil, 'name')
	icon:RegisterWatchLua('MinimapHover', function(widget, trigger)
		widget:SetTexture(trigger.iconPath)	-- rmm icon doesn't retrigger when blank
	end, true, nil, 'iconPath')
	healthBar:RegisterWatchLua('MinimapHover', function(widget, trigger) widget:SetWidth(ToPercent(trigger.healthPercent)) end, true, nil, 'healthPercent')
	healthContainer:RegisterWatchLua('MinimapHover', function(widget, trigger) widget:SetVisible(not trigger.isShop) end, true, nil, 'isShop')
	manaBar:RegisterWatchLua('MinimapHover', function(widget, trigger) widget:SetWidth(ToPercent(trigger.manaPercent)) end, true, nil, 'manaPercent')
	manaContainer:RegisterWatchLua('MinimapHover', function(widget, trigger) widget:SetVisible(trigger.isHero) end, true, nil, 'isHero')
	
	container:RegisterWatch('MinimapHoverItems', function(widget, ...)
		for i=1,7,1 do
			if string.len(arg[i]) > 0 then
				items[i]:SetTexture(arg[i])
				items[i]:SetColor('1 1 1 1')
			else
				items[i]:SetTexture('/ui/shared/textures/pack2.tga')
				items[i]:SetColor('.6 .6 .6 .5')
			end
		end
	end)
end


minimapUnitTipRegister(object)