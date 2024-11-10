-- Pets (corral)
local petsInitialized = false
local petsQueuedPassiveChoice	= false
local petsQueuedSelectPet		= -1
Pets = {}
Pets.maxPets = 20

RMM_PET_PLACEHOLDER_COST_FRUIT = 100
RMM_PET_PLACEHOLDER_COST_GEMS  = 100

libGeneral.createGroupTrigger(
	'petsSelectGetPetStatus',
	{
		'GameClientRequestsGetPet.status',
		'GameClientRequestsGetPets.status',
		'GameClientRequestsPurchasePet.status',
	}
)

libGeneral.createGroupTrigger(
	'petsRequestsStatusFeed',
	{
		'GameClientRequestsFeedPet.status',
		'GameClientRequestsChoosePetPassive.status',
		'GameClientRequestsGetPet.status',
		'GameClientRequestsGetPets.status',
		'GameClientRequestsPurchasePet.status',
		'Corral.fruit',
		'mainPetsMode.selectedPetID',
	}
)

libGeneral.createGroupTrigger(
	'petsRequestsStatusSelectPassive',
	{
		'GameClientRequestsFeedPet.status',
		'GameClientRequestsChoosePetPassive.status',
		'GameClientRequestsGetPet.status',
		'GameClientRequestsGetPets.status',
		'GameClientRequestsPurchasePet.status',
	}
)

local petMode 		= LuaTrigger.GetTrigger('mainPetsMode')

local function petsGetPassiveChoice(trigger)
	if trigger.passiveASelected then
		return 'A'
	elseif trigger.passiveBSelected then
		return 'B'
	end
	return 'A'
end

function Pets.GetCurrentlySelectedSkinIcon(entityName)
	local index 			= Pets.GetPetIndexByEntity(entityName)
	if (index) then
		local petInfo 			= LuaTrigger.GetTrigger('CorralPet' .. index)
		
		if (index) and (petInfo) then
			if (mainUI.savedRemotely) and (mainUI.savedRemotely.petBuilds) and (mainUI.savedRemotely.petBuilds[petInfo.entityName]) and (mainUI.savedRemotely.petBuilds[petInfo.entityName].default_petSkin) and (mainUI.savedRemotely.petBuilds[petInfo.entityName].default_petSkinIndex) then
				local defaultSkinIndex = mainUI.savedRemotely.petBuilds[petInfo.entityName].default_petSkinIndex	
				local icon 				= petInfo['skinIcon'..defaultSkinIndex]
				return icon or '$checker', false
			else
				local defaultSkinIndex = 1
				local icon 				= petInfo['skinIcon'..defaultSkinIndex]	
				return icon or '$checker', false
			end
		else
			return '$checker', true
		end
	else
		return '$checker', true
	end		
end

function petsGetEvolutionLevel(level)
	level = level or -1

	if type(level) == 'number' then
		if level >= 6 then
			return 2
		elseif level >= 3 and level < 6 then
			return 1
		end
	end

	return 0
end

local prefixToIndex = {
	Active		= 1,
	triggered	= 2,
	passiveA	= 3,
	passiveB	= 4,
	passiveC	= 5
}

local function petsRegisterXPSegment(object, index, abilPrefix)

	abilPrefix = abilPrefix or ''
	local container		= object:GetWidget('mainPetsXPSegment'..index)
	local icon			= object:GetWidget('mainPetsXPSegment'..index..'Icon')	
	local xpBar			= object:GetWidget('mainPetsXPSegment'..index..'Bar')
	local xpBarQueued	= object:GetWidget('mainPetsXPSegment'..index..'BarQueued')	
	local arrow			= object:GetWidget('mainPetsXPSegment'..index..'Arrow')
	local label			= object:GetWidget('mainPetsXPSegment'..index..'Label')
	local button		= object:GetWidget('mainPetsXPSegment'..index..'Button')
	local glow			= object:GetWidget('mainPetsXPSegment'..index..'Glow')
	local BackerGlow	= object:GetWidget('mainPetsXPSegment'..index..'backerGlow')
	local frame			= object:GetWidget('mainPetsXPSegment'..index..'Frame')
	
	local abilPrefixLower	= string.lower(abilPrefix)
	
	local petAbilityIndex = 1
	if abilPrefixLower == 'passive' then
		petAbilityIndex = 3
	elseif abilPrefixLower == 'active' then
		petAbilityIndex = 1
	elseif abilPrefixLower == 'triggered' then
		petAbilityIndex = 2
	end

	local lastPetID
	
	local function xpBarUpdate(widget, trigger)
		local petLevel	= tonumber(trigger.petLevel) or 1
		
		if (mainUI.progressionData.accountValues.petLevelToAccountLevel[index]) then
			local currentAccountLevel 	= mainUI.progressionData.accountValues.petLevelToAccountLevel[index]
			local minimumAccountLevel	= mainUI.progressionData.accountValues.petLevelToAccountLevel[(index-1)] or 0
			local multiplier 			= 1 / ( currentAccountLevel - minimumAccountLevel )
			local completedBlocks 		= (trigger.level - minimumAccountLevel) * multiplier
			local progressionBlock 		= trigger.percentToNextPetLevel * multiplier
			
			label:SetText(currentAccountLevel)

			if (petLevel >= index) then
				icon:SetColor(1, 1, 1, 1)
				glow:SetVisible(true)
				frame:SetBorderColor(0, 0, 0, 1)
				widget:SetVisible(true)
				xpBarQueued:SetVisible(false)
			elseif (petLevel == (index - 1)) then
				icon:SetColor(1, 1, 1, 0.25)
				glow:SetVisible(false)
				frame:SetBorderColor('#161f29')
				widget:SetVisible(false)
				xpBarQueued:SetWidth(ToPercent(completedBlocks + progressionBlock))
				xpBarQueued:SetVisible(true)
			else
				icon:SetColor(1, 1, 1, 0.25)
				glow:SetVisible(false)
				frame:SetBorderColor('#161f29')
				widget:SetVisible(false)
				xpBarQueued:SetVisible(false)
			end
		end
	end
	
	xpBar:RegisterWatchLua('AccountProgression', xpBarUpdate, false, nil, 'petLevel')
	
	button:SetCallback('onmouseover', function(widget)
		local petMode 		= LuaTrigger.GetTrigger('mainPetsMode')
		local abilityLevel 	= 0
		
		if (mainUI.progressionData.accountValues.petsAbilityLevelByPetLevel) and (mainUI.progressionData.accountValues.petsAbilityLevelByPetLevel[petAbilityIndex]) and (mainUI.progressionData.accountValues.petsAbilityLevelByPetLevel[petAbilityIndex][index]) then
			abilityLevel = mainUI.progressionData.accountValues.petsAbilityLevelByPetLevel[petAbilityIndex][index]
		end
		
		local petInfo = LuaTrigger.GetTrigger('CorralPet'..petMode.selectedPetID)
		if abilPrefix == 'passive' then
		
			local selectedPassiveID = 'A'
		
			petMode.hoverAbilityID = prefixToIndex[abilPrefix..selectedPassiveID]
			if abilityLevel >= 1 then
				simpleTipGrowYUpdate(true, petInfo[abilPrefix..selectedPassiveID..'Icon'], petInfo[abilPrefix..selectedPassiveID..'Name'], petInfo[abilPrefix..selectedPassiveID..'Description'..(abilityLevel - 1)], libGeneral.HtoP(30))
			end
		
		else
			petMode.hoverAbilityID = prefixToIndex[abilPrefix]
			if abilityLevel >= 1 then
				simpleTipGrowYUpdate(true, petInfo[abilPrefix..'Icon'], petInfo[abilPrefix..'Name'], petInfo[abilPrefix..'Description'..(abilityLevel - 1)], libGeneral.HtoP(30))
			end
		end
		
		BackerGlow:FadeIn(150)
		arrow:SetColor(0.63, 0.93, 0.92, 1)
		petMode:Trigger(false)
	end)
	
	button:SetCallback('onmouseout', function(widget)
		local petMode = LuaTrigger.GetTrigger('mainPetsMode')
		
		petMode.hoverAbilityID = -1
		petMode:Trigger(false)		
		BackerGlow:FadeOut(150)
		arrow:SetColor(0.33, 0.4, 0.43, 1)
		simpleTipGrowYUpdate(false)
	end)
	
	frame:RegisterWatchLua('mainPetsMode', function(widget, trigger)
		local petMode 			= LuaTrigger.GetTrigger('mainPetsMode')
		local triggerAccount	= LuaTrigger.GetTrigger('AccountProgression')	
		local abilSuffix 		= petMode.selectedPassiveID
		local petLevel			= tonumber(triggerAccount.petLevel) or 1
		
		local isOver 			= false
		
		if abilPrefix == 'passive' then
			isOver = trigger.hoverAbilityID == prefixToIndex[abilPrefix..petMode.selectedPassiveID]
		else
			isOver = trigger.hoverAbilityID == prefixToIndex[abilPrefix]
		end
		
		if isOver then			
			icon:SetColor(1, 1, 1, 1)
			widget:SetBorderColor('0.01 0.85 0.91 1')
			BackerGlow:FadeIn(150)
			arrow:SetColor(0.63, 0.93, 0.92, 1)
		else
			if (petLevel >= index) then
				icon:SetColor(1, 1, 1, 1)
				widget:SetBorderColor(0, 0, 0, 1)
			else
				icon:SetColor(1, 1, 1, 0.25)
				widget:SetBorderColor('#161f29')
			end
		
			BackerGlow:FadeOut(150)
			arrow:SetColor(0.33, 0.4, 0.43, 1)
		end
	end, false, nil, 'hoverAbilityID')
	
	local function iconUpdate(widget, trigger)
		widget:SetTexture(trigger[abilPrefix..'Icon'])
	end
	
	local function iconUpdatePassive(widget, groupTrigger)
		local triggerPetMode	= groupTrigger['mainPetsMode']
		local triggerPet 		= LuaTrigger.GetTrigger('CorralPet'..triggerPetMode.selectedPetID)
		local abilSuffix 		= triggerPetMode.selectedPassiveID
		
		if abilSuffix == 'C' then	-- None chosen
			widget:SetTexture('/ui/_textures/icons/mystery.tga')
		else
			widget:SetTexture(triggerPet[abilPrefix..abilSuffix..'Icon'])
		end

	end
	
	local iconGroupTrigger
	
	container:RegisterWatchLua('mainPetsMode', function(widget, trigger)
		local selectedPetID = trigger.selectedPetID
		
		if lastPetID and lastPetID >= 0 then
			icon:UnregisterWatchLuaByKey('mainPetsXPSegment'..index..'Watch')
		end
			if iconGroupTrigger then
				LuaTrigger.DestroyGroupTrigger(iconGroupTrigger)
				iconGroupTrigger = nil
			end
		if selectedPetID >= 0 then
			local petInfo = LuaTrigger.GetTrigger('CorralPet'..selectedPetID)
			
			if abilPrefix == 'passive' then
				iconGroupTrigger = libGeneral.createGroupTrigger('mainPetsXPSegment'..index..'IconWatch', { 'CorralPet'..selectedPetID..'.passiveAIcon', 'CorralPet'..selectedPetID..'.passiveBIcon', 'mainPetsMode.selectedPassiveID', 'mainPetsMode.selectedPetID' })
				icon:RegisterWatchLua('mainPetsXPSegment'..index..'IconWatch', iconUpdatePassive, false, 'mainPetsXPSegment'..index..'Watch')
				iconUpdatePassive(icon, LuaTrigger.GetTrigger('mainPetsXPSegment'..index..'IconWatch'))
			else
				icon:RegisterWatchLua('CorralPet'..selectedPetID, iconUpdate, false, 'mainPetsXPSegment'..index..'Watch', 'passiveAIcon', 'passiveBIcon', 'passiveASelected', 'passiveBSelected')
				iconUpdate(icon, petInfo)
			end
			
			lastPetID = selectedPetID
		end
	end, false, nil, 'selectedPetID')
