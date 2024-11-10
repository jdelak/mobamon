-- Tutorial Config

shopForcedCategoryItems = {
	ability		= {
		'Item_Gauntlet',
	},
	['crafted+itembuild']	= {
		'Item_Gauntlet',
		'Item_PowerBoots',
		'Item_FellBlade',
		'Item_Supercharger',
		'Item_MaxManaPower',
		'Item_Malevolence',
		'Item_Soulstealer',
	}
}

--Objective 1

tutorialRegisterMessage({
	event			= 'tutorial2_dialogue0',				-- Event Name (trigger)
	icon			= '/maps/tutorial_2/resources/heroes/lexikhan/icon.tga',
	title			= 'tutorial2_dialogue0',				-- Trom interface_en.str
	body			= 'tutorial2_dialogue0_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_khan_1.ogg',
	model			= 'tutorialMessageModelLexikhan',
	anim			= 'vo_khan_1',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 7000
})

tutorialRegisterMessage({
	event			= 'tutorial2_dialogue0b',				-- Event Name (trigger)
	icon			= '/heroes/caprice/icon.tga',
	title			= 'tutorial2_dialogue0b',				-- Trom interface_en.str
	body			= 'tutorial2_dialogue0b_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_caprice_1.ogg',
	anim			= 'tutorial_1_1b',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 4000
})

tutorialRegisterMessage({
	event			= 'tutorial2_dialogue1',				-- Event Name (trigger)
	icon			= '/maps/tutorial_2/resources/heroes/lexikhan/icon.tga',
	title			= 'tutorial2_dialogue1',				-- Trom interface_en.str
	body			= 'tutorial2_dialogue1_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_khan_2.ogg',
	model			= 'tutorialMessageModelLexikhan',
	anim			= 'vo_khan_2',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 17000
})

tutorialRegisterMessage({
	event			= 'tutorial2_dialogue1b',				-- Event Name (trigger)
	icon			= '/maps/tutorial_2/resources/heroes/lexikhan/icon.tga',
	title			= 'tutorial2_dialogue1b',				-- Trom interface_en.str
	body			= 'tutorial2_dialogue1b_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_khan_2.ogg',
	model			= 'tutorialMessageModelLexikhan',
	anim			= 'vo_khan_2',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 7000
})

tutorialRegisterMessage({
	event			= 'tutorial2_dialogue2',				-- Event Name (trigger)
	icon			= '/maps/tutorial_2/resources/heroes/lexikhan/icon.tga',
	title			= 'tutorial2_dialogue2',				-- Trom interface_en.str
	body			= 'tutorial2_dialogue2_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_khan_3.ogg',
	model			= 'tutorialMessageModelLexikhan',
	anim			= 'vo_khan_3',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 3000
})

tutorialRegisterMessage({
	event			= 'tutorial2_dialogue2b',				-- Event Name (trigger)
	icon			= '/maps/tutorial_2/resources/heroes/lexikhan/icon.tga',
	title			= 'tutorial2_dialogue2b',				-- Trom interface_en.str
	body			= 'tutorial2_dialogue2b_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_khan_4.ogg',
	model			= 'tutorialMessageModelLexikhan',
	anim			= 'vo_khan_4',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 7000
})

tutorialRegisterTip({
	event			= 'tutorial2_tip1',				-- Event Name (trigger)
	body			= 'tutorial2_tip1_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial2_tip1Hide',
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_announcer_16.wav',
	hotkey1Action	= 'ToggleShop',
	hotkey1Param	= ''
})

tutorialRegisterTip({
	event			= 'tutorial2_tip2',				-- Event Name (trigger)
	body			= 'tutorial2_tip2_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial2_tip2Hide',
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_announcer_1.wav'
})

tutorialRegisterTip({
	event			= 'tutorial2_tip3',				-- Event Name (trigger)
	body			= 'tutorial2_tip3_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial2_tip3Hide',
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_announcer_2.wav'
})

tutorialRegisterTip({
	event			= 'tutorial2_tip4',				-- Event Name (trigger)
	body			= 'tutorial2_tip4_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial2_tip4Hide',
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_announcer_4.wav',
	showTime		= 8000
})

