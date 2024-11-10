libGameAnalytics = libGameAnalytics or {}

function libGameAnalytics:validLogin()
	local triggerLogin = LuaTrigger.GetTrigger('LoginStatus')
	return (triggerLogin.isLoggedIn and triggerLogin.hasIdent)
end

function libGameAnalytics:isValidValue(value)
	return ( value and ( type(value) == 'number' or ( type(value) == 'string' and string.len(value) > 0 ) ) )
end

function libGameAnalytics:isValidCategory(category)
	return (category and type(category) == 'string' and string.len(category) > 0)
end

function libGameAnalytics:isValidKey(key)
	return (key and type(key) == 'string' and string.len(key) > 0)
end

function libGameAnalytics:iterateValue(category, key)
	if not libGameAnalytics:validLogin() then
		SevereError('libGameAnalytics:iterateValue - must be logged in.', 'main_reconnect_thatsucks', '', nil, nil, false)
		return
	end

	if not libGameAnalytics:isValidCategory(category) then
		SevereError('libGameAnalytics:iterateValue - invalid category.', 'main_reconnect_thatsucks', '', nil, nil, false)
		return
	end

	if not libGameAnalytics:isValidKey(key) then
		SevereError('libGameAnalytics:iterateValue - invalid key.', 'main_reconnect_thatsucks', '', nil, nil, false)
		return
	end

	local function successFunction(request)
		local responseData = request:GetBody()

		if responseData == nil then
			SevereError('libGameAnalytics:iterateValue - no data', 'main_reconnect_thatsucks', '', nil, nil, false)
			return nil
		else
			-- eh
		end
	end

	local function failFunction(request)
		SevereError('libGameAnalytics:iterateValue - request failed', 'main_reconnect_thatsucks', '', nil, nil, false)
	end

	Strife_Web_Requests:IncrementGameAnalytics(successFunction, failFunction, category, key)
end

function libGameAnalytics:create(category, key, value)
	if not libGameAnalytics:validLogin() then
		SevereError('libGameAnalytics:create - must be logged in.', 'main_reconnect_thatsucks', '', nil, nil, false)
		return
	end

	if not libGameAnalytics:isValidCategory(category) then
		SevereError('libGameAnalytics:create - invalid category.', 'main_reconnect_thatsucks', '', nil, nil, false)
		return
	end

	if not libGameAnalytics:isValidKey(key) then
		SevereError('libGameAnalytics:create - invalid key.', 'main_reconnect_thatsucks', '', nil, nil, false)
		return
	end

	if not libGameAnalytics:isValidValue(category) then
		SevereError('libGameAnalytics:create - invalid value.', 'main_reconnect_thatsucks', '', nil, nil, false)
		return
	end

	local function successFunction(request)
		local responseData = request:GetBody()

		if responseData == nil then
			SevereError('libGameAnalytics:create - no data', 'main_reconnect_thatsucks', '', nil, nil, false)
			return nil
		else
			-- eh
		end
	end

	local function failFunction(request)
		SevereError('libGameAnalytics:create - request failed', 'main_reconnect_thatsucks', '', nil, nil, false)
	end

	Strife_Web_Requests:CreateGameAnalytics(successFunction, failFunction, category, key, value)
end

function libGameAnalytics:set(category, key, value)
	if not libGameAnalytics:validLogin() then
		SevereError('libGameAnalytics:set - must be logged in.', 'main_reconnect_thatsucks', '', nil, nil, false)
		return
	end

	if not libGameAnalytics:isValidCategory(category) then
		SevereError('libGameAnalytics:set - invalid category.', 'main_reconnect_thatsucks', '', nil, nil, false)
		return
	end

	if not libGameAnalytics:isValidKey(key) then
		SevereError('libGameAnalytics:set - invalid key.', 'main_reconnect_thatsucks', '', nil, nil, false)
		return
	end

	if not libGameAnalytics:isValidValue(category) then
		SevereError('libGameAnalytics:set - invalid value.', 'main_reconnect_thatsucks', '', nil, nil, false)
		return
	end

	local function successFunction(request)
		local responseData = request:GetBody()

		if responseData == nil then
			SevereError('libGameAnalytics:set - no data', 'main_reconnect_thatsucks', '', nil, nil, false)
			return nil
		else
			-- eh
		end
	end

	local function failFunction(request)
		SevereError('libGameAnalytics:set - request failed', 'main_reconnect_thatsucks', '', nil, nil, false)
	end

	Strife_Web_Requests:SetGameAnalyticsValue(successFunction, failFunction, category, key, value)
end

-- ================================================================

function libGameAnalytics:registerUITriggerSetValue(widget, trigger, category, key, value)
	if libGeneral.isValidWidget(widget) then
		if UITrigger.GetTrigger(trigger) then
			widget:RegisterWatch(trigger, function(widget)
				libGameAnalytics:set(category, key, value)
			end)
		else
			printr('libGameAnalytics:registerUITriggerSetValue - invalid trigger')
		end
	else
		printr('libGameAnalytics:registerUITriggerSetValue - invalid widget')
	end
end

function libGameAnalytics:registerUITriggerCreate(widget, trigger, category, key, value)
	if libGeneral.isValidWidget(widget) then
		if UITrigger.GetTrigger(trigger) then
			widget:RegisterWatch(trigger, function(widget)
				libGameAnalytics:create(category, key, value)
			end)
		else
			printr('libGameAnalytics:registerUITriggerCreate - invalid trigger')
		end
	else
		printr('libGameAnalytics:registerUITriggerCreate - invalid widget')
	end
end

function libGameAnalytics:registerUITriggerIterateValue(widget, trigger, category, key)
	if libGeneral.isValidWidget(widget) then
		if UITrigger.GetTrigger(trigger) then
			widget:RegisterWatch(trigger, function(widget)
				libGameAnalytics:iterateValue(category, key)
			end)
		else
			printr('libGameProgress:registerUITriggerIterateValue - invalid trigger')
		end
	else
		printr('libGameProgress:registerUITriggerIterateValue - invalid widget')
	end
end
