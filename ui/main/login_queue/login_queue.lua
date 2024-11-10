local ipairs, pairs, select, string, table, next, type, unpack, tinsert, tconcat, tremove, format, tostring, tonumber, tsort, ceil, floor, sub, find, gfind = _G.ipairs, _G.pairs, _G.select, _G.string, _G.table, _G.next, _G.type, _G.unpack, _G.table.insert, _G.table.concat, _G.table.remove, _G.string.format, _G.tostring, _G.tonumber, _G.table.sort, _G.math.ceil, _G.math.floor, _G.string.sub, _G.string.find, _G.string.gfind
local interface, interfaceName = object, object:GetName()
local GetTrigger = LuaTrigger.GetTrigger
LoginQueue = {}
QUEUE_DEBUG = GetCvarBool('ui_devLoginQueue')

function LoginQueue.MinimiseQueue()
	GetWidget('login_queue_content_area_1'):FadeOut(125)
	GetWidget('login_queue_content_area_2'):FadeIn(125)
	GetWidget('game_of_strife_maximize_btn'):FadeIn(125)
end

function LoginQueue.MaximiseQueue()
	GetWidget('login_queue_content_area_1'):FadeIn(125)
	GetWidget('login_queue_content_area_2'):FadeOut(125)
	GetWidget('game_of_strife_maximize_btn'):FadeOut(125)
end

local function LoginQueueRegister()
	
	local loginQueue = LuaTrigger.GetTrigger('LoginQueue') or LuaTrigger.CreateCustomTrigger('LoginQueue',
		{
			{ name	= 'position',			type	= 'number' },
			{ name	= 'maxPosition',		type	= 'number' },
			{ name	= 'eta',				type	= 'number' },
		}
	)
	
	local function UpdateLoginQueue(position, maxPosition, eta)
		GetWidget('login_queue_progress_bar_label'):SetText(Translate('login_queue_label_1', 'value', (position)) .. '   ' .. Translate('login_queue_label_2', 'value', FtoA2(eta / (60 * 1000), 0, 2)))
		GetWidget('login_queue_progress_bar'):ScaleWidth(((position/maxPosition)*100)..'%', 150)
	end

	GetWidget('main_login_queue'):RegisterWatchLua('LoginQueue', function(widget, trigger)
		if (trigger.position > 0) then
			UpdateLoginQueue(trigger.position, trigger.maxPosition, trigger.eta)			
			if (not widget:IsVisible()) then
				LoginQueue.MaximiseQueue()		
				GetWidget('main_login_queue'):FadeIn(250)
			end
		else
			GetWidget('main_login_queue'):FadeOut(250)
		end
	end)
	
	function LoginQueue.BuildQueue()
		-- if (QUEUE_DEBUG) then
			-- local testQueuePos = math.random(45,70)
			-- local delayPerSlot = 100
			
			-- loginQueue.position 			= testQueuePos
			-- loginQueue.maxPosition 			= testQueuePos
			-- loginQueue.eta 					= testQueuePos * delayPerSlot
			-- loginQueue:Trigger(true)
			
			-- local startTime = GetTime()
			-- GetWidget('main_login_queue'):UnregisterWatchLua('System')
			-- GetWidget('main_login_queue'):RegisterWatchLua('System', function(widget, trigger)
				-- local delayPerSlot = math.random(120,1250)
				-- if (loginQueue.position > 0) then
					-- if ((startTime + delayPerSlot) < trigger.hostTime) then
						-- startTime = trigger.hostTime
						-- loginQueue.position = loginQueue.position - 1
						-- loginQueue.eta = loginQueue.position * delayPerSlot
						-- loginQueue:Trigger(false)
					-- end
				-- else
					-- GetWidget('main_login_queue'):UnregisterWatchLua('System')
				-- end
			-- end, false, nil, 'hostTime')
		-- end
	end
	
	local queueAnimController = LuaTrigger.GetTrigger('queueAnimController') or LuaTrigger.CreateGroupTrigger('queueAnimController', {'PartyStatus.inParty', 'LoginQueue', 'GameClientRequestsGetAllLoginData.status', 'GameClientRequestsGetAllGearSets.status', 'GameClientRequestsGetPet.status', 'GameClientRequestsGetCraftedItems.status', 'GameClientRequestsIdentCommodities.status', 'GameClientRequestsGetAllIdentGameData.status', 'LoginStatus.isLoggedIn', 'LoginStatus.hasIdent', 'LoginStatus.isIdentPopulated', 'mainPanelStatus.chatConnectionState', 'LoginStatus.statusTitle', 'PostGameLoopBusyStatus.busy', 'ChatConnectionStatus'} )
	GetWidget('main_login_queue'):RegisterWatchLua('queueAnimController', function(widget, groupTrigger)
		local loginStatus 								= groupTrigger['LoginStatus']
		local ChatConnectionStatus 						= groupTrigger['ChatConnectionStatus']
		local gameClientRequestsGetAllIdentGameData 	= groupTrigger['GameClientRequestsGetAllIdentGameData']
		local gameClientRequestsIdentCommodities 		= groupTrigger['GameClientRequestsIdentCommodities']
		local gameClientRequestsGetCraftedItems 		= groupTrigger['GameClientRequestsGetCraftedItems']
		local gameClientRequestsGetPet 					= groupTrigger['GameClientRequestsGetPet']
		local gameClientRequestsGetAllGearSets 			= groupTrigger['GameClientRequestsGetAllGearSets']
		local gameClientRequestsGetAllLoginData 		= groupTrigger['GameClientRequestsGetAllLoginData']
		local triggerPanelStatus 						= groupTrigger['mainPanelStatus']
		local PartyStatus 								= groupTrigger['mainPanelStatus']
		local postGameLoopBusy							= groupTrigger['PostGameLoopBusyStatus'].busy
		
		if (postGameLoopBusy) then
			QUEUE_DEBUG = false
		elseif (loginStatus.isLoggedIn) and (loginStatus.hasIdent) then
			if (QUEUE_DEBUG) then
				LoginQueue.BuildQueue()
			end			
			if (not PartyStatus.inParty) and ((widget:IsVisible()) or (loginQueue.position > 0) or QUEUE_DEBUG) and (gameClientRequestsGetAllLoginData.status ~= 1) and (gameClientRequestsIdentCommodities.status ~= 1) and (gameClientRequestsGetAllIdentGameData.status ~= 1) and (gameClientRequestsGetAllGearSets.status ~= 1)  and (gameClientRequestsGetPet.status ~= 1)  and (gameClientRequestsGetCraftedItems.status ~= 1) then	
				ChatClient.CreateParty()
			end	
			QUEUE_DEBUG = false
		end
	end)
	
	GetWidget('login_queue_dialog_button_1'):SetCallback('onclick', function(widget)
		LoginQueue.MinimiseQueue()
		MiniGames.StartGameOfStrife()
	end)
	
	GetWidget('login_queue_dialog_button_1'):SetEnabled(0)
	GetWidget('login_queue_dialog_button_1'):RegisterWatchLua('PartyStatus', function(widget, trigger)
		widget:SetEnabled(trigger.inParty)
	end, false, nil, 'inParty')

end

-- LoginQueueRegister()