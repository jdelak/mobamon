-- Simple Tip, grow Y, not as a floater

function simpleTipNoFloatRegister(object)
	local container			= object:GetWidget('simpleTipNoFloatContainer')
	local icon				= object:GetWidget('simpleTipNoFloatIcon')
	local iconContainer		= object:GetWidget('simpleTipNoFloatIconContainer')
	local title				= object:GetWidget('simpleTipNoFloatTitle')
	local body				= object:GetWidget('simpleTipNoFloatBody')
	local bodySeparator		= object:GetWidget('simpleTipNoFloatBodySeparator')
	local titleContainer	= object:GetWidget('simpleTipNoFloatTitleContainer')
	local dataTrigger		= LuaTrigger.GetTrigger('simpleTipNoFloatData')
	
	local defaultWidth		= libGeneral.HtoP(30)
	local defaultAlign		= 'left'
	local defaultValign		= 'top'
	local defaultX			= 0
	local defaultY			= 0
	
	container:RegisterWatchLua('simpleTipNoFloatData', function(widget, trigger)
		local width = trigger.width
		local x = trigger.x
		local y = trigger.y
		local align = trigger.align
		local valign = trigger.valign
		widget:SetVisible(trigger.show)

		if width == -1 then
			width = defaultWidth
		end
		widget:SetWidth(width)
		
		if x == '' then
			x = defaultX
		end
		widget:SetX(x)
		
		if y == '' then
			y = defaultY
		end
		widget:SetY(y)
		
		if align == '' then
			align = defaultAlign
		end
		widget:SetAlign(align)
		
		if valign == '' then
			valign = defaultValign
		end
		widget:SetVAlign(valign)
		
	end, false, nil, 'show', 'width', 'x', 'y', 'align', 'valign')
	icon:RegisterWatchLua('simpleTipNoFloatData', function(widget, trigger) widget:SetTexture(trigger.icon) end, false, nil, 'icon')
	iconContainer:RegisterWatchLua('simpleTipNoFloatData', function(widget, trigger) widget:SetVisible(trigger.hasIcon) end, false, nil, 'hasIcon')
	bodySeparator:RegisterWatchLua('simpleTipNoFloatData', function(widget, trigger) widget:SetVisible(trigger.hasTitle) end, false, nil, 'hasTitle')
	
	titleContainer:RegisterWatchLua('simpleTipNoFloatData', function(widget, trigger) widget:SetVisible(trigger.hasTitle or trigger.hasIcon) end, false, nil, 'hasTitle', 'hasIcon')
	title:RegisterWatchLua('simpleTipNoFloatData', function(widget, trigger)
		widget:SetText(trigger.title)
		widget:SetVisible(trigger.hasTitle)
	end, false, nil, 'title', 'hasTitle')

	body:RegisterWatchLua('simpleTipNoFloatData', function(widget, trigger)
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
	dataTrigger.x			= ''
	dataTrigger.y			= ''
	dataTrigger.align		= ''
	dataTrigger.valign		= ''
	dataTrigger:Trigger(true)
end

function simpleTipNoFloatUpdate(visible, icon, title, body, width, x, y, align, valign)
	visible = visible or false
	local hasBody		= (body ~= nil)
	local hasTitle		= (title ~= nil)
	local hasIcon		= (icon ~= nil)
	
	local x				= x or ''
	local y				= y or ''
	
	local align			= align or ''
	local valign		= valign or ''

	local width			= width or -1
	local tipTrigger = LuaTrigger.GetTrigger('simpleTipNoFloatData')
	
	tipTrigger.width	= width	

	tipTrigger.align	= align	
	tipTrigger.valign	= valign	
	tipTrigger.x		= x	
	tipTrigger.y		= y	
	
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

simpleTipNoFloatRegister(object)