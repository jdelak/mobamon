
local _G = getfenv(0)
local ipairs, pairs, select, string, table, next, type, unpack, tinsert, tconcat, tremove, format, tostring, tonumber, tsort, ceil, floor, sub, find, gfind = _G.ipairs, _G.pairs, _G.select, _G.string, _G.table, _G.next, _G.type, _G.unpack, _G.table.insert, _G.table.concat, _G.table.remove, _G.string.format, _G.tostring, _G.tonumber, _G.table.sort, _G.math.ceil, _G.math.floor, _G.string.sub, _G.string.find, _G.string.gfind
local interface, interfaceName = object, object:GetName()
local GetTrigger = LuaTrigger.GetTrigger
local tinsert = table.insert
local tremove = table.remove
MiniGames = {}

-- HeroSelectHeroList

-- icon:SetTexture(heroTrigger['ability'..index..'IconPath'] or '$checker')
-- title:SetText(heroTrigger['ability'..index..'DisplayName'] or '?')
-- description:SetText(heroTrigger['ability'..index..'SimpleDescription'] or '?')
		
local gameOfStrifeTrigger = LuaTrigger.CreateCustomTrigger('gameOfStrifeTrigger',
	{
		{ name	= 'answerGiven',			type	= 'bool' },		
		{ name	= 'correctAnswer',			type	= 'number' },		
	}
)

local correctAnswers = 0
local maxHeroes = 15
local maxAbilities = 3
local maxPets = 9
		
local GetQuestion		
		
local function Answered(correctly)
	gameOfStrifeTrigger:Trigger(true)
	groupfcall('game_of_strife_abilities', function (_, widget) widget:SetNoClick(1) end)
	if (correctly) then
		correctAnswers = correctAnswers + 1
		interface:GetWidget('game_of_strife_correct'):FadeIn(500, function(widget) widget:Sleep(2500, function(widget) widget:FadeOut(250, function() end) end) end)
		interface:GetWidget('game_of_strife_header_2'):SetText(Translate('game_of_strife_answered', 'value', correctAnswers))
		interface:GetWidget('game_of_strife_header_2'):FadeIn(500)
	else
		interface:GetWidget('game_of_strife_incorrect'):FadeIn(500, function(widget) widget:Sleep(2500, function(widget) widget:FadeOut(250, function() end) end) end)
	end
	libThread.threadFunc(function()	
		wait(3250)
		GetQuestion()
	end)	
end

local function GetRandomItem(selectedItemAnswer)

	local randomItemAnswer = math.random(1, 50)

	if (randomItemAnswer == selectedItemAnswer) then
		return GetRandomItem(selectedItemAnswer)
	end
	
	local randomItemAnswerTrigger = GetTrigger('ShopItem' .. randomItemAnswer)
	
	if randomItemAnswerTrigger and randomItemAnswerTrigger.entity then
	
		local randomAnswerTable =  {
			texture = GetEntityIconPath(randomItemAnswerTrigger.entity),
			name 	= GetEntityDisplayName(randomItemAnswerTrigger.entity),
			desc 	= '',
			isCorrect = false,
		}	
		
		return randomAnswerTable
	
	else
		GetRandomItem(selectedItemAnswer)
	end
end		
	
local function GetRandomPetAbility(selectedHeroAnswer, selectedAbilityAnswer)

	local randomPetAnswer = math.random(1, maxPets)
	local randomAbilityAnswer = math.random(1, 3)
	
	if randomAbilityAnswer == 1 then
		randomAbilityAnswer = 'Active'
	elseif randomAbilityAnswer == 2 then
		randomAbilityAnswer = 'triggered'
	elseif randomAbilityAnswer == 3 then
		randomAbilityAnswer = 'passiveA'
	end	
	
	if (randomPetAnswer == selectedHeroAnswer) or (randomAbilityAnswer == selectedAbilityAnswer) then
		return GetRandomPetAbility(selectedHeroAnswer, selectedAbilityAnswer)
	end
	
	local randomPetAnswerTrigger = GetTrigger('HeroSelectFamiliarList' .. randomPetAnswer)
	
	local randomAnswerTable =  {
		texture = randomPetAnswerTrigger[randomAbilityAnswer .. 'Icon'],
		name 	= randomPetAnswerTrigger[randomAbilityAnswer .. 'Name'],
		desc 	= randomPetAnswerTrigger[randomAbilityAnswer .. 'DescriptionSimple'],
		isCorrect = false,
	}	
	
	return randomAnswerTable
	
