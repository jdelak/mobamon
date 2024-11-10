-- Track and update game progress

--[[
	responseData = {
	    identIncrement = "4"
	    shard = "002"
	    gameProgress = {
	        keyA = {
	            key = "keyA"
	            value = "1"
	        }
	    }
	    category = "singlePlayerExperience"
	}
--]]

libGameProgress = libGameProgress or {
	lastGetTime		= 0,
	lastIdentID		= nil,	-- Also serves to determine whether initialized
	requestThrottle	= 500,
	requestQueue	= {},	-- Not currently in use.  Ideally we'd want to filter requests through a queue until we can conslidate requests
	requestActive	= false
}

libGameProgress.loginCategories	= {		-- List of categories to update on login
	'newPlayerExperience',
	'singlePlayerExperience'
}

libGameProgress.currentProgress = GetAnonDBEntry('strife_db_gameProgress', libGameProgress.currentProgress, true, false, true) or {}

local gameProgressUpdate = LuaTrigger.CreateCustomTrigger('gameProgressUpdate', {
	{ name = 'lastUpdate',		type = 'number' }
})

libGeneral.createGroupTrigger('gameProgressLoginGroup', {
	'LoginStatus.isLoggedIn',
	'LoginStatus.hasIdent',
	'AccountInfo.identID'
})

local prioritizeString 	= true	-- Since we don't have any explicit rules for comparing strings to numbers, this at least allows us to determine which to prioritize
local valueBIsNewer		= true	-- Another assumption we have to make without knowing much about the data we're evaluating

function libGameProgress:findHighestValue(valueA, valueB)	-- Favor highest value / most populated.  Second return is whether valueB was returned
	if valueA ~= nil or valueB ~= nil then	-- There's a usable value somewhere
		if valueA == nil then				-- use B
			return valueB, true
		elseif valueB == nil then			-- use A
			return valueA, false
		elseif (type(valueA) == 'string' or type(valueA) == 'number') and (type(valueB) == 'string' or type(valueB) == 'number') then								-- neither is nil...
			local valueANumeric	= tonumber(valueA)
			local valueBNumeric	= tonumber(valueB)
			if valueANumeric ~= nil and valueBNumeric ~= nil then	-- both reasonably convert to number, return highest value
				if valueANumeric > valueBNumeric then
					return valueANumeric, false
				else
					return valueBNumeric, true
				end
			elseif valueANumeric == nil then	-- A is a string
				if prioritizeString then
					return valueA, false
				else
					return valueBNumeric, true
				end
			elseif valueBNumeric == nil then	-- B is a string
				if prioritizeString then
					return valueB, true
				else
					return valueANumeric, false
				end
			else	-- Both strings
				if string.len(valueA) == 0 then		-- A empty, whatever B has is the best we'll get
					return valueB, true
				elseif string.len(valueB) == 0 then	-- B empty, A is our best bet
					return valueA, false
				else								-- Both populated, need to guess at the newest value
					if valueBIsNewer then
						return valueB, true
					else
						return valueA, false
					end
				end
			end
		else				-- Neither is a string or a number, error
			return nil, nil
		end
	else					-- Both are nil, more or less an error state
		return nil, nil
	end
end

function libGameProgress:saveDB()
	GetAnonDBEntry('strife_db_gameProgress', libGameProgress.currentProgress, true, false, false)
	SaveState()
end

function libGameProgress:resetDB()
	libGameProgress.currentProgress = GetAnonDBEntry('strife_db_gameProgress', nil, true, true, false)
end

-- This may be more elaborate in the future, but generally this should occur whenever anything that would cause libGameProgress.currentProgress to update, regardless of change.
-- Generally, you'd slurp the relevant category from gameProgress and dump it into a trigger as necessary and let the firing trigger determine whether a change occurred (and how to handle it from there).
-- That way everything's not explicitly linked to a trigger but you can still attach that same behavior as necessary.
function libGameProgress:updateOccurred()
	gameProgressUpdate.lastUpdate = GetTime()
	gameProgressUpdate:Trigger(true)
	libGameProgress:saveDB()
end

function libGameProgress:updateAndEvaluateChange(category, key, value)
	libGameProgress:checkCreateCategory(category)
	local originalValue	= libGameProgress.currentProgress[category][key]
	local newValue = value

	if tonumber(value) ~= nil then
		newValue = tonumber(value)
	end

	libGameProgress.currentProgress[category][key] = newValue

	return (originalValue ~= newValue)
end

function libGameProgress:mergeFromWeb(webProgress, category)
	local localUpdated		= false
	local updateWebValues	= {}
	local inheritedValue	= false
	local newValue			= nil

	libGameProgress:checkCreateCategory(category)

	for k,v in pairs(webProgress) do	-- Update local from web as necessary
		newValue, inheritedValue = libGameProgress.findHighestValue(libGameProgress.currentProgress[category][k], v.value)
		if inheritedValue then
			localUpdated = true
			libGameProgress.currentProgress[category][k] = newValue
		end
	end

	for k,v in pairs(libGameProgress.currentProgress[category]) do
		if webProgress[k] then
			newValue, inheritedValue = libGameProgress.findHighestValue(webProgress[k].value, v)
		else
			newValue = v
			inheritedValue = true
		end

		if inheritedValue then
			updateWebValues[k] = newValue
		end
	end

	for k,v in pairs(updateWebValues) do
		libGameProgress:updateValue(category, k, v)
		-- libGameProgress:queueRequest(type, category, k, v)
	end

	if localUpdated then
		libGameProgress:updateOccurred()
	end