end

local function petsRegisterAbility(object, index, paramPrefix, paramSuffix)
	paramSuffix			= paramSuffix or ''

	local container		= object:GetWidget('mainPetsAbility'..index)
	local icon			= object:GetWidget('mainPetsAbility'..index..'Icon')
	local level			= object:GetWidget('mainPetsAbility'..index..'Level')
	local locked		= object:GetWidget('mainPetsAbility'..index..'Locked')
	local name			= object:GetWidget('mainPetsAbility'..index..'Name')
	local description	= object:GetWidget('mainPetsAbility'..index..'Description')
	local key			= object:GetWidget('mainPetsAbility'..index..'Key')
	local button		= object:GetWidget('mainPetsAbility'..index..'Button')
	local backerGlow	= object:GetWidget('mainPetsAbility'..index..'backerGlow')
	local base			= object:GetWidget('mainPetsAbility'..index..'Base')
	local border		= object:GetWidget('mainPetsAbility'..index..'Border')
	
	local lastPetID
	
	base:SetVisible(false)
	border:SetVisible(false)
	backerGlow:SetVisible(false)
	
	local paramPrefixLower
	if index ~= 1 then
		key:SetVisible(0)
		paramPrefixLower = string.lower(paramPrefix)
	else
		key:SetVisible(1)
		paramPrefixLower = paramPrefix
	end
	
	button:SetCallback('onmouseover', function(widget)
		local petMode = LuaTrigger.GetTrigger('mainPetsMode')
		
		petMode.hoverAbilityID = index
		
		petMode:Trigger(false)
		
		local petInfo = LuaTrigger.GetTrigger('CorralPet'..petMode.selectedPetID)		
		local petLevel	=  math.max(petInfo.level, 1)
		local abilityLevel	= math.max(mainUI.progressionData.accountValues.petsAbilityLevelByPetLevel[index][petLevel], 1) - 1
		
		simpleTipGrowYUpdate(true, petInfo[paramPrefixLower..paramSuffix..'Icon'], petInfo[paramPrefixLower..paramSuffix..'Name'], petInfo[paramPrefixLower..paramSuffix..'Description'..abilityLevel], libGeneral.HtoP(34))
		
		base:FadeIn(100)
		border:FadeIn(100)
		backerGlow:FadeIn(150)
	end)
	
	button:SetCallback('onmouseout', function(widget)
		local petMode = LuaTrigger.GetTrigger('mainPetsMode')
		
		petMode.hoverAbilityID = -1
		petMode:Trigger(false)
		simpleTipGrowYUpdate(false)
		
		base:FadeOut(170)
		border:FadeOut(100)
		backerGlow:FadeOut(100)
	end)
	
	local function iconUpdate(widget, trigger)
		widget:SetTexture(trigger[paramPrefixLower..paramSuffix..'Icon'])
	end
	
	local function nameUpdate(widget, trigger)
		widget:SetText(trigger[paramPrefixLower..paramSuffix..'Name'])
	end

	local function descriptionUpdate(widget, trigger)
		widget:SetText(trigger[paramPrefixLower..paramSuffix..'DescriptionSimple'])
	end
	
	-- level:RegisterWatchLua('AccountProgression', function(widget, trigger)	
		-- local petLevel	= trigger.petLevel
		
		-- if (mainUI.progressionData.accountValues.petsAbilityLevelByPetLevel[index][petLevel]) then
			-- if (mainUI.progressionData.accountValues.petsAbilityLevelByPetLevel[index][petLevel] > 0) then
				-- widget:SetVisible(true)
				-- locked:SetVisible(false)
				-- widget:SetText(mainUI.progressionData.accountValues.petsAbilityLevelByPetLevel[index][petLevel])
			-- else
				-- widget:SetVisible(false)
				-- locked:SetVisible(true)
			-- end
		-- end
	-- end, false, nil, 'petLevel')
	
	name:RegisterWatchLua('AccountProgression', function(widget, trigger)
		local petLevel 		= trigger.petLevel
		local unlock		= object:GetWidget('mainPetsNextUnlock')

		if (trigger.accountLevelForNextPetLevel > 0) then
			unlock:SetText(Translate('corral_next_pet_level_unlock_x', 'value', trigger.accountLevelForNextPetLevel))
		else
			unlock:SetText(Translate('corral_next_pet_level_maxed'))
		end
		
		if petLevel >= 1 and mainUI.progressionData.accountValues.petsAbilityLevelByPetLevel[index][trigger.petLevel] >= 1 then
			widget:SetColor(1,1,1)
			description:SetColor(.8,.8,.8)
			level:SetColor(1,1,1)
			-- icon:SetColor(1, 1, 1, 1)
			-- icon:SetRenderMode('normal')
		else
			widget:SetColor(1,1,1)
			description:SetColor(.8,.8,.8)
			level:SetColor(1,1,1)
			-- icon:SetColor(1, 1, 1, 0.15)
			-- icon:SetRenderMode('grayscale')
		end
	end, false, nil, 'petLevel')

	local infoGroupTrigger

	if index >= 3 then
		infoGroupTrigger = libGeneral.createGroupTrigger(
			'mainPetsAbility'..index..paramSuffix..'PassiveInfo', {
				'mainPetsMode.selectedPassiveID',
				'AccountProgression.petLevel'
			}
		)
	end
	
	container:RegisterWatchLua('mainPetsMode', function(widget, trigger)
		local selectedPetID = trigger.selectedPetID
		
		if lastPetID and lastPetID >= 0 then
			container:UnregisterAllWatchLuaByKey('mainPetsAbility'..index..'Watch')
		end
		
		if selectedPetID >= 0 then
			local petInfo 	= LuaTrigger.GetTrigger('CorralPet'..selectedPetID)
			lastPetID 		= selectedPetID
			
			icon:RegisterWatchLua('CorralPet'..selectedPetID, iconUpdate, false, 'mainPetsAbility'..index..'Watch', paramPrefixLower..paramSuffix..'Icon')
			name:RegisterWatchLua('CorralPet'..selectedPetID, nameUpdate, false, 'mainPetsAbility'..index..'Watch', paramPrefixLower..paramSuffix..'Name')
			description:RegisterWatchLua('CorralPet'..selectedPetID, descriptionUpdate, false, 'mainPetsAbility'..index..'Watch', paramPrefixLower..paramSuffix..'DescriptionSimple')
			
			nameUpdate(name, petInfo)
			descriptionUpdate(description, petInfo)
			iconUpdate(icon, petInfo)
			
		end
	end, false, nil, 'selectedPetID')
