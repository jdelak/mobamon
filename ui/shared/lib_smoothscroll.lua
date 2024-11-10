-- SmoothScroll Library

libSmoothScroll = {}

libSmoothScroll.simpleErrString = function(errTask, errType, errMsg)
	return '^923libSmoothScroll ^w| ^069'..errTask..' ^w| ^960'..errType..' ^w| ^888'..errMsg..'\n'
end

libSmoothScroll.validateWidget = function(widget)
	if widget ~= nil then
		if type(widget) == 'userdata' then
			if widget:IsValid() then
				return true
			end
		end
	end
	return false
end

libSmoothScroll.validate = function(widgets, dataSet)
	local validateFail = false
	local errMsg = ''
	
	local haveScrollBar		= false
	local haveScrollPanel	= false
	
	if libSmoothScroll.validateWidget(widgets.scrollBar) then
		haveScrollBar = true
	end
	
	if libSmoothScroll.validateWidget(widgets.scrollPanel) then
		haveScrollPanel = true
	end

	if not haveScrollBar and not haveScrollPanel then
		errMSG = errMSG + libSmoothScroll.simpleErrString('Validation', 'Widget', 'No scrollPanel nor Scrollbar.')
		validateFail = true
	end
	
	if not libSmoothScroll.validateWidget(widgets.viewArea) then
		errMsg = errMsg + libSmoothScroll.simpleErrString('Validation', 'Widget', 'No viewArea.')
		validateFail = true
	end
	
	if not libSmoothScroll.validateWidget(widgets.contentBody) then
		errMsg = errMsg + libSmoothScroll.simpleErrString('Validation', 'Widget', 'No contentBody.')
		validateFail = true
	end
	
	if validateFail then
		print(errMsg)
	end
	
	return {
		validateFail	= validateFail,
		haveScrollBar	= haveScrollBar,
		haveScrollPanel	= haveScrollPanel
	}
end

