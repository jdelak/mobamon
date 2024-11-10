-- Remote Cursor

function remoteCursorRegister(object)
	local cursor		= object:GetWidget('remote_cursor')
	local cursorIcon	= object:GetWidget('remote_cursor_icon')
	local cursorColorR, cursorColorG, cursorColorB, cursorColorA	= cursorIcon:GetColor()
	
	cursor:RegisterWatchLua('RemoteCursor', function(widget, trigger)
		widget:SetVisible(trigger.visible)
		if trigger.visible then
			widget:SetXF(trigger.xpos)
			widget:SetYF(trigger.ypos)
		end
	end, true, nil, 'visible', 'xpos', 'ypos')
	
	cursorIcon:RegisterWatchLua('RemoteCursor', function(widget, trigger)
		widget:SetTexture(trigger.texturePath)
		widget:SetXF(-trigger.hotspotX)
		widget:SetYF(-trigger.hotspotY)
	end, true, nil, 'texturePath', 'hotspotX', 'hotspotY')
	
	cursorIcon:RegisterWatchLua('spectatorMouseSettings', function(widget, trigger) widget:SetColor(cursorColorR, cursorColorG, cursorColorB, trigger.opacity) end)
end

remoteCursorRegister(object)