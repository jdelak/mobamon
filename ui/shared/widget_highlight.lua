local interface = object


local sizeMultiplier	= 2

local aspectModels = {
	{ 16, '16to1' },
	{ 8, '8to1' },
	{ 4, '4to1' },
	{ 2, '2to1' },
	{ 1, '1to1' },
	{ 0.5, '1to2' },
	{ 0.25, '1to4' },
	{ 0.125, '1to8' },
	{ 0.0625, '1to16' }
}

local function findAspectModel(width, height)
	if width and height and type(width) == 'number' and type(height) == 'number' and width > 0 and height > 0 then
		local aspect = (width / height)
		for i=1,#aspectModels,1 do
			if aspect >= aspectModels[i][1] then
				return aspectModels[i][2]
			end
		end
	end
	return '1to1'
end

function spotlightWidget(widget, legacy)
	legacy = legacy or false
	local spotlightEffect	= interface:GetWidget('widgetHighlight')
	local spotlightModel	= interface:GetWidget('widgetHighlightModel')
	if widget then

		local useSize = sizeMultiplier
		if legacy then
			useSize = 1
		end
		local width = (widget:GetWidth() * useSize)
		local height = (widget:GetHeight() * useSize)

		local model = ''
		if not legacy then
			model = findAspectModel(width, height)
		end


		spotlightEffect:SetWidth(width)
		spotlightEffect:SetHeight(height)


		if legacy then
			spotlightModel:SetModel('/ui/_models/tut_highlight.mdf')
			spotlightModel:Sleep(1, function()
				spotlightModel:SetEffect('/ui/_models/tut_highlight.effect')
				spotlightModel:SetCameraPos(0, -1000, 3)
			end)
		else
			spotlightModel:SetModel('/ui/_models/'..model..'/button.mdf')
			spotlightModel:Sleep(1, function()
				spotlightModel:SetEffect('/ui/_models/'..model..'/button.effect')
				spotlightModel:SetCameraPos(0, -1000, 0.25)
			end)
		end




		spotlightEffect:SetX(widget:GetAbsoluteX() - ((width - widget:GetWidth()) * 0.5))
		spotlightEffect:SetY(widget:GetAbsoluteY() - ((height - widget:GetHeight()) * 0.5))
		--[[
		spotlightEffect:SetX(widget:GetAbsoluteX())
		spotlightEffect:SetY(widget:GetAbsoluteY())
		--]]
		spotlightEffect:SetVisible(true)
	else
		spotlightEffect:SetVisible(false)
	end
end

function darkenScreen(visible)
	local visible = visible or false

	libGeneral.fade(interface:GetWidget('darkenScreen'), visible, 200)
end

widgetHighlightMultiList		= {}
local widgetHighlightMultiContainer	= interface:GetWidget('widgetHighlightInstanceContainer')
local widgetHighlightMultiPrefix	= 'widgetHighlightMulti_'

local function widgetHighlightMultiClear()
	local multiGroup = interface:GetGroup('widgetHighlightInstances')
	if multiGroup and type(multiGroup) == 'table' and #multiGroup > 0 then
		local widgetName
		for k,widget in ipairs(multiGroup) do
			local widgetName = widget:GetName()
			widgetHighlightMultiList[widgetName]	= false
			-- widget:Destroy()	-- apparently these don't destroy
		end
	end
	widgetHighlightMultiContainer:ClearChildren()	-- have to do this instead of destroy on individual widgets
end

local function widgetHighlightMultiInstantiate(widget)
	legacy = legacy or false
	if widget and type(widget) == 'userdata' and widget:IsValid() then
		local widgetName	= widget:GetName()
		local placeholder	= interface:GetWidget('widgetHighlightPlaceholder')
		if not widgetHighlightMultiList[widgetHighlightMultiPrefix..widgetName] then
			local width		= (widget:GetWidth() * sizeMultiplier)
			local height	= (widget:GetHeight() * sizeMultiplier)

			placeholder:SetWidth(width)
			placeholder:SetHeight(height)

			-- local posX	= libGeneral.getXToCenterOnTarget(placeholder, widget)
			-- local posY	= libGeneral.getYToCenterOnTarget(placeholder, widget)

			local posX = (widget:GetAbsoluteX() - ((width - widget:GetWidth()) * 0.5))
			local posY = (widget:GetAbsoluteY() - ((height - widget:GetHeight()) * 0.5))

			if legacy then
				widgetHighlightMultiContainer:Instantiate('widgetHighlightInstanceOld', 'id', widgetHighlightMultiPrefix..widgetName, 'x', posX, 'y', posY, 'width', width, 'height', height)
			else
				widgetHighlightMultiContainer:Instantiate('widgetHighlightInstance', 'id', widgetHighlightMultiPrefix..widgetName, 'x', posX, 'y', posY, 'width', width, 'height', height, 'model', findAspectModel(width, height))
			end

			widgetHighlightMultiList[widgetHighlightMultiPrefix..widgetName] = true
		end
	end

