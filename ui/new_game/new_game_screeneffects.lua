-- new_game_screeneffects.lua
-- functionality for all of the screen effects (damage, death, level up, ect).
local max	= math.max
local min	= math.min
gameUI = gameUI or {}
gameUI.playerWasDead = false


-- Enable Screen Effects
local function EnableScreenEdgeFeedback(object)
	local screenFeedbackActive = 0 			--[[
		9 Dead / Respawn
		7 Crowd Control (stun / poly)
		x Silenced / Disarm
		x Attempt to cast while OOM
		4 ScreenFlashDamage
		3 Damaged (and on screen) / (and off screen)
		x Low Health
		x Levelup
		x Base Under Attack				BuildingAttackAlert / EventBuildingKill
		x Null
	--]]

	local screen_effect_frame_0			= object:GetWidget('screen_effect_frame_0')
	local screen_effect_frame_1			= object:GetWidget('screen_effect_frame_1')
	local screen_effect_frame_2			= object:GetWidget('screen_effect_frame_2')
	local game_deathfx					= object:GetWidget('game_deathfx')

	local game_warning_frame_group_0 	= object:GetGroup('game_warning_frame_group_0')
	local game_warning_frame_group_1 	= object:GetGroup('game_warning_frame_group_1')
	local game_warning_frame_group_2 	= object:GetGroup('game_warning_frame_group_2')

	local heartpulseLastTime			= 0
	local heartbeatMinDuration			= 400
	local heartbeatMultiplier			= 3000
	local heartpulseOn					= false

	local lastHeroHealthPercent			= 1
	local lastDamageAlertTime			= 0

	local totalDamagetLastClear			= 0
	local totalDamagePercent			= 0

	local fadingIn 						= false

	
	screen_effect_frame_0:UnregisterWatchLua('HeroUnit')
	screen_effect_frame_0:RegisterWatchLua('HeroUnit', function(widget, trigger)

		if ((trigger.health > 0) and (trigger.healthPercent < 0.50)) then

			for index, groupWidget in ipairs(game_warning_frame_group_0) do
				groupWidget:SetColor('1 0 0 ' .. (0.65 - (1.1 * trigger.healthPercent)) )
			end

			widget:SetVisible(1)
		else
			widget:FadeOut(500)
		end
	end, true, nil, 'healthPercent', 'health')
	
	screen_effect_frame_1:UnregisterWatchLua('HeroUnit')
	screen_effect_frame_1:RegisterWatchLua('HeroUnit', function(widget, trigger)

		if (trigger.health > 0 and trigger.healthPercent < 0.42) then

			if not heartpulseOn then
				heartpulseOn = true

				for index, groupWidget in ipairs(game_warning_frame_group_1) do
					groupWidget:SetColor('1 0 0 0.3') -- .. (0.30 - (0.5 * trigger.healthPercent)) )
				end

				widget:FadeIn(150)
				widget:UnregisterWatchLua('System')
				local isFadingIn = false
				widget:RegisterWatchLua('System', function(widget2, trigger2)
					local triggerHealth		= LuaTrigger.GetTrigger('HeroUnit')
					local curTime			= trigger2.hostTime
					local heartbeatDelay	= max(
						heartbeatMinDuration,
						heartbeatMultiplier * triggerHealth.healthPercent
					)

					if ((curTime - (heartbeatDelay)) >= heartpulseLastTime) then

						if (isFadingIn) then
							widget2:FadeOut(heartbeatDelay * 0.99)
							isFadingIn = false
						else
							widget2:FadeIn(heartbeatDelay * 0.99)
							isFadingIn = true
						end

						if (trigger.inCombat) then
							PlaySound('/ui/_effects/heartbeat.wav')
						end

						heartpulseLastTime = curTime

					end
				end, false, nil, 'hostTime')

			end
		elseif (heartpulseOn) then
			heartpulseOn = false
			widget:FadeOut(500)
			widget:UnregisterWatchLua('System')
		end
	end, true, nil, 'health', 'healthPercent', 'inCombat')

	game_deathfx:UnregisterWatchLua('HeroUnit')
	game_deathfx:RegisterWatchLua('HeroUnit', function(widget, trigger)	-- Death and Respawn

		if (trigger.isActive) then
			Set('vid_postEffectPath', '/core/post/null.posteffect',  'string')

			game_deathfx:FadeOut(125)
			if (screenFeedbackActive <= 9) and (gameUI.playerWasDead) then

				screenFeedbackActive = 9

				local triggerHostTime			= 	LuaTrigger.GetTrigger('System')

				local tempTime = triggerHostTime.hostTime

				if (not trigger.isOnScreen) then

					for index, groupWidget in ipairs(game_warning_frame_group_2) do
						groupWidget:SetColor('0.5 1 0 1.0')
					end
					widget:FadeIn(250)

					widget:UnregisterWatchLua('System')
					widget:RegisterWatchLua('System', function(widget2, trigger2)
						if (trigger2.hostTime > (tempTime + 2500)) then
							widget:FadeOut(500)
							screenFeedbackActive = -1
							widget2:UnregisterWatchLua('System')
						end
					end, false, nil, 'hostTime')

				else

					for index, groupWidget in ipairs(game_warning_frame_group_2) do
						groupWidget:SetColor('0.5 1 0 0.0')
					end
					widget:FadeIn(250)

					widget:UnregisterWatchLua('System')
					widget:RegisterWatchLua('System', function(widget2, trigger2)
						if (trigger2.hostTime > (tempTime + 750)) then
							widget:FadeOut(500)
							screenFeedbackActive = -1
							widget2:UnregisterWatchLua('System')
						end
					end, false, nil, 'hostTime')

				end

			end
			gameUI.playerWasDead = false
		else
			gameUI.playerWasDead = true
			Set('vid_postEffectPath', '/core/post/grayscale_light.posteffect',  'string')
			if (screenFeedbackActive <= 9) then

				screenFeedbackActive = 9

				for index, groupWidget in ipairs(game_warning_frame_group_2) do
					groupWidget:SetColor('1 1 1 0.10')
				end

				game_deathfx:FadeIn(4500)
			end
		end
	end, true, nil, 'isActive')

	screen_effect_frame_2:UnregisterWatchLua('HeroUnit')
	screen_effect_frame_2:RegisterWatchLua('HeroUnit', function(widget, trigger)

		local triggerHostTime			= 	LuaTrigger.GetTrigger('System')

		if (screenFeedbackActive <= 7) then
			if (trigger.isImmobilized) or (trigger.isStunned) then
				screenFeedbackActive = 7
				if not widget:IsVisibleSelf() then
					for index, groupWidget in ipairs(game_warning_frame_group_2) do
						groupWidget:SetColor('0 1 1 0.35')
					end
					widget:SetVisible(true)
				end
			elseif (trigger.isSilenced) or (trigger.isPerplexed) or (trigger.isDisarmed) or (trigger.isIsolated) or (trigger.isRestrained)  then
				screenFeedbackActive = 7
				if not widget:IsVisibleSelf() then
					for index, groupWidget in ipairs(game_warning_frame_group_2) do
						groupWidget:SetColor('1 0 1 0.35')
					end
					widget:SetVisible(true)
				end
			elseif (screenFeedbackActive == 7) then
				if widget:IsVisibleSelf() then
					widget:FadeOut(250)
				end
				screenFeedbackActive = -1
			end
		end

		if (triggerHostTime.hostTime > (totalDamagetLastClear + 750)) then
			totalDamagetLastClear = triggerHostTime.hostTime
			totalDamagePercent = 0
		end

		if ((lastHeroHealthPercent - trigger.healthPercent) > 0.00) then
			totalDamagePercent = totalDamagePercent + (lastHeroHealthPercent - trigger.healthPercent)
		end

		if (screenFeedbackActive <= 3) and (trigger.health > 0) and ( ((trigger.isOnScreen) and (totalDamagePercent > 0.03)) or ((not trigger.isOnScreen) and ((totalDamagePercent) > 0.01)) ) then

			screenFeedbackActive = 3

			for index, groupWidget in ipairs(game_warning_frame_group_2) do
				if (trigger.isOnScreen) then
					groupWidget:SetColor('1 0 0 ' .. min(0.85, max(0.10, (totalDamagePercent * 5) ) ))
				else
					groupWidget:SetColor('1 0 0 0.90')
				end
			end

			if (triggerHostTime.hostTime > (lastDamageAlertTime + 550)) then

				lastDamageAlertTime 		= triggerHostTime.hostTime

				if (trigger.isOnScreen) then
					widget:SetVisible(1)
				else
					PlaySound('/ui/_effects/heartbeat.wav')
					widget:SetVisible(1)
				end

				widget:UnregisterWatchLua('System')
				if (trigger.isOnScreen) then
					widget:RegisterWatchLua('System', function(widget2, trigger2)
						if (trigger2.hostTime > (lastDamageAlertTime + 500 + (totalDamagePercent * 3000))) then
							widget:FadeOut(500)
							screenFeedbackActive = -1
							widget2:UnregisterWatchLua('System')
						end
					end, false, nil, 'hostTime')
				else
					widget:RegisterWatchLua('System', function(widget2, trigger2)
						if (trigger2.hostTime > (lastDamageAlertTime + 500)) then
							widget:FadeOut(500)
							screenFeedbackActive = -1
							widget2:UnregisterWatchLua('System')
						end
					end, false, nil, 'hostTime')
				end
			end
		end

		lastHeroHealthPercent = trigger.healthPercent

		if (screenFeedbackActive <= 1) then
			if (trigger.availablePoints > 0) then
				screenFeedbackActive = 1
				for index, groupWidget in ipairs(game_warning_frame_group_2) do
					groupWidget:SetColor('0 1 1 0.1')
				end
				widget:FadeIn(150)
			elseif (screenFeedbackActive == 1) then
				widget:FadeOut(150)
				screenFeedbackActive = -1
			end
		end

	end, true, nil, 'health', 'healthPercent', 'availablePoints', 'isActive', 'inCombat', 'isStunned', 'isImmobilized', 'isPerplexed', 'isRestrained', 'isSilenced', 'isDisarmed', 'isIsolated')

	screen_effect_frame_2:UnregisterWatchLua('BuildingAttackAlert')
	screen_effect_frame_2:RegisterWatchLua('BuildingAttackAlert', function(widget, trigger)

		if (trigger.name) and (trigger.isSameTeam) then

			if (screenFeedbackActive < 2) then

				screenFeedbackActive = 2

				local triggerHostTime			= 	LuaTrigger.GetTrigger('System')

				local tempTime = triggerHostTime.hostTime


				for index, groupWidget in ipairs(game_warning_frame_group_2) do
					groupWidget:SetColor('0.5 0 .5 0.3')
				end
				widget:FadeIn(250)

				widget:UnregisterWatchLua('System')
				widget:RegisterWatchLua('System', function(widget2, trigger2)
					if (trigger2.hostTime > (tempTime + 1500)) then
						widget:FadeOut(500)
						screenFeedbackActive = -1
						widget2:UnregisterWatchLua('System')
					end
				end, false, nil, 'hostTime')

			end
		end
	end)

	screen_effect_frame_2:UnregisterWatchLua('EventNoMana')
	screen_effect_frame_2:RegisterWatchLua('EventNoMana', function(widget, trigger)

		if (screenFeedbackActive < 6) then

			screenFeedbackActive = 6

			local triggerHostTime			= 	LuaTrigger.GetTrigger('System')

			local tempTime = triggerHostTime.hostTime


			for index, groupWidget in ipairs(game_warning_frame_group_2) do
				groupWidget:SetColor('0.0 0.0 .5 0.70')
			end
			widget:FadeIn(125)

			widget:UnregisterWatchLua('System')
			widget:RegisterWatchLua('System', function(widget2, trigger2)
				if (trigger2.hostTime > (tempTime + 750)) then
					widget:FadeOut(125)
					screenFeedbackActive = -1
					widget2:UnregisterWatchLua('System')
				end
			end, false, nil, 'hostTime')

		end
	end)

	screen_effect_frame_2:UnregisterWatchLua('EventOnCooldown')
	screen_effect_frame_2:RegisterWatchLua('EventOnCooldown', function(widget, trigger)

		if (screenFeedbackActive < 5) then

			screenFeedbackActive = 5

			local triggerHostTime			= 	LuaTrigger.GetTrigger('System')

			local tempTime = triggerHostTime.hostTime


			for index, groupWidget in ipairs(game_warning_frame_group_2) do
				groupWidget:SetColor('0.0 0.0 .5 0.35')
			end
			widget:FadeIn(125)

			widget:UnregisterWatchLua('System')
			widget:RegisterWatchLua('System', function(widget2, trigger2)
				if (trigger2.hostTime > (tempTime + 750)) then
					widget:FadeOut(125)
					screenFeedbackActive = -1
					widget2:UnregisterWatchLua('System')
				end
			end, false, nil, 'hostTime')

		end
	end)
