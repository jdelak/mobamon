-- These will also be used in game.interface for tutorial

local scriptWidget = object:GetWidget('main_login_prompt_parent') or object:GetWidget('tutorialScriptWidget1') or object:GetWidget('npeScriptWidget')

NewPlayerExperience = NewPlayerExperience or {}

NewPlayerExperience.lastWebSubmit = -1

function NewPlayerExperience.progressCanSkip()
	if (not NewPlayerExperience.trigger.tutorialComplete) and (NewPlayerExperience.trigger.tutorialProgress >= NPE_PROGRESS_ENTEREDNAME and NewPlayerExperience.trigger.tutorialProgress < NPE_PROGRESS_FINISHTUT3 and (NewPlayerExperience.trigger.tutorialProgress ~= NPE_PROGRESS_ACCOUNTCREATED or LuaTrigger.GetTrigger('Corral').initialPetPicked)) then
		if (
			(
				(
					Strife_Region and
					Strife_Region.regionTable and
					Strife_Region.regionTable[Strife_Region.activeRegion] and
					( (Strife_Region.regionTable[Strife_Region.activeRegion].NPEIsOptional) or
						( Client.GetAccountID() and tonumber(Client.GetAccountID()) and (tonumber(Client.GetAccountID()) > 0) and Strife_Region.regionTable[Strife_Region.activeRegion].NPEIsABOptional and ((tonumber(string.match(Client.GetAccountID(), '(%d+)%.')))%2 == 1))
					)

				)
			) or (
				NewPlayerExperience.data.lastLocalProgress and
				NewPlayerExperience.data.lastLocalProgress > NewPlayerExperience.data.tutorialProgressLastWeb and
				(not LuaTrigger.GetTrigger('setTutorialProgressStatus').busy)
			)
		) then
			return true
		end
	end

	return false
end

function NewPlayerExperience.progressSkip()
	NewPlayerExperience.trigger.tutorialProgressBeforeSkip	= NewPlayerExperience.trigger.tutorialProgress
	NewPlayerExperience.trigger.tutorialProgress			= NPE_PROGRESS_TUTORIALCOMPLETE
	NewPlayerExperience.trigger:Trigger(false)
		libThread.threadFunc(function()
			wait(2000)	
			if (not mainUI.savedRemotely) or (not mainUI.savedRemotely.splashScreensViewed) or (not mainUI.savedRemotely.splashScreensViewed['splash_screen_control_presets']) then
				mainUI.savedRemotely = mainUI.savedRemotely or {}
				mainUI.savedRemotely.splashScreensViewed = mainUI.savedRemotely.splashScreensViewed or {}
				mainUI.savedRemotely.splashScreensViewed['splash_screen_control_presets'] = true
				SaveState()
				local mainPanelStatus = LuaTrigger.GetTrigger('mainPanelStatus')
				mainPanelStatus.main = mainUI.MainValues.controlPresets
				mainPanelStatus:Trigger(false)
			end	
		end)
end

NewPlayerExperience.data = GetAnonDBEntry('strife_db_newPlayerExperience', NewPlayerExperience.data, true, false, true) or {
	tutorialProgress		= NPE_PROGRESS_START,			-- What's the last tutorial section that they've completed? (0 for none)
	tutorialComplete		= false,
	newIdentName			= '',
	craftingIntroProgress	= 0,
	enchantingIntroProgress	= 0,
	corralIntroProgress		= 0,
	rewardsIntroProgress	= 0,
	tutorial1Revisit		= 0,
	tutorial2Revisit		= 0,
	tutorial3Revisit		= 0,
	tutorialProgressBeforeSkip	= 0,
	tutorialProgressLastWeb	= 0,
	lastLocalProgress		= 0,
	seenTowerDamageWarning	= false,
	seenAttackHeroWarning	= false,
	signupEmails			= {},
}

NewPlayerExperience.data.lastLocalProgress		= NewPlayerExperience.data.lastLocalProgress or 0
NewPlayerExperience.data.seenTowerDamageWarning	= NewPlayerExperience.data.seenTowerDamageWarning or false
NewPlayerExperience.data.seenAttackHeroWarning	= NewPlayerExperience.data.seenAttackHeroWarning or false

