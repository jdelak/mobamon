--[[
========================
Local Variables
========================
]]--
local message				= object:GetWidget('Dialogue_Container')
local messageModelHolder	= object:GetWidget('Dialogue_Message_Model')
local messageTextHolder		= object:GetWidget('Dialogue_Message_Text')
local messageTextVisible	= object:GetWidget('Dialogue_Message_Text_Holder')
local messageBody			= object:GetWidget('Dialogue_Message_Text_Body')

local teamModel_GlowFlicker	= object:GetWidget('Dialogue_Message_Model_GlowFlicker')
local teamModel_TopDoor		= object:GetWidget('Dialogue_Message_Model_TopDoor')
local teamModel_BottomDoor	= object:GetWidget('Dialogue_Message_Model_BottomDoor')
local teamModel_Icon		= object:GetWidget('Dialogue_Message_Model_Icon')

local crack01				= object:GetWidget('Dialogue_Message_Text_Crack01')
local crack02				= object:GetWidget('Dialogue_Message_Text_Crack02')
local crack03				= object:GetWidget('Dialogue_Message_Text_Crack03')
local crack04				= object:GetWidget('Dialogue_Message_Text_Crack04')
local crack05				= object:GetWidget('Dialogue_Message_Text_Crack05')
local crack06				= object:GetWidget('Dialogue_Message_Text_Crack06')
local crack07				= object:GetWidget('Dialogue_Message_Text_Crack07')

local rubble01				= object:GetWidget('Dialogue_Message_Text_Rubble01')
local rubble02				= object:GetWidget('Dialogue_Message_Text_Rubble02')

local rubbleGroup			= object:GetGroup('Dialogue_Message_Text_Rubbles')
local rubbleOffGroup		= object:GetGroup('Dialogue_Message_Text_Rubble_Off')

local act2					= object:GetWidget('Cinematic_EndGame_act2')
local comingsoon			= object:GetWidget('Cinematic_EndGame_comingsoon')
local questHolder			= object:GetWidget('Cinematic_EndGame_questHolder')
local reward01				= object:GetWidget('Cinematic_EndGame_quest_01')
local reward01MP1			= object:GetWidget('Cinematic_EndGame_quest_01_MP1')
local reward01MP2			= object:GetWidget('Cinematic_EndGame_quest_01_MP2')
local reward02				= object:GetWidget('Cinematic_EndGame_quest_02')
local reward02MP1			= object:GetWidget('Cinematic_EndGame_quest_02_MP1')
local reward02MP2			= object:GetWidget('Cinematic_EndGame_quest_02_MP2')
local reward03				= object:GetWidget('Cinematic_EndGame_quest_03')
local reward03MP1			= object:GetWidget('Cinematic_EndGame_quest_03_MP1')
local reward03MP2			= object:GetWidget('Cinematic_EndGame_quest_03_MP2')
local title					= object:GetWidget('Cinematic_EndGame_questTitle')
local complete				= object:GetWidget('Cinematic_EndGame_questComplete')
local largeText				= object:GetGroup('origin_resourceLG')
local smallText				= object:GetGroup('origin_resourceSM')
local alreadyCompelted		= object:GetGroup('origin_alreadyCompleted')
local modelPanels			= object:GetGroup('endgame_modelPanel')


--[[
========================
Ranomized Smoke Colors Based on Team Color
========================
]]--
function DialogueRandomColor(widget, team, randomizedColor)
	if (team == 'boss' or team == 'enemy') then
		if (randomizedColor == 1) then
			widget:SetColor(0.4, 0.31, 0.24, 0.1)
		elseif (randomizedColor == 2) then
			widget:SetColor(0.4, 0.28, 0.24, 0.2)
		else
			widget:SetColor(0.34, 0.2, 0.16, 0.1)
		end
	else
		if (randomizedColor == 1) then
			widget:SetColor(0.4, 0.31, 0.24, 0.1)
		elseif (randomizedColor == 2) then
			widget:SetColor(0.4, 0.34, 0.24, 0.2)
		else
			widget:SetColor(0.4, 0.31, 0.17, 0.1)
		end
	end
