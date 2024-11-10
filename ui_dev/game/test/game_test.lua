-- Test Menu

function testMenuRegister(object)

	local container				= object:GetWidget('testMenu')
	local spawner				= object:GetWidget('testMenuSpawner')
	local closeButton			= object:GetWidget('testMenuClose')
	local spawnerCloseButton	= object:GetWidget('testMenuSpawnerClose')
	--[[
	local refreshButton			= object:GetWidget('gameTestRefreshButton')
	local killButton			= object:GetWidget('testMenuKillButton')
	local smallXPButton			= object:GetWidget('gameTestAddSmallXPButton')
	local largeXPButton			= object:GetWidget('gameTestAddLargeXPButton')
	local addLevelButton		= object:GetWidget('gameTestAddLevelButton')
	local resetLevelButton		= object:GetWidget('gameTestResetLevelButton')
	local maxLevelButton		= object:GetWidget('gameTestMaxLevelButton')
	local giveGoldButton		= object:GetWidget('gameTestGiveGoldButton')
	local creepSpawnButton		= object:GetWidget('gameTestCreepSpawnButton')
	local creepKillButton		= object:GetWidget('gameTestCreepKillButton')
	local spawnerButton			= object:GetWidget('gameTestSpawnerButton')
	local itemsButton			= object:GetWidget('gameTestItemsButton')
	local spawnButton			= object:GetWidget('gameTestSpawnButton')
	local giveItemButton		= object:GetWidget('gameTestGiveItemButton')
	--]]
	local entityTypeBox			= object:GetWidget('gameTestBoxEntityType')
	local teamBox				= object:GetWidget('gameTestBoxTeam')
	local playerBox				= object:GetWidget('gameTestBoxPlayer')
	local precacheBox			= object:GetWidget('gameTestBoxPrecache')
	local itemTypeBox			= object:GetWidget('gameTestBoxItemType')
	
	local testButton			= object:GetWidget('gameTestButton')

	local function open()
		container:FadeIn(100)
	end

	local function close()
		container:FadeOut(100)
	end

	local function spawnerOpen()
		spawner:FadeIn(100)
	end

	local function spawnerClose()
		spawner:FadeOut(100)
	end

	closeButton:SetCallback(
		'onclick', function(widget)
			close()
		end
	)

	spawnerCloseButton:SetCallback(
		'onclick', function(widget)
			spawnerClose()
		end
	)
	
	testButton:SetCallback('onclick', function(widget)
		open()
	end)

	testButton:RegisterWatchLua(
		'Dev', function(widget, trigger)
			local bool showDevMenu = trigger.showDevMenu and (not GetCvarBool('ui_hideDevMenu'))
			widget:SetVisible(showDevMenu)
			if not showDevMenu then
				container:SetVisible(false)
			end
		end
	)
	
	testButton:RegisterWatchLua('gamePanelInfo', function(widget, trigger)
		if trigger.shopOpen then
			widget:SlideX(libGeneral.HtoP(59), styles_uiSpaceShiftTime)
		else
			widget:SlideX(libGeneral.HtoP(6), styles_uiSpaceShiftTime)
		end
	end, false, nil, 'shopOpen')

	object:GetWidget('gameTestRefreshButton'):SetCallback('onclick', function(widget)
		PlaySound('/ui/sounds/sfx_button_generic.wav')
		Cmd('Refresh '..GetSelectedEntity())
	end)

	object:GetWidget('gameTestKillButton'):SetCallback('onclick', function(widget)
		PlaySound('/ui/sounds/sfx_button_generic.wav')
		Cmd('Kill '..GetSelectedEntity())
	end)

	object:GetWidget('gameTestAddSmallXPButton'):SetCallback('onclick', function(widget)
		PlaySound('/ui/sounds/sfx_button_generic.wav')
		Cmd('GiveExp '..GetSelectedEntity()..' 150')
	end)

	object:GetWidget('gameTestAddLargeXPButton'):SetCallback('onclick', function(widget)
		PlaySound('/ui/sounds/sfx_button_generic.wav')
		Cmd('GiveExp '..GetSelectedEntity()..' 1500')
	end)

	object:GetWidget('gameTestAddLevelButton'):SetCallback('onclick', function(widget)
		PlaySound('/ui/sounds/sfx_button_generic.wav')
		Cmd('LevelUp '..GetSelectedEntity())
	end)

	object:GetWidget('gameTestResetLevelButton'):SetCallback('onclick', function(widget)
		PlaySound('/ui/sounds/sfx_button_generic.wav')
		Cmd('ResetExp '..GetSelectedEntity())
	end)

	object:GetWidget('gameTestMaxLevelButton'):SetCallback('onclick', function(widget)
		PlaySound('/ui/sounds/sfx_button_generic.wav')
		Cmd('LevelMax '..GetSelectedEntity())
	end)
	
	object:GetWidget('gameTestGiveGoldButton'):SetCallback('onclick', function(widget)
		PlaySound('/ui/sounds/sfx_button_generic.wav')
		Cmd('GiveGold '..GetLocalClientNumber()..' 15000')
	end)
	
	object:GetWidget('gameTestCreepSpawnButton'):SetCallback('onclick', function(widget)
		PlaySound('/ui/sounds/sfx_button_generic.wav')
		Cmd('SpawnCreeps')
	end)

	object:GetWidget('gameTestCreepKillButton'):SetCallback('onclick', function(widget)
		PlaySound('/ui/sounds/sfx_button_generic.wav')
		Cmd('KillCreeps')
	end)

	object:GetWidget('gameTestSpawnerButton'):SetCallback('onclick', function(widget)
		PlaySound('/ui/sounds/sfx_button_generic.wav')
		spawnerOpen()
	end)

	object:GetWidget('gameTestSpawnButton'):SetCallback('onclick', function(widget)
		PlaySound('/ui/sounds/sfx_button_generic.wav')
		local spawnerClientID = -1
		if AtoN(playerBox:GetValue()) ~= -1 then
			spawnerClientID = GetLocalClientNumber()
		end
		Cmd("StartCmdClickPos SpawnUnit2 "..entityTypeBox:GetValue()..' '..spawnerClientID..' '..teamBox:GetValue()..' '..precacheBox:GetValue());
	end)

	object:GetWidget('gameTestGiveItemButton'):SetCallback('onclick', function(widget)
		PlaySound('/ui/sounds/sfx_button_generic.wav')
		Cmd("GiveItem "..GetSelectedEntity()..' '..itemTypeBox:GetValue())
	end)

	entityTypeBox:UICmd("AddUnitTypes('simpleDropdownItem')")
	-- entityTypeBox:UICmd("SetSelectedItemByIndex(0)")
	entityTypeBox:UICmd("SetSelectedItemByValue('Creep_LegionMelee')")

	entityTypeBox:RegisterWatchLua(
		'Dev', function(widget, trigger)
			local bool showDevMenu = trigger.showDevMenu
			if showDevMenu then
				entityTypeBox:Clear()
				entityTypeBox:UICmd("AddUnitTypes('simpleDropdownItem')")
				entityTypeBox:UICmd("SetSelectedItemByIndex(0)")
			end
		end
	)

	teamBox:AddTemplateListItem('simpleDropdownItem', '-2', 'label', 'Neutral')
	teamBox:AddTemplateListItem('simpleDropdownItem', '-1', 'label', 'Passive')
	teamBox:AddTemplateListItem('simpleDropdownItem', '1', 'label', Translate('general_glory'))
	teamBox:AddTemplateListItem('simpleDropdownItem', '2', 'label', Translate('general_valor'))
	teamBox:UICmd("SetSelectedItemByIndex(0)")

	playerBox:AddTemplateListItem('simpleDropdownItem', '-1', 'label', 'None')
	playerBox:AddTemplateListItem('simpleDropdownItem', '1', 'label', 'Local Client')
	playerBox:UICmd("SetSelectedItemByIndex(1)")

	precacheBox:AddTemplateListItem('simpleDropdownItem', '0', 'label', 'Precache all')
	precacheBox:AddTemplateListItem('simpleDropdownItem', '1', 'label', 'Precache self')
	precacheBox:AddTemplateListItem('simpleDropdownItem', '2', 'label', 'Precache ally')
	precacheBox:AddTemplateListItem('simpleDropdownItem', '3', 'label', 'Precache other')
	precacheBox:AddTemplateListItem('simpleDropdownItem', '4', 'label', 'No precache')
	precacheBox:UICmd("SetSelectedItemByIndex(0)")

	itemTypeBox:UICmd("AddItemTypes('simpleDropdownItem')")
	itemTypeBox:UICmd("SetSelectedItemByIndex(0)")

	itemTypeBox:RegisterWatchLua(
		'Dev', function(widget, trigger)
			local bool showDevMenu = trigger.showDevMenu
			if showDevMenu then
				itemTypeBox:Clear()
				itemTypeBox:UICmd("AddItemTypes('simpleDropdownItem')")
				itemTypeBox:UICmd("SetSelectedItemByIndex(0)")
			end
		end
	)

end

testMenuRegister(object)