end

local currentPetModel	= object:GetWidget('mainPetsCurrentPetModel')

local function updatePetModel(petInfo)
	local selectedPetID			= 	LuaTrigger.GetTrigger('mainPetsMode').selectedPetID
	local petInfo 				= 	LuaTrigger.GetTrigger('CorralPet'..selectedPetID)	
	local currentPetModel		= 	GetWidget('mainPetsCurrentPetModel')
	
	if (petMode.petSkinHoveringIndex > 0) then
		currentPetModel:SetModel(petInfo['skinModel'..(petMode.petSkinHoveringIndex)] or petInfo['evolutionModel'..(petMode.petSkinHoveringIndex-1)] or '/npcs/Krytos/model.mdf')	
		currentPetModel:SetModelOrientation(petInfo['skinModelOrient'..(petMode.petSkinHoveringIndex)])	
		currentPetModel:SetModelPosition(petInfo['skinModelPos'..(petMode.petSkinHoveringIndex)])	
		currentPetModel:SetModelScale(petInfo['skinModelScale'..(petMode.petSkinHoveringIndex)])
	elseif (petMode.selectedPetSkinIndex > 0) then
		currentPetModel:SetModel(petInfo['skinModel'..(petMode.selectedPetSkinIndex)] or petInfo['evolutionModel'..(petMode.petSkinHoveringIndex-1)] or '/npcs/Krytos/model.mdf')	
		currentPetModel:SetModelOrientation(petInfo['skinModelOrient'..(petMode.selectedPetSkinIndex)])	
		currentPetModel:SetModelPosition(petInfo['skinModelPos'..(petMode.selectedPetSkinIndex)])	
		currentPetModel:SetModelScale(petInfo['skinModelScale'..(petMode.selectedPetSkinIndex)])
	else
		currentPetModel:SetModel(petInfo['skinModel1'] or petInfo['evolutionModel1'] or '/npcs/Krytos/model.mdf')
		currentPetModel:SetModelOrientation(petInfo['skinModelOrient1'])
		currentPetModel:SetModelPosition(petInfo['skinModelPos1'])	
		currentPetModel:SetModelScale(petInfo['skinModelScale1'])		
	end

end

local function petsGearsets(object, index, gearPrefix, triggerIndex, uiPrefix)
	uiPrefix				= uiPrefix or ''
	gearPrefix				= gearPrefix or ''
	triggerIndex			= triggerIndex or 1
	
	local container			= object:GetWidget(uiPrefix .. 'gearsetPetEntry'..index)
	local glow				= object:GetWidget(uiPrefix .. 'gearsetPetEntry'..index..'Glow')
	local icon				= object:GetWidget(uiPrefix .. 'gearsetPetEntry'..index..'Icon')
	local selectedBorder	= object:GetWidget(uiPrefix .. 'gearsetPetEntry'..index..'SelectedBorder')
	local HoverBorder		= object:GetWidget(uiPrefix .. 'gearsetPetEntry'..index..'HoverBorder')
	local selectedGlow		= object:GetWidget(uiPrefix .. 'gearsetPetEntry'..index..'SelectedGlow')
	local hoverGlow			= object:GetWidget(uiPrefix .. 'gearsetPetEntry'..index..'HoverGlow')
	local lock				= object:GetWidget(uiPrefix .. 'gearsetPetEntry'..index..'Lock')
	local button			= object:GetWidget(uiPrefix .. 'gearsetPetEntry'..index..'Button')

	local lastPetID

	local function Update(petInfo)			
		local selectedPetID			= 	LuaTrigger.GetTrigger('mainPetsMode').selectedPetID
		local petInfo 				= 	LuaTrigger.GetTrigger('CorralPet'..selectedPetID)		
		updatePetModel(petInfo)

		icon:SetTexture(petInfo['skinIcon'..(triggerIndex)] or  petInfo['evolutionIcon'..(index-1)] or '$checker')
		lock:SetVisible(not ((triggerIndex == 1) or petInfo['skinOwned' .. triggerIndex]))
		
		selectedGlow:SetVisible(petMode.selectedPetSkin == gearPrefix)
		selectedBorder:SetVisible(petMode.selectedPetSkin == gearPrefix)

		if (not ((triggerIndex == 1) or petInfo['skinOwned' .. triggerIndex])) then
			icon:SetColor('1 1 1 0.45')
		else
			icon:SetColor('1 1 1 1')
		end
	end

	button:SetCallback('onmouseover', function(widget)
		local selectedPetID			= 	LuaTrigger.GetTrigger('mainPetsMode').selectedPetID
		local petInfo 				= 	LuaTrigger.GetTrigger('CorralPet'..selectedPetID)	
		
		petMode.petSkinHoveringIndex = triggerIndex
		petMode.petSkinHovering = gearPrefix
		petMode:Trigger(false)
		
		HoverBorder:FadeIn(100)
		hoverGlow:FadeIn(150)
	end)
	
	button:SetCallback('onmouseout', function(widget)
		local selectedPetID			= 	LuaTrigger.GetTrigger('mainPetsMode').selectedPetID
		local petInfo 				= 	LuaTrigger.GetTrigger('CorralPet'..selectedPetID)	
		petMode.petSkinHoveringIndex = -1
		petMode.petSkinHovering = ''
		petMode:Trigger(false)		
		
		HoverBorder:FadeOut(100)
		hoverGlow:FadeOut(150)
	end)
	
	button:SetCallback('onclick', function(widget)
		local triggerHeroSelectLocalPlayerInfo	= 	LuaTrigger.GetTrigger('HeroSelectLocalPlayerInfo')
		
		local selectedPetID			= 	LuaTrigger.GetTrigger('mainPetsMode').selectedPetID
		local petInfo 				= 	LuaTrigger.GetTrigger('CorralPet'..selectedPetID)		
		
		petMode.selectedPetSkinCost = (petInfo['skinCost' .. triggerIndex])
		
		if (triggerIndex == 1) or (petInfo['skinOwned' .. triggerIndex]) then
			petMode.selectedPetSkin 		= gearPrefix
			petMode.selectedPetSkinOwned 	= gearPrefix
			petMode.selectedPetSkinIndex 	= triggerIndex
			petMode:Trigger(false)			
			
			mainUI.savedRemotely 													= mainUI.savedRemotely 									or {}
			mainUI.savedRemotely.petBuilds 											= mainUI.savedRemotely.petBuilds 						or {}
			mainUI.savedRemotely.petBuilds[petInfo.entityName]						= mainUI.savedRemotely.petBuilds[petInfo.entityName] 	or {}
			mainUI.savedRemotely.petBuilds[petInfo.entityName].default_petSkin 		= gearPrefix
			mainUI.savedRemotely.petBuilds[petInfo.entityName].default_petSkinIndex	= triggerIndex
			SaveState()
			
			if (triggerHeroSelectLocalPlayerInfo.petEntityName == petInfo.entityName) then
				SpawnFamiliar(triggerHeroSelectLocalPlayerInfo.petEntityName, gearPrefix)
			end
			
		else
			petMode.selectedPetSkin 		= gearPrefix
			petMode.selectedPetSkinIndex 	= triggerIndex
			petMode:Trigger(false)		
		end
		
		PlaySound('ui/sounds/sfx_button_generic.wav')
		if (GetCvarBool('ui_newUISounds')) then PlaySound('/ui/sounds/launcher/sfx_pet_skin_select.wav') end
	end)
	
	container:RegisterWatchLua('mainPetsMode', function(widget, trigger)
		local selectedPetID = trigger.selectedPetID
		local petInfo = LuaTrigger.GetTrigger('CorralPet'..selectedPetID)
		if lastPetID and lastPetID >= 0 then
			currentPetModel:UnregisterWatchLuaByKey('gearsetPetEntry'..index..'Watch')
		end
		if selectedPetID >= 0 then			
			currentPetModel:UnregisterWatchLuaByKey('gearsetPetEntry'..index..'Watch')
			currentPetModel:UnregisterWatchLua('CorralPet'..selectedPetID)
			currentPetModel:RegisterWatchLua('CorralPet'..selectedPetID, Update, false, 'gearsetPetEntry'..index..'Watch')
			Update(petInfo)
		end
		lastPetID = selectedPetID
	end, false, nil, 'selectedPetID', 'selectedPetSkin', 'selectedPetSkinIndex', 'selectedPetSkinOwned', 'petSkinHoveringIndex', 'petSkinHovering')
	
