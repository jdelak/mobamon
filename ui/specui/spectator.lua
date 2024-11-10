local floor = math.floor
local max	= math.max
local min	= math.min
local tsort	= table.sort
local atan2 = math.atan2
local pi = math.pi
local sqrt = math.sqrt
local log = math.log
local log10 = math.log10
local pow = math.pow
local abs = math.abs
local tinsert = table.insert
local tremove = table.remove

local interface = object

-- Can't do (var or default) because false and nil are both false, but false is a valid value. ((var ~= nil and var) or default) also doesn't work if var is false.
local function checkVar(var, default)
	if var == nil then return default end
	return var
end

specUI = {
	abilityFlyoutMode		= checkVar(GetCvarNumber('_spec_abilityFlyoutMode', true), 2), -- 1) every ability,	2) ults only,	3) none
	displaying				= true,
	showingOverlays			= checkVar(GetCvarBool('_spec_showingOverlays', true), false),
	playerPodView			= checkVar(GetCvarNumber('_spec_playerPodView', true), 2),		-- 1) Full View 2) Items hidden 3) Skills only 4) Nothing
	itemFlyoutCostThreshhold= checkVar(GetCvarNumber('_spec_itemFlyoutCostThreshhold', true), 250),
	itemFlyoutRecipeOnly	= checkVar(GetCvarBool('_spec_itemFlyoutRecipeOnly', true), true),
	--teamInfoMode			= 0,		-- 0) Totals, 1) Percent, 2) Deviation from Average
	gankIndexes				= { -1, -1, -1 },
}

local specUIWidgets = {
	selected_frame		= object:GetWidget('spec_selected_unit_parent'),
	pushBar				= object:GetWidget('spec_push_bar'),
	statPanel			= object:GetWidget('spec_stats_parent'),
	playersPodParent	= object:GetWidget('spec_hero_frames_container_parent'),
	playerPodGroup1		= object:GetWidget('spec_hero_frames_1'),
	playerPodGroup2		= object:GetWidget('spec_hero_frames_2'),
	gankAlert			= {}
}


-- ================================================================
-- ======================== Graphing code ========================= Note - this code will likely be refactored from here when a graph is needed elsewhere
-- ================================================================

local GPMhistory = {0}
local XPMhistory = {0}

local recentOnly = false -- Depreciated - this shouldn't be turned on otherwise events may break - it hasn't been tested recently
local lines = {}
local markerLines = {} -- The vertical breaks
local markerLabels = {} --Labels for the breaks
local forcedGraphMin = 0 --For when images start to overflow the window
local forcedGraphMax = 0
local straightStacks = true
local stackOverlapMax = 17.5 -- when stack is overflowing
local graphOpen = false