tutorialRegisterTip({
	event			= 'tutorial2_tip5',				-- Event Name (trigger)
	body			= 'tutorial2_tip5_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial2_tip5Hide',
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_announcer_3.wav'
})

--[[
tutorialRegisterMessage({
	event			= 'tutorial_objective1MoreInfo',				-- Event Name (trigger)
	icon			= '/heroes/ace/icon.tga',
	title			= 'tutorial_objective1MoreInfo',				-- Trom interface_en.str
	body			= 'tutorial_objective1MoreInfo_body',			-- Body, from interface_en.str
	sound			= '/shared/sounds/keepers/draknia/none.wav',
	darkenBG		= true,							-- Show darkened background
	grayscale		= true,								-- Render rest of the game in grayscale
	showContinue	= true,							-- Allow manual continue by clicking button (or BG)
	pause			= true						-- Pause Game
})
--]]

--Objective 2

tutorialRegisterMessage({
	event			= 'tutorial2_dialogue3',				-- Event Name (trigger)
	icon			= '/heroes/caprice/icon.tga',
	title			= 'tutorial2_dialogue3',				-- Trom interface_en.str
	body			= 'tutorial2_dialogue3_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_caprice_2.ogg',
	model			= 'tutorialMessageModelCaprice',
	anim			= '2ndtutorial_2',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 5000
})

tutorialRegisterMessage({
	event			= 'tutorial2_dialogue3b',				-- Event Name (trigger)
	icon			= '/maps/tutorial_2/resources/heroes/lexikhan/icon.tga',
	title			= 'tutorial2_dialogue3b',				-- Trom interface_en.str
	body			= 'tutorial2_dialogue3b_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_khan_6.ogg',
	model			= 'tutorialMessageModelLexikhan',
	anim			= 'vo_khan_6',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 9000
})

tutorialRegisterMessage({
	event			= 'tutorial2_dialogue4',				-- Event Name (trigger)
	icon			= '/maps/tutorial_2/resources/heroes/lexikhan/icon.tga',
	title			= 'tutorial2_dialogue4',				-- Trom interface_en.str
	body			= 'tutorial2_dialogue4_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_khan_5.ogg',
	model			= 'tutorialMessageModelLexikhan',
	anim			= 'vo_khan_5',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 4000
})

tutorialRegisterTip({
	event			= 'tutorial2_tip6',				-- Event Name (trigger)
	body			= 'tutorial2_tip6_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial2_tip6Hide',
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_announcer_6.ogg'
})

tutorialRegisterTip({
	event			= 'tutorial2_tip6a',				-- Event Name (trigger)
	body			= 'tutorial2_tip6a_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial2_tip6aHide',
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_announcer_5.ogg',
	hotkey1Action	= 'ToggleShop',
	hotkey1Param	= ''
})

tutorialRegisterTip({
	event			= 'tutorial2_tip7',				-- Event Name (trigger)
	body			= 'tutorial2_tip7_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial2_tip7Hide',
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_announcer_7.ogg'
})

tutorialRegisterTip({
	event			= 'tutorial2_tip7a',				-- Event Name (trigger)
	body			= 'tutorial2_tip7a_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial2_tip7aHide',
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_announcer_8.ogg'
})

tutorialRegisterTip({
	event			= 'tutorial2_tip7b',				-- Event Name (trigger)
	body			= 'tutorial2_tip7b_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial2_tip7bHide',
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_announcer_9.ogg'
})

tutorialRegisterTip({
	event			= 'tutorial2_tip7c',				-- Event Name (trigger)
	body			= 'tutorial2_tip7c_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial2_tip7cHide',
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_announcer_10.ogg'
})

tutorialRegisterMessage({
	event			= 'tutorial2_dialogue5',				-- Event Name (trigger)
	icon			= '/maps/tutorial_2/resources/heroes/lexikhan/icon.tga',
	title			= 'tutorial2_dialogue5',				-- Trom interface_en.str
	body			= 'tutorial2_dialogue5_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_khan_6.ogg',
	model			= 'tutorialMessageModelLexikhan',
	anim			= 'vo_khan_6',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 11000
})

