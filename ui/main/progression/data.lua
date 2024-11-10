local tinsert = table.insert
mainUI.progressionData = mainUI.progressionData or {}
local GetTrigger = LuaTrigger.GetTrigger
local AccountProgression = GetTrigger('AccountProgression')

function mainUI.progressionData.GenerateFakeAccountData()
	mainUI.progressionData.accountValues = mainUI.progressionData.accountValues or {}
	
	mainUI.progressionData.accountValues.accountLevelTable = GetAccountLevelToExperience() 
	mainUI.progressionData.accountValues.petLevelToAccountLevel = GetPetLevelToAccountLevel()
					
	mainUI.progressionData.accountValues.petsAbilityLevelByPetLevel = {
	--	  1  2  3  4  5  6  7  8  9	
		{ 1, 2, 2, 3, 3, 3, 3, 3, 3 },	-- Active
		{ 0, 0, 1, 1, 2, 2, 2, 3, 3 },	-- Triggered
		{ 0, 0, 0, 0, 0, 1, 2, 2, 3 },	-- Passive
	}
	
	mainUI.progressionData.accountValues.accountLevelToPrize = {}

end

function mainUI.progressionData.GenerateFakeQuests()
	
	local function GetPetLevelPrizeFromAccountLevel(currentAccountLevel)
		local petLevelToAccountLevel = mainUI.progressionData.accountValues.petLevelToAccountLevel
		table.sort(petLevelToAccountLevel, function(a, b) return a < b end)
		for petLevel, accountLevel in ipairs(petLevelToAccountLevel) do
			if (currentAccountLevel == accountLevel) then
				return petLevel
			end
		end
		return nil
	end
	
	local function GetCustomPrizeFromAccountLevel(currentAccountLevel)
		local customPrizeFromAccountLevel = mainUI.progressionData.accountValues.accountLevelToPrize
		table.sort(customPrizeFromAccountLevel, function(a, b) return a > b end)
		for accountLevel, customPrize in ipairs(customPrizeFromAccountLevel) do
			if (currentAccountLevel == accountLevel) then
				return customPrize
			end
		end
		return nil
	end	
	
	local function GetAccountLevelPrize(accountLevel, questIncrement)
		local prize
		local petPrize = GetPetLevelPrizeFromAccountLevel(accountLevel)
		local customPrize = GetCustomPrizeFromAccountLevel(accountLevel)
	
		if (customPrize) then
			prize =  {
				[0] = {
					['isCustomPrize'] = '1',
					['customPrize'] = customPrize,
					['questIncrement'] = questIncrement,
				},
			}					
		elseif (petPrize) then
			prize =  {
				[0] = {
					['isPetLevel'] = '1',
					['petLevel'] = petPrize,
					['questIncrement'] = questIncrement,
				},
			}
		else
			prize =  nil
		end
		
		return prize
		
	end
	
	local function GetExperienceFromAccountLevel(accountLevel)
		return mainUI.progressionData.accountValues.accountLevelTable[accountLevel] or -1
	end
	
	local function GetExperienceToNextLevel(currentLevel, currentExperience)
		if (mainUI.progressionData.accountValues.accountLevelTable[currentLevel + 1]) and (mainUI.progressionData.accountValues.accountLevelTable[currentLevel]) then
			local experienceToNextLevel 		= mainUI.progressionData.accountValues.accountLevelTable[currentLevel + 1] - mainUI.progressionData.accountValues.accountLevelTable[currentLevel]
			local currentExperienceToNextLevel 	= currentExperience - mainUI.progressionData.accountValues.accountLevelTable[currentLevel]
			local percentToNextLevel = currentExperienceToNextLevel / experienceToNextLevel
			return experienceToNextLevel, percentToNextLevel
		else
			return 0, 1
		end
	end	
	
	local function GetAccountExperienceQuestData(currentTotalExperience, newTotalExperience, totalExperienceRequired, accountLevel)
		
		local levelBelowExperience 				= mainUI.progressionData.accountValues.accountLevelTable[accountLevel - 1] or 0
		local newExperienceAtThisLevel 			= newTotalExperience
		local lastExperienceAtThisLevel 		= currentTotalExperience - levelBelowExperience
		local experienceToCompleteThisLevel 	= totalExperienceRequired - levelBelowExperience

		newExperienceAtThisLevel 		= math.max(0, newExperienceAtThisLevel)
		lastExperienceAtThisLevel 		= math.max(0, lastExperienceAtThisLevel)
		experienceToCompleteThisLevel 	= math.max(0, experienceToCompleteThisLevel)
		
		return lastExperienceAtThisLevel, newExperienceAtThisLevel, experienceToCompleteThisLevel 
	end
	
	mainUI.progressionData.fakeQuests = {}
	local ident_id = GetIdentID()

	for accountLevel, experienceRequired in ipairs(mainUI.progressionData.accountValues.accountLevelTable) do
		local questIncrement = 1000 + accountLevel
		local lastExperienceAtThisLevel, newExperienceAtThisLevel, experienceToCompleteThisLevel

		lastExperienceAtThisLevel, newExperienceAtThisLevel, experienceToCompleteThisLevel = GetAccountExperienceQuestData(AccountProgression.lastExperience, AccountProgression.newExperience, GetExperienceFromAccountLevel(accountLevel), accountLevel)
		
		local prize = GetAccountLevelPrize(accountLevel, questIncrement)
		if (prize) then
			tinsert(mainUI.progressionData.fakeQuests, {
					['progress'] = {
						['account'] = {
							['experience'] = lastExperienceAtThisLevel,
						},
					},
					['ident_id'] = ident_id,
					['latestProgress'] = {
						['account'] = {
							['experience'] = newExperienceAtThisLevel,
						},
					},
					['quest'] = {
						['enabled'] = 1,
						['required'] = {
							['account'] = {
								['experience'] = experienceToCompleteThisLevel,
							},
						},
						['questIncrement'] = questIncrement,
						['active'] = 1,
						['rewards'] = prize,
						['displayType'] = 0,			 -- Lifetime
					},
					['questIncrement'] = questIncrement,
				}
			)
		end
	end

	return mainUI.progressionData.fakeQuests
	
end

mainUI.progressionData.GenerateFakeAccountData()
-- mainUI.progressionData.GenerateFakeQuests()
