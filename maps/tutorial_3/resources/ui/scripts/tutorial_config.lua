-- Tutorial Config


-- ========================================
-- Tips / Dialogue
-- ========================================


tutorialRegisterTip({
	event			= 'tutorial3_tip1',				-- Event Name (trigger)
	body			= 'tutorial3_tip1_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial3_tip1Hide',
	showTime		= 8000,
	sound			= '/maps/tutorial_3/resources/sounds/voice/vo_announcer_1.wav'
})

tutorialRegisterTip({
	event			= 'tutorial3_tip2',				-- Event Name (trigger)
	body			= 'tutorial3_tip2_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial3_tip2Hide',
	showTime		= 8000,
	sound			= '/maps/tutorial_3/resources/sounds/voice/vo_announcer_2.wav'
})

tutorialRegisterTip({
	event			= 'tutorial3_tip3',				-- Event Name (trigger)
	body			= 'tutorial3_tip3_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial3_tip3Hide',
	showTime		= 9000,
	sound			= '/maps/tutorial_3/resources/sounds/voice/vo_announcer_3.wav'
})

tutorialRegisterTip({
	event			= 'tutorial3_tip4',				-- Event Name (trigger)
	body			= 'tutorial3_tip4_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial3_tip4Hide',
	showTime		= 9000,
	sound			= '/maps/tutorial_3/resources/sounds/voice/vo_announcer_4.wav'
})

tutorialRegisterTip({
	event			= 'tutorial3_tip5',				-- Event Name (trigger)
	body			= 'tutorial3_tip5_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial3_tip5Hide',
	sound			= '/maps/tutorial_3/resources/sounds/voice/vo_announcer_5.wav'
})

tutorialRegisterTip({
	event			= 'tutorial3_tip6',				-- Event Name (trigger)
	body			= 'tutorial3_tip6_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial3_tip6Hide',
	showTime		= 3500,
	sound			= '/maps/tutorial_3/resources/sounds/voice/vo_announcer_6.wav'
})

tutorialRegisterTip({
	event			= 'tutorial3_tip7',				-- Event Name (trigger)
	body			= 'tutorial3_tip7_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial3_tip7Hide',
	sound			= '/maps/tutorial_3/resources/sounds/voice/vo_announcer_11.wav'
})


tutorialRegisterTip({
	event			= 'tutorial3_tip8',				-- Event Name (trigger)
	body			= 'tutorial3_tip8_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial3_tip8Hide',
	sound			= '/maps/tutorial_3/resources/sounds/voice/vo_announcer_7.wav'
})

tutorialRegisterTip({
	event			= 'tutorial3_tip9',				-- Event Name (trigger)
	body			= 'tutorial3_tip9_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial3_tip9Hide',
	showTime		= 6000,
	sound			= '/maps/tutorial_3/resources/sounds/voice/vo_announcer_8.wav'
})

tutorialRegisterTip({
	event			= 'tutorial3_tip10',				-- Event Name (trigger)
	body			= 'tutorial3_tip10_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial3_tip10Hide',
	showTime		= 14000,
	sound			= '/maps/tutorial_3/resources/sounds/voice/vo_announcer_9.wav'
})

tutorialRegisterTip({
	event			= 'tutorial3_tip11',				-- Event Name (trigger)
	body			= 'tutorial3_tip11_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial3_tip11Hide',
	showTime		= 13000,
	sound			= '/maps/tutorial_3/resources/sounds/voice/vo_announcer_10.wav'
})

tutorialRegisterTip({	-- Doesn't support models - let Merc know if that's required.
	event			= 'tutorial3_tip_toweraggro',				-- Event Name (trigger)
	body			= 'tutorial3_tip_toweraggro_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial3_tip_toweraggro_Hide',
	sound			= '/maps/tutorial/resources/sounds/voice/vo_announcer_38.wav',
	showTime		= 10000
})

tutorialRegisterTip({	-- Doesn't support models - let Merc know if that's required.
	event			= 'tutorial3_tip_attackhero',				-- Event Name (trigger)
	body			= 'tutorial3_tip_attackhero_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial3_tip_attackhero_Hide',
	sound			= '/maps/tutorial/resources/sounds/voice/vo_announcer_34.wav',
	showTime		= 10000
})

-- ========================================
-- Sounds
-- ========================================

-- Announcer Sounds

tutorialRegisterSound({
	event			= 'tutorial3_sound_2_1',				-- Event Name (trigger)
	sound			= '/maps/tutorial_3/resources/sounds/voice/vo_announcer_2_1.wav'
})

tutorialRegisterSound({
	event			= 'tutorial3_sound_2_2',				-- Event Name (trigger)
	sound			= '/maps/tutorial_3/resources/sounds/voice/vo_announcer_2_2.wav'
})

tutorialRegisterSound({
	event			= 'tutorial3_sound_2_3',				-- Event Name (trigger)
	sound			= '/maps/tutorial_3/resources/sounds/voice/vo_announcer_2_3.wav'
})

