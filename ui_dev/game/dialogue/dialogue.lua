--[[
========================
Local Variables
========================
]]--
local interface 			= object

local message				= interface:GetWidget('Dialogue_Container')
local messageBG 			= interface:GetWidget('Dialogue_Message_BG')
local messageTitle			= interface:GetWidget('Dialogue_Message_Text_Title')
local messageBody			= interface:GetWidget('Dialogue_Message_Text_Body')
local messageModel

local teamText_BaseC		= object:GetWidget('Dialogue_Message_Text_BaseC')
local teamText_BaseL		= object:GetWidget('Dialogue_Message_Text_BaseL')
local teamText_BaseR		= object:GetWidget('Dialogue_Message_Text_BaseR')

local teamModel_BottomFrame	= interface:GetWidget('Dialogue_Message_Model_BottomFrame')
local teamModel_GlowConstant= interface:GetWidget('Dialogue_Message_Model_GlowConstant')
local teamModel_GlowFlicker	= interface:GetWidget('Dialogue_Message_Model_GlowFlicker')
local teamModel_TopFrame	= interface:GetWidget('Dialogue_Message_Model_TopFrame')
local teamModel_DetailTL	= interface:GetWidget('Dialogue_Message_Model_DetailTL')
local teamModel_DetailTR	= interface:GetWidget('Dialogue_Message_Model_DetailTR')
local teamModel_DetailB		= interface:GetWidget('Dialogue_Message_Model_DetailB')

local teamModel_TopDoor		= interface:GetWidget('Dialogue_Message_Model_TopDoor')
local teamModel_BottomDoor	= interface:GetWidget('Dialogue_Message_Model_BottomDoor')
local teamModel_Icon		= interface:GetWidget('Dialogue_Message_Model_Icon')

local teamText_GlowC		= interface:GetWidget('Dialogue_Message_Text_GlowC')
local teamText_GlowL		= interface:GetWidget('Dialogue_Message_Text_GlowL')
local teamText_GlowR		= interface:GetWidget('Dialogue_Message_Text_GlowR')

local smoke01a				= interface:GetWidget('Dialogue_Message_Smoke_01_a')
local smoke01b				= interface:GetWidget('Dialogue_Message_Smoke_01_b')
local smoke01c				= interface:GetWidget('Dialogue_Message_Smoke_01_c')
local smoke02a				= interface:GetWidget('Dialogue_Message_Smoke_02_a')
local smoke02b				= interface:GetWidget('Dialogue_Message_Smoke_02_b')
local smoke02c				= interface:GetWidget('Dialogue_Message_Smoke_02_c')

local smokeVerical			= interface:GetGroup('Dialogue_Message_Text_SmokeVerical')
local smokeLeft				= interface:GetGroup('Dialogue_Message_Text_SmokeLeft')
local smokeRight			= interface:GetGroup('Dialogue_Message_Text_SmokeRight')
local smokeLeftOff			= interface:GetGroup('Dialogue_Message_Text_SmokeLeftOff')
local smokeRightOff			= interface:GetGroup('Dialogue_Message_Text_SmokeRightOff')

local rubbleGroup			= interface:GetGroup('Dialogue_Message_Text_Rubbles')
local rubbleOffGroup		= interface:GetGroup('Dialogue_Message_Text_Rubble_Off')

local messageModelGroup		= interface:GetGroup('Dialogue_Message_Models')

--[[
========================
Core Base Functionality
========================
]]--
local dialogueMessageStatus = LuaTrigger.CreateCustomTrigger('dialogueMessageVis', {
	{ name		= 'dialogueMessageVis',				type	= 'boolean' },
})

local cinematicDialogueMessageStatus = LuaTrigger.CreateCustomTrigger('cinematicDialogueMessageVis', {
	{ name		= 'cinematicDialogueMessageVis',	type	= 'boolean' },
})

-- Checks if there is a TutorialPause, or creates one...
tutorialPauseTrigger	= LuaTrigger.GetTrigger('TutorialPause')