local graphStartIndex = 0 -- from 0-1, the numbers to start the graph rendering at.
local graphEndIndex = 1
local maxStackSize = 0.35
-- Draw a graph from points
function specUI.drawGraph(data, events, noshow)
	local backing = interface:GetWidget('spec_stats_graph_background')
	local noDataLabel = interface:GetWidget('spec_stats_graph_no_data_label')
	if (data and #data>0) then
		
		local graphHeight = backing:GetHeight()
		local graphWidth = backing:GetWidth()
		local minimum = -100
		local yStep
		local xStep
		local maxPoints = 100
		local pointsRemoved = 0
		local points = table.copy(data)
		
		-- Given a n in terms of the filtered data, what is the x pixel
		local function transformX(n)
			return ((n-1)/((#points-1) or 1)) *graphWidth --points will be modified by this point
		end
		-- Given an x pixel, where would the value be in the filtered data
		local function deTransformX(x)
			return (x/graphWidth) * ((#points-1) or 1) + 1
		end
		-- Given a value from the data, what pixel would it be plotted on Y
		local function transformY(value)
			if value then
				return graphHeight-(value-minimum)*yStep
			end
			return 0
		end
		-- Given a Y pixel, what would the value be from points?
		local function deTransformY(y)
			return (graphHeight-y)/yStep+minimum
		end
		-- Given an entry n from data, about where would it be in points?
		local function transformN(n)
			if (recentOnly) then
				return (n-#data)+#points
			else
				local multiplier = 1/(graphEndIndex-graphStartIndex)
				local multiplier2 = #points/#GPMhistory
				
				local result = floor((n - (#GPMhistory*graphStartIndex)) * multiplier * multiplier2 + 0.5)
				
				return result
			end
		end
		-- Given two points, gets the centre co-ordinates in pixels - as well as the angle and distance
		local function GetTransformedMiddlePos(n1, n2, fromData)
			local starty= transformY(fromData and data[n1] or points[n1])
			local endy=   transformY(fromData and data[n2] or points[n2])
			if (fromData) then
				n1 = transformN(n1)
				n2 = transformN(n2)
			end
			local startx= transformX(n1)
			local endx=   transformX(n2)
			local angle = atan2(endy-starty, endx-startx)
			local distance = sqrt((endy-starty)*(endy-starty) + (endx-startx)*(endx-startx))+0.5
			return (startx+endx)/2,(starty+endy)/2, angle, distance
		end
		-- Given 2 X pixels as lower and upper bounds, return the y pixels of the maxima and minima of the graph.
		local function GetExtremesBetween(x1, x2)
			x1 = floor(deTransformX(x1))
			x2 = floor(deTransformX(x2)+1)
			local maximum = -999999
			local minimum = 999999
			for n = x1, x2 do
				if points[n] then
					if points[n]>maximum then maximum = points[n] end
					if points[n]<minimum then minimum = points[n] end
				end
			end
			return transformY(minimum), transformY(maximum)
		end
		-- Set multiple of a widgets properties at once.
		local function SetWidgetPos(widget, x, y, width, height, rotation, text)
			if x then widget:SetX(x) end
			if y then widget:SetY(y) end
			if width then widget:SetWidth(width) end
			if height then widget:SetHeight(height) end
			if rotation then widget:SetRotation(rotation) end
			if text then widget:SetText(text) end
		end
		-- Makes numbers pretty. 9805 -> 10000,		1.11 -> 1.1		5600 -> 5600 etc etc
		local function pretifyNumber(value)
			local accuracy = 5
			local logValue = floor(log10(value))
			local inversePower = pow(10, -logValue)
			local prettyNumber = floor(value * inversePower * accuracy + 0.5)
			local prettyNumber = floor(prettyNumber / inversePower / accuracy + 0.5)
			return prettyNumber
		end
		
		noDataLabel:FadeOut(250)
		
		-- Filter out some points if we are above our max
		if #points > maxPoints then
			if (recentOnly) then -- only take last MAX numbers
				points = {}
				for n= #data-maxPoints, #data do
					points[n]=data[#data-maxPoints+n]
				end
			else -- grab values throughout the array to have MAX by the end
				local multiplier = (#data-1)/maxPoints
				
				points = {}
				additions = {}
				for n = 1, maxPoints do
					points[n] = 0
					additions[n] = 0 
				end
				
				-- add points through-out the data, represent them in points
				for n=1, #data do
					if data[n] ~= 0 then
						local actualN = (n/#data)*(maxPoints-1) + 1
						local ratio = (actualN%1)
						points[floor(actualN)] = points[floor(actualN)] + (1-ratio)*data[n]
						additions[floor(actualN)] = additions[floor(actualN)] + (1-ratio)
						points[floor(actualN+0.999)] = points[floor(actualN+0.999)] + ratio*data[n]
						additions[floor(actualN+0.999)] = additions[floor(actualN+0.999)] + ratio
					end
				end
				-- average them
				for n = 1, maxPoints do
					points[n] = points[n] / additions[n]
				end
				
				
			end
			pointsRemoved = #data-#points
		end
		
		-- determine the maximum and minimum values. Always show at least 100 either side, so we can clearly see the center line
		local maximum = 100
		for n=1, #points do
			if points[n]>maximum then maximum=points[n] end
			if points[n]<minimum then minimum=points[n] end
		end
		-- If we are forced to expand due to events overflowing, then do so
		if forcedGraphMin ~= 0 and forcedGraphMin<minimum then minimum = forcedGraphMin end
		if forcedGraphMax ~= 0 and forcedGraphMax>maximum then maximum = forcedGraphMax end
		
		-- Scale the graph so it looks nice, don't have it too skewed Max of 80% one team
		if ( maximum>4*(-minimum)) then minimum = -maximum/4 end
		if (-minimum>4*( maximum)) then maximum = -minimum/4 end
		-- Allow increasing scale if it gets a nice number, e.g. maximum of 9,800 should stretch to show where 10,000 is.
		local highPretty = pretifyNumber(maximum)
		local lowPretty = -pretifyNumber(-minimum)
		if highPretty>maximum then maximum = highPretty end
		if lowPretty <minimum then minimum = lowPretty end
		
		local range = maximum-minimum
		--calculate how much each x or y affects the graph
		xStep = graphWidth/((#points-1) or 1) --stop divide by 0
		yStep = graphHeight/(range or 1)
		
		-- Draw the lines
		for n=1, #points-1 do
			if ((points[n] == 0 and n ~= 0) or points[n+1] == 0) then
				if (lines[n]) then
					lines[n]:Destroy()
					lines[n] = nil
				end
			else
				local middleX, middleY, angle, distance = GetTransformedMiddlePos(n, n+1)
				if (lines[n] and lines[n]:IsValid()) then
					SetWidgetPos(lines[n], middleX-distance/2, middleY, distance, nil, angle*180/pi)
				else
					lines[n] = backing:InstantiateAndReturn('spec_stats_graph_line', 'x', (middleX-distance/2), 'y', middleY, 'width', distance, 'height', '0.22h')[1]
					lines[n]:SetRotation(angle*180/pi)
				end
			end
		end
		-- Remove lines which shouldn't be used to draw but are
		for n=#points, maxPoints do
			if (lines[n]) then
				lines[n]:Destroy()
				lines[n] = nil
			end
		end
		
		-- If images begin to spill over all sides, we keep track of about how many pixels.
		local newGraphMin = 0
		local newGraphMax = graphHeight
		
		local eventRects = {} -- Used for stack collision checks
		-- Draw all events
		if (events and #events>0) then
			for n = 1, #events do
				local filteredN = transformN(events[n].n)
				if filteredN>0 and filteredN<#points then
					local middleX, middleY, angle, distance = GetTransformedMiddlePos(filteredN, filteredN+1)
					local size = events[n].size
					
					-- Sort out event collisions
					local x = middleX-size/2
					local y = middleY-size/2
					local x2 = middleX+size/2
					local y2 = middleY+size/2
					
					-- Stack-sorting code. Join a stack if you would collide with it, and it'd make you further from the 0 line.
					-- The overlap code is complicated. Overlap if you would go outside the window. If the overlap isn't enough, then warp the graph to fit the images
					-- UNLESS the stack is > 35% of the height of the graph, in which case, try to fit in as best you can.
					local foundStack = false
					if (#eventRects > 0) then
						for m = 1, #eventRects do
							if x<eventRects[m].x2 and x2>eventRects[m].x and eventRects[m].team == events[n].goodForLegion then
								-- Colliding in the x direction, but we may not join it, if it'd put us closer to the center line?
								local minimum, maximum = GetExtremesBetween(x, x2)
								if events[n].goodForLegion and eventRects[m].nexyY-size < (maximum-size*1.5) then
									foundStack = true
									tinsert(eventRects[m].indexes, n)
									eventRects[m].totalSize = eventRects[m].totalSize + size
									y = eventRects[m].nexyY - size
									eventRects[m].nexyY = y
									if y < newGraphMin then
										local overlap = eventRects[m].overlap
										if eventRects[m].totalSize-((#eventRects[m].indexes-1)*overlap) > graphHeight * maxStackSize then --Fail-safe, don't allow stacks to exceed 35% of the graph.
											overlap = (eventRects[m].totalSize-(graphHeight * maxStackSize)) / (#eventRects[m].indexes-1)
										end
										eventRects[m].overlap = overlap
										-- Shrink stack
										eventRects[m].nexyY=eventRects[m].y
										for i=1, #eventRects[m].indexes do
											local index = eventRects[m].indexes[i]
											y = eventRects[m].nexyY - size+overlap
											eventRects[m].nexyY = y
											if events[index].widget and events[index].widget:IsValid() then
												SetWidgetPos(events[index].widget, nil, y)
											end
										end
										if y < newGraphMin then
											newGraphMin = y
											y=middleY-size/2
										end
									end
								elseif not events[n].goodForLegion and eventRects[m].nexyY > (minimum+size/2) then
									foundStack = true
									tinsert(eventRects[m].indexes, n)
									eventRects[m].totalSize = eventRects[m].totalSize + size
									y = eventRects[m].nexyY
									eventRects[m].nexyY = eventRects[m].nexyY + size
									if y+size > newGraphMax then
										local overlap = eventRects[m].overlap
										if eventRects[m].totalSize-((#eventRects[m].indexes-1)*overlap) > graphHeight * maxStackSize then --Fail-safe, don't allow stacks to exceed 35% of the graph.
											overlap = (eventRects[m].totalSize-(graphHeight * maxStackSize)) / (#eventRects[m].indexes-1)
										end
										eventRects[m].overlap = overlap
										
										-- Shrink stack
										eventRects[m].nexyY=eventRects[m].y
										for i=1, #eventRects[m].indexes do
											local index = eventRects[m].indexes[i]
											y = eventRects[m].nexyY
											if events[index].widget and events[index].widget:IsValid() then
												SetWidgetPos(events[index].widget, nil, y)
											end
											eventRects[m].nexyY = eventRects[m].nexyY + size - overlap
										end
										if y+size > newGraphMax then
											newGraphMax = y+size
											y=middleY-size/2
										end
									end
								end
								if foundStack then
									x = (x+eventRects[m].x)/2
									if straightStacks then
										x = eventRects[m].x
									end
								end
							end
						end
					end
					if (not foundStack) then -- make our own stack
						local minimum, maximum = GetExtremesBetween(x, x2)
						y = events[n].goodForLegion and (maximum-size*1.5) or (minimum+size/2)
						y2 = y+size
						if y < newGraphMin then newGraphMin = y end
						if y+size > newGraphMax then newGraphMax = y+size end
						local nextOffset = events[n].goodForLegion and 0 or size
						tinsert(eventRects, {x=x,y=y,x2=x2,y2=y2,team=events[n].goodForLegion,nexyY=y+nextOffset,indexes={n},totalSize=size,overlap=stackOverlapMax})
					end
					
					-- Create/move event images
					if events[n].widget and events[n].widget:IsValid() then
						SetWidgetPos(events[n].widget, x, y)
					else
						local color = events[n].goodForLegion and '0.3 1 0.3 0.8' or '1 0.3 0.3 0.8'
						events[n].widget = backing:InstantiateAndReturn('spec_stats_graph_image', 'x', x, 'y', y, 'texture', events[n].texture, 'size', size, 'borderColor', color,
						'onmouseoverlua', "simpleTipGrowYUpdate(true, '"..events[n].texture.."', '"..events[n].tipTitle.."', '"..events[n].tipBody.."', libGeneral.HtoP(32))",
						'onmouseoutlua', "simpleTipGrowYUpdate(false)"
						)[1]
						if events[n].frame then
							events[n].widget:SetCallback('onclick', function()
								specUI.hideGraph(true)
								Cmd('ReplaySetFrame '.. (events[n].frame-200))
								if (events[n].entityIndex) then
									libThread.threadFunc(function()
										wait(200) -- 30 fps
										SelectUnit(events[n].entityIndex)
										SelectUnit(events[n].entityIndex)
									end)
								end
							end)
						end
					end
					if events[n].goodForLegion then
						events[n].widget:PushToBack()
					else
						events[n].widget:BringToFront()
					end
				elseif (events[n].widget) then --widget shouldn't exist but does
					events[n].widget:Destroy()
					events[n].widget = nil
				end
			end
		end
		
		-- Create the graph's y axis reference labels/lines:
		for n = 1, 9 do
			local y=0
			if n<5 then y=lowPretty *(n/4)       end --lower 4 lines
			if n>5 then y=highPretty*(n-5)/4 end --upper 4 lines
			displayy = transformY(y)
			local label = y
			if n<5 then label=-label end
			if (markerLines[n] and markerLines[n]:IsValid()) then
				SetWidgetPos(markerLines[n] , nil, displayy, graphWidth)
				SetWidgetPos(markerLabels[n], nil, displayy-7, nil, nil, nil, label)
				markerLines[n]:PushToBack()
			else
				local lineWidth = 1
				local lineColor = '1 1 1 0.25'
				local labelColor = 'white'
				if n == 5 then -- emphasize 0 line
					lineWidth = 3
					lineColor = '1 1 1 0.75'
				end
				if n<5 then labelColor = '1 0.3 0.3 1' end
				if n>5 then labelColor = '0.3 1 0.3 1' end
				markerLines[n] = backing:InstantiateAndReturn('spec_stats_graph_line', 'x', '0h', 'y', displayy, 'width', graphWidth, 'height', lineWidth, 'color', lineColor)[1]
				markerLabels[n] = backing:InstantiateAndReturn('spec_stats_graph_label', 'x', '-45', 'y', (displayy-7), 'label', label, 'color', labelColor)[1]
			end
		end
		
		-- did images go off the screen?
		if (newGraphMax > graphHeight or newGraphMin < 0) then -- images went off the screen..
			if (newGraphMax > graphHeight) then forcedGraphMin = deTransformY(newGraphMax)*1.01 end
			if (newGraphMin < 0) then           forcedGraphMax = deTransformY(newGraphMin)*1.01 end
			specUI.drawGraph(data, events, noshow) -- redraw graph without overflowing images.
		end
		
		backing:FadeIn(250)
	else -- no data
		noDataLabel:FadeIn(250)
		backing:FadeOut(250)
	end
	
	-- Finally display the graph
	if (not noshow) then
		interface:GetWidget('spec_stats_graph_parent'):FadeIn(250)
		graphOpen = true
	end
end
specUI.drawGraph(nil, nil, true)

function specUI.hideGraph(instant)
	graphOpen = false
	if (instant) then
		interface:GetWidget('spec_stats_graph_parent'):SetVisible(false)
	else
		interface:GetWidget('spec_stats_graph_parent'):FadeOut(250)
	end
end



-- 4 graph updaters
local majorEventsHistory = {} --Generator, tower, bald/cind, hero kill. Format is (n=GPMhistoryTime, texture=icon, goodForLegion=true, size=40, importance=int(1-9))
local graphMode = 1 --1: gold, 2: xp

function specUI.updateGraph(force, mode)
	mode = mode or graphMode or 1
	graphMode = mode
	
	--draw/show graph if need be
	if not interface:GetWidget('spec_stats_graph_parent'):IsVisible() and not force then return end --don't update if we don't need to
	
	graphStartIndex = clamp(graphStartIndex, 0, 1)
	graphEndIndex   = clamp(graphEndIndex  , 0, 1)
	
	interface:GetWidget('spec_stats_graph_header_btn_'..mode..'current'):SetVisible(true)
	interface:GetWidget('spec_stats_graph_header_btn_'..(3-mode)..'current'):SetVisible(false)
	if mode == 1 then
		local filteredGPM = {unpack(GPMhistory, floor(graphStartIndex*#GPMhistory)+1, floor(graphEndIndex*#GPMhistory)+1.9)}
		specUI.drawGraph(filteredGPM, majorEventsHistory)
	elseif mode == 2 then
		local filteredXPM = {unpack(XPMhistory, floor(graphStartIndex*#XPMhistory)+1, floor(graphEndIndex*#XPMhistory)+1.9)}
		specUI.drawGraph(filteredXPM, majorEventsHistory)
	end
end


local function clamp(n, low, high) return math.max( math.min(n, high), low ) end

-- This is to stop the graph looking odd when resizing - by updating it constantly while you do it.
local slider = object:GetWidget('spec_stats_graph_slider') --refresh slider too
local graphResizingThread
object:GetWidget('spec_stats_graph_sizer'):SetCallback('onstartdrag', function(widget)
	if (graphResizingThread and graphResizingThread:IsValid()) then
		graphResizingThread:kill()
		graphResizingThread = nil
	end
	local startingWidth = interface:GetWidget('spec_stats_graph_slider_container'):GetWidth()
	local sliderStartingWidth = slider:GetWidth()
	local sliderStartingX = slider:GetX()
	graphResizingThread = libThread.threadFunc(function()
		while (true) do
			wait(33) -- 30 fps
			
			-- Scale the slider bar too
			local sliderContainerWidth = interface:GetWidget('spec_stats_graph_slider_container'):GetWidth()
			local newWidth = clamp((sliderContainerWidth/startingWidth)*sliderStartingWidth, 50, sliderContainerWidth)
			slider:SetWidth(newWidth)
			if slider:GetX()+newWidth > sliderContainerWidth then
				slider:SetX(sliderContainerWidth - newWidth)
				graphStartIndex = (sliderContainerWidth - newWidth)/sliderContainerWidth
			else
				slider:SetX(graphStartIndex*sliderContainerWidth)
			end
			specUI.updateGraph()
			
		end
	end)
end)
object:GetWidget('spec_stats_graph_sizer'):SetCallback('onenddrag', function(widget)
	if (graphResizingThread and graphResizingThread:IsValid()) then
		graphResizingThread:kill()
		graphResizingThread = nil
	end
end)

-- Slider mechanics
local dragThread
slider:SetCallback('onmouseldown', function(widget)
	local sliderContainerWidth = interface:GetWidget('spec_stats_graph_slider_container'):GetWidth()
	local cursorXPos = Input.GetCursorPosX()
	local initialX = widget:GetX()
	local initialWidth = widget:GetWidth()
	local xPosOnSlider = Input.GetCursorPosX()-widget:GetAbsoluteX()
	local dragMode = 1 -- 0:expand left, 1: move all, 2: expand right
	if xPosOnSlider < 10 then dragMode = 0 end
	if xPosOnSlider > widget:GetWidth()-10 then dragMode = 2 end
	
	if (dragThread) then
		dragThread:kill()
		dragThread = nil
	end
	dragThread = libThread.threadFunc(function(thread)
		while (true) do
			local cursorXDiff = Input.GetCursorPosX()-cursorXPos
			
			if dragMode == 1 then
				local newX = clamp(initialX+cursorXDiff, 0, sliderContainerWidth-widget:GetWidth())
				widget:SetX(newX)
			elseif dragMode == 0 then
				local newX = clamp(initialX+cursorXDiff, 0, initialX+initialWidth-50)
				widget:SetX(newX)
				local newWidth = clamp(initialWidth-(newX-initialX), 50, 99999)
				widget:SetWidth(newWidth)
			elseif dragMode == 2 then
				local newWidth = clamp(initialWidth+cursorXDiff, 50, sliderContainerWidth-widget:GetX())
				widget:SetWidth(newWidth)
			end
			
			graphStartIndex = widget:GetX()/sliderContainerWidth
			graphEndIndex = (widget:GetX()+widget:GetWidth())/sliderContainerWidth
			
			forcedGraphMin = 0 --Reset graph
			forcedGraphMax = 0
			specUI.updateGraph(true)
			wait(17)--about 60 fps
		end
	end)
end)
slider:SetCallback('onmouselup', function(widget)
	if (dragThread) then
		dragThread:kill()
		dragThread = nil
	end
end)




function specUI.drawGoldGraph()
	graphMode = 1
	forcedGraphMin = 0
	forcedGraphMax = 0
	specUI.updateGraph(true, nil)
end
function specUI.drawXpGraph()
	graphMode = 2
	forcedGraphMin = 0
	forcedGraphMax = 0
	specUI.updateGraph(true, nil)
end

-- 5. Options
function specUI.updateOverlay(show)
	specUI.showingOverlays = show
	local overlay1 = interface:GetWidget('spec_stats_overlay_1')
	local overlay2 = interface:GetWidget('spec_stats_overlay_2')
	if (show) then
		overlay1:SetTexture('/'..interface:GetWidget('spec_stats_options_input_box_1'):GetValue())
		overlay2:SetTexture('/'..interface:GetWidget('spec_stats_options_input_box_2'):GetValue())
		overlay1:GetParent():SetVisible(true)
		overlay2:GetParent():SetVisible(true)
	else
		overlay1:GetParent():SetVisible(false)
		overlay2:GetParent():SetVisible(false)
	end
end

---------------------------------
-- Events to trigger the updaters
---------------------------------
local function GetTimeInGameFormat()
	local mins = (Game.GetMatchTime()/1000) / 60
	local secs = floor(mins%1*60)
	if secs < 10 then secs = "0"..secs end
	return floor(mins) .. ":" .. secs
end

local flashGlowThread = {}
local function AddEvent(event) -- Every major event is passed to this, so add it to a list - but check to see if we already have it first!

	-- Green/red flashs on the main stats panel.
	if event.goodForLegion ~= nil then
		-- Left and right threads are independent and won't interrupt each other. Same side events will.
		local side = event.goodForLegion and 'left' or 'right'
		if (flashGlowThread[side] and flashGlowThread[side]:IsValid()) then
			flashGlowThread[side]:kill()
			flashGlowThread[side] = nil
		end
		flashGlowThread[side] = libThread.threadFunc(function()
			local widget = interface:GetWidget('spec_stats_flash_'..side)
			for n = 1, 3 do
				widget:FadeIn(100)
				wait(300)
				widget:FadeOut(100)
				wait(100)
			end
			widget:FadeIn(100)
			wait(300)
			widget:FadeOut(3000)
		end)
	end

	-- Adding event to the graph.
	for n=1, #majorEventsHistory do
		if (abs(majorEventsHistory[n].frame-event.frame)<=1 and majorEventsHistory[n].tipTitle == event.tipTitle and majorEventsHistory[n].tipBody == event.tipBody) then return end
	end
	tinsert(majorEventsHistory, event)
end
local function GetCurrentX()
	return floor(LuaTrigger.GetTrigger('MatchTime').matchTime/3000)
end

-- Baldir/cindara
object:GetWidget('spec_stats_container_1'):RegisterWatchLua('EventBossKill', function(widget, trigger)
	local team = trigger.attackerTeam==1 and Translate("general_glory") or Translate("general_valor")
	if (trigger.entityName == 'Neutral_BossPowerUp') then
		AddEvent({n=GetCurrentX(), texture='/ui/game/event_log/textures/icon_baldir.tga', goodForLegion=trigger.attackerTeam==1, importance=8, size=35, 
		frame=LuaTrigger.GetTrigger('Replay').frame,
		tipTitle=Translate("spec_stats_baldir_defeat"), 
		tipBody="["..GetTimeInGameFormat().."] "..Translate("spec_stats_baldir_defeat_desc", 'team', team)})
	elseif (trigger.entityName == 'Neutral_TowerMaster') then
		AddEvent({n=GetCurrentX(), texture='/ui/game/event_log/textures/icon_cindara.tga', goodForLegion=trigger.attackerTeam==1, importance=8, size=35, 
		frame=LuaTrigger.GetTrigger('Replay').frame,
		tipTitle=Translate("spec_stats_cindara_defeat"), 
		tipBody="["..GetTimeInGameFormat().."] "..Translate("spec_stats_cindara_defeat_desc", 'team', team)})
	end
end)

-- Returns the index of a hero, given their team and type.
local function findEntityIndex(team, typeName)
	for i = (team-1)*5, (team)*5-1 do
		local trigger = LuaTrigger.GetTrigger('SpectatorUnit' .. i)
		if trigger and trigger.typeName==typeName then return trigger.index end
	end
	return nil
end

-- Hero kill
object:GetWidget('spec_stats_container_1'):RegisterWatchLua('EventKill', function(widget, trigger)
	AddEvent({n=GetCurrentX(), texture=trigger.victimIcon, goodForLegion=trigger.killerTeam==1, importance=5, size=35, 
		frame=LuaTrigger.GetTrigger('Replay').frame, entityIndex = findEntityIndex(1-(trigger.killerTeam-1)+1, trigger.victimTypeName), --1-(x-1)+1 switches 2-1, and 1-2
		tipTitle=Translate("spec_stats_hero_defeat"), 
		tipBody="["..GetTimeInGameFormat().."] "..Translate("spec_stats_hero_defeat_desc", 'victim', trigger.victimName, 'victimHero', string.sub(trigger.victimTypeName, 6), 'killer', trigger.killerName, 'killerHero', string.sub(trigger.killerTypeName, 6)) })
end)
local barracksEntities = {
	'Building_LegionMeleeBarracks',
	'Building_HellbourneMeleeBarracks'
}
local function isBarracksEntity(input)
	return libGeneral.isInTable(barracksEntities, input)
end

local towerEntities = {
	'Building_LegionTower',
	'Building_HellbourneTower',
	'Building_Tutorial_Tower'
}

local function isTowerEntity(input)
	return libGeneral.isInTable(towerEntities, input)
end
-- Tower/generator kill
object:GetWidget('spec_stats_container_1'):RegisterWatchLua('EventBuildingKill', function(widget, trigger)
	local team = trigger.attackerTeam==1 and Translate("general_glory") or Translate("general_valor")
	if isTowerEntity(trigger.entityName) then
		AddEvent({n=GetCurrentX(), texture='/ui/game/event_log/textures/icon_tower1.tga', goodForLegion=trigger.attackerTeam==1, importance=7, size=35, 
		frame=LuaTrigger.GetTrigger('Replay').frame,
		tipTitle=Translate("spec_stats_tower_destroy"), 
		tipBody="["..GetTimeInGameFormat().."] "..Translate("spec_stats_tower_destroy_desc", 'team', team)})
	elseif isBarracksEntity(trigger.entityName) then
		AddEvent({n=GetCurrentX(), texture='/ui/game/event_log/textures/icon_generator.tga', goodForLegion=trigger.attackerTeam==1, importance=9, size=35, 
		frame=LuaTrigger.GetTrigger('Replay').frame,
		tipTitle=Translate("spec_stats_generator_destroy"), 
		tipBody="["..GetTimeInGameFormat().."] "..Translate("spec_stats_generator_destroy_desc", 'team', team)})
	end
end)

-- Second passed
local lastIndex
object:GetWidget('spec_stats_container_1'):RegisterWatchLua('MatchTime', function(widget, trigger)
	specUI.updateGPM()
	local index = GetCurrentX()--Don't update the graph constantly. Only every 3 seconds, to avoid a massive dataset.
	if (index ~= lastIndex) then
	
		-- Three cases here, this new time is the next in line(insert), it is in the future(0 the values in-between), or it is in the past(replace old value).
		local function insertValue(array, value, index)
			if (index>#array) then -- Case 1&2, we need to insert (possibly multiple) values.
				local excess = index-#array
				for n = 1, excess do
					tinsert(array, floor(n/excess)*value) -- Only the last value gets set to non-0.
				end
			else -- We already have a value.. Just replace it, in case it was a lerp from case 2.
				array[index] = value
			end
		end
		local gold1 = LuaTrigger.GetTrigger('SpectatorTeamInfo0').totalGold
		local gold2 = LuaTrigger.GetTrigger('SpectatorTeamInfo1').totalGold
		insertValue(GPMhistory, gold1-gold2, index)
		local xp1 = LuaTrigger.GetTrigger('SpectatorTeamInfo0').totalXP
		local xp2 = LuaTrigger.GetTrigger('SpectatorTeamInfo1').totalXP
		insertValue(XPMhistory, xp1-xp2, index)
		
		lastSecond=trigger.matchTime/1000
		specUI.updateGraph()
		lastIndex = index
	end
end)

-- ================================================================
-- ======================== Gank Alerts ===========================
-- ================================================================

for i=1,3,1 do
	specUIWidgets.gankAlert[i] = {
		container	= object:GetWidget('spectatorGankAlert'..i),
		hotkey		= object:GetWidget('spectatorGankAlert'..i..'Hotkey'),
		icon		= object:GetWidget('spectatorGankAlert'..i..'Icon')
	}
end

function specUI.showGankAlert(id)
	libThread.threadFunc(function()
		local displaySlot = specUIWidgets.gankAlert[id]
		local gankIndex = specUI.gankIndexes[id]
		displaySlot.container:SetY(displaySlot.container:GetHeight() * -1)
		displaySlot.container:FadeOut(0)
		displaySlot.container:SetVisible(false)
		wait(1)
		displaySlot.container:SlideY(0, 150)
		displaySlot.container:FadeIn(150)
		wait(3000)
		if gankIndex == specUI.gankIndexes[id] then
			specUI.hideGankAlert(id)
		end
	end)
end

function specUI.hideGankAlert(id)
	local displaySlot = specUIWidgets.gankAlert[id]
	specUI.gankIndexes[id] = -1
	displaySlot.container:SlideY(displaySlot.container:GetHeight() * -1, 150)
	displaySlot.container:FadeOut(150)
end

function specUI.chooseGankAlert(sourceWidget, id)
	if (specUI.gankIndexes[id] ~= -1) then
		SelectUnit(specUI.gankIndexes[id])
		SelectUnit(specUI.gankIndexes[id])
		specUI.hideGankAlert(id)
	end
end

function specUI.gankAlert(id, entity, index)
	local displaySlot	= specUIWidgets.gankAlert[id]
	local keybind		= GetKeybindButton('spectator', 'TriggerToggle', 'SpecUIViewGank'..id)
	local keybindString	= ''
	if keybind and string.len(keybind) > 0 then
		keybindString = keybind
	end
	specUI.gankIndexes[id] = index
	displaySlot.icon:SetTexture(GetEntityIconPath(entity))
	displaySlot.hotkey:SetText(keybindString)
	specUI.showGankAlert(id)
end

object:GetWidget('gank_alert_container'):RegisterWatchLua('SpectatorGankAlert', function(sourceWidget, trigger)
	local entityName = trigger.entityName
	local unitIndex = trigger.unitIndex
	if specUI.gankIndexes[1] ~= unitIndex and specUI.gankIndexes[2] ~= unitIndex and specUI.gankIndexes[3] ~= unitIndex then
		for i=1,3,1 do
			if specUI.gankIndexes[i] == -1 then
				specUI.gankAlert(i, entityName, unitIndex)
				break
			end
		end
	end
end)

-- ================================================================
-- ========================== Push Bar ============================
-- ================================================================

-- Push bar. Take into account total team gold, xp, as well as recent gold/xp, while having everything smooth and looking nice.
local pushBarThread = nil
function specUI.updatePushBar()
	local team1Trigger = LuaTrigger.GetTrigger('SpectatorTeamInfo0')
	local team2Trigger = LuaTrigger.GetTrigger('SpectatorTeamInfo1')
	local ground = interface:GetWidget('spec_push_bar_ground')
	local greenBar = interface:GetWidget('spec_push_bar_green')
	local redBar = interface:GetWidget('spec_push_bar_red')
	local greenBarContainer = interface:GetWidget('spec_push_bar_green_contianer')
	local icon = interface:GetWidget('spec_push_bar_image')
	
	local recentLeadMultiplier = 0.1
	local smoothing = 0.05
	local pastGoldFactor = 0.25
	local tiltFactor = 75
	local tiltMax = 15
	local recentDecay = 0.98
	local pushGoldThreshhold = 0.5
	local pushXpThreshhold = 0.5
	
	local displayedLead = 0
	local displayLagLag = 0
	local displayedIconLead = 0
	local oldLead = 0
	local recentLead = 0
	
	if (pushBarThread and pushBarThread:IsValid()) then
		pushBarThread:kill()
		pushBarThread = nil
	end
	pushBarThread = libThread.threadFunc(function()
		wait(100)
		while (true) do
			wait(50) -- 20 fps
			-- Reset Check
			if not ground or not ground:IsValid() then
				specUI.updatePushBar()
				return
			end
			
			-- Grab recent statistics
			local gold1 = team1Trigger.totalGold
			local gold2 = team2Trigger.totalGold
			local xp1 = team1Trigger.totalXP
			local xp2 = team2Trigger.totalXP
			
			-- Filter out majority of resources of the game up until this point
			gold1 = gold1 - pastGoldFactor*(math.min(gold1,gold2))
			gold2 = gold2 - pastGoldFactor*(math.min(gold1,gold2))
			xp1 = xp1 - pastGoldFactor*(math.min(xp1,xp2))
			xp2 = xp2 - pastGoldFactor*(math.min(xp1,xp2))
			
			-- Calculate the lead
			local lead = ( (gold1 / (gold1+gold2))*pushGoldThreshhold + (xp1 / (xp1+xp2))*pushXpThreshhold ) * 2 - 1 -- Actual lead
			lead = clamp(lead, -1, 1)
			local displayLag = lead-displayedLead -- Displayed lead
			recentLead = (recentLead)*recentDecay + lead-oldLead
			displayedLead = displayedLead + displayLag*smoothing + recentLead*recentLeadMultiplier
			displayedLead = clamp(displayedLead, -1, 1)
			displayLagLag = displayLagLag + (displayLag-displayLagLag)*smoothing -- Lerp towards Displayed lead - taking recent into account
			
			-- Rotate the ground
			local rotation = (displayLagLag)*tiltFactor
			rotation = clamp(rotation, -tiltMax, tiltMax)
			if (tostring(rotation) == '-1.#IND') then
				specUI.updatePushBar()
				return
			end
			ground:SetRotation(rotation)
			greenBar:SetRotation(rotation)
			redBar:SetRotation(rotation)
			greenBarContainer:SetWidth((displayedLead+1)*50 .. "%")
			
			-- Position the icon
			local distance = displayedLead*125
			if (displayedLead<0) then
				icon:SetTexture('/ui/specui/textures/team_logo_valor_red.tga')
			else
				icon:SetTexture('/ui/specui/textures/team_logo_glory_green.tga')
			end
			icon:SetX(distance*math.cos(rotation*pi/180))
			icon:SetY(distance*math.sin(rotation*pi/180))
			
			oldLead = lead
		end
	end)
end
specUI.updatePushBar()

specUIWidgets.pushBar:RegisterWatchLua('game_specPanelInfo', function(widget, trigger)
	if trigger.moreInfoKey or trigger.pushBarVis then 
		widget:FadeIn(150)
	else
		widget:FadeOut(150)
	end
end, false, nil, 'moreInfoKey', 'pushBarVis')

-- ================================================================
-- ========================= Stats Panel ==========================
-- ================================================================

-- register widgets for stats panel
for n = 1, 10 do
	local parent = interface:GetWidget('ssps_' .. 'player'..n..'StatsLabel')
	local icon = interface:GetWidget('player'..n..'StatsLabel_hero_icon')
	local level = interface:GetWidget('player'..n..'StatsLabel_level_label')
	local name = interface:GetWidget('player'..n..'StatsLabel_player_label')
	local kills = interface:GetWidget('player'..n..'StatsLabel_kills_label')
	local deaths = interface:GetWidget('player'..n..'StatsLabel_deaths_label')
	local assists = interface:GetWidget('player'..n..'StatsLabel_assists_label')
	local trigger = LuaTrigger.GetTrigger('SpectatorUnit' .. (n-1))
	parent:SetVisible(trigger.playerName ~= '')
	specUIWidgets.playersPodParent:RegisterWatchLua('SpectatorUnit'..(n-1), function(widget, trigger)
		icon:SetTexture(trigger.iconPath)
		level:SetText(trigger.level)
		name:SetText(trigger.playerName)
		kills:SetText(trigger.kills)
		deaths:SetText(trigger.death)
		assists:SetText(trigger.assists)
		parent:SetVisible(trigger.playerName ~= '')
	end)
end

-- tab/pin control
specUIWidgets.statPanel:RegisterWatchLua('game_specPanelInfo', function(widget, trigger)
	if trigger.moreInfoKey or trigger.statsVis then
		interface:GetWidget('gank_alert_container'):SlideY("-21h", 50)
		widget:SlideY("0h", 50)
	else
		interface:GetWidget('gank_alert_container'):SlideY("-2.22h", 50)
		widget:SlideY("21.66h", 50)
	end
end, false, nil, 'moreInfoKey', 'unitFramesVis')


-- Update currently open stats tab
local currentStatsPage=1
function specUI.changeStatsPage(page)
	if page==currentStatsPage then return end
	interface:GetWidget('spec_stats_btn_'..currentStatsPage..'current'):SetVisible(false)
	interface:GetWidget('spec_stats_btn_'..			   page..'current'):SetVisible(true)
	local oldPage = currentStatsPage
	currentStatsPage = page
	
	if (page==2) then specUI.updateGPM(nil, false) end
	if (page==3) then specUI.updateGPM(nil, true) end
	if (oldPage) then
		if (oldPage == 3 and page == 2) or (oldPage == 2 and page == 3) then
			return -- Don't fade if we are just changing between GPM and XPM
		end
		if oldPage == 3 then oldPage = 2 end -- panel 3 shares with 2.
		interface:GetWidget('spec_stats_container_'..oldPage):FadeOut(150)
	end
	if page == 3 then page = 2 end
	interface:GetWidget('spec_stats_container_'..page):FadeIn(150)
end
object:GetWidget('spec_stats_btn_'..currentStatsPage..'current'):SetVisible(true)

--[[ Not used currently.
-- ================================================================
-- ==================== Stats Panel (options) =====================
-- ================================================================

-- Update currently open stats options page
local currentStatsOptionsPage=1
function specUI.statsOptionsPageChange(page, relative)
	relative = relative or false
	if relative then
		currentStatsOptionsPage = currentStatsOptionsPage + page
	else
		currentStatsOptionsPage = page
	end
	if currentStatsOptionsPage < 1 then currentStatsOptionsPage = 1 end
	if currentStatsOptionsPage > 2 then currentStatsOptionsPage = 2 end
	interface:GetWidget('spec_stats_container_5_1'):SetVisible(currentStatsOptionsPage==1)
	interface:GetWidget('spec_stats_container_5_2'):SetVisible(currentStatsOptionsPage==2)
	--interface:GetWidget('spec_stats_container_5_3'):SetVisible(currentStatsOptionsPage==3)
	interface:GetWidget('spec_stats_container_5_page_label'):SetText(currentStatsOptionsPage)
	
end
]]

-- ================================================================
-- ========================= GPM/XPM bars =========================
-- ================================================================


local oldMode = false
-- 2/3 GPM/XPM bar updaters. This is run only once a second to avoid lag when sorting
function specUI.updateGPM(force, xp) -- This updates using xpm instead, if xp is true.
	if xp == nil then xp = oldMode end
	if currentStatsPage ~= 2 and currentStatsPage ~= 3 and not force then return end --don't update if we don't need to
	local highest = -1
	local maxBarHeight = interface:GetWidget('spec_stats_container_2'):GetHeight() * 0.7
	-- Get highest GPM for scale first. Also, sort the entries
	local playerlist = {{},{}}
	for n = 1, 10 do
		local value
		if xp then
			value = floor(LuaTrigger.GetTrigger('SpectatorPlayer'..(n-1)).xpPerMinute+0.5)
		else
			value = LuaTrigger.GetTrigger('SpectatorUnit'..(n-1)).gpm
		end
		if value>highest then highest=value end
		local group = n < 6 and 1 or 2
		local playernumber = n-(group-1)*5
		playerlist[group][playernumber] = {playernumber, value}
	end
	tsort(playerlist[1], function(a,b) -- sort legion forwards
		return a[2] < b[2]
	end)
	tsort(playerlist[2], function(a,b) -- sort hellbourne backwards
		return a[2] > b[2]
	end)
	
	for n = 1, 10 do
		local group = n < 6 and 1 or 2
		local playernumber = n-(group-1)*5
		local player = playerlist[group][playernumber][1]+(group-1)*5
		local value =  playerlist[group][playernumber][2]
		local trigger = LuaTrigger.GetTrigger('SpectatorUnit'..(player-1))
		local barHeight = maxBarHeight
		if value > 0 then
			barHeight = maxBarHeight*value/highest
		end

		local label = interface:GetWidget('spec_stats_bar_'..n..'_label')
		label:SetText(value)		
		local labelContainer = interface:GetWidget('spec_stats_bar_'..n..'_label_container')
		labelContainer:SetY((-barHeight+2))		
		local icon = interface:GetWidget('spec_stats_bar_'..n..'_hero_icon')
		icon:SetTexture(trigger.iconPath)
		icon:SetY((-barHeight-10))		
		interface:GetWidget('spec_stats_bar_'..n..'_bar'):SetHeight(barHeight)
	end
	oldMode = xp
end
specUI.updateGPM(true)
specUI.updateGPM(true, true)


-- ================================================================
-- ========================= Unit Frames ==========================
-- ================================================================

function specUI.setHeroFramesDetail(value)
	local slideValues = {0,5,11.66,31.11} -- Full, partial, skills, hidden. Skills only (3) is hidden for the time being.
	specUIWidgets.playerPodGroup1:SlideX(-slideValues[value]..'h', 200)
	specUIWidgets.playerPodGroup2:SlideX( slideValues[value]..'h', 200)
	
	libThread.threadFunc( function()
		wait(1)
		if not interface:IsValid() or not interface:GetWidget('gameEventsContainer') or UIManager.GetActiveInterface():GetName() ~= 'game_spectator' then
			return
		end
		if value < 4 then
			interface:GetWidget('gameEventsContainer'):SlideX(-18.88+slideValues[value]..'h', 200)
		else
			interface:GetWidget('gameEventsContainer'):SlideX('h', 200)
		end
	end)
end

local defaultUnitFrameView = specUI.playerPodView
function specUI.overrideHeroFramesDetail(value)
	SetSave('_spec_playerPodView', value, 'int')
	defaultUnitFrameView = value
	if value ~= -1 then
		Cvar.GetCvar('_spec_unitFramesVis'):Set("false")
		LuaTrigger.GetTrigger('game_specPanelInfo').unitFramesVis = false
	end
	LuaTrigger.GetTrigger('game_specPanelInfo'):Trigger(true)
	
	interface:GetWidget('spec_stats_options_btn_5_2_1'):SetEnabled(not (value==1))
	interface:GetWidget('spec_stats_options_btn_5_2_2'):SetEnabled(not (value==2))
	interface:GetWidget('spec_stats_options_btn_5_2_3'):SetEnabled(not (value==3))
	interface:GetWidget('spec_stats_options_btn_5_2_4'):SetEnabled(not (value==4))
end
interface:GetWidget('spec_stats_options_btn_5_2_'..specUI.playerPodView):SetEnabled(false)

specUIWidgets.playersPodParent:RegisterWatchLua('game_specPanelInfo', function(widget, trigger)
	if trigger.unitFramesVis then 
		for n = 1, 4 do -- reset buttons
			interface:GetWidget('spec_stats_options_btn_5_2_'..n):SetEnabled(true)
		end
	end
	if (trigger.moreInfoKey) or (trigger.unitFramesVis) then
		specUI.playerPodView = 1 -- items
	else
		specUI.playerPodView = defaultUnitFrameView -- portraits only
	end
	specUI.setHeroFramesDetail(specUI.playerPodView)
end, false, nil, 'moreInfoKey', 'unitFramesVis')


-- ================================================================
-- ======================= Ability flyouts ========================
-- ================================================================

function specUI.setItemFlyoutMode(value)
	specUI.abilityFlyoutMode = value
	SetSave('_spec_abilityFlyoutMode', value, 'int')
	interface:GetWidget('spec_stats_options_btn_5_2_5'):SetEnabled(not (value==1))
	interface:GetWidget('spec_stats_options_btn_5_2_6'):SetEnabled(not (value==2))
	interface:GetWidget('spec_stats_options_btn_5_2_7'):SetEnabled(not (value==3))
end
interface:GetWidget('spec_stats_options_btn_5_2_'..(specUI.abilityFlyoutMode+4)):SetEnabled(false)

-- ================================================================
-- ========================= Item flyouts =========================
-- ================================================================

object:RegisterWatchLua('SpectatorItemPurchased', function(sourceWidget, trigger)
	local playerID = trigger.playerIndex
	local spawnTime = GetTime()
	local isRecipe = trigger.isRecipe
	
	if trigger.itemCost > specUI.itemFlyoutCostThreshhold and (isRecipe or not specUI.itemFlyoutRecipeOnly --[[and not trigger.recipeScroll]]) then
		local group = playerID < 5 and 1 or 2
		local playernumber = 1+playerID-(group-1)*5
		
		local spawnPanel = interface:GetWidget('spec_hero_frames_' .. group .. '_' .. playernumber .. '_portrait')
		local flyout = spawnPanel:InstantiateAndReturn('spec_hero_flyout', 'texture', GetEntityIconPath(trigger.entityName))[1]
		flyout:SetX(group==0 and '11.11h' or '-14.44h')
		
		libThread.threadFunc( function()
			wait(1)
			libAnims.wobbleStart(flyout, 2)
			wait(750)
			flyout:FadeOut(150)
			flyout:SlideX('0h', 150)
			flyout:ScaleWidth( '2.22h', 150)
			flyout:ScaleHeight('2.22h', 150)
			wait(200)
			libAnims.wobbleStop(flyout)
			flyout:Destroy()
		end)
	end
end)

function specUI.toggleItemFlyouts()
	specUI.itemFlyoutRecipeOnly = not specUI.itemFlyoutRecipeOnly
	SetSave('_spec_itemFlyoutRecipeOnly', specUI.itemFlyoutRecipeOnly, 'bool')
	interface:GetWidget('spec_stats_options_recipe_only_checkbox'):SetVisible(specUI.itemFlyoutRecipeOnly)
end
interface:GetWidget('spec_stats_options_recipe_only_checkbox'):SetVisible(specUI.itemFlyoutRecipeOnly)
function specUI.setItemFlyoutsCostThreshhold(cost)
	specUI.itemFlyoutCostThreshhold = tonumber(cost) or 250
	SetSave('_spec_itemFlyoutCostThreshhold', specUI.itemFlyoutCostThreshhold, 'int')
end


-- ================================================================
-- ======================= Selected Unit ==========================
-- ================================================================

specUIWidgets.selectedUnit = {
	hero	= {
		container	= object:GetWidget('specSelectedUnitHero'),
		icon		= object:GetWidget('specSelectedUnitHeroIcon'),
		name		= object:GetWidget('specSelectedUnitHeroName'),
		level		= object:GetWidget('specSelectedUnitHeroLevel'),
		healthBar	= object:GetWidget('specSelectedUnitHeroHealthBar'),
		healthCur	= object:GetWidget('specSelectedUnitHeroHealthCur'),
		healthGain	= object:GetWidget('specSelectedUnitHeroHealthGain'),
		healthMax	= object:GetWidget('specSelectedUnitHeroHealthMax'),
		manaBar		= object:GetWidget('specSelectedUnitHeroManaBar'),
		manaCur		= object:GetWidget('specSelectedUnitHeroManaCur'),
		manaGain	= object:GetWidget('specSelectedUnitHeroManaGain'),
		manaMax		= object:GetWidget('specSelectedUnitHeroManaMax'),
		damage		= object:GetWidget('specSelectedUnitHeroDamage'),
		power		= object:GetWidget('specSelectedUnitHeroPower'),
		armor		= object:GetWidget('specSelectedUnitHeroArmor'),
		magArmor	= object:GetWidget('specSelectedUnitHeroMagArmor'),
		mitigation	= object:GetWidget('specSelectedUnitHeroMitigation'),
		resistance	= object:GetWidget('specSelectedUnitHeroResistance'),
		moveSpeed	= object:GetWidget('specSelectedUnitHeroMoveSpeed'),
		items		= {},
		abilities	= {}
	},
	nonHero	= {
		container	= object:GetWidget('specSelectedUnitNonHero'),
		icon		= object:GetWidget('specSelectedUnitNonHeroIcon'),
		name		= object:GetWidget('specSelectedUnitNonHeroName'),
		level		= object:GetWidget('specSelectedUnitNonHeroLevel'),
		damage		= object:GetWidget('specSelectedUnitNonHeroDamage'),
		lifetime	= object:GetWidget('specSelectedUnitNonHeroLifetime'),
		lifetimePie	= object:GetWidget('specSelectedUnitNonHeroLifetimePie'),
		healthBar	= object:GetWidget('specSelectedUnitNonHeroHealthBar'),
		healthCur	= object:GetWidget('specSelectedUnitNonHeroHealthCur'),
		healthGain	= object:GetWidget('specSelectedUnitNonHeroHealthGain'),
		healthMax	= object:GetWidget('specSelectedUnitNonHeroHealthMax')
	},
}

specUIWidgets.selected_frame:RegisterWatchLua('game_specPanelInfo', function(widget, trigger)
	if (trigger.moreInfoKey) or (trigger.selectedUnitVis) then
		widget:SetVisible(1)
		widget:SlideX('0', 125)
	else
		widget:SlideX('-35h', 125)
		widget:Sleep(125, function()
			widget:SetVisible(0)
		end)
	end
end, false, nil, 'moreInfoKey', 'selectedUnitVis')

for i=0,3,1 do -- Abilities
	specUIWidgets.selectedUnit.hero.abilities[i] = {
		container			= object:GetWidget('specSelectedUnitHeroAbility'..i),
		icon				= object:GetWidget('specSelectedUnitHeroAbility'..i..'Icon'),
		cooldown			= object:GetWidget('specSelectedUnitHeroAbility'..i..'Cooldown'),
		cooldownPie			= object:GetWidget('specSelectedUnitHeroAbility'..i..'CooldownPie'),
		statusCornerGroup	= object:GetGroup('specSelectedUnitHeroAbility'..i..'StatusCornerGroup'),
		statusFrameGroup	= object:GetGroup('specSelectedUnitHeroAbility'..i..'StatusFrameGroup')
	}
	
	specUIWidgets.selectedUnit.hero.abilities[i].container:SetCallback('onmouseover', function(widget)
		Trigger('abilityTipShow', 1, i)
	end)
	
	specUIWidgets.selectedUnit.hero.abilities[i].container:SetCallback('onmouseout', function(widget)
		Trigger('abilityTipHide')
	end)	
	
	specUIWidgets.selectedUnit.hero.abilities[i].container:RegisterWatchLua('SelectedInventory'..i, function(widget, trigger)
		widget:SetVisible(trigger.exists)
	end, false, nil, 'exists')	
	
	specUIWidgets.selectedUnit.hero.abilities[i].icon:RegisterWatchLua('SelectedInventory'..i, function(widget, trigger)
		widget:SetTexture(trigger.icon)
	end, false, nil, 'icon')

	specUIWidgets.selectedUnit.hero.abilities[i].cooldown:RegisterWatchLua('SelectedInventory'..i, function(widget, trigger)
		local remainingCooldownTime = trigger.remainingCooldownTime
		if remainingCooldownTime > 0 then
			widget:SetText(math.ceil(remainingCooldownTime / 1000)..'s')
		else
			widget:SetText('')
		end
		specUIWidgets.selectedUnit.hero.abilities[i].cooldownPie:SetValue(trigger.remainingCooldownPercent)
	end, false, nil, 'remainingCooldownTime', 'remainingCooldownPercent')
	
	object:RegisterWatchLua('SelectedInventory'..i, function(widget, trigger)
		local displaySlot = specUIWidgets.selectedUnit.hero.abilities[i]

		if trigger.level < 1 then
			colorString = '0.75 0.75 0.75 0.5'
			displaySlot.icon:SetColor('1 1 1 0.5')
		else
			displaySlot.icon:SetColor('white')
			if trigger.isDisabled then
				colorString = 'red'
			elseif false then	-- trigger.isPassive
				colorString = 'green'
			elseif trigger.needMana then
				colorString = '#0084ff'
			elseif trigger.isOnCooldown then
				colorString = 'yellow'
			elseif trigger.isActive then	-- was canActivate
				colorString = 'lime'
			else
				colorString = 'orange'
			end
		end
		
		if (displaySlot) and (displaySlot.statusFrameGroup) then
			for k,v in pairs(displaySlot.statusFrameGroup) do
				v:SetColor(colorString)
			end
		end
		
		if (displaySlot) and (displaySlot.statusCornerGroup) then
			for k,v in pairs(displaySlot.statusCornerGroup) do
				v:SetColor(colorString)
			end
		end
		
	end, false, nil, 'isDisabled', 'needMana', 'isActive', 'level', 'isOnCooldown')	-- isPassive
	
end




local trigger_spec_spec_shopItemTipInfo = LuaTrigger.CreateCustomTrigger('spec_shopItemTipInfo', {
	{ name	= 'index',							type		= 'number' },
	{ name	= 'itemType',						type		= 'string' },
})

local function shopItemTipRegisterStat(object, index, statName, heroTriggerName, iconPath)
	local container	= object:GetWidget('shopItemTip_compare_'..heroTriggerName)
	local icon		= object:GetWidget('shopItemTip_compare_'..heroTriggerName..'_icon')
	local label_1		= object:GetWidget('shopItemTip_compare_'..heroTriggerName..'_label_1')
	local label_2		= object:GetWidget('shopItemTip_compare_'..heroTriggerName..'_label_2')
	local label_3		= object:GetWidget('shopItemTip_compare_'..heroTriggerName..'_label_3')
	local lastIndex	= -1

	if (not container) then return end

	icon:SetTexture(iconPath or '$invis')
	icon:SetColor(style_crafting_componentTypeColors[statName] or '1 1 1 1')

	container:RegisterWatchLua('spec_shopItemTipInfo', function(widget, trigger)
		local newIndex = trigger.index
		local statTotal

		if lastIndex >= 0 then
			container:UnregisterAllWatchLuaByKey('shopItemWatchStat'..index)
		end

		if newIndex >= 0 then
			local triggerName = 'ShopItem'
			local itemType = trigger.itemType
			if string.len(itemType) > 0 then triggerName = itemType end
			container:RegisterWatchLua(triggerName..newIndex, function(widget, trigger)
				if (trigger[statName] > 0) then
					widget:SetVisible(1)

					if (statName ~= 'baseAttackSpeed') then
						statTotal = trigger[statName] + LuaTrigger.GetTrigger('HeroUnit')[heroTriggerName]
						label_2:SetText('^777(' .. FtoA2(LuaTrigger.GetTrigger('HeroUnit')[heroTriggerName], 0, 1) .. ' ^g+'..FtoA2(trigger[statName], 0, 1)..'^777)^*   '.. FtoA2(statTotal, 0, 1))
						label_3:SetText(Translate('shop_item_compare_stat_'..heroTriggerName..'_tip', 'value', FtoA2(statTotal, 0, 1)))
					else
						statTotal = (100 * trigger[statName]) + LuaTrigger.GetTrigger('HeroUnit')[heroTriggerName]
						label_2:SetText('^777(' .. FtoA2(LuaTrigger.GetTrigger('HeroUnit')[heroTriggerName], 0, 1) .. ' ^g+'..FtoA2((100 * trigger[statName]), 0, 1)..'^777)^*   '.. FtoA2(statTotal, 0, 1))
						label_3:SetText(Translate('shop_item_compare_stat_'..heroTriggerName..'_tip', 'value', FtoA2(((100 * trigger[statName])-100) + LuaTrigger.GetTrigger('HeroUnit')[heroTriggerName], 0, 1)))
					end
				else
					widget:SetVisible(0)
				end
			end, false, 'shopItemWatchStat'..index, statName)
			lastIndex = newIndex
		end
	end, false, nil, 'index', 'itemType')
end

local function shopItemTipRegisterComponent(object, index, useDivider)
	useDivider = useDivider or false
	local container	= object:GetWidget('shopItemTipComponent'..index)
	local icon	= object:GetWidget('shopItemTipComponent'..index..'Icon')
	local lastIndex	= -1
	local divider
	if useDivider then
		divider	= object:GetWidget('shopItemTipComponent'..index..'Divider')
	end

	container:RegisterWatchLua('spec_shopItemTipInfo', function(widget, trigger)
		local newIndex		= trigger.index

		if lastIndex >= 0 then
			container:UnregisterAllWatchLuaByKey('shopItemWatchComponent'..index)
			if useDivider then
				divider:UnregisterWatchLuaByKey('shopItemWatchComponent'..index)
			end
		end

		if newIndex >= 0 then
			local triggerName = 'ShopItem'
			local itemType		= trigger.itemType
			local paramPrefix	= 'recipeComponentDetail'
			local existsParam	= 'exists'
			local iconParam		= 'icon'

			if itemType == 'SelectedInventory' or itemType == 'ActiveInventory' or itemType == 'StashInventory' or itemType == 'HeroInventory' then
				paramPrefix = 'recipeComponentDetail'
				existsParam	= 'isValid'
				iconParam	= 'icon'
			end

			if string.len(itemType) > 0 then triggerName = itemType end

			local infoTrigger = LuaTrigger.GetTrigger(triggerName..newIndex)
			icon:SetTexture(infoTrigger[paramPrefix..index..iconParam])

			container:RegisterWatchLua(triggerName..newIndex, function(widget, trigger)
				widget:SetVisible(infoTrigger[paramPrefix..index..existsParam])
			end, false, 'shopItemWatchComponent'..index, paramPrefix..index..existsParam)

			if useDivider then
				divider:SetVisible(infoTrigger[paramPrefix..index..existsParam])
				divider:RegisterWatchLua(triggerName..newIndex, function(widget, trigger)
					widget:SetVisible(infoTrigger[paramPrefix..index..existsParam])
				end, false, 'shopItemWatchComponent'..index, paramPrefix..index..existsParam)
			end

			infoTrigger:Trigger(true)

			lastIndex = newIndex
		end
	end, false, nil, 'index', 'itemType')
end

local function shopItemTipRegister(object)
	local container			= object:GetWidget('shopItemTip')
	local icon				= object:GetWidget('shopItemTipIcon')
	local name				= object:GetWidget('shopItemTipName')
	local description		= object:GetWidget('shopItemTipDescription')
	local cost				= object:GetWidget('shopItemTipCost')
	local cooldownContainer	= object:GetWidget('shopItemTipCooldownContainer')
	local manaCostContainer	= object:GetWidget('shopItemTipManaCostContainer')
	local components		= object:GetWidget('shopItemTipComponents')
	local manaDivider		= object:GetWidget('shopItemTipManaDivider')
	local manaCost			= object:GetWidget('shopItemTipManaCost')
	local cooldown			= object:GetWidget('shopItemTipCooldown')
	local enchantLabel1		= object:GetWidget('shopItemTip_enchantment_label_1')
	local enchantLabel3		= object:GetWidget('shopItemTip_enchantment_label_3')
	local enchantIcon		= object:GetWidget('shopItemTip_enchantment_icon')
	local enchantContainer	= object:GetWidget('shopItemTip_enchantment')
	local lastIndex			= -1

	function spec_shopItemTipShow(index, itemType)
		itemType = itemType or ''
		container:SetVisible(true)
		trigger_spec_spec_shopItemTipInfo.index = index
		trigger_spec_spec_shopItemTipInfo.itemType = itemType
		trigger_spec_spec_shopItemTipInfo:Trigger(false)
	end

	function spec_shopItemTipHide()
		container:SetVisible(false)
	end

	shopItemTipRegisterStat(object, 1, 'power', 'power', '/ui/elements:itemtype_damage')
	shopItemTipRegisterStat(object, 6, 'baseAttackSpeed', 'baseAttackSpeed', '/ui/elements:itemtype_boots')
	shopItemTipRegisterStat(object, 7, 'armor', 'armor', '/ui/elements:itemtype_physdefense')
	shopItemTipRegisterStat(object, 8, 'magicArmor', 'magicArmor', '/ui/elements:itemtype_magdefense')
	shopItemTipRegisterStat(object, 9, 'mitigation', 'mitigation', '/ui/elements:itemtype_mitigation')
	shopItemTipRegisterStat(object, 10, 'resistance', 'resistance', '/ui/elements:itemtype_resistance')
	shopItemTipRegisterStat(object, 2, 'maxHealth', 'healthMax', '/ui/elements:itemtype_health')
	shopItemTipRegisterStat(object, 3, 'maxMana', 'manaMax', '/ui/elements:itemtype_mana')
	shopItemTipRegisterStat(object, 4, 'baseHealthRegen', 'healthRegen', '/ui/elements:itemtype_healthregen')
	shopItemTipRegisterStat(object, 5, 'baseManaRegen', 'manaRegen', '/ui/elements:itemtype_manaregen')

	for i=0,2,1 do
		shopItemTipRegisterComponent(object, i, (i >= 1))
	end

	container:RegisterWatchLua('spec_shopItemTipInfo', function(widget, trigger)

		local index = trigger.index

		if lastIndex >= 0 then
			container:UnregisterAllWatchLuaByKey('shopItemWatch')
		end

		if index >= 0 then

			local triggerName			= 'ShopItem'
			local itemType				= trigger.itemType
			local cooldownParam			= 'cooldown'
			local costParam				= 'cost'
			local recipeParam			= 'isRecipe'
			local firstComponentParam	= 'recipeComponentDetail0exists'

			if string.len(itemType) > 0 then 
				triggerName = itemType 
			end

			if itemType == 'SelectedInventory' or itemType == 'ActiveInventory' or itemType == 'StashInventory' or itemType == 'HeroInventory' then
				cooldownParam		= 'cooldownTime'
				costParam			= 'sellValue'
				-- recipeParam		= 'isRecipeCompleted'
				firstComponentParam	= 'recipeComponentDetail0isValid'
			end
			
			enchantContainer:RegisterWatchLua(triggerName..index, function(widget, trigger) widget:SetVisible(trigger.currentEmpoweredEffectEntityName ~= "") end, false, 'shopItemWatch', 'currentEmpoweredEffectEntityName')
			enchantLabel1:RegisterWatchLua(triggerName..index, function(widget, trigger) widget:SetText(trigger.currentEmpoweredEffectDisplayName) end, false, 'shopItemWatch', 'currentEmpoweredEffectDisplayName')
			enchantLabel3:RegisterWatchLua(triggerName..index, function(widget, trigger) widget:SetText(trigger.currentEmpoweredEffectDescription) end, false, 'shopItemWatch', 'currentEmpoweredEffectDescription')
			enchantIcon:RegisterWatchLua(triggerName..index, function(widget, trigger)
				if (trigger.currentEmpoweredEffectEntityName) and (not Empty(trigger.currentEmpoweredEffectEntityName)) and ValidateEntity(trigger.currentEmpoweredEffectEntityName) then
					widget:SetTexture('/ui/main/crafting/textures/imbue_icon_selected_' .. tonumber(string.sub(trigger.currentEmpoweredEffectEntityName, -1, -1))-1 .. '.tga')
				end
			end, false, 'shopItemWatch', 'currentEmpoweredEffectEntityName')
			
			
			
			icon:RegisterWatchLua(triggerName..index, function(widget, trigger) widget:SetTexture(trigger.icon) end, false, 'shopItemWatch', 'icon')
			name:RegisterWatchLua(triggerName..index, function(widget, trigger) widget:SetText(trigger.displayName) end, false, 'shopItemWatch', 'displayName')

			cost:RegisterWatchLua(triggerName..index, function(widget, trigger) widget:SetText(libNumber.commaFormat(trigger[costParam])) end, false, 'shopItemWatch', costParam)

			manaDivider:RegisterWatchLua(triggerName..index, function(widget, trigger)
				widget:SetVisible(trigger.manaCost > 0 and trigger[cooldownParam] > 0)
			end, false, 'shopItemWatch', 'manaCost', cooldownParam)

			description:RegisterWatchLua(triggerName..index, function(widget, trigger) widget:SetText(trigger.description) end, false, 'shopItemWatch', 'description')

			components:RegisterWatchLua(triggerName..index, function(widget, trigger)
				widget:SetVisible(trigger[firstComponentParam])
			end, false, 'shopItemWatch', firstComponentParam)

			manaCost:RegisterWatchLua(triggerName..index, function(widget, trigger)
				local manaCost = trigger.manaCost

				if manaCost > 0 then
					widget:SetText(manaCost)
					manaCostContainer:SetVisible(true)
				else
					manaCostContainer:SetVisible(false)
				end
			end, false, 'shopItemWatch', 'manaCost')

			cooldown:RegisterWatchLua(triggerName..index, function(widget, trigger)
				local cooldown = trigger[cooldownParam]

				if cooldown > 0 then
					widget:SetText(libNumber.round(cooldown / 1000, 1))
					cooldownContainer:SetVisible(true)
				else
					cooldownContainer:SetVisible(false)
				end
			end, false, 'shopItemWatch', cooldownParam)

			LuaTrigger.GetTrigger(triggerName..index):Trigger(true)
			lastIndex = index
		end
	end)

end

shopItemTipRegister(object)

trigger_spec_spec_shopItemTipInfo.index		= -1
trigger_spec_spec_shopItemTipInfo.itemType	= ''
trigger_spec_spec_shopItemTipInfo:Trigger(true)

for i=96,102 do	-- Items
	specUIWidgets.selectedUnit.hero.items[i] = {
		container			= object:GetWidget('specSelectedUnitHeroItem'..i),
		icon				= object:GetWidget('specSelectedUnitHeroItem'..i..'Icon'),
		cooldown			= object:GetWidget('specSelectedUnitHeroItem'..i..'Cooldown'),
		cooldownPie			= object:GetWidget('specSelectedUnitHeroItem'..i..'CooldownPie'),
		statusCornerGroup	= object:GetGroup('specSelectedUnitHeroItem'..i..'StatusCornerGroup'),
		statusFrameGroup	= object:GetGroup('specSelectedUnitHeroItem'..i..'StatusFrameGroup')
	}

	specUIWidgets.selectedUnit.hero.items[i].container:SetCallback('onmouseover', function(widget)
		spec_shopItemTipShow(i, 'SelectedInventory')
	end)
	
	specUIWidgets.selectedUnit.hero.items[i].container:SetCallback('onmouseout', function(widget)
		spec_shopItemTipHide()
	end)		
	
	specUIWidgets.selectedUnit.hero.items[i].icon:RegisterWatchLua('SelectedInventory'..i, function(widget, trigger) widget:SetTexture(trigger.icon) end, false, nil, 'icon')
	specUIWidgets.selectedUnit.hero.items[i].container:RegisterWatchLua('SelectedInventory'..i, function(widget, trigger) widget:SetVisible(trigger.exists) end, false, nil, 'exists')

	specUIWidgets.selectedUnit.hero.items[i].cooldown:RegisterWatchLua('SelectedInventory'..i, function(widget, trigger)
		local displaySlot = specUIWidgets.selectedUnit.hero.items[i]
		local remainingCooldownTime = trigger.remainingCooldownTime
		if remainingCooldownTime > 0 then
			displaySlot.cooldown:SetText(math.ceil(remainingCooldownTime / 1000)..'s')
		else
			displaySlot.cooldown:SetText('')
		end
		displaySlot.cooldownPie:SetValue(trigger.remainingCooldownPercent)
	end, false, nil, 'remainingCooldownTime', 'remainingCooldownPercent')
end

local SelectedUnitGroupTrigger_trigger = LuaTrigger.CreateGroupTrigger('SelectedUnitGroupTrigger', {'SelectedUnit', 'SelectedUnits0'})

object:RegisterWatchLua('SelectedUnitGroupTrigger', function(widget, groupTrigger)
		local SelectedUnit 		= groupTrigger[1]
		local SelectedUnits0 	= groupTrigger[2]
		-- local SelectedVisible0 	= groupTrigger[3]
		-- local SelectedVisible1 = LuaTrigger.GetTrigger('SelectedVisible1')
		
		if (SelectedUnits0.isVisible) then
			specUIWidgets.selectedUnit.hero.container:SetVisible(SelectedUnit.hasInventory and (not Empty(SelectedUnits0.displayName)))
			specUIWidgets.selectedUnit.nonHero.container:SetVisible((not SelectedUnit.hasInventory) and (not Empty(SelectedUnits0.displayName)))
		else
			specUIWidgets.selectedUnit.hero.container:SetVisible(false)
			specUIWidgets.selectedUnit.nonHero.container:SetVisible(false)
		end
	end
)

specUIWidgets.selectedUnit.hero.icon:RegisterWatchLua('SelectedUnitGroupTrigger', function(widget, groupTrigger)
	local trigger = groupTrigger[1]
	
	local playerSlot = trigger.playerSlot
	local unitTrigger = LuaTrigger.GetTrigger('SpectatorUnit' .. playerSlot)
	
	if (unitTrigger) and (unitTrigger.typeName) and (not Empty(unitTrigger.typeName)) then
		local conceptArtPath = '/ui/game/loading/textures/'
		conceptArtPath = conceptArtPath .. string.lower(unitTrigger.typeName) .. '_default.jpg'
		widget:SetImage(conceptArtPath)
		widget:SetVisible(true)	
	else
		widget:SetImage('')
		widget:SetVisible(true)
	end

end)

specUIWidgets.selectedUnit.nonHero.icon:RegisterWatchLua('SelectedUnitGroupTrigger', function(widget, groupTrigger)
	local trigger = groupTrigger[2]
	if (trigger.iconPath) and (not Empty(trigger.iconPath)) then
		widget:SetTexture(trigger.iconPath)
	else
		widget:SetTexture('$checker')
	end
end)

specUIWidgets.selectedUnit.hero.level:RegisterWatchLua('SelectedUnitGroupTrigger', function(widget, groupTrigger)
	local trigger = groupTrigger[2]
	if (trigger.level) and (trigger.level > 0) then
		widget:SetText(math.floor(trigger.level))
	else
		widget:SetText('-')
	end
end)

specUIWidgets.selectedUnit.hero.name:RegisterWatchLua('SelectedUnitGroupTrigger', function(widget, groupTrigger)
	local trigger = groupTrigger[2]
	if (trigger.displayName) and (not Empty(trigger.displayName)) then
		widget:SetText(trigger.displayName)
	else
		widget:SetText('?')
	end
end)

specUIWidgets.selectedUnit.nonHero.name:RegisterWatchLua('SelectedUnitGroupTrigger', function(widget, groupTrigger)
	local trigger = groupTrigger[2]
	if (trigger.displayName) and (not Empty(trigger.displayName)) then
		widget:SetText(trigger.displayName)
	else
		widget:SetText('?')
	end
end)

specUIWidgets.selectedUnit.hero.healthCur:RegisterWatchLua('SelectedUnitGroupTrigger', function(widget, groupTrigger)
	local trigger = groupTrigger[2]
	local health		= trigger.health
	local healthMax		= trigger.healthMax
	local healthPercent	= trigger.healthPercent
	specUIWidgets.selectedUnit.hero.healthCur:SetText(math.ceil(health))
	specUIWidgets.selectedUnit.nonHero.healthCur:SetText(math.ceil(health))
	specUIWidgets.selectedUnit.hero.healthMax:SetText(math.ceil(healthMax))
	specUIWidgets.selectedUnit.nonHero.healthMax:SetText(math.ceil(healthMax))
	specUIWidgets.selectedUnit.hero.healthBar:SetWidth(ToPercent(healthPercent))
	specUIWidgets.selectedUnit.nonHero.healthBar:SetWidth(ToPercent(healthPercent))
end)

specUIWidgets.selectedUnit.hero.manaCur:RegisterWatchLua('SelectedUnitGroupTrigger', function(widget, groupTrigger)
	local trigger = groupTrigger[2]
	specUIWidgets.selectedUnit.hero.manaCur:SetText(math.ceil(trigger.mana))
	specUIWidgets.selectedUnit.hero.manaMax:SetText(math.ceil(trigger.manaMax))
	specUIWidgets.selectedUnit.hero.manaBar:SetWidth(ToPercent(trigger.manaPercent))
end)

specUIWidgets.selectedUnit.hero.healthGain:RegisterWatchLua('SelectedUnitGroupTrigger', function(widget, groupTrigger)
	local trigger = groupTrigger[1]
	specUIWidgets.selectedUnit.hero.healthGain:SetText(libNumber.round('+'..trigger.healthRegen, 1))
	specUIWidgets.selectedUnit.nonHero.healthGain:SetText('+'..libNumber.round(trigger.healthRegen, 1))
end)

specUIWidgets.selectedUnit.hero.manaGain:RegisterWatchLua('SelectedUnitGroupTrigger', function(widget, groupTrigger)
	local trigger = groupTrigger[1]
	specUIWidgets.selectedUnit.hero.manaGain:SetText('+'..libNumber.round(trigger.manaRegen, 1))
end)

specUIWidgets.selectedUnit.hero.damage:RegisterWatchLua('SelectedUnitGroupTrigger', function(widget, groupTrigger)
	local trigger = groupTrigger[1]
	specUIWidgets.selectedUnit.hero.damage:SetText(math.floor(trigger.damage))
	specUIWidgets.selectedUnit.nonHero.damage:SetText(math.floor(trigger.damage))
end)

specUIWidgets.selectedUnit.hero.power:RegisterWatchLua('SelectedUnitGroupTrigger', function(widget, groupTrigger)
	local trigger = groupTrigger[1]
	specUIWidgets.selectedUnit.hero.power:SetText(math.floor(trigger.power))
	specUIWidgets.selectedUnit.hero.armor:SetText(math.floor(trigger.armor))
	specUIWidgets.selectedUnit.hero.magArmor:SetText(math.floor(trigger.magicArmor))
	specUIWidgets.selectedUnit.hero.mitigation:SetText(math.floor(trigger.mitigation))
	specUIWidgets.selectedUnit.hero.resistance:SetText(math.floor(trigger.resistance))
	specUIWidgets.selectedUnit.hero.moveSpeed:SetText(math.floor(trigger.moveSpeed))
end)

specUIWidgets.selectedUnit.nonHero.lifetimePie:RegisterWatchLua('SelectedUnitGroupTrigger', function(widget, groupTrigger)
	local trigger = groupTrigger[1]
	local remainingLifetime = trigger.remainingLifetime
	specUIWidgets.selectedUnit.nonHero.lifetimePie:SetValue(trigger.remainingLifetimePercent)
	if remainingLifetime > 0 then
		specUIWidgets.selectedUnit.nonHero.lifetime:SetText(math.ceil(remainingLifetime / 1000)..'s')
	else
		specUIWidgets.selectedUnit.nonHero.lifetime:SetText('')
	end
end)


local function gamePlayerInfoMVPRegister(object, widgetName, paramName, playerIndex)

	local icon	= object:GetWidget(widgetName)

	icon:RegisterWatchLua('game_specPanelInfo', function(widget, trigger)
		widget:SetVisible(trigger[paramName])
	end, false, nil, paramName)
	
	icon:RegisterWatchLua('Team', function(widget, trigger)

		if (playerIndex >= 5) then
			widget:SetHFlip(true)
			widget:SetAlign('left')
			widget:SetX(libGeneral.HtoP(-1.25))
		else
			widget:SetHFlip(false)
			widget:SetAlign('right')
			widget:SetX(libGeneral.HtoP(1.25))
		end
	end)
end

local function gamePlayerInfoVoipRegister(object, widgetName, triggerName)
	object:GetWidget(widgetName):RegisterWatchLua(triggerName, function(widget, trigger) widget:SetVisible(trigger.isTalking) end, false, nil, 'isTalking')
end

local function gamePlayerInfoDisconnectTimeRegister(object, widgetName, triggerName)
	object:GetWidget(widgetName):RegisterWatchLua(triggerName, function(widget, trigger)
		widget:SetText(libNumber.timeFormat(trigger.disconnectTime))
		widget:SetVisible(trigger.isDisconnected)
	end, false, nil, 'disconnectTime', 'isDisconnected')
end

local function gamePlayerInfoLoadPercentRegister(object, widgetName, triggerName)
	object:GetWidget(widgetName):RegisterWatchLua(triggerName, function(widget, trigger)
		widget:SetText(floor(trigger.loadingPercent * 100)..'%')
		widget:SetVisible(trigger.isLoading)
	end, false, nil, 'loadingPercent', 'isLoading')
end

local function gamePlayerInfoLoadIconRegister(object, widgetName, triggerName)
	object:GetWidget(widgetName):RegisterWatchLua(triggerName, function(widget, trigger)
		widget:SetVisible(trigger.isLoading)
	end, false, nil, 'isLoading')
end

local function gamePlayerInfoDisconnectIconRegister(object, widgetName, triggerName)
	object:GetWidget(widgetName):RegisterWatchLua(triggerName, function(widget, trigger)
		widget:SetVisible(trigger.isDisconnected)
	end, false, nil, 'isDisconnected')	
end

local function gamePlayerInfoLevelRegister(object, widgetName, triggerName, isEnemy)
	isEnemy = isEnemy or false
	local label = object:GetWidget(widgetName)
	label:RegisterWatchLua(triggerName, function(widget, trigger)
		widget:SetText(trigger.level)
	end, false, nil, 'level')	
end

local function gamePlayerInfoAFKRegister(object, widgetName, triggerName)
	object:GetWidget(widgetName):RegisterWatchLua(triggerName, function(widget, trigger)
		widget:SetVisible(trigger.isAFK)
	end, false, nil, 'isAFK')
end

local function gamePlayerInfoDeadIconRegister(object, widgetName, triggerName, playerIndex)
	isEnemy = isEnemy or false
	local icon	= object:GetWidget(widgetName)

	icon:RegisterWatchLua(triggerName, function(widget, trigger)
		widget:SetVisible(not trigger.isActive)
	end, false, nil, 'isActive')
	
	icon:RegisterWatchLua('Team', function(widget, trigger)
		if (playerIndex >= 5) then
			widget:SetAlign('left')
			widget:SetX(libGeneral.HtoP(-1.2))		
		else
			widget:SetAlign('right')
			widget:SetX(libGeneral.HtoP(1.2))
		end
	end)
end

local function gamePlayerInfoRespawnRegister(object, widgetName, triggerName)
	object:GetWidget(widgetName):RegisterWatchLua(triggerName, function(widget, trigger)
		if (trigger.remainingRespawnTime > 0) then
			widget:SetVisible(not trigger.isActive)
			widget:SetText(math.ceil(trigger.remainingRespawnTime / 1000))
		else
			widget:SetVisible(false)
		end
	end, false, nil, 'isActive', 'remainingRespawnTime')
end


-- RMM replace with libGeneral.getCutoutOrRegularIcon(entityName), which grabs it from the entity file
local function getHeroHeadCutoutFromIcon(iconPath) --Note: This is also in events2.lua and arcade_text.lua, perhaps it should be refactored.
	if iconPath and type(iconPath) == 'string' and string.len(iconPath) > 0 then
		return string.sub(iconPath, 1,-5)..'_full.tga'
	end
	
	return ''
end

local function RegisterUnitFrames(object)
	-- Hero portrait tooltip
	local function ShowHeroTooltip(sourceWidget, playerIndex)
		local unitTriggerName = 'SpectatorUnit' .. playerIndex
		local unitTrigger = LuaTrigger.GetTrigger(unitTriggerName)
		local height, width = 15.8, 22
		
		local function labelWatchTrigger(widgetString,UnregisterKey, value)
			sourceWidget:GetWidget(widgetString):UnregisterWatchLuaByKey(UnregisterKey)
			sourceWidget:GetWidget(widgetString):SetText(unitTrigger[value])
			sourceWidget:GetWidget(widgetString):RegisterWatchLua(unitTriggerName, function(widget2, trigger2)
				widget2:SetText(trigger2[value])
			end, false, UnregisterKey, value)
		end
		local function GetIcon(index)
			local iconTrigger = LuaTrigger.GetTrigger('Spectator'..index..'HeroInventory'..playerIndex)
			if (iconTrigger.iconPath) and (not Empty(iconTrigger.iconPath)) and (iconTrigger.isValid) then
				return iconTrigger.iconPath
			else
				return '/ui/shared/textures/pack2.tga'
			end
		end
		
		local prefix='game_hero_unitframe_tooltip'
		sourceWidget:GetWidget(prefix):SetVisible(1)
		sourceWidget:GetWidget(prefix..'_icon'):SetTexture(unitTrigger.iconPath)
		sourceWidget:GetWidget(prefix..'_player_label'):SetText(unitTrigger.playerName)
		sourceWidget:GetWidget(prefix..'_hero_label'):SetText(unitTrigger.name)
		
		if (trigger_game_specPanelInfo['player'..playerIndex..'MVP']) then
			height = height + 3.0
			sourceWidget:GetWidget(prefix..'_mvp'):SetVisible(1)
			sourceWidget:GetWidget(prefix..'_mvp_label'):UnregisterWatchLuaByKey('tooltip_mvp_label')
			sourceWidget:GetWidget(prefix..'_mvp_label'):SetText(Translate('game_mvp_enemy', 'value', (unitTrigger.kills + unitTrigger.assists)))
			sourceWidget:GetWidget(prefix..'_mvp_label'):RegisterWatchLua(unitTriggerName, function(widget2, trigger2)
				widget2:SetText(Translate('game_mvp_enemy', 'value', (trigger2.kills + trigger2.assists)))
			end, false, 'tooltip_mvp_label', 'kills', 'assists')
		else
			sourceWidget:GetWidget(prefix..'_mvp'):SetVisible(0)
			sourceWidget:GetWidget(prefix..'_mvp_label'):UnregisterWatchLuaByKey('tooltip_mvp_label')
		end	
		labelWatchTrigger(prefix..'_kills_label', 'tooltip_kills_label', 'kills')
		labelWatchTrigger(prefix..'_assists_label', 'tooltip_assists_label', 'assists')
		labelWatchTrigger(prefix..'_deaths_label', 'tooltip_deaths_label', 'death')
		labelWatchTrigger(prefix..'_gold_label', 'tooltip_gold_label', 'gold')
		labelWatchTrigger(prefix..'_gpm_label', 'tooltip_gpm_label', 'gpm')
		
		height = height + 10.9
		sourceWidget:GetWidget(prefix..'_inventory_parent'):SetVisible(1)
		for n = 0, 6 do
			sourceWidget:GetWidget(prefix..'_inventory_'..n):SetTexture(GetIcon(n))
		end
		sourceWidget:GetWidget(prefix):SetHeight(libGeneral.HtoP(height))
		sourceWidget:GetWidget(prefix):SetWidth(libGeneral.HtoP(width))
	end
	
	local function HideHeroTooltip(sourceWidget)
		sourceWidget:GetWidget('game_hero_unitframe_tooltip'):SetVisible(0)
	end
	
	-- Custom hero portraits:
	for groupIndex = 0, 1 do
		for playerIndex = 0,4,1 do
			local player = groupIndex*5 + playerIndex
			
			if (groupIndex == 1) then --Red backgrounds for right portraits
				object:GetWidget('spec_hero_frames_2_'..playerIndex+1 .. '_portrait_side'):SetTexture('/ui/specui/textures/spec_hero_frame_heroset_right.tga')
			end
			
			-- Abilities
			for n = 0, 3 do
				local abilityPanel = object:GetWidget('spec_hero_frames_' .. groupIndex+1 .. '_' .. playerIndex+1 .. '_abiltiy_' .. n+1)
				local trigger = LuaTrigger.GetTrigger('SpectatorHeroAbility'.. n ..'Info' .. player)
				local oldCooldown = false
				abilityPanel:RegisterWatchLua('SpectatorHeroAbility'.. n ..'Info' .. player, function(widget, trigger)
					widget:SetTexture(trigger.iconPath)
					local onCooldown = trigger.remainingCooldownTime > 0
					widget:SetRenderMode(onCooldown and 'grayscale' or 'normal')
					local label = interface:GetWidget('spec_hero_frames_' .. groupIndex+1 .. '_' .. playerIndex+1 .. '_abiltiy_' .. n+1 .. "_cooldown")
					label:SetText(floor(trigger.remainingCooldownTime/1000 + 1))
					label:SetVisible(onCooldown)
					if (specUI.abilityFlyoutMode == 1 or (specUI.abilityFlyoutMode == 2 and n == 3)) then -- our mode allows this ability
						if (onCooldown and not oldCooldown and not trigger.isPassive) then -- it came off cooldown
						
						
							local flyout = widget:InstantiateAndReturn('spec_hero_flyout', 'texture', trigger.iconPath)[1]
							libThread.threadFunc( function()
								flyout:SlideX(groupIndex==0 and '7.77h' or '-11.11h', 200)
								flyout:SlideY('-2.22h', 200)
								flyout:ScaleWidth( '6.66h', 200)
								flyout:ScaleHeight('6.66h', 200)
								wait(200)
								--the scaling breaks the slide ending
								flyout:SetX(groupIndex==0 and '7.77h' or '-11.11h')
								flyout:SetY('-2.22h')
								libAnims.wobbleStart(flyout, 2)
								wait(550)
								flyout:FadeOut(150)
								wait(150)
								libAnims.wobbleStop(flyout)
								flyout:Destroy()
							end)
							
							
						end
					end
					oldCooldown = onCooldown
				end)
				
				abilityPanel:SetCallback('onmouseover', function(widget)
					Trigger('abilityTipShow', player+10, n)
				end)
				abilityPanel:SetCallback('onmouseout', function(widget)
					Trigger('abilityTipHide')
				end)
				
			end
			
			-- Portrait
			local trigger = LuaTrigger.GetTrigger('SpectatorUnit' .. player)
			local parent = object:GetWidget('spec_hero_frames_' .. groupIndex+1 .. '_' .. playerIndex+1)
			local portraitPanel = object:GetWidget('spec_hero_frames_' .. groupIndex+1 .. '_' .. playerIndex+1 .. '_portrait')
			
			parent:SetVisible(trigger.playerName ~= '')
			
			portraitPanel:SetCallback('onclick', function()
				SelectUnit(trigger.index)
			end)
			portraitPanel:SetCallback('onmouseover', function()
				ShowHeroTooltip(object, player, true)
			end)
			portraitPanel:SetCallback('onmouseout', function()
				HideHeroTooltip(object)
			end)
			
			-- Level label
			if (player>=5) then
				object:GetWidget('spec_hero_frames_' .. groupIndex+1 .. '_' .. playerIndex+1 .. '_portrait_level_image'):SetX('1.8h')
				object:GetWidget('spec_hero_frames_' .. groupIndex+1 .. '_' .. playerIndex+1 .. '_portrait_level_label'):SetX('1.8h')
			end
			
			-- Portrait overlays
			local overlayPre = 'spec_hero_frames_' .. groupIndex+1 .. '_' .. playerIndex+1 .. '_portrait_'
			gamePlayerInfoRespawnRegister(			object, overlayPre..'RespawnTime', 'SpectatorUnit' .. player)
			gamePlayerInfoMVPRegister(				object, overlayPre..'MVPIcon', 'player' .. player .. 'MVP', player)
			gamePlayerInfoVoipRegister(				object, overlayPre..'Voip', 'SpectatorUnit' .. player)
			gamePlayerInfoAFKRegister(				object, overlayPre..'AFK', 'SpectatorUnit' .. player)
			gamePlayerInfoDisconnectTimeRegister(	object, overlayPre..'DisconnectTime', 'SpectatorUnit' .. player)
			gamePlayerInfoLoadPercentRegister(		object, overlayPre..'LoadPercent', 'SpectatorUnit' .. player)
			gamePlayerInfoDisconnectIconRegister(	object, overlayPre..'DisconnectIcon', 'SpectatorUnit' .. player)
			gamePlayerInfoLoadIconRegister(			object, overlayPre..'LoadIcon', 'SpectatorUnit' .. player)
			gamePlayerInfoDeadIconRegister(			object, overlayPre..'DeadIcon', 'SpectatorUnit' .. player, player)
			
			-- Health/level/anything updated by SpectatorUnitX
			local healthPanel = object:GetWidget('spec_hero_frames_' .. groupIndex+1 .. '_' .. playerIndex+1 .. '_hp')
			local levelLabel = object:GetWidget('spec_hero_frames_' .. groupIndex+1 .. '_' .. playerIndex+1 .. '_portrait_level_label')
			local oldHealthPercent = 0
			local recentDamagePercent = 0
			portraitPanel:RegisterWatchLua('SpectatorUnit'.. player, function(widget, trigger)
				widget:SetTexture(getHeroHeadCutoutFromIcon(trigger.iconPath))
				healthPanel:SetWidth(trigger.healthPercent * 100 .. '%')
				recentDamagePercent = (recentDamagePercent + oldHealthPercent-trigger.healthPercent)*0.98
				local displayDamage = (1-recentDamagePercent*3)
				if displayDamage>1 or trigger.healthPercent==1 or trigger.status==0 then recentDamagePercent=0 displayDamage = 1 end
				widget:SetColor('1 '..displayDamage..' '..displayDamage)
				oldHealthPercent = trigger.healthPercent
				widget:SetRenderMode( trigger.status==1 and 'normal' or 'grayscale' )
				levelLabel:SetText(trigger.level)
				parent:SetVisible(trigger.playerName ~= '')
			end)
			-- Mana
			local manaPanel = object:GetWidget('spec_hero_frames_' .. groupIndex+1 .. '_' .. playerIndex+1 .. '_mana')
			manaPanel:RegisterWatchLua('SpectatorUnit'.. player, function(widget, trigger)
				widget:SetWidth(trigger.manaPercent * 100 .. '%')
			end)
			
			-- Items
			for n = 0, 6 do
				local itemPanel = object:GetWidget('spec_hero_frames_' .. groupIndex+1 .. '_' .. playerIndex+1 .. '_item_' .. n+1)
				itemPanel:RegisterWatchLua('Spectator'.. n ..'HeroInventory'.. player, function(widget, trigger)
					if (trigger.iconPath) and (not Empty(trigger.iconPath)) and (trigger.isValid) then
						widget:SetTexture(trigger.iconPath)
					else
						widget:SetTexture('/ui/shared/textures/pack2.tga')
						return 
					end
				end)
			end
		end
	end
end

local function gameRegisterBindableHotkey(object, buttonID, onButtonClick, triggerRefresh)
	local button		= object:GetWidget(buttonID..'Button')
	local backer		= object:GetWidget(buttonID..'Backer')
	local body			= object:GetWidget(buttonID..'Body')
	local label			= object:GetWidget(buttonID..'Label')
	local highlight		= object:GetWidget(buttonID..'Highlight')
	local buttonTip		= object:GetWidget(buttonID..'ButtonTip')
	
	triggerRefresh = triggerRefresh or false
	
	button:RegisterWatchLua('ModifierKeyStatus', function(widget, trigger)
		widget:SetNoClick(not trigger.moreInfoKey)
	end, false)

	backer:RegisterWatchLua('ModifierKeyStatus', function(widget, trigger)
		if trigger.moreInfoKey then
			widget:SetColor(styles_colors_hotkeyCanSet)
			widget:SetBorderColor(styles_colors_hotkeyCanSet)
		else
			widget:SetColor(styles_colors_hotkeyNoSet)
			widget:SetBorderColor(styles_colors_hotkeyNoSet)
		end
	end, false)

	buttonTip:SetCallback('onmouseover', function(widget)
		simpleTipNoFloatUpdate(true, nil, Translate('game_keybind_1'), Translate('game_keybind_2', 'value', GetKeybindButton('game', 'TriggerToggle', 'gameShowMoreInfo', 0)), nil, nil, libGeneral.HtoP(-18), 'center', 'bottom')
		
		UpdateCursor(widget, true, { canLeftClick = true})
	end)

	buttonTip:SetCallback('onmouseout', function(widget)
		simpleTipNoFloatUpdate(false)
		UpdateCursor(widget, false, { canLeftClick = true})
	end)

	button:SetCallback('onmouseover', function(widget)
		simpleTipNoFloatUpdate(true, nil, Translate('game_keybind_1'), Translate('game_keybind_2_no_mod'), nil, nil, libGeneral.HtoP(-18), 'center', 'bottom')
		UpdateCursor(widget, true, { canLeftClick = true, canRightClick = false })
	end)

	button:SetCallback('onmouseout', function(widget)
		simpleTipNoFloatUpdate(false)
		UpdateCursor(widget, false, { canLeftClick = true, canRightClick = false })
	end)

	button:SetCallback('onclick', function(widget)
		onButtonClick(widget, buttonInfo)
	end)
	
	if triggerRefresh then
		label:RegisterWatchLua('gameRefreshKeyLabels', function(widget, trigger)
			widget:DoEvent()			
		end)
	end
end
gameRegisterBindableHotkey(object, 'specCinemaModeButtonKey', function()
	local binderData	= LuaTrigger.GetTrigger('buttonBinderData')
	local oldButton		= nil
	binderData.show			= true
	binderData.table		= 'spectator'
	binderData.action		= 'TriggerToggle'
	binderData.param		= 'SpecCinematicMode'
	binderData.keyNum		= 0	-- 0 for leftclick, 1 for rightclick
	binderData.impulse		= false
	binderData.oldButton	= (GetKeybindButton('spectator', 'TriggerToggle', 'SpecCinematicMode', 0) or 'None')
	binderData:Trigger()
end, true)

function specUI.toggleDisplay()
	specUI.displaying = not specUI.displaying
	
	-- Hide minimap
	minimapGroup = interface:GetGroup('gameMinimapContainers')
	for k,v in pairs(minimapGroup) do
		v:SetVisible(specUI.displaying)
	end
	-- Hide hero frames
	specUIWidgets.playersPodParent:SetVisible(specUI.displaying)
	-- Hide stats
	specUIWidgets.statPanel:SetVisible(specUI.displaying)
	-- Hide paused dialog
	--interface:GetWidget('spec_gamePausedIndicator'):SetVisible(specUI.displaying)
	-- Hide selected unit
	interface:GetWidget('spec_selected_unit_parent'):SetVisible(specUI.displaying)
	-- Hide Clock
	interface:GetWidget('game_push_clock'):SetVisible(specUI.displaying and GetCvarBool('_pushOrbVis'))
	local showBosses = specUI.displaying and GetCvarBool('_bossTimerVis')
	-- Hide Cindara timer
	interface:GetWidget('game_push_boss_1'):SetVisible(showBosses)
	-- Hide Baldir timer
	interface:GetWidget('game_push_boss_2'):SetVisible(showBosses)
	-- Hide overlays
	interface:GetWidget('spec_stats_overlay_container'):SetVisible(specUI.displaying)
	-- Hide push bar
	specUIWidgets.pushBar:SetVisible(specUI.displaying and GetCvarBool('_spec_pushBarVis'))
	-- Hide gank alerts
	interface:GetWidget('gank_alert_container'):SetVisible(specUI.displaying)
	-- Hide events log
--	interface:GetWidget('gameEventsContainer'):SetVisible(specUI.displaying)
	-- Hide graph
	interface:GetWidget('spec_stats_graph_parent'):SetVisible(specUI.displaying and graphOpen)
	-- Show Cinema mode text
	local cinemaHotkey = GetKeybindButton('spectator', 'TriggerToggle', 'SpecCinematicMode')
	if cinemaHotkey then
		interface:GetWidget('spec_cinema_mode_text'):SetText(Translate("spec_stats_cinemaMode", 'orHotkey', '/^248'..cinemaHotkey..'^*'))
	else
		interface:GetWidget('spec_cinema_mode_text'):SetText(Translate("spec_stats_cinemaMode", 'orHotkey', ''))
	end
	interface:GetWidget('spec_cinema_mode_panel'):SetVisible(not specUI.displaying)
	--interface:GetWidget('spec_cinema_mode_panel'):FadeOut(5000)
end

local function specUIRegister(object)
	registerCvarPinButton(object, 'spec_pushBarPin',		'_spec_pushBarVis',	true, 'game_specPanelInfo', 'pushBarVis', nil, 'pin_spec_pushBar', 'pin_spec_pushBar_tip')
	registerCvarPinButton(object, 'spec_unitFramesPin',		'_spec_unitFramesVis',	true, 'game_specPanelInfo', 'unitFramesVis', nil, 'pin_heroportraits', 'pin_heroportraits_tip')
	registerCvarPinButton(object, 'spec_statsPin',			'_spec_statsVis', 			true, 'game_specPanelInfo', 'statsVis', nil, 'pin_spec_stats', 'pin_spec_stats_tip')
	registerCvarPinButton(object, 'spec_selectedUnitPin',	'_spec_selectedUnitVis', 	true, 'game_specPanelInfo', 'selectedUnitVis', nil, 'pin_spec_selectedUnit', 'pin_spec_selectedUnit_tip')
	registerCvarPinButton(object, 'spec_replay_control_btn','_spec_replayControlsVis',  false, 'game_specPanelInfo', 'replayControlsVis')
	registerCvarPinButton(object, 'gamePushOrbPin', '_pushOrbVis', true, 'gamePanelInfo', 'clockExpandedPinned', nil, 'pin_clock', 'pin_clock_tip')
	registerCvarPinButton(object, 'gameBossPin', '_bossTimerVis', true, 'gamePanelInfo', 'boss1ExpandedPinned', nil, 'pin_spec_bossTimers', 'pin_spec_bossTimers_tip')
	-- registerCvarPinButton(object, 'spec_replay_control_btn', '_spec_replayControlsVis',  false, 'game_specPanelInfo', 'replayControlsVis')
	-- registerCvarPinButton(UIManager.GetInterface('game_replay_control'), 'spec_replayControlsPin', '_spec_replayControlsVis',  true, 'game_specPanelInfo', 'replayControlsVis')
	
	-- object:GetWidget('spec_replay_control_btn'):SetCallback('onmouseover', function(widget)
		-- simpleTipGrowYUpdate(true, nil, Translate('options_label_replay_controls'), Translate('options_label_replay_controls_desc'), libGeneral.HtoP(30))
	-- end)
	
	-- object:GetWidget('spec_replay_control_btn'):SetCallback('onmouseout', function(widget)
		-- simpleTipGrowYUpdate(false)
	-- end)
	
	object:GetWidget('specgameMenuButton'):SetCallback('onclick', function()
		object:GetWidget('game_menu_parent'):SetVisible(not object:GetWidget('game_menu_parent'):IsVisible() )
	end)	
	object:GetWidget('specgameMenuButtonKey'):RegisterWatchLua('ModifierKeyStatus', function(widget, trigger) widget:SetVisible(trigger.moreInfoKey) end)
	
	object:GetWidget('specCinemaModeButton'):SetCallback('onclick', function()
		specUI.toggleDisplay()
	end)	
	object:GetWidget('specCinemaModeButtonKey'):RegisterWatchLua('ModifierKeyStatus', function(widget, trigger) widget:SetVisible(trigger.moreInfoKey) end)
	
	object:RegisterWatch('SpecCinematicMode', function(widget, keyDown)
		if AtoB(keyDown) then
			specUI.toggleDisplay()
		end
	end)
	
		
	local function gameRegisterBindableHotkey(object, buttonID, onButtonClick)
		local button		= object:GetWidget(buttonID..'Button')
		local backer		= object:GetWidget(buttonID..'Backer')
		local body		= object:GetWidget(buttonID..'Body')
		local label			= object:GetWidget(buttonID..'Label')
		local highlight		= object:GetWidget(buttonID..'Highlight')
		local buttonTip		= object:GetWidget(buttonID..'ButtonTip')
		
		button:RegisterWatchLua('ModifierKeyStatus', function(widget, trigger)
			widget:SetNoClick(not trigger.moreInfoKey)
		end, false)

		backer:RegisterWatchLua('ModifierKeyStatus', function(widget, trigger)
			if trigger.moreInfoKey then
				widget:SetColor(styles_colors_hotkeyCanSet)
				widget:SetBorderColor(styles_colors_hotkeyCanSet)
			else
				widget:SetColor(styles_colors_hotkeyNoSet)
				widget:SetBorderColor(styles_colors_hotkeyNoSet)
			end
		end, false)


		buttonTip:SetCallback('onmouseover', function(widget)
			simpleTipGrowYUpdate(true, nil, Translate('game_keybind_1'), Translate('game_keybind_2', 'value', GetKeybindButton('game', 'TriggerToggle', 'gameShowMoreInfo', 0)))
			UpdateCursor(widget, true, { canLeftClick = true})
		end)

		buttonTip:SetCallback('onmouseout', function(widget)
			simpleTipGrowYUpdate(false)
			UpdateCursor(widget, false, { canLeftClick = true})
		end)

		button:SetCallback('onmouseover', function(widget)
			simpleTipGrowYUpdate(true, nil, Translate('game_keybind_1'), Translate('game_keybind_2_no_mod'))
			UpdateCursor(widget, true, { canLeftClick = true, canRightClick = false })
		end)

		button:SetCallback('onmouseout', function(widget)
			simpleTipGrowYUpdate(false)
			UpdateCursor(widget, false, { canLeftClick = true, canRightClick = false })
		end)

		button:SetCallback('onclick', function(widget)
			onButtonClick(widget, buttonInfo)
		end)
	end

	function GameMenuToggle(object)
		object = object or interface
		if object:GetWidget('game_menu_parent') then
			object:GetWidget('game_menu_parent'):SetVisible(not object:GetWidget('game_menu_parent'):IsVisible())
		end
	end	
		
	gameRegisterBindableHotkey(object, 'specgameMenuButtonKey', function()
		local binderData	= LuaTrigger.GetTrigger('buttonBinderData')
		local oldButton		= nil
		binderData.show			= true
		binderData.table		= 'ui'
		binderData.action		= 'Cmd'
		binderData.param		= 'Script GameMenuToggle()'
		binderData.keyNum		= 0	-- 0 for leftclick, 1 for rightclick
		binderData.impulse		= true
		binderData.oldButton	= (GetKeybindButton('ui', 'Cmd', 'Script GameMenuToggle()', 0) or 'None')
		binderData:Trigger()
	end)

	object:RegisterWatch('gameToggleMenu', function(widget, keyDown)
		if AtoB(keyDown) then
			GameMenuToggle(object)
		end
	end)	
	
	-- Pause
	local pausedIndicator			= object:GetWidget('spec_gamePausedIndicator')
	pausedIndicator:RegisterWatchLua('GameIsPaused', function(widget, trigger) widget:SetVisible(trigger.paused) end)

	-- Hero Frames
	RegisterUnitFrames(object)
	
	specUIWidgets.playersPodParent:RegisterWatchLua('game_specPlayerKillAssistsCompare', function(widget, trigger)
		for group = 0, 1 do
			local infoTable = {}
			for i=(5*group)+0,(5*group)+4,1 do
				table.insert(infoTable, { index = i, ka = trigger['player'..i..'KillAssists'] })
			end
			table.sort(infoTable, function(a,b) return a.ka > b.ka end)
			local MVPID = 5
			if (infoTable[1].ka > 0) then
				MVPID = infoTable[1].index
			end
			for i=(5*group)+0,(5*group)+4,1 do
				trigger_game_specPanelInfo['player'..i..'MVP'] = (i == MVPID)
			end
			trigger_game_specPanelInfo:Trigger(false)
		end
	end)
		
	specUIWidgets.playersPodParent:RegisterWatchLua('ModifierKeyStatus', function(widget, trigger)
		trigger_game_specPanelInfo.moreInfoKey	= trigger.moreInfoKey
		if (specUI.displaying) then
			trigger_game_specPanelInfo:Trigger(true)
		end
	end, false, nil, 'moreInfoKey')	
	
	trigger_game_specPanelInfo:Trigger(true)
	
	FindChildrenClickCallbacks(object)
end

specUIRegister(object)



