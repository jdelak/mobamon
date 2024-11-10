if NewPlayerExperience.isNPEDemo() then

	Strife_Web_Requests = Strife_Web_Requests or {}
	local interface = object
	function Strife_Web_Requests:DemoSignUp(emailAddress)
		
		if (emailAddress) and (not Empty(emailAddress)) then
			
			println('^y Strife_Web_Requests:DemoSignUp: emailAddress ' .. emailAddress)
			
			local request1 = self:SpawnRequest(GetIdentID(), '/betaSignup')
			request1:SetRequestMethod('POST')	

			request1:AddVariable('email', emailAddress)
			-- request1:AddVariable('betaKey', '') -- removed
			request1:AddVariable('secret', 'abc123')
			request1:AddVariable('wantsNotifications', '1')
			request1:SendRequest(true)

			local main_simple_ui_signup_parent 		= interface:GetWidget('main_simple_ui_signup_parent')
			local main_simple_ui_signup_input 		= interface:GetWidget('main_simple_ui_signup_input')
			local main_simple_ui_signup_submit 		= interface:GetWidget('main_simple_ui_signup_submit')
			local main_simple_ui_signup_response 	= interface:GetWidget('main_simple_ui_signup_response')
			local main_simple_ui_signup_response_label 	= interface:GetWidget('main_simple_ui_signup_response_label')			
			
			request1:ManagedWait(
				function (request)	-- response handler
					local responseData = request:GetBody()
					
					if responseData == nil then
					
						main_simple_ui_signup_response:SetVisible(1)
						main_simple_ui_signup_response_label:SetText(Translate('main_simple_email_response_1'))	-- main_simple_email_response_0
						main_simple_ui_signup_response:Sleep(3500, function(widget)
							widget:FadeOut(750)
						end)
						main_simple_ui_signup_input:SetInputLine('')			
					
					
						SevereError('DemoSignUp no response', 'main_reconnect_thatsucks', '', nil, nil, false)
						return nil
					else
						
						main_simple_ui_signup_response:SetVisible(1)
						main_simple_ui_signup_response_label:SetText(Translate('main_simple_email_response_1'))
						main_simple_ui_signup_response:Sleep(2500, function(widget)
							widget:FadeOut(750)
						end)				
						main_simple_ui_signup_input:SetInputLine('')					
						
						return responseData
					end
				end,
				function (request)	-- error handler
				
					main_simple_ui_signup_response:SetVisible(1)
					main_simple_ui_signup_response_label:SetText(Translate('main_simple_email_response_1'))	-- main_simple_email_response_0
					main_simple_ui_signup_response:Sleep(3500, function(widget)
						widget:FadeOut(750)
					end)
					main_simple_ui_signup_input:SetInputLine('')			
				
					SevereError('DemoSignUp Request Error: ' .. Translate(request:GetError()), 'main_reconnect_thatsucks', '', nil, nil, false)
					return nil
				end
			)
		else
			SevereError('Strife_Web_Requests:DemoSignUp - invalid emailAddress: '.. tostring(emailAddress), 'main_reconnect_thatsucks', '', nil, nil, false)
		end
	end

	local main_simple_ui_signup_parent 		= object:GetWidget('main_simple_ui_signup_parent')
	local main_simple_ui_signup_input 		= object:GetWidget('main_simple_ui_signup_input')
	local main_simple_ui_signup_submit 		= object:GetWidget('main_simple_ui_signup_submit')
	local main_simple_ui_signup_response 	= object:GetWidget('main_simple_ui_signup_response')
	local main_simple_ui_signup_response_label 	= object:GetWidget('main_simple_ui_signup_response_label')

	local function SubmitEmail()
		local value = main_simple_ui_signup_input:GetValue()
		if (value) and (string.len(value) >= 5) then
			NewPlayerExperience.data.signupEmails = NewPlayerExperience.data.signupEmails or {}
			table.insert(NewPlayerExperience.data.signupEmails, value)
			Strife_Web_Requests:DemoSignUp(value)	-- local response = 
		end		
	end

	main_simple_ui_signup_parent:SetCallback('onevent', function(widget)
		SubmitEmail()
	end)

	main_simple_ui_signup_submit:SetCallback('onclick', function(widget)
		-- main_simpleUI_signup_submit
		PlaySound('ui/sounds/sfx_ui_login.wav')
		SubmitEmail()
	end)

	main_simple_ui_signup_input:SetCallback('onchange', function(widget)
		local value = widget:GetValue()
		if (value) and (string.len(value) >= 5) then
			main_simple_ui_signup_submit:SetEnabled(1)
		else
			main_simple_ui_signup_submit:SetEnabled(0)
		end
	end)

	GetWidget('main_simple_ui_signup_parent'):SetVisible(1)	
	
end