if not tutorialPauseTrigger then
	local tutorialPauseTrigger = LuaTrigger.CreateCustomTrigger("TutorialPause", {{name = "hidePaused", type = "boolean"}})
	
	tutorialPauseTrigger.hidePaused = false
	tutorialPauseTrigger:Trigger(true)
end

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
	cinematicDialogueVisible			= false,
	objectiveOverlayVisible 			= false
}

if not gameSPE.initialized then
	dialogueMessageStatus.dialogueMessageVis					= false
	cinematicDialogueMessageStatus.cinematicDialogueMessageVis 	= false
	dialogueMessageStatus:Trigger(false)
	cinematicDialogueMessageStatus:Trigger(false)
	gameSPE.initialized 										= true
end

--[[
========================
On/Off Functions for Dialogue Message
========================
]]--
local function DialogueAnimateOn (team, delay)
	DialogueAnimateCracks(true)
	DialogueAnimateRubble(true)
	DialogueAnimateGlow(true, delay)
	
	-- No Smoke or Rubble Effects Anymore
	-- DialogueAnimateSmokeVertical(true, smoke01a, team, 2)
	-- DialogueAnimateSmokeVertical(true, smoke01b, team, 2)
	-- DialogueAnimateSmokeVertical(true, smoke01c, team, 2)
	-- DialogueAnimateSmokeVertical(true, smoke02a, team, 1)
	-- DialogueAnimateSmokeVertical(true, smoke02b, team, 1)
	-- DialogueAnimateSmokeVertical(true, smoke02c, team, 1)
	
	-- for k,v in ipairs(smokeLeft) do
		-- DialogueAnimateSmokeHorizontal(true, v, 'left', team)
	-- end
	
	-- for k,v in ipairs(smokeRight) do
		-- DialogueAnimateSmokeHorizontal(true, v, 'right', team)
	-- end
	
	-- for k,v in ipairs(smokeLeftOff) do
		-- DialogueAnimateSmokeOff(true, v, 'left', team)
	-- end
	
	-- for k,v in ipairs(smokeRightOff) do
		-- DialogueAnimateSmokeOff(true, v, 'right', team)
	-- end
	
	-- for k,v in ipairs(rubbleOffGroup) do
		-- DialogueAnimateRubbleOff(true, v)
	-- end
end

local function DialogueAnimateOff (team)
	gameSPE.activeMessage = nil
	dialogueMessageStatus.dialogueMessageVis = false
	dialogueMessageStatus:Trigger(false)
	
	DialogueAnimateWindow(false, nil)
	DialogueAnimateCracks(false)
	DialogueAnimateGlow(false, 0)
	
	-- No Smoke or Rubble Effects Anymore
	--DialogueAnimateRubble(false)
	
	-- for k,v in ipairs(smokeVerical) do
		-- DialogueAnimateSmokeVertical(false, v, team, 1)
	-- end
	
	-- for k,v in ipairs(smokeLeft) do
		-- DialogueAnimateSmokeHorizontal(false, v, 'left', team)
	-- end
	
	-- for k,v in ipairs(smokeRight) do
		-- DialogueAnimateSmokeHorizontal(false, v, 'right', team)
	-- end
	
	-- for k,v in ipairs(smokeLeftOff) do
		-- DialogueAnimateSmokeOff(false, v, 'left', team)
	-- end
	
	-- for k,v in ipairs(smokeRightOff) do
		-- DialogueAnimateSmokeOff(false, v, 'right', team)
	-- end
	
	-- for k,v in ipairs(rubbleOffGroup) do
		-- DialogueAnimateRubbleOff(false, v)
	-- end
	
	interface:UICmd("StopSound(6)")
	Cvar.GetCvar('vid_postEffectPath'):Set('')
end

local function turnOn ()
	message:SetVisible(true)
end

local function turnOff ()
	gameSPE.activeMessage = nil
	dialogueMessageStatus.dialogueMessageVis = false
	dialogueMessageStatus:Trigger(false)
	
	message:SetVisible(false)
	
	interface:UICmd("StopSound(6)")
	Cvar.GetCvar('vid_postEffectPath'):Set('')
end

