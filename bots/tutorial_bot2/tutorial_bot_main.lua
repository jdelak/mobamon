-- Custom logic for Tutorial Bot

runfile "/bots/globals.lua"
runfile "/bots/bot.lua"
runfile "/bots/ability.lua"

local object = getfenv(0).object

local KnifeAbility = {}

function KnifeAbility:Evaluate()
	if not TargetPositionAbility.Evaluate(self) then
		return false
	end

	return self.owner:CheckClearPath(self.owner:GetAttackTarget(), false)
end

function KnifeAbility.Create(owner, ability)
	local self = TargetPositionAbility.Create(owner, ability)
	ShallowCopy(KnifeAbility, self)
	return self
end

-- Custom Behavior Tree Functions

local TutorialBot = {}

function TutorialBot.Create(object)
	local self = Bot.Create(object)
	ShallowCopy(TutorialBot, self)
	return self
end

function TutorialBot:State_Init()
	
	-- Throw Knife
	local ability = KnifeAbility.Create(self, self.hero:GetAbility(0), true)
	self:RegisterAbility(ability)

	self:SetOverrideLane("middle")
	Bot.State_Init(self)
end

function TutorialBot:CalculateThreatLevel(pos)
	return Bot.CalculateThreatLevel(self, pos) * 0.5 -- Shrink threat for tutorial bot
end

-- End Custom Behavior Tree Functions

TutorialBot.Create(object)