NewPlayerExperience.data.tutorial1Revisit				= NewPlayerExperience.data.tutorial1Revisit or 0
NewPlayerExperience.data.tutorial2Revisit				= NewPlayerExperience.data.tutorial2Revisit or 0
NewPlayerExperience.data.tutorial3Revisit				= NewPlayerExperience.data.tutorial3Revisit or 0
NewPlayerExperience.data.tutorialProgressBeforeSkip		= NewPlayerExperience.data.tutorialProgressBeforeSkip or 0

NewPlayerExperience.requiresLogin	= true

function NewPlayerExperience.isNPEDemo()
	return (Strife_Region and Strife_Region.regionTable and Strife_Region.regionTable[Strife_Region.activeRegion] and Strife_Region.regionTable[Strife_Region.activeRegion].NPEDemo)
end

function NewPlayerExperience.isNPEDemo2()
	return (Strife_Region and Strife_Region.regionTable and Strife_Region.regionTable[Strife_Region.activeRegion] and Strife_Region.regionTable[Strife_Region.activeRegion].NPEDemo2)
end

if NewPlayerExperience.isNPEDemo() or NewPlayerExperience.isNPEDemo2() then
	NewPlayerExperience.requiresLogin	= false
end

function NewPlayerExperience.resetDB()
	NewPlayerExperience.data = GetAnonDBEntry('strife_db_newPlayerExperience', nil, true, true, false)
end

function NewPlayerExperience.saveDB()
	-- local identID = GetIdentID()
	-- if identID and string.len(identID) > 0 then
		GetAnonDBEntry('strife_db_newPlayerExperience', NewPlayerExperience.data, true, false, false)
	-- else
		-- print('NPE saveDB with invalid ident.')
	-- end
	SaveState()
end

scriptWidget:RegisterWatchLua('newPlayerExperience', function(widget, trigger)
	NewPlayerExperience.data.tutorialProgress			= trigger.tutorialProgress
	NewPlayerExperience.data.tutorialComplete			= trigger.tutorialComplete
	NewPlayerExperience.data.craftingIntroProgress		= trigger.craftingIntroProgress
	NewPlayerExperience.data.enchantingIntroProgress	= trigger.enchantingIntroProgress
	NewPlayerExperience.data.corralIntroProgress		= trigger.corralIntroProgress
	NewPlayerExperience.data.rewardsIntroProgress		= trigger.rewardsIntroProgress
	NewPlayerExperience.data.tutorial1Revisit			= trigger.tutorial1Revisit
	NewPlayerExperience.data.tutorial2Revisit			= trigger.tutorial2Revisit
	NewPlayerExperience.data.tutorial3Revisit			= trigger.tutorial3Revisit
	NewPlayerExperience.data.tutorialProgressBeforeSkip	= trigger.tutorialProgressBeforeSkip


	NewPlayerExperience.saveDB()
end, false, nil,
	'tutorialProgress',
	'tutorialComplete',
	'craftingIntroProgress',
	'enchantingIntroProgress',
	'corralIntroProgress',
	'rewardsIntroProgress',
	'tutorial1Revisit',
	'tutorial2Revisit',
	'tutorial3Revisit',
	'tutorialProgressBeforeSkip'
)

function NewPlayerExperience.crippledRegion()
	return (Strife_Region and Strife_Region.regionTable and Strife_Region.regionTable[Strife_Region.activeRegion] and Strife_Region.regionTable[Strife_Region.activeRegion].crippled)
end

-- rmm large portions of this only occur if not NewPlayerExperience.crippledRegion() and if npe is enabled

NewPlayerExperience.data.tutorialProgressLastWeb = NewPlayerExperience.data.tutorialProgressLastWeb or 0

NewPlayerExperience.trigger = LuaTrigger.GetTrigger('newPlayerExperience')

