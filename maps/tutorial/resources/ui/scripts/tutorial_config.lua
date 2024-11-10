-- Tutorial Config

shopForcedCategoryItems = {
	boots		= {
		'Item_TeleportBoots',
	},
	ability		= {
		'Item_FellBlade',
		'Item_Spellblade',
		'Item_Gauntlet',
	}
}

--Objective 1

tutorialRegisterMessage({
	event			= 'tutorial_dialogue0',				-- Event Name (trigger)
	icon			= '/heroes/caprice/icon.tga',
	title			= 'tutorial_dialogue0',				-- Trom interface_en.str
	body			= 'tutorial_dialogue0_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_caprice_1_1a.wav',
	model			= 'tutorialMessageModelCaprice',
	anim			= 'tutorial_1_1a',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 9000
})

tutorialRegisterMessage({
	event			= 'tutorial_dialogue0b',				-- Event Name (trigger)
	icon			= '/heroes/caprice/icon.tga',
	title			= 'tutorial_dialogue0b',				-- Trom interface_en.str
	body			= 'tutorial_dialogue0b_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_caprice_1_1b.wav',
	model			= 'tutorialMessageModelCaprice',
	anim			= 'tutorial_1_1b',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 9000
})

tutorialRegisterMessage({
	event			= 'tutorial_dialogue1',				-- Event Name (trigger)
	icon			= '/heroes/caprice/icon.tga',
	title			= 'tutorial_dialogue1',				-- Trom interface_en.str
	body			= 'tutorial_dialogue1_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_caprice_1_3.wav',
	model			= 'tutorialMessageModelCaprice',
	anim			= 'tutorial_1_2',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 4800
})

tutorialRegisterMessage({
	event			= 'tutorial_dialogue2',				-- Event Name (trigger)
	icon			= '/heroes/caprice/icon.tga',
	title			= 'tutorial_dialogue2',				-- Trom interface_en.str
	body			= 'tutorial_dialogue2_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_caprice_2.wav',
	model			= 'tutorialMessageModelCaprice',
	anim			= 'tutorial_2',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 3000
})

tutorialRegisterTip({
	event			= 'tutorial_tip1',				-- Event Name (trigger)
	body			= 'tutorial_tip1_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial_tip1Hide',
	sound			= '/maps/tutorial/resources/sounds/voice/vo_announcer_1.wav',
})

tutorialRegisterTip({
	event			= 'tutorial_tip1b',				-- Event Name (trigger)
	body			= 'tutorial_tip1b_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial_tip1bHide',
	sound			= '/maps/tutorial/resources/sounds/voice/vo_announcer_39.wav',
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
	event			= 'tutorial_dialogue3',				-- Event Name (trigger)
	icon			= '/heroes/caprice/icon.tga',
	title			= 'tutorial_dialogue3',				-- Trom interface_en.str
	body			= 'tutorial_dialogue3_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_caprice_3.wav',
	model			= 'tutorialMessageModelCaprice',
	anim			= 'tutorial_3',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 6000
})

tutorialRegisterMessage({
	event			= 'tutorial_dialogue4',				-- Event Name (trigger)
	icon			= '/heroes/caprice/icon.tga',
	title			= 'tutorial_dialogue4',				-- Trom interface_en.str
	body			= 'tutorial_dialogue4_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_caprice_4.wav',
	model			= 'tutorialMessageModelCaprice',
	anim			= 'tutorial_4',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 4000
})

tutorialRegisterTip({
	event			= 'tutorial_tip2',				-- Event Name (trigger)
	body			= 'tutorial_tip2_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial_tip2Hide',
	sound			= '/maps/tutorial/resources/sounds/voice/vo_announcer_2.wav'
})


-- Objective 3

tutorialRegisterMessage({
	event			= 'tutorial_dialogue5',				-- Event Name (trigger)
	icon			= '/heroes/caprice/icon.tga',
	title			= 'tutorial_dialogue5',				-- Trom interface_en.str
	body			= 'tutorial_dialogue5_body',			-- Body, from interface_en.str
	sound			= '/shared/sounds/keepers/draknia/none.wav',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	showTime		= 7000
})

tutorialRegisterMessage({
	event			= 'tutorial_dialogue5a',				-- Event Name (trigger)
	icon			= '/heroes/caprice/icon.tga',
	title			= 'tutorial_dialogue5a',				-- Trom interface_en.str
	body			= 'tutorial_dialogue5a_body',			-- Body, from interface_en.str
	sound			= '/shared/sounds/keepers/draknia/none.wav',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	showTime		= 3000
})

