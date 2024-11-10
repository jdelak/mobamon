-------------------------------------------------------------------------------
-- (C)2013 S2 Games
-------------------------------------------------------------------------------
local _G = getfenv(0)
local ipairs, pairs, select, string, table, next, type, unpack, tinsert, tconcat, tremove, format, tostring, tonumber, tsort, ceil, floor, sub, find, gfind = _G.ipairs, _G.pairs, _G.select, _G.string, _G.table, _G.next, _G.type, _G.unpack, _G.table.insert, _G.table.concat, _G.table.remove, _G.string.format, _G.tostring, _G.tonumber, _G.table.sort, _G.math.ceil, _G.math.floor, _G.string.sub, _G.string.find, _G.string.gfind
local interface, interfaceName = object, object:GetName()

local loginStatus = LuaTrigger.GetTrigger('LoginStatus')
local gamePhase = LuaTrigger.GetTrigger('GamePhase')
local lastLoadFromWeb

mainUI 					= mainUI 					or {}
mainUI.savedLocally 	= mainUI.savedLocally 		or {}
mainUI.savedRemotely 	= mainUI.savedRemotely 		or {}
mainUI.savedAnonymously	= mainUI.savedAnonymously 	or {}
mainUI.loadedLocally 		= false
mainUI.loadedRemotely 		= false
mainUI.loadedAnonymously	= false

function SaveDBToWeb()
	if IsFullyLoggedIn(GetIdentID()) and (mainUI.savedRemotely) and (gamePhase.gamePhase == 0) and ((Strife_Region.regionTable) and (Strife_Region.regionTable[Strife_Region.activeRegion]) and (Strife_Region.regionTable[Strife_Region.activeRegion].enableCloudStorage)) then
		if (Strife_DB) and (Strife_DB.current) and (Strife_DB.current.unixTimestamp) then	
			if (false) then
				GetOptionsToSaveToWeb()
				
				mainUI.savedRemotely.unixTimestamp		= Strife_DB.current.unixTimestamp
				
				local function encodeData()
					return JSON:encode(mainUI.savedRemotely)
				end			
				
				local encodeSuccess, encodeData = pcall(encodeData)

				if (encodeSuccess) and (encodeData) then
					local optionsTrigger = LuaTrigger.GetTrigger('optionsTrigger')
					local function successFunction(request)
						SetSave('cg_cloudSynced', 'true', 'bool')
						optionsTrigger.isSynced = true
						optionsTrigger:Trigger(true)
					end
					local function failFunction(request)
						SetSave('cg_cloudSynced', 'false', 'bool')
						optionsTrigger.isSynced = false
						optionsTrigger:Trigger(true)
					end
				
					SetSave('cg_cloudSynced', 'false', 'bool')
					SetPlayerResources('lua_db_5', encodeData, successFunction, failFunction)
					-- println('^g SaveDBToWeb ')
				else
					SevereError('Failed to encode data SaveDBToWeb ' .. tostring(encodeData), 'main_reconnect_thatsucks', '', nil, nil, false)
					printr(mainUI.savedRemotely)
				end
			else
				GetOptionsToSaveToWeb()
				
				mainUI.savedRemotely.unixTimestamp		= Strife_DB.current.unixTimestamp
				
				local tableOfJSONValues = {}
				local count = 0
				for index, value in pairs(mainUI.savedRemotely) do
					local function encodeData()
						return JSON:encode(value)
					end						
					local encodeSuccess, encodeData = pcall(encodeData)
					if (encodeSuccess) and (encodeData) and (encodeData ~= '[]') then
						-- table.insert(tableOfJSONValues, encodeData)
						tableOfJSONValues[index] = encodeData
						count = count + 1
					end
				end

				if (tableOfJSONValues) and (count > 0) then
					local optionsTrigger = LuaTrigger.GetTrigger('optionsTrigger')
					local function successFunction(request)
						SetSave('cg_cloudSynced', 'true', 'bool')
						optionsTrigger.isSynced = true
						optionsTrigger:Trigger(true)
					end
					local function failFunction(request)
						SetSave('cg_cloudSynced', 'false', 'bool')
						optionsTrigger.isSynced = false
						optionsTrigger:Trigger(true)
					end
				
					SetSave('cg_cloudSynced', 'false', 'bool')
					Strife_Web_Requests:SaveCloudStorage(successFunction, failFunction, tableOfJSONValues)
				else
					SevereError('Failed to encode data SaveDBToWeb ' .. tostring(encodeData), 'main_reconnect_thatsucks', '', nil, nil, false)
					printr(mainUI.savedRemotely)
				end			
			end
		end
	end