end			
			
local function GetRandomAbility(selectedHeroAnswer, selectedAbilityAnswer)

	local randomHeroAnswer = math.random(1, maxHeroes)
	local randomAbilityAnswer = math.random(0, maxAbilities)
	
	if (randomHeroAnswer == selectedHeroAnswer) or (randomAbilityAnswer == selectedAbilityAnswer) then
		return GetRandomAbility(selectedHeroAnswer, selectedAbilityAnswer)
	end
	
	local randomHeroAnswerTrigger = GetTrigger('HeroSelectHeroList' .. randomHeroAnswer)
	
	local randomAnswerTable =  {
		texture = randomHeroAnswerTrigger['ability' .. randomAbilityAnswer .. 'IconPath'],
		name 	= randomHeroAnswerTrigger['ability' .. randomAbilityAnswer .. 'DisplayName'],
		desc 	= randomHeroAnswerTrigger['ability' .. randomAbilityAnswer .. 'SimpleDescription'],
		isCorrect = false,
	}	
	
	return randomAnswerTable
	
end			

local function GetRandomHero(selectedHeroAnswer, selectedAbilityAnswer)

	local randomHeroAnswer = math.random(1, maxHeroes)
	local randomAbilityAnswer = math.random(0, maxAbilities)
	
	if (randomHeroAnswer == selectedHeroAnswer) or (randomAbilityAnswer == selectedAbilityAnswer) then
		return GetRandomHero(selectedHeroAnswer, selectedAbilityAnswer)
	end
	
	local randomHeroAnswerTrigger = GetTrigger('HeroSelectHeroList' .. randomHeroAnswer)
	
	local randomAnswerTable =  {
		texture = randomHeroAnswerTrigger.iconPath,
		name 	= randomHeroAnswerTrigger.displayName,
		desc 	= randomHeroAnswerTrigger.description,
		isCorrect = false,
	}		
	
	return randomAnswerTable
	
end	

local function GetRandomPet(selectedHeroAnswer, selectedAbilityAnswer)

	local randomPetAnswer = math.random(1, maxPets)
	local randomAbilityAnswer = math.random(0, maxAbilities)
	
	if (randomPetAnswer == selectedHeroAnswer) or (randomAbilityAnswer == selectedAbilityAnswer) then
		return GetRandomPet(selectedHeroAnswer, selectedAbilityAnswer)
	end
	
	local randomPetAnswerTrigger = GetTrigger('HeroSelectFamiliarList' .. randomPetAnswer)
	
	local randomAnswerTable =  {
		texture = GetEntityIconPath(randomPetAnswerTrigger.entityName),
		name 	= GetEntityDisplayName(randomPetAnswerTrigger.entityName),
		desc 	= randomPetAnswerTrigger.description,
		isCorrect = false,
	}		
	
	return randomAnswerTable
	
end	

local function PopulateQuestionSlot(slot, questionContentTable)
	local parent 		= interface:GetWidget('game_of_strife_ability_' .. slot)
	local name 			= interface:GetWidget('game_of_strife_ability_' .. slot .. '_name')
	local texture 		= interface:GetWidget('game_of_strife_ability_' .. slot .. '_icon')
	local desc 			= interface:GetWidget('game_of_strife_ability_' .. slot .. '_description')

	name:SetText(questionContentTable.name)
	desc:SetText(questionContentTable.desc)
	texture:SetTexture(questionContentTable.texture)
	
end