end

--[[
========================
Dialogue Message Animations
========================
]]--
local DialogueAnimateWindowThread
function DialogueAnimateWindow(isActive, text)
	if (DialogueAnimateWindowThread) then
		DialogueAnimateWindowThread:kill()
		DialogueAnimateWindowThread = nil
	end
	
	if (isActive) then
		DialogueAnimateWindowThread = libThread.threadFunc(function()
			-- Reset
			messageTextVisible:SetVisible(false)
			messageTextHolder:SetVisible(false)
			message:SetVisible(false)
			message:SlideY('-30h', 10)
			messageTextHolder:Scale('0%', '90%', 10)
			
			message:FadeIn(200)
			message:SlideY('2.25h', 250)
			
			wait(250)
				message:SlideY('1h', 50)
			wait(50)
				message:SlideY('2.25h', 50)
			wait(50)
				messageTextHolder:SetVisible(true)
				messageTextHolder:Scale('78%', '90%', 100)
			wait(100)
				messageTextHolder:Scale('76%', '90%', 50)
			wait(50)
				messageTextHolder:Scale('78%', '90%', 50)
			wait(200)
				teamModel_TopDoor:Scale('100%', '0%', 200)
				teamModel_BottomDoor:Scale('100%', '0%', 200)
			wait(50)
				libAnims.textPopulateFade(messageBody, 2500, Translate(text), 250)
				messageTextVisible:SetVisible(true)

			DialogueAnimateWindowThread = nil
		end)
	else
		DialogueAnimateWindowThread = libThread.threadFunc(function()
			messageTextVisible:FadeOut(50)
			teamModel_TopDoor:Scale('100%', '100%', 150)
			teamModel_BottomDoor:Scale('100%', '100%', 150)
			
			wait(50)
				messageTextHolder:Scale('0%', '90%', 50)		
			wait(50)
				messageTextHolder:SetVisible(false)
				message:FadeOut(100)
				message:SlideY('-30h', 150)

			DialogueAnimateWindowThread = nil
		end)
	end
end

local DialogueAnimateCracksThread
function DialogueAnimateCracks(isActive)
	if (DialogueAnimateCracksThread) then
		DialogueAnimateCracksThread:kill()
		DialogueAnimateCracksThread = nil
	end
	
	if (isActive) then
		DialogueAnimateCracksThread = libThread.threadFunc(function()
			-- Reset
			crack01:SetVisible(false)
			crack02:SetVisible(false)
			crack03:SetVisible(false)
			crack04:SetVisible(false)
			crack05:SetVisible(false)
			crack06:SetVisible(false)
			crack07:SetVisible(false)
			crack01:Scale('0h', '0h', 10)
			crack02:Scale('0h', '0h', 10)
			crack03:Scale('0h', '0h', 10)
			crack04:Scale('0h', '0h', 10)
			crack05:Scale('0h', '0h', 10)
			crack06:Scale('0h', '0h', 10)
			crack07:Scale('0h', '0h', 10)
			
			wait(500)
				crack01:FadeIn(30)
				crack02:FadeIn(30)	
				crack01:Scale('5h', '2.5h', 100)
				crack02:Scale('6h', '5h', 100)
			
			wait(30)
				crack03:FadeIn(20)
				crack03:Scale('1.5h', '2h', 70)
			
			wait(40)
				crack04:FadeIn(10)
				crack05:FadeIn(10)
				crack07:FadeIn(10)
				crack06:FadeIn(10)
				crack04:Scale('2.5h', '2h', 30)
				crack05:Scale('2.5h', '2h', 30)
				crack07:Scale('2.5h', '2h', 30)
				crack06:Scale('1.5h', '1.3h', 30)

			DialogueAnimateCracksThread = nil
		end)
	else
		crack01:SetVisible(false)
		crack02:SetVisible(false)
		crack03:SetVisible(false)
		crack04:SetVisible(false)
		crack05:SetVisible(false)
		crack06:SetVisible(false)
		crack07:SetVisible(false)
		crack01:Scale('0h', '0h', 50)
		crack02:Scale('0h', '0h', 50)
		crack03:Scale('0h', '0h', 50)
		crack04:Scale('0h', '0h', 50)
		crack05:Scale('0h', '0h', 50)
		crack06:Scale('0h', '0h', 50)
		crack07:Scale('0h', '0h', 50)
	end
