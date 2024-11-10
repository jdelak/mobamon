
-- Scan all main widgets for clicks
local hasLeftClick, hasRightClick, hasDrag = false, false, false
local function findChildrenClickCallbacks(widget)
	if (not widget) then return end
	
	for index, value in pairs(widget:GetChildren()) do
		-- table.insert(widgetPointerTable, value)
		
		if (value:GetCallback('onclick')) or (value:GetCallback('onselect')) or (value:GetCallback('onbutton')) or (value:GetCallback('onslide')) or (value:GetCallback('onmouseldown')) or (value:GetType() == 'combobox') or (value:GetType() == 'listitem') then
			hasLeftClick = true
		else
			hasLeftClick = false
		end
		
		if (value:GetCallback('onrightclick')) then
			hasRightClick = true
		else
			hasRightClick = false
		end		
		
		if (value:GetCallback('onstartdrag')) or (value:GetCallback('onenddrag')) then
			hasDrag = true
		else
			hasDrag = false
		end			
		
		if (hasLeftClick) or (hasRightClick) or (hasDrag) then
			
			local hasLeftClick, hasRightClick, hasDrag = hasLeftClick, hasRightClick, hasDrag
			
			local oldMouseover = value:GetCallback('onmouseover')
			value:SetCallback('onmouseover', function(sourceWidget) 
				if (oldMouseover) and type(oldMouseover) == 'function' then 
					oldMouseover()
				end
				UpdateCursor(sourceWidget, true, { canLeftClick = hasLeftClick, canRightClick = hasRightClick, canDrag = hasDrag } )
			end)

			local oldMouseout = value:GetCallback('onmouseout')
			value:SetCallback('onmouseout', function(sourceWidget) 
				if (oldMouseout) and type(oldMouseout) == 'function' then 
					oldMouseout()
				end
				UpdateCursor(sourceWidget, false, { canLeftClick = hasLeftClick, canRightClick = hasRightClick, canDrag = hasDrag })
			end)
			value:RefreshCallbacks()
		end
		
		if (#value:GetChildren() > 0) then
			findChildrenClickCallbacks(value)
		end
	end
end

function FindChildrenClickCallbacks(widget)
	findChildrenClickCallbacks(widget)
end