tutorialRegisterTip({
	event			= 'tutorial2_tip8',				-- Event Name (trigger)
	body			= 'tutorial2_tip8_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial2_tip8Hide',
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_announcer_11.ogg'
})

tutorialRegisterTip({
	event			= 'tutorial2_tip8b',				-- Event Name (trigger)
	body			= 'tutorial2_tip8b_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial2_tip8bHide',
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_announcer_12.ogg'
})

tutorialRegisterTip({
	event			= 'tutorial2_tip9',				-- Event Name (trigger)
	body			= 'tutorial2_tip9_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial2_tip9Hide',
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_announcer_13.ogg'
})

tutorialRegisterTip({
	event			= 'tutorial2_tip10',				-- Event Name (trigger)
	body			= 'tutorial2_tip10_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial2_tip10Hide',
	--sound			= '/maps/tutorial/resources/sounds/voice/vo_announcer_2.wav'
})

tutorialRegisterMessage({
	event			= 'tutorial2_dialogue8',				-- Event Name (trigger)
	icon			= '/heroes/caprice/icon.tga',
	title			= 'tutorial2_dialogue8',				-- Trom interface_en.str
	body			= 'tutorial2_dialogue8_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_caprice_3.wav',
	model			= 'tutorialMessageModelCaprice',
	anim			= '2ndtutorial_3',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 6000
})

tutorialRegisterMessage({
	event			= 'tutorial2_dialogue9',				-- Event Name (trigger)
	icon			= '/maps/tutorial_2/resources/heroes/lexikhan/icon.tga',
	title			= 'tutorial2_dialogue9',				-- Trom interface_en.str
	body			= 'tutorial2_dialogue9_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_khan_7.ogg',
	model			= 'tutorialMessageModelLexikhan',
	anim			= 'vo_khan_7',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 7000
})

tutorialRegisterMessage({
	event			= 'tutorial2_dialogue9b',				-- Event Name (trigger)
	icon			= '/maps/tutorial_2/resources/heroes/lexikhan/icon.tga',
	title			= 'tutorial2_dialogue9b',				-- Trom interface_en.str
	body			= 'tutorial2_dialogue9b_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_khan_8.ogg',
	model			= 'tutorialMessageModelLexikhan',
	anim			= 'vo_khan_8',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 5000
})

tutorialRegisterMessage({
	event			= 'tutorial2_dialogue10',				-- Event Name (trigger)
	icon			= '/npcs/cindara/icon.tga',
	title			= 'tutorial2_dialogue10',				-- Trom interface_en.str
	body			= 'tutorial2_dialogue10_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_cindara_1.wav',
	model			= 'tutorialMessageModelCindara',
	anim			= 'vo_cindara_1',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 8000
})

tutorialRegisterMessage({
	event			= 'tutorial2_dialogue10c',				-- Event Name (trigger)
	icon			= '/heroes/caprice/icon.tga',
	title			= 'tutorial2_dialogue10c',				-- Trom interface_en.str
	body			= 'tutorial2_dialogue10c_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_caprice_4.wav',
	model			= 'tutorialMessageModelCaprice',
	anim			= '2ndtutorial_4',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 2000
})

tutorialRegisterMessage({
	event			= 'tutorial2_dialogue10d',				-- Event Name (trigger)
	icon			= '/maps/tutorial_2/resources/heroes/lexikhan/icon.tga',
	title			= 'tutorial2_dialogue10d',				-- Trom interface_en.str
	body			= 'tutorial2_dialogue10d_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_khan_9.ogg',
	model			= 'tutorialMessageModelLexikhan',
	anim			= 'vo_khan_9',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 2000
})

tutorialRegisterMessage({
	event			= 'tutorial2_dialogue10e',				-- Event Name (trigger)
	icon			= '/npcs/cindara/icon.tga',
	title			= 'tutorial2_dialogue10e',				-- Trom interface_en.str
	body			= 'tutorial2_dialogue10e_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_cindara_2.wav',
	model			= 'tutorialMessageModelCindara',
	anim			= 'vo_cindara_2',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 7000
})

