-- A component entry should have:
-- internalName			The name to be used to save/id the component
-- externalName			The name to show on dialogues etc
-- singleton			Whether multiple of this component are disallowed
-- resizableContainer	The widget that represents the size of the component
-- onLoad				A function to be called when the component loads
-- onRemove				A function to be called when the component is removed
-- init					A function to be called to create the component, takes (parent, x, y, w, h)

local interface = object

local function startQuickMatchByRole(neededRole, neededRoleIndex)
	local IS_MATCHMAKING = false
	if (IS_MATCHMAKING) then
		QueueQuickPickHero(neededRole, neededRoleIndex)
		Party.OpenedPlayScreen()
		selectModeInfo.queuedMode = 'pve'
		selectModeInfo:Trigger(false)
		local mainPanelStatus = LuaTrigger.GetTrigger('mainPanelStatus') 
		mainPanelStatus.main				= 102
		mainPanelStatus:Trigger(false)	
	else	
		local quickPickableHeroes = {
			['PhysDamage'] = {
				'Hero_Blazer',
				'Hero_Hale',
				'Hero_Gokong',
				'Hero_Harrower',
				'Hero_Minerva',
				'Hero_Rook',
				'Hero_Vermillion',
			},
			['MagDamage'] = {
				'Hero_Moxie',	
				'Hero_Malady',		
				'Hero_Caprice',
				'Hero_Carter',				
			},
			['Survival'] = {
				'Hero_Bastion',
				'Hero_Bo',
				'Hero_Claudessa',
				'Hero_Nikolai',
				'Hero_Shank',
				'Hero_JinShe',
				'Hero_Ace',
			},
			['Utility'] = {
				'Hero_Ray',
				'Hero_Vex',
				'Hero_LadyTinder',
				'Hero_Chester',
				'Hero_Iah',
			},
		}
		local selectedHeroEntity = quickPickableHeroes[neededRole][math.random(1, #quickPickableHeroes[neededRole])]
		mainUI.botDifficulty = 0
		PlaySound('/ui/sounds/sfx_ui_creategame_2.wav')
		SetSave('ui_hideDevMenu', 'true', 'bool')
		StartGame('practice', Translate('game_name_default_botmatch'), 'map:strife nolobby:true botfill:true finalheroesonly:true quickplay:true hero:'..selectedHeroEntity)
	end
	GetWidget('quick_play_role_selection'):FadeOut(125)
end

local function setUpQuickPlaySection()
	local button = interface:GetWidget('main_quickplay_button')
	local buttonContainer = interface:GetWidget('main_quickplay_button_container')
	buttonContainer:SetCallback('onclick', function()
		if (GetCvarBool('ui_newUISounds')) then PlaySound('/ui/sounds/launcher/sfx_quickmatch.wav') end
		GetWidget('quick_play_role_selection'):FadeIn(125)
	end)
	buttonContainer:SetCallback('onmouseover', function()
		button:SetTexture('/ui/shared/frames/blue_btn_over.tga')
		libAnims.bounceIn(button, button:GetWidth(), button:GetHeight(), nil, nil, 0.02, 200, 0.9, 0.1)
	end)
	buttonContainer:SetCallback('onmouseout', function()
		button:SetTexture('/ui/shared/frames/blue_btn_up.tga')
	end)
	GetWidget('quick_play_role_selection_role_btn_1'):SetCallback('onclick', function(widget)
		startQuickMatchByRole('PhysDamage', 3)
		if (GetCvarBool('ui_newUISounds')) then PlaySound('/ui/sounds/launcher/sfx_qm_attackdamage.wav') end
	end)
	GetWidget('quick_play_role_selection_role_btn_2'):SetCallback('onclick', function(widget)
		startQuickMatchByRole('MagDamage', 2)
		if (GetCvarBool('ui_newUISounds')) then PlaySound('/ui/sounds/launcher/sfx_qm_abilitydamage.wav') end
	end)
	GetWidget('quick_play_role_selection_role_btn_3'):SetCallback('onclick', function(widget)
		startQuickMatchByRole('Survival', 4)
		if (GetCvarBool('ui_newUISounds')) then PlaySound('/ui/sounds/launcher/sfx_qm_survivability.wav') end
	end)
	GetWidget('quick_play_role_selection_role_btn_4'):SetCallback('onclick', function(widget)
		startQuickMatchByRole('Utility', 5)
		if (GetCvarBool('ui_newUISounds')) then PlaySound('/ui/sounds/launcher/sfx_qm_support.wav') end
	end)
end


-- local function setUpBotGameSection()
	-- local button = interface:GetWidget('main_quickplay_button')
	-- local buttonContainer = interface:GetWidget('main_quickplay_button_container')
	-- buttonContainer:SetCallback('onclick', function()
		-- button:SetTexture('/ui/shared/frames/std_btn_over.tga')
		-- Party.OpenedPlayScreen()
		-- selectModeInfo.queuedMode = 'pve'
		-- selectModeInfo:Trigger(false)
		-- local mainPanelStatus = LuaTrigger.GetTrigger('mainPanelStatus') 
		-- mainPanelStatus.main				= 102
		-- mainPanelStatus:Trigger(false)	
	-- end)
	-- buttonContainer:SetCallback('onmouseover', function()
		-- button:SetTexture('/ui/shared/frames/blue_btn_over.tga')
		-- libAnims.bounceIn(button, button:GetWidth(), button:GetHeight(), nil, nil, 0.02, 200, 0.9, 0.1)
	-- end)
	-- buttonContainer:SetCallback('onmouseout', function()
		-- button:SetTexture('/ui/shared/frames/blue_btn_up.tga')
	-- end)
-- end	


local function onLoad()
	setUpQuickPlaySection()
end
local function init(parent, x, y, w, h)
	return parent:InstantiateAndReturn('main_quickplay_container_template', 'x', x, 'y', y, 'w', w, 'h', h)[1]
end
local function onRemove()
	getResizableContainer():Destroy()
end

local function getResizableContainer()
	return interface:GetWidget("main_quickplay_container")
end

local newsStoryComponent = {
	internalName = "main_news_bot_match",
	externalName = "news_component_bot_match",
	singleton = true,
	defaultPosition = {"20s", "390s", "606s", "83s"},
	sizeRange = {'543s', 999999, '65s', 999999},
	onLoad = onLoad,
	onRemove = onRemove,
	init = init,
	getResizableContainer = getResizableContainer,
}


mainUI.news.registerComponent(newsStoryComponent)