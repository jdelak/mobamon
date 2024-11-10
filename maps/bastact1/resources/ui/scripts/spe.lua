--[[
========================
SPE Interface Core
========================
]]--
local interface 			= object
local objectiveContainer	= interface:GetWidget('Objective_Container')	-- Any widget will do!

Cmd("LoadInterface /ui/blank.interface") -- For cinematics to have no UI

local executionerHPMax		= 0
local executionerHPCurrent	= 0

gameSPE = gameSPE or {
	objectiveIndex						= 0,	-- Just provide a unique id per objective
	hintIndex							= 0,	-- Just provide a unique id per hint
	activeObjectives					= {},
	activeHints							= {},
	hintDisplayOrder					= {},
	objectiveDisplayOrder				= {},
	initWidgetSoundEnabled				= false,
	blackOverlayVisible					= true,
	activeMessage						= nil,
	activeMessage2						= nil,
	activeMessage3						= nil,
	activeTip							= nil,
	initialized							= false,
	panelVis							= {},
	cinematicOverlayVisible				= false,
	cinematicBlackOverlayVisible		= false,
	cinematicDialogueVisible			= false
}

local speMessageStatus = LuaTrigger.CreateCustomTrigger('speMessageVis', {
	{ name		= 'speMessageVis',			type		= 'boolean' },
	{ name		= 'speTipVis',				type		= 'boolean' },
})

if not gameSPE.initialized then
	dialogueMessageStatus.dialogueMessageVis					= false
	cinematicDialogueMessageStatus.cinematicDialogueMessageVis 	= false
	dialogueMessageStatus:Trigger(false)
	cinematicDialogueMessageStatus:Trigger(false)
	gameSPE.initialized 										= true
end

--[[
========================
Turning On/Off Map Specific UI
========================
]]--
local function speRegister(triggerName, params0)
	if gameSPE.panelVis[params0] == nil then
		gameSPE.panelVis[params0] = triggerName[params0]
	else
		triggerName[params0] = gameSPE.panelVis[params0]
		triggerName:Trigger(false)
	end
end

local function speRegisterShow(triggerName, params0)
	triggerName[params0] = true
	gameSPE.panelVis[params0] = true
	triggerName:Trigger(true)
end

local function speRegisterHide(triggerName, params0)
	triggerName[params0] = false
	gameSPE.panelVis[params0] = false
	triggerName:Trigger(true)
end

local function speRegisterGameWidgetVis(object)	
	-- gamePanelInfo
	objectiveContainer:RegisterWatch('genericMapTriggerHide', function(widget, params0)
		speRegister(trigger_gamePanelInfo, params0)
		speRegisterHide(trigger_gamePanelInfo, params0)
	end)
	
	objectiveContainer:RegisterWatch('genericMapTriggerShow', function(widget, params0)
		speRegister(trigger_gamePanelInfo, params0)
		speRegisterShow(trigger_gamePanelInfo, params0)

		if trigger_gamePanelInfo then
			trigger_gamePanelInfo:Trigger(true)
		end
	end)
	
	-- altInfoSelfMapTrigger
	objectiveContainer:RegisterWatch('altInfoSelfMapTriggerHide', function(widget, params0)
		local altInfoSelfMapTrigger = LuaTrigger.GetTrigger('altInfoSelfMapTrigger')
		
		speRegister(altInfoSelfMapTrigger, params0)
		speRegisterHide(altInfoSelfMapTrigger, params0)

		if altInfoSelfMapTrigger then
			altInfoSelfMapTrigger:Trigger(true)
		end
	end)
	
	objectiveContainer:RegisterWatch('altInfoSelfMapTriggerShow', function(widget, params0)
		local altInfoSelfMapTrigger = LuaTrigger.GetTrigger('altInfoSelfMapTrigger')
		
		speRegister(altInfoSelfMapTrigger, params0)
		speRegisterShow(altInfoSelfMapTrigger, params0)

		if altInfoSelfMapTrigger then
			altInfoSelfMapTrigger:Trigger(true)
		end
	end)
	
	-- altInfoHeroMapTrigger
	objectiveContainer:RegisterWatch('altInfoHeroMapTriggerHide', function(widget, params0)
		local altInfoHeroMapTrigger = LuaTrigger.GetTrigger('altInfoHeroMapTrigger')
		
		speRegister(altInfoHeroMapTrigger, params0)
		speRegisterHide(altInfoHeroMapTrigger, params0)

		if altInfoHeroMapTrigger then
			altInfoHeroMapTrigger:Trigger(true)
		end
	end)
	
	objectiveContainer:RegisterWatch('altInfoHeroMapTriggerShow', function(widget, params0)
		local altInfoHeroMapTrigger = LuaTrigger.GetTrigger('altInfoHeroMapTrigger')
		
		speRegister(altInfoHeroMapTrigger, params0)
		speRegisterShow(altInfoHeroMapTrigger, params0)

		if altInfoHeroMapTrigger then
			altInfoHeroMapTrigger:Trigger(true)
		end
	end)
	
	-- mapTriggerActObjectives
	objectiveContainer:RegisterWatch('mapTriggerActObjectives', function(widget, params0)
		speRegister(triggerMapObjectivesActSet, params0)
		speRegisterShow(triggerMapObjectivesActSet, params0)

		local mapObjectivesActSet = LuaTrigger.GetTrigger('mapObjectivesActSet')
		if mapObjectivesActSet then
			mapObjectivesActSet:Trigger(true)
		end
	end)
	
	objectiveContainer:RegisterWatch('mapTriggerActObjectivesHide', function(widget, params0)
		speRegister(triggerMapObjectivesActSet, params0)
		speRegisterHide(triggerMapObjectivesActSet, params0)

		local mapObjectivesActSet = LuaTrigger.GetTrigger('mapObjectivesActSet')
		if mapObjectivesActSet then
			mapObjectivesActSet:Trigger(true)
		end
	end)
	
	-- mapTriggerAbility
	objectiveContainer:RegisterWatch('mapTriggerAbilityHide', function(widget, params0)
		speRegister(trigger_SPEAbilityUpdate, params0)
		speRegisterHide(trigger_SPEAbilityUpdate, params0)

		local SPEAbilityUpdate = LuaTrigger.GetTrigger('SPEAbilityUpdate')
		if SPEAbilityUpdate then
			SPEAbilityUpdate:Trigger(true)
		end
	end)
	
	objectiveContainer:RegisterWatch('mapTriggerAbilityShow', function(widget, params0)
		speRegister(trigger_SPEAbilityUpdate, params0)
		speRegisterShow(trigger_SPEAbilityUpdate, params0)

		local SPEAbilityUpdate = LuaTrigger.GetTrigger('SPEAbilityUpdate')
		if SPEAbilityUpdate then
			SPEAbilityUpdate:Trigger(true)
		end
	end)