-- Only append to this - needs to remain in order so bits match.  Do not increase bits count for existing entries.
local npeWebParams	= {
	{
		name	= 'tutorialProgress',
		bits	= 5,
		lastWeb	= -1
	},
	{
		name	= 'enchantingIntroProgress',
		bits	= 3,
		lastWeb	= (NewPlayerExperience.data.tutorialProgressLastWeb or 0)
	},
	{
		name	= 'craftingIntroProgressOld',	-- OLD, UNUSED BY RC 6/13/2014
		bits	= 3,
		lastWeb	= -1,
		skip	= true
	},
	{
		name	= 'corralIntroProgress',
		bits	= 3,
		lastWeb	= -1
	},
	{
		name	= 'rewardsIntroProgress',
		bits	= 3,
		lastWeb	= -1
	},
	{
		name	= 'craftingIntroProgress',
		bits	= 3,
		lastWeb	= -1
	},
	{
		name	= 'tutorialProgressBeforeSkip',
		bits	= 3,	-- This is shorter than it should be as a temp hack to fit the next 3 bits.
		lastWeb	= -1
	},
	{
		name	= 'tutorial1Revisit',
		bits	= 1,
		lastWeb	= -1
	},
	{
		name	= 'tutorial2Revisit',
		bits	= 1,
		lastWeb	= -1
	},
	{
		name	= 'tutorial3Revisit',
		bits	= 1,
		lastWeb	= -1
	},
}


function NewPlayerExperience.webProgressCalcArray()
	local triggerNPE	= LuaTrigger.GetTrigger('newPlayerExperience')
	local tutorialProgressArray = {}
	for i=1,#npeWebParams,1 do
		if not npeWebParams[i].skip then
			table.insert(tutorialProgressArray, triggerNPE[npeWebParams[i].name])
		end
	end
	return tutorialProgressArray
end
function NewPlayerExperience.webProgressCalc()
	local triggerNPE	= LuaTrigger.GetTrigger('newPlayerExperience')
	local output	= 0
	local bitPos	= 0
	for i=1,#npeWebParams,1 do
		if not npeWebParams[i].skip then
			output = output + libNumber.bitShiftL(triggerNPE[npeWebParams[i].name], bitPos)
		end

		bitPos = bitPos + npeWebParams[i].bits
	end
	return output
end

function NewPlayerExperience.webProgressImport(webProgress)
	local newValues	= {}
	local sectionProgress = webProgress
	local bitShift
	local paramValue
	for i=#npeWebParams,1,-1 do
		bitShift = 0
		for j=1,(i - 1),1 do
			bitShift = bitShift + npeWebParams[j].bits
		end
		paramValue = libNumber.bitShiftR(sectionProgress, bitShift)
		sectionProgress = sectionProgress - libNumber.bitShiftL(paramValue, bitShift)
		-- if not npeWebParams[i].skip then
			newValues[npeWebParams[i].name] = paramValue
		-- end

	end

	return newValues
end

function NewPlayerExperience.setTutorialProgress(progress, complete)
	if progress and type(progress) == 'number' then
		NewPlayerExperience.trigger.tutorialProgress		= progress
		if complete ~= nil then
			NewPlayerExperience.trigger.tutorialComplete	= complete
		end
		NewPlayerExperience.trigger:Trigger(false)
	end
end

-- ================================================
function NewPlayerExperience.resetCrafting()
	NewPlayerExperience.trigger.craftingIntroProgress	= 0
	NewPlayerExperience.trigger.craftingIntroStep		= 0
	NewPlayerExperience.trigger.enchantingIntroProgress	= 0
	NewPlayerExperience.trigger.enchantingIntroStep		= 0
end

function NewPlayerExperience.resetAll()
	NewPlayerExperience.trigger.craftingIntroProgress	= 0
	NewPlayerExperience.trigger.craftingIntroStep		= 0
	NewPlayerExperience.trigger.enchantingIntroProgress	= 0
	NewPlayerExperience.trigger.enchantingIntroStep		= 0
	NewPlayerExperience.trigger.corralIntroProgress		= 0
	NewPlayerExperience.trigger.corralIntroStep			= 0
	NewPlayerExperience.trigger.rewardsIntroProgress	= 0
	NewPlayerExperience.trigger.rewardsIntroStep		= 0
	NewPlayerExperience.resetTutorial()
end

