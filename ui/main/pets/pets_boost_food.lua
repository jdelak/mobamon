-- Pet XP Boosts

local function petsRegisterXPBoostEntry(object, index)
	local button		= object:GetWidget('mainPetsXPBoostEntry'..index)
	local icon			= object:GetWidget('mainPetsXPBoostEntry'..index..'Icon')
	local iconShadow	= object:GetWidget('mainPetsXPBoostEntry'..index..'IconShadow')
	local xpLabel		= object:GetWidget('mainPetsXPBoostEntry'..index..'XPLabel')
	local gemLabel		= object:GetWidget('mainPetsXPBoostEntry'..index..'GemLabel')
	
	--button:RegisterWatchLua('CorralBoostXP', function(widget, trigger) widget:SetVisible(trigger['offerAmount'..index] > 0) end, false, nil, 'offerAmount'..index)

	--button:RegisterWatchLua('petCorralXPBoostPurchaseCompare', function(widget, groupTrigger)
	--	local triggerBoost	= groupTrigger[1]
	--	local triggerGems	= groupTrigger[2]
	--
	--	widget:SetEnabled(triggerBoost['offerCost'..index] <= triggerGems.gems)
	--end)

	--icon:RegisterWatchLua('CorralBoostXP', function(widget, trigger) widget:SetTexture(trigger['offerIcon'..index]) end, false, nil, 'offerIcon'..index)
	--iconShadow:RegisterWatchLua('CorralBoostXP', function(widget, trigger) widget:SetTexture(trigger['offerIcon'..index]) end, false, nil, 'offerIcon'..index)
	--xpLabel:RegisterWatchLua('CorralBoostXP', function(widget, trigger) widget:SetText(libNumber.commaFormat(trigger['offerAmount'..index])) end, false, nil, 'offerAmount'..index)
	--gemLabel:RegisterWatchLua('CorralBoostXP', function(widget, trigger) widget:SetText(trigger['offerCost'..index]) end, false, nil, 'offerCost'..index)

	button:SetCallback('onclick', function(widget)
		PlaySound('/ui/sounds/sfx_button_generic.wav')
		--Corral.BuyBoost(index)
	end)
end

local function petsRegisterXPBoosts(object)
	local container		= object:GetWidget('mainPetsBuyBoostedXP')
	local close			= object:GetWidget('mainPetsBuyBoostedXPClose')
	local gemCount		= object:GetWidget('mainPetsBuyBoostedXPGemCount')
	local currentBoost	= object:GetWidget('mainPetsBuyBoostedXPBoostCurrent')
	local buyGemsButton	= object:GetWidget('mainPetsBuyBoostedXPBuyGemsButton')

	currentBoost:RegisterWatchLua('Corral', function(widget, trigger) widget:SetText(libNumber.commaFormat(trigger.boostedExperience)) end, false, nil, 'boostedExperience')
	gemCount:RegisterWatchLua('GemOffer', function(widget, trigger) widget:SetText(trigger.gems) end, false, nil, 'gems')

	close:SetCallback('onclick', function(widget) buyBoostedXPContainer:FadeOut(250) end)

	buyGemsButton:SetCallback('onclick', function(widget)
		PlaySound('/ui/sounds/sfx_button_generic.wav')
		buyGemsShow()
	end)

	local confirmContainer		= object:GetWidget('mainPetsXPBoostConfirm')
	local confirmClose			= object:GetWidget('mainPetsBuyBoostedXPConfirmClose')
	local confirmCancel			= object:GetWidget('mainPetsXPBoostConfirmCancel')
	local confirmOK				= object:GetWidget('mainPetsXPBoostConfirmOK')
	local confirmGemLabel		= object:GetWidget('mainPetsXPBoostConfirmGemLabel')
	local confirmXPLabel		= object:GetWidget('mainPetsXPBoostConfirmXPLabel')
	local confirmXPIconSpace	= object:GetWidget('mainPetsXPBoostConfirmIconSpace')
	local confirmXPIconShadow	= object:GetWidget('mainPetsXPBoostConfirmIconShadow')
	local confirmXPIconIcon		= object:GetWidget('mainPetsXPBoostConfirmIcon')

	confirmCancel:SetCallback('onclick', function(widget)
		PlaySound('/ui/sounds/sfx_button_generic.wav')
		print('clicked purchase xp boost cancel.\n')
		confirmContainer:FadeOut(250)
	end)
	
	confirmOK:SetCallback('onclick', function(widget)
		PlaySound('/ui/sounds/sfx_button_generic.wav')
		print('clicked purchase xp boost ok.\n')
		confirmContainer:FadeOut(250)
	end)

	confirmClose:SetCallback('onclick', function(widget) confirmContainer:FadeOut(250) end)

	--libGeneral.createGroupTrigger('petCorralXPBoostPurchaseCompare', { 'CorralBoostXP', 'GemOffer' })
	
	for i=1,5,1 do
		petsRegisterXPBoostEntry(object, i)
	end	
end