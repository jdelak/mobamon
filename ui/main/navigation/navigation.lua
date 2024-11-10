local triggerPanelStatus			= LuaTrigger.GetTrigger('mainPanelStatus')
local triggerPanelAnimationStatus	= LuaTrigger.GetTrigger('mainPanelAnimationStatus')

libGeneral.createGroupTrigger('navVisAnimGroup', {
	'featureMaintenanceTrigger',
	'mainPanelAnimationStatus.newMain',
	'mainPanelAnimationStatus.main'
})

local function navigationRegister(object)

	-- Big Reds
	local function RightNavRegisterButton(widgetName, main, featureName)
		local widget			= GetWidget(widgetName)
		local button			= GetWidget(widgetName .. 'Button')
		local pulseEffect		= GetWidget(widgetName .. 'PulseEffect')
		local pulseEffectFrame	= GetWidget(widgetName .. 'PulseEffectFrame')
		local visibleX  		= widget:GetX()
		local visibleY  		= widget:GetY()

		if featureName == 'crafting' then
			button:RegisterWatchLua('AccountInfo', function(button, trigger)
				button:SetEnabled(trigger.canCraft)
			end, false, nil, 'canCraft')
		end

		if pulseEffect then
			local pulseVisible		= true
			local lastPulseVisible	= false
			local pulseDuration		= 1000
			pulseEffect:SetCallback('onshow', function(widget)
				widget:RegisterWatchLua('System', function(widget, trigger)
					local hostTime = trigger.hostTime

					if pulseVisible and (lastPulseVisible ~= pulseVisible) then
						pulseEffectFrame:FadeIn(pulseDuration)
						lastPulseVisible = pulseVisible
					elseif (not pulseVisible) and (lastPulseVisible ~= pulseVisible) then
						pulseEffectFrame:FadeOut(pulseDuration)
						lastPulseVisible = pulseVisible
					end

					pulseVisible = ((hostTime % (pulseDuration * 2)) > pulseDuration)
				end, false, nil, 'hostTime')
			end)

			pulseEffect:SetCallback('onhide', function(widget)
				widget:UnregisterWatchLua('System')
				pulseEffectFrame:SetVisible(false)
			end)
		end
		
		local lastAnim = ''
		widget:RegisterWatchLua('navVisAnimGroup', function(self, groupTrigger)
			if ((featureName) and (mainUI.featureMaintenance) and (mainUI.featureMaintenance[featureName])) then	-- fully hidden due to feature maintenance
				button:SetVisible(0)
			else
				local trigger	= groupTrigger['mainPanelAnimationStatus']
				button:SetVisible(1)

				if (trigger.newMain ~= 101) and (trigger.newMain ~= -1) then		-- outro
					if (lastAnim ~= 'outro') then
						lastAnim = 'outro'
						button:SetNoClick(1)
						RegisterRadialEase(self, nil, 393, true)
						libThread.threadFunc(function()
							self:DoEventN(8)
						end)
					end
				elseif ((trigger.main ~= 101) and (trigger.newMain ~= 101)) then			-- fully hidden
					lastAnim = 'hidden'
					button:SetNoClick(1)
					self:GetWidget('main_landing_buttons_0'):SetVisible(0)
				elseif (trigger.newMain == 101) and (trigger.newMain ~= -1) then		-- intro
					if (lastAnim ~= 'intro') then
						lastAnim = 'intro'
						button:SetNoClick(1)
						self:GetWidget('main_landing_buttons_0'):SetVisible(1)
						libThread.threadFunc(function()
							RegisterRadialEase(self, nil, 393, true)
							self:DoEventN(7)
						end)
					end
				elseif (trigger.main == 101) then										-- fully displayed
					lastAnim = 'visible'
					button:SetNoClick(0)
					self:GetWidget('main_landing_buttons_0'):SetVisible(1)
					self:SetX(visibleX)
					self:SetY(visibleY)
				end
			end
		end)

		button:SetCallback('onclick', function(self)
			-- navButtonClick (side)
			-- PlaySound('/path_to/filename.wav')
			if (triggerPanelStatus.main == main) then
				triggerPanelStatus.main = 101
				triggerPanelStatus:Trigger(false)
			else
				triggerPanelStatus.main = main
				triggerPanelStatus:Trigger(false)
			end
		end)

		button:SetCallback('onmouseoverdisabled', function()
			if featureName == 'crafting' and (not LuaTrigger.GetTrigger('AccountInfo').canCraft) then
				simpleTipGrowYUpdate(true, nil, Translate('navigation_crafting_mustlevelaccount'), Translate('navigation_crafting_mustlevelaccount_tip', 'value', mainUI.progression.CRAFTING_UNLOCK_LEVEL), libGeneral.HtoP(40))
			else
				simpleTipGrowYUpdate(true, nil, Translate('new_player_experience_mustfinishtutorial'), Translate('new_player_experience_mustfinishtutorial_tip'), libGeneral.HtoP(40))
			end
		end)
		button:SetCallback('onmouseoutdisabled', function() simpleTipGrowYUpdate(false) end)
		button:SetCallback('onmouseout', function() simpleTipGrowYUpdate(false) end)

		button:RefreshCallbacks()
	end

	RightNavRegisterButton('main_landing_button_0_0', 40, 'play')
	-- RightNavRegisterButton('main_landing_button_0_1b', 40, 'party')	-- create party button
	-- RightNavRegisterButton('main_landing_button_0_1d', 8, 'lobby') -- bot game button (just create game)
	RightNavRegisterButton('main_landing_button_0_1', 2,  'pets')
	RightNavRegisterButton('main_landing_button_0_2', 1,  'crafting')
	-- RightNavRegisterButton('main_landing_button_0_3', 5,  'enchanting')
	RightNavRegisterButton('main_landing_button_0_5', 28,  'watch')

	-- ===============================

	-- Top Grays
	local function TopNavRegisterButton(widgetName, main, featureName)
		local widget	=	GetWidget(widgetName)
		local button	=	GetWidget(widgetName .. 'Button')
		local bgcurrent	=	GetWidget(widgetName .. 'BackgroundCurrent')
		local visibleX  =	widget:GetX()
		local visibleY  =	widget:GetY()

		if (main == 40) then
			bgcurrent:RegisterWatchLua('mainPanelStatus', function(self, trigger)
				libGeneral.fade(self, ((trigger.main == main) or (trigger.main == 24) or (trigger.main == 12)), 250)
			end, false, nil, 'main')
		elseif (main == 1) then -- crafting
			bgcurrent:RegisterWatchLua('mainPanelStatus', function(self, trigger)
				libGeneral.fade(self, ((trigger.main == 1) or (trigger.main == 5) or (trigger.main == 6)), 250) -- crafting enchanting inventory
			end, false, nil, 'main')
		else
			bgcurrent:RegisterWatchLua('mainPanelStatus', function(self, trigger)
				libGeneral.fade(self, (trigger.main == main), 250)
			end, false, nil, 'main')
		end

		widget:RegisterWatchLua('featureMaintenanceTrigger', function(self, trigger)
			if ((featureName) and (mainUI.featureMaintenance) and (mainUI.featureMaintenance[featureName])) then	-- fully hidden due to feature maintenance
				button:SetVisible(0)
			else
				button:SetVisible(1)
			end
		end)

		widget:RegisterWatchLua('mainPanelAnimationStatus', function(self, trigger)
			-- local trigger  = groupTrigger['mainPanelAnimationStatus']
			if ((featureName) and (mainUI.featureMaintenance) and (mainUI.featureMaintenance[featureName])) then	-- fully hidden due to feature maintenance
				button:SetVisible(0)
			else
				button:SetVisible(1)
				if ((trigger.newGamePhase == 3) and ((trigger.newMain == -1) or (trigger.newMain == 40))) or (trigger.newMain == 101)  or (trigger.newMain == 1001) then		-- outro
					button:SetNoClick(1)
					RegisterRadialEase(self, nil, nil, true)
					libThread.threadFunc(function()
						self:DoEventN(8)
					end)
				elseif (trigger.gamePhase == 3) or ((trigger.main == 10) or (trigger.main == 11) or (trigger.main == 13)) or ((trigger.main == 101) and (trigger.newMain == -1)) or ((trigger.main == 1001) and (trigger.newMain == -1)) then			-- fully hidden
					button:SetNoClick(1)
					self:GetWidget('main_landing_buttons_1'):SetVisible(0)
				elseif (trigger.newMain ~= 101) and (trigger.newMain ~= -1) then		-- intro
					button:SetNoClick(1)
					self:GetWidget('main_landing_buttons_1'):SetVisible(1)
					if (not self:IsVisible()) then
						libThread.threadFunc(function()
							RegisterRadialEase(self, nil, nil, true)
							self:DoEventN(7)
						end)
					end
				elseif (trigger.main ~= 101) then										-- fully displayed
					libThread.threadFunc(function()
						wait(styles_mainSwapAnimationDuration)
						GetWidget(widgetName .. 'Button'):SetNoClick(0)
					end)
					if (not self:IsVisible()) then
						libThread.threadFunc(function()
							RegisterRadialEase(self, nil, nil, true)
							self:DoEventN(7)
						end)
					end					
					self:GetWidget('main_landing_buttons_1'):SetVisible(1)
					self:SetX(visibleX)
					self:SetY(visibleY)
				end
			end
		end, false, nil, 'main', 'newMain', 'gamePhase', 'newGamePhase')

		button:SetCallback('onclick', function(self)
			-- navButtonClick (top)
			-- PlaySound('/path_to/filename.wav')
			if (triggerPanelStatus.main == main) then
				triggerPanelStatus.main = 101
				triggerPanelStatus:Trigger(false)
				PlaySound('/ui/sounds/sfx_transition_3.wav')
			else
				triggerPanelStatus.main = main
				triggerPanelStatus:Trigger(false)
			end
		end)

		if featureName == 'crafting' then
			button:RegisterWatchLua('AccountInfo', function(button, trigger)
				button:SetEnabled(trigger.canCraft)
			end, false, nil, 'canCraft')
		end

		button:SetCallback('onmouseoverdisabled', function()
			if featureName == 'crafting' and (not LuaTrigger.GetTrigger('AccountInfo').canCraft) then
				simpleTipGrowYUpdate(true, nil, Translate('navigation_crafting_mustlevelaccount'), Translate('navigation_crafting_mustlevelaccount_tip'), libGeneral.HtoP(40))
			else
				simpleTipGrowYUpdate(true, nil, Translate('new_player_experience_mustfinishtutorial'), Translate('new_player_experience_mustfinishtutorial_tip'), libGeneral.HtoP(40))
			end
		end)
		button:SetCallback('onmouseoutdisabled', function() simpleTipGrowYUpdate(false) end)
		button:SetCallback('onmouseout', function() simpleTipGrowYUpdate(false) end)

	end

	TopNavRegisterButton('main_landing_button_1_0', 40, 'play')
	TopNavRegisterButton('main_landing_button_1_1', 2,  'pets')
	TopNavRegisterButton('main_landing_button_1_2', 1,  'crafting')
	-- TopNavRegisterButton('main_landing_button_1_3', 5,  'enchanting')
	TopNavRegisterButton('main_landing_button_1_5', 28,  'watch')

	-- ===============================

	-- pets
	GetWidget('main_landing_button_0_1_count_label_parent'):RegisterWatchLua('Corral', function(widget, trigger)
		widget:SetVisible(trigger.fruit > 0)
	end, false, nil, 'fruit')

	GetWidget('main_landing_button_0_1_count_label'):RegisterWatchLua('Corral', function(widget, trigger)
		local fruit		= trigger.fruit
		widget:SetText(math.floor(fruit))
	end)	-- , false, nil, 'fruit'

	GetWidget('main_landing_button_1_1_count_label_parent'):RegisterWatchLua('Corral', function(widget, trigger)
		widget:SetVisible(trigger.fruit > 0)
	end, false, nil, 'fruit')
	GetWidget('main_landing_button_1_1_count_label'):RegisterWatchLua('Corral', function(widget, trigger)
		local fruit		= trigger.fruit
		widget:SetText(math.floor(fruit))
	end)	-- , false, nil, 'fruit'

	GetWidget('main_landing_button_0_1Label2'):RegisterWatchLua('Corral', function(widget, trigger)
		if (trigger.fruit >= 3000) then
			GetWidget('main_landing_button_1_1_texture_alert'):FadeIn(500)
		else
			GetWidget('main_landing_button_1_1_texture_alert'):FadeOut(500)
		end
	end, false, nil, 'fruit')

	-- crafting
	GetWidget('main_landing_button_0_2_count_label_parent'):RegisterWatchLua('CraftingCommodityInfo', function(widget, trigger)
		widget:SetVisible(trigger.oreCount > 0)
	end, false, nil, 'oreCount')
	GetWidget('main_landing_button_0_2_count_label'):RegisterWatchLua('CraftingCommodityInfo', function(widget, trigger)
		widget:SetText(math.floor(trigger.oreCount))
	end, false, nil, 'oreCount')

	GetWidget('main_landing_button_1_2_count_label_parent'):RegisterWatchLua('CraftingCommodityInfo', function(widget, trigger)
		widget:SetVisible(trigger.oreCount > 0)
	end, false, nil, 'oreCount')
	GetWidget('main_landing_button_1_2_count_label'):RegisterWatchLua('CraftingCommodityInfo', function(widget, trigger)
		widget:SetText(math.floor(trigger.oreCount))
	end, false, nil, 'oreCount')

	GetWidget('main_landing_button_0_2Label2'):RegisterWatchLua('CraftingCommodityInfo', function(widget, trigger)
		if (trigger.oreCount >= 3000) then
			widget:SetText(Translate('crafting_have_a_lot_of_ore'))
			GetWidget('main_landing_button_1_2_texture_alert'):FadeIn(500)
		elseif (trigger.oreCount >= 360) then
			widget:SetText(Translate('crafting_craft_available'))
			GetWidget('main_landing_button_1_2_texture_alert'):FadeIn(500)
		else
			widget:SetText(Translate('mainmenu_crafting_2'))
			GetWidget('main_landing_button_1_2_texture_alert'):FadeOut(500)
		end
	end, false, nil, 'oreCount')

	-- watch
	GetWidget('main_landing_button_0_5_count_label_parent'):SetVisible(0)
	GetWidget('main_landing_button_1_5_count_label_parent'):SetVisible(0)

	-- play
	local function PlayUpdate(widget, trigger, isBig)
		local gamePhase	= trigger.gamePhase
		local isReady	= trigger.isReady
		local hasIdent	= trigger.hasIdent
		local isLoggedIn	= trigger.isLoggedIn
		local initialPetPicked	= trigger.initialPetPicked
		local getAllIdentGameDataStatus	= trigger.getAllIdentGameDataStatus
		local LeaverBan	= LuaTrigger.GetTrigger('UILeaverBan')

		if (trigger.missedGameAddress and (not Empty(trigger.missedGameAddress))) and (LuaTrigger.GetTrigger('ChatMissedGame').isRewarding) and (not LuaTrigger.GetTrigger('mainPanelStatus').leftLastGame) then	-- game started without you
			widget:SetText(Translate('general_reconnect'))
		elseif (trigger.reconnectShow and trigger.reconnectAddress and (not Empty(trigger.reconnectAddress)) and trigger.reconnectType and (not Empty(trigger.reconnectType)) ) and  (LuaTrigger.GetTrigger('ReconnectInfo').isRewarding) and (not LuaTrigger.GetTrigger('mainPanelStatus').leftLastGame)  then	-- you left a game, it's still going
			widget:SetText(Translate('general_reconnect'))
		elseif (trigger.updaterState == 1) and (isLoggedIn) and (hasIdent) then
			widget:SetText(Translate('main_label_update'))
		elseif (LeaverBan) and (LeaverBan.remainingBanSeconds) and (LeaverBan.remainingBanSeconds > 0) then
			local formattedRemaining = libNumber.timeFormat((LeaverBan.remainingBanSeconds) * 1000)
			widget:SetText(Translate('main_label_leaver2', 'value', formattedRemaining))
		elseif (isLoggedIn) and (hasIdent) then
			local party = (trigger.inParty and (trigger.numPlayersInParty > 1))

			widget:SetText('')
			if (not initialPetPicked) and (getAllIdentGameDataStatus ~= 1) then
				if (isBig) then
					widget:SetText(Translate('temp_signbutton_petselect'))
				else
					widget:SetText(Translate('temp_signbutton_petselect2'))
				end
			elseif (trigger.inQueue) then
				if (isBig) then
					widget:SetText(Translate('mainlobby_label_custom_searching'))
				else
					widget:SetText(Translate('general_play'))
				end
			elseif (party) then
				if (isBig) then
					widget:SetText(Translate(''))
				else
					widget:SetText(Translate('general_play'))
				end
			else
				if (isBig) then
					widget:SetText('')
				else
					widget:SetText(Translate('general_play'))
				end
			end
		end
	end

	local function PlayUpdateGraphics(widget, trigger, isBig)
		local party = (trigger.inParty and (trigger.numPlayersInParty > 1))

		if (isBig) then
			GetWidget('main_landing_button_0_0PartyButton'):SetVisible(party)
			GetWidget('main_landing_button_0_0BaseButton'):SetVisible(not party)
		else
			GetWidget('main_landing_button_1_0PartyButton'):SetVisible(party)
			GetWidget('main_landing_button_1_0BaseButton'):SetVisible(not party)
		end
	end

	GetWidget('main_landing_button_0_0Body'):RegisterWatchLua('mainPanelStatus', function(widget, trigger)
		PlayUpdateGraphics(widget, trigger, true)
	end, false, nil, 'inParty', 'numPlayersInParty')

	GetWidget('main_landing_button_0_0Label2'):RegisterWatchLua('mainPanelStatus', function(widget, trigger)
		PlayUpdate(widget, trigger, true)
	end, false, nil, 'reconnectShow', 'reconnectType', 'reconnectAddress', 'missedGameAddress', 'inQueue', 'inParty', 'numPlayersInParty', 'gamePhase', 'chatConnectionState', 'isReady', 'hasIdent', 'updaterState', 'initialPetPicked', 'getAllIdentGameDataStatus', 'isLoggedIn', 'main')

	GetWidget('main_landing_button_1_0Label'):RegisterWatchLua('mainPanelStatus', function(widget, trigger)
		PlayUpdate(widget, trigger, false)
	end, false, nil, 'reconnectShow', 'reconnectType', 'reconnectAddress', 'missedGameAddress', 'inQueue', 'inParty', 'numPlayersInParty', 'gamePhase', 'chatConnectionState', 'isReady', 'hasIdent', 'updaterState', 'initialPetPicked', 'getAllIdentGameDataStatus', 'isLoggedIn', 'main')

	GetWidget('main_landing_button_0_0Label2'):RegisterWatchLua('UILeaverBan', function(widget, trigger)
		if (trigger) and (trigger.remainingBanSeconds) and (trigger.remainingBanSeconds > -10) then
			PlayUpdate(widget, LuaTrigger.GetTrigger('mainPanelStatus'), true)
		end
	end, false, nil, 'now', 'bannedUntil', 'remainingBanSeconds')

	GetWidget('main_landing_button_1_0Label'):RegisterWatchLua('UILeaverBan', function(widget, trigger)
		if (trigger) and (trigger.remainingBanSeconds) and (trigger.remainingBanSeconds > -10) then
			PlayUpdate(widget, LuaTrigger.GetTrigger('mainPanelStatus'), false)
		end
	end, false, nil, 'now', 'bannedUntil', 'remainingBanSeconds')


	GetWidget('main_landing_button_1_0Body'):RegisterWatchLua('mainPanelStatus', function(widget, trigger)
		PlayUpdateGraphics(widget, trigger, false)
	end, false, nil, 'inParty', 'numPlayersInParty')
	GetWidget('main_landing_button_1_0_throb'):RegisterWatchLua('mainPanelStatus', function(widget, trigger)
		widget:SetVisible(trigger.inQueue)
	end, false, nil, 'inQueue')

	local function PlayNowClicked(isRightClick)
		local triggerPanelStatus		= LuaTrigger.GetTrigger('mainPanelStatus')
		local LeaverBan					= LuaTrigger.GetTrigger('UILeaverBan')
		-- soundEvent - Play Button Clicked

		if (triggerPanelStatus.missedGameAddress and (not Empty(triggerPanelStatus.missedGameAddress))) and (LuaTrigger.GetTrigger('ChatMissedGame').isRewarding) and (not LuaTrigger.GetTrigger('mainPanelStatus').leftLastGame) then	-- game started without you
			local reconnectAddress = triggerPanelStatus.missedGameAddress
			GenericDialog(
				'main_reconnect_header', '', 'main_reconnect_text', 'general_reconnect', 'general_cancel',
					function()
						-- soundEvent
						Connect(reconnectAddress)
					end,
					function()
						-- soundEvent - Cancel
						PlaySound('/ui/sounds/sfx_ui_back.wav')
					end
			)
		elseif (triggerPanelStatus.reconnectShow and triggerPanelStatus.reconnectAddress and (not Empty(triggerPanelStatus.reconnectAddress)) and triggerPanelStatus.reconnectType and (not Empty(triggerPanelStatus.reconnectType)) ) and (LuaTrigger.GetTrigger('ReconnectInfo').isRewarding) and (not LuaTrigger.GetTrigger('mainPanelStatus').leftLastGame) then	-- you left a game, it's still going
			local reconnectType = triggerPanelStatus.reconnectType
			local reconnectAddress = triggerPanelStatus.reconnectAddress
			local text = 'main_reconnect_text'
			-- allow them to reconnect or abandon the game
			if (LuaTrigger.GetTrigger('ReconnectInfo').isRewarding and not LuaTrigger.GetTrigger('ReconnectInfo').hasLeaver) then
				text = 'main_abandon_text'
			end	
			GenericDialog(
				'main_reconnect_header', '', text, 'general_reconnect', 'main_abandon',
					function()
						-- soundEvent
						if reconnectType == 'game' then
							Connect(reconnectAddress)
						elseif reconnectType == 'lobby' then
							ChatClient.JoinGame(reconnectAddress)
						end
					end,
					function()
						ChatClient.AbandonGame(LuaTrigger.GetTrigger('ReconnectInfo').gameUID)
					end)
						
		elseif (triggerPanelStatus.updaterState == 1) then
			Party.LeaveParty()
			GenericDialog(
				Translate('main_label_update'), Translate('main_label_update_avail'), '', Translate('general_ok'), Translate('general_cancel'),
					function()
						-- soundEvent - Confirm
						Client.Update()
					end,
					function()
						-- soundEvent - Cancel
						PlaySound('/ui/sounds/sfx_ui_back.wav')
						triggerPanelStatus.main = 101
						triggerPanelStatus:Trigger(false)
					end
			)
		elseif (not triggerPanelStatus.initialPetPicked) and (triggerPanelStatus.isLoggedIn) and (triggerPanelStatus.hasIdent) then
			triggerPanelStatus.main = 2
			triggerPanelStatus:Trigger(false)
		elseif (LeaverBan) and (LeaverBan.remainingBanSeconds) and (LeaverBan.remainingBanSeconds > 0) then
			local formattedRemaining = libNumber.timeFormat((LeaverBan.remainingBanSeconds) * 1000)
			GenericDialog(
				'main_label_leaver', '', Translate('main_label_leaver_long_desc', 'value', formattedRemaining), 'general_ok', '',
					function()
						-- soundEvent
					end,
					nil
			)
		else
			if ((mainUI.featureMaintenance) and (not mainUI.featureMaintenance['party'])) then
				if (triggerPanelStatus.main ~= 40) and (triggerPanelStatus.main ~= 24) then
					if (triggerPanelStatus.gamePhase ~= 1) or (LuaTrigger.GetTrigger('HeroSelectMode').mode == 'captains') then
						triggerPanelStatus.main = 40
						triggerPanelStatus:Trigger(false)
						PlaySound('/ui/sounds/sfx_ui_playbutton.wav')
					else
						triggerPanelStatus.main = 12
						triggerPanelStatus:Trigger(false)
						PlaySound('/ui/sounds/sfx_ui_playbutton.wav')
					end
				else
					triggerPanelStatus.main = 101
					triggerPanelStatus:Trigger(false)
					PlaySound('/ui/sounds/sfx_transition_3.wav')
				end
			elseif ((mainUI.featureMaintenance) and (not mainUI.featureMaintenance['lobby'])) then
				if (triggerPanelStatus.main ~= 24) and (triggerPanelStatus.main ~= 40) then
					if (triggerPanelStatus.gamePhase ~= 1) then
						triggerPanelStatus.main = 24
						triggerPanelStatus:Trigger(false)
						PlaySound('/ui/sounds/sfx_ui_playbutton.wav')
					else
						triggerPanelStatus.main = 12
						triggerPanelStatus:Trigger(false)
						PlaySound('/ui/sounds/sfx_ui_playbutton.wav')
					end
				else
					triggerPanelStatus.main = 101
					triggerPanelStatus:Trigger(false)
					PlaySound('/ui/sounds/sfx_transition_3.wav')
				end
			end
		end
	end

	GetWidget('main_landing_button_0_0Button'):SetCallback('onclick', function(widget)
		-- navButtonClick (side - play now)
		-- PlaySound('/path_to/filename.wav')
		PlayNowClicked(false)
	end)
	GetWidget('main_landing_button_0_0Button'):SetCallback('onrightclick', function(widget)
		-- navButtonRightClick (side - play now)
		-- PlaySound('/path_to/filename.wav')
		PlayNowClicked(true)
	end)
	GetWidget('main_landing_button_1_0Button'):SetCallback('onclick', function(widget)
		-- navButtonClick (top - play now)
		-- PlaySound('/path_to/filename.wav')
		PlayNowClicked(false)
	end)
	GetWidget('main_landing_button_1_0Button'):SetCallback('onrightclick', function(widget)
		-- navButtonRightClick (top - play now)
		-- PlaySound('/path_to/filename.wav')
		PlayNowClicked(true)
	end)

	local function CraftingClicked(isRightClick)
		local triggerPanelStatus		= LuaTrigger.GetTrigger('mainPanelStatus')
		if (triggerPanelStatus.main == 1) or (triggerPanelStatus.main == 5) or (triggerPanelStatus.main == 6) then
			triggerPanelStatus.main = 101
			triggerPanelStatus:Trigger(false)
		else
			triggerPanelStatus.main = 1
			triggerPanelStatus:Trigger(false)
		end
	end

	GetWidget('main_landing_button_0_2Button'):SetCallback('onclick', function(widget)
		-- navButtonClick (side - crafting)
		-- PlaySound('/path_to/filename.wav')
		CraftingClicked(false)
	end)
	GetWidget('main_landing_button_1_2Button'):SetCallback('onclick', function(widget)
		-- navButtonRightClick (top - crafting)
		-- PlaySound('/path_to/filename.wav')
		CraftingClicked(false)
	end)

	-- GetWidget('main_landing_button_0_1bButton'):SetCallback('onclick', function(widget)
		-- navButtonClick (side - form party)
		-- PlaySound('/path_to/filename.wav')
		-- Party.CreateParty()
	-- end)
	-- GetWidget('main_landing_button_0_1b'):SetCallback('onmouseover', function(widget)
		-- simpleTipGrowYUpdate(true, nil, Translate('mainmenu_form_party'), Translate('mainmenu_form_party_desc'))
	-- end)
	-- GetWidget('main_landing_button_0_1b'):SetCallback('onmouseout', function(widget)
		-- simpleTipGrowYUpdate(false)
	-- end)

	libGeneral.createGroupTrigger('craftProgressBarVisWatch', {
		'LoginStatus.isLoggedIn',
		'LoginStatus.hasIdent',
		'AccountInfo.canCraft',
		'AccountInfo.accountLevel',
		'AccountInfo.isIdentPopulated',
		'AccountProgression.level',
		'newPlayerExperience.tutorialComplete',
		'newPlayerExperience.tutorialProgress'
	})

	GetWidget('canCraftProgress'):RegisterWatchLua('craftProgressBarVisWatch', function(widget, groupTrigger)
		local triggerLogin		= groupTrigger['LoginStatus']
		local triggerAccount	= groupTrigger['AccountInfo']
		local AccountProgression	= groupTrigger['AccountProgression']
		local triggerNPE		= groupTrigger['newPlayerExperience']
		widget:SetVisible(triggerLogin.isLoggedIn and triggerLogin.hasIdent and (triggerNPE.tutorialComplete or triggerNPE.tutorialProgress >= NPE_PROGRESS_FINISHTUT3) and triggerAccount.isIdentPopulated and ((not triggerAccount.canCraft) or AccountProgression.level < mainUI.progression.CRAFTING_UNLOCK_LEVEL))
	end)


	libGeneral.createGroupTrigger('craftProgressBarWatch', {
		'AccountInfo.canCraft',
		'AccountInfo.accountLevel',
		'AccountProgression.percentToNextLevel',
		'AccountProgression.level',
	})

	GetWidget('canCraftProgressBar'):RegisterWatchLua('craftProgressBarWatch', function(widget, groupTrigger)
		local triggerAccount	= groupTrigger['AccountInfo']
		local triggerProg		= groupTrigger['AccountProgression']
		if not triggerAccount.canCraft and triggerProg.level < mainUI.progression.CRAFTING_UNLOCK_LEVEL then
			widget:SetWidth(ToPercent(
				(math.min((triggerProg.level / (mainUI.progression.CRAFTING_UNLOCK_LEVEL-1)), 1) * ((1/mainUI.progression.CRAFTING_UNLOCK_LEVEL) * (mainUI.progression.CRAFTING_UNLOCK_LEVEL - 1))) + (triggerProg.percentToNextLevel * 0.25)
			))
		end
	end)

end

navigationRegister(object)