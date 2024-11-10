local interface = object

local selectModeInfo = LuaTrigger.GetTrigger('selectModeInfo') or LuaTrigger.CreateCustomTrigger('selectModeInfo', {
	{ name	= 'queuedMode',		type		= 'string' }
})

local function setUpQuickPartySection()
	local button = interface:GetWidget('main_quickparty_button')
	local buttonContainer = interface:GetWidget('main_quickparty_button_container')
	buttonContainer:SetCallback('onclick', function()
		if (GetCvarBool('ui_newUISounds')) then PlaySound('/ui/sounds/launcher/sfx_quickmatch.wav') end
		
		local function openPvp()
			Party.OpenedPlayScreen()
			selectModeInfo.queuedMode = 'pvp'
			selectModeInfo:Trigger(false)
			local mainPanelStatus = LuaTrigger.GetTrigger('mainPanelStatus')
			mainPanelStatus.main				= mainUI.MainValues.preGame
			mainPanelStatus:Trigger(false)
		end
		
		local state = mainUI.getPregameState()
		if (state ~= '' and state ~= 'pregame' and state ~= 'scrim') then
			triggerVarChangeOrFunction('GamePhase', 'gamePhase', 0, 2000, 'quickParty',nil, openPvp)
			ChatClient.LeaveGame()
		elseif (state == 'pregame' or state == 'scrim') then
			triggerVarChangeOrFunction('PartyStatus', 'inParty', false, 2000, 'quickParty', nil, openPvp)
			ChatClient.LeaveParty()
		else
			openPvp()
		end
	
	end)
	buttonContainer:SetCallback('onmouseover', function()
		button:SetTexture('/ui/shared/frames/blue_btn_over.tga')
		libAnims.bounceIn(button, button:GetWidth(), button:GetHeight(), nil, nil, 0.02, 200, 0.9, 0.1)
	end)
	buttonContainer:SetCallback('onmouseout', function()
		button:SetTexture('/ui/shared/frames/blue_btn_up.tga')
	end)
end

local function onLoad()
	setUpQuickPartySection()
end
local function init(parent, x, y, w, h)
	return parent:InstantiateAndReturn('main_quickparty_container_template', 'x', x, 'y', y, 'w', w, 'h', h)[1]
end
local function onRemove()
	getResizableContainer():Destroy()
end

local function getResizableContainer()
	return interface:GetWidget("main_quickparty_container")
end

local newsStoryComponent = {
	internalName = "main_news_quick_party",
	externalName = "news_component_quick_party",
	singleton = true,
	defaultPosition = {"20s", "390s", "606s", "83s"},
	sizeRange = {'573s', 999999, '65s', 999999},
	onLoad = onLoad,
	onRemove = onRemove,
	init = init,
	getResizableContainer = getResizableContainer,
}


mainUI.news.registerComponent(newsStoryComponent)