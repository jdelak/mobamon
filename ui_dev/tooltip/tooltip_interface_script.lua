local interface = object
mainUI = mainUI or {}
mainUI.tooltip = mainUI.tooltip or {}
Windows = Windows or {}
Windows.state = Windows.state or {}

local function register(object)

	function simpleMultiWindowTipGrowYRegister(object)
		local container			= object:GetWidget('simpleTipGrowYContainer')
		local icon				= object:GetWidget('simpleTipGrowYIcon')
		local iconContainer		= object:GetWidget('simpleTipGrowYIconContainer')
		local title				= object:GetWidget('simpleTipGrowYTitle')
		local body				= object:GetWidget('simpleTipGrowYBody')
		local bodySeparator		= object:GetWidget('simpleTipGrowYBodySeparator')
		local titleContainer	= object:GetWidget('simpleTipGrowYTitleContainer')
		local dataTrigger		= LuaTrigger.GetTrigger('simpleMultiWindowTipGrowYData')
		
		local defaultWidth		= libGeneral.HtoP(22)

		container:RegisterWatchLua('simpleMultiWindowTipGrowYData', function(widget, trigger)
			local width = trigger.width

			if (trigger.show) then
				widget:SetVisible(1)		
			else
				widget:SetVisible(0)
			end
		
			if width == -1 then
				width = defaultWidth
			end
			widget:SetWidth(width)
		end, false, nil, 'show', 'width')

		icon:RegisterWatchLua('simpleMultiWindowTipGrowYData', function(widget, trigger) widget:SetTexture(trigger.icon) end, false, nil, 'icon')
		iconContainer:RegisterWatchLua('simpleMultiWindowTipGrowYData', function(widget, trigger) widget:SetVisible(trigger.hasIcon) end, false, nil, 'hasIcon')
		bodySeparator:RegisterWatchLua('simpleMultiWindowTipGrowYData', function(widget, trigger) widget:SetVisible(trigger.hasTitle) end, false, nil, 'hasTitle')
		
		titleContainer:RegisterWatchLua('simpleMultiWindowTipGrowYData', function(widget, trigger) widget:SetVisible(trigger.hasTitle or trigger.hasIcon) end, false, nil, 'hasTitle', 'hasIcon')
		title:RegisterWatchLua('simpleMultiWindowTipGrowYData', function(widget, trigger)
			widget:SetText(trigger.title)
			widget:SetVisible(trigger.hasTitle)
		end, false, nil, 'title', 'hasTitle')
		body:RegisterWatchLua('simpleMultiWindowTipGrowYData', function(widget, trigger)
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

	end

	simpleMultiWindowTipGrowYRegister(object)	
	
end

register(object)