tutorialRegisterMessage({
	event			= 'tutorial2_dialogue10f',				-- Event Name (trigger)
	icon			= '/heroes/caprice/icon.tga',
	title			= 'tutorial2_dialogue10f',				-- Trom interface_en.str
	body			= 'tutorial2_dialogue10f_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_caprice_5.wav',
	model			= 'tutorialMessageModelCaprice',
	anim			= '2ndtutorial_5',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 6000
})

tutorialRegisterMessage({
	event			= 'tutorial2_dialogue10g',				-- Event Name (trigger)
	icon			= '/maps/tutorial_2/resources/heroes/lexikhan/icon.tga',
	title			= 'tutorial2_dialogue10g',				-- Trom interface_en.str
	body			= 'tutorial2_dialogue10g_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_khan_10.ogg',
	model			= 'tutorialMessageModelLexikhan',
	anim			= 'vo_khan_10',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 3000
})

tutorialRegisterTip({
	event			= 'tutorial2_tip11',				-- Event Name (trigger)
	body			= 'tutorial2_tip11_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial2_tip11Hide',
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_announcer_14.ogg',
	hotkey1Action	= 'ActivateTool',
	hotkey1Param	= 8
})

tutorialRegisterTip({
	event			= 'tutorial2_tip11a',				-- Event Name (trigger)
	body			= 'tutorial2_tip11a_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial2_tip11aHide',
	sound			= '/maps/tutorial/resources/sounds/voice/vo_announcer_41.wav'
})

tutorialRegisterTip({
	event			= 'tutorial2_tip11b',				-- Event Name (trigger)
	body			= 'tutorial2_tip11b_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial2_tip11bHide',
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_announcer_15.ogg'
})

tutorialRegisterTip({
	event			= 'tutorial2_tip11c',				-- Event Name (trigger)
	body			= 'tutorial2_tip11c_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial2_tip11cHide',
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_announcer_16.ogg'
})

tutorialRegisterMessage({
	event			= 'tutorial2_dialogue11',				-- Event Name (trigger)
	icon			= '/maps/tutorial_2/resources/heroes/lexikhan/icon.tga',
	title			= 'tutorial2_dialogue11',				-- Trom interface_en.str
	body			= 'tutorial2_dialogue11_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_khan_11.ogg',
	model			= 'tutorialMessageModelLexikhan',
	anim			= 'vo_khan_11',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 10000
})

tutorialRegisterTip({
	event			= 'tutorial2_tip12',				-- Event Name (trigger)
	body			= 'tutorial2_tip12_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial2_tip12Hide',
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_announcer_17.ogg',
	showTime		= 8000
})

tutorialRegisterTip({
	event			= 'tutorial2_tip12b',				-- Event Name (trigger)
	body			= 'tutorial2_tip12b_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial2_tip12bHide',
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_announcer_21.wav'
	
})

tutorialRegisterTip({
	event			= 'tutorial2_tip12c',				-- Event Name (trigger)
	body			= 'tutorial2_tip12c_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial2_tip12cHide',
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_announcer_23.wav',
	showTime		= 8000
})

tutorialRegisterTip({
	event			= 'tutorial2_tip12d',				-- Event Name (trigger)
	body			= 'tutorial2_tip12d_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial2_tip12dHide',
	showTime		= 8000
})

tutorialRegisterTip({
	event			= 'tutorial2_tip12e',				-- Event Name (trigger)
	body			= 'tutorial2_tip12e_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial2_tip12eHide',
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_announcer_28.wav',
	showTime		= 8000
})

tutorialRegisterTip({
	event			= 'tutorial2_tip12f',				-- Event Name (trigger)
	body			= 'tutorial2_tip12f_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial2_tip12fHide',
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_announcer_29.wav',
	showTime		= 6500
})

tutorialRegisterTip({
	event			= 'tutorial2_tip12g',				-- Event Name (trigger)
	body			= 'tutorial2_tip12g_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_announcer_22.wav',
	hideTipEvent	= 'tutorial2_tip12gHide'
})

tutorialRegisterTip({
	event			= 'tutorial2_tip12h',				-- Event Name (trigger)
	body			= 'tutorial2_tip12h_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial2_tip12hHide',
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_announcer_31.wav'
})