end

local DialogueAnimateRubbleThread
function DialogueAnimateRubble(isActive)
	if (DialogueAnimateRubbleThread) then
		DialogueAnimateRubbleThread:kill()
		DialogueAnimateRubbleThread = nil
	end
	
	if (isActive) then
		DialogueAnimateRubbleThread = libThread.threadFunc(function()
			-- Reset
			for k,v in ipairs(rubbleGroup) do
				v:SetVisible(false)
				v:Scale('0h', '0h', 10)
				v:SetY('0h')
				v:SetX('0h')
			end
			
			wait(450)
				rubble01:FadeIn(20)
				rubble01:SlideY('2h', 100)
				rubble01:Scale('5h', '5h', 100)				
			wait(100)
				rubble02:FadeIn(20)
				rubble02:SlideY('2h', 100)
				rubble02:Scale('3h', '3h', 100)
				
				rubble01:FadeOut(400)
				rubble01:SlideY('10h', 400)
				rubble01:SlideX('1h', 400)
				rubble01:Scale('2h', '2h', 400)
			wait(100)
				rubble02:FadeOut(400)
				rubble02:SlideY('10h', 400)
				rubble02:SlideX('2h', 400)
				rubble02:Scale('1h', '1h', 400)
	
			DialogueAnimateRubbleThread = nil
		end)
	else
		for k,v in ipairs(rubbleGroup) do
			v:SetVisible(false)
			v:Scale('0h', '0h', 20)
			v:SetY('0h')
			v:SetX('0h')
		end
	end
end

local DialogueAnimateRubbleOffThread
function DialogueAnimateRubbleOff(isActive, widget)
	if (DialogueAnimateRubbleOffThread) then
		DialogueAnimateRubbleOffThread:kill()
		DialogueAnimateRubbleOffThread = nil
	end
	
	if (isActive) then
		DialogueAnimateRubbleOffThread = libThread.threadFunc(function()	
			local startUpTime 	= math.random(0, 50)
			local fadeOut 		= math.random(300, 500)
			local newY 			= math.random(8, 12)
			
			widget:SetVisible(false)
			widget:Scale('0h', '0h', 20)
			widget:SetY('0h')
			widget:SetX('0h')
			
			wait(startUpTime)
				widget:FadeIn(20)
				widget:SlideY('2h', 100)
				widget:Scale('5h', '5h', 100)				
			wait(100)				
				widget:FadeOut(fadeOut)
				widget:SlideY(newY..'h', fadeOut)
				widget:SlideX('1h', fadeOut)
				widget:Scale('2h', '2h', fadeOut)

			DialogueAnimateRubbleOffThread = nil
		end)
	else
		DialogueAnimateRubbleOffThread = libThread.threadFunc(function()	
			local startUpTime 	= math.random(10, 150)
			local fadeOut 		= math.random(300, 500)
			local startX 		= math.random(0, 8) - 4
			local newY 			= math.random(8, 12)
			
			widget:SetVisible(false)
			widget:Scale('0h', '0h', 20)
			widget:SetY('0h')
			widget:SetX(startX..'h')
			
			wait(startUpTime)
				widget:FadeIn(20)
				widget:SlideY('2h', 100)
				widget:Scale('5h', '5h', 100)				
			wait(100)				
				widget:FadeOut(fadeOut)
				widget:SlideY(newY..'h', fadeOut)
				widget:SlideX('1h', fadeOut)
				widget:Scale('2h', '2h', fadeOut)

			DialogueAnimateRubbleOffThread = nil
		end)
	end