tutorialRegisterMessage({
	event			= 'tutorial_dialogue6',				-- Event Name (trigger)
	icon			= '/heroes/caprice/icon.tga',
	title			= 'tutorial_dialogue6',				-- Trom interface_en.str
	body			= 'tutorial_dialogue6_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_caprice_5.wav',
	model			= 'tutorialMessageModelCaprice',
	anim			= 'tutorial_5',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 6000,
})

tutorialRegisterMessage({
	event			= 'tutorial_dialogue6a',				-- Event Name (trigger)
	icon			= '/heroes/caprice/icon.tga',
	title			= 'tutorial_dialogue6a',				-- Trom interface_en.str
	body			= 'tutorial_dialogue6a_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_caprice_6.wav',
	model			= 'tutorialMessageModelCaprice',
	anim			= 'tutorial_6',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	showTime		= 4000,
	forceHeight		= 16,								-- Forces the message to be a minimum height of 8h.
	-- modelScale		= 1,
	-- modelAngles		= {1,1,1},
	-- modelPosition	= {1,1,1},
	--[[
		cameraPos		= {1,1,1},
		cameraAngles	= {1,1,1},
		cameraFov		= 90,
		cameraNear		= 0,
		cameraFar		= 180,
		sunAzimuth		= 180,
		sunAltitude		= 180,
		sunColor		= {1,1,1},
		ambientColor	= {1,1,1},
		lookAt			= false
	--]]
})

tutorialRegisterTip({
	event			= 'tutorial_tip2a',				-- Event Name (trigger)
	body			= 'tutorial_tip2a_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial_tip2aHide',
	sound			= '/maps/tutorial/resources/sounds/voice/vo_announcer_3.wav'
})

tutorialRegisterTip({
	event			= 'tutorial_tip2b',				-- Event Name (trigger)
	body			= 'tutorial_tip2b_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial_tip2bHide',
	sound			= '/maps/tutorial/resources/sounds/voice/vo_announcer_4.wav'
})

tutorialRegisterTip({
	event			= 'tutorial_tip3',				-- Event Name (trigger)
	body			= 'tutorial_tip3_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial_tip3Hide',
	sound			= '/maps/tutorial/resources/sounds/voice/vo_announcer_5.wav'
})

tutorialRegisterTip({
	event			= 'tutorial_tip3a',				-- Event Name (trigger)
	body			= 'tutorial_tip3a_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial_tip3aHide',
	sound			= '/maps/tutorial/resources/sounds/voice/vo_announcer_6.wav'
})

tutorialRegisterTip({
	event			= 'tutorial_tip4',				-- Event Name (trigger)
	body			= 'tutorial_tip4_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial_tip4Hide',
	sound			= '/maps/tutorial/resources/sounds/voice/vo_announcer_10.wav',
	hotkey1Action	= 'ActivateTool',
	hotkey1Param	= 0
})

tutorialRegisterTip({
	event			= 'tutorial_tip4a',				-- Event Name (trigger)
	body			= 'tutorial_tip4a_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial_tip4aHide',
	sound			= '/maps/tutorial/resources/sounds/voice/vo_announcer_7.wav',
	showTime		= 7000
})

-- Objective 4

tutorialRegisterMessage({
	event			= 'tutorial_dialogue7',				-- Event Name (trigger)
	icon			= '/heroes/caprice/icon.tga',
	title			= 'tutorial_dialogue7',				-- Trom interface_en.str
	body			= 'tutorial_dialogue7_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_caprice_12_1.wav',
	model			= 'tutorialMessageModelCaprice',
	anim			= 'tutorial_12_1',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 5500
})

tutorialRegisterMessage({
	event			= 'tutorial_dialogue8',				-- Event Name (trigger)
	icon			= '/heroes/caprice/icon.tga',
	title			= 'tutorial_dialogue8',				-- Trom interface_en.str
	body			= 'tutorial_dialogue8_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_caprice_12_2.wav',
	model			= 'tutorialMessageModelCaprice',
	anim			= 'tutorial_12_2',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 4000
})

