---------------------------------------------------------- 		
--  Copyright 2013 S2 Games								--
----------------------------------------------------------

local _G = getfenv(0)
local ipairs, pairs, select, string, table, next, type, unpack, tinsert, tconcat, tremove, format, tostring, tonumber, tsort, ceil, floor, sub, find, gfind = _G.ipairs, _G.pairs, _G.select, _G.string, _G.table, _G.next, _G.type, _G.unpack, _G.table.insert, _G.table.concat, _G.table.remove, _G.string.format, _G.tostring, _G.tonumber, _G.table.sort, _G.math.ceil, _G.math.floor, _G.string.sub, _G.string.find, _G.string.gfind
local print  =_G['print']
local interface, interfaceName = object, object:GetName()
local delayedFunctionTable = {}
local GetTrigger = LuaTrigger.GetTrigger
mainUI = mainUI or {}
mainUI.savedLocally 	= mainUI.savedLocally 		or {}
mainUI.savedRemotely 	= mainUI.savedRemotely 		or {}
mainUI.savedAnonymously	= mainUI.savedAnonymously 	or {}
mainUI.savedLocally.downVoteList 	= mainUI.savedLocally.downVoteList 	or {}

-- interface:GetWidget('main_animator'):Sleep(100, function()
	
	-- GetMatchStats('447.002')
	
	-- interface:GetWidget('main_animator'):Sleep(1000, function()
		-- CloseRewardsPrompt(interface)
	-- end)
-- end)

table = table or {}
function table.pack(...)
	return { n = select("#", ...), ... }
end

function println(stringVar)
	print(tostring(stringVar)..'\n')
end

function e(stringVar, stringVal)
	print('^rError: ' .. tostring(stringVar)..' | ' .. tostring(stringVal) .. '\n')
end

function groupfcall(groupName, functionArg, fromInterface)
	--println('^o groupfcall looking for: ' .. tostring(groupName) .. ' in interface ' .. tostring(fromInterface)..' \n')
	local groupTable
	if (fromInterface) then
		groupTable = UIManager.GetInterface(fromInterface):GetGroup(groupName)
	else
		groupTable = interface:GetGroup(groupName)
	end	
	if (groupTable) then
		for index, widget in ipairs(groupTable) do
			functionArg(index, widget, groupName)
		end 
	else
		--println('^o groupfcall could not find: ' .. tostring(groupName) .. ' in interface ' .. tostring(fromInterface)..' \n')
	end	
end

function round(num, idp)
	local num = tonumber(num)
	if (num) and type(num) == 'number' then
		return tonumber(format("%." .. (idp or 0) .. "f", num))
	else
		return nil
	end
end

function animateChildren(widget, intro, recurse, exclude, delay)
	local exclude = exclude or {}
	local delay = delay or styles_mainSwapAnimationDuration
	for index, child in pairs(widget:GetChildren()) do
		if child:IsValid() and not IsInTable(exclude, child:GetName()) then
			if recurse and child:GetType() == 'panel' then
				animateChildren(child, intro, true, exclude)
			else
				RegisterRadialEase(child, nil, nil, true)
				libThread.threadFunc(function()
					child:DoEventN(intro and 7 or 8)
				end)
			end
		end
	end
	libThread.threadFunc(function()
		wait(delay/2)
		fadeWidget(widget, intro, delay/2)
	end)
end

function AnimatedLabelIncrease(labelWidget, incCurrentValue, incLastValue)
	local valueAdd = incCurrentValue - incLastValue
	local lastValue = incLastValue
	local valueStart = incLastValue
	local animType = math.max(500, math.min(2000, (incCurrentValue * 1)))
	libAnims.customTween(
		labelWidget, animType,
		function(posPercent)

			local newValue = math.floor(valueStart + (valueAdd * posPercent))
			if newValue > lastValue then
				-- Purchase gem sound 
				-- PlaySound('/ui/sounds/rewards/sfx_tally_oneshot.wav')
				lastValue = newValue
			end
			labelWidget:SetText(libNumber.commaFormat(newValue))
		end
	)	
end

function AnimatedLabelDecrease(labelWidget, incCurrentValue, incLastValue)
	local valueSubtract = incLastValue - incCurrentValue
	local lastValue = incLastValue
	local valueStart = incLastValue
	local animType = math.max(500, math.min(2000, (valueSubtract * 1)))
	libAnims.customTween(
		labelWidget, animType,
		function(posPercent)
			local newValue = math.floor(valueStart - (valueSubtract * posPercent))
			if newValue < lastValue then
				lastValue = newValue
			end
			labelWidget:SetText(libNumber.commaFormat(newValue))
		end
	)	
end

function IsInTable(checkTable, input, returnParentTable)
	local isIt = false
	if checkTable and type(checkTable) == 'table' then
		for k,v in pairs(checkTable) do
			if type(v) == 'table' then
				isIt = IsInTable(v, input, returnParentTable)
				if (isIt) then
					break
				end
			elseif v == input then
				isIt = true
				if returnParentTable then
					isIt = checkTable
				end
				break
			end
		end
	end
	return isIt
end

function RandomUniqueNumbers(minimum, maximum, count)
	local randomNumbers = {}
	while (count > 0) do
		local randomNumber = math.random(minimum, maximum)
		if (not IsInTable(randomNumbers, randomNumber)) then
			table.insert(randomNumbers, randomNumber)
			count = count - 1
		end
	end
	return randomNumbers
end


