-- Level Up Panel
local tinsert = table.insert

function registerLevelUpEntry(object, index)
	local container				= object:GetWidget('abilityLevelUpEntry'..index)
	local icon					= object:GetWidget('abilityLevelUpEntry'..index..'Icon')
	local name					= object:GetWidget('abilityLevelUpEntry'..index..'Name')
	local levelLabel		 	= object:GetWidget('abilityLevelUpEntry'..index..'LevelLabel')
	local level				 	= object:GetWidget('abilityLevelUpEntry'..index..'Level')
	local levelHeader			= object:GetWidget('abilityLevelUpEntry'..index..'LevelHeader')
	local cooldownLabel			= object:GetWidget('abilityLevelUpEntry'..index..'CooldownLabel')
	local cooldownIcon			= object:GetWidget('abilityLevelUpEntry'..index..'CooldownIcon')
	local iconSimple			= object:GetWidget('abilityLevelUpEntry'..index..'IconSimple')
	local iconLevelColor		= object:GetWidget('abilityLevelUpEntry'..index..'LVLColorSimple')
	local iconNoColor			= object:GetWidget('abilityLevelUpEntry'..index..'NoColorSimple')
	local iconFrameSimple		= object:GetWidget('abilityLevelUpEntry'..index..'IconFrameSimple')
	local nameSimple			= object:GetWidget('abilityLevelUpEntry'..index..'NameSimple')
	local manaCost				= object:GetWidget('abilityLevelUpEntry'..index..'ManaCost')
	local manaCostSimple		= object:GetWidget('abilityLevelUpEntry'..index..'ManaCostSimple')
	local manaIcon				= object:GetWidget('abilityLevelUpEntry'..index..'ManaIcon')
	local manaIconSimple		= object:GetWidget('abilityLevelUpEntry'..index..'ManaIconSimple')
	local hotkey				= object:GetWidget('abilityLevelUpEntry'..index..'Hotkey')
	local hotkeyParent			= object:GetWidget('abilityLevelUpEntry'..index..'Hotkey_parent')
	local hotkeySimple			= object:GetWidget('abilityLevelUpEntry'..index..'HotkeySimple')
	local hotkeySimpleParent	= object:GetWidget('abilityLevelUpEntry'..index..'HotkeySimple_parent')
	local description			= object:GetWidget('abilityLevelUpEntry'..index..'Description')
	local descriptionSimple		= object:GetWidget('abilityLevelUpEntry'..index..'DescriptionSimple')
	local descriptionArrows		= object:GetWidget('abilityLevelUpEntry'..index..'DescriptionArrowContainer')
	local levelUpButton			= object:GetWidget('abilityLevelUpEntry'..index..'ButtonContainer')
	-- local currentLevelHighlight	= object:GetWidget('abilityLevelUpEntry'..index..'CurrentLevelHighlight')
	-- local nextLevelHighlight	= object:GetWidget('abilityLevelUpEntry'..index..'NextLevelHighlight')
	local canLevelBorder		= object:GetWidget('abilityLevelUpEntry'..index..'CanLevelBorder')
	local panelButton			= object:GetWidget('abilityLevelUpEntry'..index..'PanelButton')
	
	local button				= object:GetWidget('abilityLevelUpEntry'..index..'Button')
	local buttonSimple			= object:GetWidget('abilityLevelUpEntry'..index..'ButtonSimple')
	local frame_1				= object:GetWidget('abilityLevelUpEntry'..index..'_frame_1')
	local frame_2				= object:GetWidget('abilityLevelUpEntry'..index..'_frame_1')
	local simple_frame_1		= object:GetWidget('abilityLevelUpEntry'..index..'_simple_frame_1')
	local simple_frame_2		= object:GetWidget('abilityLevelUpEntry'..index..'_simple_frame_2')
	
	local bg_canLevel			= '#12778a'
	local bg_canLevelHover		= '#00d7ff'
	local bg_withLevels			= '#062b36'
	local bg_cantLevel			= '#010a10'
	local aboveBG_withLevels	= '#268896'
	local aboveBG_cantLevel		= '#133641'

	local function levelUpClick(widget)
		local triggerUnit = LuaTrigger.GetTrigger('HeroUnit')
		PlaySound('/ui/sounds/ui_level_ability.wav', 0.3)
		widget:UICmd("LevelUpAbility("..index..")")
	end
	
	button:SetCallback('onmouseover', function(widget)
		frame_1:SetColor(bg_canLevelHover)
		frame_1:SetBorderColor(bg_canLevelHover)
		UpdateCursor(widget, true, { canLeftClick = true})
	end)
	
	button:SetCallback('onmouseout',  function(widget)
		frame_1:SetColor(bg_canLevel)
		frame_1:SetBorderColor(bg_canLevel)
		UpdateCursor(widget, false, { canLeftClick = true})
	end)	
	
	buttonSimple:SetCallback('onmouseover', function(widget)
		simple_frame_1:SetColor(bg_canLevelHover)
		simple_frame_1:SetBorderColor(bg_canLevelHover)
		simple_frame_2:SetColor('#121111')
		simple_frame_2:SetBorderColor('#121111')
		UpdateCursor(widget, true, { canLeftClick = true})
	end)
	
	buttonSimple:SetCallback('onmouseout',  function(widget)
		simple_frame_1:SetColor(bg_canLevel)
		simple_frame_1:SetBorderColor(bg_canLevel)
		simple_frame_2:SetColor('0 0 0 1')
		simple_frame_2:SetBorderColor('0 0 0 1')
		UpdateCursor(widget, false, { canLeftClick = true})
	end)
	
	button:SetCallback('onclick', levelUpClick)
	
	buttonSimple:SetCallback('onclick', levelUpClick)
	
	button:RefreshCallbacks()
	buttonSimple:RefreshCallbacks()
	
	button:RegisterWatchLua('HeroInventory'..index, function(widget, trigger)
		local canLevelUp = trigger.canLevelUp
		widget:SetEnabled(canLevelUp)
		buttonSimple:SetEnabled(canLevelUp)
	end, false, nil, 'canLevelUp')
	
	if (hotkeyParent) then
		hotkeyParent:RegisterWatchLua('HeroInventory'..index, function(widget, trigger)
			if (trigger.level > 0) then
				widget:FadeIn(250)
			else
				widget:FadeOut(250)
			end
		end, true, nil, 'canLevelUp', 'level')		
	end
	
	if (hotkeySimpleParent) then
		hotkeySimpleParent:RegisterWatchLua('HeroInventory'..index, function(widget, trigger)
			if (trigger.level > 0) then
				widget:FadeIn(250)
			else
				widget:FadeOut(250)
			end
		end, true, nil, 'canLevelUp', 'level')		
	end
	
	frame_1:RegisterWatchLua('HeroInventory'..index, function(widget, trigger)
		if trigger.canLevelUp then
			widget:SetColor(bg_canLevel)
			widget:SetBorderColor(bg_canLevel)
		elseif trigger.level > 0 then
			widget:SetColor(bg_withLevels)
			widget:SetBorderColor(bg_withLevels)
		else
			widget:SetColor(bg_cantLevel)
			widget:SetBorderColor(bg_cantLevel)
		end
	end, true, nil, 'canLevelUp', 'level')		
	
	simple_frame_1:RegisterWatchLua('HeroInventory'..index, function(widget, trigger)
		if trigger.canLevelUp then
			widget:SetColor(bg_canLevel)
			widget:SetBorderColor(bg_canLevel)
		elseif trigger.level > 0 then
			widget:SetColor(bg_withLevels)
			widget:SetBorderColor(bg_withLevels)
		else
			widget:SetColor(bg_cantLevel)
			widget:SetBorderColor(bg_cantLevel)
		end
	end, true, nil, 'canLevelUp', 'level')	
	
	local levelHeadings			= {}
	local levelPips				= {}
	
	for i=1,4,1 do
		levelPips[i] = object:GetWidget('abilityLevelUpEntry'..index..'Level'..i..'Pip')
		levelPips[i]:RegisterWatchLua('HeroInventory'..index, function(widget, trigger)
			widget:SetVisible(i <= trigger.maxLevel)
			if trigger.level >= i then
				widget:SetColor('#00ccff')
			else
				widget:SetColor('#001c23')
			end
		end, false, nil, 'maxLevel', 'level')
	end

	for i=1,4,1 do
		levelHeadings[i] = object:GetWidget('abilityLevelUpEntry'..index..'LevelHeading'..i)
		levelHeadings[i]:RegisterWatchLua('HeroInventory'..index, function(widget, trigger)
			local abilityLevel = trigger.level

			if i <= trigger.maxLevel then
				widget:SetVisible(true)
				
				if trigger.canLevelUp then
					if i <= abilityLevel then
						widget:SetColor(1,1,1)
					else
						widget:SetColor(0.6, 0.6, 0.6)
					end
				else
					widget:SetColor(0.5, 0.5, 0.5)
				end
			else
				widget:SetVisible(false)
			end
		end, true, nil, 'level', 'maxLevel', 'canLevelUp')
	end
	
	local buttonTemplate = 'abilityLevelUpPanelButton2'

	icon:RegisterWatchLua('HeroInventoryAbilityTipDescription'..index, function(widget, trigger) widget:SetTexture(trigger.icon) end)
	iconSimple:RegisterWatchLua('HeroInventoryAbilityTipDescription'..index, function(widget, trigger) widget:SetTexture(trigger.icon) end)
	name:RegisterWatchLua('HeroInventoryAbilityTipDescription'..index, function(widget, trigger) widget:SetText(trigger.name) end)
	nameSimple:RegisterWatchLua('HeroInventoryAbilityTipDescription'..index, function(widget, trigger) widget:SetText(trigger.name) end)
	
	icon:RegisterWatchLua('HeroInventory'..index, function(widget, trigger)
		if trigger.canLevelUp then
			widget:SetRenderMode('normal')
		else
			widget:SetRenderMode('grayscale')
		end
	end, true, nil, 'canLevelUp')	
	
	iconSimple:RegisterWatchLua('HeroInventory'..index, function(widget, trigger)
		if trigger.canLevelUp then
			widget:SetRenderMode('normal')
			iconLevelColor:SetVisible(0)
			iconNoColor:SetVisible(0)
			iconFrameSimple:SetBorderColor('#175d6c')
		elseif trigger.level > 0 then
			widget:SetRenderMode('grayscale')
			iconLevelColor:SetVisible(1)
			iconNoColor:SetVisible(0)
			iconFrameSimple:SetBorderColor('#084552')
		else
			widget:SetRenderMode('grayscale')
			iconLevelColor:SetVisible(0)
			iconNoColor:SetVisible(1)
			iconFrameSimple:SetBorderColor('#022026')
		end
	end, true, nil, 'canLevelUp')	
	
	levelLabel:RegisterWatchLua('HeroInventory'..index, function(widget, trigger)
		widget:SetText(trigger.level..'/'..trigger.maxLevel)
	end, false, nil, 'level', 'maxLevel')
	
	levelLabel:RegisterWatchLua('HeroInventory'..index, function(widget, trigger)
		if trigger.canLevelUp then
			widget:SetColor('1 1 1')
			level:SetColor('#74e3ff')
		elseif trigger.level > 0 then
			widget:SetColor(aboveBG_withLevels)
			level:SetColor('#1b727f')
		else
			widget:SetColor(aboveBG_cantLevel)
			level:SetColor('#0e2c36')
		end
	end, true, nil, 'canLevelUp', 'level')		
	
	cooldownLabel:RegisterWatchLua('HeroInventory'..index, function(widget, trigger)
		local cooldownTime = trigger.cooldownTime
		
		if cooldownTime > 0 then
			widget:SetVisible(true)
			widget:SetText(math.floor(cooldownTime / 1000)..'s')
			cooldownIcon:SetVisible(true)
		else
			widget:SetVisible(false)
			cooldownIcon:SetVisible(false)
		end
		
	end, false, nil, 'cooldownTime')
	
	manaCost:RegisterWatchLua('HeroInventoryAbilityTipDescription'..index, function(widget, trigger)
		local manaCostLabel = math.floor(trigger.manaCost)
		widget:SetText(manaCostLabel)
		manaCostSimple:SetText(manaCostLabel)
	end)
	manaCost:RegisterWatchLua('HeroInventory'..index, function(widget, trigger)
		if trigger.canLevelUp then
			widget:SetColor('#a7e9ff')
			manaCostSimple:SetColor('#a7e9ff')
		elseif trigger.level > 0 then
			widget:SetColor(aboveBG_withLevels)
			manaCostSimple:SetColor(aboveBG_withLevels)
		else
			widget:SetColor(aboveBG_cantLevel)
			manaCostSimple:SetColor(aboveBG_cantLevel)
		end
	end, true, nil, 'canLevelUp')
	
	manaIcon:RegisterWatchLua('HeroInventory'..index, function(widget, trigger)
		if trigger.canLevelUp then
			widget:SetColor('#a7e9ff')
			manaIconSimple:SetColor('#a7e9ff')
		elseif trigger.level > 0 then
			widget:SetColor(aboveBG_withLevels)
			manaIconSimple:SetColor(aboveBG_withLevels)
		else
			widget:SetColor(aboveBG_cantLevel)
			manaIconSimple:SetColor(aboveBG_cantLevel)
		end
	end, true, nil, 'canLevelUp')

	hotkey:RegisterWatchLua('HeroInventoryAbilityTipDescription'..index, function(widget, trigger)
		local keyBind = trigger.keyBind
		widget:SetText(keyBind)
		hotkeySimple:SetText(keyBind)
	end)
	
	libGeneral.createGroupTrigger('heroInventoryStatusDesc'..index, {'HeroInventoryAbilityTipDescription'..index, 'HeroInventory'..index})
	
	local properties				= {}
	local propertiesMax				= 10
	
	-- Given a position in a string, find what color the text is at that position
	local function getLastColorCode(s, pos)
		local extension = string.sub(s, 1, pos):match".*^(.*)"
		if not extension then return "^*" end
		if string.len(extension) >= 3 and tonumber(string.sub(extension, 1, 3)) then return "^" .. string.sub(extension, 1, 3) end
		return "^"..string.sub(extension, 1, 1)
	end
	-- Simply split a string by a separator
	local function split(s, sep)
		local list = {}
		local position = 1
		while (true) do
			local newPosition = string.find(s, sep, position)
			if not newPosition then
				tinsert(list, string.sub(s, position))
				break
			end
			tinsert(list, string.sub(s, position, newPosition-1))
			position = newPosition + 1
		end
		return list
	end
	-- Given a label, returns the actual, (x,y) positions of any and all "\r\r", taking into account text-wrapping.
	-- Note: \r has a special trait - it doesn't wrap, e.g. with 'hello\rworld', the words won't ever be split from text wrapping, but \r still provides a space.
	local function getArrowPositions(widget, str, font)
		-- Params from widget
		font = font or widget:GetFont()
		local width = widget:GetWidth()
		local lineHeight = widget:UICmd("GetFontHeight('"..font.."')")
		local arrowXOffset = -GetScreenHeight()/110
		local arrowYOffset = GetScreenHeight()/648
		
		local positions = {}
		
		-- Split into words
		local wordList = split(str, " ")
		-- Split out the '\n' chars, so we can filter them properly
		local i = 1
		while true do
			local s = wordList[i]
			if not s then break end
			local newLinePos = string.find(s, "\n")
			if (newLinePos) then -- split the word with the new line character into 3 strings X\nY
				wordList[i] = string.sub(s, 1, newLinePos-1)
				tinsert(wordList, i+1, "\n")
				tinsert(wordList, i+2, string.sub(s, newLinePos+1))
				i = i + 1
			end
			i = i + 1
		end
		-- Start working out where all the words would be, taking into account newlines
		local currentString = ""
		local currentLine = 1
		local oldString = currentString
		local n = 1
		while n <= #wordList do
			if (currentString ~= "") then -- Add spaces between words
				currentString = currentString .. " "
			end
			local isNewLine = wordList[n] == "\n"
			-- Add the next word
			oldString = currentString
			if (not isNewLine) then
				currentString = currentString .. wordList[n]
			end
			-- If it doesn't fit, start working on the next line
			if GetStringWidth(font, currentString) > width or isNewLine then
				-- Error: A word is longer than the width! It can't fit. Return an error.
				if not string.find(currentString, " ") and not isNewLine then
					println("^cWarning, word("..currentString..") too long for label("..widget:GetName()..")!")
					return -1
				end
				local arrowPos = string.find(oldString, "\r\r") 
				while (arrowPos) do
					tinsert(positions, {x=GetStringWidth(font, string.sub(currentString, 1, arrowPos))+arrowXOffset, y=lineHeight*(currentLine-1)+arrowYOffset})
					arrowPos = string.find(oldString, "\r\r", arrowPos+2)
				end
				currentString = ""
				currentLine = currentLine + 1
				if not isNewLine then
					n = n - 1 -- Try this word again (unless new line)
				end
			end
			oldString = currentString
			n = n + 1
		end
		local arrowPos = string.find(oldString, "\r\r") 
		while (arrowPos) do
			tinsert(positions, {x=GetStringWidth(font, string.sub(currentString, 1, arrowPos))+arrowXOffset, y=lineHeight*(currentLine-1)+arrowYOffset})
			arrowPos = string.find(oldString, "\r\r", arrowPos+2)
		end
		return positions
	end
	
	local invalidPosition = -1
	-- Given a string and a position in the string, returns whether the position is the start of a number - i.e it isn't the end of another number, unless it is a color code.
	local function isValidNumber(s, pos, toFind)
		if not pos then return false end -- Nil isn't valid.
		if (pos >= invalidPosition and pos <= invalidPosition+11) then return false end -- This position is flagged as invalid - likely because another property has it.
		if (tonumber(string.sub(s, pos-1, pos-1))) and -- There is a number right before it
		  not (tonumber(string.sub(s, pos-3, pos-1)) and string.sub(s, pos-4, pos-4) == "^") then -- And it isn't part of a color code
			return false -- This is the end of another number!
		end
		if (tonumber(string.sub(s, pos+string.len(toFind), pos+string.len(toFind)))) then -- There's number(s) after it
			return false -- This is the start of another number!
		end
		return true
	end
	-- Given a large string and a string to find within it, find the first valid number within it
	local function findNumber(s, toFind)
		toFind = libNumber.round(tonumber(toFind), 1)
		local pos = 0
		repeat
			pos = pos + 1
			pos = string.find(s, toFind, pos)
		until not pos or isValidNumber(s, pos, toFind) -- Validate that this isn't part of another number
		return pos, toFind
	end
	
	description:RegisterWatchLua('heroInventoryStatusDesc'..index, function(widget, groupTrigger)
		local triggerDesc	= groupTrigger[1]
		local triggerStatus	= groupTrigger[2]
		local cooldownTime = 0
		local nextCooldownTime = nil
		descriptionArrows:ClearChildren()
		
		local level = triggerStatus.level
		if triggerStatus.canLevelUp then
			-- Lets put some more info in this description.
			-- Scan the string for properties which we know, and put in a space ('\r\r') for the arrow and the next level's property.
			local s = triggerDesc.description
			local cooldown = triggerStatus.cooldownTime
			invalidPosition = -1
			
			-- Mystic provides damage amp, include this in the number finding. Note that the percent increase is between:
			-- English: the last space, and second to last character
			-- Russian: the last space, and third  to last character
			local mysticAmp = nil
			local mysticTrigger = LuaTrigger.GetTrigger('ActiveInventory16')
			if (mysticTrigger.entity == "Ability_Mystik_Passive_2") then
				local splitTable = split(mysticTrigger.description, " ")
				local amp = tonumber(string.sub(splitTable[#splitTable], 1, -2))
				if not amp then amp = tonumber(string.sub(splitTable[#splitTable], 1, -3)) end
				if amp then mysticAmp = 1 + amp/100 end
			end
			
			if (level ~= 0) then -- Try to show what happens on levelup
				for n = 1, 2 do
					if (properties[n].name:GetText() == "-") then break end -- For skills with < 2 properties
					local toFind = tonumber(properties[n].values[level]:GetText())
					local nextProperty = tonumber(properties[n].values[level+1]:GetText())
					if (properties[n].name:GetText() == "Cooldown Time") then  -- Grabs cooldowns for use later
						cooldownTime = toFind
						nextCooldownTime = nextProperty
					elseif (toFind ~= nextProperty) then
						-- Try to find the property in the string, but check a few things. We want it to actually be the correct position, not a part of another property.
						
						-- It's possible that the property is increased by power.. try that first.
						local powerMultiplier = LuaTrigger.GetTrigger("HeroUnit").power/100
						local powerToFind = toFind * powerMultiplier
						
						-- Try to find the power-enhanced number
						local pos = findNumber(s, powerToFind)
						-- Try to find the power-enhanced, mystic enhanced number
						if not pos and mysticAmp then 
							pos, powerToFind = findNumber(s, powerToFind * mysticAmp)
						end
						
						if not pos then -- It doesn't seem to be boosted by power. Lets find the normal one
							-- Try to find the normal number
							pos = findNumber(s, toFind)
							if not pos and mysticAmp then
								pos, toFind = findNumber(s, toFind * mysticAmp)
							end
						else -- It is boosted by power. Boost the next level text too.
							toFind = powerToFind
							nextProperty = nextProperty * powerMultiplier
						end
						toFind = libNumber.round(tonumber(toFind), 1)
						nextProperty = libNumber.round(tonumber(nextProperty), 1)
						
						if pos then
							-- We have found our property in the description, inject our next level's properties, while maintaining the color
							local color = getLastColorCode(s, pos)
							s = string.sub(s, 1, pos-1) .. toFind .. "^*(\r\r" .. color .. nextProperty .. "^*)" .. color .. string.sub(s, pos+ string.len(toFind))
							invalidPosition = pos
						end
					end
				end
			end
			
			-- Grab the arrow positions ('\r\r') for our description when constrained by our widget
			local arrowPositions = getArrowPositions(descriptionSimple, s)
			
			if arrowPositions ~= -1 then 
				-- Create the arrows
				for i = 1, #arrowPositions do
					descriptionArrows:Instantiate('abilityLevelUpEntryArrowTemplate', 'x', arrowPositions[i].x, 'y', arrowPositions[i].y)
				end
			end
			
			widget:SetText(s)
			descriptionSimple:SetText(s)
		else
			for n = 1, 2 do
				if (properties[n].name:GetText() == "Cooldown Time" and level > 0) then  -- Grabs cooldowns
					cooldownTime = tonumber(properties[n].values[level]:GetText())
				end
			end
			widget:SetText(StripColorCodes(triggerDesc.description))
			descriptionSimple:SetText(StripColorCodes(triggerDesc.description))
		end
		
		-- Render the cooldown and next cooldown change if there is one.
		if cooldownTime > 0 then
			cooldownLabel:SetVisible(true)
			local cooldownString = cooldownTime..'s'
			if (triggerStatus.level > 0 and nextCooldownTime ~= nil) then
				cooldownString = cooldownString .. "     "..nextCooldownTime..'s'
				descriptionArrows:Instantiate('abilityLevelUpEntryArrowTemplate', 'x', "-6.75h", 'y', "8.5h")
			end
			cooldownLabel:SetText(cooldownString)
			cooldownIcon:SetVisible(true)
		end
		
	end)
	

	for i=1,propertiesMax,1 do
		properties[i]	= {
			row		= object:GetWidget('abilityLevelUpEntry'..index..'PropertyRow'..i),
			-- rule	= object:GetWidget('abilityLevelUpEntry'..index..'Property'..i..'HorizRule'),
			name	= object:GetWidget('abilityLevelUpEntry'..index..'Property'..i..'Name'),
			values	= {}
		}
		properties[i].name:RegisterWatchLua('HeroInventory'..index, function(widget, trigger)
			if trigger.canLevelUp then
				widget:SetColor(1,1,1)
			else
				widget:SetColor(0.5,0.5,0.5)
			end
		end, false, nil, 'canLevelUp')
		for j=1,4,1 do
			properties[i].values[j]	= object:GetWidget('abilityLevelUpEntry'..index..'Property'..i..'Value'..j)
			properties[i].values[j]:RegisterWatchLua('HeroInventory'..index, function(widget, trigger)
				local abilityLevel = trigger.level
				if j <= trigger.maxLevel then
					widget:SetVisible(true)
					if trigger.canLevelUp then
						if j == abilityLevel then
							widget:SetColor(0,1,0)
						elseif j > abilityLevel then
							widget:SetColor(0.6, 0.6, 0.6)
						else
							widget:SetColor(1,1,1)
						end
					else
						widget:SetColor(0.5,0.5,0.5)
					end
				else
					widget:SetVisible(false)
				end
			end, true, nil, 'level', 'maxLevel', 'canLevelUp')
		end
	end
	
	container:RegisterWatchLua('HeroInventory'..index, function(widget, trigger)
		if trigger.canLevelUp then
			description:SetColor(1,1,1)
			descriptionSimple:SetColor(1,1,1)
			cooldownLabel:SetColor(1,1,1)
			name:SetColor(1,1,1)
			nameSimple:SetColor(1,1,1)
			levelHeader:SetColor(1,1,1)
			
			for i=1,4,1 do
				levelHeadings[i]:SetColor(1,1,1)
			end
		elseif trigger.level > 0 then
			description:SetColor(aboveBG_withLevels)
			descriptionSimple:SetColor(aboveBG_withLevels)
			cooldownLabel:SetColor(aboveBG_withLevels)
			name:SetColor(aboveBG_withLevels)
			nameSimple:SetColor(aboveBG_withLevels)
			levelHeader:SetColor(aboveBG_withLevels)

			for i=1,4,1 do
				levelHeadings[i]:SetColor(aboveBG_withLevels)
			end
		else
			description:SetColor(aboveBG_cantLevel)
			descriptionSimple:SetColor(aboveBG_cantLevel)
			cooldownLabel:SetColor(aboveBG_cantLevel)
			name:SetColor(aboveBG_cantLevel)
			nameSimple:SetColor(aboveBG_cantLevel)
			levelHeader:SetColor(aboveBG_cantLevel)

			for i=1,4,1 do
				levelHeadings[i]:SetColor(aboveBG_cantLevel)
			end
		end
	end, false, nil, 'canLevelUp')
	
	container:RegisterWatchLua('HeroInventoryAbilityTipProperties'..index, function(widget, trigger)
		local propertyIndex = 1
		local valueIndex = 1
		local lastIndex = 0
		local index = 1
	
		for i=1,propertiesMax,1 do
			properties[i].values[4]:SetVisible(false)
		end
	
		while index <= #trigger do
			-- propertyTable:SetVisible(true)

			properties[propertyIndex].row:SetVisible(true)
			-- properties[propertyIndex].rule:SetVisible(true)
			properties[propertyIndex].name:SetText(trigger[index])
			
			valueCount = trigger[index + 1]
			index = index + 2
			for i=1, valueCount do
				lastIndex = propertyIndex
				properties[propertyIndex].row:SetVisible(true)
				properties[propertyIndex].values[i]:SetText(libNumber.round(trigger[index], 2))
				properties[propertyIndex].values[i]:SetVisible(true)
				index = index + 1
			end
			
			propertyIndex = propertyIndex + 1
		end

		if lastIndex == 0 then
			-- propertyTable:SetVisible(false)
		else
			for i = lastIndex + 1, #properties do
				properties[i].row:SetVisible(false)
				-- properties[i].rule:SetVisible(false)
			end
		end
	end)

	LuaTrigger.GetTrigger('HeroInventoryAbilityTipProperties'..index):Trigger()
	LuaTrigger.GetTrigger('HeroInventoryAbilityTipDescription'..index):Trigger()
end

function registerLevelUpPanel(object)
	local container				= object:GetWidget('levelUpPanel')
	local pointsLeft			= object:GetWidget('levelUpPanelPointsLeft')
	local currentLevel			= object:GetWidget('levelUpPanelCurrentLevel')
	local buttonContainer		= object:GetWidget('abilityLevelUpButtonPos')
	
	container:RegisterWatchLua('gamePanelInfo', function(widget, trigger)
		widget:SetVisible(trigger.abilityPanel)
	end, false, nil, 'abilityPanel')
	
	pointsLeft:RegisterWatchLua('HeroUnit', function(widget, trigger) widget:SetText(trigger.availablePoints) end, true, nil, 'availablePoints')
	currentLevel:RegisterWatchLua('HeroUnit', function(widget, trigger) widget:SetText(Translate('game_level', 'level', trigger.level)) end, true, nil, 'level')

	local keysActivate		= {}
	local keysLevel			= {}

	for i=0,3,1 do
		keysActivate[i] = GetKeybindButton('Game', 'ActivateTool', i)
		keysLevel[i]	= GetKeybindButton('Game', 'LevelupAbility', i)
	end
	
	
	local viewButtonSimple		= object:GetWidget('levelUpPanelViewButtonSimple')
	local viewButtonDetailed	= object:GetWidget('levelUpPanelViewButtonDetailed')
	
	local viewButtonSimpleLabel		= object:GetWidget('levelUpPanelViewButtonSimpleLabel')
	local viewButtonDetailedLabel	= object:GetWidget('levelUpPanelViewButtonDetailedLabel')

	local viewButtonSimpleBacker		= object:GetWidget('levelUpPanelViewButtonSimpleBacker')
	local viewButtonDetailedBacker		= object:GetWidget('levelUpPanelViewButtonDetailedBacker')

	local listSimple			= object:GetWidget('levelUpPanelListSimple')
	local listDetailed			= object:GetWidget('levelUpPanelListDetailed')

	viewButtonSimpleLabel:RegisterWatchLua('gamePanelInfo', function(widget, trigger)
		if trigger.abilityPanelView == 0 then
			widget:SetColor(1,1,1)
		else
			widget:SetColor(0.7, 0.7, 0.7)
		end
	end, false, nil, 'abilityPanelView')

	viewButtonDetailedLabel:RegisterWatchLua('gamePanelInfo', function(widget, trigger)
		if trigger.abilityPanelView == 1 then
			widget:SetColor(1,1,1)
		else
			widget:SetColor(0.7, 0.7, 0.7)
		end
	end, false, nil, 'abilityPanelView')
	

	viewButtonSimpleBacker:RegisterWatchLua('gamePanelInfo', function(widget, trigger)
		if trigger.abilityPanelView == 0 then
			widget:SetRenderMode('normal')
		else
			widget:SetRenderMode('grayscale')
		end
	end, false, nil, 'abilityPanelView')
	viewButtonDetailedBacker:RegisterWatchLua('gamePanelInfo', function(widget, trigger)
		if trigger.abilityPanelView == 1 then
			widget:SetRenderMode('normal')
		else
			widget:SetRenderMode('grayscale')
		end
	end, false, nil, 'abilityPanelView')
	
	
	listSimple:SetVisible(1)
	-- listDetailed:RegisterWatchLua('gamePanelInfo', function(widget, trigger) widget:SetVisible(trigger.abilityPanelView == 1) end, false, nil, 'abilityPanelView')
	
	viewButtonSimple:SetCallback('onclick', function(widget)
		local triggerInfo = LuaTrigger.GetTrigger('gamePanelInfo')
		triggerInfo.abilityPanelView = 0
		Cvar.GetCvar('_abilityPanelView'):Set(0)
		triggerInfo:Trigger(false)
	end)
	
	viewButtonDetailed:SetCallback('onclick', function(widget)
		local triggerInfo = LuaTrigger.GetTrigger('gamePanelInfo')
		triggerInfo.abilityPanelView = 1
		Cvar.GetCvar('_abilityPanelView'):Set(1)
		triggerInfo:Trigger(false)
	end)
	
	local function abilityKeySwap()

	end
	
	local function abilityKeyUnswap()

	end

	local openButton			= object:GetWidget('abilitiesLevelUpButton')
	local openButtonKey			= object:GetWidget('abilitiesLevelUpButtonKey')
	local openButtonKeyButton	= object:GetWidget('abilitiesLevelUpButtonKeyButton')
	local openButtonKeyBacker	= object:GetWidget('abilitiesLevelUpButtonKeyBacker')

	libGeneral.createGroupTrigger('levelUpButtonContainerVis', {'HeroUnit.availablePoints', 'gamePanelInfo.gameMenuExpanded'})
	
	buttonContainer:RegisterWatchLua('levelUpButtonContainerVis', function(widget, groupTrigger) 
		local heroUnit = groupTrigger['HeroUnit']
		local gamePanelInfo = groupTrigger['gamePanelInfo']
		
		-- widget:SetVisible((heroUnit.availablePoints > 0) and (not gamePanelInfo.gameMenuExpanded))
		
		if heroUnit.availablePoints > 0 then
			widget:FadeIn(200)
		else
			widget:FadeOut(150)
		end
	end)
	
	-- buttonContainer:RegisterWatchLua('gamePanelInfo', function(widget, trigger)
		-- if trigger.goldSplashVisible then
			-- widget:SlideY('-11.5h', styles_uiSpaceShiftTime)
		-- else
			-- widget:SlideY('-5.5h', styles_uiSpaceShiftTime)
		-- end
	-- end, false, nil, 'goldSplashVisible')

	openButton:SetCallback('onclick', function(widget)
		gameToggleShowSkills(widget)
	end)
	
	openButtonKeyButton:SetCallback('onmouseover', function(widget)
		simpleTipNoFloatUpdate(true, nil, Translate('game_keybind_1'), Translate('game_keybind_2', 'value', GetKeybindButton('game', 'TriggerToggle', 'gameShowMoreInfo', 0)), nil, nil, libGeneral.HtoP(-18), 'center', 'bottom')
		UpdateCursor(widget, true, { canLeftClick = true})
	end)
	
	openButtonKeyButton:SetCallback('onmouseout', function(widget)
		simpleTipNoFloatUpdate(false)
		UpdateCursor(widget, false, { canLeftClick = true})
	end)	
	
	openButtonKeyButton:SetCallback('onclick', function(widget)
		local tabDown = LuaTrigger.GetTrigger('ModifierKeyStatus').moreInfoKey

		if not tabDown then
			gameToggleShowSkills(widget)
		else
			PlaySound('/ui/sounds/sfx_button_generic.wav')

			local binderData			= LuaTrigger.GetTrigger('buttonBinderData')
			local oldButton				= nil
			binderData.allowMoreInfoKey	= false
			binderData.show				= true
			binderData.table			= 'game'
			binderData.action			= 'TriggerToggle'
			binderData.param			= 'gameShowSkills'
			binderData.keyNum			= 0	-- 0 for leftclick, 1 for rightclick
			binderData.impulse			= false
			binderData.oldButton		= (GetKeybindButton('game', 'TriggerToggle', 'gameShowSkills', 0) or 'None')
			binderData:Trigger()
		end
	end)
	
end

registerLevelUpPanel(object)

for i=0,3,1 do
	registerLevelUpEntry(object, i)
end