tutorialRegisterTip({
	event			= 'tutorial2_tip13',				-- Event Name (trigger)
	body			= 'tutorial2_tip13_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial2_tip13Hide',
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_announcer_18.ogg',
	showTime		= 8000
})

tutorialRegisterTip({
	event			= 'tutorial2_tip14',				-- Event Name (trigger)
	body			= 'tutorial2_tip14_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial2_tip14Hide',
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_announcer_19.ogg',
	showTime		= 8000
})

tutorialRegisterMessage({
	event			= 'tutorial2_dialogue12',				-- Event Name (trigger)
	icon			= '/maps/tutorial_2/resources/heroes/lexikhan/icon.tga',
	title			= 'tutorial2_dialogue12',				-- Trom interface_en.str
	body			= 'tutorial2_dialogue12_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_khan_12.ogg',
	model			= 'tutorialMessageModelLexikhan',
	anim			= 'vo_khan_12',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 3000
})

tutorialRegisterMessage({
	event			= 'tutorial2_dialogue13',				-- Event Name (trigger)
	icon			= '/maps/tutorial_2/resources/heroes/lexikhan/icon.tga',
	title			= 'tutorial2_dialogue13',				-- Trom interface_en.str
	body			= 'tutorial2_dialogue13_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_khan_13.ogg',
	model			= 'tutorialMessageModelLexikhan',
	anim			= 'vo_khan_13',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 5000
})

tutorialRegisterMessage({
	event			= 'tutorial2_dialogue14',				-- Event Name (trigger)
	icon			= '/heroes/caprice/icon.tga',
	title			= 'tutorial2_dialogue14',				-- Trom interface_en.str
	body			= 'tutorial2_dialogue14_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_caprice_6.wav',
	model			= 'tutorialMessageModelCaprice',
	anim			= '2ndtutorial_6',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 3000
})

tutorialRegisterMessage({
	event			= 'tutorial2_dialogue15',				-- Event Name (trigger)
	icon			= '/maps/tutorial_2/resources/heroes/lexikhan/icon.tga',
	title			= 'tutorial2_dialogue15',				-- Trom interface_en.str
	body			= 'tutorial2_dialogue15_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_khan_14.ogg',
	model			= 'tutorialMessageModelLexikhan',
	anim			= 'vo_khan_14',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 8000
})

tutorialRegisterMessage({
	event			= 'tutorial2_dialogue16',				-- Event Name (trigger)
	icon			= '/maps/tutorial_2/resources/heroes/lexikhan/icon.tga',
	title			= 'tutorial2_dialogue16',				-- Trom interface_en.str
	body			= 'tutorial2_dialogue16_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_khan_15.ogg',
	model			= 'tutorialMessageModelLexikhan',
	anim			= 'vo_khan_15',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 4000
})

tutorialRegisterMessage({
	event			= 'tutorial2_dialogue17',				-- Event Name (trigger)
	icon			= '/maps/tutorial_2/resources/heroes/flaskblack/icon.tga',
	title			= 'tutorial2_dialogue17',				-- Trom interface_en.str
	body			= 'tutorial2_dialogue17_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_flaskblack.wav',
	model			= 'tutorialMessageModelAlchemist',
	anim			= 'vo_flaskblack',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 15000
})

tutorialRegisterMessage({
	event			= 'tutorial2_dialogue18',				-- Event Name (trigger)
	icon			= '/maps/tutorial_2/resources/heroes/lexikhan/icon.tga',
	title			= 'tutorial2_dialogue18',				-- Trom interface_en.str
	body			= 'tutorial2_dialogue18_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_khan_16.ogg',
	model			= 'tutorialMessageModelLexikhan',
	anim			= 'vo_khan_16',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 6000
})

tutorialRegisterMessage({
	event			= 'tutorial2_dialogue19',				-- Event Name (trigger)
	icon			= '/heroes/caprice/icon.tga',
	title			= 'tutorial2_dialogue19',				-- Trom interface_en.str
	body			= 'tutorial2_dialogue19_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_caprice_7.wav',
	model			= 'tutorialMessageModelCaprice',
	anim			= '2ndtutorial_7',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 3000
})

