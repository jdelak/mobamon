local interface = object

local accountBoostInfoTrigger = LuaTrigger.GetTrigger('AccountBoostInfoTrigger') or LuaTrigger.CreateCustomTrigger('AccountBoostInfoTrigger',
	{
		{ name	= 'hasPermanentXPBoost',					type	= 'boolean' },
		{ name	= 'hasPermanentCommodityBoost',				type	= 'boolean' },
		{ name	= 'hasPermanentPetBoost',					type	= 'boolean' },
		{ name	= 'hasTemporaryXPBoost',					type	= 'boolean' },
		{ name	= 'hasTemporaryCommodityBoost',				type	= 'boolean' },
		{ name	= 'hasTemporaryPetBoost',					type	= 'boolean' },
		{ name	= 'hasLANXPBoost',							type	= 'boolean' },
		{ name	= 'hasLANCommodityBoost',					type	= 'boolean' },
		{ name	= 'hasLANPetBoost',							type	= 'boolean' },		
		{ name	= 'temporaryXPBoostTimeRemaining',			type	= 'number' },
		{ name	= 'temporaryCommodityBoostTimeRemaining',	type	= 'number' },
		{ name	= 'temporaryPetBoostTimeRemaining',			type	= 'number' },
		{ name	= 'LANXPBoostTimeRemaining',				type	= 'number' },
		{ name	= 'LANCommodityBoostTimeRemaining',			type	= 'number' },
		{ name	= 'LANPetBoostTimeRemaining',				type	= 'number' },	
		{ name	= 'temporaryXPBoost1DayCost',				type	= 'number' },	
		{ name	= 'temporaryXPBoost3DayCost',				type	= 'number' },	
		{ name	= 'temporaryXPBoost7DayCost',				type	= 'number' },	
		{ name	= 'temporaryXPBoost30DayCost',				type	= 'number' },	
		{ name	= 'permanentXPBoostCost',					type	= 'number' },	
		{ name	= 'temporaryCommodityBoost1DayCost',		type	= 'number' },	
		{ name	= 'temporaryCommodityBoost3DayCost',		type	= 'number' },	
		{ name	= 'temporaryCommodityBoost7DayCost',		type	= 'number' },	
		{ name	= 'temporaryCommodityBoost30DayCost',		type	= 'number' },	
		{ name	= 'permanentCommodityBoostCost',			type	= 'number' },	
		{ name	= 'temporaryPetBoost1DayCost',				type	= 'number' },	
		{ name	= 'temporaryPetBoost3DayCost',				type	= 'number' },	
		{ name	= 'temporaryPetBoost7DayCost',				type	= 'number' },	
		{ name	= 'temporaryPetBoost30DayCost',				type	= 'number' },	
		{ name	= 'permanentPetBoostCost',					type	= 'number' },			
	}
)

accountBoostInfoTrigger.hasPermanentXPBoost 					= false
accountBoostInfoTrigger.hasPermanentCommodityBoost 				= false
accountBoostInfoTrigger.hasPermanentPetBoost 					= false
accountBoostInfoTrigger.hasTemporaryXPBoost 					= false
accountBoostInfoTrigger.hasTemporaryCommodityBoost 				= false
accountBoostInfoTrigger.hasTemporaryPetBoost 					= false
accountBoostInfoTrigger.hasLANXPBoost 							= false
accountBoostInfoTrigger.hasLANCommodityBoost 					= false
accountBoostInfoTrigger.hasLANPetBoost 							= false
accountBoostInfoTrigger.temporaryXPBoostTimeRemaining 			= -1
accountBoostInfoTrigger.temporaryCommodityBoostTimeRemaining 	= -1
accountBoostInfoTrigger.temporaryPetBoostTimeRemaining 			= -1
accountBoostInfoTrigger.LANXPBoostTimeRemaining 				= -1
accountBoostInfoTrigger.LANCommodityBoostTimeRemaining 			= -1
accountBoostInfoTrigger.LANPetBoostTimeRemaining 				= -1
accountBoostInfoTrigger.temporaryXPBoost1DayCost 				= -1
accountBoostInfoTrigger.temporaryXPBoost3DayCost 				= -1
accountBoostInfoTrigger.temporaryXPBoost7DayCost 				= -1
accountBoostInfoTrigger.temporaryXPBoost30DayCost 				= -1
accountBoostInfoTrigger.permanentXPBoostCost 					= -1
accountBoostInfoTrigger.temporaryCommodityBoost1DayCost 		= -1
accountBoostInfoTrigger.temporaryCommodityBoost3DayCost 		= -1
accountBoostInfoTrigger.temporaryCommodityBoost7DayCost 		= -1
accountBoostInfoTrigger.temporaryCommodityBoost30DayCost 		= -1
accountBoostInfoTrigger.permanentCommodityBoostCost 			= -1
accountBoostInfoTrigger.temporaryPetBoost1DayCost 				= -1
accountBoostInfoTrigger.temporaryPetBoost3DayCost 				= -1
accountBoostInfoTrigger.temporaryPetBoost7DayCost 				= -1
accountBoostInfoTrigger.temporaryPetBoost30DayCost 				= -1
accountBoostInfoTrigger.permanentPetBoostCost 					= -1
accountBoostInfoTrigger:Trigger(false)

