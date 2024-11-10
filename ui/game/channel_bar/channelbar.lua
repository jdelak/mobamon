-- Channel Bar
local floor = math.floor

function channelBarRegister(object)
	local container		= object:GetWidget('gameChannelBar')
	local bar			= object:GetWidget('gameChannelBarPercent')
	local label			= object:GetWidget('gameChannelBarLabel')
	local label2			= object:GetWidget('gameChannelBarLabel2')
	local icon			= object:GetWidget('gameChannelBarIcon')
	local lastID		= nil
	local visTrigger	= LuaTrigger.GetTrigger('channelBarVis')
	visTrigger.isChanneling = false
	visTrigger:Trigger()
	
	local triggerList	= {}
	
	local function containerUpdate(widget, trigger)
		local isActive			= trigger.isChanneling
		visTrigger.isChanneling = isActive
		visTrigger:Trigger()
	end
	
	local function barUpdate(widget, trigger)
		widget:SetWidth(ToPercent(trigger.channelPercent))
	end
	
	local function labelUpdate(widget, trigger)
		widget:SetText(trigger.displayName)
	end
	
	local function labelUpdate2(widget, trigger)
		widget:SetText(FtoA2(trigger.activeChannelTime/1000, 1, 1))
	end	
	
	local function iconUpdate(widget, trigger)
		if (not Empty(trigger.icon)) then
			widget:SetTexture(trigger.icon)
		else
			widget:SetTexture('$invis')
		end
	end	
	
	container:RegisterWatchLua('channelBarVis', function(widget, trigger)
		if trigger.isChanneling then
			widget:SetVisible(true)
		else
			widget:FadeOut(250)
		end
	end)
	
	local function channelRegister(index)
		local triggerInventory		= LuaTrigger.GetTrigger('ActiveInventory'..index)

		container:RegisterWatchLua('ActiveInventory'..index, function(widget, trigger)
			containerUpdate(widget, trigger)
		end, true, nil, 'isChanneling')
		
		bar:RegisterWatchLua('ActiveInventory'..index, function(widget, trigger)
			barUpdate(widget, trigger)
		end, true, nil, 'channelPercent')
		
		label:RegisterWatchLua('ActiveInventory'..index, function(widget, trigger)
			labelUpdate(widget, trigger)
		end, true, nil, 'displayName')

		label2:RegisterWatchLua('ActiveInventory'..index, function(widget, trigger)
			labelUpdate2(widget, trigger)
		end, true, nil, 'activeChannelTime')		
		
		icon:RegisterWatchLua('ActiveInventory'..index, function(widget, trigger)
			iconUpdate(widget, trigger)
		end, true, nil, 'icon')		
		
		containerUpdate(container, triggerInventory)
		barUpdate(bar, triggerInventory)
		labelUpdate(label, triggerInventory)		
		labelUpdate2(label2, triggerInventory)		
		iconUpdate(icon, triggerInventory)		

		lastID	= index
	end
	
	local function channelUnregister()
		if lastID then
			container:UnregisterWatchLua('ActiveInventory'..lastID)
			bar:UnregisterWatchLua('ActiveInventory'..lastID)
			label:UnregisterWatchLua('ActiveInventory'..lastID)
			label2:UnregisterWatchLua('ActiveInventory'..lastID)
			icon:UnregisterWatchLua('ActiveInventory'..lastID)
			lastID	= nil
		end
	end
	
	for i=32,42,1 do
		object:RegisterWatchLua('ActiveInventory'..i, function(widget, trigger)
			if trigger.isChanneling then
				channelUnregister()
				channelRegister(i)
				trigger_gamePanelInfo.channelBarVis = true
				trigger_gamePanelInfo:Trigger(false)
			else
				trigger_gamePanelInfo.channelBarVis = false
				trigger_gamePanelInfo:Trigger(false)			
			end
		end, true, nil, 'isChanneling')
	end

	container:RegisterWatchLua('gamePanelInfo', function(widget, trigger)
		local ypos = -19
		if (trigger.moreInfoKey) or (trigger.heroVitalsVis) then
			ypos = ypos - 4		
		end
		if (trigger.lanePusherVis) then
			ypos = ypos - 5
		end
		widget:SlideY(libGeneral.HtoP(ypos), 125)
	end, false, nil, 'moreInfoKey', 'heroVitalsVis', 'lanePusherVis')	

end

channelBarRegister(object)