tutorialRegisterSound({
	event			= 'tutorial3_sound_3_1',				-- Event Name (trigger)
	sound			= '/maps/tutorial_3/resources/sounds/voice/vo_announcer_3_1.wav'
})

tutorialRegisterSound({
	event			= 'tutorial3_sound_3_2',				-- Event Name (trigger)
	sound			= '/maps/tutorial_3/resources/sounds/voice/vo_announcer_3_2.wav'
})

-- Lex Sounds

tutorialRegisterSound({
	event			= 'tutorial3_sound_lex_1',				-- Event Name (trigger)
	sound			= '/maps/tutorial_3/resources/sounds/voice/vo_khan_6.wav'
})

tutorialRegisterSound({
	event			= 'tutorial3_sound_lex_2',				-- Event Name (trigger)
	sound			= '/maps/tutorial_3/resources/sounds/voice/vo_khan_7.wav'
})

tutorialRegisterSound({
	event			= 'tutorial3_sound_lex_3',				-- Event Name (trigger)
	sound			= '/maps/tutorial_3/resources/sounds/voice/vo_khan_10.wav'
})

tutorialRegisterSound({
	event			= 'tutorial3_sound_lex_4',				-- Event Name (trigger)
	sound			= '/maps/tutorial_3/resources/sounds/voice/vo_khan_11.wav'
})

tutorialRegisterSound({
	event			= 'tutorial3_sound_lex_5',				-- Event Name (trigger)
	sound			= '/maps/tutorial_3/resources/sounds/voice/vo_khan_12.wav'
})

tutorialRegisterSound({
	event			= 'tutorial3_sound_lex_6',				-- Event Name (trigger)
	sound			= '/maps/tutorial_3/resources/sounds/voice/vo_khan_13.wav'
})

tutorialRegisterSound({
	event			= 'tutorial3_sound_lex_7',				-- Event Name (trigger)
	sound			= '/maps/tutorial_3/resources/sounds/voice/vo_khan_14.wav'
})

tutorialRegisterSound({
	event			= 'tutorial3_sound_lex_8',				-- Event Name (trigger)
	sound			= '/maps/tutorial_3/resources/sounds/voice/vo_khan_15.wav'
})

tutorialRegisterSound({
	event			= 'tutorial3_sound_lex_9',				-- Event Name (trigger)
	sound			= '/maps/tutorial_3/resources/sounds/voice/vo_khan_16.wav'
})

tutorialRegisterSound({
	event			= 'tutorial3_sound_lex_10',				-- Event Name (trigger)
	sound			= '/maps/tutorial_3/resources/sounds/voice/vo_khan_17.wav'
})

tutorialRegisterSound({
	event			= 'tutorial3_sound_lex_11',				-- Event Name (trigger)
	sound			= '/maps/tutorial_3/resources/sounds/voice/vo_khan_18.wav'
})





-- ========================================
-- Objectives
-- ========================================

tutorialRegisterObjective({
	showEvent				= 'tutorial3_objective1',
	completionEvent			= 'tutorial3_objective1Complete',	-- Will increment the completion count and will clear the objective once completion is maxed.
	completionCount			= 1,		-- How many times must this be completed?, defaults to 1
	label					= 'tutorial3_objective1',
	extraInfo				= 'tutorial3_objective1MoreInfo',			-- Click the "more info" question mark button to trigger this event (can be linked back to a message or popup)
	pingScriptValue			= 'tutorial3_objective1ScriptValue',			-- Value to set to 1 when the ping map button is clicked
	showOptions				= true,			-- Whether to show ping/more help buttons.
})

tutorialRegisterObjective({
	showEvent				= 'tutorial3_objective2',
	completionEvent			= 'tutorial3_objective2Complete',	-- Will increment the completion count and will clear the objective once completion is maxed.
	completionCount			= 1,		-- How many times must this be completed?, defaults to 1
	label					= 'tutorial3_objective2',
	extraInfo				= 'tutorial3_objective2MoreInfo',			-- Click the "more info" question mark button to trigger this event (can be linked back to a message or popup)
	pingScriptValue			= 'tutorial3_objective2ScriptValue',			-- Value to set to 1 when the ping map button is clicked
	showOptions				= true,			-- Whether to show ping/more help buttons.
})

tutorialRegisterObjective({
	showEvent				= 'tutorial3_objective3',
	completionEvent			= 'tutorial3_objective3Complete',	-- Will increment the completion count and will clear the objective once completion is maxed.
	completionCount			= 6,		-- How many times must this be completed?, defaults to 1
	label					= 'tutorial3_objective3',
	extraInfo				= 'tutorial3_objective3MoreInfo',			-- Click the "more info" question mark button to trigger this event (can be linked back to a message or popup)
	pingScriptValue			= 'tutorial3_objective3ScriptValue',			-- Value to set to 1 when the ping map button is clicked
	showOptions				= true,			-- Whether to show ping/more help buttons.
})