function RemoveFriendsFromRecentlyPlayed()
	if (mainUI.savedRemotely.recentlyPlayedWith) then
		for i, v in pairs(mainUI.savedRemotely.recentlyPlayedWith) do
			if ChatClient.IsFriend(v.identID or '') then
				table.remove(mainUI.savedRemotely.recentlyPlayedWith, i)
			end
		end
		while (#mainUI.savedRemotely.recentlyPlayedWith > 20) do
			table.remove(mainUI.savedRemotely.recentlyPlayedWith, 1)
		end
	end
end

function FormatTimeUntil(endTime, nowTime, incFormatString)
	local formatString = incFormatString or '%#I:%M %p %B %d, %Y'
	local System	= LuaTrigger.GetTrigger('System')
	nowTime = nowTime or System.unixTimestamp
	
	local formattedEndTime, remainingSeconds, formattedRemaining	= 0,0,0
	
	if (not endTime) or (not tonumber(endTime)) then
		return -1, -1, -1
	end

	formattedEndTime = FormatDateTime(endTime, formatString, true)
	
	if (endTime > nowTime) then
		remainingSeconds = endTime - nowTime
		formattedRemaining = libNumber.timeFormat(remainingSeconds * 1000)
	else
		remainingSeconds = 0
		formattedRemaining = 0
	end
	
	return formattedEndTime, formattedRemaining, remainingSeconds
	
end

function AddRecentlyPlayedWith(displayName, uniqueID, identID, groupName)
	mainUI = mainUI or {}
	mainUI.savedRemotely.recentlyPlayedWith = mainUI.savedRemotely.recentlyPlayedWith or {}					

	if (not IsInTable(mainUI.savedRemotely.recentlyPlayedWith, identID)) and (not ChatClient.IsFriend(identID)) and (not IsMe(identID)) then
		table.insert(mainUI.savedRemotely.recentlyPlayedWith, {
			icon		= '/ui/shared/textures/user_icon.tga',
			type		= 'user',
			name		= displayName,
			uniqueID	= uniqueID or '????',
			identID		= identID,
			buddyGroup	= groupName or Translate('general_strife_beta') 					
		})
	end

	RemoveFriendsFromRecentlyPlayed()
end

function LeaveParty()
	local partyStatusTrigger 		= LuaTrigger.GetTrigger('PartyStatus')
	if (partyStatusTrigger.inParty) then
		println('^y LeaveParty() ')
		ChatClient.LeaveParty()
	end
	Cmd('Unready')
end

function LeaveGameLobby(dontUnready)
	--println('^y LeaveGameLobby() ')
	Disconnect()
	if (not dontUnready) then
		Cmd('Unready')
		LeaveParty()
	end
	ChatClient.LeaveGame()
	local mainPanelStatus = GetTrigger('mainPanelStatus')
	if (mainPanelStatus.main == 40)	or (mainPanelStatus.main == 12) or (mainPanelStatus.main == 24) then
		libThread.threadFunc(function()			
			wait(styles_mainSwapAnimationDuration / 3)
			local mainPanelStatus = GetTrigger('mainPanelStatus')
			if GetCvarBool('ui_PAXDemo') then
				mainPanelStatus.main	= 1001 
			else
				mainPanelStatus.main	= 101 
			end
			mainPanelStatus:Trigger(true)		
		end)	
	end
end

function GetCatPicture(sourceWidget)
	-- sourceWidget:SetTextureURL('http://thecatapi.com/api/images/get?format=src&size=full')
	-- sourceWidget:SetTextureURL('http://lorempixel.com/400/200/')
	sourceWidget:SetTextureURL('http://lorempixel.com/' .. round(sourceWidget:GetWidth()) .. '/' .. round(sourceWidget:GetHeight()) .. '/?p=' .. math.random(1,100000) .. '/')
	-- sourceWidget:SetTextureURL('http://lorempixel.com/128/128?p=' .. math.random(1,100000) .. '/')
	-- sourceWidget:SetTextureURL('http://lorempixel.com/512/256/cats/p' .. math.random(1,100000) .. '/')
	-- sourceWidget:SetTextureURL('http://lorempixel.com/512/256/cats/')
	-- sourceWidget:SetTextureURL('http://placekitten.com/512/256/'..math.random(1,100000))
	-- Script "GetWidget('mainBG', 'main'):SetTextureURL('http://lorempixel.com/512/256/cats/p' .. math.random(1,100000) .. '/') GetWidget('mainBGWheel_parent'):SetVisible(0)"
end

function GetSliderPicture(sourceWidget, index)
	sourceWidget:SetTextureURL('http://lorempixel.com/512/256/animals/?p=' .. index .. '/')
end

function implode2(tableIn, delimiter1)

	local delimiter1 = delimiter1 or '~'
	local stringOut = ''
	
	local function subImplode(stringOut, delimiter)
		local stringOut2
		for i, v in pairs(stringOut) do
			if (stringOut2) then
				stringOut2 = (stringOut2 .. delimiter .. tostring(v))
			else
				stringOut2 = tostring(v)
			end
		end
		return stringOut2
	end

	stringOut = subImplode(tableIn, delimiter1)

	return stringOut
end

function implode(tableIn, delimiter1, delimiter2, delimiter3)

	local delimiter1 = delimiter1 or '~'
	local delimiter2 = delimiter2 or '|'
	local delimiter3 = delimiter3 or '!'

	local stringOut = ''
	
	local function subImplode(stringOut, delimiter)
		local stringOut2
		for i, v in pairs(stringOut) do
			if (stringOut2) then
				stringOut2 = (stringOut2 .. delimiter .. tostring(i) .. delimiter3 .. tostring(v) )
			else
				stringOut2 = tostring(i) .. delimiter3 .. tostring(v)
			end
		end
		return stringOut2
	end
	
	for i,v in pairs(tableIn) do
		if (type(v) == 'table') then
			v = subImplode(v, delimiter2)
		end
	end

	stringOut = subImplode(tableIn, delimiter1)

	return stringOut
end

function explode(d,p)
	if (d) and (p) and (type(p) == 'string') then
		  local t, ll
		  t={}
		  ll=0
		  if(#p == 1) then return {p} end
			while true do
			  l=find(p,d,ll,true) 
			  if l~=nil then 
				tinsert(t, sub(p,ll,l-1))
				ll=l+1 
			  else
				tinsert(t, sub(p,ll))
				break 
			  end
			end
		  return t
	else
		println('Explode error d: ' .. tostring(d) .. ' in ' .. tostring(p))
	end
end

function implodeTable(tableIn)
	
	-- println(' ')
	-- println('implodeTable')
	-- printr(tableIn)
	
	local stringOut = ''
	
	local function GetDelimiter(index)
		local delimiter = '!'
		for x = 1, index, 1 do
			delimiter = delimiter .. '~'
		end
		delimiter = delimiter .. '!'
		return delimiter
	end
	
	local function GetDelimiter2(index)
		local delimiter = '|'
		for x = 1, index, 1 do
			delimiter = delimiter .. '~'
		end		
		delimiter = delimiter .. '|'
		return delimiter
	end	
	
	local function implode2(index, input, output)
		for i,v in pairs(input) do
			if (not (string.find(i, 'strife_db_main_ui_state'))) and (not (string.find(i, 'strife_db_newPlayerExperience'))) then
				if (type(v) == 'table') then	
					output = output .. GetDelimiter(index) .. tostring(i) .. GetDelimiter2(index) .. tostring(implode2(index + 1, v, output))
				elseif Empty(output) then
					output = tostring(i) .. GetDelimiter2(index) .. tostring(v)
				else
					output = output .. GetDelimiter(index) .. tostring(i) .. GetDelimiter2(index) .. tostring(v)
				end
			end
		end
		return output
	end

	stringOut = implode2(1, tableIn, stringOut)
	
	-- println('^c stringOut : ' .. tostring(stringOut) )

	return stringOut
end

function explodeTable2(stringIn)
	
	println('^c stringIn : ' .. tostring(stringIn) )
	
	local tableOut = {}
	
	local function GetDelimiter(index)
		local delimiter = '!'
		for x = 1, index, 1 do
			delimiter = delimiter .. '~'
		end
		delimiter = delimiter .. '!'
		return delimiter
	end
	
	local function GetDelimiter2(index)
		local delimiter = '|'
		for x = 1, index, 1 do
			delimiter = delimiter .. '~'
		end		
		delimiter = delimiter .. '|'
		return delimiter
	end	
		
	local function split(inputstr, sep)
		println('inputstr ' .. inputstr)
		println('sep ' .. sep)
		if sep == nil then
				sep = "%s"
		end
		t={} ; i=1
		for str in string.gmatch(inputstr, '' .. sep .. '(.+)') do
				t[i] = str
				i = i + 1
		end
		return t
	end
	
	local function explode2(index, stringIn, delim)
		local tableOut2 = split(stringIn, delim)
		
		println('index: ' .. index)
		printTable(tableOut2)
		
		for i, v in pairs(tableOut2) do
			if (string.find(v, GetDelimiter(index + 1))) then
				v = explode2(index + 1, v, GetDelimiter(index + 1))
			elseif (string.find(v, GetDelimiter2(index + 1))) then
				v = explode2(index + 1, v, GetDelimiter2(index))
			else
				v = v
			end
		end
		
		return tableOut2
	end
	
	tableOut = explode2(1, stringIn, GetDelimiter(1))
	
	println('^r^: tableOut')
	printr(tableOut)

	return tableOut
end

function explodeTable(inString, delimiter1, delimiter2, delimiter3)

	local delimiter1 = delimiter1 or '~'
	local delimiter2 = delimiter2 or '|'
	local delimiter3 = delimiter3 or '!'	
	
	if (inString) then

		local tableOut = {}

		local function subExplode2(inString3, delimiter)
			local tableOut3 = {}
			local count3 = 0
			while (true) do
				local foundAt = nil
				foundAt = find(inString3, delimiter, count3, true) 
				if foundAt ~= nil then 
					tinsert(tableOut3, sub(inString3, count3, foundAt - 1))
					count3 = foundAt + 1 
				else
					tinsert(tableOut3, sub(inString3, count3))
					break 
				end
			end		
			return tableOut3
		end		
		
		local function subExplode(inString2, delimiter)
			local tableOut2 = {}
			local count2 = 0
			while (true) do
				local foundAt = nil
				foundAt = find(inString2, delimiter, count2, true) 
				if foundAt ~= nil then 
					local stringToSeperate = sub(inString2, count2, foundAt - 1)
					local seperatedTable = subExplode2(stringToSeperate, delimiter3)
					tableOut2[seperatedTable[1]] = seperatedTable[2]
					count2 = foundAt + 1 
				else
					local stringToSeperate = sub(inString2, count2)
					local seperatedTable = subExplode2(stringToSeperate, delimiter3)
					tableOut2[seperatedTable[1]] = seperatedTable[2]					
					break 
				end
			end		
			return tableOut2
		end
		
		tableOut = subExplode(inString, delimiter1)
		
		-- find sub tables
		-- for i, v in pairs(tableOut) do
			-- if type(v) == 'string' then
				-- local foundAt = nil
				-- foundAt = find(v, delimiter2, 1, true) 
				-- if foundAt ~= nil then 
					-- v = subExplode(v, delimiter2)
				-- end
			-- end
		-- end

		return tableOut
	else
		println('Explode error inString: ' .. tostring(inString) .. ' delimiter1: ' .. tostring(delimiter1))
	end
end

function Empty(stringVar)
	if (stringVar) and type(stringVar) == 'string' then
		return (string.len(stringVar) <= 0) 
	else
		return true
	end
end

function split(str, delim, maxNb)
    if find(str, delim) == nil then
        return { str }
    end
    if maxNb == nil or maxNb < 1 then
        maxNb = 0
    end
    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local lastPos
    for part, pos in gfind(str, pat) do
        nb = nb + 1
        result[nb] = part
        lastPos = pos
        if nb == maxNb then break end
    end
    if nb ~= maxNb then
        result[nb + 1] = sub(str, lastPos)
    end
    return result
end

function pairsByKeys (t, f)
	local a = {}
	for n in pairs(t) do 
		tinsert(a, n) 
	end
	tsort(a, f)
	local i = 0      -- iterator variable
	local iter = function ()   -- iterator function
		i = i + 1
		if a[i] == nil then 
			return nil
		else 
			return a[i], t[a[i]]
		end
	end
  return iter 
end

function pairsSortByValue(incTable)

	local table1 = {}
	local table2 = {}
	local table3 = {}

	for i,v in pairs(incTable) do
		table1[v] = i
	end

	tsort(table1, function(a, b) return tonumber(a) > tonumber(b) end)
	
	printr(table1)
	
	for i,v in pairs(table1) do
		table2[v] = i
	end

	--printr(table2)
	
	return pairs(table2)
end

function table.copy(t)
  local u = { }
  for k, v in pairs(t) do u[k] = v end
  return setmetatable(u, getmetatable(t))
end

function printTable(printThatTable)
	if (type(printThatTable) == 'table') then
		for i,v in pairs(printThatTable) do
			print('i: '..tostring(i)..' | v: '.. tostring(v)..'\n')
		end
	else
		print('printTable: ' .. tostring(printThatTable) .. ' is not a table \n')
	end
end

function delayFunction(duration, callFunc, inTable, a1, a2, a3)		
	if (#delayedFunctionTable <= 0) then
		local function delayThread ()
			wait(duration)
			for index, value in ipairs(delayedFunctionTable) do
				print(value.inTable[value.callFunc](value.a1, value.a2, value.a3))	
			end
			delayedFunctionTable = {}
		end		
		delayThread = newthread(delayThread)
	end	
	table.insert(delayedFunctionTable, {callFunc = callFunc, inTable = inTable, a1 = a1, a2 = a2, a3 = a3})	
end

function memoizeObject (f)
	if (f) then
		local mem = {} -- memoizing table
		setmetatable(mem, {__mode = "kv"}) -- make it weak
		return function (x,a1,a2) -- new version of f, with memoizing
			if (x) then
				local r = mem[x]
				if r == nil or not r:IsValid() then -- no previous result?
					r = f(x,a1,a2) -- calls original function
					mem[x] = r -- store result for reuse
				end
				return r
			end
		end
	end
end

function GetWidget(widget, fromInterface, hideErrors)
	-- println('GetWidget Global: ' .. tostring(widget) .. ' in interface ' .. tostring(fromInterface))
	if (widget) then
		local returnWidget		
		if (fromInterface) then
			if UIManager.GetInterface(fromInterface) then
				returnWidget = UIManager.GetInterface(fromInterface):GetWidget(widget)
			else
				println('^o GetWidget could not find interface ' .. tostring(fromInterface))
			end		
		else
			if (interface) and (interface:IsValid()) then
				returnWidget = interface:GetWidget(widget)
			else
				println('^o GetWidget base interface is missing or invalid! ' .. tostring(widget) .. ' in interface ' .. tostring(fromInterface))
			end
		end	
		if (returnWidget) then
			return returnWidget
		else
			if (not hideErrors) then println('GetWidget Global failed to find ' .. tostring(widget) .. ' in interface ' .. tostring(fromInterface)) end
			return nil		
		end	
	else
		println('GetWidget called without a target')
		return nil
	end
end
GetWidget = memoizeObject(GetWidget)

function GetCvarBool(cvar, checkForNil)
	--println('GetCvarBool: ' .. tostring(cvar))
	if (cvar) then
		if (Cvar.GetCvar(cvar)) then
			return Cvar.GetCvar(cvar):GetBoolean()
		elseif (checkForNil) then
			return nil
		else
			return false
		end
	else
		println('GetCvarBool: ' .. tostring(cvar))
	end		
end

function GetCvarNumber(cvar, checkForNil)
	if (cvar) then
		if (Cvar.GetCvar(cvar)) then
			return Cvar.GetCvar(cvar):GetNumber()
		elseif (checkForNil) then
			return nil			
		else
			return 0
		end
	else
		println('GetCvarNumber: ' .. tostring(cvar))
	end
end

function GetCvarString(cvar, checkForNil)
	if (cvar) then
		if (Cvar.GetCvar(cvar)) then
			return Cvar.GetCvar(cvar):GetString()
		elseif (checkForNil) then
			return nil			
		else
			return ''
		end
	else
		println('GetCvarString: ' .. tostring(cvar))
	end			
end

function HostTime()
	print('^069WARNING:^* use of deprecated HostTime() in ben_dev.lua (replace with GetTime())\n')
	return GetTime()
end

function Set(cvarName, cvarValue, cvarType, noOverwrite)
	local cvar = Cvar.GetCvar(cvarName)
	if (cvar) then
		if (not noOverwrite) then
			Cvar.Set(cvar, tostring(cvarValue))
		end
		return cvar
	elseif (cvarType) then
		Cvar.CreateCvar(cvarName, cvarType, tostring(cvarValue))
		return Cvar.GetCvar(cvarName)
	else
		println('^o Set: Unable to find cvar ' .. tostring(cvarName))
	end
end

function SetSave(cvarName, cvarValue, cvarType, noOverwrite)
	local cvar = Cvar.GetCvar(cvarName)
	if (cvar) then
		if (not noOverwrite) then
			Cvar.Set(cvar, tostring(cvarValue))
			interface:UICmd([[SetSave(']] .. cvarName .. [[')]])
		end
	elseif (cvarType) then
		Cvar.CreateCvar(cvarName, cvarType, tostring(cvarValue))
		interface:UICmd([[SetSave(']] .. cvarName .. [[')]])
	else
		println('^o Set: Unable to find cvar ' .. tostring(cvarName))
	end
end

function printdb(stringVar)
	if GetCvarBool('ui_dev') then print(tostring(stringVar)..'\n') end
end

function GenericDialogAutoSize(header, label1, label2, btn1, btn2, onConfirm, onCancel, dontDimBG, showFlair, forceDisplay, dontAskAgain, delayOkButton)
		 GenericDialog        (header, label1, label2, btn1, btn2, onConfirm, onCancel, dontDimBG, showFlair, forceDisplay, dontAskAgain, delayOkButton)
	
	-- interface:GetWidget('generic_dialog_box'):FadeIn(250)
	-- if (dontDimBG) then
		-- interface:GetWidget('generic_dialog_box'):SetColor('invisible')
	-- else
		-- interface:GetWidget('generic_dialog_box'):SetColor('0 0 0 0.3')
	-- end
	
	-- FitFontToLabel(interface:GetWidget('generic_dialog_header_1'), header or '?')	
	-- FitFontToLabel(interface:GetWidget('generic_dialog_label_1'), label1 or '?')	
	-- FitFontToLabel(interface:GetWidget('generic_dialog_label_2'), label2 or '?')	
	-- groupfcall('generic_dialog_button_1_label_group', function(_, widget) FitFontToLabel(widget, btn1)	 end)
	-- groupfcall('generic_dialog_button_2_label_group', function(_, widget) FitFontToLabel(widget, btn2)	 end)		
	
	-- interface:GetWidget('generic_dialog_header_1'):SetText(Translate(header) or '?')
	
	-- if (label1) and (not Empty(label1)) then
		-- interface:GetWidget('generic_dialog_label_1'):SetText(Translate(label1) or '?')
	-- else
		-- interface:GetWidget('generic_dialog_label_1'):SetText('')
		-- interface:GetWidget('generic_dialog_label_1'):SetVisible(0)
	-- end
			
	-- if (label2) and (not Empty(label2)) then
		-- interface:GetWidget('generic_dialog_label_2'):SetText(Translate(label2) or '?')
	-- else
		-- interface:GetWidget('generic_dialog_label_2'):SetText('')
		-- interface:GetWidget('generic_dialog_label_2'):SetVisible(0)
	-- end	
	
	-- if (btn1) and (not Empty(btn1)) then
		-- groupfcall('generic_dialog_button_1_label_group', function(_, widget) widget:SetText(Translate(btn1) or '?') end)
		-- interface:GetWidget('generic_dialog_button_1'):SetVisible(1)
	-- else
		-- groupfcall('generic_dialog_button_1_label_group', function(_, widget) widget:SetText('') end)
		-- interface:GetWidget('generic_dialog_button_1'):SetVisible(0)
	-- end		
	
	-- if (btn2) and (not Empty(btn2)) then
		-- groupfcall('generic_dialog_button_2_label_group', function(_, widget) widget:SetText(Translate(btn2) or '?') end)
		-- interface:GetWidget('generic_dialog_button_2'):SetVisible(1)
	-- else
		-- groupfcall('generic_dialog_button_2_label_group', function(_, widget) widget:SetText('') end)
		-- interface:GetWidget('generic_dialog_button_2'):SetVisible(0)
	-- end	

	-- interface:GetWidget('generic_dialog_button_1'):SetCallback('onclick', function()
		-- interface:GetWidget('generic_dialog_box'):SetVisible(false)
		-- if (onConfirm) then
			-- onConfirm()
		-- end
	-- end)
	
	-- interface:GetWidget('generic_dialog_button_2'):SetCallback('onclick', function()
		-- interface:GetWidget('generic_dialog_box'):SetVisible(false)
		-- if (onCancel) then
			-- onCancel()
		-- end		
	-- end)	

	-- interface:GetWidget('generic_dialog_box_closex'):SetCallback('onclick', function()
		-- interface:GetWidget('generic_dialog_box'):SetVisible(false)
		-- if (onCancel) then
			-- onCancel()
		-- end		
	-- end)	
	
	-- FindChildrenClickCallbacks(interface:GetWidget('generic_dialog_box'))
end

local lastDialogForced = false
function GenericDialog(header, label1, label2, btn1, btn2, onConfirm, onCancel, dontDimBG, showFlair, forceDisplay, dontAskAgain, delayOkButton)

	if (UIManager.GetActiveInterface():GetName() == 'game') and (GenericDialogGame) then
		GenericDialogGame(header, label1, label2, btn1, btn2, onConfirm, onCancel, dontDimBG, showFlair, forceDisplay, dontAskAgain, delayOkButton)
		return
	elseif (UIManager.GetActiveInterface():GetName() == 'game_spectator') and (GenericDialogGameSpec) then
		GenericDialogGameSpec(header, label1, label2, btn1, btn2, onConfirm, onCancel, dontDimBG, showFlair, forceDisplay, dontAskAgain, delayOkButton)
		return
	end
	
	if (not interface:GetWidget('generic_dialog_box_bg')) then 
		println('^r^: GenericDialog Called Before Exists : ' .. tostring(header..' '..label1..' '..label2) )
		return 
	end
	
	if (interface:GetWidget('generic_dialog_box_wrapper'):IsVisible() and (lastDialogForced)) and (not forceDisplay) then
		println('^r^: GenericDialog ignored as last was forced')
		return
	end
	
	if (dontAskAgain) and (mainUI) and (mainUI.savedLocally.skipTheseDialogs) and (mainUI.savedLocally.skipTheseDialogs[header..label1..label2]) and (onConfirm) then
		onConfirm()
		return
	end		
	
	lastDialogForced = forceDisplay
	
	interface:GetWidget('generic_dialog_flair'):SetVisible(0)
	
	if (dontDimBG) then
		interface:GetWidget('generic_dialog_box_bg'):SetColor('invisible')
	else
		interface:GetWidget('generic_dialog_box_bg'):SetColor('0 0 0 0.4')
	end
	
	interface:GetWidget('generic_dialog_header_1'):SetText(Translate(header) or '?')
	interface:GetWidget('generic_dialog_header_1'):SetFont('maindyn_22')
	if (label1) and (not Empty(label1)) then
		interface:GetWidget('generic_dialog_label_1'):SetText(Translate(label1) or '?')
		interface:GetWidget('generic_dialog_label_1'):SetVisible(1)
		interface:GetWidget('generic_dialog_label_1'):SetFont('maindyn_22')
	else
		interface:GetWidget('generic_dialog_label_1'):SetText('')
		interface:GetWidget('generic_dialog_label_1'):SetVisible(0)
	end
	if (label2) and (not Empty(label2)) then
		interface:GetWidget('generic_dialog_label_2'):SetText(Translate(label2) or '?')
		interface:GetWidget('generic_dialog_label_2'):SetVisible(1)
		interface:GetWidget('generic_dialog_label_2'):SetFont('maindyn_22')
	else
		interface:GetWidget('generic_dialog_label_2'):SetText('')
		interface:GetWidget('generic_dialog_label_2'):SetVisible(0)
	end	

	if (btn1) and (not Empty(btn1)) then
		groupfcall('generic_dialog_button_1_label_group', function(_, widget) widget:SetText(Translate(btn1) or '?') widget:SetFont('maindyn_30') end)
		interface:GetWidget('generic_dialog_button_1'):SetVisible(1)
		if (delayOkButton) then
			interface:GetWidget('generic_dialog_button_1'):SetEnabled(0)
			libThread.threadFunc(function()	
				wait(1500)		
				interface:GetWidget('generic_dialog_button_1'):SetEnabled(1)
			end)
		end
	else
		groupfcall('generic_dialog_button_1_label_group', function(_, widget) widget:SetText('') end)
		interface:GetWidget('generic_dialog_button_1'):SetVisible(0)
	end		

	if (btn2) and (not Empty(btn2)) then
		groupfcall('generic_dialog_button_2_label_group', function(_, widget) widget:SetText(Translate(btn2) or '?') widget:SetFont('maindyn_24') end)
		interface:GetWidget('generic_dialog_button_2'):SetVisible(1)
	else
		groupfcall('generic_dialog_button_2_label_group', function(_, widget) widget:SetText('') end)
		interface:GetWidget('generic_dialog_button_2'):SetVisible(0)
	end		

	interface:GetWidget('generic_dialog_button_1'):SetCallback('onclick', function()
		interface:GetWidget('generic_dialog_box'):SetVisible(false)
		interface:GetWidget('generic_dialog_box_wrapper'):SetVisible(0)
		if (onConfirm) then
			onConfirm()
		end
	end)
	
	interface:GetWidget('generic_dialog_button_2'):SetCallback('onclick', function()
		interface:GetWidget('generic_dialog_box'):SetVisible(false)
		interface:GetWidget('generic_dialog_box_wrapper'):SetVisible(0)
		if (onCancel) then
			onCancel()
		end		
	end)	

	interface:GetWidget('generic_dialog_box_closex'):SetCallback('onclick', function()
		interface:GetWidget('generic_dialog_box'):SetVisible(false)
		interface:GetWidget('generic_dialog_box_wrapper'):SetVisible(0)
		if (onCancel) then
			onCancel()
		end		
	end)

	if (dontAskAgain) then
		interface:GetWidget('generic_dialog_dontaskagain'):SetVisible(1)
		interface:GetWidget('generic_dialog_dontaskagain_checkbox'):SetCallback('onclick', function(widget) 
			mainUI = mainUI or {}
			mainUI.savedLocally.skipTheseDialogs = mainUI.savedLocally.skipTheseDialogs or {}
			if (widget:GetValue() == '1') then
				mainUI.savedLocally.skipTheseDialogs[header..label1..label2] = true
			else
				mainUI.savedLocally.skipTheseDialogs[header..label1..label2] = nil
			end
		end)	
		interface:GetWidget('generic_dialog_dontaskagain_checkbox_parent'):SetCallback('onclick', function(widget) 
			mainUI = mainUI or {}
			mainUI.savedLocally.skipTheseDialogs = mainUI.savedLocally.skipTheseDialogs or {}
			if (interface:GetWidget('generic_dialog_dontaskagain_checkbox'):GetValue() == '0') then
				mainUI.savedLocally.skipTheseDialogs[header..label1..label2] = true
				interface:GetWidget('generic_dialog_dontaskagain_checkbox'):SetButtonState(1)
			else
				mainUI.savedLocally.skipTheseDialogs[header..label1..label2] = nil
				interface:GetWidget('generic_dialog_dontaskagain_checkbox'):SetButtonState(0)
			end
		end)		
		interface:GetWidget('generic_dialog_dontaskagain_checkbox'):RefreshCallbacks()
		interface:GetWidget('generic_dialog_dontaskagain_checkbox_parent'):RefreshCallbacks()
	else
		interface:GetWidget('generic_dialog_dontaskagain'):SetVisible(0)
		interface:GetWidget('generic_dialog_dontaskagain_checkbox'):ClearCallback('onclick')
		interface:GetWidget('generic_dialog_dontaskagain_checkbox_parent'):ClearCallback('onclick')
	end
	
	interface:GetWidget('generic_dialog_box_wrapper'):SetHeight(0)
	interface:GetWidget('generic_dialog_box_wrapper'):SetWidth(0)
	interface:GetWidget('generic_dialog_box_wrapper'):SetVisible(1)
	interface:GetWidget('generic_dialog_box_bg'):SetVisible(0)
	
	interface:GetWidget('generic_dialog_box_wrapper'):Scale(interface:GetWidget('generic_dialog_box_insert'):GetWidth(), interface:GetWidget('generic_dialog_box_insert'):GetHeight(), 125)
	
	interface:GetWidget('generic_dialog_box'):Sleep(125, function()	
		interface:GetWidget('generic_dialog_box'):FadeIn(125)
		if (showFlair) then
			interface:GetWidget('generic_dialog_flair'):SetVisible(1)
		end
	end)	
	
	interface:GetWidget('generic_dialog_box_bg'):FadeIn(1500)
	
	FindChildrenClickCallbacks(interface:GetWidget('generic_dialog_box'))

end

function GenericAlert(header, doOnCancel)
	interface:GetWidget('generic_alert_bar'):FadeIn(250)
	
	interface:GetWidget('generic_alert_header_1'):SetText(Translate(header) or '?')

	interface:GetWidget('generic_alert_box_closex'):SetCallback('onclick', function()
		interface:GetWidget('generic_alert_bar'):SetVisible(false)
		if (doOnCancel) then
			doOnCancel()
		end
	end)
	FindChildrenClickCallbacks(interface:GetWidget('generic_alert_bar'))
end

function ShowConfirmation(displayName, cost, onConfirm, onCancel)
	interface:GetWidget('gem_purchase_confirm'):FadeIn(250)
	
	interface:GetWidget('gem_purchase_confirm_label_1'):SetText(displayName or '?')
	
	interface:GetWidget('gem_purchase_confirm_label_2'):SetText(cost or '?')
	
	interface:GetWidget('gem_purchase_confirm_button_1'):SetCallback('onclick', function()
		interface:GetWidget('gem_purchase_confirm'):SetVisible(false)
		if (onConfirm) then
			onConfirm()
		end
	end)
	
	interface:GetWidget('gem_purchase_confirm_button_2'):SetCallback('onclick', function()
		interface:GetWidget('gem_purchase_confirm'):SetVisible(false)
		if (onCancel) then
			onCancel()
		end		
	end)	
	FindChildrenClickCallbacks(interface:GetWidget('gem_purchase_confirm'))
end

function RegisterLoopingScrollingLabel(sourceWidget, text, fontSize, loopByDefault)
	
	if (loopByDefault) then
		local currentText = text
		local lastUpdate = LuaTrigger.GetTrigger('System').hostTime + 300	
		sourceWidget:RegisterWatchLua('System', function(widget, trigger)
			if ((lastUpdate + 150) < trigger.hostTime) then
				lastUpdate 	= trigger.hostTime
				currentText = sourceWidget:GetText()
				if ((GetStringWidth(fontSize, currentText)) < (sourceWidget:GetWidth())) then
					currentText = sub(currentText, 2) .. '  ' .. text
					sourceWidget:SetText(currentText)
				else
					currentText = sub(currentText, 2)
					sourceWidget:SetText(currentText)				
				end
			end
		end, false, nil, 'hostTime')	
	else
		sourceWidget:SetCallback('onmouseout', function()
			sourceWidget:UnregisterWatchLua('System')
			sourceWidget:SetText(text)
		end)	
		sourceWidget:SetCallback('onmouseover', function()
			if ((GetStringWidth(fontSize, text)) > (sourceWidget:GetWidth())) then
				local currentText = text
				local lastUpdate = LuaTrigger.GetTrigger('System').hostTime + 300	
				sourceWidget:RegisterWatchLua('System', function(widget, trigger)
					if ((lastUpdate + 150) < trigger.hostTime) then
						lastUpdate 	= trigger.hostTime
						currentText = sourceWidget:GetText()
						if ((GetStringWidth(fontSize, currentText)) < (sourceWidget:GetWidth())) then
							currentText = sub(currentText, 2) .. '  ' .. text
							sourceWidget:SetText(currentText)
						else
							currentText = sub(currentText, 2)
							sourceWidget:SetText(currentText)				
						end
					end
				end, false, nil, 'hostTime')
			end
		end)
	end
	sourceWidget:RefreshCallbacks()
end

function RegisterRockingScrollingLabel(sourceWidget, text, fontSize, padding, labelWidget)
	labelWidget = labelWidget or sourceWidget
	sourceWidget:SetCallback('onmouseout', function()
		labelWidget:UnregisterWatchLua('System')
		labelWidget:SetText(text)
	end)	
	sourceWidget:SetCallback('onmouseover', function()
		if ((GetStringWidth(fontSize, text)) > (labelWidget:GetWidth())) then
			local currentText = text
			local deletedText = ''
			local reverse = false
			local lastUpdate = LuaTrigger.GetTrigger('System').hostTime + 300
			labelWidget:RegisterWatchLua('System', function(widget, trigger)
				if ((lastUpdate + 150) < trigger.hostTime) then
					lastUpdate 	= trigger.hostTime
					if ((GetStringWidth(fontSize, currentText) + (padding or 0)) < (labelWidget:GetWidth())) or (reverse) then
						if (not reverse) and (not Empty(deletedText)) then
							reverse = true
							lastUpdate = lastUpdate + 500
						else
							if (not Empty(deletedText)) then
								currentText = sub(deletedText, 1, 1) .. currentText
								deletedText = sub(deletedText, 2)
								labelWidget:SetText(currentText)	
							else
								reverse = false
								deletedText = ''
								currentText = text
								labelWidget:SetText(currentText)	
								lastUpdate = lastUpdate + 500
							end
						end
					else
						deletedText = sub(currentText, 1, 1) .. deletedText
						currentText = sub(currentText, 2)
						labelWidget:SetText(currentText)		
					end
				end
			end, false, nil, 'hostTime')
		end
	end)
	sourceWidget:RefreshCallbacks()
end

function GetFontThatFits(width, text, fontSizeTable)
	local fontSizeTable = fontSizeTable or {
		-- 'maindyn_72',
		-- 'maindyn_56',
		'maindyn_48',
		'maindyn_40',
		'maindyn_36',
		'maindyn_30',
		'maindyn_26',
		'maindyn_24',
		'maindyn_22',
		'maindyn_20',
		'maindyn_18',
		'maindyn_16',
		'maindyn_15',
		'maindyn_14',
		'maindyn_13',
		'maindyn_12',
		'maindyn_11',
		'maindyn_10',
		'maindyn_9',
		'maindyn_8',
	}

	local widgetWidth = interface:GetWidthFromString(width)*0.98	

	local stringWidth
	for _, fontSize in ipairs(fontSizeTable) do 
		stringWidth = GetStringWidth(fontSize, text)
		if (stringWidth) < (widgetWidth) then
			return fontSize
		end
	end
	return fontSizeTable[#fontSizeTable]
end

function FitFontToLabel(sourceWidget, text, fontSizeTable, setFont)
	if (sourceWidget) and (sourceWidget:IsValid()) then
		if setFont == nil then setFont = true end
		local text = text or sourceWidget:GetText()
		local fontSizeTable = fontSizeTable or {
			'maindyn_48',
			'maindyn_40',
			'maindyn_36',
			'maindyn_30',
			'maindyn_26',
			'maindyn_24',
			'maindyn_22',
			'maindyn_20',
			'maindyn_18',
			'maindyn_16',
			'maindyn_15',
			'maindyn_14',
			'maindyn_13',
			'maindyn_12',
			'maindyn_11',
			'maindyn_10',
			'maindyn_9',
			'maindyn_8',
		}
		for _, fontSize in ipairs(fontSizeTable) do 
			if ((GetStringWidth(fontSize, text)) < (sourceWidget:GetWidth()*0.98)) then
				-- if tonumber(sourceWidget:UICmd("GetStringWrapHeight('"..fontSize.."', '"..text.."')")) < (sourceWidget:GetHeight()*0.95) then
					if setFont then
						sourceWidget:SetFont(fontSize)
					end
					return fontSize
					-- break
				-- end
			end
		end
	else
		println('^rError FitFontToLabel called on invalid widget')
		println('sourceWidget ' .. tostring(sourceWidget))
		println('text ' .. tostring(text))
	end
end

function estimateLines(widget, str, font)
	-- Params from widget
	font = font or widget:GetFont()
	local width = widget:GetWidth() - 3

	-- Split into words
	local wordList = {}
	for w in str:gmatch("%S+") do tinsert(wordList, w) end
	
	local currentLine = 1
	local currentString = ""
	local n = 1
	while n <= #wordList do
		if (currentString ~= "") then -- Add spaces between words
			currentString = currentString .. " "
		end
		-- Add the next word
		currentString = currentString .. wordList[n]
		-- If it doesn't fit, start working on the next line
		if GetStringWidth(font, currentString) > width then
			-- Error: A word is longer than the width! It can't fit. Return an error.
			if not string.find(currentString, " ") then
				println("^cWarning, word("..currentString..") too long for label("..widget:GetName()..")!")
				return -1
			end
			currentString = ""
			currentLine = currentLine + 1
			n = n - 1 -- Try this word again
		end
		n = n + 1
	end
	return currentLine
end

function FitStringToWrappingLabel(sourceWidget, text, fontSizeTable, setFont, setText, maxHeight)
	local setFont = setFont or true
	local setText = setText or true
	local maxHeight = nil or sourceWidget:GetHeight()*0.95
	local text = text or sourceWidget:GetText()
	local lineHeight = sourceWidget:GetLineHeight()
	
	local fontSizeTable = fontSizeTable or {
		'maindyn_48',
		'maindyn_40',
		'maindyn_36',
		'maindyn_30',
		'maindyn_26',
		'maindyn_24',
		'maindyn_22',
		'maindyn_20',
		'maindyn_18',
		'maindyn_16',
		'maindyn_15',
		'maindyn_14',
		'maindyn_13',
		'maindyn_12',
		'maindyn_11',
		'maindyn_10',
		'maindyn_9',
		'maindyn_8',
	}
	for _, fontSize in ipairs(fontSizeTable) do 
		local lines = estimateLines(sourceWidget, text, fontSize)
		if lines*tonumber(sourceWidget:UICmd("GetFontHeight('"..fontSize.."')")) < maxHeight then
			if setFont then
				sourceWidget:SetFont(fontSize)
			end
			if setText then
				sourceWidget:SetText(text)
			end
			return fontSize
			-- break
		end
	end
end

function UserAction(action, openAction, extraInfo)
	--println('UserAction - action: ' ..tostring(action) .. ' | openAction: ' ..tostring(openAction) .. ' | extraInfo: ' ..tostring(extraInfo) )
	--local validActions = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22}
	if (openAction) then
		if (GetCvarBoolMem('ui_sendUserActions')) then 
			printdb('^gSent UserAction - action: ' ..tostring(action) .. ' | openAction: ' ..tostring(openAction) .. ' | extraInfo: ' ..tostring(extraInfo) )
			interface:UICmd("SendAction("..action..");")		
		elseif (GetCvarBoolMem('client_enableActionTracking'))  then
			interface:UICmd("SendAction("..action..");")	
		end
	end
end

function IsValidIdent(identID)
	if (identID) and tonumber(identID) and (tonumber(identID) > 0) and (identID ~= '4294967.295') then
		return true
	else	
		return false
	end
end

function IsFullyLoggedIn(identID)
	local loginStatus = LuaTrigger.GetTrigger('LoginStatus')
	if IsValidIdent(identID) and (loginStatus.isLoggedIn and ((loginStatus.hasIdent and loginStatus.isIdentPopulated)))  then
		return true
	else	
		return false
	end
end

-- Temp Chat Stuff

function IsMe(stringVar)
	local accountInfoTrigger = LuaTrigger.GetTrigger('AccountInfo')
	
	if tonumber(stringVar) then
		return (string.lower(accountInfoTrigger.identID) == string.lower(stringVar))
	else
		if (stringVar) and (not Empty(stringVar)) then
			if (string.find(stringVar, ']')) then
				stringVar = string.sub(stringVar, string.find(stringVar, ']') + 1)
			end
			if (string.find(accountInfoTrigger.nickname, ']')) then
				accountInfoTrigger.nickname = string.sub(accountInfoTrigger.nickname, string.find(accountInfoTrigger.nickname, ']') + 1)
			end		
			return (string.lower(stringVar) == string.lower(accountInfoTrigger.nickname))
		else
			return false
		end			
	end
end

function IsOpponent(userIdentID)
	if (userIdentID) then
		for i = 0, 4, 1 do
			local enemyUnitTrigger = LuaTrigger.GetTrigger('EnemyUnit' .. i)
			if (enemyUnitTrigger) and (enemyUnitTrigger.identID == userIdentID) then
				return true
			end
		end
	end
	return false
end

function IsAlly(userIdentID)
	if (userIdentID) then
		for i = 0, 3, 1 do
			local allyUnitTrigger = LuaTrigger.GetTrigger('AllyUnit' .. i)
			if (allyUnitTrigger) and (allyUnitTrigger.identID == userIdentID) then
				return true
			end
		end
	end
	return false
end

function IsInParty(userIdentID)
	local partyStatus = LuaTrigger.GetTrigger('PartyStatus')
	if (partyStatus.inParty) and (userIdentID) then
		for i = 0, 4, 1 do
			local partyPlayerInfo = LuaTrigger.GetTrigger('PartyPlayerInfo' .. i)
			if (partyPlayerInfo) and (partyPlayerInfo.identID == userIdentID) then
				return true
			end
		end
		return false
	else
		return false
	end
end

function ChatUserOnline(userIdentID)
	return ChatClient.IsOnline(userIdentID)
end

function IsFriend(userIdentID)
	return ChatClient.IsFriend(userIdentID)
end

function ChatAddFriend(userIdentID)
	--println('Adding friend: ' .. tostring(userIdentID) )
	if (userIdentID) and (not Empty(userIdentID)) then
		AddFriendStrife(GetIdentID(), userIdentID, '')
	end
end

function TranslateOrNil(inputString)
	if (inputString == Translate(inputString)) then
		return nil
	else
		return Translate(inputString)
	end
end

function Link()
	
	local index = 0
	local inputBuffer = GetWidget('overlay_chat_' .. index .. '_input')
	
	inputBuffer:InputChatLink('i', '1', '2')
	
	-- InputChatLink			identifier, data, message

	-- SetChatLinkClickColor
	-- SetChatLinkColor
	-- UpdateLinkColors
	
	-- ChatLinkClick			data displayText index linkType
	-- ChatLinkCreated
	-- ChatLinkMouseOver
	-- ChatLinkMouseOut
	
end

function UIMute(slotIndex, identID, clientNumber, name, uniqueID)
	
	println('^y UIMute slotIndex: ' .. tostring(slotIndex) .. ' | identID: ' .. tostring(identID)  .. ' | clientNumber: ' .. tostring(clientNumber)  .. ' | name: ' .. tostring(name))
	local identID = tostring(identID)
	
	local thisGuyWasMuted = ChatClient.IsIgnored(identID)
	
	if (not thisGuyWasMuted) and ((not identID) or (not IsValidIdent(identID)) or IsMe(identID)) then
		println('^r You cannot mute this identID')
		return
	end	
	
	-- RMM Add These
	-- Mute Chat Wheel
	-- Mute Command Dial
	-- Mute Game Chat
	-- Mute IMs
	-- Mute Channel Chat
		
	mainUI = mainUI or {}
	mainUI.savedLocally.downVoteList = mainUI.savedLocally.downVoteList or {}	
	
	local heroIndex = GetTrigger('AllyUnit'..tostring(slotIndex))
	if heroIndex then 
		heroIndex = heroIndex.index 
	end
	
	if (thisGuyWasMuted) then
		ChatClient.RemoveIgnore(identID)
		mainUI.savedLocally.downVoteList[identID] = false
		VoiceClient.SetMuted(identID, false)
		if clientNumber then UnMutePlayerPings(clientNumber) end
		if (heroIndex) then UnMuteHeroAnnouncements(heroIndex) end
	else
		ChatClient.AddIgnore(identID)
		mainUI.savedLocally.downVoteList[identID] = true
		VoiceClient.SetMuted(identID, true)	
		if clientNumber then MutePlayerPings(clientNumber) end
		if (heroIndex) then MuteHeroAnnouncements(heroIndex) end
	end
	
end

--[[ Auth types
	c = client
	a = admin
	s = gameserver
	cs = chatserver
--]]

function PromptQuit()
	-- soundEvent - Open Quit Prompt
	local triggerPanelStatus		= LuaTrigger.GetTrigger('mainPanelStatus')
	if (triggerPanelStatus.main == 26) then
		triggerPanelStatus.main = 101
		triggerPanelStatus:Trigger(false)	
	end
	libThread.threadFunc(function()	
		wait(10)
		if (petsFlushRequestQueue) then
			petsFlushRequestQueue(nil, function() end)
		end
		SaveState()
		-- Sync only if we need to.
		if not LuaTrigger.GetTrigger('optionsTrigger').isSynced then
			SaveDBToWeb()
		end
		PlaySound('/ui/sounds/sfx_ui_back.wav')
		GenericDialogAutoSize(
			'main_quit_confirm', 'main_quit_confirm2', '', 'general_quit', 'general_cancel', 
			function()
				-- soundEvent - Confirm Quit
				PlaySound('/ui/sounds/ui_quit.wav')
				libThread.threadFunc(function()	
					WindowManager.CloseAllWindows()
					wait(500)
					Quit()
				end)
			end,
			function()
				-- soundEvent - Cancel Quit
				PlaySound('/ui/sounds/sfx_ui_back.wav')
			end,
			nil,
			false,
			true
		)
	end)
end
function Quit()
	Cmd('Quit')
end

function Logout()
	local triggerPanelStatus		= LuaTrigger.GetTrigger('mainPanelStatus')
	triggerPanelStatus.main = 0
	triggerPanelStatus:Trigger(true)
	Cmd('Logout')
	Cmd('Disconnect')
	ChatClient.LeaveGame()
end

function UpdateCursor(sourceWidget, updateCursor, actionsTable)
	if (sourceWidget) then
		if (updateCursor) and (actionsTable) then
			
			local cursorPathString = '/core/cursors/arrow'
			
			if (actionsTable.canLeftClick) then
				cursorPathString = cursorPathString .. '_left'
			end
			
			if (actionsTable.canRightClick) then
				cursorPathString = cursorPathString .. '_right'
			end		

			if (actionsTable.canDrag) then
				cursorPathString = cursorPathString .. '_drag'
			end			

			if (actionsTable.spendGems) then
				cursorPathString = '/core/cursors/cost_gem'
			elseif (actionsTable.spendGold) then
				cursorPathString = '/core/cursors/cost_coin'
			elseif (actionsTable.baller) then
				cursorPathString = '/core/cursors/baller'			
			elseif (actionsTable.draw) then
				cursorPathString = '/core/cursors/draw'			
			elseif (actionsTable.ping) then
				cursorPathString = '/core/cursors/ping'			
			elseif (actionsTable.ping_ally) then
				cursorPathString = '/core/cursors/ping_ally'		
			elseif (actionsTable.text) then
				cursorPathString = '/core/cursors/text'		
			elseif (actionsTable.blank) then
				cursorPathString = '/core/cursors/blank'
			end				
			
			-- if (actionsTable.newWindow) then
				-- cursorPathString = '/core/cursors/cost_gem'
			-- end			
			
			cursorPathString = cursorPathString .. '.cursor'
			
			-- println('^g set cursor ' .. cursorPathString)
			
			sourceWidget:SetCursor(cursorPathString)
			
		else
			-- println('^r set cursor')
			sourceWidget:SetCursor('/core/cursors/arrow.cursor')
		end
	else
		-- println('^r UpdateCursor called without a sourcewidget')
	end
end 

function CursorInside(widget)
	if (widget) then
		local pos = Input.GetCursorPos()
		local x, y, w, h = widget:GetAbsoluteX(), widget:GetAbsoluteY(), widget:GetWidth(), widget:GetHeight()
		if (pos.x>x and pos.x<x+w and pos.y>y and pos.y<y+h) then
			return true
		else
			return false
		end
	end
	return nil
end 

function IsThisTheBaseItem(incItemTable)
	local CraftingUnfinishedDesign = incItemTable or LuaTrigger.GetTrigger('CraftingUnfinishedDesign')
	local CraftedItems
	local isTheBaseItem = false
	
	if (CraftingUnfinishedDesign) and (CraftingUnfinishedDesign.name) and (not Empty(CraftingUnfinishedDesign.name)) then
		local recipeInfo = craftingGetRecipe(CraftingUnfinishedDesign.name)
		if (recipeInfo) and
			((not recipeInfo.components[1]) or (recipeInfo.components[1] == CraftingUnfinishedDesign.component1)) and
			((not recipeInfo.components[2]) or (recipeInfo.components[2] == CraftingUnfinishedDesign.component2)) and
			((not recipeInfo.components[3]) or (recipeInfo.components[3] == CraftingUnfinishedDesign.component3)) and
			(CraftingUnfinishedDesign.currentEmpoweredEffectEntityName == '') 
		then
			isTheBaseItem = true
		end
	end
	
	return isTheBaseItem
end

function DoIAlreadyOwnThisItem(incItemTable)
	local CraftingUnfinishedDesign = incItemTable or LuaTrigger.GetTrigger('CraftingUnfinishedDesign')
	local CraftedItems
	local doIOwnIt = false
	
	if (CraftingUnfinishedDesign) and (CraftingUnfinishedDesign.name) and (not Empty(CraftingUnfinishedDesign.name)) then
		for index = 0,99,1 do
			CraftedItems = LuaTrigger.GetTrigger('CraftedItems' .. index)
			if (CraftedItems) and (CraftedItems.name) and (not Empty(CraftedItems.name)) then
				local splitTable = split(CraftedItems.name, '|')
				local name = splitTable[2]
				if (name) and (name == CraftingUnfinishedDesign.name) then
					if (CraftedItems.currentEmpoweredEffectEntityName == CraftingUnfinishedDesign.currentEmpoweredEffectEntityName) and
						(CraftedItems.component1 == CraftingUnfinishedDesign.component1) and
						(CraftedItems.component2 == CraftingUnfinishedDesign.component2) and
						(CraftedItems.component3 == CraftingUnfinishedDesign.component3) then
						doIOwnIt = true
						break
					end
				end
			end
		end
	end
	
	return doIOwnIt
end

--

function Anims()

	local pow = math.pow  
	local sin = math.sin
	local cos = math.cos
	local pi = math.pi
	local sqrt = math.sqrt
	local abs = math.abs
	local asin  = math.asin

	local function linear(t, b, c, d)
	  return c * t / d + b
	end

	local function inQuad(t, b, c, d)
	  t = t / d
	  return c * pow(t, 2) + b
	end

	local function outQuad(t, b, c, d)
	  t = t / d
	  return -c * t * (t - 2) + b
	end

	local function inOutQuad(t, b, c, d)
	  t = t / d * 2
	  if t < 1 then
		return c / 2 * pow(t, 2) + b
	  else
		return -c / 2 * ((t - 1) * (t - 3) - 1) + b
	  end
	end

	local function outInQuad(t, b, c, d)
	  if t < d / 2 then
		return outQuad (t * 2, b, c / 2, d)
	  else
		return inQuad((t * 2) - d, b + c / 2, c / 2, d)
	  end
	end

	local function inCubic (t, b, c, d)
	  t = t / d
	  return c * pow(t, 3) + b
	end

	local function outCubic(t, b, c, d)
	  t = t / d - 1
	  return c * (pow(t, 3) + 1) + b
	end

	local function inOutCubic(t, b, c, d)
	  t = t / d * 2
	  if t < 1 then
		return c / 2 * t * t * t + b
	  else
		t = t - 2
		return c / 2 * (t * t * t + 2) + b
	  end
	end

	local function outInCubic(t, b, c, d)
	  if t < d / 2 then
		return outCubic(t * 2, b, c / 2, d)
	  else
		return inCubic((t * 2) - d, b + c / 2, c / 2, d)
	  end
	end

	local function inQuart(t, b, c, d)
	  t = t / d
	  return c * pow(t, 4) + b
	end

	local function outQuart(t, b, c, d)
	  t = t / d - 1
	  return -c * (pow(t, 4) - 1) + b
	end

	local function inOutQuart(t, b, c, d)
	  t = t / d * 2
	  if t < 1 then
		return c / 2 * pow(t, 4) + b
	  else
		t = t - 2
		return -c / 2 * (pow(t, 4) - 2) + b
	  end
	end

	local function outInQuart(t, b, c, d)
	  if t < d / 2 then
		return outQuart(t * 2, b, c / 2, d)
	  else
		return inQuart((t * 2) - d, b + c / 2, c / 2, d)
	  end
	end

	local function inQuint(t, b, c, d)
	  t = t / d
	  return c * pow(t, 5) + b
	end

	local function outQuint(t, b, c, d)
	  t = t / d - 1
	  return c * (pow(t, 5) + 1) + b
	end

	local function inOutQuint(t, b, c, d)
	  t = t / d * 2
	  if t < 1 then
		return c / 2 * pow(t, 5) + b
	  else
		t = t - 2
		return c / 2 * (pow(t, 5) + 2) + b
	  end
	end

	local function outInQuint(t, b, c, d)
	  if t < d / 2 then
		return outQuint(t * 2, b, c / 2, d)
	  else
		return inQuint((t * 2) - d, b + c / 2, c / 2, d)
	  end
	end

	local function inSine(t, b, c, d)
	  return -c * cos(t / d * (pi / 2)) + c + b
	end

	local function outSine(t, b, c, d)
	  return c * sin(t / d * (pi / 2)) + b
	end

	local function inOutSine(t, b, c, d)
	  return -c / 2 * (cos(pi * t / d) - 1) + b
	end

	local function outInSine(t, b, c, d)
	  if t < d / 2 then
		return outSine(t * 2, b, c / 2, d)
	  else
		return inSine((t * 2) -d, b + c / 2, c / 2, d)
	  end
	end

	local function inExpo(t, b, c, d)
	  if t == 0 then
		return b
	  else
		return c * pow(2, 10 * (t / d - 1)) + b - c * 0.001
	  end
	end

	local function outExpo(t, b, c, d)
	  if t == d then
		return b + c
	  else
		return c * 1.001 * (-pow(2, -10 * t / d) + 1) + b
	  end
	end

	local function inOutExpo(t, b, c, d)
	  if t == 0 then return b end
	  if t == d then return b + c end
	  t = t / d * 2
	  if t < 1 then
		return c / 2 * pow(2, 10 * (t - 1)) + b - c * 0.0005
	  else
		t = t - 1
		return c / 2 * 1.0005 * (-pow(2, -10 * t) + 2) + b
	  end
	end

	local function outInExpo(t, b, c, d)
	  if t < d / 2 then
		return outExpo(t * 2, b, c / 2, d)
	  else
		return inExpo((t * 2) - d, b + c / 2, c / 2, d)
	  end
	end

	local function inCirc(t, b, c, d)
	  t = t / d
	  return(-c * (sqrt(1 - pow(t, 2)) - 1) + b)
	end

	local function outCirc(t, b, c, d)
	  t = t / d - 1
	  return(c * sqrt(1 - pow(t, 2)) + b)
	end

	local function inOutCirc(t, b, c, d)
	  t = t / d * 2
	  if t < 1 then
		return -c / 2 * (sqrt(1 - t * t) - 1) + b
	  else
		t = t - 2
		return c / 2 * (sqrt(1 - t * t) + 1) + b
	  end
	end

	local function outInCirc(t, b, c, d)
	  if t < d / 2 then
		return outCirc(t * 2, b, c / 2, d)
	  else
		return inCirc((t * 2) - d, b + c / 2, c / 2, d)
	  end
	end

	local function inElastic(t, b, c, d, a, p)
	  if t == 0 then return b end

	  t = t / d

	  if t == 1  then return b + c end

	  if not p then p = d * 0.3 end

	  local s

	  if not a or a < abs(c) then
		a = c
		s = p / 4
	  else
		s = p / (2 * pi) * asin(c/a)
	  end

	  t = t - 1

	  return -(a * pow(2, 10 * t) * sin((t * d - s) * (2 * pi) / p)) + b
	end

	-- a: amplitud
	-- p: period
	local function outElastic(t, b, c, d, a, p)
	  if t == 0 then return b end

	  t = t / d

	  if t == 1 then return b + c end

	  if not p then p = d * 0.3 end

	  local s

	  if not a or a < abs(c) then
		a = c
		s = p / 4
	  else
		s = p / (2 * pi) * asin(c/a)
	  end

	  return a * pow(2, -10 * t) * sin((t * d - s) * (2 * pi) / p) + c + b
	end

	-- p = period
	-- a = amplitud
	local function inOutElastic(t, b, c, d, a, p)
	  if t == 0 then return b end

	  t = t / d * 2

	  if t == 2 then return b + c end

	  if not p then p = d * (0.3 * 1.5) end
	  if not a then a = 0 end

	  if not a or a < abs(c) then
		a = c
		s = p / 4
	  else
		s = p / (2 * pi) * asin(c / a)
	  end

	  if t < 1 then
		t = t - 1
		return -0.5 * (a * pow(2, 10 * t) * sin((t * d - s) * (2 * pi) / p)) + b
	  else
		t = t - 1
		return a * pow(2, -10 * t) * sin((t * d - s) * (2 * pi) / p ) * 0.5 + c + b
	  end
	end

	-- a: amplitud
	-- p: period
	local function outInElastic(t, b, c, d, a, p)
	  if t < d / 2 then
		return outElastic(t * 2, b, c / 2, d, a, p)
	  else
		return inElastic((t * 2) - d, b + c / 2, c / 2, d, a, p)
	  end
	end

	local function inBack(t, b, c, d, s)
	  if not s then s = 1.70158 end
	  t = t / d
	  return c * t * t * ((s + 1) * t - s) + b
	end

	local function outBack(t, b, c, d, s)
	  if not s then s = 1.70158 end
	  t = t / d - 1
	  return c * (t * t * ((s + 1) * t + s) + 1) + b
	end

	local function inOutBack(t, b, c, d, s)
	  if not s then s = 1.70158 end
	  s = s * 1.525
	  t = t / d * 2
	  if t < 1 then
		return c / 2 * (t * t * ((s + 1) * t - s)) + b
	  else
		t = t - 2
		return c / 2 * (t * t * ((s + 1) * t + s) + 2) + b
	  end
	end

	local function outInBack(t, b, c, d, s)
	  if t < d / 2 then
		return outBack(t * 2, b, c / 2, d, s)
	  else
		return inBack((t * 2) - d, b + c / 2, c / 2, d, s)
	  end
	end

	local function outBounce(t, b, c, d)
	  t = t / d
	  if t < 1 / 2.75 then
		return c * (7.5625 * t * t) + b
	  elseif t < 2 / 2.75 then
		t = t - (1.5 / 2.75)
		return c * (7.5625 * t * t + 0.75) + b
	  elseif t < 2.5 / 2.75 then
		t = t - (2.25 / 2.75)
		return c * (7.5625 * t * t + 0.9375) + b
	  else
		t = t - (2.625 / 2.75)
		return c * (7.5625 * t * t + 0.984375) + b
	  end
	end

	local function inBounce(t, b, c, d)
	  return c - outBounce(d - t, 0, c, d) + b
	end

	local function inOutBounce(t, b, c, d)
	  if t < d / 2 then
		return inBounce(t * 2, 0, c, d) * 0.5 + b
	  else
		return outBounce(t * 2 - d, 0, c, d) * 0.5 + c * .5 + b
	  end
	end

	local function outInBounce(t, b, c, d)
	  if t < d / 2 then
		return outBounce(t * 2, b, c / 2, d)
	  else
		return inBounce((t * 2) - d, b + c / 2, c / 2, d)
	  end
	end

	return {
	  linear = linear,
	  inQuad = inQuad,
	  outQuad = outQuad,
	  inOutQuad = inOutQuad,
	  outInQuad = outInQuad,
	  inCubic  = inCubic ,
	  outCubic = outCubic,
	  inOutCubic = inOutCubic,
	  outInCubic = outInCubic,
	  inQuart = inQuart,
	  outQuart = outQuart,
	  inOutQuart = inOutQuart,
	  outInQuart = outInQuart,
	  inQuint = inQuint,
	  outQuint = outQuint,
	  inOutQuint = inOutQuint,
	  outInQuint = outInQuint,
	  inSine = inSine,
	  outSine = outSine,
	  inOutSine = inOutSine,
	  outInSine = outInSine,
	  inExpo = inExpo,
	  outExpo = outExpo,
	  inOutExpo = inOutExpo,
	  outInExpo = outInExpo,
	  inCirc = inCirc,
	  outCirc = outCirc,
	  inOutCirc = inOutCirc,
	  outInCirc = outInCirc,
	  inElastic = inElastic,
	  outElastic = outElastic,
	  inOutElastic = inOutElastic,
	  outInElastic = outInElastic,
	  inBack = inBack,
	  outBack = outBack,
	  inOutBack = inOutBack,
	  outInBack = outInBack,
	  inBounce = inBounce,
	  outBounce = outBounce,
	  inOutBounce = inOutBounce,
	  outInBounce = outInBounce,
	}
end

function CameraShakeControlled(multiplier, duration, widget)
	local multiplier 			= multiplier 		or 0.3
	local duration 				= duration 			or 500
	local slideDuration 		= slideDuration 	or 50
	local negX, negY 			= false, false
	
	local target = widget or UIManager.GetActiveInterface()

	local doIt
	
	doIt = function()

		local randomOffsetX = math.random(0,10) * multiplier
		local randomOffsetY = math.random(0,10) * multiplier
		
		if (negX) then
			negX = false
			randomOffsetX = randomOffsetX * -1
		else
			negX = true
		end
		
		if (negY) then
			negY = false
			randomOffsetY = randomOffsetY * -1
		else
			negY = true
		end		

		target:SlideX(randomOffsetX, slideDuration, true)		
		target:SlideY(randomOffsetY, slideDuration, true)		
	end
	
	libThread.threadFunc(function()	
		while (duration > 0) do
			doIt()	
			wait(slideDuration)
			duration = duration - slideDuration
		end
		wait(slideDuration)
		target:SlideX(0, slideDuration, true)		
		target:SlideY(0, slideDuration, true)				
	end)
end

function CameraShake(multiplier, duration, widget)
	local multiplier 			= multiplier 		or 1
	local duration 				= duration 			or 1000
	local slideDuration 		= slideDuration 	or 50
	
	local target = widget or UIManager.GetActiveInterface()

	local doIt
	
	doIt = function()

		local randomOffsetX = math.random(0,3) * multiplier
		local randomOffsetY = math.random(0,3) * multiplier
		
		target:SlideX(randomOffsetX, slideDuration, true)		
		target:SlideY(randomOffsetY, slideDuration, true)		
	end
	
	libThread.threadFunc(function()	
		while (duration > 0) do
			doIt()	
			wait(slideDuration)
			duration = duration - slideDuration
		end
		wait(slideDuration)
		target:SlideX(0, slideDuration, true)		
		target:SlideY(0, slideDuration, true)				
	end)
end

local animsTable = Anims()
function StaggeredAnimationInX(widget)

	local oldOnShow = widget:GetCallback('onshow')
	
	local maxTime =  2500 -- half screen
	local timePerPixel = maxTime / (GetScreenWidth() / 2)
	
	
	widget:SetCallback('onshow', function(widget)
		
		local endRelX = self:GetX()
		
		local absX = self:GetAbsoluteX()
		
		local width = self:GetWidth()

		local duration = (absX * timePerPixel)
		local startDelay = maxTime - duration
		
		self:SetX(endRelX - (absX + width), true)
		
		local startRelX = self:GetX()
		
		self:Sleep(startDelay, function(widget)
			-- self:SlideX(endRelX, duration)
			
			local startTime = GetTime()
			widget:RegisterWatchLua('System', function(widget, trigger)
				
				local currentTime = trigger.hostTime - startTime
				
				widget:SetX( animsTable.outBounce(currentTime, startRelX, endRelX - startRelX, duration) )
				
				if (widget:GetX() == endRelX) or (trigger.hostTime >= (startTime + duration)) then
					widget:UnregisterWatchLua('System')
				end
				
			end, false, nil, 'hostTime')			
			
		end)		
		
		if (oldOnShow) then
			oldOnShow()
		end
	end)
	
end

function StaggeredAnimationInY(widget)

	local oldOnShow = widget:GetCallback('onshow')
	
	local maxTime =  400 -- half screen
	local timePerPixel = maxTime / (GetScreenHeight() / 2)
	
	
	widget:SetCallback('onshow', function(widget)
		
		local endRelY = self:GetY()
		
		local absY = self:GetAbsoluteY()
		
		local height = self:GetHeight()

		local duration = (absY * timePerPixel)
		local startDelay = maxTime - duration
		
		self:SetY((endRelY + ((GetScreenHeight() + absY) - height) - (GetScreenHeight() * 0.7)), true)
		
		local startRelY = self:GetY()
		
		self:Sleep(startDelay, function(widget)
			-- self:SlideY(endRelY, duration)
			
			local startTime = GetTime()
			local system = GetTrigger('System')
			
			widget:SetCallback('onframe', function(widget)
				
				local currentTime = (system.hostTime - startTime)
				
				widget:SetY( animsTable.outCubic(currentTime, startRelY, endRelY - startRelY, duration) )
				
				if (widget:GetY() <= endRelY) then
					widget:ClearCallback('onframe')
					widget:SetY(endRelY)
				end
				
			end)			
			
		end)		
		
		if (oldOnShow) then
			oldOnShow()
		end
	end)
	
end

function StaggeredAnimationInY2(self)

	local maxTime =  300 -- half screen
	local timePerPixel = maxTime / (GetScreenHeight() / 2)

	local endRelY = self:GetY()
	
	local absY = self:GetAbsoluteY()
	
	local height = self:GetHeight()

	local duration = (absY * timePerPixel)
	local startDelay = maxTime - duration
	
	self:SetY((endRelY + ((GetScreenHeight() + absY) - height) - (GetScreenHeight() * 1.3)), true)
	
	local startRelY = self:GetY()
	
	self:Sleep(startDelay, function(widget)
		-- self:SlideY(endRelY, duration)
		
		local startTime = GetTime()
		local system = GetTrigger('System')
		
		widget:SetCallback('onframe', function(widget)
			
			local currentTime = (system.hostTime - startTime)
			
			widget:SetY( animsTable.outCubic(currentTime, startRelY, endRelY - startRelY, duration) )
			
			if (widget:GetY() <= endRelY) then
				widget:ClearCallback('onframe')
				widget:SetY(endRelY)
			end
			
		end)			
		
	end)		
	
end


function RadialEaseIn(widget, startingX, startingY, widgetStartingAlign, widgetStartingVAlign, centerPointX, centerPointY)

	local GetTrigger = LuaTrigger.GetTrigger
	
	widget:SetVisible(0)
	widget:FadeOut(0)
	widget:Sleep(1, function()
	
	widget:SetVAlign(widgetStartingVAlign)
	widget:SetAlign(widgetStartingAlign)

	widget:Sleep(1, function()
	
	widget:UICmd([[SetAbsoluteX(]] .. startingX .. [[)]]) 
	widget:UICmd([[SetAbsoluteY(]] .. startingY .. [[)]]) 

	widget:Sleep(1, function()
		
		local self = widget
		
		local centerPointX	 =		centerPointX or widget:GetXFromString('640s')
		local centerPointY	 =		centerPointY or widget:GetYFromString('330s')
		local maximumOffsetY =   	widget:GetYFromString('640s') -- GetScreenHeight() / 2
		local maximumOffsetX =   	widget:GetXFromString('640s') -- GetScreenWidth() / 2
		local maxTime 		 =  	styles_mainSwapAnimationDuration * 1.5 -- move in place exactly on time
		local timePerPixelY  =  	maxTime / (GetScreenHeight() / 2)
		local timePerPixelX  = 	    maxTime / (GetScreenWidth() / 2)

		local endRelY 		= self:GetY()
		local endRelX 		= self:GetX()
		local absY 			= self:GetAbsoluteY()
		local absYOffset 	= self:GetAbsoluteY() - (self:GetHeight()/2)
		local absX 			= self:GetAbsoluteX()
		local absXOffset 	= self:GetAbsoluteX() - (self:GetWidth()/2)

		if (oldAlign == 'left') then
			absXOffset = (absX + (widget:GetWidth()/2))
		elseif (oldAlign == 'right')  then
			absXOffset = (absX - (widget:GetWidth()/2))
		else
			absXOffset = absX
		end
		
		if (oldAlign == 'top') then
			absYOffset = (absY + (widget:GetHeight()/2))
		elseif (oldAlign == 'bottom') then
			absYOffset = (absY - (widget:GetHeight()/2))
		else
			absYOffset = absY
		end			

		local offsetMultiplierY = 1
		local offsetMultiplierX = 1
		
		local oldAlign = self:GetAlign()
		local oldVAlign = self:GetVAlign()
		
		self:SetVAlign('top')		
		self:SetAlign('left')
		
		local targetX = 0
		local targetY = 0
		
		if (absYOffset >= centerPointY) then
			offsetMultiplierY = math.min(maximumOffsetY, (absYOffset - centerPointY)) / maximumOffsetY
			offsetMultiplierY = ((offsetMultiplierY^2)^0.5)
			targetY			= ((endRelY + (maximumOffsetY * offsetMultiplierY)) + (self:GetHeight()))			
		else
			offsetMultiplierY = math.min(maximumOffsetY, (centerPointY - absYOffset)) / maximumOffsetY
			offsetMultiplierY = ((offsetMultiplierY^2)^0.5)
			targetY			= ((endRelY - (maximumOffsetY * offsetMultiplierY)) + (self:GetHeight()))			
		end
		
		self:SetY(targetY, true)
		
		if (absXOffset >= centerPointX) then	
			offsetMultiplierX = math.min(maximumOffsetX, (absXOffset - centerPointX)) / maximumOffsetX
			offsetMultiplierX = ((offsetMultiplierX^2)^0.5)
			targetX			  = ((endRelX + (maximumOffsetX * offsetMultiplierX)) + (self:GetWidth()))
		else
			offsetMultiplierX = math.min(maximumOffsetX, (centerPointX - absXOffset)) / maximumOffsetX
			offsetMultiplierX = ((offsetMultiplierX^2)^0.5)
			targetX			  = ((endRelX - (maximumOffsetX * offsetMultiplierX)) + (self:GetWidth()))
		end			
		
		self:SetX(targetX, true)
		
		local duration = math.max(((maximumOffsetY * offsetMultiplierY) * timePerPixelY), ((maximumOffsetX * offsetMultiplierX) * timePerPixelX))		
		duration = math.max(duration, (0.2 * maxTime))
		
		local startRelY = self:GetY()				
		local startRelX = self:GetX()				
		
		local startTime = GetTime()
		local system = GetTrigger('System')
		
		widget:FadeIn(styles_mainSwapAnimationDuration * 0.6)
		
		widget:SetCallback('onframe', function(self)
			
			local currentTime = (system.hostTime - startTime)
			
			self:SetY( animsTable.outCubic(currentTime, startRelY, endRelY - startRelY, duration) )
			self:SetX( animsTable.outCubic(currentTime, startRelX, endRelX - startRelX, duration) )
			
			if  ((self:GetY() <= endRelY) and (absYOffset >= centerPointY)) or ((self:GetY() >= endRelY) and (absYOffset < centerPointY)) 
			or	((self:GetX() <= endRelX) and (absXOffset >= centerPointX)) or ((self:GetX() >= endRelX) and (absXOffset < centerPointX)) then
				self:ClearCallback('onframe')

				self:SlideY(endRelY, 150, function() 
					self:SetVAlign(oldVAlign) 
					self:UICmd([[SetAbsoluteY(]] .. absY .. [[)]]) 
				end)
				self:SlideX(endRelX, 150, function() 
					self:SetAlign(oldAlign) 
					self:UICmd([[SetAbsoluteX(]] .. absX .. [[)]]) 
				end)
			end
			
		end)
	end)
	end)
	end)

end

function RadialEaseOut(widget, startingX, startingY, centerPointX, centerPointY)

	local oldAlign  = widget:GetAlign()
	local oldVAlign = widget:GetVAlign()

	local centerPointX	 =		centerPointX or widget:GetXFromString('640s')
	local centerPointY	 =		centerPointY or widget:GetYFromString('330s')
	local maximumOffsetY =   	widget:GetYFromString('640s')
	local maximumOffsetX =   	widget:GetXFromString('640s')
	local maxTime 		 =  	styles_mainSwapAnimationDuration
	local timePerPixelY  =  	maxTime / (GetScreenHeight() / 2) 
	local timePerPixelX  = 	    maxTime / (GetScreenWidth() / 2)
	local exaggerationX	 =      1
	local exaggerationY	 =      1
	
	local endRelY 		= widget:GetY()
	local endRelX 		= widget:GetX()
	local absY 			= widget:GetAbsoluteY()
	local absYOffset
	local absX 			= widget:GetAbsoluteX()
	local absXOffset
	
	if (oldAlign == 'left') then
		absXOffset = (absX + (widget:GetWidth()/2))
	elseif (oldAlign == 'right')  then
		absXOffset = (absX - (widget:GetWidth()/2))
	else
		absXOffset = absX
	end
	
	if (oldAlign == 'top') then
		absYOffset = (absY + (widget:GetHeight()/2))
	elseif (oldAlign == 'bottom') then
		absYOffset = (absY - (widget:GetHeight()/2))
	else
		absYOffset = absY
	end	
	
	local offsetMultiplierY = 1
	local offsetMultiplierX = 1
	
	widget:FadeOut(styles_mainSwapAnimationDuration * 0.4)
	widget:SetVAlign('top')		
	widget:SetAlign('left')
	
	local targetX = 0
	local targetY = 0	

	if (absYOffset >= centerPointY) then
		offsetMultiplierY = math.min(maximumOffsetY, (absYOffset - centerPointY)) / maximumOffsetY
		offsetMultiplierY = ((offsetMultiplierY^2)^0.5)
		offsetMultiplierY = offsetMultiplierY
		targetY			= ((endRelY + (maximumOffsetY * offsetMultiplierY)) + (widget:GetHeight())) * exaggerationY
	else
		offsetMultiplierY = math.min(maximumOffsetY, (centerPointY - absYOffset)) / maximumOffsetY
		offsetMultiplierY = ((offsetMultiplierY^2)^0.5)
		offsetMultiplierY = offsetMultiplierY
		targetY			= ((endRelY - (maximumOffsetY * offsetMultiplierY)) + (widget:GetHeight())) * exaggerationY
	end

	if (absXOffset >= centerPointX) then	
		offsetMultiplierX = math.min(maximumOffsetX, (absXOffset - centerPointX)) / maximumOffsetX
		offsetMultiplierX = ((offsetMultiplierX^2)^0.5)
		offsetMultiplierX = offsetMultiplierX
		targetX			  = ((endRelX + (maximumOffsetX * offsetMultiplierX)) + (widget:GetWidth())) * exaggerationX
	else
		offsetMultiplierX = math.min(maximumOffsetX, (centerPointX - absXOffset)) / maximumOffsetX
		offsetMultiplierX = ((offsetMultiplierX^2)^0.5)
		offsetMultiplierX = offsetMultiplierX
		targetX			  = ((endRelX - (maximumOffsetX * offsetMultiplierX)) + (widget:GetWidth())) * exaggerationX
	end			
	
	local durationX = math.max(((maximumOffsetX * offsetMultiplierX) * timePerPixelX), (maxTime * 0.3))
	local durationY = math.max(((maximumOffsetY * offsetMultiplierY) * timePerPixelY), (maxTime * 0.3))	
	local duration = math.max(durationY, durationX)
	
	local startTime = GetTime()
	local system = GetTrigger('System')
	
	local distanceY = endRelY - targetY
	local distanceX = endRelX - targetX

	widget:SetCallback('onframe', function(self)
		
		local currentTime = (system.hostTime - startTime)

		self:SetY((targetY + (animsTable.inCubic(currentTime, distanceY, targetY, duration)) ))
		self:SetX((targetX + (animsTable.inCubic(currentTime, distanceX, targetX, duration)) ))			

		if	( ((self:GetY() <= targetY) and (absYOffset < centerPointY)) or ((self:GetY() >= targetY) and (absYOffset >= centerPointY)) ) and
			( ((self:GetX() <= targetX) and (absXOffset < centerPointX)) or ((self:GetX() >= targetX) and (absXOffset >= centerPointX)) ) then
			self:ClearCallback('onframe')
		end		
		
	end)

end

RegisterRadialEaseStartingOverrides = {} -- This should be filled as such: radialEaseStartingOverrides[widget] = {x, y} - and will serve as the starting positions for the radial ease.
function RegisterRadialEase(widget, centerPointX, centerPointY, registerWhileHidden)

	-- if ((widget:GetName()) ~= 'main_landing_button_0_1') then
		-- return
	-- end
	
	if ((widget:GetCallback('onevent7')) and type(widget:GetCallback('onevent7') == 'function')) or ((widget:GetCallback('onevent8')) and type(widget:GetCallback('onevent8') == 'function')) then
		-- println('^r did not register ' .. widget:GetName())
		return
	end

	-- println('^g registered ' .. widget:GetName())
	
	local widgetStartingX 		= widget:GetAbsoluteX()
	local widgetStartingY 		= widget:GetAbsoluteY()
	local widgetStartingAlign   = widget:GetAlign()
	local widgetStartingVAlign  = widget:GetVAlign()	
	
	if (widget:IsVisibleSelf()) or (registerWhileHidden) then
		widget:SetCallback('onevent7', function(self)
			-- println('^c onevent7 ' .. widget:GetName())
			self:SetVisible(0)
			local positionOverride = RegisterRadialEaseStartingOverrides[widget]
			if (positionOverride) then
				widgetStartingX = widget:GetXFromString(positionOverride[1])
				widgetStartingY = widget:GetYFromString(positionOverride[2])
			end
			RadialEaseIn(self, widgetStartingX, widgetStartingY, widgetStartingAlign, widgetStartingVAlign, centerPointX, centerPointY)
		end)
		
		widget:SetCallback('onevent8', function(self)
			-- println('^c onevent8 ' .. widget:GetName())
			RadialEaseOut(self, widgetStartingX, widgetStartingY, centerPointX, centerPointY)
		end)
		
		widget:RefreshCallbacks()
	else
		-- println('was not visible RegisterRadialEase ' .. widget:GetName() )
	end
	
end

function fadeWidget(widget, visible, delay)
	local delay = delay or styles_mainSwapAnimationDuration
	if (widget) and (widget:IsValid()) then
		if (visible) then
			widget:FadeIn(delay)
		else
			widget:FadeOut(delay)
		end
	end
end

-- Given a widget, optionally mirror it, and all of it's children
-- flipImages - whether to horizontally flip images too
-- notFirst - true if you want to move the widget passed, false if just it's children
-- dontRecurse - true if you don't want to recursively go to children
-- excludedList - table containing names of children to not recurse to.
function FlipWidgets(widget, flipImages, speed, notFirst, dontRecurse, excludedList)
	notFirst = notFirst or false
	flipImages = flipImages or false
	excludedList = excludedList or {}
	speed = speed or 1
	if (speed < 1) then
		speed = 1
	end
	
	if notFirst then
		local parent = widget:GetParent()
		local x = widget:GetX()
		local dest = 0
		if widget:GetAlign() == 'center' then
			local width = (widget:GetType() == 'label' and GetStringWidth(widget:GetFont(), widget:GetText())) or widget:GetWidth()
			dest = -((x-parent:GetWidth()/2)+width/2)
		elseif widget:GetAlign() == 'right' then
			local width = (widget:GetType() == 'label' and GetStringWidth(widget:GetFont(), widget:GetText())) or widget:GetWidth()
			dest = -x + (widget:GetWidth()-width)
		else
			local width = (widget:GetType() == 'label' and widget:GetTextAlign() == 'left' and GetStringWidth(widget:GetFont(), widget:GetText())) or widget:GetWidth()
			width = math.min(width, widget:GetWidth())
			dest = parent:GetWidth()-(x+width)
		end
		widget:SlideX(dest, speed)
		
		if flipImages then
			widget:SetHFlip(not widget:GetHFlip())
		end
	end
	
	
	if (#widget:GetChildren() > 0 and not dontRecurse) then
		for index, value in pairs(widget:GetChildren()) do
			if (value:IsValid() and not IsInTable(excludedList, value:GetName())) then
				FlipWidgets(value, flipImages, speed, true)
			end
		end
	end
end

-- local function flipEverything(widget)
	-- if (widget) then
		-- for index, value in pairs(widget:GetChildren()) do
			-- value:SetHFlip(true)
			-- if (#value:GetChildren() > 0) then
				-- flipEverything(value)
			-- end
		-- end
	-- end
-- end
-- function FlipEverything(widget)
	-- flipEverything(widget)
-- end
-- FlipEverything(UIManager.GetActiveInterface())

-- function GetMeanAndStdDeviation(values)
	-- local sum,n = 0,#values
	-- for i = 1,n do
		-- sum = sum + values[i]
	-- end
	-- local mean = sum/n
	-- sum = 0,0
	-- for i = 1,n do
		-- sum = sum + (mean - values[i])^2
	-- end
	-- return mean, math.sqrt(sum/n)
-- end

-- local function escapeCSV(text)
	-- if string.find(text, '[,"]') then
		-- text = '"' .. string.gsub(text, '"', '""') .. '"'
	-- end
	-- return text
-- end

-- local function toCSV(incTable)
	-- local text = ""
	-- for _,p in ipairs(incTable) do  
		-- text = text .. "," .. escapeCSV(p)
	-- end
	-- return string.sub(text, 2)
-- end

-- local function toMultiLineString(incTable)
	-- local text = ''
	-- for _,v in ipairs(incTable) do  
		-- text = text .. '\n' .. v
	-- end
	-- return text
-- end

-- function WriteOutputFile(fileName, incTable)
	-- local file = io.open(fileName, "w")
	-- file:write(toMultiLineString(incTable))
	-- file:flush()
	-- file:close()
-- end

local widgetsUsingTexture = {}
local function findWhatWidgetIsUsingThisTexture(widget, texture)
	if (not widget) then return end
	
	for index, value in pairs(widget:GetChildren()) do
		if (value:GetType() == 'image') or (value:GetType() == 'frame') or (value:GetType() == 'panel') then
			local widgetTexture = value:GetTexture()
			if widgetTexture and widgetTexture == texture then
				table.insert(widgetsUsingTexture, value)
			end
		end

		if (#value:GetChildren() > 0) then
			findWhatWidgetIsUsingThisTexture(value, texture)
		end
	end
end

function FindWhatWidgetIsUsingThisTexture(widget, texture)
	widgetsUsingTexture = {}
	findWhatWidgetIsUsingThisTexture(widget, texture)
	if (widgetsUsingTexture) and (#widgetsUsingTexture > 0) then
		return widgetsUsingTexture
	else
		return false
	end
end

function ShowTextureUsage(minimumSize, filter, findWidgets)
	local minimumSize 	= minimumSize or 20000
	local filter 		= filter or [[/ui/]]
	local findWidgets 	= findWidgets or false
	
	println('^g ShowTextureUsage(minimumSize, filter, findWidgets)')
	println('^g minimumSize: ' .. tostring(minimumSize))
	println('^g filter: ' .. tostring(filter))
	println('^g findWidgets: ' .. tostring(findWidgets))
	
	Cmd('ExportTextureCSV')
	
	libThread.threadFunc(function()	
		wait(200)

		local function readFile(filePath)
			println('^g readFile ' .. filePath)
			local f = io.open(filePath, "rb")
			local content = f:read("*all")
			f:close()
			return content
		end

		local function parseCSVLine (line,sep) -- From http://lua-users.org/wiki/LuaCsv
			local res = {}
			local pos = 1
			sep = sep or ','
			while true do 
				local c = string.sub(line,pos,pos)
				if (c == "") then break end
				if (c == '"') then
					-- quoted value (ignore separator within)
					local txt = ""
					repeat
						local startp,endp = string.find(line,'^%b""',pos)
						txt = txt..string.sub(line,startp+1,endp-1)
						pos = endp + 1
						c = string.sub(line,pos,pos) 
						if (c == '"') then txt = txt..'"' end 
						-- check first char AFTER quoted string, if it is another
						-- quoted string without separator, then append it
						-- this is the way to "escape" the quote char in a quote. example:
						--   value1,"blub""blip""boing",value3  will result in blub"blip"boing  for the middle
					until (c ~= '"')
					table.insert(res,txt)
					assert(c == sep or c == "")
					pos = pos + 1
				else	
					-- no quotes used, just look for the first separator
					local startp,endp = string.find(line,sep,pos)
					if (startp) then 
						table.insert(res,string.sub(line,pos,startp-1))
						pos = endp + 1
					else
						-- no separator found -> use rest of string and terminate
						table.insert(res,string.sub(line,pos))
						break
					end 
				end
			end
			return res
		end	
		
		local filePath = '~/textures.csv'
		filePath = FileManager.GetSystemPath(filePath)	
		
		local fileContentsString = readFile(filePath)	
		local fileContentsTableOfStringLines = explode('\n', fileContentsString)
		local fileTable = {}
		local textureCount = 0
		local textureSize = 0
		local textureDisplayedSize = 0
		for i,v in ipairs(fileContentsTableOfStringLines) do
			local lineTable = parseCSVLine(v)
			if (lineTable[3]) and (not Empty(lineTable[3])) and (lineTable[7]) and tonumber(lineTable[7]) then
				if (tonumber(lineTable[7]) > minimumSize)  and string.find(lineTable[3], filter) then
					table.insert(fileTable, {name = lineTable[3], size = lineTable[7]})
					textureDisplayedSize = textureDisplayedSize + tonumber(lineTable[7])
				end
				textureCount = textureCount + 1
				textureSize = textureSize + tonumber(lineTable[7])
			end
		end
		
		table.sort(fileTable, function(a,b) 
			if (a.size) and (tonumber(a.size)) then
				if (b.size) and (tonumber(b.size)) then
					return tonumber(a.size) > tonumber(b.size)
				else
					return true
				end
			else
				return false
			end
		end)
		
		for i,v in ipairs(fileTable) do
			println('^c' .. FtoA2(((v.size/1024)/1024),0,2) .. ' ^y' .. v.name)
			if (findWidgets) then
				local widgets = FindWhatWidgetIsUsingThisTexture(interface, v.name)
				if (widgets) then
					println('widgets using this texture:')
					for i,v in ipairs(widgets) do
						println(v:GetName() .. ' - ' .. tostring(v))
					end
				end
			end
		end
		
		println(#fileTable .. ' displayed of ' .. textureCount .. ' textures found')
		println(FtoA2(((textureDisplayedSize/1024)/1024),0,2) .. ' memory use displayed of ' .. FtoA2(((textureSize/1024)/1024),0,2) .. ' usage found')
		
	end)
	
end

-- UICmd GetWidthFromString doesn't work with % or @. This works with everything.
-- % needs height param as true/false for obvious reasons.
function getMeasurementFromString(widget, measurement, height)
	if measurement:find('@', #measurement) then -- ends with @, the same as height and %
		height = true;
		measurement = string.sub(measurement, 1, #measurement-1).."%"
	end
	if measurement:find("%%", #measurement) then -- ends with %
		local parent = widget:GetParent()
		local percent = tonumber(string.sub(measurement, 1, #measurement-1))
		if not height then
			return parent:GetWidth()*percent/100
		else
			return parent:GetHeight()*percent/100
		end
	end
	-- Not a varying number - then just use the normal method.
	return tonumber(widget:UICmd("GetXFromString("..measurement..")"))
end

local ScaleInPlaceThreads = {}
local ScaleInPlaceInitialPositions = {}
-- Scales a widget outwards/inwards towards it's center - regardless of float/alignment etc
function ScaleInPlace(widget, width, height, duration, recurse, reset)
	local recurse = recurse or false
	
	if (not ScaleInPlaceInitialPositions[widget]) then
		ScaleInPlaceInitialPositions[widget] = {widget:GetX(), widget:GetY()}
	end
	
	local parent = widget:GetParent()
	
	local currentX = widget:GetAbsoluteX() - parent:GetAbsoluteX()
	local currentY = widget:GetAbsoluteY() - parent:GetAbsoluteY()
	local desiredWidth = getMeasurementFromString(widget, width)
	local desiredHeight = getMeasurementFromString(widget, height, true)
	local desiredX = currentX - (desiredWidth  - widget:GetWidth() )/2
	local desiredY = currentY - (desiredHeight - widget:GetHeight())/2
	-- Move/scale
	widget:Scale(desiredWidth, desiredHeight, duration, recurse)
	widget:SlideX(reset and ScaleInPlaceInitialPositions[widget][1] or desiredX, duration)
	widget:SlideY(reset and ScaleInPlaceInitialPositions[widget][2] or desiredY, duration)
	-- Thread to fix it snapping back
	if (ScaleInPlaceThreads[widget] and ScaleInPlaceThreads[widget]:IsValid()) then
		ScaleInPlaceThreads[widget]:kill()
	end
	ScaleInPlaceThreads[widget] = libThread.threadFunc(function()
		wait(duration)
		if (widget) and (widget:IsValid()) then
			widget:SetX(reset and ScaleInPlaceInitialPositions[widget][1] or desiredX)
			widget:SetY(reset and ScaleInPlaceInitialPositions[widget][2] or desiredY)
		end
		ScaleInPlaceThreads[widget] = nil
	end)
end

function ClickButton(self, widgetName)
	local self = self or UIManager.GetActiveInterface()
	if (widgetName) then
		local widget = self:GetWidget(widgetName)
		if (widget) then
			local callback = widget:GetCallback('onclick')
			if (callback) then
				callback(widget)
			end
		end
	end
end

function DoubleClickButton(self, widgetName)
	local self = self or UIManager.GetActiveInterface()
	if (widgetName) then
		local widget = self:GetWidget(widgetName)
		if (widget) then
			local callback = widget:GetCallback('ondoubleclick')
			if (callback) then
				callback(widget)
			end
		end
	end
end

function RightClickButton(self, widgetName)
	local self = self or UIManager.GetActiveInterface()
	if (widgetName) then
		local widget = self:GetWidget(widgetName)
		if (widget) then
			local callback = widget:GetCallback('onrightclick')
			if (callback) then
				callback(widget)
			end
		end
	end
end

function OnStartDragButton(self, widgetName)
	local self = self or UIManager.GetActiveInterface()
	if (widgetName) then
		local widget = self:GetWidget(widgetName)
		if (widget) then
			widget:UICmd("BreakDrag()")
			local callback = widget:GetCallback('onstartdrag')
			if (callback) then
				callback(widget)
			end
		end
	end
end

function OnEndDragButton(self, widgetName)
	local self = self or UIManager.GetActiveInterface()
	if (widgetName) then
		local widget = self:GetWidget(widgetName)
		if (widget) then
			local callback = widget:GetCallback('onenddrag')
			if (callback) then
				callback(widget)
			end
		end
	end
end

function AddResourceContext(widget, value)
	--println("Adding context of "..widget:GetName())
	mainUI.resourceContextTable = mainUI.resourceContextTable or {}
	mainUI.resourceContextTable[widget:GetName()] = true
	local type = widget:GetType()
	if (type == "image" or type == "panel") then
		widget:SetTexture(value)
	elseif (type == "model") then
		widget:SetModel(value)
	end
end

function DeleteResourceContext(widget)
	--println("Removing context of "..widget:GetName())
	local type = widget:GetType()
	if (type == "image" or type == "panel") then
		widget:SetTexture('')
	elseif (type == "model") then
		widget:SetModel('')
	end
	libThread.threadFunc(function()
		wait(1)
		if (mainUI.resourceContextTable) and (mainUI.resourceContextTable[widget:GetName()]) then
			mainUI.resourceContextTable[widget:GetName()] = nil
			widget:UICmd('DeleteResourceContext(\''..widget:GetName()..'\')')
		end
	end)
end

-- ======

if GetCvarBool('ui_devStats') then
	dofile(FileManager.GetSystemPath('/ui/dontcommit/churn.lua'))
end

-- =====

local function findClickEaters(widget)
	if (not widget) then return end
	
	for index, value in pairs(widget:GetChildren()) do
		-- table.insert(widgetPointerTable, value)
		
		if (value:IsVisible()) and (value:GetNoClick() == false) and ((value:GetType() == 'panel') or (value:GetType() == 'image') or (value:GetType() == 'frame') or (value:GetType() == 'label') or (value:GetType() == 'modelpanel') or (value:GetType() == 'effect')) then
		
			if (value:GetCallback('onclick')) or (value:GetCallback('onselect')) or (value:GetCallback('onbutton')) or (value:GetCallback('onslide')) or (value:GetCallback('onmouseldown')) or (value:GetType() == 'combobox') or (value:GetType() == 'listitem') then
				hasLeftClick = true
			else
				hasLeftClick = false
			end
			
			if (value:GetCallback('onrightclick')) then
				hasRightClick = true
			else
				hasRightClick = false
			end		
			
			if (value:GetCallback('onstartdrag')) or (value:GetCallback('onenddrag')) then
				hasDrag = true
			else
				hasDrag = false
			end			
			
			if (hasLeftClick) or (hasRightClick) or (hasDrag) then
			
			else
				local name = value:GetName()
				
				if (name) and (not Empty(name)) then
					println('Found click eater called ^y ' .. tostring(name))
				else
					println('Found click eater without a name, so doing a lookup...')
					FindUnnamedWidget(value, 'click_eater')
				end
			end
		
		end
		
		if (#value:GetChildren() > 0) then
			findClickEaters(value)
		end
	end
end

function FindClickEaters(widget)
	if (widget) then
		if type(widget) == 'string' then
			widget = GetWidget(widget)
		end
	else
		widget = UIManager.GetActiveInterface()
	end
	findClickEaters(widget)
end

function ScanAbilities()
	
	for index=0,1000,1 do
	
		local trigger = LuaTrigger.GetTrigger('ActiveInventory'..index)
		
		if (trigger) and (trigger.entity) and (not Empty(trigger.entity)) then
			println(index .. ' ' .. trigger.entity)
		end
		
	end
	
end

-- When called by a function, this will print the parameters and their respective values, of that function.
function printParams()
	local index = 1
	while (true) do
		local var, val = debug.getlocal(2, index)
		if (not var) then break end
		print("^m" .. tostring(var) .. " : ^w")
		printr(val)
		index = index + 1
	end
end

function GetClientInfoTriggerName(identID)
	return 'ChatClientInfo' .. string.gsub(identID, '%.', '')
end

function GetClientInfoTrigger(identID)
	return LuaTrigger.GetTrigger('ChatClientInfo' .. string.gsub(identID, '%.', ''))
end

function GetMyChatClientInfo()
	return GetClientInfoTrigger(GetIdentID())
end

-- Given a number of pixels, a widget and whether the pixels are of height, the unit to convert to, and decimal accuracy, return the equivalent in converted units
function pixelsToUnit(pixels, widget, isHeight, unit, accuracy)
	local accuracy = accuracy or 0
	local multiplier = math.pow(10, accuracy)
	local oneUnitInPixels = (isHeight and widget:GetHeightFromString('10000'..unit) or widget:GetWidthFromString('10000'..unit))/10000
	return math.floor((pixels/oneUnitInPixels)*multiplier + .5)/multiplier .. unit
end

-- Waits for a trigger variable change, and runs a function if it succeeds, or another if it fails. Used in pregame, for the client-feedback for example.
function triggerVarChangeOrFunction(triggerName, var, varValue, waitTime, threadKey, failFunc, successFunc)
	local rndString = threadKey or tostring(math.random())
	local thread = libThread.threadFunc(function()
		wait(waitTime)
		UnwatchLuaTriggerByKey(triggerName, rndString)
		if (failFunc) then failFunc() end
		thread = nil
	end)
	local function succeed()
		UnwatchLuaTriggerByKey(triggerName, rndString)
		thread:kill()
		thread = nil
		if (successFunc) then successFunc() end
	end
	if (LuaTrigger.GetTrigger(triggerName)[var] ~= varValue) then
		UnwatchLuaTriggerByKey(triggerName, rndString)
		WatchLuaTrigger(triggerName, function(trigger)
			if (trigger[var] == varValue) then
				succeed()
			end
		end, rndString, var)
	else
		succeed()
	end
end

-- Hook the PlaySound event, and filter what sounds we are going to play
local oldSoundThread -- To not double up on old sounds, and instead notify on it.
oldPlaySound = oldPlaySound or PlaySound
local lastSound -- To print what the conflicting sound is
local lastSoundTime = 0 -- To know if an old sound is going to conflict a new one
function PlaySound(path)
	local isNewSound = string.find(path, "/ui/sounds/launcher/") or string.find(path, "/heroes/")
	--local usingNewSounds = GetCvarBool('ui_newUISounds')
	--println("Looking to play " .. path .. " Matches: " .. tostring(isNewSound))
	if (isNewSound) then
		if (oldSoundThread and oldSoundThread:IsValid()) then -- Old sound about to play
			println("Warning: Blocked old sound: " .. lastSound)
			oldSoundThread:kill()
		end
		oldPlaySound(path)
		lastSoundTime = GetTime()
	else
		if (GetTime() <= lastSoundTime + 1) then -- New sound playing < 1 ms ago
			println("Warning: Blocked old sound: " .. path)
		else
			lastSound = path
			oldSoundThread = libThread.threadFunc(function()
				wait(1)
				oldPlaySound(path)
			end)
		end
	end
end