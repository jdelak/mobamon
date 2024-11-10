local interface = object
mainUI = mainUI or {}
mainUI.tooltip = mainUI.tooltip or {}
Windows = Windows or {}
Windows.state = Windows.state or {}

local function register()
		
	local function GetWidget(widget, fromInterface, hideErrors)
		fromInterface = fromInterface or 'tooltip'
		if (widget) then
			local returnWidget		
			if (Windows.Tooltip) and (Windows.Tooltip:GetInterface(fromInterface)) then
				returnWidget = Windows.Tooltip:GetInterface(fromInterface):GetWidget(widget)
			else
				println('^o GetWidget tooltip could not find interface ' .. tostring(fromInterface))
			end	
			if (returnWidget) then
				return returnWidget
			else
				if (not hideErrors) then println('GetWidget context failed to find ' .. tostring(widget) .. ' in interface ' .. tostring(fromInterface)) end
				return nil		
			end	
		else
			println('GetWidget called without a target')
			return nil
		end
	end	
	
	if (Windows.Tooltip) and (Windows.Tooltip:IsValid()) then
		Windows.Tooltip:Close()		
	end
	Windows.Tooltip = nil
	Windows.state.Tooltip = false

	function mainUI.tooltip.ShowTooltip()
		if (Windows.Tooltip) and (Windows.Tooltip:IsValid()) then
			libThread.threadFunc(function()	
				Windows.Tooltip:Resize(GetWidget('simpleTipGrowYContainer'):GetWidthFromString('+4s'), GetWidget('simpleTipGrowYContainer'):GetHeightFromString('+4s'), false)
				wait(1)
				if (Windows.Tooltip) and (Windows.Tooltip:IsValid()) then
					Windows.Tooltip:Move(Input.GetCursorPosX() + System.GetWindowX() + 16, Input.GetCursorPosY() + System.GetWindowY() + 16)			
					Windows.Tooltip:Show(true)
					Windows.state.Tooltip = true
				end
			end)
		end
	end		
		
	function mainUI.tooltip.HideTooltip()
		if (Windows.Tooltip) and (Windows.Tooltip:IsValid()) then
			Windows.Tooltip:Hide(true)
			Windows.state.Tooltip = false
		end
	end			
		
	function mainUI.tooltip.SilentlySpawnTooltip()
		local widget = object or interface
		if (Windows.Tooltip) and (Windows.Tooltip:IsValid()) then
		
		else
			Windows.Tooltip = Window.New(
					interface:GetXFromString('0s'),
					interface:GetYFromString('0s'),
					interface:GetWidthFromString('30s'),
					interface:GetHeightFromString('30s'),
				{
					Window.BORDERLESS,
					Window.THREADED,
					Window.COMPOSITE,
					-- Window.RESIZABLE,
					-- Window.CENTER,
					Window.HIDDEN,
					Window.POSITION,
					Window.NOACTIVATE,
					Window.TOPMOST,
				},
				"/ui_dev/tooltip/tooltip.interface",
				Translate('window_name_tooltip')
			)
		end
	end	

	local tipDelayThread
	local tipDelayDuration = GetCvarNumber('ui_tipDelayDuration', true) or 250
	UnwatchLuaTriggerByKey('simpleMultiWindowTipGrowYData', 'simpleMultiWindowTipGrowYData')
	WatchLuaTrigger('simpleMultiWindowTipGrowYData', function(trigger)
		if (tipDelayThread) then
			tipDelayThread:kill()
			tipDelayThread = nil
		end
		if (trigger.show) then
			tipDelayThread = libThread.threadFunc(function()
				wait(tipDelayDuration)
				mainUI.tooltip.ShowTooltip()
				tipDelayThread =  nil
			end)		
		else
			mainUI.tooltip.HideTooltip()
		end
	end, 'simpleMultiWindowTipGrowYData', 'show')
	
	function simpleMultiWindowTipGrowYUpdate(visible, icon, title, body, width, xOffset, yOffset)
		mainUI.tooltip.SilentlySpawnTooltip()
		visible = visible or false
		local hasBody		= (body ~= nil)
		local hasTitle		= (title ~= nil)
		local hasIcon		= (icon ~= nil)
		local width			= width or -1
		local xOffset		= xOffset or -1
		local yOffset		= yOffset or -1
		local tipTrigger = LuaTrigger.GetTrigger('simpleMultiWindowTipGrowYData')
		
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

end

register()