tutorialRegisterMessage({
	event			= 'tutorial_dialogue8a',				-- Event Name (trigger)
	icon			= '/heroes/caprice/icon.tga',
	title			= 'tutorial_dialogue8a',				-- Trom interface_en.str
	body			= 'tutorial_dialogue8a_body',			-- Body, from interface_en.str
	sound			= '/shared/sounds/keepers/draknia/none.wav',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	showTime		= 4000
})

tutorialRegisterMessage({
	event			= 'tutorial_dialogue8b',				-- Event Name (trigger)
	icon			= '/maps/tutorial/resources/npcs/general/icon.tga',
	title			= 'tutorial_dialogue8b',				-- Trom interface_en.str
	body			= 'tutorial_dialogue8b_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_leader_1.wav',
	model			= 'tutorialMessageModelMilitia',
	anim			= 'tutorial_1',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 5000
})

tutorialRegisterMessage({
	event			= 'tutorial_dialogue8c',				-- Event Name (trigger)
	icon			= '/heroes/caprice/icon.tga',
	title			= 'tutorial_dialogue8c',				-- Trom interface_en.str
	body			= 'tutorial_dialogue8c_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_caprice_13_1.wav',
	model			= 'tutorialMessageModelCaprice',
	anim			= 'tutorial_13_1',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 3000
})

tutorialRegisterMessage({
	event			= 'tutorial_dialogue8d',				-- Event Name (trigger)
	icon			= '/maps/tutorial/resources/npcs/general/icon.tga',
	title			= 'tutorial_dialogue8d',				-- Trom interface_en.str
	body			= 'tutorial_dialogue8d_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_leader_2.wav',
	model			= 'tutorialMessageModelMilitia',
	anim			= 'tutorial_2',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 3000
})

tutorialRegisterMessage({
	event			= 'tutorial_dialogue8e',				-- Event Name (trigger)
	icon			= '/heroes/caprice/icon.tga',
	title			= 'tutorial_dialogue8e',				-- Trom interface_en.str
	body			= 'tutorial_dialogue8e_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_caprice_13_2.wav',
	model			= 'tutorialMessageModelCaprice',
	anim			= 'tutorial_13_2',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	showTime		= 9000,
	forceHeight		= 16								-- Forces the message to be a minimum height of 8h.
})

tutorialRegisterMessage({
	event			= 'tutorial_dialogue8f',				-- Event Name (trigger)
	icon			= '/maps/tutorial/resources/npcs/general/icon.tga',
	title			= 'tutorial_dialogue8f',				-- Trom interface_en.str
	body			= 'tutorial_dialogue8f_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_leader_3.wav',
	model			= 'tutorialMessageModelMilitia',
	anim			= 'tutorial_3',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 6000
})

tutorialRegisterMessage({
	event			= 'tutorial_dialogue8g',				-- Event Name (trigger)
	icon			= '/maps/tutorial/resources/npcs/general/icon.tga',
	title			= 'tutorial_dialogue8g',				-- Trom interface_en.str
	body			= 'tutorial_dialogue8g_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_leader_3_2.wav',
	model			= 'tutorialMessageModelMilitia',
	anim			= 'tutorial_3_2',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 9300
})

tutorialRegisterTip({
	event			= 'tutorial_tip5',				-- Event Name (trigger)
	body			= 'tutorial_tip5_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial_tip5Hide',
	sound			= '/maps/tutorial/resources/sounds/voice/vo_announcer_11.wav'
})

tutorialRegisterTip({
	event			= 'tutorial_tip6',				-- Event Name (trigger)
	body			= 'tutorial_tip6_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial_tip6Hide',
	sound			= '/maps/tutorial/resources/sounds/voice/vo_announcer_12.wav',
	hotkey1Action	= 'ToggleLockedCam',
	hotkey1Param	= '',
})

tutorialRegisterTip({
	event			= 'tutorial_tip6d',				-- Event Name (trigger)
	body			= 'tutorial_tip6d_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial_tip6dHide',
	sound			= '/maps/tutorial/resources/sounds/voice/vo_announcer_14.wav'
})


-- Objective 5

tutorialRegisterMessage({
	event			= 'tutorial_dialogue9',				-- Event Name (trigger)
	icon			= '/heroes/caprice/icon.tga',
	title			= 'tutorial_dialogue9',				-- Trom interface_en.str
	body			= 'tutorial_dialogue9_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_caprice_7.wav',
	model			= 'tutorialMessageModelCaprice',
	anim			= 'tutorial_7',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 4000
})