--[[
========================
Set Colors or Textures for Dialogue Message
========================
]]--
local function DialogueSetDark ()
	local useDarkColor = {0.81, 0.81, 0.81, 1}
				
	teamModel_BottomFrame:SetColor(unpack(useDarkColor))
	teamModel_TopFrame:SetColor(unpack(useDarkColor))
	teamModel_DetailTL:SetColor(unpack(useDarkColor))
	teamModel_DetailTR:SetColor(unpack(useDarkColor))
	teamModel_DetailB:SetColor(unpack(useDarkColor))
	teamModel_Icon:SetColor(unpack(useDarkColor))
	
	teamText_BaseC:SetColor(0.81, 0.81, 0.81, 0.5)
	teamText_BaseL:SetColor(0.81, 0.81, 0.81, 0.5)
	teamText_BaseR:SetColor(0.81, 0.81, 0.81, 0.5)
end

local function DialogueSetLight ()
	local useLightColor = {1, 1, 1, 1}
			
	teamModel_BottomFrame:SetColor(unpack(useLightColor))
	teamModel_TopFrame:SetColor(unpack(useLightColor))
	teamModel_DetailTL:SetColor(unpack(useLightColor))
	teamModel_DetailTR:SetColor(unpack(useLightColor))
	teamModel_DetailB:SetColor(unpack(useLightColor))
	teamModel_Icon:SetColor(unpack(useLightColor))
	
	teamText_BaseC:SetColor(1, 1, 1, 0.5)
	teamText_BaseL:SetColor(1, 1, 1, 0.5)
	teamText_BaseR:SetColor(1, 1, 1, 0.5)
end

local function DialogueSetNotAlly()
	local useRedTint = {1, 0.07, 0, 0.4}
			
	for k,v in ipairs(rubbleGroup) do
		v:SetColor(1.0, 0.9, 0.9, 1)
	end
	
	teamModel_GlowConstant:SetColor(unpack(useRedTint))
	teamModel_GlowFlicker:SetColor(1, 0.07, 0, 0.25)
	
	teamModel_TopDoor:SetTexture('/ui/game/dialogue/textures/model_doorsTop_enemy.tga')
	teamModel_BottomDoor:SetTexture('/ui/game/dialogue/textures/model_doorsBottom_enemy.tga')
	
	teamText_GlowC:SetColor(unpack(useRedTint))
	teamText_GlowL:SetColor(unpack(useRedTint))
	teamText_GlowR:SetColor(unpack(useRedTint))
end

local function DialogueSetAlly ()
	local useBlueTint = {0, 0.73, 1, 0.4}
			
	for k,v in ipairs(rubbleGroup) do
		v:SetColor(0.9, 0.9, 1, 1)
	end
	
	teamModel_Icon:SetVisible(false)
	
	teamModel_GlowConstant:SetColor(unpack(useBlueTint))
	teamModel_GlowFlicker:SetColor(0, 0.73, 1, 0.25)
	
	teamModel_TopDoor:SetTexture('/ui/game/dialogue/textures/model_doorsTop_ally.tga')
	teamModel_BottomDoor:SetTexture('/ui/game/dialogue/textures/model_doorsBottom_ally.tga')
	
	teamText_GlowC:SetColor(unpack(useBlueTint))
	teamText_GlowL:SetColor(unpack(useBlueTint))
	teamText_GlowR:SetColor(unpack(useBlueTint))
end

