---------------------------------------------------------- 
--	Name: 		Adaptive Training Script           		--				
--  Copyright 2014 S2 Games								--
----------------------------------------------------------

local ipairs, pairs, select, string, table, next, type, unpack, tinsert, tconcat, tremove, format, tostring, tonumber, tsort, ceil, floor, sub, find, gfind = _G.ipairs, _G.pairs, _G.select, _G.string, _G.table, _G.next, _G.type, _G.unpack, _G.table.insert, _G.table.concat, _G.table.remove, _G.string.format, _G.tostring, _G.tonumber, _G.table.sort, _G.math.ceil, _G.math.floor, _G.string.sub, _G.string.find, _G.string.gfind
local interface, interfaceName = object, object:GetName()
mainUI = mainUI or {}
mainUI.savedLocally 	= mainUI.savedLocally 		or {}
mainUI.savedRemotely 	= mainUI.savedRemotely 		or {}
mainUI.savedAnonymously	= mainUI.savedAnonymously 	or {}
mainUI.AdaptiveTraining = {}

local function AdaptiveTrainingRegister(object)

	local secondsToMS, secondsToS, minutesToS, hoursToS, daysToS = 1000, 1, 60, 3600, 86400
	local systemTrigger 		= LuaTrigger.GetTrigger('System')
	local currentUnixTimestamp 	= LuaTrigger.GetTrigger('System').unixTimestamp
	local fadeTime 				= 125
	
	local function printDebug(msg)
		if (GetCvarBool('ui_debug_AdaptiveTraining')) then
			println(tostring(msg))
		end
	end
	
	function mainUI.AdaptiveTraining.GetCurrentUnixTimestamp()
		local timeStamp = (systemTrigger.unixTimestamp)
		timeStamp = string.sub(timeStamp, -8) -- Well, this is good for the next 3 years...
		timeStamp = tonumber(timeStamp)
		return timeStamp or -1
	end	
	
	mainUI.AdaptiveTraining.global 										= {}
	mainUI.AdaptiveTraining.global.lastPromptedTimestamp				= mainUI.AdaptiveTraining.GetCurrentUnixTimestamp()
	if (GetCvarBool('ui_debug_AdaptiveTraining')) then
		mainUI.AdaptiveTraining.global.minimumPromptCooldown				= (5 * secondsToS)
	else
		mainUI.AdaptiveTraining.global.minimumPromptCooldown				= (15 * minutesToS)
	end
	mainUI.AdaptiveTraining.global.activePromptObjects					= {}

	function mainUI.AdaptiveTraining.AddStringsAsNumbers(num1, num2)
	
	end
	
	function mainUI.AdaptiveTraining.CompareStringsAsNumbers(num1, num2)
		
	end	
	
	function mainUI.AdaptiveTraining.InvokeGCD()
		mainUI.AdaptiveTraining.global.lastPromptedTimestamp				= mainUI.AdaptiveTraining.GetCurrentUnixTimestamp()
	end	
	
	function mainUI.AdaptiveTraining.CheckIfIShouldPromptAnything(main)
		
		if (mainUI.AdaptiveTraining.global.lastPromptedTimestamp + mainUI.AdaptiveTraining.global.minimumPromptCooldown) > (mainUI.AdaptiveTraining.GetCurrentUnixTimestamp() + 0) then		
			printDebug('^r CheckIfIShouldPromptAnything ' .. main)
			return
		else
			printDebug('^g CheckIfIShouldPromptAnything ' .. main)
		end
		
		if (mainUI) and  (mainUI.savedLocally) and  (mainUI.savedLocally.adaptiveTraining) and (mainUI.savedLocally.adaptiveTraining.featureList) then
			
			local tSortableFeatureTable = {}
			for featureIndex,featureTable in pairs(mainUI.savedLocally.adaptiveTraining.featureList) do
				table.insert(tSortableFeatureTable, featureTable)
			end
			
			table.sort(tSortableFeatureTable, function(a,b) return a.priorityRank < b.priorityRank end)
			
			for featureIndex,featureTable in ipairs(tSortableFeatureTable) do
				if (featureTable.displayPrompts) and (featureTable.eligibleToPromptUserFunction) and (featureTable.eligibleToPromptUserFunction(featureTable)) then
					if ((not featureTable.trackViewed) or (not featureTable.lastViewed) or (not featureTable.minimumViewCooldown) or ((featureTable.lastViewed + featureTable.minimumViewCooldown) <= mainUI.AdaptiveTraining.GetCurrentUnixTimestamp())) and (not ((featureTable.lastViewed) and (featureTable.minimumViewCooldown) and (featureTable.minimumViewCooldown == -1))) then
						if (not featureTable.lastViewed) or (not featureTable.minimumPromptCooldown) or ((featureTable.lastViewed + featureTable.minimumPromptCooldown) <= mainUI.AdaptiveTraining.GetCurrentUnixTimestamp()) then
							if (not featureTable.lastPrompted) or ((featureTable.lastPrompted + featureTable.minimumPromptCooldown) <= mainUI.AdaptiveTraining.GetCurrentUnixTimestamp()) and (not ((featureTable.lastPrompted) and (featureTable.minimumPromptCooldown) and (featureTable.minimumPromptCooldown == -1))) then
								mainUI.AdaptiveTraining.InvokeGCD()
								mainUI.AdaptiveTraining.UpdateLastPromptedTimestampByFeatureName(featureTable.featureName)
								mainUI.AdaptiveTraining.DisplayPromptByFeatureName(featureTable.featureName)
								printDebug('^c CheckIfIShouldPromptAnything is prompting ' .. featureTable.featureName)
								return true
							else
							
							end		
						else
						
						end	
					else
					
					end
				else
		
				end
			end
		end
		printDebug('^o CheckIfIShouldPromptAnything nothing to prompt')
	end
	
	function mainUI.AdaptiveTraining.QueueDelayedEvent(functionToCall, delayDuration, isRepeating)
		if (not functionToCall) then return end		
		delayDuration = delayDuration or 0
		isRepeating = isRepeating or false
		local startTime = GetTime()
		
		UnwatchLuaTriggerByKey('System', 'QueueDelayedEventSystemKey'..tostring(functionToCall))
		WatchLuaTrigger('System', function(trigger)	
			local timeElapsed = trigger.hostTime - startTime
			if (timeElapsed >= delayDuration) then
				functionToCall()
				if (isRepeating) then
					startTime = trigger.hostTime
				else
					UnwatchLuaTriggerByKey('System', 'QueueDelayedEventSystemKey'..tostring(functionToCall))
				end
			end
		end, 'QueueDelayedEventSystemKey'..tostring(functionToCall), 'hostTime')		
		
	end			
	
	function mainUI.AdaptiveTraining.KillAllActivePrompts()
		for i,v in pairs(mainUI.AdaptiveTraining.global.activePromptObjects) do
			if (v) and (v:IsValid()) then
				v:SetVisible(0)
				v:Destroy()
			end
		end
		mainUI.AdaptiveTraining.global.activePromptObjects = {}
		groupfcall('adaptive_training_speech_bubbles', function(_, groupWidget) groupWidget:SetVisible(0) groupWidget:Destroy() end)
	end
	
	function mainUI.AdaptiveTraining.FadeOut(self)
		self:FadeOut(fadeTime)
	end
	
	function mainUI.AdaptiveTraining.AlwaysTrue()
		return true
	end
	
	function mainUI.AdaptiveTraining.AlwaysFalse()
		return false
	end
	
	function mainUI.AdaptiveTraining.WidgetVisible(widgetName)
		return ((interface:GetWidget(widgetName)) and (interface:GetWidget(widgetName):IsVisible()))
	end	
	
	function mainUI.AdaptiveTraining.DoIHaveAtLeastXSeals(xSeals)
		local triggerCorral = LuaTrigger.GetTrigger('Corral')
		printDebug('triggerCorral: fruit: ' .. triggerCorral.fruit .. ' / shards: '..triggerCorral.shards)
		return (triggerCorral.fruit >= xSeals)
	end		
	
	function mainUI.AdaptiveTraining.IsThereAPetICanBuy()
		local maxPets = 15
		if (Pets) and (Pets.maxPets) then
			maxPets = Pets.maxPets
		end 
		for i=0,maxPets do
			local petTrigger = LuaTrigger.GetTrigger('CorralPet'..i)
			if (petTrigger) and (petTrigger.canPurchasePet) and (petTrigger.foodCost) and mainUI.AdaptiveTraining.DoIHaveAtLeastXSeals(petTrigger.foodCost) then
				return true
			end
		end
		return false
	end

	function mainUI.AdaptiveTraining.DoIHaveAtLeastXElixir(xElixir)
		local triggerCraftingCommodityInfo = LuaTrigger.GetTrigger('CraftingCommodityInfo')
		printDebug('triggerCraftingCommodityInfo: essenceCount: ' .. triggerCraftingCommodityInfo.essenceCount .. ' / oreCount: '..triggerCraftingCommodityInfo.oreCount)
		return (triggerCraftingCommodityInfo.oreCount >= xElixir)
	end		
	
	function mainUI.AdaptiveTraining.CurrentMainPanelIs(index)
		local triggerPanelStatus = LuaTrigger.GetTrigger('mainPanelStatus')
		printDebug('CurrentMainPanelIs: ' .. index .. '/'..triggerPanelStatus.main)
		return (triggerPanelStatus.main == index)
	end		
	
	function mainUI.AdaptiveTraining.ReachedAccountLevelX(accountLevelTarget)
		local accountLevel = LuaTrigger.GetTrigger('AccountProgression').level
		printDebug('ReachedAccountLevelX: ' .. accountLevel .. '/'..accountLevelTarget)
		return (accountLevel >= accountLevelTarget)
	end
	
	function mainUI.AdaptiveTraining.DisplayPromptInKeeperNotificationStyle(featureName, url)
		printDebug('DisplayPromptInKeeperNotificationStyle: ' .. featureName)
		local label						=  label 	or 	TranslateOrNil('adaptive_training_feature_desc_'..featureName) or 'I forgot to label this'
		local url						=  url 		or 	TranslateOrNil('adaptive_training_feature_desc_'..featureName..'_url') or nil
				
		Notifications.QueueKeeperPopupNotification(-1,
			Translate(label or ''),
			function()
				mainUI.OpenURL(tostring(url)  .. '?' .. tostring(session) .. '=' .. Client.GetSessionKey()..'&' .. tostring(identid) .. '='..GetIdentID())
			end,
			nil,
			nil,
			'/ui/main/keepers/textures/lexikhan.png',
			nil, nil, nil, true,
			nil, nil, nil,
			'general_read_more'
		)
		
	end	
	
	function mainUI.AdaptiveTraining.DisplayPromptInTrayNotificationStyle()
		printDebug('DisplayPromptInTrayNotificationStyle: ' .. featureName)
	end	
	
	function mainUI.AdaptiveTraining.DisplayPromptInSpeechBubbleStyle(featureName, label, align, valign, x, y, width, height, frame, clickCallback, rightClickCallback, displayDuration)
		printDebug('DisplayPromptInSpeechBubbleStyle: ' .. featureName)
		
		local noclick					= 'false'
		local target 					= interface:GetWidget('adaptive_training_instantiation_target')
		local template 					= 'adaptive_training_speech_bubble_template'
		local align						=  align or 'left'
		local valign					=  valign or 'top'
		local width						=  width or '300s'
		local height					=  height or '10s'
		local x							=  x or '100s'
		local y							=  y or '100s'
		local label						=  label or TranslateOrNil('adaptive_training_feature_desc_'..featureName) or 'I forgot to label this'
		local displayDuration			=  displayDuration or (15 * secondsToMS)

		local clickCallback				=  clickCallback or 
			function(self) 
				self:FadeOut(fadeTime)
			end
			
		local rightClickCallback		=  rightClickCallback or 
			function(self) 
				self:FadeOut(fadeTime) 
			end
		
		local function WhichFrameShouldITake(align, valign)
			if (align == 'left') then
				if (valign == 'top') then
					return '/ui/main/shared/frames/speech_tl_nip.tga'
				else
					return '/ui/main/shared/frames/speech_bl_nip.tga'
				end
			else
				if (valign == 'top') then
					return '/ui/main/shared/frames/speech_tr_nip.tga'
				else
					return '/ui/main/shared/frames/speech_br_nip.tga'
				end			
			end
		end
	
		local frame						= frame or WhichFrameShouldITake(align, valign)
		local instantiatedWidgets 		= target:InstantiateAndReturn(template,
			'align', align,
			'valign', valign,
			'width', width,
			'height', height,
			'x', x,
			'y', y,
			'frame', frame,
			'label', label,
			'noclick', noclick
		)
		
		local bubbleParent = instantiatedWidgets[1]
		
		bubbleParent:SetCallback('onclick', function(widget)
			clickCallback(widget)
		end)
		
		bubbleParent:SetCallback('onrightclick', function(widget)
			rightClickCallback(widget)
		end)		
		
		bubbleParent:FadeIn(fadeTime)

		libThread.threadFunc(function()
			wait(displayDuration)		
			if (bubbleParent) and (bubbleParent:IsValid()) then
				bubbleParent:FadeOut(fadeTime)
			end
		end)
		
		table.insert(mainUI.AdaptiveTraining.global.activePromptObjects, bubbleParent)
		
	end		
	
	function mainUI.AdaptiveTraining.Test()
		mainUI.AdaptiveTraining.DisplayPromptInSpeechBubbleStyle('profile')
	end
	
	function mainUI.AdaptiveTraining.DisplayPromptInSplashPageStyle(featureName)
		printDebug('DisplayPromptInSplashPageStyle: ' .. featureName)
	end		
	
	function mainUI.AdaptiveTraining.OpenMainPanelByIndex(index)
		printDebug('OpenMainPanelByIndex: ' .. index)
		local triggerPanelStatus = LuaTrigger.GetTrigger('mainPanelStatus')
		triggerPanelStatus.main = index
		triggerPanelStatus:Trigger(false)
	end	
	
	function mainUI.AdaptiveTraining.UpdateLastPromptedTimestampByFeatureName(featureName)
		printDebug('UpdateLastPromptedTimestampByFeatureName: ' .. featureName)
		if (featureName) and (mainUI) and  (mainUI.savedLocally) and  (mainUI.savedLocally.adaptiveTraining) and ( mainUI.savedLocally.adaptiveTraining.featureList) and (mainUI.savedLocally.adaptiveTraining.featureList[featureName]) then
			mainUI.savedLocally.adaptiveTraining.featureList[featureName].lastPrompted = mainUI.AdaptiveTraining.GetCurrentUnixTimestamp()
		end
	end		
	
	function mainUI.AdaptiveTraining.ActivatePromptByFeatureName(featureName)
		printDebug('ActivatePromptByFeatureName: ' .. featureName)
		if (featureName) and (mainUI) and  (mainUI.savedLocally) and  (mainUI.savedLocally.adaptiveTraining) and ( mainUI.savedLocally.adaptiveTraining.featureList) and (mainUI.savedLocally.adaptiveTraining.featureList[featureName]) and (mainUI.savedLocally.adaptiveTraining.featureList[featureName].activatedPromptFunction) then
			mainUI.savedLocally.adaptiveTraining.featureList[featureName].activatedPromptFunction(featureName)
		end	
		mainUI.AdaptiveTraining.UpdateLastPromptedTimestampByFeatureName(featureName)
		mainUI.AdaptiveTraining.KillAllActivePrompts()
	end			
	
	function mainUI.AdaptiveTraining.ActivateMoreInfoPromptByFeatureName(featureName)
		printDebug('ActivateMoreInfoPromptByFeatureName: ' .. featureName)
		if (featureName) and (mainUI) and  (mainUI.savedLocally) and  (mainUI.savedLocally.adaptiveTraining) and ( mainUI.savedLocally.adaptiveTraining.featureList) and (mainUI.savedLocally.adaptiveTraining.featureList[featureName]) and (mainUI.savedLocally.adaptiveTraining.featureList[featureName].activatedMoreInfoPromptFunction) then
			mainUI.savedLocally.adaptiveTraining.featureList[featureName].activatedMoreInfoPromptFunction(featureName)
		elseif (featureName) and (mainUI) and  (mainUI.savedLocally) and  (mainUI.savedLocally.adaptiveTraining) and ( mainUI.savedLocally.adaptiveTraining.featureList) and (mainUI.savedLocally.adaptiveTraining.featureList[featureName]) and (mainUI.savedLocally.adaptiveTraining.featureList[featureName].activatedPromptFunction) then
			mainUI.savedLocally.adaptiveTraining.featureList[featureName].activatedPromptFunction(featureName)
		end
		mainUI.AdaptiveTraining.UpdateLastPromptedTimestampByFeatureName(featureName)
		mainUI.AdaptiveTraining.KillAllActivePrompts()
	end		
	
	function mainUI.AdaptiveTraining.DisplayPromptByFeatureName(featureName)
		printDebug('DisplayPromptByFeatureName: ' .. featureName)
		if (featureName) and (mainUI) and  (mainUI.savedLocally) and  (mainUI.savedLocally.adaptiveTraining) and ( mainUI.savedLocally.adaptiveTraining.featureList) and (mainUI.savedLocally.adaptiveTraining.featureList[featureName]) and (mainUI.savedLocally.adaptiveTraining.featureList[featureName].displayPromptFunction) then
			mainUI.savedLocally.adaptiveTraining.featureList[featureName].displayPromptFunction(featureName)
		end
		mainUI.AdaptiveTraining.UpdateLastPromptedTimestampByFeatureName(featureName)	
	end	
	
	function mainUI.AdaptiveTraining.RecordViewInstanceByFeatureName(featureName)
		printDebug('RecordViewInstanceByFeatureName: ' .. featureName)
		if (featureName) and (mainUI) and  (mainUI.savedLocally) and  (mainUI.savedLocally.adaptiveTraining) and ( mainUI.savedLocally.adaptiveTraining.featureList) and (mainUI.savedLocally.adaptiveTraining.featureList[featureName]) then
			if (mainUI.savedLocally.adaptiveTraining.featureList[featureName].trackViewed) then
				mainUI.savedLocally.adaptiveTraining.featureList[featureName].lastViewed = mainUI.AdaptiveTraining.GetCurrentUnixTimestamp()
				mainUI.savedLocally.adaptiveTraining.featureList[featureName].timesViewed = mainUI.savedLocally.adaptiveTraining.featureList[featureName].timesViewed or 0
				mainUI.savedLocally.adaptiveTraining.featureList[featureName].timesViewed = mainUI.savedLocally.adaptiveTraining.featureList[featureName].timesViewed + 1
			end
			if (mainUI.savedLocally.adaptiveTraining.featureList[featureName].trackAllViews) then
				mainUI.savedLocally.adaptiveTraining.featureList[featureName].tableOfAllViewInstances = mainUI.savedLocally.adaptiveTraining.featureList[featureName].tableOfAllViewInstances or {}
				table.insert(mainUI.savedLocally.adaptiveTraining.featureList[featureName].tableOfAllViewInstances, mainUI.AdaptiveTraining.GetCurrentUnixTimestamp())
			end			
		end
		mainUI.AdaptiveTraining.KillAllActivePrompts()
	end
	
	function mainUI.AdaptiveTraining.RecordUtilisationInstanceByFeatureName(featureName)
		printDebug('RecordUtilisationInstanceByFeatureName: ' .. featureName)
		if (featureName) and (mainUI) and  (mainUI.savedLocally) and  (mainUI.savedLocally.adaptiveTraining) and ( mainUI.savedLocally.adaptiveTraining.featureList) and (mainUI.savedLocally.adaptiveTraining.featureList[featureName]) then
			if (mainUI.savedLocally.adaptiveTraining.featureList[featureName].trackUtilisation) then
				mainUI.savedLocally.adaptiveTraining.featureList[featureName].lastUtilised = mainUI.AdaptiveTraining.GetCurrentUnixTimestamp()
				mainUI.savedLocally.adaptiveTraining.featureList[featureName].timesUtilised = mainUI.savedLocally.adaptiveTraining.featureList[featureName].timesUtilised or 0
				mainUI.savedLocally.adaptiveTraining.featureList[featureName].timesUtilised = mainUI.savedLocally.adaptiveTraining.featureList[featureName].timesUtilised + 1
			end
			if (mainUI.savedLocally.adaptiveTraining.featureList[featureName].trackAllUtilisations) then
				mainUI.savedLocally.adaptiveTraining.featureList[featureName].tableOfAllUtilisedInstances = mainUI.savedLocally.adaptiveTraining.featureList[featureName].tableOfAllUtilisedInstances or {}
				table.insert(mainUI.savedLocally.adaptiveTraining.featureList[featureName].tableOfAllUtilisedInstances, mainUI.AdaptiveTraining.GetCurrentUnixTimestamp())
			end			
		end
		mainUI.AdaptiveTraining.KillAllActivePrompts()
		mainUI.AdaptiveTraining.RecordViewInstanceByFeatureName(featureName)
	end	
	
	function mainUI.AdaptiveTraining.UpdateFeatureByName(featureName, index, value)
		printDebug('UpdateFeatureByName: ' .. featureName)
		if (featureName) and (index) and (value ~= nil) and (mainUI) and  (mainUI.savedLocally) and  (mainUI.savedLocally.adaptiveTraining) and (mainUI.savedLocally.adaptiveTraining.featureList) and (mainUI.savedLocally.adaptiveTraining.featureList[featureName]) then
			mainUI.savedLocally.adaptiveTraining.featureList[featureName][index] = value
		end
	end
		
	function mainUI.AdaptiveTraining.GetFeatureByName(featureName)
		printDebug('GetFeatureByName: ' .. featureName)
		if (featureName) and (mainUI) and  (mainUI.savedLocally) and  (mainUI.savedLocally.adaptiveTraining) and ( mainUI.savedLocally.adaptiveTraining.featureList) and (mainUI.savedLocally.adaptiveTraining.featureList[featureName]) then
			return mainUI.savedLocally.adaptiveTraining.featureList[featureName]
		end
	end		
	
	function mainUI.AdaptiveTraining.GetPositionDataFromTargetWidget(widgetName)
		printDebug('GetPositionDataFromTargetWidget: ' .. widgetName)
		local widget = GetWidget(widgetName)
		return {
			align 	= widget:GetAlign(),
			valign 	= widget:GetVAlign(),
			x 		= widget:GetAbsoluteX(),
			y 		= widget:GetAbsoluteY(),
			width 	= widget:GetWidth(),
			height 	= widget:GetHeight(),
		}
	end	
	
	local function InitData()

		local featureDepthRequiredLevel0			= 2			-- New Account, one game played
		local featureDepthRequiredLevel1			= 5			-- Account level required before introducing the most basic extra features	(Pets, Crafting, Add Friend)
		local featureDepthRequiredLevel2			= 10		-- Account level required before introducing common extra features			(Chat/IMs, Single Player Experience, Hero Builds, Stats, The Profile, Spectating, Replays, Unlock Another Pet, Account Boost)
		local featureDepthRequiredLevel3			= 25		-- Account level required before introducing advanced extra features		(Ranked Play, Groups, Practice Mode, Twitch, Change Account Icon, Skins, Gear, Pet Skins)
		local featureDepthRequiredLevel4			= 50		-- Account level required before introducing end game extra features		(IHL Groups?, Custom Games, Change Unique ID, Gem Purchase)
		
		local featureList = {		
			{
				featureName 						= 'profile',
				priorityRank 						= 50,
				eligibleToTrackFunction				= function() return mainUI.AdaptiveTraining.AlwaysTrue() end,
				eligibleToPromptUserFunction		= function(...) return ( mainUI.AdaptiveTraining.ReachedAccountLevelX(featureDepthRequiredLevel2) and mainUI.AdaptiveTraining.WidgetVisible('main_header_player_card') and mainUI.AdaptiveTraining.CurrentMainPanelIs(mainUI.MainValues.news) ) end,
				displayPromptFunction				= function(...) 
					mainUI.AdaptiveTraining.DisplayPromptInSpeechBubbleStyle('profile', nil, nil, nil, x, y, nil, nil, nil, nil, nil, nil) 
				end,
				activatedPromptFunction				= function() mainUI.AdaptiveTraining.OpenMainPanelByIndex(mainUI.MainValues.profile) end,
				activatedMoreInfoPromptFunction		= function() mainUI.AdaptiveTraining.OpenMainPanelByIndex(mainUI.MainValues.profile) end,
				trackViewed							= true,
				displayPrompts						= true,
				minimumPromptCooldown				= (3 * daysToS),
				minimumViewCooldown					= (14 * daysToS),
			},
			{
				featureName 						= 'play_spe_1',
				priorityRank 						= 55,
				eligibleToTrackFunction				= function() return mainUI.AdaptiveTraining.AlwaysTrue() end,
				eligibleToPromptUserFunction		= function(...) 
					
					return ((not (mainUI.featureMaintenance and mainUI.featureMaintenance['play_spe_1'])) and mainUI.AdaptiveTraining.ReachedAccountLevelX(featureDepthRequiredLevel1) and mainUI.AdaptiveTraining.WidgetVisible('playScreenTypeSwitcher3Parent') and mainUI.AdaptiveTraining.CurrentMainPanelIs(mainUI.MainValues.selectMode) ) 
				end,
				displayPromptFunction				= function(...) 
					local positionData  			= mainUI.AdaptiveTraining.GetPositionDataFromTargetWidget('playScreenTypeSwitcher3Parent')
					mainUI.AdaptiveTraining.DisplayPromptInSpeechBubbleStyle('play_spe_1', nil, nil, nil, positionData.x + 20, positionData.y - 160, '370s', nil, '/ui/main/shared/frames/speech_bl_nip.tga', nil, nil, nil) 
				end,
				activatedPromptFunction				= nil,
				activatedMoreInfoPromptFunction		= nil,
				trackViewed							= true,
				displayPrompts						= true,
				minimumPromptCooldown				= (14 * daysToS),
				minimumViewCooldown					= -1,
			},	 	
			{  
				featureName 						= 'crafting',
				priorityRank 						= 40,
				eligibleToTrackFunction				= function() return mainUI.AdaptiveTraining.AlwaysTrue() end,
				eligibleToPromptUserFunction		= function(...) 
					return ( mainUI.AdaptiveTraining.ReachedAccountLevelX(featureDepthRequiredLevel2) and mainUI.AdaptiveTraining.WidgetVisible('main_top_button_craftButton') and mainUI.AdaptiveTraining.CurrentMainPanelIs(mainUI.MainValues.news) and mainUI.AdaptiveTraining.DoIHaveAtLeastXElixir(360) ) 
				end,
				displayPromptFunction				= function(...) 
					if (mainUI) and (mainUI.savedRemotely) and ((not mainUI.savedRemotely.splashScreensViewed) or (not mainUI.savedRemotely.splashScreensViewed['splash_screen_unlocked_crafting'])) and LuaTrigger.GetTrigger('CraftedItems0') and LuaTrigger.GetTrigger('CraftedItems0').name and (Empty(LuaTrigger.GetTrigger('CraftedItems0').name)) then
						mainUI.savedRemotely = mainUI.savedRemotely or {}
						mainUI.savedRemotely.splashScreensViewed = mainUI.savedRemotely.splashScreensViewed or {}
						mainUI.savedRemotely.splashScreensViewed['splash_screen_unlocked_crafting'] = true
						SaveState()
						mainUI.ShowSplashScreen('splash_screen_unlocked_crafting')
					else
						local positionData  			= mainUI.AdaptiveTraining.GetPositionDataFromTargetWidget('main_top_button_craftButton')
						mainUI.AdaptiveTraining.DisplayPromptInSpeechBubbleStyle('crafting', nil, nil, nil, positionData.x - 380, positionData.y + 60, '370s', nil, '/ui/main/shared/frames/speech_tr_nip.tga', nil, nil, nil)
					end
				end,
				activatedPromptFunction				= nil,
				activatedMoreInfoPromptFunction		= nil,
				trackViewed							= true,
				displayPrompts						= true,
				minimumPromptCooldown				= (3 * daysToS),
				minimumViewCooldown					= (8 * daysToS),
			},		
			{	 	 
				featureName 						= 'pets',
				priorityRank 						= 45,
				eligibleToTrackFunction				= function() return mainUI.AdaptiveTraining.AlwaysTrue() end,
				eligibleToPromptUserFunction		= function(...) 
					return ( mainUI.AdaptiveTraining.ReachedAccountLevelX(featureDepthRequiredLevel2) and mainUI.AdaptiveTraining.WidgetVisible('main_top_button_petsButton') and mainUI.AdaptiveTraining.CurrentMainPanelIs(mainUI.MainValues.news) and mainUI.AdaptiveTraining.IsThereAPetICanBuy() ) 
				end,
				displayPromptFunction				= function(...) 
					local positionData  			= mainUI.AdaptiveTraining.GetPositionDataFromTargetWidget('main_top_button_petsButton')
					mainUI.AdaptiveTraining.DisplayPromptInSpeechBubbleStyle('pets', nil, nil, nil, positionData.x - 380, positionData.y + 60, '370s', nil, '/ui/main/shared/frames/speech_tr_nip.tga', nil, nil, nil) 
				end,
				activatedPromptFunction				= nil,
				activatedMoreInfoPromptFunction		= nil,
				trackViewed							= true,
				displayPrompts						= true,
				minimumPromptCooldown				= (3 * daysToS),
				minimumViewCooldown					= (8 * daysToS),
			},		
			{	
				featureName 						= 'prompt_newbie_checklist',
				priorityRank 						= 5,
				eligibleToTrackFunction				= function() return mainUI.AdaptiveTraining.AlwaysTrue() end,
				eligibleToPromptUserFunction		= function(...) 
					return ((not (mainUI.featureMaintenance and mainUI.featureMaintenance['prompt_newbie_checklist'])) and mainUI.AdaptiveTraining.ReachedAccountLevelX(featureDepthRequiredLevel0) and mainUI.AdaptiveTraining.CurrentMainPanelIs(mainUI.MainValues.news) and (not Empty(TranslateOrNil('adaptive_training_feature_desc_prompt_newbie_checklist_url'))) )
				end,
				displayPromptFunction				= function(...) 
					mainUI.AdaptiveTraining.DisplayPromptInKeeperNotificationStyle('prompt_newbie_checklist') 
				end,
				activatedPromptFunction				= nil,
				activatedMoreInfoPromptFunction		= nil,
				trackViewed							= true,
				displayPrompts						= true,
				minimumPromptCooldown				= -1,
				minimumViewCooldown					= -1,
			},		
			{	
				featureName 						= 'prompt_boost_expired',
				priorityRank 						= 35,
				eligibleToTrackFunction				= function() return mainUI.AdaptiveTraining.AlwaysTrue() end,
				eligibleToPromptUserFunction		= function(...) 
					return (mainUI.AdaptiveTraining.ReachedAccountLevelX(featureDepthRequiredLevel0) and mainUI.AdaptiveTraining.CurrentMainPanelIs(40) and mainUI and mainUI.savedLocally and mainUI.savedLocally.accountBoostInfo and mainUI.savedLocally.accountBoostInfo.notifyOfXPBoostExpiry)
				end,
				displayPromptFunction				= function(...) 
					mainUI.savedLocally.accountBoostInfo.notifyOfXPBoostExpiry = nil
					SaveState()
					local positionData  			= mainUI.AdaptiveTraining.GetPositionDataFromTargetWidget('player_card_purchase_bonus_boost')
					mainUI.AdaptiveTraining.DisplayPromptInSpeechBubbleStyle('prompt_boost_expired', nil, nil, nil, positionData.x + 10, positionData.y + 4, '370s', nil, '/ui/main/shared/frames/speech_tl_nip.tga', nil, nil, nil) 
				end,
				activatedPromptFunction				= nil,
				activatedMoreInfoPromptFunction		= nil,
				trackViewed							= true,
				displayPrompts						= true,
				minimumPromptCooldown				= (1 * daysToS),
				minimumViewCooldown					= (1 * daysToS),
			},			
			{	
				featureName 						= 'server_regions_changed',
				priorityRank 						= 65,
				eligibleToTrackFunction				= function() return mainUI.AdaptiveTraining.AlwaysTrue() end,
				eligibleToPromptUserFunction		= function(...) 
					return mainUI.AdaptiveTraining.AlwaysFalse()
				end,
				displayPromptFunction				= function(...) 
					local positionData  			= mainUI.AdaptiveTraining.GetPositionDataFromTargetWidget('selection_ribbons_primary_btn')
					mainUI.AdaptiveTraining.DisplayPromptInSpeechBubbleStyle('server_regions_changed', nil, nil, nil, positionData.x - 380, positionData.y - 100, '370s', nil, '/ui/main/shared/frames/speech_br_nip.tga', nil, nil, nil) 
				end,
				activatedPromptFunction				= nil,
				activatedMoreInfoPromptFunction		= nil,
				trackViewed							= true,
				displayPrompts						= true,
				minimumPromptCooldown				= (1 * daysToS),
				minimumViewCooldown					= (1 * daysToS),
			},	 	
			{
				featureName 						= 'options',
				priorityRank 						= 70,
				eligibleToTrackFunction				= function() return mainUI.AdaptiveTraining.AlwaysTrue() end,
				eligibleToPromptUserFunction		= function(...) return ( mainUI.AdaptiveTraining.ReachedAccountLevelX(featureDepthRequiredLevel2) and mainUI.AdaptiveTraining.WidgetVisible('main_header_btn_options') and mainUI.AdaptiveTraining.CurrentMainPanelIs(mainUI.MainValues.news) ) end,
				displayPromptFunction				= function(...) 
					local positionData  			= mainUI.AdaptiveTraining.GetPositionDataFromTargetWidget('main_header_btn_options')
					mainUI.AdaptiveTraining.DisplayPromptInSpeechBubbleStyle('options', nil, nil, nil, positionData.x - 370, positionData.y + 10, '370s', nil, '/ui/main/shared/frames/speech_tr_nip.tga', nil, nil, nil) 
				end,
				activatedPromptFunction				= function() mainUI.AdaptiveTraining.OpenMainPanelByIndex(mainUI.MainValues.profile) end,
				activatedMoreInfoPromptFunction		= function() mainUI.AdaptiveTraining.OpenMainPanelByIndex(mainUI.MainValues.profile) end,
				trackViewed							= true,
				displayPrompts						= true,
				minimumPromptCooldown				= (3 * daysToS),
				minimumViewCooldown					= (30 * daysToS),
			},	
			{
				featureName 						= 'twitch',
				priorityRank 						= 75,
				eligibleToTrackFunction				= function() return mainUI.AdaptiveTraining.AlwaysTrue() end,
				eligibleToPromptUserFunction		= function(...) return ( mainUI.AdaptiveTraining.ReachedAccountLevelX(featureDepthRequiredLevel3) and mainUI.AdaptiveTraining.WidgetVisible('main_header_btn_twitch') and mainUI.AdaptiveTraining.CurrentMainPanelIs(mainUI.MainValues.news) ) end,
				displayPromptFunction				= function(...) 
					local positionData  			= mainUI.AdaptiveTraining.GetPositionDataFromTargetWidget('main_header_btn_twitch')
					mainUI.AdaptiveTraining.DisplayPromptInSpeechBubbleStyle('twitch', nil, nil, nil, positionData.x - 370, positionData.y + 10, '370s', nil, '/ui/main/shared/frames/speech_tr_nip.tga', nil, nil, nil) 
				end,
				activatedPromptFunction				= function() mainUI.AdaptiveTraining.OpenMainPanelByIndex(mainUI.MainValues.profile) end,
				activatedMoreInfoPromptFunction		= function() mainUI.AdaptiveTraining.OpenMainPanelByIndex(mainUI.MainValues.profile) end,
				trackViewed							= true,
				displayPrompts						= true,
				minimumPromptCooldown				= (3 * daysToS),
				minimumViewCooldown					= (30 * daysToS),
			},				
			{
				featureName 						= 'watch',
				priorityRank 						= 85,
				eligibleToTrackFunction				= function() return mainUI.AdaptiveTraining.AlwaysTrue() end,
				eligibleToPromptUserFunction		= function(...) return ( mainUI.AdaptiveTraining.ReachedAccountLevelX(featureDepthRequiredLevel2) and mainUI.AdaptiveTraining.WidgetVisible('main_top_button_watchButton') and mainUI.AdaptiveTraining.CurrentMainPanelIs(mainUI.MainValues.news) ) end,
				displayPromptFunction				= function(...) 
					local positionData  			= mainUI.AdaptiveTraining.GetPositionDataFromTargetWidget('main_top_button_watchButton')
					mainUI.AdaptiveTraining.DisplayPromptInSpeechBubbleStyle('watch', nil, nil, nil, positionData.x - 380, positionData.y + 60, '370s', nil, '/ui/main/shared/frames/speech_tr_nip.tga', nil, nil, nil) 
				end,
				activatedPromptFunction				= function() mainUI.AdaptiveTraining.OpenMainPanelByIndex(mainUI.MainValues.profile) end,
				activatedMoreInfoPromptFunction		= function() mainUI.AdaptiveTraining.OpenMainPanelByIndex(mainUI.MainValues.profile) end,
				trackViewed							= true,
				displayPrompts						= true,
				minimumPromptCooldown				= (7 * daysToS),
				minimumViewCooldown					= (30 * daysToS),
			},		
			
			-- {'play_pvp'},					
			-- {'play_pve'},										 
			-- {'practice_mode'}, 			
			-- {'npe_complete'},								
			-- {'referafriend'}, 			 
			-- {'ranked'},					
			-- {'replays'},					
			-- {'spectate'},							
			-- {'boost_account'},			 
			-- {'buy_gems'},				
		}
		
		local featureName
		for i,featureTable in pairs(featureList) do
			featureName = featureTable.featureName
			if (featureName) then
				mainUI.savedLocally.adaptiveTraining.featureList[featureName]									= mainUI.savedLocally.adaptiveTraining.featureList[featureName]											or	featureTable									or {}
				
				mainUI.savedLocally.adaptiveTraining.featureList[featureName].featureName 						= featureTable.featureName 						or nil
				
				mainUI.savedLocally.adaptiveTraining.featureList[featureName].priorityRank						= featureTable.priorityRank							or 100
				mainUI.savedLocally.adaptiveTraining.featureList[featureName].eligibleToTrackFunction			= featureTable.eligibleToTrackFunction				or mainUI.AdaptiveTraining.AlwaysTrue
				mainUI.savedLocally.adaptiveTraining.featureList[featureName].eligibleToPromptUserFunction		= featureTable.eligibleToPromptUserFunction			or mainUI.AdaptiveTraining.AlwaysTrue
				
				mainUI.savedLocally.adaptiveTraining.featureList[featureName].displayPromptFunction				= featureTable.displayPromptFunction				or nil
				mainUI.savedLocally.adaptiveTraining.featureList[featureName].activatedPromptFunction			= featureTable.activatedPromptFunction				or nil
				mainUI.savedLocally.adaptiveTraining.featureList[featureName].activatedMoreInfoPromptFunction	= featureTable.activatedMoreInfoPromptFunction		or nil
				
				mainUI.savedLocally.adaptiveTraining.featureList[featureName].displayPrompts					= featureTable.displayPrompts						or nil
				mainUI.savedLocally.adaptiveTraining.featureList[featureName].trackViewed						= featureTable.trackViewed							or nil
				mainUI.savedLocally.adaptiveTraining.featureList[featureName].trackAllViews						= featureTable.trackAllViews						or nil
				
				mainUI.savedLocally.adaptiveTraining.featureList[featureName].trackUtilisation					= featureTable.trackUtilisation						or nil
				mainUI.savedLocally.adaptiveTraining.featureList[featureName].trackAllUtilisations				= featureTable.trackAllUtilisations					or nil	
				mainUI.savedLocally.adaptiveTraining.featureList[featureName].minimumPromptCooldown 			= featureTable.minimumPromptCooldown 				or (5 * secondsToS)
				mainUI.savedLocally.adaptiveTraining.featureList[featureName].minimumViewCooldown 				= featureTable.minimumViewCooldown 					or -1
				mainUI.savedLocally.adaptiveTraining.featureList[featureName].minimumUtilisationCooldown 		= featureTable.minimumUtilisationCooldown			or -1
				
				-- These are tracked, not specified
				mainUI.savedLocally.adaptiveTraining.featureList[featureName].lastPrompted 						= mainUI.savedLocally.adaptiveTraining.featureList[featureName].lastPrompted 							or	featureTable.lastPrompted 						or nil	
				mainUI.savedLocally.adaptiveTraining.featureList[featureName].lastViewed 						= mainUI.savedLocally.adaptiveTraining.featureList[featureName].lastViewed 								or	featureTable.lastViewed 						or nil
				mainUI.savedLocally.adaptiveTraining.featureList[featureName].timesViewed						= mainUI.savedLocally.adaptiveTraining.featureList[featureName].timesViewed 							or	featureTable.timesViewed 						or nil
				mainUI.savedLocally.adaptiveTraining.featureList[featureName].tableOfAllViewInstances			= mainUI.savedLocally.adaptiveTraining.featureList[featureName].tableOfAllViewInstances 				or	featureTable.tableOfAllViewInstances 			or nil
				mainUI.savedLocally.adaptiveTraining.featureList[featureName].lastUtilised 						= mainUI.savedLocally.adaptiveTraining.featureList[featureName].lastUtilised 							or	featureTable.lastUtilised 						or nil
				mainUI.savedLocally.adaptiveTraining.featureList[featureName].timesUtilised						= mainUI.savedLocally.adaptiveTraining.featureList[featureName].timesUtilised 							or	featureTable.timesUtilised 						or nil
				mainUI.savedLocally.adaptiveTraining.featureList[featureName].tableOfAllUtilisedInstances		= mainUI.savedLocally.adaptiveTraining.featureList[featureName].tableOfAllUtilisedInstances 			or	featureTable.tableOfAllUtilisedInstances 		or nil
			end
		end		

	end

	local function Init()
		
		mainUI.savedLocally 								= mainUI.savedLocally 									or {}
		mainUI.savedLocally.adaptiveTraining 				= mainUI.savedLocally.adaptiveTraining 					or {}
		mainUI.savedLocally.adaptiveTraining.featureList 	= mainUI.savedLocally.adaptiveTraining.featureList 		or {}
		
		if (GetCvarBool('ui_debug_AdaptiveTraining')) then
			mainUI.savedLocally.adaptiveTraining.featureList	= {} -- RMM Clear all data for testing
		end

		InitData()

		local npeTrigger = LuaTrigger.GetTrigger('newPlayerExperience')
		if ((npeTrigger) and ((npeTrigger.tutorialProgress >= NPE_PROGRESS_TUTORIALCOMPLETE) or (npeTrigger.tutorialComplete))) then
			
			-- mainUI.AdaptiveTraining.QueueDelayedEvent(mainUI.AdaptiveTraining.CheckIfIShouldPromptAnything, (60 * secondsToS), true)
			
			-- UnwatchLuaTriggerByKey('mainPanelStatus', 'AdaptiveTrainingmainPanelStatusKey')
			-- WatchLuaTrigger('mainPanelStatus', function(trigger)	
				-- mainUI.AdaptiveTraining.CheckIfIShouldPromptAnything()
			-- end, 'AdaptiveTrainingmainPanelStatusKey', 'main')				
			
			local statusThread
			GetWidget('adaptive_training_instantiation_target'):RegisterWatchLua('mainPanelStatus', function(widget, trigger)
				mainUI.AdaptiveTraining.KillAllActivePrompts()
				if (statusThread) then
					statusThread:kill()
					statusThread = nil
				end
				statusThread = libThread.threadFunc(function()
					wait(styles_mainSwapAnimationDuration * 2.1)				
					mainUI.AdaptiveTraining.CheckIfIShouldPromptAnything(trigger.main)
					statusThread = nil
				end)
			end, false, nil, 'main')
			
		end
		
		mainUI.AdaptiveTraining.global.lastPromptedTimestamp				= (mainUI.AdaptiveTraining.GetCurrentUnixTimestamp() - mainUI.AdaptiveTraining.global.minimumPromptCooldown) + (15 * secondsToS)

	end
	
	local needsInit = true
	function mainUI.AdaptiveTraining.Init()
		if (needsInit) and IsFullyLoggedIn(GetIdentID()) then
			needsInit = false
			Init()
		end
	end

end

AdaptiveTrainingRegister(object)