tutorialRegisterMessage({
	event			= 'tutorial_dialogue10',				-- Event Name (trigger)
	icon			= '/maps/tutorial/resources/npcs/shopkeeper/icon.tga',
	title			= 'tutorial_dialogue10',				-- Trom interface_en.str
	body			= 'tutorial_dialogue10_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_merchant_1.wav',
	model			= 'tutorialMessageModelMerchant',
	anim			= 'tutorial_1',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 2000
})

tutorialRegisterMessage({
	event			= 'tutorial_dialogue11',				-- Event Name (trigger)
	icon			= '/maps/tutorial/resources/npcs/shopkeeper/icon.tga',
	title			= 'tutorial_dialogue11',				-- Trom interface_en.str
	body			= 'tutorial_dialogue11_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_merchant_1_2.wav',
	model			= 'tutorialMessageModelMerchant',
	anim			= 'tutorial_1_2',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 12000
})

tutorialRegisterMessage({
	event			= 'tutorial_dialogue12',				-- Event Name (trigger)
	icon			= '/heroes/caprice/icon.tga',
	title			= 'tutorial_dialogue12',				-- Trom interface_en.str
	body			= 'tutorial_dialogue12_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_caprice_8.wav',
	model			= 'tutorialMessageModelCaprice',
	anim			= 'tutorial_8',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	showTime		= 6000,
	forceHeight		= 16								-- Forces the message to be a minimum height of 8h.
})

tutorialRegisterMessage({
	event			= 'tutorial_dialogue13',				-- Event Name (trigger)
	icon			= '/maps/tutorial/resources/npcs/shopkeeper/icon.tga',
	title			= 'tutorial_dialogue13',				-- Trom interface_en.str
	body			= 'tutorial_dialogue13_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_merchant_2.wav',
	model			= 'tutorialMessageModelMerchant',
	anim			= 'tutorial_2',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 14400
})

-- Objective 6

tutorialRegisterMessage({
	event			= 'tutorial_dialogue14',				-- Event Name (trigger)
	icon			= '/maps/tutorial/resources/npcs/thief/icon.tga',
	title			= 'tutorial_dialogue14',				-- Trom interface_en.str
	body			= 'tutorial_dialogue14_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_bandit_1.wav',
	model			= 'tutorialMessageModelThief',
	anim			= 'tutorial_1',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 6000
})

tutorialRegisterMessage({
	event			= 'tutorial_dialogue15',				-- Event Name (trigger)
	icon			= '/maps/tutorial/resources/npcs/thief/icon.tga',
	title			= 'tutorial_dialogue15',				-- Trom interface_en.str
	body			= 'tutorial_dialogue15_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_bandit_2.wav',
	model			= 'tutorialMessageModelThief',
	anim			= 'tutorial_2',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 6000
})

tutorialRegisterMessage({
	event			= 'tutorial_dialogue16',				-- Event Name (trigger)
	icon			= '/heroes/caprice/icon.tga',
	title			= 'tutorial_dialogue16',				-- Trom interface_en.str
	body			= 'tutorial_dialogue16_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_caprice_9.wav',
	model			= 'tutorialMessageModelCaprice',
	anim			= 'tutorial_9',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 3500
})


tutorialRegisterTip({
	event			= 'tutorial_tip5a',				-- Event Name (trigger)
	body			= 'tutorial_tip5a_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial_tip5aHide',
	sound			= '/maps/tutorial/resources/sounds/voice/vo_announcer_18.wav'
})

tutorialRegisterTip({
	event			= 'tutorial_tip6a',				-- Event Name (trigger)
	body			= 'tutorial_tip6a_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial_tip6aHide',
	sound			= '/maps/tutorial/resources/sounds/voice/vo_announcer_21.wav'
})

tutorialRegisterTip({
	event			= 'tutorial_tip6b',				-- Event Name (trigger)
	body			= 'tutorial_tip6b_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial_tip6bHide',
	sound			= '/maps/tutorial/resources/sounds/voice/vo_announcer_20.wav'
})

tutorialRegisterTip({
	event			= 'tutorial_tip6c',				-- Event Name (trigger)
	body			= 'tutorial_tip6c_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial_tip6cHide',
	sound			= '/maps/tutorial/resources/sounds/voice/vo_announcer_19.wav'
})

-- Objective 7

