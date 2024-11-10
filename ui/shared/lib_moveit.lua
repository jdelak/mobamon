
	--[[
		onstartdrag
		onendstart
		cangrab
		spawn dragger
	--]]

MoveIt = {}	
-- MoveIt.storeUserdata = nil

function MoveIt.Register(sourceWidget, minWidth, maxWidth, minHeight, maxHeight, width, height, x, y, valign, align, width2, height2)
	-- local sourceWidget = sourceWidget
	-- println('^g MoveIt.Register ')
	
	-- sourceWidget:Sleep(1, function()
	
		-- MoveIt.storeUserdata = sourceWidget
		
		-- sourceWidget:Instantiate('moveit_frame_template',
			-- 'width', width or '1.7h',
			-- 'height', height or '1.7h',
			-- 'width2', width2 or '1.5h',
			-- 'height2', height2 or '1.5h',			
			-- 'x', x or '-4',
			-- 'y', y or '-4',
			-- 'valign', valign or 'bottom',
			-- 'align', align or 'right',
			-- 'minWidth', minWidth or '40h',
			-- 'maxWidth', maxWidth or '120h',
			-- 'minHeight', minHeight or '20h',
			-- 'maxHeight', maxHeight or '70h'
			
		-- )
		
	-- end)
	
	-- sourceWidget:SetCallback('onstartdrag', function(widget)
		-- widget:SetVisible(false)
	-- end)
	
	sourceWidget:SetCallback('onenddrag', function(widget, event) -- event is moving or sizing

		if (widget:GetAbsoluteX() < 0) then
			widget:SetY(widget:GetY())
			widget:SetX('0')
		elseif ((widget:GetAbsoluteX() + widget:GetWidth()) > GetScreenWidth()) then
			widget:SetY(widget:GetY())
			widget:SetX(GetScreenWidth() - widget:GetWidth())
		end
		
		if (widget:GetAbsoluteY() < 0) then
			widget:SetX(widget:GetX())
			widget:SetY('0')
		elseif ((widget:GetAbsoluteY() + widget:GetHeight()) > GetScreenHeight()) then
			widget:SetX(widget:GetX())
			widget:SetY(GetScreenHeight() - widget:GetHeight())
		end		
		
	end)	
	
	sourceWidget:RefreshCallbacks()
	
end

-- local function DoDrag(sourceWidget, targetWidget, isDragging, minWidth, maxWidth, minHeight, maxHeight)
	-- local dragWidget = sourceWidget
	-- local dragParent = targetWidget

	-- if (isDragging) then
		
		-- local dragParentStartingHeight = dragParent:GetHeight()
		-- local dragParentStartingY = dragParent:GetY()
		-- local cursorStartingY = Input.GetCursorPosY()
		
		-- local dragParentStartingWidth = dragParent:GetWidth()
		-- local dragParentStartingX = dragParent:GetX()
		-- local cursorStartingX = Input.GetCursorPosX()		
		
		-- dragParent:SetHeight(dragParentStartingHeight)
		-- dragParent:SetWidth(dragParentStartingWidth)
		-- dragParent:SetY(dragParentStartingY)
		-- dragParent:SetX(dragParentStartingX)
		
		-- dragWidget.onframe = function()	
		
			-- if ((Input.GetCursorPosY() - cursorStartingY) + dragParentStartingHeight) < dragParent:GetHeightFromString(minHeight) then
				-- dragParent:SetHeight('20h')	
			-- elseif ((Input.GetCursorPosY() - cursorStartingY) + dragParentStartingHeight) > dragParent:GetHeightFromString(maxHeight) then
				-- dragParent:SetHeight('70h')	
			-- else
				-- dragParent:SetHeight((Input.GetCursorPosY() - cursorStartingY) + dragParentStartingHeight)	
			-- end
			
			-- if ((Input.GetCursorPosX() - cursorStartingX) + dragParentStartingWidth) < dragParent:GetWidthFromString(minWidth) then
				-- dragParent:SetWidth('40h')	
			-- elseif ((Input.GetCursorPosX() - cursorStartingX) + dragParentStartingWidth) > dragParent:GetWidthFromString(maxWidth) then
				-- dragParent:SetWidth('120h')	
			-- else
				-- dragParent:SetWidth((Input.GetCursorPosX() - cursorStartingX) + dragParentStartingWidth)	
			-- end			

			-- dragParent:SetY(dragParentStartingY)
			-- dragParent:SetX(dragParentStartingX)			
		-- end
	
	-- else
		-- dragWidget.onframe = nil	
		-- dragWidget:SetY('0')
		-- dragWidget:SetX('0')
	-- end
	-- dragWidget:RefreshCallbacks()
-- end	

-- function MoveIt.SpawnedDragger(sourceWidget, minWidth, maxWidth, minHeight, maxHeight)
	-- local targetWidget = MoveIt.storeUserdata
	
	-- sourceWidget.onmouseldown = function()
		-- DoDrag(sourceWidget, targetWidget, true, minWidth, maxWidth, minHeight, maxHeight)
	-- end
	-- sourceWidget.onmouselup = function()
		-- DoDrag(sourceWidget, targetWidget, false, minWidth, maxWidth, minHeight, maxHeight)
	-- end
	-- sourceWidget:RefreshCallbacks()
	
	-- MoveIt.storeUserdata = nil
-- end