end

function libGameProgress:updateLocal(gameProgress, category, mergeData, doSave)	-- If not merge, assume incoming data is latest/newest
	doSave					= doSave or false
	mergeData				= mergeData or false	-- if not, use inherited data (typically from web)
	local lastUpdate		= nil
	local newValue			= nil
	local changeOccurred	= false
	local usedWeb			= nil

	libGameProgress:checkCreateCategory(category)

	for k,v in pairs(gameProgress) do
		if mergeData then
			newValue, usedWeb = libGameProgress.findHighestValue(libGameProgress.currentProgress[category][k], v.value)
		else
			newValue	= v.value
			usedWeb		= true
		end

		lastUpdate = libGameProgress:updateAndEvaluateChange(category, k, v.value)
		changeOccurred = changeOccurred or lastUpdate
	end

	if changeOccurred and doSave then
		libGameProgress:updateOccurred()
	end
end

function libGameProgress:get(category, key, mergeData)
	mergeData = mergeData or false

	local function successFunction(request)
		local responseData = request:GetBody()

		if responseData == nil then
			SevereError('libGameProgress:getProgress - no data', 'main_reconnect_thatsucks', '', nil, nil, false)
			return nil
		else
			if mergeData then
				libGameProgress:mergeFromWeb(responseData.gameProgress, category)
			else
				libGameProgress:updateLocal(responseData.gameProgress, category, mergeData, true)
			end
		end
	end

	local function failFunction(request)
		SevereError('libGameProgress:getProgress - request failed', 'main_reconnect_thatsucks', '', nil, nil, false)
	end

	Strife_Web_Requests:GetGameProgress(successFunction, failFunction, category, key)
end


function libGameProgress:create(category, key, value)
	local function successFunction(request)
		libGameProgress:processQueue()
		local responseData = request:GetBody()

		if responseData == nil then
			SevereError('libGameProgress:create - no data', 'main_reconnect_thatsucks', '', nil, nil, false)
			return nil
		else
			libGameProgress:updateLocal(responseData.gameProgress, category)
		end
	end

	local function failFunction(request)
		libGameProgress:processQueue()
		SevereError('libGameProgress:create - request failed', 'main_reconnect_thatsucks', '', nil, nil, false)
	end

	Strife_Web_Requests:CreateGameProgress(successFunction, failFunction, category, key, value)
end

function libGameProgress:setValue(category, key, value)
	local function successFunction(request)
		libGameProgress:processQueue()
		local responseData = request:GetBody()

		if responseData == nil then
			SevereError('libGameProgress:getValue - no data', 'main_reconnect_thatsucks', '', nil, nil, false)
			return nil
		else
			libGameProgress:updateLocal(responseData.gameProgress, category)
		end
	end

	local function failFunction(request)
		libGameProgress:processQueue()
		SevereError('libGameProgress:getValue - request failed', 'main_reconnect_thatsucks', '', nil, nil, false)
	end

	Strife_Web_Requests:SetGameProgressValue(successFunction, failFunction, category, key, value)
end

function libGameProgress:delete(category, key)

	local function successFunction(request)
		libGameProgress:processQueue()
		local responseData = request:GetBody()

		if responseData == nil then
			SevereError('libGameProgress:delete - no data', 'main_reconnect_thatsucks', '', nil, nil, false)
			return nil
		else
			libGameProgress.currentProgress[category][key] = nil
		end
	end

	local function failFunction(request)
		libGameProgress:processQueue()
		SevereError('libGameProgress:delete - request failed', 'main_reconnect_thatsucks', '', nil, nil, false)
	end

	Strife_Web_Requests:DeleteGameProgress(successFunction, failFunction, category, key)
end

function libGameProgress:isValidCategory(category)
	return (category and type(category) == 'string' and string.len(category) > 0)
end

function libGameProgress:isValidKeyValue(category, key)
	return (
		libGameProgress.currentProgress and
		libGameProgress.currentProgress[category] and
		libGameProgress.currentProgress[category][key] and
		(
			type(libGameProgress.currentProgress[category][key]) == 'number' or
			(
				type(libGameProgress.currentProgress[category][key]) == 'string' and
				string.len(libGameProgress.currentProgress[category][key]) > 0
			)
		)
	)
end

function libGameProgress:getLocalCategory(category)
	if libGameProgress:isValidCategory(category) then
		return libGameProgress.currentProgress[category]
	end
end

function libGameProgress:getLocalValue(category, key)
	if libGameProgress:isValidCategory(category) then
		if libGameProgress:isValidKeyValue(category, key) then
			return libGameProgress.currentProgress[category][key]
		end
	end
end