tutorialRegisterMessage({
	event			= 'tutorial_dialogue17',				-- Event Name (trigger)
	icon			= '/maps/tutorial/resources/npcs/shopkeeper/icon.tga',
	title			= 'tutorial_dialogue17',				-- Trom interface_en.str
	body			= 'tutorial_dialogue17_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_merchant_3.wav',
	model			= 'tutorialMessageModelMerchant',
	anim			= 'tutorial_3',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 4300
})

tutorialRegisterMessage({
	event			= 'tutorial_dialogue18',				-- Event Name (trigger)
	icon			= '/maps/tutorial/resources/npcs/shopkeeper/icon.tga',
	title			= 'tutorial_dialogue18',				-- Trom interface_en.str
	body			= 'tutorial_dialogue18_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_merchant_3_2.wav',
	model			= 'tutorialMessageModelMerchant',
	anim			= 'tutorial_3_2',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 8000
})

tutorialRegisterMessage({
	event			= 'tutorial_dialogue19',				-- Event Name (trigger)
	icon			= '/heroes/caprice/icon.tga',
	title			= 'tutorial_dialogue19',				-- Trom interface_en.str
	body			= 'tutorial_dialogue19_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_caprice_10.wav',
	model			= 'tutorialMessageModelCaprice',
	anim			= 'tutorial_10',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	showTime		= 7000,
	forceHeight		= 16								-- Forces the message to be a minimum height of 8h.
})

tutorialRegisterMessage({
	event			= 'tutorial_dialogue20',				-- Event Name (trigger)
	icon			= '/maps/tutorial/resources/npcs/shopkeeper/icon.tga',
	title			= 'tutorial_dialogue20',				-- Trom interface_en.str
	body			= 'tutorial_dialogue20_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_merchant_4.wav',
	model			= 'tutorialMessageModelMerchant',
	anim			= 'tutorial_4',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 10000
})

tutorialRegisterMessage({
	event			= 'tutorial_dialogue21',				-- Event Name (trigger)
	icon			= '/maps/tutorial/resources/npcs/shopkeeper/icon.tga',
	title			= 'tutorial_dialogue21',				-- Trom interface_en.str
	body			= 'tutorial_dialogue21_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_merchant_5.wav',
	model			= 'tutorialMessageModelMerchant',
	anim			= 'tutorial_5',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 5000
})

tutorialRegisterTip({
	event			= 'tutorial_tip7',				-- Event Name (trigger)
	body			= 'tutorial_tip7_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial_tip7Hide',
	sound			= '/maps/tutorial/resources/sounds/voice/vo_announcer_22.wav',
	hotkey1Action	= 'ToggleShop',
	hotkey1Param	= ''
})

tutorialRegisterTip({
	event			= 'tutorial_tip7silent',				-- Event Name (trigger)
	body			= 'tutorial_tip7_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial_tip7silentHide',
	hotkey1Action	= 'ToggleShop',
	hotkey1Param	= ''
})

tutorialRegisterTip({
	event			= 'tutorial_tip7a',				-- Event Name (trigger)
	body			= 'tutorial_tip7a_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial_tip7aHide',
	sound			= '/maps/tutorial/resources/sounds/voice/vo_announcer_23.wav'
})


tutorialRegisterTip({
	event			= 'tutorial_tip8',				-- Event Name (trigger)
	body			= 'tutorial_tip8_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial_tip8Hide',
	showTime		= 6000,
	sound			= '/maps/tutorial/resources/sounds/voice/vo_announcer_27.wav'
})



--Objective 8

tutorialRegisterMessage({
	event			= 'tutorial_dialogue22',				-- Event Name (trigger)
	icon			= '/maps/tutorial/resources/npcs/shopkeeper/icon.tga',
	title			= 'tutorial_dialogue22',				-- Trom interface_en.str
	body			= 'tutorial_dialogue22_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_merchant_6.wav',
	model			= 'tutorialMessageModelMerchant',
	anim			= 'tutorial_6',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 3000
})

tutorialRegisterMessage({
	event			= 'tutorial_dialogue22a',				-- Event Name (trigger)
	icon			= '/heroes/caprice/icon.tga',
	title			= 'tutorial_dialogue22a',				-- Trom interface_en.str
	body			= 'tutorial_dialogue22a_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_caprice_11.wav',
	model			= 'tutorialMessageModelCaprice',
	anim			= 'tutorial_11',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 4000
})

