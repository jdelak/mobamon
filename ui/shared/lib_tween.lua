--[[
	Tweening library

	Tweening functions based on Robert Penner's tween equations
	http://www.robertpenner.com/easing/penner_chapter7_tweening.pdf

	For reference (or if shorter variable names are a performance boost here as well), the initial variable names are as follows:
	t		positionCurrent (start at 0, basically always a portion of positionEnd)
	b		valueStart
	c		valueChange (basically how much to add to valueStart based on how far the tween is)
	d		positionEnd (final value that positionCurrent is trying to achieve as part of the tween)
	a		amplitude
	p		period
--]]

libTween = {
	linear = function(positionCurrent, valueStart, valueChange, positionEnd)
		return valueChange * positionCurrent / positionEnd + valueStart
	end,
	easeInQuad = function(positionCurrent, valueStart, valueChange, positionEnd)
		local positionCurrentByPositionEnd = positionCurrent / positionEnd
		return valueChange * positionCurrentByPositionEnd * positionCurrent + valueStart
	end,
	easeOutQuad = function(positionCurrent, valueStart, valueChange, positionEnd)
		local positionCurrentByPositionEnd = positionCurrent / positionEnd
		return (valueChange * -1) * positionCurrentByPositionEnd * (positionCurrent - 2) + valueStart
	end,
	easeInOutQuad = function(positionCurrent, valueStart, valueChange, positionEnd)
		local positionCurrentByPositionEnd = positionCurrent / (positionEnd / 2)
		local positionCurrentDecrement = positionCurrentByPositionEnd - 1
		if (positionCurrentByPositionEnd) < 1 then
			return valueChange / 2 * positionCurrentByPositionEnd * positionCurrentByPositionEnd + valueStart
		end
		return (valueChange * -1) / 2 * (positionCurrentDecrement * (positionCurrentDecrement - 2) - 1) + valueStart
	end,
	easeInCubic = function(positionCurrent, valueStart, valueChange, positionEnd)
		return valueChange * math.pow(positionCurrent / positionEnd, 3) + valueStart
	end,
	easeOutCubic = function(positionCurrent, valueStart, valueChange, positionEnd)
		return valueChange * (math.pow(positionCurrent / positionEnd - 1, 3) + 1) + valueStart
	end,
	easeInOutCubic = function(positionCurrent, valueStart, valueChange, positionEnd)
		local positionCurrentByPositionEnd = positionCurrent / (positionEnd / 2)
		local positionCurrentDecrement = positionCurrentByPositionEnd - 2
		if positionCurrentByPositionEnd < 1 then
			return valueChange / 2 * math.pow(positionCurrentByPositionEnd, 3) + valueStart
		end
		return valueChange / 2 * (math.pow(positionCurrentDecrement, 3) + 2) + valueStart
	end,
	easeInQuartic = function(positionCurrent, valueStart, valueChange, positionEnd)
		return valueChange * math.pow(positionCurrent / positionEnd, 4) + valueStart
	end,
	easeOutQuartic = function(positionCurrent, valueStart, valueChange, positionEnd)
		return (valueChange * -1) * (math.pow(positionCurrent / positionEnd - 1, 4) - 1) + valueStart
	end,
	easeInOutQuartic = function(positionCurrent, valueStart, valueChange, positionEnd)	-- Ends at 0.5
		local positionCurrentByPositionEnd = positionCurrent / (positionEnd / 2)
		local positionCurrentDecrement = positionCurrentByPositionEnd - 2
		if positionCurrentByPositionEnd < 1 then
			return valueChange / 2 * math.pow(positionCurrentByPositionEnd, 4) + valueStart
		end
		return (valueChange * -1) / 2 * (math.pow(positionCurrentDecrement, 4) - 2) + valueStart
	end,
	easeOutElastic = function(positionCurrent, valueStart, valueChange, positionEnd, amplitude, period)
		local unknownNum3 = nil	-- S
		local positionCurrentByPositionEnd = positionCurrent / positionEnd
		if positionCurrent == 0 then
			return valueStart
		end
		if positionCurrentByPositionEnd == 1 then
			return valueStart + valueChange
		end
		if not period then
			period = positionEnd * 0.3
		end

		if not amplitude or amplitude < math.abs(valueChange) then
			amplitude = valueChange
			unknownNum3 = period / 4
		else
			unknownNum3 = period / (2 * math.pi) * math.asin(valueChange / amplitude)
		end
		return amplitude * math.pow(2, -10 * positionCurrentByPositionEnd) * math.sin((positionCurrentByPositionEnd * positionEnd - unknownNum3) * (2 * math.pi) / period) + valueChange + valueStart
	end,
	easeInOutElastic = function(positionCurrent, valueStart, valueChange, positionEnd, amplitude, period)	-- Need fix
		local unknownNum3 = nil	-- S
		local positionCurrentByPositionEnd = positionCurrent / (positionEnd / 2)
		local positionCurrentDecrement = positionCurrentByPositionEnd - 1
		if positionCurrent == 0 then
			return valueStart
		end
		if positionCurrentByPositionEnd == 2 then
			return valueStart + valueChange
		end
		if not period then
			period = positionEnd * 0.45 -- (.3*1.5)
		end

		if not amplitude or amplitude < math.abs(valueChange) then
			amplitude = valueChange
			unknownNum3 = period / 4
		else
			unknownNum3 = period / (2 * math.pi) * math.asin(valueChange / amplitude)
		end
		if positionCurrentByPositionEnd < 1 then
			return -0.5 * (amplitude * math.pow(2, 10 * positionCurrentDecrement) * math.sin( (positionCurrentDecrement * positionEnd - unknownNum3) * (2 * math.pi) / period)) + valueStart;
		end

		return amplitude * math.pow(2, -10 * positionCurrentDecrement) * math.sin( (positionCurrentDecrement * positionEnd - unknownNum3) * (2 * math.pi) / period ) * 0.5 + valueChange + valueStart;
	end
	
}