tutorialRegisterObjective({
	showEvent				= 'tutorial3_objective4',
	completionEvent			= 'tutorial3_objective4Complete',	-- Will increment the completion count and will clear the objective once completion is maxed.
	completionCount			= 1,		-- How many times must this be completed?, defaults to 1
	label					= 'tutorial3_objective4',
	extraInfo				= 'tutorial3_objective4MoreInfo',			-- Click the "more info" question mark button to trigger this event (can be linked back to a message or popup)
	pingScriptValue			= 'tutorial3_objective4ScriptValue',			-- Value to set to 1 when the ping map button is clicked
	showOptions				= true,			-- Whether to show ping/more help buttons.
})

tutorialRegisterObjective({
	showEvent				= 'tutorial3_objective5',
	completionEvent			= 'tutorial3_objective5Complete',	-- Will increment the completion count and will clear the objective once completion is maxed.
	completionCount			= 1,		-- How many times must this be completed?, defaults to 1
	label					= 'tutorial3_objective5',
	extraInfo				= 'tutorial3_objective5MoreInfo',			-- Click the "more info" question mark button to trigger this event (can be linked back to a message or popup)
	pingScriptValue			= 'tutorial3_objective5ScriptValue',			-- Value to set to 1 when the ping map button is clicked
	showOptions				= true,			-- Whether to show ping/more help buttons.
})

tutorialRegisterObjective({
	showEvent				= 'tutorial3_objective6',
	completionEvent			= 'tutorial3_objective6Complete',	-- Will increment the completion count and will clear the objective once completion is maxed.
	completionCount			= 1,		-- How many times must this be completed?, defaults to 1
	label					= 'tutorial3_objective6',
	extraInfo				= 'tutorial3_objective6MoreInfo',			-- Click the "more info" question mark button to trigger this event (can be linked back to a message or popup)
	pingScriptValue			= 'tutorial3_objective6ScriptValue',			-- Value to set to 1 when the ping map button is clicked
	showOptions				= true,			-- Whether to show ping/more help buttons.
})

tutorialRegisterObjective({
	showEvent				= 'tutorial3_objective7',
	completionEvent			= 'tutorial3_objective7Complete',	-- Will increment the completion count and will clear the objective once completion is maxed.
	completionCount			= 1,		-- How many times must this be completed?, defaults to 1
	label					= 'tutorial3_objective7',
	extraInfo				= 'tutorial3_objective7MoreInfo',			-- Click the "more info" question mark button to trigger this event (can be linked back to a message or popup)
	pingScriptValue			= 'tutorial3_objective7ScriptValue',			-- Value to set to 1 when the ping map button is clicked
	showOptions				= true,			-- Whether to show ping/more help buttons.
})

tutorialRegisterObjective({
	showEvent				= 'tutorial3_objective8',
	completionEvent			= 'tutorial3_objective8Complete',	-- Will increment the completion count and will clear the objective once completion is maxed.
	completionCount			= 1,		-- How many times must this be completed?, defaults to 1
	label					= 'tutorial3_objective8',
	extraInfo				= 'tutorial3_objective8MoreInfo',			-- Click the "more info" question mark button to trigger this event (can be linked back to a message or popup)
	pingScriptValue			= 'tutorial3_objective8ScriptValue',			-- Value to set to 1 when the ping map button is clicked
	showOptions				= true,			-- Whether to show ping/more help buttons.
})


-- ========================================
-- Hints
-- ========================================

tutorialRegisterHint({
	showEvent				= 'tutorial3_hint1',				-- Adds/shows the tip
	hideEvent				= 'tutorial3_hint1Close',		-- Removes the tip
	label1					= 'tutorial3_hint1',				-- Primary Label
	label2					= 'tutorial3_hint1Desc',			-- Secondary label (small, gray)
	icon					= '/familiars/luster/ability_02/icon.tga',
	alternateScriptValue	= 'tutorial3_hint1Alternate'		-- 
})

tutorialRegisterHint({
	showEvent				= 'tutorial3_hint2',				-- Adds/shows the tip
	hideEvent				= 'tutorial3_hint2Close',		-- Removes the tip
	label1					= 'tutorial3_hint2',				-- Primary Label
	label2					= 'tutorial3_hint2Desc',			-- Secondary label (small, gray)
	icon					= '/familiars/razer/model_2/icon.tga',
	alternateScriptValue	= 'tutorial3_hint2Alternate'		-- 
})

tutorialRegisterHint({
	showEvent				= 'tutorial3_hint3',				-- Adds/shows the tip
	hideEvent				= 'tutorial3_hint3Close',		-- Removes the tip
	label1					= 'tutorial3_hint3',				-- Primary Label
	label2					= 'tutorial3_hint3Desc',			-- Secondary label (small, gray)
	icon					= '/familiars/luster/ability_01/icon.tga',
	extraInfo				= 'tutorial3_hint3MoreInfo',	-- Click the "more info" question mark button to trigger this event (can be linked back to a message or popup)
})

