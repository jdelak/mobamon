local function createAccountRegister(object)
	local container			= object:GetWidget('createAccountContainer')

	-- Buttons
	local submit			= object:GetWidget('createAccountSubmit')
	local haveAccount		= object:GetWidget('createAccountHaveAccount')
	local tosLabelButton	= object:GetWidget('createAccountTOSLabelButton')
	local createThrobber	= object:GetWidget('createAccountStatusThrob')

	-- Input
	local ident				= object:GetWidget('createAccountIdent')	-- Display Name
	local email				= object:GetWidget('createAccountEmail')
	local betaKey			= object:GetWidget('createAccountBetaKey')
	local password			= object:GetWidget('createAccountPassword')
	local password2			= object:GetWidget('createAccountPassword2')

	local uniqueID			= object:GetWidget('createAccountUniqueID')	-- Unused, hidden

	local TOSAcceptBox		= object:GetWidget('createAccountTOSAccept')
	local createAccountTOS	= object:GetWidget('createAccountTOS')

	local NewsletterAcceptBox		= object:GetWidget('createAccountNewsletterAccept')
	local createAccountNewsletter	= object:GetWidget('createAccountNewsletter')	
	
	-- Validation result
	local identUnique = false

	local function identValidate()
		local identValue = ident:GetValue()
		if not (identValue and string.len(identValue) >= 4) then
			GetWidget('createAccountIdent_label'):SetColor('red')
			return false
		else
			GetWidget('createAccountIdent_label'):SetColor('white')
		end
		return true
	end

	local function TOSAcceptValidate()
		local acceptValue = TOSAcceptBox:GetButtonState()
		if not (acceptValue == 1) then
			return false
		end
		return true
	end

	local function NewsletterAcceptValidate()
		local acceptValue = NewsletterAcceptBox:GetButtonState()
		if not (acceptValue == 1) then
			return false
		end
		return true
	end	
	
	local function emailValidate()
		local emailValue = email:GetValue()
		if not (emailValue and string.len(emailValue) > 0 and AtoB(object:UICmd("IsEmailAddress('"..emailValue.."')"))) then
			GetWidget('createAccountEmail_label'):SetColor('red')
			return false
		else
			GetWidget('createAccountEmail_label'):SetColor('white')
		end
		return true
	end

	local function uniqueIDValidate()
		local IDValue = uniqueID:GetValue()
		--[[
		if not (IDValue and string.len(IDValue) >= 4) then
			return false
		end
		--]]
		return true
	end

	local function passwordValidate()
		local passValue = password:GetValue()	
		if not (passValue and string.len(passValue) >= 3) then
			GetWidget('createAccountPassword_label'):SetColor('red')
			return false
		else
			GetWidget('createAccountPassword_label'):SetColor('white')
		end
		return true
	end
	
	local function passwordValidate2()
		local passValue = password:GetValue()	
		if (password:GetValue() ~= password2:GetValue()) then
			GetWidget('createAccountPassword2_label'):SetColor('red')
			return false
		else
			GetWidget('createAccountPassword2_label'):SetColor('white')
		end	
		return true
	end

	local function betaKeyValidate()
		local betaKeyValue = betaKey:GetValue()
		if not (betaKeyValue and string.len(betaKeyValue) >= 4) then
			GetWidget('createAccountBetaKey_label'):SetColor('red')
			return false
		else
			GetWidget('createAccountBetaKey_label'):SetColor('white')
		end
		return true
	end

	local function validate()
		local validForCreate = true	-- Failed checks invalidate this

		if not identValidate() then
			validForCreate = false
		end

		if not emailValidate() then
			validForCreate = false
		end

		if not betaKeyValidate() then
			validForCreate = false
		end

		if not uniqueIDValidate() then
			validForCreate = false
		end

		if not passwordValidate() then
			validForCreate = false
		end

		if not passwordValidate2() then
			validForCreate = false
		end

		if not TOSAcceptValidate() then
			validForCreate = false
		end

		if validForCreate then
			submit:SetEnabled(true)
		else
			submit:SetEnabled(false)
		end
	end

	password:SetCallback('onchange', validate)
	password2:SetCallback('onchange', validate)
	ident:SetCallback('onchange', validate)
	email:SetCallback('onchange', validate)
	betaKey:SetCallback('onchange', validate)
	uniqueID:SetCallback('onchange', validate)

	TOSAcceptBox:SetCallback('onclick', validate)
	NewsletterAcceptBox:SetCallback('onclick', validate)

	container:RegisterWatchLua('loginNPEStatus', function(widget, groupTrigger)
		local triggerNewPlayerExperience	= groupTrigger['newPlayerExperience']
		local triggerGamePhase				= groupTrigger['GamePhase']
		local triggerMainPanelStatus		= groupTrigger['mainPanelStatus']

		libGeneral.fade(container,
			( triggerMainPanelStatus.main == 50 and triggerGamePhase.gamePhase == 0 )
		, 250)
	end)

	local function haveAcountShowLogin()
	
		local triggerNPE = LuaTrigger.GetTrigger('newPlayerExperience')

		if not triggerNPE.tutorialComplete and triggerNPE.tutorialProgress <= NPE_PROGRESS_FINISHTUT2 then
			triggerNPE.showLogin = true
			triggerNPE:Trigger(false)
		end
	
		local mainPanelStatus = LuaTrigger.GetTrigger('mainPanelStatus')
		mainPanelStatus.main = 0
		mainPanelStatus:Trigger(false)


	end

	haveAccount:SetCallback('onclick', function(widget)
		haveAcountShowLogin()
	end)

	submit:SetEnabled(0)

	createAccountTOS:SetCallback('onclick', function(widget)
		local tosCheckState = TOSAcceptBox:GetButtonState()
		if tosCheckState == 1 then
			TOSAcceptBox:SetButtonState(0)
		else
			TOSAcceptBox:SetButtonState(1)
		end
		validate()
	end)

	createAccountNewsletter:SetCallback('onclick', function(widget)
		local NewsletterCheckState = NewsletterAcceptBox:GetButtonState()
		if NewsletterCheckState == 1 then
			NewsletterAcceptBox:SetButtonState(0)
		else
			NewsletterAcceptBox:SetButtonState(1)
		end
		validate()
	end)	
	
	tosLabelButton:SetCallback('onclick', function(widget)
		GenericDialogAutoSize(
			Translate('general_go_to_website'), Translate('general_go_to_view_tos'), '', 'general_ok', 'general_cancel',
				function()
					mainUI.OpenURL(Strife_Region.regionTable[Strife_Region.activeRegion].strifeWebsiteURL or 'http://www.strife.com')
				end,
				nil
		)
	end)	
	
	local function createAccountSuccess(request) -- response handler
		local responseData = request:GetBody()
		
		createThrobber:FadeOut(250)

		if responseData == nil then
			SevereError('CreateAccount - no response data', 'main_reconnect_thatsucks', '', nil, nil, false)
			return nil
		else
			print('Create account success.\n')
			-- printr(responseData)
			

			
			ident:EraseInputLine()
			betaKey:EraseInputLine()
			password2:EraseInputLine()

			Cvar.GetCvar('login_rememberName'):Set('false')
			Cvar.GetCvar('login_rememberPassword'):Set('false')
			Cvar.GetCvar('login_name'):Set('')
			Cvar.GetCvar('login_password'):Set('')
			object:GetWidget('loginUsernameBox'):SetInputLine(email:GetValue())
			object:GetWidget('loginPasswordBox'):SetInputLine(password:GetValue())
			password:EraseInputLine()
			email:EraseInputLine()
			
			GenericDialogAutoSize(
				'main_button_create_account', 'create_acc_success', '', 'general_login', nil,	-- 'general_cancel'
				function()
					PlaySound('/ui/sounds/sfx_ui_creategame_2.wav')
					haveAcountShowLogin()
					Login.AttemptLogin()
				end
			)

			return true
		end
	end

	local function createAccountFail(request) -- error handler
		createThrobber:FadeOut(250)
		return nil
	end

	submit:SetCallback('onclick', function(widget)
		print('Clicked submit for create account.\n')
		createThrobber:FadeIn(250)
		Strife_Web_Requests:CreateAccount(
			createAccountSuccess,
			createAccountFail,
			email:GetValue(),
			password:GetValue(),
			ident:GetValue(),		-- username
			'John',					-- firstName
			'Doe',					-- lastName
			betaKey:GetValue(),
			NewsletterAcceptBox:GetValue()
		)
	end)

end

createAccountRegister(object)