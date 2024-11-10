local interface = object

libHeroCosmeticPurchase = {
	
	promptToPurchaseHeroCosmetic = function(purchaseFunction, rentalFunction, headerText, productText, purchaseCost, rentalCost, originalCost, cancelFunction)
		mainUI.ShowSplashScreen('splash_screen_purchase_hero_cosmetic_template')	
		libThread.threadFunc(function()	
			wait(1)
			libHeroCosmeticPurchase.preparePromptToPurchaseHeroCosmetic(purchaseFunction, rentalFunction, headerText, productText, purchaseCost, rentalCost, originalCost, cancelFunction)
		end)		
	end,
	
	preparePromptToPurchaseHeroCosmetic = function(purchaseFunction, rentalFunction, headerText, productText, purchaseCost, rentalCost, originalCost, cancelFunction)

		purchaseFunction, rentalFunction, headerText, productText, purchaseCost, rentalCost, originalCost, cancelFunction = purchaseFunction or nil, rentalFunction or nil, headerText or 'No Header', productText or 'No Product', purchaseCost or -2, rentalCost or -2, originalCost or -2, cancelFunction or nil
		
		local splash_screen_purchase_hero_cosmetic										= GetWidget('splash_screen_purchase_hero_cosmetic')
		local splash_screen_purchase_hero_cosmetic_header_label							= GetWidget('splash_screen_purchase_hero_cosmetic_header_label')
		local splash_screen_purchase_hero_cosmetic_product_name_label					= GetWidget('splash_screen_purchase_hero_cosmetic_product_name_label')
		local splash_screen_purchase_hero_cosmetic_product_cost_label_1					= GetWidget('splash_screen_purchase_hero_cosmetic_product_cost_label_1')
		local splash_screen_purchase_hero_cosmetic_product_purchase_confirm_btn_1		= GetWidget('splash_screen_purchase_hero_cosmetic_product_purchase_confirm_btn_1')
		local splash_screen_purchase_hero_cosmetic_product_cost_label_2					= GetWidget('splash_screen_purchase_hero_cosmetic_product_cost_label_2')
		local splash_screen_purchase_hero_cosmetic_product_purchase_confirm_btn_2		= GetWidget('splash_screen_purchase_hero_cosmetic_product_purchase_confirm_btn_2')
		local splash_screen_purchase_hero_cosmetic_product_purchase_option_1			= GetWidget('splash_screen_purchase_hero_cosmetic_product_purchase_option_1')
		local splash_screen_purchase_hero_cosmetic_product_purchase_option_2			= GetWidget('splash_screen_purchase_hero_cosmetic_product_purchase_option_2')
		local splash_screen_purchase_hero_cosmetic_closex_btn							= GetWidget('splash_screen_purchase_hero_cosmetic_closex_btn')
		local splash_screen_purchase_hero_cosmetic_product_ownership_parent				= GetWidget('splash_screen_purchase_hero_cosmetic_product_ownership_parent')
		local splash_screen_purchase_hero_cosmetic_product_ownership_bar				= GetWidget('splash_screen_purchase_hero_cosmetic_product_ownership_bar')
		local splash_screen_purchase_account_remaining_duration_bar_new_leader			= GetWidget('splash_screen_purchase_account_remaining_duration_bar_new_leader')
		local splash_screen_purchase_hero_cosmetic_product_ownership_label				= GetWidget('splash_screen_purchase_hero_cosmetic_product_ownership_label')
		local splash_screen_purchase_hero_cosmetic_product_ownership_tip				= GetWidget('splash_screen_purchase_hero_cosmetic_product_ownership_tip')
		local splash_screen_purchase_hero_cosmetic_product_purchase_option_parent		= GetWidget('splash_screen_purchase_hero_cosmetic_product_purchase_option_parent')
		local splash_screen_purchase_hero_cosmetic_product_needgems_btn_1				= GetWidget('splash_screen_purchase_hero_cosmetic_product_needgems_btn_1')
		local splash_screen_purchase_hero_cosmetic_product_needgems_btn_2				= GetWidget('splash_screen_purchase_hero_cosmetic_product_needgems_btn_2')
		
		local gemOffer 																	= LuaTrigger.GetTrigger('GemOffer')
		local currentGems																= gemOffer.gems
		
		splash_screen_purchase_hero_cosmetic_header_label:SetText(headerText)
		splash_screen_purchase_hero_cosmetic_product_name_label:SetText(productText)		
		
		-- Purchase
		splash_screen_purchase_hero_cosmetic_product_cost_label_2:SetText(purchaseCost)
		splash_screen_purchase_hero_cosmetic_product_purchase_confirm_btn_2:SetCallback('onclick', function(widget)
			mainUI.ShowSplashScreen()
			if (purchaseFunction) and (purchaseCost >= 0) then
				purchaseFunction()
			end
		end)
		splash_screen_purchase_hero_cosmetic_product_purchase_confirm_btn_2:SetEnabled(((purchaseFunction) and (purchaseCost >= 0))	or false)
		splash_screen_purchase_hero_cosmetic_product_purchase_option_2:SetVisible(((purchaseFunction) and (purchaseCost >= 0))	or false)
		splash_screen_purchase_hero_cosmetic_product_purchase_confirm_btn_2:SetCallback('onmouseover', function(widget) UpdateCursor(widget, true, { canLeftClick = true, canRightClick = false, spendGems = true }) end)			
		splash_screen_purchase_hero_cosmetic_product_purchase_confirm_btn_2:SetCallback('onmouseout', function(widget) UpdateCursor(widget, false, { canLeftClick = true, canRightClick = false, spendGems = true }) end)			
		
		splash_screen_purchase_hero_cosmetic_product_needgems_btn_2:SetVisible(((purchaseFunction) and (purchaseCost) and (currentGems) and (purchaseCost > currentGems)) or false)

		-- Rental
		if ((rentalFunction) and (rentalCost >= 1)) then
			splash_screen_purchase_hero_cosmetic_product_cost_label_1:SetText(rentalCost)
			splash_screen_purchase_hero_cosmetic_product_purchase_confirm_btn_1:SetCallback('onclick', function(widget)
				mainUI.ShowSplashScreen()
				if (rentalFunction) and (rentalCost >= 0) then
					rentalFunction()
				end
			end)
			splash_screen_purchase_hero_cosmetic_product_purchase_confirm_btn_1:SetEnabled((((rentalFunction) and (rentalCost >= 0)) and (purchaseCost and (rentalCost < purchaseCost)))	or false)
			splash_screen_purchase_hero_cosmetic_product_purchase_option_1:SetVisible(1)
			splash_screen_purchase_hero_cosmetic_product_purchase_confirm_btn_1:SetCallback('onmouseover', function(widget) UpdateCursor(widget, true, { canLeftClick = true, canRightClick = false, spendGems = true }) end)		
			splash_screen_purchase_hero_cosmetic_product_purchase_confirm_btn_1:SetCallback('onmouseout', function(widget) UpdateCursor(widget, false, { canLeftClick = true, canRightClick = false, spendGems = true }) end)		
			splash_screen_purchase_hero_cosmetic_product_purchase_option_2:SetWidth('188s')
			splash_screen_purchase_hero_cosmetic_product_purchase_option_parent:SetY('86s')
			splash_screen_purchase_hero_cosmetic_product_purchase_option_parent:SetHeight('224s')
			splash_screen_purchase_hero_cosmetic_product_purchase_option_1:SetX('32s')
			splash_screen_purchase_hero_cosmetic_product_purchase_option_2:SetX('-32s')
		else
			splash_screen_purchase_hero_cosmetic_product_purchase_option_1:SetVisible(0)
			splash_screen_purchase_hero_cosmetic_product_purchase_option_2:SetWidth('376s')
			splash_screen_purchase_hero_cosmetic_product_purchase_option_parent:SetY('100s')
			splash_screen_purchase_hero_cosmetic_product_purchase_option_parent:SetHeight('244s')
			splash_screen_purchase_hero_cosmetic_product_purchase_option_2:SetX('-40s')
		end
		
		splash_screen_purchase_hero_cosmetic_product_needgems_btn_1:SetVisible(((rentalFunction) and (rentalCost) and (currentGems) and (rentalCost > currentGems)) or false)
		
		-- Current Ownership
		if (originalCost) and (originalCost > 0) and (purchaseCost) and (purchaseCost >= 0) and (rentalCost >= 1) then
			local barWidth = math.min(100, math.max(0, (((originalCost-purchaseCost)/originalCost)*100)))
			splash_screen_purchase_hero_cosmetic_product_ownership_bar:SetWidth(barWidth .. '%')
			splash_screen_purchase_account_remaining_duration_bar_new_leader:SetX(barWidth .. '%')
			splash_screen_purchase_hero_cosmetic_product_ownership_parent:SetVisible(1)
			splash_screen_purchase_hero_cosmetic_product_ownership_tip:SetVisible(1)
			splash_screen_purchase_hero_cosmetic_product_ownership_label:SetText(Translate('hallofheroes_item_ownership', 'value', math.floor(barWidth) .. '%'))
		else
			splash_screen_purchase_hero_cosmetic_product_ownership_parent:SetVisible(0)
			splash_screen_purchase_hero_cosmetic_product_ownership_tip:SetVisible(0)
		end
		
		-- Close
		splash_screen_purchase_hero_cosmetic_closex_btn:SetCallback('onclick', function(widget)
			mainUI.ShowSplashScreen()
			if (cancelFunction) then
				cancelFunction()
			end
		end)
		splash_screen_purchase_hero_cosmetic_closex_btn:SetCallback('onmouseout', function(widget) UpdateCursor(widget, false, { canLeftClick = true, canRightClick = false, spendGems = true }) end)			

	end,

}