end

function LoadDBFromWeb(forceLoad)
	if IsFullyLoggedIn(GetIdentID()) and (gamePhase.gamePhase == 0) and ((Strife_Region.regionTable) and (Strife_Region.regionTable[Strife_Region.activeRegion]) and (Strife_Region.regionTable[Strife_Region.activeRegion].enableCloudStorage)) then
		if (false) then
			local function successFunction(request)	-- response handler
				local responseData = request:GetBody()
				if responseData == nil then
					-- SevereError('GetPlayerResources - no data', 'main_reconnect_thatsucks', '', nil, nil, false)
					return nil
				else
					if (responseData) and (responseData.playerResources) and (responseData.playerResources.lua_db_5) then
						
						-- println('^y LoadDBFromWeb responseData ')
						
						-- println('^y responseData.playerResources.lua_db_5 ' .. tostring(responseData.playerResources.lua_db_5) )
						
						local function decodeData()
							return JSON:decode(responseData.playerResources.lua_db_5)
						end
						
						local decodeSuccess, decodedData = pcall(decodeData)
						if (decodeSuccess) and (decodedData) then

							lastLoadFromWeb = GetIdentID()

							if (forceLoad) or (((not Strife_DB) or (not Strife_DB.current) or (not Strife_DB.current.unixTimestamp)) and (decodedData.unixTimestamp)) or (decodedData.unixTimestamp and tonumber(decodedData.unixTimestamp) and (Strife_DB) and (Strife_DB.current) and (Strife_DB.current.unixTimestamp) and tonumber(Strife_DB.current.unixTimestamp) and (tonumber(decodedData.unixTimestamp) > tonumber(Strife_DB.current.unixTimestamp))) then
								println('^c LoadDBFromWeb ')
								GenericDialogAutoSize(
									'cloud_storage_mismatch', 'cloud_storage_mismatch_desc_1', FormatDateTime(decodedData.unixTimestamp, '%#I:%M %p %B %d, %Y', true), 'cloud_storage_mismatch_btn_1', 'cloud_storage_mismatch_btn_2', 
										function()
											mainUI.savedRemotely = decodedData
											Strife_Options:LoadOptionsFromWeb()
											LuaTrigger.GetTrigger('optionsTrigger').isSynced = true
											SetSave('cg_cloudSynced', 'true', 'bool')
											SaveState()
										end,
										function()
											SaveState()
											SaveDBToWeb()
										end
								)
							else
								-- println('^y LoadDBFromWeb ')
							end
						else
							println('^r LoadDBFromWeb ')
							SevereError('Failed to decode data LoadDBFromWeb ' .. tostring(decodedData), 'main_reconnect_thatsucks', '', nil, nil, false)
						end
					end
				end
			end				
			
			local function failureFunction(request)	-- error handler
				SevereError('GetPlayerResources Request Error: ' .. Translate(request:GetError() or ''), 'main_reconnect_thatsucks', '', nil, nil, false)
				return nil
			end	

			Strife_Web_Requests:GetPlayerResources(successFunction, failureFunction)
		else
			local function successFunction(request)	-- response handler
				local responseData = request:GetBody()
				if responseData == nil then
					return nil
				else
					if (responseData) and (responseData.gameProgress) then
			
						local tableOfValues = {}
						local count = 0
						for index, value in pairs(responseData.gameProgress) do
							local function decodeData()
								return JSON:decode(value)
							end					
							local decodeSuccess, decodedData = pcall(decodeData)
							if (decodeSuccess) and (decodedData) then
								-- table.insert(tableOfValues, decodedData)
								tableOfValues[index] = decodedData
								count = count + 1
							end
						end
						
						if (tableOfValues) and (count > 0) then

							lastLoadFromWeb = GetIdentID()

							if (forceLoad) or (((not Strife_DB) or (not Strife_DB.current) or (not Strife_DB.current.unixTimestamp)) and (tableOfValues.unixTimestamp)) or (tableOfValues.unixTimestamp and tonumber(tableOfValues.unixTimestamp) and (Strife_DB) and (Strife_DB.current) and (Strife_DB.current.unixTimestamp) and tonumber(Strife_DB.current.unixTimestamp) and (tonumber(tableOfValues.unixTimestamp) > tonumber(Strife_DB.current.unixTimestamp))) then
								println('^c LoadDBFromWeb ')
								GenericDialogAutoSize(
									'cloud_storage_mismatch', 'cloud_storage_mismatch_desc_1', FormatDateTime(tableOfValues.unixTimestamp, '%#I:%M %p %B %d, %Y', true), 'cloud_storage_mismatch_btn_1', 'cloud_storage_mismatch_btn_2', 
										function()
											mainUI.savedRemotely = tableOfValues
											Strife_Options:LoadOptionsFromWeb()
											LuaTrigger.GetTrigger('optionsTrigger').isSynced = true
											SetSave('cg_cloudSynced', 'true', 'bool')
											SaveState()
										end,
										function()
											SaveState()
											SaveDBToWeb()
										end
								)
							else
								-- println('^y LoadDBFromWeb ')
							end
						else
							println('^r LoadDBFromWeb ')
							println('no data from LoadDBFromWeb ' .. tostring(tableOfValues))
							printr(responseData)
						end
					end
				end
			end				
			
			local function failureFunction(request)	-- error handler
				SevereError('GetCloudStorage Request Error: ' .. Translate(request:GetError() or ''), 'main_reconnect_thatsucks', '', nil, nil, false)
				return nil
			end	

			Strife_Web_Requests:GetCloudStorage(successFunction, failureFunction)	
		end
	end