end

local DialogueAnimateSmokeHorizontalThread
function DialogueAnimateSmokeHorizontal(isActive, widget, direction, team)
	if (DialogueAnimateSmokeHorizontalThread) then
		DialogueAnimateSmokeHorizontalThread:kill()
		DialogueAnimateSmokeHorizontalThread = nil
	end
	
	if (isActive) then
		DialogueAnimateSmokeHorizontalThread = libThread.threadFunc(function()
			local startUpTime 	= math.random(100, 250)
			local startColor 	= math.random(1, 3)
			local startX 		= math.random(0, 2) - 1
			local startR 		= math.random(0, 20) - 10
			local newR 			= 0
			local newX 			= math.random(2, 5)
			local newY 			= -(math.random(2, 5))
			local newS			= math.random(15, 20)
			local fadeOut 		= math.random(2500, 3000)
			
			-- Reset
			widget:SetVisible(false)
			widget:Scale('8h', '8h', 10)
			widget:SetY('0h')
			
			-- If the direction is to the left, reverse newX
			if (direction == 'left') then
				newX = -newX
			end
			
			-- Randomizing spinning direction
			if (math.random(0, 1) == 1) then
				newR = startR
			else
				newR = -startR
			end

			-- Randomizing Color
			RandomColor(widget, team, startColor)
			
			widget:SetX(startX..'h')
			widget:Rotate(startR, 10)
		
			wait(startUpTime)
				widget:FadeIn(20)
				widget:Scale(newS..'h', newS..'h', 4000)
				widget:Rotate(newR, fadeOut)
				widget:SlideX(newX..'h', fadeOut)
				widget:SlideY(newY..'h', fadeOut)
			wait(100)
				widget:FadeOut(fadeOut)

			DialogueAnimateSmokeHorizontalThread = nil
		end)
	else		
		widget:SetVisible(false)
		widget:Scale('8h', '8h', 10)
		widget:SetY('0h')
	end
end

local DialogueAnimateSmokeVerticalThread
function DialogueAnimateSmokeVertical(isActive, widget, team, size)
	if (DialogueAnimateSmokeVerticalThread) then
		DialogueAnimateSmokeVerticalThread:kill()
		DialogueAnimateSmokeVerticalThread = nil
	end
	
	if (isActive) then
		DialogueAnimateSmokeVerticalThread = libThread.threadFunc(function()
			local startUpTime 	= math.random(450, 550)
			local startColor 	= math.random(1, 3)
			--local startX 		= math.random(0, 3)
			local startX 		= 2
			local startY 		= math.random(0, 2) - 1
			local startR 		= math.random(0, 40) - 20
			local startS		= math.random(2, 4) * size
			local newS			= math.random(15, 25)
			local newR 			= 0
			local newY 			= -(math.random(2, 5))	
			local fadeOut 		= math.random(1500, 3500)	
			
			-- Reset
			widget:SetVisible(false)
			
			-- Randomizing spinning direction
			if (math.random(0, 1) == 1) then
				newR = startR
			else
				newR = -startR
			end

			-- Randomizing Color
			RandomColor(widget, team, startColor)
			
			widget:Scale(startS..'h', startS..'h', 10)
			widget:SetX(startX..'h')
			widget:SetY(startY..'h')
			widget:Rotate(startR, 10)
		
			wait(startUpTime)
				widget:FadeIn(20)
				widget:Scale(newS..'h', newS..'h', 4000)
				widget:Rotate(newR, fadeOut)
				widget:SlideY(newY..'h', fadeOut)
			wait(100)
				widget:FadeOut(fadeOut)

			DialogueAnimateSmokeVerticalThread = nil
		end)
	else		
		widget:SetVisible(false)
	end
end