--[[
========================
Dialogue Message
This one animates down and animates ups
========================
]]--
local function dialogueShowMessage(messageInfo, value)	
	local fadeOutTime = 250
	local fadeInTime = 750
		
	if not messageInfo.darkerUI then
		messageInfo.darkerUI = true
	end
	
	if not messageInfo.team then
		messageInfo.team = 'ally'
	end
	
	if value and tonumber(value) then	
		if (tonumber(value) > 0) then
			messageInfo.showTime = tonumber(value)
		end
	end

	if not messageInfo.showTime or messageInfo.showTime <= 0 then
		messageInfo.showTime = 0
		messageInfo.pause = true
	end
	
	if messageInfo.darkerUI then
		if (messageInfo.darkerUI == true) then
			DialogueSetDark()
		else
			DialogueSetLight()
		end
	end

	if messageInfo.model and (interface:GetWidget(messageInfo.model)) then
		messageModel = interface:GetWidget(messageInfo.model)
		messageModelAnimation = messageInfo.anim
		
		for k,v in ipairs(messageModelGroup) do
			v:SetVisible(false)
		end
		
		effectThread = libThread.threadFunc(function()
			if (messageInfo.aniType == 'animatesFull' or messageInfo.aniType == 'animatesOn') then
				wait(750)
					messageModel:FadeIn(150)
				wait(100)
			else
				messageModel:SetVisible(true)
			end				
				
			if messageInfo.anim then
				messageModel:SetAnim(messageInfo.anim)
			end
			
			if (updateEvent) then
				updateEvent(true)
			end
			effectThread = nil
		end)
	end

	if messageInfo.title then
		messageTitle:SetText(Translate(messageInfo.title))
	end
	
	if messageInfo.team then
		teamModel_BottomFrame:SetTexture('/ui/game/dialogue/textures/model_'..messageInfo.team..'.tga')
		teamModel_TopFrame:SetTexture('/ui/game/dialogue/textures/model_frame_'..messageInfo.team..'.tga')
		teamModel_DetailTL:SetTexture('/ui/game/dialogue/textures/detail_'..messageInfo.team..'_tl.tga')
		teamModel_DetailTR:SetTexture('/ui/game/dialogue/textures/detail_'..messageInfo.team..'_tr.tga')
		teamModel_DetailB:SetTexture('/ui/game/dialogue/textures/detail_'..messageInfo.team..'_b.tga')
		
		if (messageInfo.aniType == 'animatesFull' or messageInfo.aniType == 'animatesOn') then
			if (messageInfo.team == 'boss') then
				DialogueAnimateBoss(true)
			else
				DialogueAnimateBoss(false)
			end
		else
			if (messageInfo.team == 'boss') then
				teamModel_Icon:SetVisible(true)
				teamModel_Icon:Scale('100%', '100%', 150)
				teamModel_Icon:Rotate(0, 150)
			else
				teamModel_Icon:SetVisible(false)
			end
		end
			
		if (messageInfo.team == 'boss' or messageInfo.team == 'enemy') then	
			DialogueSetNotAlly()
		else	
			DialogueSetAlly()
		end
	end

	if messageInfo.body then
		if (messageInfo.aniType == 'animatesFull' or messageInfo.aniType == 'animatesOn') then
			DialogueAnimateWindow(true, messageInfo.body)
		else
			libAnims.textPopulateFade(messageBody, 2500, Translate(messageInfo.body), 250)
		end
	end
	
	if (messageInfo.aniType == 'animatesFull' or messageInfo.aniType == 'animatesOn') then
		DialogueAnimateOn(messageInfo.team, (messageInfo.showTime - fadeOutTime + fadeInTime))
	else
		turnOn()
	end
	
	dialogueMessageStatus.dialogueMessageVis = true
	dialogueMessageStatus:Trigger(false)

	if messageInfo.darkenBG then
		messageBG:FadeIn(250)
	else
		messageBG:FadeOut(250)
	end

	if messageInfo.pause then
		tutorialPauseTrigger.hidePaused = true
		tutorialPauseTrigger:Trigger(true)
		Cmd("ServerPause")
		messageBG:SetNoClick(false)
	else
		messageBG:SetNoClick(true)
	end

	if messageInfo.showTime > 0 then		
		if (messageInfo.aniType == 'animatesFull' or messageInfo.aniType == 'animatesOff') then
			message:Sleep(( messageInfo.showTime - fadeOutTime + fadeInTime ), function() 
				DialogueAnimateOff(messageInfo.team) 
			end)
		else
			message:Sleep(messageInfo.showTime, function() 
				turnOff()
			end)
		end
	end

	if messageInfo.sound and string.len(messageInfo.sound) > 0 then
		if (playStreamThread) then
			playStreamThread:kill()
			playStreamThread = nil
		end
	
		interface:UICmd("StopSound(6)")
		interface:UICmd("StopSound(7)")
		interface:UICmd("StopSound(8)")
		
		playStreamThread = libThread.threadFunc(function()
			if (messageInfo.aniType == 'animatesFull' or messageInfo.aniType == 'animatesOn') then
				wait(750)
			end
			
			PlayStream(messageInfo.sound, 1, 6, 0)	-- [vol 0-1], [channel]

			playStreamThread = nil
		end)
	end

	if messageInfo.grayscale then
		Cvar.GetCvar('vid_postEffectPath'):Set('/core/post/grayscale.posteffect')
	else
		Cvar.GetCvar('vid_postEffectPath'):Set('')
	end
