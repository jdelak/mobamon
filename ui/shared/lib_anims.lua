--
--========================
--UTF8 Support
--========================
--
local function chsize(char)
    if not char then
        return 0
    elseif char > 240 then
        return 4
    elseif char > 225 then
        return 3
    elseif char > 192 then
        return 2
    else
        return 1
    end
end

local function utf8sub(str, startChar, numChars)
  local startIndex = 1
  while startChar > 1 do
      local char = string.byte(str, startIndex)
      startIndex = startIndex + chsize(char)
      startChar = startChar - 1
  end
 
  local currentIndex = startIndex
 
  while numChars > 0 and currentIndex <= #str do
    local char = string.byte(str, currentIndex)
    currentIndex = currentIndex + chsize(char)
    numChars = numChars -1
  end
  return str:sub(startIndex, currentIndex - 1)
end

--
--========================
--Effect
--========================
--
libAnims = {
	slideElastic = function(slidePanel, duration, targX, targY, slidePortion)
		slidePortion = slidePortion or 0.75
		if slidePortion >= 1 then
			slidePortion = 0.75
		end

		local startTime = GetTime()
		local initialX = slidePanel:GetX()
		local initialY = slidePanel:GetY()
		slidePanel:RegisterWatchLua(
			'System', function(widget, trigger)
				local currentTime = trigger.hostTime - startTime
				local posMod = nil

				if currentTime < duration * slidePortion then	-- First portion, slide at all
					posMod = libTween.easeOutCubic(
						currentTime,
						0,
						1,
						duration
					)
					if targX ~= initialX then
						widget:SetX(targX + ((initialX - targX) * posMod))
					end
					if targY ~= initialY then
						widget:SetY(initialY + ((targY - initialY) * posMod))
					end
				elseif currentTime < duration then				-- Elastic bounce portion
					posMod = libTween.easeOutElastic(
						currentTime,
						0,
						1,
						duration,
						3,
						75
					)
					if targX ~= initialX then
						widget:SetX(targX + ((initialX - targX) * posMod))
					end
					if targY ~= initialY then
						widget:SetY(initialY + ((targY - initialY) * posMod))
					end
				else											-- Done
					if targX ~= initialX then
						widget:SetX(initialX)
					end
					if targY ~= initialY then
						widget:SetY(targY)
					end
					widget:UnregisterWatchLua('System')
					widget:UICmd("SleepWidget(1000, 'FadeOut(250)')")
				end
			end, false, nil, 'hostTime')
	end,
	wobbleStart2 = function(widget, duration, rotMax, rotOffset, timeOffset)
		duration = duration or 500
		rotMax = rotMax or 45
		rotOffset = rotOffset or 0
		timeOffset = timeOffset or 0
		
		widget:RegisterWatchLua('System', function(widget, trigger)
			local rotationValue = (math.sin(
				(
					((trigger.hostTime + timeOffset) % duration) / duration
				) * math.pi * 2
			) * rotMax) + rotOffset
			widget:SetRotation(
				rotationValue
			)
		end, false, nil, 'hostTime')
	end,
	wobbleStop2 = function(widget, duration)
		duration = duration or 250
		widget:UnregisterWatchLua('System')
		widget:Rotate(0, duration)
	end,
	bounceIn = function(widget, initialWidth, initialHeight, visibility, duration, amplitude, period, startPos, posMod, callback)
		duration = duration or 300
		amplitude = amplitude or 0.1
		period = period or 350
		startPos = startPos or 0.2
		posMod = posMod or 0.8

		local startTime = GetTime()

		if visibility ~= nil then
			if visibility then
				widget:FadeIn(duration * 0.5)
			else
				widget:FadeOut(duration * 0.5)
			end
		end

		widget:UnregisterWatchLua('System')
		widget:RegisterWatchLua(
			'System', function(widget, trigger)
				local currentPosition = trigger.hostTime - startTime
				local scaleMod = libTween.easeOutElastic(currentPosition, startPos, posMod, duration, amplitude, period)
				widget:SetWidth(initialWidth * scaleMod)
				widget:SetHeight(initialHeight * scaleMod)
				if currentPosition >= duration then
					widget:SetWidth(initialWidth)
					widget:SetHeight(initialHeight)
					widget:UnregisterWatchLua('System')
					if callback then
						callback()
					end
				end
			end, false, nil, 'hostTime')
	end,
	positionJiggle = function(widget, initialX, initialY, duration, modX, modY, startPos, posMod, amplitude, period)
		duration = duration or 300
		amplitude = amplitude or 0.15
		period = period or 150
		modX = modX or false
		modY = modY or true
		startPos = startPos or 0.2
		posMod = posMod or 0.8

		local startTime = GetTime()
		
		widget:UnregisterWatchLua('System')
		widget:RegisterWatchLua(
			'System', function(widget, trigger)
				local currentPosition = trigger.hostTime - startTime
				local scaleMod = libTween.easeOutElastic(currentPosition, startPos, posMod, duration, amplitude, period)
				if modX then
					widget:SetX(initialX * scaleMod)
				end
				
				if modY then
					widget:SetY(initialY * scaleMod)
				end

				if currentPosition >= duration then
					if modX then
						widget:SetX(initialX)
					end
					if modY then
						widget:SetY(initialY)
					end
					widget:UnregisterWatchLua('System')
				end
			end, false, nil, 'hostTime')
	end,
	wobbleStart = function(widget, multiplier)
		widget:UnregisterWatchLua('System')
		widget:RegisterWatchLua(
		'System', function(widget, trigger)
			widget:SetRotation(math.sin(((trigger.hostTime % 300) / 300) * (3.14159265 * 2)) * (multiplier or 4))
		end, false, nil, 'hostTime')
	end,
	wobbleStop = function(widget)
		widget:UnregisterWatchLua('System')
		widget:SetRotation(0)
	end,	
	--[[
		This one will tween from 0 to 1 and pass that value to tweenFunc.  callback will be used at the end of the tween.
		Should be the most flexible, although most potentially resource-intensive.

		Still has to be tied to a widget so HostTime can be registered and unregistered.
		Later on we could probably just set up something to be independent of specific widgets but we'll worry about that later.
	--]]
	customTween = function(widget, duration, tweenFunc, callback)
		local startTime = GetTime()
		widget:UnregisterWatchLua('System')
		widget:RegisterWatchLua(
			'System', function(widget, trigger)
				local currentPosition = trigger.hostTime - startTime
				-- local posPercent = libTween.linear(currentPosition, 0, 1, duration)

				if currentPosition >= duration then
					widget:UnregisterWatchLua('System')
					tweenFunc(1)
					if callback and type(callback) == 'function' then
						callback()
					end
				else
					tweenFunc((currentPosition / duration))
				end
			end, false, nil, 'hostTime')
	end,
	textPopulateFade = function(widget, duration, label, fadeLength)
		if label and type(label) == 'string' then
			local labelLength = string.len(label)
			if labelLength > 0 then
				local r,g,b,a = widget:GetColor()
				r = math.ceil(r * 9)
				g = math.ceil(g * 9)
				b = math.ceil(b * 9)
				a = (a * 9)
				duration		= duration or 500

				fadeLength = math.min(duration, (fadeLength or 350))
				
				local timePerChar	= (duration / 160)
				
				local charArray = {}
				local charPercent = {}
				
				for i=1,labelLength,1 do
					table.insert(charArray, utf8sub(label, i, 1))
					-- table.insert(charArray, string.sub(label, i, i))
					table.insert(charPercent, 0)
				end
				
				local charPos = nil
				
				local durationAdd = (duration + fadeLength)
				
				libAnims.customTween(widget, duration, function(progPercent)
					local durationCur		= (durationAdd * progPercent)
					local durationOpaque	= durationCur - fadeLength
					
					local currentLabel = ''
					
					for i=1,labelLength,1 do
						charPos = (i * timePerChar)
						if charPos <= durationOpaque then
							currentLabel = currentLabel .. charArray[i]
						elseif charPos <= durationCur then
							local charAlpha = (1 - (math.max(0, (charPos - durationOpaque)) / fadeLength))
							currentLabel = currentLabel .. '^a'..r..g..b..( math.ceil( math.max(0, math.min(9, (charAlpha * a))) ) )..charArray[i]
						end
					end
					
					-- printr(currentLabel)
					widget:SetText(currentLabel)
				end)
			end
		end
	end,
}