libBoost = {
	
	SetUpAccountBoostSplash = function()
		local splash_screen_purchase_account_remaining_duration_bar									= GetWidget('splash_screen_purchase_account_remaining_duration_bar')
		local splash_screen_purchase_account_remaining_duration_bar_new_leader						= GetWidget('splash_screen_purchase_account_remaining_duration_bar_new_leader')
		local splash_screen_purchase_account_remaining_duration_label								= GetWidget('splash_screen_purchase_account_remaining_duration_label')
		local splash_screen_purchase_account_confirm_1_day											= GetWidget('splash_screen_purchase_account_confirm_1_day')
		local splash_screen_purchase_account_confirm_gemcost_1_day									= GetWidget('splash_screen_purchase_account_confirm_gemcost_1_day')
		local splash_screen_purchase_account_confirm_gemcost_label_1_day							= GetWidget('splash_screen_purchase_account_confirm_gemcost_label_1_day')
		local splash_screen_purchase_account_confirm_3_day											= GetWidget('splash_screen_purchase_account_confirm_3_day')
		local splash_screen_purchase_account_confirm_gemcost_3_day									= GetWidget('splash_screen_purchase_account_confirm_gemcost_3_day')
		local splash_screen_purchase_account_confirm_gemcost_label_3_day							= GetWidget('splash_screen_purchase_account_confirm_gemcost_label_3_day')
		local splash_screen_purchase_account_confirm_7_day											= GetWidget('splash_screen_purchase_account_confirm_7_day')
		local splash_screen_purchase_account_confirm_gemcost_7_day									= GetWidget('splash_screen_purchase_account_confirm_gemcost_7_day')
		local splash_screen_purchase_account_confirm_gemcost_label_7_day							= GetWidget('splash_screen_purchase_account_confirm_gemcost_label_7_day')
		local splash_screen_purchase_account_confirm_30_day											= GetWidget('splash_screen_purchase_account_confirm_30_day')
		local splash_screen_purchase_account_confirm_gemcost_30_day									= GetWidget('splash_screen_purchase_account_confirm_gemcost_30_day')
		local splash_screen_purchase_account_confirm_gemcost_label_30_day							= GetWidget('splash_screen_purchase_account_confirm_gemcost_label_30_day')
		-- local splash_screen_purchase_account_confirm_permanent										= GetWidget('splash_screen_purchase_account_confirm_permanent')
		-- local splash_screen_purchase_account_confirm_gemcost_permanent								= GetWidget('splash_screen_purchase_account_confirm_gemcost_permanent')
		-- local splash_screen_purchase_account_confirm_gemcost_label_permanent						= GetWidget('splash_screen_purchase_account_confirm_gemcost_label_permanent')
		
		
		if (not splash_screen_purchase_account_remaining_duration_bar) then
			mainUI.ShowSplashScreen()
			return
		elseif (accountBoostInfoTrigger.hasPermanentXPBoost) or (accountBoostInfoTrigger.hasPermanentCommodityBoost) then
			splash_screen_purchase_account_confirm_1_day:SetEnabled(0)
			splash_screen_purchase_account_confirm_3_day:SetEnabled(0)
			splash_screen_purchase_account_confirm_7_day:SetEnabled(0)
			splash_screen_purchase_account_confirm_30_day:SetEnabled(0)
			-- splash_screen_purchase_account_confirm_permanent:SetEnabled(0)
			GetWidget('splash_screen_purchase_account_confirm_1_dayBackground'):SetRenderMode('grayscale')
			GetWidget('splash_screen_purchase_account_confirm_3_dayBackground'):SetRenderMode('grayscale')
			GetWidget('splash_screen_purchase_account_confirm_7_dayBackground'):SetRenderMode('grayscale')
			GetWidget('splash_screen_purchase_account_confirm_30_dayBackground'):SetRenderMode('grayscale')
			-- GetWidget('splash_screen_purchase_account_confirm_permanentBackground'):SetRenderMode('grayscale')
			splash_screen_purchase_account_remaining_duration_bar:SetWidth('100%')
			splash_screen_purchase_account_remaining_duration_label:SetText(Translate('purchase_account_bar_lbl_remaining_permanent'))
			splash_screen_purchase_account_confirm_gemcost_label_1_day:SetText(accountBoostInfoTrigger.temporaryXPBoost1DayCost + accountBoostInfoTrigger.temporaryCommodityBoost1DayCost)
			splash_screen_purchase_account_confirm_gemcost_label_3_day:SetText(accountBoostInfoTrigger.temporaryXPBoost3DayCost + accountBoostInfoTrigger.temporaryCommodityBoost3DayCost)
			splash_screen_purchase_account_confirm_gemcost_label_7_day:SetText(accountBoostInfoTrigger.temporaryXPBoost7DayCost + accountBoostInfoTrigger.temporaryCommodityBoost7DayCost)
			splash_screen_purchase_account_confirm_gemcost_label_30_day:SetText(accountBoostInfoTrigger.temporaryXPBoost30DayCost + accountBoostInfoTrigger.temporaryCommodityBoost30DayCost)
			-- splash_screen_purchase_account_confirm_gemcost_label_permanent:SetText(accountBoostInfoTrigger.permanentXPBoostCost + accountBoostInfoTrigger.permanentXPBoostCost)		
			splash_screen_purchase_account_confirm_1_day:SetVisible((accountBoostInfoTrigger.temporaryXPBoost1DayCost >= 0) and (accountBoostInfoTrigger.temporaryCommodityBoost1DayCost >= 0))
			splash_screen_purchase_account_confirm_gemcost_1_day:SetVisible((accountBoostInfoTrigger.temporaryXPBoost1DayCost >= 0) and (accountBoostInfoTrigger.temporaryCommodityBoost1DayCost >= 0))
			splash_screen_purchase_account_confirm_3_day:SetVisible((accountBoostInfoTrigger.temporaryXPBoost3DayCost >= 0) and (accountBoostInfoTrigger.temporaryCommodityBoost3DayCost >= 0))
			splash_screen_purchase_account_confirm_gemcost_3_day:SetVisible((accountBoostInfoTrigger.temporaryXPBoost3DayCost >= 0) and (accountBoostInfoTrigger.temporaryCommodityBoost3DayCost >= 0))
			splash_screen_purchase_account_confirm_7_day:SetVisible((accountBoostInfoTrigger.temporaryXPBoost7DayCost >= 0) and (accountBoostInfoTrigger.temporaryCommodityBoost7DayCost >= 0))
			splash_screen_purchase_account_confirm_gemcost_7_day:SetVisible((accountBoostInfoTrigger.temporaryXPBoost7DayCost >= 0) and (accountBoostInfoTrigger.temporaryCommodityBoost7DayCost >= 0))
			splash_screen_purchase_account_confirm_30_day:SetVisible((accountBoostInfoTrigger.temporaryXPBoost30DayCost >= 0) and (accountBoostInfoTrigger.temporaryCommodityBoost30DayCost >= 0))
			splash_screen_purchase_account_confirm_gemcost_30_day:SetVisible((accountBoostInfoTrigger.temporaryXPBoost30DayCost >= 0) and (accountBoostInfoTrigger.temporaryCommodityBoost30DayCost >= 0))
			-- splash_screen_purchase_account_confirm_permanent:SetVisible((accountBoostInfoTrigger.permanentXPBoostCost >= 0) and (accountBoostInfoTrigger.permanentCommodityBoostCost >= 0))
			-- splash_screen_purchase_account_confirm_gemcost_permanent:SetVisible((accountBoostInfoTrigger.permanentXPBoostCost >= 0) and (accountBoostInfoTrigger.permanentCommodityBoostCost >= 0))
		else
			splash_screen_purchase_account_confirm_1_day:SetEnabled(1)
			splash_screen_purchase_account_confirm_3_day:SetEnabled(1)
			splash_screen_purchase_account_confirm_7_day:SetEnabled(1)
			splash_screen_purchase_account_confirm_30_day:SetEnabled(1)
			-- splash_screen_purchase_account_confirm_permanent:SetEnabled(1)
			GetWidget('splash_screen_purchase_account_confirm_1_dayBackground'):SetRenderMode('normal')
			GetWidget('splash_screen_purchase_account_confirm_3_dayBackground'):SetRenderMode('normal')
			GetWidget('splash_screen_purchase_account_confirm_7_dayBackground'):SetRenderMode('normal')
			GetWidget('splash_screen_purchase_account_confirm_30_dayBackground'):SetRenderMode('normal')
			-- GetWidget('splash_screen_purchase_account_confirm_permanentBackground'):SetRenderMode('normal')			
			splash_screen_purchase_account_confirm_gemcost_label_1_day:SetText(accountBoostInfoTrigger.temporaryXPBoost1DayCost + accountBoostInfoTrigger.temporaryCommodityBoost1DayCost)
			splash_screen_purchase_account_confirm_gemcost_label_3_day:SetText(accountBoostInfoTrigger.temporaryXPBoost3DayCost + accountBoostInfoTrigger.temporaryCommodityBoost3DayCost)
			splash_screen_purchase_account_confirm_gemcost_label_7_day:SetText(accountBoostInfoTrigger.temporaryXPBoost7DayCost + accountBoostInfoTrigger.temporaryCommodityBoost7DayCost)
			splash_screen_purchase_account_confirm_gemcost_label_30_day:SetText(accountBoostInfoTrigger.temporaryXPBoost30DayCost + accountBoostInfoTrigger.temporaryCommodityBoost30DayCost)
			-- splash_screen_purchase_account_confirm_gemcost_label_permanent:SetText(accountBoostInfoTrigger.permanentXPBoostCost + accountBoostInfoTrigger.permanentCommodityBoostCost)			
			splash_screen_purchase_account_confirm_1_day:SetVisible((accountBoostInfoTrigger.temporaryXPBoost1DayCost >= 0) and (accountBoostInfoTrigger.temporaryCommodityBoost1DayCost >= 0))
			splash_screen_purchase_account_confirm_gemcost_1_day:SetVisible((accountBoostInfoTrigger.temporaryXPBoost1DayCost >= 0) and (accountBoostInfoTrigger.temporaryCommodityBoost1DayCost >= 0))
			splash_screen_purchase_account_confirm_3_day:SetVisible((accountBoostInfoTrigger.temporaryXPBoost3DayCost >= 0) and (accountBoostInfoTrigger.temporaryCommodityBoost3DayCost >= 0))
			splash_screen_purchase_account_confirm_gemcost_3_day:SetVisible((accountBoostInfoTrigger.temporaryXPBoost3DayCost >= 0) and (accountBoostInfoTrigger.temporaryCommodityBoost3DayCost >= 0))
			splash_screen_purchase_account_confirm_7_day:SetVisible((accountBoostInfoTrigger.temporaryXPBoost7DayCost >= 0) and (accountBoostInfoTrigger.temporaryCommodityBoost7DayCost >= 0))
			splash_screen_purchase_account_confirm_gemcost_7_day:SetVisible((accountBoostInfoTrigger.temporaryXPBoost7DayCost >= 0) and (accountBoostInfoTrigger.temporaryCommodityBoost7DayCost >= 0))
			splash_screen_purchase_account_confirm_30_day:SetVisible((accountBoostInfoTrigger.temporaryXPBoost30DayCost >= 0) and (accountBoostInfoTrigger.temporaryCommodityBoost30DayCost >= 0))
			splash_screen_purchase_account_confirm_gemcost_30_day:SetVisible((accountBoostInfoTrigger.temporaryXPBoost30DayCost >= 0) and (accountBoostInfoTrigger.temporaryCommodityBoost30DayCost >= 0))			
			-- splash_screen_purchase_account_confirm_permanent:SetVisible((accountBoostInfoTrigger.permanentXPBoostCost >= 0) and (accountBoostInfoTrigger.permanentCommodityBoostCost >= 0))
			-- splash_screen_purchase_account_confirm_gemcost_permanent:SetVisible((accountBoostInfoTrigger.permanentXPBoostCost >= 0) and (accountBoostInfoTrigger.permanentCommodityBoostCost >= 0))
			
			if (accountBoostInfoTrigger.hasTemporaryXPBoost) then
				if ((accountBoostInfoTrigger.temporaryXPBoostTimeRemaining) and (accountBoostInfoTrigger.temporaryXPBoostTimeRemaining > 0)) then
					local dayToSeconds = (60 * 60 * 24)
					local hourToSeconds = (60 * 60)
					local minuteToSeconds = (60)
					local daysRemaining = math.floor(accountBoostInfoTrigger.temporaryXPBoostTimeRemaining / (dayToSeconds))
					local hoursRemaining = math.floor((accountBoostInfoTrigger.temporaryXPBoostTimeRemaining - (daysRemaining * dayToSeconds))/hourToSeconds)
					local minutesRemaining = math.floor((accountBoostInfoTrigger.temporaryXPBoostTimeRemaining - ((daysRemaining * dayToSeconds) + (hoursRemaining * hourToSeconds)))/minuteToSeconds)
					local barWidth = math.max(0, math.min(100, ((accountBoostInfoTrigger.temporaryXPBoostTimeRemaining / (7 * dayToSeconds)) * 100)))
					splash_screen_purchase_account_remaining_duration_bar:ScaleWidth(barWidth .. '%', 125)
					splash_screen_purchase_account_remaining_duration_bar_new_leader:SlideX(barWidth .. '%', 125)
					splash_screen_purchase_account_remaining_duration_bar_new_leader:FadeIn(125)					
					if (daysRemaining > 0) then
						splash_screen_purchase_account_remaining_duration_label:SetText(Translate('purchase_account_bar_lbl_remaining_days', 'value', daysRemaining, 'value2', hoursRemaining))	
					elseif (hoursRemaining > 0) then
						splash_screen_purchase_account_remaining_duration_label:SetText(Translate('purchase_account_bar_lbl_remaining_hours', 'value', hoursRemaining, 'value2', minutesRemaining))	
					elseif (minutesRemaining > 0) then
						splash_screen_purchase_account_remaining_duration_label:SetText(Translate('purchase_account_bar_lbl_remaining_minutes', 'value', minutesRemaining))
					else
						local formattedRemaining = libNumber.timeFormat((accountBoostInfoTrigger.temporaryXPBoostTimeRemaining) * 1000)
						splash_screen_purchase_account_remaining_duration_label:SetText(Translate('purchase_account_bar_lbl_remaining_all', 'value', formattedRemaining))		
					end
				else
					splash_screen_purchase_account_remaining_duration_bar:ScaleWidth('0%', 125)
					splash_screen_purchase_account_remaining_duration_label:SetText(Translate('purchase_account_bar_lbl_remaining_error'))						
				end
			elseif (accountBoostInfoTrigger.hasLANXPBoost) or (accountBoostInfoTrigger.hasLANCommodityBoost) then
				splash_screen_purchase_account_remaining_duration_bar:ScaleWidth('20%', 125)
				splash_screen_purchase_account_remaining_duration_label:SetText(Translate('purchase_account_bar_lbl_remaining_lan'))					
			else
				splash_screen_purchase_account_remaining_duration_bar:ScaleWidth('0%', 125)
				splash_screen_purchase_account_remaining_duration_label:SetText(Translate('purchase_account_bar_lbl_remaining_none'))				
			end
			
			splash_screen_purchase_account_remaining_duration_bar:UnregisterWatchLua('AccountBoostInfoTrigger')
			splash_screen_purchase_account_remaining_duration_bar:RegisterWatchLua('AccountBoostInfoTrigger', function(widget, trigger)
				if (accountBoostInfoTrigger.hasTemporaryXPBoost) then
					if ((accountBoostInfoTrigger.temporaryXPBoostTimeRemaining) and (accountBoostInfoTrigger.temporaryXPBoostTimeRemaining > 0)) then
						local dayToSeconds = (60 * 60 * 24)
						local hourToSeconds = (60 * 60)
						local minuteToSeconds = (60)
						local daysRemaining = math.floor(accountBoostInfoTrigger.temporaryXPBoostTimeRemaining / (dayToSeconds))
						local hoursRemaining = math.floor((accountBoostInfoTrigger.temporaryXPBoostTimeRemaining - (daysRemaining * dayToSeconds))/hourToSeconds)
						local minutesRemaining = math.floor((accountBoostInfoTrigger.temporaryXPBoostTimeRemaining - ((daysRemaining * dayToSeconds) + (hoursRemaining * hourToSeconds)))/minuteToSeconds)
						local barWidth = math.max(0, math.min(100, ((accountBoostInfoTrigger.temporaryXPBoostTimeRemaining / (7 * dayToSeconds)) * 100)))
						splash_screen_purchase_account_remaining_duration_bar:ScaleWidth(barWidth .. '%', 125)
						splash_screen_purchase_account_remaining_duration_bar_new_leader:SlideX(barWidth .. '%', 125)
						splash_screen_purchase_account_remaining_duration_bar_new_leader:FadeIn(125)					
						if (daysRemaining > 0) then
							splash_screen_purchase_account_remaining_duration_label:SetText(Translate('purchase_account_bar_lbl_remaining_days', 'value', daysRemaining, 'value2', hoursRemaining))
						elseif (hoursRemaining > 0) then
							splash_screen_purchase_account_remaining_duration_label:SetText(Translate('purchase_account_bar_lbl_remaining_hours', 'value', hoursRemaining))	
						elseif (minutesRemaining > 0) then
							splash_screen_purchase_account_remaining_duration_label:SetText(Translate('purchase_account_bar_lbl_remaining_minutes', 'value', minutesRemaining))
						else
							local formattedRemaining = libNumber.timeFormat((accountBoostInfoTrigger.temporaryXPBoostTimeRemaining) * 1000)
							splash_screen_purchase_account_remaining_duration_label:SetText(Translate('purchase_account_bar_lbl_remaining_all', 'value', formattedRemaining))		
						end
					else
						splash_screen_purchase_account_remaining_duration_bar:ScaleWidth('0%', 125)
						splash_screen_purchase_account_remaining_duration_label:SetText(Translate('purchase_account_bar_lbl_remaining_error'))						
					end
				elseif (accountBoostInfoTrigger.hasLANXPBoost) or (accountBoostInfoTrigger.hasLANCommodityBoost) then
					splash_screen_purchase_account_remaining_duration_bar:ScaleWidth('20%', 125)
					splash_screen_purchase_account_remaining_duration_label:SetText(Translate('purchase_account_bar_lbl_remaining_lan'))					
				else
					splash_screen_purchase_account_remaining_duration_bar:ScaleWidth('0%', 125)
					splash_screen_purchase_account_remaining_duration_label:SetText(Translate('purchase_account_bar_lbl_remaining_none'))				
				end
				splash_screen_purchase_account_confirm_1_day:SetEnabled(1)
				splash_screen_purchase_account_confirm_3_day:SetEnabled(1)
				splash_screen_purchase_account_confirm_7_day:SetEnabled(1)
				splash_screen_purchase_account_confirm_30_day:SetEnabled(1)
				-- splash_screen_purchase_account_confirm_permanent:SetEnabled(1)
				GetWidget('splash_screen_purchase_account_confirm_1_dayBackground'):SetRenderMode('normal')
				GetWidget('splash_screen_purchase_account_confirm_3_dayBackground'):SetRenderMode('normal')
				GetWidget('splash_screen_purchase_account_confirm_7_dayBackground'):SetRenderMode('normal')
				GetWidget('splash_screen_purchase_account_confirm_30_dayBackground'):SetRenderMode('normal')
				-- GetWidget('splash_screen_purchase_account_confirm_permanentBackground'):SetRenderMode('normal')			
				splash_screen_purchase_account_confirm_gemcost_label_1_day:SetText(accountBoostInfoTrigger.temporaryXPBoost1DayCost + accountBoostInfoTrigger.temporaryCommodityBoost1DayCost)
				splash_screen_purchase_account_confirm_gemcost_label_3_day:SetText(accountBoostInfoTrigger.temporaryXPBoost3DayCost + accountBoostInfoTrigger.temporaryCommodityBoost3DayCost)
				splash_screen_purchase_account_confirm_gemcost_label_7_day:SetText(accountBoostInfoTrigger.temporaryXPBoost7DayCost + accountBoostInfoTrigger.temporaryCommodityBoost7DayCost)
				splash_screen_purchase_account_confirm_gemcost_label_30_day:SetText(accountBoostInfoTrigger.temporaryXPBoost30DayCost + accountBoostInfoTrigger.temporaryCommodityBoost30DayCost)
				-- splash_screen_purchase_account_confirm_gemcost_label_permanent:SetText(accountBoostInfoTrigger.permanentXPBoostCost + accountBoostInfoTrigger.permanentCommodityBoostCost)			
				splash_screen_purchase_account_confirm_1_day:SetVisible((accountBoostInfoTrigger.temporaryXPBoost1DayCost >= 0) and (accountBoostInfoTrigger.temporaryCommodityBoost1DayCost >= 0))
				splash_screen_purchase_account_confirm_gemcost_1_day:SetVisible((accountBoostInfoTrigger.temporaryXPBoost1DayCost >= 0) and (accountBoostInfoTrigger.temporaryCommodityBoost1DayCost >= 0))
				splash_screen_purchase_account_confirm_3_day:SetVisible((accountBoostInfoTrigger.temporaryXPBoost3DayCost >= 0) and (accountBoostInfoTrigger.temporaryCommodityBoost3DayCost >= 0))
				splash_screen_purchase_account_confirm_gemcost_3_day:SetVisible((accountBoostInfoTrigger.temporaryXPBoost3DayCost >= 0) and (accountBoostInfoTrigger.temporaryCommodityBoost3DayCost >= 0))
				splash_screen_purchase_account_confirm_7_day:SetVisible((accountBoostInfoTrigger.temporaryXPBoost7DayCost >= 0) and (accountBoostInfoTrigger.temporaryCommodityBoost7DayCost >= 0))
				splash_screen_purchase_account_confirm_gemcost_7_day:SetVisible((accountBoostInfoTrigger.temporaryXPBoost7DayCost >= 0) and (accountBoostInfoTrigger.temporaryCommodityBoost7DayCost >= 0))
				splash_screen_purchase_account_confirm_30_day:SetVisible((accountBoostInfoTrigger.temporaryXPBoost30DayCost >= 0) and (accountBoostInfoTrigger.temporaryCommodityBoost30DayCost >= 0))
				splash_screen_purchase_account_confirm_gemcost_30_day:SetVisible((accountBoostInfoTrigger.temporaryXPBoost30DayCost >= 0) and (accountBoostInfoTrigger.temporaryCommodityBoost30DayCost >= 0))			
				-- splash_screen_purchase_account_confirm_permanent:SetVisible((accountBoostInfoTrigger.permanentXPBoostCost >= 0) and (accountBoostInfoTrigger.permanentCommodityBoostCost >= 0))
				-- splash_screen_purchase_account_confirm_gemcost_permanent:SetVisible((accountBoostInfoTrigger.permanentXPBoostCost >= 0) and (accountBoostInfoTrigger.permanentCommodityBoostCost >= 0))			
			end)

			local function RegisterBoostPurchaseButton(title, widget, gems, label, onclick1, onclick2)
				widget:SetCallback('onmouseover', function(widget) UpdateCursor(widget, true, { canLeftClick = true, canRightClick = false, spendGems = true }) end)
				widget:SetCallback('onmouseout', function(widget) UpdateCursor(widget, false, { canLeftClick = true, canRightClick = false, spendGems = true }) end)
				widget:SetCallback('onclick', function()
					-- mainUI.ShowSplashScreen()			
					spendGemsShow(
						function()
							println('^o^: Purchase Account Boost ' .. tostring(label) .. ' ' .. tostring(gems) .. ' ' .. tostring(onclick1))
							if onclick1 and onclick2 then
								splash_screen_purchase_account_confirm_1_day:SetEnabled(0)
								splash_screen_purchase_account_confirm_3_day:SetEnabled(0)
								splash_screen_purchase_account_confirm_7_day:SetEnabled(0)
								splash_screen_purchase_account_confirm_30_day:SetEnabled(0)
								-- splash_screen_purchase_account_confirm_permanent:SetEnabled(0)
								GetWidget('splash_screen_purchase_account_confirm_1_dayBackground'):SetRenderMode('grayscale')
								GetWidget('splash_screen_purchase_account_confirm_3_dayBackground'):SetRenderMode('grayscale')
								GetWidget('splash_screen_purchase_account_confirm_7_dayBackground'):SetRenderMode('grayscale')
								GetWidget('splash_screen_purchase_account_confirm_30_dayBackground'):SetRenderMode('grayscale')
								-- GetWidget('splash_screen_purchase_account_confirm_permanentBackground'):SetRenderMode('grayscale')																
								
								interface:UnregisterWatchLua('GameClientRequestsPurchaseBoost')
								interface:RegisterWatchLua('GameClientRequestsPurchaseBoost', function(widget, requestStatusTrigger)
									if (requestStatusTrigger.status > 1) then
										println('^g GameClientRequestsPurchaseBoost.status ' .. requestStatusTrigger.status)
										mainUI.RefreshProducts(function()
											interface:UnregisterWatchLua('GameClientRequestsPurchaseBoost')
											interface:RegisterWatchLua('GameClientRequestsPurchaseBoost', function(widget, requestStatusTrigger)
												if (requestStatusTrigger.status > 1) then
													println('^g GameClientRequestsPurchaseBoost.status ' .. requestStatusTrigger.status)
													mainUI.RefreshProducts(
														function()
															println('^g RefreshProducts GameClientRequestsPurchaseBoost')
															PlaySound('/ui/sounds/pets/sfx_unlock.wav')
															if (splash_screen_purchase_account_confirm_1_day) and (splash_screen_purchase_account_confirm_1_day:IsValid()) then
																splash_screen_purchase_account_confirm_1_day:SetEnabled(1)
																splash_screen_purchase_account_confirm_3_day:SetEnabled(1)
																splash_screen_purchase_account_confirm_7_day:SetEnabled(1)
																splash_screen_purchase_account_confirm_30_day:SetEnabled(1)
																-- splash_screen_purchase_account_confirm_permanent:SetEnabled(1)
																GetWidget('splash_screen_purchase_account_confirm_1_dayBackground'):SetRenderMode('normal')
																GetWidget('splash_screen_purchase_account_confirm_3_dayBackground'):SetRenderMode('normal')
																GetWidget('splash_screen_purchase_account_confirm_7_dayBackground'):SetRenderMode('normal')
																GetWidget('splash_screen_purchase_account_confirm_30_dayBackground'):SetRenderMode('normal')
																-- GetWidget('splash_screen_purchase_account_confirm_permanentBackground'):SetRenderMode('normal')	
															end
														end
													)
													interface:UnregisterWatchLua('GameClientRequestsPurchaseBoost')
												end
											end)	
											println('^o^: Purchasing Boost 2')
											onclick2()
										end)
									end
								end)
								println('^o^: Purchasing Boost 1')
								onclick1()
								
							end
						end,
						label, 
						title,
						gems, 
						function() 
							if (splash_screen_purchase_account_confirm_1_day) and (splash_screen_purchase_account_confirm_1_day:IsValid()) then
								splash_screen_purchase_account_confirm_1_day:SetEnabled(1)
								splash_screen_purchase_account_confirm_3_day:SetEnabled(1)
								splash_screen_purchase_account_confirm_7_day:SetEnabled(1)
								splash_screen_purchase_account_confirm_30_day:SetEnabled(1)
								-- splash_screen_purchase_account_confirm_permanent:SetEnabled(1)
								GetWidget('splash_screen_purchase_account_confirm_1_dayBackground'):SetRenderMode('normal')
								GetWidget('splash_screen_purchase_account_confirm_3_dayBackground'):SetRenderMode('normal')
								GetWidget('splash_screen_purchase_account_confirm_7_dayBackground'):SetRenderMode('normal')
								GetWidget('splash_screen_purchase_account_confirm_30_dayBackground'):SetRenderMode('normal')
								-- GetWidget('splash_screen_purchase_account_confirm_permanentBackground'):SetRenderMode('normal')
							end
						end
					)
				end)
				widget:RefreshCallbacks()			
			end
			
			RegisterBoostPurchaseButton(Translate('purchase_account_boost_1_day_title'), splash_screen_purchase_account_confirm_1_day, 		accountBoostInfoTrigger.temporaryXPBoost1DayCost + accountBoostInfoTrigger.temporaryCommodityBoost1DayCost, Translate('purchase_account_boost_1_day_title'),  		function() Boost.PurchaseDayBoost('experience', 1)   end,  function() Boost.PurchaseDayBoost('commodities', 1) end)
			RegisterBoostPurchaseButton(Translate('purchase_account_boost_3_day_title'), splash_screen_purchase_account_confirm_3_day, 		accountBoostInfoTrigger.temporaryXPBoost3DayCost + accountBoostInfoTrigger.temporaryCommodityBoost3DayCost, Translate('purchase_account_boost_3_day_title'),  		function() Boost.PurchaseDayBoost('experience', 3)   end,  function() Boost.PurchaseDayBoost('commodities', 3) end)
			RegisterBoostPurchaseButton(Translate('purchase_account_boost_7_day_title'), splash_screen_purchase_account_confirm_7_day, 		accountBoostInfoTrigger.temporaryXPBoost7DayCost + accountBoostInfoTrigger.temporaryCommodityBoost7DayCost, Translate('purchase_account_boost_7_day_title'),  		function() Boost.PurchaseDayBoost('experience', 7)   end,  function() Boost.PurchaseDayBoost('commodities', 7) end)
			RegisterBoostPurchaseButton(Translate('purchase_account_boost_30_day_title'), splash_screen_purchase_account_confirm_30_day, 		accountBoostInfoTrigger.temporaryXPBoost30DayCost + accountBoostInfoTrigger.temporaryCommodityBoost30DayCost, Translate('purchase_account_boost_30_day_title'),     function() Boost.PurchaseDayBoost('experience', 30)  end,  function() Boost.PurchaseDayBoost('commodities', 30) end)                                         
			-- RegisterBoostPurchaseButton(Translate('purchase_account_boost_perm_title'), splash_screen_purchase_account_confirm_permanent, 	accountBoostInfoTrigger.permanentXPBoostCost 	 + accountBoostInfoTrigger.permanentCommodityBoostCost, 	Translate('purchase_account_boost_title'),  	    function() Boost.PurchaseDayBoost('experience', -1)  end,  function() Boost.PurchaseDayBoost('commodities', -1) end)
			
		end		
		
	end,
	
	ShowAccountBoostPurchaseSplash = function()
		mainUI.ShowSplashScreen('splash_screen_purchase_account_boost')	
	end,

}