local function PopulateAnswerSlot(slot, questionContentTable)
	local parent 		= interface:GetWidget('game_of_strife_ability_' .. slot)
	local name 			= interface:GetWidget('game_of_strife_ability_' .. slot .. '_name')
	local texture 		= interface:GetWidget('game_of_strife_ability_' .. slot .. '_icon')
	local desc 			= interface:GetWidget('game_of_strife_ability_' .. slot .. '_description')
	local border 		= interface:GetWidget('game_of_strife_ability_' .. slot .. '_border')
	local frame 		= interface:GetWidget('game_of_strife_ability_' .. slot .. '_frame')
	local frame2 		= interface:GetWidget('game_of_strife_ability_' .. slot .. '_frame2')
	
	parent:SetCallback('onmouseover', function(widget) frame:FadeIn(125) frame2:FadeIn(125) end)
	parent:SetCallback('onmouseout', function(widget) frame:FadeOut(125) frame2:FadeOut(125) end)
	
	if (questionContentTable.isCorrect) then
		parent:SetCallback('onclick', function(widget) border:SetBorderColor('0 1 0 1') Answered(true) end)
		parent:RegisterWatchLua('gameOfStrifeTrigger', function(widget, trigger)
			border:SetBorderColor('0 1 0 1')
		end)
	else
		parent:SetCallback('onclick', function(widget) border:SetBorderColor('1 0 0 1') Answered(false) end)
		parent:UnregisterWatchLua('gameOfStrifeTrigger')	
	end

	name:SetText(questionContentTable.name)
	desc:SetText(questionContentTable.desc)
	texture:SetTexture(questionContentTable.texture)
	
end