function NewPlayerExperience.resetTutorial(useTrigger)
	if useTrigger == nil then useTrigger = true end
	NewPlayerExperience.trigger.tutorialComplete			= false
	NewPlayerExperience.trigger.tutorialProgress			= 0
	NewPlayerExperience.trigger.npeStarted					= false
	NewPlayerExperience.trigger.showLogin					= false
	NewPlayerExperience.trigger.tutorial1Revisit			= 0
	NewPlayerExperience.trigger.tutorial2Revisit			= 0
	NewPlayerExperience.trigger.tutorial3Revisit			= 0
	NewPlayerExperience.trigger.tutorialProgressBeforeSkip	= 0

	NewPlayerExperience.data.tutorialProgressLastWeb	= -1
	NewPlayerExperience.data.lastLocalProgress			= 0
	NewPlayerExperience.data.seenTowerDamageWarning		= false
	NewPlayerExperience.data.seenAttackHeroWarning		= false
	NewPlayerExperience.lastWebSubmit					= -1
	Cvar.GetCvar('net_name'):Set('')
	if useTrigger then
		NewPlayerExperience.trigger:Trigger(true)
	end

end

-- ================================================

if scriptWidget then

	scriptWidget:RegisterWatch('tutorial_finishMap1', function(widget)
		NewPlayerExperience.trigger.tutorialProgress = NPE_PROGRESS_FINISHTUT1
		NewPlayerExperience.trigger:Trigger(false)
	end)

	scriptWidget:RegisterWatch('tutorial_finishMap2', function(widget)
		NewPlayerExperience.trigger.tutorialProgress = NPE_PROGRESS_FINISHTUT2
		NewPlayerExperience.trigger:Trigger(false)
	end)

	scriptWidget:RegisterWatch('tutorial_finishMap3', function(widget)
		NewPlayerExperience.trigger.tutorialProgress = NPE_PROGRESS_FINISHTUT3
		NewPlayerExperience.trigger:Trigger(false)
	end)

else
	print('============================================= could not find script widget\n')
end

local npeWebCompareParams = {
	'AccountInfo.isIdentPopulated',
	'AccountInfo.tutorialProgress',
	'LoginStatus.isLoggedIn',
	'LoginStatus.hasIdent',
	'LoginStatus.externalLogin',
	'LoginStatus.launchedViaSteam',
	'LoginStatus.loggedInViaSteam'
}

for k,v in ipairs(npeWebParams) do
	table.insert(npeWebCompareParams, 'newPlayerExperience.'..v.name)
end

libGeneral.createGroupTrigger('npeWebCompareUpdate', npeWebCompareParams)

local function checkLoginAdvanceNPEProgress(currentProgress)
	local returnProgress	= currentProgress
	--[[
	if returnProgress <= NPE_PROGRESS_ENTEREDNAME then
		returnProgress = NPE_PROGRESS_ENTEREDNAME
	end
	--]]

	if returnProgress == NPE_PROGRESS_FINISHTUT2 then
		returnProgress = NPE_PROGRESS_ACCOUNTCREATED
	end
	return returnProgress
end