end

-- Disable Screen Effects
local function DisableScreenEdgeFeedback(object)
	local screen_effect_frame_0			= object:GetWidget('screen_effect_frame_0')
	local screen_effect_frame_1			= object:GetWidget('screen_effect_frame_1')
	local screen_effect_frame_2			= object:GetWidget('screen_effect_frame_2')
	local game_deathfx					= object:GetWidget('game_deathfx')
	
	screen_effect_frame_0:SetVisible(false)
	screen_effect_frame_1:SetVisible(false)
	screen_effect_frame_2:SetVisible(false)
	game_deathfx:SetVisible(false)
	
	screen_effect_frame_0:UnregisterWatchLua('System')
	screen_effect_frame_1:UnregisterWatchLua('System')
	screen_effect_frame_2:UnregisterWatchLua('System')
	
	screen_effect_frame_0:UnregisterWatchLua('HeroUnit')
	screen_effect_frame_1:UnregisterWatchLua('HeroUnit')
	screen_effect_frame_2:UnregisterWatchLua('HeroUnit')
	screen_effect_frame_2:UnregisterWatchLua('HeroUnit')
	screen_effect_frame_2:UnregisterWatchLua('BuildingAttackAlert')
	screen_effect_frame_2:UnregisterWatchLua('EventNoMana')
	screen_effect_frame_2:UnregisterWatchLua('EventOnCooldown')
end

-- Update Screen Effects
function updateScreenFeedback(object, enabled)
	if (enabled) then
		EnableScreenEdgeFeedback(object)
	else
		DisableScreenEdgeFeedback(object)
	end
end
updateScreenFeedback(object, Cvar.GetCvar('_game_screenFeedbackVis'):GetBoolean())