tutorialRegisterMessage({
	event			= 'tutorial2_dialogue20',				-- Event Name (trigger)
	icon			= '/maps/tutorial_2/resources/heroes/auros/icon.tga',
	title			= 'tutorial2_dialogue20',				-- Trom interface_en.str
	body			= 'tutorial2_dialogue20_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_auros_1.wav',
	model			= 'tutorialMessageModelAuros',
	anim			= 'vo_auros_1',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 6000
})

tutorialRegisterMessage({
	event			= 'tutorial2_dialogue21',				-- Event Name (trigger)
	icon			= '/maps/tutorial_2/resources/heroes/lexikhan/icon.tga',
	title			= 'tutorial2_dialogue21',				-- Trom interface_en.str
	body			= 'tutorial2_dialogue21_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_khan_17.ogg',
	model			= 'tutorialMessageModelLexikhan',
	anim			= 'vo_khan_17',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 13000
})

tutorialRegisterTip({
	event			= 'tutorial2_tip_death',				-- Event Name (trigger)
	body			= 'tutorial_tip_death_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial_tip_death_Hide',
	sound			= '/maps/tutorial/resources/sounds/voice/vo_announcer_37.wav',
	showTime		= 3500
})

tutorialRegisterTip({	-- Doesn't support models - let Merc know if that's required.
	event			= 'tutorial2_tip_toweraggro',				-- Event Name (trigger)
	body			= 'tutorial2_tip_toweraggro_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial2_tip_toweraggro_Hide',
	sound			= '/maps/tutorial/resources/sounds/voice/vo_announcer_38.wav',
	showTime		= 10000
})

tutorialRegisterTip({	-- Doesn't support models - let Merc know if that's required.
	event			= 'tutorial2_tip_attackhero',				-- Event Name (trigger)
	body			= 'tutorial2_tip_attackhero_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial2_tip_attackhero_Hide',
	sound			= '/maps/tutorial/resources/sounds/voice/vo_announcer_34.wav',
	showTime		= 10000
})

tutorialRegisterMessage2({	-- Doesn't support models - let Merc know if that's required.
	event				= 'tutorial_tip_start',				-- Event Name (trigger)
	title				= 'tutorial_tip_start_title',				-- Trom interface_en.str
	body				= 'tutorial_tip_start_body',			-- Body, from interface_en.str
	darkenBG			= true,							-- Show darkened background
	grayscale			= true,								-- Render rest of the game in grayscale
	showContinue		= true,							-- Allow manual continue by clicking button (or BG)
	pause				= true,						-- Pause Game
	imageHeight			= 0,	-- Height of the image - defaults to 6
	imageWidth			= 0,	-- Width of the image - defaults to imageHeight or 6
	imageSpaceHeight	= 0	-- Total height reserved for the image - defaults to imageHeight or 6.
})

-- ========================================
-- Announcer Sounds
-- ========================================

tutorialRegisterSound({
	event			= 'tutorial2_sound_21',				-- Event Name (trigger)
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_announcer_21.wav'
})

tutorialRegisterSound({
	event			= 'tutorial2_sound_22',				-- Event Name (trigger)
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_announcer_22.wav'
})

tutorialRegisterSound({
	event			= 'tutorial2_sound_23',				-- Event Name (trigger)
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_announcer_23.wav'
})

tutorialRegisterSound({
	event			= 'tutorial2_sound_24',				-- Event Name (trigger)
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_announcer_24.wav'
})

tutorialRegisterSound({
	event			= 'tutorial2_sound_25',				-- Event Name (trigger)
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_announcer_25.wav'
})

tutorialRegisterSound({
	event			= 'tutorial2_sound_26',				-- Event Name (trigger)
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_announcer_26.wav'
})

tutorialRegisterSound({
	event			= 'tutorial2_sound_27',				-- Event Name (trigger)
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_announcer_27.wav'
})

tutorialRegisterSound({
	event			= 'tutorial2_sound_28',				-- Event Name (trigger)
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_announcer_28.wav'
})