scriptWidget:RegisterWatchLua('npeWebCompareUpdate', function(widget, groupTrigger)
	local needToUpdateWeb	= false
	local localUpdated	= false

	local triggerAccount			= groupTrigger['AccountInfo']
	local triggerLogin				= groupTrigger['LoginStatus']
	local fullyLoggedIn				= (triggerLogin.isLoggedIn and triggerLogin.hasIdent and triggerLogin.isIdentPopulated)

	local triggerNPE				= NewPlayerExperience.trigger

	if fullyLoggedIn then
		local currentWeb	= NewPlayerExperience.webProgressImport(triggerAccount.tutorialProgress)

		for k,v in ipairs(npeWebParams) do

			if not v.skip then
				if v.name == 'tutorialProgress' then
					currentWeb[v.name]	= checkLoginAdvanceNPEProgress(currentWeb[v.name])
					v.lastWeb			= checkLoginAdvanceNPEProgress(v.lastWeb)
					triggerNPE[v.name]	= checkLoginAdvanceNPEProgress(triggerNPE[v.name])

					if currentWeb[v.name] > NewPlayerExperience.data.tutorialProgressLastWeb then
						NewPlayerExperience.data.tutorialProgressLastWeb = currentWeb[v.name]
					end

					NewPlayerExperience.data.lastLocalProgress = triggerNPE[v.name]
				end

				if (
					-- ((v.name == 'tutorialProgress' and (triggerNPE.tutorialComplete or currentWeb[v.name] >= NPE_PROGRESS_ACCOUNTCREATED)) or currentWeb[v.name] > triggerNPE[v.name]) and currentWeb[v.name] > v.lastWeb
					(	-- ( web > local or not isTutProgress or tutComplete or web > accCreated ) and web > lastWeb
						currentWeb[v.name] > triggerNPE[v.name] or			-- Web is newer, inherit web
						v.name ~= 'tutorialProgress' or						-- Always inherit web, always have an account for non-tutorialProgress
						(NewPlayerExperience.requiresLogin and (not (triggerLogin.externalLogin and (not (triggerLogin.launchedViaSteam and (not triggerLogin.loggedInViaSteam))) and currentWeb[v.name] < NPE_PROGRESS_ENTEREDNAME))) or				-- No NPE without login, always use web
						triggerNPE.tutorialComplete or						-- Always inherit web, potentially a new account
						currentWeb[v.name] >= NPE_PROGRESS_ACCOUNTCREATED	-- User def has web progress, inherit web.  This is primarily for cases where we allow tut1/tut2 before logging in.
					) and currentWeb[v.name] > v.lastWeb					-- Web has been updated since the last time it was received

				) then
					-- printdb('local gets updated for '..v.name..' from '..triggerNPE[v.name]..' to '..currentWeb[v.name]..'\n')

					triggerNPE[v.name] = currentWeb[v.name]

					if v.name == 'tutorialProgress' then
						NewPlayerExperience.data.lastLocalProgress = triggerNPE[v.name]
					end

					v.lastWeb = currentWeb[v.name]
					localUpdated = true
				elseif triggerNPE[v.name] > currentWeb[v.name] and triggerNPE[v.name] > v.lastWeb then
					-- printdb(v.name..' -- web needs to be updated from '..tostring(v.lastWeb)..' to '..tostring(triggerNPE[v.name])..'\n')
					v.lastWeb = triggerNPE[v.name]
					needToUpdateWeb = true
				elseif (triggerNPE[v.name] > currentWeb[v.name] and (v.lastWeb > currentWeb[v.name])) then
					needToUpdateWeb = true
				else
					-- printdb('no updates for '..v.name..'|'..currentWeb[v.name]..'|'..triggerNPE[v.name]..'\n')
				end
			else
				-- printdb('skipping npeWebCompareUpdate for '..k..' -> '..v.name..'\n')
			end


		end

		if needToUpdateWeb then
			local newProgress = NewPlayerExperience.webProgressCalc()

			if newProgress ~= NewPlayerExperience.lastWebSubmit then
				-- printdb('need to update web\n')

				NewPlayerExperience.lastWebSubmit = newProgress

				Strife_Web_Requests:SetTutorialProgress(newProgress, nil, NewPlayerExperience.webProgressCalcArray())
			end
		end

		-- rmm if not already its new value, localUpdated = true
		if triggerNPE.tutorialProgress < NPE_PROGRESS_TUTORIALCOMPLETE then
			if triggerNPE.tutorialComplete then
				triggerNPE.tutorialComplete = false
				localUpdated = true
			end
		else
			if not triggerNPE.tutorialComplete then
				triggerNPE.tutorialComplete = true
				localUpdated = true
			end
		end

		if localUpdated then
			-- printdb('local updated\n')
			triggerNPE:Trigger(false)
		end

		genericEvent.broadcast('newPlayerExperience_checkCanSkip')
	else
		if NewPlayerExperience.isNPEDemo() then
			if triggerNPE.tutorialProgress >= NPE_PROGRESS_FINISHTUT1 then
				NewPlayerExperience.resetTutorial()
			end
		elseif NewPlayerExperience.isNPEDemo2() then
			if triggerNPE.tutorialProgress ~= NPE_PROGRESS_SELECTEDPET then
				NewPlayerExperience.resetTutorial(false)
				triggerNPE.tutorialProgress = NPE_PROGRESS_SELECTEDPET
				triggerNPE:Trigger(true)
			end
		end
	end
end)