local DialogueAnimateSmokeOffThread
function DialogueAnimateSmokeOff(isActive, widget, direction, team)
	if (DialogueAnimateSmokeOffThread) then
		DialogueAnimateSmokeOffThread:kill()
		DialogueAnimateSmokeOffThread = nil
	end
	
	if (isActive) then
		DialogueAnimateSmokeOffThread = libThread.threadFunc(function()			
			widget:SetVisible(false)
			widget:Scale('8h', '8h', 10)
			widget:SetY('0h')
			
			DialogueAnimateSmokeOffThread = nil
		end)
	else
		DialogueAnimateSmokeOffThread = libThread.threadFunc(function()
			local startUpTime 	= math.random(50, 150)
			local startColor 	= math.random(1, 3)
			local startY 		= math.random(0, 3)
			local startX 		= math.random(0, 4) - 2
			local startR 		= math.random(0, 20) - 10
			local newR 			= 0
			local newX 			= math.random(2, 5)
			local newY 			= math.random(2, 5)
			local newS			= math.random(15, 20)
			local fadeOut 		= math.random(2500, 3000)
			
			-- If the direction is to the left, reverse newX
			if (direction == 'left') then
				newX = -newX
			end
			
			-- Randomizing spinning direction
			if (math.random(0, 1) == 1) then
				newR = startR
			else
				newR = -startR
			end

			-- Randomizing Color
			RandomColor(widget, team, startColor)
			
			widget:SetX(startX..'h')
			widget:SetY(startY..'h')
			widget:Rotate(startR, 10)
		
			wait(startUpTime)
				widget:FadeIn(20)
				widget:Scale(newS..'h', newS..'h', 4000)
				widget:Rotate(newR, fadeOut)
				widget:SlideX(newX..'h', fadeOut)
				widget:SlideY(newY..'h', fadeOut)
			wait(100)
				widget:FadeOut(fadeOut)

			DialogueAnimateSmokeOffThread = nil
		end)
	end
end

local DialogueAnimateBossThread
function DialogueAnimateBoss(isActive)
	if (DialogueAnimateBossThread) then
		DialogueAnimateBossThread:kill()
		DialogueAnimateBossThread = nil
	end
	
	if (isActive) then
		DialogueAnimateBossThread = libThread.threadFunc(function()
			-- Reset
			teamModel_Icon:SetVisible(false)
			teamModel_Icon:Scale('300%', '300%', 10)
			teamModel_Icon:Rotate(100, 10)
			
			wait(300)
				teamModel_Icon:FadeIn(150)
				teamModel_Icon:Scale('100%', '100%', 150)
				teamModel_Icon:Rotate(0, 150)

			DialogueAnimateBossThread = nil
		end)
	else
		teamModel_Icon:SetVisible(false)
		teamModel_Icon:Scale('300%', '300%', 50)
		teamModel_Icon:Rotate(100, 50)
	end
end

function DialogueAnimateGlow(isActive, delay)
	isActive = isActive or false
		
	if (isActive) then
		local lastStep  = 0
		local stopTime = GetTime() + delay
		
		teamModel_GlowFlicker:SetVisible(true)		
		teamModel_GlowFlicker:UnregisterWatchLua('System')
		teamModel_GlowFlicker:RegisterWatchLua('System', function(widget, trigger)
			if (trigger.hostTime >= stopTime) then
				lastStep = 0
				return
			else
				local timer = trigger.hostTime % 5000
				
				if (timer <= 200 and lastStep ~= 1) then
					widget:FadeOut(200)
					lastStep = 1
				elseif (timer <= 400 and timer > 200 and lastStep ~= 2) then
					widget:FadeIn(50)
					lastStep = 2			
				elseif (timer <= 450 and timer > 400 and lastStep ~= 3) then
					widget:FadeOut(50)
					lastStep = 3
				elseif (timer <= 500 and timer > 450 and lastStep ~= 4) then
					widget:FadeIn(50)
					lastStep = 4
				elseif (timer <= 2000 and timer > 500 and lastStep ~= 5) then
					widget:FadeOut(50)
					lastStep = 5
				elseif (timer <= 2050 and timer > 2000 and lastStep ~= 6) then
					widget:FadeIn(100)
					lastStep = 6
				elseif (timer <= 2150 and timer > 2050 and lastStep ~= 7) then
					widget:FadeOut(50)
					lastStep = 7
				elseif (timer <= 2200 and timer > 2150 and lastStep ~= 8) then
					widget:FadeIn(50)
					lastStep = 8
				elseif (timer <= 2250 and timer > 2200 and lastStep ~= 9) then
					widget:FadeOut(200)
					lastStep = 9
				elseif (timer <= 2450 and timer > 2250 and lastStep ~= 10) then
					widget:FadeIn(100)
					lastStep = 10
				elseif (timer <= 5000 and timer > 2450 and lastStep ~= 11) then
					--Pause
					lastStep = 11
				end
			end
		end, false, nil, 'hostTime')
	else
		teamModel_GlowFlicker:FadeIn(50)
	end
