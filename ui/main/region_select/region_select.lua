RegionSelect = RegionSelect or {}

local interface = object
local regionSelectClosedTrigger = LuaTrigger.GetTrigger('regionSelectClosed')

local main_customization_region_container = object:GetWidget('main_customization_region_container')
local main_region_selection_container = object:GetWidget('main_region_selection_container')

RegionSelect.loaded = false
local needsRefresh = true

local function isInLobby()
	return LuaTrigger.GetTrigger('GamePhase').gamePhase > 2 and LuaTrigger.GetTrigger('LobbyStatus').inLobby and not LuaTrigger.GetTrigger('PartyStatus').inParty
end
local function isLeader()
	return LuaTrigger.GetTrigger('PartyStatus').isPartyLeader
end
local function isInQueue()
	return LuaTrigger.GetTrigger('PartyStatus').inQueue
end
local function getQueue()
	if isLeader() then
		local queue = LuaTrigger.GetTrigger('selectModeInfo').queuedMode
		if (queue ~= "") then return queue end
	end
	return LuaTrigger.GetTrigger('PartyStatus').queue
end

function RegionSelect.initSettings()
	if not RegionSelect.loaded then return end
	-- Populate regions if leader
	local PartyStatus = LuaTrigger.GetTrigger('PartyStatus')
	local selectModeInfo = LuaTrigger.GetTrigger('selectModeInfo')

	libThread.threadFunc(function()
		wait(2000)
		Client.GetRegionPingList(selectModeInfo.queuedMode)

		main_customization_region_container:UnregisterWatchLua('RegionPingListStatus')
		
		main_customization_region_container:RegisterWatchLua('RegionPingListStatus', function(widget, trigger)
			if (not trigger.isWorking) then
				main_customization_region_container:UnregisterWatchLua('RegionPingListStatus')
			end
		end)
	end)
	
	if (isLeader()) then
		ChatClient.SetPartyQueue(selectModeInfo.queuedMode)
		println('Setting queue to '..selectModeInfo.queuedMode)
		RegionSelect.setRegionString()
	else
		RegionSelect.GetSelectedRegionsFromPartyStatus()
	end
	needsRefresh = true
end

function RegionSelect.hideRegions()
	if not RegionSelect.loaded then return end
	if (isLeader()) then
		RegionSelect.setRegionString() -- Set regions when closing
	end
	main_region_selection_container:FadeOut(150)
	regionSelectClosedTrigger:Trigger()
	SaveState()	
end
function RegionSelect.showRegions()
	if not RegionSelect.loaded then return end
	if (GetCvarBool('ui_newUISounds')) then PlaySound('/ui/sounds/launcher/sfx_region.wav') end
	RegionSelect.populateRegions()
	main_region_selection_container:FadeIn(150)
end
object:GetWidget("main_region_selection_background"):SetCallback('onclick', function(widget)
	RegionSelect.hideRegions()
end)
object:GetWidget("main_region_selection_close"):SetCallback('onclick', function(widget)
	RegionSelect.hideRegions()
end)
object:GetWidget("main_region_selection_ok_btn"):SetCallback('onclick', function(widget)
	RegionSelect.hideRegions()
end)

function RegionSelect.setRegionString() -- Set the region string to either user selected, or default
	if not RegionSelect.loaded then return end
	local queue = getQueue()
	if not mainUI.savedLocally.matchmakingLocalRegionTable[queue] then
		println("^rNo regions for mode: "..queue)
		return
	end
	local region
	for k, v in pairs(mainUI.savedLocally.matchmakingLocalRegionTable[queue]) do
		if (v.userSelected) and (v.enabled) and (v.visible) then region = (region and region .. "," .. k) or k end
	end
	if (not region) then
		for k, v in pairs(mainUI.savedLocally.matchmakingLocalRegionTable[queue]) do
			if (v.default) and (v.enabled) and (v.visible) then region = (region and region .. "," .. k) or k end
		end
	end
	if (region) then
		println('Setting region string to ' .. region)
		ChatClient.SetPartyRegion(region)
	end