local last_questionType = -1
GetQuestion = function()
	
	local questionType
	while (questionType == nil) or (questionType == last_questionType) do
		questionType = math.random(1,5) -- 1: Match ability to Hero. 2: Match Hero to ability. 3: Match ability to Pet. 4:Match pet to ability. 5: Match item description to name + icon.
	end
	
	last_questionType =  questionType

	if (questionType == 1) then

		local selectedHeroAnswer = math.random(0, maxHeroes)
		local selectedAbilityAnswer = math.random(0, maxAbilities)
		
		local selectedHeroAnswerTrigger = GetTrigger('HeroSelectHeroList' .. selectedHeroAnswer)
		
		if (not selectedHeroAnswerTrigger) or Empty(selectedHeroAnswerTrigger.displayName) then
			GetQuestion()
		else		
		
			local questionTable =  {
				texture = selectedHeroAnswerTrigger.iconPath,
				name 	= selectedHeroAnswerTrigger.displayName,
				desc 	= Translate('game_of_strife_question_' .. questionType),
			}
			
			PopulateQuestionSlot(0, questionTable)
			
			local correctAnswerTable =  {
				texture = selectedHeroAnswerTrigger['ability' .. selectedAbilityAnswer .. 'IconPath'],
				name 	= selectedHeroAnswerTrigger['ability' .. selectedAbilityAnswer .. 'DisplayName'],
				desc 	= selectedHeroAnswerTrigger['ability' .. selectedAbilityAnswer .. 'SimpleDescription'],
				isCorrect = true,
			}
			
			local questionContentTable = {}
			
			tinsert(questionContentTable, correctAnswerTable)
			local count = 0
			while (#questionContentTable < 4) do
				local randomAbility = GetRandomAbility(selectedHeroAnswer, selectedAbilityAnswer)
				if (not IsInTable(questionContentTable, randomAbility.name)) then
					tinsert(questionContentTable, randomAbility)
				end
				count = count + 1
				if count > 1000 then
					break
				end
			end
			
			
			local currentWidget = 1
			local currentEntry
			
			while (#questionContentTable > 0) do
				currentEntry = math.random(1, #questionContentTable)
				PopulateAnswerSlot(currentWidget, questionContentTable[currentEntry])
				tremove(questionContentTable, currentEntry)
				currentWidget = currentWidget + 1
			end
		end
	elseif (questionType == 2) then	
		
		local selectedHeroAnswer = math.random(0, maxHeroes)
		local selectedAbilityAnswer = math.random(0, maxAbilities)
		
		local selectedHeroAnswerTrigger = GetTrigger('HeroSelectHeroList' .. selectedHeroAnswer)
		
		if (not selectedHeroAnswerTrigger) or Empty(selectedHeroAnswerTrigger.displayName) then
			GetQuestion()
		else

			local questionTable =  {
				texture = selectedHeroAnswerTrigger['ability' .. selectedAbilityAnswer .. 'IconPath'],
				name 	= selectedHeroAnswerTrigger['ability' .. selectedAbilityAnswer .. 'DisplayName'],
				desc 	=  Translate('game_of_strife_question_' .. questionType),
			}			
			
			PopulateQuestionSlot(0, questionTable)
			
			local correctAnswerTable =  {
				texture = selectedHeroAnswerTrigger.iconPath,
				name 	= selectedHeroAnswerTrigger.displayName,
				desc 	= selectedHeroAnswerTrigger.description,
				isCorrect = true,
			}		
			
			local questionContentTable = {}
			
			tinsert(questionContentTable, correctAnswerTable)
			local count = 0
			while (#questionContentTable < 4) do
				local randomHero = GetRandomHero(selectedHeroAnswer, selectedAbilityAnswer)
				if (not IsInTable(questionContentTable, randomHero.name)) then
					tinsert(questionContentTable, randomHero)
				end
				count = count + 1
				if count > 1000 then
					break
				end
			end


			local currentWidget = 1
			local currentEntry
			
			while (#questionContentTable > 0) do
				currentEntry = math.random(1, #questionContentTable)
				PopulateAnswerSlot(currentWidget, questionContentTable[currentEntry])
				tremove(questionContentTable, currentEntry)
				currentWidget = currentWidget + 1
			end		
		end
	elseif (questionType == 3) then

		local selectedPetAnswer = math.random(0, maxPets)
		local selectedAbilityAnswer = math.random(1, 3)
		
		if selectedAbilityAnswer == 1 then
			selectedAbilityAnswer = 'Active'
		elseif selectedAbilityAnswer == 2 then
			selectedAbilityAnswer = 'triggered'
		elseif selectedAbilityAnswer == 3 then
			selectedAbilityAnswer = 'passiveA'
		end

		local selectedPetAnswerTrigger = GetTrigger('HeroSelectFamiliarList' .. selectedPetAnswer)
		
		if (not selectedPetAnswerTrigger) or Empty(selectedPetAnswerTrigger.entityName) then
			GetQuestion()
		else		
		
			local questionTable =  {
				texture = GetEntityIconPath(selectedPetAnswerTrigger.entityName),
				name 	= GetEntityDisplayName(selectedPetAnswerTrigger.entityName),
				desc 	=  Translate('game_of_strife_question_' .. questionType),
			}			
			
			PopulateQuestionSlot(0, questionTable)
			
			local correctAnswerTable =  {
				texture = selectedPetAnswerTrigger[selectedAbilityAnswer .. 'Icon'],
				name 	= selectedPetAnswerTrigger[selectedAbilityAnswer .. 'Name'],
				desc 	= selectedPetAnswerTrigger[selectedAbilityAnswer .. 'DescriptionSimple'],
				isCorrect = true,
			}
			
			local questionContentTable = {}
			
			tinsert(questionContentTable, correctAnswerTable)
			local count = 0
			while (#questionContentTable < 4) do
				local randomPetAbility = GetRandomPetAbility(selectedPetAnswer, selectedAbilityAnswer)
				if (not IsInTable(questionContentTable, randomPetAbility.name)) then
					tinsert(questionContentTable, randomPetAbility)
				end
				count = count + 1
				if count > 1000 then
					break
				end
			end
			
			local currentWidget = 1
			local currentEntry
			
			while (#questionContentTable > 0) do
				currentEntry = math.random(1, #questionContentTable)
				PopulateAnswerSlot(currentWidget, questionContentTable[currentEntry])
				tremove(questionContentTable, currentEntry)
				currentWidget = currentWidget + 1
			end	
		end
	elseif (questionType == 4) then
	
		local selectedPetAnswer = math.random(0, maxPets)
		local selectedAbilityAnswer = math.random(1, 3)
		
		if selectedAbilityAnswer == 1 then
			selectedAbilityAnswer = 'Active'
		elseif selectedAbilityAnswer == 2 then
			selectedAbilityAnswer = 'triggered'
		elseif selectedAbilityAnswer == 3 then
			selectedAbilityAnswer = 'passiveA'
		end		
		
		local selectedPetAnswerTrigger = GetTrigger('HeroSelectFamiliarList' .. selectedPetAnswer)
		
		if (not selectedPetAnswerTrigger) or Empty(selectedPetAnswerTrigger.entityName) then
			GetQuestion()
		else				
			
			local questionTable =  {
				texture = selectedPetAnswerTrigger[selectedAbilityAnswer .. 'Icon'],
				name 	= selectedPetAnswerTrigger[selectedAbilityAnswer .. 'Name'],
				desc 	=  Translate('game_of_strife_question_' .. questionType),
			}			
			
			PopulateQuestionSlot(0, questionTable)
			
			local correctAnswerTable =  {
				texture = GetEntityIconPath(selectedPetAnswerTrigger.entityName),
				name 	= GetEntityDisplayName(selectedPetAnswerTrigger.entityName),
				desc 	= selectedPetAnswerTrigger.description,
				isCorrect = true,
			}		
			
			local questionContentTable = {}
			
			tinsert(questionContentTable, correctAnswerTable)
			local count = 0
			while (#questionContentTable < 4) do
				local randomPet = GetRandomPet(selectedHeroAnswer, selectedAbilityAnswer)
				if (not IsInTable(questionContentTable, randomPet.name)) then
					tinsert(questionContentTable, randomPet)
				end
				count = count + 1
				if count > 1000 then
					break
				end
			end


			local currentWidget = 1
			local currentEntry
			
			while (#questionContentTable > 0) do
				currentEntry = math.random(1, #questionContentTable)
				PopulateAnswerSlot(currentWidget, questionContentTable[currentEntry])
				tremove(questionContentTable, currentEntry)
				currentWidget = currentWidget + 1
			end		
		end
	elseif (questionType == 5) then
	
		local selectedItemAnswer = math.random(0, 60)

		local selectedItemAnswerTrigger = GetTrigger('ShopItem' .. selectedItemAnswer)	
	
		if (not selectedItemAnswerTrigger) or Empty(selectedItemAnswerTrigger.entity) then
			GetQuestion()
		else
			
			local questionTable =  {
				texture = '/ui/_textures/icons/mystery.tga',
				name 	= selectedItemAnswerTrigger.descriptionSimple,
				desc 	=  Translate('game_of_strife_question_' .. questionType),
			}			
			
			PopulateQuestionSlot(0, questionTable)
			
			local correctAnswerTable =  {
				texture = GetEntityIconPath(selectedItemAnswerTrigger.entity),
				name 	= GetEntityDisplayName(selectedItemAnswerTrigger.entity),
				desc 	= '',
				isCorrect = true,
			}		
			
			local questionContentTable = {}
			
			tinsert(questionContentTable, correctAnswerTable)
			local count = 0
			while (#questionContentTable < 4) do
				local randomItem = GetRandomItem(selectedItemAnswer)
				if (not IsInTable(questionContentTable, randomItem.name)) then
					tinsert(questionContentTable, randomItem)
				end
				count = count + 1
				if count > 1000 then
					break
				end
			end

			local currentWidget = 1
			local currentEntry
			
			while (#questionContentTable > 0) do
				currentEntry = math.random(1, #questionContentTable)
				PopulateAnswerSlot(currentWidget, questionContentTable[currentEntry])
				tremove(questionContentTable, currentEntry)
				currentWidget = currentWidget + 1
			end			
		end	
	
	end

	groupfcall('game_of_strife_abilities', function (_, widget) widget:SetNoClick(0) end)
	groupfcall('game_of_strife_abilities_borders', function (_, widget) widget:SetBorderColor('black') end)	
	
end

function MiniGames.StartGameOfStrife()
	local partyStatusTrigger = LuaTrigger.GetTrigger('PartyStatus')
	if (not partyStatusTrigger.inParty) then
		ChatClient.CreateParty()  println('^y CreateParty 2')
		InitSelectionTriggers(object, false)
	end
	Shop.SetVisible(true)
	Shop.SetFilter('')
	Shop.SetVisible(false)
	GetQuestion()
	if interface:GetWidget('main_game_of_strife') then
		interface:GetWidget('main_game_of_strife'):FadeIn(250)
	end
	if interface:GetWidget('main_login_queue') then
		interface:GetWidget('main_login_queue'):FadeIn(250)
	end
end
