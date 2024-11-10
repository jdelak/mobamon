-- new_game_minimapheader.lua (12/2014)
-- buttons / functionality of the area above the minimap

-- Updates the position of the minimap
function updateMinimapPosition()
	local swapSides = 1
	
	if GetCvarBool('ui_swapMinimap') then
		swapSides = -1
	end
	
	local object = gameGetInterface()
	
	local minimapContainers		= object:GetGroup('gameMinimapContainers')
	local minimapBG				= object:GetWidget('gameMinimapBG')
	local minimapBottomLeft		= object:GetWidget('gameMinimapBottomLeft')
	local minimapBottomRight	= object:GetWidget('gameMinimapBottomRight')
	local minimapTopLeft		= object:GetWidget('gameMinimapTopLeft')
	local minimapTopRight		= object:GetWidget('gameMinimapTopRight')
	
	local minimapHeader			= object:GetWidget('gameMinimapHeader')
	local minimapHeaderButtons	= object:GetWidget('gameMinimapHeaderButtons')
	
	local minimapMenu			= object:GetWidget('gameMinimapMenu')
	
	for k,v in ipairs(minimapContainers) do
		if (swapSides == 1) then
			v:SetAlign('right')
			v:SetX('1.7h')
		else
			v:SetAlign('left')
			v:SetX('-1.7h')
		end
	end
	
	if (swapSides == 1) then
		minimapBottomRight:SetVisible(true)
		minimapBottomLeft:SetVisible(false)
		minimapTopRight:SetVisible(true)
		minimapTopLeft:SetVisible(false)
		
		minimapHeader:SetAlign('right')
		minimapHeader:SlideY('-4.3h', 300)
		minimapHeaderButtons:SetAlign('right')
		minimapHeaderButtons:SetX('-2.5h')
		
		minimapMenu:SetX('-1.7h')
	else
		minimapBottomRight:SetVisible(false)
		minimapBottomLeft:SetVisible(true)
		minimapTopRight:SetVisible(false)
		minimapTopLeft:SetVisible(true)
		
		minimapHeader:SetAlign('left')
		minimapHeader:SlideY('-4.3h', 300)
		minimapHeaderButtons:SetAlign('left')
		minimapHeaderButtons:SetX('2.5h')
		
		minimapMenu:SetX('-2.5h')
	end
end
updateMinimapPosition()

