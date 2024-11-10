local interface = object

triggerMapObjectivesActSet	= LuaTrigger.GetTrigger('mapObjectivesActSet')

if not triggerMapObjectivesActSet then
	triggerMapObjectivesActSet = LuaTrigger.CreateCustomTrigger('mapObjectivesActSet', {
		{	name	= 'act1',				type	= 'boolean'	},
		{	name	= 'act2',				type	= 'boolean'	},
	})

	triggerMapObjectivesActSet.act1		= false
	triggerMapObjectivesActSet.act2		= false
end

--[[
========================
Local Variables
========================
]]--
local objectives						= interface:GetWidget('Objective_Container')
local objective_act1					= interface:GetWidget('Objective_Act1')

local objectives_popup					= interface:GetWidget('Objective_Popup_Container')
local objectives_popup_glow				= interface:GetWidget('Objective_Popup_Glow')
local objectives_popup_particles		= interface:GetWidget('Objective_Popup_Particles')
local objectives_popup_stoneTop			= interface:GetWidget('Objective_Popup_StoneTop')
local objectives_popup_bottomLine		= interface:GetWidget('Objective_Popup_BottomLine')
local objectives_popup_topLine			= interface:GetWidget('Objective_Popup_TopLine')
local objectives_popup_text				= interface:GetWidget('Objectives_Popup_Text')
local objectives_popup_stoneBottom		= interface:GetWidget('Objective_Popup_StoneBottom')
local objectives_popup_title			= interface:GetWidget('Objectives_Popup_Title')
local objectives_popup_description		= interface:GetWidget('Objectives_Popup_Description')
local objectives_popup_runeParticles	= interface:GetWidget('Objective_Popup_RuneParticles')
local objectives_popup_runeGlow			= interface:GetWidget('Objectives_Popup_RuneGlow')
local objectives_popup_runeGlowFades	= interface:GetWidget('Objectives_Popup_RuneGlowFades')
local objectives_popup_rune				= interface:GetWidget('Objectives_Popup_Rune')
local objectives_popup_runeBorder		= interface:GetWidget('Objectives_Popup_RuneBorder')

--[[
========================
Core Functionality
========================
]]--
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

objectives:RegisterWatchLua('mapObjectivesActSet', function(widget, trigger)
	if (trigger.act1) or (trigger.act2) then
		objective_act1:SetVisible(1)
	else
		objective_act1:SetVisible(0)
	end				
end, false, nil, 'act1')

--[[
========================
Animations
========================
]]--
local function ResetUnlockWindow (object, status, icon, text)
	--Reset
	objectives_popup_rune:SetTexture(icon)
	
	if (object) then
		object:SetTexture(icon)	
	end
	
	if (status == 'unlocked') then
		objectives_popup_title:SetText(Translate('objective_unlocked'))
	elseif (status == 'complete') then
		objectives_popup_title:SetText(Translate('objective_complete'))
	elseif (status == 'ability') then
		objectives_popup_title:SetText(Translate('ability_unlocked'))
	end
	
	objectives_popup_rune:SetVisible(0)
	objectives_popup_rune:SetHeight('0%')
	objectives_popup_rune:SetWidth('0%')
	
	objectives_popup_runeBorder:SetVisible(0)
	objectives_popup_runeBorder:SetHeight('0%')
	objectives_popup_runeBorder:SetWidth('0%')
	
	objectives_popup_runeGlow:SetVisible(0)	
	objectives_popup_runeGlow:SetHeight('0%')
	objectives_popup_runeGlow:SetWidth('0%')
	
	objectives_popup_runeGlowFades:SetVisible(0)	
	objectives_popup_runeGlowFades:SetHeight('0%')
	objectives_popup_runeGlowFades:SetWidth('0%')
	
	objectives_popup_glow:SetVisible(0)
	objectives_popup_glow:SetHeight('25%')
	objectives_popup_glow:SetWidth('60%')
	
	objectives_popup_particles:SetVisible(0)
	objectives_popup_particles:SetHeight('25%')
	objectives_popup_particles:SetWidth('60%')
	
	objectives_popup_stoneTop:SetVisible(0)
	objectives_popup_stoneBottom:SetVisible(0)
	
	objectives_popup_runeParticles:SetVisible(0)
	objectives_popup_runeParticles:SetHeight('0%')
	objectives_popup_runeParticles:SetWidth('0%')
	
	objectives_popup_bottomLine:SetVisible(0)
	objectives_popup_bottomLine:SetX('0h')
	objectives_popup_topLine:SetVisible(0)
	objectives_popup_topLine:SetX('0h')	
	
	objectives_popup_title:SetVisible(0)
	objectives_popup_description:SetVisible(0)
	objectives_popup_description:SetText(Translate(text))
	
	objectives_popup:SetVisible(1)
