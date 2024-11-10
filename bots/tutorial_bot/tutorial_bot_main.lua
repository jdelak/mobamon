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
	ability = TargetAllyAbility.Create(self, self.hero:GetAbility(0))
	self:RegisterAbility(ability)

	self:SetOverrideLane("middle")
	Bot.State_Init(self)
end

-- End Custom Behavior Tree Functions

TutorialBot.Create(object)