-- registers the button row above the minimap
function registerMinimapButtons()

	local shopButtonHotkey	 		= object:GetWidget('gameMinimapButtonShopButton')
	local shopBacker	 			= object:GetWidget('gameMinimapButtonShopBacker')
	local shopButtonLabel 			= object:GetWidget('gameMinimapButtonShopLabel')

	local homeButton	 			= object:GetWidget('gameMinimapButtonHome')
	local homeCooldownText 			= object:GetWidget('gameMinimapButtonHomeCooldown')
	local homeCooldownPieUp 		= object:GetWidget('gameMinimapButtonHomeCooldownPieUp')
	local homeCooldownPieOver 		= object:GetWidget('gameMinimapButtonHomeCooldownPieOver')
	local homeCooldownPieDown 		= object:GetWidget('gameMinimapButtonHomeCooldownPieDown')
	local homeBacker	 			= object:GetWidget('gameMinimapButtonHomeMiniButtonBacker')
	local homeButtonHotkey			= object:GetWidget('gameMinimapButtonHomeMiniButtonButton')
	local homeButtonHotkeyLabel		= object:GetWidget('gameMinimapButtonHomeMiniButtonLabel')
		
	local courierButton	 			= object:GetWidget('gameMinimapButtonCourier')
	local courierBacker	 			= object:GetWidget('gameMinimapButtonCourierMiniButtonBacker')
	local courierButtonHotkey		= object:GetWidget('gameMinimapButtonCourierMiniButtonButton')
	local courierButtonHotkeyLabel	= object:GetWidget('gameMinimapButtonCourierMiniButtonLabel')

	local optionsButton	 			= object:GetWidget('gameMinimapButtonOptions')
	local optionsBacker	 			= object:GetWidget('gameMinimapButtonOptionsMiniButtonBacker')
	local optionsButtonHotkey		= object:GetWidget('gameMinimapButtonOptionsMiniButtonButton')
	local optionsButtonHotkeyLabel	= object:GetWidget('gameMinimapButtonOptionsMiniButtonLabel')
	
	local pingButton	 			= object:GetWidget('gameMinimapButtonPing')
	local pingBacker	 			= object:GetWidget('gameMinimapButtonPingMiniButtonBacker')
	local pingButtonHotkey			= object:GetWidget('gameMinimapButtonPingMiniButtonButton')
	local pingButtonHotkeyLabel		= object:GetWidget('gameMinimapButtonPingMiniButtonLabel')

	local object = object
	
	-- General hotkey display when tabbing
	local hotKeys = object:GetGroup('gameMinimapHotkeys')

	for k,v in ipairs(hotKeys) do
		gameHelper.registerWatchVisible(v, 'ModifierKeyStatus', 'moreInfoKey')


		v:SetCallback('onmouseover', function(widget)
			UpdateCursor(widget, true, { canLeftClick = true})
		end)
		
		v:SetCallback('onmouseout', function(widget)
			UpdateCursor(widget, false, { canLeftClick = true})
		end)
	end
	
	-- register home button
	function registerHomeButton()
		homeBacker:RegisterWatchLua('ModifierKeyStatus', function(widget, trigger)			
			if trigger.moreInfoKey then
				widget:SetColor(styles_colors_hotkeyCanSet)
				widget:SetBorderColor(styles_colors_hotkeyCanSet)
			else
				widget:SetColor('1 1 1 1')
				widget:SetBorderColor('1 1 1 1')		
			end
		end)
		
		homeButton:RegisterWatchLua('gamePanelInfo', function(widget, trigger)
			widget:SetVisible(trigger.mapWidgetVis_portHomeButton)
		end, false, nil, 'mapWidgetVis_portHomeButton')
		
		gameHelper.registerMiniButton('gameMinimapButtonHome', 'ActiveInventory8', 'icon', function() ActivateTool(8) end)

		homeButton:SetCallback('onclick', function(widget)
			ActivateTool(8)
		end)
		
		homeButtonHotkey:SetCallback('onmouseover', function(widget)
			simpleTipNoFloatUpdate(true, nil, Translate('game_keybind_1'), Translate('game_keybind_2', 'value', GetKeybindButton('game', 'TriggerToggle', 'gameShowMoreInfo', 0)), nil, nil, libGeneral.HtoP(-18), 'center', 'bottom')
			UpdateCursor(widget, true, { canLeftClick = true})
		end)
		
		homeButtonHotkey:SetCallback('onmouseout', function(widget)
			simpleTipNoFloatUpdate(false)
			UpdateCursor(widget, false, { canLeftClick = true})
		end)		
		
		homeButtonHotkey:SetCallback('onclick', function(widget)
			PlaySound('/ui/sounds/sfx_button_generic.wav')

			local binderData			= LuaTrigger.GetTrigger('buttonBinderData')
			local oldButton				= nil
			binderData.allowMoreInfoKey	= false
			binderData.show				= true
			binderData.table			= 'game'
			binderData.action			= 'ActivateTool'
			binderData.param			= '8'
			binderData.keyNum			= 0	-- 0 for leftclick, 1 for rightclick
			binderData.impulse			= false
			binderData.oldButton		= (GetKeybindButton('game', 'ActivateTool', '8', 0) or 'None')
			binderData:Trigger()
		end)

		homeButton:SetCallback('onmouseover', function(widget)
			UpdateCursor(widget, true, { canLeftClick = true})
		end)
		
		homeButton:SetCallback('onmouseout', function(widget)
			UpdateCursor(widget, false, { canLeftClick = true})
		end)

		homeButtonHotkeyLabel:RegisterWatchLua('ActiveInventory8', function(widget, trigger)
			widget:SetText(trigger.binding1)
		end, true, nil, 'binding1')

		-- homebutton cooldown
		homeCooldownText:RegisterWatchLua('ActiveInventory8', function(widget, trigger)
			local cooldownTime = trigger.remainingCooldownTime
			widget:SetVisible(cooldownTime > 0)
			widget:SetText(math.floor(cooldownTime * 0.001) .. 's')
		end, true, nil, 'remainingCooldownTime')

	
		-- for some reason, Lua hates this object
		homeCooldownPieUp:RegisterWatchLua('ActiveInventory8', function(widget, trigger)
			local percent = trigger.remainingCooldownPercent
			widget:SetVisible(percent > 0)
			widget:SetValue(percent)
		end, true, nil, 'remainingCooldownPercent')
		
		homeCooldownPieOver:RegisterWatchLua('ActiveInventory8', function(widget, trigger)	
			local percent = trigger.remainingCooldownPercent
			widget:SetVisible(percent > 0)
			widget:SetValue(percent)
		end, true, nil, 'remainingCooldownPercent')
		
		homeCooldownPieDown:RegisterWatchLua('ActiveInventory8', function(widget, trigger)
			local percent = trigger.remainingCooldownPercent
			widget:SetVisible(percent > 0)
			widget:SetValue(percent)
		end, true, nil, 'remainingCooldownPercent')
	
	end

	-- register shop button
	function registerShopButton()
		shopBacker:RegisterWatchLua('ModifierKeyStatus', function(widget, trigger)			
			if trigger.moreInfoKey then
				widget:SetColor(styles_colors_hotkeyCanSet)
				widget:SetBorderColor(styles_colors_hotkeyCanSet)
			else
				widget:SetColor('1 1 1 1')
				widget:SetBorderColor('1 1 1 1')		
			end
		end)
	
		shopButtonHotkey:SetCallback('onclick', function(widget)
			local tabDown = LuaTrigger.GetTrigger('ModifierKeyStatus').moreInfoKey

			if not tabDown then
				ToggleShop()
			else
				PlaySound('/ui/sounds/sfx_button_generic.wav')

				local binderData			= LuaTrigger.GetTrigger('buttonBinderData')
				local oldButton				= nil
				binderData.allowMoreInfoKey	= false
				binderData.show				= true
				binderData.table			= 'game'
				binderData.action			= 'ToggleShop'
				binderData.param			= ''
				binderData.keyNum			= 0	-- 0 for leftclick, 1 for rightclick
				binderData.impulse			= true
				binderData.oldButton		= (GetKeybindButton('game', 'ToggleShop', '', 0) or 'None')
				binderData:Trigger()
			end
		end)
		
		shopButtonHotkey:SetCallback('onmouseover', function(widget)
			simpleTipNoFloatUpdate(true, nil, Translate('game_keybind_1'), Translate('game_keybind_2', 'value', GetKeybindButton('game', 'TriggerToggle', 'gameShowMoreInfo', 0)), nil, nil, libGeneral.HtoP(-18), 'center', 'bottom')
			UpdateCursor(widget, true, { canLeftClick = true})
		end)
		
		shopButtonHotkey:SetCallback('onmouseout', function(widget)
			simpleTipNoFloatUpdate(false)
			UpdateCursor(widget, false, { canLeftClick = true})
		end)

		shopButtonLabel:RegisterWatchLua('gameRefreshKeyLabels', function(widget, trigger)
			local binding = GetKeybindButton('game', 'ToggleShop', '', 0)
			shopButtonLabel:SetText(binding or '')
		end, true, nil)

		local binding = GetKeybindButton('game', 'ToggleShop' , '', 0)
		shopButtonLabel:SetText(binding or '')
	end

	-- register courier button
	function registerCourierButton()
		courierBacker:RegisterWatchLua('ModifierKeyStatus', function(widget, trigger)			
			if trigger.moreInfoKey then
				widget:SetColor(styles_colors_hotkeyCanSet)
				widget:SetBorderColor(styles_colors_hotkeyCanSet)
			else
				widget:SetColor('1 1 1 1')
				widget:SetBorderColor('1 1 1 1')		
			end
		end)
		
		courierButton:RegisterWatchLua('gamePanelInfo', function(widget, trigger)
			widget:SetVisible(trigger.mapWidgetVis_courierButton)
		end, false, nil, 'mapWidgetVis_courierButton')
		
		courierButton:SetCallback('onclick', function()
			ActivateTool(11)
		end)
		
		courierButton:SetCallback('onmouseover', function(widget)
			UpdateCursor(widget, true, { canLeftClick = true})
		end)
		
		courierButton:SetCallback('onmouseout', function(widget)
			UpdateCursor(widget, false, { canLeftClick = true})
		end)
	
		gameHelper.registerMiniButton('gameMinimapButtonCourier', 'ActiveInventory11', 'icon')

		courierButtonHotkey:SetCallback('onmouseover', function(widget)
			simpleTipNoFloatUpdate(true, nil, Translate('game_keybind_1'), Translate('game_keybind_2', 'value', GetKeybindButton('game', 'TriggerToggle', 'gameShowMoreInfo', 0)), nil, nil, libGeneral.HtoP(-18), 'center', 'bottom')
			UpdateCursor(widget, true, { canLeftClick = true})
		end)
		
		courierButtonHotkey:SetCallback('onmouseout', function(widget)
			simpleTipNoFloatUpdate(false)
			UpdateCursor(widget, false, { canLeftClick = true})
		end)		
		
		courierButtonHotkey:SetCallback('onclick', function(widget)
			PlaySound('/ui/sounds/sfx_button_generic.wav')

			local binderData			= LuaTrigger.GetTrigger('buttonBinderData')
			local oldButton				= nil
			binderData.allowMoreInfoKey	= false
			binderData.show				= true
			binderData.table			= 'game'
			binderData.action			= 'ActivateTool'
			binderData.param			= '11'
			binderData.keyNum			= 0	-- 0 for leftclick, 1 for rightclick
			binderData.impulse			= false
			binderData.oldButton		= (GetKeybindButton('game', 'ActivateTool', '11', 0) or 'None')
			binderData:Trigger()
		end)

		courierButtonHotkeyLabel:RegisterWatchLua('ActiveInventory11', function(widget, trigger)
			widget:SetText(trigger.binding1)
		end, true, nil, 'binding1')

	end

	-- register options button
	function registerOptionsButton()
		local gameMenuParent = object:GetWidget('game_menu_parent')
		local gameMenuClose  = object:GetWidget('game_menu_close')
		
		optionsBacker:RegisterWatchLua('ModifierKeyStatus', function(widget, trigger)			
			if trigger.moreInfoKey then
				widget:SetColor(styles_colors_hotkeyCanSet)
				widget:SetBorderColor(styles_colors_hotkeyCanSet)
			else
				widget:SetColor('1 1 1 1')
				widget:SetBorderColor('1 1 1 1')		
			end
		end)

		-- This turns the menu on
		optionsButton:SetCallback('onclick', function()
			if not gameMenuParent:IsVisible() then
				gameMenuParent:FadeIn(200)
			else
				gameMenuParent:FadeOut(150)
			end
		end)
		
		optionsButton:SetCallback('onmouseover', function(widget)
			UpdateCursor(widget, true, { canLeftClick = true})
		end)
		
		optionsButton:SetCallback('onmouseout', function(widget)
			UpdateCursor(widget, false, { canLeftClick = true})
		end)
		
		-- This turns the menu off
		if gameMenuClose then
			gameMenuClose:SetCallback('onclick', function()
				gameMenuParent:SetVisible(not gameMenuParent:IsVisible())
			end)
		end

		optionsButtonHotkey:SetCallback('onmouseover', function(widget)
			simpleTipNoFloatUpdate(true, nil, Translate('game_keybind_1'), Translate('game_keybind_2', 'value', GetKeybindButton('game', 'TriggerToggle', 'gameShowMoreInfo', 0)), nil, nil, libGeneral.HtoP(-18), 'center', 'bottom')
			UpdateCursor(widget, true, { canLeftClick = true})
		end)
		
		optionsButtonHotkey:SetCallback('onmouseout', function(widget)
			simpleTipNoFloatUpdate(false)
			UpdateCursor(widget, false, { canLeftClick = true})
		end)			
		
		optionsButtonHotkey:SetCallback('onclick', function(widget)
			PlaySound('/ui/sounds/sfx_button_generic.wav')

			local binderData	= LuaTrigger.GetTrigger('buttonBinderData')
			local oldButton		= nil
			binderData.show			= true
			binderData.table		= 'game'
			binderData.action		= 'TriggerToggle'
			binderData.param		= 'gameToggleMenu'
			binderData.keyNum		= 0	-- 0 for leftclick, 1 for rightclick
			binderData.impulse		= false
			binderData.oldButton	= (GetKeybindButton('game', 'TriggerToggle', 'gameToggleMenu', 0) or 'None')
			binderData:Trigger()
		end)

		optionsButtonHotkeyLabel:RegisterWatchLua('gameRefreshKeyLabels', function(widget, trigger)
			local binding = GetKeybindButton('game', 'TriggerToggle', 'gameToggleMenu', 0) 
			widget:SetText(binding or '')
		end, true, nil)

		local binding = GetKeybindButton('game', 'TriggerToggle', 'gameToggleMenu', 0) 
		optionsButtonHotkeyLabel:SetText(binding or '')
	end

	-- register the ping button
	function registerPingButton()
		pingBacker:RegisterWatchLua('ModifierKeyStatus', function(widget, trigger)			
			if trigger.moreInfoKey then
				widget:SetColor(styles_colors_hotkeyCanSet)
				widget:SetBorderColor(styles_colors_hotkeyCanSet)
			else
				widget:SetColor('1 1 1 1')
				widget:SetBorderColor('1 1 1 1')		
			end
		end)
		
		pingButton:SetCallback('onclick', function()
			if GetLocalHeroLocation then
				local worldPos = GetLocalHeroLocation()
				--local startX = tonumber(string.sub(trigger.mousePos, 0, string.find(trigger.mousePos, " ")))
				--local startY = tonumber(string.sub(trigger.mousePos,    string.find(trigger.mousePos, " ")+1))
				if (worldPos) then
					openRadialCommand(1, 0, 0, worldPos, 1)
				end
			end
		end)
		
		pingButton:SetCallback('onmouseover', function(widget)
			UpdateCursor(widget, true, { canLeftClick = true})
		end)
		
		pingButton:SetCallback('onmouseout', function(widget)
			UpdateCursor(widget, false, { canLeftClick = true})
		end)

		pingButtonHotkey:SetCallback('onmouseover', function(widget)
			simpleTipNoFloatUpdate(true, nil, Translate('game_keybind_1'), Translate('game_keybind_2', 'value', GetKeybindButton('game', 'TriggerToggle', 'gameShowMoreInfo', 0)), nil, nil, libGeneral.HtoP(-18), 'center', 'bottom')
			UpdateCursor(widget, true, { canLeftClick = true})
		end)
		
		pingButtonHotkey:SetCallback('onmouseout', function(widget)
			simpleTipNoFloatUpdate(false)
			UpdateCursor(widget, false, { canLeftClick = true})
		end)		
		
		pingButtonHotkey:SetCallback('onclick', function(widget)
			PlaySound('/ui/sounds/sfx_button_generic.wav')

			local binderData			= LuaTrigger.GetTrigger('buttonBinderData')
			local oldButton				= nil
			binderData.allowMoreInfoKey	= false
			binderData.show				= true
			binderData.table			= 'game'
			binderData.action			= 'ActivateTool'
			binderData.param			= '8'
			binderData.keyNum			= 0	-- 0 for leftclick, 1 for rightclick
			binderData.impulse			= false
			binderData.oldButton		= (GetKeybindButton('game', 'ActivateTool', '8', 0) or 'None')
			binderData:Trigger()
		end)

	end	
	
	registerHomeButton()
	registerShopButton()
	registerCourierButton()
	registerOptionsButton()
	registerPingButton()
end