end

function widgetHighlightMulti(widgetList, legacy)
	legacy = legacy or false
	if widgetList then
		if type(widgetList) == 'table' then
			for k,widget in ipairs(widgetList) do
				widgetHighlightMultiInstantiate(widget, legacy)
			end
		elseif type(widgetList) == 'userdata' then
			widgetHighlightMultiInstantiate(widgetList, legacy)
		end
	else
		widgetHighlightMultiClear()
	end
end

function darkenAroundWidget(widget, showClose, fadeTime)

	local widgetHighlightBG1	= interface:GetWidget('widgetHighlightBG1')
	local widgetHighlightBG2	= interface:GetWidget('widgetHighlightBG2')
	local widgetHighlightBG3	= interface:GetWidget('widgetHighlightBG3')
	local widgetHighlightBG4	= interface:GetWidget('widgetHighlightBG4')
	local widgetHighlightBorder	= interface:GetWidget('widgetHighlightBorder')
	local widgetHighlightClose	= interface:GetWidget('widgetHighlightClose')

	local visBG1			= false
	local visBG2			= false
	local visBG3			= false
	local visBG4			= false
	local visBorder			= false
	local visClose			= false

	local showClose				= showClose or false
	if widget and (type(widget) == 'userdata' or type(widget) == 'boolean') then
		if type(widget) == 'userdata' then
			local targetX = widget:GetAbsoluteX()
			local targetY = widget:GetAbsoluteY()
			local targetW = widget:GetWidth()
			local targetH = widget:GetHeight()
			visBG1		= true
			visBG2		= true
			visBG3		= true
			visBG4		= true
			visBorder	= true
			visClose	= showClose

			widgetHighlightBG1:SetX(targetX + targetW + 4)

			widgetHighlightBG2:SetX(targetX - widgetHighlightBG2:GetWidthFromString('100%') - 4)

			widgetHighlightBG3:SetWidth(targetW + 8)
			widgetHighlightBG3:SetX(targetX - 4)
			widgetHighlightBG3:SetY(targetY + targetH + 4)

			widgetHighlightBG4:SetWidth(targetW + 8)

			widgetHighlightBorder:SetX(targetX - 4)
			widgetHighlightBorder:SetY(targetY - 4)
			widgetHighlightBorder:SetWidth(targetW + 8)
			widgetHighlightBorder:SetHeight(targetH + 8)
			widgetHighlightBG4:SetX(targetX - 4)
			widgetHighlightBG4:SetY(targetY - widgetHighlightBG4:GetHeightFromString('100%') - 4)
			widgetHighlightClose:SetVisible(showClose)
		else
			widgetHighlightBG1:SetX(0)
			widgetHighlightBG1:SetY(0)
			widgetHighlightBG1:SetWidth(GetScreenWidth())
			widgetHighlightBG1:SetHeight(GetScreenHeight())
			visBG1		= true
			visBG2		= false
			visBG3		= false
			visBG4		= false
			visBorder	= false
			visclose	= showClose
		end
	else
		visBG1		= false
		visBG2		= false
		visBG3		= false
		visBG4		= false
		visBorder	= false
		visClose	= false
	end

	if fadeTime and type(fadeTime) == 'number' and fadeTime > 0 then
		libGeneral.fade(widgetHighlightBG1, visBG1, fadeTime)
		libGeneral.fade(widgetHighlightBG2, visBG2, fadeTime)
		libGeneral.fade(widgetHighlightBG3, visBG3, fadeTime)
		libGeneral.fade(widgetHighlightBG4, visBG4, fadeTime)
		libGeneral.fade(widgetHighlightClose, visClose, fadeTime)
		libGeneral.fade(widgetHighlightBorder, visBorder, fadeTime)
	else
		widgetHighlightBG1:SetVisible(visBG1)
		widgetHighlightBG2:SetVisible(visBG2)
		widgetHighlightBG3:SetVisible(visBG3)
		widgetHighlightBG4:SetVisible(visBG4)
		widgetHighlightClose:SetVisible(visClose)
		widgetHighlightBorder:SetVisible(visBorder)
	end
end

