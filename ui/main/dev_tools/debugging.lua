local _G = getfenv(0)
local ipairs, pairs, select, string, table, next, type, unpack, tinsert, tconcat, tremove, format, tostring, tonumber, tsort, ceil, floor, sub, find, gfind = _G.ipairs, _G.pairs, _G.select, _G.string, _G.table, _G.next, _G.type, _G.unpack, _G.table.insert, _G.table.concat, _G.table.remove, _G.string.format, _G.tostring, _G.tonumber, _G.table.sort, _G.math.ceil, _G.math.floor, _G.string.sub, _G.string.find, _G.string.gfind
local print  =_G['print']
local interface, interfaceName = object, object:GetName()
local delayedFunctionTable = {}
local GetTrigger = LuaTrigger.GetTrigger
mainUI = mainUI or {}
Ben = {}
Ben.lastTestedPointer = nil

local functionPointerTable = {}

local function clickEverything(widget)
	if (not widget) then return end
	
	for index, value in pairs(widget:GetChildren()) do
		
		local onclick = value:GetCallback('onclick')
		if onclick and type(onclick) == 'function' then
			table.insert(functionPointerTable, {value, onclick})
		end

		local ondoubleclick = value:GetCallback('ondoubleclick')
		if ondoubleclick and type(ondoubleclick) == 'function' then
			table.insert(functionPointerTable, {value, ondoubleclick})
		end		
		
		local onrightclick = value:GetCallback('onrightclick')
		if onrightclick and type(onrightclick) == 'function' then
			table.insert(functionPointerTable, {value, onrightclick})
		end		
		
		local onselect = value:GetCallback('onselect')
		if onselect and type(onselect) == 'function' then
			table.insert(functionPointerTable, {value, onselect})
		end			
		
		local onmouseover = value:GetCallback('onmouseover')
		if onmouseover and type(onmouseover) == 'function' then
			table.insert(functionPointerTable, {value, onmouseover})
		end				
		
		local onmouseout = value:GetCallback('onmouseout')
		if onmouseout and type(onmouseout) == 'function' then
			table.insert(functionPointerTable, {value, onmouseout})
		end			
		
		if (#value:GetChildren() > 0) then
			clickEverything(value)
		end
	end

end

local testThread
local old_Cmd = function(cmd) getfenv(0).Cmd(cmd) end
function UIUnitTest(show)
	
	if (testThread) then
		testThread:kill()
		testThread = nil
	end	
	
	local mainPanelAnimationStatus =  LuaTrigger.GetTrigger('mainPanelAnimationStatus')

	if (show) then

		local errors = 0
		local inParty 		= 	LuaTrigger.GetTrigger('PartyStatus').inParty
		local gamePhase 	= 	LuaTrigger.GetTrigger('GamePhase').gamePhase

		StartGame = function(game) println('^g I tried to start a game ' .. tostring(game)) end
		RequestMatchStart = function(game) println('^g I tried to RequestMatchStart ' .. tostring(game)) end
		interface.UICmd = function(cmd,  cmd2) println('^g I tried to run a UI Cmd:' .. tostring(cmd) .. ' ' .. tostring(cmd2)) end		
		Quit = function() println('^g I tried to quit') end
		Logout = function() println('^g I tried to Logout') end		
		UIUnitTest = nil
		RestartSoundManager = function() println('^g I tried to RestartSoundManager') end		
		Cmd = function(cmd) println('^g I tried to Cmd ' .. tostring(cmd)) end				

		clickEverything(UIManager.GetActiveInterface('main'))

		testThread = libThread.threadFunc(function()	
			
			for index, value in pairs(functionPointerTable) do

				if (gamePhase == 1) then
					LeaveGameLobby()
					wait(500)
				end				
				if (inParty) then
					Party.LeaveParty()		
					wait(500)
				end
				
				Ben.lastTestedPointer = value[1]
				local function testIt()
					value[2](value[1])
				end
				local success, errorMessage = pcall(testIt)
				if (success) then
				
				elseif (not errorMessage) or (not string.find(errorMessage, "'self'")) then
					printr(tostring(testIt) .. ' ^r: ' .. tostring(errorMessage))
					printr(debug.getinfo(value[2]))
					errors = errors + 1
				end
				wait(10)
				if (mainPanelAnimationStatus.newMain ~= -1) then
					wait(1500)
				end
				GetWidget('dev_tools_ui_unit_test_progress'):SetWidth( ((index/#functionPointerTable)*100) .. '%')
				GetWidget('dev_tools_ui_unit_test_bar_label'):SetText(errors .. ' errors. ' .. index .. '/' .. #functionPointerTable .. '. ' .. math.floor(((#functionPointerTable-index)*10)/1000)..'s')
			end
			
		end)
	
		GetWidget('dev_tools_ui_unit_test'):SetVisible(1)
		
	else
		GetWidget('dev_tools_ui_unit_test'):SetVisible(0)
		old_Cmd('ReloadInterfaces')
	end
end

--

local function findUnnamedWidget(startingWidget, count)
	if (startingWidget) and (startingWidget:GetName()) and (not Empty(startingWidget:GetName())) then
		println(count .. ' ' .. startingWidget:GetName() )
	end
	if (startingWidget:GetParent()) then
		count = count + 1
		findUnnamedWidget(startingWidget:GetParent(), count)
	end
end
function FindUnnamedWidget(startingWidget, sourceName)
	 println('^r--- FINDING WIDGET WITH NO NAME --- ' .. tostring(sourceName))
	 findUnnamedWidget(startingWidget, 0)
end

--

local function findWidgetByName(widgetName, widget)
	if (not widget) then return end
	
	for index, value in pairs(widget:GetChildren()) do
		
		if (value) and (value:GetName()) and  (value:GetName() == widgetName) then
			FindUnnamedWidget(value)
		end
		
		if (#value:GetChildren() > 0) then
			findWidgetByName(widgetName, value)
		end
	end
end
function FindWidgetByName(widgetName, interface)
	Cmd('Clear')
	println('FindWidgetByName ' .. widgetName .. ' | ' .. interface)
	findWidgetByName(widgetName, UIManager.GetInterface(interface))
end

--

local function findWidgetByTypeMismatch(type1, type2, widget)
	if (not widget) then return end
	
	for index, value in pairs(widget:GetChildren()) do
		
		if (widget) and (widget:GetType()) and (widget:GetType() == type1) then
			if (value) and (value:GetType()) and  (value:GetType() == type2) then
				FindUnnamedWidget(value)
			end
		end			

		if (#value:GetChildren() > 0) then
			findWidgetByTypeMismatch(type1, type2, value)
		end

	end
end
function FindWidgetByTypeMismatch(type1, type2, interface)
	Cmd('Clear')
	println('searching for ' .. type2 .. ' inside a ' .. type1)
	findWidgetByTypeMismatch(type1, type2,  UIManager.GetInterface(interface))
end

--

local function findUntranslatedStrings(widget) -- this doesn't work :(
	if (not widget) then return end
	
	for index, value in pairs(widget:GetChildren()) do
		
		if (value) and (value:GetType()) and (value:GetType() == 'label') then
			if (value:GetText()) and (not Empty(value:GetText())) then
				if (Translate(value:GetText()) == value:GetText()) then
					println('^r Found Untranslated String ' .. tostring(value:GetText()) )
					FindUnnamedWidget(value)
				end
			end
		end			

		if (#value:GetChildren() > 0) then
			findUntranslatedStrings(value)
		end

	end
end
function FindUntranslatedStrings(interface)
	Cmd('Clear')
	println('FindUntranslatedStrings in ' .. interface)
	findUntranslatedStrings(UIManager.GetInterface(interface))
end


-- Old method of error handling, still used by game server errors
interface:RegisterWatch('HostErrorMessage', function(sourceWidget, param0, param1, param2)
	println('^r HostErrorMessage ' .. tostring(param0) .. ' ' .. tostring(param1))
	GenericDialog(
		Translate(param0), '', Translate(param1), 'general_ok', '', 
			nil,
			nil
	)
end)

interface:RegisterWatchLua('BadGameName', function(sourceWidget)
	println('^r BadGameName ' .. tostring('error_console_badgamename') .. ' ' .. tostring('error_console_badgamename'))
	GenericDialog(
		Translate('error_console_badgamename'), '', Translate('error_console_badgamename'), 'general_ok', '', 
			nil,
			nil
	)
end)

interface:RegisterWatchLua('BadServerName', function(sourceWidget)
	println('^r BadServerName ' .. tostring('error_console_badservername') .. ' ' .. tostring('error_console_badservername'))
	GenericDialog(
		Translate('error_console_badservername'), '', Translate('error_console_badservername'), 'general_ok', '', 
			nil,
			nil
	)
end)

interface:RegisterWatchLua('BadPetName', function(sourceWidget)
	println('^r BadPetName ' .. tostring('error_console_badpetname') .. ' ' .. tostring('error_console_badpetname'))
	GenericDialog(
		Translate('error_console_badpetname'), '', Translate('error_console_badpetname'), 'general_ok', '', 
			nil,
			nil
	)
end)

interface:RegisterWatchLua('BadChannelName', function(sourceWidget)
	println('^r BadChannelName ' .. tostring('error_console_badchannelname') .. ' ' .. tostring('error_console_badchannelname'))
	GenericDialog(
		Translate('error_console_badchannelname'), '', Translate('error_console_badchannelname'), 'general_ok', '', 
			nil,
			nil
	)
end)

interface:RegisterWatchLua('BadPartyName', function(sourceWidget)
	println('^r BadPartyName ' .. tostring('error_console_badpartyname') .. ' ' .. tostring('error_console_badpartyname'))
	GenericDialog(
		Translate('error_console_badpartyname'), '', Translate('error_console_badpartyname'), 'general_ok', '', 
			nil,
			nil
	)
end)

-- Error Handling. errorMessage, status
local statusTriggerTable = {
		'GameClientRequestsChoosePetPassive',
		'GameClientRequestsClaimReward',
		'GameClientRequestsCreateCraftedItem',
		'GameClientRequestsDownloadCompatManifest',
		'GameClientRequestsEnchantCraftedItem',
		'GameClientRequestsFeedPet',
		'GameClientRequestsGetAllGearSets',
		'GameClientRequestsGetAllLoginData',
		'GameClientRequestsGetAllIdentGameData',
		'GameClientRequestsGetCraftedItem',
		'GameClientRequestsGetCraftedItems',
		'GameClientRequestsGetOwnedGearSets',
		'GameClientRequestsGetPet',
		'GameClientRequestsGetPetSlotProduct',
		'GameClientRequestsGetPets',
		'GameClientRequestsIdentCommodities',
		'GameClientRequestsNamePet',
		'GameClientRequestsPurchasePet',
		'GameClientRequestsRequestReplayDownload',
		'GameClientRequestsSalvageCraftedItem',
		'GameClientRequestsTemperCraftedItemWithEssence',
		'GameClientRequestsTemperCraftedItemWithGems',
		'GameClientRequestsUnlockGearSet',
	}

for i, triggerName in pairs(statusTriggerTable) do
	interface:RegisterWatchLua(triggerName, function(sourceWidget, trigger)
		if (trigger.status == 3) or ((trigger.errorMessage) and (trigger.errorMessage ~= '') and (trigger.errorMessage ~= 'error_not_found')) then
			if (Strife_Region.regionTable[Strife_Region.activeRegion].dialogOnWebError) then

				local errorTable = explode('|', trigger.errorMessage)
				local errorTable2 = {}
				for i,v in ipairs(errorTable) do
					table.insert(errorTable2, Translate(v))
				end
				local errorString = implode2(errorTable2, ' \n', '', '')
				
				println('^r Minor Request Error ' .. triggerName .. ' ' .. tostring(errorString))
				
				if (Strife_Region.regionTable[Strife_Region.activeRegion].dialogOnMinorError) then
					GenericDialogAutoSize(
						'error_web_general', tostring(triggerName), tostring(Translate(errorString)), 'general_ok', '', 
							nil,
							nil
					)
				else
					GenericDialogAutoSize(
						'error_web_general', '', tostring(Translate(errorString)), 'general_ok', '', 
							nil,
							nil
					)
				end
				
			end
		end
	end, true, nil)
end

-- Error Handling. errorMessage, status
local alwaysVisStatusTriggerTable = {
		'GameClientRequestsCreateCraftedItem',
		'GameClientRequestsFeedPet',
		'GameClientRequestsNamePet',
		'GameClientRequestsPurchasePet',
		'GameClientRequestsRequestReplayDownload',
		'GameClientRequestsDownloadCompatManifest',
		'GameClientRequestsSalvageCraftedItem',
		'GameClientRequestsUnlockGearSet',
	}

for i, triggerName in pairs(alwaysVisStatusTriggerTable) do
	interface:RegisterWatchLua(triggerName, function(sourceWidget, trigger)
		if (trigger.status == 3) or ((trigger.errorMessage) and (trigger.errorMessage ~= '') and (trigger.errorMessage ~= 'error_not_found')) then
			if (not Strife_Region.regionTable[Strife_Region.activeRegion].dialogOnWebError) then
				local errorTable = explode('|', trigger.errorMessage)
				local errorTable2 = {}
				for i,v in ipairs(errorTable) do
					table.insert(errorTable2, Translate(v))
				end
				local errorString = implode2(errorTable2, ' \n', '', '')
				
				println('^r Minor Request Error ' .. triggerName .. ' ' .. tostring(errorString))
				
				if (Strife_Region.regionTable[Strife_Region.activeRegion].dialogOnMinorError) then
					GenericDialogAutoSize(
						'error_web_general', tostring(triggerName), tostring(Translate(errorString)), 'general_ok', '', 
							nil,
							nil
					)
				else
					GenericDialogAutoSize(
						'error_web_general', '', tostring(Translate(errorString)), 'general_ok', '', 
							nil,
							nil
					)
				end
			end
		end
	end, true, nil)
end

-- Connsole Error Handling. prefix, line
local consoleOutputStreams = {
	'Dev',
	'Error',
	'Warning',
	'Net',
	'Sv',
	'Cl',
	'UI',
	'Perf',
	'Mem',
	'AI',
	'Vid',
	'SGame',
	'CGame',
	'Resource',
	'GroupVoice',
	'GroupVoiceDebug',
	'Script',
	'LuaError',
	'LuaPrint',
	'ChatClientNet',
}

local consoleOutputStreams_active = {
		'UI',
		'LuaError',
		'Script',
		'Error',
	}

local consoleOutputStreams_active2 = {
		'Cl',
	}	
	
for i, streamName in pairs(consoleOutputStreams) do
	Console.SetTriggerOutputStream(streamName, false)
end	
	
for i, streamName in pairs(consoleOutputStreams_active) do
	Console.SetTriggerOutputStream(streamName, true)
end

for i, streamName in pairs(consoleOutputStreams_active2) do
	Console.SetTriggerOutputStream(streamName, true)
end

local errorBlacklist = {
	'unregistered',
	'texture',
	'sound',
	'resource',
	'effect',
	'shader',
	'filemanager',
	'cbitmap',
	'memory',
	'error_not_found',
	'error_manifest_not_found',
}

interface:UnregisterWatchLua('ConsoleOutput')
interface:RegisterWatchLua('ConsoleOutput', function(sourceWidget, trigger)
	if (Strife_Region.regionTable[Strife_Region.activeRegion].dialogOnMinorError) and (not GetCvarBool('ui_hide_errors')) then
		if (IsInTable(consoleOutputStreams_active, trigger.prefix)) then
			local showMessage = true
			for _, entry in pairs(errorBlacklist) do
				if string.find(string.lower(trigger.line), string.lower(entry), 1, true) then
					showMessage = false
					break
				end
			end
			if (showMessage) then
				SevereError(Translate('error_console_general') .. ' \n ' .. trigger.prefix .. ' \n ' .. trigger.line , 'main_reconnect_thatsucks', '', nil, nil, nil)
			end
			if (Ben.lastTestedPointer) then
				if string.find(string.lower(trigger.line), string.lower('self'), 1, true) then
				
				else
					GetWidget('dev_tools_ui_unit_test_bar_label'):SetText('^r Found One!')
					FindUnnamedWidget(Ben.lastTestedPointer, 'ClickEverything')
				end
			end
		elseif (trigger.prefix == 'Cl') then
			local d1 = string.match(trigger.line, 'RequestTime%D*(%d*).%d*')
			if (d1) and (tonumber(d1) >= 3) then
				println('^r Slow Request Error ' .. 'error_slow_request_1' .. ' ' .. tostring(d1))
				GenericDialogAutoSize(
					'error_web_general', Translate('error_slow_request_1', 'value', d1 .. ' s'), '', 'general_ok', '', 
						nil,
						nil
				)					
			end	
		end
	end
end, true, nil)


function FindData(searchTerm)
	local currentTrigger
	local output = ''
	for z,x in ipairs(LuaTrigger.GetTriggers()) do	
		currentTrigger = LuaTrigger.GetTrigger(x)
		if (currentTrigger) and (type(currentTrigger) == 'table') then
			for i,v in ipairs(currentTrigger) do
				if string.find(tostring(i), tostring(searchTerm)) or string.find(tostring(v), tostring(searchTerm)) then
					output = output .. ( tostring(t) .. ' | ' .. tostring(i) .. ' | ' .. tostring(v) .. '\n' )
				end
			end
		elseif (currentTrigger) then
			for i,v in LuaTrigger.Iterate(currentTrigger) do
				if string.find(tostring(i), tostring(searchTerm)) or string.find(tostring(v), tostring(searchTerm)) then
					output = output .. ( tostring(t) .. ' | ' .. tostring(i) .. ' | ' .. tostring(v) .. '\n' )
				end
			end
		end
	end
	println('output: ' .. tostring(output) )
end

mainUI.errorLog = {}
function SevereError(errorString, okLabel, cancelLabel, doOnOk, doOnCancel, noDialog)
	if (Strife_Region.regionTable[Strife_Region.activeRegion].dialogOnSevereError) and (not noDialog) and (interface:GetWidget('generic_dialog_box')) and (not interface:GetWidget('generic_dialog_box'):IsVisible()) and (not GetCvarBool('ui_hide_errors')) then
		println('^r^: SevereError UI: ' .. tostring(errorString) )
		mainUI.errorLog = mainUI.errorLog or {}
		table.insert(mainUI.errorLog, errorString)
		-- if GetWidget('main_footer_user_online_label', nil, true) then
			-- GetWidget('main_footer_user_online'):SetVisible(1)
			-- GetWidget('main_footer_user_online_label', nil, true):SetColor('1 0 0 1')
			-- GetWidget('main_footer_user_online_label', nil, true):SetFont('subdyn_13')
			-- GetWidget('main_footer_user_online_label', nil, true):SetShadow(true)
			-- GetWidget('main_footer_user_online_label', nil, true):SetShadowColor('black')
		-- end
		groupfcall('main_header_btn_bug_icon_group', function(_, widget) widget:SetColor('red') end)
		GenericDialog(
			'general_severe_error', '', FormatStringNewline(errorString), okLabel, cancelLabel, 
				doOnOk,
				doOnCancel
		)
	elseif (Strife_Region.regionTable[Strife_Region.activeRegion].alertOnSevereError) and (interface:GetWidget('generic_alert_bar')) and (not interface:GetWidget('generic_alert_bar'):IsVisible()) then
		println('^r^: SevereError UI: ' .. tostring(errorString) )
		GenericAlert(errorString, doOnOk)
	else
		println('^r^: SevereError UI: ' .. tostring(errorString) )
	end
end

local JIRAReportThread
function mainUI.BugReportJIRAREST()
	
	if (JIRAReportThread) then
		JIRAReportThread:kill()
		JIRAReportThread = nil
	end
	
	JIRAReportThread = libThread.threadFunc(function()	

		println('^g mainUI.BugReportJIRA() ')
		
		local testData = {
			["update"] = {
				["summary"] = {
					{
						["set"] = "Bug in business logic"
					},
				},
			}
		}
		
		local function encodeData()
			return JSON:encode(testData)
		end			
		
		local encodeSuccess, encodedData = pcall(encodeData)
		
		printr(encodedData)
		
		if (encodeSuccess) and (encodedData) then
			local successFunction = function(responseData)
				println('^g successFunction')
				printr(responseData)
				if responseData.GetError then
					printr(responseData:GetError())
				end
				if (responseData.GetBody) then
					printr(responseData:GetBody())
				end
			end
			local failFunction = function(responseData)
				println('^r failFunction')
				printr(responseData)
				if responseData.GetError then
					printr(responseData:GetError())
				end
				if (responseData.GetBody) then
					printr(responseData:GetBody())
				end
			end		
			
			local request = HTTP.SpawnRequest()
		
			request:SetTargetURL('jira.s2games.com/rest/api/2/issue/')
			request:SendSecureRequest('PUT')
			request:AddVariable('data', encodedData)
			request:AddVariable('h', "Content-Type: application/json")
			request:AddVariable('X', "POST")
			request:AddVariable('u', "")
			
			request:ManagedWait(
				successFunction,
				failFunction
			)
		end

		JIRAReportThread = nil
	end)
	
end

local JIRAReportThread
function mainUI.BugReportJIRA()
	
	if (JIRAReportThread) then
		JIRAReportThread:kill()
		JIRAReportThread = nil
	end
	
	JIRAReportThread = libThread.threadFunc(function()	

		println('^g mainUI.BugReportJIRA() ')
		
		mainUI.errorLog = mainUI.errorLog or {}
		
		local parent 			= GetWidget('ui_dev_bug_report')
		local button 			= GetWidget('main_header_btn_bug')
		
		button:SetEnabled(0)
		
		local system 							= LuaTrigger.GetTrigger('System')
		local partystatus						= LuaTrigger.GetTrigger('PartyStatus')
		local loginstatus 						= LuaTrigger.GetTrigger('LoginStatus')
		local mainpanelstatus					= LuaTrigger.GetTrigger('mainPanelStatus')
		local gamephase							= LuaTrigger.GetTrigger('GamePhase')
		local heroselectlocalplayerinfo			= LuaTrigger.GetTrigger('HeroSelectLocalPlayerInfo')

		local branch 		= tostring(Translate(GetCvarString('build_branch')))
		local version 		= tostring(GetCvarString('host_version'))
		local identid 		= tostring(GetIdentID())
		local timestamp 	= tostring(system.unixTimestamp)
		local sys_os		= tostring(Translate(GetCvarString('build_os')))
		local sys_mods		= tostring(system.usingMods)
		
		local error_log = table.concat(mainUI.errorLog, '\n')

		local bugTable = {}
		table.insert(bugTable, 'error_log ' .. error_log)
		table.insert(bugTable, 'branch ' .. branch)
		table.insert(bugTable, 'version ' .. version)
		table.insert(bugTable, 'identid ' .. identid)
		table.insert(bugTable, 'timestamp ' .. timestamp)
		table.insert(bugTable, 'sys_os ' .. sys_os)
		table.insert(bugTable, 'sys_mods ' .. sys_mods)
		-- table.insert(bugTable, 'session ' .. Client.GetSessionKey())

		local triggersToTestTable = {
			-- 'selection_Status',
			-- 'AccountInfo',
			-- 'PartyStatus',
			-- 'mainPanelStatus',
			-- 'LeaverBan',
			-- 'LoginStatus',
			-- 'Corral',
			-- 'HeroSelectLocalPlayerInfo',
		}
		
		for index, triggerName in ipairs(triggersToTestTable) do
			table.insert(bugTable, 'Trigger: ' .. triggerName)
			local trigger = LuaTrigger.GetTrigger(triggerName)
			local triggerTable = LuaTrigger.ToTable(trigger)
			for i, v in pairs(triggerTable) do
				table.insert(bugTable, tostring(i) .. ' ' .. tostring(v))
			end
		end

		local bugString = table.concat(bugTable, '\n')

		local function URLEncode(str)
		  if (str) then
			str = string.gsub (str, "\n", "\r\n")
			str = string.gsub (str, "([^%w %-%_%.%~])",
				function (c) return string.format ("%%%02X", string.byte(c)) end)
			str = string.gsub (str, " ", "+")
		  end
		  return str	
		end

		local components 			= 10529 									-- Unknown
		local projectID 			= 10501 									-- QA
		local issuetype 			= 1 										-- Bug
		local priority 				= 3 										-- Normal
		local summary				= "Report From: " .. identid
		local description			= URLEncode(bugString) or 'No+Description'
		local sendURL 				= "https://jira.s2games.com/secure/CreateIssueDetails!init.jspa?pid="..projectID.."&components="..components.."&issuetype="..issuetype.."&summary="..summary.."&environment="..branch.."&labels=BugTool&priority="..priority.."&description="..description
		
		println('sendURL length ' .. string.len(sendURL))
		printr(sendURL)
		mainUI.OpenURL(sendURL)

		wait(500)
		
		button:SetEnabled(1)
		
		JIRAReportThread = nil
	end)
	
end

function mainUI.BugReportDialog()
	println('^g mainUI.BugReportDialog() ')
	
	mainUI.errorLog = mainUI.errorLog or {}
	
	local system 							= LuaTrigger.GetTrigger('System')
	local partystatus						= LuaTrigger.GetTrigger('PartyStatus')
	local loginstatus 						= LuaTrigger.GetTrigger('LoginStatus')
	local mainpanelstatus					= LuaTrigger.GetTrigger('mainPanelStatus')
	local gamephase							= LuaTrigger.GetTrigger('GamePhase')
	local heroselectlocalplayerinfo			= LuaTrigger.GetTrigger('HeroSelectLocalPlayerInfo')
	
	local parent 			= GetWidget('ui_dev_bug_report')
	local input_textbox		= GetWidget('ui_dev_bug_report_input_textbox')
	local log_textbox		= GetWidget('ui_dev_bug_report_log_textbox')
	
	local btn_1				= GetWidget('ui_dev_bug_report_btn_1')
	local btn_2				= GetWidget('ui_dev_bug_report_btn_2')

	local label_1_a 		= GetWidget('ui_dev_bug_report_label_1a')
	local label_1_b 		= GetWidget('ui_dev_bug_report_label_1b')
	local label_2_a 		= GetWidget('ui_dev_bug_report_label_2a')
	local label_2_b 		= GetWidget('ui_dev_bug_report_label_2b')
	local label_3_a 		= GetWidget('ui_dev_bug_report_label_3a')
	local label_3_b 		= GetWidget('ui_dev_bug_report_label_3b')
	local label_4_a 		= GetWidget('ui_dev_bug_report_label_4a')
	local label_4_b 		= GetWidget('ui_dev_bug_report_label_4b')
	local label_5_a 		= GetWidget('ui_dev_bug_report_label_5a')
	local label_5_b 		= GetWidget('ui_dev_bug_report_label_5b')
	local label_6_a 		= GetWidget('ui_dev_bug_report_label_6a')
	local label_6_b 		= GetWidget('ui_dev_bug_report_label_6b')

	log_textbox:UICmd("ClearBufferText")
	if (mainUI.errorLog) and (#mainUI.errorLog > 0) then
		for i, errorString in ipairs(mainUI.errorLog) do
			log_textbox:UICmd([[AddBufferText(']] .. string.gsub(errorString, "'", "") .. [[')]])
		end
	else
		log_textbox:UICmd("AddBufferText('Error Log: No Errors Found')")
	end
	
	local branch 		= Translate(GetCvarString('build_branch'))
	local version 		= GetCvarString('host_version')
	local identid 		= GetIdentID()
	local timestamp 	= system.unixTimestamp
	local sys_os		= Translate(GetCvarString('build_os'))
	local sys_mods		= system.usingMods

	label_1_b:SetText(version or '?')
	label_2_b:SetText(sys_os or '?')
	label_3_b:SetText(branch or '?')
	label_4_b:SetText(FormatDateTime(timestamp, '%#I:%M %p %B %d, %Y', true) or '?')
	label_5_b:SetText(identid or '?')
	label_6_b:SetText(tostring(sys_mods) or '?')

	local function SubmitReport()
		
		local bug_description = input_textbox:GetValue()
		
		local bugTable = {
			bug_description = bug_description,
			branch = branch,
			version = version,
			identid = identid,
			timestamp = timestamp,
			sys_os = sys_os,
			sys_mods = sys_mods,
			error_log = mainUI.errorLog,
			main = mainpanelstatus.main,
			chatconnectionstate = mainpanelstatus.chatConnectionState,
			inparty = partystatus.inParty,
			inqueue = partystatus.inQueue,
			isidentpopulated = loginstatus.isIdentPopulated,
			gamephase = gamephase.gamePhase,
			petentity = heroselectlocalplayerinfo.petEntityName,
			heroentity = heroselectlocalplayerinfo.heroEntityName,
			session = Client.GetSessionKey(),
		}

		local function encodeData()
			return JSON:encode(bugTable)
		end			
		
		local encodeSuccess, encodeData = pcall(encodeData)

		if (encodeSuccess) and (encodeData) then
			println('^g Send off ' .. tostring(encodeData))
			parent:FadeOut(250)
		else
			SevereError('Failed to encode data bugTable ' .. tostring(encodeData), 'main_reconnect_thatsucks', '', nil, nil, false)
		end
		
	end
	
	btn_1:SetCallback('onclick', function(widget)
		SubmitReport()
	end)
	
	parent:FadeIn(250)
	
end

function traceback()
	local level = 1
	while true do
		local info = debug.getinfo(level, "Sl")
		if not info then break end
		if info.what == "C" then   -- is a C function?
			println('Level: ' .. level)
			println('Is a C function')
		else   -- a Lua function
			println('Level: ' .. level)
			printr(info)
		end
		level = level + 1
	end
end