end

function GetAnonDBEntry(entry, value, saveToDB, restoreDefault, setDefault)	
	
	Strife_Anon_DB = Strife_Anon_DB or Database.New('Strife_Anon_DB.ldb')
	Strife_Anon_DB.current = Strife_Anon_DB.current or {}
	Strife_Anon_DB.default = Strife_Anon_DB.default or {}	
	
	if (entry) then	
		--println('^g DB GetEntry: ' .. tostring(entry) .. ' | ' .. ' value: ' .. tostring(value) .. ' | ' .. ' saveToDB: ' .. tostring(saveToDB) .. ' | ' .. ' restoreDefault: ' .. tostring(restoreDefault)  .. ' | ' .. ' setDefault: ' .. tostring(setDefault) )
		if (value) then	
			if (Strife_Anon_DB.default[entry]) and (not setDefault) then				
				if (restoreDefault) then				
					Strife_Anon_DB.current[entry] = Strife_Anon_DB.default[entry]
					Strife_Anon_DB.current.unixTimestamp		= '' .. tostring(LuaTrigger.GetTrigger('System').unixTimestamp) .. ''
					Strife_Anon_DB:Flush()
					--println('^y DB Restore default entry: ' .. tostring(entry)) 
					return Strife_Anon_DB.default[entry], false, true					
				elseif (saveToDB) then				
					Strife_Anon_DB.current[entry] = value
					Strife_Anon_DB.current.unixTimestamp		= '' .. tostring(LuaTrigger.GetTrigger('System').unixTimestamp) .. ''
					Strife_Anon_DB:Flush()
					--println('^y DB Save to db entry: ' .. tostring(entry))
					return value, false, true					
				else
					--println('^y DB loading entry 1: ' .. tostring(entry))
					return Strife_Anon_DB.current[entry], false, false	
				end			
			else
				Strife_Anon_DB.default[entry] = value
				Strife_Anon_DB.current[entry] = value
				Strife_Anon_DB.current.unixTimestamp		= '' .. tostring(LuaTrigger.GetTrigger('System').unixTimestamp) .. ''
				Strife_Anon_DB:Flush()
				--println('^y DB Set default entry: ' .. tostring(entry))
				return value, true, true
			end
		else
			--println('^y DB loading entry 2: ' .. tostring(entry))
			return Strife_Anon_DB.current[entry], false, false	
		end
	else
		SevereError('GetAnonDBEntry called without valid entry: ' .. tostring(entry), 'main_reconnect_thatsucks', '', nil, nil, nil)
		return nil
	end		
end	