tutorialRegisterTip({
	event			= 'tutorial_tip9',				-- Event Name (trigger)
	body			= 'tutorial_tip9_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial_tip9Hide',
	sound			= '/maps/tutorial/resources/sounds/voice/vo_announcer_28.wav',
	forceHeight		= 9,
	hotkey1Action	= 'ActivateTool',
	hotkey1Param	= 96
})

tutorialRegisterTip({
	event			= 'tutorial_tip9b',				-- Event Name (trigger)
	body			= 'tutorial_tip9b_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial_tip9bHide',
	sound			= '/maps/tutorial/resources/sounds/voice/vo_announcer_29.wav'
})

--Killing the tower

tutorialRegisterTip({
	event			= 'tutorial_tip10',				-- Event Name (trigger)
	body			= 'tutorial_tip10_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial_tip10Hide',
	showTime		= 7500,
	sound			= '/maps/tutorial/resources/sounds/voice/vo_announcer_30.wav'
})

tutorialRegisterTip({
	event			= 'tutorial_tip11',				-- Event Name (trigger)
	body			= 'tutorial_tip11_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial_tip11Hide',
	showTime		= 8000,
	sound			= '/maps/tutorial/resources/sounds/voice/vo_announcer_31b.wav'
})

tutorialRegisterTip({
	event			= 'tutorial_tip11a',				-- Event Name (trigger)
	body			= 'tutorial_tip11a_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial_tip11aHide',
	showTime		= 9500,
	sound			= '/maps/tutorial/resources/sounds/voice/vo_announcer_32.wav'
})

tutorialRegisterMessage({
	event			= 'tutorial_dialogue23',				-- Event Name (trigger)
	icon			= '/maps/tutorial/resources/npcs/general/icon.tga',
	title			= 'tutorial_dialogue23',				-- Trom interface_en.str
	body			= 'tutorial_dialogue23_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_leader_4.wav',
	model			= 'tutorialMessageModelMilitia',
	anim			= 'tutorial_4',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 6000
})

tutorialRegisterMessage({
	event			= 'tutorial_dialogue24',				-- Event Name (trigger)
	icon			= '/heroes/caprice/icon.tga',
	title			= 'tutorial_dialogue24',				-- Trom interface_en.str
	body			= 'tutorial_dialogue24_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_caprice_14.wav',
	model			= 'tutorialMessageModelCaprice',
	anim			= 'tutorial_14',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 4000
})

tutorialRegisterMessage({
	event			= 'tutorial_dialogue24a',				-- Event Name (trigger)
	icon			= '/maps/tutorial/resources/npcs/thief/icon.tga',
	title			= 'tutorial_dialogue24a',				-- Trom interface_en.str
	body			= 'tutorial_dialogue24a_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_bandit_3_1.wav',
	model			= 'tutorialMessageModelThief',
	anim			= 'tutorial_3_1',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 3000
})

tutorialRegisterMessage({
	event			= 'tutorial_dialogue24b',				-- Event Name (trigger)
	icon			= '/maps/tutorial/resources/npcs/thief/icon.tga',
	title			= 'tutorial_dialogue24b',				-- Trom interface_en.str
	body			= 'tutorial_dialogue24b_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_bandit_3_2.wav',
	model			= 'tutorialMessageModelThief',
	anim			= 'tutorial_3_2',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 4000
})

tutorialRegisterMessage({
	event			= 'tutorial_dialogue25',				-- Event Name (trigger)
	icon			= '/maps/tutorial/resources/npcs/general/icon.tga',
	title			= 'tutorial_dialogue25',				-- Trom interface_en.str
	body			= 'tutorial_dialogue25_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_leader_5.wav',
	model			= 'tutorialMessageModelMilitia',
	anim			= 'tutorial_5',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 5000
})

tutorialRegisterMessage({
	event			= 'tutorial_dialogue26',				-- Event Name (trigger)
	icon			= '/maps/tutorial/resources/npcs/general/icon.tga',
	title			= 'tutorial_dialogue26',				-- Trom interface_en.str
	body			= 'tutorial_dialogue26_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_leader_5_2.wav',
	model			= 'tutorialMessageModelMilitia',
	anim			= 'tutorial_5_2',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 4500
})

tutorialRegisterMessage({
	event			= 'tutorial_dialogue27',				-- Event Name (trigger)
	icon			= '/heroes/caprice/icon.tga',
	title			= 'tutorial_dialogue27',				-- Trom interface_en.str
	body			= 'tutorial_dialogue27_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_caprice_15.wav',
	model			= 'tutorialMessageModelCaprice',
	anim			= 'tutorial_15',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 5000
})

