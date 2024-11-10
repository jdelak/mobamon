local _G = getfenv(0)
local ipairs, pairs, select, string, table, next, type, unpack, tinsert, tconcat, tremove, format, tostring, tonumber, tsort, ceil, floor, sqrt, atan2, sin, cos, pi, sub, find, gfind = _G.ipairs, _G.pairs, _G.select, _G.string, _G.table, _G.next, _G.type, _G.unpack, _G.table.insert, _G.table.concat, _G.table.remove, _G.string.format, _G.tostring, _G.tonumber, _G.table.sort, _G.math.ceil, _G.math.floor, _G.math.sqrt, _G.math.atan2, _G.math.sin, _G.math.cos, _G.math.pi, _G.string.sub, _G.string.find, _G.string.gfind
local interface = object
local interfaceName = interface:GetName()
GameUI = GameUI or {}
GameUI.RadialSelection = {}

Cmd('SetSave cg_commandDialOpenTime 125')

local moveCursor 				= {['command'] = true,  ['chat'] = true}
local moveCursorBack 			= {['command'] = true, ['chat'] = true}
local RadialSelectionOpen 		= {['command'] = false, ['chat'] = false}

local oldX 						= {['command'] = nil,  ['chat'] = nil}
local oldY 						= {['command'] = nil,  ['chat'] = nil}
local oldSelected  				= {['command'] = -1,   ['chat'] = -1}

local movingCenterThread = nil

-- This allows for the use of a generic radial selection - which can be re-purposed with several different numbers of options etc.
-- Note that the reason for NOT using mouseOver callbacks etc is because the bitmasks still don't act the same way as the image (rotating, scaling etc)

function GameUI.RadialSelection:hide(radialType)
	if (movingCenterThread and movingCenterThread:IsValid()) then
		movingCenterThread:kill()
		movingCenterThread = nil
	end
	if moveCursorBack[radialType] and oldX[radialType] and oldY[radialType] then Input.SetCursorPos(oldX[radialType], oldY[radialType]) end
	interface:GetWidget('radial_selection_'..radialType):SetVisible(false)
	RadialSelectionOpen[radialType] = false
	oldY[radialType] = nil
	oldX[radialType] = nil
end

-- Our selector is offset by 10h, upwards.
local centerPos = {GetScreenWidth()/2, GetScreenHeight()/2}

