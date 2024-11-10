-- Spend Gems

function spendGemsRegister(object)
	local container			= object:GetWidget('spendGems')
	local buttonClose		= object:GetWidget('spendGemsClose')
	local buttonCancel		= object:GetWidget('spendGemsCancel')
	local buttonOK			= object:GetWidget('spendGemsOK')
	local buttonBuyGems		= object:GetWidget('spendGemsBuyGems')
	local title				= object:GetWidget('spendGemsTitle')
	local cost				= object:GetWidget('spendGemsCost')
	local body				= object:GetWidget('spendGemsBody')
	
	local function spendGemsClose()
		container:FadeOut(150)
	end
	
	local lastCancelAction
	function spendGemsShow(spendAction, newTitle, newBody, newCost, cancelAction)
		newTitle	= newTitle or ''
		newBody	= newBody or ''
		if newCost and newCost > 0 then
			if spendAction and type(spendAction) == 'function' then
				
				if (lastCancelAction) then 
					lastCancelAction()
				end
				lastCancelAction = cancelAction
				
				container:FadeIn(150)
				buttonOK:SetCallback('onclick', function()
					spendAction()
					spendGemsClose()
					
					-- sound_spendGemsOK
					-- PlaySound('path_to/filename.wav')
				end)
				if cancelAction and type(cancelAction) == 'function' then
					buttonCancel:SetCallback('onclick', function()
						lastCancelAction = nil
						cancelAction()
						spendGemsClose()
					end)	
					buttonClose:SetCallback('onclick', function()
						lastCancelAction = nil
						cancelAction()
						spendGemsClose()
					end)					
					
					-- sound_spendGemsCancel
					-- PlaySound('path_to/filename.wav')
				end
				cost:SetText(libNumber.commaFormat(newCost))
				title:SetText(Translate(newTitle))
				body:SetText(Translate(newBody))
				buttonOK:UnregisterWatchLua('GemOffer')
				buttonOK:RegisterWatchLua('GemOffer', function(widget, trigger)
					widget:SetVisible(trigger.gems >= newCost)
				end, false, nil, 'gems')
				
				buttonBuyGems:UnregisterWatchLua('GemOffer')
				buttonBuyGems:RegisterWatchLua('GemOffer', function(widget, trigger)
					widget:SetVisible(trigger.gems < newCost)
				end, false, nil, 'gems')
				
				buttonOK:SetCallback('onmouseover', function(widget) UpdateCursor(widget, true, { canLeftClick = true, canRightClick = false, spendGems = true }) end)
				buttonOK:SetCallback('onmouseout', function(widget) UpdateCursor(widget, false, { canLeftClick = true, canRightClick = false, spendGems = true }) end)				
				
				LuaTrigger.GetTrigger('GemOffer'):Trigger(true)
			else
				print('^960Warning: ^069 No cost specified for spend gems prompt.\n')
			end
			
		else
			spendGemsClose()
			print('^960Warning: ^069 No cost specified for spend gems prompt.\n')
		end
	end
	
	object:GetWidget('spendGemsClose'):SetCallback('onclick', function(widget)
		spendGemsClose()
	end)
	
	object:GetWidget('spendGemsCancel'):SetCallback('onclick', function(widget)
		spendGemsClose()
	end)
	
	object:GetWidget('spendGemsBuyGems'):SetCallback('onclick', function(widget)
		buyGemsShow()
		
		-- sound_spendGemsBuyGems
		-- PlaySound('/path_to/filename.wav')
	end)
	
	object:GetWidget('spendGemsOwned'):RegisterWatchLua('GemOffer', function(widget, trigger)
		widget:SetText(libNumber.commaFormat(trigger.gems))
	end, false, nil, 'gems')
	
	FindChildrenClickCallbacks(container)
end

spendGemsRegister(object)