tutorialRegisterHint({
	showEvent				= 'tutorial3_hint4',				-- Adds/shows the tip
	hideEvent				= 'tutorial3_hint4Close',		-- Removes the tip
	label1					= 'tutorial3_hint4',				-- Primary Label
	label2					= 'tutorial3_hint4Desc',			-- Secondary label (small, gray)
	icon					= '/npcs/Baldir_2/icon.tga',
	alternateScriptValue	= 'tutorial3_hint4Alternate'		-- 
})

tutorialRegisterHint({
	showEvent				= 'tutorial3_hint5',				-- Adds/shows the tip
	hideEvent				= 'tutorial3_hint5Close',		-- Removes the tip
	label1					= 'tutorial3_hint5',				-- Primary Label
	label2					= 'tutorial3_hint5Desc',			-- Secondary label (small, gray)
	icon					= '/maps/tutorial_3/resources/images/neutrals-icon.tga',
	extraInfo				= 'tutorial3_hint5MoreInfo',	-- Click the "more info" question mark button to trigger this event (can be linked back to a message or popup)
})

tutorialRegisterHint({
	showEvent				= 'tutorial3_hint6',				-- Adds/shows the tip
	hideEvent				= 'tutorial3_hint6Close',		-- Removes the tip
	label1					= 'tutorial3_hint6',				-- Primary Label
	label2					= 'tutorial3_hint6Desc',			-- Secondary label (small, gray)
	icon					= '/maps/tutorial_3/resources/images/observatory-icon.tga',
	extraInfo				= 'tutorial3_hint6MoreInfo',	-- Click the "more info" question mark button to trigger this event (can be linked back to a message or popup)
})

tutorialRegisterHint({
	showEvent				= 'tutorial3_hint7',				-- Adds/shows the tip
	hideEvent				= 'tutorial3_hint7Close',		-- Removes the tip
	label1					= 'tutorial3_hint7',				-- Primary Label
	label2					= 'tutorial3_hint7Desc',			-- Secondary label (small, gray)
	icon					= '/npcs/cindara/icon.tga',
	alternateScriptValue	= 'tutorial3_hint7Alternate'		-- 
})

tutorialRegisterHint({
	showEvent				= 'tutorial3_hint8',				-- Adds/shows the tip
	hideEvent				= 'tutorial3_hint8Close',		-- Removes the tip
	label1					= 'tutorial3_hint8',				-- Primary Label
	label2					= 'tutorial3_hint8Desc',			-- Secondary label (small, gray)
	icon					= '/buildings/base/melee_rax/icon.tga',
	extraInfo				= 'tutorial3_hint8MoreInfo',	-- Click the "more info" question mark button to trigger this event (can be linked back to a message or popup)
})

tutorialRegisterHint({
	showEvent				= 'tutorial3_hint9',				-- Adds/shows the tip
	hideEvent				= 'tutorial3_hint9Close',		-- Removes the tip
	label1					= 'tutorial3_hint9',				-- Primary Label
	label2					= 'tutorial3_hint9Desc',			-- Secondary label (small, gray)
	icon					= '/items/recipes/damage/zealotblade/icon.tga',
	extraInfo				= 'tutorial3_hint9MoreInfo',	-- Click the "more info" question mark button to trigger this event (can be linked back to a message or popup)
})

tutorialRegisterHint({
	showEvent				= 'tutorial3_hint10',				-- Adds/shows the tip
	hideEvent				= 'tutorial3_hint10Close',		-- Removes the tip
	label1					= 'tutorial3_hint10',				-- Primary Label
	label2					= 'tutorial3_hint10Desc',			-- Secondary label (small, gray)
	icon					= '/buildings/base/main/icon.tga',
	extraInfo				= 'tutorial3_hint10MoreInfo',	-- Click the "more info" question mark button to trigger this event (can be linked back to a message or popup)
})

tutorialRegisterHint({
	showEvent				= 'tutorial3_hint11',				-- Adds/shows the tip
	hideEvent				= 'tutorial3_hint11Close',		-- Removes the tip
	label1					= 'tutorial3_hint11',				-- Primary Label
	label2					= 'tutorial3_hint11Desc',			-- Secondary label (small, gray)
	icon					= '/npcs/Kongor/icon.tga',
	extraInfo				= 'tutorial3_hint11MoreInfo',	-- Click the "more info" question mark button to trigger this event (can be linked back to a message or popup)
})

tutorialRegisterHint({
	showEvent				= 'tutorial3_hint12',				-- Adds/shows the tip
	hideEvent				= 'tutorial3_hint12Close',		-- Removes the tip
	label1					= 'tutorial3_hint12',				-- Primary Label
	label2					= 'tutorial3_hint12Desc',			-- Secondary label (small, gray)
	icon					= '/items/boots/marchers/icon.tga',
	extraInfo				= 'tutorial3_hint12MoreInfo',	-- Click the "more info" question mark button to trigger this event (can be linked back to a message or popup)
})