end

function RegionSelect.numUserSelected() -- Get the number of regions the user has selected
	if not RegionSelect.loaded then return end
	local regions = mainUI.savedLocally.matchmakingLocalRegionTable[getQueue()]
	if (not regions) then return end
	local numSelected = 0
	for _, v2 in pairs(regions) do
		if (v2.enabled and v2.userSelected) then
			numSelected = numSelected + 1
		end
	end
	return numSelected
end

function RegionSelect.getShortRegionName(name) -- Given a full region name, get it's shortened version
	if not RegionSelect.loaded then return end
	-- Scan regions to find the region name
	for _, a in pairs(mainUI.savedLocally.matchmakingLocalRegionTable) do
		for k, v in pairs(a) do
			if (Translate('game_region_'..k) == name) then return k end
		end
	end
end

function RegionSelect.getFirstSelectedRegion() -- Get the short name of the first region we have selected if party leader, or first in the queue string if not
	if not RegionSelect.loaded then return end
	if (isInLobby()) then
		return RegionSelect.getShortRegionName(LuaTrigger.GetTrigger('LobbyGameInfo').serverName)
	end
	if (not mainUI.savedLocally.matchmakingLocalRegionTable[getQueue()]) then return '---' end
	if isLeader() then
		for k, v in pairs(mainUI.savedLocally.matchmakingLocalRegionTable[getQueue()]) do
			if (v.userSelected) and (v.enabled) and (v.visible) then return k end
		end
	elseif (mainUI.savedLocally.matchmakingLocalRegionTable[getQueue()]) then
		for k, v in pairs(mainUI.savedLocally.matchmakingLocalRegionTable[getQueue()]) do
			if (v.selected) and (v.enabled) and (v.visible) then return k end
		end
	end
	return '---'
end

function RegionSelect.numSelectedRegion() -- Get the number of internally selected regions
	if not RegionSelect.loaded then return end
	local i = 0
	for k, v in pairs(mainUI.savedLocally.matchmakingLocalRegionTable[getQueue()]) do
		if ((v.userSelected or v.selected) and (v.enabled) and (v.visible)) then i = i + 1 end
	end
	return i
end

function RegionSelect.GetSelectedRegionsFromPartyStatus() -- Renew the regions which are selected
	if not RegionSelect.loaded then return end
	local regions = mainUI.savedLocally.matchmakingLocalRegionTable[getQueue()]
	if not regions then return nil end
	for k, v in pairs(regions) do -- clear old
		v.selected = false
	end
	if (LuaTrigger.GetTrigger('PartyStatus').region ~= '') then
		local selected = split(LuaTrigger.GetTrigger('PartyStatus').region, ",") -- fill with new
		for n = 1, #selected do
			if (regions[selected[n]]) then
				regions[selected[n]].selected = true
			end
		end
		RegionSelect.populateRegions()
		return #selected
	end
	return nil
end

function RegionSelect.GetSelectedRegionsString()
	if not RegionSelect.loaded then return end
	
	local regionToDisplay = RegionSelect.getFirstSelectedRegion()
	if (isInLobby()) then
		return regionToDisplay
	else
		numSelected = RegionSelect.GetSelectedRegionsFromPartyStatus()
		if (not numSelected) then return '---' end
		local postfix = (numSelected > 1) and (' (+'..numSelected-1 ..')') or ''
		if (regionToDisplay) then
			local regionText = Translate('endstats_label_'..string.lower(regionToDisplay))
			if (regionText == 'endstats_label_'..string.lower(regionToDisplay)) then regionText = regionToDisplay end
			return regionText..postfix
		end
	end
	
	return '---'
end

local oldQueue = nil

local function regionsEqual(a, b)
	return (a.visible ~= nil and a.visible == b.visible and a.default == b.default and a.enabled == b.enabled and a.timestamp == b.timestamp)
end

