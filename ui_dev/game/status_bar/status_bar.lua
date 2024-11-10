-- status Bar
local floor = math.floor

function statusBarRegister(object)
	local container		= object:GetWidget('gamestatusBar')
	local bar			= object:GetWidget('gamestatusBarPercent')
	local label			= object:GetWidget('gamestatusBarLabel')
	local label2		= object:GetWidget('gamestatusBarLabel2')
	local icon			= object:GetWidget('gamestatusBarIcon')

	-- This controls what mode to display, in order of priority:
	local currentMode = 0 -- 0:none		1:match start		2:death		3:stun
	local MATCH_START_MODE	= 1
	local DEATH_MODE		= 2
	local STUN_MODE			= 3
	
	local highestPrematchTime = -1 -- This is to know how long the pre-match will last, where the max of the timer bar should be.
	
	local function clamp(n, low, high) return math.max( math.min(n, high), low ) end -- This is such a useful function - it should probably be in a general library.
	
	-- This updates the bar for whatever the current mode is.
	local function updateBar(mode, trigger)
		if mode ~= currentMode then return end -- Not our current mode, don't update.
		
		if currentMode == 0 then -- No active mode, hide the bar.
			container:SetVisible(0)
			trigger_gamePanelInfo.respawnBarVis = false
			trigger_gamePanelInfo:Trigger(false)
			return
		elseif currentMode == MATCH_START_MODE then
			if trigger.matchTime > highestPrematchTime then 
				highestPrematchTime = trigger.matchTime -- This will be our maximum time.
			end
			label:SetText(Translate("events_pregame"))
			label2:SetText(FtoA2(trigger.matchTime/1000, 1, 1))
			bar:SetWidth(clamp((trigger.matchTime/highestPrematchTime) * 100, 0, 100) .. '%')
			icon:SetTexture("/ui/game/status_bar/textures/prematch.tga")
		elseif currentMode == DEATH_MODE then
			label:SetText(Translate("events_respawn"))
			label2:SetText(FtoA2(trigger.remainingRespawnTime/1000, 1, 1))
			bar:SetWidth(clamp((trigger.respawnPercent) * 100, 0, 100) .. '%')
			icon:SetTexture("/ui/game/unit_frames/textures/dead.tga")
		elseif currentMode == STUN_MODE then
			label:SetText(Translate("events_stunned"))
			label2:SetText(FtoA2(trigger.stunnedRemainingDuration/1000, 1, 1))
			bar:SetWidth(clamp((trigger.stunnedDurationPercent) * 100, 0, 100) .. '%')
			icon:SetTexture("/shared/effects/textures/stun_01.tga")
		end
		container:SetVisible(1)
		trigger_gamePanelInfo.respawnBarVis = true
		trigger_gamePanelInfo:Trigger(false)
	end
	
	
	local modeState = {false, false, false}
	local function disableMode(mode)
		modeState[mode] = false
		if currentMode == mode then -- Our current mode just ended
			for i = mode, 1, -1 do -- Set the new mode to the next which is available - if any.
				if not modeState[i] then
					currentMode = currentMode - 1
				end
			end
			-- Clear the bar if the mode which was just disabled was the only one left.
			if currentMode == 0 then
				updateBar(currentMode)
			end
		end
	end
	local function enableMode(mode)
		modeState[mode] = true
		if currentMode < mode then -- New mode which is higher priority than our current one, lets go to it.
			currentMode = mode
		end
	end
	
	-- Death and Respawn
	container:RegisterWatchLua('HeroUnit', function(widget, trigger)
		if (trigger.isActive or trigger.respawnPercent == 0 or trigger.respawnPercent == 1) then
			disableMode(DEATH_MODE)
		else
			disableMode(STUN_MODE) -- disable stun mode - You can't be stunned while dead.
			if (trigger_gamePanelInfo.mapWidgetVis_respawnTimer) then
				enableMode(DEATH_MODE)
				updateBar(DEATH_MODE, trigger)
			end
		end
	end, true, nil, 'isActive', 'remainingRespawnTime', 'respawnPercent')
	
	-- Pre-game timer
	container:RegisterWatchLua('MatchTime', function(widget, trigger)
		-- If the bar only has a short time on it (<6 secs) or a long time (> 2 mins), don't show it. This gets around it showing in tutorial 3.
		if (trigger.isPreMatchPhase and trigger.matchTime < 120000) then
			if highestPrematchTime > 6000 or trigger.matchTime > 6000 then
				enableMode(MATCH_START_MODE)
				updateBar(MATCH_START_MODE, trigger)
			end
		else
			disableMode(MATCH_START_MODE)
			container:UnregisterWatchLua('MatchTime') -- There is only 1 pre-match. We don't need to check again.
		end
	end)
	
	-- Stunned
	container:RegisterWatchLua('AltInfoSelf', function(widget, trigger)
		if (trigger.isStunned) then
			enableMode(STUN_MODE)
			updateBar(STUN_MODE, trigger)
		else
			disableMode(STUN_MODE)
		end
	end, false, nil, 'isStunned', 'stunnedDurationPercent')
	
	container:RegisterWatchLua('gamePanelInfo', function(widget, trigger)
		local ypos = -19
		if (trigger.moreInfoKey) or (trigger.heroVitalsVis) then
			ypos = ypos - 4		
		end
		if (trigger.lanePusherVis) then
			ypos = ypos - 5
		end
		widget:SlideY(libGeneral.HtoP(ypos), 125)
	end, false, nil, 'moreInfoKey', 'heroVitalsVis', 'lanePusherVis')	

end

statusBarRegister(object)