end

local function ResetMouseOver(isUnlocked, particles, glow, titleObject, bodyObject, color, title, body)
	-- Reset
	particles:SetColor(color)
	particles:SetVisible(0)
	particles:SetHeight('50%')
	particles:SetWidth('50%')
	glow:SetColor(color)
	glow:SetVisible(0)
	glow:SetWidth('0%')
	glow:SetHeight('0%')
	
	if (isUnlocked) then
		titleObject:SetText(Translate(title))
		bodyObject:SetText(Translate(body))
	end
end

local function AnimateGlow(isActive, delay)
	isActive = isActive or false
		
	if (isActive) then
		local lastStep  = 0
		local stopTime = GetTime() + delay
		
		objectives_popup_runeGlowFades:SetVisible(true)		
		objectives_popup_runeGlowFades:UnregisterWatchLua('System')
		objectives_popup_runeGlowFades:RegisterWatchLua('System', function(widget, trigger)
			if (trigger.hostTime >= stopTime) then
				lastStep = 0
				return
			else
				local timer = trigger.hostTime % 5000
				
				if (timer <= 150 and lastStep ~= 1) then
					widget:FadeOut(150)
					lastStep = 1
				elseif (timer <= 300 and timer > 150 and lastStep ~= 2) then
					widget:FadeIn(150)
					lastStep = 2			
				elseif (timer <= 350 and timer > 300 and lastStep ~= 3) then
					widget:FadeOut(50)
					lastStep = 3
				elseif (timer <= 400 and timer > 350 and lastStep ~= 4) then
					widget:FadeIn(50)
					lastStep = 4
				end
			end
		end, false, nil, 'hostTime')
	else
		objectives_popup_runeGlowFades:FadeIn(50)
	end
end