-- ========================================
-- Hint Details
-- ========================================

local empowerBracerInfo = GetItemInfo('Item_Gauntlet')
--local demonFangInfo     = GetItemInfo('Item_DemonEdge')
tutorialRegisterMessage2({	-- Doesn't support models - let Merc know if that's required.
	event				= 'tutorial3_hint1MoreInfo',				-- Event Name (trigger)
	image				= '/maps/tutorial_3/resources/images/startingitems-hint.tga',
	title				= 'tutorial3_hint1MoreInfo',				-- Trom interface_en.str
	body				= 'tutorial3_hint1MoreInfo_body',			-- Body, from interface_en.str
	sound				= '/shared/sounds/keepers/draknia/none.wav',
	darkenBG			= true,							-- Show darkened background
	grayscale			= true,								-- Render rest of the game in grayscale
	showContinue		= true,							-- Allow manual continue by clicking button (or BG)
	pause				= true,						-- Pause Game
	imageHeight			= 50,	-- Height of the image - defaults to 6
	imageWidth			= 50,	-- Width of the image - defaults to imageHeight or 6
	imageSpaceHeight	= 41,	-- Total height reserved for the image - defaults to imageHeight or 6.
	hideScriptValue		= 'tutorial3_hint1MoreInfoClosed',
	hotKeyInfo = {	-- Positions to show certain hotkeys. in relation to the image. Requires x, y, content - and an interface with tutorialMessage2HotkeyContainer.
		{x = '6h', y = '8.5h',       content = Translate('game_shop_search'),      style="gameShopSearchCoverLabel"},
		{x = '13.5h', y = '16.5h', content = empowerBracerInfo.displayName, style="gameShopItemListItemName" },
		{x = '13.5h', y = '19.5h',   content = empowerBracerInfo.description:gsub("%$power%$", "7"):gsub("%$hp%$", "110"), style="gameShopItemListItemDescription" },
		--{x = '12.5h', y = '30.6h', content = demonFangInfo.displayName,     style="gameShopItemListItemName2" },
		--{x = '12.5h', y = '32.5h', content = demonFangInfo.description:gsub("%$damage%$", "18"):gsub("%^o", "^520"),   style="gameShopItemListItemDescription2" },
	}
})

tutorialRegisterMessage2({	-- Doesn't support models - let Merc know if that's required.
	event				= 'tutorial3_hint2MoreInfo',				-- Event Name (trigger)
	image				= '/maps/tutorial_3/resources/images/pets-hint.tga',
	title				= 'tutorial3_hint2MoreInfo',				-- Trom interface_en.str
	body				= 'tutorial3_hint2MoreInfo_body',			-- Body, from interface_en.str
	sound				= '/shared/sounds/keepers/draknia/none.wav',
	darkenBG			= true,							-- Show darkened background
	grayscale			= true,								-- Render rest of the game in grayscale
	showContinue		= true,							-- Allow manual continue by clicking button (or BG)
	pause				= true,						-- Pause Game
	imageHeight			= 60,	-- Height of the image - defaults to 6
	imageWidth			= 60,	-- Width of the image - defaults to imageHeight or 6
	imageSpaceHeight	= 14,	-- Total height reserved for the image - defaults to imageHeight or 6.
	hideScriptValue		= 'tutorial3_hint2MoreInfoClosed',
})

tutorialRegisterMessage2({	-- Doesn't support models - let Merc know if that's required.
	event				= 'tutorial3_hint3MoreInfo',				-- Event Name (trigger)
	image				= '/maps/tutorial_3/resources/images/goldsplitting-hint.tga',
	title				= 'tutorial3_hint3MoreInfo',				-- Trom interface_en.str
	body				= 'tutorial3_hint3MoreInfo_body',			-- Body, from interface_en.str
	sound				= '/shared/sounds/keepers/draknia/none.wav',
	darkenBG			= true,							-- Show darkened background
	grayscale			= true,								-- Render rest of the game in grayscale
	showContinue		= true,							-- Allow manual continue by clicking button (or BG)
	pause				= true,						-- Pause Game
	imageHeight			= 65,	-- Height of the image - defaults to 6
	imageWidth			= 65,	-- Width of the image - defaults to imageHeight or 6
	imageSpaceHeight	= 52,	-- Total height reserved for the image - defaults to imageHeight or 6.
	hideScriptValue		= 'tutorial3_hint3MoreInfoClosed'
})

tutorialRegisterMessage2({	-- Doesn't support models - let Merc know if that's required.
	event				= 'tutorial3_hint4MoreInfo',				-- Event Name (trigger)
	image				= '/maps/tutorial_3/resources/images/tut3ss-temp.tga',
	title				= 'tutorial3_hint4MoreInfo',				-- Trom interface_en.str
	body				= 'tutorial3_hint4MoreInfo_body',			-- Body, from interface_en.str
	sound				= '/shared/sounds/keepers/draknia/none.wav',
	darkenBG			= true,							-- Show darkened background
	grayscale			= true,								-- Render rest of the game in grayscale
	showContinue		= true,							-- Allow manual continue by clicking button (or BG)
	pause				= true,						-- Pause Game
	imageHeight			= 36,	-- Height of the image - defaults to 6
	imageWidth			= 40,	-- Width of the image - defaults to imageHeight or 6
	imageSpaceHeight	= 50,	-- Total height reserved for the image - defaults to imageHeight or 6.
	hideScriptValue		= 'tutorial3_hint4MoreInfoClosed'
})

