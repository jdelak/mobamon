-- General func library

local rootObject = object

libGeneral = {
	canILeaveHeroSelectWithoutConsequence = function()
		local triggerHeroSelectInfo = LuaTrigger.GetTrigger('HeroSelectInfo')
		local triggerPartyStatus =  LuaTrigger.GetTrigger('PartyStatus')
		local triggerGamePhase =  LuaTrigger.GetTrigger('GamePhase')
		if (triggerGamePhase.gamePhase == 0) and (triggerHeroSelectInfo.type == 'party') and (triggerPartyStatus.numPlayersInParty == 1) and (triggerPartyStatus.isPartyLeader) then
			return true
		else
			return false
		end
	end,	
	newTable	= function()	-- This is a hack for inline lua
		return {}
	end,
	clearTable	= function(sourceTable)
		if sourceTable and type(sourceTable) == 'table' then
			for k,v in pairs(sourceTable) do
				if type(v) == 'table' then
					libGeneral.clearTable(sourceTable[k])
				else
					sourceTable[k] = nil
				end
			end
		end
	end,
	DoIHaveAnAccountExperienceBoost = function()
		local accountBoostInfoTrigger = LuaTrigger.GetTrigger('AccountBoostInfoTrigger')
		return accountBoostInfoTrigger.hasPermanentXPBoost or accountBoostInfoTrigger.hasTemporaryXPBoost or accountBoostInfoTrigger.hasLANXPBoost or GetCvarBool('ui_pretend_to_have_account_boost') or false
	end,	
	getCutoutOrRegularIcon = function(entity)
		if entity and string.len(entity) > 0 then
			local cutoutIcon = GetEntityCutOutIconPath(entity)
			if cutoutIcon and string.len(cutoutIcon) > 0 then
				return cutoutIcon
			else
				return GetEntityIconPath(entity)
			end
		end
		return ''
	end,
	printTable	= function(sourceTable, prefix)
		print('^960Warning: ^wUse of ^069libGeneral.printTable^w (deprecated).\n')
		printr(sourceTable)
	end,
	craftedItemGetNameColor = function(isRare, isLegendary)
		if isLegendary then
			return style_crafting_tier_legendary_color
		elseif isRare then
			return style_crafting_tier_rare_color
		end
		return style_crafting_tier_common_color
	end,
	craftedItemFormatName = function(baseName, isRare, rareBonusName, isLegendary, legendaryBonusName)
		rareBonusName		= rareBonusName or ''
		legendaryBonusName	= legendaryBonusName or ''

		if isLegendary then
			return Translate('crafted_item_name_legendary', 'rarebonus', rareBonusName, 'itemname', baseName, 'legendarybonus', legendaryBonusName)
		elseif isRare then
			return Translate('crafted_item_name_rare', 'rarebonus', rareBonusName, 'itemname', baseName)
		end
		return baseName
	end,
	placeWidgetAtWidget = function(setWidget, toWidget)
		setWidget:SetWidth(toWidget:GetWidth())
		setWidget:SetHeight(toWidget:GetHeight())
		setWidget:SetX(toWidget:GetAbsoluteX())
		setWidget:SetY(toWidget(GetAbsoluteY()))
	end,
	getWidgetsBounds = function(widgets, skipVisCheck)
		skipVisCheck = skipVisCheck or false
		local minX, minY, maxX, maxY
		if widgets and type(widgets) == 'table' then
			if table.maxn(widgets) > 0 then
				for k,v in ipairs(widgets) do
					if v:IsVisible() or skipVisCheck then
						if minX == nil then
							minX = v:GetAbsoluteX()
						else
							minX = math.min(minX, v:GetAbsoluteX())
						end
						
						if minY == nil then
							minY = v:GetAbsoluteY()
						else
							minY = math.min(minY, v:GetAbsoluteY())
						end
						
						if maxX == nil then
							maxX = v:GetAbsoluteX() + v:GetWidth()
						else
							maxX = math.max(maxX, v:GetAbsoluteX() + v:GetWidth())
						end
						
						if maxY == nil then
							maxY = v:GetAbsoluteY() + v:GetHeight()
						else
							maxY = math.max(maxY, v:GetAbsoluteY() + v:GetHeight())
						end
					end
				end
				
				if maxX == nil then
					print('No maxX for libGeneral.getWidgetsBounds.\n')
				elseif maxY == nil then
					print('No maxY for libGeneral.getWidgetsBounds.\n')
				elseif minX == nil then
					print('No minX for libGeneral.getWidgetsBounds.\n')
				elseif minY == nil then
					print('No minY for libGeneral.getWidgetsBounds.\n')
				else
					-- Return x, y, w, h
					print('widget bounds are \n')
					printr( {minX, minY, (maxX - minX), (maxY - minY)} )
					return minX, minY, (maxX - minX), (maxY - minY)
				end
			else
				print('Empty table for libGeneral.getWidgetsBounds.\n')
			end
		else
			print('^960Warning: ^wlibGeneral.getWidgetsMaxBounds with ^069bad/empty widget list.\n')
		end
		
		return 0, 0, 0, 0
	end,
	isValidWidget = function(widget, requireName)
		requireName = requireName or false
		if widget and type(widget) == 'userdata' and widget:IsValid() then
			local widgetName = widget:GetName()
			if (not requireName) or (widgetName and string.len(widgetName) > 0) then
				return true
			end
		end
		return false
	end,
	getXToCenterOnTarget = function(sourceWidget, targWidget)
		if not libGeneral.isValidWidget(sourceWidget) then
			print('^960Warning: ^wlibGeneral.getXToCenterOnTarget with ^069invalid sourceWidget.\n')
			return false
		end
		if not libGeneral.isValidWidget(targWidget) then
			print('^960Warning: ^wlibGeneral.getXToCenterOnTarget with ^069invalid targWidget.\n')
			return false
		end
		local targWidth		= targWidget:GetWidth()
		local sourceWidth	= sourceWidget:GetWidth()
		return targWidget:GetAbsoluteX() + ((math.max(sourceWidth, targWidth) - math.min(sourceWidth, targWidth)) / 2)
	end,
	getYToCenterOnTarget = function(sourceWidget, targWidget)
		if not libGeneral.isValidWidget(sourceWidget) then
			print('^960Warning: ^wlibGeneral.getYToCenterOnTarget with ^069invalid sourceWidget.\n')
			return false
		end
		if not libGeneral.isValidWidget(targWidget) then
			print('^960Warning: ^wlibGeneral.getYToCenterOnTarget with ^069invalid targWidget.\n')
			return false
		end
		local targHeight	= targWidget:GetHeight()
		local sourceHeight	= sourceWidget:GetHeight()
		return targWidget:GetAbsoluteY() + ((math.max(sourceHeight, targHeight) - math.min(sourceHeight, targHeight)) / 2)
	end,
	floatRight	= function(widgets, padding, useInvis, posOffset, slideTime)
		local useSlide = false
		slideTime = slideTime or 0
		if slideTime > 0 then
			useSlide = true
		end
		padding		= padding or libGeneral.HtoP(0.5)
		useInvis = useInvis or false
		posOffset	= posOffset or 0
		local currentPos = posOffset
		if widgets and type(widgets) == 'table' and #widgets > 0 then
			for k, widget in ipairs(widgets) do
				if useInvis or widget:IsVisibleSelf() then
					if useSlide then
						widget:SlideX(currentPos, slideTime, true)
					else
						widget:SetX(currentPos)
					end
					currentPos = currentPos + padding + widget:GetWidth()
				end

			end
			return currentPos - padding
		else
			print('^960Warning: ^wlibGeneral.floatRight with ^069bad/empty widget list.\n')
		end
		return 0
	end,
	floatBottom	= function(widgets, padding, useInvis, posOffset, slideTime)
		local useSlide = false
		slideTime = slideTime or 0
		if slideTime > 0 then
			useSlide = true
		end
		padding		= padding or libGeneral.HtoP(0.5)
		useInvis = useInvis or false
		posOffset	= posOffset or 0
		local currentPos = posOffset
		if widgets and type(widgets) == 'table' and #widgets > 0 then
			for k, widget in ipairs(widgets) do
				if useInvis or widget:IsVisibleSelf() then
					if useSlide then
						widget:SlideY(currentPos, slideTime, true)
					else
						widget:SetY(currentPos)
					end
					currentPos = currentPos + padding + widget:GetHeight()
				end

			end
			return currentPos - padding
		else
			print('^960Warning: ^wlibGeneral.floatBottom with ^069bad/empty widget list.\n')
		end
		return 0
	end,
	tableCopy	= function(sourceTable)
		local newTable = {}
		for k,v in pairs(sourceTable) do
			if type(v) == 'table' then
				newTable[k] = libGeneral.tableCopy(v)
			else
				newTable[k] = v
			end
		end
		return newTable
	end,
	tableMerge	= function(sourceTable, targTable)	-- Take fields from source table and overwrite same fields in targ table
		for k,v in pairs(sourceTable) do
			if type(v) == 'table' then
				if targTable[k] then
					if type(targTable[k]) == 'table' then
						libGeneral.tableMerge(v, targTable[k])
					else
						targTable[k] = libGeneral.tableCopy(v)
					end
				else
					targTable[k] = libGeneral.tableCopy(v)
				end
			else
				targTable[k] = v
			end
		end
	end,
	firstToUpper = function(str)
		return (str:gsub("^%l", string.upper))
	end,
	createTrigger = function(triggerName, ...)
		if triggerName and string.len(triggerName) > 0 then
			if not LuaTrigger.GetTrigger(triggerName) then
				return LuaTrigger.CreateCustomTrigger(triggerName, ...)
			end
		else
			print('^960Warning: ^wlibGeneral.createTrigger with ^069empty trigger name.\n')
		end
	end,
	createGroupTrigger = function(triggerName, ...)
		if triggerName and string.len(triggerName) > 0 then
			if not LuaTrigger.GetTrigger(triggerName) then
				return LuaTrigger.CreateGroupTrigger(triggerName, ...)
			end
		else
			print('^960Warning: ^wlibGeneral.createTrigger with ^069empty trigger name.\n')
		end
	end,
	fade		= function(widget, show, fadeTime)
		if show then
			widget:FadeIn(fadeTime)
		else
			widget:FadeOut(fadeTime)
		end
	end,
	isInTable = function(checkTable, input)
		if checkTable and type(checkTable) == 'table' then
			for k,v in pairs(checkTable) do
				if v == input then
					return true
				end
			end
		end

		return false
	end,

	getTeamSlotIndex = function(teamID, slot)
		if teamID == 2 then slot = slot - 5 end
		return slot
	end,
	getSlotTeam	= function(index)
		if index > 4 then
			return 2
		else
			return 1
		end
	end,
	BtoN = function(input)
		if input then
			return 1
		else
			return 0
		end
	end,

	HtoP = function(inputHeight)	-- Convert H units to pixel size
		return math.ceil(GetScreenHeight() * (inputHeight / 100))
	end,

	PtoH = function(inputInPixels)	-- Convert pixel units to H
		return ((inputInPixels * 100) / GetScreenHeight()) .. 'h'
	end,	
	
	mouseInArea = function(x, y, width, height)
		-- Not sure how to access the lua versions of these.
		local cursorPosX = Input.GetCursorPosX()
		local cursorPosY = Input.GetCursorPosY()

		return (
			cursorPosX >= x and cursorPosX < (x + width) and
			cursorPosY >= y and cursorPosY < (y + height)
		)
	end,

	mouseOnScreen = function()	-- Visible at all?
		local cursorPosX = Input.GetCursorPosX()
		local cursorPosY = Input.GetCursorPosY()
		return (cursorPosX >= 0 and cursorPosY >= 0 and cursorPosX <= GetScreenWidth() and cursorPosY <= GetScreenHeight())
	end,

	mouseInWidgetArea = function(areaWidget)	-- Allows for custom button functionality, various other interactive widgets (often for mouse L/R up, which needs to occur off the widget)
		return libGeneral.mouseInArea(
			areaWidget:GetAbsoluteX(),
			areaWidget:GetAbsoluteY(),
			areaWidget:GetWidth(),
			areaWidget:GetHeight()
		)
	end,
	
	-- Resize widget to size of target (generally a handle) widget
	resizeToTarget = function(modifyWidget, targetWidget, minWidth, minHeight, widthAdjust, heightAdjust)
		minWidth = minWidth or 400
		minHeight = minHeight or 300
		widthAdjust	= widthAdjust or false
		widthAdjust	= widthAdjust or false

		local targetWidth = math.max(targetWidget:GetX(), minWidth) + (targetWidget:GetWidth() * 0.5)
		local targetHeight = math.max(targetWidget:GetY(), minHeight) + (targetWidget:GetWidth() * 0.5)
		local targetX = modifyWidget:GetX()
		local targetY = modifyWidget:GetY()
		local handleX = math.max(targetWidget:GetX(), minWidth)
		local handleY = math.max(targetWidget:GetY(), minHeight)

		if widthAdjust then
			modifyWidget:SetWidth(math.min(GetScreenWidth() - targetWidget:GetWidth(), modifyWidget:GetAbsoluteX() + targetWidth))
			targetWidget:SetX(handleX)
		end

		if heightAdjust then
			modifyWidget:SetHeight(math.min(GetScreenHeight() - targetWidget:GetHeight(), modifyWidget:GetAbsoluteY() + targetHeight))
			targetWidget:SetY(handleY)
		end

		modifyWidget:SetX(targetX)
		modifyWidget:SetY(targetY)
	end,
	
	findNearestSnap = function(currentValue, perSnap)
		local wholePerSnap = math.floor(currentValue / perSnap)
		if (currentValue / perSnap) == wholePerSnap then
			return currentValue									-- No change
		else
			if ((wholePerSnap * perSnap) + (perSnap * 0.5)) >= currentValue then
				return (wholePerSnap * perSnap) + perSnap		-- Up
			else
				return (wholePerSnap * perSnap)					-- Down
			end
		end
	end,
	
	frameTimeRatio = function()
		local currentFrameTime = Game.GetFrameLength()
		if currentFrameTime == 0 then
			return 0
		else
			return (1000 / currentFrameTime) / 20
		end
	end,	
	
	canIAccessRankedPlay = function()
		local playerRankInfo = LuaTrigger.GetTrigger('playerRankInfo')
		if GetCvarBool('ui_IAm25SoRankedPlayIsYes') or ((LuaTrigger.GetTrigger('AccountInfo').canPlayRanked)) then
			return true
		else
			return false
		end
	end,	
	
	canIAccessKhanquest = function()
		return true
	end,
	
	canIAccessChallenges = function()
		if (LuaTrigger.GetTrigger('AccountProgression').level >= mainUI.progression.SCRIM_AND_CHALLENGE_UNLOCK_LEVEL) then
			return true
		else
			return false
		end
	end,		
	
	coloredHealthBar = function(barWidget, healthPercent)	-- Not used, but in case health bars that change color based on health percent are needed again
		barWidget:SetWidth(ToPercent(healthPercent))
		barWidget:SetColor(
			(1 - (healthPercent - 0.50) / 0.50)	-- Red
			..' '..
			(healthPercent + (((healthPercent - 0.05) / 1.0)*0.2))	-- Green
			..' '..0	-- Blue
		)
	end,
	registerNonObscuringFloat = function(container)	-- A float that, while visible, will attempt to re-align to avoid colliding with the cursor
		
		if container and type(container) == 'userdata' and container:IsValid() then
			local widgetName = container:GetName()
			
			if widgetName and string.len(widgetName) > 0 then

				local widgetPosTrigger	= LuaTrigger.CreateCustomTrigger('nonObscuringFloat_'..widgetName, {
					{ name	= 'right',	type		= 'boolean' },
					{ name	= 'bottom',	type		= 'boolean' },
				})
			
				local offset	= 28
				local throttle	= 50
				local width		= container:GetWidth()
				local height	= container:GetHeight()
				local lastTime	= 0

				local containerShow	= container:GetCallback('onshow')
				local containerHide	= container:GetCallback('onhide')
				
				container:SetCallback('onshow', function(widget)
					if containerShow then
						containerShow(widget)
					end

					container:UnregisterWatchLua('System')
					container:RegisterWatchLua('System', function(widget, trigger)
						local hostTime = trigger.hostTime
						if hostTime + throttle > lastTime then
							height = widget:GetHeight()
							local screenWidth	= GetScreenWidth()
							local screenHeight	= GetScreenHeight()
							widgetPosTrigger.right = (width <= (screenWidth / 2) and ((Input.GetCursorPosX() + offset + width) > screenWidth))
							widgetPosTrigger.bottom = (height <= (screenHeight / 2) and ((Input.GetCursorPosY() + offset + height) > screenHeight))
							widgetPosTrigger:Trigger(false)
							
							lastTime = hostTime
						end
					end, false, nil, 'hostTime')
				end)
				
				container:RegisterWatchLua('nonObscuringFloat_'..widgetName, function(widget, trigger)
					if trigger.right then
						widget:SetAlign('right')
						widget:SetX(offset * -1)
					else
						widget:SetAlign('left')
						widget:SetX(offset)
					end
					
					if trigger.bottom then
						widget:SetVAlign('bottom')
						widget:SetY(offset)
					else
						widget:SetVAlign('top')
						widget:SetY(offset * -1)
					end
				end)

				container:SetCallback('onhide', function(widget)
					if containerHide then
						containerHide(widget)
					end
					container:UnregisterWatchLua('System')
				end)
				
				widgetPosTrigger.right = false
				widgetPosTrigger.bottom = false
				widgetPosTrigger:Trigger(true)

			else
				-- Empty widget name
			end
		else
			-- Invalid widget
		end
		
	end
}
