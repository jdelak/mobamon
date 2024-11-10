-- Item Cursor

function itemCursorRegister(object)
	local cursor		= object:GetWidget('itemCursor')
	local cursorIcon	= object:GetWidget('itemCursorIcon')
	
	cursor:RegisterWatchLua('ItemCursorVisible', function(widget, trigger)
		widget:SetVisible(trigger.cursorVisible)
	end)
	
	cursor:RegisterWatchLua('ItemCursorPosition', function(widget, trigger)
		widget:SetX(trigger.xpos - 20)
		widget:SetY(trigger.ypos - 20)
	end)
	
	cursorIcon:RegisterWatchLua('ItemCursorIcon', function(widget, trigger)
		widget:SetTexture(trigger.iconPath)
	end)
end

itemCursorRegister(object)