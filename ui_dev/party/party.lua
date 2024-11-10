-- Party Manager
mainUI = mainUI or {}
Party = Party or {}

local tinsert, tremove, tsort = table.insert, table.remove, table.sort

local partyStatusTrigger 		= LuaTrigger.GetTrigger('PartyStatus')
local partyCustomTrigger 		= LuaTrigger.GetTrigger('PartyTrigger')

local partyComboTrigger 		= LuaTrigger.GetTrigger('PartyComboStatus')
local mainPanelStatusDragInfo 	= LuaTrigger.GetTrigger('mainPanelStatusDragInfo')
local clientInfoDrag	= LuaTrigger.GetTrigger('clientInfoDrag')
local partyPlayerInfos 	= LuaTrigger.GetTrigger('PartyPlayerInfos') or libGeneral.createGroupTrigger('PartyPlayerInfos', {'PartyPlayerInfo0', 'PartyPlayerInfo1', 'PartyPlayerInfo2', 'PartyPlayerInfo3', 'PartyPlayerInfo4', 'PartyStatus.queue', 'PartyStatus.wins', 'PartyStatus.losses'})

ClientInfo = ClientInfo or {}
ClientInfo.duplicateUsernameTable = ClientInfo.duplicateUsernameTable or {}
local clientInfoDrag	= LuaTrigger.GetTrigger('clientInfoDrag')
local globalDragInfo	= LuaTrigger.GetTrigger('globalDragInfo')
local lastFriendHoveringWidgetIndex
local socialPanelInfo = LuaTrigger.GetTrigger('socialPanelInfo')
local socialPanelInfoHovering = LuaTrigger.GetTrigger('socialPanelInfoHovering')
local partyLastPositionData = {}

Party.partyInfos = Party.partyInfos or {}

function Party.OpenedPlayScreen()
	if ((mainUI.featureMaintenance) and (not mainUI.featureMaintenance['party'])) then
		if (not partyStatusTrigger.inParty) and (LuaTrigger.GetTrigger('GamePhase').gamePhase ~= 1) then
			ChatClient.CreateParty()
			--println('^y CreateParty 1')
			InitSelectionTriggers(object, false)
		end
		Party.ToggleParty(false, true)
	end
end

function Party.SoftCreateParty()
	if ((mainUI.featureMaintenance) and (not mainUI.featureMaintenance['party'])) then
		if (not partyStatusTrigger.inParty) then
			ChatClient.CreateParty()
			--println('^y CreateParty 2')
			InitSelectionTriggers(object, false)
		end
		partyCustomTrigger.userRequestedParty = true
		partyCustomTrigger:Trigger(true)
		LuaTrigger.GetTrigger('selection_Status'):Trigger(true)
	end
end

function Party.CreateParty()
	if ((mainUI.featureMaintenance) and (not mainUI.featureMaintenance['party'])) then
		if (not partyStatusTrigger.inParty) then
			ChatClient.CreateParty()
			--println('^y CreateParty 3')
			InitSelectionTriggers(object, false)
		end
		Party.ToggleParty(true)
		Friends.ToggleFriends(true)
		partyCustomTrigger.userRequestedParty = true
		partyCustomTrigger:Trigger(true)
		if Friends and Friends['main'] and Friends['main'].AttemptUpdate then
			Friends['main'].AttemptUpdate(false, nil)
		end
		if Windows.Friends and Friends and Friends['friends'] and Friends['friends'].AttemptUpdate then
			Friends['friends'].AttemptUpdate(false, nil)			
		end		
	end
end

function Party.ToggleParty(forceOpen, forceClose)
	if ((mainUI.featureMaintenance) and (not mainUI.featureMaintenance['party'])) then
		if (forceOpen) then
			partyCustomTrigger.isOpen = true
		elseif (forceClose) then
			partyCustomTrigger.isOpen = false
		else
			partyCustomTrigger.isOpen = not partyCustomTrigger.isOpen
		end
		partyCustomTrigger:Trigger(true)
		if Friends and Friends['main'] and Friends['main'].AttemptUpdate then
			Friends['main'].AttemptUpdate(false, nil)
		end
		if Windows.Friends and Friends and Friends['friends'] and Friends['friends'].AttemptUpdate then
			Friends['friends'].AttemptUpdate(false, nil)			
		end		
	end
