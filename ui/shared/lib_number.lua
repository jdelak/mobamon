-- Number manipulation and formatting

libNumber = {
	round = function(input, precision)
		-- return math.floor((input * 10 ^ precision) + 0.5) / (10 ^ precision) -- refuses to actually round to the target precision in certain cases (not sure why atm)
		-- return tonumber(string.format("%." .. (precision or 0) .. "f", input))
		return FtoA2(tonumber(input), 0, precision)
	end,	
	isInt = function(input)
		return (type(input) == 'number' and (math.floor(input) == input))
	end,
	isFloat = function(input)
		return (type(input) == 'number' and (not libNumber.isInt(input)))
	end,	
	commaFormat = function(input, precision)	-- Rounds number and adds commas.  Accepts number or string
		local rounded = FtoA2(tonumber(input), 0, precision)

		local result = ""
		local sign, before, after = string.match (tostring (rounded), "^([%+%-]?)(%d*)(%.?.*)$")

		while string.len (before) > 3 do
			result = ','..string.sub (before, -3, -1)..result
			before = string.sub (before, 1, -4)
		end

		return sign .. before .. result .. after
	end,
	
	timeFormat = function(inputTimeMS)	-- Convert MS to a string representing an amount of time (up to hours, anyways)
		
		if (inputTimeMS < 0) then
			return '00:00'
		end
		
		local rangeHours = 0
		local rangeMinutes = 0
		local rangeSeconds = 0
		local rangeDays = 0
		local inputTimeSeconds = math.ceil(inputTimeMS / 1000)
		local timeString = ''

		rangeDays = math.floor(inputTimeSeconds / (3600 * 24))
		inputTimeSeconds = inputTimeSeconds - (rangeDays * (3600 * 24))
		
		rangeHours = math.floor(inputTimeSeconds / 3600)
		inputTimeSeconds = inputTimeSeconds - (rangeHours * 3600)
		
		rangeMinutes = math.floor(inputTimeSeconds / 60)
		inputTimeSeconds = inputTimeSeconds - (rangeMinutes * 60)
		
		rangeSeconds = inputTimeSeconds

		if rangeDays > 0 then
			timeString = timeString .. rangeDays..'d '
		end
		
		if rangeHours > 0 then
			timeString = timeString .. rangeHours..':'
		end
		
		if rangeMinutes > 0 then
			if rangeMinutes < 10 then
				timeString = timeString .. rangeMinutes
			else
				timeString = timeString .. rangeMinutes
			end	
		else
			timeString = timeString .. '00'
		end
		
		if rangeSeconds > 0 then
			if rangeSeconds < 10 then
				timeString = timeString .. ':0' .. rangeSeconds
			else
				timeString = timeString .. ':' .. rangeSeconds
			end	
		else
			timeString = timeString .. ':00'
		end		

		return timeString
	end,
	
	bitShiftL = function(x, by)
	  return x * 2 ^ by
	end,

	bitShiftR = function(x, by)
	  return math.floor(x / 2 ^ by)
	end
}