tutorialRegisterMessage({
	event			= 'tutorial_dialogue27a',				-- Event Name (trigger)
	icon			= '/maps/tutorial/resources/npcs/general/icon.tga',
	title			= 'tutorial_dialogue27a',				-- Trom interface_en.str
	body			= 'tutorial_dialogue27a_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_leader_6.wav',
	model			= 'tutorialMessageModelMilitia',
	anim			= 'tutorial_6',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 4000
})

tutorialRegisterMessage({
	event			= 'tutorial_dialogue27b',				-- Event Name (trigger)
	icon			= '/maps/tutorial/resources/npcs/shopkeeper/icon.tga',
	title			= 'tutorial_dialogue27b',				-- Trom interface_en.str
	body			= 'tutorial_dialogue27b_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_merchant_7.wav',
	model			= 'tutorialMessageModelMerchant',
	anim			= 'tutorial_7',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 5500
})

-- Boss

tutorialRegisterMessage({
	event			= 'tutorial_dialogue28',				-- Event Name (trigger)
	icon			= '/heroes/caprice/icon.tga',
	title			= 'tutorial_dialogue28',				-- Trom interface_en.str
	body			= 'tutorial_dialogue28_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_caprice_16.wav',
	model			= 'tutorialMessageModelCaprice',
	anim			= 'tutorial_16',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 5000
})

tutorialRegisterMessage({
	event			= 'tutorial_dialogue29',				-- Event Name (trigger)
	icon			= '/heroes/caprice/icon.tga',
	title			= 'tutorial_dialogue29',				-- Trom interface_en.str
	body			= 'tutorial_dialogue29_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_caprice_17.wav',
	model			= 'tutorialMessageModelCaprice',
	anim			= 'tutorial_17',
	darkenBG		= false,							-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,							-- Allow manual continue by clicking button (or BG)
	pause			= false,						-- Pause Game
	forceHeight		= 16,	
	showTime		= 4000
})

tutorialRegisterMessage({
	event			= 'tutorial_dialogue30',				-- Event Name (trigger)
	icon			= '/heroes/caprice/none.tga',
	title			= 'tutorial_dialogue30',				-- Trom interface_en.str
	body			= 'tutorial_dialogue30_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_baldir.wav',
	model			= 'tutorialMessageModelBaldir',
	anim			= 'talking_1',
	darkenBG		= false,								-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,								-- Allow manual continue by clicking button (or BG)
	pause			= false,								-- Pause Game
	forceHeight		= 16,	
	showTime		= 16200
})

tutorialRegisterMessage({
	event			= 'tutorial_dialogue31',				-- Event Name (trigger)
	icon			= '/heroes/caprice/none.tga',
	title			= 'tutorial_dialogue31',				-- Trom interface_en.str
	body			= 'tutorial_dialogue31_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_caprice_18.wav',
	model			= 'tutorialMessageModelCaprice',
	anim			= 'tutorial_18',
	darkenBG		= false,								-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,								-- Allow manual continue by clicking button (or BG)
	pause			= false,								-- Pause Game
	forceHeight		= 16,	
	showTime		= 6000
})

tutorialRegisterMessage({
	event			= 'tutorial_dialogue32',				-- Event Name (trigger)
	icon			= '/heroes/caprice/none.tga',
	title			= 'tutorial_dialogue32',				-- Trom interface_en.str
	body			= 'tutorial_dialogue32_body',			-- Body, from interface_en.str
	sound			= '/maps/tutorial/resources/sounds/voice/vo_caprice_19.wav',
	model			= 'tutorialMessageModelCaprice',
	anim			= 'tutorial_19',
	darkenBG		= false,								-- Show darkened background
	grayscale		= false,								-- Render rest of the game in grayscale
	showContinue	= false,								-- Allow manual continue by clicking button (or BG)
	pause			= false,								-- Pause Game
	forceHeight		= 16,	
	showTime		= 6000
})


tutorialRegisterTip({
	event			= 'tutorial_tip12',				-- Event Name (trigger)
	body			= 'tutorial_tip12_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial_tip12Hide',
	showTime		= 5000
})