local AnimateWindowThread
local function AnimateUnlockWindow(object, status, icon, text)
	if (AnimateWindowThread) then
		AnimateWindowThread:kill()
		AnimateWindowThread = nil
	end

	AnimateWindowThread = libThread.threadFunc(function()
			--Reset
			ResetUnlockWindow(object, status, icon, text)
		wait(50)
			objectives_popup_runeParticles:Scale('0%', '0%', 50)
			objectives_popup_particles:Scale('25%', '60%', 50)
			objectives_popup_glow:Scale('25%', '60%', 50)
		wait(50)
		
			--Start Animating In
			objectives_popup_text:FadeIn(300)
			objectives_popup_glow:FadeIn(300)
			objectives_popup_glow:Scale('55%', '120%', 3000)
			objectives_popup_particles:FadeIn(300)
			objectives_popup_particles:Scale('55%', '120%', 3000)
			objectives_popup_stoneTop:FadeIn(500)
			objectives_popup_stoneBottom:FadeIn(500)
		wait(150)
		
			if (status == 'ability') then
				objectives_popup_rune:Scale('55%', '55@', 500)
				objectives_popup_runeBorder:Scale('70%', '70@', 500)
				objectives_popup_runeBorder:FadeIn(500)
			else
				objectives_popup_rune:Scale('80%', '80@', 500)
			end
			
			objectives_popup_rune:FadeIn(500)
			objectives_popup_runeParticles:FadeIn(500)
			objectives_popup_runeParticles:Scale('55%', '120%', 2800)
			objectives_popup_title:FadeIn(500)
			objectives_popup_description:FadeIn(500)
		wait(150)
			objectives_popup_runeGlow:Scale('100%', '100%', 100)
			objectives_popup_runeGlow:FadeIn(500)
			objectives_popup_runeGlowFades:Scale('100%', '100%', 100)
			objectives_popup_runeGlowFades:FadeIn(500)
		wait(500)
		
			--Idle State Stuff
			AnimateGlow(true, 1600)
		wait(500)
			objectives_popup_topLine:FadeIn(200)
			objectives_popup_topLine:SlideX('30h',400)
		wait(200)
			objectives_popup_topLine:FadeOut(200)
			objectives_popup_bottomLine:FadeIn(200)
			objectives_popup_bottomLine:SlideX('30h',400)
		wait(200)
		
			--Start Animating Off
			objectives_popup_particles:FadeOut(800)
			objectives_popup_runeParticles:FadeOut(800)
			objectives_popup_bottomLine:FadeOut(200)
		wait(700)
			objectives_popup_glow:FadeOut(300)
			objectives_popup_stoneTop:FadeOut(300)
			objectives_popup_stoneBottom:FadeOut(300)
			objectives_popup_rune:FadeOut(50)
			objectives_popup_runeBorder:FadeOut(50)
			objectives_popup_text:FadeOut(300)
			objectives_popup_title:FadeOut(50)
			objectives_popup_description:FadeOut(50)
			objectives_popup_runeGlowFades:FadeOut(50)
			objectives_popup_runeGlow:FadeOut(50)
		wait(300)
			objectives_popup:SetVisible(0)	
			ResetUnlockWindow(object, status, icon, text)
		
		AnimateWindowThread = nil
	end)
end

local AnimateUnlockThread
local function AnimateUnlock(object, number)
	if (AnimateUnlockThread) then
		AnimateUnlockThread:kill()
		AnimateUnlockThread = nil
	end
	
	local clip						= interface:GetWidget('Objective_'..number..'_Clip')
	local rClip						= interface:GetWidget('Objective_'..number..'_ReverseClip')
	local glow						= interface:GetWidget('Objective_'..number..'_Glow')
	local line						= interface:GetWidget('Objective_'..number..'_UnlockLine')
	local activeGlow				= interface:GetWidget('Objective_'..number..'_UnlockGlow')
	local activeGlow2				= interface:GetWidget('Objective_'..number..'_UnlockGlow2')
	
	AnimateUnlockThread = libThread.threadFunc(function()
			local totalTime = 1500
			glow:FadeIn(totalTime)
			glow:Rotate(120, totalTime*2)
			glow:Scale('180%', '180%', totalTime*2)		
			clip:Scale('110%', '110%', totalTime)
			rClip:Scale('110%', '0%', totalTime-(totalTime/8))
			line:FadeIn(totalTime/4)
			line:SlideY('40%', totalTime)
			activeGlow:FadeIn(totalTime/3)
			activeGlow:SlideY('46%', totalTime/2)
			activeGlow:Scale('200%', '0%', totalTime/2)
		wait(totalTime/2)
			object:FadeOut(totalTime/2)			
			activeGlow:SetVisible(0)
			activeGlow2:SetVisible(1)
			activeGlow2:SlideY('35%', totalTime/2)
			activeGlow2:Scale('100%', '100%', totalTime/2)
		wait(totalTime/4)
			activeGlow2:FadeOut(totalTime/4)
			line:FadeOut(totalTime/4)
		wait(200)
			glow:FadeOut(totalTime*2)
			glow:Scale('100%', '100%', totalTime*2)
			
		AnimateUnlockThread = nil
	end)
end

