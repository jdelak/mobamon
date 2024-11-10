-- Moving Altinfo stuff here over time so there's better, clearer separation between Lua and XML.  wip atm...
local interface = object

local altInfoHeroMapTrigger = LuaTrigger.GetTrigger('altInfoHeroMapTrigger') or LuaTrigger.CreateCustomTrigger('altInfoHeroMapTrigger', {
	{	name	= 'stunVis',				type	= 'boolean'	},
	{	name	= 'healthVis',				type	= 'boolean'	}
})

altInfoHeroMapTrigger.stunVis				= false
altInfoHeroMapTrigger.healthVis				= true

--[[
========================
Stun Visible Changes
========================
]]--
interface:GetWidget('AltInfoHeroContainer'):RegisterWatchLua('altInfoHeroMapTrigger', function(widget, trigger)
	widget:SetVisible(trigger.healthVis)	
end, true, nil, 'healthVis')

interface:GetWidget('AltInfoHeroStun'):RegisterWatchLua('altInfoHeroMapTrigger', function(widget, trigger)	
	if (trigger.stunVis) then		
		widget:UnregisterWatchLua('AltInfoHero')
		widget:RegisterWatchLua('AltInfoHero', function(widget, trigger2)
			if (trigger2.shield > 0) then
				widget:SetY('1.0h')
			else
				widget:SetY('0.4h')
			end
		end, false, nil, 'shield')
	else
		widget:UnregisterWatchLua('AltInfoHero')
		widget:SetVisible(0)
	end
end, false, nil, 'stunVis')

interface:GetWidget('AltInfoHeroStunBar'):RegisterWatchLua('altInfoHeroMapTrigger', function(widget, trigger)
	if (trigger.stunVis) then	
		widget:UnregisterWatchLua('AltInfoHero')
		widget:RegisterWatchLua('AltInfoHero', function(widget, trigger2)
			if (trigger2.isStunned) then				
				widget:GetParent():SetVisible(1)
				widget:SetWidth(ToPercent(trigger2.stunnedDurationPercent))
			else				
				widget:GetParent():SetVisible(0)
			end
		end, false, nil, 'isStunned', 'stunnedDurationPercent')
	else
		widget:UnregisterWatchLua('AltInfoHero')
		widget:GetParent():SetVisible(0)
	end
end, false, nil, 'stunVis')

interface:GetWidget('AltInfoHeroStunBar02'):RegisterWatchLua('altInfoHeroMapTrigger', function(widget, trigger)
	if (trigger.stunVis) then		
		widget:UnregisterWatchLua('AltInfoHero')
		widget:RegisterWatchLua('AltInfoHero', function(widget, trigger2)
			if (trigger2.stunnedMaxDuration > 0) then
				widget:SetUScale(1000 / (trigger2.stunnedMaxDuration) )
			end
		end, false, nil, 'stunnedMaxDuration')
	else
		widget:UnregisterWatchLua('AltInfoHero')
	end
end, false, nil, 'stunVis')

altInfoHeroMapTrigger:Trigger(false)