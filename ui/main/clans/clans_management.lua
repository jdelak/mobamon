local _G = getfenv(0)
local ipairs, pairs, select, string, table, next, type, unpack, tinsert, tconcat, tremove, format, tostring, tonumber, tsort, ceil, floor, sub, find, gfind, len, lower, gsub = _G.ipairs, _G.pairs, _G.select, _G.string, _G.table, _G.next, _G.type, _G.unpack, _G.table.insert, _G.table.concat, _G.table.remove, _G.string.format, _G.tostring, _G.tonumber, _G.table.sort, _G.math.ceil, _G.math.floor, _G.string.sub, _G.string.find, _G.string.gfind, _G.string.len, _G.string.lower, _G.string.gsub

local interfaceName = object:GetName()
local interface = object

mainUI = mainUI or {}
mainUI.Clans = mainUI.Clans or {}

local function RegisterClansManagement(object)
	
	-- println('RegisterClansManagement 1/2')
	
	local clan_management 								= interface:GetWidget('clan_management')
	local clan_management_language_combobox 			= interface:GetWidget('clan_management_language_combobox')
	local clan_management_region_combobox 				= interface:GetWidget('clan_management_region_combobox')
	
	clan_management_region_combobox:SetVisible(0) -- NO REGIONS SEARCH THIS PHRASE
	
	local function RegisterInput(name, onenterCallback, triggerField, canEdit)
		canEdit = canEdit or false
		
		local frame 				= interface:GetWidget('clan_management_' .. name .. '_frame')
		local buffer 				= interface:GetWidget('clan_management_' .. name .. '_buffer')
		local frame_coverlabel 		= interface:GetWidget('clan_management_' .. name .. '_frame_coverlabel')
		local highlight 			= interface:GetWidget('clan_management_' .. name .. '_highlight')
		local label 				= interface:GetWidget('clan_management_' .. name .. '_label')
		local edit_parent 			= interface:GetWidget('clan_management_' .. name .. '_edit_parent')
		local edit_btn 				= interface:GetWidget('clan_management_' .. name .. '_edit_btn')
		local attemptSave			= true
		
		buffer:SetCallback('onevent', function(widget)
			attemptSave = false
			buffer:SetFocus(false)
			buffer:SetDefaultFocus(false)
			edit_parent:SetVisible(1)
			frame:SetVisible(0)			
		end)
		
		buffer:SetCallback('onevent2', function(widget)
			local value = widget:GetValue()
			buffer:SetFocus(false)
			buffer:SetDefaultFocus(false)
			edit_parent:SetVisible(1)
			frame:SetVisible(0)			
		end)
		
		buffer:SetCallback('onfocus', function(widget)
			attemptSave = true
			frame_coverlabel:SetVisible(0)
		end)

		buffer:SetCallback('onlosefocus', function(widget)
			local value = widget:GetValue()
			frame_coverlabel:SetVisible((string.len(value) == 0) or false)
			if (attemptSave) then
				if (onenterCallback) then
					if (mainUI.Clans.CanManageClan()) or ((mainUI.Clans.CanEditTopic()) and (name == 'chattopicinput')) then
						onenterCallback(value)
					else
						println('^r ' .. name .. ' missing permissions for ' .. value)
					end
				else
					println('^r ' .. name .. ' no callback for ' .. value)
				end
			end
		end)

		buffer:SetCallback('onchange', function(widget)
			local value = widget:GetValue()
		end)
		
		if (triggerField) and (triggerField ~= '') then
			local function UpdateBuffer()
				local trigger = LuaTrigger.GetTrigger('ChatClanInfo')
				if (trigger[triggerField]) then
					label:SetText(trigger[triggerField])
					if (trigger[triggerField] ~= '') then
						buffer:SetInputLine(trigger[triggerField])
						frame_coverlabel:SetVisible(0)
					end
				end			
			end
			
			buffer:UnregisterWatchLua('ChatClanInfo')
			buffer:RegisterWatchLua('ChatClanInfo', function(widget, trigger)
				UpdateBuffer()
			end, false, nil, triggerField)		
			
			UpdateBuffer()
		end
		
		edit_btn:SetCallback('onclick', function(widget)
			if (edit_parent:IsVisible()) then
				edit_parent:SetVisible(0)
				frame:SetVisible(1)
			else
				edit_parent:SetVisible(1)
				frame:SetVisible(0)
			end
		end)		
		
		edit_parent:SetVisible(1)
		frame:SetVisible(0)
		
		if (name == 'chattopicinput') then	
			edit_btn:SetVisible(mainUI.Clans.CanEditTopic() and (canEdit or GetCvarBool('ui_devClans')))
		else
			edit_btn:SetVisible(mainUI.Clans.CanManageClan() and (canEdit or GetCvarBool('ui_devClans')))
		end
		
	end

	local filters = {}
	local function UpdateFilters()
		if (mainUI.Clans.CanManageClan()) then

			if (filters['membership']) then
				for i,v in pairs(filters['membership']) do
					if (v.active and v.id == 'clan_management_filter_0_1') then
						ChatClient.SetClanRecruitment(2)
					elseif (v.active and v.id == 'clan_management_filter_0_2') then
						ChatClient.SetClanRecruitment(1)
					elseif (v.active and v.id == 'clan_management_filter_0_3') then
						ChatClient.SetClanRecruitment(0)
					end
				end
			end
			
			local activeTags = ''
			
			if (filters['focus']) then
				for i,v in pairs(filters['focus']) do
					if (v.active and v.id == 'clan_management_filter_1_1') then
						activeTags = 'social'
					elseif (v.active and v.id == 'clan_management_filter_1_2') then
						activeTags = 'competitive'
					elseif (v.active and v.id == 'clan_management_filter_1_3') then
						activeTags = 'social,competitive'
					end
				end
			end
		
			if (filters['skill']) then
				for i,v in pairs(filters['skill']) do
					if (v.active and v.id == 'clan_management_filter_2_1') then
						activeTags = activeTags .. ',newbies'
					elseif (v.active and v.id == 'clan_management_filter_2_2') then
						activeTags = activeTags .. ',experienced'
					elseif (v.active and v.id == 'clan_management_filter_2_3') then
						activeTags = activeTags .. ',newbies,experienced'
					end
				end
			end	
		
			ChatClient.SetClanTags(activeTags)
		end
	end
	
	local function registerFilter(id, filterValue, isDefault)
		local cbpanel 							= GetWidget(id .. '_cbpanel')
		local cbname 							= GetWidget(id .. '_cbname')
		-- local cb_frame_ 						= GetWidget(id .. 'cb_frame_')
		local options_checkbox_check 			= GetWidget('options_checkbox_check_' .. id)
		local options_checkbox_titlelabel 		= GetWidget('options_checkbox_titlelabel_' .. id)
		isDefault 								= isDefault or false
		
		filters[filterValue] = filters[filterValue] or {}
		table.insert(filters[filterValue], {active = isDefault, id = id})
		options_checkbox_check:SetVisible(isDefault)
		
		cbname:SetCallback('onclick', function(widget)
			if (not options_checkbox_check:IsVisible()) then
				local isChecked = not options_checkbox_check:IsVisible()
				
				for i,v in pairs(filters[filterValue]) do
					local check = GetWidget('options_checkbox_check_' .. v.id)
					check:SetVisible(0)
					v.active = false
				end
				
				options_checkbox_check:SetVisible(isChecked)
				
				for i,v in pairs(filters[filterValue]) do
					if (v.id == id) then
						v.active = isChecked
					end
				end
				
				UpdateFilters()
			end
		end)
		
		cbname:SetEnabled(mainUI.Clans.CanManageClan())
		
	end
	
	local regionComboboxInit = false
	local function UpdateRegionCombox()
		if (not regionComboboxInit) then
			regionComboboxInit = true
			clan_management_region_combobox:ClearItems()
			-- local regions = Login.regionsTable
			local regions = mainUI.Clans.Regions or {}
			for i, v in ipairs(regions) do
				if (v[1]) then
					-- clan_management_region_combobox:AddTemplateListItem('simpleDropdownItem', v[2], 'code', v[2], 'texture', '$invis', 'label', Translate(v[1]))
					clan_management_region_combobox:AddTemplateListItem('windowframe_combobox_lang_item', v[1], 'code', v[1], 'texture', Translate('game_region_flag_' .. v[1]), 'label', Translate('game_region_' .. v[1]))
				end
			end	
		end
		local trigger = LuaTrigger.GetTrigger('ChatClanInfo')
		if (clan_management_region_combobox:HasListItem(trigger.region)) then
			clan_management_region_combobox:SetSelectedItemByValue(trigger.region, false)
		end	
		clan_management_region_combobox:SetEnabled(mainUI.Clans.CanManageClan())
	end
	
	clan_management_region_combobox:SetCallback('onselect', function(widget)
		local value = widget:GetValue()
		if (mainUI.Clans.CanManageClan()) then
			ChatClient.SetClanRegion(value)
		end
	end)
	
	clan_management_region_combobox:SetCallback('onshow', function(widget)
		UpdateRegionCombox()
	end)

	local function UpdateLanguageCombox()
		local trigger = LuaTrigger.GetTrigger('ChatClanInfo')
		
		local clanLanguage = trigger.language
		if (clanLanguage == 'pt') then clanLanguage = 'pt_br' end
		
		if (clan_management_language_combobox:HasListItem(clanLanguage)) then
			clan_management_language_combobox:SetSelectedItemByValue(clanLanguage, false)
		end	
		clan_management_language_combobox:SetEnabled(mainUI.Clans.CanManageClan())
	end
	
	clan_management_language_combobox:SetCallback('onselect', function(widget)
		local value = widget:GetValue()
		if (mainUI.Clans.CanManageClan()) then
			value = string.sub(value, 1, 2)
			ChatClient.SetClanLanguage(value)
		end
	end)
	
	clan_management_language_combobox:SetCallback('onshow', function(widget)
		UpdateLanguageCombox()
	end)

	local function registerminRatingSlider(id, actionCallback, triggerParam)

		local parent 	= GetWidget(id .. '_parent')
		local slider 	= GetWidget(id .. '_slider')
		local label 	= GetWidget(id .. '_value_label')
		local input 	= GetWidget(id .. '_input')
		
		local function Update()
			local ChatClanInfo = LuaTrigger.GetTrigger('ChatClanInfo')
			if (triggerParam) and (ChatClanInfo[triggerParam]) then
				local inValue = math.floor(math.max(0, math.min(3000, (ChatClanInfo[triggerParam] + 1500))))
				slider:SetValue(inValue)
				label:SetText(inValue)
			end
			slider:SetEnabled(mainUI.Clans.CanManageClan() or false)
		end	
		
		local function SetValue(value)
			-- println('SetValue ' .. tostring(value))
			if (value) and tonumber(value) and (mainUI.Clans.CanManageClan()) then
				local ChatClanInfo = LuaTrigger.GetTrigger('ChatClanInfo')
				if (triggerParam) and (ChatClanInfo[triggerParam]) then
					local inValue = math.floor(math.max(0, math.min(3000, (ChatClanInfo[triggerParam] + 1500))))
					value = math.floor(math.max(0, math.min(3000, value)))
					if (value) and tonumber(value) and (inValue ~= value) then
						slider:SetValue(value)
						label:SetText(value)
						ChatClient.SetClanMinRating(value - 1500)
						println('SetValue success ' .. tostring(value))
					else
						println('SetValue failed 3 ' .. tostring(value) .. ' ' .. inValue)
					end
				else
					println('SetValue failed 2 ' .. tostring(value))
				end
			else
				println('SetValue failed 1 ' .. tostring(value))
			end		
		end
		
		input:SetCallback('onevent', function(widget)
			input:SetInputLine('')
		end)
		
		input:SetCallback('onfocus', function(widget)
			label:SetVisible(0)
			input:SetInputLine('')
		end)
		
		input:SetCallback('onlosefocus', function(widget)
			label:SetVisible(1)
			local value = tonumber(widget:GetValue())
			SetValue(value)
			input:SetInputLine('')
		end)
		
		parent:SetCallback('onshow', function(widget)
			Update()
		end)	

		slider:SetCallback('onenddrag', function(widget)
			local value = math.floor(math.floor(tonumber(widget:GetValue())/50)*50)
			SetValue(value)
		end)
		
		slider:SetCallback('onchange', function(widget)
			local value = math.floor(math.floor(tonumber(widget:GetValue())/50)*50)
			label:SetText(value)
		end)		
		
		if (triggerParam) then
			parent:RegisterWatchLua('ChatClanInfo', function(widget, trigger)
				Update()
			end, false, nil, triggerParam)
		end
		
		slider:SetEnabled(mainUI.Clans.CanManageClan() or false)
		parent:RefreshCallbacks()
		slider:RefreshCallbacks()
		Update()
		
	end	
	
	registerminRatingSlider('clans_management_minRating', ChatClient.SetClanMinRating, 'minRating')
	
	local function UpdateManagementInfo()
		local trigger = LuaTrigger.GetTrigger('ChatClanInfo')
		if (trigger.id ~= '' and trigger.id ~= '0.000') then

			RegisterInput('clannameinput', ChatClient.SetClanName, 'name', false)
			RegisterInput('clantaginput', ChatClient.SetClanTag, 'tag', false)
			RegisterInput('clandescriptioninput', ChatClient.SetClanDescription, 'description', true)
			RegisterInput('chattopicinput', ChatClient.SetClanTopic, 'topic', true)		
			
			filters = {}
			
			registerFilter('clan_management_filter_0_1', 'membership', (trigger.recruitment == 2) )
			registerFilter('clan_management_filter_0_2', 'membership', (trigger.recruitment == 1) )
			registerFilter('clan_management_filter_0_3', 'membership', (trigger.recruitment == 0) )

			local isBoth = (string.find(trigger.tags, 'social')) and (string.find(trigger.tags, 'competitive'))
			registerFilter('clan_management_filter_1_1', 'focus', (not isBoth) and (string.find(trigger.tags, 'social')))	
			registerFilter('clan_management_filter_1_2', 'focus', (not isBoth) and (string.find(trigger.tags, 'competitive')))	
			registerFilter('clan_management_filter_1_3', 'focus', isBoth)	
			
			local isBoth2 = (string.find(trigger.tags, 'newbies')) and (string.find(trigger.tags, 'experienced'))
			registerFilter('clan_management_filter_2_1', 'skill', (not isBoth2) and (string.find(trigger.tags, 'newbies')))	
			registerFilter('clan_management_filter_2_2', 'skill', (not isBoth2) and (string.find(trigger.tags, 'experienced')))	
			registerFilter('clan_management_filter_2_3', 'skill', isBoth2)
			
			UpdateLanguageCombox()
			UpdateRegionCombox()
		end	
	end
	
	clan_management:RegisterWatchLua('ChatClanInfo', function(widget, trigger)
		if (trigger.id ~= '' and trigger.id ~= '0.000') and (clan_management:IsVisible()) then
			UpdateManagementInfo()
		end
	end)
	
	clan_management:SetCallback('onshow', function(widget)
		UpdateManagementInfo()
		
		local myChatClientInfoTriggerName = GetClientInfoTriggerName(GetIdentID())
		if (myChatClientInfoTriggerName) then
			clan_management:UnregisterWatchLua(myChatClientInfoTriggerName)
			clan_management:RegisterWatchLua(myChatClientInfoTriggerName, function(widget, trigger)
				if (clan_management:IsVisible()) then
					UpdateManagementInfo()
				end
			end, false, nil, 'clanRank')
		end
		
	end)
	
	-- ChatClient.SetClanRegion(string region)
	-- ChatClient.SetClanMinRating(number minRating)	
	
	-- println('RegisterClansManagement 2/2')
	
end

RegisterClansManagement(object)