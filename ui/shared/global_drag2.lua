--[[
	types of draggables with common actions:
	0	None
	1	Crafted Item Components
	2	? (example social panel interface users?(
	3	Shop auto-buy queue entries
	4	Shop Item.  Also dragging a quick slot item.
	5	Item (in main UI) used for salvaging and linking
	7	Ability on builder
	9	Item Imbuement
	10	Player - Social Entry
	11	Dragging a player in main who is not a friend
	12	Dragging a player in main who is a friend
	20	Dragging a replay / matchid
	21	Dragging a hero build
	
--]]
GlobalDragger = {}
GlobalDragger.lastWidget		= GlobalDragger.lastWidget or nil
GlobalDragger.execFunction		= GlobalDragger.execFunction or nil

function ClearDrag()
	local dragTrigger = LuaTrigger.GetTrigger('globalDragInfo')
	local clientInfoDrag = LuaTrigger.GetTrigger('clientInfoDrag')		 
	dragTrigger.active = false 
	dragTrigger:Trigger(false)
	clientInfoDrag.dragActive = false
	clientInfoDrag:Trigger(false)
end

function globalDraggerRegister(object)
	
	local infoTrigger			= LuaTrigger.GetTrigger('globalDragInfo')
	local targetType			= 0
	
	local selfOnClick			= nil
	local selfWidget			= nil	-- The widget you're dragging FROM (generally looks like what you're actually dragging)
	
	infoTrigger.active			= false
	infoTrigger.type			= 0
	
	infoTrigger:Trigger(true)
	
	local function startDragging(widget)
		selfOnClick 		= widget:GetCallback('onclick')
		selfWidget			= widget
		GlobalDragger.execFunction		= nil
		infoTrigger.active	= true
		infoTrigger.type	= targetType

		infoTrigger:Trigger(false)
	end
	
	local function endDragging(widget, stillOverSource, noTargetFunc)
		local stillOverTarget	= false
		local stillOverSource	= false
		
		if GlobalDragger.lastWidget then
			stillOverTarget = libGeneral.mouseInWidgetArea(GlobalDragger.lastWidget)
		end
		
		if (not GlobalDragger.lastWidget) and (selfOnClick) then
			stillOverSource = libGeneral.mouseInWidgetArea(selfWidget)	-- this effectively means you're performing a click action on self without a drag
		end

		if stillOverTarget then
			if GlobalDragger.execFunction and type(GlobalDragger.execFunction) == 'function' then
				GlobalDragger.execFunction()
			end
		elseif stillOverSource then
			if selfOnClick and type(selfOnClick) == 'function' then
				selfOnClick()
			end
		else
			if (not stillOverSource) and noTargetFunc and type(noTargetFunc) == 'function' then
				noTargetFunc()
			end
		end
		
		GlobalDragger.lastWidget		= nil
		GlobalDragger.execFunction		= nil
		selfWidget			= nil
		selfOnClick			= nil
		infoTrigger.active	= false
		infoTrigger.type	= 0

		infoTrigger:Trigger(false)
	end

	function globalDraggerReadTarget(overTargetWidget, funcToExec)
		GlobalDragger.lastWidget	= overTargetWidget
		GlobalDragger.execFunction = funcToExec
	end
	
	function globalDraggerRegisterSource(sourceWidget, newTargetType, renderParent, noTargetFunc)
		renderParent = renderParent or 'mainDragLayer'
		sourceWidget:SetDragRenderParent(renderParent)
		local onDrag	= sourceWidget:GetCallback('onstartdrag')
		local onDragEnd	= sourceWidget:GetCallback('onenddrag')
		
		-- sourceWidget:SetDragExclusive(false)
		
		if onDrag then
			sourceWidget:SetCallback('onstartdrag', function(widget)
				targetType = newTargetType
				onDrag(widget)
				startDragging(widget)
			end)
		else
			sourceWidget:SetCallback('onstartdrag', function(widget)
				targetType = newTargetType
				startDragging(widget)
			end)
		end

		if onDragEnd then
			sourceWidget:SetCallback('onenddrag', function(widget)
				onDragEnd(widget)
				endDragging(widget, stillOverSource, noTargetFunc)
			end)
		else
			sourceWidget:SetCallback('onenddrag', function(widget)
				endDragging(widget, stillOverSource, noTargetFunc)
			end)
		end
	end
end

globalDraggerRegister(object)