tutorialRegisterSound({
	event			= 'tutorial2_sound_29',				-- Event Name (trigger)
	sound			= '/maps/tutorial_2/resources/sounds/voice/vo_announcer_29.wav'
})

-- ========================================
-- Stuff for highlighting inventory slots by index
-- ========================================

tutorial_registerPointAtInventory(0)
tutorial_registerSpotlightInventory(0)
tutorial_registerDarkenInventory(0)

tutorial_registerPointAtInventory(8)
tutorial_registerSpotlightInventory(8)
tutorial_registerDarkenInventory(8)

tutorial_registerPointAtInventory(11)
tutorial_registerSpotlightInventory(11)
tutorial_registerDarkenInventory(11)

tutorial_registerPointAtInventory(11, 'B')
tutorial_registerSpotlightInventory(11, 'B')
tutorial_registerDarkenInventory(11, 'B')

tutorial_registerPointAtInventory(96)
tutorial_registerSpotlightInventory(96)
tutorial_registerDarkenInventory(96)

-- ========================================
-- Stuff for highlighting shop items by entity
-- ========================================

tutorial_registerPointAtShopEntity('Item_Gauntlet')
tutorial_registerSpotlightShopEntity('Item_Gauntlet')
tutorial_registerDarkenShopEntity('Item_Gauntlet')

tutorial_registerForceOpenEntity('Item_Gauntlet')

-- ========================================
-- Sample objective stuff
-- ========================================

tutorialRegisterObjective({
	showEvent				= 'tutorial_objective1',
	completionEvent			= 'tutorial_objective1Complete',	-- Will increment the completion count and will clear the objective once completion is maxed.
	completionCount			= 3,		-- How many times must this be completed?, defaults to 1
	label					= 'tutorial_objective1',
	extraInfo				= 'tutorial_objective1MoreInfo',			-- Click the "more info" question mark button to trigger this event (can be linked back to a message or popup)
	pingScriptValue			= 'tutorial_objective1ScriptValue'			-- Value to set to 1 when the ping map button is clicked
})

tutorialRegisterObjective({
	showEvent				= 'tutorial_objective2',
	completionEvent			= 'tutorial_objective2Complete',	-- Will increment the completion count and will clear the objective once completion is maxed.
	completionCount			= 2,		-- How many times must this be completed?, defaults to 1
	label					= 'tutorial_objective2',
	extraInfo				= 'tutorial_objective2MoreInfo',			-- Click the "more info" question mark button to trigger this event (can be linked back to a message or popup)
	pingScriptValue			= 'tutorial_objective2ScriptValue',			-- Value to set to 1 when the ping map button is clicked
	objectiveContainer		= 'tutorialSecondaryObjectives',
	objectiveList			= 'tutorialSecondaryObjectiveList'
})


-- ========================================
-- Sample new type of message
-- ========================================

tutorialRegisterMessage2({	-- Doesn't support models - let Merc know if that's required.
	event				= 'tutorial_objective1MoreInfo',				-- Event Name (trigger)
	image				= '/heroes/ace/icon.tga',
	title				= 'tutorial_objective1MoreInfo',				-- Trom interface_en.str
	body				= 'tutorial_objective1MoreInfo_body',			-- Body, from interface_en.str
	sound				= '/shared/sounds/keepers/draknia/none.wav',
	darkenBG			= true,							-- Show darkened background
	grayscale			= true,								-- Render rest of the game in grayscale
	showContinue		= true,							-- Allow manual continue by clicking button (or BG)
	pause				= true,						-- Pause Game
	imageHeight			= 16,	-- Height of the image - defaults to 6
	imageWidth			= 16,	-- Width of the image - defaults to imageHeight or 6
	imageSpaceHeight	= 24	-- Total height reserved for the image - defaults to imageHeight or 6.
})

tutorialReinitialize(object)

if (libGameAnalytics) and (libGameAnalytics.registerUITriggerCreate) then
	libGameAnalytics:registerUITriggerCreate(object:GetWidget("tutorialwtfdoesthisdo"), "tutorial_finishMap2", "tutorial_finishMap2", "tutorial_finishMap2", 1)
end