function GetDBEntry(entry, value, saveToDB, restoreDefault, setDefault)	
	
	if IsFullyLoggedIn(GetIdentID()) then
	
		Strife_DB = Strife_DB or Database.New('Strife_DB_' .. GetIdentID() .. '.ldb')
		Strife_DB.current = Strife_DB.current or {}
		Strife_DB.default = Strife_DB.default or {}	
		
		if (entry) then	
			--println('^g DB GetEntry: ' .. tostring(entry) .. ' | ' .. ' value: ' .. tostring(value) .. ' | ' .. ' saveToDB: ' .. tostring(saveToDB) .. ' | ' .. ' restoreDefault: ' .. tostring(restoreDefault)  .. ' | ' .. ' setDefault: ' .. tostring(setDefault) )
			if (value) then	
				if (Strife_DB.default[entry]) and (not setDefault) then				
					if (restoreDefault) then				
						Strife_DB.current[entry] = Strife_DB.default[entry]
						Strife_DB.current.unixTimestamp		= '' .. tostring(LuaTrigger.GetTrigger('System').unixTimestamp) .. ''
						Strife_DB:Flush()
						--println('^y DB Restore default entry: ' .. tostring(entry)) 
						return Strife_DB.default[entry], false, true					
					elseif (saveToDB) then				
						Strife_DB.current[entry] = value
						Strife_DB.current.unixTimestamp		= '' .. tostring(LuaTrigger.GetTrigger('System').unixTimestamp) .. ''
						Strife_DB:Flush()
						--println('^y DB Save to db entry: ' .. tostring(entry))
						return value, false, true					
					else
						--println('^y DB loading entry 1: ' .. tostring(entry))
						return Strife_DB.current[entry], false, false	
					end			
				else
					Strife_DB.default[entry] = value
					Strife_DB.current[entry] = value
					if Strife_DB.current.unixTimestamp then
						Strife_DB.current.unixTimestamp		= '' .. tostring(LuaTrigger.GetTrigger('System').unixTimestamp) .. ''
					end
					Strife_DB:Flush()
					--println('^y DB Set default entry: ' .. tostring(entry))
					return value, true, true
				end
			else
				--println('^y DB loading entry 2: ' .. tostring(entry))
				return Strife_DB.current[entry], false, false	
			end
		else
			SevereError('GetDBEntry called without valid entry: ' .. tostring(entry), 'main_reconnect_thatsucks', '', nil, nil, nil)
			return nil
		end		
	else
		SevereError('GetDBEntry called without valid IdentID: ' .. tostring(GetIdentID()) .. ' | entry: ' .. tostring(entry), 'main_reconnect_thatsucks', '', nil, nil, nil)
		return nil
	end
end

function LoadState()
	
	-- println('^y LoadState() Anon ')
	
	mainUI 					= mainUI 					or {}
	mainUI.savedLocally 	= mainUI.savedLocally 		or {}
	mainUI.savedRemotely 	= mainUI.savedRemotely 		or {}
	mainUI.savedAnonymously	= mainUI.savedAnonymously 	or {}

	mainUI.savedAnonymously = GetAnonDBEntry('savedAnonymously', nil, true, false, true) or mainUI.savedAnonymously or {}
	mainUI.loadedAnonymously	= true
	
	if IsFullyLoggedIn(GetIdentID()) then
		
		println('^y LoadState() Authed as ' .. GetIdentID())
		
		local function LoadDB()
			mainUI.savedLocally 	= GetDBEntry('savedLocally', nil, true, false, true) 	or mainUI.savedLocally 	or {}
			mainUI.savedRemotely 	= GetDBEntry('savedRemotely', nil, true, false, true) 	or mainUI.savedRemotely or {}
			mainUI.loadedLocally	= true
			mainUI.loadedRemotely	= true
		end			
		
		local loadSuccess = pcall(LoadDB)		

		-- println('mainUI.savedLocally')
		-- printr(mainUI.savedLocally)		
		-- println('GetDBEntry mainUI.savedLocally')
		-- printr(GetDBEntry('savedLocally', nil, true, false, true))		
		
		local triggerStatus 				= LuaTrigger.GetTrigger('selection_Status')
		triggerStatus.selectedBuild 		= mainUI.savedLocally.selectedBuild or 1

		if (not mainUI.savedLocally.enableAutoBuild) or (mainUI.savedLocally.enableAutoBuild and (mainUI.savedLocally.enableAutoBuild == 'false')) then
			triggerStatus.enableAutoBuild = false
		else
			triggerStatus.enableAutoBuild = true
		end
		if (mainUI.savedLocally.enableAutoAbilities) then
			triggerStatus.enableAutoAbilities = true
		else
			triggerStatus.enableAutoAbilities = false
		end		
		triggerStatus:Trigger(false)
		
		DatabaseLoadStateTrigger.stateLoaded = true
		DatabaseLoadStateTrigger:Trigger(false)		
		
		-- println('^g COMPLETED LoadState() Authed as ' .. GetIdentID())
		
		-- Load From Web, overriding local savedRemotely if possible
		if ((not lastLoadFromWeb) or (GetIdentID() ~= lastLoadFromWeb)) and IsFullyLoggedIn(GetIdentID()) and (gamePhase.gamePhase == 0) then
			lastLoadFromWeb = GetIdentID()
			LoadDBFromWeb()	
		end		
		
		if (mainUI) and (mainUI.AdaptiveTraining) and (mainUI.AdaptiveTraining.Init) then
			mainUI.AdaptiveTraining.Init()
		end
		
		if (not loadSuccess) then
			GenericDialogAutoSize(
				'error_could_not_connect_to_local_database', 'error_could_not_connect_to_local_database_desc', '', 'general_ok', '', 
					function()
					end,
					nil
			)		
		end
		
	end