end

speRegisterGameWidgetVis(object)

--[[
========================
Movie Stuff
========================
]]--

local movieEscTextbox					= object:GetWidget('movieEscTextbox')
local optionsButton						= object:GetWidget('speMenuButton')
local movieInstantiationTarget			= object:GetWidget('movieInstantiationTarget')

if movieEscTextbox and movieInstantiationTarget then
	local function skipTutorialVideo()
		local videoWidget						= interface:GetWidget('videowidget')
		if (videoWidget) then
			videoWidget:StopMovie()
		end
	end

	movieEscTextbox:SetCallback('onlosefocus', function(widget)
		skipTutorialVideo()
	end)
	
	movieInstantiationTarget:RegisterWatch('video_start', function (widget, param0)		
		println('video_start ' .. param0)
		
		local prevVideoWidgets = widget:GetGroup('videowidgets')
		if (prevVideoWidgets) then
			for i, v in pairs(prevVideoWidgets) do
				if (v) and (v:IsValid()) then
					v:SetVisible(0)
				end
			end
		end

		
		
		if optionsButton then
			optionsButton:SetVisible(0)
		end
		
		if (param0 == 'opening') then
			local moviesWidgets = widget:GetWidget('videowidget')		
		
			moviesWidgets:PauseMovie()
			moviesWidgets:PlayMovie('/bink/bastion_act1_intro.bk2')

			moviesWidgets:SetVisible(1)
		elseif (param0 == 'closing') then
			local moviesWidgets = widget:GetWidget('videowidget2')		
		
			moviesWidgets:PauseMovie()
			moviesWidgets:PlayMovie('/bink/bastion_act1_ending.bk2')

			moviesWidgets:SetVisible(1)
		end
		
		SetMoviePlaying(true)
		
		--MuteSound()
		
	end)
end

--[[
========================
End Game Screen
========================
]]--
-- interface:GetWidget('spe_scriptWidget'):RegisterWatch('bastact1_finishedAct1', function(widget, trigger)
	-- mainUI = mainUI or {}
	-- mainUI.savedLocally = mainUI.savedLocally or {}
	-- mainUI.savedLocally.speContentComplete = {}
	-- mainUI.savedLocally.speContentComplete.bastion1 = true
	-- SaveState()
-- end)

interface:GetWidget('spe_scriptWidget'):RegisterWatch('bastact1_endGame', function(widget, trigger)
	widget:Sleep(30000, function()
		Client.FinishGame()
	end)
	if (mainUI) and (mainUI.Analytics) and (mainUI.Analytics.AddFeatureFinishInstance) then
		mainUI.Analytics.AddFeatureFinishInstance('spe_1b')
	end	
end)

--[[
========================
Blank Interface Stuff
========================
]]--
objectiveContainer:RegisterWatch('interface_turnOn', function(widget)	
	Cmd('SetGameInterface game')	
end)

objectiveContainer:RegisterWatch('interface_turnOff', function(widget)	
	Cmd('SetGameInterface blank')
end)