tutorialRegisterMessage2({	-- Doesn't support models - let Merc know if that's required.
	event				= 'tutorial3_hint5MoreInfo',				-- Event Name (trigger)
	image				= '/maps/tutorial_3/resources/images/minimap.tga',
	title				= 'tutorial3_hint5MoreInfo',				-- Trom interface_en.str
	body				= 'tutorial3_hint5MoreInfo_body',			-- Body, from interface_en.str
	sound				= '/shared/sounds/keepers/draknia/none.wav',
	darkenBG			= true,							-- Show darkened background
	grayscale			= true,								-- Render rest of the game in grayscale
	showContinue		= true,							-- Allow manual continue by clicking button (or BG)
	pause				= true,						-- Pause Game
	imageHeight			= 30,	-- Height of the image - defaults to 6
	imageWidth			= 30,	-- Width of the image - defaults to imageHeight or 6
	imageSpaceHeight	= 33,	-- Total height reserved for the image - defaults to imageHeight or 6.
	hideScriptValue		= 'tutorial3_hint5MoreInfoClosed'
})

tutorialRegisterMessage2({	-- Doesn't support models - let Merc know if that's required.
	event				= 'tutorial3_hint6MoreInfo',				-- Event Name (trigger)
	image				= '/maps/tutorial_3/resources/images/observatory-hint.tga',
	title				= 'tutorial3_hint6MoreInfo',				-- Trom interface_en.str
	body				= 'tutorial3_hint6MoreInfo_body',			-- Body, from interface_en.str
	sound				= '/shared/sounds/keepers/draknia/none.wav',
	darkenBG			= true,							-- Show darkened background
	grayscale			= true,								-- Render rest of the game in grayscale
	showContinue		= true,							-- Allow manual continue by clicking button (or BG)
	pause				= true,						-- Pause Game
	imageHeight			= 90,	-- Height of the image - defaults to 6
	imageWidth			= 90,	-- Width of the image - defaults to imageHeight or 6
	imageSpaceHeight	= 39,	-- Total height reserved for the image - defaults to imageHeight or 6.
	hideScriptValue		= 'tutorial3_hint6MoreInfoClosed'
})


tutorialRegisterMessage2({	-- Doesn't support models - let Merc know if that's required.
	event				= 'tutorial3_hint8MoreInfo',				-- Event Name (trigger)
	image				= '/maps/tutorial_3/resources/images/generator-hint.tga',
	title				= 'tutorial3_hint8MoreInfo',				-- Trom interface_en.str
	body				= 'tutorial3_hint8MoreInfo_body',			-- Body, from interface_en.str
	sound				= '/shared/sounds/keepers/draknia/none.wav',
	darkenBG			= true,							-- Show darkened background
	grayscale			= true,								-- Render rest of the game in grayscale
	showContinue		= true,							-- Allow manual continue by clicking button (or BG)
	pause				= true,						-- Pause Game
	imageHeight			= 90,	-- Height of the image - defaults to 6
	imageWidth			= 90,	-- Width of the image - defaults to imageHeight or 6
	imageSpaceHeight	= 39,	-- Total height reserved for the image - defaults to imageHeight or 6.
	hideScriptValue		= 'tutorial3_hint8MoreInfoClosed'
})

tutorialRegisterMessage2({	-- Doesn't support models - let Merc know if that's required.
	event				= 'tutorial3_hint9MoreInfo',				-- Event Name (trigger)
	image				= '/maps/tutorial_3/resources/images/spending-hint.tga',
	title				= 'tutorial3_hint9MoreInfo',				-- Trom interface_en.str
	body				= 'tutorial3_hint9MoreInfo_body',			-- Body, from interface_en.str
	sound				= '/shared/sounds/keepers/draknia/none.wav',
	darkenBG			= true,							-- Show darkened background
	grayscale			= true,								-- Render rest of the game in grayscale
	showContinue		= true,							-- Allow manual continue by clicking button (or BG)
	pause				= true,						-- Pause Game
	imageHeight			= 60,	-- Height of the image - defaults to 6
	imageWidth			= 60,	-- Width of the image - defaults to imageHeight or 6
	imageSpaceHeight	= 15,	-- Total height reserved for the image - defaults to imageHeight or 6.
	hideScriptValue		= 'tutorial3_hint9MoreInfoClosed',
	hotKeyInfo = {	-- Positions to show certain hotkeys. in relation to the image. Requires x, y, content - and an interface with tutorialMessage2HotkeyContainer.
		{x = '12.5h', y = '4.25h', content = GetKeybindButton('game', 'ToggleShop', ''), style="gameTipHotkeyLabel" },
	},
})

