-- Game List
local interface = object

-- Widgets
local backing = interface:GetWidget('buildsBrowser_backing')
local container = interface:GetWidget('buildsBrowser_container')
local contentContainer = interface:GetWidget('buildsBrowser_content_container')
local list = interface:GetWidget('buildEntryList')
local throb = interface:GetWidget('buildsBrowser_throb')
local itemList = interface:GetWidget('buildsBrowser_itemList')
local abilityList = interface:GetWidget('buildsBrowser_abilityList')
local buildName = interface:GetWidget('buildsBrowser_name')
local buildAuthor = interface:GetWidget('buildsBrowser_author')
local buildPet = interface:GetWidget('buildsBrowser_pet')
local buildRating = interface:GetWidget('buildsBrowser_rating')
local buildVotes = interface:GetWidget('buildsBrowser_votes')
local siteimg = interface:GetWidget('buildsBrowser_siteimg')
local bottomText = interface:GetWidget('buildsBrowser_bottomText')
local bottomTextContainer = interface:GetWidget('buildsBrowser_bottomText_container')
local failed = interface:GetWidget('buildsBrowser_failed')



-- Variables
BuildBrowser = {}
local lastHeroRequested
local data
local selectedBuild = 0

--/////////////
-- Interface-specific functions
--/////////////

function BuildBrowser.loadCurrent()
	local info = data[selectedBuild]
	local heroTrigger = LuaTrigger.GetTrigger('HeroSelectHeroList' .. lastHeroRequested)
	local entityName = heroTrigger.entityName
	local shortEntityName = string.sub(entityName, 6)
	local abilityTable = {}
	for k,v in pairs(data[selectedBuild].abilityOrder) do
		table.insert(abilityTable, 'Ability_' .. shortEntityName .. v)
	end
	local itemTable = {}
	for k,v in pairs(data[selectedBuild].items) do
		table.insert(itemTable, v.short_link)
	end
	
	LoadBuildFromLink(nil, nil, {heroEntity=entityName, name=info.name}, abilityTable, itemTable)

	local trigger = LuaTrigger.GetTrigger('mainBuildBrowser')
	trigger.visible = false
	trigger:Trigger()
end

local function highlightSelectedInList()
	for i = 1, 100 do
		local widget = interface:GetWidget('buildsBrowser_entry_' .. i ..'_selected')
		if (widget) then
			fadeWidget(widget, i == selectedBuild, 125)
		else
			break
		end
	end
end

local function updateAbilities()
	abilityList:ClearChildren()
	local trigger = LuaTrigger.GetTrigger('HeroSelectHeroList' .. lastHeroRequested)
	for k,v in pairs(data[selectedBuild].abilityOrder) do
		abilityList:InstantiateAndReturn('buildsBrowser_itemEntry', 'img', trigger['ability' .. v .. 'IconPath'])
	end
end

local function updatItems()
	itemList:ClearChildren()
	local trigger = LuaTrigger.GetTrigger('HeroSelectHeroList' .. lastHeroRequested)
	for k,v in pairs(data[selectedBuild].items) do
		itemList:InstantiateAndReturn('buildsBrowser_itemEntry', 'img', GetEntityIconPath(v.short_link))
	end
end

local externalPetNameChanges = {}
externalPetNameChanges['Fitz'] = 'Ganker'
externalPetNameChanges['Tink'] = 'Tinker'
externalPetNameChanges['Zen'] = 'Owl'
local function updatePet()
	local pet = data[selectedBuild].pet
	pet = pet:gsub("^%l", string.upper)
	if (externalPetNameChanges[pet]) then
		pet = externalPetNameChanges[pet]
	end
	buildPet:SetTexture(GetEntityIconPath('Familiar_' .. pet))
end