object:RegisterWatchLua('AccountBoostInfoTrigger', function(widget, trigger)
	mainUI.savedLocally  							= mainUI.savedLocally  or {}
	mainUI.savedLocally.accountBoostInfo	 		= mainUI.savedLocally.accountBoostInfo or {}

	if (trigger.hasTemporaryXPBoost) then
		if (trigger.temporaryXPBoostTimeRemaining) and (trigger.temporaryXPBoostTimeRemaining > 0) then	
			mainUI.savedLocally.accountBoostInfo.hadTemporaryXPBoost = true
		else
			if (mainUI.savedLocally.accountBoostInfo.hadTemporaryXPBoost) and (not trigger.hasPermanentXPBoost) then
				-- mainUI.savedLocally.accountBoostInfo.notifyOfXPBoostExpiry = true
				mainUI.savedLocally.accountBoostInfo.hadTemporaryXPBoost = false
				SaveState()
			end
		end
	else
		if (mainUI.savedLocally.accountBoostInfo.hadTemporaryXPBoost) and (not trigger.hasPermanentXPBoost) then
			-- mainUI.savedLocally.accountBoostInfo.notifyOfXPBoostExpiry = true
			mainUI.savedLocally.accountBoostInfo.hadTemporaryXPBoost = false
			SaveState()
		end	
	end
	
end, true, nil, 'hasTemporaryXPBoost', 'hasPermanentXPBoost', 'temporaryXPBoostTimeRemaining')