-- interface:GetWidget('Objective_03'):SetCallback('onclick', function(widget)
	-- AnimateUnlockWindow(false, 'complete', '/ui/game/map_objectives/textures/objective_key_complete.tga', 'Blind Justice')
-- end)

local AnimateMouseOverThread
local function AnimateMouseOver(isActive, isUnlocked, object, number, color, title, body)
	if (AnimateMouseOverThread) then
		AnimateMouseOverThread:kill()
		AnimateMouseOverThread = nil
	end
	
	local scalableObject			= interface:GetWidget('Objective_'..number..'_Scalable')
	local hoverObject				= interface:GetWidget('Objective_'..number..'_Hover')
	local titleObject				= interface:GetWidget('Objective_'..number..'_Title')
	local bodyObject				= interface:GetWidget('Objective_'..number..'_Description')
	local particles					= interface:GetWidget('Objective_'..number..'_Particles')
	local glow						= interface:GetWidget('Objective_'..number..'_Glow')
	
	if (isActive) then
		AnimateMouseOverThread = libThread.threadFunc(function()
			while (isActive) do
					-- Reset
					ResetMouseOver(isUnlocked, particles, glow, titleObject, bodyObject, color, title, body)
				wait(100)
					particles:Scale('50%', '50%', 200)
					glow:Scale('0%', '0%', 200)
				wait(200)
					hoverObject:FadeIn(500)					
					particles:FadeIn(1000)
					particles:Scale('250%', '250%', 3000)
					glow:FadeIn(1000)
					glow:Scale('180%', '180%', 3000)
				wait(1500)
					particles:FadeOut(1000)
					glow:FadeOut(1000)
				wait(1000)
			end			
				
			AnimateMouseOverThread = nil
		end)
	else
		AnimateMouseOverThread = libThread.threadFunc(function()
			hoverObject:FadeOut(300)
			particles:SetColor(color)
			glow:SetColor(color)
			particles:FadeOut(500)
			glow:FadeOut(500)
			glow:Scale('150%', '150%', 500)
			
			ResetMouseOver(isUnlocked, particles, glow, titleObject, bodyObject, color, title, body)
			
			wait(200)
			
			AnimateMouseOverThread = nil
		end)
	end
	
end