tutorialRegisterTip({
	event			= 'tutorial_tip13',				-- Event Name (trigger)
	body			= 'tutorial_tip13_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial_tip13Hide',
	sound			= '/maps/tutorial/resources/sounds/voice/vo_announcer_40.wav',
	showTime		= 8000
})

tutorialRegisterTip({
	event			= 'tutorial_tip_death',				-- Event Name (trigger)
	body			= 'tutorial_tip_death_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial_tip_death_Hide',
	sound			= '/maps/tutorial/resources/sounds/voice/vo_announcer_37.wav',
	showTime		= 3500
})

tutorialRegisterTip({	-- Doesn't support models - let Merc know if that's required.
	event			= 'tutorial_tip_toweraggro',				-- Event Name (trigger)
	body			= 'tutorial_tip_toweraggro_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial_tip_toweraggro_Hide',
	sound			= '/maps/tutorial/resources/sounds/voice/vo_announcer_38.wav',
	showTime		= 10000
})

tutorialRegisterTip({	-- Doesn't support models - let Merc know if that's required.
	event			= 'tutorial_tip_attackhero',				-- Event Name (trigger)
	body			= 'tutorial_tip_attackhero_body',			-- Body, from interface_en.str
	hideTipEvent	= 'tutorial_tip_attackhero_Hide',
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
-- Stuff for highlighting inventory slots by index
-- ========================================

tutorial_registerPointAtInventory(0)
tutorial_registerSpotlightInventory(0)
tutorial_registerDarkenInventory(0)

tutorial_registerPointAtInventory(96)
tutorial_registerSpotlightInventory(96)
tutorial_registerDarkenInventory(96)

-- ========================================
-- Stuff for highlighting shop items by entity
-- ========================================

tutorial_registerPointAtShopEntity('Item_TeleportBoots')
tutorial_registerSpotlightShopEntity('Item_TeleportBoots')
tutorial_registerDarkenShopEntity('Item_TeleportBoots')

-- ========================================
-- Sample objective stuff
-- ========================================

tutorialRegisterObjective({
	showEvent				= 'tutorial_objective1',
	completionEvent			= 'tutorial_objective1Complete',		-- Will increment the completion count and will clear the objective once completion is maxed.
	completionCount			= 3,									-- How many times must this be completed?, defaults to 1
	label					= 'tutorial_objective1',
	extraInfo				= 'tutorial_objective1MoreInfo',		-- Click the "more info" question mark button to trigger this event (can be linked back to a message or popup)
	pingScriptValue			= 'tutorial_objective1ScriptValue',		-- Value to set to 1 when the ping map button is clicked
})

tutorialRegisterObjective({
	showEvent				= 'tutorial_objective2',
	completionEvent			= 'tutorial_objective2Complete',		-- Will increment the completion count and will clear the objective once completion is maxed.
	completionCount			= 2,									-- How many times must this be completed?, defaults to 1
	label					= 'tutorial_objective2',
	extraInfo				= 'tutorial_objective2MoreInfo',		-- Click the "more info" question mark button to trigger this event (can be linked back to a message or popup)
	pingScriptValue			= 'tutorial_objective2ScriptValue',		-- Value to set to 1 when the ping map button is clicked
	objectiveContainer		= 'tutorialSecondaryObjectives',
	objectiveList			= 'tutorialSecondaryObjectiveList',
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

-- ========================================
-- Sample hint system
-- ========================================

tutorialRegisterHint({
	showEvent				= 'tutorial_hint1',				-- Adds/shows the tip
	hideEvent				= 'tutorial_hint1Close',		-- Removes the tip
	label1					= 'tutorial_hint1',				-- Primary Label
	label2					= 'tutorial_hint1Desc',			-- Secondary label (small, gray)
	extraInfo				= 'tutorial_objective1MoreInfo',	-- Click the "more info" question mark button to trigger this event (can be linked back to a message or popup)
})

-- ========================================
-- Sample chat message
-- ========================================

tutorialRegisterChatEvent({
	event					= 'tutorial_chatMessage1',			-- ClientUITrigger which initiates the message
	message					= 'tutorial_chatMessage1',			-- In interface_en.str
	sender					= 'tutorial_chatMessage1Sender',	-- In interface_en.str (name of character sending message)
	entity					= 'Hero_Ace',				-- Entity that the message is coming from (icon populates from this).
	relation				= 1,								-- 1 for team, 2 for enemy, 4 for self.
})

tutorialReinitialize(object)