-- == Get Boost Data from code

local function BoostDataRegister(object)

	object:RegisterWatchLua('ExpBoost', function(widget, trigger)
		UnwatchLuaTriggerByKey('CountDownSeconds', 'ExpBoostCountDownKey')
		if (trigger.isBoosted) and (trigger.multiplier > 1) then
			if (trigger.timedBoost) and (tonumber(trigger.endTime) > 0) then
				accountBoostInfoTrigger.hasPermanentXPBoost 				= false
				accountBoostInfoTrigger.hasTemporaryXPBoost 				= true
				
				accountBoostInfoTrigger.temporaryXPBoostTimeRemaining 		= trigger.endTime - LuaTrigger.GetTrigger('System').unixTimestamp

				WatchLuaTrigger('CountDownSeconds', function(countDownTrigger)
					if (accountBoostInfoTrigger.temporaryXPBoostTimeRemaining > 0) then
						accountBoostInfoTrigger.temporaryXPBoostTimeRemaining = accountBoostInfoTrigger.temporaryXPBoostTimeRemaining - 1
						accountBoostInfoTrigger:Trigger(false)
					else
						accountBoostInfoTrigger.temporaryXPBoostTimeRemaining = 0
						accountBoostInfoTrigger:Trigger(false)
						UnwatchLuaTriggerByKey('CountDownSeconds', 'ExpBoostCountDownKey')
					end
				end, 'ExpBoostCountDownKey', 'timeSeconds')				
				
			elseif (true) then -- (trigger.endTime == -1) ?
				accountBoostInfoTrigger.hasPermanentXPBoost 				= true
				accountBoostInfoTrigger.hasTemporaryXPBoost 				= false
				accountBoostInfoTrigger.temporaryXPBoostTimeRemaining 		= 0	
			end
		else
			accountBoostInfoTrigger.hasPermanentXPBoost 				= false
			accountBoostInfoTrigger.hasTemporaryXPBoost 				= false
			accountBoostInfoTrigger.temporaryXPBoostTimeRemaining 		= 0
		end
		accountBoostInfoTrigger:Trigger(false)
	end, true, nil, 'endTime', 'endTimeString', 'isBoosted', 'multiplier', 'timedBoost')
	LuaTrigger.GetTrigger('ExpBoost'):Trigger(true)
	
	object:RegisterWatchLua('CommodityBoost', function(widget, trigger)
		UnwatchLuaTriggerByKey('CountDownSeconds', 'CommodityBoostCountDownKey')
		if (trigger.isBoosted) and (trigger.multiplier > 1) then
			if (trigger.timedBoost) and (tonumber(trigger.endTime) > 0) then
				accountBoostInfoTrigger.hasPermanentCommodityBoost 				= false
				accountBoostInfoTrigger.hasTemporaryCommodityBoost 				= true
				
				accountBoostInfoTrigger.temporaryCommodityBoostTimeRemaining 		= trigger.endTime -LuaTrigger.GetTrigger('System').unixTimestamp
				
				WatchLuaTrigger('CountDownSeconds', function(countDownTrigger)
					if (accountBoostInfoTrigger.temporaryCommodityBoostTimeRemaining > 0) then
						accountBoostInfoTrigger.temporaryCommodityBoostTimeRemaining = accountBoostInfoTrigger.temporaryCommodityBoostTimeRemaining - 1
						accountBoostInfoTrigger:Trigger(false)
					else
						accountBoostInfoTrigger.temporaryCommodityBoostTimeRemaining = 0
						accountBoostInfoTrigger:Trigger(false)
						UnwatchLuaTriggerByKey('CountDownSeconds', 'CommodityBoostCountDownKey')
					end
				end, 'CommodityBoostCountDownKey', 'timeSeconds')				
				
			elseif (true) then -- (trigger.endTime == -1) ?
				accountBoostInfoTrigger.hasPermanentCommodityBoost 				= true
				accountBoostInfoTrigger.hasTemporaryCommodityBoost 				= false
				accountBoostInfoTrigger.temporaryCommodityBoostTimeRemaining 		= 0		
			end
		else
			accountBoostInfoTrigger.hasPermanentCommodityBoost 				= false
			accountBoostInfoTrigger.hasTemporaryCommodityBoost 				= false
			accountBoostInfoTrigger.temporaryCommodityBoostTimeRemaining 		= 0
		end
		accountBoostInfoTrigger:Trigger(false)
	end, true, nil, 'endTime', 'endTimeString', 'isBoosted', 'multiplier', 'timedBoost')	
	LuaTrigger.GetTrigger('CommodityBoost'):Trigger(true)
	
	object:RegisterWatchLua('PetBoost', function(widget, trigger)
		UnwatchLuaTriggerByKey('CountDownSeconds', 'PetBoostCountDownKey')
		if (trigger.isBoosted) and (trigger.multiplier > 1) then
			if (trigger.timedBoost) and (tonumber(trigger.endTime) > 0) then
				accountBoostInfoTrigger.hasPermanentPetBoost 				= false
				accountBoostInfoTrigger.hasTemporaryPetBoost 				= true
				
				accountBoostInfoTrigger.temporaryPetBoostTimeRemaining 		= trigger.endTime - LuaTrigger.GetTrigger('System').unixTimestamp
				
				WatchLuaTrigger('CountDownSeconds', function(countDownTrigger)
					if (accountBoostInfoTrigger.temporaryPetBoostTimeRemaining > 0) then
						accountBoostInfoTrigger.temporaryPetBoostTimeRemaining = accountBoostInfoTrigger.temporaryPetBoostTimeRemaining - 1
						accountBoostInfoTrigger:Trigger(false)
					else
						accountBoostInfoTrigger.temporaryPetBoostTimeRemaining = 0
						accountBoostInfoTrigger:Trigger(false)
						UnwatchLuaTriggerByKey('CountDownSeconds', 'PetBoostCountDownKey')
					end
				end, 'PetBoostCountDownKey', 'timeSeconds')				
				
			elseif (true) then -- (trigger.endTime == -1) ?
				accountBoostInfoTrigger.hasPermanentPetBoost 				= true
				accountBoostInfoTrigger.hasTemporaryPetBoost 				= false
				accountBoostInfoTrigger.temporaryPetBoostTimeRemaining 		= 0	
			end
		else
			accountBoostInfoTrigger.hasPermanentPetBoost 				= false
			accountBoostInfoTrigger.hasTemporaryPetBoost 				= false
			accountBoostInfoTrigger.temporaryPetBoostTimeRemaining 		= 0
		end
		accountBoostInfoTrigger:Trigger(false)
	end, true, nil, 'endTime', 'endTimeString', 'isBoosted', 'multiplier', 'timedBoost')		
	LuaTrigger.GetTrigger('PetBoost'):Trigger(true)
	
	object:RegisterWatchLua('ExpLanBoost', function(widget, trigger)
		UnwatchLuaTriggerByKey('CountDownSeconds', 'ExpBoostCountDownKey')
		if (trigger.isBoosted) and (trigger.multiplier > 1) then
			accountBoostInfoTrigger.hasLANXPBoost 						= true
			
			accountBoostInfoTrigger.LANXPBoostTimeRemaining 		= trigger.endTime - LuaTrigger.GetTrigger('System').unixTimestamp
			
			WatchLuaTrigger('CountDownSeconds', function(countDownTrigger)
				if (accountBoostInfoTrigger.LANXPBoostTimeRemaining > 0) then
					accountBoostInfoTrigger.LANXPBoostTimeRemaining = accountBoostInfoTrigger.LANXPBoostTimeRemaining - 1
					accountBoostInfoTrigger:Trigger(false)
				else
					accountBoostInfoTrigger.LANXPBoostTimeRemaining = 0
					accountBoostInfoTrigger:Trigger(false)
					UnwatchLuaTriggerByKey('CountDownSeconds', 'ExpBoostCountDownKey')
				end
			end, 'ExpBoostCountDownKey', 'timeSeconds')	
		else
			accountBoostInfoTrigger.hasLANXPBoost 						= false
			accountBoostInfoTrigger.LANXPBoostTimeRemaining 			= 0
		end
		accountBoostInfoTrigger:Trigger(false)
	end, true, nil, 'endTime', 'endTimeString', 'isBoosted', 'multiplier', 'timedBoost')
	LuaTrigger.GetTrigger('ExpLanBoost'):Trigger(true)

	object:RegisterWatchLua('CommodityLanBoost', function(widget, trigger)
		UnwatchLuaTriggerByKey('CountDownSeconds', 'ExpBoostCountDownKey')
		if (trigger.isBoosted) and (trigger.multiplier > 1) then
			accountBoostInfoTrigger.hasLANCommodityBoost 						= true
			
			accountBoostInfoTrigger.LANCommodityBoostTimeRemaining 		= trigger.endTime - LuaTrigger.GetTrigger('System').unixTimestamp
			
			WatchLuaTrigger('CountDownSeconds', function(countDownTrigger)
				if (accountBoostInfoTrigger.LANCommodityBoostTimeRemaining > 0) then
					accountBoostInfoTrigger.LANCommodityBoostTimeRemaining = accountBoostInfoTrigger.LANCommodityBoostTimeRemaining - 1
					accountBoostInfoTrigger:Trigger(false)
				else
					accountBoostInfoTrigger.LANCommodityBoostTimeRemaining = 0
					accountBoostInfoTrigger:Trigger(false)
					UnwatchLuaTriggerByKey('CountDownSeconds', 'ExpBoostCountDownKey')
				end
			end, 'ExpBoostCountDownKey', 'timeSeconds')	
		else
			accountBoostInfoTrigger.hasLANCommodityBoost 						= false
			accountBoostInfoTrigger.LANCommodityBoostTimeRemaining 			= 0
		end
		accountBoostInfoTrigger:Trigger(false)
	end, true, nil, 'endTime', 'endTimeString', 'isBoosted', 'multiplier', 'timedBoost')
	LuaTrigger.GetTrigger('CommodityLanBoost'):Trigger(true)

	object:RegisterWatchLua('PetLanBoost', function(widget, trigger)
		UnwatchLuaTriggerByKey('CountDownSeconds', 'ExpBoostCountDownKey')
		if (trigger.isBoosted) and (trigger.multiplier > 1) then
			accountBoostInfoTrigger.hasLANPetBoost 						= true
			
			accountBoostInfoTrigger.LANPetBoostTimeRemaining 		= trigger.endTime - LuaTrigger.GetTrigger('System').unixTimestamp
			
			WatchLuaTrigger('CountDownSeconds', function(countDownTrigger)
				if (accountBoostInfoTrigger.LANPetBoostTimeRemaining > 0) then
					accountBoostInfoTrigger.LANPetBoostTimeRemaining = accountBoostInfoTrigger.LANPetBoostTimeRemaining - 1
					accountBoostInfoTrigger:Trigger(false)
				else
					accountBoostInfoTrigger.LANPetBoostTimeRemaining = 0
					accountBoostInfoTrigger:Trigger(false)
					UnwatchLuaTriggerByKey('CountDownSeconds', 'ExpBoostCountDownKey')
				end
			end, 'ExpBoostCountDownKey', 'timeSeconds')	
		else
			accountBoostInfoTrigger.hasLANPetBoost 						= false
			accountBoostInfoTrigger.LANPetBoostTimeRemaining 			= 0
		end
		accountBoostInfoTrigger:Trigger(false)
	end, true, nil, 'endTime', 'endTimeString', 'isBoosted', 'multiplier', 'timedBoost')
	LuaTrigger.GetTrigger('PetLanBoost'):Trigger(true)	
	
	for index=0,9,1 do
		object:RegisterWatchLua('PurchasableBoostProducts'..index, function(widget, trigger)
			if (trigger.boostType == 'matches') and (trigger.boostItemKey == 'experience') and (trigger.productID > 0) then
				if (trigger.days == -1) and (accountBoostInfoTrigger) and (accountBoostInfoTrigger['permanentXPBoostCost']) then
					accountBoostInfoTrigger['permanentXPBoostCost'] = trigger.gems
					accountBoostInfoTrigger:Trigger(false)
				elseif (accountBoostInfoTrigger) and (accountBoostInfoTrigger['temporaryXPBoost' .. trigger.days .. 'DayCost']) then
					accountBoostInfoTrigger['temporaryXPBoost' .. trigger.days .. 'DayCost'] = trigger.gems
					accountBoostInfoTrigger:Trigger(false)
				end
			elseif (trigger.boostType == 'matches') and (trigger.boostItemKey == 'commodities') and (trigger.productID > 0) then
				if (trigger.days == -1) and (accountBoostInfoTrigger) and (accountBoostInfoTrigger['permanentCommodityBoostCost']) then
					accountBoostInfoTrigger['permanentCommodityBoostCost'] = trigger.gems
					accountBoostInfoTrigger:Trigger(false)
				elseif (accountBoostInfoTrigger) and (accountBoostInfoTrigger['temporaryCommodityBoost' .. trigger.days .. 'DayCost']) then
					accountBoostInfoTrigger['temporaryCommodityBoost' .. trigger.days .. 'DayCost'] = trigger.gems
					accountBoostInfoTrigger:Trigger(false)
				end
			elseif (trigger.boostType == 'pets') and (trigger.productID > 0) then
				if (trigger.days == -1) and (accountBoostInfoTrigger) and (accountBoostInfoTrigger['permanentPetBoostCost']) then
					accountBoostInfoTrigger['permanentPetBoostCost'] = trigger.gems
					accountBoostInfoTrigger:Trigger(false)
				elseif (accountBoostInfoTrigger) and (accountBoostInfoTrigger['temporaryPetBoost' .. trigger.days .. 'DayCost']) then
					accountBoostInfoTrigger['temporaryPetBoost' .. trigger.days .. 'DayCost'] = trigger.gems
					accountBoostInfoTrigger:Trigger(false)
				end
			end
		end, true, nil, 'boostItemKey', 'boostType', 'days', 'gems', 'multiplier', 'productID')
		LuaTrigger.GetTrigger('PurchasableBoostProducts'..index):Trigger(true)
	end
	