--[[
========================
Objective Messages
========================
]]--
function speRegisterObjective(objectiveInfo)
	local objectives
	local objectivesName
	local objectivesUnlocked
	local objectivesColor = '#453d3d'
	
	if objectiveInfo.objectives then		
		objectives				= interface:GetWidget(objectiveInfo.objectives)
		objectivesName 			= objectiveInfo.objectives
	end
	
	if objectiveInfo.number then		
		objectivesUnlocked		= interface:GetWidget('Objective_'..objectiveInfo.number..'_Unlocked')
	end

	if not (gameSPE.activeObjectives[objectivesName] and type(gameSPE.activeObjectives[objectivesName]) == 'table') then
		gameSPE.activeObjectives[objectivesName] = {}
	end
	
	if not (gameSPE.objectiveDisplayOrder[objectivesName] and type(gameSPE.objectiveDisplayOrder[objectivesName]) == 'table') then
		gameSPE.objectiveDisplayOrder[objectivesName] = {}
	end

	objectives:RegisterWatch(objectiveInfo.showEvent, function(widget) -- , ...
		objectiveInfo.index				= gameSPE.objectiveIndex
		objectiveInfo.unlocked 			= objectiveInfo.unlocked or false
		objectiveInfo.complete 			= objectiveInfo.complete or false
		objectiveInfo.icon				= objectiveInfo.icon or ''
		
		objectivesUnlocked:SetTexture('/ui/game/map_objectives/textures/objective_'..objectiveInfo.icon..'_progress.tga')
		
		if (objectiveInfo.complete) then
			objectivesColor = '#da3f1b'
			AnimateUnlockWindow(objectivesUnlocked, 'complete', '/ui/game/map_objectives/textures/objective_'..objectiveInfo.icon..'_complete.tga', objectiveInfo.title)
		elseif (objectiveInfo.unlocked) then
			objectivesColor = '#e1dddd'
		end
		
		objectiveInfo.orderIndex = (#gameSPE.objectiveDisplayOrder[objectivesName]) + 1

		objectives:SetVisible(true)

		if gameSPE.initWidgetSoundEnabled then
			PlaySound('/ui/sounds/sfx_quest.wav', 0.7, 9)
		end

		gameSPE.activeObjectives[objectivesName][objectiveInfo.showEvent] = true
		table.insert(gameSPE.objectiveDisplayOrder[objectivesName], objectiveInfo.orderIndex, objectiveInfo)
		
		objectives:SetCallback('onmouseover',function(widget)
			if (objectiveInfo.unlocked) then
				AnimateMouseOver(true, true, widget, objectiveInfo.number, objectivesColor, objectiveInfo.title, objectiveInfo.body)
			else
				AnimateMouseOver(true, false, widget, objectiveInfo.number, objectivesColor, objectiveInfo.title, objectiveInfo.body)
			end
		end)

		objectives:SetCallback('onmouseout',function(widget)
			if (objectiveInfo.unlocked) then
				AnimateMouseOver(false, true, widget, objectiveInfo.number, objectivesColor, objectiveInfo.title, objectiveInfo.body)
			else
				AnimateMouseOver(false, false, widget, objectiveInfo.number, objectivesColor, objectiveInfo.title, objectiveInfo.body)
			end
		end)
		
		objectivesUnlocked:SetCallback('onmouseover',function(widget)
			AnimateMouseOver(true, true, widget, objectiveInfo.number, objectivesColor, objectiveInfo.title, objectiveInfo.body)
		end)
		
		objectivesUnlocked:SetCallback('onmouseout',function(widget)			
			AnimateMouseOver(false, true, widget, objectiveInfo.number, objectivesColor, objectiveInfo.title, objectiveInfo.body)
		end)
		
		objectives:RegisterWatch(objectiveInfo.unlockEvent, function(widget) -- , ...
			objectivesColor = '#e1dddd'
			
			AnimateUnlock(objectives, objectiveInfo.number)
			AnimateUnlockWindow(false, 'unlocked', '/ui/game/map_objectives/textures/objective_'..objectiveInfo.icon..'_progress.tga', objectiveInfo.title)
			objectiveInfo.unlocked = true
		end)

		objectives:RegisterWatch(objectiveInfo.completionEvent, function(widget) -- , ...
			objectivesColor = '#da3f1b'
			
			if (gameSPE.activeObjectives[objectivesName][objectiveInfo.showEvent]) then
				AnimateUnlockWindow(objectivesUnlocked, 'complete', '/ui/game/map_objectives/textures/objective_'..objectiveInfo.icon..'_complete.tga', objectiveInfo.title)
				objectiveInfo.unlocked = true
				objectiveInfo.complete = true
			end
		end)

		gameSPE.objectiveIndex = gameSPE.objectiveIndex + 1
	end)
end

--[[
========================
Ability Unlock Messages
========================
]]--
function speRegisterAbilityUnlock(abilityInfo)		
	objectives_popup:RegisterWatch(abilityInfo.showEvent, function(widget) -- uses the objective popup as a base
		if (abilityInfo.icon) and (abilityInfo.title) then
			AnimateUnlockWindow(false, 'ability', abilityInfo.icon, abilityInfo.title)
		end
	end)
end

--[[
========================
Fade In/Out
========================
]]--
objectives:RegisterWatch('objectives_turnOn', function(widget)
	gameSPE.objectiveOverlayVisible = true
	widget:FadeIn(500)
end)

objectives:RegisterWatch('objectives_turnOff', function(widget)
	gameSPE.objectiveOverlayVisible = false
	widget:FadeOut(500)
end)