end

local function selectPetID(petID, forceTrigger)
	--println('selectPetID ' .. tostring(petID))
	
	local container				= GetWidget('mainPets')
	local CorralSelectedPet		= LuaTrigger.GetTrigger('CorralSelectedPet')
	
	petsQueuedSelectPet = -1
	forceTrigger = forceTrigger or false
	local petModeTrigger = LuaTrigger.GetTrigger('mainPetsMode')
	petModeTrigger.selectedPetID = petID
	
	local defaultPassive = 'A' -- petsGetPassiveChoice(LuaTrigger.GetTrigger('CorralPet'..petID))
	petModeTrigger.selectedPassiveID	= defaultPassive
	if defaultPassive == 'A' then
		petModeTrigger.selectedPassiveIndex	= 1
	elseif defaultPassive == 'B' then
		petModeTrigger.selectedPassiveIndex	= 2
	else
		petModeTrigger.selectedPassiveIndex	= 0
	end

	Corral.SelectPetSlot(petID)
	
	local petInfo 				= 	LuaTrigger.GetTrigger('CorralPet'..petID)	
	
	if (mainUI.savedRemotely) and (mainUI.savedRemotely.petBuilds) and (mainUI.savedRemotely.petBuilds[petInfo.entityName]) and (mainUI.savedRemotely.petBuilds[petInfo.entityName].default_petSkin) and (mainUI.savedRemotely.petBuilds[petInfo.entityName].default_petSkinIndex) then
		if (petInfo['skinOwned'..mainUI.savedRemotely.petBuilds[petInfo.entityName].default_petSkinIndex]) then
			petModeTrigger.selectedPetSkin 			= mainUI.savedRemotely.petBuilds[petInfo.entityName].default_petSkin
			petModeTrigger.selectedPetSkinOwned 	= mainUI.savedRemotely.petBuilds[petInfo.entityName].default_petSkin
			petModeTrigger.selectedPetSkinIndex 	= mainUI.savedRemotely.petBuilds[petInfo.entityName].default_petSkinIndex
		else
			petModeTrigger.selectedPetSkin 			= 'default'
			petModeTrigger.selectedPetSkinOwned 	= 'default'
			petModeTrigger.selectedPetSkinIndex 	= 1		
		end
	else
		petModeTrigger.selectedPetSkin 			= 'default'
		petModeTrigger.selectedPetSkinOwned 	= 'default'
		petModeTrigger.selectedPetSkinIndex 	= 1
	end	
	
	petModeTrigger:Trigger(forceTrigger)
	
	container:UnregisterAllWatchLuaByKey('key_CorralSelectedPet')
	container:RegisterWatchLua('CorralPet'..petID, function(widget, trigger)
		CorralSelectedPet.petFruitCost 		= trigger.foodCost
		CorralSelectedPet.petGemCost 		= trigger.gemCost
		CorralSelectedPet.canPurchasePet 	= trigger.canPurchasePet
		CorralSelectedPet:Trigger(true)
	end, true, 'key_CorralSelectedPet')
	CorralSelectedPet.petFruitCost 		= LuaTrigger.GetTrigger('CorralPet'..petID).foodCost
	CorralSelectedPet.petGemCost 		= LuaTrigger.GetTrigger('CorralPet'..petID).gemCost
	CorralSelectedPet.canPurchasePet	= LuaTrigger.GetTrigger('CorralPet'..petID).canPurchasePet
	
	container:RegisterWatchLua('Corral', function(widget, trigger)
		CorralSelectedPet.initialPetPicked 	= trigger.initialPetPicked
		CorralSelectedPet.fruit 			= trigger.fruit
		CorralSelectedPet:Trigger(true)
	end, true, 'key_CorralSelectedPet', 'initialPetPicked', 'fruit')	
	CorralSelectedPet.initialPetPicked 	= LuaTrigger.GetTrigger('Corral').initialPetPicked
	CorralSelectedPet.fruit 			= LuaTrigger.GetTrigger('Corral').fruit
	CorralSelectedPet:Trigger(false)

end

function Pets.SelectPetByEntity(petEntity)
	local petID = 0
	local petInfoTrigger
	for i=0,Pets.maxPets,1 do
		petInfoTrigger = LuaTrigger.GetTrigger('CorralPet'..i)
		if (petInfoTrigger) and (petEntity) and (petEntity == petInfoTrigger.entityName) then
			selectPetID(i)
			break
		end
	end	
end

function Pets.GetPetIndexByEntity(petEntity)
	local petID = 0
	local petInfoTrigger
	for i=0,Pets.maxPets,1 do
		petInfoTrigger = LuaTrigger.GetTrigger('CorralPet'..i)
		if (petInfoTrigger) and (petEntity) and (petEntity == petInfoTrigger.entityName) then
			return i
		end
	end	
end

local function petsGetShowID(selectedID, hoverID)
	if hoverID >= 0 then
		return hoverID
	end
	return selectedID
end

