local interface = object
local tinsert, tremove, tsort = table.insert, table.remove, table.sort
local questsTrigger = LuaTrigger.GetTrigger('questsTrigger')
Quests = {}
Quests.questsWithProgress = {}
Quests.questsWithoutProgress = {}
Quests.newlyCompletedQuests = {}
Quests.responseData = nil
Quests.splashTheseQuests = {}
Quests.splashTheseQuestsThread = nil

QUEST_TYPE_COUNT			= 0		-- Lifetime
QUEST_TYPE_DAILY			= 1
QUEST_TYPE_MONTHLY			= 2
QUEST_TYPE_WEEKLY			= 3
QUEST_TYPE_CALLTOACTION		= 4

local rewardsClaimed 		= 0
MAX_REWARDS_CLAIMABLE		= 8
QUESTS_CAN_BULK_CLAIM		= true

local function questGetReqLabelText(reqType, reqKey, reqValue, labelSuffix, localContent)
	labelSuffix = labelSuffix or ''
	localContent = localContent or ''
	local label
	
	if (reqType == 'experience') and (reqKey == 'experience') and tonumber(reqValue) and (tonumber(reqValue) >= 0) then
		label = (Translate( "quest_type_" .. string.lower(reqType) .. "_" .. string.lower(reqKey) .. labelSuffix, "value", mainUI.progression.GetAccountLevelFromExperience(reqValue), "value2", Translate(localContent)))	
	elseif (reqType == 'games') and (reqKey == 'winsashero') then
		label = (Translate( "quest_type_" .. string.lower(reqType) .. "_" .. string.lower(reqKey) .. labelSuffix, "value", mainUI.progression.GetAccountLevelFromExperience(reqValue), "value2", Translate(localContent)))
	elseif (reqType == 'division') and (reqKey == 'division') and tonumber(reqValue) and (tonumber(reqValue) >= 0) and (libCompete) and (libCompete.divisions) then
		local division = (#libCompete.divisions + 1) - reqValue
		local name = Translate('ranked_division_' .. libCompete.divisions[division].key)
		label = (Translate( "quest_type_" .. string.lower(reqType) .. "_" .. string.lower(reqKey), "value", name, "value2", Translate(localContent)))		
	else
		label = (Translate( "quest_type_" .. string.lower(reqType) .. "_" .. string.lower(reqKey) .. labelSuffix, "value", reqValue, "value2", Translate(localContent)))
	end
	
	return label
end

local function questParseLocalContent(localContent)
	if (localContent) and ValidateEntity(localContent) then
		return GetEntityDisplayName(localContent)
	end
	return ''
end

local function questGetReqValueWithSuffix(reqValue)
	reqValueNum = tonumber(reqValue)
	if (reqValueNum) and (reqValueNum > 1) then
		return reqValueNum, 'number', nil
	elseif (reqValueNum) then
		return reqValueNum, 'number', '_b'
	elseif (reqValue) and ValidateEntity(reqValue) then
		return GetEntityDisplayName(reqValue), 'string', '_b'
	else
		return reqValue, 'string', '_b'
	end
end

local function questProcessRequirements(questTable)
	local requirementTriggerTable = {}
	local requirementTable = {}

	tinsert(requirementTriggerTable, {'is_complete', 'bool', false})

	local function addReqEntry(valueCur, valueReq, valueType, reqType, reqKey, localContent)
		localContent = localContent or ''
		tinsert(requirementTriggerTable, {'requirement_' .. reqType .. '_' .. reqKey .. '_cur', valueType, valueCur})
		tinsert(requirementTriggerTable, {'requirement_' .. reqType .. '_' .. reqKey .. '_req', valueType, valueReq, 'value2', localContent})
		return 
	end
	
	local function AddRequirement(reqType, reqKey, reqValue, localContent)
		localContent = questParseLocalContent(localContent)
		local useReqValue, reqValueType, labelSuffix = questGetReqValueWithSuffix(reqValue)
		local labelText = questGetReqLabelText(reqType, reqKey, useReqValue, labelSuffix, localContent)

		
		if questTable.amountLatestProgress and questTable.amountLatestProgress > 0 then
			addReqEntry(questTable.amountLatestProgress, useReqValue, reqValueType, reqType, reqKey)
		else
			addReqEntry(questTable.currentProgress, useReqValue, reqValueType, reqType, reqKey)
		end
		
		
		tinsert(requirementTable, labelText)
		questTable.labelText = labelText
	end
	
	if (questTable) and (questTable.required) then
		for reqType, reqTable in pairs(questTable.required) do
			for reqKey, reqValue in pairs(reqTable) do
				AddRequirement(reqType, reqKey, reqValue, questTable.localContent)
			end
		end
	end
	
	questTable.requirementTriggerTable = requirementTriggerTable
	questTable.requirementTable = requirementTable
	
	return questTable
end

local function updateQuestLatestProgress(questProcessedTable, reqType, reqKey, requiredProgress, fieldName)
	fieldName = fieldName or 'latestProgress'
	if (
		questProcessedTable[fieldName] and type(questProcessedTable[fieldName]) == 'table' and
		questProcessedTable[fieldName][reqType] and type(questProcessedTable[fieldName][reqType]) == 'table' and
		questProcessedTable[fieldName][reqType][reqKey]
	) then
		if (requiredProgress) and (requiredProgress == 'complete') then
			requiredProgress = 1
		end
		if (questProcessedTable[fieldName][reqType][reqKey]) and (questProcessedTable[fieldName][reqType][reqKey] == 'complete') then
			questProcessedTable[fieldName][reqType][reqKey] = 1
		end		
		if (requiredProgress) and (tonumber(requiredProgress)) and (tonumber(questProcessedTable[fieldName][reqType][reqKey])) then
			questProcessedTable.percentLatestProgress = math.max(0, tonumber(questProcessedTable[fieldName][reqType][reqKey]) / tonumber(requiredProgress))
		else
			questProcessedTable.percentLatestProgress = 0
		end
		questProcessedTable.amountLatestProgress = questProcessedTable[fieldName][reqType][reqKey]
		questProcessedTable.amountLatestProgress = math.min(questProcessedTable.amountLatestProgress, questProcessedTable.currentProgress)
		questProcessedTable.amountLatestProgress = math.max(questProcessedTable.amountLatestProgress, 0)
		questProcessedTable.percentLatestProgress = math.min(questProcessedTable.percentLatestProgress, questProcessedTable.percentProgress)
		questProcessedTable.percentLatestProgress = math.max(questProcessedTable.percentLatestProgress, 0)
	else
		if type(questProcessedTable[fieldName]) ~= 'table' then
			questProcessedTable[fieldName] = {}
		end
		
		questProcessedTable[fieldName][reqType] = questProcessedTable[fieldName][reqType] or {}
		questProcessedTable[fieldName][reqType][reqKey] = 0
		questProcessedTable.percentLatestProgress		= 0
		questProcessedTable.amountLatestProgress		= 0
	end
end

local function updateQuestCurrentProgress(questProcessedTable, reqType, reqKey, requiredProgress, fieldName)
	fieldName = fieldName or 'progress'
	if (requiredProgress == 'complete') then
		requiredProgress = 1
	end
	if (
		questProcessedTable[fieldName] and type(questProcessedTable[fieldName]) == 'table' and
		questProcessedTable[fieldName][reqType] and type(questProcessedTable[fieldName][reqType]) == 'table' and
		questProcessedTable[fieldName][reqType][reqKey]
	) then
		if (questProcessedTable[fieldName][reqType][reqKey]) and (questProcessedTable[fieldName][reqType][reqKey] == 'complete') then
			questProcessedTable[fieldName][reqType][reqKey] = 1
		end		
		questProcessedTable.percentProgress = math.max(0, tonumber(questProcessedTable[fieldName][reqType][reqKey]) / requiredProgress)
		questProcessedTable.currentProgress = math.max(0, tonumber(questProcessedTable[fieldName][reqType][reqKey]))
		if (questProcessedTable.percentProgress) and (questProcessedTable.percentProgress >= 0) then -- we have progress information, we must be eligible
			questProcessedTable.eligible = true
		end		
	else	-- no progress information
		questProcessedTable.currentProgress = 0
		questProcessedTable.percentProgress = 0
	end
end

local function updateQuestRequirementOffset(questProcessedTable, reqType, reqKey, requiredProgress, fieldName)
	if (
		questProcessedTable.progress and type(questProcessedTable.progress) == 'table' and
		questProcessedTable.progress[reqType] and type(questProcessedTable.progress[reqType]) == 'table' and
		questProcessedTable.progress[reqType][reqKey] and 
		questProcessedTable and
		questProcessedTable.startingRequirements and type(questProcessedTable.startingRequirements) == 'table' and
		questProcessedTable.startingRequirements[reqType] and type(questProcessedTable.startingRequirements[reqType]) == 'table' and
		questProcessedTable.startingRequirements[reqType][reqKey] 		
	) then
		questProcessedTable.progress[reqType][reqKey] = questProcessedTable.progress[reqType][reqKey] - questProcessedTable.startingRequirements[reqType][reqKey] 
	end
	if (
		questProcessedTable and
		questProcessedTable.required and type(questProcessedTable.required) == 'table' and
		questProcessedTable.required[reqType] and type(questProcessedTable.required[reqType]) == 'table' and
		questProcessedTable.required[reqType][reqKey] and 
		questProcessedTable.startingRequirements and type(questProcessedTable.startingRequirements) == 'table' and
		questProcessedTable.startingRequirements[reqType] and type(questProcessedTable.startingRequirements[reqType]) == 'table' and
		questProcessedTable.startingRequirements[reqType][reqKey] 		
	) then
		questProcessedTable.requiredOverride 					= questProcessedTable.requiredOverride or {}
		questProcessedTable.requiredOverride[reqType] 		= questProcessedTable.requiredOverride[reqType] or {}
		questProcessedTable.requiredOverride[reqType][reqKey] = questProcessedTable.requiredOverride[reqType][reqKey] or {}
		questProcessedTable.requiredOverride[reqType][reqKey] = questProcessedTable.required[reqType][reqKey] - questProcessedTable.startingRequirements[reqType][reqKey] 
	end	
end

local function PopulateQuests(responseData, pushUpdate)

	println('^y^: PopulateQuests')

	if (responseData == nil) and (Quests.questDataConsolidationTable == nil) then
		println('^963Warning:^*PopulateQuests - no response data', 'main_reconnect_thatsucks', '', nil, nil, false)
	end
	if (responseData) and (responseData.quests == nil or responseData.quests.quests == nil) then
		println('^963Warning:^*PopulateQuests - no quests data', 'main_reconnect_thatsucks', '', nil, nil, false)
	end
	if (responseData) and ((responseData.clientQuestProgresses == nil) or (responseData.clientQuestProgresses.progresses == nil)) then
		println('^963Warning:^*PopulateQuests - no clientQuestProgresses.progresses data')	
	end
	if (responseData) and (responseData.questHistory == nil or responseData.questHistory.history == nil) then
		println('^963Warning:^*PopulateQuests - no questHistory.history data')	
	end
	if (responseData) and (responseData.questRewards == nil or responseData.questRewards.rewards == nil) then
		println('^963Warning:^*PopulateQuests - no questRewards.rewards data')			
	end

	mainUI.progressionData.GenerateFakeAccountData()
	
	local notificationsTrigger = LuaTrigger.GetTrigger('notificationsTrigger')
	
	Quests.questDataConsolidationTable = Quests.questDataConsolidationTable or {}
	local questsProcessedTable = {}
	local questsVisibleProcessedTable = {}
	local questsProcessedTable2 = {}
	Quests.splashTheseQuests = Quests.splashTheseQuests or {}
	Quests.newlyCompletedQuests = {}
	Quests.questsWithProgress = {}
	Quests.questsWithoutProgress = {}
	questsTrigger.unclaimedQuestRewards 	 		= 0
	questsTrigger['count'..QUEST_TYPE_COUNT] = 0
	questsTrigger['count'..QUEST_TYPE_DAILY] = 0
	questsTrigger['count'..QUEST_TYPE_MONTHLY] = 0
	questsTrigger['count'..QUEST_TYPE_WEEKLY] = 0
	questsTrigger['count'..QUEST_TYPE_CALLTOACTION] = 0
	
	for i, questRawTable in pairs(Quests.questDataConsolidationTable) do
		questRawTable.pushUpdate = false	
	end

	-- Form base quest table from quests.quests
	if (responseData) and (responseData.quests) and (responseData.quests.quests) then
		for i, questRawTable in pairs(responseData.quests.quests) do
			if (questRawTable) and (questRawTable.questIncrement) and (questRawTable.enabled) and (questRawTable.active) then
				questRawTable.pushUpdate = false
				if (questRawTable.activationType and questRawTable.activationType == '2') then
					questRawTable.alwaysHidden = true
					questRawTable.eligible = true
				elseif (questRawTable.activationType and questRawTable.activationType == '1') then
					questRawTable.eligible = false
				else
					questRawTable.eligible = true
				end
				if (questRawTable.cooldown) and (questRawTable.cooldown == '0') then
					questRawTable.canOnlyCompleteOnce = true
				else
					questRawTable.canOnlyCompleteOnce = false
				end
				local questIncrement = tonumber(questRawTable.questIncrement)
				Quests.questDataConsolidationTable[questIncrement] = questRawTable
			end
		end
	end

	-- Merge quest progress in from questsList / clientQuestProgresses.progresses
	if (responseData) and (responseData.clientQuestProgresses) and (responseData.clientQuestProgresses.progresses) then
		for i, questRawTable in pairs(responseData.clientQuestProgresses.progresses) do
			if (questRawTable) and (questRawTable.questIncrement) then
				local questIncrement = tonumber(questRawTable.questIncrement)
				if (Quests.questDataConsolidationTable[questIncrement]) then
					-- Quests.questDataConsolidationTable[questIncrement].eligible 				= questRawTable.eligible
					Quests.questDataConsolidationTable[questIncrement].timesCompleted 			= questRawTable.timesCompleted
					Quests.questDataConsolidationTable[questIncrement].progress  				= questRawTable.progress 
					Quests.questDataConsolidationTable[questIncrement].latestProgress   		= questRawTable.latestProgress  
					Quests.questDataConsolidationTable[questIncrement].readProgress   			= questRawTable.readProgress  
					Quests.questDataConsolidationTable[questIncrement].hasChanged   			= questRawTable.hasChanged  
					if (Quests.questDataConsolidationTable[questIncrement].last_modified) and (questRawTable.last_modified) and (questRawTable.last_modified == Quests.questDataConsolidationTable[questIncrement].last_modified) then
						Quests.questDataConsolidationTable[questIncrement].duplicateUpdate = true
					end
					Quests.questDataConsolidationTable[questIncrement].last_modified   			= questRawTable.last_modified  
				else
					-- Got a progress entry for a quest we aren't eligible for or doesn't exist in list, usually not a good thing
					Quests.questDataConsolidationTable[questIncrement] = questRawTable
					-- Quests.questDataConsolidationTable[questIncrement].eligible 				= questRawTable.eligible
					Quests.questDataConsolidationTable[questIncrement].timesCompleted 			= questRawTable.timesCompleted
					Quests.questDataConsolidationTable[questIncrement].progress  				= questRawTable.progress 
					Quests.questDataConsolidationTable[questIncrement].latestProgress   		= questRawTable.latestProgress  
					Quests.questDataConsolidationTable[questIncrement].readProgress   			= questRawTable.readProgress  
					Quests.questDataConsolidationTable[questIncrement].hasChanged   			= questRawTable.hasChanged  
					Quests.questDataConsolidationTable[questIncrement].last_modified   			= questRawTable.last_modified  
				end
			end
		end
	end	

	-- Add table of completion dates if they exist
	if (responseData) and (responseData.questHistory) and (responseData.questHistory.history) then
		for i, questRawTable in pairs(responseData.questHistory.history) do
			if (questRawTable) and (questRawTable.questIncrement) then
				local questIncrement = tonumber(questRawTable.questIncrement)
				if (Quests.questDataConsolidationTable[questIncrement]) then
					Quests.questDataConsolidationTable[questIncrement].date_completed = Quests.questDataConsolidationTable[questIncrement].date_completed or {}
					tinsert(Quests.questDataConsolidationTable[questIncrement].date_completed, questRawTable.date_completed)
				else
					-- Got a history entry for a quest we aren't eligible for or exists in list
					Quests.questDataConsolidationTable[questIncrement] = questRawTable
					Quests.questDataConsolidationTable[questIncrement].date_completed = {}
					tinsert(Quests.questDataConsolidationTable[questIncrement].date_completed, questRawTable.date_completed)
				end
			end
		end
	end
	
	-- Add rewards waiting to be claimed
	if (responseData) and (responseData.questRewards) and (responseData.questRewards.rewards) then
		for questIncrementKey, rewardRawTable in pairs(responseData.questRewards.rewards) do
			local questIncrement = tonumber(rewardRawTable.questIncrement)
			if (rewardRawTable) and (rewardRawTable.questRewardIncrement) and (questIncrement) and (rewardRawTable.used == '0') then
				if (Quests.questDataConsolidationTable[questIncrement]) then
					Quests.questDataConsolidationTable[questIncrement].rewardsAvailable = Quests.questDataConsolidationTable[questIncrement].rewardsAvailable or {}
					tinsert(Quests.questDataConsolidationTable[questIncrement].rewardsAvailable, rewardRawTable)
				else
					println('^r Error: Quest reward reciept error. questIncrement: ' .. tostring(questIncrement) .. ' | rewardRawTable.questRewardIncrement: ' .. tostring(rewardRawTable.questRewardIncrement) .. ' | rewardRawTable.used: ' .. tostring(rewardRawTable.used)  )
				end
			end
		end
	end

	-- Add push updates to base table, override any from quest list or eligible quests
	if (pushUpdate) then
		for i, questRawTable in pairs(pushUpdate) do
			if (questRawTable) and (questRawTable.questIncrement) then
				local questIncrement = tonumber(questRawTable.questIncrement)
				-- println('^g ChatServer QuestUpdate ' .. i)
				-- printr(questRawTable)
				Quests.questDataConsolidationTable[questIncrement] = Quests.questDataConsolidationTable[questIncrement] or {}
				Quests.questDataConsolidationTable[questIncrement].quest = Quests.questDataConsolidationTable[questIncrement].quest or {}
				Quests.questDataConsolidationTable[questIncrement].progress = Quests.questDataConsolidationTable[questIncrement].progress or {}
				Quests.questDataConsolidationTable[questIncrement].latestProgress = Quests.questDataConsolidationTable[questIncrement].latestProgress or {}
				if questRawTable.previous then
					for requirementName1, requirementTable1 in pairs(questRawTable.previous) do 
						for requirementName2, requirementValue in pairs(requirementTable1) do 
							Quests.questDataConsolidationTable[questIncrement].progress[requirementName1] = Quests.questDataConsolidationTable[questIncrement].progress[requirementName1] or {}
							Quests.questDataConsolidationTable[questIncrement].progress[requirementName1][requirementName2] = requirementValue
						end
					end
				end					
				if questRawTable.new then
					for requirementName1, requirementTable1 in pairs(questRawTable.new) do 
						for requirementName2, requirementValue in pairs(requirementTable1) do 
							Quests.questDataConsolidationTable[questIncrement].latestProgress[requirementName1] = Quests.questDataConsolidationTable[questIncrement].latestProgress[requirementName1] or {}
							if questRawTable.previous and questRawTable.previous[requirementName1] and questRawTable.previous[requirementName1][requirementName2] then
								Quests.questDataConsolidationTable[questIncrement].progress[requirementName1] = Quests.questDataConsolidationTable[questIncrement].progress[requirementName1] or {}
								Quests.questDataConsolidationTable[questIncrement].progress[requirementName1][requirementName2] = (tonumber(requirementValue) or 0)								
								Quests.questDataConsolidationTable[questIncrement].latestProgress[requirementName1][requirementName2] = (tonumber(requirementValue) or 0) - (tonumber(questRawTable.previous[requirementName1][requirementName2]) or 0)
							else
								Quests.questDataConsolidationTable[questIncrement].progress[requirementName1] = Quests.questDataConsolidationTable[questIncrement].progress[requirementName1] or {}
								Quests.questDataConsolidationTable[questIncrement].progress[requirementName1][requirementName2] = (tonumber(requirementValue) or 0)										
								Quests.questDataConsolidationTable[questIncrement].latestProgress[requirementName1][requirementName2] = (tonumber(requirementValue) or 0)
							end
						end
					end
				end	
				Quests.questDataConsolidationTable[questIncrement].pushUpdate = true
				Quests.questDataConsolidationTable[questIncrement].eligible = true	
				-- printr(Quests.questDataConsolidationTable[questIncrement])
				if (Quests.questDataConsolidationTable[questIncrement].last_modified) and (questRawTable.last_modified) and (questRawTable.last_modified == Quests.questDataConsolidationTable[questIncrement].last_modified) then
					Quests.questDataConsolidationTable[questIncrement].duplicateUpdate = true
				end
				Quests.questDataConsolidationTable[questIncrement].last_modified   		= questRawTable.last_modified  
			else
				-- println('^r ChatServer QuestUpdate ' .. i)
			end
		end
	end	
	
	-- Move to indexed format
	for i, questRawTable in pairs(Quests.questDataConsolidationTable) do
		if (questRawTable) and (questRawTable.questIncrement) then
			tinsert(questsProcessedTable, questRawTable)
		end
	end

	-- Index by requrement and calculate progress
	local questsByRequirement = {}
	for i, questProcessedTable in pairs(questsProcessedTable) do
		if type(questProcessedTable.required) == 'table' then
			for reqType, reqTable in pairs(questProcessedTable.required) do
				if type(reqTable) == 'table' then
					for reqKey, reqValue in pairs(reqTable) do
						if (reqKey ~= 'localContent') then	
							local displayType = questProcessedTable.displayType or -1
							displayType = tonumber(displayType)
							
							questsByRequirement[reqType .. '_' .. reqKey .. '_' .. displayType] = questsByRequirement[reqType .. '_' .. reqKey .. '_' .. displayType] or {}
					
							updateQuestRequirementOffset(questProcessedTable, reqType, reqKey, tonumber(questProcessedTable.required[reqType][reqKey]))
							
							if (questProcessedTable.requiredOverride) and (questProcessedTable.requiredOverride[reqType]) and (questProcessedTable.requiredOverride[reqType][reqKey]) then 
								questProcessedTable.requirementTotal = questProcessedTable.requiredOverride[reqType][reqKey]
							else
								if (questProcessedTable.required[reqType][reqKey] == 'complete') then
									questProcessedTable.requirementTotal = 1
								else
									questProcessedTable.requirementTotal = questProcessedTable.required[reqType][reqKey]
								end
							end
							
							if ((displayType) == QUEST_TYPE_COUNT or (displayType) == QUEST_TYPE_CALLTOACTION) and questProcessedTable.date_completed and (type(questProcessedTable.date_completed) == 'table') and (#questProcessedTable.date_completed > 0) then	-- lifetime or call to action with completion
								questProcessedTable.percentProgress = 1 
								questProcessedTable.currentProgress = questProcessedTable.required[reqType][reqKey]
								questProcessedTable.eligible = true
							elseif (questProcessedTable.canOnlyCompleteOnce) and (questProcessedTable.timesCompleted) and (tonumber(questProcessedTable.timesCompleted)) and (tonumber(questProcessedTable.timesCompleted) >= 1) then	-- no cooldown with completion
								questProcessedTable.percentProgress = 1 
								questProcessedTable.currentProgress = questProcessedTable.required[reqType][reqKey]		
								questProcessedTable.eligible = true								
							elseif (questProcessedTable.requiredOverride) and (questProcessedTable.requiredOverride[reqType]) and (questProcessedTable.requiredOverride[reqType][reqKey]) then 
								updateQuestCurrentProgress(questProcessedTable, reqType, reqKey, tonumber(questProcessedTable.requiredOverride[reqType][reqKey]))
							else
								updateQuestCurrentProgress(questProcessedTable, reqType, reqKey, tonumber(questProcessedTable.required[reqType][reqKey]))
							end

							if (questProcessedTable.requiredOverride) and (questProcessedTable.requiredOverride[reqType]) and (questProcessedTable.requiredOverride[reqType][reqKey]) then 
								updateQuestLatestProgress(questProcessedTable, reqType, reqKey, questProcessedTable.requiredOverride[reqType][reqKey])
							else
								updateQuestLatestProgress(questProcessedTable, reqType, reqKey, questProcessedTable.required[reqType][reqKey])
							end

							tinsert(questsByRequirement[reqType .. '_' .. reqKey .. '_' .. displayType], questProcessedTable)
						end
					end
				end
			end
		end
	end

	-- group quests with same requirement to show only the next available
	local foundFirstQuest = false
	for i, questByRequirement in pairs(questsByRequirement) do
		tsort(questByRequirement, function(a,b)
			return (a.requirementTotal) and (b.requirementTotal) and (tonumber(a.requirementTotal)) and (tonumber(b.requirementTotal)) and (tonumber(a.requirementTotal) < tonumber(b.requirementTotal))
		end)
		foundFirstQuest = false
		for questConsecutiveIndex, questTable in ipairs(questByRequirement) do
			questTable.questConsecutiveIndex = questConsecutiveIndex
			if (((questTable.percentProgress < 1) or (questTable.percentProgress - questTable.percentLatestProgress < 1)) or (questTable.rewardsAvailable and (type(questTable.rewardsAvailable) == 'table') and (#questTable.rewardsAvailable > 0))) and (not foundFirstQuest) then
				foundFirstQuest = true
				questTable.hideQuestFromGroup = false
			elseif (not foundFirstQuest) and (questConsecutiveIndex == #questByRequirement) then
				foundFirstQuest = true
				questTable.hideQuestFromGroup = false			
			else
				questTable.hideQuestFromGroup = true
			end
		end
	end

	-- create tables of splash, visible, and processed quests
	for requirementKey, questsTable in pairs(questsByRequirement) do
		for _, questTable in pairs(questsTable) do
			questTable = questProcessRequirements(questTable)
			if ((not questTable.hideQuestFromGroup) and (questTable.eligible) and (questTable.pushUpdate)) or (questTable.rewardsAvailable and (type(questTable.rewardsAvailable) == 'table') and (#questTable.rewardsAvailable > 0)) then
				if (questTable.rewardsAvailable and (type(questTable.rewardsAvailable) == 'table') and (#questTable.rewardsAvailable > 0)) then
					questTable.percentProgress = 1
				end			
				tinsert(questsVisibleProcessedTable, questTable)
				tinsert(questsProcessedTable2, questTable)
				if (not questTable.duplicateUpdate) then
					tinsert(Quests.splashTheseQuests, questTable)
				end
			elseif (not questTable.hideQuestFromGroup) and (questTable.eligible) then
				tinsert(questsVisibleProcessedTable, questTable)
				tinsert(questsProcessedTable2, questTable)
			else
				tinsert(questsProcessedTable2, questTable)
			end		
		end
	end
	
	tsort(questsVisibleProcessedTable, function(a,b)
		return tonumber(a.questIncrement) < tonumber(b.questIncrement)
	end)

	tsort(questsProcessedTable2, function(a,b)
		return tonumber(a.questIncrement) < tonumber(b.questIncrement)
	end)	

	-- get icons and labels
	local function GetQuestIconsAndLabels(incQuestTable, count)
		local validCommodityRewards = { 'ore', 'essence', 'gems', 'food', 'shards' }
		
		local function CheckTableForRewards(questTable, i, v, rewardCount)
			if (i == 'customRewardString') and (type(v) == 'table') and (v.type) then 
				if (v.type == 'unlock') then 
					if (v.stringTableName == 'account_unlock_ranked') then
						rewardCount = rewardCount + 1
						questTable['rewardIcon'..rewardCount] = '/ui/main/shared/textures/ranked.tga'
						questTable['rewardText'..rewardCount] = Translate('quest_reward_label_ranked')		
						questTable.texture = '/ui/main/quests/textures/quest_item_card_lexikhan.tga'
						questTable.splashTemplate = 'splash_screen_unlocked_ranked'
					elseif (v.stringTableName == 'account_unlock_crafting') then
						rewardCount = rewardCount + 1
						questTable['rewardIcon'..rewardCount] = '/ui/main/shared/textures/crafting.tga'
						questTable['rewardText'..rewardCount] = Translate('quest_reward_label_crafting')		
						questTable.texture = '/ui/main/quests/textures/quest_item_card_draknia.tga'
						questTable.splashTemplate = 'splash_screen_unlocked_crafting'					
					elseif (v.stringTableName == 'account_unlock_khanquest') then
						-- rewardCount = rewardCount + 1
						-- questTable['rewardIcon'..rewardCount] = '/ui/main/shared/textures/khanquest.tga'
						-- questTable['rewardText'..rewardCount] = Translate('quest_reward_label_khanquest')		
						-- questTable.texture = '/ui/main/quests/textures/quest_item_card_lexikhan.tga'	
						-- questTable.splashTemplate = 'splash_screen_unlocked_ranked'
					end
				elseif (v.type == 'craft') then 
					if (v.stringTableName == 'crafted_item') then
						if (v.craft) and (v.craft.entityName) and (not Empty(v.craft.entityName)) and ValidateEntity(v.craft.entityName) then
							local itemName, itemIcon = '',''
							rewardCount = rewardCount + 1
							itemName = GetEntityDisplayName(v.craft.entityName) or ''
							itemIcon = GetEntityIconPath(v.craft.entityName) or '$checker'
							questTable['rewardIcon'..rewardCount] = itemIcon
							questTable['rewardText'..rewardCount] = itemName
							questTable.texture = '/ui/main/quests/textures/quest_item_card_draknia.tga'
							questTable.craftedItemReward = v.craft
						end
					end					
				elseif (v.type == 'pet') then
					if (v.stringTableName == 'pet_unlock') then -- unlock a pet
						rewardCount = rewardCount + 1
						if (v.entityName) and (not Empty(v.entityName)) and ValidateEntity(v.entityName) then
							questTable['rewardText'..rewardCount] = Translate('quest_reward_label_petunlock_short_x', 'value', GetEntityDisplayName(v.entityName))
							questTable['rewardIcon'..rewardCount] = GetEntityIconPath(v.entityName)
						else
							questTable['rewardText'..rewardCount] = Translate('quest_reward_label_petunlock_noname_x')
							questTable['rewardIcon'..rewardCount] = '/ui/main/quests/textures/quest_reward_auros.tga'
						end
						questTable.texture = '/ui/main/quests/textures/quest_item_card_auros.tga'
					elseif (v.pet_level) then -- gain a pet level
						rewardCount = rewardCount + 1
						questTable['rewardIcon'..rewardCount] = '/ui/main/quests/textures/quest_reward_auros.tga'
						questTable['rewardText'..rewardCount] = Translate('quest_reward_label_petlevel_x', 'value', v.pet_level)
						questTable.texture = '/ui/main/quests/textures/quest_item_card_auros.tga'
					end
				elseif (v.type == 'hero') then
					if (v.stringTableName == 'hero_unlock') and (v.heroList) and (type(v.heroList) == 'table') then
						local heroCount = 0
						for i,v in pairs(v.heroList) do
							heroCount = heroCount + 1
						end
						if (heroCount > 0) and (heroCount <= 10) then
							for i,v in pairs(v.heroList) do
								if (v) and (not Empty(v)) and ValidateEntity(v) then
									rewardCount = rewardCount + 1
									questTable['rewardIcon'..rewardCount] = GetEntityIconPath(v)
									questTable['rewardText'..rewardCount] = Translate('quest_reward_label_unlocked_hero_x', 'value', GetEntityDisplayName(v))
									questTable.texture = '/ui/main/quests/textures/quest_item_card_lexikhan.tga'
								end
							end
							questTable['rewardIconPack'] = '/ui/main/shared/textures/unlock_hero_single.tga'
							questTable['rewardTextPack'] = Translate('quest_reward_label_unlocked_hero_pack_x')		
							questTable.texture = '/ui/main/quests/textures/quest_item_card_lexikhan.tga'
						elseif (heroCount > 0) then
							rewardCount = rewardCount + 1
							questTable['rewardIcon'..rewardCount] = '/ui/main/shared/textures/unlock_hero_all.tga'
							questTable['rewardText'..rewardCount] = Translate('quest_reward_label_unlocked_allheroes_pack_x')
							questTable.texture = '/ui/main/quests/textures/quest_item_card_lexikhan.tga'						
						end
					end					
				elseif (v.type == 'accountIcon') then
					rewardCount = rewardCount + 1
					questTable['rewardIcon'..rewardCount] = string.lower(v.localPath) or '$checker'
					questTable['rewardText'..rewardCount] = Translate('quest_reward_' .. (v.stringTableName or ''))
					questTable.texture = '/ui/main/quests/textures/quest_item_card_rhao.tga'		
				else
					printdb('Unable to find custom reward icon for quest '..questTable.questIncrement..'\n')
				end	
			elseif (i == 'chestTier') and (v == '0') then
				rewardCount = rewardCount + 1
				questTable['rewardIcon'..rewardCount] = '/ui/main/shared/textures/rewards_chest.tga'
				questTable['rewardText'..rewardCount] = Translate('quest_reward_label_chest')	
				questTable.texture = '/ui/main/quests/textures/quest_item_card_rhao.tga'
			elseif (i == 'chestTier') then
				rewardCount = rewardCount + 1
				questTable['rewardIcon'..rewardCount] = '/ui/main/shared/textures/rewards_chest.tga'
				questTable['rewardText'..rewardCount] = Translate('quest_reward_label_chest_x', 'value', v)
				questTable.texture = '/ui/main/quests/textures/quest_item_card_rhao.tga'
			elseif IsInTable(validCommodityRewards, i) and tonumber(v) and (tonumber(v) > 0) then
				rewardCount = rewardCount + 1
				questTable['rewardIcon'..rewardCount] = Translate('general_commodity_texture_'..i)
				questTable['rewardText'..rewardCount] = Translate('general_commodity_' .. i .. '_x', 'value', v)
				questTable['rewardCount'..rewardCount] = v
				questTable.texture = '/ui/main/quests/textures/quest_item_card_draknia.tga'			
			elseif (i == 'productIncrement') then
				rewardCount = rewardCount + 1
				questTable['rewardIcon'..rewardCount] = TranslateOrNil('quest_reward_product_' .. v .. '_texture') or '$checker'
				questTable['rewardText'..rewardCount] = TranslateOrNil('quest_reward_product_' .. v) or '?Unknown'
				questTable.texture = '/ui/main/quests/textures/quest_item_card_rhao.tga'				
			else
				-- printdb('Unable to find reward icon for quest ' .. tostring(i) .. ' '..questTable.questIncrement..'\n')
				-- printr(v)
				-- printr(questTable)
			end		
			return rewardCount
		end
		

		
		for i, questTable in pairs(incQuestTable) do

			if (questTable.rewards) and (questTable.rewards.rewards) and (type(questTable.rewards.rewards) == 'table') then
				local rewardCount = 0
				for _, rewardTable in pairs(questTable.rewards.rewards) do
					for i, v in pairs(rewardTable) do
						rewardCount = CheckTableForRewards(questTable, i, v, rewardCount)					
					end
				end
				questTable.rewardCount = rewardCount
			end
			
			if (questTable) and  (questTable.displayType) then
				if (tonumber(questTable.displayType) == QUEST_TYPE_COUNT) then
					questTable.questTypeIcon = '/ui/main/quests/textures/quest_type_lifetime.tga'
					if (questTable) and (questTable.required) and (questTable.required.experience) and (questTable.required.experience.experience) then
						-- these arent counted as they are in their own section
					elseif (questTable) and (questTable.required) and (questTable.required.games) and (questTable.required.games.winsashero) then
						-- these arent counted as they are in their own section		
					elseif (questTable) and (questTable.required) and (questTable.required.division) and (questTable.required.division.division) then	
						-- Heroes go to hero section	
					elseif (questTable) and (questTable.required) and (questTable.required.division1) and (questTable.required.division1.division1) then	
						-- Heroes go to hero section	
					elseif (questTable) and (questTable.required) and (questTable.required.division2) and (questTable.required.division2.division2) then	
						-- Heroes go to hero section		
					elseif (questTable) and (questTable.required) and (questTable.required.friendReferals) and (questTable.required.friendReferals.friendReferals) then	
						-- hide RAF it has its own section			
					elseif (questTable) and (questTable.required) and (questTable.required.inactive) and (questTable.required.inactive.inactive) then	
						-- hide inactive
					else
						if (count) then questsTrigger['count'..QUEST_TYPE_COUNT] = questsTrigger['count'..QUEST_TYPE_COUNT] + 1 end
					end
				elseif (tonumber(questTable.displayType) == QUEST_TYPE_DAILY) then
					if (count) then questsTrigger['count'..QUEST_TYPE_DAILY] = questsTrigger['count'..QUEST_TYPE_DAILY] + 1 end
					questTable.questTypeIcon = '/ui/main/quests/textures/quest_type_day.tga'
				elseif (tonumber(questTable.displayType) == QUEST_TYPE_WEEKLY) then
					if (count) then questsTrigger['count'..QUEST_TYPE_WEEKLY] = questsTrigger['count'..QUEST_TYPE_WEEKLY] + 1 end
					questTable.questTypeIcon = '/ui/main/quests/textures/quest_type_week.tga'
				elseif (tonumber(questTable.displayType) == QUEST_TYPE_MONTHLY) then
					if (count) then questsTrigger['count'..QUEST_TYPE_MONTHLY] = questsTrigger['count'..QUEST_TYPE_MONTHLY] + 1 end
					questTable.questTypeIcon = '/ui/main/quests/textures/quest_type_month.tga'
				elseif (tonumber(questTable.displayType) == QUEST_TYPE_CALLTOACTION) then
					-- questTable.questTypeIcon = '/ui/main/quests/textures/quest_type_day.tga'
				end
			end
			
		end	
		return incQuestTable
	end
	
	if (questsProcessedTable2) then
		questsProcessedTable2 = GetQuestIconsAndLabels(questsProcessedTable2, false)
	end		
	
	if (questsVisibleProcessedTable) then
		questsVisibleProcessedTable = GetQuestIconsAndLabels(questsVisibleProcessedTable, true)
	end
	
	local profileInfo = LuaTrigger.GetTrigger('playerProfileInfo')
	profileInfo.questCount = #questsVisibleProcessedTable
	profileInfo:Trigger(false)
	
	if (profileInfo.questCount > 0) then
		trigger_postGameLoopStatus.questsAvailable 	= true
		trigger_postGameLoopStatus:Trigger(false)	
	end

	questsTrigger:Trigger(true)

	-- Add quests with progress and completion
	if (questsVisibleProcessedTable) then
		for i, questTable in pairs(questsVisibleProcessedTable) do
			if (questTable.rewardsAvailable and (type(questTable.rewardsAvailable) == 'table') and (#questTable.rewardsAvailable > 0)) then
				tinsert(Quests.newlyCompletedQuests, questTable)
				trigger_postGameLoopStatus.unlocksAvailable 	= true
				trigger_postGameLoopStatus.progressAvailable	 	= true
				trigger_postGameLoopStatus:Trigger(false)			
			elseif questTable.percentLatestProgress and questTable.percentLatestProgress > 0 then
				if (questTable.percentProgress >= 1) then
					tinsert(Quests.newlyCompletedQuests, questTable)
					trigger_postGameLoopStatus.unlocksAvailable 	= true				
					trigger_postGameLoopStatus:Trigger(false)
				else
					tinsert(Quests.questsWithProgress, questTable) 
					trigger_postGameLoopStatus.progressAvailable	 = true		
					trigger_postGameLoopStatus:Trigger(false)				
				end
			else	
				tinsert(Quests.questsWithoutProgress, questTable) 				
			end
		end
	end

	table.sort(Quests.questsWithProgress, function(a,b) return a.percentLatestProgress > b.percentLatestProgress end)
	table.sort(Quests.questsWithoutProgress, function(a,b) return a.percentProgress > b.percentProgress end)
	
	-- add complete quests, quests with progress
	local sideCount = 0
	
	-- Clear any previous entries
	groupfcall('postgame_progress_quests_entries', function(_, widget) widget:Destroy() end)

	local index = 0

	-- Find account progression and other quest completion (add progression too?), send off to the postgame splash module
	PostGame.Splash.modules = PostGame.Splash.modules or {}	
	
	-- Scan all quests for specific ones for progression, blarg
	local shouldUpdateProgression = false
	if (questsProcessedTable2) then
		for i, questTable in pairs(questsProcessedTable2) do
			if (questTable) and (questTable.required) and (questTable.percentProgress) and (questTable.percentProgress == 1) then
				if (questTable.required.spe_act1) and (questTable.required.spe_act1.spe_act1) then
					mainUI 											= mainUI 									or {}
					mainUI.savedLocally 							= mainUI.savedLocally 						or {}
					mainUI.savedLocally.questsComplete 				= mainUI.savedLocally.questsComplete 		or {}
					mainUI.savedLocally.questsComplete.spe1 		= true
					SaveState()
					shouldUpdateProgression = true
				elseif (questTable.required.games) and (questTable.required.games.winsashero) and (questTable.localContent) then	
					mainUI.progression 																= mainUI.progression 											or {}	
					mainUI.progression.stats 														= mainUI.progression.stats 										or {}	
					mainUI.progression.stats.heroes 												= mainUI.progression.stats.heroes 								or {}	
					mainUI.progression.stats.heroes[questTable.localContent] 						= mainUI.progression.stats.heroes[questTable.localContent] 		or {}	
					mainUI.progression.stats.heroes[questTable.localContent].questAwardMastered 	= true
					shouldUpdateProgression = true
				elseif (questTable.required.division) and (questTable.required.division.division) and (questTable.localContent)  then	
					mainUI.progression 																= mainUI.progression 											or {}	
					mainUI.progression.stats 														= mainUI.progression.stats 										or {}	
					mainUI.progression.stats.heroes 												= mainUI.progression.stats.heroes 								or {}	
					mainUI.progression.stats.heroes[questTable.localContent] 						= mainUI.progression.stats.heroes[questTable.localContent] 		or {}	
					mainUI.progression.stats.heroes[questTable.localContent]['questAwardDivision'..questTable.required.division.division] 	= true		
					shouldUpdateProgression = true				
				end
			end
			if (questTable) and (questTable.required) and (questTable.percentProgress) and (questTable.required.friendReferals) and (questTable.required.friendReferals.friendReferals)  then	-- Typo intentional
				if (questTable.progress) and (questTable.progress.friendReferals) and (questTable.progress.friendReferals.friendReferals)  then	
					mainUI.progression 																= mainUI.progression 											or {}	
					mainUI.progression.stats 														= mainUI.progression.stats 										or {}	
					mainUI.progression.stats.referafriend 											= mainUI.progression.stats.referafriend 						or {}	
					mainUI.progression.stats.referafriend.referrals									= questTable.progress.friendReferals.friendReferals
					shouldUpdateProgression = true		
				end
			end		
		end
	end

	groupfcall('postgame_reward_quest_items', function(_, widget) widget:Destroy() end)
	local postgame_rewards_insert_quest_rewards 				= 	GetWidget('postgame_rewards_insert_quest_rewards')
	local postgame_rewards_insert_quest_rewards_insert 			= 	GetWidget('postgame_rewards_insert_quest_rewards_insert')	
	local postgame_rewards_content_parent 						= 	GetWidget('postgame_rewards_content_parent')	
	if (Quests.newlyCompletedQuests) and (#Quests.newlyCompletedQuests > 0) then	
		postgame_rewards_insert_quest_rewards:SetVisible(1)
		postgame_rewards_content_parent:SetY('170s')
		PostGame.Splash.modules.questProgression = {}
		for i, questTable in pairs(Quests.newlyCompletedQuests) do
			if (questTable) and (questTable.required) and (questTable.required.experience) and (questTable.required.experience.experience) then

			else
				PostGame.Splash.modules.questProgression = PostGame.Splash.modules.questProgression or {}
				tinsert(PostGame.Splash.modules.questProgression, questTable)
			end
		end
	else
		postgame_rewards_insert_quest_rewards:SetVisible(0)
		postgame_rewards_content_parent:SetY('240s')
	end

	-- Populate profile quests section
	local main_center_content_quests_scrollbox = GetWidget('main_center_content_quests_scrollbox')
	local main_center_content_quests_scrollbox_vscroll = GetWidget('main_center_content_quests_scrollbox_vscroll')
	
	local sideCount = 0
	groupfcall('profile_quests_entries', function(_, widget) widget:Destroy() end)
	main_center_content_quests_scrollbox:ClearItems()

	local index = 0
	local function InstantiateProfileQuest(questTable)
		local rewardCount = TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_reward_count') or questTable.rewardCount or '0'
		local showCount = (not Empty(TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_reward_label_1') or questTable.rewardText1 or '')) or false
		local isComplete, progressLabel1 = false, ''
		if (questTable.percentProgress >= 1) then
			isComplete = true
			progressLabel1 = Translate('general_complete')
		elseif (questTable.percentProgress <= 0) then
			isComplete = false
			progressLabel1 = tostring(questTable.requirementTotal)
		else
			isComplete = false
			progressLabel1 = tostring(questTable.currentProgress) .. ' / ' .. tostring(questTable.requirementTotal)
		end		
		
		if (progressLabel1 == '1') then
			progressLabel1 = Translate('quest_simple_progress_incomplete')
		end		
		
		local hasReward1 = tonumber( rewardCount ) >= 1
		local hasReward2 = tonumber( rewardCount ) >= 2
		local hasReward3 = tonumber( rewardCount ) >= 3				
		local hasReward4 = tonumber( rewardCount ) >= 4				
		
		local rewardText3, rewardIcon3
		if (hasReward4) and (questTable.rewardIconPack) and (questTable.rewardTextPack) then 
			rewardText3 = questTable.rewardTextPack
			rewardIcon3 = questTable.rewardIconPack
		end
		
		main_center_content_quests_scrollbox:AddTemplateListItem('quest_item_card', index,
			'id', questTable.questIncrement,
			'index', tostring(index),
			'questName1', TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_name') or questTable.labelText or '',
			'progressLabel1', tostring(progressLabel1),
			'isComplete', tostring(isComplete),
			'backgroundTexture1', TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_texture') or questTable.texture or '/ui/main/quests/textures/quest_item_card_lexikhan.tga',
			'rewardIcon1', TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_reward_texture_1') or questTable.rewardIcon1 or '/ui/main/shared/textures/scroll.tga',
			'rewardIcon2', TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_reward_texture_2') or questTable.rewardIcon2 or '/ui/main/shared/textures/scroll.tga',
			'rewardIcon3', TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_reward_texture_3') or rewardIcon3 or '/ui/main/shared/textures/scroll.tga',
			'rewardText1', TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_reward_label_1') or questTable.rewardText1 or '',
			'rewardText2', TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_reward_label_2') or questTable.rewardText2 or '',
			'rewardText3', TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_reward_label_3') or rewardText3 or '',
			'rewardCount', TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_reward_count') or questTable.rewardCount or '0',
			'hasReward1', tostring(hasReward1),
			'hasReward2', tostring(hasReward2),
			'hasReward3', tostring(hasReward3),			
			'progressPercent', math.min(100, (questTable.percentProgress * 100)),
			'oldProgressPercent', math.min(100, ((questTable.percentProgress - questTable.percentLatestProgress) * 100)),
			'questTypeIcon', TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_type_icon') or questTable.questTypeIcon or '$invis',
			'displayType', questTable.displayType or '',
			'showCount', tostring(showCount)
		)		
		index = index + 1
	end
	
	for _, questTable in ipairs(questsVisibleProcessedTable) do
		if (questTable) and (questTable.required) and (questTable.required.experience) and (questTable.required.experience.experience) then
			-- Account ones go to account section
		elseif (questTable) and (questTable.required) and (questTable.required.games) and (questTable.required.games.winsashero) then	
			-- Heroes go to hero section
		elseif (questTable) and (questTable.required) and (questTable.required.division) and (questTable.required.division.division) then	
			-- Heroes go to hero section	
		elseif (questTable) and (questTable.required) and (questTable.required.division1) and (questTable.required.division1.division1) then	
			-- Heroes go to hero section	
		elseif (questTable) and (questTable.required) and (questTable.required.division2) and (questTable.required.division2.division2) then	
			-- Heroes go to hero section			
		elseif (questTable) and (questTable.required) and (questTable.required.friendReferals) and (questTable.required.friendReferals.friendReferals) then	
			-- hide RAF it has its own section				
		elseif (questTable) and (questTable.required) and (questTable.required.inactive) and (questTable.required.inactive.inactive) then	
			-- closed beta inactive flag, used for OB gems quest
		elseif (questTable) and (questTable.alwaysHidden) then
			-- Hidden surprise quests, such stealth
		else		
			InstantiateProfileQuest(questTable)
		end
	end	
	
	-- Populate profile account section
	local player_profile_account_progress_quest_scrollbox 			= GetWidget('player_profile_account_progress_quest_scrollbox')
	local player_profile_account_progress_quest_scrollbox_vscroll 	= GetWidget('player_profile_account_progress_quest_scrollbox_vscroll')
	local player_profile_account_progression_parent 				= GetWidget('player_profile_account_progression_parent')
	
	local sideCount = 0
	player_profile_account_progress_quest_scrollbox_vscroll:SetValue(0)
	groupfcall('profile_account_progress_quest_list_vis', function(_, widget) widget:Destroy() end)
	groupfcall('profile_account_progress_quest_list', function(_, widget) widget:Destroy() end)
	
	local index = 0
	local currentAccountQuestIndex

	local function InstantiateHiddenProfileAccountQuest(questTable)
		
		local rewardCount = TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_reward_count') or questTable.rewardCount or '0'
		local progressBarWidth 	= 98.0
		if (rewardCount == 0) then
			progressBarWidth 	= 	98.0
		elseif (rewardCount == 1) then
			progressBarWidth 	= 	87.9			
		elseif (rewardCount == 2) then
			progressBarWidth 	= 	76.1	
		elseif (rewardCount == 3) then
			progressBarWidth 	= 	64.4
		end

		local hasReward1 = tonumber( rewardCount ) >= 1
		local hasReward2 = tonumber( rewardCount ) >= 2
		local hasReward3 = tonumber( rewardCount ) >= 3	
		local hasReward4 = tonumber( rewardCount ) >= 4	

		local showCount = (not Empty(TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_reward_label_1') or questTable.rewardText1 or '')) or false
		
		local rewardText1 = TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_reward_label_1') or questTable.rewardText1 or ''
		local rewardText2 = TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_reward_label_2') or questTable.rewardText2 or ''
		local rewardText3 = TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_reward_label_3') or questTable.rewardText3 or ''
		
		local rewardIcon1 = TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_reward_texture_1') or questTable.rewardIcon1 or '/ui/main/shared/textures/scroll.tga'
		local rewardIcon2 = TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_reward_texture_2') or questTable.rewardIcon2 or '/ui/main/shared/textures/scroll.tga'
		local rewardIcon3 = TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_reward_texture_3') or questTable.rewardIcon3 or '/ui/main/shared/textures/scroll.tga'
		
		if (hasReward4) and (questTable.rewardIconPack) and (questTable.rewardTextPack) then 
			rewardText3 = questTable.rewardTextPack
			rewardIcon3 = questTable.rewardIconPack
		end			
		
		local isComplete, progressLabel1 = false, ''
		if (questTable.percentProgress >= 1) then
			isComplete = true
			progressLabel1 = '' -- Translate('general_complete')
		elseif (questTable.percentProgress <= 0) then
			isComplete = false
			progressLabel1 = '' -- tostring(questTable.requirementTotal)
		else
			isComplete = false
			progressLabel1 = tostring(questTable.currentProgress) .. ' / ' .. tostring(questTable.requirementTotal)
		end		
		
		if (progressLabel1 == '1') then
			progressLabel1 = Translate('quest_simple_progress_incomplete')
		end		
		
		local popup = player_profile_account_progress_quest_scrollbox:AddTemplateListItem('postgame_quest_accountlevel_template', index,
			'id', questTable.questIncrement,
			'questName1', TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_name') or questTable.labelText or '',
			'progressLabel1', tostring(progressLabel1),
			'isComplete', tostring(isComplete),
			'backgroundTexture1', TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_texture') or '/ui/main/quests/textures/quest_item_card_lexikhan.tga',
			'rewardIcon1', rewardIcon1,
			'rewardIcon2', rewardIcon2,
			'rewardIcon3', rewardIcon3,
			'rewardText1Long', Translate('quest_reward_colon') .. ' ' .. rewardText1 .. ' ' .. rewardText2 .. ' ' .. rewardText3,
			'rewardText1', rewardText1,
			'rewardText2', rewardText2,
			'rewardText3', rewardText3,
			'rewardCount', rewardCount,
			'hasReward1', tostring(hasReward1),
			'hasReward2', tostring(hasReward2),
			'hasReward3', tostring(hasReward3),
			'progressBarWidth', progressBarWidth,
			'progressPercent', math.min(100, (questTable.percentProgress * 100)),
			'oldProgressPercent', math.min(100, ((questTable.percentProgress - questTable.percentLatestProgress) * 100)),
			'questTypeIcon', TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_type_icon') or questTable.questTypeIcon or '$invis',
			'group', 'profile_account_progress_quest_list',
			'showCount', tostring(showCount)
		)		
		index = index + 1
	end	
	
	tsort(questsProcessedTable2, function(a,b) 
		if (a) and (a.required) and (a.required.experience) and (a.required.experience.experience) then 
			if (b) and (b.required) and (b.required.experience) and (b.required.experience.experience) then
				return tonumber(a.required.experience.experience) < tonumber(b.required.experience.experience)
			else
				return true
			end
		else
			return false
		end
	end)
	
	for questLoopIndex, questTable in ipairs(questsProcessedTable2) do
		if (questTable) and (questTable.required) and (questTable.required.experience) and (questTable.required.experience.experience) then
			InstantiateHiddenProfileAccountQuest(questTable) 
			if (not questTable.hideQuestFromGroup) then
				currentAccountQuestIndex = (tonumber(questTable.questConsecutiveIndex) or 2)
				currentAccountQuestIndex = currentAccountQuestIndex - 1
			end
			PostGame.Splash.modules.allAccountProgression = PostGame.Splash.modules.allAccountProgression or {}
			local questLevel = mainUI.progression.GetAccountLevelFromExperience(questTable.required.experience.experience)
			if (questLevel) and (questLevel >= 0) then
				PostGame.Splash.modules.allAccountProgression[questLevel] = questTable
			end
			if (GetCvarBool('ui_testPostgame10')) then
				tinsert(PostGame.Splash.modules.questProgression, questTable)
			end
		end
	end
	if (currentAccountQuestIndex) then
		player_profile_account_progression_parent:FadeIn(250)
	end
	
	currentAccountQuestIndex = currentAccountQuestIndex or 70
	
	player_profile_account_progress_quest_scrollbox_vscroll:SetValue(currentAccountQuestIndex)

	player_profile_account_progress_quest_scrollbox:SetCallback('onevent', function()
		player_profile_account_progress_quest_scrollbox_vscroll:SetValue(currentAccountQuestIndex)
	end)

	if (shouldUpdateProgression) then
		LuaTrigger.GetTrigger('AccountProgression'):Trigger(true)
	end	
	
	-- == Splash
	
	-- Populate splash quests if we are not at the end game screen
	local quests_overlay 					= GetWidget('quests_overlay')
	local quest_popup_entry_target_insert 	= GetWidget('quest_popup_entry_target_insert')
	local quest_popup_entry_target 			= GetWidget('quest_popup_entry_target')
	groupfcall('splash_quest_cards', function(_, widget) widget:Destroy() end)

	local index = 0
	local function InstantiateSplashQuest(questTable)

		local rewardCount = TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_reward_count') or questTable.rewardCount or '0'
		local showCount = (not Empty(TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_reward_label_1') or questTable.rewardText1 or '')) or false
		local isComplete, progressLabel1 = false, ''
		if (questTable.percentProgress >= 1) then
			isComplete = true
			progressLabel1 = Translate('general_complete')
		elseif (questTable.percentProgress <= 0) then
			isComplete = false
			progressLabel1 = tostring(questTable.currentProgress) .. ' / ' .. tostring(questTable.requirementTotal)
		else
			isComplete = false
			progressLabel1 = tostring(questTable.currentProgress) .. ' / ' .. tostring(questTable.requirementTotal)
		end		
		
		if (progressLabel1 == '1') then
			progressLabel1 = Translate('quest_simple_progress_incomplete')
		end		
		
		local hasReward1 = tonumber( rewardCount ) >= 1
		local hasReward2 = tonumber( rewardCount ) >= 2
		local hasReward3 = tonumber( rewardCount ) >= 3			
		local hasReward4 = tonumber( rewardCount ) >= 4	
		
		local rewardText3, rewardIcon3
		if (hasReward4) and (questTable.rewardIconPack) and (questTable.rewardTextPack) then 
			rewardText3 = questTable.rewardTextPack
			rewardIcon3 = questTable.rewardIconPack
		end			
		
		local splashWidget = quest_popup_entry_target_insert:InstantiateAndReturn('splash_quest_item_card',
			'id', questTable.questIncrement,
			'index', tostring(index),
			'group', 'splash_quest_cards',
			'questName1', TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_name') or questTable.labelText or '',
			'progressLabel1', tostring(progressLabel1),
			'isComplete', tostring(isComplete),
			'backgroundTexture1', TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_texture') or questTable.texture or '/ui/main/quests/textures/quest_item_card_lexikhan.tga',
			'rewardIcon1', TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_reward_texture_1') or questTable.rewardIcon1 or '/ui/main/shared/textures/scroll.tga',
			'rewardIcon2', TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_reward_texture_2') or questTable.rewardIcon2 or '/ui/main/shared/textures/scroll.tga',
			'rewardIcon3', TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_reward_texture_3') or rewardIcon3 or '/ui/main/shared/textures/scroll.tga',
			'rewardText1', TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_reward_label_1') or questTable.rewardText1 or '',
			'rewardText2', TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_reward_label_2') or questTable.rewardText2 or '',
			'rewardText3', TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_reward_label_3') or rewardText3 or '',
			'rewardCount', TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_reward_count') or questTable.rewardCount or '0',
			'hasReward1', tostring(hasReward1),
			'hasReward2', tostring(hasReward2),
			'hasReward3', tostring(hasReward3),			
			'progressPercent', math.min(100, (questTable.percentProgress * 100)),
			'oldProgressPercent', math.min(100, ((questTable.percentProgress - questTable.percentLatestProgress) * 100)),
			'questTypeIcon', TranslateOrNil('quest_string_' .. questTable.questIncrement .. '_type_icon') or questTable.questTypeIcon or '$invis',
			'displayType', questTable.displayType or '',
			'showCount', tostring(showCount)
		)		

		index = index + 1
	end
	
	-- Populate splash quests if we are not at the end game screen

	if (Quests.splashTheseQuests) and (#Quests.splashTheseQuests > 0) and (((LuaTrigger.GetTrigger('mainPanelStatus').main ~= 10) and (LuaTrigger.GetTrigger('PostGameLoopStatus').showPostGameLoop == false)) or (GetCvarBool('ui_testQuestSplash'))) then

		local quests_overlay 					= GetWidget('quests_overlay')
		local quest_popup_entry_target_insert 	= GetWidget('quest_popup_entry_target_insert')
		local quest_popup_entry_target 			= GetWidget('quest_popup_entry_target')
		groupfcall('splash_quest_cards', function(_, widget) widget:Destroy() end)	
	
		if (Quests.splashTheseQuestsThread) then
			Quests.splashTheseQuestsThread:kill()
			Quests.splashTheseQuestsThread = nil
		end		
		Quests.splashTheseQuestsThread =  libThread.threadFunc(function()
			wait(3000)
			if (Quests.splashTheseQuests) and (#Quests.splashTheseQuests > 0) and (((LuaTrigger.GetTrigger('mainPanelStatus').main ~= 10) and (LuaTrigger.GetTrigger('PostGameLoopStatus').showPostGameLoop == false)) or (GetCvarBool('ui_testQuestSplash'))) then

				if quest_popup_entry_target and quest_popup_entry_target:IsValid() then

					quest_popup_entry_target:SetY('800s')
					for questIndex, questTable in ipairs(Quests.splashTheseQuests) do
						if (questTable.percentLatestProgress and questTable.percentLatestProgress > 0) or GetCvarBool('ui_testQuestSplash') then
							InstantiateSplashQuest(questTable)
							if (questIndex >= 4) then
								break
							end
						end
					end		
					quests_overlay:SetVisible(1)
					quest_popup_entry_target:SlideY('500s', styles_mainSwapAnimationDuration)
					
					if (QUESTS_CAN_BULK_CLAIM) then
						QUESTS_CAN_BULK_CLAIM = false
					
						local successFunction =  function (request)	-- response handler
							local responseData = request:GetBody()
							if responseData == nil then
								SevereError('ClaimAllQuestRewards - no response data', 'main_reconnect_thatsucks', '', nil, nil, false)
							else
								println('ClaimAllQuestRewards Success')
							end
							trigger_postGameLoopStatus.requestingClaimQuestReward = false
							trigger_postGameLoopStatus:Trigger(false)														
						end

						local failFunction =  function (request)	-- error handler
							SevereError('ClaimAllQuestRewards Request Error: ' .. Translate(request:GetError()), 'main_reconnect_thatsucks', '', nil, nil, false)
							trigger_postGameLoopStatus.requestingClaimQuestReward = false
							trigger_postGameLoopStatus:Trigger(false)							
						end						
					
						trigger_postGameLoopStatus.requestingClaimQuestReward = true
						trigger_postGameLoopStatus:Trigger(false)						
					
						Strife_Web_Requests:ClaimAllQuestRewards(
							successFunction,
							failFunction
						)					
					
					end				
					
					wait((styles_mainSwapAnimationDuration * 5) + 2000)
				end
				if (GetCvarBool('ui_testQuestSplash')) then
					wait(styles_mainSwapAnimationDuration * 10)
				end
				if quest_popup_entry_target and quest_popup_entry_target:IsValid() then
					quest_popup_entry_target:SlideY('800s', styles_mainSwapAnimationDuration)
					wait(styles_mainSwapAnimationDuration * 2)
					groupfcall('splash_quest_cards', function(_, widget) widget:Destroy() end)
				end
				Quests.splashTheseQuests = {}
				Quests.splashTheseQuestsThread = nil
			end
		end)
	end	
	LuaTrigger.GetTrigger('questsTrigger'):Trigger()
end

local function ClearQuestData()
	rewardsClaimed = 0
	questsTrigger.hasQuestData = false
	questsTrigger:Trigger(false)
end

function Quests.QuestData(responseData)

	trigger_postGameLoopStatus.questsAvailable 					= false
	trigger_postGameLoopStatus:Trigger(false)

	local successFunction =  function (request)	-- response handler

		if responseData == nil then
			questsTrigger.hasQuestData = false
			questsTrigger:Trigger(false)
			SevereError('GetQuests - no response data', 'main_reconnect_thatsucks', '', nil, nil, false)
			return nil
		else
			questsTrigger.hasQuestData = true
			questsTrigger:Trigger(false)
			if mainUI.progression.UpdateProgression ~= nil then
				mainUI.progression.UpdateProgression()
			end
			Quests.questDataConsolidationTable = {}
			PopulateQuests(responseData)
			return true
		end
	end

	if ((mainUI.featureMaintenance) and (not mainUI.featureMaintenance['quests'])) then
		successFunction(responseData)
	else
		responseData = {}
		responseData.questEligibility = {}
		responseData.questHistory = {}
		responseData.questRewards = {}
		responseData.questDailies = {}
		questsTrigger.hasQuestData = true
		questsTrigger:Trigger(false)
		if mainUI.progression.UpdateProgression ~= nil then
			mainUI.progression.UpdateProgression()
		end
		Quests.questDataConsolidationTable = {}
		PopulateQuests(responseData)
	end

end

local function QuestsInputRegister(object)
	local quests_input_textbox				= GetWidget('quests_menu_search_input')
	local quests_input_coverup				= GetWidget('quests_menu_search_input_cover')
	local quests_input_button				= GetWidget('quests_menu_search_go_btn')
	local quests_menu_search_close_btn		= GetWidget('quests_menu_search_close_btn')

	function Quests.InputOnEnter()
		quests_input_textbox:SetFocus(false)
	end

	function Quests.InputOnEsc()
		quests_input_textbox:EraseInputLine()
		quests_input_textbox:SetFocus(false)
		quests_input_coverup:SetVisible(true)
		quests_menu_search_close_btn:SetVisible(0)
	end

	quests_input_button:SetCallback('onclick', function(widget)
		quests_input_textbox:SetFocus(true)
	end)

	quests_menu_search_close_btn:SetCallback('onclick', function(widget)
		Quests.InputOnEsc()
	end)

	quests_input_textbox:SetCallback('onfocus', function(widget)
		quests_input_coverup:SetVisible(false)
		quests_menu_search_close_btn:SetVisible(1)
	end)

	quests_input_textbox:SetCallback('onlosefocus', function(widget)
		if string.len(widget:GetValue()) == 0 then
			quests_input_coverup:SetVisible(true)
			quests_menu_search_close_btn:SetVisible(0)
		end
	end)

	quests_input_textbox:SetCallback('onhide', function(widget)
		 Quests.InputOnEsc()
	end)

	quests_input_textbox:SetCallback('onchange', function(widget)
		questsTrigger.selectedDisplayType = ''
		questsTrigger.searchString = string.lower(widget:GetValue() or '')
		questsTrigger:Trigger(true)
	end)
end

local function registerQuestTypeFilter(questType, widgetName)
	local button		= GetWidget(widgetName)
	local backer		= GetWidget(widgetName..'Backer')
	local prog_label	= GetWidget(widgetName..'_prog_label')
	button:SetCallback('onclick', function(widget)
		if (questsTrigger.selectedDisplayType ~= tostring(questType)) then
			questsTrigger.selectedDisplayType = tostring(questType)
		else
			questsTrigger.selectedDisplayType = ''
		end
		questsTrigger:Trigger(true)
	end)

	backer:RegisterWatchLua('questsTrigger', function(widget, trigger)
		local selectedDisplayType = trigger.selectedDisplayType
		if selectedDisplayType == '' or selectedDisplayType == tostring(questType) then
			backer:SetRenderMode('normal')
		else
			backer:SetRenderMode('grayscale')
		end
	end, false, nil, 'selectedDisplayType')
	
	prog_label:RegisterWatchLua('questsTrigger', function(widget, trigger)
		widget:SetText(trigger['count' .. questType] or '0')
	end, false, nil)
	
end

local function QuestsFilterRegister(object)
	registerQuestTypeFilter(QUEST_TYPE_DAILY, 'quests_menu_category_item_achievements_dailyquests')
	registerQuestTypeFilter(QUEST_TYPE_WEEKLY, 'quests_menu_category_item_achievements_weeklyquests')
	registerQuestTypeFilter(QUEST_TYPE_MONTHLY, 'quests_menu_category_item_achievements_monthlyquests')
	registerQuestTypeFilter(QUEST_TYPE_COUNT, 'quests_menu_category_item_achievements_lifetimequests')
end

local function QuestsRegister(interface)

	QuestsInputRegister(object)
	QuestsFilterRegister(object)

	questsTrigger.selectedDisplayType 	 = ''
	questsTrigger.hasQuestData			 = false
	questsTrigger:Trigger(true)
	

	object:RegisterWatchLua('QuestUpdate', function(widget, trigger)
		if ((mainUI.featureMaintenance) and (mainUI.featureMaintenance['quests'])) then
			return
		end			
		
		local questTable = trigger.questData

		if questTable and type(questTable) == 'table' then
			-- PopulateQuests(nil, questTable)	
		end
	end)	

end

QuestsRegister(interface)