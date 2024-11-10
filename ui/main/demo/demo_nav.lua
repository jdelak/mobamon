
local function demoNavRegister(object)
		
	mainUI 									= mainUI 									or {}
	mainUI.savedLocally 					= mainUI.savedLocally 						or {}	
	mainUI.savedLocally.currentFeature 		= mainUI.savedLocally.currentFeature 		or 'menu'	

	local parent = object:GetWidget('demo_navigation_screen_parent')
	local skipLobby = false
	
	parent:UnregisterWatchLua('GamePhase')
	parent:RegisterWatchLua('GamePhase', function(widget, trigger)
		if trigger.gamePhase == 1 and skipLobby then
			skipLobby = false
			RequestBotFill()
			RequestBotDifficulty('easy')
			Lobby.isFilledWithBots = true
			-- RequestMatchStart()
		end
	end)	
	
	parent:RegisterWatchLua('mainPanelAnimationStatus', function(widget, trigger)
		local animState = mainSectionAnimState(1001, trigger.main, trigger.newMain)
		
		local function hide(object)
			parent:SetVisible(false)
		end
		
		local function show(object)
			parent:SetVisible(true)
		end

		local function intro(object)
			libThread.threadFunc(function()	
				wait(100)
				PlaySound('/ui/sounds/sfx_transition_2.wav')
				groupfcall('demo_navigation_animation_widgets', function(_, widget) RegisterRadialEase(widget,  nil, nil, true) widget:DoEventN(7) end)	
			end)
		end
		
		local function outro(object)
			libThread.threadFunc(function()	
				groupfcall('demo_navigation_animation_widgets', function(_, widget) RegisterRadialEase(widget,  nil, nil, true) widget:DoEventN(8) end)			
			end)		
		end		
		
		if animState == 1 then
			outro(object)
		elseif animState == 2 then
			hide(object)
		elseif animState == 3 then
			intro(object)
		elseif animState == 4 then
			show(object)
			if (mainUI.Analytics) then
				mainUI.Analytics.AddFeatureStartInstance('menu')
			end
		end
	end, false, nil, 'main', 'newMain')

	
	local function demoButtonRegister(index, buttonTable)
		local button = object:GetWidget('demoNav_playScreenOption' .. index ..'Button')
		
		button:SetCallback('onclick', function(widget)
			buttonTable[1]()
		end)
	end

	local demoButton1 = {function() 
		if (mainUI.Analytics) then
			mainUI.Analytics.AddFeatureStartInstance('npe_1')
		end
		PlaySound('/ui/sounds/sfx_ui_creategame_2.wav')
		libThread.threadFunc(function()	
			wait(styles_mainSwapAnimationDuration)
			ManagedSetLoadingInterface('loading_npe_1')
			StartGame('tutorial', Translate('game_name_default_tutorial'), 'map:tutorial nolobby:true')
		end)
	end} 
	
	local demoButton2 = {function()
		if (mainUI.Analytics) then
			mainUI.Analytics.AddFeatureStartInstance('npe_2')
		end
		PlaySound('/ui/sounds/sfx_ui_creategame_2.wav')
		libThread.threadFunc(function()
			wait(styles_mainSwapAnimationDuration)
			ManagedSetLoadingInterface('loading_npe_2')
			StartGame('tutorial', Translate('game_name_default_tutorial'), 'map:tutorial_2 nolobby:true')
		end)			
	end}	
	
	local demoButton3 = { function() 
		if (mainUI.Analytics) then
			mainUI.Analytics.AddFeatureStartInstance('spe_1')
		end
		PlaySound('/ui/sounds/sfx_ui_creategame_2.wav')
		ManagedSetLoadingInterface('loading_bastion_1')
		StartGame('tutorial', Translate('game_name_default_tutorial'), 'map:bastact1 nolobby:true', '-vid_d9')
	end} 	
	
	local demoButton4 = {function()
		if (mainUI.Analytics) then
			mainUI.Analytics.AddFeatureStartInstance('bot_match')
		end
		PlaySound('/ui/sounds/sfx_ui_creategame_2.wav')
		libThread.threadFunc(function()
			skipLobby = true	
			SetSave('ui_hideDevMenu', 'true', 'bool')
			wait(styles_mainSwapAnimationDuration)
			StartGame('practice', Translate('game_name_default_practice'), 'map:strife nolobby:false fillbots:true dev:false finalheroesonly:true')
		end)
	end}	
	
	demoButtonRegister(1, demoButton1)
	demoButtonRegister(2, demoButton2)
	demoButtonRegister(3, demoButton3)
	demoButtonRegister(4, demoButton4)
	
	Strife_Web_Requests = Strife_Web_Requests or {}
	local interface = object
	function Strife_Web_Requests:DemoSignUp(emailAddress)
		
		if (emailAddress) and (not Empty(emailAddress)) then
			
			println('^y Strife_Web_Requests:DemoSignUp: emailAddress ' .. emailAddress)
			
			local request1 = self:SpawniGamesRequest('/paxPrimeSignup')
			request1:SetRequestMethod('POST')	

			request1:AddVariable('email', emailAddress)
			request1:SendRequest(true)

			local main_demo_ui_signup_parent 			= interface:GetWidget('main_demo_ui_signup_parent')
			local main_demo_ui_signup_input 			= interface:GetWidget('main_demo_ui_signup_input')
			local main_demo_ui_signup_submit 			= interface:GetWidget('main_demo_ui_signup_submit')
			local main_demo_ui_signup_response 			= interface:GetWidget('main_demo_ui_signup_response')
			local main_demo_ui_signup_response_label 	= interface:GetWidget('main_demo_ui_signup_response_label')			
			
			request1:ManagedWait(
				function (request)	-- response handler
					local responseData = request:GetBody()
					
					if responseData == nil then
					
						main_demo_ui_signup_response:SetVisible(1)
						main_demo_ui_signup_response_label:SetText(Translate('main_simple_email_response_0'))	-- main_simple_email_response_0
						main_demo_ui_signup_response:Sleep(3500, function(widget)
							widget:FadeOut(750)
						end)		
					
					
						SevereError('DemoSignUp no response', 'main_reconnect_thatsucks', '', nil, nil, false)
						return nil
					else
						
						main_demo_ui_signup_response:SetVisible(1)
						main_demo_ui_signup_response_label:SetText(Translate('main_simple_email_response_1'))
						main_demo_ui_signup_response:Sleep(2500, function(widget)
							widget:FadeOut(750)
						end)				
						main_demo_ui_signup_input:SetInputLine('')					
						
						mainUI.Analytics.AddFeatureFinishInstance('signup')
						
						return responseData
					end
				end,
				function (request)	-- error handler
				
					main_demo_ui_signup_response:SetVisible(1)
					main_demo_ui_signup_response_label:SetText(Translate('main_simple_email_response_0'))	-- main_simple_email_response_0
					main_demo_ui_signup_response:Sleep(3500, function(widget)
						widget:FadeOut(750)
					end)		
				
					SevereError('DemoSignUp Request Error: ' .. Translate(request:GetError()), 'main_reconnect_thatsucks', '', nil, nil, false)
					return nil
				end
			)
		else
			SevereError('Strife_Web_Requests:DemoSignUp - invalid emailAddress: '.. tostring(emailAddress), 'main_reconnect_thatsucks', '', nil, nil, false)
			main_demo_ui_signup_response:SetVisible(1)
			main_demo_ui_signup_response_label:SetText(Translate('main_simple_email_response_0'))	-- main_simple_email_response_0
			main_demo_ui_signup_response:Sleep(3500, function(widget)
				widget:FadeOut(750)
			end)				
		end
	end

	local main_demo_ui_signup_parent 			= object:GetWidget('main_demo_ui_signup_parent')
	local main_demo_ui_signup_input 			= object:GetWidget('main_demo_ui_signup_input')
	local main_demo_ui_signup_submit 			= object:GetWidget('main_demo_ui_signup_submit')
	local main_demo_ui_signup_response 			= object:GetWidget('main_demo_ui_signup_response')
	local main_demo_ui_signup_response_label 	= object:GetWidget('main_demo_ui_signup_response_label')

	local function SubmitEmail()
		local value = main_demo_ui_signup_input:GetValue()
		if (value) and (string.len(value) >= 5) then
			NewPlayerExperience.data.signupEmails = NewPlayerExperience.data.signupEmails or {}
			table.insert(NewPlayerExperience.data.signupEmails, value)
			Strife_Web_Requests:DemoSignUp(value)	-- local response = 
		end		
	end

	main_demo_ui_signup_parent:SetCallback('onevent', function(widget)
		SubmitEmail()
	end)

	main_demo_ui_signup_submit:SetCallback('onclick', function(widget)
		-- main_simpleUI_signup_submit
		PlaySound('ui/sounds/sfx_ui_login.wav')
		SubmitEmail()
		mainUI.Analytics.AddFeatureStartInstance('signup')
	end)

	main_demo_ui_signup_input:SetCallback('onchange', function(widget)
		local value = widget:GetValue()
		if (value) and (string.len(value) >= 5) then
			main_demo_ui_signup_submit:SetEnabled(1)
		else
			main_demo_ui_signup_submit:SetEnabled(0)
		end
	end)

end

if GetCvarBool('ui_PAXDemo') then
	demoNavRegister(object)
end




