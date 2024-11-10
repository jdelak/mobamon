local ipairs, pairs, select, string, table, next, type, unpack, tinsert, tconcat, tremove, format, tostring, tonumber, tsort, ceil, floor, atan2, sin, cos, pi, sqrt, max, min, random, sub, find, gfind = _G.ipairs, _G.pairs, _G.select, _G.string, _G.table, _G.next, _G.type, _G.unpack, _G.table.insert, _G.table.concat, _G.table.remove, _G.string.format, _G.tostring, _G.tonumber, _G.table.sort, _G.math.ceil, _G.math.floor, _G.math.atan2, _G.math.sin, _G.math.cos, _G.math.pi, _G.math.sqrt, _G.math.max, _G.math.min, _G.math.random, _G.string.sub, _G.string.find, _G.string.gfind

local interface = object
local GetTrigger = LuaTrigger.GetTrigger

local multiKillTypes = {
	'doublekill',
	'triplekill',
	'quadkill',
	'annihilation',
}
local multiKillStrings = {
	'player_stats_doubletap',
	'player_stats_hattrick',
	'player_stats_quadkill',
	'player_stats_annihilated',
}
local streakStrings = {
	'player_stats_serialkiller',
	'player_stats_legndary',
	'player_stats_bloodbath',
	'player_stats_immortal',
}



--multikill 			1, {nbrKilled=numberKilled, name = name, icon=icon, isGood=true}
--killstreak 			2, {name=name, isGood=true, icon=icon, killCount = 2}
--krytospush 			3, {lane=top/mid/bot, isGood=true, entityName='Krytos'}
--cindaradefeat 		4, isGood=true, goldReward = 450
--baldirdefeat 			5, isGood=true, goldReward = 250
--towerdestroyed		6, isGood=true, entityName='tower', goldReward = 250
--generatordestroyed 	7, isGood=true, entityName='generator', goldReward = 1500
--respawn 				8
--victory 				9
--defeat 				10

local eventQueue = {}

function queueEvent(EventType, EventData)
	tinsert(eventQueue, {type=EventType,Data=EventData})
	updateEvent()
end