local function selectBuild(selected)
	selectedBuild = selected

	buildName:SetText(data[selectedBuild].name)
	buildAuthor:SetText(Translate('build_browser_Author', 'name', data[selectedBuild].author_username))
	highlightSelectedInList()
	updateAbilities()
	updatItems()
	updatePet()
	local rating = tonumber(data[selectedBuild].rating) or -1
	buildRating:SetColor((rating < 2 and '.8 .2 .2') or (rating < 5 and '.7 .3 .3') or (rating < 8 and '.4 .7 .4') or '.2 .8 .2')
	buildRating:SetText(data[selectedBuild].rating or 'n/a')
	buildVotes:SetText(data[selectedBuild].votes)
	local site = 'StrifeBuilds.net'
	local url = 'https://strifebuilds.net/builds/view/' .. data[selectedBuild].short_link
	bottomText:SetText(Translate('build_browser_bottomText', 'site', site))
	bottomTextContainer:SetCallback('onclick', function()
		mainUI.OpenURL(url)
	end)
	bottomTextContainer:SetCallback('onmouseover', function(widget)
 		UpdateCursor(widget, true, { canLeftClick = true})
	end)
	bottomTextContainer:SetCallback('onmouseout', function(widget)
 		UpdateCursor(widget, false, { canLeftClick = true})
	end)

	siteimg:SetCallback('onclick', function()
		mainUI.OpenURL(url)
	end)
	siteimg:SetCallback('onmouseover', function(widget)
 		UpdateCursor(widget, true, { canLeftClick = true})
	end)
	siteimg:SetCallback('onmouseout', function(widget)
 		UpdateCursor(widget, false, { canLeftClick = true})
	end)
end

local function clearBuildList()
	list:UICmd([[Clear()]])
end
local function populateBuildList(request)
	clearBuildList()
	if (request) then
		local resp = request:GetResponse()
		resp = resp:gsub('\\','\\\\') -- Escape escape-codes
		data = JSON:decode(resp)
	end
	--printr(data)
	if (data and not data.error) then
		index = 1
		for k,v in pairs(data) do
			list:AddTemplateListItem('buildsBrowser_entry', index, 'index', index, 'name', v.name)

			local i = index
			interface:GetWidget('buildsBrowser_entry_' .. index):SetCallback('onclick', function()
				selectBuild(i)
			end)

			index = index + 1
		end
		if (index > 1) then
			selectBuild(1)
		end
		contentContainer:FadeIn(125)
	else
		failed:FadeIn(125)
	end
	throb:FadeOut(125)
end



--/////////////
-- Web stuff
--/////////////

local function successFunc(request)
	populateBuildList(request)
end

local function failFunc()
	throb:FadeOut(125)
	failed:FadeIn(125)
end

-- When sending a request, change the hero names to fit their system
local externalNameChanges = {}
externalNameChanges['Ladytinder'] = 'tinder'

local function populateBuilds(hero)
	if (lastHeroRequested ~= hero or not data) then
		lastHeroRequested = hero
		data = nil
		clearBuildList()
		throb:FadeIn(125)
		contentContainer:FadeOut(125)
		failed:FadeOut(125)

		local trigger = LuaTrigger.GetTrigger('HeroSelectHeroList'..hero)
		if not trigger then return end
		local requestedName = string.sub(trigger.entityName, 6)
		if (externalNameChanges[requestedName]) then -- Change the name to 3rd party naming scheme
			requestedName = externalNameChanges[requestedName]
		end

		--println("Requesting hero: " .. requestedName .. " From 3rd party site!")
		Strife_Web_Requests:getStrifebuildsBuilds(requestedName, successFunc, failFunc)
	else
		populateBuildList()
	end
end






--/////////////
-- Triggered functions
--/////////////

local function show(trigger)
	if (not GetCvarBool('ui_hadCommunitySiteWarning')) then
		GenericDialogAutoSize(
		'build_browser_warningTitle', 'build_browser_warning', '', 'general_proceed', 'general_cancel', 
			function()
				-- ok
				SetSave('ui_hadCommunitySiteWarning', 'true', 'bool')
				show(trigger)
				
			end,
			function()
				-- cancel				
			end
		)
	else
		fadeWidget(backing, true, 125)
		fadeWidget(container, true, 125)
		populateBuilds(trigger.hero)
	end
end

container:RegisterWatchLua('mainBuildBrowser', function(widget, trigger)
	if (trigger.visible) then
		show(trigger)
	else
		fadeWidget(backing, false, 125)
		fadeWidget(container, false, 125)
	end
end, false, nil, 'visible')