tutorialRegisterMessage2({	-- Doesn't support models - let Merc know if that's required.
	event				= 'tutorial3_hint10MoreInfo',				-- Event Name (trigger)
	image				= '/maps/tutorial_3/resources/images/crux-hint.tga',
	title				= 'tutorial3_hint10MoreInfo',				-- Trom interface_en.str
	body				= 'tutorial3_hint10MoreInfo_body',			-- Body, from interface_en.str
	sound				= '/shared/sounds/keepers/draknia/none.wav',
	darkenBG			= true,							-- Show darkened background
	grayscale			= true,								-- Render rest of the game in grayscale
	showContinue		= true,							-- Allow manual continue by clicking button (or BG)
	pause				= true,						-- Pause Game
	imageHeight			= 60,	-- Height of the image - defaults to 6
	imageWidth			= 60,	-- Width of the image - defaults to imageHeight or 6
	imageSpaceHeight	= 50,	-- Total height reserved for the image - defaults to imageHeight or 6.
	hideScriptValue		= 'tutorial3_hint10MoreInfoClosed'
})

tutorialRegisterMessage2({	-- Doesn't support models - let Merc know if that's required.
	event				= 'tutorial3_hint11MoreInfo',				-- Event Name (trigger)
	image				= '/maps/tutorial_3/resources/images/kongor-hint.tga',
	title				= 'tutorial3_hint11MoreInfo',				-- Trom interface_en.str
	body				= 'tutorial3_hint11MoreInfo_body',			-- Body, from interface_en.str
	sound				= '/shared/sounds/keepers/draknia/none.wav',
	darkenBG			= true,							-- Show darkened background
	grayscale			= true,								-- Render rest of the game in grayscale
	showContinue		= true,							-- Allow manual continue by clicking button (or BG)
	pause				= true,						-- Pause Game
	imageHeight			= 50,	-- Height of the image - defaults to 6
	imageWidth			= 50,	-- Width of the image - defaults to imageHeight or 6
	imageSpaceHeight	= 50,	-- Total height reserved for the image - defaults to imageHeight or 6.
	hideScriptValue		= 'tutorial3_hint11MoreInfoClosed'
})

tutorialRegisterMessage2({	-- Doesn't support models - let Merc know if that's required.
	event				= 'tutorial3_hint12MoreInfo',				-- Event Name (trigger)
	image				= '/maps/tutorial_3/resources/images/boots-hint.tga',
	title				= 'tutorial3_hint12MoreInfo',				-- Trom interface_en.str
	body				= 'tutorial3_hint12MoreInfo_body',			-- Body, from interface_en.str
	sound				= '/shared/sounds/keepers/draknia/none.wav',
	darkenBG			= true,							-- Show darkened background
	grayscale			= true,								-- Render rest of the game in grayscale
	showContinue		= true,							-- Allow manual continue by clicking button (or BG)
	pause				= true,						-- Pause Game
	imageHeight			= 40,	-- Height of the image - defaults to 6
	imageWidth			= 40,	-- Width of the image - defaults to imageHeight or 6
	imageSpaceHeight	= 35,	-- Total height reserved for the image - defaults to imageHeight or 6.
	hideScriptValue		= 'tutorial3_hint12MoreInfoClosed',
	hotKeyInfo = {	-- Positions to show certain hotkeys. in relation to the image. Requires x, y, content - and an interface with tutorialMessage2HotkeyContainer.
		{x = '5.5h', y = '6.4h',       content = Translate('game_shop_search'),      style="gameShopSearchCoverLabel"}
	}
})

-- ========================================
-- Forced Hint Details
-- ========================================

tutorialRegisterMessage2({	-- Doesn't support models - let Merc know if that's required.
	event				= 'tutorial3_begin',				-- Event Name (trigger)
	title				= 'tutorial3_begin_title',				-- Trom interface_en.str
	body				= 'tutorial3_begin_body',			-- Body, from interface_en.str
	darkenBG			= true,							-- Show darkened background
	grayscale			= true,								-- Render rest of the game in grayscale
	showContinue		= true,							-- Allow manual continue by clicking button (or BG)
	pause				= true,						-- Pause Game

})


-- ========================================
-- Lex chat messages
-- ========================================

tutorialRegisterChatEvent({
	event					= 'tutorial3_chatMessage1',			-- ClientUITrigger which initiates the message
	message					= 'tutorial3_chatMessage1',			-- In interface_en.str
	sender					= 'tutorial3_chatMessage1Sender',	-- In interface_en.str (name of character sending message)
	entity					= 'Tutorial2_LexiKhan',						-- Entity that the message is coming from (icon populates from this).
	relation				= 1,								-- 1 for team, 2 for enemy, 4 for self.
})