local effectThread = nil
local currentEvent = -1
local currentContainer -- used for skipping current effect
local ready = true
function updateEvent(force)
	if force then
		ready = true
	end
	if (#eventQueue == 0) then return end --Nothing to show, quit.
	local currentTime = GetTime()
	if (ready) then --time for a new event
		ready = false
		------------
		-- Get Event
		------------
		local event = tremove(eventQueue, 1)
		currentEvent = event.type

		-----------------
		-- Event Displays
		-----------------

		------------
		-- multikill
		------------
		if (currentEvent == 'multikill') then

			if true then
				arcadeTextMultiKill(event.Data.nbrKilled, event.Data.name, GetEntityDisplayName(event.Data.killHero), event.Data.icon, event.Data.isGood)

			--[[
					nbrKilled	= nbrKilled,
					name		= trigger.killerName,
					icon		= libGeneral.getCutoutOrRegularIcon(trigger.killerTypeName),
					isGood		= isGood,
					killHero	= trigger.killerTypeName
			--]]

			else
				local container = interface:GetWidget('center_announcements_multikill')
				local title = interface:GetWidget('center_announcements_multikill_title')
				local label = interface:GetWidget('center_announcements_multikill_username')
				local icon = interface:GetWidget('center_announcements_multikill_icon')
				local holder = interface:GetWidget('center_announcements_multikill_holder')
				local model = interface:GetWidget('center_announcements_multikill_model')
				local labelColor = (event.Data.isGood and '#15e915' or '#e91515')
				local slashScaler = interface:GetWidget('center_announcements_multikill_slashscaler')
				local slash1 = interface:GetWidget('center_announcements_multikill_slash1')
				local slash2 = interface:GetWidget('center_announcements_multikill_slash2')
				local slash3 = interface:GetWidget('center_announcements_multikill_slash3')
				local slash4 = interface:GetWidget('center_announcements_multikill_slash4')
				local slash5 = interface:GetWidget('center_announcements_multikill_slash5')

				currentContainer = container

				model:SetEffect('/ui/game/arcade_text/effects/templates/'..multiKillTypes[event.Data.nbrKilled -1]..'/'..multiKillTypes[event.Data.nbrKilled -1]..'_'..getEventColor(event.Data.isGood)..'.effect')
				--model:SetEffect('/ui/game/arcade_text/effects/'..multiKillTypes[event.Data.nbrKilled-1]..'_'..(event.Data.isGood and 'green' or 'red')..'.effect')
				title:SetText(Translate(multiKillStrings[event.Data.nbrKilled-1])..'!')
				label:SetText(event.Data.name)
				icon:SetTexture(event.Data.icon)
				slash1:SetTexture('/ui/game/arcade_text/textures/slash01_'..getEventColor(event.Data.isGood)..'.tga')
				slash2:SetTexture('/ui/game/arcade_text/textures/slash02_'..getEventColor(event.Data.isGood)..'.tga')
				slash3:SetTexture('/ui/game/arcade_text/textures/slash01_'..getEventColor(event.Data.isGood)..'.tga')
				slash4:SetTexture('/ui/game/arcade_text/textures/slash02_'..getEventColor(event.Data.isGood)..'.tga')
				slash5:SetTexture('/ui/game/arcade_text/textures/slash03_'..getEventColor(event.Data.isGood)..'.tga')

				if (event.Data.isGood) then
					title:SetOutlineColor('0.04 0.24 0.03 0.9')
					holder:SetColor(0.75, 1, 0.78, 1)
					label:SetColor(1, 0.71, 0, 1)
					label:SetOutlineColor('0.16 0.09 0.03 0.9')
				else
					title:SetOutlineColor('0.24 0.01 0.01 0.9')
					holder:SetColor(1, 0.73, 0.65, 1)
					label:SetColor(0, 0.87, 1, 1)
					label:SetOutlineColor('0.03 0.13 0.17 0.9')
				end

				container:SetVisible(true)
				label:SetVisible(false)
				title:SetVisible(false)
				title:SetColor(labelColor)
				icon:SetVisible(false)
				icon:SetWidth('400s')
				icon:SetHeight('400s')

				if (effectThread) then
					effectThread:kill()
					effectThread = nil
				end

				effectThread = libThread.threadFunc(function()
						icon:Scale('0%', '0%', 10)
						holder:Scale('0%', '0%', 10)
						slashScaler:SetVisible(true)
						slashScaler:Scale('0%', '0%', 10)

					wait(10)
						--This next section will determine where the slashes fade in based on the number of kills--
						if (multiKillStrings[event.Data.nbrKilled -1] == 'player_stats_doubletap') then
							slash1:SetX('-30%')
							slash1:FadeIn(200)
							slash2:SetX('30%')
							slash2:FadeIn(200)
						elseif (multiKillStrings[event.Data.nbrKilled -1] == 'player_stats_hattrick') then
							slash1:SetX('-50%')
							slash1:FadeIn(200)
							slash2:SetX('0%')
							slash2:FadeIn(200)
							slash3:SetX('50%')
							slash3:FadeIn(200)
						elseif (multiKillStrings[event.Data.nbrKilled -1] == 'player_stats_quadkill') then
							slash1:SetX('-75%')
							slash1:FadeIn(200)
							slash2:SetX('-30%')
							slash2:FadeIn(200)
							slash3:SetX('30%')
							slash3:FadeIn(200)
							slash4:SetX('75%')
							slash4:FadeIn(200)
						else
							slash1:SetX('-75%')
							slash1:FadeIn(200)
							slash2:SetX('-30%')
							slash2:FadeIn(200)
							slash3:SetX('30%')
							slash3:FadeIn(200)
							slash4:SetX('75%')
							slash4:FadeIn(200)
							slash5:FadeIn(200)
						end

						slashScaler:Scale('110%', '110%', 200)

					wait(100)
						icon:FadeIn(200)
						holder:FadeIn(200)
						icon:Scale('110%', '120%', 200)
						holder:Scale('350%', '225%', 200)

					wait(100)
						slashScaler:Scale('100%', '110%', 90)
						label:FadeIn(70)
						title:FadeIn(70)
						label:SlideY('57%', 70)
						title:SlideY('-90%', 70)

					wait(100)
						icon:Scale('90%', '90%', 90)

					wait(2200)
						if (multiKillStrings[event.Data.nbrKilled -1] == 'player_stats_annihilated') then
							wait(400)
						end

						label:FadeOut(70)
						title:FadeOut(70)
						label:SlideY('97%', 70)
						title:SlideY('-120%', 70)
						icon:FadeOut(400)
						holder:FadeOut(400)
						slash1:FadeOut(300)
						slash2:FadeOut(300)
						slash3:FadeOut(300)
						slash4:FadeOut(300)
						slash5:FadeOut(300)
						icon:Scale('200%', '10%', 180)
						holder:Scale('500%', '80%', 180)
						slashScaler:Scale('220%', '1%', 180)

					wait(180)
						icon:Scale('10%', '150%', 90)
						holder:Scale('60%', '350%', 90)
						slashScaler:Scale('1%', '200%', 90)

					wait(90)
						icon:Scale('0%', '0%', 30)
						holder:Scale('0%', '0%', 30)
						slashScaler:Scale('0%', '0%', 30)

					wait(130)
						slashScaler:SetVisible(false)
						icon:SetVisible(false)
						holder:SetVisible(false)
						label:SetVisible(false)
						title:SetVisible(false)
						container:SetVisible(false)

					updateEvent(true)
					effectThread = nil

				end)
			end
		end

		------------
		-- killStreak
		------------
		if (currentEvent == 'killstreak') then

			local container = interface:GetWidget('center_announcements_killstreak')
			local title = interface:GetWidget('center_announcements_killstreak_title')
			local label = interface:GetWidget('center_announcements_killstreak_username')
			local icon = interface:GetWidget('center_announcements_killstreak_icon')
			local holder = interface:GetWidget('center_announcements_killstreak_holder')
			local model = interface:GetWidget('center_announcements_killstreak_model')
			local labelColor = (event.Data.isGood and '#15e915' or '#e91515')
			local count = interface:GetWidget('center_announcements_killstreak_streak')
			local badgeScaler = interface:GetWidget('center_announcements_killstreak_badgescaler')
			local badgeBase = interface:GetWidget('center_announcements_killstreak_badge')
			local badge3 = interface:GetWidget('center_announcements_killstreak_badge3')
			local badge5 = interface:GetWidget('center_announcements_killstreak_badge5')
			local badge10 = interface:GetWidget('center_announcements_killstreak_badge10')
			local badge15 = interface:GetWidget('center_announcements_killstreak_badge15')

			local killCount = event.Data.killCount
			local streakType = (killCount==3 and 1) or (killCount==5 and 2) or (killCount==10 and 3) or (killCount==15 and 4)

			currentContainer = container

			model:SetEffect('/ui/game/arcade_text/effects/templates/doublekill/doublekill_green.effect')

			--I would like to ultimately update string tables to read without the (3), (5), (10), and (15)
			title:SetText(Translate(streakStrings[streakType]) or '')
			label:SetText(event.Data.name)
			count:SetText(killCount)
			icon:SetTexture(event.Data.icon)

			if (event.Data.isGood) then
				badge5:SetColor(0, 0.22, 0.16, 1)
				badge10:SetColor(0, 0.22, 0.16, 1)
				badge15:SetColor(0, 0.22, 0.16, 1)
				title:SetOutlineColor('0.04 0.24 0.03 0.9')
				holder:SetColor(0.75, 1, 0.78, 1)
				label:SetColor(1, 0.71, 0, 1)
				label:SetOutlineColor('0.16 0.09 0.03 0.9')
			else
				badge5:SetColor(0.22, 0, 0, 1)
				badge10:SetColor(0.22, 0, 0, 1)
				badge15:SetColor(0.22, 0, 0, 1)
				title:SetOutlineColor('0.24 0.01 0.01 0.9')
				holder:SetColor(1, 0.73, 0.65, 1)
				label:SetColor(0, 0.87, 1, 1)
				label:SetOutlineColor('0.03 0.13 0.17 0.9')
			end

			container:SetVisible(true)
			label:SetVisible(false)
			title:SetVisible(false)
			title:SetColor(labelColor)
			icon:SetVisible(false)
			icon:SetWidth('400s')
			icon:SetHeight('400s')

			if (effectThread) then
				effectThread:kill()
				effectThread = nil
			end

			effectThread = libThread.threadFunc(function()
					icon:Scale('0%', '0%', 10)
					holder:Scale('0%', '0%', 10)
					badgeScaler:SetVisible(true)
					badgeScaler:Scale('0%', '0%', 10)
					count:SetX('140%', 70)

				wait(10)
					badgeBase:FadeIn(200)
					badge3:FadeIn(200)

					--This next section will determine which badges will fade in--
					if (streakStrings[streakType] == 'player_stats_legndary') then
						badge5:FadeIn(200)
					elseif (streakStrings[streakType] == 'player_stats_bloodbath') then
						badge5:FadeIn(200)
						badge10:FadeIn(200)
					elseif (streakStrings[streakType] ~= 'player_stats_serialkiller') then
						badge5:FadeIn(200)
						badge10:FadeIn(200)
						badge15:FadeIn(200)
					end

					badgeScaler:Scale('100%', '100%', 200)

				wait(100)
					icon:FadeIn(200)
					holder:FadeIn(200)
					icon:Scale('110%', '120%', 200)
					holder:Scale('350%', '225%', 200)

				wait(100)
					count:FadeIn(180)
					label:FadeIn(70)
					title:FadeIn(70)
					count:SlideX('40%', 70)
					label:SlideY('57%', 70)
					title:SlideY('-90%', 70)

				wait(100)
					badgeScaler:Scale('90%', '90%', 90)
					icon:Scale('90%', '90%', 90)

				wait(2200)
					label:FadeOut(70)
					title:FadeOut(70)
					count:FadeOut(70)
					label:SlideY('97%', 70)
					title:SlideY('-120%', 70)
					count:SlideX('140%', 70)
					icon:FadeOut(400)
					holder:FadeOut(400)
					badgeBase:FadeOut(300)
					badge3:FadeOut(300)
					badge5:FadeOut(300)
					badge10:FadeOut(300)
					badge15:FadeOut(300)
					icon:Scale('200%', '10%', 180)
					holder:Scale('500%', '80%', 180)
					badgeScaler:Scale('220%', '1%', 180)

				wait(180)
					icon:Scale('10%', '150%', 90)
					holder:Scale('60%', '350%', 90)
					badgeScaler:Scale('1%', '200%', 90)

				wait(90)
					icon:Scale('0%', '0%', 30)
					holder:Scale('0%', '0%', 30)
					badgeScaler:Scale('0%', '0%', 30)

				wait(130)
					badgeScaler:SetVisible(false)
					icon:SetVisible(false)
					holder:SetVisible(false)
					label:SetVisible(false)
					title:SetVisible(false)
					container:SetVisible(false)

				updateEvent(true)
				effectThread = nil

			end)
		end

		--------------
		-- Krytos push
		--------------
		if (currentEvent == 'krytospush') then
			local container = interface:GetWidget('center_announcements_krytospush')
			local model = interface:GetWidget('center_announcements_krytospush_model')
			local label = interface:GetWidget('center_announcements_krytospush_title')
			local lane = interface:GetWidget('center_announcements_krytospush_lane')

			local laneName = event.Data.lane

			currentContainer = container

			model:SetEffect('/ui/game/arcade_text/effects/krytos_pushing_'..(event.Data.isGood and 'green' or 'red')..'.effect')
			label:SetText(Translate('events_pusheris', 'pusher', event.Data.entityName))
			lane:SetText(laneName)
			--label:SetText(Translate('events_pusherispushing', 'lane', laneName, 'pusher', event.Data.entityName))

			container:SetVisible(true)

			if (event.Data.isGood) then
				label:SetOutlineColor('0 0.10 0.01 0.9')
				label:SetColor(0, 0.7, 0, 1)
				lane:SetColor(0, 1, 0, 1)
			else
				label:SetOutlineColor('0.10 0 0 0.9')
				label:SetColor(0.8, 0, 0, 1)
				lane:SetColor(1, 0, 0, 1)
			end

			if (effectThread) then
				effectThread:kill()
				effectThread = nil
			end

			effectThread = libThread.threadFunc(function()
					label:SetX('-35%')
					lane:SetX('55%')
					label:SlideX('18%', 400)
					label:FadeIn(400)
				wait(200)
					lane:SlideX('23%', 400)
					lane:FadeIn(400)
				wait(2250)
					PlaySound('/npcs/Krytos/sounds/sfx_poundchest.wav')
				wait(1050)
					PlaySound('/npcs/Krytos/sounds/sfx_attack_'..floor(random(4))..'.wav')
					label:FadeOut(250)
					lane:FadeOut(250)
					label:SlideX('50%', 250)
					lane:SlideX('55%', 250)
				wait(500)
					container:SetVisible(false)

				updateEvent(true)
				effectThread = nil
			end)
		end

		-----------------
		-- Cindara defeat
		-----------------
		if (currentEvent == 'cindaradefeat') then
			local container = interface:GetWidget('center_announcements_cindaradefeat')
			local model = interface:GetWidget('center_announcements_cindaradefeat_model')
			local title = interface:GetWidget('center_announcements_cindaradefeat_title')
			local label = interface:GetWidget('center_announcements_cindaradefeat_defeat')
			--local goldLabel = interface:GetWidget('center_announcements_cindaradefeat_label')

			currentContainer = container

			model:SetEffect('/ui/game/arcade_text/effects/cindara_defeat_'..(event.Data.isGood and 'green' or 'red')..'.effect')

			--goldLabel:SetVisible(false)
			--goldLabel:SetText('+'..event.Data.goldReward)
			container:SetVisible(true)

			if (event.Data.isGood) then
				title:SetOutlineColor('0 0.10 0.01 0.9')
				title:SetColor(0, 0.7, 0, 1)
				label:SetColor(0, 1, 0, 1)
			else
				title:SetOutlineColor('0.10 0 0 0.9')
				title:SetColor(0.8, 0, 0, 1)
				label:SetColor(1, 0, 0, 1)
			end

			if (effectThread) then
				effectThread:kill()
				effectThread = nil
			end

			effectThread = libThread.threadFunc(function()
					title:SetX('-50%')
					label:SetX('50%')
					title:SlideX('-15%', 400)
					title:FadeIn(400)
				wait(200)
					label:SlideX('0%', 400)
					label:FadeIn(400)
				wait(2300)
					--if (event.Data.goldReward > 0) then
					--	goldLabel:FadeIn(250)
					--end
				wait(1000)
					title:FadeOut(200)
					label:FadeOut(200)
					title:SlideX('50%', 200)
					label:SlideX('-50%', 200)
				wait(200)
					--goldLabel:FadeOut(180)
					--goldLabel:SlideX('150s', 180)
				wait(200)
					--goldLabel:SetX('40s') --hardcoded RMM
					container:SetVisible(false)

				updateEvent(true)
				effectThread = nil
			end)
		end

		----------------
		-- Baldir defeat
		----------------
		if (currentEvent == 'baldirdefeat') then
			local container = interface:GetWidget('center_announcements_baldirdefeat')
			local title = interface:GetWidget('center_announcements_baldirdefeat_title')
			local label = interface:GetWidget('center_announcements_baldirdefeat_defeat')
			--local goldLabel = interface:GetWidget('center_announcements_baldirdefeat_award_label')
			local model = interface:GetWidget('center_announcements_baldirdefeat_model')
			currentContainer = container

			model:SetEffect('/ui/game/arcade_text/effects/baldir_defeat_'..(event.Data.isGood and 'green' or 'red')..'.effect')
			--goldLabel:SetVisible(false)
			--goldLabel:SetText('+'..event.Data.goldReward)

			container:SetVisible(true)

			if (event.Data.isGood) then
				title:SetOutlineColor('0 0.10 0.01 0.9')
				title:SetColor(0, 0.7, 0, 1)
				label:SetColor(0, 1, 0, 1)
			else
				title:SetOutlineColor('0.10 0 0 0.9')
				title:SetColor(0.8, 0, 0, 1)
				label:SetColor(1, 0, 0, 1)
			end

			if (effectThread) then
				effectThread:kill()
				effectThread = nil
			end

			effectThread = libThread.threadFunc(function()
					title:SetX('-50%')
					label:SetX('50%')
					title:SlideX('-15%', 400)
					title:FadeIn(400)
				wait(200)
					label:SlideX('0%', 400)
					label:FadeIn(400)
				wait(2500)
					--goldLabel:FadeIn(250)
				wait(1000)
					title:FadeOut(200)
					label:FadeOut(200)
					title:SlideX('50%', 200)
					label:SlideX('-50%', 200)
				wait(200)
					--goldLabel:FadeOut(180)
					--goldLabel:SlideX('150s', 180)
				wait(200)
					--goldLabel:SetX('40s') --hardcoded RMM
					container:SetVisible(false)

				updateEvent(true)
				effectThread = nil
			end)
		end

		----------------
		-- Tower destroy
		----------------
		if (currentEvent == 'towerdestroyed') then
			local container = interface:GetWidget('center_announcements_tower1')
			local title = interface:GetWidget('center_announcements_tower1_title')
			local label = interface:GetWidget('center_announcements_tower1_defeat')
			local model = interface:GetWidget('center_announcements_tower1_model')
			--local goldLabel = interface:GetWidget('center_announcements_tower1_award_label')

			currentContainer = container
			model:SetEffect('/ui/game/arcade_text/effects/tower_kill_'..(event.Data.isGood and 'green' or 'red')..'.effect')

			--title:SetText(Translate('events_destroyed', 'entity', event.Data.entityName))
			--goldLabel:SetVisible(false)
			--goldLabel:SetText('+'..event.Data.goldReward)
			container:SetVisible(true)

			if (event.Data.isGood) then
				title:SetOutlineColor('0 0.10 0.01 0.9')
				title:SetColor(0, 0.7, 0, 1)
				label:SetColor(0, 1, 0, 1)
			else
				title:SetOutlineColor('0.10 0 0 0.9')
				title:SetColor(0.8, 0, 0, 1)
				label:SetColor(1, 0, 0, 1)
			end

			if (effectThread) then
				effectThread:kill()
				effectThread = nil
			end

			effectThread = libThread.threadFunc(function()
					title:SetX('-50%')
					label:SetX('50%')
					title:SlideX('-20%', 400)
					title:FadeIn(400)
				wait(200)
					label:SlideX('0%', 400)
					label:FadeIn(400)
				wait(2500)
					--if (event.Data.goldReward > 0) then
					--	goldLabel:FadeIn(250)
					--end
				wait(1000)
					title:FadeOut(200)
					label:FadeOut(200)
					title:SlideX('50%', 200)
					label:SlideX('-50%', 200)
				wait(200)
					--goldLabel:FadeOut(200)
					--goldLabel:SlideX('150s', 200)
				wait(250)
					--goldLabel:SetX('40s') --hardcoded RMM
					container:SetVisible(false)

				updateEvent(true)
				effectThread = nil
			end)
		end

		--------------------
		-- Generator destroy
		--------------------
		if (currentEvent == 'generatordestroyed') then
			local container = interface:GetWidget('center_announcements_generator')
			local title = interface:GetWidget('center_announcements_generator_title')
			local label = interface:GetWidget('center_announcements_generator_defeat')
			local model = interface:GetWidget('center_announcements_generator_model')
			--local goldLabel = interface:GetWidget('center_announcements_generator_award_label')

			currentContainer = container
			model:SetEffect('/ui/game/arcade_text/effects/generator_destroyed_'..(event.Data.isGood and 'green' or 'red')..'.effect')
			--title:SetText(Translate('events_destroyed', 'entity', event.Data.entityName))
			--goldLabel:SetVisible(false)
			--goldLabel:SetText('+'..event.Data.goldReward)
			container:SetVisible(true)

			if (event.Data.isGood) then
				title:SetOutlineColor('0 0.10 0.01 0.9')
				title:SetColor(0, 0.7, 0, 1)
				label:SetColor(0, 1, 0, 1)
			else
				title:SetOutlineColor('0.10 0 0 0.9')
				title:SetColor(0.8, 0, 0, 1)
				label:SetColor(1, 0, 0, 1)
			end

			if (effectThread) then
				effectThread:kill()
				effectThread = nil
			end

			effectThread = libThread.threadFunc(function()
				title:SetX('-50%')
					label:SetX('50%')
					title:SlideX('-15%', 400)
					title:FadeIn(400)
				wait(200)
					label:SlideX('0%', 400)
					label:FadeIn(400)
				wait(2500)
					--if (event.Data.goldReward > 0) then
					--	goldLabel:FadeIn(250)
					--end
				wait(1000)
					title:FadeOut(200)
					label:FadeOut(200)
					title:SlideX('50%', 200)
					label:SlideX('-50%', 200)
				wait(200)
					--goldLabel:FadeOut(200)
					--goldLabel:SlideX('150s', 200)
				wait(250)
					--goldLabel:SetX('40s') --hardcoded RMM
					container:SetVisible(false)

				updateEvent(true)
				effectThread = nil
			end)
		end

		----------
		-- Respawn
		----------
		if (currentEvent == 'respawn') then
			local container = interface:GetWidget('center_announcements_respawn')
			local title = interface:GetWidget('center_announcements_respawn_title')
			local label = interface:GetWidget('center_announcements_respawn_sub')

			currentContainer = container

			--label:SetText(Translate('events_respawned'))
			container:SetVisible(true)

			if (effectThread) then
				effectThread:kill()
				effectThread = nil
			end
			effectThread = libThread.threadFunc(function()
					title:FadeIn(400)
					label:FadeIn(400)
				wait(2500)
					title:FadeOut(250)
					label:FadeOut(250)
				wait(500)
					container:SetVisible(false)

				updateEvent(true)
				effectThread = nil
			end)
		end

		----------
		-- Victory
		----------
		if (currentEvent == 'victory') then
			local container = interface:GetWidget('center_announcements_victory')
			local model = interface:GetWidget('center_announcements_victory_model')
			local title = interface:GetWidget('center_announcements_victory_title')

			currentContainer = container
			model:SetEffect('/ui/main/postgame/rewards/models/chests/effects/default_cloud.effect')
			container:SetVisible(true)

			if (effectThread) then
				effectThread:kill()
				effectThread = nil
			end

			effectThread = libThread.threadFunc(function()
					title:FadeIn(400)
				wait(4000)
					title:FadeOut(500)
				wait(500)
					container:SetVisible(false)

				updateEvent(true)
				effectThread = nil
			end)
		end

		----------
		-- Defeat
		----------
		if (currentEvent == 'defeat') then
			local container = interface:GetWidget('center_announcements_defeat')
			local model = interface:GetWidget('center_announcements_defeat_model')
			local title = interface:GetWidget('center_announcements_defeat_title')

			currentContainer = container
			model:SetEffect('/ui/main/postgame/rewards/models/chests/effects/default_cloud.effect')
			container:SetVisible(true)

			if (effectThread) then
				effectThread:kill()
				effectThread = nil
			end

			effectThread = libThread.threadFunc(function()
					title:FadeIn(400)
				wait(4000)
					title:FadeOut(500)
				wait(500)
					container:SetVisible(false)

				updateEvent(true)
				effectThread = nil
			end)
		end
	end
end


-- ===============================================

local multiKillBannerThread

local multiKillHeroIconWidth		= interface:GetWidget('arcadeTextMultiKillBannerHeroIcon'):GetWidth()
local multiKillHeroIconHeight		= interface:GetWidget('arcadeTextMultiKillBannerHeroIcon'):GetHeight()

local starBase				= {}
local starFilled			= {}
local starFilledWidth		= {}
local starFilledHeight		= {}

local killCountImage		= interface:GetWidget('arcadeTextMultiKillBannerKillCount')
local killCountImageWidth	= killCountImage:GetWidth()
local killCountImageHeight	= killCountImage:GetHeight()

for i=1,5,1 do
	starBase[i]			= interface:GetWidget('arcadeTextMultiKillBannerStar'..i)
	starFilled[i]		= interface:GetWidget('arcadeTextMultiKillBannerStar'..i..'Filled')
	starFilledWidth[i]	= starFilled[i]:GetWidth()
	starFilledHeight[i]	= starFilled[i]:GetHeight()
end

function arcadeTextMultiKill(killCount, playerName, heroName, heroIconPath, isAlly, killTypeColor, killCountColor, playerNameColor, heroNameColor, killLabelColor)

	isAlly		= isAlly or false
	killCount	= killCount or 2
	playerName	= playerName or 'BlinkyisaNoob'
	heroName	= heroName or 'Bo'
	heroIconPath	= heroIconPath or '/heroes/bo/icon_full.tga'

	local container				= interface:GetWidget('arcadeTextMultiKill')
	local banner				= interface:GetWidget('arcadeTextMultiKillBanner')

	local heroIcon				= interface:GetWidget('arcadeTextMultiKillBannerHeroIcon')

	local heroArrow				= interface:GetWidget('arcadeTextMultiKillBannerHeroArrow')
	local killType				= interface:GetWidget('arcadeTextMultiKillBannerKillType')
	local killLabel				= interface:GetWidget('arcadeTextMultiKillBannerKill')
	local glow					= interface:GetWidget('arcadeTextMultiKillBannerGlow')

	local bannerCenter			= interface:GetWidget('arcadeTextMultiKillBannerCenter')
	local bannerLeft			= interface:GetWidget('arcadeTextMultiKillBannerLeft')
	local bannerRight			= interface:GetWidget('arcadeTextMultiKillBannerRight')

	local playerNameLabel		= interface:GetWidget('arcadeTextMultiKillBannerPlayerName')
	local heroNameLabel			= interface:GetWidget('arcadeTextMultiKillBannerHeroName')

	if (multiKillBannerThread) then
		multiKillBannerThread:kill()
		multiKillBannerThread = nil
	end

	-- Init stuff
	banner:SetVisible(false)
	banner:SetWidth('110@')
	killLabel:SetVisible(false)
	killCountImage:SetVisible(false)
	killCountImage:SetWidth('400@')
	killCountImage:SetHeight('400%')
	killType:SetVisible(false)
	heroNameLabel:SetVisible(false)
	playerNameLabel:SetVisible(false)
	heroNameLabel:SetText(heroName)
	playerNameLabel:SetText(playerName)
	heroIcon:SetTexture(heroIconPath)
	heroArrow:SetVisible(false)
	heroArrow:SetX('-125@')

	killCountImage:SetTexture('/ui/shared/textures/number_'..killCount..'.tga')
	killType:SetText(Translate('arcade_text_kill_'..killCount))

	for i=1,5,1 do
		starBase[i]:SetVisible(true)
		starFilled[i]:SetVisible(false)
	end

	-- local killAlpha = (0.25 + (0.5 * (killCount / 5)))
	local killAlpha = 0.7

	local colorValues = { 1, 1, 1, 1 }

	if isAlly then
		colorValues = { 0.266, 0.431, 0.513, killAlpha }
		-- playerNameLabel:SetColor()
	else
		colorValues = { 0.792, 0.239, 0.184, killAlpha }
		-- playerNameLabel:SetColor()
	end

	bannerCenter:SetColor(unpack(colorValues))
	bannerLeft:SetColor(unpack(colorValues))
	bannerRight:SetColor(unpack(colorValues))
	heroArrow:SetColor(unpack(colorValues))


	-- ============= debug ==============
	if killTypeColor then

		killType:SetColor(killTypeColor)
	end


	if killLabelColor then
		killLabel:SetColor(killLabelColor)
	end



	if killCountColor then
		killCountImage:SetColor(killCountColor)
	end

	if playerNameColor then
		playerNameLabel:SetColor(playerNameColor)
	end

	if heroNameColor then
		heroNameLabel:SetColor(heroNameColor)
	end

	-- ==============

	multiKillBannerThread = libThread.threadFunc(function()

		if isAlly then
			glow:SetEffect('/ui/game/arcade_text/effects/templates/doublekill/doublekill_white.effect')
		else
			glow:SetEffect('/ui/game/arcade_text/effects/templates/doublekill/doublekill_orange.effect')
		end

		container:SetVisible(true)

		libAnims.bounceIn(heroIcon, multiKillHeroIconWidth, multiKillHeroIconHeight, true, 600, nil, 225)

		banner:FadeIn(125)
		banner:ScaleWidth('100%', 185)

		wait(125)

		if isAlly then
			glow:SetEffect('/ui/game/arcade_text/effects/templates/doublekill/doublekill_white.effect')
		else
			glow:SetEffect('/ui/game/arcade_text/effects/templates/doublekill/doublekill_orange.effect')
		end

		killCountImage:Scale('100@', '100%', 160)
		killCountImage:FadeIn(160)

		wait(100)

		killLabel:FadeIn(160)
		killType:FadeIn(160)

		heroArrow:FadeIn(150)
		heroArrow:SlideX('-90', 200)

		heroNameLabel:SetVisible(true)
		libAnims.textPopulateFade(heroNameLabel, 350, heroName)

		playerNameLabel:SetVisible(true)
		libAnims.textPopulateFade(playerNameLabel, 400, playerName)

		wait(60)

		libAnims.bounceIn(killCountImage, killCountImageWidth, killCountImageWidth, true, 400, 0.1, 160)

		for i=1,5,1 do
			if killCount >= i then
				-- starFilled[i]:FadeIn(250)
				libAnims.bounceIn(starFilled[i], starFilledWidth[i], starFilledHeight[i], true, 600, 0.35, 125)
			else
				starBase[i]:FadeIn(125)
			end
			wait(50)
		end

		wait(2200)

		container:FadeOut(500)

		multiKillBannerThread = nil

		updateEvent(true)
	end)

end

-- =========================================

function getEventColor(isGood)
	if (isGood) then
		return 'green'
	else
		return 'red'
	end
end

function skipEvent(clearQueue)
	if (clearQueue) then eventQueue = {} end
	if (effectThread) then
		effectThread:kill()
		effectThread = nil
	end
	if currentContainer then
		currentContainer:SetVisible(false)
	end
	updateEvent()
end

local fullLaneNames = {	-- May not always just be a case change
	bottom	= Translate('lane_bot'),
	middle	= Translate('lane_mid'),
	top		= Translate('lane_top')
}

local barracksEntities = {
	'Building_LegionMeleeBarracks',
	'Building_HellbourneMeleeBarracks'
}
local function isBarracksEntity(input)
	return libGeneral.isInTable(barracksEntities, input)
end

local towerEntities = {
	'Building_LegionTower',
	'Building_HellbourneTower',
	'Building_Tutorial_Tower'
}

local function isTowerEntity(input)
	return libGeneral.isInTable(towerEntities, input)
end

function ArcadeEventsRegister(object)

	if GetCvarBool('ui_hideArcadeText') then return end

	local nemesisStreakTable = {}
	local killSteakTable = {}

	local function ClearEventsQueue()
		eventQueue = {}
		nemesisStreakTable = {}
		killSteakTable = {}
	end
	interface:GetWidget('center_announcements_0'):RegisterWatchLua('GameReinitialize', ClearEventsQueue)

	function CenterArcadeEventKill(trigger)
		if ((trigger.killType ~= 1) and (trigger.killType ~= 2)) or (not trigger_gamePanelInfo.mapWidgetVis_arcadeText) then
			return
		end
		if (trigger.multiKill) and (trigger.multiKill >= 2) then
			local isGood = (trigger.killerIsAlly or trigger.killerIsSelf)
			local nbrKilled = trigger.multiKill
			if nbrKilled > 5 then nbrKilled = 5 end
			queueEvent(
				'multikill',
				{
					nbrKilled	= nbrKilled,
					name		= trigger.killerName,
					icon		= libGeneral.getCutoutOrRegularIcon(trigger.killerTypeName),
					isGood		= isGood,
					killHero	= trigger.killerTypeName
				}
			)

		end
		if (trigger.killStreak == 15 or trigger.killStreak == 10 or trigger.killStreak == 5 or trigger.killStreak == 3) then
			local isGood = (trigger.killerIsAlly or trigger.killerIsSelf)
			--[[
			queueEvent(
				'killstreak',
				{
					name		= trigger.killerName,
					isGood		= isGood,
					icon		= libGeneral.getCutoutOrRegularIcon(trigger.killerTypeName),
					killCount	= trigger.killStreak
				}
			)
			--]]
		end
	end
	interface:GetWidget('center_announcements_0'):RegisterWatchLua('EventKill', function(widget, trigger)
		CenterArcadeEventKill(trigger)
	end)

	function CenterArcadeEventBuildingKill(trigger)
		if (not trigger_gamePanelInfo.mapWidgetVis_arcadeText) or ((not isTowerEntity(trigger.entityName)) and (not isBarracksEntity(trigger.entityName))) then
			return
		end
		if isTowerEntity(trigger.entityName) then
			local isGood = (trigger.killerIsAlly or trigger.killerIsSelf)
			local displayName = GetEntityDisplayName(trigger.entityName) or trigger.entityName
			local gold = LuaTrigger.GetTrigger('EventTowerGold').gold or 0
			queueEvent('towerdestroyed'	, {isGood = isGood, entityName = displayName, goldReward = gold})
		elseif isBarracksEntity(trigger.entityName) then
			local isGood = (trigger.killerIsAlly or trigger.killerIsSelf)
			local displayName = GetEntityDisplayName(trigger.entityName) or trigger.entityName
			local gold = LuaTrigger.GetTrigger('EventGeneratorGold').gold or 0
			queueEvent('generatordestroyed'	, {isGood = isGood, entityName = displayName, goldReward = gold})
		end
	end
	interface:GetWidget('center_announcements_0'):RegisterWatchLua('EventBuildingKill', function(widget, trigger)
		-- CenterArcadeEventBuildingKill(trigger)
	end)

	function CenterArcadeEventBossKill(trigger)
		if (not trigger_gamePanelInfo.mapWidgetVis_arcadeText) then
			return
		end

		local isGood = (trigger.killerIsAlly or trigger.killerIsSelf)
		if (trigger.entityName == 'Neutral_BossPowerUp') then
			local gold = LuaTrigger.GetTrigger('EventBossGold').gold or 0
			queueEvent('baldirdefeat', {isGood = isGood, goldReward = gold})
		elseif (trigger.entityName == 'Neutral_TowerMaster') then
			queueEvent('cindaradefeat', {isGood = isGood, goldReward = trigger.goldReward})
		end

	end
	interface:GetWidget('center_announcements_0'):RegisterWatchLua('EventBossKill', function(widget, trigger)
		-- CenterArcadeEventBossKill(trigger)
	end)

	function CenterArcadeEventPusher(trigger)
		if (not trigger.name) or Empty(trigger.name) or (not GetEntityIconPath(trigger.name)) or (not (trigger.status == 1)) then
			return
		end

		local LanePushSet = LuaTrigger.GetTrigger('LanePushSet')
		local laneName	  = fullLaneNames[LanePushSet.laneName] or laneName or '?LANE?'
		local isGood = LanePushSet.friendly
		local displayName = GetEntityDisplayName(trigger.name) or trigger.name
		queueEvent('krytospush', {lane = laneName, isGood = isGood, entityName = displayName})
	end
	interface:GetWidget('center_announcements_0'):RegisterWatchLua('LanePushers0', function(widget, trigger)
		-- CenterArcadeEventPusher(trigger)
	end)

	----------
	-- Victory
	----------
	interface:GetWidget('center_announcements_0'):RegisterWatchLua('EventVictory', function(widget, trigger)
		-- skipEvent(true)
		-- queueEvent('victory')
	end)

	----------
	-- Defeat
	----------
	interface:GetWidget('center_announcements_0'):RegisterWatchLua('EventDefeat', function(widget, trigger)
		-- skipEvent(true)
		-- queueEvent('defeat')
	end)

	----------
	-- Respawn
	----------
	local playerWasDead = false
	interface:GetWidget('center_announcements_0'):RegisterWatchLua('HeroUnit', function(widget, trigger)	-- Death and Respawn
		if (trigger.isActive) then
			if (not trigger.isOnScreen) and (playerWasDead) then
				-- queueEvent('respawn')
			end
			playerWasDead = false
		else
			playerWasDead = true
		end
		if (not trigger.isActive) then
			nemesisStreakTable = {}
		end
	end, true, nil, 'isActive')

	--------------------
	-- Slide down on tab
	--------------------
	interface:GetWidget('center_announcements_0'):RegisterWatchLua('gamePanelInfo', function(widget, trigger)
		if (trigger.moreInfoKey) or (trigger.orbExpanded) or (trigger.orbExpandedPinned) then
			widget:SlideY('4.6h', 125)
			widget:Sleep(125, function()
				widget:SetY('4.6h')
			end)
		else
			widget:SlideY('0.0h', 125)
			widget:Sleep(125, function()
				widget:SetY('0.0h')
			end)
		end
	end, false, nil, 'moreInfoKey', 'orbExpanded', 'orbExpandedPinned')

	ArcadeEventsRegister = nil
end
ArcadeEventsRegister(object)

-- =========================================================

function arcadeTextTestKill(killCount, playerName, heroName, heroIcon, isAlly, killTypeColor, killCountColor, playerNameColor, heroNameColor, killLabelColor)
	arcadeTextMultiKill(killCount, playerName, heroName, heroIcon, isAlly, killTypeColor, killCountColor, playerNameColor, heroNameColor, killLabelColor)
end