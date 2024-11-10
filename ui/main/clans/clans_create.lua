local _G = getfenv(0)
local ipairs, pairs, select, string, table, next, type, unpack, tinsert, tconcat, tremove, format, tostring, tonumber, tsort, ceil, floor, sub, find, gfind, len, lower, gsub = _G.ipairs, _G.pairs, _G.select, _G.string, _G.table, _G.next, _G.type, _G.unpack, _G.table.insert, _G.table.concat, _G.table.remove, _G.string.format, _G.tostring, _G.tonumber, _G.table.sort, _G.math.ceil, _G.math.floor, _G.string.sub, _G.string.find, _G.string.gfind, _G.string.len, _G.string.lower, _G.string.gsub

local interfaceName = object:GetName()
local interface = object

mainUI = mainUI or {}
mainUI.Clans = mainUI.Clans or {}
mainUI.Clans.availableClanProducts = nil

local function RegisterClansCreate(object)
	
	-- println('RegisterClansCreate 1/2')
	
	local clan_create 					= interface:GetWidget('clan_create')
	local clans_create_clan_btn 		= interface:GetWidget('clans_create_clan_btn2')
	local clan_create_region_combobox 	= interface:GetWidget('clan_create_region_combobox')
	local foundClubCreationProduct		= false
	local isCreatingClan				= false
	
	local function UpdateCanCreateClan()
		local chatClanInfo = LuaTrigger.GetTrigger('ChatClanInfo')
		local notInClan = (chatClanInfo.id == nil or chatClanInfo.id == '' or chatClanInfo.id == '0.000')
		
		local clanName 				= interface:GetWidget('clan_create_clannameinput_buffer'):GetValue()
		local clanDescription 		= interface:GetWidget('clan_create_clandescriptioninput_buffer'):GetValue()
		-- local clanTopic				= interface:GetWidget('clan_create_chattopicinput_buffer'):GetValue()
		local clanLanguage			= interface:GetWidget('clan_create_language_combobox'):GetValue()
		local clanRegion			= interface:GetWidget('clan_create_region_combobox'):GetValue()
		local clanTag				= interface:GetWidget('clan_create_clantaginput_buffer'):GetValue()
		local minRating				= math.floor(tonumber(interface:GetWidget('clans_create_minRating_slider'):GetValue()))
		
		local canCreateClan = (not isCreatingClan) and (((clanName) and (clanName ~= '')) and ((clanTag) and (clanTag ~= '')) and ((clanDescription) and (clanDescription ~= '')) and ((minRating >= 0) and (minRating <= 3000)))

		clans_create_clan_btn:SetEnabled(canCreateClan or false)
	end	
	
	local function RegisterInput(name)
		local frame 				= interface:GetWidget('clan_create_' .. name .. '_frame')
		local buffer 				= interface:GetWidget('clan_create_' .. name .. '_buffer')
		local frame_coverlabel 		= interface:GetWidget('clan_create_' .. name .. '_frame_coverlabel')
		local highlight 			= interface:GetWidget('clan_create_' .. name .. '_highlight')

		buffer:SetCallback('onevent', function(widget)
			buffer:SetInputLine('')
			buffer:SetFocus(false)
			buffer:SetDefaultFocus(false)
		end)
		
		buffer:SetCallback('onfocus', function(widget)
			frame_coverlabel:SetVisible(0)
		end)

		buffer:SetCallback('onlosefocus', function(widget)
			local value = widget:GetValue()
			frame_coverlabel:SetVisible(string.len(value) == 0)
		end)

		buffer:SetCallback('onchange', function(widget)
			local value = widget:GetValue()
			UpdateCanCreateClan()
		end)
	end
	
	RegisterInput('clannameinput')
	RegisterInput('clantaginput')
	RegisterInput('clandescriptioninput')
	-- RegisterInput('chattopicinput')
	
	local filters = {}
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
					v.active = false
					check:SetVisible(0)
				end
				
				options_checkbox_check:SetVisible(isChecked)
				
				for i,v in pairs(filters[filterValue]) do
					if (v.id == id) then
						v.active = isChecked
					end
				end
				
				UpdateCanCreateClan()
			end
		end)

	end
	
	registerFilter('clan_create_filter_0_1', 'membership')	
	registerFilter('clan_create_filter_0_2', 'membership', true)	
	registerFilter('clan_create_filter_0_3', 'membership')	
	
	registerFilter('clan_create_filter_1_1', 'focus')	
	registerFilter('clan_create_filter_1_2', 'focus')	
	registerFilter('clan_create_filter_1_3', 'focus', true)	
	
	registerFilter('clan_create_filter_2_1', 'skill')	
	registerFilter('clan_create_filter_2_2', 'skill')	
	registerFilter('clan_create_filter_2_3', 'skill', true)	
	
	local function registerminRatingSlider(id)

		local parent 	= GetWidget(id .. '_parent')
		local slider 	= GetWidget(id .. '_slider')
		local label 	= GetWidget(id .. '_value_label')
		local input 	= GetWidget(id .. '_input')

		local function SetValue(value)
			println('SetValue ' .. tostring(value))
			if (value) and tonumber(value) then
				value = math.floor(math.max(0, math.min(3000, value)))
				if (value) and tonumber(value) then
					slider:SetValue(value)
					label:SetText(value)					
					println('SetValue success ' .. tostring(value))
				else
					println('SetValue failed 3 ' .. tostring(value))
				end

			else
				println('SetValue failed 1 ' .. tostring(value))
			end		
		end
		
		input:SetCallback('onevent', function(widget)
			input:SetInputLine('')
		end)
		
		input:SetCallback('onevent2', function(widget)
			input:SetFocus(false)
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

		slider:SetCallback('onenddrag', function(widget)
			local value = math.floor(math.floor(tonumber(widget:GetValue())/50)*50)
			SetValue(value)
		end)
		
		slider:SetCallback('onchange', function(widget)
			local value = math.floor(math.floor(tonumber(widget:GetValue())/50)*50)
			label:SetText(value)
		end)	

		slider:SetEnabled(true)
		parent:RefreshCallbacks()
		slider:RefreshCallbacks()

		slider:SetValue(0)
		label:SetText(0)
		
	end	
	
	registerminRatingSlider('clans_create_minRating')	
	
	local regionComboboxInit = false
	local function UpdateRegionCombox()
		if (not regionComboboxInit) then
			regionComboboxInit = true
			clan_create_region_combobox:ClearItems()
			-- local regions = Login.regionsTable
			local regions = mainUI.Clans.Regions or {}
			for i, v in ipairs(regions) do
				if (v[1]) then
					-- clan_create_region_combobox:AddTemplateListItem('simpleDropdownItem', v[2], 'code', v[2], 'texture', '$invis', 'label', Translate(v[1]))
					clan_create_region_combobox:AddTemplateListItem('windowframe_combobox_lang_item', v[1], 'code', v[1], 'texture', Translate('game_region_flag_' .. v[1]), 'label', Translate('game_region_' .. v[1]))
				end
			end	
			clan_create_region_combobox:SetSelectedItemByValue((mainUI.savedLocally and mainUI.savedLocally.defaultClanRegion) or 'NA')
		end
		clan_create_region_combobox:SetEnabled(true)
	end

	clan_create_region_combobox:SetCallback('onshow', function(widget)
		UpdateRegionCombox()
	end)	
	

	local function UpdateCreateClubCost()
		local clans_create_clan_btn2_cost_label	 	= GetWidget('clans_create_clan_btn2_cost_label')
		local clans_create_clan_btn2_cost_image 	= GetWidget('clans_create_clan_btn2_cost_image')
		
		clans_create_clan_btn2_cost_label:SetText('')
		clans_create_clan_btn2_cost_image:SetTexture('$invis')
		
		local successFunction2 = function (request)
			local responseData = request:GetBody()
			if responseData == nil then
				SevereError('GetClanProducts - no data', 'general_ok', '', nil, nil, false)
				return false
			else
				println('^g GetClanProducts SUCCESS')
				printr(responseData)
				local hasAToken = false
				if (responseData.clientClanProducts and responseData.clientClanProducts.clanProducts) then
					for i,v in pairs(responseData.clientClanProducts.clanProducts) do
						if (v.type and v.type == '1') then
							hasAToken = true
						end
					end
				end
				if (hasAToken) then
					foundClubCreationProduct = true
					clans_create_clan_btn2_cost_label:SetText(Translate('general_cost_free'))
					clans_create_clan_btn2_cost_image:SetTexture('$invis')
					GetWidget('clans_create_clan_btn_buygems'):SetVisible(0)
					GetWidget('clans_create_clan_btn2'):SetVisible(1)					
				else
					local availableClanProducts = mainUI.Clans.availableClanProducts
					foundClubCreationProduct = false
					if (availableClanProducts) then
						for i,v in pairs(availableClanProducts) do
							if (v.type and v.type == '1') and (v.productIncrement) and (v.gems == nil or tonumber(v.gems) == 0) then
								foundClubCreationProduct = true
								clans_create_clan_btn2_cost_label:SetText(Translate('general_cost_free'))
								clans_create_clan_btn2_cost_image:SetTexture('$invis')
								GetWidget('clans_create_clan_btn_buygems'):SetVisible(0)
								GetWidget('clans_create_clan_btn2'):SetVisible(1)
								break
							end
						end
						for i,v in pairs(availableClanProducts) do
							if (v.type and v.type == '1') and (v.productIncrement) and (v.gems and tonumber(v.gems) and tonumber(v.gems) > 0) then
								foundClubCreationProduct = true

								clans_create_clan_btn2_cost_label:SetText(v.gems)
								clans_create_clan_btn2_cost_image:SetTexture(Translate('general_commodity_texture_gems'))
								
								local gemOffer = LuaTrigger.GetTrigger('GemOffer') 	
								GetWidget('clans_create_clan_btn_buygems'):SetVisible((tonumber(v.gems) > gemOffer.gems) or false)
								GetWidget('clans_create_clan_btn2'):SetVisible(not ((tonumber(v.gems) > gemOffer.gems) or false))
								
								break
							end
						end			
					end
					if (not foundClubCreationProduct) then
						println('^r Could not find valid clan product')
					end
				end
				UpdateCanCreateClan()
			end
		end

		local successFunction = function (request)
			local responseData = request:GetBody()
			if responseData == nil then
				SevereError('GetPurchasableClanProducts - no data', 'general_ok', '', nil, nil, false)
				return false
			else
				println('^g GetPurchasableClanProducts SUCCESS')
				printr(responseData)		
				mainUI.Clans.availableClanProducts = responseData.clanProducts.clanProducts
				Strife_Web_Requests:GetClanProducts(successFunction2)
			end
		end
		
		GetWidget('clans_create_clan_btn2'):SetVisible(0)
		GetWidget('clans_create_clan_btn_buygems'):SetVisible(0)
		Strife_Web_Requests:GetPurchasableClanProducts(successFunction)
		
	end	
	
	function mainUI.Clans.ClearCreatingClan()
		isCreatingClan = false
		UpdateCanCreateClan()
	end
	
	function mainUI.Clans.CreateClan()
		local clanName 				= interface:GetWidget('clan_create_clannameinput_buffer'):GetValue()
		local clanDescription 		= interface:GetWidget('clan_create_clandescriptioninput_buffer'):GetValue()
		-- local clanTopic				= interface:GetWidget('clan_create_chattopicinput_buffer'):GetValue()
		local clanLanguage			= interface:GetWidget('clan_create_language_combobox'):GetValue()
		local clanRegion			= interface:GetWidget('clan_create_region_combobox'):GetValue()
		local clanTag				= interface:GetWidget('clan_create_clantaginput_buffer'):GetValue()
		
		clanLanguage = string.sub(clanLanguage, 1, 2)
		
		local minRating 			=  math.floor(tonumber(interface:GetWidget('clans_create_minRating_slider'):GetValue())) - 1500
		local recruitment = 0
		local activeTags = ''
		
		isCreatingClan = true
		clans_create_clan_btn:SetEnabled(0)
		
		if (filters['membership']) then
			for i,v in pairs(filters['membership']) do
				if (v.active and v.id == 'clan_create_filter_0_1') then
					recruitment = 2
				elseif (v.active and v.id == 'clan_create_filter_0_2') then
					recruitment = 1
				elseif (v.active and v.id == 'clan_create_filter_0_3') then
					recruitment = 0
				end
			end
		end

		if (filters['focus']) then
			for i,v in pairs(filters['focus']) do
				if (v.active and v.id == 'clan_create_filter_1_1') then
					activeTags = 'social'
				elseif (v.active and v.id == 'clan_create_filter_1_2') then
					activeTags = 'competitive'
				elseif (v.active and v.id == 'clan_create_filter_1_3') then
					activeTags = 'social,competitive'
				end
			end
		end
	
		if (filters['skill']) then
			for i,v in pairs(filters['skill']) do
				if (v.active and v.id == 'clan_create_filter_2_1') then
					activeTags = activeTags .. ',newbies'
				elseif (v.active and v.id == 'clan_create_filter_2_2') then
					activeTags = activeTags .. ',experienced'
				elseif (v.active and v.id == 'clan_create_filter_2_3') then
					activeTags = activeTags .. ',newbies,experienced'
				end
			end	
		end

		mainUI.Clans.init = false
		mainUI.Clans.initInClan = false

		local successFunction = function (request)
			local responseData = request:GetBody()
			if responseData == nil then
				SevereError('PurchaseProductByIDWithCoins - no data', 'general_ok', '', nil, nil, false)
			else
				println('^g PurchaseProductByIDWithCoins SUCCESS')
				printr(responseData)
				
				println('CreateClan ' .. tostring(clanName) .. ' ' .. tostring(clanTag) .. ' ' ..tostring(clanLanguage) .. ' ' .. tostring(clanRegion)  .. ' ' .. tostring(clanDescription)  .. ' ' .. tostring(activeTags)  .. ' ' .. tostring(recruitment)   .. ' ' .. tostring(minRating) )
				
				local clans_create_clan_btn2_cost_label	 	= GetWidget('clans_create_clan_btn2_cost_label')
				local clans_create_clan_btn2_cost_image 	= GetWidget('clans_create_clan_btn2_cost_image')				
				
				clans_create_clan_btn2_cost_label:SetText(Translate('general_cost_free'))
				clans_create_clan_btn2_cost_image:SetTexture('$invis')		
				GetWidget('clans_create_clan_btn_buygems'):SetVisible(0)
				GetWidget('clans_create_clan_btn2'):SetVisible(1)		
				
				ChatClient.CreateClan(clanName, clanTag, clanLanguage, clanRegion, clanDescription, activeTags, recruitment, minRating)
				
				if (responseData.clientIdentity) and (responseData.clientIdentity.commodities) and (responseData.clientIdentity.commodities.valor) and tonumber(responseData.clientIdentity.commodities.valor) then
					SetCommodity('valor', tonumber(responseData.clientIdentity.commodities.valor))
				end
				
				if (responseData.clientIdentity) and (responseData.clientIdentity.commodities) and (responseData.clientIdentity.commodities.gems) and tonumber(responseData.clientIdentity.commodities.gems) then
					SetCommodity('gems', tonumber(responseData.clientIdentity.commodities.gems))
				end	
				
				if (responseData.clientIdentity) and (responseData.clientIdentity.commodities) and (responseData.clientIdentity.commodities.coins) and tonumber(responseData.clientIdentity.commodities.coins) then
					SetCommodity('coins', tonumber(responseData.clientIdentity.commodities.coins))
				end					
				
			end
		end

		local successFunction2 = function (request)
			local responseData = request:GetBody()
			if responseData == nil then
				SevereError('GetClanProducts - no data', 'general_ok', '', nil, nil, false)
				return false
			else
				println('^g GetClanProducts SUCCESS')
				printr(responseData)
				local hasAToken = false
				if (responseData.clientClanProducts and responseData.clientClanProducts.clanProducts) then
					for i,v in pairs(responseData.clientClanProducts.clanProducts) do
						if (v.type and v.type == '1') then
							hasAToken = true
						end
					end
				end
				if (hasAToken) then
					println('We already have a clan token, creating clan')
					println('CreateClan ' .. tostring(clanName) .. ' ' .. tostring(clanTag) .. ' ' ..tostring(clanLanguage) .. ' ' .. tostring(clanRegion)  .. ' ' .. tostring(clanDescription)  .. ' ' .. tostring(activeTags)  .. ' ' .. tostring(recruitment)   .. ' ' .. tostring(minRating) )
					ChatClient.CreateClan(clanName, clanTag, clanLanguage, clanRegion, clanDescription, activeTags, recruitment, minRating)
				else
					println('We need a clan token, searching for the right product')
					
					local availableClanProducts = mainUI.Clans.availableClanProducts
					
					local foundProduct = false
					if (availableClanProducts) then
						for i,v in pairs(availableClanProducts) do
							if (v.type and v.type == '1') and (v.productIncrement) and (v.gems == nil or tonumber(v.gems) == 0) then
								foundProduct = true
								println('Found the product for free, purchasing')
								Strife_Web_Requests:PurchaseProductByIDWithCoins(v.productIncrement, successFunction)
								break
							end
						end
						for i,v in pairs(availableClanProducts) do
							if (v.type and v.type == '1') and (v.productIncrement) and (v.gems and tonumber(v.gems) and tonumber(v.gems) > 0) then
								foundProduct = true
								println('Found the product for gems, purchasing')
								Strife_Web_Requests:PurchaseProductByID(v.productIncrement, successFunction)
								break
							end
						end							
					end
					if (not foundProduct) then
						println('^r Could not find valid clan product')
						printr(availableClanProducts)
					end
				end
				return hasAToken
			end
		end

		if (foundClubCreationProduct) then
			println('Attempting CreateClan ' .. tostring(clanName) .. ' ' .. tostring(clanTag) .. ' ' ..tostring(clanLanguage) .. ' ' .. tostring(clanRegion)  .. ' ' .. tostring(clanDescription)  .. ' ' .. tostring(activeTags)  .. ' ' .. tostring(recruitment)   .. ' ' .. tostring(minRating) )

			Strife_Web_Requests:GetClanProducts(successFunction2)
		else
			GenericDialogAutoSize('error_web_general_clan', '', Translate('error_clan_no_create_product'), 'general_ok', '', function() end, nil)
		end

	end
	
	clan_create:SetCallback('onshow', function(widget)
		UpdateCreateClubCost()
	end)
	
	clans_create_clan_btn:RegisterWatchLua('ChatClanInfo', function(widget, trigger)
		isCreatingClan = false
		UpdateCanCreateClan()
	end) -- id, name, tag, description, language, region, tags, autoAcceptMembers, minRating, title	
	
	clans_create_clan_btn:SetCallback('onclick', function(widget)
		local chatClanInfo = LuaTrigger.GetTrigger('ChatClanInfo')
		local notInClan = (chatClanInfo.id == nil or chatClanInfo.id == '' or chatClanInfo.id == '0.000')
		if (notInClan) then
			mainUI.Clans.CreateClan()
		else
			GenericDialogAutoSize(
				'clans_leave_club', '', Translate('clans_leave_club_desc2', 'value', chatClanInfo.name), 'clans_leave_club_leave', 'general_cancel',
				function() 
					clans_create_clan_btn:UnregisterWatchLua('ChatClanInfo')
					clans_create_clan_btn:RegisterWatchLua('ChatClanInfo', function(widget, trigger)
						local notInClan = (chatClanInfo.id == nil or chatClanInfo.id == '' or chatClanInfo.id == '0.000')
						if (notInClan) then						
							clans_create_clan_btn:UnregisterWatchLua('ChatClanInfo')
							clans_create_clan_btn:RegisterWatchLua('ChatClanInfo', function(widget, trigger)
								UpdateCanCreateClan()
							end)	
							mainUI.Clans.CreateClan()
						end
					end)						
					ChatClient.LeaveClan() 
				end,
				function() end
			)
		end
	end)
	
	UpdateCanCreateClan()
	
	-- println('RegisterClansCreate 2/2')
	
end

RegisterClansCreate(object)