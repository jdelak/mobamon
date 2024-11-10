-- Custom logic for Tutorial Bot

runfile "/bots/globals.lua"
runfile "/bots/bot.lua"
runfile "/bots/ability.lua"

local object = getfenv(0).object

local SpinAbility = {}

function SpinAbility:Evaluate()
	if not Ability.Evaluate(self) then
		return false
	end

	local target = self.owner:GetAttackTarget()
	if target == nil then
		return false
	end


	local dist = Vector2.Distance(self.owner.hero:GetPosition(), self.owner.teambot:GetLastSeenPosition(target))
	if dist > (self.ability:GetRange() * 0.8) then
		return false
	end

	return true
end

function SpinAbility.Create(owner, ability)
	local self = Ability.Create(owner, ability)
	ShallowCopy(SpinAbility, self)
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
	local ability = SpinAbility.Create(self, self.hero:GetAbility(1))
	self:RegisterAbility(ability)

	ability = SpinAbility.Create(self, self.hero:GetAbility(2))
	self:RegisterAbility(ability)

	self:SetOverrideLane("middle")
	Bot.State_Init(self)
end

-- End Custom Behavior Tree Functions

TutorialBot.Create(object)