end

function Party.LeaveParty(forceLeave, msg)
	if (partyStatusTrigger.inParty) or (forceLeave) then
		println('^c^: Party.LeaveParty() ' .. tostring(msg))
		LeaveParty()
		partyCustomTrigger.isOpen = false
		partyCustomTrigger:Trigger(false)
		mainUI.LeavePinnedChannel(nil, 'Party')
		partyCustomTrigger.userRequestedParty = true
		partyCustomTrigger:Trigger(false)		
		if Friends and Friends['main'] and Friends['main'].AttemptUpdate then
			Friends['main'].AttemptUpdate(false, nil)
		end
		if Windows.Friends and Friends and Friends['friends'] and Friends['friends'].AttemptUpdate then
			Friends['friends'].AttemptUpdate(false, nil)			
		end		
	end
end

local function PartyRegister(object)

	UnwatchLuaTriggerByKey('PartyStatus', 'PartyStatusWatch')
	WatchLuaTrigger('PartyStatus', function(trigger)
		if (trigger.inParty) then
			partyCustomTrigger.userRequestedParty = true
			partyCustomTrigger:Trigger(true)		
		else
			partyCustomTrigger.userRequestedParty = false
			partyCustomTrigger:Trigger(true)		
		
		end
	end, 'PartyStatusWatch')
	
	UnwatchLuaTriggerByKey('PartyPlayerInfos', 'PartyPlayerInfos')

	local oldPlayerExists = {false, false, false, false, false}
	WatchLuaTrigger('PartyPlayerInfos', function(groupTrigger)
		
		local queuedCleanup = {}
		if (Party) and (Party.partyInfos) then
			for i,v in pairs(Party.partyInfos) do
				if (v) and (v.identID) and (not Empty(v.identID)) then
					local stillInParty = false
					for i=1,5 do
						local info = groupTrigger[i]
						if (info) and (info.identID) and (info.identID == v.identID) then
							stillInParty = true
							break
						end
					end
					if (not stillInParty) and (v.name) and (v.uniqueID) then
						table.insert(queuedCleanup, {v.identID, v.name .. v.uniqueID})
					end
				end
			end
		end
		
		local infoTable = {}
		-- Party.partyInfos = {}
		libGeneral.clearTable(Party.partyInfos)

		local newPlayerExists = {}

		for i=1,5 do
			local info = groupTrigger[i]
			local clientInfo = LuaTrigger.GetTrigger('ChatClientInfo' .. string.gsub(info.identID, '%.', ''))
			
			local isTalking = false
			if (VoiceClient) then
				isTalking = info.isTalking
			end
			
			if (info.identID) and (Empty(info.identID)) then
			
			end
			
			infoTable[i] = {
				['accountIconPath']	= info.accountIconPath,
				['canBePromoted']	= info.canBePromoted,
				['canKickPlayer']	= info.canKickPlayer,
				['gearSetName']		= info.gearSetName,
				['heroDisplayName']	= info.heroDisplayName,
				['heroEntityName']	= info.heroEntityName,
				['heroIconPath']	= info.heroIconPath,
				['identID']			= info.identID,
				['isLeader']		= info.isLeader,
				['isLocalPlayer']	= info.isLocalPlayer,
				['isReady']			= info.isReady,
				['isPending']		= info.isPending,
				['petDisplayName']	= info.petDisplayName,
				['petEntityName']	= info.petEntityName,
				['petIconPath']		= info.petIconPath,
				['playerName']		= info.playerName,
				['clanTag']			= info.clanTag,
				['playerUniqueID']	= info.playerUniqueID,
				['skinName']		= info.skinName,
				['isTalking']		= isTalking,
				['selfPaid']		= info.sitAndGoPaidFor and info.payingIdentID == info.identID,
				['otherPaid']		= info.sitAndGoPaidFor and (info.payingIdentID ~= GetIdentID() and info.payingIdentID ~= info.identID),
				['localPaid']		= info.sitAndGoPaidFor and info.payingIdentID == GetIdentID(),
				['selfPaid']		= info.sitAndGoPaidForBySelf,
				['otherPaid']		= info.sitAndGoPaidForByOther,
				['localPaid']		= info.sitAndGoPaidForByOther,
				['canPlayMode']		= info.canPlayCurrentQueue,
			}
			
			if (info.identID) and (not Empty(info.identID)) and (clientInfo) and (clientInfo.name) and (not Empty(clientInfo.name)) then
		
				infoTable[i].trueName			= clientInfo.name
				infoTable[i].name				= clientInfo.name
				infoTable[i].clanTag			= clientInfo.clanTag
				infoTable[i].icon				= info.accountIconPath
				infoTable[i].accountTitle		= clientInfo.accountTitle
				infoTable[i].uniqueID			= clientInfo.uniqueID 
				infoTable[i].status				= clientInfo.status
				infoTable[i].identID			= clientInfo.identID
				infoTable[i].isDND				= clientInfo.isDND			
				infoTable[i].isStaff			= clientInfo.isStaff			
				infoTable[i].ready				= clientInfo.ready						
				infoTable[i].isInParty			= true					
				infoTable[i].buddyGroup			= 'party'					
				
				WatchFriend(clientInfo.identID, clientInfo.name .. clientInfo.uniqueID, infoTable[i])
				
				local clientInfo = LuaTrigger.GetTrigger('ChatClientInfo' .. string.gsub(clientInfo.identID, '%.', ''))
				libThread.threadFunc(function()
					wait(1)	
					if (clientInfo) then
						clientInfo:Trigger(true)
					end	
				end)
				
				newPlayerExists[i] = true
			else
				newPlayerExists[i] = false
			end

		end

		local myLocation = 0
		for i=1,5,1 do
			local v = infoTable[i]
			if (IsMe(v.identID)) or (v.isLocalPlayer) then
				libGeneral.clearTable(Party.partyInfos[1])
				if not Party.partyInfos[1] then
					Party.partyInfos[1] = {}
				end
				for j,l in pairs(v) do
					Party.partyInfos[1][j] = l
				end
				myLocation = i
				break
			end
		end

		for i = 1,5,1 do
			if not Party.partyInfos[i] then
				Party.partyInfos[i] = {}
			end
			if (i < myLocation) then
				for k,v in pairs(infoTable[i]) do
					Party.partyInfos[i + 1][k] = v
				end
			elseif (i > myLocation) then
				for k,v in pairs(infoTable[i]) do
					Party.partyInfos[i][k] = v
				end
			end
		end
		
		if (queuedCleanup) then
			for i,v in pairs(queuedCleanup) do
				WatchFriend(v[1], v[2])
				local clientInfo = LuaTrigger.GetTrigger('ChatClientInfo' .. string.gsub(v[1], '%.', ''))
				libThread.threadFunc(function()
					wait(1)	
					if (clientInfo) then
						clientInfo:Trigger(true)
					end		
				end)
			end
		end

		local changed = false
		for n = 1, 5 do
			if newPlayerExists ~= oldPlayerExists then
				changed = true
				return
			end
		end

		if (changed) then
			if Friends and Friends['main'] and Friends['main'].AttemptUpdate then
				Friends['main'].AttemptUpdate(false, nil)
			elseif Windows.Friends and Friends and Friends['friends'] and Friends['friends'].AttemptUpdate then
				Friends['friends'].AttemptUpdate(false, nil)			
			end
			oldPlayerExists = newPlayerExists
		end
	end, 'PartyPlayerInfos')
	
	function GetPartyPlayerDataFromIdentID(identID)
		if (Party) and (Party.partyInfos) then
			for i,v in pairs(Party.partyInfos) do
				if (v.identID) and (v.identID == identID) then
					return v
				end
			end
		end
		return nil
	end	
	
end

PartyRegister(object)
