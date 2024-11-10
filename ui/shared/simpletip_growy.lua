-- Simple Tip, grow Y

function simpleTipGrowYRegister(object)
	local container			= object:GetWidget('simpleTipGrowYContainer')
	local icon				= object:GetWidget('simpleTipGrowYIcon')
	local iconContainer		= object:GetWidget('simpleTipGrowYIconContainer')
	local title				= object:GetWidget('simpleTipGrowYTitle')
	local body				= object:GetWidget('simpleTipGrowYBody')
	local bodySeparator		= object:GetWidget('simpleTipGrowYBodySeparator')
	local titleContainer	= object:GetWidget('simpleTipGrowYTitleContainer')
	local dataTrigger		= LuaTrigger.GetTrigger('simpleTipGrowYData')
	
	local defaultWidth		= libGeneral.HtoP(22)

	local tipDelayThread
	local tipDelayDuration = GetCvarNumber('ui_tipDelayDuration', true) or 250	
	container:RegisterWatchLua('simpleTipGrowYData', function(widget, trigger)
		local width = trigger.width
		
		if (tipDelayThread) then
			tipDelayThread:kill()
			tipDelayThread = nil
		end
		
		if (trigger.show) then
			tipDelayThread = libThread.threadFunc(function()
				wait(tipDelayDuration)
				widget:SetVisible(1)
				tipDelayThread =  nil
			end)		
		else
			widget:SetVisible(0)
		end
	
		if width == -1 then
			width = defaultWidth
		end
		widget:SetWidth(width)
	end, false, nil, 'show', 'width')

	icon:RegisterWatchLua('simpleTipGrowYData', function(widget, trigger) widget:SetTexture(trigger.icon) end, false, nil, 'icon')
	iconContainer:RegisterWatchLua('simpleTipGrowYData', function(widget, trigger) widget:SetVisible(trigger.hasIcon) end, false, nil, 'hasIcon')
	bodySeparator:RegisterWatchLua('simpleTipGrowYData', function(widget, trigger) widget:SetVisible(trigger.hasTitle) end, false, nil, 'hasTitle')
	
	titleContainer:RegisterWatchLua('simpleTipGrowYData', function(widget, trigger) widget:SetVisible(trigger.hasTitle or trigger.hasIcon) end, false, nil, 'hasTitle', 'hasIcon')
	title:RegisterWatchLua('simpleTipGrowYData', function(widget, trigger)
		widget:SetText(trigger.title)
		widget:SetVisible(trigger.hasTitle)
	end, false, nil, 'title', 'hasTitle')
	body:RegisterWatchLua('simpleTipGrowYData', function(widget, trigger)
		if trigger.hasBody then
			widget:SetText(trigger.body)
			widget:SetVisible(true)
		else
			widget:SetVisible(false)
		end
	end, false, nil, 'hasBody', 'body')
	
	dataTrigger.show		= false
	dataTrigger.title		= ''
	dataTrigger.hasTitle	= false
	dataTrigger.icon		= ''
	dataTrigger.HasIcon		= false
	dataTrigger.body		= ''
	dataTrigger.hasBody		= false
	dataTrigger.width		= -1
	dataTrigger:Trigger(true)

	libGeneral.registerNonObscuringFloat(container)
end

function simpleTipGrowYUpdate(visible, icon, title, body, width, xOffset, yOffset)
	visible = visible or false
	local hasBody		= (body ~= nil)
	local hasTitle		= (title ~= nil)
	local hasIcon		= (icon ~= nil)
	local width			= width or -1
	local xOffset		= xOffset or -1
	local yOffset		= yOffset or -1
	local tipTrigger = LuaTrigger.GetTrigger('simpleTipGrowYData')
	
	tipTrigger.width	= width	
	tipTrigger.xOffset	= xOffset	
	tipTrigger.yOffset	= yOffset	
	tipTrigger.show 	= visible
	if visible then
		tipTrigger.hasBody	= hasBody
		tipTrigger.hasIcon	= hasIcon
		tipTrigger.hasTitle	= hasTitle
		if hasBody then tipTrigger.body = body end
		if hasIcon then tipTrigger.icon = icon end
		if hasTitle then tipTrigger.title = title end
	end
	tipTrigger:Trigger(true)
end

simpleTipGrowYRegister(object)