object:GetWidget('widgetHighlightClose'):SetCallback('onclick', function(widget)
	darkenAroundWidget()
	-- spotlightWidget()
end)

local function widgetHighlightRegister(object)
	local posOffset			= libGeneral.HtoP(3)
	local slideTime			= 800
	local fadeTime			= 1000
	local pointer			= object:GetWidget('widgetPointer')
	local widgetPlaceholder	= object:GetWidget('widgetHighlightPlaceholder')
	local labelFrame		= object:GetWidget('widgetHighlightLabelFrame')
	local pointerOffsetX	= (pointer:GetWidth() / 2) + libGeneral.HtoP(0.75)
	local pointerOffsetY	= (pointer:GetHeight() / 2) + libGeneral.HtoP(0.75)

	local slideIn = false

	local function pointEnd()
		pointer:UnregisterWatchLua('System')
		pointer:FadeOut(fadeTime)
		labelFrame:FadeOut(fadeTime)
	end


	function widgetHighlightGetPlaceholder()
		return widgetPlaceholder
	end

	function widgetHighlightPlacePlaceholder(widgetInfo, skipVisCheck)
		skipVisCheck = skipVisCheck or false
		if widgetInfo then
			if type(widgetInfo) ~= 'table' then
				widgetInfo = { widgetInfo }
			end

			local x, y, width, height = libGeneral.getWidgetsBounds(widgetInfo, skipVisCheck)

			widgetPlaceholder:SetX(x)
			widgetPlaceholder:SetY(y)
			widgetPlaceholder:SetWidth(width)
			widgetPlaceholder:SetHeight(height)
		end
	end

	pointer:SetCallback('onhide', function(widget) pointEnd() end)

	local function slideOut(widget, targX, targY, xMod, yMod)
		if slideIn then
			widget:SlideX(targX + (pointerOffsetX * xMod), slideTime)
			widget:SlideY(targY + (pointerOffsetY * yMod), slideTime)
			slideIn = false
		end
	end

	local function pointStart(targX, targY, xMod, yMod)
		slideIn	= true	-- Will force slideout to start
		pointer:SetX(targX)
		pointer:SetY(targY)

		slideOut(pointer, targX, targY, xMod, yMod)
		pointer:FadeIn(fadeTime)

		local currentTime	= LuaTrigger.GetTrigger('System').hostTime
		local timeOffset	= (currentTime % (slideTime * 2)) -- Ensures that we start with the same motion (out)

		pointer:RegisterWatchLua('System', function(widget, trigger)
			if (trigger.hostTime - timeOffset) % (slideTime * 2) > slideTime then
				-- In
				if not slideIn then
					widget:SlideX(targX, slideTime)
					widget:SlideY(targY, slideTime)
					slideIn = true
				end

			else
				-- Out
				slideOut(widget, targX, targY, xMod, yMod)
			end
		end, false, nil, 'hostTime')
	end

	function pointAtWidgetStop()
		pointEnd()
	end

	function pointAtWidget(widget, pointerLabel)
		if (widget) and (widget:IsValid()) then
			local label 		= object:GetWidget('widgetHighlightLabel')

			local xMod				= 1
			local yMod				= 1

			local targX		= widget:GetAbsoluteX() + (widget:GetWidth() / 2) - pointerOffsetX
			local targY		= widget:GetAbsoluteY() + (widget:GetHeight() / 2) - pointerOffsetY

			local slidePos		= -1

			if targX > (GetScreenWidth() / 2) then
				xMod = -1
				if targY > (GetScreenHeight() / 2) then
					yMod = -1
					pointer:SetRotation(135)
				else
					yMod = 1
					pointer:SetRotation(45)
				end
			else
				xMod = 1
				if targY > (GetScreenHeight() / 2) then
					yMod = -1
					pointer:SetRotation(-135)
				else
					pointer:SetRotation(-45)
					yMod = 1
				end
			end

			pointEnd(widget)
			pointStart(targX, targY, xMod, yMod)

			if pointerLabel and string.len(pointerLabel) > 0 then
				labelFrame:SetX(targX + (xMod * pointerOffsetX * 2.5))
				labelFrame:SetY(targY + (yMod * pointerOffsetY * 2.5))
				labelFrame:FadeIn(fadeTime)
				label:SetText(Translate(pointerLabel))
			else
				labelFrame:SetVisible(false)
			end
		else
			println('pointAtWidget failed')
			println('widget ' .. tostring(widget))
			println('pointerLabel ' .. tostring(pointerLabel))
		end
	end
end

widgetHighlightRegister(object)