local function petsRegisterPet(object, index, petsFlushRequestQueue)
	local container			= GetWidget('mainPetsListEntry'..index, nil, true)
	if (not container) then
		return
	end	
	
	local parent			= object:GetWidget('mainPetsListEntry'..index..'Container')
	
	if (not LuaTrigger.GetTrigger('CorralPet'..index)) then
		-- println('^o Warning - Trigger Doesnt Exist: CorralPet' .. index)
		container:SetVisible(0)
		return
	end	

	local icon				= object:GetWidget('mainPetsListEntry'..index..'Icon')
	local name				= object:GetWidget('mainPetsListEntry'..index..'Name')
	local level				= object:GetWidget('mainPetsListEntry'..index..'Level')
	local lock				= object:GetWidget('mainPetsListEntry'..index..'Lock')
	local boost				= object:GetWidget('mainPetsListEntry'..index..'Boost')
	local button			= object:GetWidget('mainPetsListEntry'..index..'Button')
	local selected			= object:GetWidget('mainPetsListEntry'..index..'Selected')
	local hoverGlow			= object:GetWidget('mainPetsListEntry'..index..'hoverGlow')
	local selectFrame		= object:GetWidget('mainPetsListEntry'..index..'SelectFrame')
	local backer			= object:GetWidget('mainPetsListEntry'..index..'Backer')
	
	local function UpdateContainer(widget, trigger)
		local entity = trigger.entityName
		widget:SetVisible(entity and string.len(entity) > 0)
	end
	
	container:RegisterWatchLua('CorralPet'..index, function(widget, trigger)
		UpdateContainer(widget, trigger)
	end, false, nil, 'entityName')
	UpdateContainer(container, LuaTrigger.GetTrigger('CorralPet'..index))	
	
	selected:RegisterWatchLua('mainPetsMode', function(widget, trigger)
		widget:SetVisible(trigger.selectedPetID == index)
	end, false, nil, 'selectedPetID')
	
	if LuaTrigger.GetTrigger('corralPet'..index..'InitialPickLevel') then LuaTrigger.DestroyGroupTrigger('corralPet'..index..'InitialPickLevel') end
	LuaTrigger.CreateGroupTrigger('corralPet'..index..'InitialPickLevel', {
		'CorralPet'..index..'.slotNumber',
		'CorralPet'..index..'.level',
		'Corral.initialPetPicked'
	})

	button:SetCallback('onclick', function(widget)
		-- sound_petsSelectPet
		PlaySound('/ui/sounds/pets/sfx_select.wav')
		if (GetCvarBool('ui_newUISounds')) then PlaySound('/ui/sounds/launcher/sfx_pet_select.wav') end
		petsFlushRequestQueue(index)
	end)
	
	button:SetCallback('onmouseover', function(widget)
		selectFrame:FadeIn(100)
		hoverGlow:FadeIn(150)
	end)
	
	button:SetCallback('onmouseout', function(widget)
		selectFrame:FadeOut(100)
		hoverGlow:FadeOut(150)
	end)
	
	boost:RegisterWatchLua('CorralPet'..index, function(widget, trigger)
		widget:SetVisible(trigger.boosted)
	end, false, nil, 'boosted')	
	
	name:RegisterWatchLua('CorralPet'..index, function(widget, trigger)
		local entityName	= trigger.entityName

		if entityName and string.len(entityName) > 0 and ValidateEntity(entityName) then
			if (trigger['customName']) and (not Empty(trigger['customName'])) then
				widget:SetText(trigger['customName'])
			else
				widget:SetText(GetEntityDisplayName(entityName))
			end
		else
			widget:SetText('')
		end

	end, false, nil, 'entityName', 'level')
	
	name:RegisterWatchLua('corralPet'..index..'InitialPickLevel', function(widget, groupTrigger)
		local corralPetTrigger	= groupTrigger['CorralPet'..index]
		local initialPicked		= groupTrigger['Corral'].initialPetPicked

		if (not initialPicked) or ((corralPetTrigger.level > 0) and (corralPetTrigger.slotNumber) and (corralPetTrigger.slotNumber >= 0)) or (corralPetTrigger.canPurchasePet and corralPetTrigger.boosted) then
			widget:SetColor(1,1,1,.8)
		else
			widget:SetColor(0.5, 0.5, 0.5)
		end
	end)

	if LuaTrigger.GetTrigger('petsIconQueuedInfo'..index) then LuaTrigger.DestroyGroupTrigger('petsIconQueuedInfo'..index) end
	LuaTrigger.CreateGroupTrigger('petsIconQueuedInfo'..index, {
		'CorralPet'..index..'.slotNumber',
		'CorralPet'..index..'.level',
		'CorralPet'..index..'.entityName',
		'mainPetsMode.selectedPetID',
	})
	
	icon:RegisterWatchLua('petsIconQueuedInfo'..index, function(widget, groupTrigger)
		local petInfo		= groupTrigger['CorralPet'..index]
		local entityName	= petInfo.entityName
		local selectedPetID	= groupTrigger['mainPetsMode'].selectedPetID
		local useLevel		= 1
		
		if string.len(entityName) > 0 then
			useLevel	= petInfo.level
			widget:SetTexture(Pets.GetCurrentlySelectedSkinIcon(entityName))
		end
	
	end)

	icon:RegisterWatchLua('corralPet'..index..'InitialPickLevel', function(widget, groupTrigger)
		local corralPetTrigger		= groupTrigger['CorralPet'..index]
		local initialPicked			= groupTrigger['Corral'].initialPetPicked

		if (not initialPicked) or ((corralPetTrigger.level > 0) and (corralPetTrigger.slotNumber) and (corralPetTrigger.slotNumber >= 0)) or (corralPetTrigger.canPurchasePet and corralPetTrigger.boosted) then
			widget:SetRenderMode('normal')
		else
			widget:SetRenderMode('grayscale')
		end
	end)
	
	lock:RegisterWatchLua('corralPet'..index..'InitialPickLevel', function(widget, groupTrigger)
		local corralPetTrigger	= groupTrigger['CorralPet'..index]
		local initialPicked		= groupTrigger['Corral'].initialPetPicked

		if (not initialPicked) or ((corralPetTrigger.level > 0) and (corralPetTrigger.slotNumber) and (corralPetTrigger.slotNumber >= 0)) or (corralPetTrigger.canPurchasePet and corralPetTrigger.boosted) then
			widget:SetVisible(false)
			backer:SetColor(1,1,1)
		else
			widget:SetVisible(true)
			backer:SetColor(0.6, 0.6, 0.6)
		end
	end)

	local slotTrigger	= LuaTrigger.GetTrigger('CorralPet'..index)
	slotTrigger:Trigger()
end