end

function dialogueRegisterMessage(messageInfo)
	local event = messageInfo.event
	if event and string.len(event) > 0 then
		local eventTrigger = UITrigger.GetTrigger(event)
		if eventTrigger then
			interface:RegisterWatch(event, function(widget, param, value)
				dialogueShowMessage(messageInfo, value)
				gameSPE.activeMessage = event
			end)
		else
			print('^960Error:^w Attempted to create a tutorial entry with nonexistent event ^069'..event..'^w.\n')
		end
	else
		print('^960Error:^w Attempted to create a tutorial entry with no event.\n')
	end
end

--[[
========================
Cinematic Fades
========================
]]--
local cinematicBlack			= interface:GetWidget('Cinematic_BlackOverlay')

cinematicBlack:RegisterWatch('cinematic_turnOn', function(widget)
	gameSPE.cinematicBlackOverlayVisible = true
	widget:SetVisible(true)
end)

cinematicBlack:RegisterWatch('cinematic_fadeBlackIn', function(widget)
	gameSPE.cinematicBlackOverlayVisible = true
	widget:FadeIn(500)
end)

cinematicBlack:RegisterWatch('cinematic_fadeBlackInSlow', function(widget)
	gameSPE.cinematicBlackOverlayVisible = true
	widget:FadeIn(4000)
end)

cinematicBlack:RegisterWatch('cinematic_fadeBlackOut', function(widget)
	gameSPE.cinematicBlackOverlayVisible = false
	widget:FadeOut(500)
end)

cinematicBlack:RegisterWatch('cinematic_fadeBlackOutSlow', function(widget)
	gameSPE.cinematicBlackOverlayVisible = false
	widget:FadeOut(3000)
end)

--[[
========================
Cinematic Bars
========================
]]--
local cinematic					= interface:GetWidget('Cinematic_Container')

cinematic:RegisterWatch('campaign_startCinematicOverlay', function(widget)
	gameSPE.cinematicOverlayVisible = true
	widget:FadeIn(500)
end)

cinematic:RegisterWatch('campaign_endCinematicOverlay', function(widget)
	gameSPE.cinematicOverlayVisible = false
	widget:FadeOut(1000)
end)

--[[
========================
Cinematic Dialogue
========================
]]--
local cinematicDialogue			= interface:GetWidget('Cinematic_Dialogue_Container')

cinematicDialogue:RegisterWatch('act1_startCinematicOverlay', function(widget)
	gameSPE.cinematicDialogueVisible = true
	widget:FadeIn(750)
end)

cinematicDialogue:RegisterWatch('act1_endCinematicOverlay', function(widget)
	gameSPE.cinematicDialogueVisible = false
	widget:FadeOut(250)
end)

--[[
========================
End Screen
========================
]]--
local cinematicEndGame			= interface:GetWidget('Cinematic_EndGame')		

cinematicEndGame:RegisterWatch('bastact1_endGame', function(widget)
	local isFirstTime = true
	
	if (mainUI) and (mainUI.savedLocally) and (mainUI.savedLocally.questsComplete) and (mainUI.savedLocally.questsComplete.spe1) then
		isFirstTime = false
	end
	
	startOriginsAnimations(widget, isFirstTime)
end)

--[[
========================
Reload
========================
]]--
function dialogueReinitialize(object)
	cinematic:Sleep(1, function()
		if not gameSPE.cinematicOverlayVisible then
			cinematic:SetVisible(false)
		end
	end)	
end