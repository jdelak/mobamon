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

	self:SetOverrideLane("top")

	local lanes = { "middle", "middle", "bottom" }
	local allies = Game.GetHeroes(self.hero:GetTeam())
	for _,ally in ipairs(allies) do
		if ally ~= self.hero then
			local bot = ally:GetBotBrain()
			if bot ~= self and bot ~= nil then
				Echo(bot:GetName() .. ":  Lane is " .. lanes[1])
				bot:SetOverrideLane(lanes[1])
				table.remove(lanes, 1)

				if #lanes == 0 then
					break
				end
			end
		end
	end

	Bot.State_Init(self)
end

-- End Custom Behavior Tree Functions

TutorialBot.Create(object)

