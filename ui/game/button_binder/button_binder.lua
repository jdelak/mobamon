-- General-purpose button binder (for use in main, game, etc.)

buttonBinderLastUIWidget = object

function buttonBinderRegister(object)
	local root					= object:GetWidget('buttonBinder')
	local container				= object:GetWidget('buttonBinderContainer')
	local containerWidth		= container:GetWidth()
	local containerHeight		= container:GetHeight()
	local closeButton			= object:GetWidget('buttonBinderClose')
	local buttonCatcher			= object:GetWidget('buttonBinderCatcher')
	local buttonCatcherImpulse	= object:GetWidget('buttonBinderCatcherImpulse')
	
	
	local modifierCTRL			= object:GetWidget('buttonBinderModifierCTRL')
	local modifierALT			= object:GetWidget('buttonBinderModifierALT')
	local modifierSHIFT			= object:GetWidget('buttonBinderModifierSHIFT')
	
	local buttonRegistry		= {}

	local bindData				= LuaTrigger.GetTrigger('buttonBinderData')
	bindData.show				= false
	bindData.table				= 'game'
	bindData.action				= ''
	bindData.param				= ''
	bindData.oldButton			= ''
	bindData.keyNum				= 0
	bindData.impulse			= false
	bindData.useCtrl			= false
	bindData.useAlt				= false
	bindData.useShift			= false
	
	bindData.allowMoreInfoKey	= false
	
	local function open(isImpulse)
		isImpulse = isImpulse or false

		buttonCatcher:SetVisible( not isImpulse )
		buttonCatcherImpulse:SetVisible(isImpulse)

		if not isImpulse then
			bindData.useCtrl			= false
			bindData.useAlt				= false
			bindData.useShift			= false

			-- Actually checking these for now as we might have them resume their prior state later on
			
			if bindData.useCtrl then
				modifierCTRL:SetButtonState(1)
			else
				modifierCTRL:SetButtonState(0)
			end
			
			if bindData.useAlt then
				modifierALT:SetButtonState(1)
			else
				modifierALT:SetButtonState(0)
			end
			
			if bindData.useShift then
				modifierSHIFT:SetButtonState(1)
			else
				modifierSHIFT:SetButtonState(0)
			end
			
		end
		
		-- sound_buttonBinderOpen
		-- PlaySound('path_to/filename.wav')
		
		root:FadeIn(100)
		libAnims.bounceIn(container, containerWidth, containerHeight, true, 300, nil, nil, 0.8, 0.2)
	end

	local function close()
		bindData.show = false
		bindData:Trigger(false)
		local triggerRefresh = LuaTrigger.GetTrigger('gameRefreshKeyLabels')
		if triggerRefresh then
			triggerRefresh.time = GetTime()
			triggerRefresh:Trigger(false)
		end
	end
	
	object:GetWidget('buttonBinderChooseModifier'):RegisterWatchLua('buttonBinderData', function(widget, trigger)
		widget:SetVisible(not trigger.impulse)
	end, false, nil, 'impulse')
	
	root:RegisterWatchLua('buttonBinderData', function(widget, trigger)
		if trigger.show then
			open(trigger.impulse)
		else
			container:FadeOut(150)
			root:FadeOut(150)
		end
	end, false, nil, 'show')

	modifierCTRL:RegisterWatchLua('buttonBinderData', function(widget, trigger)
		if trigger.useCtrl then
			widget:SetButtonState(1)
		else
			widget:SetButtonState(0)
		end
		
	end, false, nil, 'useCtrl')
	modifierALT:RegisterWatchLua('buttonBinderData', function(widget, trigger)
		if trigger.useAlt then
			widget:SetButtonState(1)
		else
			widget:SetButtonState(0)
		end
	end, false, nil, 'useAlt')
	
	modifierSHIFT:RegisterWatchLua('buttonBinderData', function(widget, trigger)
		if trigger.useShift then
			widget:SetButtonState(1)
		else
			widget:SetButtonState(0)
		end
	end, false, nil, 'useShift')
	
	
	local function resumeNonImpulseCatcherFocus()
		buttonCatcher:SetFocus(true)
	end
	
	modifierCTRL:SetCallback('onclick', function(widget)
		bindData.useCtrl = (not bindData.useCtrl)
		bindData:Trigger(false)
		resumeNonImpulseCatcherFocus()
	end)
	modifierALT:SetCallback('onclick', function(widget)
		bindData.useAlt = (not bindData.useAlt)
		bindData:Trigger(false)
		resumeNonImpulseCatcherFocus()
	end)
	modifierSHIFT:SetCallback('onclick', function(widget)
		bindData.useShift = (not bindData.useShift)
		bindData:Trigger(false)
		resumeNonImpulseCatcherFocus()
	end)
	
	
	object:GetWidget('buttonBinderDefault'):SetCallback('onclick', function(widget)
		local oldButton	= bindData.oldButton
		local bindTable	= bindData.table
		local action	= bindData.action
		local param		= bindData.param
		local keyNum	= bindData.keyNum
		Cmd('Unbind '..bindTable..' '..oldButton)
		Cmd('DefaultGameBind '..keyNum..' '..bindTable..' '..action..' "'..param..'"')
	
		PlaySound('/ui/sounds/sfx_button_generic.wav')
		buttonBinderLastUIWidget:UICmd("Refresh()")
		close()
	end)
	
	
	object:GetWidget('buttonBinderClear'):SetCallback('onclick', function(widget)
		local oldButton	= bindData.oldButton
		local bindTable	= bindData.table
		local action	= bindData.action
		local param		= bindData.param
		local bindCmd	= 'BindButton '

		if impulse then
			bindCmd = 'BindImpulse '
		end

		Cmd('Unbind '..bindTable..' '..oldButton)
		Cmd(bindCmd..bindTable..' '..' INVALID '..' '..action..' "'..param..'"')

		PlaySound('/ui/sounds/sfx_button_generic.wav')
		buttonBinderLastUIWidget:UICmd("Refresh()")
		close()
	end)
	
	object:GetWidget('buttonBinderCancel'):SetCallback('onclick', function(widget)
		PlaySound('/ui/sounds/sfx_button_generic.wav')
		close()
	end)
	
	closeButton:SetCallback('onclick', function(widget)
		PlaySound('/ui/sounds/sfx_button_generic.wav')
		close()
	end)

	function catchButton(widget, caughtButton)
		local oldButton		= bindData.oldButton
		local bindTable		= bindData.table
		local action		= bindData.action
		local param			= bindData.param
		local impulse		= bindData.impulse
		local bindCmd		= 'BindButton '
		local moreInfoKey	= GetKeybindButton('game', 'TriggerToggle', 'gameShowMoreInfo', 0)
		local buttonPrefix	= ''
		
		print('catch with '..tostring(caughtButton)..'\n')
		
		if not impulse then
			if caughtButton == 'CTRL' or caughtButton == 'ALT' or caughtButton == 'SHIFT' then
				return
			end
		end
		
		if (bindData.allowMoreInfoKey or not (moreInfoKey ~= nil and caughtButton == moreInfoKey)) and caughtButton ~= 'MOUSEL' and caughtButton ~= 'MOUSER' then
			if impulse then
				bindCmd = 'BindImpulse '
			else
				if bindData.useCtrl then
					buttonPrefix = 'CTRL+'..buttonPrefix
				end
				
				if bindData.useAlt then
					buttonPrefix = 'ALT+'..buttonPrefix
				end
				
				if bindData.useShift then
					buttonPrefix = 'SHIFT+'..buttonPrefix
				end
				
			end

			if oldButton and oldButton ~= 'None' then
				Cmd('Unbind '..bindTable..' '..oldButton)
			end

			-- print('command to bind is '..bindCmd..bindTable..' '..caughtButton..' '..action..' "'..param..'"\n')
			Cmd(bindCmd..bindTable..' '..buttonPrefix..caughtButton..' '..action..' "'..param..'"')
			
			-- buttonBinderRebindKey
			PlaySound('/shared/sounds/ui/tutorial/popup_show_1.mp3')
			buttonBinderLastUIWidget:UICmd("Refresh()")
			
			LuaTrigger.GetTrigger('optionsTrigger').isSynced = false
			SetSave('cg_cloudSynced', 'false', 'bool')
			LuaTrigger.GetTrigger('optionsTrigger'):Trigger(true)
			
			close()
		end
	end

	buttonCatcher:SetCallback( 'onbutton', catchButton )
	buttonCatcherImpulse:SetCallback( 'onbutton', catchButton )
end

buttonBinderRegister(object)