-- Load regions from chat server trigger
function RegionSelect.syncRegions()
	local ChatAvailabilityTrigger = LuaTrigger.GetTrigger('ChatAvailability')
	local triggerQueues = ChatAvailabilityTrigger and ChatAvailabilityTrigger.matchmaking and ChatAvailabilityTrigger.matchmaking.queues
	if not DatabaseLoadStateTrigger or not DatabaseLoadStateTrigger.stateLoaded or not triggerQueues then
		RegionSelect.loaded = false
		return
	end
	needsRefresh = true
	mainUI.savedLocally.matchmakingLocalRegionTable = mainUI.savedLocally.matchmakingLocalRegionTable or {}
	RegionSelect.seenRegions = RegionSelect.seenRegions or {}
	
	for k,v in ipairs(triggerQueues) do
		mainUI.savedLocally.matchmakingLocalRegionTable = mainUI.savedLocally.matchmakingLocalRegionTable or {}
		mainUI.savedLocally.matchmakingLocalRegionTable[v.name] = mainUI.savedLocally.matchmakingLocalRegionTable[v.name] or {}
		RegionSelect.seenRegions[v.name] = true
		for index,regionTable in ipairs(v.regions) do
			mainUI.savedLocally.matchmakingLocalRegionTable[v.name][regionTable.name] = mainUI.savedLocally.matchmakingLocalRegionTable[v.name][regionTable.name] or {}
			local curTable = mainUI.savedLocally.matchmakingLocalRegionTable[v.name][regionTable.name]
			if not (curTable and regionsEqual(curTable, regionTable)) then -- region changed since last time
				println(v.name.." regions out of date because "..regionTable.name.." has changed.")
				RegionSelect.seenRegions[v.name] = false
			end
			curTable.visible   = regionTable.visible
			curTable.default   = regionTable.default
			curTable.enabled   = regionTable.enabled
			curTable.timestamp = regionTable.timestamp
			curTable.selected 	 = false
			if (curTable.userSelected and not (regionTable.enabled and regionTable.visible)) then -- Selected, but is invalid
				println(v.name.." regions out of date because "..regionTable.name.." is selected but not valid")
				RegionSelect.seenRegions[v.name] = false
				curTable.userSelected = false
			end
		end
		-- Disable regions that are no longer in the list
		for k,localTable in pairs(mainUI.savedLocally.matchmakingLocalRegionTable[v.name]) do
			if (localTable.enabled) then
				local found = false
				for index,regionTable in ipairs(v.regions) do
					if (k == regionTable.name) then
						found = true
						break
					end
				end
				if (not found) then
					localTable.enabled = false
					RegionSelect.seenRegions[v.name] = false
					println(v.name.." regions out of date because "..k.." is enabled but is no longer an option.")
				end
			end
		end
	end
	RegionSelect.loaded = true
	needsRefresh = true
	RegionSelect.populateRegions()
	LuaTrigger.GetTrigger('regionSelectLoaded'):Trigger()
	SaveState()
end

-- Sync after 10 ms, and whenever it changes
libThread.threadFunc(function()
	wait(10)
	RegionSelect.syncRegions() -- Reload
	main_region_selection_container:RegisterWatchLua('ChatAvailability', function(widget, trigger)
		if DatabaseLoadStateTrigger and DatabaseLoadStateTrigger.stateLoaded then
			RegionSelect.syncRegions() -- Regions update
		end
	end, false, nil, 'matchmaking')
	main_region_selection_container:RegisterWatchLua('DatabaseLoadStateTrigger', function(widget, trigger)
		println('DatabaseLoadStateTrigger fired!')
		if trigger and trigger.stateLoaded then
			RegionSelect.syncRegions() -- Database loaded
		end
	end, false, nil, 'stateLoaded')
end)

