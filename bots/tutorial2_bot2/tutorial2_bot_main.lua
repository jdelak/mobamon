-- Custom logic for Tutorial Bot

runfile "/bots/globals.lua"
runfile "/bots/bot.lua"
runfile "/bots/ability.lua"

local object = getfenv(0).object

-- Custom Behavior Tree Functions

local TutorialBot = {}

function TutorialBot.Create(object)
	local self = Bot.Create(object)
	ShallowCopy(TutorialBot, self)
	return self
end

function TutorialBot:State_Init()
	
	-- Throw Knife
	local ability = TargetPositionAbility.Create(self, self.hero:GetAbility(0))
	self:RegisterAbility(ability)

	self:SetOverrideLane("middle")
	Bot.State_Init(self)
end

function TutorialBot:CalculateThreatLevel(pos)
	return Bot.CalculateThreatLevel(self, pos) * 0.5 -- Shrink threat for tutorial bot
end

-- End Custom Behavior Tree Functions

TutorialBot.Create(object)