function libGameProgress:categoryKeyExists(category, key)
	if libGameProgress:isValidCategory(category) then
		if libGameProgress.currentProgress[category][key] and libGameProgress:isValidKeyValue(category, key) then
			return true
		end
	end
	return false
end

function libGameProgress:checkCreateCategory(category)	-- local only
	if libGameProgress:isValidCategory(category) then
		if libGameProgress.currentProgress and type(libGameProgress.currentProgress) == 'table' then
			if not libGameProgress.currentProgress[category] then
				libGameProgress.currentProgress[category] = {}
				return false	-- had to create category
			end
			return true	-- category existed
		end
	end
end

function libGameProgress:updateValue(category, key, value)
	libGameProgress:checkCreateCategory(category)
	local keyExists = libGameProgress:categoryKeyExists(category, key)
	local triggerLogin	= LuaTrigger.GetTrigger('LoginStatus')
	local loggedIn		= triggerLogin.isLoggedIn and triggerLogin.hasIdent

	if loggedIn then
		if keyExists then
			libGameProgress:setValue(category, key, value)
		else
			libGameProgress:create(category, key, value)
		end
	else
		local wasUpdated = libGameProgress:updateAndEvaluateChange(category, key, value)
		if wasUpdated then
			libGameProgress:updateOccurred()
		end
	end
end

function libGameProgress:doRequest(type, category, key, value, mergeData)
	libGameProgress.requestActive = true
	if type == 'update' then
		libGameProgress:updateValue(category, key, value)
	elseif type == 'get' then
		libGameProgress:get(category, key, mergeData)
	elseif type == 'delete' then
		libGameProgress:delete(category, key)
	end
end

function libGameProgress:processQueue()	-- Callback for finishing any request in the queue to allow executing the next queued request.  Basically pop a queue element and go to town
	local queuedRequest = table.remove(libGameProgress.requestQueue, 1)

	if queuedRequest then
		libGameProgress:doRequest(
			queuedRequest.type,
			queuedRequest.category,
			queuedRequest.key,
			queuedRequest.value,
			queuedRequest.mergeData
		)
	else	-- Done for now
		libGameProgress.requestActive = false
	end

end

function libGameProgress:queueRequest(type, category, key, value, mergeData)
	mergeData = mergeData or false


	if (not libGameProgress.requestActive) or true then	-- rmm actually implement queue system
		libGameProgress:doRequest(type, category, key, value, mergeData)
	else
		table.insert(libGameProgress.requestQueue, {
			type		= type,
			category	= category,
			key			= key,
			value		= value,
			mergeData	= mergeData or false
		})
	end
end

function libGameProgress:registerUITriggerUpdateValue(widget, trigger, category, key, value)
	if libGeneral.isValidWidget(widget) then
		if UITrigger.GetTrigger(trigger) then
			widget:RegisterWatch(trigger, function(widget)
				libGameProgress:updateValue(category, key, value)	-- rmm queue request
			end)
		else
			printr('libGameProgress:registerUITriggerUpdateValue - invalid trigger')
		end
	else
		printr('libGameProgress:registerUITriggerUpdateValue - invalid widget')
	end
end

function libGameProgress:registerUITriggerIterateValue(widget, trigger, category, key)
	if libGeneral.isValidWidget(widget) then
		if UITrigger.GetTrigger(trigger) then
			widget:RegisterWatch(trigger, function(widget)
				local currentValue = libGameProgress:getLocalValue(category, key)
				if tonumber(currentValue) then
					currentValue = currentValue + 1
				else
					currentValue = 1
				end
				libGameProgress:updateValue(category, key, currentValue)	-- rmm queue request
			end)
		else
			printr('libGameProgress:registerUITriggerIterateValue - invalid trigger')
		end
	else
		printr('libGameProgress:registerUITriggerIterateValue - invalid widget')
	end
end

libGameProgress:processQueue()	-- process any requests in the queue as necessary

UnwatchLuaTriggerByKey('gameProgressLoginGroup', 'gameProgressLoginWatch')
WatchLuaTrigger('gameProgressLoginGroup', function(groupTrigger)
	local triggerLogin	= groupTrigger['LoginStatus']
	local identID		= groupTrigger['AccountInfo'].identID
	if triggerLogin.isLoggedIn and triggerLogin.hasIdent then
		if libGameProgress.lastIdentID == nil then	-- No last ident - merge
			for k,v in ipairs(libGameProgress.loginCategories) do
				libGameProgress:queueRequest('get', v, nil, nil, true)
			end
		elseif libGameProgress.lastIdentID == identID then	-- Was previously working with the same ident
			for k,v in ipairs(libGameProgress.loginCategories) do
				libGameProgress:queueRequest('get', v, nil, nil, true)
			end
		else	-- Different ident, clean house
			for k,v in ipairs(libGameProgress.loginCategories) do
				libGameProgress.currentProgress[v] = {}
				libGameProgress:queueRequest('get', v, nil, nil, false)
			end
		end

		libGameProgress.lastIdentID = identID
	end
end, 'gameProgressLoginWatch')

-- libGameProgress:registerUITriggerUpdateValue(object:GetWidget('progressTestWidget'), 'progressTester', 'progressTest', 'testKey', 255)