function RegionSelect.populateRegions()
	if not RegionSelect.loaded then return end
	local queue = getQueue()
	if (not needsRefresh and oldQueue == queue) then return end
	needsRefresh = false
	oldQueue = queue
	
	main_customization_region_container:ClearChildren()
	
	local enabled = 0
	local regions = mainUI.savedLocally.matchmakingLocalRegionTable[queue]
	if not regions then return end
	local isLeader = isLeader()
	
	for k, v in pairsByKeys(regions, function(a,b)
		local aPing = (a and regions and regions[a] and regions[a].ping) or false
		local bPing = (b and regions and regions[b] and regions[b].ping) or false
		if (not aPing and not bPing) then return false end
		if (aPing and not bPing) then return true end
		if (bPing and not aPing) then return false end
		return aPing < bPing
	end) do
		if (v.enabled) then
			enabled = enabled + 1
			local widget = main_customization_region_container:InstantiateAndReturn('main_customization_region_template'
				,'pop1Color', (v.activity and v.activity > 0) and '#00d1ff' or '#00d1ff48'
				,'pop2Color', (v.activity and v.activity > 1) and '#00d1ff' or '#00d1ff48'
				,'pop3Color', (v.activity and v.activity > 2) and '#00d1ff' or '#00d1ff48'
				,'pop4Color', (v.activity and v.activity > 3) and '#00d1ff' or '#00d1ff48'
				,'pop5Color', (v.activity and v.activity > 4) and '#00d1ff' or '#00d1ff48'
				,'activityVis', tostring(v.activity ~= nil)
				,'regionName', 'game_region_'..k
				,'ping', (v.ping and v.ping ~= 9999 and (v.ping..'ms')) or ''
				,'selectedVis', isLeader and tostring(v.userSelected) or tostring(v.selected)
				,'labelColor', v.userSelected and '0 .9 1 1' or '.7 .7 .7 .7'
				,'id', k
			)[1]
			if (isLeader and not isInLobby()) then
				widget:SetCallback('onclick', function(widget)
					if (isInQueue()) then return end
					v.userSelected = not v.userSelected
					if (GetCvarBool('ui_newUISounds')) then PlaySound('/ui/sounds/launcher/sfx_region_'..(v.userSelected and "" or "un")..'check.wav') end
					widget:GetWidget('main_customization_region_'..k..'_tick'):SetVisible(v.userSelected)
					widget:GetWidget('main_customization_region_'..k..'_label'):SetColor(v.userSelected and '0 .9 1 1' or '.7 .7 .7 .7')
					SaveState()
				end)
			end
		end
	end
	
	interface:GetWidget("main_region_selection_backing"):SetHeight(interface:GetHeightFromString((enabled*43 + 43)..'s'))
end


-- Update pings
UnwatchLuaTriggerByKey('RegionPingListItem', 'updatePings')
WatchLuaTrigger('RegionPingListItem', function(trigger)
	local queue = getQueue()
	mainUI.savedLocally 													= mainUI.savedLocally or {}
	mainUI.savedLocally.matchmakingLocalRegionTable 						= mainUI.savedLocally.matchmakingLocalRegionTable or {}
	mainUI.savedLocally.matchmakingLocalRegionTable[queue] 					= mainUI.savedLocally.matchmakingLocalRegionTable[queue] or {}
	mainUI.savedLocally.matchmakingLocalRegionTable[queue][trigger.name]	= mainUI.savedLocally.matchmakingLocalRegionTable[queue][trigger.name] or {}
	
	mainUI.savedLocally.matchmakingLocalRegionTable[queue][trigger.name].activity 			= trigger.activity + 1 -- offset to 1-5
	mainUI.savedLocally.matchmakingLocalRegionTable[queue][trigger.name].pingListEnabled 	= trigger.enabled
	if (trigger.pinged) then
		mainUI.savedLocally.matchmakingLocalRegionTable[queue][trigger.name].ping 			= trigger.ping
		needsRefresh = true
	else
		mainUI.savedLocally.matchmakingLocalRegionTable[queue][trigger.name].ping 			= 9999
	end
	SaveState()
end, 'updatePings')	
