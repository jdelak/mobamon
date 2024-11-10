--[[
========================
Local Variables
========================
]]--
local interface = object

local container			= interface:GetWidget('BossHeathbarContainer')
local healthbar			= interface:GetWidget('BossHeathbarBase')
local eyes				= interface:GetWidget('BossHealthbarEyes')
local eyes_lowAlpha		= interface:GetWidget('BossHealthbarEyesLow')

local bossInfoMapTrigger = LuaTrigger.GetTrigger('bossInfoMapTrigger') or LuaTrigger.CreateCustomTrigger('bossInfoMapTrigger', {
	{	name	= 'bossPercent',			type	= 'number'	},
	{	name	= 'bossVis',				type	= 'boolean'	}
})

bossInfoMapTrigger.bossPercent			= 1
bossInfoMapTrigger.bossVis				= false

local animateBossGlowingEyesThread
local function animateBossGlowingEyes(isActive, alpha)
	if (animateBossGlowingEyesThread) then
		animateBossGlowingEyesThread:kill()
		animateBossGlowingEyesThread = nil
	end
	
	local lowAlpha = 0
	
	if alpha ~= 0 then
		lowAlpha= alpha / 2
	end
	
	eyes:SetColor(1, 1, 1, alpha)
	eyes_lowAlpha:SetColor(1, 1, 1, lowAlpha)
	
	animateBossGlowingEyesThread = libThread.threadFunc(function()
		while (isActive) do
				eyes_lowAlpha:FadeIn(1200)
			wait(1200)
				eyes_lowAlpha:FadeOut(1200)
			wait(1200)			
		end			
			
		animateBossGlowingEyesThread = nil
	end)	
end

container:RegisterWatch('bossHealthbar_TurnOn', function(widget)
		widget:FadeIn(200)
		bossInfoMapTrigger.bossVis = true
end)

container:RegisterWatch('bossHealthbar_TurnOff', function(widget)
		widget:FadeOut(200)
		animateBossGlowingEyes(false, 0)
		bossInfoMapTrigger.bossVis = false
end)

healthbar:RegisterWatch('bossHealthbar_Update', function(widget, param, value)
	if bossInfoMapTrigger.bossVis and value and tonumber(value) then
		local bossHealthPercent = tonumber(value)
		
		widget:SetWidth(ToPercent(bossHealthPercent))
		
		if (bossHealthPercent < 1) and (bossHealthPercent > 0) then
			animateBossGlowingEyes(true, (1-bossHealthPercent))
		end
	end
end, false, nil, 'bossPercent')