end

local saveStateWaitThread
local function saveStateWaitThreadKill()
	if (saveStateWaitThread) then
		saveStateWaitThread:kill()
		saveStateWaitThread = nil
	end
end	

function SaveState()
	
	saveStateWaitThreadKill()
	saveStateWaitThread = libThread.threadFunc(function()	
		wait(1)	
	
		-- println('^y SaveState() Anon ')
		
		mainUI 					= mainUI 					or {}
		mainUI.savedLocally 	= mainUI.savedLocally 		or {}
		mainUI.savedRemotely 	= mainUI.savedRemotely 		or {}
		mainUI.savedAnonymously	= mainUI.savedAnonymously 	or {}
		
		if (mainUI.loadedAnonymously) and (Strife_Anon_DB) then
			GetAnonDBEntry('savedAnonymously', mainUI.savedAnonymously, true, false, false)
		end
		
		if IsFullyLoggedIn(GetIdentID()) and (Strife_DB) and (mainUI.loadedLocally) and (mainUI.loadedRemotely) then
			
			-- println('^y SaveState() Authed as ' .. GetIdentID())
			
			local triggerStatus 						= LuaTrigger.GetTrigger('selection_Status')
			mainUI.savedLocally.selectedBuild			= triggerStatus.selectedBuild
			mainUI.savedLocally.enableAutoBuild 		= triggerStatus.enableAutoBuild
			mainUI.savedLocally.enableAutoAbilities 	= triggerStatus.enableAutoAbilities
			
			GetDBEntry('savedLocally', mainUI.savedLocally, true, false, false)
			GetDBEntry('savedRemotely', mainUI.savedRemotely, true, false, false)
			
			-- println('mainUI.savedLocally')
			-- printr(mainUI.savedLocally)
			-- println('GetDBEntry mainUI.savedLocally')
			-- printr(GetDBEntry('savedLocally', nil, true, false, true))			
			
		end
		saveStateWaitThread = nil
	end)
end

UnwatchLuaTriggerByKey('LoginStatus', 'LoginStatusKey')
WatchLuaTrigger('LoginStatus', function(trigger)
	-- Local Authed
	if ((loginStatus.isLoggedIn) and (loginStatus.hasIdent)) or (loginStatus.isAutoLogin) then
		-- println('^o^: LoginStatus')
		LoadState()
	else
		-- println('^o^: NOT LoginStatus')
		Strife_DB = nil
		mainUI.loadedLocally 		= false
		mainUI.loadedRemotely 		= false
		DatabaseLoadStateTrigger.stateLoaded = false
		DatabaseLoadStateTrigger:Trigger(false)		
	end
end, 'LoginStatusKey', 'hasIdent', 'isLoggedIn', 'isAutoLogin', 'isIdentPopulated')	

-- Local Anon
LoadState()