libSmoothScroll.init = function(widgets, data)
	--[[
		Expected Widgets:
			viewArea		-- Total height in which objects are scrolled (will clip)
			contentBody		-- This is what is actually moved when scrolled.  Objects are simply placed at the appropriate locations when visible.
		Expected Data:
			viewSet,		-- List of containers which can be utilized to show current data
			dataSet		-- Table which contains relevant data used to determine whether to show items, their position
	--]]
	
	-- Validation

	local validateInfo = libSmoothScroll.validate(widgets, dataSet)
	
	if validateInfo.validateFail then
		return false
	end
	
	local scroller = {
		widgets		= widgets,
		data		= data,
		dataHeight	= 0,	-- Maximum scrollable area
		viewHeight	= widgets.viewArea:GetHeight(),
		offsetMax	= 0,	-- Maximum item offset to have the final 
		offsetCur	= 0,
		offsetMin	= 0,		-- Should never change
		dataVisible	= {},
		useSlide	= true
	}
	
	local frameTime			= LuaTrigger.GetTrigger('FrameTime')
	local smoothScrolling	= false
	local scrollDuration	= 1000
	
	local function isDataVisible(dataID)
		if scroller.data[dataID] then
			local minPos	= scroller.data[dataID].pos
			local maxPos	= minPos + scroller.data[dataID].size
			local offsetPos	= scroller.data[scroller.offsetCur + 1].pos
			
			-- print('for data entry '..dataID..' minPos = '..minPos..' | offsetPos = '..offsetPos..' | maxPos = '..maxPos..' | scroller.viewHeight = '..scroller.viewHeight..'\n')
			
			return minPos >= offsetPos and maxPos <= scroller.viewHeight + offsetPos
		end
		return false
	end
	
	local function rebuildVisibility()	-- Always assumes starting from 0 offset
		scroller.dataVisible = {}
		print('for rebuildvisibility: ')
		for i=1,table.maxn(scroller.data),1 do
			if scroller.data[i].pos < scroller.viewHeight then --  + scroller.data[i].size
				table.insert(scroller.dataVisible, i)
				print(i..', ')
			end
		end
		print('\n')
	end
	
	local function scanVisibility()
		local newVisible = {}
		for k,v in pairs(scroller.dataVisible) do
			if isDataVisible(v) then
				table.insert(newVisible, v)
				-- print('adding '..v..'\n')
			end
		end
		
		if table.maxn(newVisible) >= 1 then
			local invisibleFound	= false
			local currentDataID		= newVisible[1]
			
			while not invisibleFound and currentDataID >= 1 do	-- Scan upward toward first entry
				currentDataID = currentDataID - 1
				if isDataVisible(currentDataID) and currentDataID ~= newVisible[1] then
					table.insert(newVisible, 1, currentDataID)
				else
					invisibleFound = true
				end
			end
			
			invisibleFound	= false
			currentDataID	= newVisible[table.maxn(newVisible)]
			
			while not invisibleFound and currentDataID <= table.maxn(newVisible) do
				currentDataID = currentDataID + 1
				
				if isDataVisible(currentdataID) and currentDataID ~= newVisible[table.maxn(newVisible)] then
					table.insert(newVisible, currentDataID)
				end
			end
		else
			rebuildVisibility()
		end

		print('scanVisibility Results: ')

		for k,v in pairs(newVisible) do
			print(v..' | ')
		end
		
		scroller.dataVisible = newVisible
		
		print('\n')
	end
	
	local function clearSmoothScrolling()
		scroller.widgets.contentBody:UnregisterWatchLua('System')
		smoothScrolling = false
	end
	
	local function updatePosition()
		if smoothScrolling then
			clearSmoothScrolling()
		end
		widgets.contentBody:SetY(-data[scroller.offsetCur + 1].pos)
	end
	
	local function updatePositionSmooth()
		local targPos			= -data[scroller.offsetCur + 1].pos
		
		scanVisibility()
		
		-- print('new targpos is '..targPos..'\n')
		
		if smoothScrolling then
			clearSmoothScrolling()
		end
		
		smoothScrolling			= true
		
		local endTime		= GetTime() + scrollDuration
		
		scroller.widgets.contentBody:RegisterWatchLua('System', function(widget, trigger)
			local currentTime	= trigger.hostTime
			local curPos		= widget:GetY()
			local posShift		= targPos - curPos
			local shiftNegative	= (posShift < 1)

			local targShift = math.ceil( math.abs(posShift * frameTime.frameLength / 100) )

			if shiftNegative then
				widget:SetY( curPos - targShift )
			else
				widget:SetY( curPos + targShift )
			end

			if (currentTime >= endTime) or (curPos == targPos) then
				-- clearSmoothScrolling()
				updatePosition()
			end
		end, false, nil, 'hostTime')
	end
	
	if validateInfo.haveScrollPanel then
		scroller.widgets.scrollPanel:SetCallback('onmousewheeldown', function(widget)
			scroller.offsetCur = math.min(
				scroller.offsetCur + 1,
				scroller.offsetMax
			)
			
			updatePositionSmooth()
		end)
		
		scroller.widgets.scrollPanel:SetCallback('onmousewheelup', function(widget)
			scroller.offsetCur = math.max(
				scroller.offsetMin,
				scroller.offsetCur - 1
			)
			updatePositionSmooth()
		end)
	end
	
	if validateInfo.haveScrollBar then
		scroller.widgets.scrollBar:SetCallback('onslide', function(widget)
			if scroller.useSlide then
				scroller.offsetCur = widget:GetValue()
				updatePositionSmooth()
			end
			
		end)
	end
	
	local function calculatePositions()
		local posCur	= 0
		local dataMax	= table.maxn(data)
		
		for i=1,dataMax,1 do
			scroller.data[i].pos = posCur
		
			posCur = posCur + scroller.data[i].size
			if i < dataMax then
				posCur = posCur + scroller.data[i].padding
			end
			
		end
		
		scroller.dataHeight = posCur
	end
	
	calculatePositions()
	
	local function calculateoffsetMax()
		local dataMax	= table.maxn(scroller.data)
		scroller.offsetMax = 0
		for i=1,dataMax,1 do
			if scroller.data[i].pos + scroller.viewHeight < (scroller.data[dataMax].pos + scroller.data[dataMax].size) then
				scroller.offsetMax = i
				-- print('max offset is now '..i..' which would place the body at '..scroller.data[i + 1].pos..'\n')
			end
		end
		
		scroller.offsetCur = math.min(
			scroller.offsetMax,
			math.max(
				scroller.offsetMin, scroller.offsetCur
			)
		)
		
		if validateInfo.haveScrollBar then
			scroller.useSlide = false
			scroller.widgets.scrollBar:SetValue(scroller.offsetCur)
			scroller.widgets.scrollBar:SetMaxValue(scroller.offsetMax)
			scroller.useSlide = true
		end
		
		updatePosition()
	end
	
	calculateoffsetMax()
	
	rebuildVisibility()

	return scroller
end