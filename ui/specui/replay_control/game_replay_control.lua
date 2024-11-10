function replayControlRegister(object)
	-- The 'locked to player' mode is broken. cam_mode 2 works in spectator, and when viewpoint is you in-game, but no-one else.
	
	local container				= object:GetWidget('replay_controller')
	local blocker				= object:GetWidget('replay_controller_blocker')
	
	local microButton			= object:GetWidget('replay_controller_micromode_button')
	local minimizedButton		= object:GetWidget('replay_controller_minimize_button')

	local viewpointDropdown		= object:GetWidget('replay_controller_viewing_dropdown')
	local cameraDropdown		= object:GetWidget('replay_controller_camera_dropdown')
	
	local speedLabel			= object:GetWidget('replay_controller_time_speed_button')
	local timeLabel				= object:GetWidget('replay_controller_time_settime')
	local timeEndLabel			= object:GetWidget('replay_control_time_totaltime')
	local timeSlider			= object:GetWidget('replay_controller_time_slider')
	local timeSliderValue		= object:GetWidget('replay_controller_time_slider_value')

	local pauseButton			= object:GetWidget('replay_controller_time_pauseplay_button')
	--local frameUpButton			= object:GetWidget('replay_controller_time_frameforward_button')
	--local frameDownButton		= object:GetWidget('replay_controller_time_frameback_button')
	local rewindButton			= object:GetWidget('replay_controller_time_rewind_button')
	local ffButton				= object:GetWidget('replay_controller_time_fastforward_button')
	local restartButton			= object:GetWidget('replay_controller_time_start_button')
	local endButton				= object:GetWidget('replay_controller_time_end_button')
	
	local interface = object
	
	local maxFrames				= 0
	local currentFrame			= 0
	
	function replayControlGetContainer()
		return container
	end
	
	----------------------------
	--        Top Menu        --
	----------------------------
	microButton:SetCallback('onclick', function(widget)	
		if (widget:GetButtonState() == 1) then
			for k,v in ipairs(widget:GetGroup('micromode')) do
				v:SetVisible(0)
			end
			--groupfcall('micromode', function('game_replay_control', groupWidget) groupWidget:SetVisible(0) end)
			
			widget:GetWidget('replay_controller_button_container'):SetY('10.2h')
			widget:GetWidget('replay_controller_dropdowns'):SetVisible(0)
			widget:GetWidget('replay_controller_time'):SetVisible(1)
		else
			for k,v in ipairs(widget:GetGroup('micromode')) do
				v:SetVisible(1)
			end
			--groupfcall('micromode', function('game_replay_control', groupWidget) groupWidget:SetVisible(1) end)
			
			widget:GetWidget('replay_controller_button_container'):SetY('17.4h')
			widget:GetWidget('replay_controller_dropdowns'):SetVisible(1)
			widget:GetWidget('replay_controller_time'):SetVisible(1)
		end	
	end)
	
	local animDuration = 300
	local oldX
	local oldY
	minimizedButton:SetCallback('onclick', function(widget)
		if (widget:GetButtonState() == 1) then -- minimize
			for k,v in ipairs(widget:GetGroup('micromode')) do
				v:SetVisible(0)
			end
			--groupfcall('micromode', function('game_replay_control', groupWidget) groupWidget:SetVisible(0) end)	
			
			-- save old values to maximize to
			oldX = container:GetX()
			oldY = container:GetY()
		
			widget:GetWidget('replay_controller_time'):SetVisible(0)
			widget:GetWidget('replay_controller_dropdowns'):SetVisible(0)
			widget:GetWidget('spacer'):SetVisible(1)
			microButton:SetVisible(0)
			container:SetWidth('26.66h') --this resets position, so we need to set it again.
			widget:GetWidget('replay_controller_container'):SetHeight('0h')
			
			widget:GetWidget('replay_controller_button_container'):SetY('0.11h')
			widget:GetWidget('replay_controller_button_container'):SetWidth('80%')
			widget:GetWidget('replay_controller_button_container'):SetHeight('3.2h')
			for k,v in ipairs(widget:GetGroup('replay_controller_btns_non_essential')) do
				v:SetVisible(0)
			end
			for k,v in ipairs(widget:GetGroup('replay_controller_btns_essential')) do
				v:SetWidth("90@")
			end
			
			container:SetX(oldX)
			container:SetY(oldY)
			libThread.threadFunc(function(thread)
				wait(1)
				container:SlideX(GetScreenWidth()-container:GetWidth(), animDuration)
				container:SlideY(66.1 ..'h', animDuration)
			end)
			
			container:SetNoClick('1') -- To prevent dragging
			blocker:SetNoClick('0') -- To prevent dragging
			widget:GetWidget('replay_controller_tab_dots'):SetVisible(0)
			
			
			for k,v in ipairs(widget:GetGroup('replay_controller_minimize_button_texture')) do
				v:SetTexture('/ui/shared/textures/button_maximize.tga')
			end
			
		else -- expand
			libThread.threadFunc(function(thread)
				wait(1)
				container:SlideX(oldX, animDuration)
				container:SlideY(oldY, animDuration)
				wait(101)
				for k,v in ipairs(widget:GetGroup('micromode')) do
					v:SetVisible(microButton:GetButtonState() == 0)
				end
				container:SetWidth('32h')
				widget:GetWidget('replay_controller_time'):SetVisible(1)
				widget:GetWidget('replay_controller_dropdowns'):SetVisible(microButton:GetButtonState() == 0)
				widget:GetWidget('spacer'):SetVisible(0)
				microButton:SetVisible(1)
				container:SetNoClick('0')
				blocker:SetNoClick('1')
				widget:GetWidget('replay_controller_tab_dots'):SetVisible(1)
				for k,v in ipairs(widget:GetGroup('replay_controller_minimize_button_texture')) do
					v:SetTexture('/ui/shared/textures/button_minimize.tga')
				end
				
				for k,v in ipairs(widget:GetGroup('replay_controller_btns_non_essential')) do
					v:SetVisible(1)
				end
				for k,v in ipairs(widget:GetGroup('replay_controller_btns_essential')) do
					v:SetWidth("12%")
				end
				pauseButton:SetWidth("15%")
				widget:GetWidget('replay_controller_button_container'):SetY(microButton:GetButtonState()==0 and '17.78h' or '10.2h')
				widget:GetWidget('replay_controller_button_container'):SetWidth('100%')
				widget:GetWidget('replay_controller_button_container'):SetHeight('4h')
			end)
		end	
	end)
	
	----------------------------
	--    Viewing Dropdown    --
	----------------------------
	local function viewpointDropdownPopulate()
		viewpointDropdown:ClearItems()
		viewpointDropdown:AddTemplateListItem('playerlist_template', -1, 'name', Translate('specui_view_specator'), 'color', 'white', 'icon', '/ui/elements:icon_spectator')
		viewpointDropdown:UICmd("AddPlayers('playerlist_template')")
		
		local lastValue = viewpointDropdown:GetValue()
		if (viewpointDropdown:GetValue() ~= '-1'  and lastValue == '-1') or not (viewpointDropdown:GetValue() == '-1'  and lastValue ~= '-1') then			
			if (viewpointDropdown:GetValue() == '-1') then
				cameraDropdown:Clear()
				cameraDropdown:AddTemplateListItem('camera_template', '0', 'label', Translate('specui_view_free'), 'icon', '/ui/shared/textures/user_icon.tga')
				cameraDropdown:SetSelectedItemByIndex(0,true)
			else
				cameraDropdown:Clear()
				cameraDropdown:AddTemplateListItem('camera_template', '0', 'label', Translate('specui_view_player'), 'icon', '/ui/shared/textures/user_icon.tga');
				cameraDropdown:AddTemplateListItem('camera_template', '1', 'label', Translate('specui_view_player_locked'), 'icon', '/ui/shared/textures/user_icon.tga');
				cameraDropdown:AddTemplateListItem('camera_template', '2', 'label', Translate('specui_view_free'), 'icon', '/ui/shared/textures/user_icon.tga');
				cameraDropdown:SetSelectedItemByIndex(0,true)	
				cameraDropdown:SetCallback('onselect', function(widget)
					println('1' .. self:GetValue())
					if ( self:GetValue() == '0' ) then
						Cvar.GetCvar('replay_unlockPlayer'):Set('false')
						Cvar.GetCvar('cam_mode'):Set(0)
					elseif ( self:GetValue() == '1' ) then
						Cvar.GetCvar('cam_mode'):Set(2)
						Cvar.GetCvar('replay_unlockPlayer'):Set('true')
					elseif ( self:GetValue() == '2' ) then
						Cvar.GetCvar('cam_mode'):Set(0)
						Cvar.GetCvar('replay_unlockPlayer'):Set('true')
					end
				end)
			end
		end
	end
	
	local ignoreViewpointChange = false
	viewpointDropdown:SetCallback('onselect', function(widget)
		if ignoreViewpointChange then
			ignoreViewpointChange = false
			return
		end
		
		local lastValue = viewpointDropdown:GetValue()
		
		if lastValue ~= '-1' then
			ignoreViewpointChange = true
		end
		viewpointDropdown:UICmd("SetReplayClient(-1)") -- set to spectator move first, otherwise it doesn't swap properly.
		
		Cvar.GetCvar('cam_mode'):Set(0)
		Cvar.GetCvar('replay_unlockPlayer'):Set('true')
		if (lastValue ~= '-1') then
			libThread.threadFunc(function(thread)
				wait(1)
				ignoreViewpointChange = true
				viewpointDropdown:UICmd("SetReplayClient("..lastValue..")")
				if LuaTrigger.GetTrigger('SpectatorUnit'..lastValue) then
					SelectUnit(LuaTrigger.GetTrigger('SpectatorUnit'..lastValue).index) --select unit
				end
				
				cameraDropdown:Clear()
				cameraDropdown:AddTemplateListItem('camera_template', '0', 'label', Translate('specui_view_player'), 'icon', '/ui/shared/textures/user_icon.tga');
				cameraDropdown:AddTemplateListItem('camera_template', '1', 'label', Translate('specui_view_player_locked'), 'icon', '/ui/shared/textures/user_icon.tga');
				cameraDropdown:AddTemplateListItem('camera_template', '2', 'label', Translate('specui_view_free'), 'icon', '/ui/shared/textures/user_icon.tga');
				cameraDropdown:SetSelectedItemByIndex(0,true)	
				cameraDropdown:SetCallback('onselect', function(widget)
					println('2 '..self:GetValue())
					if ( self:GetValue() == '0' ) then
						Cvar.GetCvar('replay_unlockPlayer'):Set('false')
					elseif ( self:GetValue() == '1' ) then
						Cvar.GetCvar('replay_unlockPlayer'):Set('true')
						Cvar.GetCvar('cam_mode'):Set(2)
					elseif ( self:GetValue() == '2' ) then
						Cvar.GetCvar('replay_unlockPlayer'):Set('true')
						Cvar.GetCvar('cam_mode'):Set(0)
					end
				end)
				Cvar.GetCvar('replay_unlockPlayer'):Set('false')
				
				wait(1)
				Cmd('hidewidget minimapUnitTip') -- The swapping of interfaces opens the minimap tip randomely.
			end)
		else
			cameraDropdown:Clear()
			cameraDropdown:AddTemplateListItem('camera_template', '0', 'label', Translate('specui_view_free'), 'icon', '/ui/shared/textures/user_icon.tga');
			cameraDropdown:SetSelectedItemByIndex(0,true)	
			cameraDropdown:SetCallback('onselect', function(widget)
				-- overwrite old onselect.
			end)
			libThread.threadFunc(function(thread)
				wait(1)
				Cmd('hidewidget minimapUnitTip') -- The swapping of interfaces opens the minimap tip randomely.
			end)
		end
	end)
	
	viewpointDropdown:RegisterWatch('PlayerList', function(widget, ...)
		viewpointDropdownPopulate()
	end)
	
	object:SetCallback('onshow', function(widget)
		viewpointDropdownPopulate()
	end)

	viewpointDropdownPopulate()	
	
	----------------------------
	--      Time Stamps       --
	----------------------------
	timeLabel:RegisterWatchLua('Replay', function(widget, trigger)
		widget:SetText(libNumber.timeFormat(trigger.time))
	end, false, nil, 'time')
	
	timeEndLabel:RegisterWatchLua('Replay', function(widget, trigger)
		widget:SetText('/ ' .. libNumber.timeFormat(trigger.endTime))
	end, false, nil, 'endTime')
	
	timeSlider:RegisterWatchLua('Replay', function(widget, trigger)
		widget:SetMaxValue(trigger.endFrame)
		widget:SetValue(trigger.frame)
		
		maxFrames = widget:GetMaxValue()
		currentFrame = widget:GetValue()
		
		timeSliderValue:SetWidth(tostring((currentFrame / maxFrames) * 100) .. '%')
	end, false, nil, 'frame', 'endFrame')
	
	timeSlider:SetCallback('onenddrag', function(widget)
		Cmd('ReplaySetFrame '.. widget:GetValue())
	end)
	
	----------------------------
	--     Speed Controls     --
	----------------------------
	speedLabel:RegisterWatchLua('Replay', function(widget, trigger)
		local replaySpeed = trigger.speed
		
		if replaySpeed == 0 then
			for k,v in ipairs(widget:GetGroup('speed_text')) do
				v:SetText(Translate('generic_speed_short_1x'))
			end
		elseif replaySpeed == -1 then
			for k,v in ipairs(widget:GetGroup('speed_text')) do
				v:SetText(Translate('generic_speed_short_05x'))
			end
		elseif replaySpeed == -2 then
			for k,v in ipairs(widget:GetGroup('speed_text')) do
				v:SetText(Translate('generic_speed_short_025x'))
			end
		elseif replaySpeed == -3 then
			for k,v in ipairs(widget:GetGroup('speed_text')) do
				v:SetText(Translate('generic_speed_short_0125x'))
			end
		elseif replaySpeed == 1 then
			for k,v in ipairs(widget:GetGroup('speed_text')) do
				v:SetText(Translate('generic_speed_short_2x'))
			end
		elseif replaySpeed == 2 then
			for k,v in ipairs(widget:GetGroup('speed_text')) do
				v:SetText(Translate('generic_speed_short_4x'))
			end
		elseif replaySpeed == 3 then
			for k,v in ipairs(widget:GetGroup('speed_text')) do
				v:SetText(Translate('generic_speed_short_8x'))
			end
		end
	end, false, nil, 'speed')
	
	--[[
	pauseButton:SetCallback('onload', function(widget)
		-- Pauses the game if the player needs to do a UI reload
		Cmd('ReplaySetPaused 1') -- Doesn't actually pause, and probably shouldn't anyway.
		pauseButton:SetButtonState(1)
	end)
	]]
	
	pauseButton:SetCallback('onclick', function(widget)
		if (widget:GetButtonState() == 1) then
			Cmd('ReplaySetPaused 1')
		else
			Cmd('ReplaySetPaused 0')
		end
	end)
	
	local function jumpForwards()
		-- Would be ideal to have this jump up 1 frame or at least slow enough for a 'frame by frame' view, when paused, this is a 'hacky' solution to not being able to increment frames.
		-- local oldCurrentFrame = currentFrame
		-- if pauseButton:GetButtonState() == 1 then -- paused
			-- Cmd('ReplaySetPaused 0')
			-- libThread.threadFunc(function(thread)
				-- while (oldCurrentFrame == currentFrame) do
					-- wait(1) --wait until they are different
				-- end
				-- Cmd('ReplaySetPaused 1')
				-- pauseButton:SetButtonState(1)
			-- end)
		-- else -- not paused
			Cmd('ReplayIncFrame 1') -- jump 5 seconds, believe it or not. Because it is rounded up to the nearest 100.
		-- end
	end
	
	local function jumpBackwards()
		-- Would be ideal to have this jump down 1 frame or at least slow enough for a 'frame by frame' view, when paused, but ReplaySetFrame can't get specific frames.
		Cmd('ReplayIncFrame -175')
	end
	
	local function restart()
		currentFrame = 0
		Cmd('ReplaySetFrame 0')
		Cmd('ReplaySetPlaybackSpeed 0')
	end
	
	local function jumpToEnd()
		-- Would be ideal to have this stop at the very end (not nearest 100), but ReplaySetFrame can't get specific frames.
		currentFrame = math.floor(maxFrames/100)*100
		Cmd('ReplaySetFrame '..currentFrame)
		Cmd('ReplayIncPlaybackSpeed 0')
		Cmd('ReplaySetPaused 1')
		pauseButton:SetButtonState(1)
	end
	
	--[[ These are no longer used.
	frameUpButton:SetCallback('onclick', function(widget)
		jumpForwards()
	end)
	
	frameDownButton:SetCallback('onclick', function(widget)
		jumpBackwards()
	end)
	]]
	
	rewindButton:SetCallback('onclick', function(widget)
		-- Would be ideal to have this go in reverse
		Cmd('ReplayIncPlaybackSpeed -1')
	end)
	
	ffButton:SetCallback('onclick', function(widget)
		Cmd('ReplayIncPlaybackSpeed 1')
	end)
	
	restartButton:SetCallback('onclick', function(widget)
		-- restart()
		jumpBackwards()
	end)
	
	endButton:SetCallback('onclick', function(widget)
		-- jumpToEnd()
		jumpForwards()
	end)
end
	
replayControlRegister(object)