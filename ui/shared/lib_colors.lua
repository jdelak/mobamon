libColors = {}

function libColors.saturateColor(inputColor, saturation) --should be in the form 'r g b', saturation 0-1
	local colors = split(inputColor, " ")
	local red = tostring(colors[1])
	local green = tostring(colors[2])
	local blue = tostring(colors[3])
	red = red +		(1-red)*saturation
	green = green +	(1-green)*saturation
	blue = blue +	(1-blue)*saturation
	return red .. " " .. green .. " " .. blue
end

function libColors.invertColor(inputColor) --should be in the form 'r g b'
	local colors = split(inputColor, " ")
	local red = tostring(colors[1])
	local green = tostring(colors[2])
	local blue = tostring(colors[3])
	red = (1-red)
	green = (1-green)
	blue = (1-blue)
	return red .. " " .. green .. " " .. blue
end

function libColors.multiplyColor(inputColor, value) --should be in the form 'r g b [a]', value 0-1
	local colors = split(inputColor, " ")
	return tonumber(colors[1])*value .. " " .. tonumber(colors[2])*value .. " " .. tonumber(colors[3])*value .. (colors[4] and (" " .. tonumber(colors[4])*value) or "")
end

--Find a color as far from other colors as possible. First input has twice the priority.
--This of course isn't perfect, however it is very quick and will provide adequate results
function libColors.getConflictingColor(...)
	local o = 0
	local first = true
	local totals = {0,0,0}
	for i,v in ipairs(arg) do --parse args
		o = o + 1
		local colors = split(v, " ")
		for n = 1, 3 do --parse colors
			if (tonumber(colors[n]) < 0.5) then --if > 0.5, 0 is furthest, if not, 1 is.
				totals[n] = totals[n] + 1
			end
		end
		if first then
			for n = 1, 3 do totals[n] = totals[n] * 2 end
			first = false
		end
	end
    for n = 1, 3 do totals[n] = totals[n] / (o+1) * 2 end --o+1 because we added the first one twice
	return totals[1] .. " " .. totals[2] .. " " .. totals[3]
end