end

--[[
========================
End Screen Animations
========================
]]--
function startOriginsAnimations (widget, isFirstTime)
	if isFirstTime then
		complete:SetText(Translate('origins_questComplete'))
		
		for index, groupWidget in ipairs(alreadyCompelted) do
			groupWidget:SetVisible(0)
		end
	else
		complete:SetText(Translate('origins_questPrevComplete'))
		
		for index, groupWidget in ipairs(alreadyCompelted) do
			groupWidget:SetVisible(1)
		end
	end
	
	effectThread = libThread.threadFunc(function()
			widget:FadeIn(2000)
		wait(2500)
			act2:FadeIn(500)
		wait(700)
			comingsoon:FadeIn(500)
		wait(700)
			PlaySound('/maps/bastact1/resources/ui/sounds/sfx_rewards.wav')
			reward01MP1:SetVisible(1)
			reward01MP1:SetEffect('/maps/bastact1/resources/ui/fx/UI_poof.effect')
		wait(300)
			reward01:FadeIn(300)
			reward01:Scale('100%', '100%', 300)
		wait(300)
			reward01MP2:SetVisible(1)
			reward02MP1:SetVisible(1)
			reward02MP1:SetEffect('/maps/bastact1/resources/ui/fx/UI_poof.effect')
		wait(600)
			reward02:FadeIn(300)
			reward02:Scale('100%', '100%', 300)
		wait(300)
			reward02MP2:SetVisible(1)
			reward03MP1:SetVisible(1)
			reward03MP1:SetEffect('/maps/bastact1/resources/ui/fx/UI_poof.effect')
		wait(600)
			reward03:FadeIn(300)
			reward03:Scale('100%', '100%', 300)
		wait(300)
			reward03MP2:SetVisible(1)
		wait(700)
			-- This sets everything in place and allows me to animate with higher objects
			reward01:SetWidth('100%')
			reward01:SetHeight('100%')
			reward02:SetWidth('100%')
			reward02:SetHeight('100%')
			reward03:SetWidth('100%')
			reward03:SetHeight('100%')
		wait(1500)
			for index, groupWidget in ipairs(modelPanels) do
				groupWidget:FadeOut(200)
			end
		
			questHolder:Scale('30%', '11.54@', 900)
			questHolder:SlideX('-26.7w', 1000)
			questHolder:SlideY('24w', 1000)
			
			for index, groupWidget in ipairs(largeText) do
				groupWidget:FadeOut(400)
			end
		wait(500)
			for index, groupWidget in ipairs(smallText) do
				groupWidget:FadeIn(400)
			end
		wait(400)
			-- This sets everything in place and prevents things from bouncing back
			questHolder:SetHeight('11.54@')
			questHolder:SetWidth('30%')
		wait(100)
			questHolder:SetX('-34w')
			questHolder:SetY('21w')			
			title:FadeIn(500)
			complete:FadeIn(500)
	end)
end	