-- Scrollable area library

--[[
	Most similar to overflow: scroll; or scrollboxes - scroll with an area, modify positions of elements within
--]]

createLibScroll = function(scrollRegistryTable) -- , interfaceWidget
	local scrollLib = {}
	function scrollLib.register(scrollerName, entries, widgets, scrollHandlerName, extraInfo)
		local scrollInfo = {
			entries				= entries,
			entryData			= {},	-- pos, stepSize and stepPos
			widgets				= widgets,
			--[[
				scrollbar			= widgets.scrollbar,
				scrollPanel			= widgets.scrollPanel,
				scrollArea			= widgets.scrollArea,
			--]]
			posData				= {
				posMin		= 0,
				posMax		= 0,
				posCur		= 0,
				viewCount	= 0	-- Max items viewable
			},
			extraInfo			= extraInfo,
			scrollHandlerName	= scrollHandlerName,
			scrollerName		= scrollerName,
			useSlide			= true
			-- scrollHandler gets set to the handler when validation succeeds
		}
		if scrollLib.preInitValidate(scrollInfo) then

			widgets.scrollbar:SetCallback(
				'onslide', function(sourceWidget)
					if scrollInfo.useSlide then
						scrollLib.scrollToPos(scrollInfo, AtoN(sourceWidget:GetValue()), false)
					end
				end
			)

			widgets.scrollPanel:SetCallback(
				'onmousewheelup', function(sourceWidget)
					scrollLib.scrollPrev(scrollInfo)
				end
			)
			
			

			widgets.scrollPanel:SetCallback(
				'onmousewheeldown', function(sourceWidget)
					scrollLib.scrollNext(scrollInfo)
				end
			)

			
			libPostFrame.addPostFrameAction('scrollLib_updatePosData'..scrollInfo.scrollerName, function() scrollLib.updatePosData(scrollInfo, true) end)
			-- scrollLib.updatePosData(scrollInfo, true)
			scrollRegistryTable[scrollerName] = scrollInfo
		end
	end
	
	
	function scrollLib.getScrollInfo(scrollerName)
		return scrollRegistryTable[scrollerName]
	end
	
	function scrollLib.updatePosNoOnSlide(scrollInfo, newPos, init, forceUpdate)
		if init == nil then init = true end
		forceUpdate = forceUpdate or false
		scrollInfo.useSlide = false
		scrollInfo.widgets.scrollbar:SetValue(newPos)
		scrollLib.scrollToPos(scrollInfo, newPos, init, forceUpdate)
		scrollInfo.useSlide = true
	end
	
	function scrollLib.preInitValidate(scrollInfo)
		local validForInit = true
		local errMsg = ''
		local errPrefix = '^960libScroll Error - ^069'
		local checkWidgets = { 'scrollbar', 'scrollPanel', 'scrollArea', 'itemContainer' }
		
		if not scrollLib.scrollHandlers[scrollInfo.scrollHandlerName] then
			errMsg = errMsg..errPrefix..'^w must be a valid^g scrollHandler.\n'
			validForInit = false
		elseif not scrollLib.scrollHandlers[scrollInfo.scrollHandlerName].validate(scrollInfo) then
			errMsg = errMsg..errPrefix..'^g scrollHandler^w validate failed.\n'
			validForInit = false
		else
			scrollInfo.scrollHandler = scrollLib.scrollHandlers[scrollInfo.scrollHandlerName]
		end
		
		
	
		for k,v in ipairs(checkWidgets) do
			if not scrollInfo.widgets[v] or type(scrollInfo.widgets[v]) ~= 'userdata' then
				errMsg = errMsg..errPrefix..v..'^w must be ^guserdata\n'
				validForInit = false
			end
		end
		
		if type(scrollInfo.entries) ~= 'table' then
			errMsg = errMsg..errPrefix..'entries^w must be a ^gtable\n'
			validForInit = false
		elseif table.maxn(scrollInfo.entries) <= 0 then
			errMsg = errMsg..errPrefix..'entries table^w must be ^gpopulated\n'
			validForInit = false
		end
		
		if not validForInit then
			print(errMsg)
		end
		return validForInit
	end

	function scrollLib.scrollNext(scrollInfo)
	
		if scrollInfo.extraInfo.onScrollFunc and type(scrollInfo.extraInfo.onScrollFunc) == 'function' then
			scrollInfo.extraInfo.onScrollFunc(scrollInfo)
		end
	
		if scrollInfo.posData.posCur < scrollInfo.posData.posMax then
			scrollLib.updatePosNoOnSlide(
				scrollInfo,
				math.min(scrollInfo.posData.posCur + 1, scrollInfo.posData.posMax),
				false
			)
		end
	end

	function scrollLib.scrollPrev(scrollInfo)
	
		if scrollInfo.extraInfo.onScrollFunc and type(scrollInfo.extraInfo.onScrollFunc) == 'function' then
			scrollInfo.extraInfo.onScrollFunc(scrollInfo)
		end
	
		if scrollInfo.posData.posCur > scrollInfo.posData.posMin then
			scrollLib.updatePosNoOnSlide(
				scrollInfo,
				math.max(scrollInfo.posData.posCur - 1, scrollInfo.posData.posMin),
				false
			)
		end
	end

	function scrollLib.scrollToPos(scrollInfo, targetPos, init, forceUpdate)
		init = init or false
		forceUpdate = forceUpdate or false
		if init or (targetPos ~= scrollInfo.posData.posCur) or forceUpdate then
			scrollInfo.posData.posCur = math.max(
				scrollInfo.posData.posMin, math.min(
					targetPos,
					scrollInfo.posData.posMax
				)
			)
			scrollLib.applyScrollState(scrollInfo, init)
		end
	end

	function scrollLib.applyScrollState(scrollInfo, init)
		init = init or false
		local currentPosValue = 0 - (scrollInfo.posData.posCur * scrollInfo.scrollHandler.scrollStep(scrollInfo, 1))
		for k,v in ipairs(scrollInfo.entries) do
			if scrollInfo.scrollHandler.entryValid(scrollInfo, k, currentPosValue) then	-- Valid for display AND placement within the current value range
				currentPosValue = scrollInfo.scrollHandler.entryPos(scrollInfo, k, currentPosValue, init)	-- Set current element to start at the last position value returned by entryPos (modified and animated via entryPos)
			end
		end
		currentPosValue = currentPosValue - scrollInfo.scrollHandler.entryPadding(scrollInfo)
	end

	function scrollLib.totalEntrySize(scrollInfo)
		local totalSize = 0
		for k,v in ipairs(scrollInfo.entries) do
			if scrollInfo.scrollHandler.entryValid(scrollInfo, k, currentPosValue) then	-- Valid for display AND placement within the current value range
				totalSize = totalSize + scrollInfo.scrollHandler.entrySize(scrollInfo, k)	-- Set current element to start at the last position value returned by entryPos (modified and animated via entryPos)
			end
		end
		return totalSize - scrollInfo.scrollHandler.entryPadding(scrollInfo)
	end

	function scrollLib.updateEntryData(scrollInfo)
		local itemPos = 0
		for i=1,table.maxn(scrollInfo.entries),1 do
			scrollInfo.entryData[i] = {
				pos			= itemPos,
				stepSize	= math.ceil(scrollInfo.scrollHandler.entrySize(scrollInfo, i) / scrollInfo.scrollHandler.scrollStep(scrollInfo, i)),
				stepPos		= math.ceil(itemPos / scrollInfo.scrollHandler.scrollStep(scrollInfo, i))
			}
			itemPos = itemPos + scrollInfo.scrollHandler.entrySize(scrollInfo, i) + scrollInfo.scrollHandler.entryPadding(scrollInfo)
		end
	end

	function scrollLib.updatePosData(scrollInfo, init, entryPosOverride, forceUpdate, stayAtMaxPos)
		local newPos
		local targPos		= scrollInfo.posData.posCur
		local newTargPos	= 0  
		init = init or false					-- Whether to override scroll to pos check
		forceUpdate = forceUpdate or false		-- Force scrolling to update even if not changing position, etc. (especially when item heights change/etc.)
		stayAtMaxPos = stayAtMaxPos or false	-- If at max pos, maintain that position (primarily if the height of the bottom-most item changes)
		-- local newMax
		-- local newMin
		-- Min/max value would be recalculated as necessary here
		scrollInfo.posData.posMin = 0
		
		local goToMaxPos = false
		
		if stayAtMaxPos and targPos == scrollInfo.posData.posMax then	-- At previous max
			goToMaxPos = true	-- Ideally forceUpdate should be set to true as well
		end
		
		scrollInfo.posData.posMax = math.max(
			math.ceil((scrollLib.totalEntrySize(scrollInfo) - scrollInfo.scrollHandler.areaSize(scrollInfo)) / scrollInfo.scrollHandler.scrollStep(scrollInfo, 1)),
			scrollInfo.posData.posMin
		)

		scrollInfo.posData.viewCount = math.ceil(scrollInfo.scrollHandler.areaSize(scrollInfo) / scrollInfo.scrollHandler.scrollStep(scrollInfo, 1))

		scrollLib.updateEntryData(scrollInfo)

		if entryPosOverride then
			
			-- newTargPos = math.min(scrollInfo.entryData[entryPosOverride].stepPos - 1, scrollInfo.posData.posMax)
			targPos = entryPosOverride
			
		end
		
		if goToMaxPos then
			newPos = scrollInfo.posData.posMax
		else
			newPos = math.max(	-- Constrain current value to min/max
				scrollInfo.posData.posMin, math.min(
					targPos,
					scrollInfo.posData.posMax
				)
			)
		end
		


		scrollInfo.useSlide = false
		scrollInfo.widgets.scrollbar:SetMaxValue(scrollInfo.posData.posMax)
		scrollInfo.useSlide = true
		
		scrollLib.updatePosNoOnSlide(
			scrollInfo, newPos, init, forceUpdate
		)


		if scrollInfo.scrollHandler.onUpdatePosData and type(scrollInfo.scrollHandler.onUpdatePosData) == 'function' then
			scrollInfo.scrollHandler.onUpdatePosData(scrollInfo)
		end
	end

	scrollLib.scrollHandlers = {
		simpleSmooth	= {
			validate = function(scrollInfo)
				return true
			end,
			entryValid = function(scrollInfo, id, startPosValue)
				return scrollInfo.entries[id]:IsVisibleSelf()
			end,
			entryPadding = function(scrollInfo)
				if scrollInfo.extraInfo.entryPadding then
					if type(scrollInfo.extraInfo.entryPadding) == 'function' then
						return scrollInfo.extraInfo.entryPadding()
					elseif type(scrollInfo.extraInfo.entryPadding) == 'number' then
						return scrollInfo.extraInfo.entryPadding
					end
				end
				return libGeneral.HtoP(0.5)
			end,
			entrySize = function(scrollInfo, id)
				if scrollInfo.extraInfo.entrySize and type(scrollInfo.extraInfo.entrySize) == 'function' then
					return scrollInfo.extraInfo.entrySize(id) + scrollInfo.scrollHandler.entryPadding(scrollInfo)
				end
				return scrollInfo.entries[id]:GetHeight() + scrollInfo.scrollHandler.entryPadding(scrollInfo)
			end,
			entryPos = function(scrollInfo, id, startPosValue, init)
				init = init or false
				local newPos = startPosValue
				if init then
					scrollInfo.entries[id]:SetY(newPos)
				else
					scrollInfo.entries[id]:SlideY(newPos, scrollInfo.extraInfo.slideTime, true)
				end
				return newPos + scrollInfo.scrollHandler.entrySize(scrollInfo, id)
			end,
			entryOrder = function()
				return true
			end,
			areaSize = function(scrollInfo)
				return scrollInfo.widgets.scrollArea:GetHeight()
			end,
			scrollStep = function(scrollInfo, id)
				if scrollInfo.extraInfo.stepOverride and type(scrollInfo.extraInfo.stepOverride) == 'function' then
					return scrollInfo.extraInfo.stepOverride()
				else
					return scrollInfo.scrollHandler.entryPadding(scrollInfo) + scrollInfo.entries[id]:GetHeight()
				end
			end,
			onUpdatePosData = function(scrollInfo)
				local showScroll = scrollInfo.posData.posMin ~= scrollInfo.posData.posMax and scrollInfo.posData.posMax > scrollInfo.posData.posMin
				local usePlaceholder = ((scrollInfo.extraInfo) and (scrollInfo.extraInfo.usePlaceholder) and (trigger_gamePanelInfo.shopShowFilters)) or false
				if (scrollInfo.widgets.scrollbarPlaceholder) and (scrollInfo.widgets.scrollbarPlaceholder:IsValid()) then
					scrollInfo.widgets.scrollbarPlaceholder:SetVisible((not showScroll) and usePlaceholder)
				end
				scrollInfo.widgets.scrollbar:SetVisible(showScroll)
				scrollInfo.widgets.scrollPanel:SetVisible(showScroll or usePlaceholder)
				if showScroll then
					scrollInfo.widgets.itemContainer:SetWidth((scrollInfo.widgets.scrollbar:GetWidth() + libGeneral.HtoP(0.5)) * -1)
				elseif usePlaceholder then
					scrollInfo.widgets.itemContainer:SetWidth((scrollInfo.widgets.scrollbarPlaceholder:GetWidth() + libGeneral.HtoP(0.5)) * -1)
				else
					scrollInfo.widgets.itemContainer:SetWidth('100%')
				end
			end
		}
	}
	return scrollLib
end

-- libScroll2 = createLibScroll(gameUI.scrollables)