end
BoostDataRegister(object)

local function BoostDebug(object)

	Cmd('LuaTriggerShowParams 	CommodityBoost')
	Cmd('WatchLuaTrigger 		CommodityBoost')
	Cmd('LuaTriggerShowParams 	ExpBoost')
	Cmd('WatchLuaTrigger 		ExpBoost')
	Cmd('LuaTriggerShowParams 	PetBoost')
	Cmd('WatchLuaTrigger 		PetBoost')
	Cmd('LuaTriggerShowParams 	GameClientRequestsPurchaseBoost')
	Cmd('WatchLuaTrigger 		GameClientRequestsPurchaseBoost')
	Cmd('LuaTriggerShowParams 	PurchasableBoostProducts0')
	Cmd('WatchLuaTrigger 		PurchasableBoostProducts0')
	Cmd('LuaTriggerShowParams 	PurchasableBoostProducts1')
	Cmd('WatchLuaTrigger 		PurchasableBoostProducts1')
	Cmd('LuaTriggerShowParams 	PurchasableBoostProducts2')
	Cmd('WatchLuaTrigger 		PurchasableBoostProducts2')
	Cmd('LuaTriggerShowParams 	PurchasableBoostProducts3')
	Cmd('WatchLuaTrigger 		PurchasableBoostProducts3')
	Cmd('LuaTriggerShowParams 	PurchasableBoostProducts4')
	Cmd('WatchLuaTrigger 		PurchasableBoostProducts4')
	Cmd('LuaTriggerShowParams 	PurchasableBoostProducts5')
	Cmd('WatchLuaTrigger 		PurchasableBoostProducts5')
	Cmd('LuaTriggerShowParams 	PurchasableBoostProducts6')
	Cmd('WatchLuaTrigger 		PurchasableBoostProducts6')
	Cmd('LuaTriggerShowParams 	PurchasableBoostProducts7')
	Cmd('WatchLuaTrigger 		PurchasableBoostProducts7')
	Cmd('LuaTriggerShowParams 	PurchasableBoostProducts8')
	Cmd('WatchLuaTrigger 		PurchasableBoostProducts8')
	Cmd('LuaTriggerShowParams 	PurchasableBoostProducts9')
	Cmd('WatchLuaTrigger 		PurchasableBoostProducts9')
	Cmd('LuaTriggerShowParams 	AccountBoostInfoTrigger')
	Cmd('WatchLuaTrigger 		AccountBoostInfoTrigger')

end
if GetCvarBool('ui_boostDebugInfo') then
	BoostDebug(object)
end 
 