local function petsRegister(object)
	local container								= object:GetWidget('mainPets')
	local mainPetsList_scrollbox				= object:GetWidget('mainPetsList_scrollbox')
	local petModeTrigger		= LuaTrigger.GetTrigger('mainPetsMode')
	local lastSelectedID		= -1
	local lastSelectedIDInit	= -1

	local lastPetLevel			= -1
	local lastSelectedPetID		= -1
	
	container:RegisterWatchLua('AccountProgression', function(widget, trigger)
		local selectedPetID		= LuaTrigger.GetTrigger('mainPetsMode').selectedPetID
		if petsInitialized then
			if lastSelectedPetID == selectedPetID then
				if trigger.petLevel > lastPetLevel then
					if trigger.petLevel == 3 or trigger.petLevel == 6 or trigger.petLevel == 9 then
						PlaySound('/ui/sounds/pets/sfx_evolve.wav')
					else

					end
				end
			end		
			lastSelectedPetID	= selectedPetID
			lastPetLevel		= trigger.petLevel
		end
	end, false, nil, 'petLevel')

	-- Unlock Pet popup
	local unlockPetContainer		= object:GetWidget('mainPetsUnlockPet')
	local unlockPetClose			= object:GetWidget('mainPetsUnlockPetClose')
	local unlockPetCost				= object:GetWidget('mainPetsUnlockPetCost')
	local unlockPetCostGems			= object:GetWidget('mainPetsUnlockPetCostGems')
	local unlockPetOKButton			= object:GetWidget('mainPetsUnlockPetOKButton')
	local unlockPetOKButtonL		= object:GetWidget('mainPetsUnlockPetOKButtonLabel')
	local unlockPetOKGemsButton		= object:GetWidget('mainPetsUnlockPetOKGemsButton')
	local unlockPetOKGemsButtonL	= object:GetWidget('mainPetsUnlockPetOKGemsButtonLabel')
	
	unlockPetClose:SetCallback('onclick', function(widget) unlockPetContainer:FadeOut(250) end)
	unlockPetCost:RegisterWatchLua('CorralSelectedPet', function(widget, trigger) widget:SetText(trigger.petFruitCost) end, false, nil, 'petFruitCost')
	unlockPetCostGems:RegisterWatchLua('CorralSelectedPet', function(widget, trigger) widget:SetText(trigger.petGemCost) end, false, nil, 'petGemCost')
	
	libGeneral.createGroupTrigger('petCostGemsCompare', { 'GemOffer', 'CorralSelectedPet' })

	unlockPetOKGemsButtonL:RegisterWatchLua('petCostGemsCompare', function(widget, groupTrigger)
		local triggerGems	= groupTrigger[1]
		local triggerCorral	= groupTrigger[2]
		
		if (triggerCorral.petGemCost > 0) then
			widget:SetText(Translate('corral_unlockpet_usegems'))
		else
			widget:SetText(Translate('corral_unlockpet_free'))
		end
	end)	
	
	unlockPetOKButtonL:RegisterWatchLua('petCostGemsCompare', function(widget, groupTrigger)
		local triggerGems	= groupTrigger[1]
		local triggerCorral	= groupTrigger[2]
		
		if (triggerCorral.petFruitCost > 0) then
			widget:SetText(Translate('corral_petcurrency_use'))
		else
			widget:SetText(Translate('corral_unlockpet_free'))
		end
	end)		
	
	local function queueReselectSamePetAfterUnlock(petEntity, useGems)
		if petEntity and string.len(petEntity) > 0 then
			useGems = useGems or false
			unlockPetContainer:FadeOut(250)
			unlockPetOKButton:RegisterWatchLua('petsSelectGetPetStatus', function(widget, groupTrigger)
				local getPetsStatus		= groupTrigger['GameClientRequestsGetPet'].status
				local unlockPetStatus	= groupTrigger['GameClientRequestsGetPets'].status
				local buyPetStatus		= groupTrigger['GameClientRequestsPurchasePet'].status
				
				if (getPetsStatus == 0 or getPetsStatus == 2) and (unlockPetStatus == 0 or unlockPetStatus == 2) and (buyPetStatus == 0 or buyPetStatus == 2) then
				
					local tempPetInfo
					for i=0,9,1 do
						tempPetInfo = LuaTrigger.GetTrigger('CorralPet'..i)
						if tempPetInfo.entityName == petEntity then
							selectPetID(i)
							break
						end
					end
					widget:UnregisterWatchLua('petsSelectGetPetStatus')
					mainUI.RefreshProducts()
				end
			end)
			
			Corral.PurchasePet(petEntity, useGems)
			if (mainUI) and  (mainUI.savedLocally) and  (mainUI.savedLocally.adaptiveTraining) and (mainUI.savedLocally.adaptiveTraining.featureList) and (mainUI.savedLocally.adaptiveTraining.featureList) then
				mainUI.AdaptiveTraining.RecordUtilisationInstanceByFeatureName('pets')
			end
		end
	end
	
	unlockPetOKButton:RegisterWatchLua('CorralSelectedPet', function(widget, trigger)
		widget:SetEnabled(trigger.fruit >= trigger.petFruitCost)
	end)
	
	unlockPetOKGemsButton:RegisterWatchLua('petCostGemsCompare', function(widget, groupTrigger)
		local triggerGems	= groupTrigger[1]
		local triggerCorral	= groupTrigger[2]

		widget:SetEnabled(triggerGems.gems >= triggerCorral.petGemCost)
	end)

	unlockPetOKButton:SetCallback('onclick', function(widget)
		PlaySound('/ui/sounds/pets/sfx_unlock.wav')
		if (GetCvarBool('ui_newUISounds')) then PlaySound('/ui/sounds/launcher/sfx_pet_skin_purchase.wav') end
		local petEntity = LuaTrigger.GetTrigger('CorralPet'..LuaTrigger.GetTrigger('mainPetsMode').selectedPetID).entityName
		queueReselectSamePetAfterUnlock(petEntity)
	end)

	unlockPetOKGemsButton:SetCallback('onclick', function(widget)
		PlaySound('/ui/sounds/pets/sfx_unlock.wav')
		if (GetCvarBool('ui_newUISounds')) then PlaySound('/ui/sounds/launcher/sfx_pet_skin_purchase.wav') end
		local petEntity = LuaTrigger.GetTrigger('CorralPet'..LuaTrigger.GetTrigger('mainPetsMode').selectedPetID).entityName
		queueReselectSamePetAfterUnlock(petEntity, true)
	end)
	
	-- =============== (/unlock pet popup) ===============

	local function onQueueComplete(onQueueComplete)
		if onFinish and type(onFinish) == 'function' then
			onFinish()
		end
	end

	function petsFlushRequestQueue(newPetIndex, onFinish)
		container:UnregisterWatchLua('GameClientRequestsFeedPet')
		container:UnregisterWatchLua('GameClientRequestsChoosePetPassive')
		
		if newPetIndex then
			petsQueuedSelectPet = newPetIndex
		end
	
		if petsQueuedSelectPet >= 0 then
			selectPetID(petsQueuedSelectPet)
			onQueueComplete(onFinish)
		else
			onQueueComplete(onFinish)
		end		
	end
	
	petsRegisterXPSegment(object, 1, 'Active')
	petsRegisterXPSegment(object, 2, 'Active')
	petsRegisterXPSegment(object, 3, 'triggered')
	petsRegisterXPSegment(object, 4, 'Active')
	petsRegisterXPSegment(object, 5, 'triggered')
	petsRegisterXPSegment(object, 6, 'passive')
	petsRegisterXPSegment(object, 7, 'passive')
	petsRegisterXPSegment(object, 8, 'triggered')
	petsRegisterXPSegment(object, 9, 'passive')
	
	petsRegisterAbility(object, 1, 'Active', nil)
	petsRegisterAbility(object, 2, 'Triggered', nil)
	petsRegisterAbility(object, 3, 'Passive', 'A')
	
	petsGearsets(object, 2, 'default', 1) -- arg
	petsGearsets(object, 1, 'baby', 2)
	petsGearsets(object, 3, 'adult', 3)

	local firstPetChoicePanel		= object:GetWidget('mainPetsSelectFirstPet')
	firstPetChoicePanel:RegisterWatchLua('Corral', function(widget, trigger) 
		widget:SetVisible((not trigger.initialPetPicked))
	end, false, nil, 'initialPetPicked')
	
	local mainPetsList_ScrollBar		= object:GetWidget('mainPetsList_ScrollBar')
	mainPetsList_ScrollBar:RegisterWatchLua('Corral', function(widget, trigger) 
		widget:SetVisible(trigger.initialPetPicked)
	end, false, nil, 'initialPetPicked')	
		
	for i=0,Pets.maxPets,1 do
		petsRegisterPet(object, i, petsFlushRequestQueue)
	end
	
	local function initializePetModeTrigger()
		petModeTrigger.hoverAbilityID = -1
		selectPetID(0, true)
	end
	
	initializePetModeTrigger()
	
	local function initialize()
		-- Corral.SelectPetSlot(0)
		initializePetModeTrigger()
		
		local firstPetChoicePanel		= object:GetWidget('mainPetsSelectFirstPet')
		local trigger_corral			= LuaTrigger.GetTrigger('Corral')
		firstPetChoicePanel:SetVisible((not trigger_corral.initialPetPicked) or false)		
		petsInitialized = true
	end

	local currentPetName		= object:GetWidget('mainPetsCurrentPetName')
	local currentPetDescription	= object:GetWidget('mainPetsCurrentPetDescription')
	
	local currentPetModel		= object:GetWidget('mainPetsCurrentPetModel')

	local lastPetID
	
	local function currentPetNameUpdate(widget, trigger)
		local entityName = trigger.entityName
		if entityName and string.len(entityName) > 0 and ValidateEntity(entityName) then
			if (trigger['customName']) and (not Empty(trigger['customName'])) then
				widget:SetText(trigger['customName'])
			else
				widget:SetText(GetEntityDisplayName(entityName))
			end
		else
			widget:SetText('')
		end
	end
	
	local function currentPetDescriptionUpdate(widget, trigger)
		widget:SetText(trigger.description)
	end

	local skinUnlockButton			= object:GetWidget('mainPetsskinUnlockButton')
	local skinUnlockButtonButton	= object:GetWidget('mainPetsskinUnlockButtonButton')
	local label						= object:GetWidget('mainPetsskinUnlockButtonLabel')
	local resources					= object:GetWidget('mainPetsskinUnlockButton_Resources')
	local oneResource				= object:GetWidget('mainPetsskinUnlockButton_Resources_One')
	local oneResourceIcon			= object:GetWidget('mainPetsskinUnlockButton_Resources_One_Icon')
	local oneResourceLabel			= object:GetWidget('mainPetsskinUnlockButton_Resources_One_Label')
	local twoResource				= object:GetWidget('mainPetsskinUnlockButton_Resources_Two')
	local twoResourceIcon1			= object:GetWidget('mainPetsskinUnlockButton_Resources_Two_Icon1')
	local twoResourceLabel1			= object:GetWidget('mainPetsskinUnlockButton_Resources_Two_Label1')
	local twoResourceIcon2			= object:GetWidget('mainPetsskinUnlockButton_Resources_Two_Icon2')
	local twoResourceLabel2			= object:GetWidget('mainPetsskinUnlockButton_Resources_Two_Label2')

	oneResource:SetVisible(true)
	twoResource:SetVisible(false)
	oneResourceIcon:SetVisible(true)
	oneResourceIcon:SetTexture('/ui/main/shared/textures/gem.tga')
	label:SetText(Translate('pet_skin_name_unlock_short'))
	
	local function labelUnlockUpdate(widget, trigger)
		if ((trigger.slotNumber < 0) or (trigger.level == 0) or (trigger.canPurchasePet and trigger.boosted)) then
			if ((trigger.isStarterPet) and (LuaTrigger.GetTrigger('Corral').initialPetPicked)) then
				widget:SetText(Translate('corral_locked_account_level_pet'))
			else
				widget:SetText(Translate('corral_locked_pet'))
			end
		else
			widget:SetText(Translate('corral_unlocked_pet', 'value', GetEntityDisplayName(trigger.entityName)))
		end
	end	
	
	local function skinUnlockButtonUpdate(widget, trigger)

		local selectedPetID			= 	LuaTrigger.GetTrigger('mainPetsMode').selectedPetID
		local petInfo 				= 	LuaTrigger.GetTrigger('CorralPet'..selectedPetID)			
		
		oneResourceLabel:SetText(petInfo['skinCost' .. petMode.selectedPetSkinIndex] or '?')

		skinUnlockButton:SetVisible((not petInfo.boosted) and (not (petInfo['skinOwned' .. petMode.selectedPetSkinIndex])) and tonumber(petInfo['skinCost' .. petMode.selectedPetSkinIndex]) and tonumber(petInfo['skinCost' .. petMode.selectedPetSkinIndex]) >= 0)
		
		skinUnlockButtonButton:SetEnabled((not petInfo.boosted) and (tonumber(petInfo['skinCost' .. petMode.selectedPetSkinIndex]) and tonumber(petInfo['skinCost' .. petMode.selectedPetSkinIndex]) >= 0))
		
		skinUnlockButtonButton:SetCallback('onclick', function(widget)
			spendGemsShow(
				function()
					println('^o^: Purchase Pet Skin')
					skinUnlockButtonButton:SetEnabled(0)
					skinUnlockButtonButton:UnregisterWatchLua('GameClientRequestsUnlockPetSkin')
					skinUnlockButtonButton:RegisterWatchLua('GameClientRequestsUnlockPetSkin', function(widget, requestStatusTrigger)
							if (requestStatusTrigger.status > 1) then
								mainUI.RefreshProducts(
									function()
										mainUI.savedRemotely 													= mainUI.savedRemotely 									or {}
										mainUI.savedRemotely.petBuilds 											= mainUI.savedRemotely.petBuilds 						or {}
										mainUI.savedRemotely.petBuilds[petInfo.entityName]						= mainUI.savedRemotely.petBuilds[petInfo.entityName] 	or {}
										mainUI.savedRemotely.petBuilds[petInfo.entityName].default_petSkin 		= petMode.selectedPetSkin
										mainUI.savedRemotely.petBuilds[petInfo.entityName].default_petSkinIndex	= petMode.selectedPetSkinIndex
										SaveState()
										if (GetCvarBool('ui_newUISounds')) then PlaySound('/ui/sounds/launcher/sfx_pet_skin_purchase.wav') end								
									
										skinUnlockButtonButton:SetEnabled(1)
										println('^g RefreshProducts GameClientRequestsUnlockPetSkin')
										PlaySound('/ui/sounds/pets/sfx_unlock.wav')

										petMode.selectedPetSkinOwned 	= petInfo['skinName' .. petMode.selectedPetSkinIndex]
										petMode:Trigger(false)			

										local triggerHeroSelectLocalPlayerInfo	= 	LuaTrigger.GetTrigger('HeroSelectLocalPlayerInfo')
										
										if (triggerHeroSelectLocalPlayerInfo.petEntityName == petInfo.entityName) then
											SpawnFamiliar(triggerHeroSelectLocalPlayerInfo.petEntityName, petInfo['skinName' .. petMode.selectedPetSkinIndex])
										end										
										
									end
								)
								skinUnlockButtonButton:UnregisterWatchLua('GameClientRequestsUnlockPetSkin')
							end
					end)
					Corral.PurchasePetSkin(petInfo.entityName, petInfo['skinName' .. petMode.selectedPetSkinIndex])
					if (mainUI) and  (mainUI.savedLocally) and  (mainUI.savedLocally.adaptiveTraining) and (mainUI.savedLocally.adaptiveTraining.featureList) and (mainUI.savedLocally.adaptiveTraining.featureList) then
						mainUI.AdaptiveTraining.RecordUtilisationInstanceByFeatureName('pets')
					end
				end,
				Translate('pet_skin_name_unlock'), 
				TranslateOrNil('pet_skin_name_' .. petInfo.entityName .. '_' .. petInfo['skinName' .. petMode.selectedPetSkinIndex]) or GetEntityDisplayName(petInfo.entityName),
				petInfo['skinCost' .. petMode.selectedPetSkinIndex], 
				function() end
			)
		end)
		skinUnlockButtonButton:SetCallback('onmouseover', function(widget) UpdateCursor(widget, true, { canLeftClick = true, canRightClick = false, spendGems = true }) end)
		skinUnlockButtonButton:SetCallback('onmouseout', function(widget) UpdateCursor(widget, false, { canLeftClick = true, canRightClick = false, spendGems = true }) end)				
	end	

	local unlockButton			= object:GetWidget('mainPetsUnlockButton')
	local unlockButtonButton	= object:GetWidget('mainPetsUnlockButtonButton')
	local label					= object:GetWidget('mainPetsUnlockButtonLabel')
	local resources				= object:GetWidget('mainPetsUnlockButton_Resources')
	local oneResource			= object:GetWidget('mainPetsUnlockButton_Resources_One')
	local oneResourceIcon		= object:GetWidget('mainPetsUnlockButton_Resources_One_Icon')
	local oneResourceLabel		= object:GetWidget('mainPetsUnlockButton_Resources_One_Label')
	local twoResource			= object:GetWidget('mainPetsUnlockButton_Resources_Two')
	local twoResourceIcon1		= object:GetWidget('mainPetsUnlockButton_Resources_Two_Icon1')
	local twoResourceLabel1		= object:GetWidget('mainPetsUnlockButton_Resources_Two_Label1')
	local twoResourceIcon2		= object:GetWidget('mainPetsUnlockButton_Resources_Two_Icon2')
	local twoResourceLabel2		= object:GetWidget('mainPetsUnlockButton_Resources_Two_Label2')
	
	label:RegisterWatchLua('Corral', function(widget, trigger)
		if trigger.initialPetPicked then
			widget:SetText(Translate('corral_unlock_pet'))
		else
			widget:SetText(Translate('corral_select_pet'))
		end
	end, false, nil, 'initialPetPicked')

	resources:RegisterWatchLua('CorralSelectedPet', function(widget, trigger)
		if trigger.initialPetPicked then
		
			-- Both seals and gems to purchase --
			if (trigger.petFruitCost > 0 and trigger.petGemCost > 0) then
				oneResource:SetVisible(false)
				twoResource:SetVisible(true)
				twoResourceIcon1:SetTexture('/ui/main/shared/textures/commodity_seal.tga')
				twoResourceLabel1:SetText(trigger.petFruitCost)
				twoResourceIcon2:SetTexture('/ui/main/shared/textures/gem.tga')
				twoResourceLabel2:SetText(trigger.petGemCost)
				
			-- Just seals to purchase --
			elseif (trigger.petFruitCost > 0 and trigger.petGemCost <= 0) then
				oneResource:SetVisible(true)
				twoResource:SetVisible(false)
				oneResourceIcon:SetVisible(true)
				oneResourceIcon:SetTexture('/ui/main/shared/textures/commodity_seal.tga')
				oneResourceLabel:SetText(trigger.petFruitCost)
				
			-- Just gems to purchase --
			else
				oneResource:SetVisible(true)
				twoResource:SetVisible(false)
				oneResourceIcon:SetVisible(true)
				oneResourceIcon:SetTexture('/ui/main/shared/textures/gem.tga')
				oneResourceLabel:SetText(trigger.petGemCost)
			end
		
		-- Pet requires no purchase --
		else
			oneResource:SetVisible(true)
			twoResource:SetVisible(false)
			oneResourceIcon:SetVisible(false)
			oneResourceLabel:SetText(Translate('corral_unlock_free_pet'))
		end
	end, false, nil, 'initialPetPicked', 'fruit', 'petFruitCost')

	unlockButtonButton:RegisterWatchLua('CorralSelectedPet', function(widget, trigger) 
		widget:SetEnabled(trigger.canPurchasePet and ((trigger.petFruitCost >= 0) or (trigger.petGemCost >= 0) or (not trigger.initialPetPicked)))
	end, false, nil, 'canPurchasePet', 'petFruitCost', 'petGemCost')	
	
	unlockButtonButton:SetCallback('onclick', function(widget)
	
		if LuaTrigger.GetTrigger('Corral').initialPetPicked then
			unlockPetContainer:FadeIn(175)
		else
			local petName 		= '?'
			local trigger 		= LuaTrigger.GetTrigger('CorralPet'..petModeTrigger.selectedPetID)
			local entityName 	= trigger.entityName
			
			if entityName and string.len(entityName) > 0 and ValidateEntity(entityName) then
				if trigger and (trigger['customName']) and (not Empty(trigger['customName'])) then
					petName = trigger['customName']
				else
					petName = GetEntityDisplayName(entityName)
				end			
			end
			
			GenericDialogAutoSize(
				'corral_firstpet_popup', Translate('corral_firstpet_popup_body', 'petname', petName), '', 'corral_firstpet_popup_select', 'general_cancel',	-- 'general_cancel'
				function()
					-- sound_petsUnlockPet
					PlaySound('/ui/sounds/pets/sfx_unlock.wav')
					queueReselectSamePetAfterUnlock(entityName)
					--[[
					libThread.threadFunc(function()	
						wait(100)
						mainUI.RefreshProducts()
					end)
					--]]
				end
			)
		end
		if (GetCvarBool('ui_newUISounds')) then PlaySound('/ui/sounds/launcher/sfx_pet_skin_unlock.wav') end
	end)
	
	local function unlockButtonUpdate(widget, trigger)
		widget:SetVisible(((trigger.slotNumber < 0) or (trigger.level == 0) or (trigger.canPurchasePet and trigger.boosted)) and (not ((trigger.isStarterPet) and (LuaTrigger.GetTrigger('Corral').initialPetPicked))))
	end

	local xpBarSegmentHeight	= 52	-- 's'
	
	local function xpBarUpdate(widget, trigger)
		local level = math.max(trigger.level, 1)
		level = level + LuaTrigger.GetTrigger('AccountProgression').percentToNextPetLevel
		level = math.min(level, 9)
		
		widget:SetHeight(
			(level * xpBarSegmentHeight)..'s'
		)
		
		currentPetXPBarEffect:SetVScale(
			(currentPetXPBarEffect:GetWidth() * 8)..'p'
		)
	end

	container:RegisterWatchLua('mainPetsMode', function(widget, trigger)
		local selectedPetID = trigger.selectedPetID
	
		if lastPetID and lastPetID >= 0 then
			-- ureg selected
			currentPetName:UnregisterWatchLuaByKey('mainPetsCurrentWatch')
			currentPetDescription:UnregisterWatchLuaByKey('mainPetsCurrentWatch')
			currentPetModel:UnregisterWatchLuaByKey('mainPetsCurrentWatch')
			unlockButton:UnregisterWatchLuaByKey('mainPetsCurrentWatch')
			skinUnlockButton:UnregisterWatchLuaByKey('mainPetsCurrentWatch')
			object:GetWidget('mainPetsCurrentPetLevel'):UnregisterWatchLuaByKey('mainPetsCurrentWatch')
		end
		
		if selectedPetID >= 0 then
			-- reg selected
			local petInfo = LuaTrigger.GetTrigger('CorralPet'..selectedPetID)
			
			currentPetName:RegisterWatchLua('CorralPet'..selectedPetID, currentPetNameUpdate, false, 'mainPetsCurrentWatch', 'entityName')
			currentPetDescription:RegisterWatchLua('CorralPet'..selectedPetID, currentPetDescriptionUpdate, false, 'mainPetsCurrentWatch', 'description')
			
			unlockButton:RegisterWatchLua('CorralPet'..selectedPetID, unlockButtonUpdate, false, 'mainPetsCurrentWatch', 'level', 'slotNumber', 'canPurchasePet', 'boosted', 'isStarterPet')
			skinUnlockButton:RegisterWatchLua('CorralPet'..selectedPetID, skinUnlockButtonUpdate, false, 'mainPetsCurrentWatch')
			object:GetWidget('mainPetsCurrentPetLevel'):RegisterWatchLua('CorralPet'..selectedPetID, labelUnlockUpdate, false, 'mainPetsCurrentWatch', 'entityName', 'level', 'slotNumber', 'canPurchasePet', 'boosted', 'isStarterPet')
			
			currentPetNameUpdate(currentPetName, petInfo)
			currentPetDescriptionUpdate(currentPetDescription, petInfo)
			unlockButtonUpdate(unlockButton, petInfo)
			skinUnlockButtonUpdate(unlockButton, petInfo)
			labelUnlockUpdate(object:GetWidget('mainPetsCurrentPetLevel'), petInfo)
			
			lastPetID = selectedPetID
		end
		
	end, false, nil, 'selectedPetID', 'selectedPetSkinIndex')
	
	local petsInitialized = false

	local function hide(object)
		petsFlushRequestQueue()
	
		container:SetVisible(false)
	end
	
	local function show(object)
		container:SetVisible(true)
	end

	local function intro(object)
		libThread.threadFunc(function()	
			wait(100)
			PlaySound('/ui/sounds/sfx_transition_2.wav')
			groupfcall('pet_animation_widgets', function(_, widget) RegisterRadialEase(widget) widget:DoEventN(7) end)	
		end)
	end
	
	local function outro(object)
		libThread.threadFunc(function()	
			groupfcall('pet_animation_widgets', function(_, widget) widget:DoEventN(8) end)			
		end)		
	end
	
	container:RegisterWatchLua('mainPanelAnimationStatus', function(widget, trigger)
		local animState = mainSectionAnimState(2, trigger.main, trigger.newMain)
		if animState == 1 then
			outro(object)
		elseif animState == 2 then
			hide(object)
		elseif animState == 3 then
			intro(object)
			setMainTriggers({
				mainBackground = {wheelX='600s'} -- left wheel background
			})
		elseif animState == 4 then
			if not petsInitialized then
				initialize()
				petsInitialized = true
			end
			show(object)
			if (mainUI) and  (mainUI.savedLocally) and  (mainUI.savedLocally.adaptiveTraining) and (mainUI.savedLocally.adaptiveTraining.featureList) and (mainUI.savedLocally.adaptiveTraining.featureList) then
				mainUI.AdaptiveTraining.RecordViewInstanceByFeatureName('pets')
			end
		end
	end, false, nil, 'main', 'newMain')

end	-- End petsRegister()

petsRegister(object)