tutorialRegisterChatEvent({
	event					= 'tutorial3_chatMessage2',			-- ClientUITrigger which initiates the message
	message					= 'tutorial3_chatMessage2',			-- In interface_en.str
	sender					= 'tutorial3_chatMessage2Sender',	-- In interface_en.str (name of character sending message)
	entity					= 'Tutorial2_LexiKhan',				-- Entity that the message is coming from (icon populates from this).
	relation				= 1,								-- 1 for team, 2 for enemy, 4 for self.
})

tutorialRegisterChatEvent({
	event					= 'tutorial3_chatMessage3',			-- ClientUITrigger which initiates the message
	message					= 'tutorial3_chatMessage3',			-- In interface_en.str
	sender					= 'tutorial3_chatMessage3Sender',	-- In interface_en.str (name of character sending message)
	entity					= 'Tutorial2_LexiKhan',						-- Entity that the message is coming from (icon populates from this).
	relation				= 1,								-- 1 for team, 2 for enemy, 4 for self.
})

tutorialRegisterChatEvent({
	event					= 'tutorial3_chatMessage4',			-- ClientUITrigger which initiates the message
	message					= 'tutorial3_chatMessage4',			-- In interface_en.str
	sender					= 'tutorial3_chatMessage4Sender',	-- In interface_en.str (name of character sending message)
	entity					= 'Tutorial2_LexiKhan',						-- Entity that the message is coming from (icon populates from this).
	relation				= 1,								-- 1 for team, 2 for enemy, 4 for self.
})

tutorialRegisterChatEvent({
	event					= 'tutorial3_chatMessage5',			-- ClientUITrigger which initiates the message
	message					= 'tutorial3_chatMessage5',			-- In interface_en.str
	sender					= 'tutorial3_chatMessage5Sender',	-- In interface_en.str (name of character sending message)
	entity					= 'Tutorial2_LexiKhan',						-- Entity that the message is coming from (icon populates from this).
	relation				= 1,								-- 1 for team, 2 for enemy, 4 for self.
})

tutorialRegisterChatEvent({
	event					= 'tutorial3_chatMessage6',			-- ClientUITrigger which initiates the message
	message					= 'tutorial3_chatMessage6',			-- In interface_en.str
	sender					= 'tutorial3_chatMessage6Sender',	-- In interface_en.str (name of character sending message)
	entity					= 'Tutorial2_LexiKhan',						-- Entity that the message is coming from (icon populates from this).
	relation				= 1,								-- 1 for team, 2 for enemy, 4 for self.
})

tutorialRegisterChatEvent({
	event					= 'tutorial3_chatMessage7',			-- ClientUITrigger which initiates the message
	message					= 'tutorial3_chatMessage7',			-- In interface_en.str
	sender					= 'tutorial3_chatMessage7Sender',	-- In interface_en.str (name of character sending message)
	entity					= 'Tutorial2_LexiKhan',						-- Entity that the message is coming from (icon populates from this).
	relation				= 1,								-- 1 for team, 2 for enemy, 4 for self.
})

tutorialRegisterChatEvent({
	event					= 'tutorial3_chatMessage8',			-- ClientUITrigger which initiates the message
	message					= 'tutorial3_chatMessage8',			-- In interface_en.str
	sender					= 'tutorial3_chatMessage8Sender',	-- In interface_en.str (name of character sending message)
	entity					= 'Tutorial2_LexiKhan',						-- Entity that the message is coming from (icon populates from this).
	relation				= 1,								-- 1 for team, 2 for enemy, 4 for self.
})

tutorialRegisterChatEvent({
	event					= 'tutorial3_chatMessage9',			-- ClientUITrigger which initiates the message
	message					= 'tutorial3_chatMessage9',			-- In interface_en.str
	sender					= 'tutorial3_chatMessage9Sender',	-- In interface_en.str (name of character sending message)
	entity					= 'Tutorial2_LexiKhan',						-- Entity that the message is coming from (icon populates from this).
	relation				= 1,								-- 1 for team, 2 for enemy, 4 for self.
})

tutorialRegisterChatEvent({
	event					= 'tutorial3_chatMessage10',			-- ClientUITrigger which initiates the message
	message					= 'tutorial3_chatMessage10',			-- In interface_en.str
	sender					= 'tutorial3_chatMessage10Sender',	-- In interface_en.str (name of character sending message)
	entity					= 'Tutorial2_LexiKhan',						-- Entity that the message is coming from (icon populates from this).
	relation				= 1,								-- 1 for team, 2 for enemy, 4 for self.
})

tutorialRegisterChatEvent({
	event					= 'tutorial3_chatMessage11',			-- ClientUITrigger which initiates the message
	message					= 'tutorial3_chatMessage11',			-- In interface_en.str
	sender					= 'tutorial3_chatMessage11Sender',	-- In interface_en.str (name of character sending message)
	entity					= 'Tutorial2_LexiKhan',						-- Entity that the message is coming from (icon populates from this).
	relation				= 1,								-- 1 for team, 2 for enemy, 4 for self.
})

tutorialReinitialize(object)