-- Creates a radial selection.
-- e.g for input: { 
--     {texture='', desc='', onclick='function'},
--     {texture='', desc='', onclick='function'}
-- }
local function clamp(n, low, high) return math.max( math.min(n, high), low ) end -- This is such a useful function - it should probably be in a general library.
function GameUI.RadialSelection:create(radialType, selectionList, mouseXOffset, mouseYOffset, pingCoords)
	-- Don't create if we are currently accessing the shop!
	if libGeneral.mouseInWidgetArea(GetWidget('gameShopContainer', 'game')) then
		return
	end

	-- Move cursor to center, and save old position
	oldX[radialType] = Input.GetCursorPosX()
	oldY[radialType] = Input.GetCursorPosY()
	
	------------
	-- variables
	------------
	local selection_container = interface:GetWidget('radial_selection_'..radialType..'_container')
	local selection_mover = interface:GetWidget('radial_selection_'..radialType..'_mover')
	local radial_selection_parent = interface:GetWidget('radial_selection_'..radialType..'_parent')
	local title = interface:GetWidget('radial_'..radialType..'_description')
	local numItems = #selectionList -1 -- works because elements should be numerical
	local buttons = {}
	local subButtons = {}
	local radius = 30 -- in h
	local iconRadius = 27 -- in h
	local centerRadius = 78
	local sectionRadius = libGeneral.HtoP(15)
	local subSectionIconRadius = 40 -- in h
	local subSectionIconsize = 8 -- in h
	local centerCircle 		= interface:GetWidget('radial_selection_'..radialType..'_center')
	local centerCircleArrow = interface:GetWidget('radial_selection_'..radialType..'_center_arrow')
	local centerCircleIcon 	= interface:GetWidget('radial_selection_'..radialType..'_center_icon')
	local radial_selection 	= interface:GetWidget('radial_selection_'..radialType)
	local radial_dropShadow	= interface:GetWidget('radial_selection_'..radialType..'_drop_shadow')
	local arrowVisible = false
	
	-- Find a good spot for our radial wheel
	local desiredX = oldX[radialType]+(mouseXOffset or 0)
	local desiredY = oldY[radialType]+(mouseYOffset or 0)
	-- stop it from going off screen
	desiredX = clamp(desiredX, libGeneral.HtoP(25), GetScreenWidth()-libGeneral.HtoP(25))
	desiredY = clamp(desiredY, libGeneral.HtoP(27), GetScreenHeight()-libGeneral.HtoP(25))
	
	-- Make the drop-shadow opaque when it could be obscuring other UI
	if (desiredX < libGeneral.HtoP(25)) or
	  (desiredY < libGeneral.HtoP(33)) or
	  (desiredX > GetScreenWidth()-libGeneral.HtoP(45)) or
	  (desiredY > libGeneral.HtoP(66)) then
		radial_dropShadow:SetColor('0.15 0.15 0.15 1')
		radial_dropShadow:SetBorderColor('0.15 0.15 0.15 1')
	else
		radial_dropShadow:SetColor('0.15 0.15 0.15 0.5')
		radial_dropShadow:SetBorderColor('0.15 0.15 0.15 0.5')
	end
	
	selection_mover:SetX(-centerPos[1] + desiredX)
	selection_mover:SetY(-centerPos[2] + desiredY)
	
	------------------
	-- Widget creation
	-- This deals with all of the new widgets, and their sub-sections if they have any.
	------------------
	-- Clear previous widgets
	selection_container:ClearChildren()
	-- center circle
	centerCircle:SetCallback('onclick', function(widget)
		GameUI.RadialSelection:hide(radialType)
		loadstring(selectionList[numItems+1].onclick)()
	end)
	centerCircle:SetCallback('onrightclick', function(widget)
		GameUI.RadialSelection:hide(radialType)
		loadstring(selectionList[numItems+1].onclick)()
	end)
	centerCircle:SetCallback('onmouseover', function(widget)
		PlaySound('/shared/sounds/ui/button_over_02.wav')
		widget:SetTexture('/ui/game/radial_selection/textures/wheel_indicator.tga')
		widget:Scale('14h', '14h', 50)
		widget:BringToFront()
		centerCircleArrow:BringToFront()
		centerCircleIcon:Scale('6h', '6h', 50)
		centerCircleIcon:BringToFront()
		--UpdateCursor(widget, true, {canLeftClick = true , canRightClick = false})
		widget:SetCursor('/core/cursors/invis.cursor')
		--description:SetText(Translate(selectionList[numItems+1].desc))
	end)
	centerCircle:SetCallback('onmouseout', function(widget)
		widget:SetTexture('/ui/game/radial_selection/textures/wheel_indicator.tga')
		widget:Scale('14h', '14h', 50)
		centerCircleIcon:Scale('5h', '5h', 50)
	end)
	centerCircleIcon:SetTexture(selectionList[numItems+1].texture)
	
	title:SetText(Translate('radial_title'..numItems))
	
	-- The sub-selections (that pop out of the main spokes on mouse-over, after 300 ms)
	for n=1, numItems do
		if selectionList[n].subButtons and #selectionList[n].subButtons > 0 then
			local container = interface:GetWidget('radial_'..radialType..'_cone_'..n..'_sub_container')
			local numSubs = #selectionList[n].subButtons
			for i = 1, numSubs do
				local sectionLength = 2*pi/numItems
				local subSectionRotation = sectionLength*(((2*i-1)/(2*numSubs))-0.5) -- with 3 options, this would be -33.5%, 0% and 33.5% of a section length
				local rotation = (n-1)*sectionLength + subSectionRotation
				
				local x = -(radius*1.05)/2*cos(rotation)
				local y = -(radius*1.05)/2*sin(rotation)
				local iconx = -(subSectionIconRadius)/2*cos(rotation)
				local icony = -(subSectionIconRadius)/2*sin(rotation)
				local subSection = selection_container:InstantiateAndReturn('radial_sub_selection_item',
					'type', radialType,
					'x', x..'h', 
					'y', y..'h', 
					'width', radius*1.05 ..'h', 
					'height', radius*1.05 ..'h', 
					'iconx', iconx..'h', 
					'icony', icony..'h', 
					'iconWidth', subSectionIconsize/3 ..'h', 
					'iconHeight', subSectionIconsize/3 ..'h', 
					'texture', selectionList[n].subButtons[i].texture, 
					'max', numItems, 
					'index', n, 
					'subNum', i,
					'subMax', numSubs)[1]
				interface:GetWidget("radial_cone_"..n.."_"..i):SetRotation(rotation*360/(2*pi) - 90)
				tinsert(subButtons, subSection)
			end
		end
	end
	
	-- The main selection spokes
	for n=1, numItems do
		
		local rotation = (n-1)*2*pi/numItems
		-- cone point will always be at 0.5, 0 the image width/height.
		local x = -(radius)/2*cos(rotation)
		local y = -(radius)/2*sin(rotation)
		local iconx = -(iconRadius)/2*cos(rotation)
		local icony = -(iconRadius)/2*sin(rotation)
		local descy = icony + 4.2
		local glowRadius = radius/2.3 + 14
		local size = 'maindyn_14'
		
		if (selectionList[n].visible == '0') then
			descy = icony
			size = 'maindyn_14'
			glowRadius = radius/2.3 + 3
		end
		
		local renderMode = selectionList[n].onclick and "normal" or "grayscale"
		local button = selection_container:InstantiateAndReturn('radial_selection_item', 
			'type', radialType,
			'x', x..'h', 
			'y', y..'h', 
			'width', radius..'h', 
			'height', radius..'h', 
			'iconx', iconx..'h', 
			'icony', icony..'h', 
			'descx', iconx..'h',
			'descy', descy..'h',
			'iconWidth', radius/2.6 ..'h', 
			'iconHeight', radius/2.6 ..'h', 
			'glowWidth', glowRadius..'h', 
			'glowHeight', glowRadius..'h', 
			'texture', selectionList[n].texture, 
			'visible', selectionList[n].visible, 
			'description', selectionList[n].desc,
			'size', size,
			'max', numItems, 
			'renderMode', renderMode, 
			'index', n)[1]
		button:SetRotation(rotation*360/(2*pi) - 90)
		tinsert(buttons, button)
	end
	
	--------------
	-- transitions
	--------------
	if (radial_selection) then
		radial_selection:SetVisible(true)
	end
	
	for i,v in ipairs(buttons) do
		v:SetWidth('0.1h')
		v:SetHeight('0.1h')
	end
	
	libThread.threadFunc(function()	
		wait(1)
		for i,v in ipairs(buttons) do
			v:Scale((radius*1.2+0.3)..'h', radius*1.2 ..'h', 125, false)
		end
		wait(125)
		for i,v in ipairs(buttons) do
			v:Scale((radius+0.3)..'h', radius..'h', 50, false)
		end
		wait(50)
		oldSelected[radialType] = -1 -- Allow the one that the mouse is over to scale itself
	end)
	
	RadialSelectionOpen[radialType] = true
	local expandingSubSectionsThread = nil
	-- These functions do the animations for mouse-overs
	-- Main spokes
	local function expandSection(section)
		if expandingSubSectionsThread and expandingSubSectionsThread:IsValid() then
			expandingSubSectionsThread:kill()
			expandingSubSectionsThread = nil
		end
		
		if (section < 1 or section > numItems) then return end
		
		local widget 		= buttons[section]
		local cone 			= interface:GetWidget('radial_'..radialType..'_cone_'..section)
		local desc			= interface:GetWidget('radial_'..radialType..'_description_'..section)
		local glow 			= interface:GetWidget('radial_'..radialType..'_glow_'..section)
		local icon 			= interface:GetWidget('radial_'..radialType..'_image_'..section)
		
		PlaySound('/shared/sounds/ui/button_over_02.wav')
		
		expandingSubSectionsThread = libThread.threadFunc(function()
			cone:SetTexture('/ui/game/radial_selection/textures/cone'..numItems..'_highlighted.tga')
			widget:Scale(radius*1.1 .. 'h', radius*1.2 .. 'h', 100)
			widget:BringToFront()
			icon:Scale(radius/2.6*1.2 .. 'h', radius/2.6*1.2 .. 'h', 100)
			glow:FadeIn(100)
			glow:BringToFront()
			icon:SetColor(1, 1, 1, 1)
			icon:BringToFront()
			desc:SetColor(0.91, 0.98, 1, 1)
			desc:SetOutlineColor('0.06 0.2 0.23 1')
			desc:BringToFront()
			
			wait(100)
			widget:Scale(radius..'h', radius..'h', 100)
			icon:Scale(radius/2.6 ..'h', radius/2.6 ..'h', 100)
		
			--UpdateCursor(widget, true, {canLeftClick = true , canRightClick = false})
			widget:SetCursor('/core/cursors/invis.cursor')
			if selectionList[section].subButtons and #selectionList[section].subButtons > 0 then
				wait(300) -- Show subsections after 500ms
				for n=1, #selectionList[section].subButtons do
					interface:GetWidget("radial_subsection_"..section.."_"..n):FadeIn(100)
				end
			end
		end)
	end
	
	local function collapseSection(section)
		if (section < 1 or section > numItems) then return end
		local widget 		= buttons[section]
		local cone 			= interface:GetWidget('radial_'..radialType..'_cone_'..section)
		local desc			= interface:GetWidget('radial_'..radialType..'_description_'..section)
		local glow 			= interface:GetWidget('radial_'..radialType..'_glow_'..section)
		local icon 			= interface:GetWidget('radial_'..radialType..'_image_'..section)
		
		cone:SetTexture('/ui/game/radial_selection/textures/cone'..numItems..'.tga')
		widget:Scale(radius..'h', radius..'h', 100)
		glow:FadeOut(50)
		icon:Scale(radius/2.6 ..'h', radius/2.6 ..'h', 100)
		icon:SetColor(0.4, 0.4, 0.4, 1)
		desc:SetColor(0.7, 0.7, 0.7, 1)
		desc:SetOutlineColor('0.05 0.05 0.05 1')
		
		-- Hide subsections
		if selectionList[section].subButtons and #selectionList[section].subButtons > 0 then
			for n=1, #selectionList[section].subButtons do
				interface:GetWidget("radial_subsection_"..section.."_"..n):FadeOut(100)
			end
		end
	end
	-- The sub sections which come out of the spokes after 300ms
	local function expandSubSection(section, subSection)
		if (section > 0 and subSection == -1) then
			--description:SetText(Translate(selectionList[section].desc))
		end
		if (section < 1 or section > numItems or subSection < 1) then return end
		local widget = interface:GetWidget('radial_'..radialType..'_cone_'..section.."_"..subSection)
		widget:SetColor('0.6 0.6 0.6 1')
		--description:SetText(Translate(selectionList[section].subButtons[subSection].desc))
	end
	local function collapseSubSection(section, subSection)
		if (section < 1 or section > numItems or subSection < 1) then return end
		local widget = interface:GetWidget('radial_'..radialType..'_cone_'..section.."_"..subSection)
		if widget and widget:IsValid() then
			widget:SetColor('0.7 0.7 0.7 0.8')
		end
	end
	
	-- Track the mouse, call animations on all the mouse overs, and do clicks
	local oldSelectedSection = -1
	
	
	radial_selection:SetCallback('onmouseover', function(widget)
		widget:SetCursor('/core/cursors/invis.cursor')
	end)
	
	radial_selection:UnregisterWatchLua('System')
	radial_selection:RegisterWatchLua('System', function(widget, trigger)
		if movingCenterThread and movingCenterThread:IsValid() then
			movingCenterThread:kill()
			movingCenterThread = nil
		end

		if not RadialSelectionOpen[radialType] then -- menu is closed, time to stop
			widget:UnregisterWatchLua('System')
			centerCircleArrow:FadeOut(100)
			arrowVisible = false
		else
			movingCenterThread = libThread.threadFunc(function()				
				wait(1) --Give time for the cursor to move to the center
				
				local centerCircle 		= interface:GetWidget('radial_selection_'..radialType..'_center')
				
				if (centerCircle) and (centerCircle:IsValid()) then
				
					local mouseAngle = atan2(Input.GetCursorPosY()-centerPos[2],Input.GetCursorPosX()-centerPos[1])
					local distancex=Input.GetCursorPosX()-centerPos[1]
					local distancey=Input.GetCursorPosY()-centerPos[2]
					
					if ((distancex*distancex + distancey*distancey) > sectionRadius*sectionRadius) then -- Mouse is outside of wheel				
						--This would keep the mouse in bounds
						Input.SetCursorPos(centerPos[1] + cos(mouseAngle)*sectionRadius, centerPos[2] + sin(mouseAngle)*sectionRadius)
						widget:SetCursor('/core/cursors/invis.cursor')
					end
					if ((distancex*distancex + distancey*distancey) < centerRadius*centerRadius) then -- Mouse is over close
						centerCircle:SetRotation(0)
						
						if arrowVisible == true then
							centerCircleArrow:FadeOut(100)
							arrowVisible = false
						end
						
					else -- Mouse is within limits to select
						centerCircleArrow:SetRotation(mouseAngle*360/(2*pi)+90)
						centerCircle:SetRotation(mouseAngle*360/(2*pi)+90)	

						if arrowVisible == false then
							centerCircleArrow:FadeIn(200)
							arrowVisible = true
						end
					end
				
					local mouseX = Input.GetCursorPosX()
					local mouseY = Input.GetCursorPosY()
					
					local pixelRadius = libGeneral.HtoP(20)
					local selectedPixelRadius = libGeneral.HtoP(25)
					local innerRadius = libGeneral.HtoP(7)
					
					local mouseAngle = atan2(mouseY-centerPos[2],mouseX-centerPos[1])
					local mouseXDisplacement = mouseX-centerPos[1]
					local mouseYDisplacement = mouseY-centerPos[2]
					local mouseDistance = sqrt(mouseXDisplacement*mouseXDisplacement + mouseYDisplacement*mouseYDisplacement)
					
					mouseAngle=mouseAngle+pi
					if (mouseAngle<0) then mouseAngle = 2*pi+mouseAngle end
					local segmentLength = 2*pi/numItems
					local newSelected = floor(0.5+(mouseAngle)/segmentLength)+1
					if newSelected == numItems+1 then newSelected = 1 end
					
					local newSelectedSection = -1
					
					if --[[mouseDistance < pixelRadius and]] mouseDistance > innerRadius then
						-- Not too far away (more for selected one)
					elseif mouseDistance > innerRadius and (newSelected == oldSelected[radialType] and selectionList[newSelected].subButtons and mouseDistance < selectedPixelRadius) then
						-- Hovering over a sub-section, lets find it!
						local angleOffset = segmentLength*(newSelected-0.5)-mouseAngle -- Angle from the main spoke
						if (angleOffset < 0) then angleOffset = angleOffset + 2*pi end
						newSelectedSection = floor(#selectionList[newSelected].subButtons * angleOffset/segmentLength)+1
						newSelectedSection = #selectionList[newSelected].subButtons - newSelectedSection + 1 -- Order of subsections is reversed, so make it normal
						if newSelectedSection < 1 then newSelectedSection = 1 end
						if newSelectedSection > #selectionList[newSelected].subButtons then newSelectedSection = #selectionList[newSelected].subButtons end
					else -- Nothing selected
						newSelected = -1
					end
					
					if newSelected ~= oldSelected[radialType] then -- We've changed what we are hovering over - update the widgets
						expandSection(newSelected)
						collapseSection(oldSelected[radialType])
						oldSelected[radialType] = newSelected
					elseif (newSelectedSection ~= oldSelectedSection) then -- We've changed sub-section, update those
						expandSubSection(newSelected, newSelectedSection)
						collapseSubSection(oldSelected[radialType], oldSelectedSection)
						oldSelectedSection = newSelectedSection
					end
				end
			end)
		end
	end)
	
	local lanes = {}
	lanes[0] = "_middle"
	lanes[1] = "_top"
	lanes[2] = "_bottom"
	
	function confirmSelection()
		if (oldSelected[radialType] < 1 or oldSelected[radialType] > numItems) then
			GameUI.RadialSelection:hide(radialType)
			return
		end
		if oldSelectedSection ~= -1 then
			loadstring(selectionList[oldSelected[radialType]].subButtons[oldSelectedSection].onclick)()
			if (pingCoords) then
				if selectionList[oldSelected[radialType]].ping then
					PingWorldPosition(pingCoords, selectionList[oldSelected[radialType]].ping)
				else
					PingWorldPosition(pingCoords)
				end
			end
			GameUI.RadialSelection:hide(radialType)
		else
			if selectionList[oldSelected[radialType]].onclick then
				if (pingCoords) then
				
					local lane = GetLaneLocation(pingCoords)
					if (lane < 3) then
						selectionList[oldSelected[radialType]].onclick(lanes[lane])
					else
						selectionList[oldSelected[radialType]].onclick("")
					end
				
					if selectionList[oldSelected[radialType]].ping then
						PingWorldPosition(pingCoords, selectionList[oldSelected[radialType]].ping)
					else
						PingWorldPosition(pingCoords)
					end
				else
					selectionList[oldSelected[radialType]].onclick("")
				end
				GameUI.RadialSelection:hide(radialType)
			end
		end
	end
	
	-- onclick: run the code in the onclick portion of the clicked segment, in the original table we were given.
	radial_selection:SetCallback('onmouselup', function(widget)
		confirmSelection()
	end)
	
	radial_selection:SetCallback('onclick', function(widget)
		confirmSelection()
	end)
	
	radial_selection:SetCallback('onrightclick', function(widget)
		GameUI.RadialSelection:hide(radialType)
	end)
	
	if moveCursor[radialType] then Input.SetCursorPos(centerPos[1]+(mouseXOffset or 0), centerPos[2]+(mouseYOffset or 0)) end
end